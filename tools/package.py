"""Create an offline source bundle after checking the downloaded OFL fonts."""
import hashlib
import json
from pathlib import Path
from zipfile import ZIP_DEFLATED, ZipFile
from bootstrap import prepare

ROOT = Path(__file__).resolve().parents[1]
OUTPUT = ROOT / 'output/typst-gbt-1.1-2020.zip'
PDF_FILES = ('gbt-1.1-2020-open-fonts.pdf', 'gbt-1.1-2020-replica.pdf',
             'standard-example.pdf', 'template-manual.pdf')


def members():
    files = [ROOT / name for name in ('README.md', 'LICENSE', 'THIRD_PARTY.md',
                                     'typst.toml', 'lib.typ', '.gitignore', '.gitattributes')]
    for folder in ('template', 'examples', 'book', 'fonts', 'tools', 'vendor', 'docs'):
        files.extend(p for p in (ROOT / folder).rglob('*') if p.is_file()
                     and '__pycache__' not in p.parts and 'reference' not in p.relative_to(ROOT).parts
                     and p.suffix not in ('.pyc', '.part'))
    files.extend(ROOT / 'output/pdf' / name for name in PDF_FILES
                 if (ROOT / 'output/pdf' / name).is_file())
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
    (ROOT / 'output/bundle.json').write_text(json.dumps(result, indent=2)+'\n', 'utf8')
    print(json.dumps(result))


if __name__ == '__main__':
    main()
