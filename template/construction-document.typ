#import "lib.typ": construction-standard, explain, explanations, construction-explanation-heading, front-title, construction-song, construction-roman
#import "content.typ": content-items, content-node

// A semantic table carries cell relationships, never widths, fonts or rules.
#let construction-data-table-body(node) = {
  let cell-content(cell) = table.cell(
    x: cell.column, y: cell.row, colspan: cell.at("colspan", default: 1),
    rowspan: cell.at("rowspan", default: 1), cell.body,
  )
  let headers = node.cells.filter(it => it.row == 0).map(cell-content)
  let cells = node.cells.filter(it => it.row > 0).map(cell-content)
  block(above: 1em, below: 1em, breakable: true)[
    #set text(size: 8.5pt)
    #set par(first-line-indent: 0pt, justify: false, leading: 3pt, spacing: 0pt)
    #align(center, block(above: 0pt, below: 0.5em, text(weight: "bold", node.caption)))
    #table(columns: if node.columns == 8 { (12pt, 16pt, 28pt, 1.2fr, 0.7fr, 30pt, 1.2fr, 2.3fr) } else { node.columns },
      stroke: 0.35pt, inset: 3pt, align: center + horizon, table.header(..headers), ..cells)
    #for note in node.notes { block(above: 0.3em, text(size: 7.5pt, note)) }
  ]
}

#let construction-data-table(node) = {
  if node.columns >= 6 {
    page(width: 203mm, height: 135mm, margin: (left: 15mm, right: 15mm, top: 16mm, bottom: 15mm),
      construction-data-table-body(node))
  } else { construction-data-table-body(node) }
}

#let construction-illustration(node) = block(above: 1em, below: 1em, breakable: false)[
  #set par(first-line-indent: 0pt, justify: false)
  #align(center)[
    #image(node.path, width: 90%)
    #block(above: 0.5em, text(size: 9pt, node.caption))
    #if node.legend != [] { block(above: 0.3em, text(size: 8.5pt, node.legend)) }
  ]
]

#let construction-content(body, renderers: (table: construction-data-table, figure: construction-illustration)) = {
  show metadata: it => if content-node(it) {
    if it.value.type == "table" { (renderers.table)(it.value) }
    else if it.value.type == "figure" { (renderers.figure)(it.value) }
    else { it }
  } else { it }
  body
}

#let construction-front(body, renderers: (table: construction-data-table, figure: construction-illustration)) = {
  for item in content-items(body) {
    if item.type == "front-section" {
      pagebreak(weak: true)
      front-title(item.title)
      construction-content(item.body, renderers: renderers)
    } else if item.type == "contents" and item.part == "body" {
      pagebreak(weak: true)
      outline(title: [目次], depth: 2, target: heading.where(supplement: []))
    }
  }
}

#let construction-body(items, renderers: (table: construction-data-table, figure: construction-illustration)) = {
  for item in items {
    if item.type == "heading" { item.heading }
    else if item.type == "clause" {
      context [#heading(level: 3, outlined: false, supplement: "gbt-clause", metadata((marker-size: text.size)))#label(item.key)#construction-content(item.body, renderers: renderers)]
      parbreak()
    } else if item.type == "explanation" {
      explain(of: label(item.target-key), through: item.through, separator: item.separator,
        construction-content(item.body, renderers: renderers))
    }
  }
}

#let construction-document-entry(record) = [
  #set par(first-line-indent: (amount: 21pt, all: true))
  #h(-21pt)#link(record.target, text(font: construction-song, weight: "bold", tracking: 1.5pt, record.number))#h(9pt)#record.body
  #parbreak()
]

#let construction-document(body, info: (:), front: [], note-front: [], explanation-intro: none,
  content-renderers: (:), ..options) = {
  let items = content-items(body)
  let renderers = (table: construction-data-table, figure: construction-illustration) + content-renderers
  let back = [
    #construction-front(note-front, renderers: renderers)
    #explanations(contents: true, intro: explanation-intro, heading-renderer: construction-explanation-heading,
      entry-renderer: construction-document-entry)
  ]
  let settings = info + (front-matter: construction-front(front, renderers: renderers), back-matter: back) + options.named()
  construction-standard(..settings, construction-body(items, renderers: renderers))
}
