#import "/template/content.typ": article as clause, commentary as explain, data-table

= 总则 <semantic-general>
#clause[
正文必须采用模板指定的十二磅字号。参见 @semantic-access。

+ 第一项完整内容；
+ 第二项完整内容。
] <semantic-purpose>
#explain[制定目的的说明。]

#if sys.inputs.at("insert-clause", default: "false") == "true" [
  #clause[新增条文保留全部内容。]
  #explain[新增条文的说明必须跟随自动条号。]
]

= 基本规定
== 功能要求
#clause[
正文必须采用模板指定的十二磅字号。
#data-table("semantic-table", [使用要求], 2, (
  (row: 0, column: 0, body: [项目]),
  (row: 0, column: 1, body: [要求]),
  (row: 1, column: 0, body: [通行]),
  (row: 1, column: 1, body: [连续、便捷]),
))
] <semantic-access>
#explain[功能要求的说明引用 @semantic-purpose。]
