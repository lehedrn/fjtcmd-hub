#!/bin/bash

# ==========================================
# fjtcmd-hub 登录认证完整测试脚本
# 功能：登录 → 用户信息 → 路由 → 退出登录
# 说明：测试阶段验证码已关闭，直接登录
# ==========================================

set -e

# 配置
BASE_URL="http://localhost:18081"
TOKEN_FILE="/tmp/fjtcmd_hub_token.txt"
USERNAME="admin"
PASSWORD="admin123"

# 颜色输出
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

info()  { echo -e "${GREEN}[INFO]${NC} $1"; }
warn()  { echo -e "${YELLOW}[WARN]${NC} $1"; }
error() { echo -e "${RED}[ERROR]${NC} $1"; }
step()  { echo -e "${BLUE}[STEP]${NC} $1"; }

echo ""
echo "=========================================="
echo "  fjtcmd-hub 登录认证测试脚本"
echo "=========================================="
echo ""

# 步骤 1: 登录
step "步骤 1: 用户登录..."
login_response=$(curl -s -X POST "$BASE_URL/login" \
    -H "Content-Type: application/json" \
    -d "{
        \"username\": \"$USERNAME\",
        \"password\": \"$PASSWORD\",
        \"code\": \"\",
        \"uuid\": \"\"
    }")

login_code=$(echo "$login_response" | jq -r '.code')
login_msg=$(echo "$login_response" | jq -r '.msg')

info "登录响应：code=$login_code, msg=$login_msg"

if [ "$login_code" != "200" ]; then
    error "登录失败：$login_msg"
    echo "完整响应："
    echo "$login_response" | jq '.'
    exit 1
fi

token=$(echo "$login_response" | jq -r '.token')
echo "$token" > "$TOKEN_FILE"
info "登录成功！Token: ${token:0:50}..."

# 步骤 2: 获取用户信息
step "步骤 2: 获取用户信息..."
user_response=$(curl -s -X GET "$BASE_URL/getInfo" \
    -H "Authorization: $token")

user_code=$(echo "$user_response" | jq -r '.code')
if [ "$user_code" != "200" ]; then
    error "获取用户信息失败"
    echo "$user_response" | jq '.'
    exit 1
fi

user_name=$(echo "$user_response" | jq -r '.user.userName')
nick_name=$(echo "$user_response" | jq -r '.user.nickName')
dept_name=$(echo "$user_response" | jq -r '.user.dept.deptName // "无"')
info "用户：$user_name ($nick_name) - 部门：$dept_name"

# 获取角色和权限
roles=$(echo "$user_response" | jq -r '.roles')
permissions=$(echo "$user_response" | jq -r '.permissions')
info "角色：$roles"
info "权限数量：$(echo "$permissions" | jq 'length') 个"

# 步骤 3: 获取路由信息
step "步骤 3: 获取菜单路由..."
routers_response=$(curl -s -X GET "$BASE_URL/getRouters" \
    -H "Authorization: $token")

routers_code=$(echo "$routers_response" | jq -r '.code')
if [ "$routers_code" != "200" ]; then
    error "获取路由失败"
    echo "$routers_response" | jq '.'
    exit 1
fi

menu_count=$(echo "$routers_response" | jq '.data | length')
info "可访问菜单数：$menu_count"

# 显示主要菜单
echo ""
info "主要菜单列表:"
echo "$routers_response" | jq -r '.data[] | "  - \(.name): \(.path) (\(.meta.title // "无标题"))"'

# 步骤 4: 退出登录
step "步骤 4: 退出登录..."
logout_response=$(curl -s -X POST "$BASE_URL/logout" \
    -H "Authorization: $token")

logout_code=$(echo "$logout_response" | jq -r '.code')
logout_msg=$(echo "$logout_response" | jq -r '.msg')

if [ "$logout_code" != "200" ]; then
    warn "退出登录响应异常：$logout_msg"
else
    info "退出登录：$logout_msg"
fi

# 删除本地 Token
rm -f "$TOKEN_FILE"
info "本地 Token 已清除"

# 验证 Token 已失效
step "验证 Token 已失效..."
verify_response=$(curl -s -X GET "$BASE_URL/getInfo" \
    -H "Authorization: $token")
verify_code=$(echo "$verify_response" | jq -r '.code')

if [ "$verify_code" == "200" ]; then
    warn "Token 仍未失效（可能是延迟）"
else
    info "Token 已失效，验证通过"
fi

echo ""
echo "=========================================="
info "登录认证流程测试完成！"
echo "=========================================="
echo ""

exit 0
