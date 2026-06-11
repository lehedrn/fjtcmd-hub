#!/usr/bin/env python3
"""
fjtcmd-hub-dev-simple 代码拷贝工具

功能：将 CLI 生成的代码从中间目录拷贝到目标模块

用法：
  python copy_code.py --source <output_dir> --target-module <module> --business <name>

拷贝映射：
  output/main/java/...       → fjtcmd-hub-{module}/src/main/java/...
  output/main/resources/...  → fjtcmd-hub-{module}/src/main/resources/...
  output/vue/api/...         → fjtcmd-hub-ui/src/api/...
  output/vue/types/api/...   → fjtcmd-hub-ui/src/types/api/...（排除 index-bak.ts）
  output/vue/views/...       → fjtcmd-hub-ui/src/views/...
"""

import argparse
import filecmp
import json
import os
import shutil
import sys


SKILL_DIR = os.path.dirname(os.path.abspath(__file__))
CONFIG_PATH = os.path.join(os.path.dirname(SKILL_DIR), "config.json")


def load_config():
    if not os.path.exists(CONFIG_PATH):
        print(f"❌ 配置文件不存在：{CONFIG_PATH}")
        sys.exit(1)
    with open(CONFIG_PATH, "r", encoding="utf-8") as f:
        return json.load(f)


def copy_with_check(src, dst, description=""):
    """拷贝文件，目标已存在且不同时警告。返回 (copied, warned)。"""
    warned = False

    if os.path.exists(dst):
        try:
            if filecmp.cmp(src, dst, shallow=False):
                return False, False  # 文件相同，跳过
        except Exception:
            pass
        warned = True
        print(f"  ⚠️  覆盖已有文件：{dst}")

    os.makedirs(os.path.dirname(dst), exist_ok=True)
    shutil.copy2(src, dst)
    return True, warned


def copy_dir_recursive(src_dir, dst_dir, exclude_files=None, description=""):
    """递归拷贝目录。返回 (count, warnings)。"""
    exclude_files = exclude_files or []
    count = 0
    warnings = 0

    if not os.path.exists(src_dir):
        return 0, 0

    for root, dirs, files in os.walk(src_dir):
        for filename in files:
            if filename in exclude_files:
                continue

            src_file = os.path.join(root, filename)
            rel_path = os.path.relpath(src_file, src_dir)
            dst_file = os.path.join(dst_dir, rel_path)

            copied, warned = copy_with_check(src_file, dst_file, description)
            if copied:
                count += 1
            if warned:
                warnings += 1

    return count, warnings


def main():
    parser = argparse.ArgumentParser(description="代码拷贝工具")
    parser.add_argument("--source", "-s", required=True, help="中间目录 output/ 路径")
    parser.add_argument("--target-module", "-m", required=True, help="目标模块名（demo/biz）")
    parser.add_argument("--business", "-b", help="业务名（用于日志展示）")
    args = parser.parse_args()

    config = load_config()
    project_root = config.get("paths", {}).get("projectRoot", os.getcwd())

    source = os.path.abspath(args.source)
    if not os.path.exists(source):
        print(f"❌ 源目录不存在：{source}")
        sys.exit(1)

    module = args.target_module
    business = args.business or ""

    print(f"代码拷贝")
    print(f"  源目录：{source}")
    print(f"  目标模块：fjtcmd-hub-{module}")
    if business:
        print(f"  业务名：{business}")
    print()

    total_copied = 0
    total_warnings = 0

    # 1. 后端 Java 文件
    java_src = os.path.join(source, "main", "java")
    java_dst = os.path.join(project_root, f"fjtcmd-hub-{module}", "src", "main", "java")
    if os.path.exists(java_src):
        count, warns = copy_dir_recursive(java_src, java_dst, description="后端Java")
        total_copied += count
        total_warnings += warns
        print(f"  ✅ 后端 Java 文件：拷贝 {count} 个文件")

    # 2. Mapper XML
    mapper_src = os.path.join(source, "main", "resources")
    mapper_dst = os.path.join(project_root, f"fjtcmd-hub-{module}", "src", "main", "resources")
    if os.path.exists(mapper_src):
        count, warns = copy_dir_recursive(mapper_src, mapper_dst, description="Mapper XML")
        total_copied += count
        total_warnings += warns
        print(f"  ✅ Mapper XML：拷贝 {count} 个文件")

    # 3. 前端 API
    api_src = os.path.join(source, "vue", "api")
    api_dst = os.path.join(project_root, "fjtcmd-hub-ui", "src", "api")
    if os.path.exists(api_src):
        count, warns = copy_dir_recursive(api_src, api_dst, description="前端API")
        total_copied += count
        total_warnings += warns
        print(f"  ✅ 前端 API：拷贝 {count} 个文件")

    # 4. 前端 Types（排除 index-bak.ts）
    types_src = os.path.join(source, "vue", "types", "api")
    types_dst = os.path.join(project_root, "fjtcmd-hub-ui", "src", "types", "api")
    if os.path.exists(types_src):
        count, warns = copy_dir_recursive(
            types_src, types_dst,
            exclude_files=["index-bak.ts"],
            description="前端Types"
        )
        total_copied += count
        total_warnings += warns
        print(f"  ✅ 前端 Types：拷贝 {count} 个文件（已排除 index-bak.ts）")

    # 5. 前端 Views
    views_src = os.path.join(source, "vue", "views")
    views_dst = os.path.join(project_root, "fjtcmd-hub-ui", "src", "views")
    if os.path.exists(views_src):
        count, warns = copy_dir_recursive(views_src, views_dst, description="前端Views")
        total_copied += count
        total_warnings += warns
        print(f"  ✅ 前端 Views：拷贝 {count} 个文件")

    print(f"\n{'='*40}")
    print(f"拷贝完成：共 {total_copied} 个文件")
    if total_warnings > 0:
        print(f"⚠️  其中 {total_warnings} 个文件覆盖了已有内容")

    # 检查是否有 route-index-bak.ts 需要处理
    route_bak = os.path.join(source, "vue", "route-index-bak.ts")
    if os.path.exists(route_bak):
        print(f"\n📌 检测到 route-index-bak.ts（主子表路由配置）")
        print(f"   位置：{route_bak}")
        print(f"   请使用 merge_router.py 将其集成到 router/index.ts")


if __name__ == "__main__":
    main()
