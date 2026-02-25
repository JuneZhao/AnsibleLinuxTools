#!/bin/bash

# Linux服务器自动化部署管理脚本
# 使用方法: ./deploy.sh [选项]

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 显示帮助信息
show_help() {
    echo -e "${BLUE}Linux服务器自动化部署管理脚本${NC}"
    echo ""
    echo "使用方法: $0 [选项]"
    echo ""
    echo "选项:"
    echo "  -h, --help              显示此帮助信息"
    echo "  -c, --check             检查Ansible环境"
    echo "  -t, --test              测试主机连通性"
    echo "  -d, --deploy            执行完整部署"
    echo "  -m, --monitoring        只安装监控工具"
    echo "  -z, --zsh               只安装zsh环境"
    echo "  -p, --plugins           只安装zsh插件"
    echo "  -k, --theme             只安装powerlevel10k主题"
    echo "  -g, --group GROUP       指定主机组"
    echo "  -l, --limit HOSTS       限制特定主机"
    echo "  -v, --verbose           详细输出"
    echo ""
    echo "示例:"
    echo "  $0 --check              # 检查环境"
    echo "  $0 --test               # 测试连通性"
    echo "  $0 --deploy             # 完整部署"
    echo "  $0 --group centos       # 只部署CentOS主机"
    echo "  $0 --limit server1      # 只部署server1"
}

# 检查Ansible环境
check_ansible() {
    echo -e "${BLUE}检查Ansible环境...${NC}"
    
    if ! command -v ansible &> /dev/null; then
        echo -e "${RED}错误: Ansible未安装${NC}"
        echo "请先安装Ansible:"
        echo "  CentOS/RHEL: dnf install ansible"
        echo "  Ubuntu/Debian: apt install ansible"
        exit 1
    fi
    
    echo -e "${GREEN}✓ Ansible版本: $(ansible --version | head -n1)${NC}"
    
    if [ ! -f "ansible.cfg" ]; then
        echo -e "${YELLOW}警告: ansible.cfg文件不存在${NC}"
    else
        echo -e "${GREEN}✓ ansible.cfg配置文件存在${NC}"
    fi
    
    if [ ! -f "inventory/hosts" ]; then
        echo -e "${YELLOW}警告: inventory/hosts文件不存在${NC}"
    else
        echo -e "${GREEN}✓ 主机清单文件存在${NC}"
    fi
    
    if [ ! -d "playbooks" ]; then
        echo -e "${RED}错误: playbooks目录不存在${NC}"
        exit 1
    else
        echo -e "${GREEN}✓ playbooks目录存在${NC}"
    fi
}

# 测试主机连通性
test_connectivity() {
    echo -e "${BLUE}测试主机连通性...${NC}"
    
    if [ ! -f "inventory/hosts" ]; then
        echo -e "${RED}错误: inventory/hosts文件不存在${NC}"
        exit 1
    fi
    
    ansible all -m ping
}

# 执行部署
deploy() {
    local playbook="$1"
    local extra_args="$2"
    
    echo -e "${BLUE}开始执行部署...${NC}"
    echo -e "${YELLOW}Playbook: $playbook${NC}"
    
    if [ -n "$extra_args" ]; then
        echo -e "${YELLOW}额外参数: $extra_args${NC}"
        ansible-playbook "$playbook" $extra_args
    else
        ansible-playbook "$playbook"
    fi
}

# 主函数
main() {
    local deploy_type=""
    local group=""
    local limit=""
    local verbose=""
    
    # 解析命令行参数
    while [[ $# -gt 0 ]]; do
        case $1 in
            -h|--help)
                show_help
                exit 0
                ;;
            -c|--check)
                check_ansible
                exit 0
                ;;
            -t|--test)
                test_connectivity
                exit 0
                ;;
            -d|--deploy)
                deploy_type="main"
                shift
                ;;
            -m|--monitoring)
                deploy_type="monitoring"
                shift
                ;;
            -z|--zsh)
                deploy_type="zsh"
                shift
                ;;
            -p|--plugins)
                deploy_type="plugins"
                shift
                ;;
            -k|--theme)
                deploy_type="theme"
                shift
                ;;
            -g|--group)
                group="$2"
                shift 2
                ;;
            -l|--limit)
                limit="$2"
                shift 2
                ;;
            -v|--verbose)
                verbose="-v"
                shift
                ;;
            *)
                echo -e "${RED}未知选项: $1${NC}"
                show_help
                exit 1
                ;;
        esac
    done
    
    # 如果没有指定操作，显示帮助
    if [ -z "$deploy_type" ]; then
        show_help
        exit 0
    fi
    
    # 检查环境
    check_ansible
    
    # 构建额外参数
    local extra_args=""
    if [ -n "$group" ]; then
        extra_args="$extra_args --limit $group"
    fi
    if [ -n "$limit" ]; then
        extra_args="$extra_args --limit $limit"
    fi
    if [ -n "$verbose" ]; then
        extra_args="$extra_args $verbose"
    fi
    
    # 执行部署
    case $deploy_type in
        main)
            deploy "playbooks/main.yml" "$extra_args"
            ;;
        monitoring)
            deploy "playbooks/install_monitoring_tools.yml" "$extra_args"
            ;;
        zsh)
            deploy "playbooks/install_zsh_omz.yml" "$extra_args"
            ;;
        plugins)
            deploy "playbooks/install_zsh_plugins.yml" "$extra_args"
            ;;
        theme)
            deploy "playbooks/install_powerlevel10k.yml" "$extra_args"
            ;;
    esac
    
    echo -e "${GREEN}部署完成！${NC}"
}

# 执行主函数
main "$@"
