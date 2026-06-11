#!/bin/bash

# ==========================================
# fjtcmd-hub Demo 模块测试 - 主子表（客户管理 + 商品子表）
# 主表路径前缀：/demo/customer，主键：customerId
# 主表字段：customerName, phonenumber, sex, birthday
# 子表路径前缀：/demo/goods，主键：goodsId
# 子表字段：customerId, name, weight, price, date, type
# 说明：主表新增/修改时通过 goodsList 一并提交子表数据
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
# 客户管理模块测试（主子表）
# ==========================================
test_customer_module() {
    module "=========================================="
    module "客户管理模块测试（主子表）"
    module "=========================================="

    # 1. 查询客户列表
    step "1. 查询客户列表..."
    local list_response=$(curl -s -X GET "$BASE_URL/demo/customer/list?pageNum=1&pageSize=10" \
        -H "Authorization: $TOKEN")
    local list_code=$(echo "$list_response" | jq -r '.code')
    if [ "$list_code" != "200" ]; then
        error "查询客户列表失败"
        echo "$list_response" | jq '.'
        return 1
    fi
    local total=$(echo "$list_response" | jq -r '.total // 0')
    info "客户总数：$total"

    # 2. 新增客户（含子表商品数据）
    step "2. 新增客户（含商品子表）..."
    local add_data='{
        "customerName": "测试客户_curl",
        "phonenumber": "13800138000",
        "sex": "0",
        "birthday": "1990-01-01",
        "remark": "curl 自动化测试客户",
        "goodsList": [
            {
                "name": "测试商品A",
                "weight": 500,
                "price": 19.9,
                "date": "2026-01-01",
                "type": "0"
            },
            {
                "name": "测试商品B",
                "weight": 1000,
                "price": 99.0,
                "date": "2026-02-01",
                "type": "2"
            }
        ]
    }'
    local add_response=$(curl -s -X POST "$BASE_URL/demo/customer" \
        -H "Authorization: $TOKEN" \
        -H "Content-Type: application/json" \
        -d "$add_data")
    local add_code=$(echo "$add_response" | jq -r '.code')
    local add_msg=$(echo "$add_response" | jq -r '.msg')

    if [ "$add_code" == "200" ]; then
        info "新增客户成功（含子表数据）：$add_msg"
    else
        warn "新增客户响应：$add_msg"
    fi

    # 3. 查询列表获取新增客户的 ID
    step "3. 查询列表获取客户 ID..."
    list_response=$(curl -s -X GET "$BASE_URL/demo/customer/list?pageNum=1&pageSize=10" \
        -H "Authorization: $TOKEN")
    local first_id=$(echo "$list_response" | jq -r '.rows[0].customerId // null')

    if [ "$first_id" == "null" ] || [ -z "$first_id" ]; then
        warn "暂无客户数据，跳过详情/修改/删除测试"
        return
    fi
    info "获取到客户 ID: $first_id"

    # 4. 查询客户详情（含子表）
    step "4. 查询客户详情 (ID: $first_id)..."
    local detail_response=$(curl -s -X GET "$BASE_URL/demo/customer/$first_id" \
        -H "Authorization: $TOKEN")
    local detail_code=$(echo "$detail_response" | jq -r '.code')
    if [ "$detail_code" == "200" ]; then
        local customer_name=$(echo "$detail_response" | jq -r '.data.customerName')
        local goods_count=$(echo "$detail_response" | jq -r '.data.goodsList // [] | length')
        info "客户详情：$customer_name, 商品数量: $goods_count"
        if [ "$goods_count" -gt 0 ]; then
            info "✅ 主子表数据关联正常"
        else
            warn "⚠️ 子表数据为空，主子表关联可能有问题"
        fi
    else
        warn "详情查询响应：$(echo "$detail_response" | jq -r '.msg')"
    fi

    # 5. 修改客户（含子表更新）
    step "5. 修改客户 (ID: $first_id)..."
    local update_data="{
        \"customerId\": $first_id,
        \"customerName\": \"测试客户_curl_已修改\",
        \"phonenumber\": \"13900139000\",
        \"sex\": \"1\",
        \"birthday\": \"1991-02-02\",
        \"remark\": \"curl 自动化测试-已修改\",
        \"goodsList\": []
    }"
    local update_response=$(curl -s -X PUT "$BASE_URL/demo/customer" \
        -H "Authorization: $TOKEN" \
        -H "Content-Type: application/json" \
        -d "$update_data")
    local update_code=$(echo "$update_response" | jq -r '.code')
    if [ "$update_code" == "200" ]; then
        info "修改客户成功"
    else
        warn "修改客户响应：$(echo "$update_response" | jq -r '.msg')"
    fi

    # 6. 验证修改结果
    step "6. 验证修改结果..."
    detail_response=$(curl -s -X GET "$BASE_URL/demo/customer/$first_id" \
        -H "Authorization: $TOKEN")
    if [ "$(echo "$detail_response" | jq -r '.code')" == "200" ]; then
        local modified_name=$(echo "$detail_response" | jq -r '.data.customerName')
        local modified_phone=$(echo "$detail_response" | jq -r '.data.phonenumber')
        info "修改后验证：名称=$modified_name, 电话=$modified_phone"
        if [ "$modified_name" == "测试客户_curl_已修改" ]; then
            info "✅ 数据修改验证通过"
        else
            warn "⚠️ 数据修改验证未通过"
        fi
    fi

    # 7. 删除客户
    step "7. 删除客户 (ID: $first_id)..."
    local delete_response=$(curl -s -X DELETE "$BASE_URL/demo/customer/$first_id" \
        -H "Authorization: $TOKEN")
    local delete_code=$(echo "$delete_response" | jq -r '.code')
    if [ "$delete_code" == "200" ]; then
        info "删除客户成功"
    else
        warn "删除客户响应：$(echo "$delete_response" | jq -r '.msg')"
    fi

    # 8. 导出测试
    step "8. 测试导出接口..."
    curl -s -X POST "$BASE_URL/demo/customer/export" \
        -H "Authorization: $TOKEN" \
        -H "Content-Type: application/json" \
        -d '{}' > /dev/null
    info "导出接口调用完成"

    info "客户管理模块（主子表）测试完成"
    echo ""
}

