@echo off
chcp 65001 >nul 2>&1
setlocal EnableDelayedExpansion

:: Record History Hook 安装脚本 (Windows)

echo.
echo ==========================================
echo   Record History Hook 安装
echo ==========================================
echo.

:: 获取脚本所在目录和项目根目录
set SCRIPT_DIR=%~dp0
set PROJECT_ROOT=%SCRIPT_DIR%\..\..\..\..

:: 获取用户名
call :get_username

if "!USERNAME!" == "" (
    echo [WARN] 无法自动获取用户名
    set /p USERNAME="请输入你的用户名（用于历史记录目录）: "
    if "!USERNAME!" == "" (
        echo [ERROR] 用户名不能为空
        exit /b 1
    )
)

echo [INFO] 用户名: !USERNAME!

:: 复制 Hook 脚本
echo.
echo [1/3] 安装 Hook 脚本...

set HOOKS_DIR=%PROJECT_ROOT%\.claude\hooks
if not exist "%HOOKS_DIR%" mkdir "%HOOKS_DIR%"

copy "%SCRIPT_DIR%assets\record-history.js" "%HOOKS_DIR%\" >nul
echo [INFO] 已安装: .claude\hooks\record-history.js

:: 配置 settings.local.json
echo.
echo [2/3] 配置 settings.local.json...

set SETTINGS_FILE=%PROJECT_ROOT%\.claude\settings.local.json
set HOOK_COMMAND=node .claude/hooks/record-history.js

if exist "%SETTINGS_FILE%" (
    findstr "record-history.js" "%SETTINGS_FILE%" >nul
    if !errorlevel! equ 0 (
        echo [INFO] 配置已存在，跳过
    ) else (
        echo [WARN] settings.local.json 已存在但未配置此 Hook
        echo.
        echo 请手动添加以下权限和 Hook 配置：
        echo.
        echo permissions.allow 中添加:
        echo   "Bash^(!HOOK_COMMAND!^)"
        echo.
        echo hooks.Stop 中添加:
        echo   {"matcher":"*","hooks":[{"type":"command","command":"!HOOK_COMMAND!"}]}
    )
) else (
    (
        echo {
        echo   "permissions": {
        echo     "allow": [
        echo       "Bash^(!HOOK_COMMAND!^)"
        echo     ]
        echo   },
        echo   "hooks": {
        echo     "Stop": [
        echo       {
        echo         "matcher": "*",
        echo         "hooks": [
        echo           {
        echo             "type": "command",
        echo             "command": "!HOOK_COMMAND!"
        echo           }
        echo         ]
        echo       }
        echo     ]
        echo   }
        echo }
    ) > "%SETTINGS_FILE%"
    echo [INFO] 已创建: .claude\settings.local.json
)

:: 创建历史目录
echo.
echo [3/3] 创建历史目录...

set HISTORY_DIR=%PROJECT_ROOT%\docs\history\!USERNAME!
if not exist "%HISTORY_DIR%" mkdir "%HISTORY_DIR%"
echo [INFO] 已创建: docs\history\!USERNAME!\

:: 完成
echo.
echo ==========================================
echo [INFO] ✅ 安装完成！
echo ==========================================
echo.
echo 历史文件将保存到: docs\history\!USERNAME!\
echo.

exit /b 0

:get_username
set USERNAME=

:: 1. 尝试 git config
for /f "tokens=*" %%i in ('git config user.name 2^>nul') do (
    set USERNAME=%%i
    goto :username_done
)

:: 2. 尝试环境变量
if defined USER (
    set USERNAME=%USER%
    goto :username_done
)
if defined USERNAME_VAR (
    set USERNAME=%USERNAME_VAR%
    goto :username_done
)

:username_done
exit /b 0
