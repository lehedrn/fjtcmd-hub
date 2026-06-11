@echo off
chcp 65001 >nul 2>&1
setlocal EnableDelayedExpansion

:: ==========================================
:: fjtcmd-hub 登录认证完整测试脚本 (Windows 版本)
:: 功能：登录 → 用户信息 → 路由 → 退出登录
:: 说明：测试阶段验证码已关闭，直接登录
:: ==========================================

:: 配置
set BASE_URL=http://localhost:18081
set TOKEN_FILE=%TEMP%\fjtcmd_hub_token.txt
set USERNAME=admin
set PASSWORD=admin123

echo.
echo ==========================================
echo   fjtcmd-hub 登录认证测试脚本 (Windows)
echo ==========================================
echo.

:: 步骤 1: 登录
echo [STEP] 步骤 1: 用户登录...

:: 使用 PowerShell 执行 curl 并解析 JSON
for /f "delims=" %%i in ('powershell -Command "$response = curl -s -X POST '%BASE_URL%/login' -H 'Content-Type: application/json' -d '{\"username\":\"%USERNAME%\",\"password\":\"%PASSWORD%\",\"code\":\"\",\"uuid\":\"\"}' | ConvertFrom-Json; Write-Output \"$($response.code)|$($response.msg)|$($response.token)\""') do (
    set LOGIN_RESULT=%%i
)

for /f "tokens=1,2,3 delims=|" %%a in ("!LOGIN_RESULT!") do (
    set LOGIN_CODE=%%a
    set LOGIN_MSG=%%b
    set TOKEN=%%c
)

echo [INFO] 登录响应：code=!LOGIN_CODE!, msg=!LOGIN_MSG!

if "!LOGIN_CODE!" neq "200" (
    echo [ERROR] 登录失败：!LOGIN_MSG!
    exit /b 1
)

:: 保存 Token
echo !TOKEN!> "%TOKEN_FILE%"
set TOKEN_SHORT=!TOKEN:~0,50!
echo [INFO] 登录成功！Token: !TOKEN_SHORT!...

:: 步骤 2: 获取用户信息
echo.
echo [STEP] 步骤 2: 获取用户信息...

for /f "delims=" %%i in ('powershell -Command "$response = curl -s -X GET '%BASE_URL%/getInfo' -H 'Authorization: !TOKEN!' | ConvertFrom-Json; Write-Output \"$($response.code)|$($response.user.userName)|$($response.user.nickName)|$($response.user.dept.deptName)|$($response.roles -join ',')|$($response.permissions.Count)\""') do (
    set USER_RESULT=%%i
)

for /f "tokens=1,2,3,4,5,6 delims=|" %%a in ("!USER_RESULT!") do (
    set USER_CODE=%%a
    set USER_NAME=%%b
    set NICK_NAME=%%c
    set DEPT_NAME=%%d
    set ROLES=%%e
    set PERM_COUNT=%%f
)

if "!USER_CODE!" neq "200" (
    echo [ERROR] 获取用户信息失败
    exit /b 1
)

echo [INFO] 用户：!USER_NAME! ^(!NICK_NAME!^) - 部门：!DEPT_NAME!
echo [INFO] 角色：!ROLES!
echo [INFO] 权限数量：!PERM_COUNT! 个

:: 步骤 3: 获取路由信息
echo.
echo [STEP] 步骤 3: 获取菜单路由...

for /f "delims=" %%i in ('powershell -Command "$response = curl -s -X GET '%BASE_URL%/getRouters' -H 'Authorization: !TOKEN!' | ConvertFrom-Json; Write-Output \"$($response.code)|$($response.data.Count)\""') do (
    set ROUTER_RESULT=%%i
)

for /f "tokens=1,2 delims=|" %%a in ("!ROUTER_RESULT!") do (
    set ROUTER_CODE=%%a
    set MENU_COUNT=%%b
)

if "!ROUTER_CODE!" neq "200" (
    echo [ERROR] 获取路由失败
    exit /b 1
)

echo [INFO] 可访问菜单数：!MENU_COUNT!

:: 显示主要菜单
echo.
echo [INFO] 主要菜单列表:
powershell -Command "$response = curl -s -X GET '%BASE_URL%/getRouters' -H 'Authorization: !TOKEN!' | ConvertFrom-Json; $response.data | ForEach-Object { Write-Output \"  - $($_.name): $($_.path) ($($_.meta.title))\" }"

:: 步骤 4: 退出登录
echo.
echo [STEP] 步骤 4: 退出登录...

for /f "delims=" %%i in ('powershell -Command "$response = curl -s -X POST '%BASE_URL%/logout' -H 'Authorization: !TOKEN!' | ConvertFrom-Json; Write-Output \"$($response.code)|$($response.msg)\""') do (
    set LOGOUT_RESULT=%%i
)

for /f "tokens=1,2 delims=|" %%a in ("!LOGOUT_RESULT!") do (
    set LOGOUT_CODE=%%a
    set LOGOUT_MSG=%%b
)

if "!LOGOUT_CODE!" neq "200" (
    echo [WARN] 退出登录响应异常：!LOGOUT_MSG!
) else (
    echo [INFO] 退出登录：!LOGOUT_MSG!
)

:: 删除本地 Token
if exist "%TOKEN_FILE%" del /f "%TOKEN_FILE%"
echo [INFO] 本地 Token 已清除

:: 验证 Token 已失效
echo.
echo [STEP] 验证 Token 已失效...

for /f "delims=" %%i in ('powershell -Command "$response = curl -s -X GET '%BASE_URL%/getInfo' -H 'Authorization: !TOKEN!' | ConvertFrom-Json; Write-Output $response.code"') do (
    set VERIFY_CODE=%%i
)

if "!VERIFY_CODE!" == "200" (
    echo [WARN] Token 仍未失效（可能是延迟）
) else (
    echo [INFO] Token 已失效，验证通过
)

echo.
echo ==========================================
echo [INFO] 登录认证流程测试完成！
echo ==========================================
echo.

exit /b 0
