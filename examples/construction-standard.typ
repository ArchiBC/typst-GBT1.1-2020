// 编译入口；内容和模板分别维护。
#import "../template/construction-document.typ": construction-document
#show: construction-document.with(
  info: (title: ([工程建设规范示例],), english: ([Example construction code],),
    serial: "XXXXX", year: "2026", issued: "2026-10-13", implemented: "2027-01-01",
    organizations: ("中华人民共和国住房和城乡建设部", "国家市场监督管理总局")),
  explanation-intro: [本条文说明供理解正文使用。],
)
#include "construction-content.typ"
