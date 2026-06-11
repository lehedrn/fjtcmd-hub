#!/usr/bin/env python3
"""
fjtcmd-hub-dev-simple 公共模块

提供统一的：
  - 退出码定义
  - 日志/输出（带颜色）
  - 配置加载与校验
  - 错误处理辅助函数

所有脚本应优先使用本模块的函数，保持行为一致。
"""

import json
import os
import sys


# ============================================================
# 退出码定义
# ============================================================

EXIT_SUCCESS = 0          # 成功
EXIT_CONFIG_ERROR = 1     # 配置错误（config.json 缺失/格式错误）
EXIT_EXEC_ERROR = 2       # 执行错误（SQL 失败、命令不存在等）
EXIT_USER_CANCEL = 3      # 用户取消
EXIT_FILE_NOT_FOUND = 4   # 文件不存在
EXIT_VALIDATION_ERROR = 5 # 校验失败


# ============================================================
# 颜色定义
# ============================================================

class Colors:
    """终端颜色代码。"""
    RED = '\033[0;31m'
    GREEN = '\033[0;32m'
    YELLOW = '\033[0;33m'
    BLUE = '\033[0;34m'
    NC = '\033[0m'  # No Color

    # 是否启用颜色（非 TTY 时禁用）
    _enabled = sys.stdout.isatty()

    @classmethod
    def disable(cls):
        cls._enabled = False

    @classmethod
    def red(cls, text):
        return f"{cls.RED}{text}{cls.NC}" if cls._enabled else str(text)

    @classmethod
    def green(cls, text):
        return f"{cls.GREEN}{text}{cls.NC}" if cls._enabled else str(text)

    @classmethod
    def yellow(cls, text):
        return f"{cls.YELLOW}{text}{cls.NC}" if cls._enabled else str(text)

    @classmethod
    def blue(cls, text):
        return f"{cls.BLUE}{text}{cls.NC}" if cls._enabled else str(text)


# ============================================================
# 日志函数
# ============================================================

def log_info(msg):
    """信息日志（绿色）。"""
    print(Colors.green(f"[INFO] {msg}"))


def log_warn(msg):
    """警告日志（黄色）。"""
    print(Colors.yellow(f"[WARN] {msg}"))


def log_error(msg):
    """错误日志（红色）。"""
    print(Colors.red(f"[ERROR] {msg}"), file=sys.stderr)


def log_step(msg):
    """步骤日志（蓝色）。"""
    print(Colors.blue(f"[STEP] {msg}"))


def log_success(msg):
    """成功日志（绿色）。"""
    print(Colors.green(f"[OK] {msg}"))


def log_fail(msg):
    """失败日志（红色）。"""
    print(Colors.red(f"[FAIL] {msg}"))


# ============================================================
# 配置加载
# ============================================================

SKILL_DIR = os.path.dirname(os.path.abspath(__file__))
CONFIG_PATH = os.path.join(os.path.dirname(SKILL_DIR), "config.json")


def load_config(config_path=None, validate=True):
    """加载配置文件。

    Args:
        config_path: 配置文件路径，默认使用 CONFIG_PATH
        validate: 是否校验配置格式

    Returns:
        dict: 配置字典

    Raises:
        SystemExit: 配置不存在或校验失败时退出
    """
    path = config_path or CONFIG_PATH

    if not os.path.exists(path):
        log_error(f"配置文件不存在：{path}")
        log_info(f"请先运行 verify_env.py --init 生成配置")
        log_info(f"或复制 config.template.json 为 config.json 并手动填写")
        sys.exit(EXIT_CONFIG_ERROR)

    try:
        with open(path, "r", encoding="utf-8") as f:
            config = json.load(f)
    except json.JSONDecodeError as e:
        log_error(f"配置文件 JSON 解析失败：{e}")
        sys.exit(EXIT_CONFIG_ERROR)

    if validate:
        # 导入校验模块（避免循环导入）
        validate_script = os.path.join(SKILL_DIR, "validate_config.py")
        if os.path.exists(validate_script):
            # 动态导入
            import importlib.util
            spec = importlib.util.spec_from_file_location("validate_config", validate_script)
            validate_module = importlib.util.module_from_spec(spec)
            spec.loader.exec_module(validate_module)

            is_valid, errors, warnings = validate_module.validate_config(path, verbose=False)

            for w in warnings:
                log_warn(w)

            if not is_valid:
                for e in errors:
                    log_error(e)
                log_info(f"请运行 python {validate_script} --fix 尝试自动修复")
                sys.exit(EXIT_CONFIG_ERROR)

    return config


def get_config_value(config, path, default=None):
    """从配置中按路径取值。

    Args:
        config: 配置字典
        path: 点分隔路径，如 "database.host"
        default: 默认值

    Returns:
        配置值或默认值
    """
    keys = path.split(".")
    current = config
    for key in keys:
        if isinstance(current, dict) and key in current:
            current = current[key]
        else:
            return default
    return current


# ============================================================
# 错误处理辅助
# ============================================================

def exit_with_error(msg, exit_code=EXIT_EXEC_ERROR):
    """输出错误信息并退出。"""
    log_error(msg)
    sys.exit(exit_code)


def exit_with_success(msg=""):
    """输出成功信息并退出。"""
    if msg:
        log_success(msg)
    sys.exit(EXIT_SUCCESS)


def require_file(path, description="文件"):
    """要求文件存在，否则退出。"""
    if not os.path.exists(path):
        exit_with_error(f"{description}不存在：{path}", EXIT_FILE_NOT_FOUND)


def confirm(prompt, default=True):
    """向用户确认操作。

    Args:
        prompt: 确认提示
        default: 默认值（True=是，False=否）

    Returns:
        bool: 用户是否确认
    """
    suffix = " [Y/n] " if default else " [y/N] "
    try:
        answer = input(prompt + suffix).strip().lower()
        if not answer:
            return default
        return answer in ('y', 'yes', '是')
    except (EOFError, KeyboardInterrupt):
        print()
        return False


# ============================================================
# 主函数（用于测试）
# ============================================================

def main():
    """测试公共模块功能。"""
    log_info("测试信息日志")
    log_warn("测试警告日志")
    log_error("测试错误日志")
    log_step("测试步骤日志")
    log_success("测试成功日志")
    log_fail("测试失败日志")

    print()
    log_info("加载配置...")
    try:
        config = load_config()
        log_success(f"配置加载成功")
        log_info(f"  数据库: {get_config_value(config, 'database.name')}")
        log_info(f"  后端端口: {get_config_value(config, 'server.backendPort')}")
        log_info(f"  前端端口: {get_config_value(config, 'server.frontendPort')}")
    except SystemExit:
        pass


if __name__ == "__main__":
    main()
