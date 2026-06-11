#!/bin/bash
# init-fjtcmd-claude Skill 安装脚本 (Linux/macOS)

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
echo "  init-fjtcmd-claude Skill 安装"
echo "=========================================="
echo ""

TARGET_DIR="$PROJECT_ROOT/.claude/skills/init-fjtcmd-claude"

# 检查是否已存在
if [ -d "$TARGET_DIR" ]; then
    echo_warn "Skill 目录已存在: $TARGET_DIR"
    read -p "是否覆盖？(y/N): " OVERWRITE
    if [[ ! "$OVERWRITE" =~ ^[Yy]$ ]]; then
        echo_info "取消安装"
        exit 0
    fi
    rm -rf "$TARGET_DIR"
fi

# 复制 Skill 文件
echo "[1/1] 复制 Skill 文件..."

mkdir -p "$TARGET_DIR/assets"

cp "$SCRIPT_DIR/SKILL.md" "$TARGET_DIR/"
cp "$SCRIPT_DIR/README.md" "$TARGET_DIR/"
cp "$SCRIPT_DIR/assets/CLAUDE-TEMPLATE.md" "$TARGET_DIR/assets/"

echo_info "已安装: .claude/skills/init-fjtcmd-claude/"

echo ""
echo "=========================================="
echo_info "✅ 安装完成！"
echo "=========================================="
echo ""
echo "使用方式："
echo "  /fjtcmd-hub-init-claude"
echo ""
