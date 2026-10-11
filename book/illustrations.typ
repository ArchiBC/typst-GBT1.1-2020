// Native examples of tables and mathematics. These examples are unnumbered
// figures in the containing standard, so they never disturb its counters.
#import "../template/lib.typ": *
#import "demos/common.typ": crosses

#let empty-row = range(4).map(_ => table.cell(stroke: (bottom: none), inset: 0pt, box(height: 27pt)))
#let diagram-table-layout() = gbt-table([表 X　表题], number: none, closed: false,
  columns: (1fr, 1fr, 1fr, 1fr), headers: range(4).map(_ => crosses(4, advance: 9.0243pt)), rows: (empty-row,))
#let diagram-table-page() = block(width: 100%, stroke: 0.5pt, inset: 4pt, align(center, black[表 3（第 2 页/共 5 页）]))
#let diagram-table-headers-1() = gbt-table([], number: none, closed: false,
  columns: (1fr, 1fr, 1fr, 1fr), headers: ([类型], [线密度\ kg/m], [内圆直径\ mm], [外圆直径\ mm]), rows: (empty-row,))
#let diagram-table-headers-2() = gbt-table([], number: none, closed: false,
  columns: (1fr, 1fr, 1fr, 1fr), headers: ([类型], $rho_1 slash upright("(kg/m)")$, $d slash upright("mm")$, $D slash upright("mm")$), rows: (empty-row,))
#let diagram-table-headers-3() = gbt-table([], number: none, closed: false, unit: [单位为毫米],
  columns: (1fr, 1fr, 1fr, 1fr), headers: ([类型], [长度], [内圆直径], [外圆直径]), rows: (empty-row,))
#let diagram-table-headers-4() = {
  set text(font: song, size: note-size)
  set par(first-line-indent: 0pt)
  table(columns: (1fr, 1fr, 1fr, 1fr), stroke: 0.4pt, align: center + horizon,
    table.cell(inset: 0pt)[#box(width: 100%, height: 36pt)[
      #place(top + left, line(end: (100%, 100%), stroke: 0.4pt))
      #place(top + right, dx: -6pt, dy: 4pt)[类型]
      #place(bottom + left, dx: 6pt, dy: -4pt)[尺寸]
    ]], [A], [B], [C], ..empty-row)
}
#let diagram-table-headers-5() = {
  set text(font: song, size: note-size)
  set par(first-line-indent: 0pt)
  table(columns: (1fr, 1fr, 1fr, 1fr), stroke: 0.4pt, inset: 5pt, align: center + horizon,
    table.cell(rowspan: 2)[尺#h(1em)寸], table.cell(colspan: 3)[类#h(1em)型],
    [A], [B], [C], ..empty-row)
}
#let diagram-table-notes() = block(stroke: 0.5pt, inset: 4pt)[
  #gbt-table([表 X　表题], number: none, unit: [单位为毫米], columns: (1fr, 1fr, 1fr, 1fr), cell-align: center + horizon,
    headers: ([类型], [长度], [内圆直径#super[a]], [外圆直径]), rows: (
      ([A], [230], [100], [125]), ([……], [……], [……], [……]),
    ), trailing: ([段（可包含要求型条款）],), notes: ([表中的注的内容], [表中的注的内容]), footnotes: ([表脚注的内容],))
]

#let equation-example(body, definitions: (), formula-gap: 1.5em) = block(stroke: 0.5pt, inset: (x: 18pt, y: 8pt))[
  #set text(size: note-size)
  #show math.equation: set text(size: 9pt)
  #set par(first-line-indent: 0pt, leading: 13.5pt - note-size)
  #align(center, math.equation(block: false, math.display(body)))
  #if definitions.len() > 0 {
    v(formula-gap)
    [式中：]
    v(0.3em)
    grid(columns: (auto, auto, 1fr), column-gutter: 0.5em, row-gutter: 13.5pt - note-size,
      ..definitions.map(it => (it.at(0), [——], it.at(1))).flatten())
  }
]
#let comparison(correct, incorrect, height: auto) = block(height: height, stroke: 0.5pt, inset: (x: 18pt, y: 8pt))[
  #set text(size: note-size)
  #show math.equation: set text(size: 9pt)
  #set par(first-line-indent: 0pt, leading: 13.5pt - note-size)
  #grid(columns: (1fr, 1fr), column-gutter: 1em,
    [正确：\ #v(0.3em) #correct], [不正确：\ #v(0.3em) #incorrect])
]
#let diagram-equation-number() = block(stroke: 0.5pt, inset: 4pt,
  gbt-equation($x^2 + y^2 < z^2$, number: "1"))
#let diagram-math-subscripts() = example(number: 5)[#comparison([
  #align(center)[$display(t_i = sqrt(S_("ME",i)/S_("MR",i)))$]
  #v(0.5em)
  式中：\
  $t_i$ —— 系统 $i$ 的统计量；\
  $S_("ME",i)$ —— 系统 $i$ 的残差均方；\
  $S_("MR",i)$ —— 系统 $i$ 由于回归产生的均方。
], [
  #align(center)[$display(t_i = sqrt(upright("MSE")_i/upright("MSR")_i))$]
  #v(0.5em)
  式中：\
  $t_i$ —— 系统 $i$ 的统计量；\
  $upright("MSE")_i$ —— 系统 $i$ 的残差均方；\
  $upright("MSR")_i$ —— 系统 $i$ 由于回归产生的均方。
])]
#let diagram-math-fraction() = example(number: 3)[#block(height: 79pt, stroke: 0.5pt, inset: 18pt)[
  #set text(size: note-size)
  #set par(first-line-indent: 0pt, leading: 13.5pt - note-size)
  #show math.equation: set text(size: 9pt)
  #grid(columns: (1fr, 1fr), column-gutter: 1em,
    [在数学公式中，使用\ #v(0.5em)
      #align(center)[$display(frac(sin[(N+1)phi slash 2] sin(N phi slash 2), sin(phi slash 2)) = dots.h)$]],
    [而不使用\ #v(0.5em)
      #align(center)[$display(frac(display(sin[display((N+1)/2)phi] sin(display(N/2)phi)), display(sin(display(phi/2)))) = dots.h)$]])
]]
