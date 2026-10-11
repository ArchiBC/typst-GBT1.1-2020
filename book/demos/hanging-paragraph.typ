#import "../../template/lib.typ": *
#import "common.typ": fragment, crosses as specimen-crosses
#import "../../vendor/cetz-0.5.2/src/lib.typ" as cetz
#let crosses(n) = specimen-crosses(n, advance: 9.0243pt)
#let suspended = grid(columns: (1fr, auto), column-gutter: 5pt, align: horizon,
  [#crosses(13)\ #crosses(14)\ #crosses(9)],
  cetz.canvas(length: 1pt, {
    cetz.decorations.flat-brace((0, 15), (0, -15), amplitude: 2, flip: true, stroke: 0.35pt)
    cetz.draw.content((7, 0), text(font: song, size: note-size)[悬置段], anchor: "west", padding: 0pt)
  }))
#let panel(title, body) = block(width: 100%, height: 270pt, stroke: 0.6pt, inset: 0pt)[
  #block(width: 100%, height: 18pt, stroke: (bottom: 0.6pt), inset: (top: 3pt))[
    #align(center)[#title]
  ]
  #pad(x: 9pt, y: 8pt, block(height: 221pt, body))
]
#fragment[
  #set text(size: note-size)
  #set par(first-line-indent: (amount: 18pt, all: true), leading: 12.5pt - note-size, spacing: 7pt)
  #show heading.where(supplement: none): it => context block(above: 10pt, below: 10pt, sticky: true)[
    #set par(first-line-indent: 0pt)
    #black[#numbering(it.numbering, ..counter(heading).at(it.location()))#h(1em)#it.body]
  ]
  #grid(columns: (1fr, 1fr), column-gutter: 14pt,
    panel([不#h(1em)正#h(1em)确], [
      #counter(heading).update(4)
      = 要求
      #suspended

      #clause(level: 2) #crosses(8)

      #crosses(18)

      #clause(level: 2) #crosses(7)

      #crosses(18)\
      #crosses(20)\
      #crosses(22)\
      #crosses(22)\
      #crosses(8)
      #v(1fr)
      = 试验方法
    ]),
    panel([正#h(1em)确], [
      #counter(heading).update(4)
      = 要求
      == 通用要求
      #crosses(13)\
      #crosses(14)\
      #crosses(9)

      #clause(level: 2) #crosses(8)

      #crosses(18)

      #clause(level: 2) #crosses(7)

      #crosses(18)\
      #crosses(20)\
      #crosses(22)\
      #crosses(22)\
      #crosses(8)
      #v(1fr)
      = 试验方法
    ]))
]
