# Catálogos del himnario

Cada colección es una lista JSON con el mismo formato que los congregacionales:

```json
[
  {
    "id": 1,
    "number": 1,
    "title": "Título del himno",
    "content": {
      "lyrics": "Primera línea\nSegunda línea\n\nCORO\nLetra del coro",
      "audio_1": null,
      "audio_2": null,
      "audio_3": null
    }
  }
]
```

`id` identifica la entrada dentro de su colección. `number` indica el número que
se muestra en la lista y en el detalle. Ambos deben ser enteros únicos dentro de
cada archivo. El título no incluye el número. La letra conserva los saltos de
línea y las indicaciones de estrofas y repeticiones de la fuente.

Los campos de audio admiten una ruta local a un archivo incluido en los assets,
o `null` cuando no hay grabación. `audio_1` corresponde a la versión antigua;
`audio_2`, a la nueva; `audio_3`, a karaoke o pista. No usar identificadores de
Google Drive ni enlaces web en estos campos: el reproductor carga assets locales.

| Archivo en `assets/data/` | Entradas | Numeración |
| --- | ---: | --- |
| `hymns.json` | 295 | 0–294 |
| `hymns_special.json` | 154 | 1–154 |
| `choruses.json` | 86 | 1–86 |
| `hymns_worship.json` | 103 | 1–103 |

## Procedencia y conversión

Las colecciones se convirtieron de los archivos `ESPECIALES.js`, `CORITOS.js`
y `ADORACION.js` del [proyecto de referencia anthem-master](https://github.com/jromeroblessed/anthem-master/tree/d401a3a732c2871bc571e2b9ff6fde74700044cf/src/resources),
revisión `d401a3a732c2871bc571e2b9ff6fde74700044cf`, consultada el 8 de octubre de 2026.
Se quitó el encabezado repetido de la letra y se normalizaron espacios al comienzo
y al final de cada línea. No se corrigió ni reinterpretó el texto de las letras.
Las nuevas colecciones no tienen grabaciones asociadas en esos archivos.

Los 294 congregacionales locales (0–293) ya cubrían los himnos numerados de
`himn.js`. Se conservaron sus letras, identificadores y audios. Se añadió
`SALIDA DEL SOL`, que figura sin número impreso al final de la referencia, con
el siguiente número local, 294, e identificador 295. Esta numeración es propia
de esta aplicación. `DOXOLOGÍA` conserva el número local 0.

El archivo de especiales anterior contenía 153 entradas congregacionales sin
`number`; se reemplazó por la colección de especiales de la referencia.

Para repetir la conversión, obtener los cuatro archivos JavaScript de esa
revisión en una carpeta y ejecutar:

```bash
python3 tools/import_reference.py /ruta/a/resources
```

El conversor lee texto sin ejecutar JavaScript, valida el número de entradas
antes de escribir y conserva los congregacionales locales. Repetirlo no añade
otra copia de `SALIDA DEL SOL`. Las colecciones nuevas se regeneran: guardar
por separado cualquier edición o audio propio antes de volver a importarlas.

## Secciones pendientes

Mandamientos ya está disponible y utiliza una estructura propia, documentada en
[commandments.md](commandments.md). Lemas y pensamientos mantienen su pantalla
actual hasta recibir el contenido del usuario. `slogans_thoughts.json` todavía contiene opciones de
menú; no es un catálogo de pensamientos y no se carga como tal.

## Validación

```bash
flutter analyze
flutter test
```

Las pruebas comprueban el formato y la numeración de las cuatro colecciones,
la carga de cada ruta y la navegación del menú a adoración. La reproducción
en segundo plano debe verificarse en un dispositivo Android o iOS.

El resultado de la validación y las particularidades de Xcode se registran en
[flutter_updates.md](flutter_updates.md).
