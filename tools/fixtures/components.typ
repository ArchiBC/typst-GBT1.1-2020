#import "../../template/lib.typ": *
#show: gbt.with(title: ([组件检验],), english: ([Component verification],),
  contents: true, figure-list: true, table-list: true, two-sided: false,
  preface: [本文件用于验证目录、编号、引用及长表分页。#footnote[脚注一。]],
)
= 范围 <scope>
见 @details、@first-table 和 @first-figure。
#footnote[脚注二。]
= 规范性引用文件
GB/T 1.1—2020　标准化工作导则
= 术语和定义
#term([测试条目], [test entry], [组件验证使用的术语条目。])
= 编号检验 <details>
#gbt-table([首次表格], columns: (1fr, 1fr), headers: ([项目], [数值]),
  rows: (([一], [1]),)) <first-table>
#gbt-figure([首次图形], rect(width: 20mm, height: 10mm)[图形]) <first-figure>
参见 @first-table、@first-figure。
#if sys.inputs.at("insert-equation",default: "false")=="true" { gbt-equation($x=y$) }
#gbt-equation($a=b+c$) <first-equation>
公式引用：@first-equation。
#pagebreak()
= 长表
#gbt-table([连续测量记录], columns: (1fr, 1fr, 1fr),
  headers: ([序号], [长度], [时间]),
  rows: range(1, 91).map(i => (str(i),str(i*10),str(i))),
  notes: ([只在末页出现的表注。],),
  footnotes: ([只在末页出现的表脚注。],))
#gbt-table([后续表格], columns: (1fr,1fr), headers: ([项目],[数值]),
  rows: (([二],[2]),))
#annex("A", [附录内独立编号])[
= 附录条文 <annex-clause>
#gbt-table([附录表格], columns: (1fr,1fr), headers: ([项目],[数值]),
  rows: (([甲],[1]),)) <annex-table>
#gbt-figure([附录图形], rect(width: 20mm, height: 10mm)[A]) <annex-figure>
参见 @annex-clause、@annex-table 和 @annex-figure。
#gbt-equation($r=n/N$) <annex-equation>
附录公式引用：@annex-equation。
]
#annex("B", [第二个附录], normative: false)[
= 附录条文
#gbt-table([第二个附录表格], columns: (1fr,1fr),
  headers: ([项目],[数值]), rows: (([乙],[2]),))
#gbt-equation($s=a+b$)
]
#references(([参考文件一],))
#keyword-index(entries: (([检验], [4，附录 A]),))
