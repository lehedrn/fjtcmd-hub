#!/bin/bash
# fjtcmd-hub 前端开发环境启停脚本
# 用法：./scripts/dev/frontend.sh start | stop | restart | status | logs

PROJECT_HOME="$(cd "$(dirname "$0")/../.." && pwd)"
UI_DIR="$PROJECT_HOME/fjtcmd-hub-ui"
LOG_DIR="$PROJECT_HOME/logs"
LOG_FILE="$LOG_DIR/frontend.log"
SERVER_PORT=3888
PID_FILE="$PROJECT_HOME/scripts/dev/.fjtcmd-hub-ui.pid"

# 颜色
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m'

echo_info()  { echo -e "${GREEN}[INFO]${NC} $1"; }
echo_warn()  { echo -e "${YELLOW}[WARN]${NC} $1"; }
echo_error() { echo -e "${RED}[ERROR]${NC} $1"; }

cd "$UI_DIR"

# 检查端口是否被占用
check_port() {
    lsof -i :$SERVER_PORT -sTCP:LISTEN -t 2>/dev/null | head -1
}

# 等待服务启动（轮询日志中的 Vite ready 标志）
wait_for_ready() {
    local timeout=15
    local elapsed=0
    while [ $elapsed -lt $timeout ]; do
        if grep -q "ready in" "$LOG_FILE" 2>/dev/null; then
            return 0
        fi
        # 检查是否有致命错误
        if grep -q "error\|Error:" "$LOG_FILE" 2>/dev/null; then
            return 1
        fi
        sleep 1
        elapsed=$((elapsed + 1))
    done
    return 1
}

# 停止占用端口的进程
stop_port_process() {
    local port_pid=$(check_port)
    if [ -n "$port_pid" ]; then
        echo_warn "端口 $SERVER_PORT 已被占用 (PID: $port_pid)，先停止旧进程..."
        kill "$port_pid" 2>/dev/null
        local count=0
        while ps -p "$port_pid" > /dev/null 2>&1; do
            sleep 1
            count=$((count + 1))
            if [ $count -ge 10 ]; then
                echo_warn "正常关闭超时，强制终止..."
                kill -9 "$port_pid" 2>/dev/null
                break
            fi
        done
        sleep 1
    fi
}

start() {
    # 先检查并停止占用端口的进程
    stop_port_process

    # 清空日志
    mkdir -p "$LOG_DIR"
    > "$LOG_FILE"

    echo_info "启动前端开发服务器..."
    pnpm run dev > "$LOG_FILE" 2>&1 &
    local new_pid=$!
    echo "$new_pid" > "$PID_FILE"

    echo_info "等待服务启动..."
    if wait_for_ready; then
        echo_info "前端开发服务器启动成功 (PID: $new_pid)"
        echo_info "地址: http://localhost:$SERVER_PORT"
        echo_info "日志: tail -f $LOG_FILE"
    else
        echo_error "前端启动超时，查看日志: tail -n 50 $LOG_FILE"
        rm -f "$PID_FILE"
        return 1
    fi
}

stop_frontend() {
    local pid=""

    # 从 PID 文件查找
    if [ -f "$PID_FILE" ]; then
        pid=$(cat "$PID_FILE")
        if ! ps -p "$pid" > /dev/null 2>&1; then
            pid=""
        fi
    fi

    # 从端口查找
    if [ -z "$pid" ]; then
        pid=$(check_port)
    fi

    if [ -z "$pid" ]; then
        echo_warn "前端未在运行"
        rm -f "$PID_FILE"
        return 0
    fi

    echo_info "正在停止前端开发服务器 (PID: $pid) ..."
    kill "$pid" 2>/dev/null
    # 同时杀死子进程
    pkill -P "$pid" 2>/dev/null

    local count=0
    while ps -p "$pid" > /dev/null 2>&1; do
        sleep 1
        count=$((count + 1))
        if [ $count -ge 10 ]; then
            echo_warn "正常关闭超时，强制终止..."
            kill -9 "$pid" 2>/dev/null
            break
        fi
    done

    rm -f "$PID_FILE"
    echo_info "前端开发服务器已停止"
}

restart() {
    stop_frontend
    sleep 2
    start
}

status() {
    local pid=""

    if [ -f "$PID_FILE" ]; then
        pid=$(cat "$PID_FILE")
        if ! ps -p "$pid" > /dev/null 2>&1; then
            pid=""
        fi
    fi

    if [ -z "$pid" ]; then
        pid=$(check_port)
    fi

    if [ -n "$pid" ]; then
        echo_info "前端开发服务器运行中 (PID: $pid)"
        echo_info "地址: http://localhost:$SERVER_PORT"
    else
        echo_warn "前端未在运行"
    fi
}

logs() {
    if [ -f "$LOG_FILE" ]; then
        tail -f "$LOG_FILE"
    else
        echo_warn "日志文件不存在: $LOG_FILE"
    fi
}

case "$1" in
    start)    start          ;;
    stop)     stop_frontend  ;;
    restart)  restart        ;;
    status)   status         ;;
    logs)     logs           ;;
    *)
        echo "用法: $0 {start|stop|restart|status|logs}"
        echo ""
        echo "  start    - 启动前端开发服务器"
        echo "  stop     - 停止前端开发服务器"
        echo "  restart  - 重启前端开发服务器"
        echo "  status   - 查看运行状态"
        echo "  logs     - 查看实时日志"
        exit 1
        ;;
esac
