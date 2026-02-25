# AnsibleLinuxTools

# Linux服务器自动化部署Ansible工程

这个Ansible工程用于自动化部署Linux服务器的监控工具和增强的zsh环境。

## 功能特性

### 监控工具
- **htop**: 交互式系统进程监控工具
- **iotop**: 实时磁盘I/O监控工具  
- **iftop**: 实时网络流量监控工具
- **fio**: 磁盘性能压测工具
- **iperf3**: 网络带宽压测工具
- **iproute**: 网络路由和接口管理工具集（ip命令）
- **iproute-doc**: iproute工具文档

### Zsh环境
- **zsh**: 增强的shell环境
- **oh-my-zsh**: zsh框架和插件管理器
- **zsh-autosuggestions**: 命令自动补全插件
- **zsh-syntax-highlighting**: 命令语法高亮插件
- **powerlevel10k**: 美观的zsh主题

## 项目结构

```
.
├── ansible.cfg                 # Ansible配置文件
├── deploy.sh                  # Linux/macOS部署管理脚本
├── deploy.bat                 # Windows部署管理脚本
├── env.example                # 环境变量配置示例
├── requirements.txt           # Python依赖包
├── inventory/
│   └── hosts                  # 主机清单文件
├── playbooks/
│   ├── main.yml               # 主playbook
│   ├── install_monitoring_tools.yml  # 安装监控工具
│   ├── install_zsh_omz.yml    # 安装zsh和oh-my-zsh
│   ├── install_zsh_plugins.yml # 安装zsh插件
│   └── install_powerlevel10k.yml # 安装powerlevel10k主题
└── README.md                  # 说明文档
```

## 使用方法

### 0. 快速开始（推荐）

使用提供的管理脚本可以更方便地执行部署：

#### Linux/macOS
```bash
# 检查环境
./deploy.sh --check

# 测试连通性
./deploy.sh --test

# 完整部署
./deploy.sh --deploy

# 只安装监控工具
./deploy.sh --monitoring

# 只安装zsh环境
./deploy.sh --zsh
```

#### Windows
```cmd
REM 检查环境
deploy.bat --check

REM 测试连通性
deploy.bat --test

REM 完整部署
deploy.bat --deploy

REM 只安装监控工具
deploy.bat --monitoring

REM 只安装zsh环境
deploy.bat --zsh
```

### 1. 配置主机清单

编辑 `inventory/hosts` 文件，添加要部署的目标主机：

```ini
[servers]
server1 ansible_host=192.168.1.100 ansible_user=root
server2 ansible_host=192.168.1.101 ansible_user=root

[centos]
centos-server ansible_host=192.168.1.102 ansible_user=root

[ubuntu]
ubuntu-server ansible_host=192.168.1.103 ansible_user=root
```

示例：如果你使用云平台或需要自定义 SSH 端口、私钥或 Python 解释器，可以在组内或 `[group:vars]` 中声明：

```ini
[azure_vm]
xxx ansible_port=1022 ansible_user=ansible ansible_ssh_private_key_file=~/.ssh/id_rsa

[azure_vm:vars]
ansible_user=ansible
ansible_ssh_private_key_file=~/.ssh/id_rsa
ansible_python_interpreter=/usr/bin/python3.8
```

说明：
- `ansible_ssh_private_key_file`：指定控制节点用于连接目标主机的私钥路径（在控制节点上可访问的路径）。
- `ansible_port`：用于非标准 SSH 端口的连接设置。
- `ansible_python_interpreter`：目标主机上 Python3 的路径，避免因系统默认 Python 版本导致模块不可用的问题。

组级或主机级变量会覆盖 `ansible.cfg` 中的默认项；也可以通过命令行 `--extra-vars` 进一步覆盖。

### 2. 执行部署

#### 完整部署（推荐）
```bash
ansible-playbook playbooks/main.yml
```

#### 分步部署
```bash
# 只安装监控工具
ansible-playbook playbooks/install_monitoring_tools.yml

# 只安装zsh和oh-my-zsh
ansible-playbook playbooks/install_zsh_omz.yml

# 只安装zsh插件
ansible-playbook playbooks/install_zsh_plugins.yml

# 只安装powerlevel10k主题
ansible-playbook playbooks/install_powerlevel10k.yml
```

#### 使用标签部署
```bash
# 只安装监控工具
ansible-playbook playbooks/main.yml --tags monitoring

# 只安装zsh相关
ansible-playbook playbooks/main.yml --tags zsh,plugins,theme
```

### 3. 针对特定主机组部署
```bash
# 只对centos主机组部署
ansible-playbook playbooks/main.yml --limit centos

# 只对ubuntu主机组部署
ansible-playbook playbooks/main.yml --limit ubuntu
```

## 支持的操作系统

