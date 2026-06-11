# Windows 兼容性分析

> 本文档分析项目脚本在 Windows 操作系统下的兼容性问题，提供改进方案供后续参考。

---

## 一、脚本总览

| 类型 | 数量 | Windows 兼容性 |
|------|------|----------------|
| Shell 脚本 (.sh) | 9 个 | 🔴 完全不兼容 |
| Python 脚本 (.py) | 13 个 | 🟢 基本兼容（1 个已修复，1 个低优先级不修复） |

---

## 二、🔴 Shell 脚本问题清单

### 2.1 核心开发脚本（必须解决）

| # | 文件 | 用途 | 不兼容命令 | Windows 替代方案 |
|---|------|------|-----------|-----------------|
| 1 | `scripts/dev/backend.sh` | 后端启停 | `ps -p`, `ps -ef`, `lsof`, `kill`, `kill -9`, `grep -q`, `awk`, `docker ps --format` | `tasklist`, `netstat -ano`, `taskkill`, `findstr` |
| 2 | `scripts/dev/frontend.sh` | 前端启停 | `lsof`, `ps -p`, `kill`, `kill -9`, `pkill -P`, `grep -q` | 同上 |
| 3 | `scripts/build/backend.sh` | 后端编译 | `echo -e`, `case...esac`, `$(cd...pwd)` | `echo`, `if/else`, `%~dp0` |
| 4 | `scripts/build/frontend.sh` | 前端编译 | `echo -e`, `command -v`, `case...esac`, `&>/dev/null` | `where`, `if/else`, `>NUL 2>&1` |

### 2.2 项目 curl 测试脚本

| # | 文件 | 不兼容点 |
|---|------|---------|
| 5 | `scripts/test/curl/test-login.sh` | `/tmp/` 路径、`echo -e` |
| 6 | `scripts/test/curl/test-demo-single.sh` | `/dev/null`、`echo -e` |
| 7 | `scripts/test/curl/test-demo-tree.sh` | `/dev/null`、`echo -e` |
| 8 | `scripts/test/curl/test-demo-student.sh` | `/tmp/`、`/dev/null`、`grep -oP`、`jq`、`wc -c` |
| 9 | `scripts/test/curl/test-demo-master-detail.sh` | `/dev/null`、`echo -e` |

---

## 三、不兼容点详解

| Linux 命令/特性 | 出现次数 | Windows 替代 |
|----------------|---------|-------------|
| `lsof -i :PORT` | 2 | `netstat -ano \| findstr :PORT` |
| `ps -p PID` | 3 | `tasklist /FI "PID eq PID"` |
| `ps -ef \| grep` | 1 | `tasklist \| findstr` |
| `kill PID` | 3 | `taskkill /PID PID` |
| `kill -9 PID` | 2 | `taskkill /F /PID PID` |
| `pkill -P PID` | 1 | `taskkill /T /F /PID PID`（杀进程树）|
| `echo -e "\033[32m"` | ~30 | `echo` 无颜色 或 PowerShell |
| `> /dev/null` | ~15 | `> NUL` |
| `/tmp/xxx` | 4 | `%TEMP%\xxx` |
| `grep -oP '\d+'` | 1 | PowerShell `-match` |
| `grep -q` | ~10 | `findstr >NUL` |
| `case...esac` | 4 | `if/else if/else` |
| `jq` | 2 | 需额外安装或用 PowerShell |
| `awk '{print $2}'` | 1 | `for /f` 或 PowerShell |
| `command -v` | 1 | `where` |
| `$(cd...&& pwd)` | 2 | `%~dp0` |

---

## 四、🟢 Python 脚本状态

| # | 文件 | 行号 | 问题 | 状态 |
|---|------|------|------|------|
| 1 | `verify_env.py` | 21 | ~~硬编码 `PROJECT_ROOT = "/home/workspaces/..."`~~ | ✅ 已修复（从脚本位置推断） |
| 2 | `test_validate_config.py` | 52 | 测试用 `/tmp/test`（不影响正常使用）| ⏭️ 不修复（仅开发测试，P3） |

其余 11 个 Python 脚本使用 `os.path`、`subprocess.run()` 等跨平台 API，**无需修改**。

---

## 五、改进方案

### 方案对比

| 方案 | 需要写 | 优点 | 缺点 | 工作量 |
|------|--------|------|------|--------|
| **A. 编写 .bat 对等脚本** | 4 个 .bat | 原生体验，无额外依赖，入口简单 | 维护两套代码（.sh + .bat） | ~8h |
| B. Python 重写核心脚本 | 4 个 .py + 4 个 .sh + 4 个 .bat | 核心逻辑复用 | 入口文件反而更多 | ~6h |
| C. PowerShell 脚本 | 4 个 .ps1 | Windows 原生，功能强 | Linux 用户不友好 | ~8h |

