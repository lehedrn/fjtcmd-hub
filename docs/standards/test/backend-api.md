# 后端接口自动化测试规范

## 概述

本规范定义 fjtcmd-hub 项目后端接口自动化测试的编写标准、脚本结构和最佳实践。

**目标**：
- 提供可复用的接口测试脚本模板
- 确保测试脚本的可读性和可维护性
- 支持持续集成中的自动化测试

---

## 1. 测试脚本规范

### 1.1 脚本位置

```
scripts/test/
└── curl/                          # curl 测试脚本目录
    ├── README.md                  # 测试脚本使用说明
    ├── test-login.sh              # 登录认证测试
    ├── test-demo-single.sh        # Demo 单表 CRUD 测试
    ├── test-demo-tree.sh          # Demo 树表测试
    └── test-demo-master-detail.sh # Demo 主子表测试
```

### 1.2 命名规范

**脚本命名格式**：`test-[模块]-[场景].sh`

| 组成部分 | 说明 | 示例 |
|---------|------|------|
| `test` | 固定前缀，表示测试脚本 | `test-` |
| `[模块]` | 模块名称（小写，多词用短横线） | `demo`、`system`、`monitor` |
| `[场景]` | 测试场景（小写，多词用短横线） | `single`、`tree`、`master-detail`、`login` |

**常见场景命名**：

| 场景 | 命名 | 说明 |
|------|------|------|
| 登录认证 | `login` | 登录、退出、认证流程 |
| 单表 CRUD | `single` | 单表增删改查 |
| 树表操作 | `tree` | 树形结构查询和操作 |
| 主子表操作 | `master-detail` | 主表 + 子表联合操作 |
| 导入导出 | `import-export` | 文件导入导出测试 |
| 批量操作 | `batch` | 批量增删改查 |
| 权限测试 | `permission` | 权限控制测试 |

**示例**：
```bash
test-login.sh                    # 登录认证测试
test-system-user-single.sh       # 系统模块 - 用户单表 CRUD
test-system-role-tree.sh         # 系统模块 - 角色树表
test-demo-single.sh              # Demo 模块 - 单表 CRUD
test-demo-tree.sh                # Demo 模块 - 树表
test-demo-master-detail.sh       # Demo 模块 - 主子表
test-monitor-operlog-single.sh   # 监控模块 - 操作日志单表
```

### 1.3 脚本分类

**按模块分类**：

| 模块 | 脚本前缀 | 说明 |
|------|---------|------|
| 通用脚本 | `test-common-*.sh` | 公共函数、工具脚本 |
| 登录认证 | `test-login.sh` | 登录认证专用脚本 |
| 系统模块 | `test-system-*.sh` | 系统管理模块测试 |
| Demo 模块 | `test-demo-*.sh` | 示例模块测试 |
| 监控模块 | `test-monitor-*.sh` | 系统监控模块测试 |

---

## 2. 脚本结构规范

### 2.1 基本结构

```bash
#!/bin/bash

# ==========================================
# [模块名称] - [测试场景]
# 功能描述：[详细说明]
# 作者：[作者]
# 创建日期：[日期]
# ==========================================

set -e  # 遇到错误立即退出

# ==========================================
# 配置区
# ==========================================
BASE_URL="http://localhost:18081"
TOKEN_FILE="/tmp/fjtcmd_hub_token.txt"
USERNAME="admin"
PASSWORD="admin123"

# ==========================================
# 颜色输出
# ==========================================
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

# ==========================================
# 日志函数
# ==========================================
info()    { echo -e "${GREEN}[INFO]${NC} $1"; }
warn()    { echo -e "${YELLOW}[WARN]${NC} $1"; }
error()   { echo -e "${RED}[ERROR]${NC} $1"; }
step()    { echo -e "${BLUE}[STEP]${NC} $1"; }
module()  { echo -e "${CYAN}[MODULE]${NC} $1"; }

# ==========================================
# 核心函数
# ==========================================

# 全局变量
TOKEN=""

# 登录函数
login() {
    step "用户登录..."
    local login_response=$(curl -s -X POST "$BASE_URL/login" \
        -H "Content-Type: application/json" \
        -d "{\"username\":\"$USERNAME\",\"password\":\"$PASSWORD\",\"code\":\"\",\"uuid\":\"\"}")

    local login_code=$(echo "$login_response" | jq -r '.code')
    if [ "$login_code" != "200" ]; then
        error "登录失败：$(echo "$login_response" | jq -r '.msg')"
        exit 1
    fi

    TOKEN=$(echo "$login_response" | jq -r '.token')
    info "登录成功"
}

# 主测试函数
test_xxx_module() {
    module "=========================================="
    module "[模块名称] - [测试场景]测试"
    module "=========================================="

    # 测试步骤...
}

# ==========================================
# 主流程
# ==========================================
main() {
    # 1. 检查服务状态
    step "检查后端服务状态..."
    if ! curl -s -o /dev/null -w "%{http_code}" "$BASE_URL/actuator/health" | grep -q "200"; then
        error "后端服务未运行"
        exit 1
    fi
    info "后端服务运行正常"

    # 2. 登录
    login

    # 3. 执行测试
    test_xxx_module

    # 4. 完成
    info "所有测试完成"
}

main "$@"
```

