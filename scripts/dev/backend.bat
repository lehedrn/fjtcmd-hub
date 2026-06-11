@echo off
chcp 65001 >nul 2>&1
setlocal EnableDelayedExpansion

:: fjtcmd-hub 后端开发环境一键启停脚本 (Windows 版本)
:: 用法：scripts\dev\backend.bat start | stop | restart | status | logs

set APP_NAME=fjtcmd-hub-admin
set PROJECT_HOME=%~dp0..\..
set JAR_NAME=fjtcmd-hub-admin.jar
set PID_FILE=%PROJECT_HOME%\scripts\dev\.fjtcmd-hub-admin.pid
set LOG_DIR=%PROJECT_HOME%\logs
set LOG_FILE=%LOG_DIR%\backend.log
set SERVER_PORT=18081

:: 处理命令
if "%1"=="start" goto :start
if "%1"=="stop" goto :stop
if "%1"=="restart" goto :restart
if "%1"=="status" goto :status
if "%1"=="logs" goto :logs

echo 用法: %~nx0 {start^|stop^|restart^|status^|logs}
echo.
echo   start    - 启动后端服务
echo   stop     - 停止后端服务
echo   restart  - 重启后端服务
echo   status   - 查看运行状态
echo   logs     - 查看实时日志
exit /b 1

:start
:: 检查端口是否被占用
for /f "tokens=5" %%a in ('netstat -ano ^| findstr ":%SERVER_PORT%" ^| findstr "LISTENING" 2^>nul') do (
    set PORT_PID=%%a
    goto :port_found
)
set PORT_PID=

if defined PORT_PID (
    echo [WARN] 端口 %SERVER_PORT% 已被占用 ^(PID: %PORT_PID%^)，先停止旧进程...
    taskkill /PID %PORT_PID% >nul 2>&1
    :: 等待进程退出
    set COUNT=0
    :kill_wait
    tasklist /FI "PID eq %PORT_PID%" 2>nul | findstr "%PORT_PID%" >nul
    if !errorlevel! equ 0 (
        timeout /t 1 /nobreak >nul
        set /a COUNT+=1
        if !COUNT! lss 10 goto :kill_wait
        echo [WARN] 正常关闭超时，强制终止...
        taskkill /F /PID %PORT_PID% >nul 2>&1
    )
    timeout /t 1 /nobreak >nul
)

:: 检查是否已在运行
call :get_pid
if defined CURRENT_PID (
    echo [WARN] %APP_NAME% 已在运行中 ^(PID: %CURRENT_PID%^)
    exit /b 0
)

:: 检查依赖
call :check_dependencies
if errorlevel 1 exit /b 1

echo [INFO] 正在启动 %APP_NAME% ...
if not exist "%LOG_DIR%" mkdir "%LOG_DIR%"

:: 清空日志
echo. > "%LOG_FILE%"

:: 启动后端（后台运行）
cd /d "%PROJECT_HOME%"
start /b "" mvn spring-boot:run -pl fjtcmd-hub-admin > "%LOG_FILE%" 2>&1

:: 等待几秒让进程启动
timeout /t 3 /nobreak >nul

:: 通过端口查找新启动的进程
call :get_pid
if not defined CURRENT_PID (
    echo [ERROR] %APP_NAME% 启动失败，未能找到进程
    exit /b 1
)

:: 保存 PID
echo %CURRENT_PID%> "%PID_FILE%"

:: 等待启动成功
echo [INFO] 等待服务启动...
call :wait_for_startup
if errorlevel 1 (
    echo [ERROR] %APP_NAME% 启动失败，查看日志: type "%LOG_FILE%" ^| more
    del /f "%PID_FILE%" >nul 2>&1
    exit /b 1
)

echo [INFO] %APP_NAME% 启动成功 ^(PID: %CURRENT_PID%^)
echo [INFO] 日志: type "%LOG_FILE%" ^| more
exit /b 0

:stop
call :get_pid
if not defined CURRENT_PID (
    :: 通过端口查找
    for /f "tokens=5" %%a in ('netstat -ano ^| findstr ":%SERVER_PORT%" ^| findstr "LISTENING" 2^>nul') do (
        set CURRENT_PID=%%a
        goto :port_pid_found
    )
    :port_pid_found
)

if not defined CURRENT_PID (
    echo [WARN] %APP_NAME% 未在运行
    del /f "%PID_FILE%" >nul 2>&1
    exit /b 0
)

