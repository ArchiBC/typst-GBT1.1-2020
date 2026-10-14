"""Create an offline source bundle after checking the downloaded OFL fonts."""
import hashlib
import json
from pathlib import Path
from zipfile import ZIP_DEFLATED, ZipFile
from bootstrap import prepare

ROOT = Path(__file__).resolve().parents[1]
OUTPUT = ROOT / 'output/typst-gbt-1.1-2020.zip'
PDF_FILES = ('gbt-1.1-2020-open-fonts.pdf', 'gbt-1.1-2020-replica.pdf',
             'standard-example.pdf', 'template-manual.pdf',
             'gb55031-2022-replica.pdf', 'construction-standard-example.pdf')
TOOLS = ('bootstrap.py', 'build.py', 'build_demos.py', 'compile.py', 'clean.py',
         'package.py', 'render_outputs.py', 'verify.py', 'verify_numbering.py', 'verify_alignment.py',
         'verify_bundle.py', 'verify_annex_e.py', 'verify_typography.py', 'verify_explanations.py', 'requirements.txt', 'setup.ps1', 'build.ps1')
FIXTURES = ('alignment.typ', 'typography.typ', 'automatic-numbering.typ', 'book-numbering.json', 'components.typ',
            'gb-mark.typ', 'index-and-merged-cells.typ', 'layout-variants.typ',
            'untitled-contents.typ', 'explanations.typ', 'construction-profile.typ', 'moved-explanations.typ',
            'semantic-content.typ', 'semantic-entry.typ')
FONT_DOCUMENTS = ('README.md', 'manifest.json', 'Liberation-LICENSE.txt',
                  'SourceHanSans-LICENSE.txt', 'SourceHanSerif-LICENSE.txt')


def source_files(folder, suffixes):
    for path in (ROOT / folder).rglob('*'):
        relative = path.relative_to(ROOT)
        if any(part.startswith('.') or part in ('__pycache__', 'tmp', 'cache')
               for part in relative.parts):
            continue
        if path.name.endswith('~') or any(part.lower() in ('.tmp', '.bak', '.part', '.pyc', '.pyo')
                                        for part in path.suffixes):
            continue
        license_file = path.name == 'LICENSE' or path.name.startswith('LICENSE-')
        if path.suffix.lower() not in suffixes and not license_file:
            continue
        if path.is_symlink() or not path.resolve().is_relative_to(ROOT):
            raise ValueError(f'Unsafe bundle path: {relative}')
        if path.is_file():
            yield path


def members():
    files = [ROOT / name for name in ('README.md', 'LICENSE', 'THIRD_PARTY.md',
                                     'typst.toml', 'lib.typ', '.gitignore', '.gitattributes')]
    for folder, suffixes in (('template', {'.typ', '.json', '.txt'}),
                             ('examples', {'.typ'}), ('book', {'.typ', '.png'}),
                             ('vendor', {'.typ', '.toml', '.md', '.wasm'}),
                             ('docs', {'.md', '.json', '.csv'})):
        files.extend(source_files(folder, suffixes))
    files.extend(ROOT / 'tools' / name for name in TOOLS)
    files.extend(ROOT / 'tools/fixtures' / name for name in FIXTURES)
    files.extend(ROOT / 'fonts' / name for name in FONT_DOCUMENTS)
    manifest = json.loads((ROOT / 'fonts/manifest.json').read_text('utf8'))
    for font in manifest:
        name = font['file']
        if Path(name).name != name:
            raise ValueError(f'Unsafe font filename: {name}')
        files.append(ROOT / 'fonts' / name)
    demos = json.loads((ROOT / 'book/demo-pdf/manifest.json').read_text('utf8'))
    files.append(ROOT / 'book/demo-pdf/manifest.json')
    for demo in demos['examples']:
        path = ROOT / demo['pdf']
        if path.parent != ROOT / 'book/demo-pdf' or path.suffix != '.pdf':
            raise ValueError(f'Unsafe demo PDF path: {demo["pdf"]}')
        files.append(path)
    files.extend(ROOT / 'output/pdf' / name for name in PDF_FILES
                 if (ROOT / 'output/pdf' / name).is_file())
    for path in files:
        if path.is_symlink() or not path.resolve().is_relative_to(ROOT):
            raise ValueError(f'Unsafe bundle path: {path}')
    return sorted(set(files))


def main():
    prepare(check_only=True)
    files = members()
    missing = [p.relative_to(ROOT).as_posix() for p in files if not p.is_file()]
    if missing:
        raise SystemExit(f'Missing files: {missing}')
    OUTPUT.parent.mkdir(parents=True, exist_ok=True)
    with ZipFile(OUTPUT, 'w', compression=ZIP_DEFLATED, compresslevel=9) as bundle:
        for path in files:
            bundle.write(path, 'typst-gbt-1.1-2020/'+path.relative_to(ROOT).as_posix())
    with ZipFile(OUTPUT) as bundle:
        assert bundle.testzip() is None
    result = dict(file=OUTPUT.relative_to(ROOT).as_posix(), files=len(files),
                  bytes=OUTPUT.stat().st_size, sha256=hashlib.sha256(OUTPUT.read_bytes()).hexdigest())
    (ROOT / 'output/bundle.json').write_text(json.dumps(result, indent=2)+'\n', 'utf8', newline='\n')
    print(json.dumps(result))


if __name__ == '__main__':
    main()
