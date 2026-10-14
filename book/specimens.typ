#import "../template/lib.typ": *

// Dimensioned Annex E specimens use explicit ink positions. All lettering,
// placeholder marks and logos remain editable Typst text and vectors.
#let specimen-sans = if font-profile == "reference" { "EU-F1" } else { "Source Han Sans SC" }
#let specimen-placeholder-size = if font-profile == "reference" { 13.5pt } else { 9.75pt }
#let specimen-text(body, font: song, size: 10.5pt, weight: "regular", tracking: 0pt,
  top-edge: "bounds", bottom-edge: "bounds") = {
  // Measurements in the parent book and standalone specimen must agree.
  show cjk-pattern: it => it
  show western-pattern: it => it
  show numeral-pattern: it => it
  text(font: font, size: size, weight: weight, tracking: tracking, top-edge: top-edge, bottom-edge: bottom-edge,
    kerning: false, ligatures: false, discretionary-ligatures: false, body)
}
#let specimen-at(x, y, body, width: none, alignment: left) = {
  place(top + left, dx: x * 1mm, dy: y * 1mm,
    if width == none { body } else { block(width: width * 1mm, align(alignment, body)) })
}
#let specimen-number(code: "GB/T", serial: "XXXXX", size: 10.5pt) = context {
  let number = specimen-text(size: size, font: specimen-sans)[
    #if code == "GB/T" { standard-code(code) } else if code == "DBXX/T" { text(font: latin-bold, weight: if font-profile == "reference" { "regular" } else { "bold" }, [DB]); [XX/T] } else { [XX/T] }#h(0.5em)#serial#text(font: hei)[—]XXXX
  ]
  // EU-F1's dash cmap is non-standard. Only placeholder letters use that face;
  // the dash uses the normal sans face and the printed width is calibrated.
  box(scale(x: (37mm * (size / 10.5pt)) / measure(number).width * 100%, origin: top + left, reflow: true, number))
}
#let specimen-row(count, x, y, advance: 3.75) = {
  for i in range(count) {
    specimen-at(x + i * advance, y,
      text(fill: rgb("#333333"), specimen-text([×], font: if font-profile == "reference" { "FZShuSong-Z01" } else { "Source Han Serif SC" }, size: specimen-placeholder-size)))
  }
}
#let specimen-page(body, verso: false, header: true, folio: false) = {
  set page(width: 210mm, height: 297mm, margin: 0mm, header: none, footer: none, numbering: none)
  set text(font: song, size: body-size, lang: "zh", cjk-latin-spacing: none, overhang: false)
  set par(first-line-indent: 0pt, justify: false, spacing: 0pt, leading: 0pt)
  if header { specimen-at(if verso { 20 } else { 25 }, 25, specimen-number(), width: 165, alignment: if verso { left } else { right }) }
  if folio { specimen-at(if verso { 24 } else { 25 }, 274, specimen-text([XX], font: specimen-sans, size: 10.5pt),
    width: if verso { none } else { 161 }, alignment: if verso { left } else { right }) }
  body
  box(width: 0pt, height: 1pt)
}
#let specimen-title(body, size: 16pt, y: 43.5) = specimen-at(0, y,
  specimen-text(body, font: hei, size: calibrated(size), weight: black-weight,
    tracking: if font-profile == "reference" { reference-spacing.body-hei.tracking } else { 0pt }), width: 210, alignment: center)

#let specimen-category-cross(x, y) = context {
  // Exact glyph bounds, in font units; text's generic bounds also contain
  // line metrics, which differ between the two fonts.
  let metrics = if font-profile == "reference" { (em: 1008, left: 248, width: 510, top: 510, bottom: 0) }
    else { (em: 1000, left: 178, width: 644, top: 698, bottom: 54) }
  let unit = 32pt / metrics.em
  let cross = specimen-text([×], font: hei, size: 32pt,
    top-edge: metrics.top * unit, bottom-edge: -metrics.bottom * unit)
  specimen-at(x - 7 * metrics.left / metrics.width, y,
    scale(x: 7mm / (metrics.width * unit) * 100%,
      y: 7mm / ((metrics.top - metrics.bottom) * unit) * 100%, origin: top + left, reflow: true, cross))
}

