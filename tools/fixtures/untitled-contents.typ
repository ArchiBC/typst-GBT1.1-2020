#import "../../template/lib.typ": *
#let inserted = sys.inputs.at("insert-clause", default: "false") == "true"
#let included = sys.inputs.at("clause-contents", default: "true") == "true"
#show: gbt.with(title: ([无标题条编号与目录验证],), contents-depth: 3,
  cover-page: false, main-title: false, two-sided: false, end-rule: false,
  clause-contents: included)

= 要求 <requirements>
#if inserted { [#clause() 新插入的无标签条。] }

#clause() 无标签条第一段正文。

本条第二段正文保持普通段落缩进。

#clause() <referenced-clause> 带引用标签的条。

== 检验方法 <test-method>
#clause() 下级无标签条正文。

#block[
  #set text(size: note-size)
  #clause(outlined: false) 本条只编号，不进入目录；条号使用当前段落字号。
]

条引用：@referenced-clause。标题引用：@test-method。页引用：#ref(<referenced-clause>, form: "page")。

#annex("A", [附录要求])[
= 一般要求
#clause() 附录内的无标签条。
]

#context {
  for key in ("requirements", "referenced-clause", "test-method") {
    let found = query(label(key))
    assert(found.len() == 1, message: "每个引用标签应只对应一个元素：" + key)
    let target = resolve-reference-target(found.first())
    assert(target.func() == heading)
    metadata((kind: "gbt-reference-check", key: key,
      number: numbering(target.numbering, ..counter(heading).at(target.location())),
      unique: true, native-heading: true, is-clause: is-kind(target, "gbt-clause"),
      page: target.location().page(), folio: counter(page).at(target.location()).first()))
  }
}
