// Native Typst paths and tiling only. Coordinates use the supplied 482 × 241
// specimen. Arc segments share analytic tangents, and bevels share vertices.
#let gb-mark(width: 40mm) = {
  let u = width / 482
  let p(x, y) = ((x - 28) * u, (y - 74) * u)
  let m(x, y) = curve.move(p(x, y))
  let l(x, y) = curve.line(p(x, y))
  let c(x1, y1, x2, y2, x, y) = curve.cubic(p(x1, y1), p(x2, y2), p(x, y))
  let z = curve.close(mode: "straight")
  let ellipse-point(cx, cy, rx, ry, angle) = (cx + rx * calc.cos(angle), cy + ry * calc.sin(angle))
  // At most 45° per cubic keeps the visible circle error below 0.001 units.
  let arc(cx, cy, rx, ry, start, end) = {
    let count = int(calc.ceil(calc.abs((end - start) / 45deg)))
    let step = (end - start) / count
    range(count).map(i => {
      let a = start + i * step
      let b = a + step
      let k = 4 / 3 * calc.tan(step / 4)
      let pa = ellipse-point(cx, cy, rx, ry, a)
      let pb = ellipse-point(cx, cy, rx, ry, b)
      c(pa.at(0) - k * rx * calc.sin(a), pa.at(1) + k * ry * calc.cos(a),
        pb.at(0) + k * rx * calc.sin(b), pb.at(1) - k * ry * calc.cos(b), ..pb)
    })
  }
  // Intersection of a shared straight bevel ray with an ellipse.
  let intersection(cx, cy, rx, ry, x, y, dx, dy) = {
    let ex = x - cx
    let ey = y - cy
    let aa = (dx / rx) * (dx / rx) + (dy / ry) * (dy / ry)
    let bb = 2 * (ex * dx / (rx * rx) + ey * dy / (ry * ry))
    let cc = (ex / rx) * (ex / rx) + (ey / ry) * (ey / ry) - 1
    let t = (-bb + calc.sqrt(bb * bb - 4 * aa * cc)) / (2 * aa)
    (x + t * dx, y + t * dy)
  }
  let angle(cx, cy, rx, ry, point) = calc.atan2((point.at(0) - cx) / rx, (point.at(1) - cy) / ry)
  let go = intersection(151, 194.5, 123, 120.5, 151, 195, -1, 1)
  let gm = intersection(151, 194, 92, 90, 151, 195, -1, 1)
  let gi = intersection(151, 195, 59, 59, 151, 195, -1, 1)
  let ga = angle(151, 194.5, 123, 120.5, go)
  let gma = angle(151, 194, 92, 90, gm)
  let bo = intersection(434, 147, 76, 73, 435, 133, 1, -1)
  let bm = intersection(435, 149.5, 44.5, 45.5, 435, 133, 1, -1)
  let ba = angle(434, 147, 76, 73, bo)
  let bma = angle(435, 149.5, 44.5, 45.5, bm)
  let bottom-cut = ellipse-point(439, 241.5, 44.5, 42.5, -40deg)
  let dots = tiling(size: (6 * u, 6 * u), relative: "parent")[
    #rect(width: 6 * u, height: 6 * u, fill: white, stroke: none)
    #place(top + left, dx: 0.2 * u, dy: 0.2 * u, circle(radius: 1.05 * u, fill: black, stroke: none))
    #place(top + left, dx: 3.2 * u, dy: 3.2 * u, circle(radius: 1.05 * u, fill: black, stroke: none))
  ]
  let face(..commands) = place(top + left, curve(fill: dots, stroke: 1.5 * u, ..commands.pos()))
  box(width: width, height: width / 2)[
    #place(top + left, curve(fill: black, stroke: none,
      m(263,74), l(151,74), ..arc(151,194.5,123,120.5,-90deg,-270deg),
      l(263,315), l(263,165), l(151,165), l(151,225), l(201,225), l(201,254), l(151,254),
      ..arc(151,195,59,59,90deg,270deg), l(263,136), z))
    #face(m(263,74), l(151,74), ..arc(151,194.5,123,120.5,-90deg,ga - 360deg),
      l(..gm), ..arc(151,194,92,90,gma,270deg), l(233,104), z)
    #face(m(..gm), l(..gi), ..arc(151,195,59,59,135deg,90deg), l(201,254),
      l(231,284), l(151,284), ..arc(151,194,92,90,90deg,gma), z)
    #face(m(231,195), l(201,225), l(201,254), l(231,284), z)
    #face(m(151,165), l(263,165), l(233,195), l(181,195), z)
    #face(m(151,165), l(181,195), l(151,225), z)

    #place(top + left, curve(fill: black, stroke: none, fill-rule: "even-odd",
      m(275,74), l(434,74), ..arc(434,147,76,73,-90deg,0deg),
      c(510,166.5,505.25,183.5,495,195), c(505.25,206.5,510,225.5,510,245),
      ..arc(439,245,71,70,0deg,90deg), l(275,315), z,
      m(336,133), l(435,133), ..arc(435,149.5,16.5,16.5,-90deg,90deg), l(336,166), z,
      m(336,225), l(435,225), ..arc(435,241.5,16.5,16.5,-90deg,90deg), l(336,258), z))
    #face(m(275,74), l(434,74), ..arc(434,147,76,73,-90deg,ba), l(..bm),
      ..arc(435,149.5,44.5,45.5,bma,-90deg), l(305,104), z)
    #face(m(275,74), l(305,104), l(305,284), l(275,315), z)
    #face(m(305,195), l(336,166), l(435,166), ..arc(435,149.5,16.5,16.5,90deg,-90deg),
      l(..bm), ..arc(435,149.5,44.5,45.5,bma,90deg), z)
    #face(m(305,284), l(336,258), l(435,258), ..arc(435,241.5,16.5,16.5,90deg,-90deg),
      c(449,225,462,219,..bottom-cut), ..arc(439,241.5,44.5,42.5,-40deg,90deg), z)
    // Draw shared seams after every patterned face. A later white pattern
    // tile must not erase part of a preceding face's edge at an intersection.
    #place(top + left, curve(fill: none, stroke: 1.5 * u,
      m(..go), l(..gi), m(..bo), l(435,133),
      m(151,165), l(181,195), l(233,195), l(263,165),
      m(231,195), l(201,225), l(201,254), l(231,284),
      m(275,74), l(305,104), l(305,284), l(275,315)))
  ]
}
