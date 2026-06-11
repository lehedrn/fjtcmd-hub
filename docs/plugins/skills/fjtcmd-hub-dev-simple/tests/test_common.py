#!/usr/bin/env python3
"""
common.py 单元测试
"""

import json
import os
import sys
import tempfile
import unittest


SCRIPT_DIR = os.path.join(os.path.dirname(os.path.dirname(os.path.abspath(__file__))), "scripts")
sys.path.insert(0, SCRIPT_DIR)

from common import (
    EXIT_SUCCESS, EXIT_CONFIG_ERROR, EXIT_EXEC_ERROR,
    Colors, load_config, get_config_value
)


class TestExitCodes(unittest.TestCase):
    """测试退出码定义。"""

    def test_exit_codes_defined(self):
        self.assertEqual(EXIT_SUCCESS, 0)
        self.assertEqual(EXIT_CONFIG_ERROR, 1)
        self.assertEqual(EXIT_EXEC_ERROR, 2)


class TestColors(unittest.TestCase):
    """测试颜色输出。"""

    def test_color_functions(self):
        # 禁用颜色后应该返回纯文本
        Colors.disable()
        self.assertEqual(Colors.red("test"), "test")
        self.assertEqual(Colors.green("test"), "test")
        self.assertEqual(Colors.yellow("test"), "test")
        self.assertEqual(Colors.blue("test"), "test")


class TestConfigLoading(unittest.TestCase):
    """测试配置加载。"""

    def setUp(self):
        self.temp_dir = tempfile.mkdtemp()
        self.config_path = os.path.join(self.temp_dir, "config.json")

    def tearDown(self):
        if os.path.exists(self.config_path):
            os.remove(self.config_path)
        os.rmdir(self.temp_dir)

    def test_load_nonexistent_config(self):
        """测试加载不存在的配置。"""
        with self.assertRaises(SystemExit) as cm:
            load_config("/nonexistent/config.json")
        self.assertEqual(cm.exception.code, EXIT_CONFIG_ERROR)

    def test_load_invalid_json(self):
        """测试加载无效 JSON。"""
        with open(self.config_path, "w") as f:
            f.write("{invalid")
        with self.assertRaises(SystemExit) as cm:
            load_config(self.config_path)
        self.assertEqual(cm.exception.code, EXIT_CONFIG_ERROR)

    def test_get_config_value(self):
        """测试配置取值。"""
        config = {
            "database": {
                "host": "localhost",
                "port": 3306
            }
        }
        self.assertEqual(get_config_value(config, "database.host"), "localhost")
        self.assertEqual(get_config_value(config, "database.port"), 3306)
        self.assertEqual(get_config_value(config, "database.missing", "default"), "default")


if __name__ == "__main__":
    unittest.main()
