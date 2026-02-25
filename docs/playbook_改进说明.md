# Playbook 改进说明

## 概述

本次改进对 `install_monitoring_tools.yml` playbook 进行了重构，使用 Ansible 标准模块和最佳实践，使其更加模块化、易维护。

## 主要改进

### 1. 使用通用 package 模块

**改进前：**
- 为每个包分别使用 `dnf` 和 `apt` 模块
- 代码重复，维护困难

**改进后：**
- 使用通用的 `package` 模块，自动适配不同发行版
- 代码简洁，易于维护

```yaml
# 改进前
- name: 安装htop (CentOS/RHEL)
  dnf:
    name: htop
    state: present
  when: ansible_os_family == "RedHat"

- name: 安装htop (Ubuntu/Debian)
  apt:
    name: htop
    state: present
  when: ansible_os_family == "Debian"

# 改进后
- name: 安装监控工具包
  package:
    name: "{{ item.name }}"
    state: present
  loop: "{{ monitoring_packages }}"
```

### 2. 使用变量定义包列表

**改进前：**
- 包列表分散在多个任务中
- 难以统一管理和修改

**改进后：**
- 使用 `vars` 集中定义所有包及其描述
- 便于维护和扩展

```yaml
vars:
  monitoring_packages:
    - name: htop
      description: "交互式系统进程监控工具"
    - name: iotop
      description: "实时磁盘I/O监控工具"
    # ...
```

### 3. 使用 package_facts 模块

**改进前：**
- 没有检查已安装的包信息

**改进后：**
- 使用 `package_facts` 收集包信息
- 可以基于事实进行条件判断

```yaml
- name: 收集已安装的包信息
  package_facts:
  when: ansible_pkg_mgr != "unknown"
```

### 4. 改进验证逻辑

**改进前：**
- 使用简单的 `--version` 命令验证
- 错误处理不够完善

**改进后：**
- 使用变量定义验证命令列表
- 更好的错误处理和输出格式

```yaml
vars:
  monitoring_tools_check:
    - name: htop
      command: htop
      args: --version
    - name: ip
      command: ip
      args: -V
```

### 5. 添加新工具

**新增工具：**
- **iproute**: 网络路由和接口管理工具集
- **iproute-doc**: iproute 工具文档

**特殊处理：**
- CentOS/RHEL: 使用 `iproute-doc`
- Ubuntu/Debian: 使用 `iproute2-doc`

## 代码结构对比

### 改进前
- 130+ 行代码
- 大量重复代码
- 难以扩展

### 改进后
- 134 行代码（包含更多功能）
- 代码复用性高
- 易于扩展和维护

## 优势

1. **可维护性**: 集中管理包列表，易于修改
2. **可扩展性**: 添加新工具只需在变量列表中添加
3. **可读性**: 代码结构清晰，逻辑明确
4. **跨平台**: 自动适配不同 Linux 发行版
5. **标准化**: 使用 Ansible 推荐的最佳实践

## 使用示例

### 添加新工具

只需在 `monitoring_packages` 变量中添加：

```yaml
vars:
  monitoring_packages:
    # ... 现有工具 ...
    - name: new-tool
      description: "新工具描述"
```

### 自定义验证

在 `monitoring_tools_check` 中添加验证命令：

```yaml
vars:
  monitoring_tools_check:
    # ... 现有验证 ...
    - name: new-tool
      command: new-tool
      args: --version
```

## 注意事项

1. **包名差异**: 某些包在不同发行版中名称不同（如 iproute-doc）
2. **EPEL源**: CentOS/RHEL 需要 EPEL 源来安装某些工具（如 iperf3）
3. **权限要求**: 需要 root 权限或 sudo 权限

## 参考文档

- [Ansible package 模块文档](https://docs.ansible.com/ansible/latest/collections/ansible/builtin/package_module.html)
- [Ansible package_facts 模块文档](https://docs.ansible.com/ansible/latest/collections/ansible/builtin/package_facts_module.html)
- [Ansible 最佳实践](https://docs.ansible.com/ansible/latest/user_guide/playbooks_best_practices.html)

