#import "../../template/lib.typ": *
#import "../../book/illustrations.typ": equation-example
#show: gbt.with(title: ([对齐检验],), cover-page: false, main-title: false,
  contents: false, two-sided: false, end-rule: false)

= 基线检验
中文与 ABC 123 同行。
#note(number: 1)[单行注基线。]
#note(number: 2)[多行注首行。\ 多行注续行。]

#gbt-table([基线检验表], columns: (1fr, 1fr), cell-align: center + horizon,
  headers: ([第一列], [第二列]),
  rows: (([*粗体单元格*], [常规单元格]),),
  notes: ([表注首行。\ 表注续行。],),
  footnotes: ([表脚注首行。\ 表脚注续行。],))

#equation-example($v = l/t$, definitions: (
  ($v$, [速度释义；]), ($l$, [距离释义；]), ($t$, [时间释义。]),
))
#gbt-equation($x^2 + y^2 < z^2$, definitions: (
  ($x$, [横坐标释义；]), ($y$, [纵坐标释义。]),
))