echo [INFO] 正在停止 %APP_NAME% ^(PID: %CURRENT_PID%^) ...
taskkill /PID %CURRENT_PID% >nul 2>&1

:: 等待进程退出
set COUNT=0
:stop_wait
tasklist /FI "PID eq %CURRENT_PID%" 2>nul | findstr "%CURRENT_PID%" >nul
if !errorlevel! equ 0 (
    timeout /t 1 /nobreak >nul
    set /a COUNT+=1
    if !COUNT! lss 15 goto :stop_wait
    echo [WARN] 正常关闭超时，强制终止...
    taskkill /F /PID %CURRENT_PID% >nul 2>&1
)

del /f "%PID_FILE%" >nul 2>&1
echo [INFO] %APP_NAME% 已停止
exit /b 0

:restart
call :stop
timeout /t 2 /nobreak >nul
call :start
exit /b %errorlevel%

:status
call :get_pid
if defined CURRENT_PID (
    echo [INFO] %APP_NAME% 运行中 ^(PID: %CURRENT_PID%^)
    :: 显示端口
    for /f "tokens=2" %%a in ('netstat -ano ^| findstr "%CURRENT_PID%" ^| findstr "LISTENING" 2^>nul') do (
        echo [INFO] 监听端口: %SERVER_PORT%
        goto :status_done
    )
    :status_done
) else (
    echo [WARN] %APP_NAME% 未运行
)
exit /b 0

:logs
if exist "%LOG_FILE%" (
    powershell -Command "Get-Content '%LOG_FILE%' -Wait -Tail 50"
) else (
    echo [WARN] 日志文件不存在: %LOG_FILE%
)
exit /b 0

:: ============================================================
:: 辅助函数
:: ============================================================

:get_pid
set CURRENT_PID=
if exist "%PID_FILE%" (
    set /p CURRENT_PID=<"%PID_FILE%"
    :: 检查进程是否还在运行
    tasklist /FI "PID eq !CURRENT_PID!" 2>nul | findstr "!CURRENT_PID!" >nul
    if errorlevel 1 set CURRENT_PID=
)
if not defined CURRENT_PID (
    :: 备用：通过端口查找
    for /f "tokens=5" %%a in ('netstat -ano ^| findstr ":%SERVER_PORT%" ^| findstr "LISTENING" 2^>nul') do (
        set CURRENT_PID=%%a
        goto :get_pid_done
    )
    :get_pid_done
)
exit /b 0

:check_dependencies
echo [INFO] 检查依赖服务...

:: 检查 MySQL
docker ps --format "{{.Names}}" 2>nul | findstr "mysql8" >nul
if !errorlevel! equ 0 (
    echo [INFO] MySQL ^(mysql8^) 运行中
) else (
    echo [WARN] MySQL ^(mysql8^) 未运行，尝试启动...
    docker start mysql8 >nul 2>&1
    if !errorlevel! equ 0 (
        echo [INFO] MySQL 已启动
    ) else (
        echo [ERROR] MySQL 启动失败，请先启动 Docker MySQL 容器
        exit /b 1
    )
)

:: 检查 Redis
docker ps --format "{{.Names}}" 2>nul | findstr "redis" >nul
if !errorlevel! equ 0 (
    echo [INFO] Redis ^(redis^) 运行中
) else (
    echo [WARN] Redis ^(redis^) 未运行，尝试启动...
    docker start redis >nul 2>&1
    if !errorlevel! equ 0 (
        echo [INFO] Redis 已启动
    ) else (
        echo [ERROR] Redis 启动失败，请先启动 Docker Redis 容器
        exit /b 1
    )
)

exit /b 0

:wait_for_startup
set TIMEOUT=60
set ELAPSED=0

:wait_loop
if !ELAPSED! geq !TIMEOUT! exit /b 1

:: 检查启动成功标志
findstr "FjtcmdHub启动成功" "%LOG_FILE%" >nul 2>&1
if !errorlevel! equ 0 exit /b 0

:: 检查致命错误
findstr "BUILD FAILURE" "%LOG_FILE%" >nul 2>&1
if !errorlevel! equ 0 exit /b 1
findstr "APPLICATION FAILED TO START" "%LOG_FILE%" >nul 2>&1
if !errorlevel! equ 0 exit /b 1

timeout /t 1 /nobreak >nul
set /a ELAPSED+=1
goto :wait_loop
