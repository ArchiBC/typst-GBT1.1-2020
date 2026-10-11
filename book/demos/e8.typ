#import "../../template/lib.typ": *
#import "common.typ": placeholder
// Every page number is queried from an actual paginated example book.
// The specimen starts its preface at III; include its second contents side.
#show outline.where(target: figure.where(kind: table)): it => [#it#pagebreak()#box(height: 1pt)]
#show: gbt.with(publication-layout: false, cover-page: false, end-rule: false,
  two-sided: false, serial: "XXXXX", year: "XXXX", title: ([标准名称],),
  preface: placeholder, introduction: placeholder, folio: [], contents-depth: 2,
  figure-list: true, table-list: true)
= 范围
#placeholder
= 规范性引用文件
#placeholder
#pagebreak()
= 术语和定义
#placeholder
#pagebreak()
#placeholder
#pagebreak()
= ××
== ××
== ×××××
== ×××××××
#placeholder
#pagebreak()
= ××××
== ×××××
#gbt-figure([×××××××××], box(width: 20mm, height: 10mm, stroke: 0.4pt))
#pagebreak()
#gbt-figure([×××××××], box(width: 20mm, height: 10mm, stroke: 0.4pt))
#pagebreak()
== ×××××××××
#gbt-table([×××××], columns: (1fr,), headers: ([××],), rows: (([×××],),))
#pagebreak()
#gbt-table([×××××××], columns: (1fr,), headers: ([××],), rows: (([×××],),))
#pagebreak()
= ×××
== ×××××××
#gbt-figure([×××××××××××], box(width: 20mm, height: 10mm, stroke: 0.4pt))
#pagebreak()
== ×××××
#placeholder
#pagebreak()
== ×××××××××××
#placeholder
#annex("A", [×××××])[
  = ××
  = ×××
  = ××××
  #gbt-table([×××××××], columns: (1fr,), headers: ([××],), rows: (([×××],),))
]
#annex("B", [×××××××])[#placeholder]
#annex("C", [×××××], normative: false)[#placeholder]
#references(([××××××××××××],))
#keyword-index(entries: (([×××], [4.1]),), columns: 1)