### 2.2 配置项规范

| 配置项 | 默认值 | 说明 |
|--------|--------|------|
| `BASE_URL` | `http://localhost:18081` | 后端服务地址（端口 18081） |
| `TOKEN_FILE` | `/tmp/fjtcmd_hub_token.txt` | Token 临时存储文件 |
| `USERNAME` | `admin` | 测试账号用户名 |
| `PASSWORD` | `admin123` | 测试账号密码 |

**要求**：
- 所有配置项必须使用大写字母命名
- 敏感信息（密码）应通过环境变量覆盖
- Token 文件应存储在临时目录

---

## 3. 核心函数规范

### 3.1 登录函数

```bash
# 全局变量
TOKEN=""

# 登录函数
login() {
    step "用户登录..."
    local login_response=$(curl -s -X POST "$BASE_URL/login" \
        -H "Content-Type: application/json" \
        -d "{\"username\":\"$USERNAME\",\"password\":\"$PASSWORD\",\"code\":\"\",\"uuid\":\"\"}")

    local login_code=$(echo "$login_response" | jq -r '.code')
    if [ "$login_code" != "200" ]; then
        error "登录失败：$(echo "$login_response" | jq -r '.msg')"
        exit 1
    fi

    TOKEN=$(echo "$login_response" | jq -r '.token')
    info "登录成功"
}
```

**要求**：
- 登录函数必须返回 Token 并存储到全局变量
- 登录失败必须退出脚本（`exit 1`）
- 必须使用 `local` 声明局部变量

### 3.2 模块测试函数

```bash
test_student_module() {
    module "=========================================="
    module "学生管理模块测试"
    module "=========================================="

    # 1. 查询列表
    step "1. 查询学生列表..."
    local list_response=$(curl -s -X GET "$BASE_URL/demo/student/list" \
        -H "Authorization: $TOKEN")
    local list_code=$(echo "$list_response" | jq -r '.code')
    if [ "$list_code" != "200" ]; then
        error "查询学生列表失败"
        return 1
    fi
    local total=$(echo "$list_response" | jq -r '.total // 0')
    info "学生总数：$total"

    # 2. 新增
    step "2. 新增学生..."
    local add_data='{
        "studentName": "张三",
        "studentAge": 20,
        "studentSex": "0",
        "studentStatus": "0",
        "studentBirthday": "2006-01-15",
        "studentHobby": "3"
    }'
    local add_response=$(curl -s -X POST "$BASE_URL/demo/student" \
        -H "Authorization: $TOKEN" \
        -H "Content-Type: application/json" \
        -d "$add_data")
    local add_code=$(echo "$add_response" | jq -r '.code')

    if [ "$add_code" != "200" ]; then
        warn "新增学生响应：$(echo "$add_response" | jq -r '.msg')"
    else
        info "新增学生成功"
    fi

    # ... 其他测试步骤

    info "学生管理模块测试完成"
    echo ""
}
```

**要求**：
- 每个模块一个独立测试函数
- 函数命名：`test_<module>_module` 或 `test_<module>_<scene>`
- 每个步骤使用 `step()` 输出说明
- 关键结果使用 `info()` 输出
- 非致命错误使用 `warn()`，致命错误使用 `error()`

---

## 4. HTTP 请求规范

### 4.1 GET 请求

```bash
# 简单 GET
local response=$(curl -s -X GET "$BASE_URL/demo/student/list" \
    -H "Authorization: $TOKEN")

# 带分页 GET
local response=$(curl -s -X GET "$BASE_URL/demo/student/list?pageNum=1&pageSize=10" \
    -H "Authorization: $TOKEN")

# 带参数 GET
local response=$(curl -s -X GET "$BASE_URL/demo/student/1" \
    -H "Authorization: $TOKEN")
```

### 4.2 POST 请求

