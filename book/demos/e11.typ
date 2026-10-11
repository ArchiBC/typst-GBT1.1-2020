#import "../../template/lib.typ": *
#show: gbt.with(publication-layout: false, cover-page: false, main-title: false, end-rule: false, contents: false, two-sided: false, serial: "XXXXX", year: "XXXX", folio: [])
// The same alphabetical index component renders the normative specimen.
#keyword-index(columns: 1, merge: false, entries: (
  ([××××], [3.6，5.1.3，6.1.1，6.2.1], "a01"),
  ([××], [表 2], "a02"),
  ([××], [5.2.1，5.2.2，表 A.1], "a03"),
  ([×××××××], [附录 B，C.3.1], "a04"),
  ([×], [5.2.1，6.1.2，6.1.3，表 A.1], "a05"),
  ([××], [6.2.3，6.2.5，图 1，表 1], "a06"),
  ([×××], [6.3.4], "a07"),
  ([××], [表 1], "a08"),
  ([××××××], [6.2.3], "a09"),
  ([××], [5.1.2，5.2.2，6.2.2，A.3，表 2], "a10"),
  ([××××], [5.2.2], "a11"),
  ([××××], [4.3，6.1.2，6.2.3，A.2], "b01"),
  ([××], [3.2.3], "b02"),
  ([×××××], [6.1.1], "b03"),
))
……
#end-mark()
