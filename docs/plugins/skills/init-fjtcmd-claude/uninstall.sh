#!/bin/bash
# init-fjtcmd-claude Skill 卸载脚本 (Linux/macOS)

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'

echo_info()  { echo -e "${GREEN}[INFO]${NC} $1"; }

PROJECT_ROOT="$(cd "$(dirname "$0")/../../../.." && pwd)"

echo ""
echo "=========================================="
echo "  init-fjtcmd-claude Skill 卸载"
echo "=========================================="
echo ""

TARGET_DIR="$PROJECT_ROOT/.claude/skills/init-fjtcmd-claude"

if [ -d "$TARGET_DIR" ]; then
    rm -rf "$TARGET_DIR"
    echo_info "已删除: .claude/skills/init-fjtcmd-claude/"
else
    echo_info "目录不存在，跳过"
fi

echo ""
echo_info "✅ 卸载完成！"
echo ""
