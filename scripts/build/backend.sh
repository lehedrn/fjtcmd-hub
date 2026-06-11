#!/bin/bash
# fjtcmd-hub 后端 Maven 编译脚本
# 用法：./scripts/build/backend.sh [clean|compile|package|install|clean-install]

PROJECT_HOME="$(cd "$(dirname "$0")/../.." && pwd)"

# 颜色
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m'

echo_info()  { echo -e "${GREEN}[INFO]${NC} $1"; }
echo_warn()  { echo -e "${YELLOW}[WARN]${NC} $1"; }
echo_error() { echo -e "${RED}[ERROR]${NC} $1"; }

cd "$PROJECT_HOME"

build() {
    local action="$1"
    case "$action" in
        clean)
            echo_info "执行 clean ..."
            mvn clean
            ;;
        compile)
            echo_info "执行 compile ..."
            mvn compile
            ;;
        package)
            echo_info "执行 package ..."
            mvn package -DskipTests
            if [ $? -eq 0 ]; then
                echo_info "构建产物: fjtcmd-hub-admin/target/fjtcmd-hub-admin.jar"
            fi
            ;;
        install)
            echo_info "执行 install ..."
            mvn install -DskipTests
            ;;
        clean-install)
            echo_info "执行 clean install ..."
            mvn clean install -DskipTests
            ;;
        test)
            echo_info "执行 test ..."
            mvn test
            ;;
        *)
            echo_error "未知的构建动作: $action"
            usage
            exit 1
            ;;
    esac

    if [ $? -eq 0 ]; then
        echo_info "构建成功: $action"
    else
        echo_error "构建失败: $action"
        exit 1
    fi
}

usage() {
    echo "用法: $0 [clean|compile|package|install|clean-install|test]"
    echo ""
    echo "  clean        - 清理 target 目录"
    echo "  compile      - 编译源码"
    echo "  package      - 打包（跳过测试）"
    echo "  install      - 编译并安装到本地仓库（跳过测试）"
    echo "  clean-install- 清理后重新编译安装（跳过测试）"
    echo "  test         - 运行单元测试"
}

case "$1" in
    clean|compile|package|install|clean-install|test)
        build "$1"
        ;;
    *)
        usage
        exit 1
        ;;
esac
