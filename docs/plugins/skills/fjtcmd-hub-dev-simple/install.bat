@echo off
chcp 65001 >nul 2>&1
setlocal EnableDelayedExpansion

:: fjtcmd-hub-dev-simple Skill 安装脚本 (Windows)

echo.
echo ==========================================
echo   fjtcmd-hub-dev-simple Skill 安装
echo ==========================================
echo.

:: 获取脚本所在目录和项目根目录
set SCRIPT_DIR=%~dp0
for %%i in ("%SCRIPT_DIR%\..\..\..") do set PROJECT_ROOT=%%~fi

:: 1. 复制 Skill 目录
echo [1/2] 复制 Skill 文件...

set TARGET_DIR=%PROJECT_ROOT%\.claude\skills\fjtcmd-hub-dev-simple

if exist "%TARGET_DIR%" (
    echo [WARN] Skill 目录已存在: %TARGET_DIR%
    set /p OVERWRITE="是否覆盖？(y/N): "
    if /i not "!OVERWRITE!" == "y" (
        echo [INFO] 取消安装
        exit /b 0
    )
    rmdir /s /q "%TARGET_DIR%"
)

:: 复制文件
xcopy "%SCRIPT_DIR%fjtcmd-hub-dev-simple\*" "%TARGET_DIR%\" /s /e /i /y /q >nul

:: 排除 __pycache__ 和 config.json
if exist "%TARGET_DIR%\config.json" del "%TARGET_DIR%\config.json"
for /d /r "%TARGET_DIR%" %%d in (__pycache__) do (
    if exist "%%d" rmdir /s /q "%%d"
)

echo [INFO] 已复制: .claude\skills\fjtcmd-hub-dev-simple\

:: 2. 初始化配置
echo.
echo [2/2] 初始化环境配置...

set VERIFY_SCRIPT=%TARGET_DIR%\scripts\verify_env.py
if exist "%VERIFY_SCRIPT%" (
    python "%VERIFY_SCRIPT%" --init
) else (
    echo [WARN] 未找到 verify_env.py，跳过配置初始化
    echo 请手动运行: python .claude\skills\fjtcmd-hub-dev-simple\scripts\verify_env.py --init
)

:: 完成
echo.
echo ==========================================
echo [INFO] ✅ 安装完成！
echo ==========================================
echo.
echo 使用方式：
echo   /fjtcmd-hub-dev-simple 我要做一个学生管理功能
echo.

exit /b 0
