"""Render every deliverable page and contact sheet for visual QA."""
from pathlib import Path
import argparse, hashlib, json, re, sys
ROOT=Path(__file__).resolve().parents[1]
sys.path.insert(0,str(ROOT/'.tools/python'))
import pypdfium2 as pdfium
from PIL import Image, ImageDraw
from pypdf import PdfReader
def render(source):
    name=source.stem
    target=ROOT/"output/qa"/name
    target.mkdir(parents=True,exist_ok=True)
    doc=pdfium.PdfDocument(source)
    # Remove only previews owned by this renderer. A shorter rebuild must not
    # leave pages or contact sheets from an older PDF in the current folder.
    expected={f"{i+1:03d}.png" for i in range(len(doc))}
    expected.update(f"contact-{i+1:03d}.png" for i in range(0,len(doc),12))
    assert target.resolve().is_relative_to((ROOT/"output/qa").resolve())
    for preview in target.glob("*.png"):
        if re.fullmatch(r"(?:contact-)?\d{3}\.png",preview.name) and preview.name not in expected:
            preview.unlink()
    reader=PdfReader(source)
    record={"file":str(source.relative_to(ROOT)),"sha256":hashlib.sha256(source.read_bytes()).hexdigest(),
            "pages":len(doc),"page_sizes_pt":[],"fonts":[]}
    fonts=set()
    for i,page in enumerate(doc):
        page.render(scale=2).to_pil().convert("RGB").save(target/f"{i+1:03d}.png")
        record["page_sizes_pt"].append(list(page.get_size()))
        resources=reader.pages[i].get("/Resources",{})
        for font in resources.get("/Font",{}).values():
            fonts.add(str(font.get_object().get("/BaseFont")))
        page.close()
    record["fonts"]=sorted(fonts)
    (target/"inspection.json").write_text(json.dumps(record,ensure_ascii=False,indent=2),encoding="utf8")
    (target/"text.txt").write_text("\n\n".join(f"=== PAGE {i+1} ===\n"+(p.extract_text() or "") for i,p in enumerate(reader.pages)),encoding="utf8")
    for start in range(0,len(doc),12):
        sheet=Image.new("RGB",(1280,1425),"#dddddd")
        draw=ImageDraw.Draw(sheet)
        for i in range(start,min(start+12,len(doc))):
            with Image.open(target/f"{i+1:03d}.png") as thumb:
                thumb.thumbnail((300,438))
                x,y=(i-start)%4*320+10,(i-start)//4*475+25
                sheet.paste(thumb,(x,y));draw.text((x,y-20),f"page {i+1}",fill="black")
        sheet.save(target/f"contact-{start+1:03d}.png")
    doc.close()
    print(json.dumps({"file":record["file"],"pages":record["pages"],"fonts":record["fonts"]},ensure_ascii=False),flush=True)
def main():
    parser=argparse.ArgumentParser();parser.add_argument("files",nargs="*");args=parser.parse_args()
    for p in args.files or [str(p.relative_to(ROOT)) for p in (ROOT/"output/pdf").glob("*.pdf")]:
        render(ROOT/p)
if __name__=="__main__":main()
