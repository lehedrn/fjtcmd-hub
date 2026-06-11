package com.fjtcmd.hub.generator.cli;

import java.util.Map;

/**
 * CLI YAML 配置模型
 * <p>
 * 对齐 RuoYi 代码生成的三层配置：全局默认 → 表级配置（基本信息 + 生成信息） → 列级配置（字段信息）。
 * <p>
 * 配置文件示例：
 * <pre>
 * # ==================== 全局默认配置 ====================
 * global:
 *   author: ztq                        # 作者
 *   packageName: com.fjtcmd.hub.biz    # 生成包路径
 *   autoRemovePre: true                # 自动去除表前缀
 *   tablePrefix: sys_                  # 表前缀（多个逗号分隔）
 *   tplCategory: crud                  # 模板类型: crud / tree / sub
 *   tplWebType: element-plus-typescript # 前端类型: element-plus / element-plus-typescript
 *   formColNum: 2                      # 表单列数: 1/2/3
 *   parentMenuId: 1                    # 上级菜单ID
 *   genView: false                     # 是否生成详情页
 *   output: ./generated                # 输出目录
 *   allowOverwrite: false              # 允许覆盖文件
 *
 * # ==================== 表级 / 列级配置 ====================
 * tables:
 *   sys_student:
 *     functionName: 学生信息
 *     genView: true
 *     columns:
 *       student_hobby:
 *         htmlType: checkbox
 *         dictType: biz_student_hobby
 *       student_birthday:
 *         queryType: BETWEEN
 * </pre>
 */
public class GenCliConfig
{
    /** 全局默认配置 */
    private GlobalConfig global;

    /** 表级配置，key = 表名 */
    private Map<String, TableConfig> tables;

    public GlobalConfig getGlobal()
    {
        return global;
    }

    public void setGlobal(GlobalConfig global)
    {
        this.global = global;
    }

    public Map<String, TableConfig> getTables()
    {
        return tables;
    }

    public void setTables(Map<String, TableConfig> tables)
    {
        this.tables = tables;
    }

    // ========== 全局配置 ==========

    public static class GlobalConfig
    {
        /** 作者 */
        private String author;
        /** 生成包路径 */
        private String packageName;
        /** 自动去除表前缀 */
        private Boolean autoRemovePre;
        /** 表前缀（多个逗号分隔） */
        private String tablePrefix;
        /** 模板类型: crud / tree / sub */
        private String tplCategory;
        /** 前端类型: element-plus / element-plus-typescript */
        private String tplWebType;
        /** 表单列数: 1/2/3 */
        private Integer formColNum;
        /** 上级菜单ID */
        private Long parentMenuId;
        /** 是否生成详情页 */
        private Boolean genView;
        /** 输出目录 */
        private String output;
        /** 允许覆盖文件 */
        private Boolean allowOverwrite;

        public String getAuthor() { return author; }
        public void setAuthor(String author) { this.author = author; }

        public String getPackageName() { return packageName; }
        public void setPackageName(String packageName) { this.packageName = packageName; }

        public Boolean getAutoRemovePre() { return autoRemovePre; }
        public void setAutoRemovePre(Boolean autoRemovePre) { this.autoRemovePre = autoRemovePre; }

        public String getTablePrefix() { return tablePrefix; }
        public void setTablePrefix(String tablePrefix) { this.tablePrefix = tablePrefix; }

        public String getTplCategory() { return tplCategory; }
        public void setTplCategory(String tplCategory) { this.tplCategory = tplCategory; }

        public String getTplWebType() { return tplWebType; }
        public void setTplWebType(String tplWebType) { this.tplWebType = tplWebType; }

        public Integer getFormColNum() { return formColNum; }
        public void setFormColNum(Integer formColNum) { this.formColNum = formColNum; }

        public Long getParentMenuId() { return parentMenuId; }
        public void setParentMenuId(Long parentMenuId) { this.parentMenuId = parentMenuId; }

        public Boolean getGenView() { return genView; }
        public void setGenView(Boolean genView) { this.genView = genView; }

        public String getOutput() { return output; }
        public void setOutput(String output) { this.output = output; }

        public Boolean getAllowOverwrite() { return allowOverwrite; }
        public void setAllowOverwrite(Boolean allowOverwrite) { this.allowOverwrite = allowOverwrite; }
    }

    // ========== 表级配置 ==========

    public static class TableConfig
    {
        // --- 基本信息 ---
        /** 表描述（覆盖 DDL 中的 COMMENT） */
        private String tableComment;
        /** 实体类名（覆盖自动转换） */
        private String className;
        /** 作者（覆盖全局 author） */
        private String functionAuthor;
        /** 功能名（菜单显示名） */
        private String functionName;

        // --- 生成信息 ---
        /** 模板类型: crud / tree / sub */
        private String tplCategory;
        /** 前端类型 */
        private String tplWebType;
        /** 生成包路径（覆盖全局） */
        private String packageName;
        /** 模块名 */
        private String moduleName;
        /** 业务名 */
        private String businessName;
        /** 上级菜单ID（覆盖全局） */
        private Long parentMenuId;
        /** 表单列数（覆盖全局） */
        private Integer formColNum;
        /** 是否生成详情页（覆盖全局） */
        private Boolean genView;

