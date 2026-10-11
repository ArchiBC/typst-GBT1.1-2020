#import "../../template/lib.typ": *
#import "../illustrations.typ": comparison
#import "common.typ": fragment
#fragment[#comparison([
  $op("dim")(E) = op("dim")(F) times op("dim")(l)$
  #v(0.5em)
  式中：\ $E$ —— 能量；\ $F$ —— 力；\ $l$ —— 长度。
], [
  $op("dim")("能量") = op("dim")("力") times op("dim")("长度")$\
  或\
  $italic(op("dim"))("能量") = italic(op("dim"))("力") times italic(op("dim"))("长度")$
])]
