#import "../template/lib.typ": *
#import "../template/annotations.typ": annotated-page

#let body-dimensions(verso: false, title: false, main: false) = {
  let left = if verso { 20 } else { 25 }
  let right = if verso { 185 } else { 190 }
  let header-x = if verso { 27 } else { 151 }
  let y = if title { 67 } else { 42 }
  let right-y = if main { 27 } else { y }
  let dimensions = (
    ((0, -y), (left, -y), (0, -(y - 5)), (left, -(y + 5)), str(left)),
    ((right, -right-y), (210, -right-y), (right, -(right-y + 5)), (210, -(right-y - 5)), str(210 - right)),
    ((header-x, 0), (header-x, -25), (header-x - 3, 0), (header-x + 5, -25), "25"),
  )
  if title {
    dimensions.push(((132, -30), (132, -45), (126, -30), (117, -45), "15"))
    dimensions.push(((132, -51), (132, -63), (117, -51), (128, -63), "12"))
  } else {
    let gap-x = if verso { left - 1 } else { right + 1 }
    dimensions.push(((gap-x, -30), (gap-x, -35), (if verso { left + 4 } else { right - 4 }, -30), (if verso { left + 4 } else { right - 4 }, -35), "5"))
    let footer-x = if verso { 24 } else { 186 }
    dimensions.push(((footer-x, -277), (footer-x, -297), (footer-x + 4, -277), (footer-x + 4, -297), "20"))
    dimensions.push(((if verso { 0 } else { footer-x }, -277), (if verso { footer-x } else { 210 }, -277),
      (if verso { 0 } else { footer-x }, -273), (if verso { footer-x } else { 210 }, -273), "24"))
  }
  dimensions
}

#let cover-dimensions(publisher-gap: 5, local: false) = {
  let dimensions = (
  ((-4, 0), (-4, -75), (0, 0), (25, -75), "75"),
  ((0, -5), (25, -5), (0, -10), (25, -10), "25"),
  ((52, 0), (52, -10), (25, 0), (25, -10), "10"),
  ((25, -81), (195, -81), (25, -75), (195, -75), "170"),
  ((164, -7), (210, -7), (164, -13), (210, -10), "46"),
  ((144, -34), (184, -34), (144, -33), (184, -33), "40"),
  ((202, -13), (202, -33), (184, -13), (184, -33), "20"),
  ((202, -33), (202, -75), (190, -33), (195, -75), "42"),
  ((190, -75), (190, -115), (195, -75), (130, -115), "40"),
  ((24, -42), (24, -50), (25, -42), (25, -50), "8"),
  ((24, -50), (24, -75), (25, -50), (25, -75), "25"),
  ((196, -50), (196, -59), (195, -50), (190, -59), "9"),
  ((196, -64), (196, -67), (190, -64), (190, -67), "3"),
  ((190, -71), (195, -71), (190, -67), (195, -75), "5"),
  ((198, -123), (198, -133), (132, -123), (132, -133), "10"),
  ((198, -138), (198, -153), (151, -138), (151, -153), "15"),
  ((25, -297), (25, -257), (0, -297), (55, -257), "40"),
  ((74, -277), (74, -297), (92, -277), (0, -297), "20"),
  ((124 - publisher-gap / 2, -282), (124 + publisher-gap / 2, -282), (124 - publisher-gap / 2, -277), (124 + publisher-gap / 2, -277), str(publisher-gap)),
  ((128.7 + publisher-gap / 2, -282), (131.7 + publisher-gap / 2, -282), (128.7 + publisher-gap / 2, -277), (131.7 + publisher-gap / 2, -277), "3"),
  ((210, -297), (210, 0), (210, -297), (210, 0), "297"),
  ((0, -302), (210, -302), (0, -297), (210, -297), "210"),
  )
  if local { dimensions.slice(0, 4) + dimensions.slice(6, 14) + dimensions.slice(16) } else { dimensions }
}

#let demo-fragment(name) = block(above: 0.6em, below: 0.8em, breakable: false)[
  #set par(first-line-indent: 0pt)
  #image("demo-pdf/" + name + ".pdf", width: 100%, alt: "由真实 Typst 示例编译的 " + name)
]

#let demo-page(number, title, dimensions: (), notes: (), footnotes: ()) = {
  gbt-figure(title, annotated-page("../book/demo-pdf/e" + str(number) + ".pdf", dimensions: dimensions, width: if number in (5, 6, 7) { 150mm } else if number == 4 { 148mm } else { 155mm }),
    unit: [单位为毫米],
    notes: notes, footnotes: footnotes)
}
#let diagram-e1() = demo-page(1, [单数页格式], dimensions: body-dimensions())
#let diagram-e2() = demo-page(2, [双数页格式], dimensions: body-dimensions(verso: true))
#let diagram-e3() = demo-page(3, [正文首页格式], dimensions: body-dimensions(title: true, main: true))
#let diagram-e4() = demo-page(4, [封底格式], dimensions: (((210, -80), (205, -80), (210, -77), (205, -77), "5"), ((198, 0), (198, -25), (194, 0), (205, -25), "25")))
#let diagram-e5() = demo-page(5, [国家标准封面格式], dimensions: cover-dimensions(), footnotes: ([国家标准发布部门按照有关规定填写。],))
#let diagram-e6() = demo-page(6, [行业标准封面格式], dimensions: cover-dimensions(publisher-gap: 10), footnotes: ([填写行业标准代号。], [行业标准发布部门按照有关规定填写。]))
#let diagram-e7() = demo-page(7, [地方标准封面格式], dimensions: cover-dimensions(publisher-gap: 10, local: true), footnotes: ([填写地方标准代号。], [地方标准发布部门按照有关规定填写。]))
#let diagram-e8() = demo-page(8, [目次格式], dimensions: body-dimensions(title: true), notes: ([以单数页为例。],))
#let diagram-e9() = demo-page(9, [前言或引言格式], dimensions: body-dimensions(title: true), notes: ([以单数页为例。], [“引言”格式与此格式相同，只是将“前言”改为“引言”。]))
#let diagram-e10() = demo-page(10, [参考文献格式], dimensions: body-dimensions(title: true).slice(0, 4) + (((190, -51), (190, -56), (117, -51), (192, -56), "5"),), notes: ([以单数页为例。],))
#let diagram-e11() = demo-page(11, [索引格式], dimensions: body-dimensions(title: true).slice(0, 4) + (((190, -51), (190, -56), (117, -51), (192, -56), "5"),), notes: ([以“索引”为文件的最后一个要素并位于单数页为例。],))
#let diagram-e12() = demo-page(12, [附录格式], dimensions: body-dimensions(title: true).slice(0, 4) + (((190, -60), (190, -65), (117, -60), (192, -65), "5"),), notes: ([以单数页为例。],))
