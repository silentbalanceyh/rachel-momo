#!/usr/bin/env bash
# rachel-momo.docs/content-node.sh
# 第三项菜单专用：Node 环境检查 + 可选切换至 10.x，并检测 gitbook
set -euo pipefail

# ---------- 彩色输出 ----------
if command -v tput >/dev/null 2>&1 && [ -n "${TERM-}" ] && tput colors >/dev/null 2>&1; then
  BOLD="$(tput bold)"; DIM="$(tput dim)"; GREEN="$(tput setaf 2)"; YELLOW="$(tput setaf 3)"; RED="$(tput setaf 1)"; CYAN="$(tput setaf 6)"; RESET="$(tput sgr0)"
else
  BOLD=""; DIM=""; GREEN=""; YELLOW=""; RED=""; CYAN=""; RESET=""
fi

# ---------- Emoji ----------
EMO_JS="🧪"; EMO_OK="🟢"; EMO_NO="🔴"; EMO_NVM="🧰"; EMO_VER="🔢"; EMO_Q="❓"; EMO_PKG="📦"

# ---------- 路径（上一级菜单） ----------
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." >/dev/null 2>&1 && pwd)"
PARENT_MENU="${REPO_ROOT}/content.sh"

# ---------- 尝试加载 nvm（脚本环境下常常未自动加载） ----------
try_source_nvm() {
  if [[ "$(type -t nvm 2>/dev/null || true)" == "function" ]]; then
    return 0
  fi
  local cand=""
  if [[ -n "${NVM_DIR-}" && -f "${NVM_DIR}/nvm.sh" ]]; then
    cand="${NVM_DIR}/nvm.sh"
  elif [[ -f "${HOME}/.nvm/nvm.sh" ]]; then
    cand="${HOME}/.nvm/nvm.sh"
  elif command -v brew >/dev/null 2>&1; then
    local brew_prefix; brew_prefix="$(brew --prefix 2>/dev/null || true)"
    if [[ -n "${brew_prefix}" && -f "${brew_prefix}/opt/nvm/nvm.sh" ]]; then
      cand="${brew_prefix}/opt/nvm/nvm.sh"
    fi
  fi
  if [[ -n "${cand}" ]]; then
    # shellcheck source=/dev/null
    . "${cand}" >/dev/null 2>&1 || true
  fi
}

# ---------- 通用检查输出 ----------
check_bin() {
  local bin="$1" label="$2"
  if command -v "$bin" >/dev/null 2>&1; then
    local ver path
    ver="$("$bin" -v 2>/dev/null || true)"
    path="$(command -v "$bin" || true)"
    echo -e "  ${EMO_OK} ${label}: ${GREEN}${ver:-(unknown)}${RESET}  ${DIM}(${path})${RESET}"
  else
    echo -e "  ${EMO_NO} ${label}: 未安装"
  fi
}

print_env() {
  echo -e "${BOLD}${EMO_JS} Node.js 运行环境检查${RESET}\n"
  check_bin node "node"
  check_bin npm  "npm"
  check_bin npx  "npx"
  check_bin yarn "yarn"
  check_bin pnpm "pnpm"
  check_bin corepack "corepack"

  # nvm 状态
  local nvm_type nvm_ver cand=""
  nvm_type="$(type -t nvm 2>/dev/null || true)"
  if [[ "${nvm_type}" == "function" ]]; then
    nvm_ver="$(nvm --version 2>/dev/null || nvm -v 2>/dev/null || true)"
    echo -e "  ${EMO_OK} ${EMO_NVM} nvm: ${GREEN}${nvm_ver:-unknown}${RESET}"
  else
    if [[ -n "${NVM_DIR-}" && -f "${NVM_DIR}/nvm.sh" ]]; then
      cand="${NVM_DIR}/nvm.sh"
    elif [[ -f "${HOME}/.nvm/nvm.sh" ]]; then
      cand="${HOME}/.nvm/nvm.sh"
    elif command -v brew >/dev/null 2>&1 && [[ -f "$(brew --prefix 2>/dev/null)/opt/nvm/nvm.sh" ]]; then
      cand="$(brew --prefix 2>/dev/null)/opt/nvm/nvm.sh"
    fi
    if [[ -n "${cand}" ]]; then
      echo -e "  ${EMO_OK} ${EMO_NVM} nvm: 已安装（${DIM}${cand}${RESET}）"
    else
      echo -e "  ${EMO_NO} ${EMO_NVM} nvm: 未检测到"
    fi
  fi

  # nvm 已安装 Node 版本（高亮 current）
  list_nvm_versions
  echo
}

