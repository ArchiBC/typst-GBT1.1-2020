// Reusable engineering-code typography. The profile is assembled in lib.typ.
#import "fonts.typ": song, song-family, latin, latin-covers, hei, hei-family
#import "gb-mark.typ": gb-mark

// The authoring machine may use its installed book faces. Portable builds use
// the bundled fonts; no proprietary font file is copied into the project.
#let construction-font-profile = sys.inputs.at("construction-font-profile", default: "open")
#let construction-roman = if construction-font-profile == "windows" { "Times New Roman" } else { "Liberation Serif" }
#let construction-song-family = if construction-font-profile == "windows" { "SimSun" } else { "Source Han Serif SC" }
#let construction-song = ((name: construction-roman, covers: latin-covers), construction-song-family)
#let construction-hei = ((name: construction-roman, covers: latin-covers),
  if construction-font-profile == "windows" { "SimHei" } else { "Source Han Sans SC" })
#let construction-title(body) = if body.has("text") and body.text.clusters().len() == 2 {
  body.text.clusters().join(h(2em))
} else { body }

#let construction-page = (
  width: 135mm, height: 203mm, margin: (inside: 18mm, outside: 15mm, top: 22mm, bottom: 17mm),
  header: none, footer-descent: 5mm,
  footer: context align(if calc.odd(counter(page).get().first()) { right } else { left },
    text(font: construction-roman, size: 10.5pt, style: "italic", counter(page).display("1"))),
)
#let construction-text = (font: construction-song, size: 10.5pt, top-edge: 0.88em, bottom-edge: -0.12em)
#let construction-paragraph = (leading: 5.25pt, spacing: 5.25pt, first-line-indent: (amount: 21pt, all: true))
#let construction-enum-marker(..numbers) = context {
  let values = numbers.pos()
  let nested = values.len() > 1
  box(width: if nested { 1.5em } else { 3.5em })[
    #if not nested { h(2em) }
    #text(font: construction-roman, weight: "bold", tracking: 0pt, str(values.last()))
  ]
}

#let construction-heading(it, chapter-break: true, zero-section: true) = context {
  let numbers = if it.numbering != none { counter(heading).at(it.location()) } else { () }
  let numbered = if it.numbering == none { none } else { numbering(it.numbering, ..numbers) }
  let kind = it.supplement
  if kind == "gbt-clause" or kind == [gbt-clause] {
    let indent = par.first-line-indent
    h(-if type(indent) == dictionary { indent.amount } else { indent })
    text(font: construction-roman, weight: "bold", tracking: 1.5pt, numbered)
    h(9pt)
  } else if it.numbering == none {
    block(above: 1.5em, below: 1.5em, sticky: true,
      align(center, text(font: construction-song, weight: "regular", size: 14pt, construction-title(it.body))))
  } else if (it.level == 1 and not (kind == "gbt-annex-section" or kind == [gbt-annex-section])) {
    if chapter-break { pagebreak(weak: true); v(12mm, weak: false) }
    block(above: 1em, below: 2em, sticky: true,
      align(center, text(font: construction-song, weight: "regular", size: 14pt)[#numbered#h(1em)#construction-title(it.body)]))
    if zero-section {
      counter(heading).update((chapter, ..rest) => (chapter, 0))
      state("gbt-clause-parent-level", 1).update(2)
    }
  } else {
    block(above: 1em, below: 1em, sticky: true,
      align(center, text(font: construction-hei, weight: "bold")[#numbered#h(1em)#it.body]))
  }
}

#let construction-explanation-heading(it) = {
  let title = it.body.has("text")
  block(width: 100%, above: 1em, below: 1em, sticky: true,
    align(center, text(font: if not title and it.level == 1 { construction-hei } else { construction-song },
      size: if title { 14pt } else { 10.5pt },
      weight: if not title and it.level == 1 { "bold" } else { "regular" }, it.body)))
}

#let construction-explanation-entry(record) = block(above: 0pt, below: 0pt, breakable: true)[
  #set par(first-line-indent: (amount: 21pt, all: true))
  #h(-21pt)#link(record.target, text(font: construction-song, weight: "bold", tracking: 1.5pt, record.number))#h(9pt)#record.body
]

#let construction-cover(info) = {
  set page(width: 135mm, height: 203mm, margin: 0pt, header: none, footer: none, numbering: none)
  set text(font: construction-song, fill: rgb("#14284f"), size: 11pt)
  set par(first-line-indent: 0pt, leading: 4pt)
  place(top + left, dx: 8mm, dy: 9mm, text(font: construction-roman, weight: "bold", "UDC"))
  if info.logo != none {
    place(top + right, dx: -10mm, dy: 12mm,
      if info.logo == auto { gb-mark(width: 23mm, ink: rgb("#14284f")) }
      else if type(info.logo) == str { image(info.logo, width: 23mm) } else { info.logo })
  }
  place(top + left, dx: 29mm, dy: 21mm, text(font: construction-hei, weight: "bold", info.category))
  place(top + left, dx: 8mm, dy: 35mm, text(font: construction-roman, weight: "bold", info.ccs))
  place(top + right, dx: -9mm, dy: 35mm,
    text(font: construction-roman, weight: "bold")[#info.code#h(0.5em)#info.serial–#info.year])
  place(top + left, dy: 41mm, line(length: 100%, stroke: rgb("#14284f") + 0.4pt))
  place(top + left, dy: 64mm, block(width: 100%)[
    #align(center, text(size: 18pt, info.title.join(linebreak())))
    #v(5mm)
    #align(center, text(font: construction-roman, size: 12pt, info.english.join(linebreak())))
  ])
  place(top + left, dx: 8mm, dy: 153mm, block(width: 118mm,
    grid(columns: (1fr, 1fr),
      [#text(font: construction-roman, weight: "bold", info.issued)#h(1em)#text(font: construction-hei, weight: "bold", [发布])],
      align(right)[#text(font: construction-roman, weight: "bold", info.implemented)#h(1em)#text(font: construction-hei, weight: "bold", [实施])])))
  place(top + left, dy: 160mm, line(length: 100%, stroke: rgb("#14284f") + 0.4pt))
  place(top + left, dx: 8mm, dy: 177mm,
    block(width: 118mm, grid(columns: (1fr, auto), align: horizon,
      text(font: construction-hei, size: 9.5pt, weight: "bold", info.organizations.join(linebreak())),
      text(font: construction-hei, weight: "bold", [联合发布]))))
  box(width: 0pt, height: 1pt)
}