- **CentOS/RHEL**: 使用dnf包管理器
- **Ubuntu/Debian**: 使用apt包管理器

## 注意事项

1. **权限要求**: 需要root权限或sudo权限
2. **网络要求**: 需要能够访问GitHub下载插件和主题
3. **首次配置**: 安装完成后，首次登录zsh时会自动进入powerlevel10k配置界面
4. **备份文件**: 所有配置文件都会自动备份，备份文件位于用户主目录
5. **额外仓库**: 在CentOS/RHEL上将自动启用EPEL仓库以安装iperf3，如需自定义源请提前配置

### 关于 `ansible.cfg` 的说明

仓库内的 `ansible.cfg` 可能包含一些默认项（例如 `inventory`, `private_key_file`, `remote_user`, `host_key_checking` 等）。示例配置项：

```ini
[defaults]
inventory = /etc/ansible/hosts
host_key_checking = False
private_key_file = ~/.ssh/id_rsa
remote_user = ansible

[ssh_connection]
ssh_args = -o ControlMaster=auto -o ControlPersist=60s -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no
pipelining = True
```

要点：
- 如果 `inventory` 指向系统路径（如 `/etc/ansible/hosts`），请在运行 playbook 时通过 `-i inventory/hosts` 指定本仓库内清单，或修改 `ansible.cfg` 指向本仓库的 `inventory/hosts`。
- `private_key_file` 在 `ansible.cfg` 中设置时会作为默认私钥，可以被主机或组变量 `ansible_ssh_private_key_file` 覆盖。
- `remote_user` 是默认远端用户名，inventory 中的 `ansible_user` 会覆盖它。
- 为避免首次连接交互，可将 `host_key_checking` 设为 `False`，但生产环境请评估安全性。

## 配置说明

### powerlevel10k主题配置
首次登录时会自动进入配置界面，按照提示选择：
- 字体支持
- 颜色主题
- 提示符样式
- 显示元素

### 插件功能
- **zsh-autosuggestions**: 输入命令时会显示历史命令建议
- **zsh-syntax-highlighting**: 命令输入时实时语法高亮

## 故障排除

### 常见问题

1. **权限不足**
   ```bash
   # 确保使用sudo权限
   ansible-playbook playbooks/main.yml --become
   ```

2. **网络连接问题**
   ```bash
   # 检查主机连通性
   ansible all -m ping
   ```

3. **zsh配置问题**
   ```bash
   # 手动重新配置powerlevel10k
   p10k configure
   ```

## 更新和维护

### 更新oh-my-zsh
```bash
omz update
```

### 更新powerlevel10k主题
```bash
git -C ~/.oh-my-zsh/custom/themes/powerlevel10k pull
```

## 参考文档

- [oh-my-zsh官方文档](https://github.com/ohmyzsh/ohmyzsh)
- [powerlevel10k主题](https://github.com/romkatv/powerlevel10k)
- [zsh-autosuggestions插件](https://github.com/zsh-users/zsh-autosuggestions)
- [zsh-syntax-highlighting插件](https://github.com/zsh-users/zsh-syntax-highlighting)
- [fio项目主页](https://github.com/axboe/fio)
- [iperf3项目主页](https://github.com/esnet/iperf)

## 新增：自动推送 SSH 公钥 (push_ssh_key)

为方便向新主机推送控制节点的 SSH 公钥（免密登录），新增一个轻量 playbook：

- 文件：playbooks/push_ssh_key.yml

- 功能：从控制节点读取指定的公钥文件（默认为 `~/.ssh/id_rsa.pub`），并将公钥写入目标主机对应用户的 `~/.ssh/authorized_keys`。

- 使用示例：

```bash
# 使用默认公钥路径和 inventory 中的 ansible_user
ansible-playbook playbooks/push_ssh_key.yml -i inventory/hosts

# 指定控制节点上的公钥文件路径（例如 Windows 下的 Git Bash 或 WSL）
ansible-playbook playbooks/push_ssh_key.yml -i inventory/hosts --extra-vars "pubkey_path=/home/youruser/.ssh/id_rsa.pub"

# 指定将公钥添加到远程主机的指定用户（覆盖 inventory 中的 ansible_user）
ansible-playbook playbooks/push_ssh_key.yml -i inventory/hosts --extra-vars "remote_user=ubuntu pubkey_path=/home/youruser/.ssh/id_rsa.pub"
```

注意事项：

- `pubkey_path` 是控制节点（运行 Ansible 的机器）上的路径，`lookup('file', pubkey_path)` 会在控制节点上读取该文件。
- 若控制节点是 Windows，请确保在 WSL 或 Git Bash 等环境中存在对应的公钥文件路径，或在 `--extra-vars` 中传入一个可被控制节点访问的路径。
- 运行前可以先用 `ansible all -m ping -i inventory/hosts` 检查连通性。
