#!/bin/bash
# fjtcmd-hub-dev-simple Skill 安装脚本 (Linux/macOS)

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo_info()  { echo -e "${GREEN}[INFO]${NC} $1"; }
echo_warn()  { echo -e "${YELLOW}[WARN]${NC} $1"; }
echo_error() { echo -e "${RED}[ERROR]${NC} $1"; }

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../../.." && pwd)"

echo ""
echo "=========================================="
echo "  fjtcmd-hub-dev-simple Skill 安装"
echo "=========================================="
echo ""

# 1. 复制 Skill 目录
echo "[1/2] 复制 Skill 文件..."

TARGET_DIR="$PROJECT_ROOT/.claude/skills/fjtcmd-hub-dev-simple"

if [ -d "$TARGET_DIR" ]; then
    echo_warn "Skill 目录已存在: $TARGET_DIR"
    read -p "是否覆盖？(y/N): " OVERWRITE
    if [[ ! "$OVERWRITE" =~ ^[Yy]$ ]]; then
        echo_info "取消安装"
        exit 0
    fi
    rm -rf "$TARGET_DIR"
fi

# 复制文件（排除 __pycache__ 和 config.json）
rsync -av --exclude='__pycache__' --exclude='config.json' \
    "$SCRIPT_DIR/fjtcmd-hub-dev-simple/" \
    "$TARGET_DIR/" > /dev/null

echo_info "已复制: .claude/skills/fjtcmd-hub-dev-simple/"

# 2. 初始化配置
echo ""
echo "[2/2] 初始化环境配置..."

VERIFY_SCRIPT="$TARGET_DIR/scripts/verify_env.py"
if [ -f "$VERIFY_SCRIPT" ]; then
    python3 "$VERIFY_SCRIPT" --init
else
    echo_warn "未找到 verify_env.py，跳过配置初始化"
    echo "请手动运行: python3 .claude/skills/fjtcmd-hub-dev-simple/scripts/verify_env.py --init"
fi

# 完成
echo ""
echo "=========================================="
echo_info "✅ 安装完成！"
echo "=========================================="
echo ""
echo "使用方式："
echo "  /fjtcmd-hub-dev-simple 我要做一个学生管理功能"
echo ""
