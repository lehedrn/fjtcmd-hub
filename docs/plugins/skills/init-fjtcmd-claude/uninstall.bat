@echo off
chcp 65001 >nul 2>&1

:: init-fjtcmd-claude Skill 卸载脚本 (Windows)

echo.
echo ==========================================
echo   init-fjtcmd-claude Skill 卸载
echo ==========================================
echo.

set SCRIPT_DIR=%~dp0
for %%i in ("%SCRIPT_DIR%\..\..\..\..") do set PROJECT_ROOT=%%~fi

set TARGET_DIR=%PROJECT_ROOT%\.claude\skills\init-fjtcmd-claude

if exist "%TARGET_DIR%" (
    rmdir /s /q "%TARGET_DIR%"
    echo [INFO] 已删除: .claude\skills\init-fjtcmd-claude\
) else (
    echo [INFO] 目录不存在，跳过
)

echo.
echo [INFO] ✅ 卸载完成！
echo.

exit /b 0
