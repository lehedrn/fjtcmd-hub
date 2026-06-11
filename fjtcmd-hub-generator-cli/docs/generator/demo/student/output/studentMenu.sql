-- 菜单 SQL
insert into sys_menu (menu_name, parent_id, order_num, path, component, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, update_by, update_time, remark)
values('学生信息', '2006', '1', 'student', 'demo/student/index', 1, 0, 'C', '0', '0', 'demo:student:list', '#', 'admin', sysdate(), '', null, '学生信息菜单');

-- 按钮父菜单ID
SELECT @parentId := LAST_INSERT_ID();

-- 按钮 SQL
insert into sys_menu (menu_name, parent_id, order_num, path, component, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, update_by, update_time, remark)
values('学生信息查询', @parentId, '1',  '#', '', 1, 0, 'F', '0', '0', 'demo:student:query',        '#', 'admin', sysdate(), '', null, '');

insert into sys_menu (menu_name, parent_id, order_num, path, component, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, update_by, update_time, remark)
values('学生信息新增', @parentId, '2',  '#', '', 1, 0, 'F', '0', '0', 'demo:student:add',          '#', 'admin', sysdate(), '', null, '');

insert into sys_menu (menu_name, parent_id, order_num, path, component, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, update_by, update_time, remark)
values('学生信息修改', @parentId, '3',  '#', '', 1, 0, 'F', '0', '0', 'demo:student:edit',         '#', 'admin', sysdate(), '', null, '');

insert into sys_menu (menu_name, parent_id, order_num, path, component, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, update_by, update_time, remark)
values('学生信息删除', @parentId, '4',  '#', '', 1, 0, 'F', '0', '0', 'demo:student:remove',       '#', 'admin', sysdate(), '', null, '');

insert into sys_menu (menu_name, parent_id, order_num, path, component, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, update_by, update_time, remark)
values('学生信息导出', @parentId, '5',  '#', '', 1, 0, 'F', '0', '0', 'demo:student:export',       '#', 'admin', sysdate(), '', null, '');