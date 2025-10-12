#!/usr/bin/env bash
# rachel-momo.MATH/book.sh
# 目标：不预构建，直接以 gitbook serve 在线编译并服务
# - 自动尝试加载 nvm
# - 尝试切换到 Node 10.24.1（若已安装）
# - 自动安装 book.json 插件（若存在）
# - 端口占用智能检测（从 PORT 开始向上找可用端口）

set -euo pipefail

# ===== 彩色输出 =====
if command -v tput >/dev/null 2>&1 && [ -n "${TERM-}" ] && tput colors >/dev/null 2>&1; then
  BOLD="$(tput bold)"; DIM="$(tput dim)"; GREEN="$(tput setaf 2)"; YELLOW="$(tput setaf 3)"; RED="$(tput setaf 1)"; CYAN="$(tput setaf 6)"; RESET="$(tput sgr0)"
else
  BOLD=""; DIM=""; GREEN=""; YELLOW=""; RED=""; CYAN=""; RESET=""
fi

# ===== 端口设置：可用 env PORT 或第一个参数覆盖，默认 4000 =====
PORT="${PORT:-${1:-4000}}"

# ===== 进入本书根目录（本脚本所在目录） =====
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"
cd "${SCRIPT_DIR}"

# ===== 尝试加载 nvm =====
try_source_nvm() {
  # 已可用则返回
  if [[ "$(type -t nvm 2>/dev/null || true)" == "function" ]]; then
    return 0
  fi
  local cand=""
  if [[ -n "${NVM_DIR-}" && -f "${NVM_DIR}/nvm.sh" ]]; then
    cand="${NVM_DIR}/nvm.sh"
  elif [[ -f "${HOME}/.nvm/nvm.sh" ]]; then
    cand="${HOME}/.nvm/nvm.sh"
  elif command -v brew >/dev/null 2>&1; then
    local bp; bp="$(brew --prefix 2>/dev/null || true)"
    [[ -n "${bp}" && -f "${bp}/opt/nvm/nvm.sh" ]] && cand="${bp}/opt/nvm/nvm.sh"
  fi
  [[ -n "${cand}" ]] && . "${cand}" >/dev/null 2>&1 || true
}

# ===== 若已安装则尽量切到 Node 10.24.1 / 或任意 10.x =====
maybe_switch_node_10() {
  local have_node="no"
  if command -v node >/dev/null 2>&1; then
    have_node="yes"
    local cur_major; cur_major="$(node -p 'process.versions.node.split(".")[0]' 2>/dev/null || echo "")"
    if [[ "${cur_major}" == "10" ]]; then
      echo -e "${GREEN}✓ 当前 Node 已是 10.x（$(node -v)）${RESET}"
      return 0
    fi
  fi

  # 如有 nvm，尝试 use 指定版本
  if [[ "$(type -t nvm 2>/dev/null || true)" == "function" ]]; then
    if nvm ls 10.24.1 >/dev/null 2>&1; then
      echo -e "${CYAN}→ 切换到 Node 10.24.1${RESET}"
      nvm use 10.24.1 >/dev/null
      echo -e "${GREEN}✓ 当前 Node：$(node -v)${RESET}"
      return 0
    fi
    # fallback：任意 10.x 的最新
    local any10
    any10="$(nvm ls --no-colors 2>/dev/null | grep -Eo 'v10\.[0-9]+\.[0-9]+' | sort -V | tail -n1 || true)"
    if [[ -n "${any10}" ]]; then
      echo -e "${CYAN}→ 切换到 Node ${any10}${RESET}"
      nvm use "${any10}" >/dev/null
      echo -e "${GREEN}✓ 当前 Node：$(node -v)${RESET}"
      return 0
    fi
    # 没有 10.x：仅提示，不强装
    echo -e "${YELLOW}⚠ 未检测到已安装的 Node 10.x；建议执行： nvm install 10.24.1${RESET}"
  else
    if [[ "${have_node}" == "yes" ]]; then
      echo -e "${YELLOW}⚠ 当前 Node 非 10.x（$(node -v)），且未检测到 nvm。GitBook CLI 推荐在 Node 10.x 下运行。${RESET}"
    else
      echo -e "${YELLOW}⚠ 未检测到 Node 与 nvm。请先安装 nvm，然后： nvm install 10.24.1${RESET}"
    fi
  fi
}

# ===== 检查 / 提示 gitbook-cli =====
ensure_gitbook_cli() {
  if ! command -v gitbook >/dev/null 2>&1; then
    echo -e "${YELLOW}⚠ 未检测到 gitbook-cli（命令：gitbook）。${RESET}"
    echo -e "  建议在 Node 10.x 环境安装： ${BOLD}npm i -g gitbook-cli${RESET}"
    echo -e "  或使用你已有的 10.x 会话安装后再运行本脚本。"
    exit 1
  fi
  # 简要显示版本
  local gv; gv="$(gitbook --version 2>/dev/null | tr -d '\n' || true)"
  echo -e "${GREEN}✓ gitbook: ${gv:-installed}${RESET}"
}

# ===== 如存在 book.json，则安装插件 =====
install_plugins_if_any() {
  if [[ -f "book.json" ]]; then
    echo -e "${CYAN}→ 检测到 book.json，执行：gitbook install（安装/更新插件）${RESET}"
    # 安装过程中可能有警告，不影响运行
    if ! gitbook install; then
      echo -e "${YELLOW}⚠ gitbook install 出现问题，但尝试继续 serve ...${RESET}"
    fi
  fi
}

# ===== 端口占用检测，向上寻找可用端口 =====
find_free_port() {
  local start="$1" max_probe=20 p
  p="${start}"
  for _ in $(seq 0 "${max_probe}"); do
    if command -v lsof >/dev/null 2>&1; then
      if ! lsof -i TCP:"${p}" -sTCP:LISTEN >/dev/null 2>&1; then
        echo "${p}"; return 0
      fi
    elif command -v nc >/dev/null 2>&1; then
      if ! nc -z localhost "${p}" >/dev/null 2>&1; then
        echo "${p}"; return 0
      fi
    else
      # 无 lsof/nc，无法检测，占位返回起始端口
      echo "${p}"; return 0
    fi
    p=$((p+1))
  done
  echo "${start}"  # 兜底
  return 0
}

# ====== 执行流程 ======
echo -e "${BOLD}GitBook 在线服务（不预构建）${RESET}"
try_source_nvm
maybe_switch_node_10
ensure_gitbook_cli
install_plugins_if_any

FREE_PORT="$(find_free_port "${PORT}")"
if [[ "${FREE_PORT}" != "${PORT}" ]]; then
  echo -e "${YELLOW}⚠ 端口 ${PORT} 已占用，改用可用端口：${FREE_PORT}${RESET}"
fi

echo -e "${CYAN}→ 启动 GitBook 服务：${RESET} http://127.0.0.1:${FREE_PORT}/"
echo -e "  ${DIM}（若希望自动打开浏览器，可移除 --no-open 参数）${RESET}"

# --no-open 避免自动打开浏览器
exec gitbook serve . --port "${FREE_PORT}" --no-open
