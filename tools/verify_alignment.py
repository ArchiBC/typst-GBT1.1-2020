"""Check alignment in rendered output, including transformed vector fragments."""
import ctypes
import json
from pathlib import Path
import re
import sys
import unicodedata

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT / '.tools/python'))
import pypdfium2 as pdfium
from pypdfium2 import raw
from compile import compile_file

TOLERANCE = .01  # PDF coordinates are in physical points.


def normalize(text):
    return re.sub(r'\s+', '', unicodedata.normalize('NFKC', text))


def character_pages(path):
    pages = []
    with pdfium.PdfDocument(path) as document:
        for number, page in enumerate(document, 1):
            chars = []
            text = page.get_textpage()
            try:
                for index in range(text.count_chars()):
                    value = raw.FPDFText_GetUnicode(text.raw, index)
                    # PDFium exposes supplementary math letters as UTF-16 pairs.
                    if 0xD800 <= value <= 0xDBFF and index + 1 < text.count_chars():
                        low = raw.FPDFText_GetUnicode(text.raw, index + 1)
                        assert 0xDC00 <= low <= 0xDFFF
                        value = 0x10000 + (value - 0xD800) * 0x400 + low - 0xDC00
                    elif 0xDC00 <= value <= 0xDFFF:
                        continue
                    char = normalize(chr(value)) if value else ''
                    if not char or raw.FPDFText_IsGenerated(text.raw, index):
                        continue
                    matrix = raw.FS_MATRIX()
                    raw.FPDFText_GetMatrix(text.raw, index, ctypes.byref(matrix))
                    if abs(matrix.b) > .0001 or abs(matrix.c) > .0001:
                        continue
                    x, y = ctypes.c_double(), ctypes.c_double()
                    raw.FPDFText_GetCharOrigin(text.raw, index, ctypes.byref(x), ctypes.byref(y))
                    buffer, flags = ctypes.create_string_buffer(256), ctypes.c_int()
                    raw.FPDFText_GetFontInfo(text.raw, index, buffer, 256, ctypes.byref(flags))
                    chars.append(dict(text=char, page=number, x=x.value, y=y.value,
                        right=text.get_charbox(index)[2], font=buffer.value.decode('utf8'),
                        size=raw.FPDFText_GetFontSize(text.raw, index) * abs(matrix.d)))
            finally:
                text.close()
            pages.append(chars)
            page.close()
    return pages


def find(pages, value):
    wanted, matches = normalize(value), []
    for chars in pages:
        expanded = [g for g in chars for _ in g['text']]
        text = ''.join(g['text'] for g in chars)
        matches += [expanded[m.start():m.end()] for m in re.finditer(re.escape(wanted), text)]
    assert len(matches) == 1, (value, len(matches))
    return matches[0]


def baseline(*groups):
    chars = [g for group in groups for g in group]
    assert len({g['page'] for g in chars}) == 1
    delta = max(g['y'] for g in chars) - min(g['y'] for g in chars)
    assert delta < TOLERANCE, (''.join(g['text'] for g in chars), delta)
    return delta


def verify_fixture(path):
    pages = character_pages(path)
    errors = {'mixed_text': baseline(*(find(pages, s) for s in ('中文与', 'ABC', '123')))}
    for prefix, body in (('注1：', '单行注基线'), ('注2：', '多行注首行'), ('注：', '表注首行')):
        label, description = find(pages, prefix), find(pages, body)
        errors[body] = baseline(label, description)
        assert 0 <= description[0]['x'] - label[-1]['right'] < description[0]['size']
    errors['table_cells'] = baseline(find(pages, '粗体单元格'), find(pages, '常规单元格'))
    for first, continuation in (('多行注首行', '多行注续行'), ('表注首行', '表注续行'),
                                ('表脚注首行', '表脚注续行')):
        a, b = find(pages, first)[0], find(pages, continuation)[0]
        assert abs(a['x'] - b['x']) < TOLERANCE, (first, a, b)
        assert a['x'] < 110, (first, a)  # Must not inherit table centering.
    for symbol, meaning in (('v', '速度释义'), ('l', '距离释义'), ('t', '时间释义'),
                            ('x', '横坐标释义'), ('y', '纵坐标释义')):
        description = find(pages, meaning)
        anchor = description[0]
        variable = [g for g in pages[anchor['page'] - 1] if g['text'] == symbol
            and 'NewCMMath' in g['font'] and g['x'] < anchor['x']
            and abs(g['y'] - anchor['y']) < 2]
        assert len(variable) == 1, (symbol, variable)
        errors[meaning] = baseline(variable, description)
        assert anchor['x'] < 160, (meaning, anchor)
    number = find(pages, '（1）')
    equation = [g for g in pages[number[0]['page'] - 1] if 'NewCMMath' in g['font']
        and g['text'] == 'x' and abs(g['y'] - number[0]['y']) < 2]
    assert len(equation) == 1
    errors['equation_number'] = baseline(equation, number)
    superscripts = [g for g in pages[number[0]['page'] - 1] if 'NewCMMath' in g['font']
        and g['text'] == '2' and 2 < g['y'] - number[0]['y'] < 5]
    assert len(superscripts) == 3, superscripts
    return dict(file=path.relative_to(ROOT).as_posix(), baseline_errors_pt=errors,
        wrapped_notes_share_left_edge=True, table_notes_left_aligned=True,
        formula_definitions_left_aligned=True, superscripts_preserved=True)


