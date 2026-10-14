// GB/T 1.1-2020, clauses 7 to 10 and normative annexes E and F.
// All dimensions are physical; no remote packages or system fonts are required.
#import "gb-mark.typ": gb-mark
#import "letter-marks.typ": db-mark
#import "index.typ": index-mark, index-body
#import "fonts.typ": *
#import "explanations.typ": explain, explanations, explanation-entry-marker
#import "construction.typ": construction-page, construction-text, construction-paragraph, construction-heading, construction-cover, construction-explanation-heading, construction-explanation-entry, construction-enum-marker, construction-song, construction-song-family, construction-hei, construction-roman, construction-font-profile
#let annex-state = state("gbt-annex", none)
#let annex-title-state = state("gbt-annex-title", none)
#let equation-counter = counter(figure.where(kind: math.equation))
#let table-counter = counter(figure.where(kind: table))
#let image-counter = counter(figure.where(kind: image))
#let two-sided-state = state("gbt-two-sided", true)
#let clause-parent-level = state("gbt-clause-parent-level", 1)
#let list-depth-state = state("gbt-list-depth", 0)

// Major sections start on a recto in two-sided documents. Authors can also
// request a verso explicitly; Typst inserts the required blank side.
#let new-page(side: auto, weak: false) = context {
  let target = if side == auto { if two-sided-state.get() { "odd" } else { none } } else { side }
  assert(target in (none, "odd", "even"), message: "side 应为 auto、none、odd 或 even。")
  pagebreak(to: target, weak: weak)
}

