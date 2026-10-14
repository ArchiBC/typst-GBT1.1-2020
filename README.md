# Typst 国标、工程建设规范模板与样书

可复用的国标写作模板，以及 GB/T 1.1—2020 的完整、可编辑 Typst 转录样书。封面、正文、章条、术语、图表、公式、附录、目次和索引由模板统一排版。GB 标志使用 Typst 原生曲线与网点绘制。

当前版本：**0.2.0**。正文与格式分离，条文说明在源码中紧跟条文，编译时汇编到文后。

新增工程建设规范版式与条文说明：说明紧跟对应正文编写，编译时自动汇编到文后，保持原条号。GB 55031—2022 样书依据用户提供的 78 页印本编排；删除版权页、出版发行文字及末页封底，现为 76 页，包含前置页、正文、起草说明、术语及横排续表。

## 下载 PDF

| 文件 | 内容 |
| --- | --- |
| [开源字体版样书](output/pdf/gbt-1.1-2020-open-fonts.pdf) | 思源宋体、思源黑体、Liberation Serif；可直接从本仓库重编 |
| [方正字体审阅版样书](output/pdf/gbt-1.1-2020-replica.pdf) | 方正书宋、方正黑体、小标宋及参考字库；重编需自行提供相应字体 |
| [完整组件示例](output/pdf/standard-example.pdf) | 编号、引用、术语、合并单元格、续表、双面分页和自动索引 |
| [使用手册](output/pdf/template-manual.pdf) | 模板接口与写作方法 |
| [GB 55031—2022 逐页复刻版](output/pdf/gb55031-2022-replica.pdf) | 76 页；142 条正文与 124 组说明关联编写，保留原印刷页码，无版权页或封底 |
| [工程规范与条文说明示例](output/pdf/construction-standard-example.pdf) | 32 开本、数字列项、无节标题章与说明自动汇编 |

两版样书均由同一个 [book/gbt-1.1-2020.typ](book/gbt-1.1-2020.typ) 编译，全文和表格按行文顺序集中在该文件。当前样书各 79 页；原书 72 页，双面正面起页、自动续表和索引重排会改变分页。

## 从干净目录编译

需要 Python 3.11 或更高版本。Python 编译器及依赖固定在 [tools/requirements.txt](tools/requirements.txt)，已经用 Typst 0.15.0 验证。

```sh
python -m pip install -r tools/requirements.txt
python tools/bootstrap.py
python tools/build.py
```

`bootstrap.py` 从官方固定版本下载 9 个开源字体，按大小和 SHA-256 校验；字体二进制不放入 Git，许可和下载清单在 [fonts/](fonts/)。已有完整字体会直接复用，下载中断或校验失败不会被当作成功。

`build.py` 默认构建开源版：先重编 32 个独立示例，再编译完整样书、组件示例和手册，随后检查字体嵌入、文字边界、编号、引用、续表、合并单元格和表 F.1。结果写入 `output/build.json` 和 `output/verification.json`。构建无需原扫描 PDF、OCR 数据或系统中文字体。

工程规范独立选择字体配置：本机具备宋体、黑体和 Times New Roman 时，Python 构建使用这些字体以接近印本；没有这些字体时使用仓库的开源字体。可用 `python tools/build.py --construction-font-profile open` 固定为开源配置，或单独编译时给 `tools/compile.py` 传同名参数。参考字体只在本机读取并嵌入 PDF，不打包字体文件。

Windows 也可使用：

```powershell
powershell -ExecutionPolicy Bypass -File tools/setup.ps1
powershell -ExecutionPolicy Bypass -File tools/build.ps1
```

已经安装 Typst CLI 和项目字体时，可单独编译新标准：

```sh
typst compile --root . --font-path fonts --ignore-system-fonts examples/blank.typ output/pdf/my-standard.pdf
```

直接编译完整样书会使用现有 `book/demo-pdf/`。切换字体配置应使用 `build.py`，让内嵌示例与整本书使用同一套字体。

## 写新标准

从 [examples/blank.typ](examples/blank.typ) 开始；[examples/standard.typ](examples/standard.typ) 展示完整组件。模板入口是 [template/lib.typ](template/lib.typ)，根目录 [lib.typ](lib.typ) 也导出同一套接口。

