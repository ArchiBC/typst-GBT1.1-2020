#import "../template/lib.typ": *
#let code(value) = block(inset: 8pt, stroke: 0.4pt, above: 8pt, below: 8pt)[
  #set par(first-line-indent: 0pt, justify: false)
  #show raw: set text(font: ("DejaVu Sans Mono", "Source Han Sans SC"), size: 8pt)
  #raw(value, block: true, lang: "typ")
]
#show: gbt.with(title: ([Typst 国标模板使用手册],),
  english: ([User manual for the Typst standards template],),
  draft: [模板说明], preface: [本手册说明模板接口及原书的编辑、编译与核查方法。])

= 文件与编译
模板入口为 template/lib.typ；新标准从 examples/blank.typ 开始；完整用例为 examples/standard.typ。原书的正文、表格和附录文字集中在 book/gbt-1.1-2020.typ。

运行 tools/build.py 默认构建并检查开源字体版本；--font-profile reference 构建参考字库审阅版，--font-profile both 构建两版。tools/compile.py 可编译单个文件。构建先编译 book/demos 中的独立 Typst 示例，再将生成的 PDF 片段作为矢量示例嵌入原书，并同步对应 PDF 的交付文件名。普通编译不读取原 PDF，不依赖 OCR 数据文件。

#code("python tools/build.py\npython tools/build.py --font-profile open\npython tools/verify_numbering.py")

默认 open 字体配置使用思源宋体、思源黑体、Liberation Serif 和 New Computer Modern Math。参考字库审阅版采用 reference 配置，读取另行提供的方正书宋、方正黑体、配套粗体及非衬线数字字库；常规英文和数字采用本机 Times New Roman。参考字库没有复制到分发包中。

#code("typst compile --root . --font-path fonts --ignore-system-fonts examples/standard.typ\npython tools/compile.py --font-profile reference\npython tools/compile.py --font-profile open")

参考印本的字号映射及测量证据在 docs/font-size-map.csv 和 docs/font-size-map.json。标称字号、实际墨迹字高、字形宽度及字面间距分别记录。

= 章、条与引用
有标题的章条使用 Typst 标题语法，编号和目录由原生计数器生成。无标题条以 clause 标记开头，后接普通正文。clause 默认取最近有标题层次的下一级；需要切换层次时指定 level。直接写 #raw("#clause()") 即可自动编号并生成目录条目，无需标签。

#code("= 要求 <requirements>\n== 一般要求 <general>\n#clause() <first> 无标题条正文。\n\n#clause() 另一条普通正文。\n\n参见 @general 和 @first。")

仅在正文或索引需要引用时，在条目后附原生 #raw("<标签>")，引用写为 #raw("@标签")，与普通标题和图表一致。插入、删除或移动条目后，条号、目录及引用随计数器更新。附录内自动添加字母前缀并重新计数。目录深度由 contents-depth 控制；单条设置 outlined: false 可隐藏其目录项，整份文件设置 clause-contents: false 可统一隐藏无标题条。原书按参考印本采用后一设置。

#code("#clause() 不需要引用标签的条。\n\n#clause() <first> 需要引用的条。\n\n参见 @first。\n\n#clause(outlined: false) 编号，但不列入目录的条。")

== 实际示例
#clause() <manual-first> 本条由计数器产生编号。

#clause() 引用上一条：#[@manual-first]。

= 列项
有序列项使用加号，无序列项使用减号；缩进表示嵌套。模板将一级有序列项排为 a）、b）等，二级排为 1）、2）等；无序列项一级为破折号，二级为居中圆点。

#code("+ 第一项；\n+ 第二项：\n  + 子项一；\n  + 子项二。\n\n- 一级无序项：\n  - 二级第一项；\n  - 二级第二项。")

+ 第一项；
+ 第二项：
  + 子项一；
  + 子项二。

- 一级无序项：
  - 二级第一项；
  - 二级第二项。

= 术语、注与示例
term 的三个位置参数为中文术语、英文对应词、定义。编号自动占用当前层次的下一级；需要引用时，将原生标签附在调用之后。source 是外部来源文字；notes、examples 是内容数组。

#code("#term([标准], [standard], [术语定义。]) <term-standard>\n#term([基础标准], [basic standard],\n  [具有广泛适用范围的标准（#[@term-standard]）。])")

