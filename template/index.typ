// Offline pinyin data is derived from pypinyin 0.55.0 (MIT).
// Separate syllables prevent "必备" from sorting after "编号"; tones break
// same-syllable ties, so "标准" sorts before "表" as in the reference index.
#let pinyin-data = json("pinyin.json")
#let plain(value) = {
  if type(value) == str { value }
  else if type(value) == content {
    if value.has("text") { value.text }
    else if value.has("children") { value.children.map(plain).join() }
    else if value.has("body") { plain(value.body) }
    else { "" }
  } else { str(value) }
}
#let pinyin-key(word) = plain(word).clusters().map(c => pinyin-data.at(c, default: lower(c)) + "/" + c).join(" ")

// Put a mark beside the first relevant occurrence; no visible text is added.
// Automatic targets follow the nearest clause, term or native heading.
#let index-mark(word, key: auto, targets: auto) = context {
  let resolved = targets
  if targets == auto {
    let before = query(selector(heading).before(here()))
    if before.len() > 0 {
      let section = before.last()
      resolved = ((number: if section.numbering == none { plain(section.body) }
        else { numbering(section.numbering, ..counter(heading).at(section.location())) },
        location: section.location()),)
    } else { resolved = ((number: counter(page).display(), location: here()),) }
  }
  metadata((kind: "gbt-index", word: plain(word), key: if key == auto { pinyin-key(word) } else { key }, targets: resolved))
}

#let index-link(target, sections) = {
  if type(target) == label { ref(target) }
  else if type(target) == dictionary { link(target.location, target.number) }
  else {
    let normalized = plain(target).replace(" ", "").replace("．", ".")
    let found = sections.filter(s => s.number.replace(" ", "") == normalized)
    if found.len() > 0 { link(found.first().location, target) } else { target }
  }
}

#let index-body(entries: none, columns: 2, font-size: 10.5pt, letter-font: "Source Han Sans SC", letter-weight: "medium", merge: true) = context {
  assert(columns > 0, message: "索引分栏数应大于零。")
  let records = if entries == none {
    query(metadata).filter(e => type(e.value) == dictionary and e.value.at("kind", default: none) == "gbt-index").map(e => e.value)
  } else {
    entries.map(e => (word: plain(e.at(0)), key: if e.len() > 2 { plain(e.at(2)) } else { pinyin-key(e.at(0)) },
      targets: if type(e.at(1)) == array { e.at(1) } else { plain(e.at(1)).split(regex("[，,、]")) }))
  }
  let headings = query(heading).map(e => (number: if e.numbering == none { plain(e.body) }
    else { plain(numbering(e.numbering, ..counter(heading).at(e.location()))) }, location: e.location()))
  let figures = query(figure).filter(e => e.numbering != none).map(e => {
    let id = plain(numbering(e.numbering, ..counter(figure.where(kind: e.kind)).at(e.location())))
    (number: if e.kind == math.equation { "公式（" + id + "）" }
      else { (if e.kind == table { "表" } else { "图" }) + id }, location: e.location())
  })
  let sections = headings + figures
  let words = (:)
  for record in records {
    let old = words.at(record.word, default: (word: record.word, key: record.key, targets: ()))
    let targets = old.targets + if type(record.targets) == array { record.targets } else { plain(record.targets).split(regex("[，,、]")) }
    words.insert(record.word, (word: old.word, key: old.key, targets: targets.dedup()))
  }
  let sorted = (if merge { words.values() } else { records }).sorted(key: e => e.key)
  let content = {
    set text(size: font-size)
    set par(first-line-indent: 0pt, justify: false, leading: 15.75pt - font-size, spacing: 0pt)
    let letter = none
    for record in sorted {
      let initial = upper(record.key.clusters().first())
      if initial != letter {
        letter = initial
        block(width: 100%, above: 15.75pt, below: 15.75pt, sticky: true,
          align(center, text(font: letter-font, weight: letter-weight, size: font-size, letter)))
      }
      block(breakable: false, below: 15.75pt - font-size, layout(size => {
        let refs = record.targets.map(t => index-link(t, sections)).join([，])
        let available = calc.max(36pt, size.width - measure(record.word).width - 38pt)
        let target = if measure(refs).width > available { box(width: available, refs) } else { refs }
        grid(columns: (auto, 1fr, auto), column-gutter: 0.5em, align: top,
          record.word, repeat(box(width: 3.5pt, height: font-size, baseline: 0.12em)[#place(horizon + center, circle(radius: 0.55pt, fill: black, stroke: none))]), target)
      }))
    }
  }
  std.columns(columns, gutter: 6mm, content)
}
