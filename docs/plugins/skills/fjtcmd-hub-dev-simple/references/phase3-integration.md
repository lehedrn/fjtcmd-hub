# 阶段 3：集成部署

**读取时机**：Step 3 开始时
**前置产出**：代码已拷贝到目标模块，TODO 已实现（简单业务模板）

---

## 执行流程

### 步骤 3a：执行菜单 SQL

菜单 SQL 在 CLI 生成时自动创建，位于：
`generate/{module}/{business}/output/{business}Menu.sql`

```bash
python3 .claude/skills/fjtcmd-hub-dev-simple/scripts/db_executor.py exec \
  --file generate/{module}/{business}/output/{business}Menu.sql
```

执行前展示 SQL 内容让用户确认。

### 步骤 3b：全量编译后端

```bash
cd /home/workspaces/com/ztq/tcmd/fjtcmd-hub
./scripts/build/backend.sh clean-install
```

编译时间约 1-3 分钟。编译失败时根据错误信息修复。

### 步骤 3c：重启后端服务

```bash
./scripts/dev/backend.sh start
```

等待启动完成，检查端口是否可用：

```bash
curl -s -o /dev/null -w "%{http_code}" http://localhost:18081/captchaImage
```

返回 200 表示启动成功。

### 步骤 3d：重启前端服务

```bash
./scripts/dev/frontend.sh start
```

前端使用 Vite 开发服务器，启动很快。

### 步骤 3e：用户确认

请用户执行以下操作：

1. 登录系统（http://localhost:3888）
2. 进入菜单管理，检查新菜单是否显示
3. 点击"刷新缓存"按钮
4. 检查新菜单对应的页面是否正常加载

---

## 完成标志

- ✅ 菜单 SQL 已执行
- ✅ 后端编译成功
- ✅ 后端服务已重启
- ✅ 前端服务已重启
- ✅ 用户确认菜单显示正常

进入阶段 4（验证与文档）。
