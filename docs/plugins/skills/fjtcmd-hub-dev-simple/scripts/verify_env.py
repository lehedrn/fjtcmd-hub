#!/usr/bin/env python3
"""
fjtcmd-hub-dev-simple 环境验证脚本

功能：
  --init     首次运行：探测环境 + 交互式确认 + 生成 config.json
  --quick    快速验证：读取 config.json + 验证 DB 连接

依赖：Python 3.6+ 标准库（无第三方依赖）
"""

import json
import os
import re
import subprocess
import sys


SKILL_DIR = os.path.dirname(os.path.abspath(__file__))
CONFIG_PATH = os.path.join(os.path.dirname(SKILL_DIR), "config.json")

# 从脚本位置推断项目根目录（scripts/ -> fjtcmd-hub-dev-simple/ -> skills/ -> .claude/ -> 项目根）
SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
DEFAULT_PROJECT_ROOT = os.path.dirname(
    os.path.dirname(
        os.path.dirname(
            os.path.dirname(SCRIPT_DIR)
        )
    )
)
PROJECT_ROOT = os.environ.get("PROJECT_ROOT", DEFAULT_PROJECT_ROOT)


# ============================================================
# 简易 YAML 解析器（仅处理 application-druid.yml 的简单结构）
# ============================================================
class yaml_parser:
    """极简 YAML 解析器，仅支持键值对和层级缩进，不依赖 PyYAML。"""

    @staticmethod
    def parse_file(filepath):
        """解析 YAML 文件为嵌套字典。"""
        if not os.path.exists(filepath):
            return {}
        with open(filepath, "r", encoding="utf-8") as f:
            lines = f.readlines()

        result = {}
        stack = [(result, -1)]  # (dict, indent_level)

        for line in lines:
            stripped = line.rstrip()
            if not stripped or stripped.lstrip().startswith("#"):
                continue

            indent = len(stripped) - len(stripped.lstrip())
            content = stripped.lstrip()

            if ":" not in content:
                continue

            key, _, value = content.partition(":")
            key = key.strip()
            value = value.strip().strip('"').strip("'")

            # 弹出比当前缩进更深的层级
            while len(stack) > 1 and stack[-1][1] >= indent:
                stack.pop()

            current_dict = stack[-1][0]

            if value:
                current_dict[key] = value
            else:
                new_dict = {}
                current_dict[key] = new_dict
                stack.append((new_dict, indent))

        return result

    @staticmethod
    def get_nested(d, *keys, default=""):
        """从嵌套字典中按路径取值。"""
        current = d
        for key in keys:
            if isinstance(current, dict) and key in current:
                current = current[key]
            else:
                return default
        return current


# ============================================================
# 环境探测函数
# ============================================================

def parse_druid_config():
    """从 application-druid.yml 解析数据库连接信息。"""
    druid_path = os.path.join(
        PROJECT_ROOT,
        "fjtcmd-hub-admin/src/main/resources/application-druid.yml"
    )
    if not os.path.exists(druid_path):
        return None

    data = yaml_parser.parse_file(druid_path)
    master = yaml_parser.get_nested(data, "spring", "datasource", "druid", "master", default={})

    url = master.get("url", "")
    # 从 JDBC URL 解析 host、port、database
    # jdbc:mysql://localhost:3306/ry-vue?useUnicode=true...
    match = re.match(r"jdbc:mysql://([^:]+):(\d+)/([^?]+)", url)
    if match:
        host = match.group(1)
        port = int(match.group(2))
        name = match.group(3)
    else:
        host = "localhost"
        port = 3306
        name = "ry-vue"

    return {
        "host": host,
        "port": port,
        "name": name,
        "user": master.get("username", "root"),
        "password": master.get("password", ""),
    }


def parse_backend_port():
    """从 application.yml 解析后端端口。"""
    app_path = os.path.join(
        PROJECT_ROOT,
        "fjtcmd-hub-admin/src/main/resources/application.yml"
    )
    if not os.path.exists(app_path):
        return 18081

    data = yaml_parser.parse_file(app_path)
    port = yaml_parser.get_nested(data, "server", "port", default="18081")
    try:
        return int(port)
    except (ValueError, TypeError):
        return 18081


