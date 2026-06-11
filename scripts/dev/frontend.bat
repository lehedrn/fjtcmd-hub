@echo off
chcp 65001 >nul 2>&1
setlocal EnableDelayedExpansion

:: fjtcmd-hub 前端开发环境启停脚本 (Windows 版本)
:: 用法：scripts\dev\frontend.bat start | stop | restart | status | logs

set PROJECT_HOME=%~dp0..\..
set UI_DIR=%PROJECT_HOME%\fjtcmd-hub-ui
set LOG_DIR=%PROJECT_HOME%\logs
set LOG_FILE=%LOG_DIR%\frontend.log
set SERVER_PORT=3888
set PID_FILE=%PROJECT_HOME%\scripts\dev\.fjtcmd-hub-ui.pid

:: 处理命令
if "%1"=="start" goto :start
if "%1"=="stop" goto :stop
if "%1"=="restart" goto :restart
if "%1"=="status" goto :status
if "%1"=="logs" goto :logs

echo 用法: %~nx0 {start^|stop^|restart^|status^|logs}
echo.
echo   start    - 启动前端开发服务器
echo   stop     - 停止前端开发服务器
echo   restart  - 重启前端开发服务器
echo   status   - 查看运行状态
echo   logs     - 查看实时日志
exit /b 1

:start
:: 停止占用端口的进程
call :stop_port_process

:: 清空日志
if not exist "%LOG_DIR%" mkdir "%LOG_DIR%"
echo. > "%LOG_FILE%"

echo [INFO] 启动前端开发服务器...
cd /d "%UI_DIR%"

:: 启动前端（后台运行）
start /b "" pnpm run dev > "%LOG_FILE%" 2>&1

:: 等待几秒让进程启动
timeout /t 2 /nobreak >nul

:: 通过端口查找新启动的进程
call :get_port_pid
if not defined PORT_PID (
    echo [ERROR] 前端启动失败，未能找到进程
    exit /b 1
)

:: 保存 PID
echo %PORT_PID%> "%PID_FILE%"

:: 等待启动成功
echo [INFO] 等待服务启动...
call :wait_for_ready
if errorlevel 1 (
    echo [ERROR] 前端启动超时，查看日志: type "%LOG_FILE%" ^| more
    del /f "%PID_FILE%" >nul 2>&1
    exit /b 1
)

echo [INFO] 前端开发服务器启动成功 ^(PID: %PORT_PID%^)
echo [INFO] 地址: http://localhost:%SERVER_PORT%
echo [INFO] 日志: type "%LOG_FILE%" ^| more
exit /b 0

:stop
set PID=

:: 从 PID 文件查找
if exist "%PID_FILE%" (
    set /p PID=<"%PID_FILE%"
    :: 检查进程是否还在运行
    tasklist /FI "PID eq !PID!" 2>nul | findstr "!PID!" >nul
    if errorlevel 1 set PID=
)

:: 从端口查找
if not defined PID (
    call :get_port_pid
    if defined PORT_PID set PID=%PORT_PID%
)

if not defined PID (
    echo [WARN] 前端未在运行
    del /f "%PID_FILE%" >nul 2>&1
    exit /b 0
)

echo [INFO] 正在停止前端开发服务器 ^(PID: %PID%^) ...

:: 终止进程树（包括子进程）
taskkill /T /PID %PID% >nul 2>&1

:: 等待进程退出
set COUNT=0
:stop_wait
tasklist /FI "PID eq %PID%" 2>nul | findstr "%PID%" >nul
if !errorlevel! equ 0 (
    timeout /t 1 /nobreak >nul
    set /a COUNT+=1
    if !COUNT! lss 10 goto :stop_wait
    echo [WARN] 正常关闭超时，强制终止...
    taskkill /T /F /PID %PID% >nul 2>&1
)

del /f "%PID_FILE%" >nul 2>&1
echo [INFO] 前端开发服务器已停止
exit /b 0

:restart
call :stop
timeout /t 2 /nobreak >nul
call :start
exit /b %errorlevel%

:status
set PID=

if exist "%PID_FILE%" (
    set /p PID=<"%PID_FILE%"
    tasklist /FI "PID eq !PID!" 2>nul | findstr "!PID!" >nul
    if errorlevel 1 set PID=
)

if not defined PID (
    call :get_port_pid
    if defined PORT_PID set PID=%PORT_PID%
)

if defined PID (
    echo [INFO] 前端开发服务器运行中 ^(PID: %PID%^)
    echo [INFO] 地址: http://localhost:%SERVER_PORT%
) else (
    echo [WARN] 前端未在运行
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

:get_port_pid
set PORT_PID=
for /f "tokens=5" %%a in ('netstat -ano ^| findstr ":%SERVER_PORT%" ^| findstr "LISTENING" 2^>nul') do (
    set PORT_PID=%%a
    goto :get_port_pid_done
)
:get_port_pid_done
exit /b 0

:stop_port_process
call :get_port_pid
if defined PORT_PID (
    echo [WARN] 端口 %SERVER_PORT% 已被占用 ^(PID: %PORT_PID%^)，先停止旧进程...
    taskkill /T /PID %PORT_PID% >nul 2>&1

    set COUNT=0
    :kill_wait
    tasklist /FI "PID eq %PORT_PID%" 2>nul | findstr "%PORT_PID%" >nul
    if !errorlevel! equ 0 (
        timeout /t 1 /nobreak >nul
        set /a COUNT+=1
        if !COUNT! lss 10 goto :kill_wait
        echo [WARN] 正常关闭超时，强制终止...
        taskkill /T /F /PID %PORT_PID% >nul 2>&1
    )
    timeout /t 1 /nobreak >nul
)
exit /b 0

:wait_for_ready
set TIMEOUT=15
set ELAPSED=0

:wait_loop
if !ELAPSED! geq !TIMEOUT! exit /b 1

:: 检查启动成功标志
findstr "ready in" "%LOG_FILE%" >nul 2>&1
if !errorlevel! equ 0 exit /b 0

:: 检查致命错误
findstr "error" "%LOG_FILE%" >nul 2>&1
if !errorlevel! equ 0 exit /b 1
findstr "Error:" "%LOG_FILE%" >nul 2>&1
if !errorlevel! equ 0 exit /b 1

timeout /t 1 /nobreak >nul
set /a ELAPSED+=1
goto :wait_loop
