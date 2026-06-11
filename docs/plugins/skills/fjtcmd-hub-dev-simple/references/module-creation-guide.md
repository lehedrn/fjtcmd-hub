# Maven 子模块创建指南

当目标模块不存在时，按以下步骤创建。

---

## 1. 检查现有模块

```bash
ls fjtcmd-hub-{module}/pom.xml 2>/dev/null
```

如果存在，跳到第 5 步检查依赖。

## 2. 创建模块目录结构

```bash
MODULE={module}
PROJECT_ROOT=/home/workspaces/com/ztq/tcmd/fjtcmd-hub

mkdir -p ${PROJECT_ROOT}/fjtcmd-hub-${MODULE}/src/main/java/com/fjtcmd/hub/${MODULE}/{controller,service/impl,mapper,domain}
mkdir -p ${PROJECT_ROOT}/fjtcmd-hub-${MODULE}/src/main/resources/mapper/${MODULE}
mkdir -p ${PROJECT_ROOT}/fjtcmd-hub-${MODULE}/src/test/java/com/fjtcmd/hub/${MODULE}
```

## 3. 创建 pom.xml

参考已有模块 `fjtcmd-hub-demo/pom.xml`，模板如下：

```xml
<?xml version="1.0" encoding="UTF-8"?>
<project xmlns="http://maven.apache.org/POM/4.0.0"
         xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 http://maven.apache.org/xsd/maven-4.0.0.xsd">
    <parent>
        <groupId>com.fjtcmd</groupId>
        <artifactId>fjtcmd-hub</artifactId>
        <version>3.9.0</version>
    </parent>
    <modelVersion>4.0.0</modelVersion>

    <artifactId>fjtcmd-hub-{module}</artifactId>

    <description>
        {模块描述}
    </description>

    <dependencies>
        <!-- 通用工具 -->
        <dependency>
            <groupId>com.fjtcmd</groupId>
            <artifactId>fjtcmd-hub-common</artifactId>
        </dependency>

        <!-- 如需依赖系统模块，取消注释 -->
        <!--
        <dependency>
            <groupId>com.fjtcmd</groupId>
            <artifactId>fjtcmd-hub-system</artifactId>
        </dependency>
        -->
    </dependencies>
</project>
```

## 4. 更新父 POM

编辑根目录 `pom.xml`，在 `<modules>` 中添加：

```xml
<module>fjtcmd-hub-{module}</module>
```

## 5. 更新 admin 依赖

编辑 `fjtcmd-hub-admin/pom.xml`，在 `<dependencies>` 中添加：

```xml
<!-- {模块描述} -->
<dependency>
    <groupId>com.fjtcmd</groupId>
    <artifactId>fjtcmd-hub-{module}</artifactId>
</dependency>
```

## 6. 创建包占位文件

在每个包目录下创建 `package-info.java`：

```java
/**
 * {模块名} - {包名}
 */
package com.fjtcmd.hub.{module}.{subpackage};
```

## 7. 检查依赖完整性

询问用户：

> 该模块是否需要引入其他子模块的依赖？
>
> 常见依赖：
> - `fjtcmd-hub-common` — 通用工具（已默认添加）
> - `fjtcmd-hub-system` — 系统模块（用户、角色、部门等服务）
> - `fjtcmd-hub-framework` — 框架模块

如果需要，编辑模块的 `pom.xml` 添加相应依赖。

## 8. 验证

```bash
cd /home/workspaces/com/ztq/tcmd/fjtcmd-hub
./scripts/build/backend.sh clean-install
```

编译成功表示模块创建完成。
