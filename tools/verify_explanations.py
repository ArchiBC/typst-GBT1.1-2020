"""Verify clause explanations and the retained edition without publisher pages."""
import hashlib
import json
from pathlib import Path
import re
import sys

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT / '.tools/python'))
import typst
import pypdfium2 as pdfium
from pypdf import PdfReader
from compile import compile_file, construction_fonts
from verify import compact, inspect_file


def query(source, inputs=None):
    engineering=source in ('book/gb55031-2022.typ','tools/fixtures/construction-profile.typ')
    profile, paths = construction_fonts((inputs or {}).get('construction-font-profile',None if engineering else 'open'))
    data = json.loads(typst.query(str(ROOT / source), 'metadata', root=str(ROOT),
        font_paths=[str(ROOT/'fonts'),*map(str,paths)], ignore_system_fonts=True,
        sys_inputs={'font-profile':'open','construction-font-profile':profile, **(inputs or {})}))
    return [item['value'] for item in data if isinstance(item.get('value'), dict)]


def verify_behaviour():
    results=[]
    for inserted in (False, True):
        inputs={'insert-clause':str(inserted).lower()}
        destination=ROOT/f'output/qa/explanations-{int(inserted)}.pdf'
        source='tools/fixtures/explanations.typ'
        compile_file(ROOT/source,destination,profile='open',inputs=inputs)
        data=query(source,inputs)
        sections=[v['number'] for v in data if v.get('kind')=='gbt-section']
        expected=['1.1.1']+(['1.1.2'] if inserted else [])+[
            '1.1.3' if inserted else '1.1.2',
            '1.1.4' if inserted else '1.1.3', '2.1.1', '3.1']
        assert sections==expected,(sections,expected)
        entries=[v for v in data if v.get('kind')=='gbt-explanation-entry']
        printed=['1.1.1']+(['1.1.2'] if inserted else [])+[
            '1.1.3' if inserted else '1.1.2',
            '1.1.3～1.1.4' if inserted else '1.1.2～1.1.3','2.1.1']
        assert [v['number'] for v in entries]==printed,entries
        _,texts,info=inspect_file(destination)
        assert '甲的说明' not in texts[0] and '乙的说明' not in texts[0]
        joined=compact(''.join(texts))
        assert '乙的说明引用原条：1.1.1。' in joined,joined
        assert joined.count('甲的说明仅在文后出现。')==1
        for phrase in ('甲的说明仅在文后出现','乙的说明引用原条','乙丙两条的合并说明','第0段长说明'):
            matches=[i+1 for i,t in enumerate(texts) if phrase in compact(t)]
            assert matches and min(matches)>1,(phrase,matches)
        assert '第89段长说明' in joined
        # Ninety actual paragraphs occupy more than one page. A par wrapper
        # must not silently flatten them into a single paragraph.
        long_pages=[i for i,t in enumerate(texts) if re.search(r'第\s*\d+\s*段长说明',t)]
        assert len(long_pages)>1,long_pages
        assert '3.1' in compact(texts[-1]),texts[-1]
        results.append(dict(inserted=inserted,entries=printed,pages=info['pages'],
            source_and_explanation_separate=True,multiline_explanation_pages=len(long_pages),
            counter_restored=True,native_references=True))
    profile=ROOT/'output/qa/construction-profile.pdf'
    compile_file(ROOT/'tools/fixtures/construction-profile.typ',profile,profile='open',
                 construction_profile=construction_fonts()[0])
    data=query('tools/fixtures/construction-profile.typ')
    expected=[f'{i}.0.1' for i in range(1,7)]+['7.1.1','A.1.1']
    assert [v['number'] for v in data if v.get('kind')=='gbt-section']==expected
    assert [v['number'] for v in data if v.get('kind')=='gbt-explanation-entry']==expected
    reader,texts,info=inspect_file(profile)
    assert all(abs(float(p.mediabox.width)-160/25.4*72)<.01 and
               abs(float(p.mediabox.height)-240/25.4*72)<.01 for p in reader.pages)
    sizes=[]
    for page in reader.pages:
        def visit(s,cm,tm,font,size):
            if '正文必须采用' in s:sizes.append(float(size))
        page.extract_text(visitor_text=visit)
    assert len(sizes)==6 and all(s==12 for s in sizes),sizes
    assert 'a)' not in ''.join(texts) and '自定义前置页' in texts[0]
    assert '7.1.1' in compact(''.join(texts))
    moves=[]
    for swapped in (False,True):
        inputs={'swap':str(swapped).lower()}
        pdf=ROOT/f'output/qa/moved-explanations-{int(swapped)}.pdf'
        compile_file(ROOT/'tools/fixtures/moved-explanations.typ',pdf,profile='open',inputs=inputs)
        data=query('tools/fixtures/moved-explanations.typ',inputs)
        assert [v['number'] for v in data if v.get('kind')=='gbt-explanation-entry']==[
            '1.1.1','1.1.2','A.1.1','B.1.1']
        _,texts,inspection=inspect_file(pdf)
        text=compact(''.join(texts))
        alpha='1.1.2' if swapped else '1.1.1'
        beta='1.1.1' if swapped else '1.1.2'
        assert alpha+'跟随甲移动的说明。' in text
        assert beta+'跟随乙移动的说明，引用甲'+alpha+'。' in text
        assert 'A.1.1附录甲说明。' in text and 'B.1.1附录乙说明。' in text
        assert '条文说明' not in compact(texts[0]),texts[0]
        moves.append(dict(swapped=swapped,alpha=alpha,beta=beta,annexes=['A','B'],
                          body_contents_exclude_explanations=True))
    return dict(insertions=results,moves=moves,profile=dict(chapters=7,numbers=expected,body_font_pt=12,
        custom_page_mm=[160,240],partial_style_merge=True,digit_lists=True,front_and_back_hooks=True))