```typst
#import "../template/lib.typ": *
#show: gbt.with(title: ([标准名称],), serial: "XXXXX", year: "2026")

= 要求 <requirements>
== 一般要求 <general>

#clause() <first>
产品应满足规定的条件。

#clause()
另一条正文；不加标签也会自动编号和编目。

参见 @general 和 @first。

+ 第一项；
+ 第二项：
  - 子项一；
  - 子项二。
```

有标题章条使用原生 `= / == / ===`，列项使用 `+ / -`；`clause()` 标记无标题条的起点，正文正常书写。术语 `term()` 和无标题条共用标题计数器，自动编号和编目无需标签。仅在正文或索引需要引用时追加原生 `<标签>`，用 `@标签` 读取目标当前位置的编号，与普通标题和图表的写法一致。

`gbt-table` 支持 `table.cell(rowspan: ..., colspan: ...)`；长表重复表题、表头、单位及“（续）”，注和脚注排在末页。图表和公式使用原生标签引用。附录重置条款、术语、图表和公式编号。

`new-page()` 自动跳到正面，`new-page(side: "even")` 跳到背面。`index-mark` 读取当前位置的章条号，`keyword-index(columns: 2)` 自动按拼音排序、字母分组和分栏。更多写法见 [手册源码](book/manual.typ)。

## 条文说明与工程规范

`explain` 写在一条正文之后，默认关联最近的编号章条，正文中不显示说明；文后调用一次 `explanations`，或在模板的 `back-matter` 中调用，即可按原章节汇编。无标签条也可关联说明。只有需要引用或合并多条说明时才使用原生标签。

```typst
#import "../template/lib.typ": *
#show: construction-standard.with(
  title: ([某工程建设规范],), serial: "XXXXX", year: "2026",
  back-matter: [#explanations(heading-renderer: construction-explanation-heading,
    entry-renderer: construction-explanation-entry)],
)

= 总则
#clause() <purpose> 为规定基本要求，制定本规范。
#explain[本条说明规范制定的目的。]

#clause() 本规范适用于有关工程。
#explain[说明直接跟随正文维护，不需要另抄条号。]
```

合并说明写作 `#explain(of: <first>, through: <last>)[说明内容。]`，默认连接符为“～”，可设置 `separator: "、"`。说明的段落、列项、表格和插图保持原有结构，长说明可跨页；正文目录不会混入说明标题，说明可单独生成目录。

`construction-standard` 采用 135 mm × 203 mm 开本、宋体正文、数字列项和工程规范章条样式。没有节标题的章自动从“1.0.1”编号；有节标题时为“2.1.1”。

**写内容请打开 [gb55031-content.typ](book/gb55031-content.typ)**。该文件只含章节、完整段落、列项、表格单元格、图示与紧随条文的说明。字体、字号、字距、表格样式、分页与页码全部由模板控制。

| 文件 | 职责 |
| --- | --- |
| [样书内容](book/gb55031-content.typ) | 编辑正文和说明，不写排版参数 |
| [样书编译入口](book/gb55031-2022.typ) | 选择模板并载入内容 |
| [逐页参考模板](template/editions/gb55031/template.typ) | 管理原书行位、目录和印刷页码；数值布局数据也在该目录 |
| [自动排版入口](book/gb55031-flow.typ) | 同一份内容按模板自动分行、分页 |
| [通用工程规范模板](template/construction-document.typ) | 自动章条、表格、图示、说明汇编与样式扩展 |
| [通用示例内容](examples/construction-content.typ) | 新规范的内容起点 |

```typst
#import "../template/content.typ": article as clause, commentary as explain
= 总则
#clause[为规定基本要求，制定本规范。]
#explain[本条说明制定目的。]
```

参考模板默认使用 `auto` 模式：样书内容匹配基准时按原书逐页排版；修改或新增内容后自动改用流式排版，保留所有新增文字，不需在正文中调整坐标。可用 `--input gb55031-mode=flow` 强制自动排版；`reference` 模式在内容改变时明确拒绝使用旧的行位。10 幅插图保留原书图像。逐页核查及原书编号差异见 [核查记录](docs/gb55031-review.md)。

通用模板的 `page-layout`、`text-style`、`paragraph-style`、`renderers` 控制版式；`content-renderers` 可分别替换 `table`、`figure` 的渲染函数。上述设置写在模板或编译入口中，内容文件无需修改。