        // --- 树表配置（tplCategory=tree 时有效） ---
        private String treeCode;
        private String treeParentCode;
        private String treeName;

        // --- 主子表配置（tplCategory=sub 时有效） ---
        private String subTableName;
        private String subTableFkName;

        // --- 主子表模板配置（新设计） ---
        /** 是否有子表（主表配置） */
        private Boolean hasSubTable;
        /** 子表配置信息 */
        private SubTableConfig subTable;
        /** 是否是子表（子表配置） */
        private Boolean isSubTable;
        /** 主表配置信息 */
        private MainTableConfig mainTable;

        // --- 菜单排序号 ---
        /** 菜单排序号 */
        private Integer orderNum;

        // --- 列级配置 ---
        /** 列级配置，key = 列名 */
        private Map<String, ColumnConfig> columns;

        public String getTableComment() { return tableComment; }
        public void setTableComment(String tableComment) { this.tableComment = tableComment; }

        public String getClassName() { return className; }
        public void setClassName(String className) { this.className = className; }

        public String getFunctionAuthor() { return functionAuthor; }
        public void setFunctionAuthor(String functionAuthor) { this.functionAuthor = functionAuthor; }

        public String getFunctionName() { return functionName; }
        public void setFunctionName(String functionName) { this.functionName = functionName; }

        public String getTplCategory() { return tplCategory; }
        public void setTplCategory(String tplCategory) { this.tplCategory = tplCategory; }

        public String getTplWebType() { return tplWebType; }
        public void setTplWebType(String tplWebType) { this.tplWebType = tplWebType; }

        public String getPackageName() { return packageName; }
        public void setPackageName(String packageName) { this.packageName = packageName; }

        public String getModuleName() { return moduleName; }
        public void setModuleName(String moduleName) { this.moduleName = moduleName; }

        public String getBusinessName() { return businessName; }
        public void setBusinessName(String businessName) { this.businessName = businessName; }

        public Long getParentMenuId() { return parentMenuId; }
        public void setParentMenuId(Long parentMenuId) { this.parentMenuId = parentMenuId; }

        public Integer getFormColNum() { return formColNum; }
        public void setFormColNum(Integer formColNum) { this.formColNum = formColNum; }

        public Boolean getGenView() { return genView; }
        public void setGenView(Boolean genView) { this.genView = genView; }

        public String getTreeCode() { return treeCode; }
        public void setTreeCode(String treeCode) { this.treeCode = treeCode; }

        public String getTreeParentCode() { return treeParentCode; }
        public void setTreeParentCode(String treeParentCode) { this.treeParentCode = treeParentCode; }

        public String getTreeName() { return treeName; }
        public void setTreeName(String treeName) { this.treeName = treeName; }

        public String getSubTableName() { return subTableName; }
        public void setSubTableName(String subTableName) { this.subTableName = subTableName; }

        public String getSubTableFkName() { return subTableFkName; }
        public void setSubTableFkName(String subTableFkName) { this.subTableFkName = subTableFkName; }

        public Boolean getHasSubTable() { return hasSubTable; }
        public void setHasSubTable(Boolean hasSubTable) { this.hasSubTable = hasSubTable; }

        public SubTableConfig getSubTable() { return subTable; }
        public void setSubTable(SubTableConfig subTable) { this.subTable = subTable; }

        public Boolean getIsSubTable() { return isSubTable; }
        public void setIsSubTable(Boolean isSubTable) { this.isSubTable = isSubTable; }

        public MainTableConfig getMainTable() { return mainTable; }
        public void setMainTable(MainTableConfig mainTable) { this.mainTable = mainTable; }

        public Integer getOrderNum() { return orderNum; }
        public void setOrderNum(Integer orderNum) { this.orderNum = orderNum; }

        public Map<String, ColumnConfig> getColumns() { return columns; }
        public void setColumns(Map<String, ColumnConfig> columns) { this.columns = columns; }
    }

    // ========== 子表配置 ==========

    /**
     * 子表配置（主表中使用）
     * <p>
     * 示例配置：
     * <pre>
     * subTable:
     *   className: Goods         # 子表类名
     *   businessName: goods      # 子表业务名
     *   subRoute: customer-goods # 子表路由路径
     *   functionName: 商品       # 子表功能名
     *   fkName: customer_id      # 外键列名
     *   fkJavaField: customerId  # 外键Java字段
     *   permissionPrefix: goods  # 子表权限前缀
     * </pre>
     */
    public static class SubTableConfig
    {
        /** 子表类名 */
        private String className;
        /** 子表业务名 */
        private String businessName;
        /** 子表路由路径 */
        private String subRoute;
        /** 子表功能名（中文） */
        private String functionName;
        /** 外键列名（数据库） */
        private String fkName;
        /** 外键Java字段名 */
        private String fkJavaField;
        /** 子表权限前缀 */
        private String permissionPrefix;

