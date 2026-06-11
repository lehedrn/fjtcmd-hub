#!/bin/bash
# Record History Hook 卸载脚本 (Linux/macOS)

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo_info()  { echo -e "${GREEN}[INFO]${NC} $1"; }
echo_warn()  { echo -e "${YELLOW}[WARN]${NC} $1"; }

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../../../.." && pwd)"

echo ""
echo "=========================================="
echo "  Record History Hook 卸载"
echo "=========================================="
echo ""

# 删除 Hook 脚本
echo "[1/2] 删除 Hook 脚本..."
HOOK_FILE="$PROJECT_ROOT/.claude/hooks/record-history.js"
if [ -f "$HOOK_FILE" ]; then
    rm "$HOOK_FILE"
    echo_info "已删除: .claude/hooks/record-history.js"
else
    echo_info "文件不存在，跳过"
fi

# 提示手动移除配置
echo ""
echo "[2/2] 移除配置..."
echo_warn "请从 .claude/settings.local.json 中手动移除以下内容："
echo ""
echo "1. permissions.allow 中的:"
echo '   "Bash(node .claude/hooks/record-history.js)"'
echo ""
echo "2. hooks.Stop 数组中包含 record-history.js 的条目"
echo ""

# 询问是否删除历史记录
read -p "是否删除历史记录文件？(y/N): " DELETE_HISTORY
if [[ "$DELETE_HISTORY" =~ ^[Yy]$ ]]; then
    rm -rf "$PROJECT_ROOT/docs/history"
    echo_info "已删除: docs/history/"
else
    echo_info "保留历史记录文件"
fi

echo ""
echo "=========================================="
echo_info "✅ 卸载完成！"
echo "=========================================="
echo ""
