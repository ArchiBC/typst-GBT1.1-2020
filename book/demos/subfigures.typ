#import "../../template/lib.typ": *
#import "common.typ": fragment
#fragment[
  #block(width: 459pt, stroke: 0.5pt, inset: (x: 20pt, y: 9pt))[
    #set text(size: note-size)
    #set par(first-line-indent: 0pt, leading: 13.5pt - note-size)
    #align(right)[关于单位的陈述]
    #v(0.6em)
    #pad(x: 15pt, grid(columns: (1fr, 1fr), column-gutter: 60pt,
      [#block(width: 100%, height: 82pt, fill: rgb("#e0e0e0"), align(center + horizon)[图])
       #v(0.3em)#align(center, black([#text(font: latin-bold)[a)]　分图题], size: 9pt))],
      [#block(width: 100%, height: 82pt, fill: rgb("#e0e0e0"), align(center + horizon)[图])
       #v(0.3em)#align(center, black([#text(font: latin-bold)[b)]　分图题], size: 9pt))]))
    #v(0.5em)
    标引序号说明：\
    1——说明的内容\
    2——说明的内容\
    段（可包含要求）\
    #black([注：], size: 9pt)图中的注的内容\
    #super[a] 图脚注的内容
    #v(1em)
    #align(center, black(size: 10.5pt)[图 X　图题])
    #v(0.5em)
  ]
]
