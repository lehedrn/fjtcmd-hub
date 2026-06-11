#!/usr/bin/env python3
"""
validate_config.py 单元测试

运行方式：
  python3 -m unittest tests/test_validate_config.py
  或
  python3 tests/test_validate_config.py
"""

import json
import os
import sys
import tempfile
import unittest


# 添加 scripts 目录到 Python 路径
SCRIPT_DIR = os.path.join(os.path.dirname(os.path.dirname(os.path.abspath(__file__))), "scripts")
sys.path.insert(0, SCRIPT_DIR)

from validate_config import validate_config, get_nested, set_nested, REQUIRED_FIELDS


class TestValidateConfig(unittest.TestCase):
    """测试配置校验功能。"""

    def setUp(self):
        """创建临时目录和有效配置。"""
        self.temp_dir = tempfile.mkdtemp()
        self.config_path = os.path.join(self.temp_dir, "config.json")
        self.valid_config = {
            "version": "1.1.0",
            "schema_version": 1,
            "database": {
                "host": "localhost",
                "port": 3306,
                "name": "ry-vue",
                "user": "root",
                "password": "test",
                "dockerContainer": "mysql8",
                "charset": "utf8mb4"
            },
            "server": {
                "backendPort": 18081,
                "frontendPort": 3888
            },
            "generator": {
                "cliJarPath": "fjtcmd-hub-generator-cli/target/fjtcmd-hub-generator-cli.jar"
            },
            "paths": {
                "projectRoot": "/tmp/test"
            },
            "modules": {
                "available": ["demo"],
                "defaultTarget": "demo"
            }
        }

    def tearDown(self):
        """清理临时文件。"""
        if os.path.exists(self.config_path):
            os.remove(self.config_path)
        os.rmdir(self.temp_dir)

    def _write_config(self, config):
        """写入配置到临时文件。"""
        with open(self.config_path, "w", encoding="utf-8") as f:
            json.dump(config, f, ensure_ascii=False, indent=2)

    def test_valid_config(self):
        """测试有效配置通过校验。"""
        self._write_config(self.valid_config)
        is_valid, errors, warnings = validate_config(self.config_path, verbose=False)
        self.assertTrue(is_valid)
        self.assertEqual(len(errors), 0)

    def test_missing_file(self):
        """测试配置文件不存在。"""
        is_valid, errors, warnings = validate_config("/nonexistent/path.json", verbose=False)
        self.assertFalse(is_valid)
        self.assertTrue(any("不存在" in e for e in errors))

    def test_invalid_json(self):
        """测试无效 JSON。"""
        with open(self.config_path, "w", encoding="utf-8") as f:
            f.write("{invalid json")
        is_valid, errors, warnings = validate_config(self.config_path, verbose=False)
        self.assertFalse(is_valid)
        self.assertTrue(any("解析失败" in e for e in errors))

    def test_missing_version(self):
        """测试缺少 version 字段产生警告。"""
        config = self.valid_config.copy()
        del config["version"]
        self._write_config(config)
        is_valid, errors, warnings = validate_config(self.config_path, verbose=False)
        self.assertTrue(is_valid)  # 不是必填，只是警告
        self.assertTrue(any("version" in w for w in warnings))

    def test_missing_schema_version(self):
        """测试缺少 schema_version 字段。"""
        config = self.valid_config.copy()
        del config["schema_version"]
        self._write_config(config)
        is_valid, errors, warnings = validate_config(self.config_path, verbose=False)
        self.assertFalse(is_valid)
        self.assertTrue(any("schema_version" in e for e in errors))

    def test_missing_database(self):
        """测试缺少 database 字段。"""
        config = self.valid_config.copy()
        del config["database"]
        self._write_config(config)
        is_valid, errors, warnings = validate_config(self.config_path, verbose=False)
        self.assertFalse(is_valid)
        self.assertTrue(any("database" in e for e in errors))

    def test_invalid_port(self):
        """测试端口超出范围。"""
        config = self.valid_config.copy()
        config["database"] = config["database"].copy()
        config["database"]["port"] = 99999
        self._write_config(config)
        is_valid, errors, warnings = validate_config(self.config_path, verbose=False)
        self.assertFalse(is_valid)
        self.assertTrue(any("超出范围" in e for e in errors))

    def test_schema_version_too_high(self):
        """测试 schema_version 过高。"""
        config = self.valid_config.copy()
        config["schema_version"] = 999
        self._write_config(config)
        is_valid, errors, warnings = validate_config(self.config_path, verbose=False)
        self.assertFalse(is_valid)
        self.assertTrue(any("过高" in e for e in errors))


class TestHelpers(unittest.TestCase):
    """测试辅助函数。"""

    def test_get_nested_simple(self):
        """测试简单路径取值。"""
        data = {"a": {"b": {"c": 1}}}
        self.assertEqual(get_nested(data, "a.b.c"), 1)

    def test_get_nested_missing(self):
        """测试缺失路径返回默认值。"""
        data = {"a": 1}
        self.assertEqual(get_nested(data, "a.b.c", "default"), "default")

    def test_set_nested_new(self):
        """测试设置新路径。"""
        data = {}
        set_nested(data, "a.b.c", 1)
        self.assertEqual(data["a"]["b"]["c"], 1)

    def test_set_nested_existing(self):
        """测试覆盖现有值。"""
        data = {"a": {"b": 1}}
        set_nested(data, "a.b", 2)
        self.assertEqual(data["a"]["b"], 2)


if __name__ == "__main__":
    unittest.main()
