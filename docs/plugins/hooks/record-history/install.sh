#!/bin/bash
# Record History Hook 安装脚本 (Linux/macOS)

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo_info()  { echo -e "${GREEN}[INFO]${NC} $1"; }
echo_warn()  { echo -e "${YELLOW}[WARN]${NC} $1"; }
echo_error() { echo -e "${RED}[ERROR]${NC} $1"; }

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../../../.." && pwd)"

echo ""
echo "=========================================="
echo "  Record History Hook 安装"
echo "=========================================="
echo ""

# 获取用户名
get_username() {
    # 1. 尝试 git config
    local git_user=$(git config user.name 2>/dev/null)
    if [ -n "$git_user" ]; then
        echo "$git_user"
        return
    fi

    # 2. 尝试环境变量
    if [ -n "$USER" ]; then
        echo "$USER"
        return
    fi
    if [ -n "$USERNAME" ]; then
        echo "$USERNAME"
        return
    fi

    # 3. 返回空
    echo ""
}

USERNAME=$(get_username)

if [ -z "$USERNAME" ] || [ "$USERNAME" = "unknown" ]; then
    echo_warn "无法自动获取用户名"
    read -p "请输入你的用户名（用于历史记录目录）: " USERNAME
    if [ -z "$USERNAME" ]; then
        echo_error "用户名不能为空"
        exit 1
    fi
fi

echo_info "用户名: $USERNAME"

# 复制 Hook 脚本
echo ""
echo "[1/3] 安装 Hook 脚本..."

HOOKS_DIR="$PROJECT_ROOT/.claude/hooks"
mkdir -p "$HOOKS_DIR"

cp "$SCRIPT_DIR/assets/record-history.js" "$HOOKS_DIR/"
chmod +x "$HOOKS_DIR/record-history.js"
echo_info "已安装: .claude/hooks/record-history.js"

# 配置 settings.local.json
echo ""
echo "[2/3] 配置 settings.local.json..."

SETTINGS_FILE="$PROJECT_ROOT/.claude/settings.local.json"
HOOK_COMMAND="node .claude/hooks/record-history.js"

if [ -f "$SETTINGS_FILE" ]; then
    if grep -q 'record-history.js' "$SETTINGS_FILE"; then
        echo_info "配置已存在，跳过"
    else
        echo_warn "settings.local.json 已存在但未配置此 Hook"
        echo ""
        echo "请手动添加以下权限和 Hook 配置："
        echo ""
        echo "permissions.allow 中添加:"
        echo "  \"Bash($HOOK_COMMAND)\""
        echo ""
        echo "hooks.Stop 中添加:"
        echo '  {"matcher":"*","hooks":[{"type":"command","command":"'"$HOOK_COMMAND"'"}]}'
    fi
else
    cat > "$SETTINGS_FILE" << EOF
{
  "permissions": {
    "allow": [
      "Bash($HOOK_COMMAND)"
    ]
  },
  "hooks": {
    "Stop": [
      {
        "matcher": "*",
        "hooks": [
          {
            "type": "command",
            "command": "$HOOK_COMMAND"
          }
        ]
      }
    ]
  }
}
EOF
    echo_info "已创建: .claude/settings.local.json"
fi

# 创建历史目录
echo ""
echo "[3/3] 创建历史目录..."

HISTORY_DIR="$PROJECT_ROOT/docs/history/$USERNAME"
mkdir -p "$HISTORY_DIR"
echo_info "已创建: docs/history/$USERNAME/"

# 完成
echo ""
echo "=========================================="
echo_info "✅ 安装完成！"
echo "=========================================="
echo ""
echo "历史文件将保存到: docs/history/$USERNAME/"
echo ""
