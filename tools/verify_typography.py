"""Measure font selection, physical sizes and intentional offsets in the PDF.

The fixture exercises real template components. Expectations use normative
point sizes and the recorded reference measurements, not template internals.
"""
import argparse
import json
import re

from compile import ROOT, compile_file
from verify_alignment import TOLERANCE, baseline, character_pages, find

ROLE_SIZES = {
    'open': {'body': (10.5, 10.5, 10.5), 'black': (10.5, 10.5, 10.5),
             'front-black': (16, 16, 16),
             'note': (9, 9, 9), 'note-black': (9, 9, 9),
             'figure': (7.5, 7.5, 7.5), 'figure-black': (7.5, 7.5, 7.5)},
    'reference': {'body': (9.571, 9.966, 9.966), 'black': (9.569, 9.426, 10.05),
                  'front-black': (14.749, 14.363429, 15.314286),
                  'note': (8.248, 8.542286, 8.542286),
                  'note-black': (8.393, 8.079429, 8.614286),
                  'figure': (6.873333, 7.118571, 7.118571),
                  'figure-black': (6.994167, 6.732857, 7.178571)},
}
SAMPLES = (
    ('body', '正文基准ABCxyz123'), ('black', '混排标题Typography123'),
    ('black', '强调混排Bold456'), ('note', '小五宋体note123'),
    ('note-black', '小五强调Bold456'), ('note-black', '继承黑体Black789'),
    ('note', '小五示例Example123'), ('note-black', '示例强调Strong456'),
    ('note', '常规单元Regular123'), ('note-black', '强调单元Strong456'),
    ('note', '单位Unitmm'), ('note', '单位Figureunitmm'),
    ('figure', '图内文字Figurebody123'), ('figure-black', '图内强调Figurebold456'),
    ('black', '中英表题Table123'), ('black', '中英图题Figure123'),
    ('black', '示例图题Nestedfigure123'), ('figure', '示例图内Nestedbody456'),
    ('note', '脚注内容Footnote123'), ('note-black', '脚注强调Bold456'),
)


def glyph_kind(glyph):
    value = glyph['text']
    if re.fullmatch(r'[\u3400-\u9fff]', value):
        return 0
    if re.fullmatch(r'[A-Za-z]', value):
        return 1
    if re.fullmatch(r'[0-9]', value):
        return 2
    return None


def check_sample(pages, profile, role, sample):
    chars = find(pages, sample)
    error = baseline(chars)
    expected = ROLE_SIZES[profile][role]
    black = role.endswith('black') or role == 'black'
    for glyph in chars:
        kind = glyph_kind(glyph)
        if kind is None:
            continue
        assert abs(glyph['size'] - expected[kind]) < TOLERANCE, (sample, glyph, expected)
        if profile == 'open':
            family = ('SourceHanSans' if black else 'SourceHanSerif') if kind == 0 or (kind == 2 and black) else 'LiberationSerif'
        else:
            family = ('FZHTK' if black else 'FZSSK') if kind == 0 else 'E-FZ' if kind == 2 and black else 'E-HZ' if black else 'TimesNewRoman'
        assert family in glyph['font'], (sample, glyph, family)
        if profile == 'open' and black and kind == 1:
            assert 'Bold' in glyph['font'], (sample, glyph)
    return dict(sample=sample, role=role, physical_sizes_pt=expected, baseline_error_pt=error)


