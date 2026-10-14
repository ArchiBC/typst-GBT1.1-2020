// GB 55031 reference profile. Content remains in book/; this directory owns
// every font, line frame, page break, border and page-number placement.
#import "../../lib.typ": construction-standard, explain, explanations
#import "../../content.typ": content-items, content-catalog, content-signature, compact-content, content-contents
#import "../../construction-document.typ": construction-document
#import "/book/gb55031-front.typ": standard-info, front-content, note-front-content, explanation-intro
#import "layout.typ": *
#import "tables.typ": edition-table-rules

#let edition-plan = json("layout.json")

#let edition-line(action, catalog) = {
  let raw = catalog.at(action.key).clusters().slice(action.start, action.end).fold("", (a, b) => a + b)
  let chars = (action.at("prefix", default: "") + raw).clusters()
  let spaces = action.at("spaces", default: ())
  let result = ""
  for i in range(chars.len() + 1) {
    for gap in spaces.filter(g => g.at(0) == i) { result += str.from-unicode(gap.at(1)) }
    if i < chars.len() { result += chars.at(i) }
  }
  result
}

#let edition-row-options(action) = (
  size: action.at("size", default: 10.5) * 1pt,
  weight: action.at("weight", default: "regular"),
  face: action.at("face", default: "song"),
  italic: action.at("italic", default: false),
  vertical: action.at("vertical", default: false),
)

#let edition-note-body(item, catalog) = {
  let result = []
  for action in edition-plan.explanations.at(item.key) {
    let body = if action.action == "picture" {
      edition-picture(catalog.at(action.key + ":path"), action.x * 1pt, action.y * 1pt,
        action.width * 1pt, action.height * 1pt)
    } else if action.action == "table-rules" { edition-table-rules(action.page) } else { none }
    if body != none { result += edition-note-asset(action.page, body) }
    else {
      let kind = if action.action in ("entry", "group") { action.action } else { "text" }
      let sample = if kind == "text" { edition-line(action, catalog) } else { "1" }
      result += edition-note-row(action.page, action.x * 1pt, action.y * 1pt, action.width * 1pt,
        sample, kind: kind, target: if kind == "group" { label(action.target) } else { none },
        ..edition-row-options(action))
    }
  }
  result
}

#let edition-action(action, catalog, items) = {
  if action.action == "text" {
    let sample = edition-line(action, catalog)
    let body = if "emphasis" in action {
      let chars = sample.clusters()
      [#text(weight: "bold", chars.slice(0, action.emphasis).join())#chars.slice(action.emphasis).join()]
    } else { auto }
    edition-row(action.x * 1pt, action.y * 1pt, action.width * 1pt,
      sample, body: body, fill: if "fill" in action { rgb(action.fill) } else { black },
      ..edition-row-options(action))
  } else if action.action == "heading" {
    let item = items.find(it => it.key == action.key)
    let sample = action.key.slice(3).replace("-", ".") + " " + catalog.at(item.key)
    edition-row(action.x * 1pt, action.y * 1pt, action.width * 1pt, sample,
      body: item.heading, ..edition-row-options(action))
  } else if action.action == "clause" {
    edition-row(action.x * 1pt, action.y * 1pt, action.width * 1pt,
      action.key.slice(3).replace("-", "."), body: edition-clause(action.key),
      ..edition-row-options(action))
  } else if action.action == "explanation" {
    let item = items.find(it => it.key == action.key)
    explain(of: label(item.target-key), through: item.through, separator: item.separator,
      edition-note-body(item, catalog))
  } else if action.action == "table-rules" { edition-table-rules(action.page) }
  else if action.action == "logo" { edition-logo() }
  else if action.action == "toc" {
    edition-toc-entry(label(action.key), action.x * 1pt, action.y * 1pt, action.width * 1pt, part: action.part)
  } else if action.action == "rules" {
    edition-rules(action.segments.map(segment => segment.map(n => n * 1pt)),
      fill: if "fill" in action { rgb(action.fill) } else { black }, stroke: action.at("stroke", default: 0.35) * 1pt)
  } else if action.action == "dotted-rule" {
    place(top + left, dx: action.x * 1pt, dy: action.y * 1pt,
      line(length: action.width * 1pt, stroke: (paint: black, thickness: 0.3pt, dash: "dotted")))
  }
}

#let edition-pages(pages, catalog, items) = {
  for sheet in pages {
    edition-page(sheet.number)[#for action in sheet.actions { edition-action(action, catalog, items) }]
  }
}

// The reference transcription divides front matter at scanned page edges.
// In flow mode, join its continuations and remove the one duplicated preface
// title. This is specific to this edition; ordinary authored text is intact.
#let edition-flow-front(items) = {
  let sections = ()
  for item in items {
    if sections.len() > 0 and item.type == "front-section" and sections.last().type == "front-section" and sections.last().title == item.title {
      let previous = sections.pop()
      sections.push(previous + (body: previous.body + item.body))
    } else { sections.push(item) }
  }
  for item in sections {
    let record = item
    if item.key == "front-6" {
      let paragraph = []
      let first = true
      for child in item.body.children {
        if first and child.func() == text and child.text.trim() != "" {
          first = false
          paragraph += if child.text.starts-with(item.title.text) { text(child.text.slice(item.title.text.len())) } else { child }
        } else { paragraph += child }
      }
      record += (body: paragraph,)
    }
    metadata(record)
  }
}

#let gb55031-edition(body, mode: sys.inputs.at("gb55031-mode", default: "auto"), ..options) = {
  assert(mode in ("auto", "reference", "flow"), message: "gb55031-mode 应为 auto、reference 或 flow。")
  let items = content-items(body)
  let front-items = content-items(front-content) + content-items(note-front-content) + ((key: "explanation-intro", body: explanation-intro),)
  let signature = content-signature(items, (standard-info, front-items))
  let matches = signature == edition-plan.signature
  let configured = options.named().len() > 0
  assert(mode != "reference" or (matches and not configured), message: "内容或格式已改变，逐页对齐配置不适用；请使用 auto 或 flow。")
  if mode == "flow" or configured or (mode == "auto" and not matches) {
    metadata((kind: "gb55031-layout-mode", mode: "flow"))
    // Cover and contents are generated by the flow template. Their original
    // repeated display strings belong only to the reference page binding.
    let front = content-items(front-content).filter(it => it.key not in ("front-1", "front-2", "front-8", "front-9"))
    let notes = content-items(note-front-content).filter(it => it.key not in ("front-30", "front-31", "front-32"))
    // Keep the semantic front matter rather than the fixed edition's frames.
    construction-document(info: standard-info,
      front: [#edition-flow-front(front)#content-contents()], note-front: edition-flow-front(notes),
      ..options.named(), body)
  } else {
    let catalog = content-catalog(items + front-items)
    construction-standard(..standard-info,
      cover-page: false, two-sided: false, contents: false, main-title: false, end-rule: false,
      page-layout: (margin: 0pt, header: none, footer: none), renderers: (heading: edition-heading),
      front-matter: edition-pages(edition-plan.front_pages, catalog, items),
      back-matter: [#explanations(title: none, outlined: false, page-break: false, source: "document",
        front-matter: edition-pages(edition-plan.note_front_pages, catalog, items), body-renderer: edition-explanations)],
      [#metadata((kind: "gb55031-layout-mode", mode: "reference"))#edition-pages(edition-plan.body_pages, catalog, items)])
  }
}