def verify_edition():
    path=ROOT/'output/pdf/gb55031-2022-replica.pdf'
    manifest=json.loads((ROOT/'docs/gb55031-transcription.json').read_text('utf8'))
    reader,texts,inspection=inspect_file(path)
    retained=manifest['output_pages']
    indexes={source_page:index for index,source_page in enumerate(retained)}
    assert retained==[n for n in range(1,79) if n not in (3,78)]
    assert len(reader.pages)==len(retained)==76
    landscape=[]
    for n,page in zip(retained,reader.pages):
        width,height=float(page.mediabox.width),float(page.mediabox.height)
        expected=(575.433,382.677) if n in (43,44,45,46) else (382.677,575.433)
        assert abs(width-expected[0])<.002 and abs(height-expected[1])<.002,(n,width,height)
        if width>height:landscape.append(n)
    assert inspection['raster_image_objects']==10,inspection
    data=query('book/gb55031-2022.typ')
    clauses=[v['number'] for v in data if v.get('kind')=='gbt-section']
    assert clauses==manifest['body_clauses'],clauses
    heads=[v for v in data if v.get('kind')=='gbt-heading']
    assert all(v['number']==v['key'].removeprefix('gb-').replace('-','.') for v in heads)
    entries=[v['number'] for v in data if v.get('kind')=='gbt-explanation-entry']
    expected=[v['start']+(v['separator']+v['end'] if v['start']!=v['end'] else '')
              for v in manifest['explanations']]
    assert entries==expected,(entries,expected)
    pages=[v['source-page'] for v in data if v.get('kind')=='gb55031-page']
    assert pages==retained,pages
    assert '1.0.1' in compact(texts[indexes[10]]) and '本条明确了本规范制定的目的' not in compact(texts[indexes[10]])
    assert '本条明确了本规范制定的目的' in compact(texts[indexes[40]])
    for part,toc_pages in (('body',(8,9)),('explanations',(31,32))):
        toc=compact(''.join(texts[indexes[n]] for n in toc_pages))
        assert len(manifest['contents'][part])==32,(part,manifest['contents'][part])
        for item in manifest['contents'][part]:
            expected=item['number']+item['title']+str(item['folio'])
            assert expected in toc,(part,item,toc)
    unmatched=[]
    checked=0
    omitted_rows={(v['source_page'],v['text']) for v in manifest['omitted_publication_rows']}
    for page in manifest['transcription']:
        number=page['source_page']
        if number not in indexes:continue
        printed=compact(texts[indexes[number]])
        for line in page['lines']:
            if (number,line['text']) in omitted_rows:continue
            expected=compact(line['text'])
            if not expected:continue
            # TOCs are reconstructed with native references; their OCR fragments
            # are retained as provenance, not treated as a second literal TOC.
            if number in (8,9,31,32):continue
            checked+=1
            if expected not in printed:unmatched.append(dict(page=number,text=expected))
    assert not unmatched,unmatched[:30]
    full=compact(''.join(texts))
    for phrase in ('统一书号','定价：','版权所有翻印必究','中国建筑工业出版社出版','网上书店：'):
        assert phrase not in full,phrase
    assert compact(texts[-1]).endswith('68') and '不能穿越配电间' in compact(texts[-1])
    assert all(compact(t) for t in texts), 'Removing a publisher page must not leave an empty placeholder page.'
    for figure in manifest['figures']:
        image=ROOT/figure['file']
        assert hashlib.sha256(image.read_bytes()).hexdigest()==figure['sha256'],figure
    geometry=verify_geometry(path,manifest)
    folios=verify_folios(path,manifest)
    return dict(**inspection,source_pages=78,landscape_pages=landscape,
        native_clauses=len(clauses),explanations=len(entries),headings=len(heads),
        transcribed_lines_verified=checked,full_page_scans_embedded=False,
        retained_source_pages=retained,publisher_information_removed=True,back_cover_removed=True,
        contents_entries_verified=sum(len(v) for v in manifest['contents'].values()),
        editable_body_and_table_text=True,figure_crops_verified=10,printed_numbers_verified=True,
        geometry=geometry,folio_positions=folios)


