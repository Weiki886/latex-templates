#!/usr/bin/env bash
# Product Report 通用构建脚本：Markdown + 元数据 yaml -> 品牌 PDF
#
# 用法：
#   bash build.sh <源文档.md> <元数据.yaml> <输出.pdf>
# 不带参数时构建内置示例：examples/example.md -> output/pdf/example.pdf
set -euo pipefail

script_dir="$(cd "$(dirname "$0")" && pwd)"
caller_dir="$(pwd)"

source_file="${1:-$script_dir/examples/example.md}"
metadata_file="${2:-$script_dir/examples/example.yaml}"
output_file="${3:-$caller_dir/output/pdf/example.pdf}"

# 相对路径统一转为绝对路径，避免 pandoc/xelatex 工作目录差异
to_abs() {
  case "$1" in
    /*) printf '%s\n' "$1" ;;
    *)  printf '%s/%s\n' "$caller_dir" "$1" ;;
  esac
}
source_file="$(to_abs "$source_file")"
metadata_file="$(to_abs "$metadata_file")"
output_file="$(to_abs "$output_file")"

mkdir -p "$(dirname "$output_file")"

# TeX 运行时缓存放到系统临时目录，不污染项目
export TEXMFVAR="${TMPDIR:-/tmp}/product-report-texmf-var"
export TEXMFCONFIG="${TMPDIR:-/tmp}/product-report-texmf-config"
export HOME="${HOME:-/tmp}"
mkdir -p "$TEXMFVAR" "$TEXMFCONFIG"

# 品牌图片：assets/ 下存在 logo.png / logo-icon.png 时自动启用，
# 替换这两张图即可更换品牌视觉，无需改动模板
logo_args=()
if [[ -f "$script_dir/assets/logo.png" ]]; then
  logo_args+=(--variable "logo=$script_dir/assets/logo.png")
fi
if [[ -f "$script_dir/assets/logo-icon.png" ]]; then
  logo_args+=(--variable "logoicon=$script_dir/assets/logo-icon.png")
fi

pandoc "$source_file" \
  --from=markdown+smart \
  --template="$script_dir/product-report.latex" \
  --metadata-file="$metadata_file" \
  "${logo_args[@]}" \
  --lua-filter="$script_dir/filters/table-layout.lua" \
  --lua-filter="$script_dir/filters/clean-headings.lua" \
  --pdf-engine=xelatex \
  --toc \
  --number-sections \
  --resource-path="$script_dir:$(dirname "$source_file"):$caller_dir" \
  --output="$output_file"

printf '%s\n' "$output_file"
