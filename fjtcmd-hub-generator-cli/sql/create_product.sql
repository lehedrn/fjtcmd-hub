-- ============================================
-- 若依代码生成 CLI 工具 - CREATE TABLE SQL 示例
-- ============================================
-- 使用方式: --sql sql/create_product.sql

CREATE TABLE fjtcmd_product (
  id          BIGINT AUTO_INCREMENT PRIMARY KEY COMMENT '主键ID',
  product_name VARCHAR(200) DEFAULT '' COMMENT '商品名称',
  price       DECIMAL(10,2) DEFAULT 0.00 COMMENT '价格（元）',
  stock       INT DEFAULT 0 COMMENT '库存数量',
  status      TINYINT DEFAULT 0 COMMENT '状态（0下架 1上架）',
  image       VARCHAR(500) DEFAULT '' COMMENT '商品图片',
  description TEXT COMMENT '商品描述',
  create_by   VARCHAR(64) DEFAULT '' COMMENT '创建者',
  create_time DATETIME COMMENT '创建时间',
  update_by   VARCHAR(64) DEFAULT '' COMMENT '更新者',
  update_time DATETIME COMMENT '更新时间',
  remark      VARCHAR(500) DEFAULT NULL COMMENT '备注'
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8mb4 COMMENT='商品信息表';
