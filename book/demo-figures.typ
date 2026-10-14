#import "../template/lib.typ": *
#import "../template/annotations.typ": annotated-page
#import "specimens.typ": specimen-publisher

#let body-dimensions(verso: false, title: false, main: false, margin-y: none) = {
  let left = if verso { 20 } else { 25 }
  let right = if verso { 185 } else { 190 }
  let header-x = if verso { 61 } else { 151 }
  let y = if margin-y != none { margin-y } else if title { 67 } else { 42 }
  let right-y = if main { 26.5 } else { y }
  let dimensions = (
    ((0, -y), (left, -y), (0, -(y - 4)), (left, -(y + 3)), str(left)),
    ((right, -right-y), (210, -right-y), (right, -(right-y + 3)), (210, -(right-y - 4)), str(210 - right)),
    ((header-x, 0), (header-x, -25), (header-x - 3, 0), (header-x + 5, -25), "25"),
  )
  if title {
    let x = if main { 117 } else { 132 }
    dimensions.push(((x, -28.5), (x, -43.5), (154, -28.5), (120, -43.5), "15"))
    if main { dimensions.push(((63, -49), (63, -61), (86, -49), (36, -61), "12")) }
    else { dimensions.push(((132, -49), (132, -61), (116, -49), (134, -61), "12")) }
  } else {
    let gap-x = if verso { 19 } else { 191 }
    dimensions.push(((gap-x, -28.5), (gap-x, -33.5), (if verso { left + 4 } else { right - 4 }, -28.5), (if verso { left + 4 } else { right - 4 }, -33.5), "5"))
    let footer-x = if verso { 24 } else { 186 }
    dimensions.push(((footer-x, -277), (footer-x, -297), (footer-x + 4, -277), (footer-x + 4, -297), "20"))
    dimensions.push(((if verso { 0 } else { footer-x }, -277), (if verso { footer-x } else { 210 }, -277),
      (if verso { 0 } else { footer-x }, -273), (if verso { footer-x } else { 210 }, -273), "24"))
  }
  dimensions
}

#let cover-dimensions(publisher-gap: 5, local: false) = {
  let kind = if local { "local" } else if publisher-gap == 10 { "industry" } else { "national" }
  let p = specimen-publisher(kind)
  let dimensions = (
    ((-4, 0), (-4, -75), (0, 0), (25, -75), "75"),
    ((0, -6), (25, -6), (0, -10), (25, -10), "25"),
    ((52, 0), (52, -10), (25, 0), (55, -10), "10"),
    ((0, -80), (25, -80), (0, -75), (25, -75), "25"),
    ((25, -80), (195, -80), (25, -75), (195, -75), "170"),
    ((164, -9), (210, -9), (164, -13), (210, -10), "46"),
    ((144, -37), (184, -37), (144, -33), (184, -33), "40"),
    ((202, -13), (202, -33), (184, -13), (184, -33), "20"),
    ((202, -33), (202, -75), (184, -33), (195, -75), "42"),
    ((202, -75), (202, -115), (195, -75), (126, -115), "40"),
    ((25, -42), (25, -50), (25, -38), (25, -54), "8"),
    ((25, -50), (25, -75), (25, -50), (25, -75), "25"),
    ((195, -50), (195, -59), (190, -50), (190, -59), "9"),
    ((195, -63), (195, -66), (190, -63), (190, -66), "3"),
    ((190, -72), (195, -72), (190, -68), (195, -75), "5"),
    ((202, -123), (202, -133), (126, -123), (128, -133), "10"),
    ((202, -138), (202, -153), (128, -138), (139, -153), "15"),
    ((33, -257), (33, -297), (25, -257), (0, -297), "40"),
    ((74, -277), (74, -297), (p.x, -277), (74, -297), "20"),
    ((p.right, -281), (p.fa, -281), (p.right, -277), (p.fa, -277), str(publisher-gap)),
    ((p.fa + p.char-width, -281), (p.bu, -281), (p.fa + p.char-width, -277), (p.bu, -277), "3"),
    ((217, -297), (217, 0), (210, -297), (210, 0), "297"),
    ((0, -304), (210, -304), (0, -297), (210, -297), "210"),
  )
  if local { dimensions.slice(0, 5) + dimensions.slice(8, 10) + dimensions.slice(11, 15) + dimensions.slice(17) } else { dimensions }
}

