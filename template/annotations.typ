// CeTZ 0.5.2 is vendored to make compilation independent of package downloads.
#import "../vendor/cetz-0.5.2/src/lib.typ" as cetz
#import "fonts.typ": song

// Coordinates and labels are measured in millimetres on the original A4 page.
// Each dimension is (start, end, extension-start, extension-end, label).
#let annotated-page(path, dimensions: (), width: 155mm) = {
  set text(font: song, size: 7.2pt, ligatures: false, discretionary-ligatures: false)
  let factor = width / 210mm
  cetz.canvas(length: factor * 1mm, {
    import cetz.draw: *
    content((0, 0), image(path, width: width), anchor: "north-west", padding: 0pt)
    rect((0, 0), (210, -297), stroke: 0.9pt)
    for dimension in dimensions {
      let (a, b, ea, eb, label) = dimension.slice(0, 5)
      let options = if dimension.len() > 5 { dimension.at(5) } else { (:) }
      let length = calc.sqrt(calc.pow(b.at(0) - a.at(0), 2) + calc.pow(b.at(1) - a.at(1), 2))
      let u = ((b.at(0) - a.at(0)) / length, (b.at(1) - a.at(1)) / length)
      let outside = options.at("outside", default: length < 10)
      for (point, extension) in ((a, ea), (b, eb)) {
        if point != extension {
          let dx = point.at(0) - extension.at(0)
          let dy = point.at(1) - extension.at(1)
          let d = calc.sqrt(dx * dx + dy * dy)
          line(extension, (point.at(0) + 1.8 * dx / d, point.at(1) + 1.8 * dy / d), stroke: 0.35pt)
        }
      }
      line((a.at(0) - if outside { 6 * u.at(0) } else { 0 }, a.at(1) - if outside { 6 * u.at(1) } else { 0 }),
        (b.at(0) + if outside { 6 * u.at(0) } else { 0 }, b.at(1) + if outside { 6 * u.at(1) } else { 0 }), stroke: 0.35pt)
      for (point, direction) in ((a, if outside { -1 } else { 1 }), (b, if outside { 1 } else { -1 })) {
        let base = (point.at(0) + direction * 2.6 * u.at(0), point.at(1) + direction * 2.6 * u.at(1))
        line(point, (base.at(0) - 0.38 * u.at(1), base.at(1) + 0.38 * u.at(0)),
          (base.at(0) + 0.38 * u.at(1), base.at(1) - 0.38 * u.at(0)), close: true, fill: rgb("#000000"), stroke: none)
      }
      let middle = ((a.at(0) + b.at(0)) / 2, (a.at(1) + b.at(1)) / 2)
      let horizontal = a.at(1) == b.at(1)
      content(options.at("label", default: (middle.at(0) + if horizontal { 0 } else { -2.2 }, middle.at(1) + if horizontal { 2.2 } else { 0 })),
        label, angle: if horizontal { 0deg } else { 90deg }, padding: 0pt)
    }
  })
}