#let black(body, size: auto) = context {
  let base = if size == auto { text.size } else { calibrated(size) }
  let rendered = if size == auto and cjk-role(text.font) == "hei" { base } else { black-size(base) }
  let edge(value) = if type(value) == length { value.to-absolute() } else { value }
  text(font: hei, weight: black-weight, size: rendered,
    baseline: text.baseline.to-absolute(),
    top-edge: if size == auto { edge(text.top-edge) } else { base * 0.88 },
    bottom-edge: if size == auto { edge(text.bottom-edge) } else { -base * 0.12 }, body)
}
#let fit-line(body, width) = context {
  let natural = measure(body).width
  if natural > width { scale(x: width / natural * 100%, reflow: true, body) } else { body }
}
#let standard-code(code) = {
  let parts = code.split("/")
  for (i, part) in parts.enumerate() {
    if i > 0 { text(font: if font-profile == "reference" { "FZHei-B01" } else { "Source Han Sans SC" }, weight: "regular", [/]) }
    text(font: latin-bold, weight: if font-profile == "reference" { "regular" } else { "bold" }, part)
  }
}
#let standard-number(code, serial, year) = [#standard-code(code)#h(0.5em)#text(font: digits, weight: "regular", [#serial—#year])]
#let letter-mark(body, width: 40mm, height: 20mm, note: none, font: if font-profile == "reference" { "EU-F1" } else { "Source Han Sans SC" }) = context {
  // A logo's cap height must not inherit the running-text Latin calibration.
  show western-pattern: it => it
  show numeral-pattern: it => it
  let marked = if body == [XX] { [X#h(0.25em)X] } else { body }
  let lettering = text(font: font, weight: "regular", size: 56pt,
    // These specimen fonts have no sCapHeight. Use the measured X bound;
    // their ascender would compress the requested 20 mm capital height.
    top-edge: if font == "EU-F1" { 0.75em } else if font == "EU-FZ" { 0.7177734375em } else { "cap-height" },
    bottom-edge: "baseline", marked)
  let natural = measure(lettering)
  box(width: width, height: height)[
    #place(top + left, scale(x: width / natural.width * 100%, y: height / natural.height * 100%, origin: top + left, reflow: true, lettering))
    #if note != none { place(top + right, dx: 1mm, text(size: 9pt, note)) }
  ]
}
#let number-for(counter) = context {
  let prefix = annex-state.get()
  if prefix != none { [#prefix.] }
  counter.display("1")
}
#let cover(
  title: (), english: (), code: "GB/T", serial: "XXXXX", year: "2026",
  ics: "01.120", ccs: "A 00", replaces: none, adopted: none,
  issued: "XXXX-XX-XX", implemented: "XXXX-XX-XX",
  organizations: ("国家市场监督管理总局", "国家标准化管理委员会"),
  category: "中华人民共和国国家标准", logo: auto,
  record: none, draft: none, organization-note: none, publisher-gap: 5mm,
) = {
  set page(width: 210mm, height: 297mm, margin: 0mm, header: none, footer: none, numbering: none)
  set par(first-line-indent: 0pt, spacing: 0pt, leading: 3mm)
  set text(font: hei, weight: black-weight, size: if font-profile == "reference" { reference-sizes.cover-digits } else { 10.5pt }, ligatures: false, discretionary-ligatures: false)
  place(top + left, dx: 25mm, dy: 10mm, block[
    #set par(leading: 1pt)
    #text(font: latin-bold, weight: if font-profile == "reference" { "regular" } else { "bold" }, "ICS")#h(0.5em)#text(font: digits, weight: "regular", ics)\
    #text(font: latin-bold, weight: if font-profile == "reference" { "regular" } else { "bold" }, "CCS")#h(0.5em)#context {
      let parts = ccs.split(" ")
      text(font: latin-bold, parts.first())
      for part in parts.slice(1) { h(0.5em); text(font: digits, part) }
    }
    #if record != none { linebreak(); record }
  ])
  if logo != none {
    place(top + left, dx: 144mm, dy: 13mm,
      if logo == auto { gb-mark(width: 40mm) } else if type(logo) == str { image(logo, width: 40mm) } else { logo })
  }
  place(top + left, dx: 25mm, dy: 42mm, box(width: 170mm)[
    #context {
      let lettering = text(font: if category == "中华人民共和国国家标准" { display-song } else { hei }, weight: if font-profile == "reference" { "regular" } else { "bold" },
        size: if font-profile == "reference" { reference-sizes.category } else { 25pt },
        tracking: if font-profile == "reference" { reference-spacing.category.tracking } else { 2pt }, category)
      let natural = measure(lettering).width
      scale(x: 170mm / natural * 100%, origin: top + left, lettering)
    }
  ])
  place(top + left, dx: 25mm, dy: 58mm, block(width: 165mm)[
    #align(right, text(size: if font-profile == "reference" { reference-sizes.cover-latin } else { 14pt }, standard-number(code, serial, year)))
    #if replaces != none {
      v(2mm)
      let parts = if type(replaces) == str { replaces.match(regex("^(.*?) +([0-9.X]+)[—–-]([0-9X]{4})$")) } else { none }
      align(right, [代替#h(0.5em)#if parts == none { replaces } else { standard-number(..parts.captures) }])
    }
  ])
  place(top + left, dx: 25mm, dy: 75mm, line(length: 170mm, stroke: 0.6pt))
  place(top + left, dx: 25mm, dy: 115mm, block(width: 170mm)[
    #align(center)[
      #set text(font: hei, size: if font-profile == "reference" { reference-sizes.cover-title } else { 26pt },
        weight: black-weight, tracking: if font-profile == "reference" { 1.926pt } else { 0pt })
      #for (i, part) in title.enumerate() {
        if i > 0 { v(3mm) }
        block(width: 100%, align(center, fit-line(part, 170mm)))
      }
      #v(10mm)
      #set text(font: ((name: latin-bold, covers: bold-covers),
        ..if font-profile == "reference" { ((name: latin, covers: latin-covers),) } else { () }, hei-family),
        size: if font-profile == "reference" { reference-sizes.cover-latin } else { 14pt },
        tracking: if font-profile == "reference" { reference-spacing.cover-latin.tracking } else { 0pt },
        weight: if font-profile == "reference" { "regular" } else { "bold" })
      #for (i, part) in english.enumerate() {
        if i > 0 { v(3mm) }
        block(width: 100%, align(center, fit-line(part, 170mm)))
      }
      #if adopted != none { v(15mm); [（#adopted）] }
      #if draft != none { v(8mm); black(draft, size: 14pt) }
    ]
  ])
  place(top + left, dx: 25mm, dy: 249mm, block(width: 170mm)[
    #set text(font: hei, weight: "regular", size: if font-profile == "reference" { reference-sizes.cover-latin } else { 14pt })
    #grid(columns: (1fr, 1fr), [#issued#h(0.5em)发布], align(right)[#implemented#h(0.5em)实施])
  ])
  place(top + left, dx: 25mm, dy: 257mm, line(length: 170mm, stroke: 0.6pt))
  place(top + left, dx: 25mm, dy: if organizations.len() == 1 { 273mm } else if font-profile == "reference" { 264mm } else { 267mm }, block(width: 170mm)[
    #let single = organizations.len() == 1
    #set par(leading: if font-profile == "reference" { 19.2129pt - reference-sizes.publisher } else { 3mm })
    // Center the publisher group, but share one left edge across name lines.
    #align(center, grid(columns: (auto, auto), column-gutter: publisher-gap, align: horizon,
      align(left, scale(x: if font-profile == "reference" and not single { reference-spacing.publisher.x } else { 100% }, reflow: true,
        text(font: if single { hei } else { display-song }, size: if single { 14pt } else if font-profile == "reference" { reference-sizes.publisher } else { 18pt },
        tracking: if font-profile == "reference" and not single { reference-spacing.publisher.tracking } else { 0pt }, weight: if font-profile == "reference" { "regular" } else { "bold" }, [#organizations.join(linebreak())#if organization-note != none { super(organization-note) }]))),
      black([发#h(3mm)布], size: 14pt)))
  ])
  // A non-floating item makes the absolutely positioned page real.
  box(width: 0pt, height: 1pt)
}

#let front-title(body, outlined: false, compact: false, kind: none) = heading(level: 1, numbering: none,
  supplement: if kind != none { kind } else if compact { "gbt-compact" } else { none }, outlined: outlined, body)

#let clause-marker(it, size) = context {
  let number = numbering(it.numbering, ..counter(heading).at(it.location()))
  metadata((kind: "gbt-section", number: number, key: if it.has("label") { str(it.label) } else { none }))
  let indent = par.first-line-indent
  h(-if type(indent) == dictionary { indent.amount } else { indent })
  text(font: hei, weight: "regular", size: size, number)
  h(body-indent - body-size)
}

#let bind-native-target(source) = context {
  let section = query(selector(heading).before(here())).last()
  let owners = query(source)
  metadata((kind: "gbt-native-target", source: source, target: section.location(),
    number: numbering(section.numbering, ..counter(heading).at(section.location())),
    label: if owners.len() > 0 and owners.first().has("label") { str(owners.first().label) } else { none }))
}

// Native labels attach to a contextual component. Resolve that component to
// its single native heading; numbering and outline entries still belong to it.
#let resolve-reference-target(target) = {
  if target.func() == heading or target.func() == figure { target }
  else {
    let bindings = query(metadata).filter(e => type(e.value) == dictionary and
      e.value.at("kind", default: none) == "gbt-native-target" and e.value.source == target.location())
    if bindings.len() > 0 { query(bindings.first().value.target).first() } else { target }
  }
}

#let clause(level: auto, outlined: true) = context {
  let source = here()
  let depth = if level == auto { clause-parent-level.get() + 1 } else { level }
  assert(depth <= 6, message: "无标题条的编号层级不得超过六级。")
  // A native heading owns numbering, outline inclusion and reference location.
  // Its show rule renders only an inline marker before the ordinary paragraph.
  // Capture the paragraph size before the heading's own style is applied.
  // Keeping it on the native element avoids competing local show rules.
  heading(level: depth, outlined: outlined, supplement: "gbt-clause",
    metadata((marker-size: text.size)))
  bind-native-target(source)
}

