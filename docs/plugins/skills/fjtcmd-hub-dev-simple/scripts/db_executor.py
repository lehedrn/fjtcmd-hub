#!/usr/bin/env python3
"""
fjtcmd-hub-dev-simple SQL 统一执行器

功能：
  exec --file <path>     执行 SQL 文件
  exec --sql "<sql>"     执行 SQL 语句
  query --sql "<sql>"    执行查询并展示结果

特性：
  - 自动读取 config.json 获取数据库连接信息
  - 自动适配 docker exec / 本地 mysql 连接
  - 强制使用 --default-character-set=utf8mb4
"""

import argparse
import json
import os
import subprocess
import sys


SKILL_DIR = os.path.dirname(os.path.abspath(__file__))
CONFIG_PATH = os.path.join(os.path.dirname(SKILL_DIR), "config.json")


def load_config():
    """读取 config.json。"""
    if not os.path.exists(CONFIG_PATH):
        print(f"❌ 配置文件不存在：{CONFIG_PATH}")
        print("   请先运行 verify_env.py --init")
        sys.exit(1)

    with open(CONFIG_PATH, "r", encoding="utf-8") as f:
        return json.load(f)


def build_mysql_cmd(config, sql_content=None, sql_file=None):
    """构建 mysql 命令。返回命令列表。"""
    db = config.get("database", {})
    host = db.get("host", "localhost")
    port = db.get("port", 3306)
    name = db.get("name", "ry-vue")
    user = db.get("user", "root")
    password = db.get("password", "")
    container = db.get("dockerContainer", "")
    charset = db.get("charset", "utf8mb4")

    mysql_args = [
        f"--default-character-set={charset}",
        f"-u{user}",
    ]
    if password:
        mysql_args.append(f"-p{password}")
    mysql_args.append(name)

    # 优先使用 docker exec
    if container:
        base_cmd = ["docker", "exec", "-i", container, "mysql"] + mysql_args
    else:
        base_cmd = ["mysql", f"-h{host}", f"-P{port}"] + mysql_args

    if sql_file:
        # 执行文件：通过 stdin 传入
        return base_cmd, sql_file, None
    elif sql_content:
        # 执行 SQL 字符串
        return base_cmd + ["-e", sql_content], None, None
    else:
        return base_cmd, None, None


def execute_sql(config, sql_content=None, sql_file=None, show_output=True):
    """执行 SQL。返回 (success, output)。"""
    cmd, file_path, _ = build_mysql_cmd(config, sql_content, sql_file)

    stdin_data = None
    if file_path:
        if not os.path.exists(file_path):
            return False, f"SQL 文件不存在：{file_path}"
        with open(file_path, "r", encoding="utf-8") as f:
            stdin_data = f.read()

    try:
        result = subprocess.run(
            cmd,
            input=stdin_data,
            capture_output=True,
            text=True,
            timeout=60
        )

        output = ""
        if result.stdout:
            output += result.stdout
        if result.stderr and "Warning" not in result.stderr:
            output += "\n" + result.stderr

        if result.returncode == 0:
            return True, output.strip() if output else "执行成功"
        else:
            return False, output.strip() or f"执行失败（退出码 {result.returncode}）"

    except subprocess.TimeoutExpired:
        return False, "执行超时（60秒）"
    except FileNotFoundError as e:
        return False, f"命令未找到：{e}"


def query_sql(config, sql):
    """执行查询并格式化输出。"""
    success, output = execute_sql(config, sql_content=sql)

    if not success:
        print(f"❌ {output}")
        return False

    if not output or output == "执行成功":
        print("查询完成，无返回数据")
        return True

    # 格式化表格输出
    lines = output.strip().split("\n")
    if len(lines) < 2:
        print(output)
        return True

    # 解析 tab-separated 输出
    headers = lines[0].split("\t")
    rows = [line.split("\t") for line in lines[1:] if line.strip()]

    # 计算列宽
    col_widths = [len(h) for h in headers]
    for row in rows:
        for i, cell in enumerate(row):
            if i < len(col_widths):
                col_widths[i] = max(col_widths[i], len(cell))

    # 打印表格
    header_line = " | ".join(h.ljust(col_widths[i]) for i, h in enumerate(headers))
    separator = "-+-".join("-" * w for w in col_widths)

    print(header_line)
    print(separator)
    for row in rows:
        line = " | ".join(
            cell.ljust(col_widths[i] if i < len(col_widths) else 0)
            for i, cell in enumerate(row)
        )
        print(line)

    print(f"\n共 {len(rows)} 行")
    return True


def main():
    parser = argparse.ArgumentParser(description="SQL 统一执行器")
    subparsers = parser.add_subparsers(dest="command", help="子命令")

    # exec 子命令
    exec_parser = subparsers.add_parser("exec", help="执行 SQL")
    exec_group = exec_parser.add_mutually_exclusive_group(required=True)
    exec_group.add_argument("--file", "-f", help="SQL 文件路径")
    exec_group.add_argument("--sql", "-s", help="SQL 语句")

    # query 子命令
    query_parser = subparsers.add_parser("query", help="执行查询并展示结果")
    query_parser.add_argument("--sql", "-s", required=True, help="SELECT 语句")

    args = parser.parse_args()

    if not args.command:
        parser.print_help()
        sys.exit(1)

    config = load_config()

    if args.command == "exec":
        if args.file:
            print(f"执行 SQL 文件：{args.file}")
            success, output = execute_sql(config, sql_file=args.file)
        else:
            print(f"执行 SQL：{args.sql[:80]}...")
            success, output = execute_sql(config, sql_content=args.sql)

        if success:
            print(f"✅ {output}")
        else:
            print(f"❌ {output}")
            sys.exit(1)

    elif args.command == "query":
        print(f"查询：{args.sql[:80]}...")
        print()
        query_sql(config, args.sql)


if __name__ == "__main__":
    main()
