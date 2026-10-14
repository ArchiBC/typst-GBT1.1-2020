#import "../../template/lib.typ": *
#show: gbt.with(cover-page: false, main-title: false, end-rule: false,
  contents: false, two-sided: false)

= 总则 <general>
== 基本要求
#clause() <purpose> 正文甲。
#explain[甲的说明仅在文后出现。]

#if sys.inputs.at("insert-clause", default: "false") == "true" {
  [#clause() 新增正文。
  #explain[新增条款的说明。]

  ]
}
#clause() <second> 正文乙。
#explain[乙的说明引用原条：@purpose。]

#clause() <third> 正文丙。
#explain(of: <second>, through: <third>)[乙丙两条的合并说明。]

= 专项要求
== 其他
#clause() <long> 正文丁。
#explain[
  #for i in range(90) { [第#i 段长说明，应可跨页续排并保留条款引用。#parbreak()] }
]

#explanations(contents: true, intro: [说明前言。])

= 正文续章
#clause() <continued> 汇编说明后的正文仍保持原计数器。
