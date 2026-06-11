#!/bin/bash

# ==========================================
# fjtcmd-hub Demo 模块测试 - 单表（学生管理）
# 路径前缀：/demo/student
# 主键：studentId
# 字段：studentName, studentAge, studentHobby, studentSex, studentStatus, studentBirthday
# 说明：标准单表 CRUD + 导出，分页查询返回 {code, rows, total}
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
# 学生管理模块测试（单表）
# ==========================================
test_student_module() {
    module "=========================================="
    module "学生管理模块测试（单表）"
    module "=========================================="

    # 1. 查询学生列表
    step "1. 查询学生列表..."
    local list_response=$(curl -s -X GET "$BASE_URL/demo/student/list" \
        -H "Authorization: $TOKEN")
    local list_code=$(echo "$list_response" | jq -r '.code')
    if [ "$list_code" != "200" ]; then
        error "查询学生列表失败"
        echo "$list_response" | jq '.'
        return 1
    fi
    local total=$(echo "$list_response" | jq -r '.total // 0')
    info "学生总数：$total"

    # 2. 新增学生
    step "2. 新增学生..."
    local add_data='{
        "studentName": "测试学生_curl",
        "studentAge": 20,
        "studentSex": "0",
        "studentStatus": "0",
        "studentBirthday": "2006-01-15",
        "studentHobby": "0"
    }'
    local add_response=$(curl -s -X POST "$BASE_URL/demo/student" \
        -H "Authorization: $TOKEN" \
        -H "Content-Type: application/json" \
        -d "$add_data")
    local add_code=$(echo "$add_response" | jq -r '.code')
    local add_msg=$(echo "$add_response" | jq -r '.msg')

    if [ "$add_code" != "200" ]; then
        warn "新增学生响应：$add_msg"
    else
        info "新增学生成功：$add_msg"
    fi

    # 3. 查询列表获取刚新增的学生 ID
    step "3. 查询列表获取学生 ID..."
    list_response=$(curl -s -X GET "$BASE_URL/demo/student/list?pageNum=1&pageSize=10" \
        -H "Authorization: $TOKEN")
    local first_id=$(echo "$list_response" | jq -r '.rows[0].studentId // null')

    if [ "$first_id" == "null" ] || [ -z "$first_id" ]; then
        warn "暂无学生数据，跳过详情/修改/删除测试"
        return
    fi
    info "获取到学生 ID: $first_id"

    # 4. 查询学生详情
    step "4. 查询学生详情 (ID: $first_id)..."
    local detail_response=$(curl -s -X GET "$BASE_URL/demo/student/$first_id" \
        -H "Authorization: $TOKEN")
    local detail_code=$(echo "$detail_response" | jq -r '.code')
    if [ "$detail_code" == "200" ]; then
        local student_name=$(echo "$detail_response" | jq -r '.data.studentName')
        local student_age=$(echo "$detail_response" | jq -r '.data.studentAge')
        info "学生详情：$student_name, 年龄: $student_age"
    else
        warn "详情查询响应：$(echo "$detail_response" | jq -r '.msg')"
    fi

    # 5. 修改学生
    step "5. 修改学生 (ID: $first_id)..."
    local update_data="{
        \"studentId\": $first_id,
        \"studentName\": \"测试学生_curl_已修改\",
        \"studentAge\": 21,
        \"studentSex\": \"0\",
        \"studentStatus\": \"0\",
        \"studentBirthday\": \"2005-02-20\",
        \"studentHobby\": \"1\"
    }"
    local update_response=$(curl -s -X PUT "$BASE_URL/demo/student" \
        -H "Authorization: $TOKEN" \
        -H "Content-Type: application/json" \
        -d "$update_data")
    local update_code=$(echo "$update_response" | jq -r '.code')
    if [ "$update_code" == "200" ]; then
        info "修改学生成功"
    else
        warn "修改学生响应：$(echo "$update_response" | jq -r '.msg')"
    fi

    # 6. 验证修改结果
    step "6. 验证修改结果..."
    detail_response=$(curl -s -X GET "$BASE_URL/demo/student/$first_id" \
        -H "Authorization: $TOKEN")
    if [ "$(echo "$detail_response" | jq -r '.code')" == "200" ]; then
        local modified_name=$(echo "$detail_response" | jq -r '.data.studentName')
        local modified_age=$(echo "$detail_response" | jq -r '.data.studentAge')
        info "修改后验证：名称=$modified_name, 年龄=$modified_age"
        if [ "$modified_name" == "测试学生_curl_已修改" ]; then
            info "✅ 数据修改验证通过"
        else
            warn "⚠️ 数据修改验证未通过"
        fi
    fi

    # 7. 删除学生
    step "7. 删除学生 (ID: $first_id)..."
    local delete_response=$(curl -s -X DELETE "$BASE_URL/demo/student/$first_id" \
        -H "Authorization: $TOKEN")
    local delete_code=$(echo "$delete_response" | jq -r '.code')
    if [ "$delete_code" == "200" ]; then
        info "删除学生成功"
    else
        warn "删除学生响应：$(echo "$delete_response" | jq -r '.msg')"
    fi

    # 8. 导出测试（仅检查接口可用性）
    step "8. 测试导出接口..."
    curl -s -X POST "$BASE_URL/demo/student/export" \
        -H "Authorization: $TOKEN" \
        -H "Content-Type: application/json" \
        -d '{}' > /dev/null
    info "导出接口调用完成"

    info "学生管理模块（单表）测试完成"
    echo ""
}

# ==========================================
# 主流程
# ==========================================
main() {
    echo ""
    echo "=========================================="
    echo "  Demo 单表测试 - 学生管理"
    echo "=========================================="
    echo ""

    login
    echo ""
    test_student_module

    echo "=========================================="
    info "单表测试完成！"
    echo "=========================================="
    echo ""
}

main
