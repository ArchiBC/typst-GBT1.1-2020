# 项目字体

运行 `python tools/bootstrap.py` 下载清单中的 9 个字体。思源字体使用 Adobe 官方仓库的固定提交；Liberation Serif 使用官方 2.1.5 字体包。每个字体的来源、大小和 SHA-256 在 `manifest.json` 中固定，已有文件也会校验。

| 字体 | 用途 | 字重 |
| --- | --- | --- |
| Source Han Serif SC | 中文宋体正文、显示宋体 | Regular、Bold |
| Source Han Sans SC | 黑体标题、数字、注标识 | Regular、Medium、Bold |
| Liberation Serif | 英文、数字及标点 | Regular、Bold、Italic、BoldItalic |

数学字体由 Typst 内置 New Computer Modern Math 提供。开源配置不依赖系统字体。

字体二进制不加入 Git；便携源码包可包含下载并校验的开源字体。三种字体的 SIL OFL 1.1 许可分别保存于本目录。

参考字库重编通过 `GBT_REFERENCE_FONTS` 和 `GBT_ROMAN_FONTS` 指定外部目录，不在本仓库分发。所需字体族名称见 `template/fonts.typ`；参考版涵盖方正书宋、方正黑体、小标宋、EU-HZ、EU-FZ、EU-F1 和 Times New Roman。
