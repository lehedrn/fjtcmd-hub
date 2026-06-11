#!/usr/bin/env python3
"""
fjtcmd-hub-dev-simple 路由集成工具

功能：将 CLI 生成的 route-index-bak.ts 中的路由配置插入到 router/index.ts 的 dynamicRoutes 中

用法：
  python merge_router.py --bak <route-index-bak.ts> --target <router/index.ts>

逻辑：
  1. 从 bak 文件提取路由对象（跳过注释行）
  2. 检查 target 中是否已存在同名路由（去重）
  3. 在 dynamicRoutes 数组的末尾 ] 前插入
  4. 展示新增的路由配置
"""

import argparse
import os
import re
import sys


def extract_route_object(filepath):
    """从 route-index-bak.ts 提取路由对象（跳过注释行）。"""
    if not os.path.exists(filepath):
        return None

    lines = []
    with open(filepath, "r", encoding="utf-8") as f:
        for line in f:
            stripped = line.strip()
            # 跳过注释行
            if stripped.startswith("//") or stripped.startswith("/*") or stripped.startswith("*"):
                continue
            if stripped:
                lines.append(line)

    content = "".join(lines).strip()
    if not content:
        return None

    # 确保以 { 开头
    if not content.startswith("{"):
        # 找到第一个 {
        idx = content.find("{")
        if idx >= 0:
            content = content[idx:]
        else:
            return None

    return content


def extract_route_name(route_content):
    """从路由对象中提取 name 字段。"""
    match = re.search(r"name:\s*['\"](\w+)['\"]", route_content)
    if match:
        return match.group(1)
    return None


def check_name_exists(target_content, name):
    """检查 target 中是否已存在该 name 的路由。"""
    pattern = rf"name:\s*['\"]{re.escape(name)}['\"]"
    return bool(re.search(pattern, target_content))


def find_dynamic_routes_end(content):
    """找到 dynamicRoutes 数组的末尾 ] 的位置。

    策略：找到 'export const dynamicRoutes' 后的第一个 [...] 块的末尾。
    """
    # 找到 dynamicRoutes 声明位置
    match = re.search(r"export\s+const\s+dynamicRoutes\s*=\s*\[", content)
    if not match:
        return -1

    start = match.end()  # [ 之后的位置
    depth = 1
    pos = start

    while pos < len(content) and depth > 0:
        ch = content[pos]
        if ch == "[":
            depth += 1
        elif ch == "]":
            depth -= 1
            if depth == 0:
                return pos
        pos += 1

    return -1


def merge_route(bak_file, target_file, dry_run=False):
    """合并路由配置。返回 (success, message)。"""
    route_obj = extract_route_object(bak_file)
    if not route_obj:
        return False, "bak 文件中未找到有效的路由对象"

    route_name = extract_route_name(route_obj)
    if not route_name:
        return False, "路由对象中未找到 name 字段"

    # 读取 target
    with open(target_file, "r", encoding="utf-8") as f:
        target_content = f.read()

    # 去重检查
    if check_name_exists(target_content, route_name):
        print(f"✅ 路由 '{route_name}' 已存在，无需重复添加")
        return True, "已存在，跳过"

    # 找到插入位置
    insert_pos = find_dynamic_routes_end(target_content)
    if insert_pos < 0:
        return False, "未找到 dynamicRoutes 数组"

    # 构建插入内容
    # 在 ] 前插入，需要加逗号和缩进
    insert_content = ",\n" + route_obj + "\n"

    if dry_run:
        print(f"将插入路由 '{route_name}'：")
        print(route_obj)
        return True, "预览模式"

    # 执行插入
    new_content = target_content[:insert_pos] + insert_content + target_content[insert_pos:]

    with open(target_file, "w", encoding="utf-8") as f:
        f.write(new_content)

    print(f"✅ 已插入路由 '{route_name}' 到：{target_file}")
    print(f"\n插入内容：")
    print(route_obj)

    return True, "插入成功"


def main():
    parser = argparse.ArgumentParser(description="路由集成工具")
    parser.add_argument("--bak", "-b", required=True, help="route-index-bak.ts 文件路径")
    parser.add_argument("--target", "-t", required=True, help="router/index.ts 文件路径")
    parser.add_argument("--dry-run", "-n", action="store_true", help="仅预览，不实际写入")
    args = parser.parse_args()

    if not os.path.exists(args.bak):
        print(f"❌ bak 文件不存在：{args.bak}")
        sys.exit(1)

    if not os.path.exists(args.target):
        print(f"❌ target 文件不存在：{args.target}")
        sys.exit(1)

    print(f"路由集成")
    print(f"  源文件：{args.bak}")
    print(f"  目标文件：{args.target}")
    print()

    success, message = merge_route(args.bak, args.target, dry_run=args.dry_run)

    if not success:
        print(f"❌ {message}")
        sys.exit(1)


if __name__ == "__main__":
    main()
