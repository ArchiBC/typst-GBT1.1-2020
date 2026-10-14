# 第三方内容及来源

用户提供的 `GBT+1.1-2020.pdf` 是 GB/T 1.1—2020 原文。页面图、OCR、转录书、重绘图形和复刻 PDF 由此产生；标准内容与原图形不适用本项目新代码的 MIT 许可。当前 GB 标志是 `template/gb-mark.typ` 中的原生曲线与网点。

用户另行提供 `GB55031-2022：民用建筑通用规范.pdf`。78 页复刻源文件、规范正文、条文说明、图题和表格文字由该印本转录；10 幅图像截取自原书插图，未嵌入整页扫描。来源哈希和插图范围保存在 `docs/gb55031-transcription.json`；原 PDF、OCR 稿及页面图不参与公开构建。规范内容、原插图及出版信息不适用新代码的 MIT 许可。工程规范支持本机宋体、黑体及 Times New Roman，也支持项目自带的开源字体配置；原书印刷字体未复制，本机字体文件不上传或打包。

## 项目使用的开源字体

| 字体 | 文件与许可 |
| --- | --- |
| 思源宋体 Source Han Serif SC | `fonts/SourceHanSerifSC-*.otf`，`fonts/SourceHanSerif-LICENSE.txt`，SIL OFL 1.1 |
| 思源黑体 Source Han Sans SC | `fonts/SourceHanSansSC-*.otf`，`fonts/SourceHanSans-LICENSE.txt`，SIL OFL 1.1 |
| Liberation Serif | `fonts/LiberationSerif-*.ttf`，`fonts/Liberation-LICENSE.txt`，SIL OFL 1.1 |

字体信息及哈希见 `fonts/manifest.json`。普通开源配置加载该目录及 Typst 内置字体，不安装到系统。官方来源：[Source Han Serif](https://github.com/adobe-fonts/source-han-serif)、[Source Han Sans](https://github.com/adobe-fonts/source-han-sans)、[Liberation Fonts](https://github.com/liberationfonts/liberation-fonts)。

参考配置读取用户指定目录内的方正书宋、黑体、小标宋及 E-HZ/E-FZ 等字库，并读取 Windows 已有 Times New Roman；没有复制或打包这些参考字体。系列对应根据原图、字体标识和本机样本推断，未确认同一字库版本。参考字体的使用及 PDF 嵌入受各自许可约束。

Typst 内置 New Computer Modern Math（GUST Font License）、Libertinus（SIL OFL）、DejaVu Sans Mono（DejaVu 许可）由编译器提供。许可入口：[Typst assets](https://github.com/typst/typst-assets)、[New Computer Modern](https://ctan.org/pkg/newcomputermodern)、[Libertinus](https://github.com/alerque/libertinus)、[DejaVu](https://dejavu-fonts.github.io/License.html)。

## 原生标注及索引

CeTZ 0.5.2 和 oxifmt 1.0.0 位于 `vendor/`，各自 LICENSE 同时保存。CeTZ 用于可编辑图形与附录 E 尺寸标注。离线拼音表 `template/pinyin.json` 由 pypinyin 0.55.0 数据生成，MIT 许可保存在 template 目录的对应许可文件。

## 编译与 OCR

Typst / Python typst 0.15.0 用于原生编译，pypdfium2 用于渲染。pypdf 读取生成 PDF 的文字、字体、链接及结构，原 PDF 正文不通过文本层读取。Windows.Media.Ocr、RapidOCR 识别原图；Pillow、OpenCV、fontTools 用于图像测量及字体校准。`.tools/` 安装目录不包含在源码包中。

本项目延续 [ArchiBC/typst-GBT1.1-2020](https://github.com/ArchiBC/typst-GBT1.1-2020)。原 0.0.1 封面实现由 ArchiBC 编写，按原提交完整保留于 `legacy/cover/`；当前模板使用独立的原生曲线标志、正文组件和自动编号接口。