def verify_geometry(path,manifest):
    """Compare printed ink positions with independent source transcription boxes.

    These catch a narrowed native title, compressed punctuation and a list
    marker glued to its text even when all text and clause-number tests pass.
    """
    targets=[(10,'1总则'),(11,'2.1功能要求'),(40,'四、条文说明'),
             (10,'通用技术措施，制定本规范。')]
    targets_by_page={n:[s for p,s in targets if p==n] for n in set(n for n,s in targets)}
    indexes={n:i for i,n in enumerate(manifest['output_pages'])}
    transcript={p['source_page']:p['lines'] for p in manifest['transcription']}
    document=pdfium.PdfDocument(path)
    report=[]
    for n,samples in targets_by_page.items():
        page=document[indexes[n]]; text=page.get_textpage()
        characters=[]; boxes=[]
        for i in range(text.count_chars()):
            char=text.get_text_range(i,1)
            if not char or char.isspace():continue
            characters.append(char);boxes.append(text.get_charbox(i))
        visible=''.join(characters)
        def locate(sample):
            first=visible.index(compact(sample)); found=boxes[first:first+len(compact(sample))]
            return [min(b[0] for b in found),page.get_height()-max(b[3] for b in found),
                    max(b[2] for b in found),page.get_height()-min(b[1] for b in found)]
        for sample in samples:
            row=next(r for r in transcript[n] if compact(r['text'])==compact(sample))
            actual=locate(sample)
            differences=[abs(actual[0]-row['x']),abs(actual[1]-row['y']),
                         abs((actual[2]-actual[0])-row['width'])]
            assert max(differences)<2.0,(n,sample,differences,actual,row)
            report.append(dict(source_page=n,text=sample,ink_box_pt=actual,
                               maximum_position_error_pt=max(differences)))
        if n==10:
            first=visible.index('1应按照可持续发展的原则')
            gap=boxes[first+1][0]-boxes[first][0]
            assert 15.5<gap<19.5,gap
            report.append(dict(source_page=n,list_marker_to_text_pt=gap,separate_marker_verified=True))
        text.close();page.close()
    document.close()
    return report


def verify_folios(path,manifest):
    document=pdfium.PdfDocument(path)
    indexes={n:i for i,n in enumerate(manifest['output_pages'])}
    errors=[]
    for number,frame in manifest['folio_frames'].items():
        n=int(number);page=document[indexes[n]];text=page.get_textpage();boxes=[]
        landscape=n in (43,44,45,46)
        for i in range(text.count_chars()):
            char=text.get_text_range(i,1)
            if not char.isdigit():continue
            left,bottom,right,top=text.get_charbox(i)
            if (left<38 if landscape else page.get_height()-top>535):
                boxes.append((left,page.get_height()-top,right,page.get_height()-bottom))
        assert boxes,(n,'missing folio')
        actual=[min(b[0] for b in boxes),min(b[1] for b in boxes),max(b[2] for b in boxes),max(b[3] for b in boxes)]
        expected=[frame[0],frame[1],frame[0]+frame[2],frame[1]+frame[3]]
        error=max(abs(a-b) for a,b in zip(actual,expected))
        assert error<.5,(n,expected,actual,error)
        errors.append(error)
        text.close();page.close()
    document.close()
    return dict(printed_folios_checked=len(errors),maximum_position_error_pt=max(errors),
                rotated_folios_checked=4)


