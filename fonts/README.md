# 项目字体

运行 `python tools/bootstrap.py` 下载清单中的 9 个字体。思源字体使用 Adobe 官方仓库的固定提交；Liberation Serif 使用官方 2.1.5 字体包。每个字体的来源、大小和 SHA-256 在 `manifest.json` 中固定，已有文件也会校验。

| 字体 | 用途 | 字重 |
| --- | --- | --- |
| Source Han Serif SC | 中文宋体正文、显示宋体 | Regular、Bold |
| Source Han Sans SC | 黑体标题、数字、注标识 | Regular、Medium、Bold |
| Liberation Serif | 正文英文和数字、标题中的英文、ASCII 标点及商标符号 | Regular、Bold、Italic、BoldItalic |

数学字体由 Typst 内置 New Computer Modern Math 提供。开源配置不依赖系统字体。

黑体的中文和编号使用思源黑体，英文使用 Liberation Serif Bold；强调文字继承所在段落的字号。字体覆盖与字号校准统一在 `template/fonts.typ` 中定义，保留上下标、显式基线偏移及作者设置的字距。参考配置的粗体字库不覆盖重音、希腊和西里尔字母时，使用 Times New Roman 的对应字重。

字体二进制不加入 Git；便携源码包可包含下载并校验的开源字体。三种字体的 SIL OFL 1.1 许可分别保存于本目录。

参考字库重编通过 `GBT_REFERENCE_FONTS` 和 `GBT_ROMAN_FONTS` 指定外部目录，不在本仓库分发。所需字体族名称见 `template/fonts.typ`；参考版涵盖方正书宋、方正黑体、小标宋、EU-HZ、EU-FZ、EU-F1 和 Times New Roman。

工程规范的字体配置独立于以上国标配置。`tools/build.py` 的工程规范构建检测 `GBT_CONSTRUCTION_FONTS` 指向的目录，默认检测 Windows 字体目录；宋体、黑体和 Times New Roman 齐全时，使用本机字体。`--construction-font-profile open` 强制使用已打包的开源字体，`windows` 强制使用本机字体。`tools/compile.py` 单文件编译默认使用开源配置，可加上述 `windows` 参数选择本机字体。模板直接由 Typst 编译时默认使用开源配置，可通过 `--input construction-font-profile=windows` 与相应字体路径启用本机配置。本机参考字体仅缓存于不打包的 `.tools/construction-fonts`，不会把 Windows 目录中的其他字体引入编译。