#let specimen-publisher(kind) = {
  let name = if kind == "national" { [国家标准发布部门] } else if kind == "industry" { [行业标准发布部门] } else { [地方标准发布部门] }
  let gap = if kind == "national" { 5mm } else { 10mm }
  let style(body) = specimen-text(body, font: hei, size: 14pt, weight: black-weight,
    top-edge: 14pt * 0.88, bottom-edge: -14pt * 0.12)
  let name-width = name.text.clusters().len() * 14pt
  let char-width = 14pt
  let total = name-width + gap + 2 * char-width + 3mm
  let x = 110mm - total / 2
  (name: name, style: style, x: x / 1mm, right: (x + name-width) / 1mm,
    fa: (x + name-width + gap) / 1mm, bu: (x + name-width + gap + char-width + 3mm) / 1mm,
    char-width: char-width / 1mm, note: if kind == "national" { [a] } else { [b] })
}
#let specimen-cover(kind: "national") = specimen-page(header: false)[
  #let local = kind == "local"
  #let code = if local { "DBXX/T" } else if kind == "industry" { "XX/T" } else { "GB/T" }
  #let serial = if local { "XXX" } else { "XXXXX" }
  #let field(prefix, value) = specimen-text(size: 10.5pt, font: specimen-sans)[
    #text(font: latin-bold, weight: if font-profile == "reference" { "regular" } else { "bold" }, prefix)#h(0.5em)#value
  ]
  #specimen-at(25, 10, field("ICS", [XXXXXXX]))
  #specimen-at(25, 14.4, field("CCS", [X XX]))
  #if kind == "industry" { specimen-at(25, 19.2, specimen-text([备案号：XXXX—XXXX], font: hei, size: 10.5pt)) }
  #if kind == "national" { specimen-at(144, 13, gb-mark(width: 40mm)) } else {
    specimen-at(144, 13, letter-mark([XX], note: [a], font: specimen-sans))
    if local { specimen-at(100, 13, db-mark()) }
  }
  #let category = {
    if kind == "national" { [中华人民共和国国家标准] }
    else if kind == "industry" { [中华人民共和国××行业标准] }
    else { [××××（地方名称）地方标准] }
  }
  #let cat = specimen-text(category, font: if kind == "national" { display-song } else { hei },
    size: 25.556pt, weight: if font-profile == "reference" { "regular" } else { "bold" }, tracking: 8.1394pt)
  #context {
    if local {
      for x in (25, 41, 57, 73) { specimen-category-cross(x, 42.5) }
      let words = specimen-text([（地方名称）地方标准], font: hei, size: 25.556pt, weight: black-weight, tracking: 8.1394pt)
      let natural = measure(words)
      specimen-at(83, 42, scale(x: 112mm / natural.width * 100%, y: 8mm / natural.height * 100%, origin: top + left, reflow: true, words))
    } else if kind == "industry" {
      let parts = category.text.clusters()
      let letters = parts.map(c => specimen-text(c, font: hei, size: 25.556pt, weight: black-weight,
        top-edge: 25.556pt * 0.88, bottom-edge: -25.556pt * 0.12))
      let ink-height = measure(specimen-text([中华人民共和国行业标准], font: hei, size: 25.556pt, weight: black-weight)).height
      let total = letters.map(c => measure(c).width).sum() + 12 * 8.1394pt
      let factor = 170mm / total
      let x = 25.0
      for (i, letter) in letters.enumerate() {
        let natural = measure(letter)
        let cross = parts.at(i) == "×"
        if cross { specimen-category-cross(x + (natural.width / 1mm * factor - 7) / 2, 42.5) }
        else { specimen-at(x, 41.8, scale(x: factor * 100%, y: 8mm / ink-height * 100%, origin: top + left, reflow: true, letter)) }
        x += (natural.width + 8.1394pt) / 1mm * factor
      }
    } else {
      let natural = measure(cat)
      specimen-at(25, 42, scale(x: 170mm / natural.width * 100%, y: 8mm / natural.height * 100%, origin: top + left, reflow: true, cat))
    }
  }
  #specimen-at(25, 59, specimen-number(code: code, serial: serial, size: 14pt), width: 165, alignment: right)
  #specimen-at(25, 66, specimen-text(font: hei, size: 10.5pt)[代替#specimen-number(code: code, serial: serial)], width: 165, alignment: right)
  #specimen-at(25, 75, line(length: 170mm, stroke: 0.6pt))
  #context {
    let title = specimen-text([标准名称], font: hei, size: 25.535pt, weight: black-weight)
    let natural = measure(title)
    specimen-at(84, 115.7, scale(x: 42mm / natural.width * 100%, y: 7.5mm / natural.height * 100%, origin: top + left, reflow: true, title))
  }
  #if not local {
    specimen-at(0, 133.7, specimen-text([标准名称的英文译名], font: hei, size: 14pt, weight: black-weight), width: 210, alignment: center)
    specimen-at(0, 152.5, specimen-text([（与国际标准一致性程度的标识）], font: hei, size: 14pt, weight: black-weight), width: 210, alignment: center)
  }
  #specimen-at(25, 252, specimen-text(font: hei, size: 14pt, top-edge: 14pt * 0.88, bottom-edge: -14pt * 0.12)[#text(font: specimen-sans)[XXXX-XX-XX]#h(0.4em)发布])
  #specimen-at(25, 252, specimen-text(font: hei, size: 14pt, top-edge: 14pt * 0.88, bottom-edge: -14pt * 0.12)[#text(font: specimen-sans)[XXXX-XX-XX]#h(0.4em)实施], width: 170, alignment: right)
  #specimen-at(25, 257, line(length: 170mm, stroke: 0.6pt))
  #context {
    let p = specimen-publisher(kind)
    specimen-at(p.x, 273, (p.style)(p.name))
    specimen-at(p.right + 0.2, 271.8, specimen-text(p.note, size: 7.5pt))
    specimen-at(p.fa, 273, (p.style)([发]))
    specimen-at(p.bu, 273, (p.style)([布]))
  }
]