#let demo-fragment(name) = block(above: 0.6em, below: 0.8em, breakable: false)[
  #set par(first-line-indent: 0pt)
  #image("demo-pdf/" + name + ".pdf", width: 100%, alt: "由真实 Typst 示例编译的 " + name)
]

#let specimen-note(body, number: none, width: 156.3mm) = block(width: width, above: 0.3em, below: 0.3em)[
  #set align(left)
  #set text(font: song, size: note-size, top-edge: note-size * 0.88, bottom-edge: -note-size * 0.12)
  #set par(first-line-indent: 0pt, leading: 13.5pt - note-size)
  #grid(columns: (auto, 1fr), column-gutter: 0pt, align: left + top,
    black(if number == none { [注：] } else { [注#h(0.25em)#number：] }, size: 9pt), body)
]

#let demo-page(number, title, dimensions: (), notes: (), footnotes: ()) = {
  let width = if number in (5, 6, 7) { 150mm } else if number == 4 { 147.7mm } else if number == 9 { 154.8mm } else { 156.3mm }
  gbt-figure(title, context [
    #annotated-page("../book/demo-pdf/e" + str(number) + ".pdf", dimensions: if type(dimensions) == function { dimensions() } else { dimensions }, width: width)
    #set text(size: body-size)
    #for (i, item) in notes.enumerate() { specimen-note(item, number: if notes.len() > 1 { i + 1 } else { none }, width: width) }
  ],
    unit: [单位为毫米],
    footnotes: footnotes)
}
#let diagram-e1() = demo-page(1, [单数页格式], dimensions: body-dimensions())
#let diagram-e2() = demo-page(2, [双数页格式], dimensions: body-dimensions(verso: true))
#let diagram-e3() = demo-page(3, [正文首页格式], dimensions: body-dimensions(title: true, main: true))
#let diagram-e4() = demo-page(4, [封底格式], dimensions: (((210, -80), (205, -80), (210, -77), (205, -77), "5"), ((198, 0), (198, -25), (194, 0), (205, -25), "25")))
#let diagram-e5() = demo-page(5, [国家标准封面格式], dimensions: () => cover-dimensions(), footnotes: ([国家标准发布部门按照有关规定填写。],))
#let diagram-e6() = demo-page(6, [行业标准封面格式], dimensions: () => cover-dimensions(publisher-gap: 10), footnotes: ([填写行业标准代号。], [行业标准发布部门按照有关规定填写。]))
#let diagram-e7() = demo-page(7, [地方标准封面格式], dimensions: () => cover-dimensions(publisher-gap: 10, local: true), footnotes: ([填写地方标准代号。], [地方标准发布部门按照有关规定填写。]))
#let diagram-e8() = demo-page(8, [目次格式], dimensions: body-dimensions(title: true, margin-y: 73.5), notes: ([以单数页为例。],))
#let diagram-e9() = demo-page(9, [前言或引言格式], dimensions: body-dimensions(title: true, margin-y: 68.5), notes: ([以单数页为例。], [“引言”格式与此格式相同，只是将“前言”改为“引言”。]))
#let diagram-e10() = demo-page(10, [参考文献格式], dimensions: body-dimensions(title: true, margin-y: 64).slice(0, 4) + (((190, -48), (190, -53), (117, -48), (192, -53), "5"),), notes: ([以单数页为例。],))
#let diagram-e11() = demo-page(11, [索引格式], dimensions: body-dimensions(title: true, margin-y: 64).slice(0, 4) + (((190, -48), (190, -53), (117, -48), (192, -53), "5"),), notes: ([以“索引”为文件的最后一个要素并位于单数页为例。],))
#let diagram-e12() = demo-page(12, [附录格式], dimensions: body-dimensions(title: true, margin-y: 70.5).slice(0, 4) + (((190, -57), (190, -62), (117, -57), (192, -62), "5"),), notes: ([以单数页为例。],))
