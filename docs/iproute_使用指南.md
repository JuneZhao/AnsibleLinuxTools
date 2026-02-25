# iproute 网络管理工具使用指南

iproute 是 Linux 系统中用于网络配置和管理的现代工具集，提供了 `ip` 命令来替代传统的 `ifconfig`、`route`、`arp` 等命令。

## 目录

- [基本概念](#基本概念)
- [安装验证](#安装验证)
- [常用命令](#常用命令)
  - [网络接口管理](#网络接口管理)
  - [IP地址管理](#ip地址管理)
  - [路由管理](#路由管理)
  - [ARP表管理](#arp表管理)
  - [网络命名空间](#网络命名空间)
  - [流量控制](#流量控制)
- [实际应用场景](#实际应用场景)
- [与旧命令对比](#与旧命令对比)

## 基本概念

### iproute 工具集包含的命令

- **ip**: 主要的网络配置命令
- **ss**: 替代 netstat，显示网络连接
- **tc**: 流量控制工具
- **bridge**: 网桥管理工具

### ip 命令的基本语法

```bash
ip [选项] 对象 命令 [参数]
```

**常用对象：**
- `link`: 网络接口
- `addr`: IP地址
- `route`: 路由表
- `neigh`: 邻居表（ARP）
- `netns`: 网络命名空间

## 安装验证

```bash
# 检查iproute是否已安装
ip -V

# 查看帮助信息
ip help

# 查看特定对象的帮助
ip link help
ip addr help
ip route help
```

## 常用命令

### 网络接口管理

#### 查看所有网络接口
```bash
# 查看所有接口
ip link show

# 查看特定接口
ip link show eth0

# 简洁显示
ip -s link show

# 显示详细信息
ip -d link show
```

#### 启用/禁用网络接口
```bash
# 启用接口
ip link set eth0 up

# 禁用接口
ip link set eth0 down

# 设置接口MTU
ip link set eth0 mtu 1500
```

#### 查看接口统计信息
```bash
# 查看接口统计
ip -s link show eth0

# 持续监控
watch -n 1 'ip -s link show eth0'
```

### IP地址管理

#### 查看IP地址
```bash
# 查看所有接口的IP地址
ip addr show
# 或简写
ip a

# 查看特定接口
ip addr show eth0

# 只显示IPv4地址
ip -4 addr show

# 只显示IPv6地址
ip -6 addr show
```

#### 添加IP地址
```bash
# 添加IP地址
ip addr add 192.168.1.100/24 dev eth0

# 添加多个IP地址（别名）
ip addr add 192.168.1.101/24 dev eth0 label eth0:1

# 添加IPv6地址
ip -6 addr add 2001:db8::1/64 dev eth0
```

#### 删除IP地址
```bash
# 删除IP地址
ip addr del 192.168.1.100/24 dev eth0

# 删除所有IP地址
ip addr flush dev eth0
```

#### 刷新IP地址
```bash
# 刷新特定接口的所有地址
ip addr flush dev eth0

# 刷新所有接口的地址
ip addr flush all
```

### 路由管理

#### 查看路由表
```bash
# 查看所有路由
ip route show
# 或简写
ip r

# 查看特定网络的路由
ip route show 192.168.1.0/24

# 查看默认路由
ip route show default

# 查看路由表（带详细信息）
ip route show table main
```

#### 添加路由
```bash
# 添加默认路由
ip route add default via 192.168.1.1

# 添加网络路由
ip route add 192.168.2.0/24 via 192.168.1.1

# 添加直连路由
ip route add 192.168.3.0/24 dev eth0

# 添加默认路由（指定接口）
ip route add default via 192.168.1.1 dev eth0
```

#### 删除路由
```bash
# 删除默认路由
ip route del default

# 删除特定路由
ip route del 192.168.2.0/24

# 删除所有路由
ip route flush all
```

#### 修改路由
```bash
# 修改路由（先删除再添加）
ip route change 192.168.2.0/24 via 192.168.1.2
```

### ARP表管理

#### 查看ARP表
```bash
# 查看ARP表（邻居表）
ip neigh show
# 或简写
ip n

# 查看特定接口的ARP表
ip neigh show dev eth0
```

#### 添加ARP条目
```bash
# 添加静态ARP条目
ip neigh add 192.168.1.100 lladdr 00:11:22:33:44:55 dev eth0
```

#### 删除ARP条目
```bash
# 删除ARP条目
ip neigh del 192.168.1.100 dev eth0

# 刷新ARP表
ip neigh flush dev eth0
```

### 网络命名空间

#### 创建网络命名空间
```bash
# 创建命名空间
ip netns add testns

# 列出所有命名空间
ip netns list

# 在命名空间中执行命令
ip netns exec testns ip addr show

# 删除命名空间
ip netns delete testns
```

#### 在命名空间中配置网络
```bash
# 将接口移到命名空间
ip link set eth1 netns testns

# 在命名空间中配置IP
ip netns exec testns ip addr add 192.168.10.1/24 dev eth1
ip netns exec testns ip link set eth1 up
```

### 流量控制

#### 查看流量控制规则
```bash
# 查看接口的流量控制规则
tc qdisc show dev eth0

# 查看所有接口
tc qdisc show
```

#### 添加流量控制
```bash
# 添加限速规则（限制为1Mbps）
tc qdisc add dev eth0 root tbf rate 1mbit burst 32kbit latency 400ms

# 添加延迟
tc qdisc add dev eth0 root netem delay 100ms

# 添加丢包率
tc qdisc add dev eth0 root netem loss 1%
```

#### 删除流量控制
```bash
# 删除所有流量控制规则
tc qdisc del dev eth0 root
```

## 实际应用场景

### 场景1: 配置静态IP地址

```bash
# 1. 查看当前配置
ip addr show eth0

# 2. 删除旧IP（如果有）
ip addr del 192.168.1.100/24 dev eth0

# 3. 添加新IP
ip addr add 192.168.1.200/24 dev eth0

# 4. 启用接口
ip link set eth0 up

# 5. 配置默认路由
ip route add default via 192.168.1.1 dev eth0

# 6. 验证配置
ip addr show eth0
ip route show
```

### 场景2: 配置多IP地址（虚拟接口）

```bash
# 为接口添加多个IP地址
ip addr add 192.168.1.101/24 dev eth0 label eth0:1
ip addr add 192.168.1.102/24 dev eth0 label eth0:2

# 查看所有IP地址
ip addr show eth0
```

### 场景3: 配置静态路由

```bash
# 添加静态路由到特定网络
ip route add 10.0.0.0/8 via 192.168.1.254 dev eth0

# 添加默认路由
ip route add default via 192.168.1.1 dev eth0

# 查看路由表
ip route show
```

### 场景4: 网络故障排查

```bash
# 1. 检查接口状态
ip link show

# 2. 检查IP配置
ip addr show

# 3. 检查路由表
ip route show

# 4. 检查ARP表
ip neigh show

# 5. 测试连通性
ping -c 4 192.168.1.1

# 6. 追踪路由
ip route get 8.8.8.8
```

### 场景5: 监控网络流量

```bash
# 实时监控接口统计
watch -n 1 'ip -s link show eth0'

# 查看接口错误统计
ip -s link show eth0 | grep -A 5 "RX:"
```

### 场景6: 配置VLAN

```bash
# 创建VLAN接口
ip link add link eth0 name eth0.100 type vlan id 100

# 配置VLAN接口IP
ip addr add 192.168.100.1/24 dev eth0.100

# 启用VLAN接口
ip link set eth0.100 up
```

## 与旧命令对比

### ifconfig vs ip

| 旧命令 | iproute 命令 | 说明 |
|--------|-------------|------|
| `ifconfig` | `ip addr show` | 查看IP地址 |
| `ifconfig eth0 up` | `ip link set eth0 up` | 启用接口 |
| `ifconfig eth0 down` | `ip link set eth0 down` | 禁用接口 |
| `ifconfig eth0 192.168.1.100 netmask 255.255.255.0` | `ip addr add 192.168.1.100/24 dev eth0` | 配置IP地址 |

### route vs ip route

| 旧命令 | iproute 命令 | 说明 |
|--------|-------------|------|
| `route -n` | `ip route show` | 查看路由表 |
| `route add default gw 192.168.1.1` | `ip route add default via 192.168.1.1` | 添加默认路由 |
| `route add -net 192.168.2.0 netmask 255.255.255.0 gw 192.168.1.1` | `ip route add 192.168.2.0/24 via 192.168.1.1` | 添加网络路由 |
| `route del default` | `ip route del default` | 删除默认路由 |

### arp vs ip neigh

| 旧命令 | iproute 命令 | 说明 |
|--------|-------------|------|
| `arp -a` | `ip neigh show` | 查看ARP表 |
| `arp -s 192.168.1.100 00:11:22:33:44:55` | `ip neigh add 192.168.1.100 lladdr 00:11:22:33:44:55 dev eth0` | 添加静态ARP |
| `arp -d 192.168.1.100` | `ip neigh del 192.168.1.100 dev eth0` | 删除ARP条目 |

### netstat vs ss

```bash
# 查看所有连接
netstat -tuln
ss -tuln

# 查看监听端口
netstat -tlnp
ss -tlnp

# 查看TCP连接
netstat -tn
ss -tn

# 查看UDP连接
netstat -un
ss -un
```

## 常用组合命令

### 一键查看网络配置
```bash
echo "=== 网络接口 ===" && \
ip link show && \
echo -e "\n=== IP地址 ===" && \
ip addr show && \
echo -e "\n=== 路由表 ===" && \
ip route show && \
echo -e "\n=== ARP表 ===" && \
ip neigh show
```

### 保存和恢复网络配置
```bash
# 保存当前配置
ip addr save > /tmp/ip_addr_backup.txt
ip route save > /tmp/ip_route_backup.txt

# 恢复配置
ip addr restore < /tmp/ip_addr_backup.txt
ip route restore < /tmp/ip_route_backup.txt
```

## 参考资源

- [iproute2 官方文档](https://wiki.linuxfoundation.org/networking/iproute2)
- [ip 命令手册](https://man7.org/linux/man-pages/man8/ip.8.html)
- [Linux 网络管理最佳实践](https://www.kernel.org/doc/Documentation/networking/)

## 快速参考

### 常用命令速查

```bash
# 查看所有网络信息
ip addr show
ip link show
ip route show
ip neigh show

# 配置IP地址
ip addr add 192.168.1.100/24 dev eth0
ip addr del 192.168.1.100/24 dev eth0

# 配置路由
ip route add default via 192.168.1.1
ip route add 192.168.2.0/24 via 192.168.1.1

# 接口管理
ip link set eth0 up
ip link set eth0 down
ip link set eth0 mtu 1500

# ARP管理
ip neigh show
ip neigh add 192.168.1.100 lladdr 00:11:22:33:44:55 dev eth0
ip neigh del 192.168.1.100 dev eth0
```

