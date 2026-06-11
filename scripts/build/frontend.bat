@echo off
chcp 65001 >nul 2>&1
setlocal

:: fjtcmd-hub 前端编译构建脚本 (Windows 版本，使用 pnpm)
:: 用法：scripts\build\frontend.bat [install|build:prod|build:stage|clean|clean-install]

set PROJECT_HOME=%~dp0..\..
set UI_DIR=%PROJECT_HOME%\fjtcmd-hub-ui
cd /d "%UI_DIR%"

:: 处理命令
if "%1"=="install" goto :install
if "%1"=="build:prod" goto :build_prod
if "%1"=="build:stage" goto :build_stage
if "%1"=="clean" goto :clean
if "%1"=="clean-install" goto :clean_install

goto :usage

:install
call :check_pnpm
echo [INFO] 安装前端依赖...
pnpm install
if %errorlevel% equ 0 (
    echo [INFO] 操作成功: install
) else (
    echo [ERROR] 操作失败: install
    exit /b 1
)
exit /b 0

:build_prod
call :check_pnpm
echo [INFO] 执行生产环境打包...
pnpm run build:prod
if %errorlevel% equ 0 (
    echo [INFO] 构建产物: fjtcmd-hub-ui\dist\
    echo [INFO] 操作成功: build:prod
) else (
    echo [ERROR] 操作失败: build:prod
    exit /b 1
)
exit /b 0

:build_stage
call :check_pnpm
echo [INFO] 执行预发布环境打包...
pnpm run build:stage
if %errorlevel% equ 0 (
    echo [INFO] 构建产物: fjtcmd-hub-ui\dist\
    echo [INFO] 操作成功: build:stage
) else (
    echo [ERROR] 操作失败: build:stage
    exit /b 1
)
exit /b 0

:clean
echo [INFO] 清理 node_modules 和 dist...
if exist "%UI_DIR%\node_modules" rmdir /s /q "%UI_DIR%\node_modules"
if exist "%UI_DIR%\dist" rmdir /s /q "%UI_DIR%\dist"
echo [INFO] 操作成功: clean
exit /b 0

:clean_install
call :check_pnpm
echo [INFO] 清理并重新安装依赖...
if exist "%UI_DIR%\node_modules" rmdir /s /q "%UI_DIR%\node_modules"
if exist "%UI_DIR%\dist" rmdir /s /q "%UI_DIR%\dist"
pnpm install
if %errorlevel% equ 0 (
    echo [INFO] 操作成功: clean-install
) else (
    echo [ERROR] 操作失败: clean-install
    exit /b 1
)
exit /b 0

:check_pnpm
where pnpm >nul 2>&1
if %errorlevel% neq 0 (
    echo [WARN] pnpm 未安装，正在全局安装...
    npm install -g pnpm
    if %errorlevel% neq 0 (
        echo [ERROR] pnpm 安装失败，请手动执行: npm install -g pnpm
        exit /b 1
    )
)
for /f "tokens=*" %%v in ('pnpm --version') do set PNPM_VERSION=%%v
echo [INFO] pnpm 版本: %PNPM_VERSION%
exit /b 0

:usage
echo 用法: %~nx0 [install^|build:prod^|build:stage^|clean^|clean-install]
echo.
echo   install       - 安装前端依赖（pnpm）
echo   build:prod    - 生产环境打包
echo   build:stage   - 预发布环境打包
echo   clean         - 清理 node_modules 和 dist
echo   clean-install - 清理后重新安装依赖
exit /b 1
