#import "../../template/lib.typ": *
#show: gbt.with(cover-page: false, main-title: false, end-rule: false,
  contents: true, contents-depth: 2, two-sided: false)

= 要求
== 一般要求
#let alpha = [
  #clause() <alpha> 可移动正文甲。
  #explain[跟随甲移动的说明。]

]
#let beta = [
  #clause() <beta> 可移动正文乙。
  #explain[跟随乙移动的说明，引用甲 @alpha。]

]
#if sys.inputs.at("swap", default: "false") == "true" { beta; alpha } else { alpha; beta }

#annex("A", [第一个附录])[
= 一般规定
#clause() <annex-a> 附录正文甲。
#explain[附录甲说明。]
]
#annex("B", [第二个附录])[
= 一般规定
#clause() <annex-b> 附录正文乙。
#explain[附录乙说明。]
]
#explanations(contents: true)
