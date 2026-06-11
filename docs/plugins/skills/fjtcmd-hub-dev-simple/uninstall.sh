#!/bin/bash
# fjtcmd-hub-dev-simple Skill 卸载脚本 (Linux/macOS)

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo_info()  { echo -e "${GREEN}[INFO]${NC} $1"; }
echo_warn()  { echo -e "${YELLOW}[WARN]${NC} $1"; }

PROJECT_ROOT="$(cd "$(dirname "$0")/../../.." && pwd)"

echo ""
echo "=========================================="
echo "  fjtcmd-hub-dev-simple Skill 卸载"
echo "=========================================="
echo ""

TARGET_DIR="$PROJECT_ROOT/.claude/skills/fjtcmd-hub-dev-simple"

# 删除 Skill 目录
echo "[1/2] 删除 Skill 文件..."

if [ -d "$TARGET_DIR" ]; then
    rm -rf "$TARGET_DIR"
    echo_info "已删除: .claude/skills/fjtcmd-hub-dev-simple/"
else
    echo_info "目录不存在，跳过"
fi

# 询问是否删除生成的配置
echo ""
echo "[2/2] 清理配置文件..."

CONFIG_FILE="$PROJECT_ROOT/.claude/skills/fjtcmd-hub-dev-simple/config.json"
GENERATE_DIR="$PROJECT_ROOT/generate"

if [ -f "$CONFIG_FILE" ]; then
    read -p "是否删除 config.json？(y/N): " DELETE_CONFIG
    if [[ "$DELETE_CONFIG" =~ ^[Yy]$ ]]; then
        rm -f "$CONFIG_FILE"
        echo_info "已删除: config.json"
    fi
fi

if [ -d "$GENERATE_DIR" ]; then
    read -p "是否删除 generate/ 目录？(y/N): " DELETE_GENERATE
    if [[ "$DELETE_GENERATE" =~ ^[Yy]$ ]]; then
        rm -rf "$GENERATE_DIR"
        echo_info "已删除: generate/"
    fi
fi

# 完成
echo ""
echo "=========================================="
echo_info "✅ 卸载完成！"
echo "=========================================="
echo ""