def parse_frontend_port():
    """从 vite.config.ts 解析前端端口。"""
    vite_path = os.path.join(PROJECT_ROOT, "fjtcmd-hub-ui/vite.config.ts")
    if not os.path.exists(vite_path):
        return 3888

    with open(vite_path, "r", encoding="utf-8") as f:
        content = f.read()

    match = re.search(r"port:\s*(\d+)", content)
    if match:
        return int(match.group(1))
    return 3888


def check_cli_jar():
    """检查 CLI JAR 是否存在。"""
    jar_path = os.path.join(
        PROJECT_ROOT,
        "fjtcmd-hub-generator-cli/target/fjtcmd-hub-generator-cli.jar"
    )
    return os.path.exists(jar_path)


def test_db_connection(host, port, user, password, db, container=None, charset="utf8mb4"):
    """测试数据库连接。返回 (success: bool, message: str)。"""

    # 方式1：如果有 docker 容器配置，尝试 docker exec
    if container:
        try:
            cmd = [
                "docker", "exec", "-i", container,
                "mysql",
                f"--default-character-set={charset}",
                f"-u{user}", f"-p{password}",
                db,
                "-e", "SELECT 1 AS connected;"
            ]
            result = subprocess.run(cmd, capture_output=True, text=True, timeout=10)
            if result.returncode == 0:
                return True, f"docker exec {container} 连接成功"
        except (FileNotFoundError, subprocess.TimeoutExpired):
            pass

    # 方式2：直接 mysql 连接
    try:
        cmd = [
            "mysql",
            f"-h{host}", f"-P{port}",
            f"-u{user}", f"-p{password}",
            f"--default-character-set={charset}",
            db,
            "-e", "SELECT 1 AS connected;"
        ]
        result = subprocess.run(cmd, capture_output=True, text=True, timeout=10)
        if result.returncode == 0:
            return True, f"mysql -h{host} -P{port} 连接成功"
    except (FileNotFoundError, subprocess.TimeoutExpired):
        pass

    return False, "无法连接数据库（docker 和本地均失败）"


def detect_docker_container():
    """检测是否有运行中的 MySQL 容器。"""
    try:
        result = subprocess.run(
            ["docker", "ps", "--format", "{{.Names}}"],
            capture_output=True, text=True, timeout=5
        )
        if result.returncode == 0:
            containers = result.stdout.strip().split("\n")
            for name in containers:
                if "mysql" in name.lower():
                    return name.strip()
    except (FileNotFoundError, subprocess.TimeoutExpired):
        pass
    return ""


# ============================================================
# 配置生成
# ============================================================

def generate_config(db_info, backend_port, frontend_port, container, db_ok):
    """生成 config.json 内容。"""
    return {
        "_comment": "fjtcmd-hub-dev-simple 环境配置文件。由 verify_env.py --init 自动生成。",
        "_updated": "自动生成",
        "version": "1.1.0",
        "schema_version": 1,

        "database": {
            "host": db_info["host"],
            "port": db_info["port"],
            "name": db_info["name"],
            "user": db_info["user"],
            "password": db_info["password"],
            "dockerContainer": container if db_ok else "",
            "charset": "utf8mb4"
        },

        "server": {
            "backendPort": backend_port,
            "frontendPort": frontend_port
        },

        "generator": {
            "cliJarPath": "fjtcmd-hub-generator-cli/target/fjtcmd-hub-generator-cli.jar",
            "defaultAuthor": "fjtcmd",
            "defaultPackagePrefix": "com.fjtcmd.hub",
            "defaultTablePrefix": "sys_",
            "defaultTplWebType": "element-plus-typescript"
        },

        "paths": {
            "projectRoot": PROJECT_ROOT,
            "requirementsBase": "docs/requirements",
            "generateBase": "generate"
        },

        "modules": {
            "available": ["demo", "biz"],
            "defaultTarget": "demo"
        }
    }


def save_config(config):
    """保存 config.json。"""
    with open(CONFIG_PATH, "w", encoding="utf-8") as f:
        json.dump(config, f, ensure_ascii=False, indent=2)
    print(f"配置文件已保存：{CONFIG_PATH}")


# ============================================================
# 主流程
# ============================================================

