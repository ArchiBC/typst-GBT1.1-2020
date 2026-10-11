#import "../../template/lib.typ": *
#let crosses(count, line-height: 5pt, advance: 10.5pt) = [#for _ in range(count) {
  // Source specimens have 5 pt ink at the embedded page scale, an advance
  // of 10.5 pt and a smaller line box. Calibrate the mark, not the paragraph.
  box(width: advance, height: line-height, baseline: 0pt)[
    #place(top + left, dx: -2pt, dy: -4.5pt,
      text(font: if font-profile == "reference" { "FZShuSong-Z01" } else { "Source Han Serif SC" },
        size: 14.2pt, tracking: 0pt)[×])
  ]
  text(size: 0pt, sym.zws)
}]
#let placeholder = crosses(86)
#let sample-body = [
  = 范围
  #placeholder
  = 规范性引用文件
  #placeholder
  = 术语和定义
  #placeholder
]
#let fragment(body) = {
  show: gbt.with(cover-page: false, main-title: false, end-rule: false, contents: false, two-sided: false)
  set page(width: 165mm, height: auto, margin: 0pt, header: none, footer: none)
  body
}
