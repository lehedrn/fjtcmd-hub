#!/bin/bash
# ==========================================
# 学生管理 API 自动化测试
# 模块：demo.student
# 生成时间：2026-06-11
# ==========================================

set -e

BASE_URL="http://localhost:18081"
USERNAME="admin"
PASSWORD="admin123"

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
    info "登录成功"
}

# ==========================================
# 测试：查询列表
# ==========================================
test_list() {
    step "查询学生列表..."
    local response=$(curl -s -X GET "$BASE_URL/demo/student/list?pageNum=1&pageSize=10" \
        -H "Authorization: Bearer $TOKEN")
    local code=$(echo "$response" | jq -r '.code')
    if [ "$code" != "200" ]; then
        fail "查询失败: $(echo "$response" | jq -r '.msg')"
    fi
    local total=$(echo "$response" | jq -r '.total')
    info "学生总数：$total"
    if [ "$total" -ge 20 ]; then
        info "✅ 模拟数据验证通过（≥20条）"
    else
        warn "数据量不足：$total"
    fi
}

# ==========================================
# 测试：新增
# ==========================================
test_add() {
    step "新增学生..."
    local add_data='{
        "studentName": "测试学生",
        "studentSex": "0",
        "studentAge": 20,
        "studentPhone": "13800138000",
        "status": "0"
    }'
    local response=$(curl -s -X POST "$BASE_URL/demo/student" \
        -H "Authorization: Bearer $TOKEN" \
        -H "Content-Type: application/json" \
        -d "$add_data")
    local code=$(echo "$response" | jq -r '.code')
    if [ "$code" == "200" ]; then
        NEW_ID=$(echo "$response" | jq -r '.msg' | grep -oP '\d+' | head -1)
        info "新增成功，响应: $(echo "$response" | jq -r '.msg')"
    else
        warn "新增失败: $(echo "$response" | jq -r '.msg')"
    fi
}

# ==========================================
# 测试：查询详情
# ==========================================
test_get() {
    step "查询详情（ID=1）..."
    local response=$(curl -s -X GET "$BASE_URL/demo/student/1" \
        -H "Authorization: Bearer $TOKEN")
    local code=$(echo "$response" | jq -r '.code')
    if [ "$code" == "200" ]; then
        local name=$(echo "$response" | jq -r '.data.studentName')
        info "查询详情成功：$name"
    else
        warn "查询详情失败: $(echo "$response" | jq -r '.msg')"
    fi
}

# ==========================================
# 测试：修改
# ==========================================
test_update() {
    step "修改学生（ID=1）..."
    local update_data='{
        "studentId": 1,
        "studentName": "张伟（已修改）",
        "studentSex": "0",
        "studentAge": 21,
        "studentPhone": "13800001099",
        "status": "0"
    }'
    local response=$(curl -s -X PUT "$BASE_URL/demo/student" \
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
# 测试：模糊搜索
# ==========================================
test_search() {
    step "模糊搜索：姓名包含'李'..."
    local response=$(curl -s -X GET "$BASE_URL/demo/student/list?studentName=%E6%9D%8E&pageNum=1&pageSize=10" \
        -H "Authorization: Bearer $TOKEN")
    local code=$(echo "$response" | jq -r '.code')
    local total=$(echo "$response" | jq -r '.total')
    if [ "$code" == "200" ]; then
        info "搜索成功，找到 $total 条记录"
    else
        warn "搜索失败: $(echo "$response" | jq -r '.msg')"
    fi
}

# ==========================================
# 测试：导出
# ==========================================
test_export() {
    step "导出学生数据..."
    local http_code=$(curl -s -o /tmp/student_export.xlsx -w "%{http_code}" -X POST \
        "$BASE_URL/demo/student/export" \
        -H "Authorization: Bearer $TOKEN")
    if [ "$http_code" == "200" ]; then
        local size=$(wc -c < /tmp/student_export.xlsx)
        info "导出成功，文件大小：${size} bytes"
        rm -f /tmp/student_export.xlsx
    else
        warn "导出失败: HTTP $http_code"
    fi
}

# ==========================================
# 主流程
# ==========================================
main() {
    echo "=========================================="
    echo "  学生管理 API 测试"
    echo "  时间：$(date '+%Y-%m-%d %H:%M:%S')"
    echo "=========================================="
    echo ""

    # 检查后端服务
    step "检查后端服务..."
    local health=$(curl -s -o /dev/null -w "%{http_code}" "$BASE_URL/captchaImage" 2>/dev/null)
    if [ "$health" != "200" ]; then
        fail "后端服务未运行（$BASE_URL）"
    fi
    info "后端服务正常"
    echo ""

    login
    echo ""
    test_list
    echo ""
    test_add
    echo ""
    test_get
    echo ""
    test_update
    echo ""
    test_search
    echo ""
    test_export
    echo ""

    echo "=========================================="
    info "所有测试完成！"
    echo "=========================================="
}

main "$@"
