# Changelog

Todos los cambios notables se documentarán en este archivo.

---

## [2.1.0] - 2026-10-08

### Nuevas funcionalidades

- Se habilitan Himnos Especiales (154) y Coros (86) desde archivos JSON.
- Se añade Himnos de Adoración (103) al menú y a las rutas.
- Se añade SALIDA DEL SOL como número local 294, con un total de 295
  himnos congregacionales.
- Se habilita Mandamientos con tres secciones, 23 grupos y 66 pasajes,
  organizados en partes, grupos y referencias bíblicas estructuradas.
- La lectura de Mandamientos permite seleccionar y copiar texto y ajustar
  el tamaño de letra entre 12 y 28.
- En monitores, el ancho de lectura de Mandamientos varía proporcionalmente
  con la letra. La columna permanece centrada y no excede la ventana.
  En ventanas de hasta 800 píxeles lógicos conserva el ancho disponible
  y los márgenes interiores de 16.

### Datos y mantenimiento

- Las cuatro colecciones de himnos comparten el formato JSON y las pantallas
  de lista y lectura. Se conservan las letras y audios congregacionales existentes.
- Se reemplaza la copia de congregacionales en `hymns_special.json` por
  el catálogo de especiales. Las nuevas colecciones tienen sus audios en `null`.
- Se añade `commandments.json` sin referencias a páginas, conservando las
  cuatro partes de Jesús y la numeración propia de los diez mandamientos.
- Se unen los pasajes divididos entre imágenes y se corrige la referencia
  a 2 Corintios 6:17.
- Se actualiza la lectura del manifiesto de assets a `AssetManifest` y se incluye
  la colección en el identificador de reproducción para evitar coincidencias.
- Se añaden conversor de catálogos y documentación del formato y del entorno.
- Se eliminan imports y métodos sin uso y se sustituye un uso de `withOpacity`.
- Se reemplaza la prueba de contador por pruebas de catálogos, referencias,
  navegación y adaptación del ancho de lectura.
- No se añaden dependencias ni se cambia la versión del SDK.

### Validación

- 19 pruebas aprobadas mediante Apple Command Line Tools.
- Análisis de Flutter sin incidencias.
- Compilación web verificada al incorporar los catálogos y Mandamientos.
- La reproducción en un dispositivo físico queda pendiente de verificar.

### Pendiente

- Lemas y pensamientos, hasta recibir su contenido.

## [2.0.1] - 2026-02-23

### 🚀 Mejoras

- Se agrega indicación al usuario de donde desplegar el drawer.
- Se agrega enlace para encuesta de satisfacción del usuario..

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