#term([标准], [standard], [术语组件示例。]) <manual-term>
#term([相关概念], [related concept], [引用标准（#[@manual-term]）。])

note、example 分别编排注与示例；framed: true 设置示例边框。需要示出真实排版时，先编译一个使用同一模板的 demo.typ，再嵌入其生成 PDF。

#code("#note[补充说明。]\n#example(number: 1)[文字示例。]\n#example(framed: true)[框内示例。]")

#note[注的标识与正文分别采用黑体和宋体。]
#example(framed: true)[真实 Typst 文字、公式 $v=L/t$ 与原生图形均可编排在线框内。]

= 图、表与公式
gbt-table 接收列宽、表头、内容、单位、注和脚注。表编号与表题自动生成；长表跨页时重复表题及表头，续页显示“（续）”。原生 table.cell 的 rowspan 和 colspan 可用于合并单元格。

#code("#gbt-table([测量结果], columns: (1fr, 1fr, 1fr),\n  header-rows: (\n    (table.cell(rowspan: 2)[项目], table.cell(colspan: 2)[测量结果]),\n    ([第一次], [第二次]),\n  ), rows: (([温度], [21.0], [21.2]),)) <results>\n参见 @results。")

#gbt-table([测量结果], columns: (1fr, 1fr, 1fr),
  header-rows: ((table.cell(rowspan: 2, align: center + horizon)[项目], table.cell(colspan: 2, align: center + horizon)[测量结果]), ([第一次], [第二次])),
  rows: (([温度], [21.0], [21.2]),)) <manual-results>

gbt-figure 接收图形内容、图题、单位、注和脚注；引用写作 #raw("@label")。gbt-equation 排列公式、编号和符号解释。公式同样使用原生标签，插入公式后引用编号自动更新；附录中的公式编号自动添加字母前缀。

#gbt-equation($v=L/t$, definitions: (($v$, [速度；]), ($L$, [长度；]), ($t$, [时间。]))) <manual-equation>

参见 @manual-equation。

#code("#gbt-equation($v=L/t$) <speed>\n参见 @speed。")

= 双面分页、附录与索引
two-sided: true 时，目次、前言、引言、正文首页、附录和文后要素按正面起页，书眉及页码随正反页镜像排列。new-page 默认自动跳到正面；side: "even" 可指定背面。

#code("#new-page()\n#new-page(side: \"even\")\n#annex(\"A\", [附录名称])[\n= 一般规定\n#clause() 无标题条正文。\n]")

index-mark 在正文中建立关键词索引目标，keyword-index 自动按拼音首字母分组、排序和分栏。引用的章条号来自当前位置的计数器。

#code("标准化文件#index-mark(\"标准化文件\")。\n#keyword-index(columns: 2)")

= 原书逐页核查
源 PDF 的正文经渲染后 OCR 转录；损坏文本层没有用于读取标准内容。作者可直接修改完整主源文件重新编译。源文件保留人工校订的正文和真实示例；历史 OCR 与扫描中间稿不参与公开仓库构建。

tools/render_outputs.py 渲染交付 PDF。docs/review 保存前一轮 72 页人工核查的记录，记录绑定当时的 PDF 与源码哈希；后续编译检查另记于 output/verification.json。自动检查不能代替原文逐页核查。

tools/verify_numbering.py 在插入术语和无标题条前后实际编译，检查编号及打印引用，同时检查原书章条计数器。tools/verify.py 检查字体嵌入、页面边界、目录、图表引用、附录编号和长表续排。

= 条文说明
explain 写在正文之后，默认关联最近的编号章条；仅记录说明，不在正文中排出。文后调用一次 explanations，按正文层次生成说明部分，使用原条款的编号和引用目标。无需标签的条同样可以附说明；附录说明保留字母前缀。

#code("= 总则\n#clause() <purpose> 为规定基本要求，制定本规范。\n#explain[本条说明制定目的。]\n\n#clause() 适用范围正文。\n#explain[无需标签也可以附说明。]\n\n#explanations(contents: true)")

合并多条说明用 of 和 through 指定首尾原生标签，连接符由 separator 控制。说明内部的段落、列项、图表及公式按正常内容排版，不会强制压成一个段落；长说明可以跨页。说明中的原生引用仍指向正文，不会因说明标题重复出现而改变目标。

#code("#explain(of: <first>, through: <last>)[多条合并说明。]\n#explain(of: <first>, through: <last>, separator: \"、\")[两条说明。]")

