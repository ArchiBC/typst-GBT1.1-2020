#import "../../template/lib.typ": *
#show: gbt.with(cover-page: false, main-title: false, end-rule: false,
  contents: false, two-sided: false)

= 术语和定义
== 概念
#if sys.inputs.at("insert-entry", default: "false") == "true" {
  term([新增条目], [inserted entry], [用于验证插入后的连续编号。])
}
#term([标准], [standard], [用于验证自动编号。]) <tested-term>
#term([相关概念], [related concept], [参见标准（@tested-term）。]) <related-term>

= 要求
#clause() <first-clause> 无标题条直接接排普通正文。

#if sys.inputs.at("insert-clause", default: "false") == "true" {
  [#clause() 新增的无标题条。

  ]
}
#clause() <second-clause> 参见 @first-clause。

== 验证
#clause() <nested-clause> 无标题条与有标题条共用层次计数器。

自动引用验证：术语 @tested-term；条 @second-clause；下级条 @nested-clause。

引用边界验证：第#[@first-clause]条，#[@second-clause]a)。

页引用验证：#ref(<first-clause>, form: "page")。

#for i in range(12) {
  [#clause()#label("sequence-" + str(i)) 连续条文，用于验证引用目标不会误指相邻条。

  ]
}

连续条引用验证：#for i in range(12) {
  if i > 0 { [；] }
  ref(label("sequence-" + str(i)))
}。

#annex("A", [附录计数器验证])[
= 一般规定
#clause() <annex-clause> 附录无标题条。

附录引用：@annex-clause。
]

#context {
  let targets = ("tested-term", "related-term", "first-clause", "second-clause", "nested-clause", "annex-clause") + range(12).map(i => "sequence-" + str(i))
  for key in targets {
    let found = query(label(key))
    assert(found.len() == 1, message: "每个引用标签应只对应一个元素：" + key)
    let target = resolve-reference-target(found.first())
    assert(target.func() == heading, message: "条与术语的引用应解析到原生标题。")
    metadata((kind: "gbt-reference-check", key: key,
      number: numbering(target.numbering, ..counter(heading).at(target.location())),
      unique: true, native-heading: true, page: target.location().page(),
      folio: counter(page).at(target.location()).first()))
  }
}

#keyword-index(entries: (
  ([条], (<second-clause>,)),
  ([术语], (<tested-term>,)),
))
