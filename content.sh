#!/usr/bin/env bash
# content.sh - 主菜单（带 Emoji）
# 1）📚 数理化生信 -> rachel-momo.docs/content.sh
# 2）🐧 Linux 命令集 -> rachel-momo.linux/content.sh
# 3）🧪 检查 Node.js 版本 -> rachel-momo.docs/content-node.sh

set -euo pipefail

# ---------- 彩色输出 ----------
if command -v tput >/dev/null 2>&1 && [ -n "${TERM-}" ] && tput colors >/dev/null 2>&1; then
  BOLD="$(tput bold)"; DIM="$(tput dim)"; GREEN="$(tput setaf 2)"; YELLOW="$(tput setaf 3)"; RED="$(tput setaf 1)"; RESET="$(tput sgr0)"
else
  BOLD=""; DIM=""; GREEN=""; YELLOW=""; RED=""; RESET=""
fi

# ---------- Emoji ----------
EMO_DOC="📚"
EMO_LNX="🐧"
EMO_JS="🧪"

# ---------- 路径 ----------
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"
REPO_ROOT="${SCRIPT_DIR}"

DOCS_REL="rachel-momo.docs/content.sh"
LINUX_REL="rachel-momo.linux/content.sh"
NODE_REL="rachel-momo.docs/content-node.sh"

DOCS="${REPO_ROOT}/${DOCS_REL}"
LINUX="${REPO_ROOT}/${LINUX_REL}"
NODE="${REPO_ROOT}/${NODE_REL}"

# ---------- 执行目标脚本 ----------
run_target() {
  local target="$1" rel="$2"
  if [[ ! -f "${target}" ]]; then
    echo "${RED}[ERROR]${RESET} 未找到脚本：${rel}"
    exit 1
  fi
  if [[ ! -x "${target}" ]]; then
    chmod +x "${target}" 2>/dev/null || true
  fi
  echo -e "${DIM}>> 正在执行：${rel}${RESET}\n"
  exec bash "${target}"
}

# ---------- 菜单 ----------
echo -e "${BOLD}请选择菜单${RESET}"
echo -e "  1）${EMO_DOC} 数理化生信"
echo -e "  2）${EMO_LNX} Linux 命令集"
echo -e "  3）${EMO_JS} 检查 Node.js 版本"
echo
read -rp "输入编号并回车（q 退出）： " choice

case "${choice:-}" in
  1) run_target "${DOCS}"  "${DOCS_REL}"  ;;
  2) run_target "${LINUX}" "${LINUX_REL}" ;;
  3) run_target "${NODE}"  "${NODE_REL}"  ;;
  q|Q|"") echo "已退出。"; exit 0 ;;
  *) echo "${YELLOW}[WARN]${RESET} 无效选择：${choice}"; exit 1 ;;
esac
