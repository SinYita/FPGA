# FPGA Lab 10: LED Bouncing Pattern

## 📋 项目概述

本项目实现了 FPGA 上的 LED 跑马灯控制系统，支持两种模式和两种速度。

### 功能特性

- **Mode A (弹跳模式)**: LED0 → LED1 → LED2 → LED3 → LED2 → LED1 → LED0 → ... (往返)
- **Mode B (循环模式)**: LED0 → LED1 → LED2 → LED3 → LED0 → ... (单向循环)
- **速度控制**: 
  - Speed 1: 1秒间隔
  - Speed 2: 3秒间隔
- **按钮控制**:
  - BTN0: 切换模式 (Mode A ↔ Mode B)
  - BTN1: 切换速度 (1s ↔ 3s)

### 设计约束
- 每次只有一个 LED 点亮
- 时钟频率: 125 MHz
- 按钮去抖动: 10ms

## 📁 文件结构

```
FPGA/
├── led_top.v              # 顶层模块 (FSM状态机)
├── debuncer.v             # 去抖动模块
├── led_top_tb.v           # 仿真测试台
├── debuncer_tb.v          # 去抖动测试台
├── lab10_constraints.xdc  # FPGA约束文件
├── VERIFICATION_REPORT.md # 验证报告
└── README.md              # 本文件
```

## 🔧 使用方法

### 1. 仿真测试

```bash
# 编译 Verilog 文件
iverilog -o sim.vvp debuncer.v led_top.v led_top_tb.v

# 运行仿真
vvp sim.vvp
```

### 2. 硬件烧录

**重要**: 烧录前需修改 `led_top.v` 中的计时参数：

```verilog
// 硬件版本 - 取消注释
localparam ONE_SECOND = 125_000_000 - 1;
localparam THREE_SECOND = 375_000_000 - 1;

// 仿真版本 - 注释掉
// localparam ONE_SECOND = 125_000 - 1;
// localparam THREE_SECOND = 375_000 - 1;
```

然后在 Vivado 中：
1. 创建新工程
2. 添加源文件: `led_top.v`, `debuncer.v`
3. 添加约束: `lab10_constraints.xdc`
4. 综合、实现、生成比特流
5. 烧录到板卡

## 🎯 设计亮点

### FSM 状态机
采用 Moore 型状态机，6个状态表示不同的 LED 位置：
- **S0**: LED0
- **S1**: LED1
- **S2**: LED2
- **S3**: LED3
- **S4**: LED2 (Mode A 回程)
- **S5**: LED1 (Mode A 回程)

### 去抖动模块
- 双寄存器同步 (防止亚稳态)
- 10ms 稳定时间检测
- 上升沿检测 (单周期脉冲输出)

### 精确计时
- 基于 125 MHz 时钟
- 1秒 = 125,000,000 周期
- 3秒 = 375,000,000 周期

## ✅ 验证状态

所有测试已通过，详见 [VERIFICATION_REPORT.md](VERIFICATION_REPORT.md)

## 📝 实验要求

本项目完全符合 Lab 10 要求：
- ✅ 两种模式 (Mode A/B)
- ✅ 两种速度 (1s/3s)
- ✅ 按钮去抖动
- ✅ 单LED约束
- ✅ FSM 设计
- ✅ 仿真验证

## 🎓 作者

TUM - Chair of Computer Architecture and Operating Systems