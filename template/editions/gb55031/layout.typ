// Edition-specific page positions. Ordinary documents use construction-standard
// directly; the retained pages preserve their printed page positions.
#import "../../lib.typ": resolve-reference-target, explanation-entry-marker, is-kind, construction-song, construction-hei, construction-roman, construction-font-profile
#import "../../fonts.typ": song, latin, song-family, cjk-pattern, western-pattern, numeral-pattern
#import "../../gb-mark.typ": gb-mark
#import "metrics.typ": edition-glyph-metrics
#import "folios.typ": edition-folio-frames, edition-folio-glyphs

#let edition-ink(sample, weight: "regular", face: "song") = {
  let key = if face == "hei" { if weight == "bold" { "hei-bold" } else { "hei" } }
    else { if weight == "bold" { "bold" } else { "regular" } }
  let metrics = edition-glyph-metrics.at(construction-font-profile).at(key)
  let chars = sample.clusters()
  let glyphs = chars.map(c => metrics.at(c, default: (0, 0, 0.88)))
  (left: glyphs.first().at(0), right: glyphs.last().at(1), ascent: calc.max(..glyphs.map(g => g.at(2))))
}
#let edition-title-number(number, name) = number + "　" + if name.clusters().len() == 2 {
  name.clusters().join("　　")
} else { name }

#let edition-advance(sample, font, size, weight, italic: false, tracking: 0pt) = {
  let lettering = text(font: font, size: size, weight: weight, tracking: tracking,
    style: if italic { "italic" } else { "normal" }, sample)
  measure([#lettering#h(0.1pt, weak: false)]).width - 0.1pt
}

#let edition-folio(sample, frame, landscape: false) = context {
  let glyphs = sample.clusters().map(c => edition-folio-glyphs.at(construction-font-profile).at(c))
  let ink-left = glyphs.first().at(0) * 10pt
  let right = glyphs.last().at(1) * 10pt
  let ascent = calc.max(..glyphs.map(g => g.at(2)))
  let bottom = calc.min(..glyphs.map(g => g.at(3)))
  let body = text(font: construction-roman, style: "italic", size: 10pt, tracking: 0pt,
    top-edge: ascent * 10pt, bottom-edge: -1.2pt, sample)
  let advance = measure([#body#h(0.1pt, weak: false)]).width - 0.1pt
  let ink-width = advance - ink-left - right
  let ink-height = (ascent - bottom) * 10pt
  let sx = (if landscape { frame.at(3) } else { frame.at(2) }) / ink-width
  let sy = (if landscape { frame.at(2) } else { frame.at(3) }) / ink-height
  let fitted = scale(x: sx * 100%, y: sy * 100%, reflow: true, box(body))
  if landscape {
    place(top + left, dx: frame.at(0) - (0.12 + bottom) * 10pt * sy, dy: frame.at(1) - ink-left * sx,
      rotate(90deg, reflow: true, fitted))
  } else {
    place(top + left, dx: frame.at(0) - ink-left * sx, dy: frame.at(1), fitted)
  }
}

#let edition-page(number, body, landscape: false, folio: auto) = {
  let printed = if folio != auto { folio } else if number in (1, 2, 3, 30, 78) { none }
    else if number <= 9 { number - 1 } else { number - 9 }
  page(width: if landscape { 575.433pt } else { 382.677pt },
    height: if landscape { 382.677pt } else { 575.433pt },
    margin: 0pt, header: none, footer: none, numbering: none)[
    #if printed != none { counter(page).update(printed) }
    #metadata((kind: "gb55031-page", source-page: number, folio: printed))
    #body
    #if printed != none {
      edition-folio(str(printed), edition-folio-frames.at(str(number)), landscape: landscape)
    }
    #box(width: 0pt, height: 1pt)
  ]
}

#let edition-row(x, y, width, sample, body: auto, size: 10.5pt, weight: "regular", fill: black, italic: false, vertical: false, face: "song") = context {
  show cjk-pattern: it => it
  show western-pattern: it => it
  show numeral-pattern: it => it
  show regex("^[0-9]+"): marker => if body == auto and sample.match(regex("^[0-9]+ ")) != none {
    text(font: construction-roman, weight: "bold", marker)
  } else { marker }
  show regex("H[1-3]|Sa"): it => box(text(font: construction-roman, style: "italic", tracking: 0pt)[
    #it.text.slice(0, 1)#sub(typographic: false, text(style: "normal", it.text.slice(1)))
  ])
  let font = if face == "hei" { construction-hei } else { construction-song }
  let ink = edition-ink(sample, weight: weight, face: face)
  // Measuring isolated Chinese text trims half an em after final punctuation.
  // The positioned line has spare room and does not trim that space. Include
  // an explicit spacer when measuring so both use the same advance width.
  let measured = edition-advance(sample, font, size, weight, italic: italic)
  // Tracking does not cross every font-run boundary. Count effective spacing
  // slots by measuring one extra point, rather than counting Unicode letters.
  let slots = (edition-advance(sample, font, size, weight, italic: italic, tracking: 1pt) - measured) / 1pt
  // OCR boxes measure visible ink, while measure() includes the invisible
  // side bearings. Without this correction, short lines ending in a comma or
  // full stop were compressed by almost a whole character.
  let advance = width + size * (ink.left + ink.right)
  let tracking = if not vertical and slots > 0 { (advance - measured) / slots } else { 0pt }
  place(top + left, dx: x - if vertical { 0pt } else { ink.left * size }, dy: y,
    block(width: advance + 5pt, above: 0pt, below: 0pt)[
      #set text(font: font, size: size, weight: weight, fill: fill, tracking: tracking,
        style: if italic { "italic" } else { "normal" }, top-edge: ink.ascent * size, bottom-edge: -0.12em)
      #set par(first-line-indent: 0pt, justify: false, leading: 0pt, spacing: 0pt)
      #if body == auto { if vertical { sample.clusters().join(linebreak()) } else { sample } } else { body }
    ])
}

