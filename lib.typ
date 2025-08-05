//字体在此网站下载 https://www.webfontfree.com/cn/download/
#let GBT11(
  author: "起草人",
  cover: true,
  ICS: "01.120",
  CCS: "A 00",
  category: "GB",
  category-cn: "中华人民共和国国家标准",
  standard-number: "GB/T 1.1-2020",
  standard-number-cover: "GB/T 1.1-2009",
  title: "标准化工作导则",
  title-part: "第1部分:标准化文件的结构和起草规则",
  title-en: "Directives for standardization",
  title-part-en: "Part 1:Rules for the structure and drafting of standardizing documents",
  label_info: [(ISO/IEC Directives,Part 2,2018,Principles and rules \ for the structure and drafting of ISO and IEC documents,NEQ) \ \ \ (ArchiBC 封面临摹)],
  date-release: "2020-03-31",
  date-implement: "2020-10-01",
  departments: ("国家市场监督管理总局", "国家标准化管理委员会"),
) = {
  set document(title: title, author: author)
  set text(lang: "zh")
  if cover {
    set page(
      margin: (top: 10mm, right: 15mm, bottom: 40mm, left: 25mm),
      background: [
        //#image("backgroud\GBT11_1.svg", width: 100%)
        //标准类别标识
        #let category_place(body) = place(right + top, dx: -27mm, dy: 13mm, body)
        #if category == "GB" {
          category_place[
            #image(width: 40mm, height: 20mm, "logo/GB_Logo_SVG.svg")
          ]
        }
        #if category != "GB" {
          if category.starts-with("DB") {
            category_place[
              #text(font: "Our 8bit childhood", weight: 900, size: 20mm, "DB")
              #text(font: "FZHei-B01", weight: 900, tracking: 0.2em, size: 20mm, h(0.2em) + category.slice(2))
            ]
          } else if category.starts-with("T/") {
            category_place[
              #text(font: "Our 8bit childhood", weight: 900, size: 20mm, "T/")
              #text(font: "FZHei-B01", weight: 900, size: 20mm, category.slice(2))
            ]
          } else if category.starts-with("Q/") {
            category_place[
              #text(font: "FZHei-B01", weight: 900, size: 20mm, category)
            ]
          } else {
            category_place[
              #text(font: "FZHei-B01", weight: 900, size: 20mm, category)
            ]
          }
        }
      ],
    )

    // ICS号
    if ICS != none and ICS.len() != 0 {
      place(dx: 0.1mm, dy: -1.44mm)[
        #text(
          font: (
            (name: "EU-F1", covers: regex("[0-9]")),
            (name: "EU-BZ", covers: regex("\.")),
            "EU-HZ",
          ),
          size: 3.35mm,
          spacing: 1.8mm,
        )[ICS ]
        #text(
          font: (
            (name: "EU-F1", covers: regex("[0-9]")),
            (name: "EU-BZ", covers: regex("\.")),
            "EU-HZ",
          ),
          size: 3.35mm,
          tracking: 0.2mm,
        )[#ICS]
      ]
    }

    // CCS号
    if CCS != none and CCS.len() != 0 {
      place(dx: 0mm, dy: 2.5mm)[
        #text(
          font: (
            (name: "EU-F1", covers: regex("[0-9]")),
            (name: "EU-BZ", covers: regex("\.")),
            "EU-HZ",
          ),
          size: 3.35mm,
          tracking: -0.25pt,
          spacing: 2mm,
        )[CCS ]
        #text(
          font: (
            (name: "EU-F1", covers: regex("[0-9]")),
            (name: "EU-BZ", covers: regex("\.")),
            "EU-HZ",
          ),
          size: 3.35mm,
          spacing: 2mm,
        )[#CCS]
      ]
    }

    //分散对齐
    let distr(s, w: auto) = {
      block(
        width: w - 7pt,
        stack(
          dir: ltr,
          ..s.clusters().map(x => scale(x: 135%)[#x]).intersperse(1fr),
        ),
      )
    }
    //标准类别
    place(center + top, dy: 31.4mm)[
      #if category == "GB" {
        set text(font: "FZXiaoBiaoSong-B05S", size: 9mm)
        distr("中华人民共和国国家标准", w: 100%)
      }
      #if category != "GB" {
        set text(font: "FZHei-B01", size: 23pt, weight: 500)
        distr(category-cn, w: 100%)
      }
    ]

    //上划线
    place(top, dy: 65mm)[#line(length: 100%)]

    //推荐标准编号模板
    let numbertext_t(t) = {
      text(
        font: (
          (name: "EU-F1", covers: regex("[0-9]")),
          (name: "EU-BZ", covers: regex("\.")),
          "EU-HZ",
        ),
        size: 13pt,
        spacing: 0mm,
        tracking: 0.2mm,
      )[#t.split("/").first()
        #math.slash.big
        #t.split("/").last().split(" ").first()
        #h(2.4mm)
        #t.split(" ").last().split("-").first()
        #box(width: 4.6mm, height: 1.5mm, line(start: (100%, 0pt), length: 100%))
        #t.split("-").last()
      ]
    }

    //其他标准编号模板
    let numbertext(t) = {
      text(
        font: (
          (name: "EU-F1", covers: regex("[0-9]")),
          (name: "EU-BZ", covers: regex("\.")),
          "EU-HZ",
        ),
        size: 13pt,
        spacing: 0mm,
        tracking: 0.2mm,
      )[#t.split(" ").first()
        #h(2.4mm)
        #t.split(" ").last().split("-").first()
        #box(width: 4.6mm, height: 1.5mm, line(start: (100%, 0pt), length: 100%))
        #t.split("-").last()
      ]
    }

    // 标准编号
    place(right + top, dy: 45.75mm, dx: -5mm)[
      #if standard-number != none and standard-number.len() != 0 {
        if standard-number.contains("/") {
          numbertext_t(standard-number)
        } else {
          numbertext(standard-number)
        }
      }
    ]

    //代替推荐标准编号模板
    let numbertext_t(t) = {
      text(
        font: (
          (name: "EU-F1", covers: regex("[0-9]")),
          (name: "EU-BZ", covers: regex("\.")),
          "EU-HZ",
        ),
        size: 9.5pt,
        spacing: 0mm,
        tracking: 0.2mm,
      )[#t.split("/").first()
        #math.slash.big
        #t.split("/").last().split(" ").first()
        #h(1.25mm)
        #t.split(" ").last().split("-").first()
        #box(width: 3.3mm, height: 1.2mm, line(start: (100%, 0pt), length: 100%))
        #t.split("-").last()
      ]
    }

    //代替其他标准编号模板
    let numbertext(t) = {
      text(
        font: (
          (name: "EU-F1", covers: regex("[0-9]")),
          (name: "EU-BZ", covers: regex("\.")),
          "EU-HZ",
        ),
        size: 9.5pt,
        spacing: 0mm,
        tracking: 0.2mm,
      )[#t.split(" ").first()
        #h(2.4mm)
        #t.split(" ").last().split("-").first()
        #box(width: 4.6mm, height: 1.5mm, line(start: (100%, 0pt), length: 100%))
        #t.split("-").last()
      ]
    }

    // 替代编号
    place(right + top, dy: 53.5mm, dx: -5mm)[
      #if standard-number-cover != none and standard-number-cover.len() != 0 {
        text(font: "FZHei-B01", size: 10pt)[代替]
        if standard-number-cover.contains("/") {
          numbertext_t(standard-number-cover)
        } else {
          numbertext(standard-number-cover)
        }
      }
    ]

    //标准名称
    set align(center + top)
    v(104.6mm)
    set par(spacing: 2mm, leading: 2mm)
    set text(
      font: (
        (name: "EU-F1", covers: regex("[0-9]")),
        (name: "EU-BZ", covers: regex("\.")),
        "FZHei-B01",
      ),
      size: 26pt,
      tracking: 0.5mm,
    )
    //中文名
    if title != none and title.len() != 0 {
      title
    }
    parbreak()

    //部分名
    if title-part != none and title-part.len() != 0 {
      title-part.split(":").first()
      h(1.2mm)
      text(font: "FZShuSong-Z01", size: 1.2em)[#math.colon]
      h(1.2mm)
      title-part.split(":").last()
    }

    set par(spacing: 0.76mm, leading: 1mm)

    set text(
      font: (
        (name: "EU-F1", covers: regex("[0-9]")),
        (name: "EU-BZ", covers: regex("\p{P}")),
        "EU-HZ",
      ),
      size: 13pt,
      tracking: 0mm,
      spacing: 2.1mm,
    )

    v(6.7mm)
    //英文名
    if title-en != none and title-en.len() != 0 {
      title-en
    }
    //英文部分名
    if title-part-en != none and title-part-en.len() != 0 {
      h(-2.2mm)
      box(width: 4.6mm, height: 1.4mm, line(start: (100%, 0pt), length: 100%))
      parbreak()
      title-part-en.split(":").first()
      h(0.8mm)
      math.colon
      h(0.8mm)
      title-part-en.split(":").last()
    }

    {
      show regex("\b[a-zA-Z]\w+\b"): set text(
        font: "EU-HZ",
        lang: "en",
      )
      show regex("\p{P}"): it => [
        #set text(
          font: "EU-BZ",
          lang: "en",
          size: 13pt,
          baseline: -0.1em,
        )
        #h(-0.2em)
        #it
        #h(-0.2em)
      ]
      show regex("/"): it => [
        #h(-0.3em)
        #math.slash.big
        #h(-0.3em)
      ]

      set text(
        font: (
          "FZHei-B01",
        ),
        size: 13pt,
        tracking: 0.1mm,
        spacing: 1.7mm,
      )

      //其他信息
      v(12mm)
      label_info
    }

    // 发布时间
    place(left + bottom, dy: -1.8mm, dx: 0mm)[
      #if date-release != none and date-release.len() != 0 {
        text(
          font: (
            (name: "EU-F1", covers: regex("[0-9]")),
            "FZHei-B01",
          ),
          size: 13pt,
          spacing: 0mm,
          tracking: 0.2mm,
        )[
          #date-release.split("-").at(0)
          #let scalen = -1.5mm
          #h(scalen)
          #box(scale(x: 30%, math.dash.em))
          #h(scalen)
          #date-release.split("-").at(1)
          #h(scalen)
          #box(scale(x: 30%, math.dash.em))
          #h(scalen)
          #date-release.split("-").at(2)
          #h(1.4mm)
          发布]
      }
    ]

    // 实施时间
    place(right + bottom, dy: -1.8mm, dx: 0mm)[
      #if date-implement != none or anddate-implement.len() != 0 {
        text(
          font: (
            (name: "EU-F1", covers: regex("[0-9]")),
            "FZHei-B01",
          ),
          size: 13pt,
          spacing: 0mm,
          tracking: 0.2mm,
        )[
          #date-implement.split("-").at(0)
          #let scalen = -1.5mm
          #h(scalen)
          #box(scale(x: 30%, math.dash.em))
          #h(scalen)
          #date-implement.split("-").at(1)
          #h(scalen)
          #box(scale(x: 30%, math.dash.em))
          #h(scalen)
          #date-implement.split("-").at(2)
          #h(1.4mm)
          实施]
      }
    ]

    // 下划线
    place(bottom)[#line(length: 100%)]

    // 发布机构
    set text(font: "FZXiaoBiaoSong-B05S", size: 16.5pt, tracking: 0.95mm)
    set par(spacing: 1.3mm, leading: 1.3mm)
    if type(departments) == str {
      place(bottom + center, dy: 12.5mm + 0.5 * 16.5pt, {
        box(departments)
        h(5mm)
        text(font: "FZHei-B01", size: 13.5pt, baseline: 2mm - 0.5 * 16.5pt)[发#h(3mm)布]
      })
    } else {
      place(bottom + center, dy: 12.5mm + departments.len() * 0.5 * 16.5pt, {
        box(
          for value in departments {
            value
            parbreak()
          },
        )
        h(5mm)
        text(font: "FZHei-B01", size: 13.5pt, baseline: 2mm - departments.len() * 0.5 * 16.5pt)[发#h(3mm)布]
      })
    }
    pagebreak(weak: true)
  }
}

#GBT11()