```bash
# 简单 POST
local response=$(curl -s -X POST "$BASE_URL/demo/student" \
    -H "Authorization: $TOKEN" \
    -H "Content-Type: application/json" \
    -d "$data")
```

### 4.3 PUT 请求

```bash
# 修改操作
local response=$(curl -s -X PUT "$BASE_URL/demo/student" \
    -H "Authorization: $TOKEN" \
    -H "Content-Type: application/json" \
    -d "$data")
```

### 4.4 DELETE 请求

```bash
# 删除操作
local response=$(curl -s -X DELETE "$BASE_URL/demo/student/1" \
    -H "Authorization: $TOKEN")
```

---

## 5. JSON 数据处理规范

### 5.1 解析响应

```bash
# 提取 code
local code=$(echo "$response" | jq -r '.code')

# 提取 msg
local msg=$(echo "$response" | jq -r '.msg')

# 提取 data 字段
local data=$(echo "$response" | jq -r '.data')

# 提取嵌套字段
local user_name=$(echo "$response" | jq -r '.user.userName')

# 提取数组元素
local first_id=$(echo "$response" | jq -r '.rows[0].id // null')

# 检查字段是否存在
local has_goods=$(echo "$response" | jq -r '.data.goodsList // null')
```

### 5.2 构造请求体

```bash
# 简单 JSON 对象
local add_data='{
    "studentName": "张三",
    "studentAge": 20,
    "studentStatus": "0"
}'

# 包含变量的 JSON（使用双引号）
local update_data="{
    \"studentId\": $first_id,
    \"studentName\": \"$new_name\",
    \"studentStatus\": \"0\"
}"

# 使用 jq 构造 JSON（推荐用于复杂场景）
local data=$(jq -n \
    --arg name "$name" \
    --arg age "$age" \
    '{studentName: $name, studentAge: ($age | tonumber)}')
```

---

## 6. 错误处理规范

### 6.1 响应码检查

```bash
local code=$(echo "$response" | jq -r '.code')
if [ "$code" != "200" ]; then
    error "操作失败：$(echo "$response" | jq -r '.msg')"
    return 1  # 或 exit 1
fi
```

### 6.2 空值检查

```bash
local first_id=$(echo "$response" | jq -r '.rows[0].id // null')

if [ "$first_id" != "null" ] && [ -n "$first_id" ]; then
    # 有数据时继续测试
    info "获取到 ID: $first_id"
else
    warn "暂无数据，跳过后续测试"
fi
```

### 6.3 服务可用性检查

```bash
step "检查后端服务状态..."
if ! curl -s -o /dev/null -w "%{http_code}" "$BASE_URL/actuator/health" | grep -q "200"; then
    error "后端服务未运行"
    exit 1
fi
info "后端服务运行正常"
```

---

## 7. 完整示例

### 7.1 示例 1：登录认证测试

**脚本**: `scripts/test/curl/test-login.sh`

```bash
#!/bin/bash

# ==========================================
# fjtcmd-hub 登录认证完整测试脚本
# 功能：登录 → 用户信息 → 路由 → 退出登录
# ==========================================

set -e

BASE_URL="http://localhost:18081"
TOKEN_FILE="/tmp/fjtcmd_hub_token.txt"
USERNAME="admin"
PASSWORD="admin123"

RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

info() { echo -e "${GREEN}[INFO]${NC} $1"; }
error() { echo -e "${RED}[ERROR]${NC} $1"; }
step() { echo -e "${BLUE}[STEP]${NC} $1"; }

# 登录测试
test_login() {
    step "测试登录..."
    local response=$(curl -s -X POST "$BASE_URL/login" \
        -H "Content-Type: application/json" \
        -d "{\"username\":\"$USERNAME\",\"password\":\"$PASSWORD\",\"code\":\"\",\"uuid\":\"\"}")
    local code=$(echo "$response" | jq -r '.code')
    if [ "$code" != "200" ]; then
        error "登录失败"
        exit 1
    fi
    TOKEN=$(echo "$response" | jq -r '.token')
    info "登录成功，Token: ${TOKEN:0:20}..."
}

# 获取用户信息
test_get_user_info() {
    step "获取用户信息..."
    local response=$(curl -s -X GET "$BASE_URL/getInfo" \
        -H "Authorization: $TOKEN")
    local code=$(echo "$response" | jq -r '.code')
    if [ "$code" != "200" ]; then
        error "获取用户信息失败"
        return 1
    fi
    local user_name=$(echo "$response" | jq -r '.user.userName')
    info "当前用户：$user_name"
}

# 主流程
main() {
    test_login
    test_get_user_info
    info "登录认证测试完成"
}

main
```