# ==========================================
# 商品管理模块测试（子表独立操作）
# ==========================================
test_goods_module() {
    module "=========================================="
    module "商品管理模块测试（子表独立操作）"
    module "=========================================="

    # 前置：获取一个有效的 customerId
    step "前置：获取关联客户 ID..."
    local customer_list=$(curl -s -X GET "$BASE_URL/demo/customer/list?pageNum=1&pageSize=1" \
        -H "Authorization: $TOKEN")
    local customer_id=$(echo "$customer_list" | jq -r '.rows[0].customerId // null')

    if [ "$customer_id" == "null" ] || [ -z "$customer_id" ]; then
        warn "暂无客户数据，新增一个测试客户用于关联商品"
        curl -s -X POST "$BASE_URL/demo/customer" \
            -H "Authorization: $TOKEN" \
            -H "Content-Type: application/json" \
            -d '{"customerName":"商品测试客户","phonenumber":"13700137000","sex":"0","birthday":"1995-05-05","goodsList":[]}' > /dev/null
        customer_list=$(curl -s -X GET "$BASE_URL/demo/customer/list?pageNum=1&pageSize=1" \
            -H "Authorization: $TOKEN")
        customer_id=$(echo "$customer_list" | jq -r '.rows[0].customerId // null')
    fi
    info "关联客户 ID: $customer_id"

    # 1. 查询商品列表
    step "1. 查询商品列表..."
    local list_response=$(curl -s -X GET "$BASE_URL/demo/goods/list?pageNum=1&pageSize=10" \
        -H "Authorization: $TOKEN")
    local list_code=$(echo "$list_response" | jq -r '.code')
    if [ "$list_code" != "200" ]; then
        error "查询商品列表失败"
        echo "$list_response" | jq '.'
        return 1
    fi
    local total=$(echo "$list_response" | jq -r '.total // 0')
    info "商品总数：$total"

    # 2. 按类型筛选（0=食品）
    step "2. 按类型筛选（食品）..."
    local search_response=$(curl -s -X GET "$BASE_URL/demo/goods/list?pageNum=1&pageSize=10&type=0" \
        -H "Authorization: $TOKEN")
    local search_code=$(echo "$search_response" | jq -r '.code')
    if [ "$search_code" == "200" ]; then
        local search_total=$(echo "$search_response" | jq -r '.total // 0')
        info "食品类商品数：$search_total"
    else
        warn "类型筛选响应异常"
    fi

    # 3. 新增商品
    step "3. 新增商品..."
    local add_data="{
        \"customerId\": $customer_id,
        \"name\": \"测试商品_curl\",
        \"weight\": 500,
        \"price\": 29.9,
        \"date\": \"2026-06-11\",
        \"type\": \"0\",
        \"remark\": \"curl 自动化测试商品\"
    }"
    local add_response=$(curl -s -X POST "$BASE_URL/demo/goods" \
        -H "Authorization: $TOKEN" \
        -H "Content-Type: application/json" \
        -d "$add_data")
    local add_code=$(echo "$add_response" | jq -r '.code')
    local add_msg=$(echo "$add_response" | jq -r '.msg')

    if [ "$add_code" == "200" ]; then
        info "新增商品成功：$add_msg"
    else
        warn "新增商品响应：$add_msg"
    fi

    # 4. 查询列表获取新增商品 ID
    step "4. 查询列表获取商品 ID..."
    list_response=$(curl -s -X GET "$BASE_URL/demo/goods/list?pageNum=1&pageSize=10" \
        -H "Authorization: $TOKEN")
    local first_id=$(echo "$list_response" | jq -r '.rows[0].goodsId // null')

    if [ "$first_id" == "null" ] || [ -z "$first_id" ]; then
        warn "暂无商品数据，跳过详情/修改/删除测试"
        return
    fi
    info "获取到商品 ID: $first_id"

    # 5. 查询商品详情
    step "5. 查询商品详情 (ID: $first_id)..."
    local detail_response=$(curl -s -X GET "$BASE_URL/demo/goods/$first_id" \
        -H "Authorization: $TOKEN")
    local detail_code=$(echo "$detail_response" | jq -r '.code')
    if [ "$detail_code" == "200" ]; then
        local goods_name=$(echo "$detail_response" | jq -r '.data.name')
        local goods_price=$(echo "$detail_response" | jq -r '.data.price')
        info "商品详情：$goods_name（价格：$goods_price）"
    else
        warn "详情查询响应：$(echo "$detail_response" | jq -r '.msg')"
    fi

    # 6. 修改商品
    step "6. 修改商品 (ID: $first_id)..."
    local update_data="{
        \"goodsId\": $first_id,
        \"customerId\": $customer_id,
        \"name\": \"测试商品_curl_已修改\",
        \"weight\": 800,
        \"price\": 39.9,
        \"date\": \"2026-06-11\",
        \"type\": \"2\",
        \"remark\": \"curl 自动化测试商品-已修改\"
    }"
    local update_response=$(curl -s -X PUT "$BASE_URL/demo/goods" \
        -H "Authorization: $TOKEN" \
        -H "Content-Type: application/json" \
        -d "$update_data")
    local update_code=$(echo "$update_response" | jq -r '.code')
    if [ "$update_code" == "200" ]; then
        info "修改商品成功"
    else
        warn "修改商品响应：$(echo "$update_response" | jq -r '.msg')"
    fi

    # 7. 删除商品
    step "7. 删除商品 (ID: $first_id)..."
    local delete_response=$(curl -s -X DELETE "$BASE_URL/demo/goods/$first_id" \
        -H "Authorization: $TOKEN")
    local delete_code=$(echo "$delete_response" | jq -r '.code')
    if [ "$delete_code" == "200" ]; then
        info "删除商品成功"
    else
        warn "删除商品响应：$(echo "$delete_response" | jq -r '.msg')"
    fi

    # 8. 导出测试
    step "8. 测试导出接口..."
    curl -s -X POST "$BASE_URL/demo/goods/export" \
        -H "Authorization: $TOKEN" \
        -H "Content-Type: application/json" \
        -d '{}' > /dev/null
    info "导出接口调用完成"

    info "商品管理模块（子表独立）测试完成"
    echo ""
}

# ==========================================
# 主流程
# ==========================================
main() {
    echo ""
    echo "=========================================="
    echo "  Demo 主子表测试 - 客户管理 + 商品子表"
    echo "=========================================="
    echo ""

    login
    echo ""
    test_customer_module
    test_goods_module

    echo "=========================================="
    info "主子表测试完成！"
    echo "=========================================="
    echo ""
}

main