### 选定方案：A（编写 .bat 对等脚本）

理由：
1. 脚本逻辑不算复杂（主要是进程管理、编译命令）
2. 直接翻译 .sh 到 .bat，减少间接调用
3. 开发者习惯直接执行 `backend.bat start`

目录结构：

```
scripts/
├── dev/
│   ├── backend.sh          # Linux/macOS
│   └── backend.bat         # Windows（新增）
│   ├── frontend.sh
│   └── frontend.bat        # Windows（新增）
└── build/
    ├── backend.sh
    ├── backend.bat         # Windows（新增）
    ├── frontend.sh
    └── frontend.bat        # Windows（新增）
```

---

## 六、优先级建议

| 优先级 | 任务 | 工作量 | 收益 | 状态 |
|--------|------|--------|------|------|
| ~~**P0**~~ | ~~`backend.bat`~~ | ~~2h~~ | Windows 能启动后端 | ✅ 已完成 |
| ~~**P0**~~ | ~~`frontend.bat`~~ | ~~1.5h~~ | Windows 能启动前端 | ✅ 已完成 |
| ~~**P1**~~ | ~~`build-backend.bat`~~ | ~~1h~~ | Windows 能编译后端 | ✅ 已完成 |
| ~~**P1**~~ | ~~`build-frontend.bat`~~ | ~~0.5h~~ | Windows 能编译前端 | ✅ 已完成 |
| ~~**P1**~~ | ~~修复 `verify_env.py` 硬编码~~ | ~~15min~~ | 跨平台环境检测 | ✅ 已完成 |
| ~~**P2**~~ | ~~curl 测试 .bat 重写~~ | ~~3h~~ | 跨平台测试 | ✅ 已完成 |
| ~~**P3**~~ | ~~`CLAUDE.md` 路径说明~~ | ~~5min~~ | 文档准确性 | ⏭️ 不修复 |

**已完成工作量**：~8h  
**剩余工作**：无  
**剩余工作量**：~3h

---

## 七、时间线建议

| 阶段 | 完成时间 | 内容 |
|------|---------|------|
| P0+P1 | 2026-06-11 | 核心开发脚本 Windows 支持（4 个 .bat） |
| P2 | 2026-06-11 | curl 测试脚本 Windows 支持（5 个 .bat） |
| P3 | - | ⏭️ 不修复 |

---

## 八、硬编码路径清单

以下文件中存在硬编码的绝对路径 `/home/workspaces/com/ztq/tcmd/fjtcmd-hub`：

### 文件清单

| # | 文件 | 行号 | 硬编码内容 | 状态 |
|---|------|------|-----------|------|
| 1 | `CLAUDE.md` | 31 | 项目根目录 | ⏭️ 暂不修复 |
| 2 | `application.yml` | 11 | `profile: /home/.../uploadPath` | ⏭️ 暂不修复 |
| 3 | `Getting-Started.md` | 250, 297 | `cd /home/...` | ⏭️ 暂不修复 |
| 4 | `04-模板体系.md` | 390 | `ruoyi.profile: /home/...` | ⏭️ 暂不修复 |
| 5 | `verify_env.py` | 21 | ~~`PROJECT_ROOT = "/home/..."`~~ | ✅ 已修复（动态推断） |
| 6 | `config.json` | 27 | `"projectRoot": "/home/..."` | ⏭️ 暂不修复（由 verify_env.py 自动生成正确值） |

### 不修改的文件

| 目录 | 原因 |
|------|------|
| `docs/history/` | 历史记录，保持原貌 |
| `docs/superpowers/specs/` | 设计文档，历史参考 |

### 说明

硬编码路径问题在 Windows 协作者加入时再统一处理。当前 `verify_env.py` 已能正确推断并写入 `config.json`，其他文件的硬编码不影响功能运行。

---

## 更新记录

| 日期 | 内容 |
|------|------|
| 2026-06-11 | 初始版本，完成脚本兼容性分析和硬编码路径清单 |
| 2026-06-11 | 修复 `verify_env.py` 硬编码路径（改为从脚本位置动态推断） |
| 2026-06-11 | 完成 P0+P1：创建 4 个 .bat 对等脚本（backend/frontend/build-backend/build-frontend） |
| 2026-06-11 | 完成 P2：创建 5 个 curl 测试 .bat 脚本 |
