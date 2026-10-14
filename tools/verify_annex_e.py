"""Inspect generated Annex E lettering and vector geometry, never source text."""
import ctypes
import json
from pathlib import Path
import re
import sys

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT / '.tools/python'))
import pypdfium2 as pdfium
from pypdfium2 import raw

MM = 72 / 25.4


def capture(path):
    with pdfium.PdfDocument(path) as doc:
        page = doc[0]
        text = page.get_textpage()
        chars = []
        for i in range(text.count_chars()):
            value = raw.FPDFText_GetUnicode(text.raw, i)
            if not value or raw.FPDFText_IsGenerated(text.raw, i):
                continue
            char = chr(value)
            if char.isspace():
                continue
            x, y = ctypes.c_double(), ctypes.c_double()
            raw.FPDFText_GetCharOrigin(text.raw, i, ctypes.byref(x), ctypes.byref(y))
            left, bottom, right, top = text.get_charbox(i)
            chars.append(dict(text=char, x=x.value / MM, y=y.value / MM,
                              left=left / MM, right=right / MM,
                              top=(page.get_size()[1] - top) / MM,
                              bottom=(page.get_size()[1] - bottom) / MM))
        rules = []
        for obj in page.get_objects():
            if obj.type == raw.FPDF_PAGEOBJ_PATH:
                left, bottom, right, top = obj.get_bounds()
                if right - left > 400:
                    rules.append(dict(center_x=(left + right) / 2 / MM,
                                      y=(page.get_size()[1] - (bottom + top) / 2) / MM,
                                      width=(right - left) / MM))
        text.close()
        page.close()
    return chars, rules


def span(chars, value):
    text = ''.join(g['text'] for g in chars)
    start = text.find(re.sub(r'\s+', '', value))
    assert start >= 0, (value, text)
    return chars[start:start + len(re.sub(r'\s+', '', value))]


def same_baseline(chars):
    error = (max(g['y'] for g in chars) - min(g['y'] for g in chars)) * MM
    assert error < .01, (''.join(g['text'] for g in chars), error)
    return error


def verify_native(profile):
    records = []
    counts = {1: 88, 2: 88, 6: 2, 7: 4, 8: 132, 9: 86, 10: 299, 11: 46, 12: 86}
    for n in range(1, 13):
        path = ROOT / f'book/demo-pdf/e{n}.pdf'
        chars, rules = capture(path)
        plain = ''.join(g['text'] for g in chars)
        assert not any(s in plain for s in ('else', 'specimen-', 'reference', 'font:')), (n, plain)
        assert plain.count('×') == counts.get(n, 0), (n, plain.count('×'))
        record = dict(figure=f'E.{n}', placeholders=plain.count('×'))
        if n not in (4, 5, 6, 7):
            header = span(chars, 'GB/TXXXXX—XXXX')
            assert abs(min(g['top'] for g in header) - 25) < .3
            assert min(g['left'] for g in header) >= (19.5 if n == 2 else 152)
        if n in (1, 2):
            marks = [g for g in chars if g['text'] == '×']
            assert sum(abs(g['top'] - 34) < .3 for g in marks) == 44
            assert sum(abs(g['top'] - 38) < .3 for g in marks) == 44
            # The final multiplication glyph extends 0.6 mm beyond its cell.
            assert max(g['right'] for g in marks) < (185.7 if n == 2 else 190.7)
            # The footer is drawn before the placeholder paragraph.
            footer = [g for g in chars if g['text'] == 'X' and g['top'] > 270]
            assert len(footer) == 2 and max(g['bottom'] for g in footer) < 277.5
        if n == 4:
            assert abs(max(g['right'] for g in chars) - 205) < .3
            assert abs(min(g['top'] for g in chars) - 25) < .3
        if n in (5, 6, 7):
            names = {5: '国家标准发布部门', 6: '行业标准发布部门', 7: '地方标准发布部门'}
            name = span(chars, names[n])
            fa = [g for g in chars if g['text'] == '发'][-1]
            bu = [g for g in chars if g['text'] == '布'][-1]
            record['publisher_baseline_error_pt'] = same_baseline(name + [fa, bu])
            issued = span(chars, 'XXXX-XX-XX发布')
            implemented = span(chars, 'XXXX-XX-XX实施')
            record['date_baseline_error_pt'] = same_baseline(issued + implemented)
            code = {5: 'GB/T', 6: 'XX/T', 7: 'DBXX/T'}[n]
            serial = 'XXX' if n == 7 else 'XXXXX'
            record['replacement_baseline_error_pt'] = same_baseline(span(chars, '代替' + code + serial + '—XXXX'))
            title = span(chars, '标准名称')
            center = (min(g['left'] for g in title) + max(g['right'] for g in title)) / 2
            assert abs(center - 105) < .6, (n, center)
            record['title_ink_center_mm'] = center
            assert len(rules) == 2
            for expected in (75, 257):
                assert any(abs(rule['y'] - expected) < .01 and abs(rule['width'] - 170) < 1 for rule in rules)
            if n == 6:
                category = span(chars, '中华人民共和国××行业标准')
                record['category_baseline_error_pt'] = same_baseline([g for g in category if g['text'] != '×'])
            if n == 7:
                crosses = [g for g in chars if g['text'] == '×']
                for g, expected in zip(crosses, (25, 41, 57, 73)):
                    assert abs(g['left'] - expected) < .15
                    assert abs(g['right'] - g['left'] - 7) < .15
                    assert abs(g['bottom'] - g['top'] - 7) < .15
        if n == 8:
            assert '前言III' in plain and '引言IV' in plain
            # The final table-list entry must reach the lower printed band.
            last = span(chars, '表A.1' + '×' * 7 + '12')
            assert 268 < min(g['top'] for g in last) < 273
        if n == 11:
            for letter, band in (('A', (50, 60)), ('B', (130, 140))):
                group = [g for g in chars if g['text'] == letter and band[0] < g['top'] < band[1]]
                assert len(group) == 1, (letter, group)
                g = group[0]
                assert abs((g['left'] + g['right']) / 2 - 111.8) < .3
                assert 1 < g['right'] - g['left'] < 1.7
        records.append(record)
    return dict(font_profile=profile, figures=records, source_text_extraction_used=False)


if __name__ == '__main__':
    manifest = json.loads((ROOT / 'book/demo-pdf/manifest.json').read_text('utf8'))
    print(json.dumps(verify_native(manifest['font_profile']), ensure_ascii=False, indent=2))
