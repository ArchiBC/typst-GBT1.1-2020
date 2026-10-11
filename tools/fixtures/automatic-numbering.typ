#import "../../template/lib.typ": *
#show: gbt.with(cover-page: false, main-title: false, end-rule: false,
  contents: false, two-sided: false)

= 术语和定义
== 概念
#if sys.inputs.at("insert-entry", default: "false") == "true" {
  term([新增条目], [inserted entry], [用于验证插入后的连续编号。])
}
#term([标准], [standard], [用于验证自动编号。], key: "tested-term")
#term([相关概念], [related concept], [参见标准（#ref(<tested-term>)）。], key: "related-term")

= 要求
#clause(key: "first-clause") 无标题条直接接排普通正文。

#if sys.inputs.at("insert-clause", default: "false") == "true" {
  [#clause() 新增的无标题条。

  ]
}
#clause(key: "second-clause") 参见 #ref(<first-clause>)。

== 验证
#clause(key: "nested-clause") 无标题条与有标题条共用层次计数器。

自动引用验证：术语 #ref(<tested-term>)；条 #ref(<second-clause>)；下级条 #ref(<nested-clause>)。

#annex("A", [附录计数器验证])[
= 一般规定
#clause(key: "annex-clause") 附录无标题条。

附录引用：#ref(<annex-clause>)。
]

#keyword-index(entries: (
  ([条], (<second-clause>,)),
  ([术语], (<tested-term>,)),
))
