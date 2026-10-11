"""Compile before/after insertions and verify counters AND printed references."""
from pathlib import Path
import json, re, sys
ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT/'.tools/python'))
import typst
from pypdf import PdfReader
from compile import REFERENCE_FONTS, ROMAN_FONTS

def verify_untitled_contents(folder, profiles):
    """Check unlabelled clauses in rendered contents and their PDF destinations."""
    results=[]
    source=ROOT/'tools/fixtures/untitled-contents.typ'
    for profile in profiles:
        for inserted in (False,True):
            for included in (False,True):
                inputs={'font-profile':profile,'insert-clause':str(inserted).lower(),
                        'clause-contents':str(included).lower()}
                fonts=[ROOT/'fonts']+([REFERENCE_FONTS,ROMAN_FONTS] if profile=='reference' else [])
                args=dict(root=str(ROOT),font_paths=list(map(str,fonts)),ignore_system_fonts=True,sys_inputs=inputs)
                pdf=folder/f'untitled-{profile}-{int(inserted)}-{int(included)}.pdf'
                typst.compile(str(source),output=str(pdf),**args)
                data=json.loads(typst.query(str(source),'metadata',**args))
                numbers=[v['value']['number'] for v in data if v['value'].get('kind')=='gbt-section']
                method='1.4' if inserted else '1.3'
                expected=['1.1','1.2']+(['1.3'] if inserted else [])+[method+'.1',method+'.2','A.1.1']
                assert numbers==expected,(profile,inserted,included,numbers,expected)
                checks=[v['value'] for v in data if v['value'].get('kind')=='gbt-reference-check']
                assert len(checks)==3 and all(v['unique'] and v['native-heading'] for v in checks),checks
                bindings=[v['value'] for v in data if v['value'].get('kind')=='gbt-native-target']
                assert len(bindings)==len(numbers),(profile,inserted,included,bindings)
                labelled_clauses=[v for v in checks if v['is-clause']]
                assert len(labelled_clauses)==1 and labelled_clauses[0]['key']=='referenced-clause',checks
                unlabelled_count=sum(v.get('label') is None for v in bindings)
                assert unlabelled_count==len(expected)-1
                reader=PdfReader(pdf)
                toc=reader.pages[0]
                entries=[]
                for obj in toc.get('/Annots',[]):
                    annot=obj.get_object();description=str(annot.get('/Contents',''))
                    if not description.startswith('gbt-clause '):continue
                    number=description.removeprefix('gbt-clause ')
                    dest=annot['/Dest']
                    if isinstance(dest,str):
                        target=reader.named_destinations[dest]
                        page=reader.get_destination_page_number(target)
                    else:
                        target=dest.get_object()
                        page=next(i for i,p in enumerate(reader.pages) if p.indirect_reference==target[0])
                        assert target[1]=='/XYZ' and float(target[3])>80,(number,target)
                    assert page in (1,2),(number,page)
                    assert number in re.sub(r'\s+','',reader.pages[page].extract_text()),(number,page)
                    entries.append(number)
                wanted=[n for n in expected if n!=method+'.2'] if included else []
                assert entries==wanted,(profile,inserted,included,entries,wanted)
                text=re.sub(r'\s+','',reader.pages[1].extract_text())
                referenced='1.3' if inserted else '1.2'
                assert f'条引用：{referenced}。标题引用：{method}。' in text
                assert labelled_clauses[0]['number']==referenced,labelled_clauses
                assert f"页引用：页{labelled_clauses[0]['folio']}。" in text,(profile,inserted,included,text)
                sizes={}
                def visit(s,cm,tm,font,size):
                    name=str(font.get('/BaseFont','')) if font else ''
                    if 'E-FZ' in name or 'SourceHanSans' in name:
                        sizes[s.strip()]=float(size)
                reader.pages[1].extract_text(visitor_text=visit)
                assert .8<sizes[method+'.2']/sizes[method+'.1']<.9, sizes
                if profile=='open':
                    assert sizes[method+'.1']==10.5 and sizes[method+'.2']==9, sizes
                results.append(dict(font_profile=profile,inserted=inserted,clause_contents=included,
                    unlabelled_clauses=unlabelled_count,numbers=numbers,contents_entries=entries,
                    destinations_verified=True,printed_references_verified=True,local_font_size_verified=True,
                    unique_native_labels_verified=True,page_reference_verified=True))
    return results

