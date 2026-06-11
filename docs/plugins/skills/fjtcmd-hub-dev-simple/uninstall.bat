@echo off
chcp 65001 >nul 2>&1

:: fjtcmd-hub-dev-simple Skill 卸载脚本 (Windows)

echo.
echo ==========================================
echo   fjtcmd-hub-dev-simple Skill 卸载
echo ==========================================
echo.

:: 获取项目根目录
set SCRIPT_DIR=%~dp0
for %%i in ("%SCRIPT_DIR%\..\..\..") do set PROJECT_ROOT=%%~fi

set TARGET_DIR=%PROJECT_ROOT%\.claude\skills\fjtcmd-hub-dev-simple

:: 删除 Skill 目录
echo [1/2] 删除 Skill 文件...

if exist "%TARGET_DIR%" (
    rmdir /s /q "%TARGET_DIR%"
    echo [INFO] 已删除: .claude\skills\fjtcmd-hub-dev-simple\
) else (
    echo [INFO] 目录不存在，跳过
)

:: 询问是否删除生成的配置
echo.
echo [2/2] 清理配置文件...

set CONFIG_FILE=%TARGET_DIR%\config.json
set GENERATE_DIR=%PROJECT_ROOT%\generate

if exist "%CONFIG_FILE%" (
    set /p DELETE_CONFIG="是否删除 config.json？(y/N): "
    if /i "!DELETE_CONFIG!" == "y" (
        del "%CONFIG_FILE%"
        echo [INFO] 已删除: config.json
    )
)

if exist "%GENERATE_DIR%" (
    set /p DELETE_GENERATE="是否删除 generate\ 目录？(y/N): "
    if /i "!DELETE_GENERATE!" == "y" (
        rmdir /s /q "%GENERATE_DIR%"
        echo [INFO] 已删除: generate\
    )
)

:: 完成
echo.
echo ==========================================
echo [INFO] ✅ 卸载完成！
echo ==========================================
echo.

exit /b 0
