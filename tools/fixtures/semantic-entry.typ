#import "/template/construction-document.typ": construction-document
#import "/template/lib.typ": construction-heading
#show: construction-document.with(
  info: (title: ([内容与格式分离],), serial: "XXXXX", year: "2026"),
  cover-page: false, two-sided: false,
  page-layout: (width: 160mm, height: 240mm),
  text-style: (size: 12pt),
  renderers: (heading: construction-heading.with(chapter-break: false)),
)
#include "semantic-content.typ"
