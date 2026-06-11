#!/usr/bin/env python3
"""
merge_router.py 单元测试
"""

import os
import sys
import tempfile
import unittest


SCRIPT_DIR = os.path.join(os.path.dirname(os.path.dirname(os.path.abspath(__file__))), "scripts")
sys.path.insert(0, SCRIPT_DIR)

from merge_router import (
    extract_route_object, extract_route_name,
    check_name_exists, find_dynamic_routes_end, merge_route
)


class TestExtractRouteObject(unittest.TestCase):
    """测试路由对象提取。"""

    def setUp(self):
        self.temp_dir = tempfile.mkdtemp()

    def tearDown(self):
        import shutil
        shutil.rmtree(self.temp_dir)

    def test_extract_route(self):
        """测试提取路由对象。"""
        bak_path = os.path.join(self.temp_dir, "route-index-bak.ts")
        with open(bak_path, "w") as f:
            f.write("""
// ============================================================
// 子表路由配置
// ============================================================

// 客户信息 - 商品管理
{
  path: '/demo/customer-goods',
  component: Layout,
  hidden: true,
  permissions: ['demo:customer:goods:list'],
  children: [
    {
      path: 'index/:customerId(\\\\d+)',
      component: () => import('@/views/demo/goods/index.vue'),
      name: 'Goods',
      meta: { title: '商品管理', activeMenu: '/demo/customer' }
    }
  ]
}
""")
        route = extract_route_object(bak_path)
        self.assertIsNotNone(route)
        self.assertIn("path: '/demo/customer-goods'", route)
        self.assertIn("name: 'Goods'", route)

    def test_extract_nonexistent(self):
        """测试不存在的文件。"""
        route = extract_route_object("/nonexistent/path.ts")
        self.assertIsNone(route)


class TestExtractRouteName(unittest.TestCase):
    """测试路由名称提取。"""

    def test_extract_name(self):
        """测试提取 name 字段。"""
        content = "{ name: 'Goods', path: '/demo' }"
        name = extract_route_name(content)
        self.assertEqual(name, "Goods")

    def test_extract_name_double_quotes(self):
        """测试双引号格式。"""
        content = '{ name: "Goods" }'
        name = extract_route_name(content)
        self.assertEqual(name, "Goods")

    def test_extract_no_name(self):
        """测试无 name 字段。"""
        content = "{ path: '/demo' }"
        name = extract_route_name(content)
        self.assertIsNone(name)


class TestCheckNameExists(unittest.TestCase):
    """测试路由名称去重检查。"""

    def test_name_exists(self):
        """测试名称存在。"""
        content = """
export const dynamicRoutes = [
  { name: 'Goods', path: '/demo' }
]
"""
        self.assertTrue(check_name_exists(content, "Goods"))

    def test_name_not_exists(self):
        """测试名称不存在。"""
        content = """
export const dynamicRoutes = [
  { name: 'Other', path: '/demo' }
]
"""
        self.assertFalse(check_name_exists(content, "Goods"))


class TestFindDynamicRoutesEnd(unittest.TestCase):
    """测试 dynamicRoutes 末尾定位。"""

    def test_find_end(self):
        """测试找到末尾 ]。"""
        content = """
export const dynamicRoutes = [
  { name: 'Goods' }
]
"""
        pos = find_dynamic_routes_end(content)
        self.assertGreater(pos, 0)
        self.assertEqual(content[pos], "]")

    def test_find_nested(self):
        """测试嵌套数组。"""
        content = """
export const dynamicRoutes = [
  {
    children: [
      { name: 'Sub' }
    ]
  }
]
"""
        pos = find_dynamic_routes_end(content)
        self.assertGreater(pos, 0)
        self.assertEqual(content[pos], "]")


class TestMergeRoute(unittest.TestCase):
    """测试路由合并。"""

    def setUp(self):
        self.temp_dir = tempfile.mkdtemp()
        self.bak_path = os.path.join(self.temp_dir, "route-index-bak.ts")
        self.target_path = os.path.join(self.temp_dir, "router.ts")

    def tearDown(self):
        import shutil
        shutil.rmtree(self.temp_dir)

    def test_merge_new_route(self):
        """测试合并新路由。"""
        with open(self.bak_path, "w") as f:
            f.write("""
{
  path: '/demo/goods',
  name: 'Goods',
  children: []
}
""")
        with open(self.target_path, "w") as f:
            f.write("""
export const dynamicRoutes = [
  { name: 'Other', path: '/other' }
]
""")
        success, msg = merge_route(self.bak_path, self.target_path)
        self.assertTrue(success)

        with open(self.target_path, "r") as f:
            content = f.read()
        self.assertIn("name: 'Goods'", content)
        self.assertIn("name: 'Other'", content)

    def test_merge_dedup(self):
        """测试去重。"""
        with open(self.bak_path, "w") as f:
            f.write("{ name: 'Goods', path: '/demo' }")
        with open(self.target_path, "w") as f:
            f.write("export const dynamicRoutes = [\n{ name: 'Goods' }\n]")

        success, msg = merge_route(self.bak_path, self.target_path)
        self.assertTrue(success)
        self.assertIn("已存在", msg)

    def test_merge_dry_run(self):
        """测试预览模式。"""
        with open(self.bak_path, "w") as f:
            f.write("{ name: 'Goods', path: '/demo' }")
        with open(self.target_path, "w") as f:
            f.write("export const dynamicRoutes = []\n")

        success, msg = merge_route(self.bak_path, self.target_path, dry_run=True)
        self.assertTrue(success)

        # 目标文件未修改
        with open(self.target_path, "r") as f:
            content = f.read()
        self.assertNotIn("name: 'Goods'", content)


if __name__ == "__main__":
    unittest.main()
