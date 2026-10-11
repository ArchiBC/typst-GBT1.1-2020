"""Build each book with freshly checked fragments from the same font profile."""
import argparse
import hashlib
import json
from pathlib import Path

from bootstrap import prepare
from compile import ROOT, compile_file
from build_demos import build as build_demos, dependencies

BOOKS = {'open': 'gbt-1.1-2020-open-fonts.pdf', 'reference': 'gbt-1.1-2020-replica.pdf'}


def fingerprint(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def book_inputs(profile):
    digest = hashlib.sha256(dependencies(profile).encode())
    for name in ('book/gbt-1.1-2020.typ', 'book/demo-figures.typ', 'book/diagrams.typ'):
        digest.update(name.encode())
        digest.update((ROOT / name).read_bytes())
    return digest.hexdigest()


def build(profiles=('open',), force=False):
    from verify import inspect_file, verify_table_f1, verify_contents_specimen, verify_cover_specimen
    prepare(check_only=True)
    folder = ROOT / 'output/pdf'
    records = []
    for profile in profiles:
        build_demos(force=force, profile=profile)
        pdf = folder / BOOKS[profile]
        compile_file(ROOT / 'book/gbt-1.1-2020.typ', pdf, profile=profile)
        _, _, inspection = inspect_file(pdf, reference=profile=='reference')
        verify_table_f1(pdf)
        manifest = json.loads((ROOT / 'book/demo-pdf/manifest.json').read_text('utf8'))
        demos = []
        for item in manifest['examples']:
            _, _, record = inspect_file(ROOT / item['pdf'], reference=profile=='reference')
            assert record['sha256'] == item['sha256']
            assert record['pages'] == 1 and record['raster_image_objects'] == 0
            stem = Path(item['pdf']).stem
            if stem == 'e8':
                record['contents_specimen'] = verify_contents_specimen(ROOT / item['pdf'])
            if stem in ('e6', 'e7'):
                record['cover_specimen'] = verify_cover_specimen(ROOT / item['pdf'])
            demos.append(record)
        records.append(dict(font_profile=profile, input_sha256=book_inputs(profile), book=inspection,
                            demos=demos, demo_input_sha256=manifest['input_sha256']))
    for source, name in (('examples/standard.typ', 'standard-example.pdf'),
                         ('book/manual.typ', 'template-manual.pdf')):
        compile_file(ROOT / source, folder / name, profile='open')
    report = dict(profiles=records, source_sha256=fingerprint(ROOT / 'book/gbt-1.1-2020.typ'),
                  not_built_in_this_run=[name for p, name in BOOKS.items() if p not in profiles
                                         and (folder / name).exists()])
    (ROOT / 'output/build.json').write_text(json.dumps(report, ensure_ascii=False, indent=2)+'\n', 'utf8')
    return report


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--font-profile', choices=('open', 'reference', 'both'), default='open')
    parser.add_argument('--force-demos', action='store_true')
    args = parser.parse_args()
    profiles = ('open', 'reference') if args.font_profile=='both' else (args.font_profile,)
    build(profiles, force=args.force_demos)
    from verify import main as verify
    verify(profiles=profiles)


if __name__ == '__main__':
    main()
