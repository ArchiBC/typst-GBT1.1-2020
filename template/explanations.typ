// Explanations stay next to their clauses in the source and are collected later.
// Store native locations, never a second set of manually maintained numbers.
#let explanation-mode = state("gbt-explanation-mode", false)

#let explain(body, of: auto, through: none, separator: "～", before: none, after: none) = context {
  assert(not explanation-mode.get(), message: "条文说明中不能嵌套 explain。")
  let origin = here()
  // The contextual helper's value is resolved here so the stored locations
  // remain those of the original body, even after an explanation is rendered.
  let find(target) = {
    if target == auto {
      let preceding = query(selector(heading).before(origin)).filter(it => it.numbering != none)
      assert(preceding.len() > 0, message: "条文说明前应有编号章条，或用 of 指定目标标签。")
      preceding.last()
    } else {
      assert(type(target) == label, message: "说明目标应为原生标签或 auto。")
      let matches = query(target)
      assert(matches.len() == 1, message: "条文说明目标标签应唯一：" + str(target))
      let found = matches.first()
      if found.func() == heading { found }
      else {
        let bindings = query(metadata).filter(it => type(it.value) == dictionary and
          it.value.at("kind", default: none) == "gbt-native-target" and it.value.source == found.location())
        assert(bindings.len() == 1, message: "说明目标应为章、条或术语：" + str(target))
        query(bindings.first().value.target).first()
      }
    }
  }
  let target = find(of)
  let end = if through == none { none } else { find(through) }
  assert(target.numbering != none, message: "说明目标必须有编号。")
  if end != none {
    assert(end.numbering != none and end.level == target.level,
      message: "合并说明的起止目标应为同层级编号章条。")
    let first-position = target.location().position()
    let last-position = end.location().position()
    assert(first-position.page < last-position.page or
      (first-position.page == last-position.page and first-position.y <= last-position.y),
      message: "合并说明的末条不得位于首条之前。")
  }
  let numbers = counter(heading).at(target.location())
  let annex = state("gbt-annex", none).at(target.location())
  let preceding = query(selector(heading).before(target.location())).filter(it => it.numbering != none)
  let ancestors = ()
  for level in range(1, target.level) {
    let candidates = preceding.filter(it => it.level == level and
      state("gbt-annex", none).at(it.location()) == annex and
      counter(heading).at(it.location()).slice(0, level) == numbers.slice(0, level))
    if candidates.len() > 0 { ancestors.push(candidates.last().location()) }
  }
  metadata((kind: "gbt-explanation", target: target.location(),
    through: if end == none { none } else { end.location() }, ancestors: ancestors,
    annex: annex, annex-title: state("gbt-annex-title", none).at(target.location()),
    body: body, separator: separator, before: before, after: after))
}

#let explanation-number(location) = context {
  let target = query(location).first()
  numbering(target.numbering, ..counter(heading).at(location))
}

#let explanation-entry-marker(entry) = context metadata((kind: "gbt-explanation-entry",
  target: entry.target, number: entry.number, source-page: entry.target.page()))