def verify_fixture(path, profile):
    pages = character_pages(path)
    samples = [check_sample(pages, profile, role, sample) for role, sample in SAMPLES]
    samples.append(check_sample(pages[1:], profile, 'front-black', '中英混排检验Typography2026'))
    nested = []
    for sample, role in (('嵌入西文EMBED123', 'note-black'), ('图内嵌套NEST789', 'figure-black')):
        chars = find(pages, sample)
        baseline(chars)
        expected = ROLE_SIZES[profile][role]
        for glyph in chars:
            kind = glyph_kind(glyph)
            if kind is None:
                continue
            assert abs(glyph['size'] - expected[0 if kind == 0 else 1]) < TOLERANCE, (sample, glyph, expected)
            if kind != 0:
                assert ('LiberationSerif-Bold' if profile == 'open' else 'E-HZ') in glyph['font'], (sample, glyph)
        nested.append(dict(sample=sample, physical_sizes_pt=(expected[0], expected[1])))
    shifts = {}
    for sample, expected in (('MRAISE', 2), ('NLOWER', -2)):
        chars = find(pages, sample)
        delta = chars[1]['y'] - chars[0]['y']
        assert abs(delta - expected) < TOLERANCE, (sample, delta, expected)
        assert max(g['y'] for g in chars[1:]) - min(g['y'] for g in chars[1:]) < TOLERANCE
        shifts[sample] = delta
    for sample, expected in (('黑体上移012', 2), ('黑体下移034', -2)):
        chars = find(pages, sample)
        delta = chars[-1]['y'] - chars[-3]['y']
        assert abs(delta - expected) < TOLERANCE, (sample, delta, expected)
        shifts[sample] = delta
    for sample, raised in (('XSUP', True), ('YSUB', False)):
        chars = find(pages, sample)
        delta = chars[1]['y'] - chars[0]['y']
        assert delta > 2 if raised else delta < -1, (sample, delta)
        assert chars[1]['size'] < chars[0]['size'] * .8, (sample, chars)
        shifts[sample] = delta
    tracked = find(pages, '追踪TRACK246')[2:]
    plain = find(pages, '对照TRACK246')[2:]
    extra = (tracked[1]['x'] - tracked[0]['x']) - (plain[1]['x'] - plain[0]['x'])
    assert abs(extra - 1) < TOLERANCE, extra
    mono = find(pages, 'MONO357')
    assert all('DejaVuSansMono' in g['font'] for g in mono), mono
    assert all(abs(g['size'] - ROLE_SIZES[profile]['body'][0]) < TOLERANCE for g in mono), mono
    mono_bold = find(pages, 'MONOBOLD468')
    assert all('DejaVuSansMono' in g['font'] and 'Bold' in g['font'] for g in mono_bold), mono_bold
    assert all(abs(g['size'] - ROLE_SIZES[profile]['body'][0]) < TOLERANCE for g in mono_bold), mono_bold
    custom = find(pages, '自定义字号Custom12pt')
    custom_black = find(pages, '自定义强调Custombold12pt')
    expected_black = 12 if profile == 'open' else 12 * 9.569 / 9.571
    assert abs(custom[0]['size'] - 12) < TOLERANCE
    assert abs(custom_black[0]['size'] - expected_black) < TOLERANCE
    baseline(custom)
    baseline(custom_black)
    extended = find(pages, '扩展字符cafénaïveαβγ')[4:]
    extended_black = find(pages, '扩展粗体cafénaïveαβγАБВ')[4:]
    family = 'LiberationSerif' if profile == 'open' else 'TimesNewRoman'
    assert all(family in g['font'] for g in extended + extended_black), (extended, extended_black)
    assert all('bold' in g['font'].lower() for g in extended_black), extended_black
    assert all(abs(g['size'] - ROLE_SIZES[profile]['body'][1]) < TOLERANCE for g in extended + extended_black)
    baseline(extended)
    baseline(extended_black)
    italic = find(pages, 'italic789')
    assert all('Italic' in g['font'] and family in g['font'] for g in italic), italic
    symbols = []
    for sample in ('商标®', '版权©', '标识TM'):
        glyph = find(pages, sample)[-1]
        assert family in glyph['font'], (sample, glyph)
        assert abs(glyph['size'] - ROLE_SIZES[profile]['body'][1]) < TOLERANCE, (sample, glyph)
        symbols.append(dict(symbol=sample, font=glyph['font'], size_pt=glyph['size']))
    return dict(file=path.relative_to(ROOT).as_posix(), pages=len(pages), samples=samples, nested_fonts=nested,
                intentional_shifts_pt=shifts, extra_tracking_pt=extra,
                custom_font_preserved=True, custom_size_inherited=True,
                extended_scripts_use_roman=True, italic_preserved=True, symbols=symbols)


def verify_native_demos(profile):
    path = ROOT / 'book/demo-pdf/subfigures.pdf'
    pages = character_pages(path)
    samples = [check_sample(pages, profile, role, sample) for role, sample in (
        ('note-black', 'a)分图题'), ('note-black', 'b)分图题'), ('black', '图X图题'))]
    continuation = character_pages(ROOT / 'book/demo-pdf/table-page.pdf')
    samples.append(check_sample(continuation, profile, 'black', '表3'))
    samples.append(check_sample(continuation, profile, 'body', '第2页/共5页'))
    baseline(find(continuation, '表3(第2页/共5页)'))
    return dict(profile=profile, samples=samples, subfigure_caption_size_verified=True,
                continuation_uses_song=True)


def main(profiles=('open',)):
    from verify import inspect_file
    records = []
    for profile in profiles:
        path = ROOT / f'output/qa/typography-{profile}.pdf'
        compile_file(ROOT / 'tools/fixtures/typography.typ', path, profile=profile)
        records.append(dict(profile=profile, fixture=verify_fixture(path, profile),
                            inspection=inspect_file(path, reference=profile == 'reference')[2]))
    manifest = json.loads((ROOT / 'book/demo-pdf/manifest.json').read_text('utf8'))
    report = dict(passed=True, tolerance_pt=TOLERANCE, artifacts=records,
                  native_demos=verify_native_demos(manifest['font_profile']))
    (ROOT / 'output/qa/typography-verification.json').write_text(
        json.dumps(report, ensure_ascii=False, indent=2) + '\n', 'utf8')
    print('PASS mixed font sizes, inherited emphasis, explicit baselines, scripts, tracking and custom fonts')
    return report


if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('--font-profile', choices=('open', 'reference', 'both'), default='open')
    args = parser.parse_args()
    main(('reference', 'open') if args.font_profile == 'both' else (args.font_profile,))
