#!/usr/bin/env python3
"""
fjtcmd-hub-dev-simple 菜单管理工具

功能：
  query     --name "菜单名" [--type M|C|F]         查询菜单
  create    --name "菜单名" --parent-id <id> ...    创建菜单
  children  --parent-id <id>                        查看子菜单树
  tree      [--name "菜单名"]                       查看完整菜单树
"""

import argparse
import json
import os
import subprocess
import sys


SKILL_DIR = os.path.dirname(os.path.abspath(__file__))
CONFIG_PATH = os.path.join(os.path.dirname(SKILL_DIR), "config.json")

# 菜单类型映射
MENU_TYPE_MAP = {
    "M": "目录",
    "C": "菜单",
    "F": "按钮",
}


def load_config():
    if not os.path.exists(CONFIG_PATH):
        print(f"❌ 配置文件不存在：{CONFIG_PATH}")
        print("   请先运行 verify_env.py --init")
        sys.exit(1)
    with open(CONFIG_PATH, "r", encoding="utf-8") as f:
        return json.load(f)


def run_sql(config, sql, show_output=False):
    """执行 SQL 并返回结果。"""
    db = config.get("database", {})
    container = db.get("dockerContainer", "")
    charset = db.get("charset", "utf8mb4")
    user = db.get("user", "root")
    password = db.get("password", "")
    name = db.get("name", "ry-vue")

    if container:
        cmd = [
            "docker", "exec", "-i", container,
            "mysql", f"--default-character-set={charset}",
            f"-u{user}", f"-p{password}", name,
            "-e", sql
        ]
    else:
        host = db.get("host", "localhost")
        port = db.get("port", 3306)
        cmd = [
            "mysql", f"-h{host}", f"-P{port}",
            f"--default-character-set={charset}",
            f"-u{user}", f"-p{password}", name,
            "-e", sql
        ]

    try:
        result = subprocess.run(cmd, capture_output=True, text=True, timeout=30)
        if result.returncode != 0:
            stderr = result.stderr.strip()
            if "Warning" not in stderr:
                print(f"❌ SQL 执行失败：{stderr}")
            return []

        output = result.stdout.strip()
        if not output:
            return []

        lines = output.split("\n")
        if len(lines) < 2:
            return []

        headers = lines[0].split("\t")
        rows = []
        for line in lines[1:]:
            if line.strip():
                values = line.split("\t")
                rows.append(dict(zip(headers, values)))

        if show_output and rows:
            print_table(headers, rows)

        return rows

    except subprocess.TimeoutExpired:
        print("❌ SQL 执行超时")
        return []
    except FileNotFoundError as e:
        print(f"❌ 命令未找到：{e}")
        return []


def print_table(headers, rows):
    """格式化打印表格。"""
    col_widths = [len(h) for h in headers]
    for row in rows:
        for i, h in enumerate(headers):
            val = row.get(h, "")
            col_widths[i] = max(col_widths[i], len(str(val)))

    header_line = " | ".join(h.ljust(col_widths[i]) for i, h in enumerate(headers))
    separator = "-+-".join("-" * w for w in col_widths)

    print(header_line)
    print(separator)
    for row in rows:
        line = " | ".join(
            str(row.get(h, "")).ljust(col_widths[i])
            for i, h in enumerate(headers)
        )
        print(line)
    print(f"\n共 {len(rows)} 行")


def cmd_query(args, config):
    """查询菜单。"""
    conditions = []
    if args.name:
        conditions.append(f"menu_name LIKE '%{args.name}%'")
    if args.type:
        conditions.append(f"menu_type = '{args.type}'")

    where = " AND ".join(conditions) if conditions else "1=1"
    sql = f"""
        SELECT menu_id, menu_name, parent_id, order_num, menu_type, path, perms
        FROM sys_menu
        WHERE {where}
        ORDER BY parent_id, order_num
    """

    rows = run_sql(config, sql)
    if not rows:
        print("未找到匹配的菜单")
        return

    print(f"\n查询结果：")
    display_headers = ["menu_id", "menu_name", "parent_id", "order_num", "menu_type", "path", "perms"]
    print_table(display_headers, rows)


