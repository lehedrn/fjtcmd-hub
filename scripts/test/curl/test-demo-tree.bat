@echo off
chcp 65001 >nul 2>&1
setlocal EnableDelayedExpansion

:: ==========================================
:: fjtcmd-hub Demo 模块测试 - 树表（产品管理）(Windows 版本)
:: 路径前缀：/demo/product
:: 主键：productId
:: 说明：树形结构，list 返回 {code, data:[...]}，不分页
:: ==========================================

set BASE_URL=http://localhost:18081
set USERNAME=admin
set PASSWORD=admin123
set TOKEN=

echo.
echo ==========================================
echo   Demo 树表测试 - 产品管理 (Windows)
echo ==========================================
echo.

:: 登录
call :login
if errorlevel 1 exit /b 1

:: 测试产品模块
call :test_product_module

echo ==========================================
echo [INFO] 树表测试完成！
echo ==========================================
echo.
exit /b 0

:login
echo [STEP] 用户登录...

for /f "delims=" %%i in ('powershell -Command "$r = curl -s -X POST '%BASE_URL%/login' -H 'Content-Type: application/json' -d '{\"username\":\"%USERNAME%\",\"password\":\"%PASSWORD%\",\"code\":\"\",\"uuid\":\"\"}' | ConvertFrom-Json; Write-Output \"$($r.code)|$($r.token)\""') do (
    set LOGIN_RESULT=%%i
)

for /f "tokens=1,2 delims=|" %%a in ("!LOGIN_RESULT!") do (
    set LOGIN_CODE=%%a
    set TOKEN=%%b
)

if "!LOGIN_CODE!" neq "200" (
    echo [ERROR] 登录失败
    exit /b 1
)

echo [INFO] 登录成功
exit /b 0

:test_product_module
echo [MODULE] ==========================================
echo [MODULE] 产品管理模块测试（树表）
echo [MODULE] ==========================================

:: 1. 查询产品列表
echo [STEP] 1. 查询产品列表...
for /f "delims=" %%i in ('powershell -Command "$r = curl -s -X GET '%BASE_URL%/demo/product/list' -H 'Authorization: %TOKEN%' | ConvertFrom-Json; Write-Output \"$($r.code)|$($r.data.Count)\""') do (
    set LIST_RESULT=%%i
)

for /f "tokens=1,2 delims=|" %%a in ("!LIST_RESULT!") do (
    set LIST_CODE=%%a
    set PRODUCT_COUNT=%%b
)

if "!LIST_CODE!" neq "200" (
    echo [ERROR] 查询产品列表失败
    exit /b 1
)
echo [INFO] 产品总数：!PRODUCT_COUNT!

:: 2. 新增产品（parentId=0 表示顶级节点）
echo [STEP] 2. 新增产品...
for /f "delims=" %%i in ('powershell -Command "$r = curl -s -X POST '%BASE_URL%/demo/product' -H 'Authorization: %TOKEN%' -H 'Content-Type: application/json' -d '{\"productName\":\"测试产品_curl\",\"parentId\":0,\"orderNum\":99,\"status\":\"0\"}' | ConvertFrom-Json; Write-Output \"$($r.code)|$($r.msg)\""') do (
    set ADD_RESULT=%%i
)

for /f "tokens=1,2 delims=|" %%a in ("!ADD_RESULT!") do (
    set ADD_CODE=%%a
    set ADD_MSG=%%b
)

if "!ADD_CODE!" == "200" (
    echo [INFO] 新增产品成功：!ADD_MSG!
) else (
    echo [WARN] 新增产品响应：!ADD_MSG!
)

:: 3. 查询列表获取新增产品的 ID
echo [STEP] 3. 查询列表获取产品 ID...
for /f "delims=" %%i in ('powershell -Command "$r = curl -s -X GET '%BASE_URL%/demo/product/list' -H 'Authorization: %TOKEN%' | ConvertFrom-Json; if ($r.data.Count -gt 0) { Write-Output $r.data[0].productId } else { Write-Output '' }"') do (
    set FIRST_ID=%%i
)

if "!FIRST_ID!" == "" (
    echo [WARN] 暂无产品数据，跳过详情/修改/删除测试
    exit /b 0
)
echo [INFO] 获取到产品 ID: !FIRST_ID!

:: 4. 查询产品详情
echo [STEP] 4. 查询产品详情 ^(ID: !FIRST_ID!^)...
for /f "delims=" %%i in ('powershell -Command "$r = curl -s -X GET '%BASE_URL%/demo/product/!FIRST_ID!' -H 'Authorization: %TOKEN%' | ConvertFrom-Json; Write-Output \"$($r.code)|$($r.data.productName)\""') do (
    set DETAIL_RESULT=%%i
)

for /f "tokens=1,2 delims=|" %%a in ("!DETAIL_RESULT!") do (
    set DETAIL_CODE=%%a
    set PRODUCT_NAME=%%b
)

if "!DETAIL_CODE!" == "200" (
    echo [INFO] 产品名称：!PRODUCT_NAME!
) else (
    echo [WARN] 详情查询失败
)

:: 5. 修改产品
echo [STEP] 5. 修改产品 ^(ID: !FIRST_ID!^)...
for /f "delims=" %%i in ('powershell -Command "$r = curl -s -X PUT '%BASE_URL%/demo/product' -H 'Authorization: %TOKEN%' -H 'Content-Type: application/json' -d '{\"productId\":!FIRST_ID!,\"productName\":\"测试产品_curl_已修改\",\"parentId\":0,\"orderNum\":100,\"status\":\"0\"}' | ConvertFrom-Json; Write-Output $r.code"') do (
    set UPDATE_CODE=%%i
)

if "!UPDATE_CODE!" == "200" (
    echo [INFO] 修改产品成功
) else (
    echo [WARN] 修改产品失败
)

:: 6. 删除产品
echo [STEP] 6. 删除产品 ^(ID: !FIRST_ID!^)...
for /f "delims=" %%i in ('powershell -Command "$r = curl -s -X DELETE '%BASE_URL%/demo/product/!FIRST_ID!' -H 'Authorization: %TOKEN%' | ConvertFrom-Json; Write-Output $r.code"') do (
    set DELETE_CODE=%%i
)

if "!DELETE_CODE!" == "200" (
    echo [INFO] 删除产品成功
) else (
    echo [WARN] 删除产品失败
)

echo [INFO] 产品管理模块（树表）测试完成
echo.
exit /b 0