def text_runs(pages):
    result = []
    for chars in pages:
        current = None
        for g in chars:
            if (current and current['font'] == g['font']
                    and abs(current['size'] - g['size']) < .001
                    and abs(current['y'] - g['y']) < .001
                    and -.1 <= g['x'] - current['right'] < g['size'] * 1.4):
                current['text'] += g['text']
                current['right'] = g['right']
            else:
                current = dict(g)
                result.append(current)
    return result


def verify_book(path):
    pages = character_pages(path)
    publisher = [find(pages[:1], name)[0]['x'] for name in
                 ('国家市场监督管理总局', '国家标准化管理委员会')]
    assert abs(publisher[0] - publisher[1]) < TOLERANCE, publisher
    term = find(pages, '包含某个或多个特定领域普遍适用的条款（3.3.1）的标准（3.1.2）。')
    term_error = baseline(term)
    diagram_error = baseline(find(pages, '标准代号和顺序号段（见'), find(pages, '特性段（见'))
    notes, largest_note_error = 0, 0
    for chars in pages:
        for index, g in enumerate(chars):
            if g['text'] != '注' or not any(f in g['font'] for f in ('FZHTK', 'SourceHanSans')):
                continue
            prefix = re.match(r'注\d*:', ''.join(c['text'] for c in chars[index:index + 8]))
            if not prefix:
                continue
            end = index + len(prefix.group())
            largest_note_error = max(largest_note_error, baseline(chars[index:end], [chars[end]]))
            gap = chars[end]['x'] - chars[end - 1]['right']
            # Adjacent CJK punctuation compresses the space before an opening quote.
            minimum = -chars[end]['size'] * .5 if chars[end]['text'] == '“' else -.01
            assert minimum <= gap < chars[end]['size'] * 1.5, (g, chars[end], gap)
            notes += 1
    assert notes >= 25, notes
    comparisons, intentional = 0, []
    runs = text_runs(pages)
    for a, b in zip(runs, runs[1:]):
        gap, delta = b['x'] - a['right'], abs(a['y'] - b['y'])
        if (a['page'] != b['page'] or not 0 <= gap < 180 or delta >= 3.5
                or abs(a['size'] - b['size']) >= 2.5 or min(a['y'], b['y']) < 70
                or not re.search(r'[\u3400-\u9fff]', a['text'] + b['text'])
                or any('NewCMMath' in g['font'] for g in (a, b))):
            continue
        # A merged cell is centered across several rows; drawing dimensions
        # use their own anchors. These do not share a paragraph baseline.
        if ((a['text'], b['text']) == ('必备', '资料性')
                or (a['text'] == '附加信息' and b['text'].startswith('条文、注、脚注'))
                or (a['text'], b['text']) == ('25', '1范围')):
            intentional.append(dict(page=a['page'], first=a['text'], second=b['text'], delta_pt=delta))
            continue
        assert delta < .02, (a, b, delta)
        comparisons += 1
    return dict(file=path.relative_to(ROOT).as_posix(), pages_scanned=len(pages),
        publisher_left_edges_pt=publisher, term_reference_error_pt=term_error,
        diagram_label_error_pt=diagram_error, note_labels_checked=notes,
        max_note_baseline_error_pt=largest_note_error, ordinary_pairs_checked=comparisons,
        intentional_offsets=intentional)


def main(profiles=('open',)):
    reports = []
    for profile in profiles:
        fixture = ROOT / f'output/qa/alignment-{profile}.pdf'
        compile_file(ROOT / 'tools/fixtures/alignment.typ', fixture, profile=profile)
        book = ROOT / ('output/pdf/gbt-1.1-2020-' +
                       ('replica' if profile == 'reference' else 'open-fonts') + '.pdf')
        reports.append(dict(profile=profile, fixture=verify_fixture(fixture), book=verify_book(book)))
    output = dict(passed=True, tolerance_pt=TOLERANCE, artifacts=reports)
    (ROOT / 'output/qa/alignment-verification.json').write_text(
        json.dumps(output, ensure_ascii=False, indent=2) + '\n', 'utf8')
    print('PASS rendered baselines, publisher edges, wrapped notes, table cells and formula definitions')
    return output


if __name__ == '__main__':
    import argparse
    parser = argparse.ArgumentParser()
    parser.add_argument('--font-profile', choices=('open', 'reference', 'both'), default='open')
    args = parser.parse_args()
    main(profiles=('reference', 'open') if args.font_profile == 'both' else (args.font_profile,))