#let is-kind(it, kind) = it.supplement == kind or it.supplement == [#kind]
#let numbered-marker(numbers, indent) = {
  let values = numbers.pos()
  let nested = values.len() > 1
  box(width: if nested { indent } else { 2 * indent })[
    #if not nested { h(indent) }
    #numbering(if nested { "1)" } else { "a)" }, values.last())
  ]
}
#let unordered-marker(depth, indent) = if depth == 0 {
  box(width: 2 * indent)[#h(indent)#text(font: song.last(), tracking: 0pt)[——]]
} else { box(width: indent)[·] }
#let note-outdent(depth) = {
  if depth > 0 { (depth + 1) * body-indent } else { 0pt }
}

#let note(body, number: none) = context pad(left: -note-outdent(list-depth-state.get()), block(above: 0.3em, below: 0.3em)[
  #set text(font: song, size: note-size, top-edge: note-size * 0.88, bottom-edge: -note-size * 0.12)
  #set par(first-line-indent: 0pt, leading: 13.5pt - note-size)
  #pad(left: 2em)[
    #grid(columns: (auto, 1fr), column-gutter: 0pt, align: left + top,
      black(if number == none { [注：] } else { [注#number：] }, size: 9pt), body)
  ]
])

#let example(body, number: none, framed: false, inline: false) = context pad(left: -note-outdent(list-depth-state.get()), block(above: 0.4em, below: 0.4em)[
  #set align(left)
  #set text(font: song, size: note-size, top-edge: note-size * 0.88, bottom-edge: -note-size * 0.12)
  #set par(first-line-indent: 0pt, leading: 13.5pt - note-size, spacing: 13.5pt - note-size)
  #set list(marker: depth => unordered-marker(depth, 18pt), indent: 0pt, body-indent: 0pt, spacing: 15pt - note-size)
  #set enum(numbering: (..numbers) => numbered-marker(numbers, 18pt), full: true, indent: 0pt, body-indent: 0pt, spacing: 15pt - note-size)
  #let prefix = black(if number == none { [示例：] } else { [示例#number：] }, size: 9pt)
  #if inline and not framed {
    par(first-line-indent: (amount: 18pt, all: true))[#prefix#body]
  } else {
    block(sticky: true)[#h(18pt)#prefix]
    if framed { block(stroke: 0.5pt, inset: 1em)[
      #set text(size: body-size, top-edge: body-size * 0.88, bottom-edge: -body-size * 0.12)
      #set par(leading: body-gap)
      #body
    ] } else { [#set par(first-line-indent: (amount: 18pt, all: true)); #body] }
  }
])

#let term(chinese, english, definition, level: auto, source: none, notes: (), examples: ()) = context {
  let origin = here()
  let depth = if level == auto { clause-parent-level.get() + 1 } else { level }
  heading(level: depth, outlined: false, supplement: "gbt-term")[
    #black(chinese)#h(10.5pt)#text(font: latin-bold-fonts, weight: if font-profile == "reference" { "regular" } else { "bold" }, english)
  ]
  bind-native-target(origin)
  block(sticky: source != none and notes.len() == 0 and examples.len() == 0,
    par(first-line-indent: body-indent, definition))
  for (i, item) in examples.enumerate() { example(item, number: if examples.len() > 1 { i + 1 } else { none }) }
  for (i, item) in notes.enumerate() { note(item, number: if notes.len() > 1 { i + 1 } else { none }) }
  if source != none { par(first-line-indent: body-indent)[\[来源：#source\]] }
}

#let annex(letter, title, normative: true, body) = {
  assert(letter.len() == 1 and letter.match(regex("^[A-Z]$")) != none,
    message: "附录编号应为单个大写拉丁字母。")
  new-page(weak: true)
  annex-state.update(letter)
  annex-title-state.update((letter: letter, title: title, normative: normative))
  clause-parent-level.update(0)
  counter(heading).update(0)
  table-counter.update(0)
  image-counter.update(0)
  equation-counter.update(0)
  set heading(numbering: (..numbers) => letter + "." + numbers.pos().map(str).join("."), supplement: "gbt-annex-section")
  set figure(numbering: n => letter + "." + str(n))
  let title-heading = heading(level: 1, numbering: none, supplement: "gbt-annex")[附录#h(0.5em)#letter#if normative { [（规范性）] } else { [（资料性）] }#h(1em)#title]
  [#title-heading#label("annex-" + lower(letter))]
  metadata((kind: "annex", letter: letter, normative: normative, title: title))
  body
  annex-state.update(none)
}

#let figure-note(body, letter: "a") = {
  set text(font: song, size: note-size, top-edge: note-size * 0.88, bottom-edge: -note-size * 0.12)
  set par(first-line-indent: 0pt, leading: 13.5pt - note-size)
  pad(left: 2em, grid(columns: (1em, 1fr), align: left + top, super(letter), body))
}

#let gbt-table(caption, columns: (), headers: (), rows: (), notes: (), footnotes: (),
  header-rows: (), unit: none, continued: false, number: auto, font-size: 9pt, cell-align: left + horizon, outlined: true,
  body-stroke: 0.4pt, trailing: (), keep-last-rows: 0, closed: true) = {
  assert(columns.len() > 0, message: "表格应至少包含一列。")
  assert(header-rows.len() > 0 or headers.len() == columns.len(), message: "单行表头数量应与列数一致；多行合并表头请使用 header-rows。")
  assert(keep-last-rows >= 0 and keep-last-rows <= rows.len(), message: "保留末尾行数应在表体行数范围内。")
  // Keep a complete final cell group and its notes on the same final page.
  // A caller chooses the whole rowspan group, rather than splitting a merge.
  let ending = (
    ..if trailing.len() > 0 or notes.len() > 0 {
      (table.hline(stroke: 0.8pt), table.cell(colspan: columns.len(), inset: (x: 0pt, y: 0.4em))[
        #set par(first-line-indent: (amount: 18pt, all: true), leading: 13.5pt - note-size, spacing: 13.5pt - note-size)
        #for paragraph in trailing { par(paragraph) }
        #for (i, body) in notes.enumerate() { note(body, number: if notes.len() > 1 { i + 1 } else { none }) }
      ])
    } else { () },
    ..if footnotes.len() > 0 {
      (table.hline(stroke: 0.8pt), table.cell(colspan: columns.len(), inset: (x: 0pt, y: 0.4em))[
        #for (i, body) in footnotes.enumerate() { figure-note(body, letter: numbering("a", i + 1)) }
      ])
    } else { () },
    table.hline(stroke: if closed { 0.8pt } else { none }),
  )
  figure(kind: table, supplement: [表],
    ..if continued or number == none { (numbering: none) } else if number != auto { (numbering: n => number) } else { (:) },
    caption: if continued { none } else { caption }, outlined: outlined and not continued and number != none, gap: 0pt,
    block(above: 0.5em, below: 1em, breakable: rows.len() > 8)[
      #set par(first-line-indent: 0pt)
      // Keep cell baselines equal when a calibrated black font is slightly larger.
      #set text(font: song, size: calibrated(font-size),
        top-edge: calibrated(font-size) * 0.88, bottom-edge: -calibrated(font-size) * 0.12)
      #table(columns: columns, inset: (x: 0.6em, y: 0.59em), stroke: body-stroke, align: cell-align,
        table.vline(x: 0, start: 1, stroke: 0.8pt),
        table.vline(x: columns.len(), start: 1, stroke: 0.8pt),
        table.header(
          table.cell(colspan: columns.len(), stroke: none, inset: (x: 0pt, top: 0pt, bottom: 1.5em))[
            #set text(size: body-size, top-edge: body-size * 0.88, bottom-edge: -body-size * 0.12)
            #context {
              let outer = query(figure.where(kind: table).before(here(), inclusive: true)).last()
              let id = if number == auto {
                if outer.numbering == none { number-for(table-counter) }
                else { numbering(outer.numbering, ..table-counter.at(outer.location())) }
              } else { number }
              let carry = continued or here().page() > outer.location().page()
              align(center)[#black[#if number != none { [表#h(0.5em)#id#h(1em)] }#caption]#if carry { text(font: song, weight: "regular", size: body-size)[（续）] }]
            }
            #if unit != none { v(0.3em); align(right, text(font: song, size: note-size,
              top-edge: note-size * 0.88, bottom-edge: -note-size * 0.12, unit)) }
          ],
          table.hline(stroke: 0.8pt),
          ..if header-rows.len() > 0 { header-rows.flatten().map(it => if it.func() == table.cell { it } else { table.cell(align: center + horizon, it) }) }
            else { headers.map(it => if it.func() == table.cell { it } else { table.cell(align: center + horizon, it) }) },
          table.hline(stroke: 0.8pt),
        ),
        ..rows.slice(0, rows.len() - keep-last-rows).flatten(),
        ..if keep-last-rows > 0 {
          (table.footer(repeat: false, ..rows.slice(rows.len() - keep-last-rows).flatten(), ..ending),)
        } else { ending },
      )
    ]
  )
}

