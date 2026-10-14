// Semantic content only. Layout is chosen by the document template.
#let content-kind = "gbt-content"
#let article(body) = metadata((kind: content-kind, type: "clause", body: body))
#let commentary(body, of: auto, through: none, separator: "～") = metadata((
  kind: content-kind, type: "explanation", body: body,
  of: of, through: through, separator: separator,
))
#let data-table(key, caption, columns, cells, notes: ()) = metadata((
  kind: content-kind, type: "table", key: key, caption: caption,
  columns: columns, cells: cells, notes: notes,
))
#let illustration(key, path, caption, legend: []) = metadata((
  kind: content-kind, type: "figure", key: key, path: path,
  caption: caption, legend: legend,
))
#let content-section(key, title, body) = metadata((
  kind: content-kind, type: "front-section", key: key, title: title, body: body,
))
#let content-contents(part: "body") = metadata((kind: content-kind, type: "contents", part: part))

#let content-node(it) = {
  (it.func() == metadata and type(it.value) == dictionary and
    it.value.at("kind", default: none) == content-kind)
}

#let content-children(body) = if body.has("children") { body.children } else { (body,) }

// Whitespace does not become a layout instruction. Paragraphs and list items
// inside a clause remain native Typst content and are rendered normally.
#let content-items(body) = {
  let items = ()
  let previous = none
  let anonymous = 0
  for it in content-children(body) {
    if it.func() == heading or content-node(it) {
      let node = if it.func() == heading { (type: "heading", body: it.body, heading: it) } else { it.value }
      let key = if it.has("label") { str(it.label) } else if "key" in node { node.key } else {
        anonymous += 1
        "content-" + str(anonymous)
      }
      if node.type == "clause" { previous = key }
      if node.type == "explanation" {
        let target = if node.of == auto { previous } else { str(node.of) }
        assert(target != none, message: "说明必须紧随条文，或指定 of。")
        key = target + ":explanation"
        node += (target-key: target,)
      }
      items.push(node + (key: key,))
    } else if it.func() == text {
      assert(it.text.trim() == "", message: "正文段落应写在 article（或 clause）的内容块中。")
    } else if it.has("children") {
      items += content-items(it)
    }
  }
  items
}

// Used only by the reference edition to bind line spans to semantic content.
// The editable source contains complete paragraphs, never positioned lines.
#let content-text(body) = {
  if body == none { "" }
  else if type(body) == str { body }
  else if body.has("text") { body.text }
  else if content-node(body) { "" }
  else if body.func() == enum {
    let start = body.start
    body.children.enumerate().map(((i, item)) => str(start + i) + content-text(item.body)).fold("", (a, b) => a + b)
  }
  else if body.func() == enum.item { content-text(body.body) }
  else if body.has("children") {
    let result = ""
    let next = 1
    for it in body.children {
      if it.func() == enum.item {
        let rank = if it.has("number") and it.number != none { it.number } else { next }
        result += str(rank) + content-text(it.body)
        next = rank + 1
      } else {
        result += content-text(it)
        if it.func() == parbreak { next = 1 }
      }
    }
    result
  }
  else if body.has("body") { content-text(body.body) }
  else { "" }
}

#let compact-content(body) = content-text(body).replace(regex("\\s+"), "")

#let content-catalog(items) = {
  let catalog = (:)
  let visit(body) = {
    let result = (:)
    if content-node(body) {
      let node = body.value
      if node.type == "table" {
        result.insert(node.key + ":caption", compact-content(node.caption))
        for cell in node.cells {
          result.insert(node.key + ":cell:" + str(cell.row) + ":" + str(cell.column), compact-content(cell.body))
        }
        for (i, note) in node.notes.enumerate() { result.insert(node.key + ":note:" + str(i), compact-content(note)) }
      } else if node.type == "figure" {
        result.insert(node.key + ":caption", compact-content(node.caption))
        result.insert(node.key + ":legend", compact-content(node.legend))
        result.insert(node.key + ":path", node.path)
      }
    } else if body.has("children") { for child in body.children { result += visit(child) } }
    else if body.has("body") { result += visit(body.body) }
    result
  }
  for item in items {
    catalog.insert(item.key, compact-content(item.body))
    catalog += visit(item.body)
  }
  catalog
}

// Two independent rolling checksums include structure, paragraphs, tables,
// figures and associations. Edits select flow layout instead of stale spans.
#let content-shape(value) = {
  let kind = type(value)
  if kind in (str, int, float, bool, none) or value == none { value }
  else if kind == array { value.map(content-shape) }
  else if kind == dictionary {
    let result = (:)
    for (key, child) in value { result.insert(key, content-shape(child)) }
    result
  } else if kind == content {
    (element: repr(value.func()), fields: content-shape(value.fields()))
  } else { repr(value) }
}

#let content-signature(items, front) = {
  let source = bytes(json.encode(content-shape((items, front))))
  let a = 1
  let b = 0
  let c = 7
  for octet in source {
    a = calc.rem(a + octet, 65521)
    b = calc.rem(b + a, 65521)
    c = calc.rem(c * 257 + octet, 1000000007)
  }
  (source.len(), b * 65536 + a, c)
}