两个模板入口都可通过 `page-layout`、`text-style`、`paragraph-style`、`list-style`、`enum-style` 配置版式，通过 `renderers` 替换封面、标题或强调样式，使用 `front-matter` / `back-matter` 插入前后置内容。工程规范配置按属性合并，覆盖页宽或一个渲染器时保留其余默认设置。

```typst
#show: construction-standard.with(
  page-layout: (width: 160mm, height: 240mm),
  text-style: (size: 12pt),
  renderers: (heading: construction-heading.with(chapter-break: false)),
)
```

`page-layout` 控制内页；改变封面开本时同时提供 `renderers.cover`。自定义封面接收标准信息字典，自定义标题接收原生 `heading`，编号、引用与说明仍由模板管理。高级说明渲染接口见 [使用手册](book/manual.typ)。

## 字体与原文核查

国标模板的 `open` 配置使用开源字体；工程规范另有上文的独立字体选择。国标 `reference` 配置用于原书字体和实测字号对照，需要自行提供参考字库，并设置字体路径：

```powershell
$env:GBT_REFERENCE_FONTS = 'D:/my-fonts/reference'
$env:GBT_ROMAN_FONTS = 'C:/Windows/Fonts'
python tools/build.py --font-profile reference
# 构建并检查两版
python tools/build.py --font-profile both
```

参考字体名称与字高映射见 [docs/font-size-map.csv](docs/font-size-map.csv)，字体选择和行距集中在 [template/fonts.typ](template/fonts.typ)。参考字库未复制或上传。字号映射基于原页图像测量，原书字体的确切历史版本尚未完全确认。

混排字体按字符覆盖选择：黑体中的数字保留非衬线字体，英文使用配套罗马体；重音字母、希腊字母、西里尔字母和商标符号也使用西文字体。`black` 和强调文字默认继承当前字号，注、表格及图内的小字号不会跳回正文大小。参考版按对应字号校准西文字形，保留所在行的边界、显式基线偏移、字距和自定义字体。

原标准通过页面图像自行 OCR 转录，损坏的 PDF 正文文字层没有用于读取内容。[docs/review/](docs/review/) 保留前一轮 72 页核查记录及当时的 PDF、源码哈希；本次发布的重编说明见 [docs/publishing.md](docs/publishing.md)。出版水印和签名提示不转录。

## 目录与维护

| 目录 | 用途 |
| --- | --- |
| `template/` | 可复用模板、字体配置、原生标志、标注及自动索引 |
| `examples/` | 新标准入口与组件示例 |
| `book/` | 完整样书、手册及真实 Typst 示例 |
| `book/demo-pdf/` | 开源版示例的矢量 PDF；切换配置时自动重编 |
| `fonts/` | 固定版本下载清单和字体许可 |
| `vendor/` | CeTZ、oxifmt 与许可，编译不下载远程 Typst 包 |
| `tools/` | 字体准备、编译、检查、渲染和打包 |
| `docs/` | 字号测量、原文来源和核查记录 |
| `output/pdf/` | 两版样书、示例与手册 PDF |
| `legacy/cover/` | 原仓库 0.0.1 封面实现，保留供追溯 |

```sh
python tools/verify.py
python tools/verify_numbering.py
python tools/verify_typography.py
python tools/verify_explanations.py
python tools/render_outputs.py output/pdf/gbt-1.1-2020-open-fonts.pdf
python tools/package.py
python tools/verify_bundle.py
# 预览清理范围后清理可再生文件
python tools/clean.py --dry-run
python tools/clean.py
```

源码包包含已下载的开源字体，可离线编译；`verify_bundle.py` 在新目录解包重编，核对每页文字。字体二进制、`.tools/`、`output/qa/`、`output/tmp/`、构建报告和源码 ZIP 由 `.gitignore` 排除；字体清单、许可和 `docs/` 核查记录保留在 Git 中。

`clean.py` 清理临时解包目录、QA 预览与测试输出、构建报告、源码 ZIP 和脚本字节码；保留源码、本地字体、运行依赖、`output/pdf/` 的正式 PDF，以及 `book/demo-pdf/` 的 32 个示例片段。清理后可重新运行构建、渲染或打包命令生成所需结果。

新代码采用 [MIT](LICENSE) 许可；标准内容、图形、字体及第三方组件的来源和许可见 [THIRD_PARTY.md](THIRD_PARTY.md)。原封面实现作者为 ArchiBC；新接口以 `gbt.with(...)` 为入口，旧 `GBT11(...)` 写法保留在历史目录。
