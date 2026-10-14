"""Verify generated PDFs; never extract text from the supplied source PDF."""
from pathlib import Path
import hashlib
import json
import re
import sys
import unicodedata
ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT / ".tools/python"))
from pypdf import PdfReader
import pypdfium2 as pdfium
from compile import compile_file

ALLOWED = ("SourceHanSerifSC", "SourceHanSansSC", "LiberationSerif", "LibertinusSerif", "NewCMMath", "DejaVuSansMono",
           "SimSun", "SimHei", "TimesNewRoman")
REFERENCE = ("FZSSK", "FZHTK", "FZXBSJW", "E-BZ", "E-HZ", "E-FZ", "E-F1", "TimesNewRoman")
def compact(text):
    return re.sub(r"\s+", "", text)

def verify_contents_specimen(path):
    """Compare E.8 with the printed specimen, including placeholder counts."""
    page=PdfReader(path).pages[0]
    lines=[compact(line) for line in (page.extract_text() or '').splitlines()]
    wanted=['前言III','引言IV','1范围1','2规范性引用文件1','3术语和定义2']
    for number,count,folio in (('4',2,4),('4.1',2,4),('4.2',5,4),('4.3',7,4),
                               ('5',4,5),('5.1',5,5),('5.2',9,7),('6',3,9),
                               ('6.1',7,9),('6.2',5,10),('6.3',11,11),
                               ('A.1',2,12),('A.2',3,12),('A.3',4,12)):
        wanted.append(number+'×'*count+str(folio))
    wanted += ['附录A（规范性）'+'×'*5+'12','附录B（规范性）'+'×'*7+'13',
               '附录C（资料性）'+'×'*5+'14','参考文献15','索引16']
    for kind,number,count,folio in (('图','1',9,5),('图','2',7,6),('图','3',11,9),
                                    ('表','1',5,7),('表','2',7,8),('表','A.1',7,12)):
        wanted.append(kind+number+'×'*count+str(folio))
    assert all(line in lines for line in wanted),(path,lines,wanted)
    return dict(entries_verified=len(wanted),source_page=60,placeholders_verified=True,
                preface_roman_folio_verified=True)

def verify_cover_specimen(path):
    text=compact(PdfReader(path).pages[0].extract_text() or '')
    if path.stem=='e6':
        assert '备案号：XXXX—XXXX' in text and 'XX/TXXXXX—XXXX' in text,text
        return dict(source_page=58,record_placeholder_count=4,serial_placeholder_count=5)
    assert 'DBXX/TXXX—XXXX' in text and 'DBXX/TXXXXX—XXXX' not in text,text
    assert '代替DBXX/TXXX—XXXX' in text,text
    return dict(source_page=59,serial_placeholder_count=3,replacement_verified=True)
def verify_table_f1(path):
    """Check the printed serial column, including its five-line/six-row group."""
    reader=PdfReader(path)
    serials=[]
    for page_number,page in enumerate(reader.pages,1):
        text=compact(page.extract_text() or '')
        if '文件中使用的字号和字体' not in text or '序号' not in text:continue
        def visit(s,cm,tm,font,size):
            s=s.strip()
            x=tm[4]*cm[0]+tm[5]*cm[2]+cm[4]
            y=tm[4]*cm[1]+tm[5]*cm[3]+cm[5]
            if len(s)==2 and s.isdecimal() and x<110 and 80<y<710:
                serials.append(dict(number=s,page=page_number,x_pt=x,baseline_y_pt=y))
        page.extract_text(visitor_text=visit)
    assert [s['number'] for s in serials]==[f'{i:02d}' for i in range(1,49)], serials
    positions={int(s['number']):s['baseline_y_pt'] for s in serials}
    pitch=positions[34]-positions[35]
    for n in range(36,40):
        assert abs((positions[n]-positions[n+1])-pitch)<.002,(n,positions,pitch)
    assert abs((positions[35]-positions[36])-1.5*pitch)<.002
    assert abs((positions[40]-positions[41])-1.5*pitch)<.002
    assert abs((positions[36]+positions[40])-(positions[35]+positions[41]))<.002
    return dict(file=str(path.relative_to(ROOT)),sha256=hashlib.sha256(path.read_bytes()).hexdigest(),
                serial_count=48,sequence_verified=True,group_36_40_equal_pitch=True,
                group_36_40_centered=True,pitch_pt=pitch,serials=serials)

