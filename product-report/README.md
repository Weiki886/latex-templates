# Product Report — 通用产品文档 PDF 模板

一套 Pandoc + XeLaTeX 的产品文档模板：Markdown 是唯一正文源，模板负责生成带品牌封面、目录、页眉页脚、信息框和长表格布局的 A4 PDF。品牌名称、Logo、配色全部通过元数据配置，适合任何产品团队直接换用。

## 快速开始

```bash
# 构建内置示例（验证环境）
bash product-report/build.sh

# 构建自己的文档
bash product-report/build.sh path/to/你的文档.md path/to/元数据.yaml output/pdf/你的文档.pdf
```

依赖：`pandoc`（≥3.x）与 XeLaTeX（TeX Live / MacTeX）。中文优先使用 PingFang SC，英文优先 Avenir Next，缺失时自动回退到 TeX 内置字体。

## 换成你自己的品牌

三步完成，无需改动 `.latex` 模板文件：

1. **换 Logo**：替换 `assets/logo.png`（封面主图，高约 30mm）和 `assets/logo-icon.png`（页眉小图标，方形）。删除对应文件则回退到文字标识。
2. **改名字**：在元数据 yaml 中设置 `wordmark`（英文主标识）与 `wordmark-cn`（中文副标识），页眉和封面自动生效。
3. **调配色**（可选）：在 yaml 中用 `color-blue`、`color-navy`、`color-cyan` 等键覆盖品牌色（HTML 色值，不带 `#`）。

## 元数据字段一览

| 字段 | 用途 |
| --- | --- |
| `title` | 封面主标题与 PDF 标题 |
| `subtitle` | 封面副标题 |
| `author` | PDF 元数据作者 |
| `date` / `version` / `status` | 封面与页脚的日期、版本号、状态标签 |
| `document-type` | 封面与页眉的英文文档类型 |
| `toc` / `toc-depth` | 是否生成目录及层级 |
| `wordmark` / `wordmark-cn` | 品牌文字标识（英文 / 中文） |
| `cover-fields` | 封面信息区自定义键值行列表（`label` + `value`） |
| `cover-tagline` | 封面底部一句话标语 |
| `color-navy` 等 9 个 | 品牌色覆盖：`navy/blue/cyan/ink/muted/line/pale/ice/warm` |

完整示例见 [examples/example.yaml](examples/example.yaml)。

## 排版能力

- 引用块自动渲染为浅蓝信息框，适合结论与问题陈述；
- 四列及以上表格自动等宽，五列及以上自动转入横向页；
- fenced Div 包表格 + `colwidths="0.2,0.5,0.3"` 可手动钉死列宽；
- fenced Div 加 `landscape` 类可强制整段内容进入横向页，再加 `compact-table` 进一步压缩字号。

示例见 [examples/example.md](examples/example.md)。

## 目录结构

```
product-report/
├── README.md
├── product-report.latex   # 主模板（品牌信息全部参数化）
├── build.sh               # 构建脚本
├── filters/               # Pandoc Lua 过滤器（表格布局、标题清理）
├── assets/                # 占位品牌图，替换成你的 Logo 即可
└── examples/              # 示例 Markdown 与元数据
```

## 致谢

模板源自诺循（Nuoryn）团队在 Anker 黑客松中的产品文档实践，后通用化为独立模板。
