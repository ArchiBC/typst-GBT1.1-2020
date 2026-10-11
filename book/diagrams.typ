#import "../template/lib.typ": *

#let diagram-identifier() = {
  let drawing = box(width: 349.000pt, height: 108.000pt)[
    #set par(first-line-indent: 0pt, justify: false, leading: 0pt, spacing: 0pt)
    #place(top + left, line(start: (0.000pt, 83.500pt), end: (347.667pt, 83.500pt), stroke: 1.167pt))
    #place(top + left, line(start: (0.000pt, 43.833pt), end: (347.667pt, 43.833pt), stroke: 1.167pt))
    #place(top + left, line(start: (95.667pt, 38.167pt), end: (347.667pt, 38.167pt), stroke: 0.500pt))
    #place(top + left, line(start: (-0.333pt, 9.000pt), end: (347.667pt, 9.000pt), stroke: 0.833pt))
    #for (x, y, direction) in ((0pt, 9pt, 1), (347.667pt, 9pt, -1), (95.667pt, 38.167pt, 1), (347.667pt, 38.167pt, -1)) {
      place(top + left, polygon((x, y), (x + direction * 5pt, y - 1.5pt), (x + direction * 5pt, y + 1.5pt), fill: rgb("#000000"), stroke: none))
      place(top + left, line(start: (x, y - 3.5pt), end: (x, y + 3.5pt), stroke: 0.5pt))
    }
    #place(top + left, line(start: (240.833pt, 43.333pt), end: (240.833pt, 84.000pt), stroke: 1.167pt))
    #place(top + left, line(start: (0.500pt, 43.333pt), end: (0.500pt, 84.000pt), stroke: 1.167pt))
    #place(top + left, line(start: (347.167pt, 37.333pt), end: (347.167pt, 84.000pt), stroke: 1.167pt))
    #place(top + left, line(start: (96.167pt, 35.000pt), end: (96.167pt, 84.000pt), stroke: 1.167pt))
    #place(top + left, dx: 167.161pt, dy: -1.646pt, box(width: 18.913pt, text(font: song, size: 9pt, weight: "regular", fit-line([标记], 18.913pt))))
    #place(top + left, dx: 189.148pt, dy: 28.910pt, box(width: 54.430pt, text(font: song, size: 9pt, weight: "regular", fit-line([识别段（见#ref(<s-B-6>)）], 54.430pt))))
    #place(top + left, dx: 261.451pt, dy: 56.071pt, box(width: 62.886pt, text(font: song, size: 9pt, weight: "regular", fit-line([特性段（见#ref(<s-B-6-3>)）], 62.886pt))))
    #place(top + left, dx: 116.845pt, dy: 56.920pt, box(width: 106.437pt, text(font: song, size: 9pt, weight: "regular", fit-line([标准代号和顺序号段（见#ref(<s-B-6-2>)）], 106.437pt))))
    #place(top + left, dx: 16.637pt, dy: 61.589pt, box(width: 55.276pt, text(font: song, size: 9pt, weight: "regular", fit-line([描述段（见#ref(<s-B-5>)）], 55.276pt))))
    #place(top + left, dx: 149.826pt, dy: 67.954pt, box(width: 43.859pt, text(font: song, size: 9pt, weight: "regular", fit-line([最多9个字符], 43.859pt))))
    #place(top + left, dx: 264.410pt, dy: 67.954pt, box(width: 61.195pt, text(font: song, size: 9pt, weight: "regular", fit-line([建议最多18个字符], 61.195pt))))
  ]
  gbt-figure([标记体系的组成], drawing, outlined: true)
}

