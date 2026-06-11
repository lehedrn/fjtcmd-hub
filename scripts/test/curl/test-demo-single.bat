@echo off
chcp 65001 >nul 2>&1
setlocal EnableDelayedExpansion

:: ==========================================
:: fjtcmd-hub Demo 模块测试 - 单表（学生管理）(Windows 版本)
:: 路径前缀：/demo/student
:: 主键：studentId
:: 说明：标准单表 CRUD + 导出
:: ==========================================

:: 配置
set BASE_URL=http://localhost:18081
set USERNAME=admin
set PASSWORD=admin123
set TOKEN=

echo.
echo ==========================================
echo   Demo 单表测试 - 学生管理 (Windows)
echo ==========================================
echo.

:: 登录
call :login
if errorlevel 1 exit /b 1

:: 测试学生模块
call :test_student_module

echo ==========================================
echo [INFO] 单表测试完成！
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

:test_student_module
echo [MODULE] ==========================================
echo [MODULE] 学生管理模块测试（单表）
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

:: 2. 新增学生
echo [STEP] 2. 新增学生...
for /f "delims=" %%i in ('powershell -Command "$r = curl -s -X POST '%BASE_URL%/demo/student' -H 'Authorization: %TOKEN%' -H 'Content-Type: application/json' -d '{\"studentName\":\"测试学生_curl\",\"studentAge\":20,\"studentSex\":\"0\",\"studentStatus\":\"0\",\"studentBirthday\":\"2006-01-15\",\"studentHobby\":\"0\"}' | ConvertFrom-Json; Write-Output \"$($r.code)|$($r.msg)\""') do (
    set ADD_RESULT=%%i
)

for /f "tokens=1,2 delims=|" %%a in ("!ADD_RESULT!") do (
    set ADD_CODE=%%a
    set ADD_MSG=%%b
)

if "!ADD_CODE!" neq "200" (
    echo [WARN] 新增学生响应：!ADD_MSG!
) else (
    echo [INFO] 新增学生成功：!ADD_MSG!
)

:: 3. 查询列表获取刚新增的学生 ID
echo [STEP] 3. 查询列表获取学生 ID...
for /f "delims=" %%i in ('powershell -Command "$r = curl -s -X GET '%BASE_URL%/demo/student/list?pageNum=1^&pageSize=10' -H 'Authorization: %TOKEN%' | ConvertFrom-Json; Write-Output $r.rows[0].studentId"') do (
    set FIRST_ID=%%i
)

if "!FIRST_ID!" == "" (
    echo [WARN] 暂无学生数据，跳过详情/修改/删除测试
    exit /b 0
)
echo [INFO] 获取到学生 ID: !FIRST_ID!

:: 4. 查询学生详情
echo [STEP] 4. 查询学生详情 ^(ID: !FIRST_ID!^)...
for /f "delims=" %%i in ('powershell -Command "$r = curl -s -X GET '%BASE_URL%/demo/student/!FIRST_ID!' -H 'Authorization: %TOKEN%' | ConvertFrom-Json; Write-Output \"$($r.code)|$($r.data.studentName)|$($r.data.studentAge)\""') do (
    set DETAIL_RESULT=%%i
)

for /f "tokens=1,2,3 delims=|" %%a in ("!DETAIL_RESULT!") do (
    set DETAIL_CODE=%%a
    set STUDENT_NAME=%%b
    set STUDENT_AGE=%%c
)

if "!DETAIL_CODE!" == "200" (
    echo [INFO] 学生详情：!STUDENT_NAME!, 年龄: !STUDENT_AGE!
) else (
    echo [WARN] 详情查询失败
)

:: 5. 修改学生
echo [STEP] 5. 修改学生 ^(ID: !FIRST_ID!^)...
for /f "delims=" %%i in ('powershell -Command "$r = curl -s -X PUT '%BASE_URL%/demo/student' -H 'Authorization: %TOKEN%' -H 'Content-Type: application/json' -d '{\"studentId\":!FIRST_ID!,\"studentName\":\"测试学生_curl_已修改\",\"studentAge\":21,\"studentSex\":\"0\",\"studentStatus\":\"0\",\"studentBirthday\":\"2005-02-20\",\"studentHobby\":\"1\"}' | ConvertFrom-Json; Write-Output $r.code"') do (
    set UPDATE_CODE=%%i
)

if "!UPDATE_CODE!" == "200" (
    echo [INFO] 修改学生成功
) else (
    echo [WARN] 修改学生失败
)

:: 6. 验证修改结果
echo [STEP] 6. 验证修改结果...
for /f "delims=" %%i in ('powershell -Command "$r = curl -s -X GET '%BASE_URL%/demo/student/!FIRST_ID!' -H 'Authorization: %TOKEN%' | ConvertFrom-Json; Write-Output \"$($r.data.studentName)|$($r.data.studentAge)\""') do (
    set VERIFY_RESULT=%%i
)

for /f "tokens=1,2 delims=|" %%a in ("!VERIFY_RESULT!") do (
    set MODIFIED_NAME=%%a
    set MODIFIED_AGE=%%b
)

echo [INFO] 修改后验证：名称=!MODIFIED_NAME!, 年龄=!MODIFIED_AGE!
if "!MODIFIED_NAME!" == "测试学生_curl_已修改" (
    echo [INFO] ✅ 数据修改验证通过
) else (
    echo [WARN] ⚠️ 数据修改验证未通过
)

:: 7. 删除学生
echo [STEP] 7. 删除学生 ^(ID: !FIRST_ID!^)...
for /f "delims=" %%i in ('powershell -Command "$r = curl -s -X DELETE '%BASE_URL%/demo/student/!FIRST_ID!' -H 'Authorization: %TOKEN%' | ConvertFrom-Json; Write-Output $r.code"') do (
    set DELETE_CODE=%%i
)

if "!DELETE_CODE!" == "200" (
    echo [INFO] 删除学生成功
) else (
    echo [WARN] 删除学生失败
)

:: 8. 导出测试
echo [STEP] 8. 测试导出接口...
powershell -Command "curl -s -X POST '%BASE_URL%/demo/student/export' -H 'Authorization: %TOKEN%' -H 'Content-Type: application/json' -d '{}' | Out-Null"
echo [INFO] 导出接口调用完成

echo [INFO] 学生管理模块（单表）测试完成
echo.
exit /b 0
