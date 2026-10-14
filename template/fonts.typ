// Font families and measured physical sizes for both build profiles.
#import "font-sizes.typ": reference-sizes, reference-spacing
#let font-profile = sys.inputs.at("font-profile", default: "open")
#let latin = if font-profile == "reference" { "Times New Roman" } else { "Liberation Serif" }
#let latin-covers = regex("[\\x20-\\x7e\\p{Latin}\\p{Greek}\\p{Cyrillic}\\u00a0\\u00a9\\u00ae\\u00b2\\u00b3\\u00b9\\u2070-\\u209f\\u2122]")
#let cjk-pattern = regex("[\\p{Han}\\u3000-\\u303f\\uff00-\\uffef]+")
#let western-pattern = regex("[\\x21-\\x2d\\x2f\\x3a-\\x7e\\p{Latin}\\p{Greek}\\p{Cyrillic}\\u00a9\\u00ae\\u00b2\\u00b3\\u00b9\\u2070-\\u209f\\u2122]+")
#let numeral-pattern = regex("[0-9.]+")
#let song-family = if font-profile == "reference" { "FZShuSong-Z01" } else { "Source Han Serif SC" }
#let hei-family = if font-profile == "reference" { "FZHei-B01" } else { "Source Han Sans SC" }
#let song = ((name: latin, covers: latin-covers), song-family)
#let latin-bold = if font-profile == "reference" { "EU-HZ" } else { "Liberation Serif" }
#let bold-covers = if font-profile == "reference" { regex("[\\x20-\\x7e]") } else { latin-covers }
#let latin-bold-fonts = if font-profile == "reference" {
  ((name: latin-bold, covers: bold-covers), (name: latin, covers: latin-covers))
} else { latin-bold }
#let digit-family = if font-profile == "reference" { "EU-FZ" } else { hei-family }
// Heading numerals are sans; Western words use the companion Roman face.
#let hei = ((name: digit-family, covers: regex("[0-9.]")),
  (name: latin-bold, covers: bold-covers),
  ..if font-profile == "reference" { ((name: latin, covers: latin-covers),) } else { () }, hei-family)
#let digits = hei
#let black-weight = if font-profile == "reference" { "regular" } else { "medium" }
#let display-song = if font-profile == "reference" { "FZXiaoBiaoSong-B05S" } else { "Source Han Serif SC" }
#let body-size = if font-profile == "reference" { reference-sizes.body-song } else { 10.5pt }
#let note-size = if font-profile == "reference" { reference-sizes.small-song } else { 9pt }
#let front-size = if font-profile == "reference" { reference-sizes.front-title } else { 16pt }
#let calibrated(size) = {
  if font-profile != "reference" { size }
  else if size == 16pt { front-size }
  else if size <= 9pt { size / 9pt * note-size }
  else { size / 10.5pt * body-size }
}
#let body-gap = (if font-profile == "reference" { 15.875pt } else { 15.75pt }) - body-size
#let paragraph-gap = (if font-profile == "reference" { 16.325pt } else { 15.75pt }) - body-size
#let body-indent = 21pt
#let sizes = (one: 26pt, three: 16pt, four: 14pt, five: 10.5pt, small-five: 9pt, six: 7.5pt)

#let font-families(font) = if type(font) == array { font } else { (font,) }
#let font-name(font) = lower(if type(font) == str { font } else { font.name })
#let cjk-role(font) = {
  let names = font-families(font).map(font-name)
  if lower(hei-family) in names { "hei" }
  else if lower(song-family) in names { "song" } else { none }
}
#let cjk-calibration(size, role) = {
  if calc.abs(size - front-size) < 0.01pt {
    (size: front-size, nominal: 16pt,
      tracking: if role == "hei" { 15.5256pt - front-size }
        else { reference-spacing.body-song.tracking * (front-size / body-size) })
  } else {
    let small = size <= reference-sizes.small-hei + 0.01pt
    let key = (if small { "small-" } else { "body-" }) + role
    (size: reference-sizes.at(key), tracking: reference-spacing.at(key).tracking,
      nominal: if small { 9pt } else { 10.5pt })
  }
}
#let black-size(size) = {
  if font-profile != "reference" { size }
  else if size == front-size { size }
  else if size <= note-size + 0.01pt { size * (reference-sizes.small-hei / note-size) }
  else { size * (reference-sizes.body-hei / body-size) }
}

// Calibration applies only to the project's faces. It must preserve an
// author's tracking, custom fonts, baseline shifts and surrounding line box.
#let cjk-lettering(it) = context {
  let role = cjk-role(text.font)
  if font-profile == "reference" and role != none {
    let metrics = cjk-calibration(text.size, role)
    text(tracking: text.tracking + metrics.tracking * (text.size / metrics.size), it)
  } else { it }
}
#let western-lettering(it) = context {
  let candidates = font-families(text.font).filter(f =>
    type(f) == str or "covers" not in f or type(f.covers) != regex or
    it.text.clusters().all(c => c.match(f.covers) != none))
  let family = if candidates.len() > 0 { font-name(candidates.first()) } else { "" }
  let roman = family == lower(latin)
  let bold = family == lower(latin-bold)
  let sans = font-profile == "reference" and family == "eu-fz"
  if not (roman or bold or sans) { it }
  else if font-profile != "reference" {
    let heavy = if type(text.weight) == int { text.weight >= 500 }
      else { text.weight in ("medium", "semibold", "bold", "extrabold", "black") }
    text(font: family, weight: if heavy { "bold" } else { text.weight }, it)
  } else {
    let role = cjk-role(text.font)
    let edge(value) = if type(value) == length { value.to-absolute() } else { value }
    let top = edge(text.top-edge)
    let bottom = edge(text.bottom-edge)
    // A nested Western font can hide the surrounding CJK face. Recover its
    // logical size from our fixed line box, only when the glyph size agrees.
    let frame = if type(top) == length and type(bottom) == length { top - bottom } else { none }
    let shared-frame = (frame != none and frame > 0pt and calc.abs(top - frame * 0.88) < 0.01pt and
      (calc.abs(text.size - frame) < 0.01pt or calc.abs(text.size - black-size(frame)) < 0.01pt))
    let base = if shared-frame { frame } else { text.size }
    let metrics = cjk-calibration(base, if shared-frame or role == none { "song" } else { role })
    let key = if sans { "cover-digits" } else if bold { "body-latin-bold" } else { "body-latin" }
    let ratio = reference-sizes.at(key) / 10.5pt * metrics.nominal / metrics.size
    let rendered-size = base * ratio
    let lettering = text(font: family, size: rendered-size,
      weight: if roman and (role == "hei" or "eu-hz" in font-families(text.font).map(font-name)) { "bold" } else { text.weight },
      baseline: text.baseline.to-absolute(), top-edge: top, bottom-edge: bottom,
      tracking: text.tracking + if sans { 0pt } else { reference-spacing.at(key).tracking * (rendered-size / reference-sizes.at(key)) }, it)
    if sans { box(scale(x: reference-spacing.cover-digits.x, reflow: true, box(lettering))) } else { lettering }
  }
}
