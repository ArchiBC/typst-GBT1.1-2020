"""Rebuild a fresh source bundle with bundled fonts and no original PDF."""
from pathlib import Path
from zipfile import ZipFile
import datetime
import hashlib
import json
import os
import subprocess
import sys

ROOT=Path(__file__).resolve().parents[1]


def main():
    bundle=ROOT/'output/typst-gbt-1.1-2020.zip'
    folder=ROOT/'output/tmp'/('portable-'+datetime.datetime.now().strftime('%Y%m%d-%H%M%S-%f'))
    assert folder.resolve().is_relative_to((ROOT/'output/tmp').resolve())
    folder.mkdir(parents=True,exist_ok=False)
    with ZipFile(bundle) as archive:
        for member in archive.infolist():
            assert (folder/member.filename).resolve().is_relative_to(folder.resolve()),member.filename
        archive.extractall(folder)
    project=folder/'typst-gbt-1.1-2020'
    assert not (project/'GBT+1.1-2020.pdf').exists()
    assert not (project/'.tools').exists()
    env=dict(os.environ)
    # Only compiler libraries come from the host. All document and font inputs
    # come from the extraction; reference and Windows font directories are absent.
    env['PYTHONPATH']=str(ROOT/'.tools/python')+os.pathsep+env.get('PYTHONPATH','')
    env['GBT_REFERENCE_FONTS']=str(project/'no-reference-fonts')
    env['GBT_ROMAN_FONTS']=str(project/'no-system-fonts')
    subprocess.run([sys.executable,'-X','utf8','tools/build.py','--font-profile','open'],
                   cwd=project,env=env,check=True)
    sys.path.insert(0,str(ROOT/'.tools/python'))
    sys.path.insert(0,str(project/'tools'))
    from verify import inspect_file,compact
    from pypdf import PdfReader
    pdf=project/'output/pdf/gbt-1.1-2020-open-fonts.pdf'
    reader,text,inspection=inspect_file(pdf)
    baseline=PdfReader(ROOT/'output/pdf/gbt-1.1-2020-open-fonts.pdf')
    assert len(reader.pages)==len(baseline.pages)
    assert [compact(t) for t in text]==[compact(p.extract_text() or '') for p in baseline.pages]
    assert inspection['raster_image_objects']==0
    source=Path('book/gbt-1.1-2020.typ')
    assert (project/source).read_bytes()==(ROOT/source).read_bytes()
    manifest=json.loads((project/'book/demo-pdf/manifest.json').read_text('utf8'))
    assert manifest['font_profile']=='open' and len(manifest['examples'])==32
    for demo in manifest['examples']:
        _,_,record=inspect_file(project/demo['pdf'])
        assert record['pages']==1 and record['raster_image_objects']==0
        assert record['sha256']==demo['sha256']
    result=dict(passed=True,bundle_sha256=hashlib.sha256(bundle.read_bytes()).hexdigest(),
                extraction_directory=str(project),font_profile='open',pages=len(reader.pages),
                source_pdf_required=False,reference_fonts_required=False,
                fresh_demo_fragments=len(manifest['examples']),
                same_page_text_as_delivered_open_pdf=True,main_inspection=inspection)
    (ROOT/'output/bundle-verification.json').write_text(json.dumps(result,ensure_ascii=False,indent=2),'utf8')
    print(json.dumps({k:v for k,v in result.items() if k not in ('main_inspection','extraction_directory')},ensure_ascii=False))


if __name__=='__main__':main()
