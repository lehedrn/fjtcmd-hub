create table sys_product (
  product_id        bigint(20)      not null auto_increment    comment '产品id',
  parent_id         bigint(20)      default 0                  comment '父产品id',
  ancestors         varchar(500)    default '0'                comment '祖级列表',
  product_name      varchar(30)     default ''                 comment '产品名称',
  order_num         int(4)          default 0                  comment '显示顺序',
  status            char(1)         default '0'                comment '产品状态（0正常 1停用）',
  primary key (product_id)
) engine=innodb auto_increment=1 comment = '产品表';
