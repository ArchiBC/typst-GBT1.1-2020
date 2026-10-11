#import "../template/lib.typ": *
#show: gbt.with(
  title: ([标准化文件], [编排与起草示例]),
  english: ([Standardizing documents—], [Examples of layout and drafting]),
  serial: "XXXXX", year: "2026", ics: "01.120", ccs: "A 00",
  issued: "XXXX-XX-XX", implemented: "XXXX-XX-XX", draft: [模板示例],
  preface: [
    本文件按照 GB/T 1.1—2020《标准化工作导则　第 1 部分：标准化文件的结构和起草规则》的规定起草。

    本文件给出国标文件的层次、要素和表述形式的排版示例。使用本模板时，应填写文件名称、分类号、编号、发布日期和实施日期等信息，并按实际内容选择要素。

    本文件由模板维护者编写。

    本文件为排版示例，其中的试验条件和技术指标用于演示组件。#footnote[示例的文件编号及日期采用占位内容。]
  ],
  introduction: [
    标准化文件的使用者需要清楚、准确、无歧义的条款，也需要便于阅读和引用的编排。本示例使用同一个模板呈现条文、列项、术语、图、表、数学公式、注和脚注。

    文件中的规范性附录和资料性附录分别给出可复用组件与辅助说明。
  ],
)

= 范围 <scope>
本文件规定了标准化文件的页面、层次及内容组件的编排要求。

本文件适用于使用 Typst 起草的标准化文件。

#note[本文件是一份完整模板的使用示例。]

= 规范性引用文件
下列文件中的内容通过文中的规范性引用而构成本文件必不可少的条款。其中，注日期的引用文件，仅该日期对应的版本适用于本文件；不注日期的引用文件，其最新版本（包括所有的修改单）适用于本文件。

GB/T 1.1—2020#h(1em)标准化工作导则　第 1 部分：标准化文件的结构和起草规则

= 术语和定义
下列术语和定义适用于本文件。

#term([标准化文件], [standardizing document],
  [通过标准化活动制定的文件。], source: [GB/T 1.1—2020，3.1.1], notes: ([本模板以可编辑的标准化文件为输出对象。],))
#term([版心], [type area], [页面中用于编排正文内容的区域。],
  examples: ([正文中包括章、条、段和列项等层次。],)) <type-area>

= 符号和缩略语
下列符号和缩略语适用于本文件。

#grid(columns: (4em, 1fr), row-gutter: 0.4em,
  [ICS], [国际标准分类], [CCS], [中国标准文献分类],
  $L$, [测量长度，单位为毫米（mm）], $t$, [测量时间，单位为秒（s）])

= 总体要求
== 页面与字体 <page-rules>
文件应采用 A4 幅面。正文字体应使用五号宋体，章、条编号和标题应使用五号黑体。

文件名称、章、条、段、列项及其字号和字体见 @text-specification。

#gbt-table([页面与文字规格],
  columns: (1.1fr, 1.2fr, 1fr), headers: ([对象], [规格], [字体]),
  rows: (
    ([幅面], [210 mm × 297 mm], [—]),
    ([正文], [五号 / 10.5 pt], [思源宋体]),
    ([章、条标题], [五号 / 10.5 pt], [思源黑体]),
    ([前言、引言标题], [三号 / 16 pt], [思源黑体]),
    ([注、示例、脚注], [小五号 / 9 pt], [思源宋体]),
  ), notes: ([字体选用与宋体、黑体类别相对应的开源字体。],),
  footnotes: ([字号按照 GB/T 1.1—2020 附录 F 设置。],)) <text-specification>

== 层次与列项
文件的章和条应连续编号。下一层次的条至少有两个才能细分。

=== 第一个条
=== 第二个条
==== 第一个下级条
==== 第二个下级条

以下条文示出两级列项。

+ 文件应提供可识别的名称；
+ 文件应按下列顺序编排：
  + 范围；
  + 规范性引用文件；
  + 术语和定义。
+ 文件宜提供便于检索的目次。

- 第一层次的无编号列项；
- 包含第二层次的列项：
  - 第一项；
  - 第二项。

#clause(level: 3) 无标题条的编号之后空一个汉字的间隙接排条文。参见版心（@type-area）。

#pagebreak()
= 试验方法
== 原理
长度和时间测量结果用于计算平均速度，按 @speed-equation 计算。