def inspect_file(path, reference=False):
    reader=PdfReader(path)
    document=pdfium.PdfDocument(path)
    fonts, image_objects, outside = {}, set(), []
    visited=set()
    def resources(value):
        value=value.get_object()
        for font in value.get("/Font",{}).values():
            f=font.get_object()
            name=str(f.get("/BaseFont",""))
            descendant=f.get("/DescendantFonts",[f])[0].get_object()
            descriptor=descendant.get("/FontDescriptor")
            descriptor=descriptor.get_object() if descriptor else {}
            embedded=any(key in descriptor for key in ("/FontFile","/FontFile2","/FontFile3"))
            fonts[name]=embedded
        for ref in value.get("/XObject",{}).values():
            obj=ref.get_object()
            key=(getattr(ref,"idnum",None),getattr(ref,"generation",None))
            if key in visited:continue
            visited.add(key)
            if obj.get("/Subtype")=="/Image":image_objects.add(key)
            if obj.get("/Resources"):resources(obj["/Resources"])
    for i,p in enumerate(reader.pages):
        resources(p.get("/Resources",{}))
        page=document[i]
        width,height=page.get_size()
        text=page.get_textpage()
        for index in range(text.count_chars()):
            left,bottom,right,top=text.get_charbox(index)
            if left < -1 or bottom < -1 or right>width+1 or top>height+1:
                outside.append([i+1,index,[left,bottom,right,top]])
        text.close();page.close()
    document.close()
    texts=[p.extract_text() or "" for p in reader.pages]
    assert fonts and all(fonts.values()), f"Non-embedded font in {path.name}: {fonts}"
    allowed=ALLOWED+REFERENCE if reference else ALLOWED
    assert all(any(name in f for name in allowed) for f in fonts), f"Unexpected font in {path.name}: {fonts}"
    assert not outside, f"Text outside page in {path.name}: {outside[:5]}"
    return reader,texts,dict(file=str(path.relative_to(ROOT)),pages=len(reader.pages),
        fonts=fonts,raster_image_objects=len(image_objects),
        links=sum(len(p.get("/Annots",[])) for p in reader.pages),
        text_outside_page=len(outside),
        sha256=hashlib.sha256(path.read_bytes()).hexdigest())

