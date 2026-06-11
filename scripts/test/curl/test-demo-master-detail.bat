@echo off
chcp 65001 >nul 2>&1
setlocal EnableDelayedExpansion

:: ==========================================
:: fjtcmd-hub Demo 模块测试 - 主子表（客户-商品）(Windows 版本)
:: 主表：/demo/customer，主键：customerId
:: 子表：/demo/goods，主键：goodsId，外键：customerId
:: 说明：主子表独立页面模式，CRUD 分别测试
:: ==========================================

set BASE_URL=http://localhost:18081
set USERNAME=admin
set PASSWORD=admin123
set TOKEN=

echo.
echo ==========================================
echo   Demo 主子表测试 - 客户商品 (Windows)
echo ==========================================
echo.

:: 登录
call :login
if errorlevel 1 exit /b 1

:: 测试客户模块（主表）
call :test_customer_module

:: 测试商品模块（子表）
call :test_goods_module

echo ==========================================
echo [INFO] 主子表测试完成！
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

:test_customer_module
echo [MODULE] ==========================================
echo [MODULE] 客户管理模块测试（主表）
echo [MODULE] ==========================================

:: 1. 查询客户列表
echo [STEP] 1. 查询客户列表...
for /f "delims=" %%i in ('powershell -Command "$r = curl -s -X GET '%BASE_URL%/demo/customer/list' -H 'Authorization: %TOKEN%' | ConvertFrom-Json; Write-Output \"$($r.code)|$($r.total)\""') do (
    set LIST_RESULT=%%i
)

for /f "tokens=1,2 delims=|" %%a in ("!LIST_RESULT!") do (
    set LIST_CODE=%%a
    set TOTAL=%%b
)

if "!LIST_CODE!" neq "200" (
    echo [ERROR] 查询客户列表失败
    exit /b 1
)
echo [INFO] 客户总数：!TOTAL!

