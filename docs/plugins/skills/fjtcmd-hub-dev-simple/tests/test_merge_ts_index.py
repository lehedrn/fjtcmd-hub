#!/usr/bin/env python3
"""
merge_ts_index.py 单元测试
"""

import os
import sys
import tempfile
import unittest


SCRIPT_DIR = os.path.join(os.path.dirname(os.path.dirname(os.path.abspath(__file__))), "scripts")
sys.path.insert(0, SCRIPT_DIR)

from merge_ts_index import extract_exports, get_existing_exports, merge_exports


class TestExtractExports(unittest.TestCase):
    """测试 export 行提取。"""

    def setUp(self):
        self.temp_dir = tempfile.mkdtemp()

    def tearDown(self):
        import shutil
        shutil.rmtree(self.temp_dir)

    def test_extract_from_bak(self):
        """测试从 bak 文件提取 export。"""
        bak_path = os.path.join(self.temp_dir, "index-bak.ts")
        with open(bak_path, "w") as f:
            f.write("""
/**
 * API 类型统一导出
 */
....

// demo 模块
export * from "./demo/student";
export * from "./demo/product";
""")
        exports = extract_exports(bak_path)
        self.assertEqual(len(exports), 2)
        self.assertIn('export * from "./demo/student";', exports)
        self.assertIn('export * from "./demo/product";', exports)

    def test_extract_empty(self):
        """测试空文件。"""
        bak_path = os.path.join(self.temp_dir, "empty.ts")
        with open(bak_path, "w") as f:
            f.write("// just a comment")
        exports = extract_exports(bak_path)
        self.assertEqual(len(exports), 0)

    def test_extract_nonexistent(self):
        """测试不存在的文件。"""
        exports = extract_exports("/nonexistent/path.ts")
        self.assertEqual(len(exports), 0)


class TestMergeExports(unittest.TestCase):
    """测试 export 合并。"""

    def setUp(self):
        self.temp_dir = tempfile.mkdtemp()
        self.bak_path = os.path.join(self.temp_dir, "index-bak.ts")
        self.target_path = os.path.join(self.temp_dir, "index.ts")

    def tearDown(self):
        import shutil
        shutil.rmtree(self.temp_dir)

    def test_merge_new_exports(self):
        """测试合并新的 export。"""
        with open(self.bak_path, "w") as f:
            f.write('export * from "./demo/student";\n')
        with open(self.target_path, "w") as f:
            f.write('export * from "./common";\n')

        count, new = merge_exports(self.bak_path, self.target_path)
        self.assertEqual(count, 1)
        self.assertEqual(len(new), 1)

        # 验证目标文件已更新
        with open(self.target_path, "r") as f:
            content = f.read()
        self.assertIn('export * from "./demo/student";', content)
        self.assertIn('export * from "./common";', content)

    def test_merge_dedup(self):
        """测试去重。"""
        with open(self.bak_path, "w") as f:
            f.write('export * from "./demo/student";\n')
        with open(self.target_path, "w") as f:
            f.write('export * from "./demo/student";\n')

        count, new = merge_exports(self.bak_path, self.target_path)
        self.assertEqual(count, 0)  # 已存在，不新增
        self.assertEqual(len(new), 0)

    def test_merge_dry_run(self):
        """测试预览模式不写入。"""
        with open(self.bak_path, "w") as f:
            f.write('export * from "./demo/student";\n')
        with open(self.target_path, "w") as f:
            f.write('export * from "./common";\n')

        count, new = merge_exports(self.bak_path, self.target_path, dry_run=True)
        self.assertEqual(count, 1)

        # 验证目标文件未修改
        with open(self.target_path, "r") as f:
            content = f.read()
        self.assertNotIn('export * from "./demo/student";', content)


if __name__ == "__main__":
    unittest.main()
