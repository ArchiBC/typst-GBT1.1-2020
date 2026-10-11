#import "../../template/lib.typ": *
#import "common.typ": fragment
#let leader(start, end, title) = [
  #place(top + left, line(start: start, end: end, stroke: 0.4pt))
  #place(top + left, line(start: (start.at(0), start.at(1)), end: (start.at(0) + 13pt, start.at(1)), stroke: 0.4pt))
  #place(top + left, dx: start.at(0) + 5pt, dy: start.at(1) - 10pt, title)
]
#let dimension(x1, x2, y, title) = [
  #place(top + left, line(start: (x1, y), end: (x2, y), stroke: 0.4pt))
  #place(top + left, curve(fill: rgb("#000000"), stroke: none,
    curve.move((x1, y)), curve.line((x1 + 5pt, y - 1.4pt)), curve.line((x1 + 5pt, y + 1.4pt)), curve.close()))
  #place(top + left, curve(fill: rgb("#000000"), stroke: none,
    curve.move((x2, y)), curve.line((x2 - 5pt, y - 1.4pt)), curve.line((x2 - 5pt, y + 1.4pt)), curve.close()))
  #place(top + left, dx: (x1 + x2) / 2 - 4pt, dy: y - 11pt, title)
]
#let drawing = box(width: 390pt, height: 133pt)[
  #set text(size: 7.5pt)
  #place(top + left, curve(stroke: 0.7pt, fill: none,
    curve.move((76pt, 76pt)), curve.line((89pt, 68pt)), curve.line((296pt, 68pt)),
    curve.line((296pt, 84pt)), curve.line((89pt, 84pt)), curve.close()))
  #place(top + left, curve(stroke: 0.6pt, fill: none,
    curve.move((248pt, 67pt)), curve.cubic((240pt, 65pt), (244pt, 49pt), (252pt, 49pt)),
    curve.line((253pt, 65pt)), curve.line((302pt, 65pt)), curve.line((302pt, 86pt)),
    curve.line((253pt, 86pt)), curve.line((253pt, 102pt)),
    curve.cubic((244pt, 102pt), (241pt, 86pt), (248pt, 85pt))))
  #place(top + left, curve(stroke: 0.7pt, fill: none,
    curve.move((302pt, 65pt)), curve.line((307pt, 65pt)),
    curve.cubic((318pt, 65pt), (318pt, 86pt), (307pt, 86pt)), curve.line((302pt, 86pt))))
  #for x in range(256, 300, step: 5) {
    place(top + left, line(start: (x * 1pt, 65pt), end: ((x + 3) * 1pt, 68pt), stroke: 0.35pt))
    place(top + left, line(start: (x * 1pt, 83pt), end: ((x + 3) * 1pt, 86pt), stroke: 0.35pt))
  }
  #place(top + left, line(start: (78pt, 76pt), end: (316pt, 76pt), stroke: (thickness: 0.35pt, dash: "dash-dotted")))
  #leader((147pt, 27pt), (165pt, 74pt), [1])
  #leader((253pt, 27pt), (268pt, 66pt), [2])
  #leader((279pt, 41pt), (288pt, 70pt), super[a])
  #leader((300pt, 41pt), (310pt, 67pt), super[b])
  #place(top + left, line(start: (76pt, 77pt), end: (76pt, 128pt), stroke: 0.4pt))
  #place(top + left, line(start: (244pt, 87pt), end: (244pt, 128pt), stroke: 0.4pt))
  #place(top + left, line(start: (255pt, 90pt), end: (255pt, 128pt), stroke: 0.4pt))
  #place(top + left, line(start: (307pt, 90pt), end: (307pt, 128pt), stroke: 0.4pt))
  #dimension(76pt, 244pt, 125pt, $l_2$)
  #dimension(255pt, 307pt, 125pt, $l_1$)
  #place(top + left, line(start: (112pt, 45pt), end: (112pt, 102pt), stroke: 0.4pt))
  #place(top + left, dx: 99pt, dy: 54pt, rotate(-90deg, reflow: true, text(font: "New Computer Modern Math", [⌀3.5])))
  #place(top + left, curve(fill: rgb("#000000"), stroke: none,
    curve.move((112pt, 68pt)), curve.line((110.6pt, 63pt)), curve.line((113.4pt, 63pt)), curve.close(),
    curve.move((112pt, 84pt)), curve.line((110.6pt, 89pt)), curve.line((113.4pt, 89pt)), curve.close()))
]
#fragment[
  #block(width: 459pt, height: 422pt, stroke: 0.5pt, inset: 0pt)[
    #set par(first-line-indent: 0pt, leading: 13.5pt - note-size, spacing: 0pt)
    #set text(size: note-size)
    #place(top + right, dx: -4pt, dy: 15pt, [单位为毫米])
    #place(top + left, dx: 31pt, dy: 42pt, drawing)
    #place(top + left, dx: 91pt, dy: 186pt, table(columns: (135pt, 135pt), rows: 15.75pt,
      inset: 2pt, stroke: 0.4pt, align: center + horizon,
      table.header($l_1$, $l_2$),
      [6], table.cell(rowspan: 4)[27], [12], [20], [30]))
    #place(top + left, dx: 20pt, dy: 275pt, block[
      标引序号说明：\
      1——钉芯；\
      2——钉体。\
      钉芯的设计应保证：安装时，钉体变形、胀粗，之后钉芯抽断。\
      注：此图所示为开口型平圆头抽芯铆钉。\
      #super[a] 断裂槽应滚压成型。\
      #super[b] 钉芯头的形状和尺寸由制造者确定。
    ])
    #place(top + left, dy: 388pt, block(width: 100%, align(center, black[图 X　抽芯铆钉])))
  ]
]