:: 2. 新增客户
echo [STEP] 2. 新增客户...
for /f "delims=" %%i in ('powershell -Command "$r = curl -s -X POST '%BASE_URL%/demo/customer' -H 'Authorization: %TOKEN%' -H 'Content-Type: application/json' -d '{\"customerName\":\"测试客户_curl\",\"phonenumber\":\"13800138000\",\"sex\":\"0\",\"birthday\":\"1990-01-01\",\"remark\":\"curl测试\"}' | ConvertFrom-Json; Write-Output \"$($r.code)|$($r.msg)\""') do (
    set ADD_RESULT=%%i
)

for /f "tokens=1,2 delims=|" %%a in ("!ADD_RESULT!") do (
    set ADD_CODE=%%a
    set ADD_MSG=%%b
)

if "!ADD_CODE!" == "200" (
    echo [INFO] 新增客户成功：!ADD_MSG!
) else (
    echo [WARN] 新增客户响应：!ADD_MSG!
)

:: 3. 查询列表获取新增客户的 ID
echo [STEP] 3. 查询列表获取客户 ID...
for /f "delims=" %%i in ('powershell -Command "$r = curl -s -X GET '%BASE_URL%/demo/customer/list?pageNum=1^&pageSize=10' -H 'Authorization: %TOKEN%' | ConvertFrom-Json; if ($r.rows.Count -gt 0) { Write-Output $r.rows[0].customerId } else { Write-Output '' }"') do (
    set CUSTOMER_ID=%%i
)

if "!CUSTOMER_ID!" == "" (
    echo [WARN] 暂无客户数据，跳过后续测试
    exit /b 0
)
echo [INFO] 获取到客户 ID: !CUSTOMER_ID!

:: 4. 查询客户详情
echo [STEP] 4. 查询客户详情 ^(ID: !CUSTOMER_ID!^)...
for /f "delims=" %%i in ('powershell -Command "$r = curl -s -X GET '%BASE_URL%/demo/customer/!CUSTOMER_ID!' -H 'Authorization: %TOKEN%' | ConvertFrom-Json; Write-Output \"$($r.code)|$($r.data.customerName)\""') do (
    set DETAIL_RESULT=%%i
)

for /f "tokens=1,2 delims=|" %%a in ("!DETAIL_RESULT!") do (
    set DETAIL_CODE=%%a
    set CUSTOMER_NAME=%%b
)

if "!DETAIL_CODE!" == "200" (
    echo [INFO] 客户名称：!CUSTOMER_NAME!
) else (
    echo [WARN] 详情查询失败
)

:: 5. 删除客户
echo [STEP] 5. 删除客户 ^(ID: !CUSTOMER_ID!^)...
for /f "delims=" %%i in ('powershell -Command "$r = curl -s -X DELETE '%BASE_URL%/demo/customer/!CUSTOMER_ID!' -H 'Authorization: %TOKEN%' | ConvertFrom-Json; Write-Output $r.code"') do (
    set DELETE_CODE=%%i
)

if "!DELETE_CODE!" == "200" (
    echo [INFO] 删除客户成功
) else (
    echo [WARN] 删除客户失败
)

echo [INFO] 客户管理模块测试完成
echo.
exit /b 0

:test_goods_module
echo [MODULE] ==========================================
echo [MODULE] 商品管理模块测试（子表）
echo [MODULE] ==========================================

:: 1. 查询商品列表
echo [STEP] 1. 查询商品列表...
for /f "delims=" %%i in ('powershell -Command "$r = curl -s -X GET '%BASE_URL%/demo/goods/list' -H 'Authorization: %TOKEN%' | ConvertFrom-Json; Write-Output \"$($r.code)|$($r.total)\""') do (
    set LIST_RESULT=%%i
)

for /f "tokens=1,2 delims=|" %%a in ("!LIST_RESULT!") do (
    set LIST_CODE=%%a
    set TOTAL=%%b
)

if "!LIST_CODE!" neq "200" (
    echo [ERROR] 查询商品列表失败
    exit /b 1
)
echo [INFO] 商品总数：!TOTAL!

:: 2. 先创建一个客户用于关联
echo [STEP] 2. 创建测试客户用于关联...
for /f "delims=" %%i in ('powershell -Command "$r = curl -s -X POST '%BASE_URL%/demo/customer' -H 'Authorization: %TOKEN%' -H 'Content-Type: application/json' -d '{\"customerName\":\"商品测试客户\",\"phonenumber\":\"13700137000\",\"sex\":\"0\",\"birthday\":\"1995-05-05\"}' | ConvertFrom-Json; Write-Output $r.code"') do (
    set CUSTOMER_ADD_CODE=%%i
)

:: 获取客户 ID
for /f "delims=" %%i in ('powershell -Command "$r = curl -s -X GET '%BASE_URL%/demo/customer/list?pageNum=1^&pageSize=10' -H 'Authorization: %TOKEN%' | ConvertFrom-Json; if ($r.rows.Count -gt 0) { Write-Output $r.rows[0].customerId } else { Write-Output '' }"') do (
    set TEST_CUSTOMER_ID=%%i
)

if "!TEST_CUSTOMER_ID!" == "" (
    echo [WARN] 无法创建测试客户，跳过商品测试
    exit /b 0
)
echo [INFO] 测试客户 ID: !TEST_CUSTOMER_ID!

:: 3. 新增商品（关联客户）
echo [STEP] 3. 新增商品...
for /f "delims=" %%i in ('powershell -Command "$r = curl -s -X POST '%BASE_URL%/demo/goods' -H 'Authorization: %TOKEN%' -H 'Content-Type: application/json' -d '{\"goodsName\":\"测试商品_curl\",\"price\":99.99,\"stock\":100,\"goodsType\":\"0\",\"customerId\":!TEST_CUSTOMER_ID!}' | ConvertFrom-Json; Write-Output \"$($r.code)|$($r.msg)\""') do (
    set ADD_RESULT=%%i
)

for /f "tokens=1,2 delims=|" %%a in ("!ADD_RESULT!") do (
    set ADD_CODE=%%a
    set ADD_MSG=%%b
)

if "!ADD_CODE!" == "200" (
    echo [INFO] 新增商品成功：!ADD_MSG!
) else (
    echo [WARN] 新增商品响应：!ADD_MSG!
)

:: 4. 查询商品列表获取 ID
echo [STEP] 4. 查询商品列表获取 ID...
for /f "delims=" %%i in ('powershell -Command "$r = curl -s -X GET '%BASE_URL%/demo/goods/list?pageNum=1^&pageSize=10' -H 'Authorization: %TOKEN%' | ConvertFrom-Json; if ($r.rows.Count -gt 0) { Write-Output $r.rows[0].goodsId } else { Write-Output '' }"') do (
    set GOODS_ID=%%i
)

if "!GOODS_ID!" == "" (
    echo [WARN] 暂无商品数据
    exit /b 0
)
echo [INFO] 获取到商品 ID: !GOODS_ID!

:: 5. 删除商品
echo [STEP] 5. 删除商品 ^(ID: !GOODS_ID!^)...
for /f "delims=" %%i in ('powershell -Command "$r = curl -s -X DELETE '%BASE_URL%/demo/goods/!GOODS_ID!' -H 'Authorization: %TOKEN%' | ConvertFrom-Json; Write-Output $r.code"') do (
    set DELETE_CODE=%%i
)

if "!DELETE_CODE!" == "200" (
    echo [INFO] 删除商品成功
) else (
    echo [WARN] 删除商品失败
)

:: 6. 清理测试客户
echo [STEP] 6. 清理测试客户...
for /f "delims=" %%i in ('powershell -Command "$r = curl -s -X DELETE '%BASE_URL%/demo/customer/!TEST_CUSTOMER_ID!' -H 'Authorization: %TOKEN%' | ConvertFrom-Json; Write-Output $r.code"') do (
    set CLEANUP_CODE=%%i
)

if "!CLEANUP_CODE!" == "200" (
    echo [INFO] 清理测试客户成功
) else (
    echo [WARN] 清理测试客户失败
)

echo [INFO] 商品管理模块测试完成
echo.
exit /b 0
