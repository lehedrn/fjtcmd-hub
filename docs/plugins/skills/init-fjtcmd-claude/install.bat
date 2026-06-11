@echo off
chcp 65001 >nul 2>&1
setlocal EnableDelayedExpansion

:: init-fjtcmd-claude Skill 安装脚本 (Windows)

echo.
echo ==========================================
echo   init-fjtcmd-claude Skill 安装
echo ==========================================
echo.

:: 获取脚本所在目录和项目根目录
set SCRIPT_DIR=%~dp0
for %%i in ("%SCRIPT_DIR%\..\..\..\..") do set PROJECT_ROOT=%%~fi

set TARGET_DIR=%PROJECT_ROOT%\.claude\skills\init-fjtcmd-claude

:: 检查是否已存在
if exist "%TARGET_DIR%" (
    echo [WARN] Skill 目录已存在: %TARGET_DIR%
    set /p OVERWRITE="是否覆盖？(y/N): "
    if /i not "!OVERWRITE!" == "y" (
        echo [INFO] 取消安装
        exit /b 0
    )
    rmdir /s /q "%TARGET_DIR%"
)

:: 复制 Skill 文件
echo [1/1] 复制 Skill 文件...

if not exist "%TARGET_DIR%\assets" mkdir "%TARGET_DIR%\assets"

copy "%SCRIPT_DIR%SKILL.md" "%TARGET_DIR%\" >nul
copy "%SCRIPT_DIR%README.md" "%TARGET_DIR%\" >nul
copy "%SCRIPT_DIR%assets\CLAUDE-TEMPLATE.md" "%TARGET_DIR%\assets\" >nul

echo [INFO] 已安装: .claude\skills\init-fjtcmd-claude\

echo.
echo ==========================================
echo [INFO] ✅ 安装完成！
echo ==========================================
echo.
echo 使用方式：
echo   /fjtcmd-hub-init-claude
echo.

exit /b 0
