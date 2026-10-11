# Typst GB/T 1.1—2020 模板与样书

可复用的国标写作模板，以及 GB/T 1.1—2020 的完整、可编辑 Typst 转录样书。封面、正文、章条、术语、图表、公式、附录、目次和索引由模板统一排版。GB 标志使用 Typst 原生曲线与网点绘制。

## 下载 PDF

| 文件 | 内容 |
| --- | --- |
| [开源字体版样书](output/pdf/gbt-1.1-2020-open-fonts.pdf) | 思源宋体、思源黑体、Liberation Serif；可直接从本仓库重编 |
| [方正字体审阅版样书](output/pdf/gbt-1.1-2020-replica.pdf) | 方正书宋、方正黑体、小标宋及参考字库；重编需自行提供相应字体 |
| [完整组件示例](output/pdf/standard-example.pdf) | 编号、引用、术语、合并单元格、续表、双面分页和自动索引 |
| [使用手册](output/pdf/template-manual.pdf) | 模板接口与写作方法 |

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

## 字体与原文核查

默认 `open` 配置全部使用开源字体。`reference` 配置用于原书字体和实测字号对照，需要自行提供参考字库，并设置字体路径：

```powershell
$env:GBT_REFERENCE_FONTS = 'D:/my-fonts/reference'
$env:GBT_ROMAN_FONTS = 'C:/Windows/Fonts'
python tools/build.py --font-profile reference
# 构建并检查两版
python tools/build.py --font-profile both
```

参考字体名称与字高映射见 [docs/font-size-map.csv](docs/font-size-map.csv)，字体选择和行距集中在 [template/fonts.typ](template/fonts.typ)。参考字库未复制或上传。字号映射基于原页图像测量，原书字体的确切历史版本尚未完全确认。

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
python tools/render_outputs.py output/pdf/gbt-1.1-2020-open-fonts.pdf
python tools/package.py
python tools/verify_bundle.py
```

源码包包含已下载的开源字体，可离线编译；`verify_bundle.py` 在新目录解包重编，核对每页文字。`.tools/`、扫描图、历史 OCR 中间稿和大幅页面预览不提交到仓库。

新代码采用 [MIT](LICENSE) 许可；标准内容、图形、字体及第三方组件的来源和许可见 [THIRD_PARTY.md](THIRD_PARTY.md)。原封面实现作者为 ArchiBC；新接口以 `gbt.with(...)` 为入口，旧 `GBT11(...)` 写法保留在历史目录。
