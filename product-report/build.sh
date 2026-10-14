#!/usr/bin/env bash
# Product Report 通用构建脚本：Markdown + 元数据 yaml -> 品牌 PDF
#
# 用法：
#   bash build.sh <源文档.md> <元数据.yaml> <输出.pdf>
set -euo pipefail

script_dir="$(cd "$(dirname "$0")" && pwd)"
caller_dir="$(pwd)"

if [[ $# -lt 3 ]]; then
  echo "用法: bash build.sh <源文档.md> <元数据.yaml> <输出.pdf>" >&2
  exit 1
fi
source_file="$1"
metadata_file="$2"
output_file="$3"

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

# 品牌图片：logo.png / logo-icon.png 存在时自动启用。
# 元数据文件旁边的 assets/ 优先（单文档品牌），其次是模板 assets/（全局默认）。
metadata_dir="$(cd "$(dirname "$metadata_file")" && pwd)"
pick_asset() {
  if [[ -f "$metadata_dir/assets/$1" ]]; then
    printf '%s\n' "$metadata_dir/assets/$1"
  elif [[ -f "$script_dir/assets/$1" ]]; then
    printf '%s\n' "$script_dir/assets/$1"
  fi
}
logo_args=()
logo_path="$(pick_asset logo.png || true)"
icon_path="$(pick_asset logo-icon.png || true)"
if [[ -n "${logo_path:-}" ]]; then
  logo_args+=(--variable "logo=$logo_path")
fi
if [[ -n "${icon_path:-}" ]]; then
  logo_args+=(--variable "logoicon=$icon_path")
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
