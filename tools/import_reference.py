"""Convierte los catálogos de anthem-master sin ejecutar su JavaScript.

Uso: python3 tools/import_reference.py /ruta/anthem-master/src/resources
"""
import argparse
import json
import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
SOURCE_COMMIT = 'd401a3a732c2871bc571e2b9ff6fde74700044cf'
COLLECTIONS = {
    'ESPECIALES.js': ('hymns_special.json', 154),
    'CORITOS.js': ('choruses.json', 86),
    'ADORACION.js': ('hymns_worship.json', 103),
}
QUOTED = r'"(?:[^"\\]|\\.)*"'
ENTRY = re.compile(
    rf'\{{id:\s*(\d+),title:\s*({QUOTED})\s*,\s*anthem:\s*'
    rf'({QUOTED}|`[\s\S]*?`)'
)
PREFIX = re.compile(r'^\s*\d+\s*\.\s*-\s*')


def read_entries(path):
    source = path.read_text(encoding='utf-8')
    entries = []
    for match in ENTRY.finditer(source):
        identifier, title, lyrics = match.groups()
        title = PREFIX.sub('', json.loads(title)).strip()
        lyrics = lyrics[1:-1] if lyrics.startswith('`') else json.loads(lyrics)
        lines = [line.strip() for line in lyrics.strip().splitlines()]
        # El encabezado ya se muestra en la pantalla de detalle.
        if lines and (PREFIX.match(lines[0]) or lines[0].casefold() == title.casefold()):
            lines.pop(0)
        lyrics = '\n'.join(lines).strip()
        if not title or not lyrics:
            raise ValueError(f'{path.name}: entrada vacía {identifier}')
        entries.append({
            'id': int(identifier),
            'number': int(identifier),
            'title': title,
            'content': {
                'lyrics': lyrics,
                'audio_1': None,
                'audio_2': None,
                'audio_3': None,
            },
        })
    if len(entries) != len(re.findall(r'\{id:', source)):
        raise ValueError(f'{path.name}: hay entradas que no se pudieron convertir')
    if len({entry['id'] for entry in entries}) != len(entries):
        raise ValueError(f'{path.name}: identificadores duplicados')
    return entries


def write_json(path, value):
    path.write_text(json.dumps(value, ensure_ascii=False, indent=2) + '\n', encoding='utf-8')


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('resources', type=Path)
    args = parser.parse_args()
    # Validar todas las fuentes antes de escribir.
    converted = {}
    for source, (destination, expected) in COLLECTIONS.items():
        entries = read_entries(args.resources / source)
        if [entry['number'] for entry in entries] != list(range(1, expected + 1)):
            raise ValueError(f'{source}: numeración distinta de la revisión documentada')
        converted[destination] = entries

    congregational_path = ROOT / 'assets/data/hymns.json'
    existing = json.loads(congregational_path.read_text(encoding='utf-8'))
    reference = read_entries(args.resources / 'himn.js')
    numbered = [entry for entry in reference if entry['number'] <= 293]
    missing = [entry for entry in numbered if entry['number'] not in {h['number'] for h in existing}]
    for entry in missing:
        entry['id'] = max(h['id'] for h in existing) + 1
        existing.append(entry)
    # DOXOLOGÍA ya existe como número 0. SALIDA DEL SOL no lleva número
    # impreso en la referencia: se asigna el siguiente número local (294).
    sunrise = next(h for h in reference if h['title'] == 'SALIDA DEL SOL')
    if not any(h['title'].casefold() == sunrise['title'].casefold() for h in existing):
        sunrise['id'] = max(h['id'] for h in existing) + 1
        sunrise['number'] = max(h['number'] for h in existing) + 1
        existing.append(sunrise)
    existing.sort(key=lambda h: h['number'])
    converted['hymns.json'] = existing
    for destination, entries in converted.items():
        write_json(ROOT / 'assets/data' / destination, entries)
        print(f'{destination}: {len(entries)} entradas')


if __name__ == '__main__':
    main()
