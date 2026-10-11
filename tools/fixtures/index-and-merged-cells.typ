#import "../../template/lib.typ": *
#import "../../template/index.typ": index-mark
#show: gbt.with(cover-page: false, contents: true, two-sided: true, title: ([索引与合并表头检查],))
= 范围
标准化文件#index-mark("标准化文件")在这里建立自动索引目标。
== 条目与定义
#clause() 此处定义术语#index-mark("术语")。

#term([框线], [frame], [示例框线#index-mark("框线")。])
#gbt-table([跨行跨列表头与合并内容], columns: (1fr, 1fr, 1fr),
  header-rows: (
    (table.cell(rowspan: 2, align: center + horizon)[项目], table.cell(colspan: 2, align: center + horizon)[测量结果]),
    ([第一次], [第二次]),
  ), rows: (
    (table.cell(rowspan: 2)[*温度*], [21.0], [21.2]),
    ([21.4], [21.6]),
    (table.cell(colspan: 3)[合并三列的说明。],),
  )) <merged-table>
#pagebreak()
= 规范性引用文件
编号#index-mark("编号")应完整。再次引用标准化文件#index-mark("标准化文件")。
#annex("A", [自动目录缩进])[
  = 一级
  == 二级
  === 三级
  参考框线#index-mark("框线")。
]
#annex("B", [无需先声明有标题条])[
  #clause() <bare-annex-clause> 附录中的首条。
  #term([附录术语], [annex term], [附录中的第二条。]) <bare-annex-term>
  附录条目引用：@bare-annex-clause、@bare-annex-term。
]
#keyword-index()