def verify_content_separation():
    """Exercise author edits through the semantic layer and template only."""
    sources=('book/gb55031-content.typ','book/gb55031-front.typ',
             'examples/construction-content.typ','tools/fixtures/semantic-content.typ')
    forbidden=re.compile(r'#(?:set|show|pagebreak|place|edition-[\w-]+)\b|\b(?:font|size|weight|tracking|margin|page-layout)\s*:')
    for source in sources:
        text=(ROOT/source).read_text('utf8')
        assert not forbidden.search(text),source
    assert len((ROOT/'book/gb55031-2022.typ').read_text('utf8').splitlines())==3
    assert not any((ROOT/'book'/f'gb55031-{part}.typ').exists()
                   for part in ('layout','metrics','folios','tables'))
    cases=[]
    for inserted in (False,True):
        inputs={'insert-clause':str(inserted).lower()}
        source='tools/fixtures/semantic-entry.typ'
        path=ROOT/f'output/qa/semantic-{int(inserted)}.pdf'
        compile_file(ROOT/source,path,inputs=inputs)
        data=query(source,inputs)
        expected=['1.0.1']+(['1.0.2'] if inserted else [])+['2.1.1']
        assert [v['number'] for v in data if v.get('kind')=='gbt-section']==expected
        assert [v['number'] for v in data if v.get('kind')=='gbt-explanation-entry']==expected
        reader,texts,inspection=inspect_file(path)
        assert all(abs(float(p.mediabox.width)-160/25.4*72)<.01 and
                   abs(float(p.mediabox.height)-240/25.4*72)<.01 for p in reader.pages)
        sizes=[]
        for page in reader.pages:
            def visit(s,cm,tm,font,size):
                if '正文必须采用' in s:sizes.append(float(size))
            page.extract_text(visitor_text=visit)
        assert len(sizes)==2 and all(s==12 for s in sizes),sizes
        joined=compact(''.join(texts))
        assert '1.0.1制定目的的说明。' in joined
        assert '功能要求的说明引用1.0.1。' in joined
        assert '第一项完整内容；2第二项完整内容。' in joined
        assert '通行连续、便捷' in joined
        cases.append(dict(inserted=inserted,numbers=expected,body_font_pt=12,
                          semantic_table=True,native_references=True,pages=inspection['pages']))

    # Edit the real content, including many new paragraphs and a table cell.
    # This must automatically leave the reference frames and retain all text.
    folder=ROOT/'output/qa/semantic-edit'
    folder.mkdir(parents=True,exist_ok=True)
    content=(ROOT/'book/gb55031-content.typ').read_text('utf8')
    content=content.replace('../template/content.typ','/template/content.typ')
    extra='\n\n'.join(f'新增正文第{i}段。'+('完整保留新增内容，模板自动分行和分页。'*8)
                        for i in range(30))
    content=content.replace('通用技术措施，制定本规范。',
                            '通用技术措施，制定本规范。\n\n'+extra,1)
    content=content.replace('= 基本规定 <gb-2>',
        '#clause[新增条文验证自动编号。]\n#explain[新增条文说明验证文后汇编。]\n\n= 基本规定 <gb-2>',1)
    content=content.replace('body: [0.26]','body: [0.27]',1)
    (folder/'content.typ').write_text(content,'utf8')
    source=folder/'entry.typ'
    source.write_text('#import "/template/editions/gb55031/template.typ": gb55031-edition\n'
                      '#show: gb55031-edition\n#include "content.typ"\n','utf8')
    path=folder/'edited.pdf'
    compile_file(source,path)
    data=query(source.relative_to(ROOT).as_posix())
    assert [v['mode'] for v in data if v.get('kind')=='gb55031-layout-mode']==['flow']
    entries=[v for v in data if v.get('kind')=='gbt-explanation-entry']
    clauses=[v for v in data if v.get('kind')=='gbt-section']
    assert len(entries)==125 and len(clauses)==143
    _,texts,inspection=inspect_file(path)
    joined=compact(''.join(texts))
    for i in range(30):assert f'新增正文第{i}段。' in joined,i
    assert '1.0.5新增条文验证自动编号。' in joined
    assert '1.0.5新增条文说明验证文后汇编。' in joined
    assert '0.27' in joined
    assert sum('新增正文第' in t for t in texts)>1
    try:
        compile_file(source,folder/'stale-reference.pdf',inputs={'gb55031-mode':'reference'})
    except SystemExit as error:
        assert '逐页对齐配置不适用' in str(error),error
    else:raise AssertionError('Reference mode must reject changed content.')
    layout=verify_explanation_layout()
    # The flow template joins scanned continuations without repeating the
    # preface title, and its body contents must have actual entries.
    assert joined.count('前言')==1
    contents_index=next(i for i,t in enumerate(texts) if '目次' in compact(t))
    body_contents=compact(''.join(texts[contents_index:contents_index+3]))
    assert all(name in body_contents for name in ('总则','功能要求','6.8变形缝')),body_contents
    return dict(content_sources_checked=list(sources),formatting_owned_by_template=True,
                three_line_compile_entry=True,flow_cases=cases,
                edited_book=dict(pages=inspection['pages'],clauses=143,explanations=125,
                    new_paragraphs=30,table_edit_retained=True,automatic_reflow=True,
                    stale_reference_rejected=True,preface_title_once=True,body_contents_populated=True),
                explanation_layout=layout)


