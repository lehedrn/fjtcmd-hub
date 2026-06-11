#!/bin/bash
# ==========================================
# curl 测试脚本模板
# 模块：{模块名称}
# 功能：{模块名称} API 自动化测试
# 生成时间：{日期}
# ==========================================

set -e

BASE_URL="http://localhost:18081"
TOKEN_FILE="/tmp/fjtcmd_hub_token.txt"
USERNAME="admin"
PASSWORD="admin123"

# 颜色输出
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[0;33m'
NC='\033[0m'

info()  { echo -e "${GREEN}[PASS]${NC} $1"; }
fail()  { echo -e "${RED}[FAIL]${NC} $1"; exit 1; }
step()  { echo -e "${BLUE}[STEP]${NC} $1"; }
warn()  { echo -e "${YELLOW}[WARN]${NC} $1"; }

# ==========================================
# 登录
# ==========================================
login() {
    step "用户登录..."
    local response=$(curl -s -X POST "$BASE_URL/login" \
        -H "Content-Type: application/json" \
        -d "{\"username\":\"$USERNAME\",\"password\":\"$PASSWORD\",\"code\":\"\",\"uuid\":\"\"}")
    local code=$(echo "$response" | jq -r '.code')
    if [ "$code" != "200" ]; then
        fail "登录失败: $(echo "$response" | jq -r '.msg')"
    fi
    TOKEN=$(echo "$response" | jq -r '.token')
    echo "$TOKEN" > "$TOKEN_FILE"
    info "登录成功"
}

# ==========================================
# 测试：查询列表
# ==========================================
test_list() {
    step "查询{模块名称}列表..."
    local response=$(curl -s -X GET "$BASE_URL/{module}/{business}/list?pageNum=1&pageSize=10" \
        -H "Authorization: Bearer $TOKEN")
    local code=$(echo "$response" | jq -r '.code')
    if [ "$code" != "200" ]; then
        fail "查询失败: $(echo "$response" | jq -r '.msg')"
    fi
    local total=$(echo "$response" | jq -r '.total')
    info "{模块名称}总数：$total"
}

# ==========================================
# 测试：新增
# ==========================================
test_add() {
    step "新增{模块名称}..."
    # TODO: 根据实际字段修改新增数据
    local add_data='{
        "name": "测试数据",
        "status": "0"
    }'
    local response=$(curl -s -X POST "$BASE_URL/{module}/{business}" \
        -H "Authorization: Bearer $TOKEN" \
        -H "Content-Type: application/json" \
        -d "$add_data")
    local code=$(echo "$response" | jq -r '.code')
    if [ "$code" == "200" ]; then
        info "新增成功"
    else
        warn "新增失败: $(echo "$response" | jq -r '.msg')"
    fi
}

# ==========================================
# 测试：查询详情
# ==========================================
test_get() {
    step "查询详情..."
    local response=$(curl -s -X GET "$BASE_URL/{module}/{business}/1" \
        -H "Authorization: Bearer $TOKEN")
    local code=$(echo "$response" | jq -r '.code')
    if [ "$code" == "200" ]; then
        info "查询详情成功"
    else
        warn "查询详情失败: $(echo "$response" | jq -r '.msg')"
    fi
}

# ==========================================
# 测试：修改
# ==========================================
test_update() {
    step "修改{模块名称}..."
    local update_data='{
        "id": 1,
        "name": "修改后的数据",
        "status": "0"
    }'
    local response=$(curl -s -X PUT "$BASE_URL/{module}/{business}" \
        -H "Authorization: Bearer $TOKEN" \
        -H "Content-Type: application/json" \
        -d "$update_data")
    local code=$(echo "$response" | jq -r '.code')
    if [ "$code" == "200" ]; then
        info "修改成功"
    else
        warn "修改失败: $(echo "$response" | jq -r '.msg')"
    fi
}

# ==========================================
# 测试：导出
# ==========================================
test_export() {
    step "导出{模块名称}..."
    local http_code=$(curl -s -o /dev/null -w "%{http_code}" -X POST \
        "$BASE_URL/{module}/{business}/export" \
        -H "Authorization: Bearer $TOKEN")
    if [ "$http_code" == "200" ]; then
        info "导出成功"
    else
        warn "导出失败: HTTP $http_code"
    fi
}

# ==========================================
# 主流程
# ==========================================
main() {
    echo "=========================================="
    echo "  {模块名称} API 测试"
    echo "  时间：$(date '+%Y-%m-%d %H:%M:%S')"
    echo "=========================================="

    # 检查后端服务
    step "检查后端服务..."
    local health=$(curl -s -o /dev/null -w "%{http_code}" "$BASE_URL/captchaImage" 2>/dev/null)
    if [ "$health" != "200" ]; then
        fail "后端服务未运行（$BASE_URL）"
    fi
    info "后端服务正常"

    login
    test_list
    test_add
    test_get
    test_update
    test_export

    echo ""
    echo "=========================================="
    info "所有测试完成！"
    echo "=========================================="
}

main "$@"
