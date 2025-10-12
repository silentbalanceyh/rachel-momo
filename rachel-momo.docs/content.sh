#!/usr/bin/env bash
# ============================================
# 《数学 / 物理 / 化学 / 生物 / 信息计算》总菜单（带Emoji & 返回上一级）
# 位置：rachel-momo.docs/content.sh
# 说明：各子目录需提供可执行脚本 book.sh
# 返回上一级：仅在选 0 时执行上层目录的 content.sh
# Ctrl+C 在子脚本时：回到本菜单（当前脚本）
# 新增：q/Q 直接退出整个程序
# ============================================

set -euo pipefail

# 解析脚本所在目录
SCRIPT_PATH="$(cd -- "$(dirname -- "$0")" && pwd)"
THIS_SH="$SCRIPT_PATH/$(basename "$0")"

# 上一级目录与其菜单脚本（一般是仓库根目录）
PARENT_DIR="$(cd -- "$SCRIPT_PATH/.." && pwd)"
PARENT_SH="$PARENT_DIR/content.sh"

# =========== 工具：回到本菜单 / 上一级主菜单 ===========
restart_this_menu() {
  echo "=> 返回当前菜单：$THIS_SH"
  exec bash "$THIS_SH"
}

go_parent_menu() {
  if [[ -f "$PARENT_SH" ]]; then
    echo "=> 返回上一级并执行：$PARENT_SH"
    exec bash "$PARENT_SH"
  else
    echo "[WARN] 未找到上一级菜单脚本：$PARENT_SH"
    read -r -p "回车返回当前菜单..." _
  fi
}

# 根据名字解析“最可能”的目标目录：
# 1) 优先：仓库根目录下的同名目录
# 2) 其次：当前 rachel-momo.docs 目录下的同名目录
# 3) 兜底：在仓库根内 maxdepth=3 搜一次
resolve_dir() {
  local name="$1"
  local candidates=(
    "$PARENT_DIR/$name"
    "$SCRIPT_PATH/$name"
  )
  for d in "${candidates[@]}"; do
    [[ -d "$d" ]] && { echo "$d"; return 0; }
  done
  local found
  found="$(find "$PARENT_DIR" -maxdepth 3 -type d -name "$name" 2>/dev/null | head -n1 || true)"
  [[ -n "${found:-}" ]] && { echo "$found"; return 0; }
  echo ""
  return 1
}

# 执行某个笔记目录下的 book.sh（Ctrl+C 时回到本菜单）
run_book() {
  local target_dir="$1"
  if [[ -z "${target_dir}" ]]; then
    echo "[ERR] 未找到目标目录。"
    read -r -p "回车返回菜单..." _
    return
  fi

  local book="$target_dir/book.sh"
  if [[ ! -d "$target_dir" ]]; then
    echo "[ERR] 目录不存在：$target_dir"
    read -r -p "回车返回菜单..." _
    return
  fi
  if [[ ! -f "$book" ]]; then
    echo "[ERR] 未找到脚本：$book"
    read -r -p "回车返回菜单..." _
    return
  fi
  [[ -x "$book" ]] || chmod +x "$book" 2>/dev/null || true

  echo "=> 执行：$book"

  # ---- 运行子脚本时临时处理 SIGINT，使 Ctrl+C 仅终止子脚本 ----
  set +e
  local __old_trap
  __old_trap="$(trap -p INT || true)"
  trap 'echo; echo "[INFO] 子脚本中断（Ctrl+C），返回本菜单...";' INT

  bash "$book"
  local code=$?

  # 还原 trap 与 -e
  if [[ -n "$__old_trap" ]]; then
    eval "$__old_trap"
  else
    trap - INT
  fi
  set -e

  # 130 = SIGINT；回到“本菜单”（不是上一级）
  if [[ $code -eq 130 ]]; then
    restart_this_menu
    return
  elif [[ $code -ne 0 ]]; then
    echo "[WARN] 子脚本退出码：$code"
  fi

  echo
  read -r -p "子脚本执行完毕，回车返回菜单..." _
}

# Emoji 菜单
show_menu() {
  clear
  cat <<'MENU'
==> 内容菜单：rachel-momo.docs
  1) 📐  数学笔记
  2) 🔥  物理笔记
  3) 🧪  化学笔记
  4) 🧬  生物笔记
  5) 💻  信息计算笔记
  0) 🔙  返回上一级
  q) ❌  退出程序
MENU
  echo
}

# 解析各学科目录（支持多位置）
DIR_MATH="$(resolve_dir 'rachel-momo.MATH')"
DIR_PHYS="$(resolve_dir 'rachel-momo.PHYS')"
DIR_CHEM="$(resolve_dir 'rachel-momo.CHEM')"
DIR_BIOL="$(resolve_dir 'rachel-momo.BIOL')"
DIR_COMP="$(resolve_dir 'rachel-momo.COMP')"

# 循环菜单
while true; do
  show_menu
  read -r -p "请选择（0-5/q）： " choice
  case "${choice:-}" in
    1) run_book "$DIR_MATH" ;;
    2) run_book "$DIR_PHYS" ;;
    3) run_book "$DIR_CHEM" ;;
    4) run_book "$DIR_BIOL" ;;
    5) run_book "$DIR_COMP" ;;
    0) go_parent_menu ;;     # 仅此处返回到一级菜单
    q|Q) echo "已退出。"; exit 0 ;;
    *) echo "无效选择：$choice"; read -r -p "回车重试..." _ ;;
  esac
done
