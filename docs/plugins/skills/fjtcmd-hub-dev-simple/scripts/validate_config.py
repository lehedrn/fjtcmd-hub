#!/usr/bin/env python3
"""
fjtcmd-hub-dev-simple 配置校验脚本

功能：
  验证 config.json 的格式和必填字段
  检查 schema_version 兼容性

用法：
  python validate_config.py [--config <path>] [--fix]

选项：
  --config   指定配置文件路径（默认 config.json）
  --fix      自动修复可修复的问题（添加缺失的必填字段）
"""

import json
import os
import sys


SKILL_DIR = os.path.dirname(os.path.abspath(__file__))
CONFIG_PATH = os.path.join(os.path.dirname(SKILL_DIR), "config.json")
TEMPLATE_PATH = os.path.join(os.path.dirname(SKILL_DIR), "config.template.json")

# 当前支持的 schema 版本
CURRENT_SCHEMA_VERSION = 1

# 必填字段定义（version 单独处理为警告，不在此处）
REQUIRED_FIELDS = {
    "schema_version": int,
    "database": dict,
    "database.host": str,
    "database.port": int,
    "database.name": str,
    "database.user": str,
    "server": dict,
    "server.backendPort": int,
    "server.frontendPort": int,
    "generator": dict,
    "generator.cliJarPath": str,
    "paths": dict,
    "paths.projectRoot": str,
    "modules": dict,
    "modules.available": list,
    "modules.defaultTarget": str,
}


def get_nested(data, path, default=None):
    """从嵌套字典中按路径取值。"""
    keys = path.split(".")
    current = data
    for key in keys:
        if isinstance(current, dict) and key in current:
            current = current[key]
        else:
            return default
    return current


def set_nested(data, path, value):
    """在嵌套字典中按路径设值。"""
    keys = path.split(".")
    current = data
    for key in keys[:-1]:
        if key not in current or not isinstance(current[key], dict):
            current[key] = {}
        current = current[key]
    current[keys[-1]] = value


def validate_config(config_path, verbose=True):
    """校验配置文件。返回 (is_valid, errors, warnings)。"""
    errors = []
    warnings = []

    # 检查文件是否存在
    if not os.path.exists(config_path):
        errors.append(f"配置文件不存在：{config_path}")
        return False, errors, warnings

    # 读取 JSON
    try:
        with open(config_path, "r", encoding="utf-8") as f:
            config = json.load(f)
    except json.JSONDecodeError as e:
        errors.append(f"JSON 解析失败：{e}")
        return False, errors, warnings

    # 检查 schema_version
    schema_version = config.get("schema_version")
    if schema_version is None:
        errors.append("缺少必填字段：schema_version")
    elif not isinstance(schema_version, int):
        errors.append(f"schema_version 类型错误：期望 int，实际 {type(schema_version).__name__}")
    elif schema_version > CURRENT_SCHEMA_VERSION:
        errors.append(
            f"schema_version 过高：当前支持 {CURRENT_SCHEMA_VERSION}，"
            f"配置文件为 {schema_version}。请升级 skill。"
        )
    elif schema_version < CURRENT_SCHEMA_VERSION:
        warnings.append(
            f"schema_version 过旧：当前为 {CURRENT_SCHEMA_VERSION}，"
            f"配置文件为 {schema_version}。建议运行 verify_env.py --init 更新配置。"
        )

    # 检查 version
    version = config.get("version")
    if version is None:
        warnings.append("缺少 version 字段（建议添加）")
    elif not isinstance(version, str):
        warnings.append(f"version 类型错误：期望 str，实际 {type(version).__name__}")

    # 检查必填字段
    for path, expected_type in REQUIRED_FIELDS.items():
        value = get_nested(config, path)
        if value is None:
            errors.append(f"缺少必填字段：{path}")
        elif not isinstance(value, expected_type):
            errors.append(
                f"字段类型错误：{path} 期望 {expected_type.__name__}，"
                f"实际 {type(value).__name__}"
            )

    # 业务校验
    db = config.get("database", {})
    if db.get("port", 0) < 1 or db.get("port", 0) > 65535:
        errors.append(f"database.port 超出范围：{db.get('port')}")

    server = config.get("server", {})
    if server.get("backendPort", 0) < 1 or server.get("backendPort", 0) > 65535:
        errors.append(f"server.backendPort 超出范围：{server.get('backendPort')}")
    if server.get("frontendPort", 0) < 1 or server.get("frontendPort", 0) > 65535:
        errors.append(f"server.frontendPort 超出范围：{server.get('frontendPort')}")

    # 检查 CLI JAR 路径
    gen = config.get("generator", {})
    cli_path = gen.get("cliJarPath", "")
    project_root = get_nested(config, "paths.projectRoot", "")
    if cli_path and project_root:
        full_jar_path = os.path.join(project_root, cli_path)
        if not os.path.exists(full_jar_path):
            warnings.append(f"CLI JAR 不存在：{full_jar_path}")

    is_valid = len(errors) == 0

    if verbose:
        if is_valid and not warnings:
            print(f"✅ 配置文件校验通过：{config_path}")
        elif is_valid:
            print(f"✅ 配置文件校验通过（有警告）：{config_path}")
            for w in warnings:
                print(f"  ⚠️  {w}")
        else:
            print(f"❌ 配置文件校验失败：{config_path}")
            for e in errors:
                print(f"  ✗ {e}")
            for w in warnings:
                print(f"  ⚠️  {w}")

    return is_valid, errors, warnings


def fix_config(config_path):
    """自动修复可修复的问题。"""
    if not os.path.exists(config_path):
        # 从模板复制
        if os.path.exists(TEMPLATE_PATH):
            with open(TEMPLATE_PATH, "r", encoding="utf-8") as f:
                template = json.load(f)
            with open(config_path, "w", encoding="utf-8") as f:
                json.dump(template, f, ensure_ascii=False, indent=2)
            print(f"✅ 已从模板创建配置文件：{config_path}")
            print(f"   请手动填写数据库密码等必填信息")
            return True
        else:
            print(f"❌ 配置文件和模板均不存在")
            return False

    # 读取现有配置
    with open(config_path, "r", encoding="utf-8") as f:
        config = json.load(f)

    modified = False

    # 添加缺失的必填字段（使用合理默认值）
    defaults = {
        "version": "1.1.0",
        "schema_version": CURRENT_SCHEMA_VERSION,
    }

    for path, default_value in defaults.items():
        if get_nested(config, path) is None:
            set_nested(config, path, default_value)
            modified = True
            print(f"  + 添加缺失字段：{path} = {default_value}")

    if modified:
        with open(config_path, "w", encoding="utf-8") as f:
            json.dump(config, f, ensure_ascii=False, indent=2)
        print(f"✅ 配置已修复：{config_path}")
    else:
        print(f"✅ 无需修复：{config_path}")

    return True


def main():
    import argparse

    parser = argparse.ArgumentParser(description="配置校验工具")
    parser.add_argument("--config", default=CONFIG_PATH, help="配置文件路径")
    parser.add_argument("--fix", action="store_true", help="自动修复可修复的问题")
    args = parser.parse_args()

    if args.fix:
        fix_config(args.config)
    else:
        is_valid, errors, warnings = validate_config(args.config)
        sys.exit(0 if is_valid else 1)


if __name__ == "__main__":
    main()
