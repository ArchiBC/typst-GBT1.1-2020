#import "../../template/lib.typ": *
#let custom-front = [#text(size: 15pt, weight: "bold")[自定义前置页]#pagebreak()]
#show: construction-standard.with(cover-page: false, two-sided: false,
  front-matter: custom-front, text-style: (size: 12pt),
  page-layout: (width: 160mm, height: 240mm),
  back-matter: [#explanations(heading-renderer: construction-explanation-heading)],
)

#for chapter in range(6) {
  heading(level: 1)[无节标题章]
  clause()
  [正文必须采用十二点字号。]
  enum([数字列项甲。], [数字列项乙。])
  explain[没有手填条号的说明。]
}

= 有节标题章
== 一般要求
#clause() <profile-target> 这里应为第七章的第一节第一条。
#explain[本条引用原文 @profile-target。]

#annex("A", [工程规范附录])[
= 一般规定
#clause() 附录沿用 A.1.1 层次，不插入无标题章的零节号。
#explain[工程规范附录说明。]
]
