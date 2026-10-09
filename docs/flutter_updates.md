# Entorno y actualizaciones

Comprobación realizada el 8 de octubre de 2026 en el equipo local:

- Flutter 3.38.9, canal stable.
- Dart 3.10.8, compatible con `environment.sdk: ^3.10.8`.
- Flutter informa que hay una versión más reciente del SDK.
- `flutter pub outdated` informa de versiones más recientes de dependencias.

Las nuevas secciones no requieren cambiar el SDK ni las dependencias. No se
modificaron `pubspec.yaml` ni `pubspec.lock`.

## Dependencias directas con actualizaciones

Estas son algunas de las versiones que mostró `flutter pub outdated` en esta
comprobación. Consultar nuevamente antes de actualizar: la disponibilidad puede
cambiar y algunas versiones requieren un SDK más reciente.

| Paquete | Versión instalada | Última versión informada |
| --- | --- | --- |
| `just_audio` | 0.9.46 | 0.10.6 |
| `audio_session` | 0.1.25 | 0.2.4 |
| `wakelock_plus` | 1.4.0 | 1.8.1 |
| `path_provider` | 2.1.5 | 2.1.6 |
| `shared_preferences` | 2.5.4 | 2.5.6 |
| `url_launcher` | 6.3.2 | 6.3.3 |
| `flutter_launcher_icons` (desarrollo) | 0.13.1 | 0.14.4 |

La migración de las dependencias de audio debe incluir pruebas de reproducción,
cambio de pista, segundo plano y controles con el dispositivo bloqueado.

## Xcode y pruebas

Xcode tiene pendiente la aceptación de su licencia. `xcrun` con la configuración
actual del equipo lo indica, y `flutter test` falla al compilar la dependencia
nativa `objective_c` antes de ejecutar las pruebas.

Para resolver esa configuración, el propietario del equipo debe revisar y
aceptar la licencia de Xcode. El mensaje del sistema indica:

```bash
sudo xcodebuild -license
```

Las 18 pruebas de himnos y mandamientos se ejecutaron y pasaron usando el SDK de
macOS instalado con Apple Command Line Tools. Se seleccionó ese SDK únicamente
para el proceso de prueba mediante `DEVELOPER_DIR` y un ejecutable temporal de
`xcrun` que conservó esa selección en el hook de compilación. No se cambió
`xcode-select` ni se aceptó la licencia en nombre del usuario.

También pasaron `flutter analyze --no-pub` sin incidencias y la compilación
`flutter build web --no-pub`. No se compiló Android ni iOS ni se verificó la
reproducción en un dispositivo físico.
