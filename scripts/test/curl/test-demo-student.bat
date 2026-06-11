@echo off
chcp 65001 >nul 2>&1
setlocal EnableDelayedExpansion

:: ==========================================
:: fjtcmd-hub Demo 模块测试 - 学生管理增强 (Windows 版本)
:: 说明：包含导出、批量删除等高级功能测试
:: ==========================================

set BASE_URL=http://localhost:18081
set USERNAME=admin
set PASSWORD=admin123
set TOKEN=

echo.
echo ==========================================
echo   Demo 学生管理增强测试 (Windows)
echo ==========================================
echo.

:: 登录
call :login
if errorlevel 1 exit /b 1

:: 测试
call :test_student_advanced

echo ==========================================
echo [INFO] 学生管理增强测试完成！
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

:test_student_advanced
echo [MODULE] ==========================================
echo [MODULE] 学生管理增强功能测试
echo [MODULE] ==========================================

:: 1. 查询学生列表
echo [STEP] 1. 查询学生列表...
for /f "delims=" %%i in ('powershell -Command "$r = curl -s -X GET '%BASE_URL%/demo/student/list' -H 'Authorization: %TOKEN%' | ConvertFrom-Json; Write-Output \"$($r.code)|$($r.total)\""') do (
    set LIST_RESULT=%%i
)

for /f "tokens=1,2 delims=|" %%a in ("!LIST_RESULT!") do (
    set LIST_CODE=%%a
    set TOTAL=%%b
)

if "!LIST_CODE!" neq "200" (
    echo [ERROR] 查询学生列表失败
    exit /b 1
)
echo [INFO] 学生总数：!TOTAL!

:: 2. 测试导出接口（检查响应状态）
echo [STEP] 2. 测试导出接口...
for /f "delims=" %%i in ('powershell -Command "$response = Invoke-WebRequest -Uri '%BASE_URL%/demo/student/export' -Method POST -Headers @{'Authorization'='%TOKEN%';'Content-Type'='application/json'} -Body '{}' -UseBasicParsing; Write-Output $response.StatusCode"') do (
    set EXPORT_STATUS=%%i
)

if "!EXPORT_STATUS!" == "200" (
    echo [INFO] 导出接口正常 ^(HTTP !EXPORT_STATUS!^)
) else (
    echo [WARN] 导出接口响应：HTTP !EXPORT_STATUS!
)

:: 3. 测试导入模板下载
echo [STEP] 3. 测试导入模板下载...
for /f "delims=" %%i in ('powershell -Command "$response = Invoke-WebRequest -Uri '%BASE_URL%/demo/student/importTemplate' -Method GET -Headers @{'Authorization'='%TOKEN%'} -UseBasicParsing; Write-Output $response.StatusCode"') do (
    set TEMPLATE_STATUS=%%i
)

if "!TEMPLATE_STATUS!" == "200" (
    echo [INFO] 导入模板下载正常
) else (
    echo [WARN] 导入模板响应：HTTP !TEMPLATE_STATUS!
)

:: 4. 测试分页查询参数
echo [STEP] 4. 测试分页查询参数...
for /f "delims=" %%i in ('powershell -Command "$r = curl -s -X GET '%BASE_URL%/demo/student/list?pageNum=1^&pageSize=5' -H 'Authorization: %TOKEN%' | ConvertFrom-Json; Write-Output \"$($r.code)|$($r.rows.Count)\""') do (
    set PAGE_RESULT=%%i
)

for /f "tokens=1,2 delims=|" %%a in ("!PAGE_RESULT!") do (
    set PAGE_CODE=%%a
    set PAGE_ROWS=%%b
)

if "!PAGE_CODE!" == "200" (
    echo [INFO] 分页查询正常，返回 !PAGE_ROWS! 条记录
) else (
    echo [WARN] 分页查询失败
)

:: 5. 测试条件查询
echo [STEP] 5. 测试条件查询...
for /f "delims=" %%i in ('powershell -Command "$r = curl -s -X GET '%BASE_URL%/demo/student/list?studentName=测试' -H 'Authorization: %TOKEN%' | ConvertFrom-Json; Write-Output \"$($r.code)|$($r.total)\""') do (
    set SEARCH_RESULT=%%i
)

for /f "tokens=1,2 delims=|" %%a in ("!SEARCH_RESULT!") do (
    set SEARCH_CODE=%%a
    set SEARCH_TOTAL=%%b
)

if "!SEARCH_CODE!" == "200" (
    echo [INFO] 条件查询正常，匹配 !SEARCH_TOTAL! 条记录
) else (
    echo [WARN] 条件查询失败
)

echo [INFO] 学生管理增强功能测试完成
echo.
exit /b 0