def cmd_create(args, config):
    """创建菜单。"""
    # 检查是否已存在
    check_sql = f"""
        SELECT menu_id, menu_name FROM sys_menu
        WHERE menu_name = '{args.name}' AND parent_id = {args.parent_id}
    """
    existing = run_sql(config, check_sql)
    if existing:
        print(f"⚠️  菜单已存在：{existing[0]['menu_name']}（ID: {existing[0]['menu_id']}）")
        return

    # 构建 INSERT
    component_val = f"'{args.component}'" if args.component else "NULL"
    icon_val = f"'{args.icon}'" if args.icon else "'#'"
    is_frame = 1 if args.is_frame else 0
    is_cache = 1 if args.is_cache else 0

    sql = f"""
        INSERT INTO sys_menu (
            menu_name, parent_id, order_num, path, component,
            is_frame, is_cache, menu_type, visible, status,
            perms, icon, create_by, create_time, remark
        ) VALUES (
            '{args.name}', {args.parent_id}, {args.order_num or 1},
            '{args.path or ''}', {component_val},
            {is_frame}, {is_cache}, '{args.type or 'C'}', '0', '0',
            '{args.perms or ''}', {icon_val},
            'admin', sysdate(), '{args.remark or ''}'
        )
    """

    # 执行 INSERT
    db = config.get("database", {})
    container = db.get("dockerContainer", "")
    charset = db.get("charset", "utf8mb4")
    user = db.get("user", "root")
    password = db.get("password", "")
    name = db.get("name", "ry-vue")

    if container:
        cmd = [
            "docker", "exec", "-i", container,
            "mysql", f"--default-character-set={charset}",
            f"-u{user}", f"-p{password}", name,
            "-e", sql
        ]
    else:
        host = db.get("host", "localhost")
        port = db.get("port", 3306)
        cmd = [
            "mysql", f"-h{host}", f"-P{port}",
            f"--default-character-set={charset}",
            f"-u{user}", f"-p{password}", name,
            "-e", sql
        ]

    try:
        result = subprocess.run(cmd, capture_output=True, text=True, timeout=30)
        if result.returncode != 0:
            print(f"❌ 创建失败：{result.stderr.strip()}")
            return
    except Exception as e:
        print(f"❌ 执行异常：{e}")
        return

    # 查询新插入的 ID
    id_sql = "SELECT LAST_INSERT_ID() AS menu_id"
    rows = run_sql(config, id_sql)
    if rows:
        new_id = rows[0]["menu_id"]
        print(f"✅ 菜单创建成功！")
        print(f"   菜单名称：{args.name}")
        print(f"   菜单 ID：{new_id}")
        print(f"   上级 ID：{args.parent_id}")
        print(f"   类型：{MENU_TYPE_MAP.get(args.type, args.type)}")
        print(f"   权限：{args.perms or '无'}")
    else:
        print("✅ INSERT 执行成功，但未能查询到新 ID")


def cmd_children(args, config):
    """查看子菜单。"""
    sql = f"""
        SELECT menu_id, menu_name, parent_id, order_num, menu_type, perms
        FROM sys_menu
        WHERE parent_id = {args.parent_id}
        ORDER BY order_num
    """
    rows = run_sql(config, sql, show_output=True)
    if not rows:
        print(f"菜单 {args.parent_id} 下没有子菜单")


def cmd_tree(args, config):
    """展示菜单树。"""
    if args.name:
        # 找根节点
        find_sql = f"SELECT menu_id FROM sys_menu WHERE menu_name = '{args.name}' LIMIT 1"
        roots = run_sql(config, find_sql)
        if not roots:
            print(f"未找到菜单：{args.name}")
            return
        root_id = roots[0]["menu_id"]
    else:
        root_id = 0

    # 递归查询
    sql = f"""
        SELECT menu_id, menu_name, parent_id, order_num, menu_type, perms
        FROM sys_menu
        WHERE parent_id >= {root_id} AND menu_id > 0
        ORDER BY parent_id, order_num
        LIMIT 200
    """
    rows = run_sql(config, sql)
    if not rows:
        print("无菜单数据")
        return

    # 构建树
    children_map = {}
    node_map = {}
    for row in rows:
        node_map[row["menu_id"]] = row
        pid = row["parent_id"]
        if pid not in children_map:
            children_map[pid] = []
        children_map[pid].append(row)

    # 打印树
    def print_tree(node_id, depth=0):
        nodes = children_map.get(node_id, [])
        for node in nodes:
            indent = "  " * depth
            type_label = MENU_TYPE_MAP.get(node["menu_type"], "?")
            perms = node.get("perms", "")
            perms_str = f" [{perms}]" if perms else ""
            print(f"{indent}├─ [{node['menu_id']}] {node['menu_name']} ({type_label}){perms_str}")
            print_tree(node["menu_id"], depth + 1)

    if args.name:
        root_node = node_map.get(str(root_id), {})
        print(f"\n📂 {root_node.get('menu_name', args.name)} (ID: {root_id})")
        print_tree(root_id)
    else:
        print("\n📂 完整菜单树（顶级目录）：")
        print_tree(0)


def main():
    parser = argparse.ArgumentParser(description="菜单管理工具")
    subparsers = parser.add_subparsers(dest="command")

    # query
    q = subparsers.add_parser("query", help="查询菜单")
    q.add_argument("--name", "-n", help="菜单名称（模糊匹配）")
    q.add_argument("--type", "-t", choices=["M", "C", "F"], help="菜单类型")

    # create
    c = subparsers.add_parser("create", help="创建菜单")
    c.add_argument("--name", "-n", required=True, help="菜单名称")
    c.add_argument("--parent-id", "-p", type=int, required=True, help="上级菜单 ID")
    c.add_argument("--order-num", "-o", type=int, help="排序号")
    c.add_argument("--path", help="路由路径")
    c.add_argument("--component", help="组件路径")
    c.add_argument("--type", "-t", choices=["M", "C", "F"], default="C", help="菜单类型")
    c.add_argument("--perms", help="权限标识")
    c.add_argument("--icon", help="图标")
    c.add_argument("--is-frame", action="store_true", help="是否外链")
    c.add_argument("--is-cache", action="store_true", help="是否缓存")
    c.add_argument("--remark", help="备注")

    # children
    ch = subparsers.add_parser("children", help="查看子菜单")
    ch.add_argument("--parent-id", "-p", type=int, required=True, help="上级菜单 ID")

    # tree
    t = subparsers.add_parser("tree", help="查看菜单树")
    t.add_argument("--name", "-n", help="根菜单名称（不指定则显示全部）")

    args = parser.parse_args()
    if not args.command:
        parser.print_help()
        sys.exit(1)

    config = load_config()

    commands = {
        "query": cmd_query,
        "create": cmd_create,
        "children": cmd_children,
        "tree": cmd_tree,
    }
    commands[args.command](args, config)


if __name__ == "__main__":
    main()