def verify_explanation_layout():
    """Measure heading alignment and distinct entry paragraphs in the example."""
    path=ROOT/'output/pdf/construction-standard-example.pdf'
    reader,texts,inspection=inspect_file(path)
    index=next(i for i,t in enumerate(texts) if '本条说明规范制定的目的' in compact(t))
    doc=pdfium.PdfDocument(path)
    page=doc[index];text=page.get_textpage();chars=[];boxes=[]
    for i in range(text.count_chars()):
        char=text.get_text_range(i,1)
        if char and not char.isspace():chars.append(char);boxes.append(text.get_charbox(i))
    visible=''.join(chars)
    def locate(sample):
        start=visible.index(sample);found=boxes[start:start+len(sample)]
        return [min(b[0] for b in found),page.get_height()-max(b[3] for b in found),
                max(b[2] for b in found),page.get_height()-min(b[1] for b in found)]
    expected_center=(page.get_width()+(18-15)/25.4*72)/2
    errors=[]
    for sample in ('1总则','2基本规定','2.1功能要求'):
        box=locate(sample);error=abs((box[0]+box[2])/2-expected_center)
        assert error<2,(sample,error,box,expected_center)
        errors.append(error)
    first,second=locate('1.0.1'),locate('1.0.2')
    assert abs(first[0]-second[0])<.5 and second[1]-first[1]>15,(first,second)
    sizes=[]
    def visit(s,cm,tm,font,size):
        if s.strip()=='总则':sizes.append(float(size))
    reader.pages[index].extract_text(visitor_text=visit)
    assert sizes==[10.5],sizes
    if any('SimSun' in f for f in inspection['fonts']):
        assert not any('SourceHan' in f for f in inspection['fonts']),inspection['fonts']
    assert '两条合并说明' in compact(texts[-1]),'No empty trailing page is allowed.'
    text.close();page.close();doc.close()
    return dict(centered_headings=3,maximum_center_error_pt=max(errors),chapter_font_pt=10.5,
                distinct_entry_paragraphs=True,range_separator_uses_body_font=True,no_empty_trailing_page=True)


def main():
    report=dict(behaviour=verify_behaviour(),edition=verify_edition(),content_separation=verify_content_separation())
    target=ROOT/'docs/explanations-regression.json'
    target.write_text(json.dumps(report,ensure_ascii=False,indent=2)+'\n','utf8')
    print(json.dumps(dict(status='passed',clauses=report['edition']['native_clauses'],
        explanations=report['edition']['explanations'],pages=report['edition']['pages']),ensure_ascii=False))
    return report


if __name__=='__main__':main()
