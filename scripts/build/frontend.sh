#!/bin/bash
# fjtcmd-hub 前端编译构建脚本（使用 pnpm）
# 用法：./scripts/build/frontend.sh [install|build:prod|build:stage|clean|clean-install]

PROJECT_HOME="$(cd "$(dirname "$0")/../.." && pwd)"
UI_DIR="$PROJECT_HOME/fjtcmd-hub-ui"

# 颜色
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m'

echo_info()  { echo -e "${GREEN}[INFO]${NC} $1"; }
echo_warn()  { echo -e "${YELLOW}[WARN]${NC} $1"; }
echo_error() { echo -e "${RED}[ERROR]${NC} $1"; }

cd "$UI_DIR"

# 检查 pnpm 是否可用
check_pnpm() {
    if ! command -v pnpm &>/dev/null; then
        echo_warn "pnpm 未安装，正在全局安装..."
        npm install -g pnpm
        if [ $? -ne 0 ]; then
            echo_error "pnpm 安装失败，请手动执行: npm install -g pnpm"
            exit 1
        fi
    fi
    echo_info "pnpm 版本: $(pnpm --version)"
}

build() {
    local action="$1"
    check_pnpm

    case "$action" in
        install)
            echo_info "安装前端依赖..."
            pnpm install
            ;;
        build:prod)
            echo_info "执行生产环境打包..."
            pnpm run build:prod
            if [ $? -eq 0 ]; then
                echo_info "构建产物: fjtcmd-hub-ui/dist/"
            fi
            ;;
        build:stage)
            echo_info "执行预发布环境打包..."
            pnpm run build:stage
            if [ $? -eq 0 ]; then
                echo_info "构建产物: fjtcmd-hub-ui/dist/"
            fi
            ;;
        clean)
            echo_info "清理 node_modules 和 dist..."
            rm -rf "$UI_DIR/node_modules"
            rm -rf "$UI_DIR/dist"
            ;;
        clean-install)
            echo_info "清理并重新安装依赖..."
            rm -rf "$UI_DIR/node_modules"
            rm -rf "$UI_DIR/dist"
            pnpm install
            ;;
        *)
            echo_error "未知的操作: $action"
            usage
            exit 1
            ;;
    esac

    if [ $? -eq 0 ]; then
        echo_info "操作成功: $action"
    else
        echo_error "操作失败: $action"
        exit 1
    fi
}

usage() {
    echo "用法: $0 [install|build:prod|build:stage|clean|clean-install]"
    echo ""
    echo "  install      - 安装前端依赖（pnpm）"
    echo "  build:prod   - 生产环境打包"
    echo "  build:stage  - 预发布环境打包"
    echo "  clean        - 清理 node_modules 和 dist"
    echo "  clean-install- 清理后重新安装依赖"
}

case "$1" in
    install|build:prod|build:stage|clean|clean-install)
        build "$1"
        ;;
    *)
        usage
        exit 1
        ;;
esac
