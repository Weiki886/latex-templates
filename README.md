# LaTeX Templates

可复用的 Pandoc + LaTeX 文档模板合集。每个模板一个独立目录，克隆后挑选使用。

## 模板列表

| 模板 | 说明 |
| --- | --- |
| [product-report](product-report/) | 通用产品文档 PDF 模板：品牌封面、目录、页眉页脚、信息框、宽表格自动横向页；品牌名、Logo、配色均可配置 |

## 使用方式

```bash
git clone https://github.com/Weiki886/latex-templates.git
cd latex-templates
bash product-report/build.sh 文档.md 元数据.yaml 输出.pdf
```

各模板的示例效果见对应目录下的 `examples/`（如 [product-report/examples/example.pdf](product-report/examples/example.pdf)）。

各模板的详细用法见对应目录下的 README。

## License

见 [LICENSE](LICENSE)。
