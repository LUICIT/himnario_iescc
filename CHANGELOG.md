# Changelog

Todos los cambios notables se documentarán en este archivo.

---

## [2.0.0] - 2026-02-19

### 🚀 Mejoras importantes

- Refactor completo del sistema de rutas.
- Separación de rutas en `AppRoutes`.
- Implementación de manejo global de rutas desconocidas (`onUnknownRoute`).

---

### 📱 Nuevas Pantallas

#### 🏗 Pantalla "En desarrollo"

- Se muestra automáticamente cuando una ruta existe en `menu.json` pero aún no está implementada.
- Incluye botón para regresar al inicio.

#### ❌ Pantalla "No encontrada"

- Se muestra cuando la ruta no existe en la aplicación.
- En Web redirige automáticamente al inicio.
- En móvil muestra botón "Volver al inicio".

#### 📖 Pantalla de Home

- Nueva sección de bienvenida más edificante.
- Inclusión de versículo (Colosenses 3:16 RVR09).
- Mejor organización visual.

#### ℹ️ Pantalla "Acerca de"

- Información del desarrollador.
- Motivación del proyecto.
- Botones de redes sociales.
- Soporte para enlaces externos:
    - Web → abre nueva pestaña.
    - Móvil → abre navegador externo.
    - Email → abre aplicación de correo (`mailto:`).

---

### ✍️ Mejoras en Hymn Detail

- Botón flotante para ajustar el tamaño de la letra.
- Control dinámico mediante `Slider`.
- Disponible tanto en modo normal como en pantalla completa.
- Mejora de experiencia para usuarios con dificultad visual.

---

### 🌐 Web

- Soporte para favicon personalizado.
- Mejora en manejo de rutas inválidas en GitHub Pages.

---

### 🎨 Modernización

- Actualización de uso de `withOpacity()` → `withValues(alpha:)`.
- Limpieza de imports no utilizados.
- Optimización de estructura general del proyecto.

---

## [1.0.0]

- Lanzamiento inicial.
- Listado de himnos desde JSON local.
- Reproducción de hasta 3 audios por himno.
- Soporte para modo pantalla completa.
- Controles en pantalla bloqueada.