def main(profiles=('open',)):
    reports=[]
    books={'open':'gbt-1.1-2020-open-fonts','reference':'gbt-1.1-2020-replica'}
    for name in (*[books[p] for p in profiles],"standard-example","template-manual"):
        path=ROOT/f"output/pdf/{name}.pdf"
        reader,texts,report=inspect_file(path, reference=name=="gbt-1.1-2020-replica")
        if name in books.values():
            assert all(abs(float(p.mediabox.width)-595.2756)<.02 and abs(float(p.mediabox.height)-841.8898)<.02 for p in reader.pages)
            main_page=next(i for i,t in enumerate(texts) if "1范围" in compact(t) and "2规范性引用文件" in compact(t) and "目次" not in compact(t))
            assert (main_page+1)%2==1
            report['main_physical_page']=main_page+1
            report['source_pages']=72
            report['blank_physical_pages']=[i+1 for i,t in enumerate(texts) if not compact(t)]
            full=compact(''.join(texts))
            assert full.count('“可”是文件表达的允许') == 1, '表 C.4 的注应完整出现一次。'
            assert 'GB/T4458.1机械制图' in full and 'GB/T4458.11机械制图' not in full
            assert '图用“图A.1”“图A.2”' in full and '表用“表A.1”“表A.2”' in full
            assert '“第*部分：”（*为使用阿拉伯数字的部分编号）' in full
            assert full.count('第#页/共*页') >= 3, '续图、续表及表 F.1 使用 # / * 占位符。'
            assert '共×页' not in full
            assert '第二行术语、英文对应词五号黑体' in full
            assert full.count('一般性陈述') >= 5, '一般性陈述必须包含正文、表题和索引。'
            assert report["raster_image_objects"]==0, "The replica must not embed scanned pages."
            report["editable_source"]="book/gbt-1.1-2020.typ"
        else:
            assert all(abs(float(p.mediabox.width)-595.2756)<.02 and abs(float(p.mediabox.height)-841.8898)<.02 for p in reader.pages)
            assert report["links"]>10
            assert reader.outline
            if name=="standard-example":
                main_page=next(i for i,t in enumerate(texts) if "1范围" in compact(t) and "2规范性引用文件" in compact(t) and "目次" not in compact(t))
                assert (main_page+1)%2==1, "The main text must begin on a recto."
                assert compact(texts[main_page]).endswith("1")
                assert "表A.1" in compact("".join(texts))
                assert "表B.1" in compact("".join(texts))
                assert "表2测量记录（续）" in compact("".join(texts))
                report["main_physical_page"]=main_page+1
        reports.append(report)
    fixture=ROOT/"output/qa/components.pdf"
    compile_file(ROOT/"tools/fixtures/components.typ",fixture)
    r,texts,report=inspect_file(fixture)
    toc=compact(''.join(texts[:3]))
    assert "图A.1附录图形" in toc and "表B.1第二个附录表格" in toc
    main=compact("".join(texts))
    assert "参见表1、图1" in main
    assert "参见A.1、表A.1和图A.1" in main
    assert '公式引用：公式（1）。' in main and '附录公式引用：公式（A.1）。' in main
    assert "（A.1）" in main and "（B.1）" in main
    assert "表3后续表格" in main
    carrying=[p for p,t in enumerate(texts[3:],4) if "表2连续测量记录" in compact(t)]
    assert len(carrying)>=2
    assert all("（续）" in compact(texts[p-1]) for p in carrying[1:])
    assert sum("只在末页出现的表注" in compact(t) for t in texts)==1
    assert sum("只在末页出现的表脚注" in compact(t) for t in texts)==1
    report["auto_table_pages"]=carrying
    report["checks"]="references, figure/table lists, annex reset, automatic repeated table captions, last-page notes"
    reports.append(report)
    inserted=ROOT/'output/qa/components-inserted.pdf'
    compile_file(ROOT/'tools/fixtures/components.typ',inserted,inputs={'insert-equation':'true'})
    _,texts,report=inspect_file(inserted)
    text=compact(''.join(texts))
    assert '公式引用：公式（2）。' in text and '附录公式引用：公式（A.1）。' in text
    report['checks']='equation insertion updates printed reference; annex equation resets to A.1'
    reports.append(report)
    # A clipped fragment can disappear inside the parent PDF without being
    # outside the parent's A4 boundary. Inspect every generated demo itself.
    demo_manifest=json.loads((ROOT/'book/demo-pdf/manifest.json').read_text('utf8'))
    demo_reports=[]
    for demo in demo_manifest['examples']:
        path=ROOT/demo['pdf']
        _,_,report=inspect_file(path, reference=demo_manifest['font_profile']=='reference')
        assert report['pages']==1, f"Embedded demo must contain one selected page: {path.name}"
        assert report['raster_image_objects']==0, f"Demo must remain vector: {path.name}"
        assert report['sha256']==demo['sha256'], f"Stale demo: {path.name}"
        if path.stem=='e8':report['contents_specimen']=verify_contents_specimen(path)
        if path.stem in ('e6','e7'):report['cover_specimen']=verify_cover_specimen(path)
        if path.stem=='table-headers-2':
            text=compact(PdfReader(path).pages[0].extract_text() or '')
            assert 'ρ1/(kg/m)' in unicodedata.normalize('NFKC',text),text
            report['subscript_matches_source']=True
        demo_reports.append(report)
    merged=ROOT/'output/qa/index-and-merged-cells.pdf'
    compile_file(ROOT/'tools/fixtures/index-and-merged-cells.typ',merged,profile='open')
    merged_reader,texts,report=inspect_file(merged)
    text=compact(''.join(texts))
    assert '跨行跨列表头与合并内容' in text and '合并三列的说明' in text
    assert '标准化文件' in text and '框线' in text and '索引' in text
    assert '附录条目引用：B.1、B.2。' in text
    bold_sizes=[]
    def check_bold(s,cm,tm,font,size):
        if s.strip()=='温度':bold_sizes.append(float(size))
    for page in merged_reader.pages:page.extract_text(visitor_text=check_bold)
    assert bold_sizes==[9.0],bold_sizes
    report['checks']='rowspan, colspan, automatic index, annex indentation, untitled annex reset, bold text inherits cell size'
    reports.append(report)
    for name,source_path in (("starter","examples/blank.typ"),
                             ("layout-variants","tools/fixtures/layout-variants.typ")):
        path=ROOT/f"output/qa/{name}.pdf"
        compile_file(ROOT/source_path,path)
        r,texts,report=inspect_file(path)
        if name=="layout-variants":
            assert len(r.pages)==3
            assert "1范围" in compact(texts[1])
            assert "GB/T12345—2026" in compact(texts[-1])
            report["checks"]="single-sided main text on page 2, rotated back cover within page"
        else:
            assert "填写标准名称" in compact(texts[0])
            report["checks"]="starter document compiles with open-source fonts"
        reports.append(report)
    f1_reports=[verify_table_f1(ROOT/'output/pdf'/(books[p]+'.pdf')) for p in profiles]
    (ROOT/'output/qa/table-f1-verification.json').write_text(json.dumps(dict(passed=True,artifacts=f1_reports),ensure_ascii=False,indent=2),'utf8')
    source=json.loads((ROOT/"docs/source-manifest.json").read_text("utf8"))
    from verify_numbering import main as numbering_checks
    numbering_checks(profiles=profiles)
    from verify_alignment import main as alignment_checks
    alignment_checks(profiles=profiles)
    from verify_typography import main as typography_checks
    typography_checks(profiles=profiles)
    from verify_annex_e import verify_native
    annex_e = verify_native(demo_manifest['font_profile'])
    (ROOT/'output/qa/annex-e-verification.json').write_text(json.dumps(annex_e, ensure_ascii=False, indent=2), 'utf8')
    from verify_explanations import main as explanation_checks
    explanations = explanation_checks()
    for filename in ('construction-standard-example.pdf', 'template-manual.pdf'):
        inspect_file(ROOT/'output/pdf'/filename)
    output=dict(status="passed",source_pdf_sha256=source["sha256"],
                source_text_extraction_used=False,compiler_tested="0.15.0",artifacts=reports,
                demo_font_profile=demo_manifest['font_profile'],demos=demo_reports,
                explanations=explanations)
    (ROOT/"output/verification.json").write_text(json.dumps(output,ensure_ascii=False,indent=2),encoding="utf8")
    for r in reports: print(f"PASS {r['file']}: {r['pages']} pages, fonts embedded, no text outside page")
    print("PASS automatic table continuation, references, annex counters, starter and back cover")
    print(f"PASS {len(demo_reports)} generated vector fragments: embedded fonts and no clipped text")

if __name__=='__main__':
    import argparse
    parser=argparse.ArgumentParser()
    parser.add_argument('--font-profile',choices=('open','reference','both'),default='open')
    args=parser.parse_args()
    main(profiles=('open','reference') if args.font_profile=='both' else (args.font_profile,))
