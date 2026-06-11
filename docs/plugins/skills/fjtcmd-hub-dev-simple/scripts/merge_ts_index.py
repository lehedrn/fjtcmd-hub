#!/usr/bin/env python3
"""
fjtcmd-hub-dev-simple TypeScript 索引合并工具

功能：将 CLI 生成的 index-bak.ts 中的 export 行合并到 types/api/index.ts

用法：
  python merge_ts_index.py --bak <index-bak.ts> --target <types/api/index.ts>

逻辑：
  1. 从 bak 文件提取所有 export * from 行
  2. 读取 target 文件已有的 export 行
  3. 去重对比
  4. 将新行追加到 target 文件末尾
  5. 展示新增的 export 行
"""

import argparse
import os
import re
import sys


def extract_exports(filepath):
    """从文件中提取 export * from 行。"""
    exports = []
    if not os.path.exists(filepath):
        return exports

    with open(filepath, "r", encoding="utf-8") as f:
        for line in f:
            line = line.strip()
            if line.startswith("export * from"):
                exports.append(line)
    return exports


def get_existing_exports(filepath):
    """获取目标文件中已有的 export 行（用于去重）。"""
    return set(extract_exports(filepath))


def merge_exports(bak_file, target_file, dry_run=False):
    """合并 export 行。返回 (新增行数, 新增行列表)。"""
    bak_exports = extract_exports(bak_file)
    if not bak_exports:
        print(f"⚠️  bak 文件中未找到 export 行：{bak_file}")
        return 0, []

    existing = get_existing_exports(target_file)

    # 去重
    new_exports = [e for e in bak_exports if e not in existing]

    if not new_exports:
        print("✅ 所有 export 行已存在，无需合并")
        return 0, []

    if dry_run:
        print(f"将新增 {len(new_exports)} 个 export 行：")
        for exp in new_exports:
            print(f"  + {exp}")
        return len(new_exports), new_exports

    # 读取目标文件
    with open(target_file, "r", encoding="utf-8") as f:
        content = f.read()

    # 追加到文件末尾
    append_lines = ["\n// 由 fjtcmd-hub-dev-simple 自动合并\n"]
    append_lines.extend(new_exports)
    append_lines.append("")  # 末尾空行

    new_content = content.rstrip() + "\n" + "\n".join(append_lines)

    with open(target_file, "w", encoding="utf-8") as f:
        f.write(new_content)

    print(f"✅ 已合并 {len(new_exports)} 个 export 行到：{target_file}")
    for exp in new_exports:
        print(f"  + {exp}")

    return len(new_exports), new_exports


def main():
    parser = argparse.ArgumentParser(description="TypeScript 索引合并工具")
    parser.add_argument("--bak", "-b", required=True, help="index-bak.ts 文件路径")
    parser.add_argument("--target", "-t", required=True, help="types/api/index.ts 文件路径")
    parser.add_argument("--dry-run", "-n", action="store_true", help="仅预览，不实际写入")
    args = parser.parse_args()

    if not os.path.exists(args.bak):
        print(f"❌ bak 文件不存在：{args.bak}")
        sys.exit(1)

    if not os.path.exists(args.target):
        print(f"❌ target 文件不存在：{args.target}")
        sys.exit(1)

    print(f"合并 TS 索引")
    print(f"  源文件：{args.bak}")
    print(f"  目标文件：{args.target}")
    print()

    count, new_exports = merge_exports(args.bak, args.target, dry_run=args.dry_run)

    if count > 0 and not args.dry_run:
        print(f"\n📌 合并完成。请检查目标文件确认无误。")
    elif count == 0:
        print(f"\n无需修改。")


if __name__ == "__main__":
    main()