// Native outline entries still query the real chapters, figures and counters
// in e8.typ. The row pitch and dots follow the printed Annex E specimen.
#let specimen-contents() = {
  set text(font: song, size: body-size, top-edge: 0.88em, bottom-edge: -0.12em)
  set par(first-line-indent: 0pt, justify: false, spacing: 0pt, leading: 0pt)
  show regex("[\\p{Han}\\u3000-\\u303f\\uff00-\\uffef]+"): it => text(tracking: if font-profile == "reference" { 10.4798pt - body-size } else { 0pt }, it)
  show regex("×+"): it => text(font: if font-profile == "reference" { "FZShuSong-Z01" } else { "Source Han Serif SC" },
    size: specimen-placeholder-size, fill: rgb("#333333"), tracking: 10.5pt - specimen-placeholder-size,
    top-edge: body-size * 0.88, bottom-edge: -body-size * 0.12, it)
  set outline.entry(fill: repeat(box(width: 5.1pt, height: body-size, baseline: 0.12em,
    align(center + horizon, circle(radius: 0.55pt, fill: rgb("#000000"), stroke: none)))))
  // Row centers measured visually from the source figure. Native entries
  // supply all wording, links and folios; only their vertical spacing is fixed.
  let rows = (63.13, 70.52, 77.91, 85.68, 92.88, 100.37, 107.86, 113.73,
    119.99, 127.38, 134.58, 140.83, 148.23, 155.52, 161.49, 167.37,
    174.95, 182.34, 188.41, 194.47, 201.48, 209.07, 216.46, 223.85,
    235.79, 241.76, 247.92, 259.86, 265.55, 271.80)
  let row-counter = counter("gbt-specimen-outline-row")
  row-counter.update(0)
  show outline.entry: it => context {
    let element = it.element
    let number = if element.func() == heading and element.numbering != none { numbering(element.numbering, ..counter(heading).at(element.location())) } else { "" }
    let in-annex = type(number) == str and number.match(regex("^[A-Z]\\.")) != none
    if not (in-annex and it.level >= 2) {
      let is-heading = element.func() == heading
      let row = row-counter.get().first()
      assert(row < rows.len(), message: "图 E.8 的目录条目数量发生变化，请复核版式。")
      let pitch = if row + 1 < rows.len() { (rows.at(row + 1) - rows.at(row)) * 1mm } else { 6mm }
      row-counter.step()
      let indent = (it.level - 1 + if in-annex { 1 } else { 0 }) * 1em
      let entry = if is-heading and element.numbering == none and not is-kind(element, "gbt-annex") {
        let name = if it.body().has("children") { it.body().children.filter(c => c.func() != h).join() } else { it.body() }
        [#name#h(0.5em)#box(width: 1fr, it.fill)#h(0.5em)#it.page()]
      } else { it.inner() }
      block(width: 100%, height: pitch, link(element.location(), pad(left: indent,
        grid(columns: (auto, 1fr), column-gutter: if it.prefix() == none { 0pt } else { 1em }, it.prefix(), entry))))
    }
  }
  outline(title: none, depth: 2, indent: 1em)
  outline(title: none, target: figure.where(kind: image), indent: 0pt)
  outline(title: none, target: figure.where(kind: table), indent: 0pt)
}

#let specimen-index(entries) = context {
  let sorted = entries.sorted(key: e => e.at(2))
  let initial = none
  let y = 61.2
  for entry in sorted {
    let letter = upper(entry.at(2).clusters().first())
    if initial != letter {
      if initial != none { y += 10.5 }
      specimen-at(25, if initial == none { 54 } else { 135.25 },
        scale(x: if letter == "A" { 51% } else { 60% }, reflow: true, specimen-text(letter, font: latin)), width: 173.6, alignment: center)
      initial = letter
    }
    let count = entry.at(0).text.clusters().len()
    let refs = specimen-text(entry.at(1), tracking: 0.5pt)
    let ref-width = measure(refs).width / 1mm
    specimen-row(count, 25.5, y)
    let leader-start = 25.5 + count * 3.75 + 2
    let leader-end = 189 - ref-width - 2
    for x in range(int(leader-start * 10), int(leader-end * 10), step: 18) {
      specimen-at(x / 10, y + 1.2, circle(radius: 0.22mm, fill: rgb("#000000"), stroke: none))
    }
    specimen-at(25, y, refs, width: 165, alignment: right)
    y += 6.465
  }
  for i in range(12) { specimen-at(25.5 + i * 1.8, 164.5, circle(radius: 0.22mm, fill: rgb("#000000"), stroke: none)) }
  specimen-at(78.75, 179, line(length: 52.5mm, stroke: 0.6pt))
}