#let explanations(
  title: [条文说明], intro: none, front-matter: none, end-matter: none,
  contents: false, contents-title: [目次], outlined: true,
  page-break: true, side: auto, chapter-break: false,
  heading-renderer: none, entry-renderer: none, contents-renderer: none, body-renderer: none,
  source: "before",
) = context {
  let origin = here()
  assert(source in ("before", "document"), message: "说明查询范围应为 before 或 document。")
  let records = query(if source == "document" { metadata } else { selector(metadata).before(origin) }).filter(it =>
    type(it.value) == dictionary and it.value.at("kind", default: none) == "gbt-explanation")
  assert(records.len() > 0, message: "没有可汇编的条文说明；先在正文后写 explain。")
  let saved-heading = counter(heading).get()
  let saved-figures = (
    counter(figure.where(kind: table)).get(), counter(figure.where(kind: image)).get(),
    counter(figure.where(kind: math.equation)).get(),
  )
  let two-sided = state("gbt-two-sided", true).get()
  let target-side = if side == auto { if two-sided { "odd" } else { none } } else { side }
  assert(target-side in (none, "odd", "even"), message: "说明起页应为 auto、none、odd 或 even。")
  if page-break { pagebreak(to: target-side, weak: true) }
  explanation-mode.update(true)

  // Unnumbered explanation headings have their own supplement and outline
  // target. They never participate in the body's contents or numbering.
  show heading: it => {
    // A heading's supplement can be resolved to content. A string-only
    // selector misses it and lets the normal heading style take over.
    if it.supplement == "gbt-explanation-heading" or it.supplement == [gbt-explanation-heading] {
      if heading-renderer != none { heading-renderer(it) }
      else { block(above: 1.5em, below: 1em, sticky: true, text(weight: "bold", it.body)) }
    } else { it }
  }
  if front-matter != none { front-matter }
  if title != none {
    heading(level: 1, numbering: none, outlined: outlined,
      supplement: "gbt-explanation-heading", title)
  }
  let groups = records.map(it => it.value.ancestors).flatten().dedup()
  if contents {
    if contents-renderer != none { contents-renderer(groups) }
    else {
      block(above: 1em, below: 1em, text(weight: "bold", contents-title))
      for location in groups {
        let source = query(location).first()
        let entries = query(metadata).filter(it => type(it.value) == dictionary and
          it.value.at("kind", default: none) == "gbt-explanation-group" and it.value.source == location)
        if entries.len() > 0 {
          let entry = entries.first()
          let folio = counter(page).at(entry.location()).first()
          block(pad(left: (source.level - 1) * 1em,
            link(entry.location())[#explanation-number(location)#h(1em)#source.body#h(1fr)#folio]))
        }
      }
      pagebreak(to: target-side)
    }
  }
  if intro != none { intro }
  let resolved = records.map(item => {
    let record = item.value
    let target = query(record.target).first()
    let first-number = numbering(target.numbering, ..counter(heading).at(record.target))
    let printed = if record.through == none { first-number } else {
      let last = query(record.through).first()
      first-number + record.separator + numbering(last.numbering, ..counter(heading).at(record.through))
    }
    record + (number: printed, source: record.target)
  })
  let previous = ()
  let previous-annex = none
  if body-renderer != none { body-renderer(resolved) }
  else { for record in resolved {
    if record.before != none { record.before }
    if record.annex != previous-annex {
      if record.annex != none {
        heading(level: 1, numbering: none, outlined: outlined,
          supplement: "gbt-explanation-heading",
          [附录#h(0.5em)#record.annex#h(1em)#record.annex-title.title])
      }
      previous = ()
      previous-annex = record.annex
    }
    for (index, location) in record.ancestors.enumerate() {
      if index >= previous.len() or previous.at(index) != location {
        let source = query(location).first()
        if chapter-break and source.level == 1 { pagebreak(to: target-side, weak: true) }
        metadata((kind: "gbt-explanation-group", source: location))
        heading(level: source.level, numbering: none, outlined: outlined,
          supplement: "gbt-explanation-heading",
          [#explanation-number(location)#h(1em)#source.body])
      }
    }
    previous = record.ancestors
    parbreak()
    explanation-entry-marker(record)
    if entry-renderer != none { entry-renderer(record) }
    else {
      // An inline prefix allows long explanations to flow across pages.
      block(above: 0pt, below: 0pt, breakable: true)[
        #set par(first-line-indent: 0pt)
        #link(record.target, text(weight: "bold", record.number))#h(1em)#record.body
      ]
    }
    parbreak()
    if record.after != none { record.after }
  } }
  if end-matter != none { end-matter }
  counter(heading).update(saved-heading)
  counter(figure.where(kind: table)).update(saved-figures.at(0))
  counter(figure.where(kind: image)).update(saved-figures.at(1))
  counter(figure.where(kind: math.equation)).update(saved-figures.at(2))
  explanation-mode.update(false)
}
