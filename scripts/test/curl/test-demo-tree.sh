#!/bin/bash

# ==========================================
# fjtcmd-hub Demo 模块测试 - 树表（产品管理）
# 路径前缀：/demo/product
# 主键：productId
# 字段：productName, parentId, orderNum, status
# 说明：树形结构，list 返回 AjaxResult {code, data:[...]}，不分页
# ==========================================

set -e

# 配置
BASE_URL="http://localhost:18081"
USERNAME="admin"
PASSWORD="admin123"

# 颜色输出
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

info()   { echo -e "${GREEN}[INFO]${NC} $1"; }
warn()   { echo -e "${YELLOW}[WARN]${NC} $1"; }
error()  { echo -e "${RED}[ERROR]${NC} $1"; }
step()   { echo -e "${BLUE}[STEP]${NC} $1"; }
module() { echo -e "${CYAN}[MODULE]${NC} $1"; }

TOKEN=""

# 登录
login() {
    step "用户登录..."
    local response=$(curl -s -X POST "$BASE_URL/login" \
        -H "Content-Type: application/json" \
        -d "{\"username\":\"$USERNAME\",\"password\":\"$PASSWORD\",\"code\":\"\",\"uuid\":\"\"}")
    local code=$(echo "$response" | jq -r '.code')
    if [ "$code" != "200" ]; then
        error "登录失败：$(echo "$response" | jq -r '.msg')"
        exit 1
    fi
    TOKEN=$(echo "$response" | jq -r '.token')
    info "登录成功"
}

# ==========================================
# 产品管理模块测试（树表）
# ==========================================
test_product_module() {
    module "=========================================="
    module "产品管理模块测试（树表）"
    module "=========================================="

    # 1. 查询产品列表（树表不分页，返回 {code, data:[...]})
    step "1. 查询产品列表..."
    local list_response=$(curl -s -X GET "$BASE_URL/demo/product/list" \
        -H "Authorization: $TOKEN")
    local list_code=$(echo "$list_response" | jq -r '.code')
    if [ "$list_code" != "200" ]; then
        error "查询产品列表失败"
        echo "$list_response" | jq '.'
        return 1
    fi
    local product_count=$(echo "$list_response" | jq -r '.data | length')
    info "产品总数：$product_count"

    # 2. 新增产品（parentId=0 表示顶级节点）
    step "2. 新增产品..."
    local add_data='{
        "productName": "测试产品_curl",
        "parentId": 0,
        "orderNum": 99,
        "status": "0"
    }'
    local add_response=$(curl -s -X POST "$BASE_URL/demo/product" \
        -H "Authorization: $TOKEN" \
        -H "Content-Type: application/json" \
        -d "$add_data")
    local add_code=$(echo "$add_response" | jq -r '.code')
    local add_msg=$(echo "$add_response" | jq -r '.msg')

    if [ "$add_code" == "200" ]; then
        info "新增产品成功：$add_msg"
    else
        warn "新增产品响应：$add_msg"
    fi

    # 3. 查询列表获取新增产品的 ID（树表返回 data 数组）
    step "3. 查询列表获取产品 ID..."
    list_response=$(curl -s -X GET "$BASE_URL/demo/product/list" \
        -H "Authorization: $TOKEN")
    local first_id=$(echo "$list_response" | jq -r '.data[0].productId // null')

    if [ "$first_id" == "null" ] || [ -z "$first_id" ]; then
        warn "暂无产品数据，跳过详情/修改/删除测试"
        return
    fi
    info "获取到产品 ID: $first_id"

    # 4. 查询产品详情
    step "4. 查询产品详情 (ID: $first_id)..."
    local detail_response=$(curl -s -X GET "$BASE_URL/demo/product/$first_id" \
        -H "Authorization: $TOKEN")
    local detail_code=$(echo "$detail_response" | jq -r '.code')
    if [ "$detail_code" == "200" ]; then
        local product_name=$(echo "$detail_response" | jq -r '.data.productName')
        local parent_id=$(echo "$detail_response" | jq -r '.data.parentId')
        info "产品详情：$product_name, parentId: $parent_id"
    else
        warn "详情查询响应：$(echo "$detail_response" | jq -r '.msg')"
    fi

    # 5. 修改产品
    step "5. 修改产品 (ID: $first_id)..."
    local update_data="{
        \"productId\": $first_id,
        \"productName\": \"测试产品_curl_已修改\",
        \"parentId\": 0,
        \"orderNum\": 98,
        \"status\": \"0\"
    }"
    local update_response=$(curl -s -X PUT "$BASE_URL/demo/product" \
        -H "Authorization: $TOKEN" \
        -H "Content-Type: application/json" \
        -d "$update_data")
    local update_code=$(echo "$update_response" | jq -r '.code')
    if [ "$update_code" == "200" ]; then
        info "修改产品成功"
    else
        warn "修改产品响应：$(echo "$update_response" | jq -r '.msg')"
    fi

    # 6. 验证修改结果
    step "6. 验证修改结果..."
    detail_response=$(curl -s -X GET "$BASE_URL/demo/product/$first_id" \
        -H "Authorization: $TOKEN")
    if [ "$(echo "$detail_response" | jq -r '.code')" == "200" ]; then
        local modified_name=$(echo "$detail_response" | jq -r '.data.productName')
        info "修改后验证：名称=$modified_name"
        if [ "$modified_name" == "测试产品_curl_已修改" ]; then
            info "✅ 数据修改验证通过"
        else
            warn "⚠️ 数据修改验证未通过"
        fi
    fi

    # 7. 删除产品
    step "7. 删除产品 (ID: $first_id)..."
    local delete_response=$(curl -s -X DELETE "$BASE_URL/demo/product/$first_id" \
        -H "Authorization: $TOKEN")
    local delete_code=$(echo "$delete_response" | jq -r '.code')
    if [ "$delete_code" == "200" ]; then
        info "删除产品成功"
    else
        warn "删除产品响应：$(echo "$delete_response" | jq -r '.msg')"
    fi

    # 8. 导出测试
    step "8. 测试导出接口..."
    curl -s -X POST "$BASE_URL/demo/product/export" \
        -H "Authorization: $TOKEN" \
        -H "Content-Type: application/json" \
        -d '{}' > /dev/null
    info "导出接口调用完成"

    info "产品管理模块（树表）测试完成"
    echo ""
}

# ==========================================
# 主流程
# ==========================================
main() {
    echo ""
    echo "=========================================="
    echo "  Demo 树表测试 - 产品管理"
    echo "=========================================="
    echo ""

    login
    echo ""
    test_product_module

    echo "=========================================="
    info "树表测试完成！"
    echo "=========================================="
    echo ""
}

main