#let edition-heading(it) = context {
  if it.numbering == none { it.body }
  else {
    let numbers = counter(heading).at(it.location())
    let number = numbering(it.numbering, ..numbers)
    let clause = is-kind(it, "gbt-clause")
    let title = if clause { number } else { edition-title-number(number, it.body.text) }
    let size = if it.level == 1 and not clause { 14pt } else { 10.5pt }
    let weight = if clause or it.level > 1 { "bold" } else { "regular" }
    show regex("^[0-9]+"): marker => if not clause and it.level == 1 {
      text(font: construction-roman, weight: "bold", marker)
    } else { marker }
    let font = if not clause and it.level > 1 { construction-hei } else { construction-song }
    let ink = edition-ink(title, weight: weight, face: if not clause and it.level > 1 { "hei" } else { "song" })
    // Measure the text that is actually printed, after resolving its native
    // counter. Measuring the OCR sample before rendering a heading lost its
    // original spacing and made the whole heading narrower.
    layout(available => {
      let natural = edition-advance(title, font, size, weight)
      let slots = (edition-advance(title, font, size, weight, tracking: 1pt) - natural) / 1pt
      text(font: font, size: size, weight: weight,
        tracking: (available.width - 5pt - natural) / calc.max(1, slots),
        top-edge: ink.ascent * size, bottom-edge: -0.12em, title)
    })
    if not clause {
      if it.level == 1 {
        counter(heading).update((chapter, ..rest) => (chapter, 0))
        state("gbt-clause-parent-level", 1).update(2)
      }
    }
  }
}

// Fixed edition rows can attach the label directly to the native heading.
// This avoids a second, context-based target binding inside an absolute place.
#let edition-clause(key) = [#heading(level: 3, outlined: false, supplement: "gbt-clause", metadata((marker-size: 10.5pt)))#label(key)]

#let edition-note-row(page, x, y, width, body, size: 10.5pt, weight: "regular", kind: "text", target: none, vertical: false, face: "song", italic: false) = metadata((kind: "gb55031-note-row", page: page, x: x, y: y, width: width,
    body: body, size: size, weight: weight, row-kind: kind, target: target, vertical: vertical, face: face, italic: italic))

#let edition-note-asset(page, body) = metadata((kind: "gb55031-note-asset", page: page, body: body))

#let edition-explanations(records) = context {
  let pages = (:)
  for record in records {
    let items = if record.body.func() == metadata { (record.body,) }
      else if record.body.has("children") { record.body.children.filter(it => it.func() == metadata) } else { () }
    for item in items {
      let row = item.value
      let key = str(row.page)
      pages.insert(key, pages.at(key, default: ()) + ((row: row, entry: record),))
    }
  }
  for number in range(40, 78) {
    let items = pages.at(str(number), default: ())
    assert(items.len() > 0, message: "条文说明复刻缺少页面 " + str(number))
    edition-page(number, landscape: number in (43, 44, 45, 46))[
      #for item in items {
        let row = item.row
        let record = item.entry
        if row.kind == "gb55031-note-asset" { row.body }
        else if row.row-kind == "entry" {
          explanation-entry-marker(record)
          edition-row(row.x, row.y, row.width, record.number, size: row.size, weight: "bold",
            body: link(record.target, record.number))
        } else if row.row-kind == "group" {
          let source = query(row.target).first()
          let number = numbering(source.numbering, ..counter(heading).at(source.location()))
          let name = source.body
          metadata((kind: "gbt-explanation-group", source: source.location()))
          let title = edition-title-number(number, name.text)
          edition-row(row.x, row.y, row.width, title, size: row.size, weight: row.weight, face: row.face,
            body: link(source.location(), title))
        } else { edition-row(row.x, row.y, row.width, row.body, size: row.size, weight: row.weight,
          vertical: row.vertical, face: row.face, italic: row.italic) }
      }
    ]
  }
}

#let edition-rules(segments, fill: black, stroke: 0.35pt) = {
  for (x1, y1, x2, y2) in segments {
    place(top + left, dx: x1, dy: y1, line(end: (x2 - x1, y2 - y1), stroke: fill + stroke))
  }
}

#let edition-picture(path, x, y, width, height) = place(top + left, dx: x, dy: y, image(path, width: width, height: height))

#let edition-logo() = place(top + left, dx: 289pt, dy: 40pt, gb-mark(width: 64pt, ink: rgb("#14284f")))

#let edition-toc-entry(target, x, y, title-width, part: "body") = context {
  let source = resolve-reference-target(query(target).first())
  let number = numbering(source.numbering, ..counter(heading).at(source.location()))
  let name = source.body.text
  let destination = if part == "body" { source.location() } else {
    let groups = query(metadata).filter(it => type(it.value) == dictionary and
      it.value.at("kind", default: none) == "gbt-explanation-group" and it.value.source == source.location())
    if groups.len() > 0 { groups.first().location() } else { source.location() }
  }
  let folio = str(counter(page).at(destination).first())
  let title = number + "　" + name
  edition-row(x, y, title-width, title, size: 9pt, body: link(destination, title))
  let folio-width = folio.len() * 4.5pt
  edition-row(338pt - folio-width, y, folio-width, folio, size: 9pt,
    body: link(destination, folio))
  let rule-left = x + title-width + 2pt
  for dot-x in range(calc.floor((324pt - rule-left) / 3.5pt)) {
    place(top + left, dx: rule-left + dot-x * 3.5pt, dy: y + 5.5pt,
      circle(radius: 0.55pt, fill: black, stroke: none))
  }
}
