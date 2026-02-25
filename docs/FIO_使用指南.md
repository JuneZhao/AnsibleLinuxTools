# FIO 磁盘性能压测工具使用指南

FIO (Flexible I/O Tester) 是一个强大的磁盘I/O性能测试工具，支持多种I/O引擎和测试模式。

## 目录

- [基本概念](#基本概念)
- [安装验证](#安装验证)
- [基本语法](#基本语法)
- [测试场景](#测试场景)
  - [顺序读写](#顺序读写)
  - [随机读写](#随机读写)
  - [混合读写](#混合读写)
  - [全盘测试](#全盘测试)
  - [多线程测试](#多线程测试)
- [常用参数详解](#常用参数详解)
- [实际应用场景](#实际应用场景)
- [性能分析](#性能分析)
- [注意事项](#注意事项)

## 基本概念

### I/O类型
- **顺序读写 (Sequential)**: 按顺序访问磁盘块，适合大文件传输
- **随机读写 (Random)**: 随机访问磁盘块，模拟数据库、文件系统元数据操作
- **混合读写 (Mixed)**: 同时进行读写操作，模拟实际应用场景

### I/O引擎
- **libaio**: Linux异步I/O，性能最好
- **sync**: 同步I/O，最稳定
- **psync**: 预读同步I/O
- **mmap**: 内存映射I/O

## 安装验证

```bash
# 检查FIO是否已安装
fio --version

# 查看帮助信息
fio --help

# 查看支持的I/O引擎
fio --enghelp
```

## 基本语法

```bash
fio [选项] [作业文件]
```

### 命令行模式
```bash
fio --name=test --filename=/tmp/testfile --size=1G --rw=read --bs=4k
```

### 配置文件模式（推荐）
```bash
fio config.ini
```

## 测试场景

### 顺序读写

#### 顺序读测试
```ini
[sequential-read]
name=顺序读测试
filename=/dev/sdb
direct=1
rw=read
bs=1M
size=10G
runtime=60
ioengine=libaio
iodepth=32
numjobs=1
group_reporting=1
```

**命令行方式：**
```bash
fio --name=sequential-read \
    --filename=/dev/sdb \
    --direct=1 \
    --rw=read \
    --bs=1M \
    --size=10G \
    --runtime=60 \
    --ioengine=libaio \
    --iodepth=32 \
    --numjobs=1 \
    --group_reporting=1
```

#### 顺序写测试
```ini
[sequential-write]
name=顺序写测试
filename=/dev/sdb
direct=1
rw=write
bs=1M
size=10G
runtime=60
ioengine=libaio
iodepth=32
numjobs=1
group_reporting=1
```

**命令行方式：**
```bash
fio --name=sequential-write \
    --filename=/dev/sdb \
    --direct=1 \
    --rw=write \
    --bs=1M \
    --size=10G \
    --runtime=60 \
    --ioengine=libaio \
    --iodepth=32 \
    --numjobs=1 \
    --group_reporting=1
```

### 随机读写

#### 随机读测试
```ini
[random-read]
name=随机读测试
filename=/dev/sdb
direct=1
rw=randread
bs=4k
size=10G
runtime=60
ioengine=libaio
iodepth=32
numjobs=4
group_reporting=1
```

**命令行方式：**
```bash
fio --name=random-read \
    --filename=/dev/sdb \
    --direct=1 \
    --rw=randread \
    --bs=4k \
    --size=10G \
    --runtime=60 \
    --ioengine=libaio \
    --iodepth=32 \
    --numjobs=4 \
    --group_reporting=1
```

#### 随机写测试
```ini
[random-write]
name=随机写测试
filename=/dev/sdb
direct=1
rw=randwrite
bs=4k
size=10G
runtime=60
ioengine=libaio
iodepth=32
numjobs=4
group_reporting=1
```

**命令行方式：**
```bash
fio --name=random-write \
    --filename=/dev/sdb \
    --direct=1 \
    --rw=randwrite \
    --bs=4k \
    --size=10G \
    --runtime=60 \
    --ioengine=libaio \
    --iodepth=32 \
    --numjobs=4 \
    --group_reporting=1
```

### 混合读写

#### 70%读 + 30%写
```ini
[mixed-rw]
name=混合读写测试(70%读30%写)
filename=/dev/sdb
direct=1
rw=randrw
rwmixread=70
rwmixwrite=30
bs=4k
size=10G
runtime=60
ioengine=libaio
iodepth=32
numjobs=4
group_reporting=1
```

**命令行方式：**
```bash
fio --name=mixed-rw \
    --filename=/dev/sdb \
    --direct=1 \
    --rw=randrw \
    --rwmixread=70 \
    --rwmixwrite=30 \
    --bs=4k \
    --size=10G \
    --runtime=60 \
    --ioengine=libaio \
    --iodepth=32 \
    --numjobs=4 \
    --group_reporting=1
```

### 全盘测试

#### 全盘顺序写（用于SSD性能测试）
```ini
[full-disk-write]
name=全盘顺序写测试
filename=/dev/sdb
direct=1
rw=write
bs=1M
size=100%
runtime=0
ioengine=libaio
iodepth=32
numjobs=1
group_reporting=1
```

#### 全盘随机写（用于SSD磨损测试）
```ini
[full-disk-randwrite]
name=全盘随机写测试
filename=/dev/sdb
direct=1
rw=randwrite
bs=4k
size=100%
runtime=0
ioengine=libaio
iodepth=32
numjobs=4
group_reporting=1
```

### 多线程测试

#### 多线程顺序读
```ini
[multi-thread-read]
name=多线程顺序读
filename=/dev/sdb
direct=1
rw=read
bs=1M
size=10G
runtime=60
ioengine=libaio
iodepth=32
numjobs=8
group_reporting=1
```

#### 多线程随机读
```ini
[multi-thread-randread]
name=多线程随机读
filename=/dev/sdb
direct=1
rw=randread
bs=4k
size=10G
runtime=60
ioengine=libaio
iodepth=32
numjobs=8
group_reporting=1
```

## 常用参数详解

### 基本参数

| 参数 | 说明 | 示例值 |
|------|------|--------|
| `name` | 作业名称 | `test-job` |
| `filename` | 测试文件或设备 | `/dev/sdb` 或 `/tmp/testfile` |
| `direct` | 直接I/O，绕过页缓存 | `1` (启用) 或 `0` (禁用) |
| `rw` | 读写模式 | `read`, `write`, `randread`, `randwrite`, `randrw` |
| `bs` | 块大小 | `4k`, `8k`, `64k`, `1M` |
| `size` | 测试数据大小 | `10G`, `100%` (全盘) |
| `runtime` | 运行时间（秒） | `60` (60秒) |
| `ioengine` | I/O引擎 | `libaio`, `sync`, `psync`, `mmap` |
| `iodepth` | I/O队列深度 | `1`, `8`, `16`, `32`, `64` |
| `numjobs` | 并发作业数 | `1`, `4`, `8`, `16` |
| `group_reporting` | 合并报告 | `1` (启用) |

### 高级参数

| 参数 | 说明 | 示例值 |
|------|------|--------|
| `rwmixread` | 混合读写中读的比例 | `70` (70%) |
| `rwmixwrite` | 混合读写中写的比例 | `30` (30%) |
| `rate_iops` | 限制IOPS速率 | `1000` |
| `rate_bw` | 限制带宽速率 | `100M` |
| `thinktime` | 思考时间（微秒） | `1000` |
| `ramp_time` | 预热时间（秒） | `10` |
| `time_based` | 基于时间运行 | `1` |
| `loops` | 循环次数 | `3` |
| `verify` | 数据校验 | `md5`, `crc32c` |
| `verify_fatal` | 校验失败时退出 | `1` |
| `stonewall` | 等待所有作业完成 | `1` |

### 文件相关参数

| 参数 | 说明 | 示例值 |
|------|------|--------|
| `directory` | 测试目录 | `/mnt/test` |
| `nrfiles` | 文件数量 | `100` |
| `openfiles` | 同时打开文件数 | `10` |
| `file_service_type` | 文件服务类型 | `random`, `sequential` |

## 实际应用场景

### 场景1: 数据库性能测试（OLTP）

模拟数据库的随机读写场景：

```ini
[oltp-test]
name=OLTP数据库测试
filename=/dev/sdb
direct=1
rw=randrw
rwmixread=70
rwmixwrite=30
bs=8k
size=100G
runtime=300
ioengine=libaio
iodepth=16
numjobs=8
group_reporting=1
ramp_time=30
```

### 场景2: 文件服务器性能测试

模拟文件服务器的顺序读写：

```ini
[file-server-test]
name=文件服务器测试
filename=/dev/sdb
direct=1
rw=read
bs=1M
size=500G
runtime=600
ioengine=libaio
iodepth=32
numjobs=4
group_reporting=1
```

### 场景3: 日志写入性能测试

模拟日志文件的顺序追加写入：

```ini
[log-write-test]
name=日志写入测试
filename=/dev/sdb
direct=1
rw=write
bs=64k
size=50G
runtime=300
ioengine=libaio
iodepth=8
numjobs=1
group_reporting=1
```

### 场景4: 虚拟机存储性能测试

模拟虚拟机的混合I/O负载：

```ini
[vm-storage-test]
name=虚拟机存储测试
filename=/dev/sdb
direct=1
rw=randrw
rwmixread=50
rwmixwrite=50
bs=4k
size=200G
runtime=600
ioengine=libaio
iodepth=32
numjobs=16
group_reporting=1
ramp_time=60
```

### 场景5: SSD性能基准测试

完整的SSD性能测试套件：

```ini
[global]
ioengine=libaio
direct=1
group_reporting=1
time_based=1
runtime=60

[seq-read]
name=顺序读
filename=/dev/sdb
rw=read
bs=1M
iodepth=32
numjobs=1

[seq-write]
name=顺序写
filename=/dev/sdb
rw=write
bs=1M
iodepth=32
numjobs=1

[rand-read]
name=随机读
filename=/dev/sdb
rw=randread
bs=4k
iodepth=32
numjobs=4

[rand-write]
name=随机写
filename=/dev/sdb
rw=randwrite
bs=4k
iodepth=32
numjobs=4

[mixed-rw]
name=混合读写
filename=/dev/sdb
rw=randrw
rwmixread=70
rwmixwrite=30
bs=4k
iodepth=32
numjobs=4
```

## 性能分析

### 关键指标

1. **IOPS (Input/Output Operations Per Second)**
   - 每秒I/O操作数
   - 随机读写性能的重要指标

2. **带宽 (Bandwidth/BW)**
   - 每秒传输的数据量
   - 顺序读写性能的重要指标

3. **延迟 (Latency)**
   - I/O操作的响应时间
   - 包括最小、最大、平均延迟

4. **CPU使用率**
   - I/O操作对CPU的占用

### 输出结果解读

```
Run status group 0 (all jobs):
   READ: bw=512MiB/s (537MB/s), 512MiB/s-512MiB/s, io=30.0GiB (32.2GB), run=60001-60001msec
   WRITE: bw=219MiB/s (230MB/s), 219MiB/s-219MiB/s, io=12.8GiB (13.7GB), run=60001-60001msec

Disk stats (read/write):
  sdb: ios=7680/3280, merge=0/0, ticks=192000/82000, in_queue=274000, util=100.00%
```

**解读：**
- `bw`: 带宽（MiB/s 和 MB/s）
- `io`: 总I/O量
- `run`: 运行时间
- `ios`: I/O操作数
- `util`: 设备利用率（100%表示满载）

## 注意事项

### 安全警告

⚠️ **重要**: 直接测试块设备（如 `/dev/sdb`）会**破坏数据**！

1. **测试前备份数据**
2. **使用测试专用设备或分区**
3. **确认设备路径正确**
4. **使用文件测试更安全**（如 `/tmp/testfile`）

### 性能测试建议

1. **预热时间**: 使用 `ramp_time` 让系统达到稳定状态
2. **测试时长**: 至少运行60秒以上，避免短期波动
3. **多次测试**: 运行多次取平均值
4. **系统负载**: 在空闲系统上测试，避免干扰
5. **直接I/O**: 使用 `direct=1` 绕过缓存，获得真实性能

### 常见问题

**Q: 如何测试文件系统而不是块设备？**
```bash
# 使用文件路径而不是设备路径
filename=/mnt/test/testfile
```

**Q: 如何限制测试速度？**
```ini
rate_iops=1000    # 限制为1000 IOPS
rate_bw=100M      # 限制为100MB/s
```

**Q: 如何测试多个文件？**
```ini
directory=/mnt/test
nrfiles=100
```

**Q: 如何验证数据完整性？**
```ini
verify=md5
verify_fatal=1
```

## 快速参考

### 常用测试命令

```bash
# 快速顺序读测试
fio --name=test --filename=/dev/sdb --direct=1 --rw=read --bs=1M --size=10G --runtime=60

# 快速随机读测试
fio --name=test --filename=/dev/sdb --direct=1 --rw=randread --bs=4k --size=10G --runtime=60

# 快速顺序写测试
fio --name=test --filename=/dev/sdb --direct=1 --rw=write --bs=1M --size=10G --runtime=60

# 快速随机写测试
fio --name=test --filename=/dev/sdb --direct=1 --rw=randwrite --bs=4k --size=10G --runtime=60

# 混合读写测试
fio --name=test --filename=/dev/sdb --direct=1 --rw=randrw --rwmixread=70 --bs=4k --size=10G --runtime=60
```

### 性能基准参考

| 存储类型 | 顺序读 (MB/s) | 顺序写 (MB/s) | 随机读 IOPS | 随机写 IOPS |
|---------|--------------|--------------|------------|------------|
| HDD (7200 RPM) | 100-150 | 100-150 | 100-200 | 100-200 |
| SSD (SATA) | 500-550 | 400-500 | 50K-80K | 30K-50K |
| SSD (NVMe) | 3000-3500 | 2000-3000 | 500K-800K | 200K-400K |

## 参考资源

- [FIO官方文档](https://fio.readthedocs.io/)
- [FIO GitHub](https://github.com/axboe/fio)
- [FIO Wiki](https://github.com/axboe/fio/wiki)


