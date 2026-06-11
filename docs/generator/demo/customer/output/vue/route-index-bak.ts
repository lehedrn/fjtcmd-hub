// ============================================================
// 子表路由配置（需要手动插入到 router/index.ts 的 dynamicRoutes 中）
// ============================================================
//
// 使用说明：
// 1. 打开 src/router/index.ts 文件
// 2. 找到 dynamicRoutes 数组
// 3. 将以下内容复制到 dynamicRoutes 数组中
// 4. 保存文件
//
// 生成时间: 2026-06-11
// 主表: 客户信息 (sys_customer)
// 子表: 商品 (Goods)
// ============================================================

// 客户信息 - 商品管理
{
  path: '/demo/customer-goods',
  component: Layout,
  hidden: true,
  permissions: ['demo:customer:goods:list'],
  children: [
    {
      path: 'index/:customerId(\\d+)',
      component: () => import('@/views/demo/goods/index.vue'),
      name: 'Goods',
      meta: {
        title: '商品管理',
        activeMenu: '/demo/customer'
      }
    }
  ]
}
