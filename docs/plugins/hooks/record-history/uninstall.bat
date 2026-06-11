@echo off
chcp 65001 >nul 2>&1

:: Record History Hook 卸载脚本 (Windows)

echo.
echo ==========================================
echo   Record History Hook 卸载
echo ==========================================
echo.

:: 获取脚本所在目录和项目根目录
set SCRIPT_DIR=%~dp0
set PROJECT_ROOT=%SCRIPT_DIR%\..\..\..\..

:: 删除 Hook 脚本
echo [1/2] 删除 Hook 脚本...
set HOOK_FILE=%PROJECT_ROOT%\.claude\hooks\record-history.js
if exist "%HOOK_FILE%" (
    del "%HOOK_FILE%"
    echo [INFO] 已删除: .claude\hooks\record-history.js
) else (
    echo [INFO] 文件不存在，跳过
)

:: 提示手动移除配置
echo.
echo [2/2] 移除配置...
echo [WARN] 请从 .claude\settings.local.json 中手动移除以下内容：
echo.
echo 1. permissions.allow 中的:
echo    "Bash(node .claude/hooks/record-history.js)"
echo.
echo 2. hooks.Stop 数组中包含 record-history.js 的条目
echo.

:: 询问是否删除历史记录
set /p DELETE_HISTORY="是否删除历史记录文件？(y/N): "
if /i "%DELETE_HISTORY%" == "y" (
    if exist "%PROJECT_ROOT%\docs\history" (
        rmdir /s /q "%PROJECT_ROOT%\docs\history"
        echo [INFO] 已删除: docs\history\
    )
) else (
    echo [INFO] 保留历史记录文件
)

echo.
echo ==========================================
echo [INFO] ✅ 卸载完成！
echo ==========================================
echo.

exit /b 0