list_nvm_versions() {
  if [[ "$(type -t nvm 2>/dev/null || true)" == "function" ]]; then
    local versions current
    versions="$(nvm ls --no-colors 2>/dev/null | grep -Eo 'v[0-9]+\.[0-9]+\.[0-9]+' | sort -Vu || true)"
    current="$(nvm current 2>/dev/null || true)"
    if [[ -n "${versions}" ]]; then
      echo -e "  ${EMO_VER} nvm versions:"
      while IFS= read -r v; do
        if [[ "${current}" == "${v}" ]]; then
          echo -e "    • ${CYAN}${BOLD}${v}${RESET} ${DIM}(current)${RESET}"
        else
          echo -e "    • ${v}"
        fi
      done <<< "${versions}"
    else
      echo -e "  ${EMO_VER} nvm versions: 无"
    fi
    return
  fi

  local root=""
  if [[ -n "${NVM_DIR-}" && -d "${NVM_DIR}/versions/node" ]]; then
    root="${NVM_DIR}"
  elif [[ -d "${HOME}/.nvm/versions/node" ]]; then
    root="${HOME}/.nvm"
  fi
  if [[ -n "${root}" && -d "${root}/versions/node" ]]; then
    local versions
    versions="$(ls -1 "${root}/versions/node" 2>/dev/null | grep -E '^v[0-9]+\.[0-9]+\.[0-9]+$' | sort -Vu || true)"
    if [[ -n "${versions}" ]]; then
      echo -e "  ${EMO_VER} nvm versions:"
      while IFS= read -r v; do
        echo -e "    • ${v}"
      done <<< "${versions}"
    else
      echo -e "  ${EMO_VER} nvm versions: 无"
    fi
  else
    echo -e "  ${EMO_VER} nvm versions: 无"
  fi
}

# ---------- 切换到 10.x ----------
switch_to_10x() {
  if [[ "$(type -t nvm 2>/dev/null || true)" != "function" ]]; then
    echo -e "${YELLOW}${EMO_Q} 无法切换：未检测到 nvm function${RESET}"
    return 1
  fi
  local target
  target="$(nvm ls --no-colors 2>/dev/null | grep -Eo 'v10\.[0-9]+\.[0-9]+' | sort -V | tail -n1 || true)"
  if [[ -z "${target}" ]]; then
    read -rp "未发现已安装的 10.x。是否安装最新 10.x？(y/N) " yn
    case "${yn:-N}" in
      y|Y)
        echo "开始安装 10.x ..."
        if nvm install 10; then
          target="$(nvm ls --no-colors 2>/dev/null | grep -Eo 'v10\.[0-9]+\.[0-9]+' | sort -V | tail -n1 || true)"
        else
          echo -e "${RED}安装 10.x 失败${RESET}"
          return 1
        fi
        ;;
      *) echo "已取消安装。"; return 1 ;;
    esac
  fi
  if [[ -n "${target}" ]]; then
    echo "切换到 ${target} ..."
    nvm use "${target}" >/dev/null
    echo
    print_env
    return 0
  fi
  echo -e "${RED}未找到可用的 10.x 版本${RESET}"
  return 1
}

# ---------- 检查 gitbook（当前 Node 版本） ----------
check_gitbook() {
  if command -v gitbook >/dev/null 2>&1; then
    local gver gpath
    gver="$(gitbook --version 2>/dev/null | tr -d '\n' || true)"
    gpath="$(command -v gitbook || true)"
    echo -e "  ${EMO_OK} ${EMO_PKG} gitbook: ${GREEN}${gver:-installed}${RESET}  ${DIM}(${gpath})${RESET}"
  else
    echo -e "  ${EMO_NO} ${EMO_PKG} gitbook: 未安装（当前 Node 版本）"
  fi
}

# ================== 执行流程 ==================
try_source_nvm
print_env

# 若当前 node 已是 10.x，直接检测 gitbook 并返回上级菜单
current_node="$(node -v 2>/dev/null || true)"
if [[ "${current_node}" =~ ^v10\. ]]; then
  echo -e "\n${BOLD}检测 gitbook（当前 Node 为 10.x）${RESET}\n"
  check_gitbook
  echo
  # 直接返回上一级菜单（保持当前会话环境）
  if [[ -f "${PARENT_MENU}" ]]; then
    exec bash "${PARENT_MENU}"
  else
    echo -e "${RED}[ERROR]${RESET} 未找到上一级菜单：${PARENT_MENU}"
    exit 1
  fi
fi

# 否则：询问是否切换到 10.x
read -rp "是否切换到 Node 10.x？(y/N) " ans
case "${ans:-N}" in
  y|Y)
    if switch_to_10x; then
      echo -e "\n${BOLD}检测 gitbook（Node 10.x 环境）${RESET}\n"
      check_gitbook
    fi
    ;;
  *) : ;;
esac

echo
read -rp "完成，按回车返回..." _ || true

# 直接返回上一级菜单（保持当前会话已生效的 nvm 切换）
if [[ -f "${PARENT_MENU}" ]]; then
  exec bash "${PARENT_MENU}"
else
  echo -e "${RED}[ERROR]${RESET} 未找到上一级菜单：${PARENT_MENU}"
  exit 1
fi
