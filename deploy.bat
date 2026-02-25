@echo off
REM Linux服务器自动化部署管理脚本 (Windows版本)
REM 使用方法: deploy.bat [选项]

setlocal enabledelayedexpansion

REM 显示帮助信息
:show_help
echo Linux服务器自动化部署管理脚本
echo.
echo 使用方法: %0 [选项]
echo.
echo 选项:
echo   -h, --help              显示此帮助信息
echo   -c, --check             检查Ansible环境
echo   -t, --test              测试主机连通性
echo   -d, --deploy            执行完整部署
echo   -m, --monitoring        只安装监控工具
echo   -z, --zsh               只安装zsh环境
echo   -p, --plugins           只安装zsh插件
echo   -k, --theme             只安装powerlevel10k主题
echo   -g, --group GROUP       指定主机组
echo   -l, --limit HOSTS       限制特定主机
echo   -v, --verbose           详细输出
echo.
echo 示例:
echo   %0 --check              # 检查环境
echo   %0 --test               # 测试连通性
echo   %0 --deploy             # 完整部署
echo   %0 --group centos       # 只部署CentOS主机
echo   %0 --limit server1      # 只部署server1
goto :eof

REM 检查Ansible环境
:check_ansible
echo 检查Ansible环境...

ansible --version >nul 2>&1
if errorlevel 1 (
    echo 错误: Ansible未安装
    echo 请先安装Ansible:
    echo   Windows: 使用WSL或安装Ansible for Windows
    echo   Linux: dnf install ansible 或 apt install ansible
    exit /b 1
)

echo ✓ Ansible已安装
for /f "tokens=*" %%i in ('ansible --version ^| findstr /r "^ansible"') do echo ✓ %%i

if not exist "ansible.cfg" (
    echo 警告: ansible.cfg文件不存在
) else (
    echo ✓ ansible.cfg配置文件存在
)

if not exist "inventory\hosts" (
    echo 警告: inventory\hosts文件不存在
) else (
    echo ✓ 主机清单文件存在
)

if not exist "playbooks" (
    echo 错误: playbooks目录不存在
    exit /b 1
) else (
    echo ✓ playbooks目录存在
)
goto :eof

REM 测试主机连通性
:test_connectivity
echo 测试主机连通性...

if not exist "inventory\hosts" (
    echo 错误: inventory\hosts文件不存在
    exit /b 1
)

ansible all -m ping
goto :eof

REM 执行部署
:deploy
set playbook=%1
set extra_args=%2

echo 开始执行部署...
echo Playbook: %playbook%

if not "%extra_args%"=="" (
    echo 额外参数: %extra_args%
    ansible-playbook %playbook% %extra_args%
) else (
    ansible-playbook %playbook%
)
goto :eof

REM 主函数
:main
set deploy_type=
set group=
set limit=
set verbose=

REM 解析命令行参数
:parse_args
if "%~1"=="" goto :execute
if "%~1"=="-h" goto :show_help
if "%~1"=="--help" goto :show_help
if "%~1"=="-c" goto :check_ansible
if "%~1"=="--check" goto :check_ansible
if "%~1"=="-t" goto :test_connectivity
if "%~1"=="--test" goto :test_connectivity
if "%~1"=="-d" set deploy_type=main & shift & goto :parse_args
if "%~1"=="--deploy" set deploy_type=main & shift & goto :parse_args
if "%~1"=="-m" set deploy_type=monitoring & shift & goto :parse_args
if "%~1"=="--monitoring" set deploy_type=monitoring & shift & goto :parse_args
if "%~1"=="-z" set deploy_type=zsh & shift & goto :parse_args
if "%~1"=="--zsh" set deploy_type=zsh & shift & goto :parse_args
if "%~1"=="-p" set deploy_type=plugins & shift & goto :parse_args
if "%~1"=="--plugins" set deploy_type=plugins & shift & goto :parse_args
if "%~1"=="-k" set deploy_type=theme & shift & goto :parse_args
if "%~1"=="--theme" set deploy_type=theme & shift & goto :parse_args
if "%~1"=="-g" set group=%~2 & shift & shift & goto :parse_args
if "%~1"=="--group" set group=%~2 & shift & shift & goto :parse_args
if "%~1"=="-l" set limit=%~2 & shift & shift & goto :parse_args
if "%~1"=="--limit" set limit=%~2 & shift & shift & goto :parse_args
if "%~1"=="-v" set verbose=-v & shift & goto :parse_args
if "%~1"=="--verbose" set verbose=-v & shift & goto :parse_args

echo 未知选项: %~1
goto :show_help

:execute
REM 如果没有指定操作，显示帮助
if "%deploy_type%"=="" goto :show_help

REM 检查环境
call :check_ansible
if errorlevel 1 exit /b 1

REM 构建额外参数
set extra_args=
if not "%group%"=="" set extra_args=%extra_args% --limit %group%
if not "%limit%"=="" set extra_args=%extra_args% --limit %limit%
if not "%verbose%"=="" set extra_args=%extra_args% %verbose%

REM 执行部署
if "%deploy_type%"=="main" call :deploy "playbooks\main.yml" "%extra_args%"
if "%deploy_type%"=="monitoring" call :deploy "playbooks\install_monitoring_tools.yml" "%extra_args%"
if "%deploy_type%"=="zsh" call :deploy "playbooks\install_zsh_omz.yml" "%extra_args%"
if "%deploy_type%"=="plugins" call :deploy "playbooks\install_zsh_plugins.yml" "%extra_args%"
if "%deploy_type%"=="theme" call :deploy "playbooks\install_powerlevel10k.yml" "%extra_args%"

echo 部署完成！
goto :eof

REM 执行主函数
call :main %*
