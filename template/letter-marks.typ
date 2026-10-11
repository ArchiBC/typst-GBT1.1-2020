// Native letter outlines for the local-standard cover specimen (Annex E.7).
// The two white counters belong to each letter; no font or image is involved.
#let db-mark(width: 40mm) = {
  let factor = width / 40mm
  scale(x: factor * 100%, y: factor * 100%, origin: top + left, reflow: true,
    box(width: 40mm, height: 20mm)[
      #place(top + left, rect(width: 19mm, height: 20mm, radius: (top-right: 1.8mm, bottom-right: 1.8mm), fill: black, stroke: none))
      #place(top + left, dx: 6mm, dy: 2.2mm, rect(width: 7mm, height: 15.6mm, radius: 0.5mm, fill: white, stroke: none))
      #place(top + left, dx: 20mm, rect(width: 19mm, height: 10mm, radius: (top-right: 1.8mm, bottom-right: 1.8mm), fill: black, stroke: none))
      #place(top + left, dx: 20mm, dy: 10mm, rect(width: 19mm, height: 10mm, radius: (top-right: 1.8mm, bottom-right: 1.8mm), fill: black, stroke: none))
      #place(top + left, dx: 26mm, dy: 2.2mm, rect(width: 7mm, height: 5.5mm, radius: 0.5mm, fill: white, stroke: none))
      #place(top + left, dx: 26mm, dy: 12.2mm, rect(width: 7mm, height: 5.5mm, radius: 0.5mm, fill: white, stroke: none))
    ])
}
