#import "../../template/lib.typ": *
#let local-logo = box(width: 40mm, height: 20mm)[
  #place(top + left, dx: -44mm, db-mark())
  #place(top + left, letter-mark([XX], note: [a]))
]
#cover(title: ([标准名称],), code: "DBXX/T", serial: "XXX", year: "XXXX", ics: "XXXXXXX", ccs: "X XX", category: "××××（地方名称）地方标准", logo: local-logo, replaces: "DBXX/T XXX—XXXX", organizations: ("地方标准发布部门",), organization-note: [b], publisher-gap: 10mm)
