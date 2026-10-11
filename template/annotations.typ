// CeTZ 0.5.2 is vendored to make compilation independent of package downloads.
#import "../vendor/cetz-0.5.2/src/lib.typ" as cetz
#import "fonts.typ": song

// Coordinates and labels are measured in millimetres on the original A4 page.
// Each dimension is (start, end, extension-start, extension-end, label).
#let annotated-page(path, dimensions: (), width: 155mm) = {
  set text(font: song, size: 7.5pt, ligatures: false, discretionary-ligatures: false)
  let factor = width / 210mm
  cetz.canvas(length: factor * 1mm, {
    import cetz.draw: *
    content((0, 0), image(path, width: width), anchor: "north-west", padding: 0pt)
    rect((0, 0), (210, -297), stroke: 0.6pt)
    for (a, b, ea, eb, label) in dimensions {
      line(ea, a, stroke: 0.35pt)
      line(eb, b, stroke: 0.35pt)
      line(a, b, stroke: 0.35pt, mark: (start: ">", end: ">", fill: rgb("#000000"), scale: 0.45))
      let middle = ((a.at(0) + b.at(0)) / 2, (a.at(1) + b.at(1)) / 2)
      let horizontal = a.at(1) == b.at(1)
      content((middle.at(0) + if horizontal { 0 } else { -2.2 }, middle.at(1) + if horizontal { 2.2 } else { 0 }),
        label, angle: if horizontal { 0deg } else { 90deg }, padding: 0pt)
    }
  })
}
