# Mandamientos

`assets/data/commandments.json` guarda el contenido con esta jerarquía:

```text
schema_version
sections
  id, title
  parts
    id, number, title
    groups
      id, number, title
      passages
        reference: book, chapter, verses
        text
        commandment_number (opcional)
```

No incluye `source_page`, números de página ni referencias al soporte original.
Los textos se guardan como cadenas, con `\n\n` cuando un pasaje tiene varios
párrafos, y se cargan desde los assets para su lectura sin conexión.

## Estructura y contenido

| Sección | Partes tituladas | Grupos | Pasajes |
| --- | ---: | ---: | ---: |
| Mandamientos de Dios el Padre | Ninguna | 5 | 14 |
| Mandamientos de Jesús Dios el Hijo | 4 | 15 | 46 |
| Mandamientos del Espíritu Santo | Ninguna | 3 | 6 |

`schema_version` es `1`. El lector rechaza versiones que no conoce para evitar
interpretar un formato incompatible.

Los identificadores son cadenas únicas. `number` conserva el número del grupo
o de la parte. La numeración de grupos empieza de nuevo en cada parte de Jesús.

Padre y Espíritu Santo tienen una sola entrada en `parts`, con `number` y `title`
en `null`. El lector muestra directamente sus grupos, sin inventar un título de
parte. Un grupo sin encabezado también tiene `title: null`.

Cada pasaje tiene una referencia con el nombre completo del libro, el capítulo
y la lista de versículos. El lector muestra rangos consecutivos, por ejemplo
`Malaquías 3:8-10`. Los pasajes que abarcan varias líneas o párrafos mantienen
su texto completo en una entrada.

Los diez mandamientos de Éxodo conservan sus grupos y usan además
`commandment_number`, del 1 al 10. Ese campo no se utiliza para numerar los
otros pasajes ni sustituye al número de grupo.

La referencia del texto «Por lo cual salid de en medio de ellos…» es
**2 Corintios 6:17**, corregida con confirmación del usuario. No se reemplazó
el texto por el de otra traducción.

## Lectura en Flutter

La ruta `/commandments` abre las tres secciones. Al seleccionar una, el lector
muestra sus partes, grupos y pasajes en orden. Permite seleccionar y copiar
texto y ajustar el tamaño de letra entre 12 y 28.

En ventanas de más de 800 píxeles lógicos, el ancho máximo de la columna varía
con el tamaño de letra: 800 con letra 16, 992 con letra 20, 1184 con letra 24 y
1376 con letra 28. Se escala el área de texto y se conservan los 16 píxeles de
margen interior a cada lado. La columna permanece centrada y siempre cabe en
la ventana. También se tiene en cuenta la escala de texto del sistema.

En ventanas de hasta 800 píxeles lógicos, se utiliza todo el ancho disponible
con los mismos márgenes interiores, cualquiera que sea el tamaño de letra.
Este comportamiento se aplica únicamente a la lectura de Mandamientos.

Los modelos están en `lib/model/commandments.dart`, la lista en
`lib/app/commandments_screen.dart` y la lectura en
`lib/app/commandment_detail_screen.dart`.

## Pruebas

`test/commandments_test.dart` comprueba la estructura, los identificadores y la
numeración, las continuaciones de los pasajes, la referencia corregida, la
navegación desde el menú, el ajuste de letra en una pantalla estrecha y el
ancho proporcional de lectura en monitores. Incluye
una comprobación de que no existe `source_page` en ningún nivel del catálogo.