explanations 的 title、intro、front-matter、end-matter 控制标题与前后置内容；contents 控制独立说明目录，outlined 控制 PDF 大纲。page-break、side 和 chapter-break 控制说明起页及章节换页。正文目录自动排除说明标题。

heading-renderer 接收原生说明标题；entry-renderer 接收说明字典，含 number、body、source、target、through、ancestors、annex 等字段。body-renderer 接收整份已解析的说明字典数组，用于特殊出版版式。自定义整体渲染时可用 explanation-entry-marker 保留说明目标元数据。source 默认 before，仅汇编调用位置之前的说明；显式 page 容器的整书出版布局可用 document 查询整份文档。

= 工程规范与版式扩展
construction-standard 与 gbt 使用同一套章条、引用和说明机制，工程规范配置采用 135 mm × 203 mm 开本、宋体正文、无书眉、数字列项。无节标题的章自动生成 1.0.1 式编号；有节标题时生成 2.1.1 式编号。正文与说明可分别设置目录和前置内容。

#code("#show: construction-standard.with(\n  title: ([某工程建设规范],), serial: \"XXXXX\", year: \"2026\",\n  back-matter: [#explanations(\n    heading-renderer: construction-explanation-heading,\n    entry-renderer: construction-explanation-entry)],\n)")

page-layout、text-style、paragraph-style、list-style 和 enum-style 分别接收原生 page、text、par、list、enum 的设置字典。工程规范配置逐项合并，覆盖一个属性不会丢失其他默认值。page-layout 控制内页，改变封面开本时需同时提供自定义封面。

#code("#show: construction-standard.with(\n  page-layout: (width: 160mm, height: 240mm),\n  text-style: (size: 12pt),\n  renderers: (heading: construction-heading.with(chapter-break: false)),\n)")

renderers 当前支持 cover、heading、strong：自定义封面接收标准信息字典，标题接收原生 heading，强调接收原生 strong。标题计数器及说明关联仍由模板管理。front-matter 和 back-matter 可插入扉页、公告、术语和条文说明等内容；普通新文档从 examples/construction-standard.typ 开始。

GB 55031—2022 样书的内容位于 book/gb55031-content.typ，只写章节、完整段落、列项、表格单元格、图示及紧随正文的说明。book/gb55031-2022.typ 是编译入口；字体、字距、分页、表格样式及原书的行位全部位于 template 中。参考版共 76 页，无出版信息、版权页或末页封底，保留正文及说明的印刷页码。

#code("// 内容文件\n#import \"../template/content.typ\": article as clause, commentary as explain\n= 总则\n#clause[为规定基本要求，制定本规范。]\n#explain[本条说明制定目的。]\n\n// 编译入口\n#import \"../template/construction-document.typ\": construction-document\n#show: construction-document.with(info: (title: ([某规范],),))\n#include \"content.typ\"")

template/construction-document.typ 根据内容结构自动生成章条、表格、图示及文后的说明。版式配置可分别覆盖 page-layout、text-style、paragraph-style、renderers；content-renderers 的 table 和 figure 函数可替换表格及图示的排版。examples/construction-content.typ 是独立内容示例，examples/construction-standard.typ 仅负责选择模板。

template/editions/gb55031 管理这一本样书的参考版式。默认 auto 模式在内容与基准一致时保持原书逐页位置；修改或新增内容后改为自动分行、分页，不使用旧行位截断文字。book/gb55031-flow.typ 始终使用自动排版。也可通过 --input gb55031-mode=flow 指定自动模式；reference 模式在内容改变时拒绝使用旧行位。

工程规范的字体配置与国标字体配置独立。Python 构建在本机字体齐全时使用宋体、黑体和 Times New Roman；无本机字体时改用思源宋体、思源黑体和 Liberation Serif。tools/build.py 和 tools/compile.py 的 --construction-font-profile open 参数可强制使用开源配置，windows 参数要求本机字体齐全。移机重编使用开源字体，不包含本机参考字体的字体文件。

tools/verify_explanations.py 检查插入、移动后的说明关联和引用、合并说明、附录、长说明跨页、七章编号、局部版式覆盖以及完整复刻的页数、开本、横排续表、每条正文和说明条号。逐页文字与图像来源见 docs/gb55031-transcription.json，核查说明见 docs/gb55031-review.md。