#let gbt-figure(caption, body, unit: none, notes: (), footnotes: (), number: auto, font-size: 7.5pt, outlined: true) = {
  figure(kind: image, supplement: [图],
    ..if number == none { (numbering: none) } else if number != auto { (numbering: n => number) } else { (:) },
    caption: caption, outlined: outlined and number != none, gap: 0pt,
    block(above: 1em, below: 0.5em)[
      #set align(left)
      #set par(first-line-indent: 0pt)
      #if unit != none { align(right, text(font: song, size: note-size,
        top-edge: note-size * 0.88, bottom-edge: -note-size * 0.12, unit)) }
      #align(center)[
        #let size = calibrated(font-size)
        #set text(font: song, size: size, top-edge: size * 0.88, bottom-edge: -size * 0.12)
        #body
      ]
      #for (i, item) in notes.enumerate() { note(item, number: if notes.len() > 1 { i + 1 } else { none }) }
      #for (i, item) in footnotes.enumerate() { figure-note(item, letter: numbering("a", i + 1)) }
      #v(0.5em)
      #context {
        let outer = query(figure.where(kind: image).before(here(), inclusive: true)).last()
        let id = if number == none { none } else { numbering(outer.numbering, ..image-counter.at(outer.location())) }
        align(center, black(size: 10.5pt)[#if id != none { [图#h(0.5em)#id#h(1em)] }#caption])
      }
    ]
  )
}