### 7.2 示例 2：单表 CRUD 测试

**脚本**: `scripts/test/curl/test-demo-single.sh`

```bash
#!/bin/bash

# ==========================================
# Demo 单表 CRUD 测试（学生管理）
# 功能：查询 → 新增 → 修改 → 删除
# ==========================================

set -e

BASE_URL="http://localhost:18081"
USERNAME="admin"
PASSWORD="admin123"

RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

info() { echo -e "${GREEN}[INFO]${NC} $1"; }
error() { echo -e "${RED}[ERROR]${NC} $1"; }
step() { echo -e "${BLUE}[STEP]${NC} $1"; }

# 登录
TOKEN=""
login() {
    step "用户登录..."
    local response=$(curl -s -X POST "$BASE_URL/login" \
        -H "Content-Type: application/json" \
        -d "{\"username\":\"$USERNAME\",\"password\":\"$PASSWORD\",\"code\":\"\",\"uuid\":\"\"}")
    local code=$(echo "$response" | jq -r '.code')
    if [ "$code" != "200" ]; then
        error "登录失败"
        exit 1
    fi
    TOKEN=$(echo "$response" | jq -r '.token')
    info "登录成功"
}

# 测试学生模块（单表 CRUD）
test_student_crud() {
    # 1. 查询列表
    step "1. 查询学生列表..."
    local response=$(curl -s -X GET "$BASE_URL/demo/student/list?pageNum=1&pageSize=10" \
        -H "Authorization: $TOKEN")
    local code=$(echo "$response" | jq -r '.code')
    [ "$code" != "200" ] && error "查询失败" && exit 1
    local total=$(echo "$response" | jq -r '.total')
    info "学生总数：$total"

    # 2. 新增
    step "2. 新增学生..."
    local add_data='{
        "studentName": "张三",
        "studentAge": 20,
        "studentSex": "0",
        "studentStatus": "0",
        "studentBirthday": "2006-01-15",
        "studentHobby": "3"
    }'
    response=$(curl -s -X POST "$BASE_URL/demo/student" \
        -H "Authorization: $TOKEN" \
        -H "Content-Type: application/json" \
        -d "$add_data")
    code=$(echo "$response" | jq -r '.code')
    [ "$code" == "200" ] && info "新增成功" || error "新增失败"

    # 3. 获取新增的 ID
    response=$(curl -s -X GET "$BASE_URL/demo/student/list?pageNum=1&pageSize=10" \
        -H "Authorization: $TOKEN")
    local student_id=$(echo "$response" | jq -r '.rows[0].studentId // null')
    if [ "$student_id" == "null" ] || [ -z "$student_id" ]; then
        warn "无法获取学生 ID，跳过后续测试"
        return
    fi
    info "获取到学生 ID: $student_id"

    # 4. 查询详情
    step "3. 查询学生详情..."
    response=$(curl -s -X GET "$BASE_URL/demo/student/$student_id" \
        -H "Authorization: $TOKEN")
    code=$(echo "$response" | jq -r '.code')
    [ "$code" == "200" ] && info "查询详情成功"

    # 5. 修改
    step "4. 修改学生..."
    local update_data="{
        \"studentId\": $student_id,
        \"studentName\": \"张三修改\",
        \"studentAge\": 21,
        \"studentSex\": \"0\",
        \"studentStatus\": \"0\",
        \"studentBirthday\": \"2006-01-15\",
        \"studentHobby\": \"1\"
    }"
    response=$(curl -s -X PUT "$BASE_URL/demo/student" \
        -H "Authorization: $TOKEN" \
        -H "Content-Type: application/json" \
        -d "$update_data")
    code=$(echo "$response" | jq -r '.code')
    [ "$code" == "200" ] && info "修改成功"

    # 6. 删除
    step "5. 删除学生..."
    response=$(curl -s -X DELETE "$BASE_URL/demo/student/$student_id" \
        -H "Authorization: $TOKEN")
    code=$(echo "$response" | jq -r '.code')
    [ "$code" == "200" ] && info "删除成功"

    info "学生模块 CRUD 测试完成"
}

# 主流程
main() {
    login
    test_student_crud
    info "所有测试完成"
}

main
```

### 7.3 示例 3：树表测试

**脚本**: `scripts/test/curl/test-demo-tree.sh`

**关键差异**：
- 列表接口返回格式：`{code: 200, data: [...]}`（不是 `rows`）
- 不需要分页
- 包含 `parentId` 字段

