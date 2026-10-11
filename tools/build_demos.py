"""Compile real Typst example documents before their PDFs are embedded in the book.

PDF crop boxes are set on generated fragments only. The source standard PDF is
never read or embedded here. All example text and vectors remain in PDF form.
"""
from pathlib import Path
import argparse, hashlib, json, sys
ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT / '.tools/python'))
from pypdf import PdfReader, PdfWriter
from compile import compile_file, REFERENCE_FONTS, ROMAN_FONTS

def dependencies(profile='open'):
    paths = []
    for folder in ('template', 'book/demos', 'vendor/cetz-0.5.2', 'fonts'):
        paths.extend(p for p in (ROOT / folder).rglob('*') if p.is_file())
    paths += [ROOT / 'book/illustrations.typ', ROOT/'tools/compile.py', ROOT/'tools/build_demos.py']
    digest = hashlib.sha256()
    for p in sorted(paths):
        digest.update(p.relative_to(ROOT).as_posix().encode()); digest.update(p.read_bytes())
    digest.update(('font-profile='+profile).encode())
    fonts = list(REFERENCE_FONTS.rglob('*')) + list(ROMAN_FONTS.glob('times*.ttf')) if profile=='reference' else []
    for p in sorted(fonts):
        if p.is_file() and p.suffix.lower() in ('.ttf','.otf','.ttc'):
            digest.update(p.name.encode());digest.update(p.read_bytes())
    return digest.hexdigest()

def build(force=False, profile='open'):
    target = ROOT / 'book/demo-pdf'; target.mkdir(parents=True, exist_ok=True)
    manifest = target / 'manifest.json'
    key = dependencies(profile)
    if not force and manifest.exists():
        data = json.loads(manifest.read_text('utf8'))
        if data.get('input_sha256') == key and all((ROOT / p['pdf']).is_file() and
            hashlib.sha256((ROOT / p['pdf']).read_bytes()).hexdigest() == p['sha256'] for p in data['examples']):
            print('demo PDFs are current', flush=True); return
    records = []
    for source in sorted((ROOT / 'book/demos').glob('*.typ')):
        if source.name == 'common.typ': continue
        raw = ROOT / 'output/qa/demo-build' / (source.stem + '.pdf')
        compile_file(source, raw, profile=profile)
        reader = PdfReader(raw)
        selected = 1 if source.stem == 'e2' else 0
        writer = PdfWriter(); writer.add_page(reader.pages[selected])
        output = target / (source.stem + '.pdf')
        with output.open('wb') as f: writer.write(f)
        records.append(dict(source=source.relative_to(ROOT).as_posix(), pdf=output.relative_to(ROOT).as_posix(),
            source_pages=len(reader.pages), embedded_page=selected+1, media_box_pt=list(map(float,reader.pages[selected].mediabox)),
            sha256=hashlib.sha256(output.read_bytes()).hexdigest()))
    manifest.write_text(json.dumps(dict(input_sha256=key, font_profile=profile, examples=records, method='native Typst compilation; selected generated PDF page; vector PDF embedding'),ensure_ascii=False,indent=2),'utf8')
    print(f'compiled {len(records)} real examples',flush=True)

if __name__ == '__main__':
    p=argparse.ArgumentParser();p.add_argument('--force',action='store_true');p.add_argument('--font-profile',choices=('open','reference'),default='open');args=p.parse_args();build(args.force,args.font_profile)
