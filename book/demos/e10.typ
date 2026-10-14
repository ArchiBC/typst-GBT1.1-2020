#import "../specimens.typ": specimen-page, specimen-title, specimen-at, specimen-text, specimen-row
#specimen-page()[
  #specimen-title([参#h(0.5em)考#h(0.5em)文#h(0.5em)献], size: 10.5pt)
  #let y = 54.5
  #for (i, count) in (38, 77, 34, 93, 57).enumerate() {
    specimen-at(33, y, specimen-text("[" + str(i + 1) + "]"))
    let first = calc.min(count, 40)
    specimen-row(first, 41, y)
    count -= first
    y += 4.35
    while count > 0 {
      let row = calc.min(count, 44)
      specimen-row(row, 25.5, y)
      count -= row
      y += 4.35
    }
  }
]