def verify_book_numbering(profiles):
    """Compare every numbered heading and clause with a label-free fixture."""
    fixture=json.loads((ROOT/'tools/fixtures/book-numbering.json').read_text('utf8'))
    expected=fixture['sections']
    results=[]
    for profile in profiles:
        fonts=[ROOT/'fonts']+([REFERENCE_FONTS,ROMAN_FONTS] if profile=='reference' else [])
        data=json.loads(typst.query(str(ROOT/'book/gbt-1.1-2020.typ'),'metadata',
            root=str(ROOT),font_paths=list(map(str,fonts)),ignore_system_fonts=True,
            sys_inputs={'font-profile':profile}))
        sections=[r['value'] for r in data if r['value'].get('kind') in ('gbt-heading','gbt-section')]
        bindings=[r['value'] for r in data if r['value'].get('kind')=='gbt-native-target']
        actual=[dict(kind=v['kind'],number=str(v['number'])) for v in sections]
        assert len(actual)==len(expected),(profile,'section count',len(actual),len(expected))
        for position,(observed,wanted) in enumerate(zip(actual,expected),start=1):
            assert observed==wanted,(profile,'section',position,observed,wanted)
        results.append(dict(font_profile=profile,numbered_sections=len(sections),
            headings=sum(v['kind']=='gbt-heading' for v in sections),
            clauses_and_terms=sum(v['kind']=='gbt-section' for v in sections),
            unlabelled_sections=sum(v['kind']=='gbt-heading' and v.get('key') is None for v in sections)
                +sum(v.get('label') is None for v in bindings),
            expected_fixture='tools/fixtures/book-numbering.json',
            complete_sequence_verified=True))
        (ROOT/f'output/qa/numbering-query-{profile}.json').write_text(
            json.dumps(data,ensure_ascii=False,indent=2)+'\n',encoding='utf8',newline='\n')
    return results


def main(profiles=('open',)):
    folder=ROOT/'output/qa/automatic-numbering'; folder.mkdir(parents=True, exist_ok=True)
    source=ROOT/'tools/fixtures/automatic-numbering.typ'
    results=[]
    for profile in profiles:
        for inserted in (False, True):
            inputs={'font-profile':profile, 'insert-entry':str(inserted).lower(), 'insert-clause':str(inserted).lower()}
            fonts=[ROOT/'fonts']+([REFERENCE_FONTS,ROMAN_FONTS] if profile=='reference' else [])
            args=dict(root=str(ROOT),font_paths=list(map(str,fonts)),ignore_system_fonts=True,sys_inputs=inputs)
            pdf=folder/f"{profile}-{'inserted' if inserted else 'baseline'}.pdf"
            typst.compile(str(source),output=str(pdf),**args)
            data=json.loads(typst.query(str(source),'metadata',**args))
            checks=[r['value'] for r in data if r['value'].get('kind')=='gbt-reference-check']
            assert len(checks)==18 and all(v['unique'] and v['native-heading'] for v in checks),checks
            actual={v['key']:v['number'] for v in checks}
            expected={'tested-term': '1.1.2' if inserted else '1.1.1',
                      'related-term':'1.1.3' if inserted else '1.1.2',
                      'first-clause':'2.1','second-clause':'2.3' if inserted else '2.2',
                      'nested-clause':'2.4.1' if inserted else '2.3.1', 'annex-clause':'A.1.1'}
            prefix='2.4' if inserted else '2.3'
            sequence=[prefix+'.'+str(i+2) for i in range(12)]
            expected.update({f'sequence-{i}':number for i,number in enumerate(sequence)})
            assert len(actual)==len(expected),actual
            for key, value in expected.items():
                assert actual.get(key)==value,(profile,inserted,key,value,actual)
            text=re.sub(r'\s+','', ''.join(p.extract_text() or '' for p in PdfReader(pdf).pages))
            printed='自动引用验证：术语'+expected['tested-term']+'；条'+expected['second-clause']+'；下级条'+expected['nested-clause']+'。'
            assert printed in text, (profile,inserted,printed,text)
            assert '附录引用：A.1.1。' in text
            assert '术语'+expected['tested-term'] in text, ('index-term', profile, inserted, text)
            assert '条'+expected['second-clause'] in text, ('index-clause', profile, inserted, text)
            boundaries='引用边界验证：第'+expected['first-clause']+'条，'+expected['second-clause']+'a)。'
            assert boundaries in text,(profile,inserted,boundaries,text)
            folio=next(v['folio'] for v in checks if v['key']=='first-clause')
            assert f'页引用验证：页{folio}。' in text,(profile,inserted,folio,text)
            continuous='连续条引用验证：'+'；'.join(sequence)+'。'
            assert continuous in text,(profile,inserted,continuous,text)
            results.append(dict(font_profile=profile,inserted=inserted,counters=actual,
                printed_references_verified=True,index_references_verified=True,
                unique_native_labels_verified=True,adjacent_context_targets_verified=12,
                reference_boundaries_verified=True,page_reference_verified=True))
    book_cases=verify_book_numbering(profiles)
    checked=book_cases[0]['numbered_sections']
    contents_cases=verify_untitled_contents(folder,profiles)
    report=dict(insertion_cases=results,untitled_contents_cases=contents_cases,book_cases=book_cases,
        book_numbered_sections_checked=checked,passed=True)
    (ROOT/'output/qa/automatic-numbering.json').write_text(json.dumps(report,ensure_ascii=False,indent=2)+'\n',
        encoding='utf8',newline='\n')
    print(json.dumps(dict(insertion_cases=results,untitled_contents_cases=len(contents_cases),
        book_cases=book_cases,book_numbered_sections_checked=checked,passed=True),ensure_ascii=False))

if __name__=='__main__':
    import argparse
    parser=argparse.ArgumentParser()
    parser.add_argument('--font-profile',choices=('open','reference','both'),default='open')
    args=parser.parse_args()
    main(profiles=('open','reference') if args.font_profile=='both' else (args.font_profile,))
