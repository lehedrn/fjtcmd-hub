-- ============================================
-- 为每个客户添加30条商品信息
-- ============================================

-- 清空旧数据
DELETE FROM sys_goods;
ALTER TABLE sys_goods AUTO_INCREMENT = 1;

-- 商品名称模板
SET @goods_names = 'iPhone 15,MacBook Pro,iPad Air,AirPods Pro,Apple Watch,华为手机,联想电脑,戴尔显示器,机械键盘,罗技鼠标,索尼耳机,三星平板,小米手环,任天堂Switch,PS5游戏机,佳能相机,大疆无人机,博世电钻,飞利浦牙刷,戴森吹风机,星巴克咖啡,农夫山泉,蒙牛牛奶,康师傅方便面,百草味零食,耐克运动鞋,阿迪达斯T恤,优衣库裤子,宜家收纳箱,南极人保暖衣';

-- 为每个客户生成30条商品（共30个客户 x 30条 = 900条）
INSERT INTO sys_goods (customer_id, name, weight, price, date, type)
SELECT
    c.customer_id,
    SUBSTRING_INDEX(SUBSTRING_INDEX(@goods_names, ',', n.n), ',', -1) AS name,
    ROUND(0.1 + RAND() * 15, 1) AS weight,
    ROUND(10 + RAND() * 9990, 2) AS price,
    DATE_ADD('2024-01-01', INTERVAL FLOOR(RAND() * 365) DAY) + INTERVAL FLOOR(RAND() * 24) HOUR + INTERVAL FLOOR(RAND() * 60) MINUTE AS date,
    CAST(FLOOR(RAND() * 4) AS CHAR) AS type
FROM sys_customer c
CROSS JOIN (
    SELECT 1 AS n UNION SELECT 2 UNION SELECT 3 UNION SELECT 4 UNION SELECT 5
    UNION SELECT 6 UNION SELECT 7 UNION SELECT 8 UNION SELECT 9 UNION SELECT 10
    UNION SELECT 11 UNION SELECT 12 UNION SELECT 13 UNION SELECT 14 UNION SELECT 15
    UNION SELECT 16 UNION SELECT 17 UNION SELECT 18 UNION SELECT 19 UNION SELECT 20
    UNION SELECT 21 UNION SELECT 22 UNION SELECT 23 UNION SELECT 24 UNION SELECT 25
    UNION SELECT 26 UNION SELECT 27 UNION SELECT 28 UNION SELECT 29 UNION SELECT 30
) n
ORDER BY c.customer_id, n.n;

SELECT '商品数据插入完成！' AS result;
SELECT customer_id, COUNT(*) AS goods_count
FROM sys_goods
GROUP BY customer_id
ORDER BY customer_id;
SELECT '总计' AS summary, COUNT(*) AS total_goods FROM sys_goods;
