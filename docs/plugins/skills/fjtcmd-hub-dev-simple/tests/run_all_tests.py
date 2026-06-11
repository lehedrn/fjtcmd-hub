#!/usr/bin/env python3
"""
测试运行器 - 运行所有单元测试

用法：
  python3 tests/run_all_tests.py
  或
  python3 -m unittest discover tests/
"""

import os
import sys
import unittest


# 添加 scripts 目录到 Python 路径
SCRIPT_DIR = os.path.join(os.path.dirname(os.path.dirname(os.path.abspath(__file__))), "scripts")
sys.path.insert(0, SCRIPT_DIR)


def run_all_tests():
    """发现并运行所有测试。"""
    # 发现 tests/ 目录下所有 test_*.py 文件
    loader = unittest.TestLoader()
    suite = loader.discover(
        start_dir=os.path.dirname(os.path.abspath(__file__)),
        pattern='test_*.py',
        top_level_dir=os.path.dirname(os.path.abspath(__file__))
    )

    # 运行测试
    runner = unittest.TextTestRunner(verbosity=2)
    result = runner.run(suite)

    # 返回退出码
    return 0 if result.wasSuccessful() else 1


if __name__ == "__main__":
    sys.exit(run_all_tests())