```bash
# 查询产品列表（树形，不分页）
step "查询产品列表..."
local response=$(curl -s -X GET "$BASE_URL/demo/product/list" \
    -H "Authorization: $TOKEN")
local code=$(echo "$response" | jq -r '.code')
[ "$code" != "200" ] && error "查询失败" && exit 1

# 注意：树形列表返回的是 .data 而不是 .rows
local product_count=$(echo "$response" | jq -r '.data | length')
info "产品总数：$product_count"

# 提取第一个产品 ID（使用 .data[0]）
local first_id=$(echo "$response" | jq -r '.data[0].productId // null')

# 新增产品（需要指定 parentId）
step "新增产品..."
local add_data='{
    "productName": "测试产品 A",
    "productStatus": "0",
    "parentId": 0,
    "orderNum": 1
}'
```

### 7.4 示例 4：主子表测试

**脚本**: `scripts/test/curl/test-demo-master-detail.sh`

**关键差异**：
- 实体类包含 `List<Goods> goodsList` 字段
- 新增/修改时需要构造子表数据
- 删除主表时子表数据级联删除

```bash
# 新增客户（包含商品列表）
step "新增客户..."
local add_data='{
    "customerName": "测试客户",
    "phonenumber": "13800138000",
    "sex": "0",
    "birthday": "1990-01-01",
    "remark": "测试客户备注",
    "goodsList": [
        {
            "goodsName": "商品 A",
            "price": 99.00,
            "stock": 100
        },
        {
            "goodsName": "商品 B",
            "price": 199.00,
            "stock": 50
        }
    ]
}'
response=$(curl -s -X POST "$BASE_URL/demo/customer" \
    -H "Authorization: $TOKEN" \
    -H "Content-Type: application/json" \
    -d "$add_data")
```

---

## 8. 运行规范

### 8.1 执行权限

```bash
chmod +x scripts/test/curl/test-*.sh
```

### 8.2 运行测试

```bash
# 直接运行
./scripts/test/curl/test-login.sh
./scripts/test/curl/test-demo-single.sh
./scripts/test/curl/test-demo-tree.sh
./scripts/test/curl/test-demo-master-detail.sh

# 指定后端地址
BASE_URL="http://192.168.1.100:18081" ./scripts/test/curl/test-demo-single.sh

# 使用测试账号
USERNAME="test" PASSWORD="test123" ./scripts/test/curl/test-login.sh

# 运行所有测试
for script in scripts/test/curl/test-*.sh; do
    echo "运行: $script"
    bash "$script"
    echo ""
done
```

### 8.3 输出重定向

```bash
# 保存日志
./scripts/test/curl/test-demo-single.sh > logs/test-$(date +%Y%m%d).log 2>&1

# 仅查看错误
./scripts/test/curl/test-demo-single.sh 2>&1 | grep ERROR
```

---

## 9. 最佳实践

### 9.1 模块化设计

- 每个功能模块一个测试函数
- 登录逻辑复用一个函数
- 使用 `return` 而非 `exit` 在模块函数内

### 9.2 清晰的日志输出

- 使用颜色区分日志级别
- 每个步骤有明确说明
- 关键数据（如 ID）要输出便于追踪

### 9.3 健壮的错误处理

- 检查服务可用性
- 检查登录状态
- 检查响应码
- 区分致命错误和警告

### 9.4 数据隔离

- 测试数据使用独立标识
- 测试完成后清理数据
- 避免依赖特定数据状态

### 9.5 可配置性

- 使用环境变量覆盖默认配置
- Token 存储使用临时文件
- 支持自定义测试参数

---

## 10. 附录：响应格式参考

### 10.1 成功响应

```json
{
  "code": 200,
  "msg": "操作成功",
  "data": { ... }
}
```

### 10.2 列表响应

```json
{
  "code": 200,
  "msg": "查询成功",
  "total": 10,
  "rows": [ ... ]
}
```

### 10.3 错误响应

```json
{
  "code": 400,
  "msg": "参数错误：studentName 不能为空"
}
```

### 10.4 未授权响应

```json
{
  "code": 401,
  "msg": "登录状态已过期，请重新登录"
}
```

---

## 11. 现有测试脚本清单

| 脚本 | 说明 | 对应模块 |
|------|------|----------|
| `test-login.sh` | 登录认证测试 | 通用 |
| `test-demo-single.sh` | 单表 CRUD 测试 | demo_student |
| `test-demo-tree.sh` | 树表测试 | demo_product |
| `test-demo-master-detail.sh` | 主子表测试 | demo_customer |

---

**文档版本**: 1.0  
**最后更新**: 2026-06-11  
**基于版本**: fjtcmd-hub (后端端口 18081)
