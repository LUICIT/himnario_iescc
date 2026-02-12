# Himnario IESCC

Aplicación móvil desarrollada en **Flutter** para la reproducción y lectura de himnos de la iglesia IESCC. La aplicación permite visualizar la letra de los himnos, reproducir distintas versiones de audio y utilizar controles desde la pantalla bloqueada del dispositivo.

---

## 📱 Descripción General

Himnario IESCC es una aplicación multiplataforma (Android e iOS) que:

- Muestra el listado completo de himnos.
- Permite visualizar la letra completa de cada himno.
- Reproduce hasta 3 versiones de audio por himno:
  - Versión antigua
  - Versión nueva
  - Karaoke / pista instrumental
- Permite pantalla completa para lectura.
- Mantiene la pantalla activa únicamente mientras el audio está en reproducción.
- Permite reproducción en segundo plano (background audio).
- Integra controles de reproducción en pantalla bloqueada (Play/Pause).
- Muestra metadatos del himno en la pantalla bloqueada (título, versión y carátula).

---

## 🏗 Arquitectura del Proyecto

El proyecto está desarrollado completamente en Flutter utilizando:

- `just_audio` para la reproducción de audio.
- `just_audio_background` para soporte de controles en pantalla bloqueada.
- `audio_session` para configuración correcta del audio en iOS.
- `wakelock_plus` para evitar que la pantalla se apague mientras el audio está activo.

Los himnos y audios se cargan desde archivos locales dentro del proyecto (`assets`).

### Estructura principal

```
lib/
 ├── main.dart
 ├── home_screen.dart
 ├── hymn_detail_screen.dart
 ├── model/
 │    ├── hym.dart
 │    └── hymn_content.dart
assets/
 ├── data/hymns.json
 ├── images/logo.png
 └── audio/
      ├── karaoke/
      ├── new/
      └── old/
```

---

## ⚙️ Requisitos Previos

- Flutter SDK instalado
- Xcode (para iOS)
- Android Studio (para Android)
- Dispositivo físico o simulador

Verificar instalación:

```bash
flutter doctor
```

---

## 🚀 Configuración del Proyecto

1. Clonar el repositorio

```bash
git clone https://github.com/LUICIT/himnario_iescc.git
cd himnario_iescc
```

2. Instalar dependencias

```bash
flutter pub get
```

3. Ejecutar en modo desarrollo

```bash
flutter run
```

4. Ejecutar en modo release (recomendado para pruebas reales)

```bash
flutter run --release
```

---

## 🍎 Configuración Especial para iOS (Audio en Background)

Para permitir que el audio continúe reproduciéndose cuando el dispositivo se bloquea:

1. Abrir `ios/Runner.xcworkspace` en Xcode.
2. Ir a **Signing & Capabilities**.
3. Agregar la capability **Background Modes**.
4. Activar:
   - Audio, AirPlay, and Picture in Picture.

Esto habilita la reproducción en segundo plano y controles en pantalla bloqueada.

---

## 🎵 Funcionamiento del Reproductor

- El audio solo se carga cuando el usuario presiona "Play".
- No es posible cambiar de versión mientras el audio está reproduciéndose.
- Al finalizar el audio:
  - Se detiene automáticamente.
  - El tiempo vuelve a 00:00.
- Si el usuario bloquea el dispositivo:
  - El audio continúa.
  - Se muestran controles de reproducción en la pantalla bloqueada.

---

## 📦 Gestión de Assets

Todos los himnos y audios están almacenados localmente dentro del proyecto.

Si se agregan nuevos audios o archivos:

```bash
flutter clean
flutter pub get
flutter run
```

Flutter genera automáticamente el `AssetManifest.json` durante el build.

---

## 🔄 Futuras Actualizaciones

Todas las nuevas funcionalidades, mejoras o cambios (por mínimos que sean) serán documentados en un archivo separado llamado:

```
CHANGELOG.md
```

En dicho archivo se registrará:

- Nuevas funcionalidades
- Corrección de errores
- Mejoras de rendimiento
- Cambios en arquitectura
- Ajustes menores

Este README describe únicamente el estado actual de la aplicación.

---

## 🧭 Estado Actual del Proyecto

La aplicación actualmente:

- Funciona completamente offline.
- Reproduce audio en background.
- Soporta controles en lock screen.
- Mantiene la pantalla activa solo mientras el audio está sonando.
- Permite lectura cómoda de los himnos.

---

Proyecto desarrollado con Flutter.
