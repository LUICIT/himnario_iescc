import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:just_audio/just_audio.dart';
import 'package:audio_session/audio_session.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'package:path_provider/path_provider.dart';

import '../model/hym.dart';

class TrackOption {
  final String key; // audio_1, audio_2, audio_3
  final String label;
  final String assetPath;

  TrackOption({
    required this.key,
    required this.label,
    required this.assetPath,
  });
}

class HymnDetailScreen extends StatefulWidget {
  final Hymn hymn;

  const HymnDetailScreen({super.key, required this.hymn});

  @override
  State<HymnDetailScreen> createState() => _HymnDetailScreenState();
}

class _HymnDetailScreenState extends State<HymnDetailScreen> {
  final AudioPlayer _player = AudioPlayer();
  AudioSession? _session;
  Uri? _artUri;

  bool _fullScreen = false;
  Set<String> _assetManifestPaths = const {};
  bool _manifestLoaded = false;
  bool _initialLoading = true;

  late List<TrackOption> _tracks;
  TrackOption? _selected;
  bool _loadingAudio = false;

  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;

  StreamSubscription<Duration>? _posSub;
  StreamSubscription<Duration?>? _durSub;
  StreamSubscription<PlayerState>? _playerStateSub;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _bootstrap();
    });

    _tracks = _buildAvailableTracks(widget.hymn);
    _configureAudioSession();
    _prepareArtwork();

    // Suscripciones de progreso
    _posSub = _player.positionStream.listen((p) {
      if (!mounted) return;
      setState(() => _position = p);
    });

    _durSub = _player.durationStream.listen((d) {
      if (!mounted) return;
      setState(() => _duration = d ?? Duration.zero);
    });

    _playerStateSub = _player.playerStateStream.listen((state) async {
      if (!mounted) return;

      // When the audio finishes, reset to start and ensure UI reflects a stopped state.
      if (state.processingState == ProcessingState.completed) {
        await _player.stop();
        await WakelockPlus.disable();
        await _session?.setActive(false);
        await _player.seek(Duration.zero);
        setState(() {
          _position = Duration.zero;
        });
      }
    });

    // Si hay tracks, preselecciona el primero y trata de cargarlo
    if (_tracks.isNotEmpty) {
      _selected = _tracks.first;
      // _loadSelectedTrack();
    }
  }

  Future<void> _configureAudioSession() async {
    final session = await AudioSession.instance;
    await session.configure(const AudioSessionConfiguration.music());
    _session = session;
  }

  Future<void> _prepareArtwork() async {
    try {
      // iOS lock screen artwork generally requires a file:// or http(s):// URI.
      // asset:/// URIs often show as a transparent square.
      final bytes = await rootBundle.load('assets/images/logo.png');
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/iescc_logo.png');
      await file.writeAsBytes(bytes.buffer.asUint8List(), flush: true);
      if (!mounted) return;
      setState(() {
        _artUri = Uri.file(file.path);
      });
    } catch (_) {
      // If we can't prepare artwork, just omit it.
      // Lock screen controls will still work.
    }
  }

  Future<void> _bootstrap() async {
    // Keep the loading UI visible for a minimum time to avoid a “blink”.
    const minLoading = Duration(milliseconds: 450);
    final startedAt = DateTime.now();

    await _loadAssetManifest();

    final elapsed = DateTime.now().difference(startedAt);
    final remaining = minLoading - elapsed;
    if (!remaining.isNegative) {
      await Future.delayed(remaining);
    }

    if (!mounted) return;
    setState(() => _initialLoading = false);
  }

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    _posSub?.cancel();
    _durSub?.cancel();
    _playerStateSub?.cancel();
    WakelockPlus.disable();
    _session?.setActive(false);
    _player.dispose();
    super.dispose();
  }

  Future<void> _loadAssetManifest() async {
    try {
      final manifestJson = await rootBundle.loadString('AssetManifest.json');
      final Map<String, dynamic> manifest =
          jsonDecode(manifestJson) as Map<String, dynamic>;
      final keys = manifest.keys;
      _assetManifestPaths = keys.toSet();
      _manifestLoaded = true;
    } catch (e) {
      // If manifest fails (rare), we still allow attempting setAsset.
      _assetManifestPaths = const {};
      _manifestLoaded = true;
    }
  }

  bool _assetExists(String path) {
    if (!_manifestLoaded) return true; // don't block while loading
    if (_assetManifestPaths.isEmpty) return true; // fall back to trying
    return _assetManifestPaths.contains(path);
  }

  List<TrackOption> _buildAvailableTracks(Hymn hymn) {
    final c = hymn.content;

    final list = <TrackOption>[];

    if ((c.audio1 ?? '').trim().isNotEmpty) {
      list.add(
        TrackOption(
          key: 'audio_1',
          label: 'Versión antigua',
          assetPath: c.audio1!.trim(),
        ),
      );
    }
    if ((c.audio2 ?? '').trim().isNotEmpty) {
      list.add(
        TrackOption(
          key: 'audio_2',
          label: 'Versión nueva',
          assetPath: c.audio2!.trim(),
        ),
      );
    }
    if ((c.audio3 ?? '').trim().isNotEmpty) {
      list.add(
        TrackOption(
          key: 'audio_3',
          label: 'Karaoke / Pista',
          assetPath: c.audio3!.trim(),
        ),
      );
    }

    return list;
  }

  Future<void> _loadSelectedTrack() async {
    final track = _selected;
    if (track == null) return;

    setState(() => _loadingAudio = true);

    try {
      if (kDebugMode) debugPrint('Trying asset: ${track.assetPath}');
      if (kDebugMode) debugPrint('Manifest loaded: $_manifestLoaded');

      // Pre-check to avoid iOS AVPlayer errors when the asset path is wrong or not bundled.
      if (!_assetExists(track.assetPath)) {
        throw StateError('Asset not found in bundle: ${track.assetPath}');
      }

      final hymn = widget.hymn;
      final mediaItem = MediaItem(
        id: '${hymn.id}:${track.key}',
        album: 'Himnario IESCC',
        title: '${hymn.number}. ${hymn.title}',
        artist: track.label,
        // Use a file:// URI for iOS lock screen artwork.
        artUri: _artUri,
      );

      await _player.setAudioSource(
        AudioSource.asset(track.assetPath, tag: mediaItem),
      );
      // si quieres autoplay, descomenta:
      // await _player.play();
    } on Object catch (e, st) {
      // en la siguiente linea con un log de e para saber que error tiene
      if (kDebugMode) {
        debugPrint(
          'Audio load failed for: ${track.assetPath} (${track.label})',
        );
        debugPrint('Error: $e');
        debugPrint('Stack: $st');
      }
      // Si el asset no existe o falla, quitamos la opción y seguimos con lo que haya
      _tracks.removeWhere((t) => t.key == track.key);
      _selected = _tracks.isNotEmpty ? _tracks.first : null;

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('No se pudo cargar ${track.label}')),
        );
      }

      if (_selected != null) {
        await _loadSelectedTrack();
      }
    } finally {
      if (mounted) setState(() => _loadingAudio = false);
    }
  }

  Future<void> _togglePlayPause() async {
    if (_loadingAudio) return;

    if (_player.playing) {
      await _player.pause();
      await WakelockPlus.disable();
      await _session?.setActive(false);
    } else {
      // Si por alguna razón no hay duración/carga aún, intenta cargar
      if (_selected != null &&
          (_player.audioSource == null || _duration == Duration.zero)) {
        await _loadSelectedTrack();
      }

      // Si después de intentar cargar no hay fuente, no hacemos play.
      if (_player.audioSource == null) return;

      // If we're at the end, restart from the beginning.
      if (_duration != Duration.zero && _position >= _duration) {
        await _player.seek(Duration.zero);
      }

      await _session?.setActive(true);
      await _player.play();
      await WakelockPlus.enable();
    }
    if (mounted) setState(() {});
  }

  Future<void> _seekToSeconds(double seconds) async {
    final target = Duration(seconds: seconds.floor());
    await _player.seek(target);
  }

  String _format(Duration d) {
    String two(int n) => n.toString().padLeft(2, '0');
    final m = two(d.inMinutes.remainder(60));
    final s = two(d.inSeconds.remainder(60));
    final h = d.inHours;
    return h > 0 ? '${two(h)}:$m:$s' : '$m:$s';
  }

  Future<void> _toggleFullScreen() async {
    final next = !_fullScreen;
    setState(() => _fullScreen = next);

    if (next) {
      await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    } else {
      await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    }
  }

  @override
  Widget build(BuildContext context) {
    final hymn = widget.hymn;

    final loadingScaffold = Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E2A78),
        foregroundColor: Colors.white,
        title: Text('${hymn.number}. ${hymn.title}'),
      ),
      body: const Center(child: CircularProgressIndicator()),
    );

    final contentScaffold = Scaffold(
      appBar: _fullScreen
          ? null
          : AppBar(
              backgroundColor: const Color(0xFF1E2A78),
              foregroundColor: Colors.white,
              title: Text('${hymn.number}. ${hymn.title}'),
              actions: [
                IconButton(
                  tooltip: 'Pantalla completa',
                  onPressed: _toggleFullScreen,
                  icon: const Icon(Icons.fullscreen),
                ),
              ],
            ),
      body: Stack(
        children: [
          Column(
            children: [
              if (!_fullScreen && _tracks.isNotEmpty) _buildAudioPanel(),
              if (!_fullScreen) const Divider(height: 1),
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          minHeight: constraints.maxHeight,
                        ),
                        child: Center(
                          child: Text(
                            hymn.content.lyrics,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 16,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
          if (_fullScreen)
            Positioned(
              top: 24,
              right: 16,
              child: SafeArea(
                child: FloatingActionButton.small(
                  heroTag: 'exit_fullscreen',
                  onPressed: _toggleFullScreen,
                  child: const Icon(Icons.fullscreen_exit),
                ),
              ),
            ),
        ],
      ),
    );

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 250),
      child: _initialLoading
          ? KeyedSubtree(key: const ValueKey('loading'), child: loadingScaffold)
          : KeyedSubtree(key: const ValueKey('content'), child: contentScaffold),
    );
  }

  Widget _buildAudioPanel() {
    final hasAudio = _tracks.isNotEmpty;

    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Selector de versión (solo muestra disponibles)
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final t in _tracks)
                ChoiceChip(
                  label: Text(t.label),
                  selected: _selected?.key == t.key,
                  onSelected: (_) async {
                    // Regla UX: no permitir cambiar de audio mientras se está reproduciendo.
                    if (_player.playing || _loadingAudio) {
                      if (!mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Pausa el audio antes de cambiar de versión.'),
                          duration: Duration(milliseconds: 1000),
                        ),
                      );
                      return;
                    }

                    // Detener y reiniciar el reproductor antes de cambiar de pista.
                    await _player.stop();
                    await _player.seek(Duration.zero);

                    setState(() {
                      _selected = t;
                      _position = Duration.zero;
                      _duration = Duration.zero;
                    });
                  },
                ),
            ],
          ),

          const SizedBox(height: 10),

          if (hasAudio)
            Row(
              children: [
                IconButton(
                  iconSize: 32,
                  onPressed: _loadingAudio ? null : _togglePlayPause,
                  icon: Icon(
                    _player.playing ? Icons.pause_circle : Icons.play_circle,
                  ),
                ),
                Expanded(
                  child: _loadingAudio
                      ? const LinearProgressIndicator()
                      : Slider(
                          min: 0,
                          max: (_duration.inSeconds > 0)
                              ? _duration.inSeconds.toDouble()
                              : 1,
                          value: (_position.inSeconds.clamp(
                            0,
                            _duration.inSeconds,
                          )).toDouble(),
                          onChanged: (_duration.inSeconds > 0)
                              ? (v) => _seekToSeconds(v)
                              : null,
                        ),
                ),
              ],
            ),

          if (hasAudio)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [Text(_format(_position)), Text(_format(_duration))],
            ),
        ],
      ),
    );
  }
}
