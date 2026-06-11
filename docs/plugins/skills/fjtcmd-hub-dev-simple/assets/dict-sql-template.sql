-- ==========================================
-- 字典 SQL 模板
-- 使用方法：替换 {} 中的占位符
-- ==========================================

-- 1. 创建字典类型
INSERT INTO sys_dict_type (dict_id, dict_name, dict_type, status, create_by, create_time, remark)
VALUES (
    (SELECT IFNULL(MAX(dict_id), 100) + 1 FROM sys_dict_type t),
    '{字典名称}',           -- 如：文章状态
    '{biz_xxx_type}',       -- 如：biz_article_status
    '0', 'admin', NOW(), '{备注}'
);

-- 2. 创建字典数据
INSERT INTO sys_dict_data (dict_code, dict_sort, dict_label, dict_value, dict_type, css_class, list_class, is_default, status, create_by, create_time, remark)
VALUES
-- 第一个选项（默认选中）
(
    (SELECT IFNULL(MAX(dict_code), 1000) + 1 FROM sys_dict_data d),
    1, '{标签1}', '0', '{biz_xxx_type}', '', 'default', 'Y', '0', 'admin', NOW(), '{备注}'
),
-- 第二个选项
(
    (SELECT IFNULL(MAX(dict_code), 1000) + 2 FROM sys_dict_data d),
    2, '{标签2}', '1', '{biz_xxx_type}', '', 'primary', 'N', '0', 'admin', NOW(), '{备注}'
),
-- 第三个选项
(
    (SELECT IFNULL(MAX(dict_code), 1000) + 3 FROM sys_dict_data d),
    3, '{标签3}', '2', '{biz_xxx_type}', '', 'warning', 'N', '0', 'admin', NOW(), '{备注}'
);

-- ==========================================
-- css_class 可选值：default, primary, success, info, warning, danger
-- list_class 可选值：default, primary, success, info, warning, danger
-- 用于前端 el-tag 的颜色显示
-- ==========================================