#gbt-equation($v = L / t$, definitions: (
  ($v$, [平均速度，单位为毫米每秒（mm/s）；]),
  ($L$, [测量长度，单位为毫米（mm）；]),
  ($t$, [测量时间，单位为秒（s）。]),
)) <speed-equation>

== 试验装置 <test-equipment>
试验装置的组成见 @equipment-figure。

#gbt-figure([试验装置示意],
  grid(columns: (1fr, auto, 1fr, auto, 1fr), align: horizon, column-gutter: 1em,
    rect(width: 30mm, height: 18mm, stroke: 0.6pt, inset: 4mm, align(center)[试件]),
    [→], rect(width: 30mm, height: 18mm, stroke: 0.6pt, inset: 4mm, align(center)[传感器]),
    [→], rect(width: 30mm, height: 18mm, stroke: 0.6pt, inset: 4mm, align(center)[记录装置])),
  notes: ([箭头表示数据传递方向。],),
  footnotes: ([各装置的位置可按实际条件调整。],)) <equipment-figure>

== 试验步骤
按下列步骤进行试验：

+ 检查测量装置并记录环境条件；
+ 测量试件长度和测量时间；
+ 按公式（1）计算结果，并保存试验记录。
#example(number: 1, [测量长度为 100 mm，测量时间为 5 s，则平均速度为 20 mm/s。])
#example(number: 2, framed: true, [
  #set text(size: 10.5pt)
  #black[6.3#h(1em)试验步骤]

  试验步骤的内容应清楚、准确，便于执行。
])

= 检验规则
== 判定 <judgement>
结果应记录在 @measurement-table 中。长表的后续页应重复表编号、表头，并标示“（续）”。

#gbt-table([测量记录], columns: (1fr, 1fr, 1fr),
  headers: ([序号], [长度 / mm], [时间 / s]),
  rows: range(1, 13).map(i => (str(i), str(i * 10), str(i)))) <measurement-table>

#pagebreak()
#gbt-table([测量记录], continued: true, columns: (1fr, 1fr, 1fr),
  headers: ([序号], [长度 / mm], [时间 / s]),
  rows: range(13, 25).map(i => (str(i), str(i * 10), str(i))),
  notes: ([每个单元格填写实测数值，无内容时填写一字线。],))

== 复核
测量结果应由记录人员复核。#footnote[此脚注连续使用前言中脚注的编号。]

= 标志与文件
记录文件应标明文件名称、编号、测试日期及结果。

采用的文档标记示例见 @annex-a，字体映射见 @annex-b。

#annex("A", [记录文件的组成])[
= 记录项目
记录文件应包括 @record-items 中的项目。

#gbt-table([记录项目], columns: (1fr, 2fr), headers: ([项目], [内容]),
  rows: (([基本信息], [名称、编号和日期]), ([试验信息], [仪器、方法和测量值]), ([复核信息], [记录人与复核人]))) <record-items>

= 标记示例
#example[记录文件标记由文件编号、记录类别和记录序号构成。]
#gbt-equation($R = n / N$, definitions: (($R$, [复核记录比例；]), ($n$, [已复核记录数；]), ($N$, [记录总数。])))
]

#annex("B", [开源字体与字号], normative: false)[
= 字体映射
宋体和黑体分别由思源宋体和思源黑体呈现。拉丁文字使用 Liberation Serif，数学公式使用 New Computer Modern Math。

#gbt-table([字体用途], columns: (1fr, 2fr), headers: ([用途], [开源字体]),
  rows: (([正文及表格], [Source Han Serif SC]), ([标题和编号], [Source Han Sans SC]), ([拉丁文字], [Liberation Serif]), ([数学公式], [New Computer Modern Math])))

= 使用说明
附录内的章、条、图、表和数学公式单独编号，并以附录字母作为前缀。
]

#references((
  [GB/T 1.1—2020#h(1em)标准化工作导则　第 1 部分：标准化文件的结构和起草规则],
  [GB/T 20000.1—2014#h(1em)标准化工作指南　第 1 部分：标准化和相关活动的通用术语],
))
#keyword-index(entries: (
  ([版心], (<type-area>, <page-rules>)),
  ([测量记录], (<judgement>, <measurement-table>)),
  ([试验装置], (<test-equipment>, <equipment-figure>)),
  ([字体], (<page-rules>, <annex-b>)),
))
