# Lemas y pensamientos

El catálogo `assets/data/slogans_thoughts.json` tiene dos listas principales:

- `introductory_texts`: Nuestro esfuerzo, Grito de batalla y Lema adicional,
  en ese orden.
- `author_groups`: los apóstoles y la Junta de Arzobispos, con sus lemas anuales.

No contiene divisiones por partes ni referencias a páginas. Cada lista tiene
IDs enteros consecutivos desde 1: los textos iniciales usan 1–3, los grupos 1–9,
y las entradas de cada grupo vuelven a comenzar en 1. El año se guarda por
separado en `year`; no se utiliza como identificador.

## Agrupación

| Grupo | Años | Entradas |
| --- | --- | ---: |
| Ap. Daddy John | 1938–1953 | 16 |
| Ap. Miguel Ángel Hernández | 1954–1961 | 8 |
| Ap. Arturo Rangel | 1962–1966 | 5 |
| Junta de Arzobispos | 1967–1988 | 22 |
| Ap. Florentino Almeida | 1989–2000 | 12 |
| Ap. Luis Cruz | 2001–2002 | 2 |
| Ap. Joel Mondejar | 2003–2004 | 2 |
| Ap. Cecilio García | 2005–2009 | 5 |
| Ap. Miguel Rodríguez | 2010–2023 | 14 |

Son 86 lemas, con un año por entrada y sin huecos. La agrupación y los nombres
siguen las indicaciones del usuario. La firma del Ap. Santiago Mata Solano
corresponde a años posteriores no incluidos en este catálogo.

`start_year` y `end_year` delimitan el periodo de cada grupo. `type` es `apostle`
o `council`, según corresponda.

## Formato de las entradas

```json
{
  "id": 1,
  "year": 1938,
  "title": "1938",
  "content": {
    "text": "Cada miembro un obrero."
  }
}
```

Un título sin encabezado adicional muestra únicamente el año. Los encabezados
se normalizan poniendo primero el año:

- `1943 - ¡Fíjese en la luz roja!`
- `1947 - Lema doble`
- `1956 - Triple lema`
- `1998 - Lema doble`

Los lemas dobles y triples son una sola entrada con párrafos separados por
`\n\n`. Se unió la continuación del lema de 1998. Los textos iniciales usan
el mismo formato `id`, `title`, `content.text`, sin el campo `year`.

Las fechas impresas como 1848 y 1871 se guardan como 1948 y 1971, de acuerdo con
la secuencia anual y los periodos confirmados. Se retiran los guiones debidos
a cortes de línea y las indicaciones de página. Las referencias bíblicas y el
texto de los lemas permanecen dentro de `content.text`.

## Lectura

El menú Lemas y Pensamientos abre primero los tres textos iniciales y después
los nueve grupos. Cada grupo abre su listado de años; cada año abre el texto
completo con el autor. El lector permite seleccionar y copiar texto y ajustar
la letra entre 12 y 28. El ancho máximo es 800, con margen interior de 16;
el ancho proporcional a la letra sigue limitado a Mandamientos.

El modelo está en `lib/model/slogans_thoughts.dart`; el índice y los años, en
`lib/app/slogans_thoughts_screen.dart`; la lectura, en
`lib/app/thought_detail_screen.dart`.

Las pruebas verifican la numeración, la cobertura anual y las atribuciones,
los títulos y párrafos, la ausencia de partes y páginas, la navegación desde
el menú y la lectura con letra grande en móvil.
