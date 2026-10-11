#import "../../template/lib.typ": *
#import "common.typ": fragment
#let node(x, y, numbers, prefix: "") = place(top + left, dx: x * 1pt, dy: y * 1pt,
  text(font: song, size: note-size, prefix + numbering("1.1", ..numbers)))
#let bracket(x, y1, y2, parent-y, tail: 15) = [
  #place(top + left, line(start: (x * 1pt, y1 * 1pt), end: (x * 1pt, y2 * 1pt), stroke: 0.5pt))
  #place(top + left, line(start: (x * 1pt, y1 * 1pt), end: ((x + 12) * 1pt, y1 * 1pt), stroke: 0.5pt))
  #place(top + left, line(start: (x * 1pt, y2 * 1pt), end: ((x + 12) * 1pt, y2 * 1pt), stroke: 0.5pt))
  #place(top + left, line(start: ((x - tail) * 1pt, parent-y * 1pt), end: (x * 1pt, parent-y * 1pt), stroke: 0.5pt))
]
#fragment[
  #box(width: 480pt, height: 370pt)[
    #set text(size: note-size)
    #place(top + left, dx: 74pt, dy: 0pt, black[章编号])
    #place(top + left, dx: 265pt, dy: 0pt, black[各层次条编号])
    #place(top + left, line(start: (132pt, 23pt), end: (430pt, 23pt), stroke: 0.5pt))
    #place(top + left, line(start: (132pt, 23pt), end: (132pt, 29pt), stroke: 0.5pt))
    #place(top + left, line(start: (430pt, 23pt), end: (430pt, 29pt), stroke: 0.5pt))
    #place(top + left, line(start: (287pt, 16pt), end: (287pt, 23pt), stroke: 0.5pt))
    #for (i, title) in ([范围], [规范性引用文件], [术语和定义]).enumerate() {
      place(top + left, dx: 5pt, dy: (35 + i * 16) * 1pt, title)
    }
    #for n in range(1, 13) { node(77, 35 + (n - 1) * 16, (n,)) }
    #for n in range(1, 5) { node(126, 99 + (n - 1) * 16, (6, n)) }
    #for n in range(1, 6) { node(176, 99 + (n - 1) * 16, (6, 3, n)) }
    #for n in range(1, 5) { node(239, 131 + (n - 1) * 16, (6, 3, 4, n)) }
    #for n in range(1, 5) { node(311, 147 + (n - 1) * 16, (6, 3, 4, 3, n)) }
    #for n in range(1, 3) { node(389, 195 + (n - 1) * 16, (6, 3, 4, 3, 4, n)) }
    #bracket(109, 104, 152, 120)
    #bracket(160, 104, 168, 136)
    #bracket(223, 136, 184, 152)
    #bracket(295, 152, 200, 168)
    #bracket(373, 200, 216, 200)
    #place(top + left, dx: 77pt, dy: 240pt, [附录A])
    #place(top + left, dx: 77pt, dy: 288pt, [附录B])
    #place(top + left, dx: 77pt, dy: 337pt, [附录C])
    #for n in range(1, 6) { node(127, 256 + (n - 1) * 16, (n,), prefix: "B.") }
    #for n in range(1, 5) { node(176, 272 + (n - 1) * 16, (3, n), prefix: "B.") }
    #for n in range(1, 5) { node(239, 288 + (n - 1) * 16, (3, 3, n), prefix: "B.") }
    #for n in range(1, 3) { node(127, 337 + (n - 1) * 16, (n,), prefix: "C.") }
    #bracket(110, 261, 325, 293, tail: 6)
    #bracket(160, 277, 325, 293)
    #bracket(223, 293, 341, 309)
    #bracket(110, 342, 358, 342, tail: 6)
  ]
]
