# 示例 1：标准 CRUD（学生管理）

最简单的单表 CRUD 场景。

---

## 调用方式

```bash
/fjtcmd-hub-dev-simple 我要做一个学生管理功能，管理姓名、性别、年龄、生日、联系电话，放到示例模块下面
```

## 推断结果

| 项目 | 值 |
|------|-----|
| 模板类型 | CRUD（标准单表） |
| 模块编码 | demo.student |
| 表名 | sys_student |
| 目标模块 | fjtcmd-hub-demo |

## 字段设计

| 字段 | 类型 | 必填 | 表单 | 查询 |
|------|------|------|------|------|
| student_name | VARCHAR(50) | 是 | input | LIKE |
| student_sex | CHAR(1) | 是 | select (sys_user_sex) | — |
| student_age | INT | 否 | input | — |
| student_birthday | DATETIME | 否 | datetime | BETWEEN |
| student_phone | VARCHAR(20) | 否 | input | EQ |
| status | CHAR(1) | 是 | radio (sys_normal_disable) | EQ |

## 字典

全部使用系统已有字典，无需新建。

## 生成的文件

```
generate/demo/student/
├── student.sql              # DDL
├── student.yml              # YAML 配置
└── output/                  # CLI 生成
    ├── main/java/com/fjtcmd/hub/demo/
    │   ├── controller/StudentController.java
    │   ├── domain/Student.java
    │   ├── mapper/StudentMapper.java
    │   ├── service/IStudentService.java
    │   └── service/impl/StudentServiceImpl.java
    ├── main/resources/mapper/demo/StudentMapper.xml
    ├── studentMenu.sql
    └── vue/
        ├── api/demo/student.ts
        ├── types/api/demo/student.ts
        └── views/demo/student/{index,view}.vue
```

## 测试

```bash
# 模拟数据：20 条学生记录
./scripts/test/curl/test-demo-student.sh
```

---

**要点**：纯 CRUD，无业务规则，全部自动完成。