#let gbt-equation(body, definitions: (), number: auto) = figure(
  kind: math.equation, supplement: [公式], outlined: false,
  ..if number == none { (numbering: none) } else if number != auto { (numbering: n => number) } else { (:) },
  caption: [], gap: 0pt,
  block(above: 0.7em, below: 0.5em)[
    #set align(left)
    #set par(first-line-indent: 0pt)
    #context {
      let outer = query(figure.where(kind: math.equation).before(here(), inclusive: true)).last()
      let id = if outer.numbering == none { none } else { numbering(outer.numbering, ..equation-counter.at(outer.location())) }
      if id == none { align(center, math.equation(block: false, body)) } else {
        grid(columns: (1fr, auto, 1fr), align: horizon, gutter: 0pt,
          [], math.equation(block: false, body),
          grid(columns: (1fr, auto), column-gutter: 0.5em, align: horizon,
            repeat(box(width: 3pt, height: text.size, baseline: 0.12em)[#place(horizon + center, circle(radius: 0.5pt, fill: rgb("#000000"), stroke: none))]), [（#id）]))
      }
    }
    #if definitions.len() > 0 {
      par(first-line-indent: 2em)[式中：]
      pad(left: 2em, grid(columns: (auto, auto, 1fr), align: left + top, column-gutter: 0.5em, row-gutter: 0.2em,
        ..definitions.map(it => (it.at(0), [——], it.at(1))).flatten()))
    }
  ]
)

#let references(entries) = {
  new-page(weak: true)
  front-title([参#h(0.5em)考#h(0.5em)文#h(0.5em)献], outlined: true, compact: true)
  for (i, entry) in entries.enumerate() { par(first-line-indent: 2em)[#text("[" + str(i + 1) + "]")#h(1em)#entry] }
}

#let keyword-index(entries: none, columns: 2, merge: true) = {
  new-page(weak: true)
  front-title([索#h(21pt)引], outlined: true, compact: true, kind: "gbt-index")
  index-body(entries: entries, columns: columns,
    font-size: body-size, letter-font: latin-bold, letter-weight: if font-profile == "reference" { "regular" } else { "bold" }, merge: merge)
}

#let end-mark() = block(width: 100%, above: 1.5em, breakable: false)[
  #align(center, line(length: 25%, stroke: 1pt))
]

#let back-cover(code: "GB/T", serial: "XXXXX", year: "2026") = {
  set page(paper: "a4", margin: 0mm, header: none, footer: none, numbering: none)
  place(top + right, dx: -5mm, dy: 25mm,
    rotate(-90deg, reflow: true, black(standard-number(code, serial, year), size: 14pt)))
  box(width: 0pt, height: 1pt)
}

#let gbt(
  title: ([标准名称],), english: (), code: "GB/T", serial: "XXXXX", year: "2026",
  ics: "01.120", ccs: "A 00", replaces: none, adopted: none,
  issued: "XXXX-XX-XX", implemented: "XXXX-XX-XX",
  organizations: ("国家市场监督管理总局", "国家标准化管理委员会"),
  category: "中华人民共和国国家标准", logo: auto,
  record: none, draft: none, preface: none, introduction: none,
  contents: true, contents-depth: 3, clause-contents: true, figure-list: false, table-list: false,
  important: none, two-sided: true, back: false,
  cover-page: true, main-title: true, end-rule: true, folio: auto,
  publication-layout: font-profile == "reference", body,
  page-layout: (:), text-style: (:), paragraph-style: (:),
  renderers: (:), front-matter: none, back-matter: none,
  list-style: (:), enum-style: (:),
) = {
  set document(title: title.join(" "), author: organizations, keywords: ("GB/T 1.1-2020", "Typst", "标准化文件"))
  set text(font: song, size: body-size, lang: "zh", region: "CN", hyphenate: false, overhang: false, cjk-latin-spacing: none,
    kerning: false, ligatures: false, discretionary-ligatures: false,
    top-edge: 0.88em, bottom-edge: -0.12em)
  set par(justify: true, first-line-indent: (amount: body-indent, all: true), leading: body-gap, spacing: paragraph-gap)
  set text(..text-style)
  set par(..paragraph-style)
  show strong: it => context {
    if "strong" in renderers { (renderers.strong)(it) }
    else if cjk-role(text.font) != none { black(it.body) }
    else { text(weight: "bold", it.body) }
  }
  set heading(numbering: "1.1", supplement: none)
  set figure(numbering: "1")
  show math.equation: it => {
    set text(font: ("New Computer Modern Math", if font-profile == "reference" { "FZShuSong-Z01" } else { "Source Han Serif SC" }))
    it
  }
  show heading: it => context {
    let heading-size = text-style.at("size", default: body-size)
    set text(size: heading-size, top-edge: heading-size * 0.88, bottom-edge: -heading-size * 0.12)
    let numbers = if it.numbering != none { counter(heading).at(it.location()) } else { () }
    let level = it.level
    let is-clause = is-kind(it, "gbt-clause")
    if it.numbering != none and not is-clause and not is-kind(it, "gbt-term") { clause-parent-level.update(level) }
    assert(level <= 6, message: "GB/T 1.1—2020 的条最多细分为五个层次（标题级别不超过 6）。")
    if "heading" in renderers {
      if it.numbering != none {
        metadata((kind: if is-clause or is-kind(it, "gbt-term") { "gbt-section" } else { "gbt-heading" },
          number: numbering(it.numbering, ..numbers), key: if it.has("label") { str(it.label) } else { none }))
      }
      (renderers.heading)(it)
    } else if it.numbering == none {
      let is-annex = is-kind(it, "gbt-annex")
      let is-index = is-kind(it, "gbt-index")
      let is-toc = is-kind(it, "gbt-toc")
      v(9mm, weak: false)
      block(width: 100%, above: 0pt, below: if is-annex { 1.5em } else if is-index or is-kind(it, "gbt-compact") { 5mm } else if is-toc { 11.5mm } else { 12.5mm }, sticky: true)[
        #set par(first-line-indent: 0pt, justify: false, leading: 0.5em)
        #if is-annex {
          let details = annex-title-state.get()
          align(center)[
            #black[附#h(1em)录#h(1em)#details.letter]\
            #black(if details.normative { [（规范性）] } else { [（资料性）] })\
            #black(if details.title == [专利] { [专#h(21pt)利] }
              else if details.title == [文件格式] { [文#h(0.5em)件#h(0.5em)格#h(0.5em)式] }
              else { details.title })
          ]
        } else {
          align(center, black(it.body, size: if is-index or is-kind(it, "gbt-compact") { 10.5pt } else { 16pt }))
        }
      ]
    } else if is-clause {
      // Keep the marker and the following text in the same normal paragraph.
      clause-marker(it, it.body.value.marker-size)
    } else if is-kind(it, "gbt-term") {
      metadata((kind: "gbt-section", number: numbering(it.numbering, ..numbers), key: if it.has("label") { str(it.label) } else { none }))
      block(above: 7.875pt, below: 7.875pt, sticky: true)[
        #set par(first-line-indent: 0pt, leading: body-gap)
        #black(numbering(it.numbering, ..numbers))\
        #h(body-indent)#it.body
      ]
    } else {
      metadata((kind: "gbt-heading", number: numbering(it.numbering, ..numbers), key: if it.has("label") { str(it.label) } else { none }))
      let chapter = level == 1 and annex-state.get() == none
      block(above: if chapter { 23.625pt } else { 13.125pt },
        below: if chapter { 23.625pt } else { 13.125pt }, sticky: true)[
        #set par(first-line-indent: 0pt, leading: 0.5em)
        #black[#numbering(it.numbering, ..numbers)#h(1em)#it.body]
      ]
    }
  }
  let dot = box(width: body-indent, text(font: if font-profile == "reference" { "FZShuSong-Z01" } else { "Source Han Serif SC" }, tracking: 0pt)[·])
  set list(marker: depth => if depth == 0 { unordered-marker(depth, body-indent) } else { dot },
    indent: 0pt, body-indent: 0pt, spacing: paragraph-gap, marker-align: left)
  set enum(full: true, numbering: (..numbers) => numbered-marker(numbers, body-indent),
    indent: 0pt, body-indent: 0pt, spacing: paragraph-gap, number-align: left)
  set list(..list-style)
  set enum(..enum-style)
  show list: set par(first-line-indent: 0pt)
  show enum: set par(first-line-indent: 0pt)
  show enum.item: it => context {
    let depth = list-depth-state.get()
    list-depth-state.update(depth + 1)
    set list(marker: dot, indent: 0pt, body-indent: 0pt)
    it
    list-depth-state.update(depth)
  }
  show list.item: it => context {
    let depth = list-depth-state.get()
    list-depth-state.update(depth + 1)
    it
    list-depth-state.update(depth)
  }
  show footnote.entry: it => context {
    set text(font: song, size: note-size, top-edge: note-size * 0.88, bottom-edge: -note-size * 0.12)
    set par(first-line-indent: 0pt, hanging-indent: 0pt, leading: 13.5pt - note-size)
    let location = it.note.location()
    pad(left: 18pt, grid(columns: (18pt, 1fr), column-gutter: 0pt, align: top,
      link(location, counter(footnote).display(at: location, "1)")), it.note.body))
  }
  set footnote(numbering: "1)")
  set footnote.entry(indent: 0pt, separator: line(length: 25%, stroke: 0.4pt), gap: 0.5em)
  // Components place captions in the repeated table header / below figure notes.
  // The native figure still owns the counter, outline entry and reference target.
  show figure.caption: it => none
  show figure.where(kind: table): set block(breakable: true)
  show ref: it => context {
    let found = query(it.target)
    let target = if found.len() > 0 { resolve-reference-target(found.first()) } else { none }
    if it.form == "page" { it }
    else if target != none and target.func() == heading {
      link(target.location(), if is-kind(target, "gbt-annex") {
        let details = annex-title-state.at(target.location())
        [附录#h(0.5em)#details.letter]
      } else if target.numbering == none { target.body } else {
        numbering(target.numbering, ..counter(heading).at(target.location()))
      })
    } else if target != none and target.func() == figure and target.kind == math.equation {
      link(target.location(), if target.numbering == none { [公式] }
        else { [公式（#numbering(target.numbering, ..equation-counter.at(target.location()))）] })
    } else if target != none and target.func() == metadata and "number" in target.value {
      link(target.location(), target.value.number)
    } else { it }
  }
  two-sided-state.update(two-sided)
  if cover-page {
    if "cover" in renderers { (renderers.cover)((title: title, english: english, code: code, serial: serial,
      year: year, ics: ics, ccs: ccs, issued: issued, implemented: implemented,
      organizations: organizations, category: category, logo: logo,
      replaces: replaces, adopted: adopted, record: record, draft: draft)) }
    else { cover(title: title, english: english, code: code, serial: serial, year: year, ics: ics, ccs: ccs,
      replaces: replaces, adopted: adopted, issued: issued, implemented: implemented,
      organizations: organizations, category: category, logo: logo, record: record, draft: draft) }
    pagebreak(to: if two-sided { "odd" } else { none })
  }
  show cjk-pattern: cjk-lettering
  // Split numerals from words before resolving coverage. A font stack can
  // select different faces and calibration ratios for each in one heading.
  show western-pattern: western-lettering
  show numeral-pattern: western-lettering
  counter(page).update(1)
  let running = black(standard-number(code, serial, year), size: 10.5pt)
  set page(paper: "a4", margin: (inside: 25mm, outside: if publication-layout { 22mm } else { 20mm }, top: 35mm, bottom: 25mm),
    binding: left, numbering: "I", header-ascent: 5mm, footer-descent: if publication-layout { 2.5mm } else { 6mm },
    header: context align(if calc.odd(counter(page).get().first()) { right } else { left }, running),
    footer: context pad(x: if publication-layout { 4mm } else { 0mm }, align(if calc.odd(counter(page).get().first()) { right } else { left },
      text(font: song, size: note-size, if folio != auto { folio } else {
        counter(page).display(if here().page-numbering() == "I" { "I" } else { "1" }) }))))
  set page(..page-layout)
  if front-matter != none { front-matter }
  if contents {
    front-title([目#h(32pt)次], kind: "gbt-toc")
    set par(first-line-indent: 0pt)
    set outline.entry(fill: repeat(box(width: 3.5pt, height: body-size, baseline: 0.12em,
      align(center + horizon, circle(radius: 0.6pt, fill: rgb("#000000"), stroke: none)))))
    show outline.entry: it => context {
      set par(first-line-indent: 0pt, spacing: 0.25em)
      let element = it.element
      // Wide spacing belongs to the displayed title, not to its TOC entry.
      let entry = if (element.func() == heading and element.numbering == none and
        not is-kind(element, "gbt-annex")) {
        let name = if it.body().has("children") { it.body().children.filter(c => c.func() != h).join() } else { it.body() }
        [#name#h(0.5em)#box(width: 1fr, it.fill)#h(0.5em)#it.page()]
      } else { it.inner() }
      let number = if element.func() == heading and element.numbering != none {
        numbering(element.numbering, ..counter(heading).at(element.location()))
      } else { "" }
      let in-annex = type(number) == str and number.match(regex("^[A-Z]\\.")) != none
      let indent = (it.level - 1 + if in-annex { 1 } else { 0 }) * 1em
      let prefix = it.prefix()
      let is-clause = element.func() == heading and (is-kind(element, "gbt-clause"))
      if (not is-kind(element, "gbt-explanation-heading") and
        (not is-clause or clause-contents) and not (in-annex and it.level >= contents-depth)) {
        // B.1, C.1, etc. are level-one headings inside the annex counter,
        // but remain subordinate entries in the document's contents.
        let pitch = if element.func() == heading and it.level == 1 and not in-annex { 18.2pt } else { 15.75pt }
        block(above: pitch - body-size, below: pitch - body-size,
          link(element.location(), pad(left: indent, grid(columns: (auto, 1fr), column-gutter: if prefix == none { 0pt } else { 1em }, prefix, entry))))
      }
    }
    outline(title: none, depth: contents-depth, indent: 1em)
    if figure-list { v(2em); outline(title: none, target: figure.where(kind: image), indent: 0pt) }
    if table-list { v(2em); outline(title: none, target: figure.where(kind: table), indent: 0pt) }
    pagebreak(to: if two-sided { "odd" } else { none })
  }
  if preface != none { front-title([前#h(32pt)言], outlined: true); preface; pagebreak(to: if two-sided { "odd" } else { none }) }
  if introduction != none { front-title([引#h(32pt)言], outlined: true); introduction; pagebreak(to: if two-sided { "odd" } else { none }) }
  if two-sided { pagebreak(to: "odd", weak: true) }
  set page(numbering: "1")
  counter(page).update(1)
  if main-title {
    v(9mm, weak: false)
    block(width: 100%, above: 0pt, below: if font-profile == "reference" { 31.75pt } else { 33pt })[
      #set par(first-line-indent: 0pt, justify: false)
      #align(center, black(title.join(linebreak()), size: 16pt))
    ]
  }
  if important != none { block(above: 0.5em, below: 0.5em, black[重要提示：#important]) }
  body
  if back-matter != none { back-matter }
  if end-rule { end-mark() }
  if back {
    pagebreak(to: if two-sided { "even" } else { none })
    back-cover(code: code, serial: serial, year: year)
  }
}

// Profiles merge styles independently so overriding one hook keeps the rest.
#let construction-standard(..args) = {
  let supplied = args.named()
  let defaults = (code: "GB", category: "中华人民共和国国家标准", ics: "", ccs: "P",
    contents: false, main-title: false, end-rule: false,
    page-layout: construction-page, text-style: construction-text,
    paragraph-style: construction-paragraph,
    list-style: (:), enum-style: (numbering: construction-enum-marker),
    renderers: (cover: construction-cover, heading: construction-heading,
      strong: it => text(font: construction-hei, weight: "bold", it.body)))
  let options = defaults + supplied
  for key in ("page-layout", "text-style", "paragraph-style", "renderers", "list-style", "enum-style") {
    options.insert(key, defaults.at(key) + supplied.at(key, default: (:)))
  }
  gbt(..options, ..args.pos())
}

