#!/bin/bash
# fjtcmd-hub 后端开发环境一键启停脚本
# 用法：./scripts/dev/backend.sh start | stop | restart | status | logs

APP_NAME="fjtcmd-hub-admin"
PROJECT_HOME="$(cd "$(dirname "$0")/../.." && pwd)"
JAR_NAME="fjtcmd-hub-admin.jar"
PID_FILE="$PROJECT_HOME/scripts/dev/.fjtcmd-hub-admin.pid"
LOG_DIR="$PROJECT_HOME/logs"
LOG_FILE="$LOG_DIR/backend.log"
SERVER_PORT=18081

# 颜色
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m'

echo_info()  { echo -e "${GREEN}[INFO]${NC} $1"; }
echo_warn()  { echo -e "${YELLOW}[WARN]${NC} $1"; }
echo_error() { echo -e "${RED}[ERROR]${NC} $1"; }

get_pid() {
    if [ -f "$PID_FILE" ]; then
        local pid=$(cat "$PID_FILE")
        if ps -p "$pid" > /dev/null 2>&1; then
            echo "$pid"
            return
        fi
    fi
    # 备用：通过进程名查找
    ps -ef | grep java | grep "$JAR_NAME" | grep -v grep | awk '{print $2}' | head -1
}

# 检查端口是否被占用
check_port() {
    lsof -i :$SERVER_PORT -sTCP:LISTEN -t 2>/dev/null | head -1
}

# 等待启动成功（轮询日志中的成功标志）
wait_for_startup() {
    local timeout=60
    local elapsed=0
    while [ $elapsed -lt $timeout ]; do
        if grep -q "FjtcmdHub启动成功" "$LOG_FILE" 2>/dev/null; then
            return 0
        fi
        # 检查是否有致命错误
        if grep -q "BUILD FAILURE\|APPLICATION FAILED TO START" "$LOG_FILE" 2>/dev/null; then
            return 1
        fi
        sleep 1
        elapsed=$((elapsed + 1))
    done
    return 1
}

# 检查依赖服务
check_dependencies() {
    echo_info "检查依赖服务..."

    # 检查 MySQL
    if docker ps --format '{{.Names}}' | grep -q "mysql8"; then
        echo_info "MySQL (mysql8) 运行中"
    else
        echo_warn "MySQL (mysql8) 未运行，尝试启动..."
        docker start mysql8 2>/dev/null
        if [ $? -eq 0 ]; then
            echo_info "MySQL 已启动"
        else
            echo_error "MySQL 启动失败，请先启动 Docker MySQL 容器"
            return 1
        fi
    fi

    # 检查 Redis
    if docker ps --format '{{.Names}}' | grep -q "redis"; then
        echo_info "Redis (redis) 运行中"
    else
        echo_warn "Redis (redis) 未运行，尝试启动..."
        docker start redis 2>/dev/null
        if [ $? -eq 0 ]; then
            echo_info "Redis 已启动"
        else
            echo_error "Redis 启动失败，请先启动 Docker Redis 容器"
            return 1
        fi
    fi

    return 0
}

start() {
    # 先检查端口是否被占用，如果占用则先停止旧进程
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

    # 再次检查是否有残留进程
    local pid=$(get_pid)
    if [ -n "$pid" ]; then
        echo_warn "$APP_NAME 已在运行中 (PID: $pid)"
        return 0
    fi

    # 检查依赖
    check_dependencies || return 1

    echo_info "正在启动 $APP_NAME ..."
    mkdir -p "$LOG_DIR"

    # 清空日志，避免旧日志干扰排查
    > "$LOG_FILE"

    # 编译并启动
    cd "$PROJECT_HOME"
    mvn spring-boot:run -pl fjtcmd-hub-admin \
        > "$LOG_FILE" 2>&1 &

    local new_pid=$!
    echo "$new_pid" > "$PID_FILE"

    # 等待启动成功
    echo_info "等待服务启动..."
    if wait_for_startup; then
        echo_info "$APP_NAME 启动成功 (PID: $new_pid)"
        echo_info "日志: tail -f $LOG_FILE"
    else
        echo_error "$APP_NAME 启动失败，查看日志: tail -n 50 $LOG_FILE"
        rm -f "$PID_FILE"
        return 1
    fi
}

stop() {
    local pid=$(get_pid)

    # 如果 PID 文件找不到进程，通过端口查找
    if [ -z "$pid" ]; then
        pid=$(check_port)
    fi

    if [ -z "$pid" ]; then
        echo_warn "$APP_NAME 未在运行"
        rm -f "$PID_FILE"
        return 0
    fi

    echo_info "正在停止 $APP_NAME (PID: $pid) ..."
    kill "$pid" 2>/dev/null

    # 等待进程退出
    local count=0
    while ps -p "$pid" > /dev/null 2>&1; do
        sleep 1
        count=$((count + 1))
        if [ $count -ge 15 ]; then
            echo_warn "正常关闭超时，强制终止..."
            kill -9 "$pid" 2>/dev/null
            break
        fi
    done

    rm -f "$PID_FILE"
    echo_info "$APP_NAME 已停止"
}

restart() {
    stop
    sleep 2
    start
}

status() {
    local pid=$(get_pid)
    if [ -n "$pid" ]; then
        echo_info "$APP_NAME 运行中 (PID: $pid)"
        # 显示端口
        local port=$(netstat -tlnp 2>/dev/null | grep $pid | grep -oP ':\K[0-9]+' | head -1)
        if [ -n "$port" ]; then
            echo_info "监听端口: $port"
        fi
    else
        echo_warn "$APP_NAME 未运行"
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
    start)    start    ;;
    stop)     stop     ;;
    restart)  restart  ;;
    status)   status   ;;
    logs)     logs     ;;
    *)
        echo "用法: $0 {start|stop|restart|status|logs}"
        echo ""
        echo "  start    - 启动后端服务"
        echo "  stop     - 停止后端服务"
        echo "  restart  - 重启后端服务"
        echo "  status   - 查看运行状态"
        echo "  logs     - 查看实时日志"
        exit 1
        ;;
esac
