create table sys_student (
  student_id      bigint(20)    not null auto_increment  comment '编号',
  student_name    varchar(50)   not null                 comment '学生名称',
  student_sex     char(1)       default '0'              comment '性别（0男 1女 2未知）',
  student_age     int(3)        default null              comment '年龄',
  student_birthday datetime                             comment '生日',
  student_phone   varchar(20)   default ''               comment '联系电话',
  status          char(1)       default '0'              comment '状态（0正常 1停用）',
  create_by       varchar(64)   default ''               comment '创建者',
  create_time     datetime                               comment '创建时间',
  update_by       varchar(64)   default ''               comment '更新者',
  update_time     datetime                               comment '更新时间',
  remark          varchar(500)  default null              comment '备注',
  del_flag        char(1)       default '0'              comment '删除标志（0代表存在 1代表删除）',
  primary key (student_id)
) engine=innodb auto_increment=1 comment = '学生信息表';
