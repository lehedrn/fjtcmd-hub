#!/bin/bash
# Record History Hook 安装脚本
# 用法：bash docs/plugins/hooks/install-record-history.sh

set -e

# 颜色
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo_info()  { echo -e "${GREEN}[INFO]${NC} $1"; }
echo_warn()  { echo -e "${YELLOW}[WARN]${NC} $1"; }
echo_error() { echo -e "${RED}[ERROR]${NC} $1"; }

# 获取项目根目录
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../../.." && pwd)"

echo ""
echo "=========================================="
echo "  Record History Hook 安装"
echo "=========================================="
echo ""

# 获取 git 用户名
GIT_USERNAME=$(git config user.name 2>/dev/null || echo "")
if [ -z "$GIT_USERNAME" ]; then
    echo_warn "未配置 git user.name，使用系统用户名"
    GIT_USERNAME=${USER:-unknown}
fi
echo_info "用户名: $GIT_USERNAME"

# 1. 复制 Hook 脚本
echo ""
echo "[1/3] 复制 Hook 脚本..."

HOOKS_DIR="$PROJECT_ROOT/.claude/hooks"
mkdir -p "$HOOKS_DIR"

SOURCE_SCRIPT="$SCRIPT_DIR/assets/record-history.js"
TARGET_SCRIPT="$HOOKS_DIR/record-history.js"

if [ ! -f "$SOURCE_SCRIPT" ]; then
    echo_error "源文件不存在: $SOURCE_SCRIPT"
    exit 1
fi

cp "$SOURCE_SCRIPT" "$TARGET_SCRIPT"
chmod +x "$TARGET_SCRIPT"
echo_info "已复制: $TARGET_SCRIPT"

# 2. 配置 settings.local.json
echo ""
echo "[2/3] 配置 settings.local.json..."

SETTINGS_FILE="$PROJECT_ROOT/.claude/settings.local.json"

# 检查是否已存在 settings 文件
if [ -f "$SETTINGS_FILE" ]; then
    # 检查是否已配置 Stop hook
    if grep -q '"Stop"' "$SETTINGS_FILE" && grep -q 'record-history.js' "$SETTINGS_FILE"; then
        echo_info "配置已存在，跳过"
    else
        echo_warn "settings.local.json 已存在但未配置 Stop hook"
        echo_warn "请手动添加以下配置到 hooks.Stop 数组中:"
        echo ""
        cat << 'EOF'
{
  "matcher": "*",
  "hooks": [
    {
      "type": "command",
      "command": "node .claude/hooks/record-history.js"
    }
  ]
}
EOF
    fi
else
    # 创建新的 settings 文件
    cat > "$SETTINGS_FILE" << EOF
{
  "permissions": {
    "allow": []
  },
  "hooks": {
    "Stop": [
      {
        "matcher": "*",
        "hooks": [
          {
            "type": "command",
            "command": "node .claude/hooks/record-history.js"
          }
        ]
      }
    ]
  }
}
EOF
    echo_info "已创建: $SETTINGS_FILE"
fi

# 3. 创建历史目录
echo ""
echo "[3/3] 创建历史目录..."

HISTORY_DIR="$PROJECT_ROOT/docs/history/$GIT_USERNAME"
mkdir -p "$HISTORY_DIR"
echo_info "已创建: $HISTORY_DIR"

# 完成
echo ""
echo "=========================================="
echo_info "安装完成！"
echo "=========================================="
echo ""
echo "已安装:"
echo "  - Hook 脚本: $TARGET_SCRIPT"
echo "  - 历史目录: $HISTORY_DIR"
echo ""
echo "配置:"
echo "  - settings.local.json: $SETTINGS_FILE"
echo ""

# 检查是否需要手动配置
if [ -f "$SETTINGS_FILE" ] && ! grep -q 'record-history.js' "$SETTINGS_FILE"; then
    echo_warn "注意: settings.local.json 需要手动配置 Stop hook"
    echo "请参考文档: docs/plugins/hooks/record-history.md"
fi

echo ""
echo "验证命令:"
echo "  ls -la .claude/hooks/record-history.js"
echo "  ls docs/history/"
echo ""
