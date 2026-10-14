#import "../../template/lib.typ": *
#show: gbt.with(title: ([中英混排检验 Typography 2026],),
  english: ([Typography and baseline alignment],),
  two-sided: false, contents: false, end-rule: false)

= 混排标题 Typography 123 <mixed-heading>
正文基准 ABC xyz 123；扩展字符 café naïve αβγ；中文标点（ABC），123。
*强调混排 Bold 456*，#emph[斜体 italic 789]。
#black[扩展粗体 café naïve αβγ АБВ]。
商标®、版权©、标识™。
文本上标 X#super(typographic: false)[SUP]；文本下标 Y#sub(typographic: false)[SUB]。
手动基线 M#text(baseline: -2pt)[RAISE]，N#text(baseline: 2pt)[LOWER]。
#black[黑体上移 0#text(baseline: -2pt)[12]；黑体下移 0#text(baseline: 2pt)[34]]。
追踪#text(tracking: 1pt)[TRACK 246]；对照#text(tracking: 0pt)[TRACK 246]；
#text(font: "DejaVu Sans Mono")[MONO 357]。
#text(font: "DejaVu Sans Mono")[*MONOBOLD 468*]。

#note[小五宋体 note 123，*小五强调 Bold 456*，#black[继承黑体 Black 789]。
  #black[嵌入西文 #text(font: latin-bold)[EMBED 123]]。
  文本脚标 H#sub(typographic: false)[2]O；文本上标 S#super(typographic: false)[a]。
  #linebreak()注释续行 continued 012。]
#example(inline: true)[小五示例 Example 123，*示例强调 Strong 456*。]

#gbt-table([中英表题 Table 123], columns: (1fr, 1fr),
  headers: ([表头 Header 123], [表头 Header 456]),
  rows: (([常规单元 Regular 123], [*强调单元 Strong 456*]),
    ([上标 T#super(typographic: false)[a]], [下标 U#sub(typographic: false)[b]])),
  unit: [单位 Unit mm], notes: ([表注 Table note 123。],),
  footnotes: ([表脚注 Table footnote 456。],))

#gbt-figure([中英图题 Figure 123],
  [图内文字 Figure body 123，*图内强调 Figure bold 456*，
    #black[图内嵌套 #text(font: latin-bold)[NEST 789]]],
  unit: [单位 Figure unit mm], notes: ([图注 Figure note 123。],))
#example[#gbt-figure([示例图题 Nested figure 123],
  [示例图内 Nested body 456])]

#gbt-equation($v = l/t$, definitions: (($v$, [速度 speed m/s；]),
  ($l$, [距离 length m；]), ($t$, [时间 time s。])))

#term([混排术语], [mixed term 123], [术语定义 definition 456。]) <mixed-term>
小五脚注测试#footnote[脚注内容 Footnote 123，*脚注强调 Bold 456*。]。
引用 @mixed-heading 和 @mixed-term。

#text(size: 12pt)[自定义字号 Custom 12pt，*自定义强调 Custom bold 12pt*。]
