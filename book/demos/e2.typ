#import "../../template/lib.typ": *
#import "common.typ": crosses
#show: gbt.with(publication-layout: false, cover-page: false, main-title: false, end-rule: false, contents: false, two-sided: false, serial: "XXXXX", year: "XXXX", folio: [XX])
#box(width: 0pt, height: 1pt)
#pagebreak()
#counter(page).update(2)
#par(first-line-indent: 0pt, crosses(88))
