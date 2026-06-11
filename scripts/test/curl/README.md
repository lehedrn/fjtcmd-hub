# Curl 接口测试脚本

用于快速验证后端 API 可用性，适合开发调试和健康检查。

## 前置条件

- `curl`、`jq` 已安装（`apt install curl jq`）
- 后端服务已启动（端口 18081）：`./scripts/dev/backend.sh start`
- 测试阶段验证码已关闭

## 脚本列表

| 文件 | 说明 | 接口数 |
|------|------|--------|
| `test-login.sh` | 登录认证完整流程（登录→用户信息→路由→退出→Token 失效验证） | 5 |
| `test-demo-single.sh` | Demo 单表测试 — 学生管理 CRUD + 导出 | 8 |
| `test-demo-tree.sh` | Demo 树表测试 — 产品管理 CRUD + 导出 | 8 |
| `test-demo-master-detail.sh` | Demo 主子表测试 — 客户管理（含商品子表）+ 商品独立 CRUD | 16 |

## 快速使用

```bash
# 测试登录流程
./scripts/test/curl/test-login.sh

# 测试单表（学生管理）
./scripts/test/curl/test-demo-single.sh

# 测试树表（产品管理）
./scripts/test/curl/test-demo-tree.sh

# 测试主子表（客户管理 + 商品子表）
./scripts/test/curl/test-demo-master-detail.sh
```

## 配置说明

每个脚本开头都有以下配置变量，按需修改：

```bash
BASE_URL="http://localhost:18081"   # 后端地址
USERNAME="admin"                     # 登录用户名
PASSWORD="admin123"                  # 登录密码
```

## 三种表类型的接口对比

| 特性 | 单表（学生） | 树表（产品） | 主子表（客户+商品） |
|------|-------------|-------------|-------------------|
| 路径前缀 | `/demo/student` | `/demo/product` | `/demo/customer` + `/demo/goods` |
| 主键 | `studentId` | `productId` | `customerId` / `goodsId` |
| list 返回格式 | `{code, rows, total}` | `{code, data:[...]}` | `{code, rows, total}` |
| 是否分页 | 是（startPage） | 否（树表全量返回） | 是（startPage） |
| 特殊字段 | — | `parentId`, `orderNum` | 客户含 `goodsList` 子表字段 |
| 新增请求体 | 仅主表字段 | 含 `parentId` | 主表字段 + `goodsList` 数组 |

## 注意事项

- 脚本中的新增/修改/删除操作会实际写入数据库，建议在开发环境使用
- 主子表测试中，商品模块会自动获取已有客户 ID 作为关联
- 每个脚本包含完整的登录流程，无需先执行 `test-login.sh`
- 每个脚本都有"验证修改结果"步骤，确保数据确实被修改
