// Font families and measured physical sizes for both build profiles.
#import "font-sizes.typ": reference-sizes, reference-spacing
#let font-profile = sys.inputs.at("font-profile", default: "open")
#let latin = if font-profile == "reference" { "Times New Roman" } else { "Liberation Serif" }
#let song = if font-profile == "reference" { ((name: latin, covers: regex("[\\x20-\\x7e]")), "FZShuSong-Z01") } else { ((name: latin, covers: "latin-in-cjk"), "Source Han Serif SC") }
#let latin-bold = if font-profile == "reference" { "EU-HZ" } else { "Liberation Serif" }
#let hei = if font-profile == "reference" { ((name: "EU-FZ", covers: regex("[0-9.]")), "FZHei-B01") } else { "Source Han Sans SC" }
#let digits = hei
#let black-weight = if font-profile == "reference" { "regular" } else { "medium" }
#let display-song = if font-profile == "reference" { "FZXiaoBiaoSong-B05S" } else { "Source Han Serif SC" }
#let body-size = if font-profile == "reference" { reference-sizes.body-song } else { 10.5pt }
#let note-size = if font-profile == "reference" { reference-sizes.small-song } else { 9pt }
#let front-size = if font-profile == "reference" { reference-sizes.front-title } else { 16pt }
#let calibrated(size) = if size == 10.5pt { body-size } else if size == 9pt { note-size } else if size == 16pt { front-size } else { size }
#let body-gap = (if font-profile == "reference" { 15.875pt } else { 15.75pt }) - body-size
#let paragraph-gap = (if font-profile == "reference" { 16.325pt } else { 15.75pt }) - body-size
#let body-indent = 21pt
#let sizes = (one: 26pt, three: 16pt, four: 14pt, five: 10.5pt, small-five: 9pt, six: 7.5pt)
