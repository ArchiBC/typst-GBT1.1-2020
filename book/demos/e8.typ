#import "../../template/lib.typ": *
#import "common.typ": placeholder
#import "../specimens.typ": specimen-page, specimen-title, specimen-at, specimen-contents
#specimen-page()[
  #specimen-title([目#h(32pt)次])
  #specimen-at(25.5, 61.15, block(width: 164.5mm, specimen-contents()))
]
#pagebreak()
#specimen-page(header: false)[]
#pagebreak()
// Query real chapters and counters: every outline entry and folio is automatic.
#show: gbt.with(publication-layout: false, cover-page: false, main-title: false,
  end-rule: false, contents: false, two-sided: false, serial: "XXXXX", year: "XXXX", folio: [])
#counter(page).update(3)
#set page(numbering: "I")
#front-title([前#h(32pt)言], outlined: true)
#placeholder
#pagebreak()
#front-title([引#h(32pt)言], outlined: true)
#placeholder
#pagebreak()
#counter(page).update(1)
#set page(numbering: "1")
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