def run_init():
    """首次运行：探测 + 交互 + 生成配置。"""
    print("=" * 60)
    print("  fjtcmd-hub-dev-simple 环境初始化")
    print("=" * 60)
    print()

    # 1. 探测数据库配置
    print("[1/5] 探测数据库配置...")
    db_info = parse_druid_config()
    if db_info:
        print(f"  推断结果：{db_info['name']}@{db_info['host']}:{db_info['port']}")
        print(f"  用户名：{db_info['user']}")
    else:
        print("  未找到 application-druid.yml，使用默认值")
        db_info = {"host": "localhost", "port": 3306, "name": "ry-vue", "user": "root", "password": ""}

    # 2. 探测 Docker 容器
    print("\n[2/5] 探测 Docker MySQL 容器...")
    container = detect_docker_container()
    if container:
        print(f"  发现容器：{container}")
    else:
        print("  未发现 MySQL 容器，将使用直接连接")

    # 3. 测试数据库连接
    print("\n[3/5] 测试数据库连接...")
    db_ok, db_msg = test_db_connection(
        db_info["host"], db_info["port"],
        db_info["user"], db_info["password"],
        db_info["name"], container
    )
    status = "✅" if db_ok else "❌"
    print(f"  {status} {db_msg}")

    if not db_ok:
        print("\n  ⚠️  数据库连接失败。可能原因：")
        print("    - 数据库服务未启动")
        print("    - 用户名/密码错误")
        print("    - 数据库不存在")
        print("    - 容器名称不正确")
        print("\n  仍然继续生成配置，请稍后手动修改 config.json 中的数据库信息。")

    # 4. 探测端口
    print("\n[4/5] 探测服务端口...")
    backend_port = parse_backend_port()
    frontend_port = parse_frontend_port()
    print(f"  后端端口：{backend_port}")
    print(f"  前端端口：{frontend_port}")

    # 5. 检查 CLI JAR
    print("\n[5/5] 检查代码生成器...")
    jar_ok = check_cli_jar()
    status = "✅" if jar_ok else "❌"
    print(f"  {status} CLI JAR {'存在' if jar_ok else '不存在，请先编译：cd fjtcmd-hub-generator-cli && mvn package -DskipTests'}")

    # 生成配置
    print("\n" + "=" * 60)
    config = generate_config(db_info, backend_port, frontend_port, container, db_ok)

    print("  即将生成以下配置：")
    print(f"  ┌────────────┬───────────────────────────┐")
    print(f"  │ 数据库      │ {db_info['name']}@{db_info['host']}:{db_info['port']}")
    print(f"  │ 连接方式    │ {'Docker (' + container + ')' if container else '直接连接'}")
    print(f"  │ DB 状态     │ {'✅ 正常' if db_ok else '❌ 失败'}")
    print(f"  │ 后端端口    │ {backend_port}")
    print(f"  │ 前端端口    │ {frontend_port}")
    print(f"  │ CLI JAR    │ {'✅ 存在' if jar_ok else '❌ 不存在'}")
    print(f"  └────────────┴───────────────────────────┘")

    save_config(config)
    print("\n初始化完成！后续使用将自动读取此配置。")
    print(f"如需修改，请编辑：{CONFIG_PATH}")
    print("或重新运行：python verify_env.py --init")

    return config


def run_quick():
    """快速验证：读取配置 + 验证连接。"""
    if not os.path.exists(CONFIG_PATH):
        print("❌ config.json 不存在，请先运行 --init")
        sys.exit(1)

    with open(CONFIG_PATH, "r", encoding="utf-8") as f:
        config = json.load(f)

    db = config.get("database", {})
    container = db.get("dockerContainer", "")
    db_ok, db_msg = test_db_connection(
        db.get("host", "localhost"),
        db.get("port", 3306),
        db.get("user", "root"),
        db.get("password", ""),
        db.get("name", "ry-vue"),
        container,
        db.get("charset", "utf8mb4")
    )

    if db_ok:
        print(f"✅ {db_msg}")
    else:
        print(f"❌ {db_msg}")
        print("请检查 config.json 中的数据库配置，或重新运行 --init")
        sys.exit(1)

    jar_ok = check_cli_jar()
    if not jar_ok:
        print("❌ CLI JAR 不存在")
        sys.exit(1)
    print("✅ CLI JAR 存在")


def main():
    if "--init" in sys.argv:
        run_init()
    elif "--quick" in sys.argv:
        run_quick()
    else:
        print("用法：")
        print("  python verify_env.py --init     首次运行：探测 + 生成配置")
        print("  python verify_env.py --quick    快速验证：检查配置是否可用")
        sys.exit(1)


if __name__ == "__main__":
    main()