        public String getClassName() { return className; }
        public void setClassName(String className) { this.className = className; }

        public String getBusinessName() { return businessName; }
        public void setBusinessName(String businessName) { this.businessName = businessName; }

        public String getSubRoute() { return subRoute; }
        public void setSubRoute(String subRoute) { this.subRoute = subRoute; }

        public String getFunctionName() { return functionName; }
        public void setFunctionName(String functionName) { this.functionName = functionName; }

        public String getFkName() { return fkName; }
        public void setFkName(String fkName) { this.fkName = fkName; }

        public String getFkJavaField() { return fkJavaField; }
        public void setFkJavaField(String fkJavaField) { this.fkJavaField = fkJavaField; }

        public String getPermissionPrefix() { return permissionPrefix; }
        public void setPermissionPrefix(String permissionPrefix) { this.permissionPrefix = permissionPrefix; }
    }

    // ========== 主表配置 ==========

    /**
     * 主表配置（子表中使用）
     * <p>
     * 示例配置：
     * <pre>
     * mainTable:
     *   className: Customer      # 主表类名
     *   businessName: customer   # 主表业务名
     *   tableName: sys_customer  # 主表表名
     *   functionName: 客户       # 主表功能名
     *   pkJavaField: customerId  # 主表主键字段
     *   nameJavaField: customerName # 主表名称字段
     * </pre>
     */
    public static class MainTableConfig
    {
        /** 主表类名 */
        private String className;
        /** 主表业务名 */
        private String businessName;
        /** 主表表名 */
        private String tableName;
        /** 主表功能名（中文） */
        private String functionName;
        /** 主表主键字段（Java属性名） */
        private String pkJavaField;
        /** 主表名称字段（Java属性名，用于下拉框显示） */
        private String nameJavaField;
        /** 外键字段名（子表关联主表的字段，可选，从主表subTable配置自动获取） */
        private String fkJavaField;

        public String getClassName() { return className; }
        public void setClassName(String className) { this.className = className; }

        public String getBusinessName() { return businessName; }
        public void setBusinessName(String businessName) { this.businessName = businessName; }

        public String getTableName() { return tableName; }
        public void setTableName(String tableName) { this.tableName = tableName; }

        public String getFunctionName() { return functionName; }
        public void setFunctionName(String functionName) { this.functionName = functionName; }

        public String getPkJavaField() { return pkJavaField; }
        public void setPkJavaField(String pkJavaField) { this.pkJavaField = pkJavaField; }

        public String getNameJavaField() { return nameJavaField; }
        public void setNameJavaField(String nameJavaField) { this.nameJavaField = nameJavaField; }

        public String getFkJavaField() { return fkJavaField; }
        public void setFkJavaField(String fkJavaField) { this.fkJavaField = fkJavaField; }
    }

    // ========== 列级配置 ==========

    public static class ColumnConfig
    {
        /** 字段描述 */
        private String columnComment;
        /** Java类型 */
        private String javaType;
        /** Java属性名 */
        private String javaField;
        /** 是否插入字段 */
        private Boolean isInsert;
        /** 是否编辑字段 */
        private Boolean isEdit;
        /** 是否列表字段 */
        private Boolean isList;
        /** 是否查询字段 */
        private Boolean isQuery;
        /** 是否必填 */
        private Boolean isRequired;
        /** 查询方式: EQ / NE / GT / GTE / LT / LTE / LIKE / BETWEEN */
        private String queryType;
        /** 显示类型: input / textarea / select / radio / checkbox / datetime / imageUpload / fileUpload / editor */
        private String htmlType;
        /** 字典类型编码 */
        private String dictType;

        public String getColumnComment() { return columnComment; }
        public void setColumnComment(String columnComment) { this.columnComment = columnComment; }

        public String getJavaType() { return javaType; }
        public void setJavaType(String javaType) { this.javaType = javaType; }

        public String getJavaField() { return javaField; }
        public void setJavaField(String javaField) { this.javaField = javaField; }

        public Boolean getIsInsert() { return isInsert; }
        public void setIsInsert(Boolean isInsert) { this.isInsert = isInsert; }

        public Boolean getIsEdit() { return isEdit; }
        public void setIsEdit(Boolean isEdit) { this.isEdit = isEdit; }

        public Boolean getIsList() { return isList; }
        public void setIsList(Boolean isList) { this.isList = isList; }

        public Boolean getIsQuery() { return isQuery; }
        public void setIsQuery(Boolean isQuery) { this.isQuery = isQuery; }

        public Boolean getIsRequired() { return isRequired; }
        public void setIsRequired(Boolean isRequired) { this.isRequired = isRequired; }

        public String getQueryType() { return queryType; }
        public void setQueryType(String queryType) { this.queryType = queryType; }

        public String getHtmlType() { return htmlType; }
        public void setHtmlType(String htmlType) { this.htmlType = htmlType; }

        public String getDictType() { return dictType; }
        public void setDictType(String dictType) { this.dictType = dictType; }
    }
}
