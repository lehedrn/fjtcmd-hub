@echo off
chcp 65001 >nul 2>&1
setlocal

:: fjtcmd-hub 后端 Maven 编译脚本 (Windows 版本)
:: 用法：scripts\build\backend.bat [clean|compile|package|install|clean-install|test]

set PROJECT_HOME=%~dp0..\..
cd /d "%PROJECT_HOME%"

:: 处理命令
if "%1"=="clean" goto :clean
if "%1"=="compile" goto :compile
if "%1"=="package" goto :package
if "%1"=="install" goto :install
if "%1"=="clean-install" goto :clean_install
if "%1"=="test" goto :test

goto :usage

:clean
echo [INFO] 执行 clean ...
mvn clean
if %errorlevel% equ 0 (
    echo [INFO] 构建成功: clean
) else (
    echo [ERROR] 构建失败: clean
    exit /b 1
)
exit /b 0

:compile
echo [INFO] 执行 compile ...
mvn compile
if %errorlevel% equ 0 (
    echo [INFO] 构建成功: compile
) else (
    echo [ERROR] 构建失败: compile
    exit /b 1
)
exit /b 0

:package
echo [INFO] 执行 package ...
mvn package -DskipTests
if %errorlevel% equ 0 (
    echo [INFO] 构建产物: fjtcmd-hub-admin\target\fjtcmd-hub-admin.jar
    echo [INFO] 构建成功: package
) else (
    echo [ERROR] 构建失败: package
    exit /b 1
)
exit /b 0

:install
echo [INFO] 执行 install ...
mvn install -DskipTests
if %errorlevel% equ 0 (
    echo [INFO] 构建成功: install
) else (
    echo [ERROR] 构建失败: install
    exit /b 1
)
exit /b 0

:clean_install
echo [INFO] 执行 clean install ...
mvn clean install -DskipTests
if %errorlevel% equ 0 (
    echo [INFO] 构建成功: clean-install
) else (
    echo [ERROR] 构建失败: clean-install
    exit /b 1
)
exit /b 0

:test
echo [INFO] 执行 test ...
mvn test
if %errorlevel% equ 0 (
    echo [INFO] 构建成功: test
) else (
    echo [ERROR] 构建失败: test
    exit /b 1
)
exit /b 0

:usage
echo 用法: %~nx0 [clean^|compile^|package^|install^|clean-install^|test]
echo.
echo   clean         - 清理 target 目录
echo   compile       - 编译源码
echo   package       - 打包（跳过测试）
echo   install       - 编译并安装到本地仓库（跳过测试）
echo   clean-install - 清理后重新编译安装（跳过测试）
echo   test          - 运行单元测试
exit /b 1
