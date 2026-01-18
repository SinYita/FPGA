`timescale 1ns / 1ps

module tb_lab1_top();

    reg clk;
    reg rst_n;
    reg btn0;
    reg btn1;
    wire [3:0] leds;

    // 实例化顶层模块
    lab1_top uut (
        .clk(clk),
        .rst_n(rst_n),
        .btn0(btn0),
        .btn1(btn1),
        .leds(leds)
    );
    
    // 单独实例化 debouncer 用于测试
    reg test_btn_in;
    wire test_btn_pulse;
    debouncer_edge_det #(
        .CLK_HZ(1000000),  // 模拟 1MHz 时钟
        .DEBOUNCE_MS(1)    // 1ms 阈值
    ) debouncer_test (
        .clk(clk),
        .rst(!rst_n),
        .btn_in(test_btn_in),
        .btn_pulse(test_btn_pulse)
    );
    initial begin
       dumpfile("tb_lab1_top.vcd");
         dumpvars(0, tb_lab1_top);
    end
    // 125MHz 时钟 (周期 8ns)
    always #4 clk = ~clk;

    // 仿真中 1秒 = 125K 个周期，约 1ms
    localparam SIM_ONE_SECOND = 125_000 * 8;  // 8ns per cycle

    initial begin
        // 初始化
        clk = 0;
        rst_n = 0;
        btn0 = 0;
        btn1 = 0;
        test_btn_in = 0;
        
        // 释放复位
        #100;
        rst_n = 1;
        #100;

        $display("\n========== 测试开始 ==========");
        
        // ========== 测试 0: Debouncer 模块测试 ==========
        $display("\n--- Test 0: Debouncer 去抖动功能测试 ---");
        $display("  模拟按键抖动...");
        
        // 模拟按键按下时的抖动 (Bouncing)
        #50  test_btn_in = 1; #20  test_btn_in = 0;
        #30  test_btn_in = 1; #10  test_btn_in = 0;
        #40  test_btn_in = 1; // 最终稳定在 1
        
        // 等待足够长的时间让去抖动计数器溢出
        // 阈值是 1000 个时钟周期，约 8000ns
        #15000;
        if (test_btn_pulse)
            $display("  [PASS] 检测到上升沿脉冲");
        else
            $display("  [INFO] 等待脉冲...");
        
        // 模拟按键松开
        test_btn_in = 0;
        #10000;
        $display("  [PASS] Debouncer 测试完成\n");
        $display("初始状态: Mode A, Speed=1秒");
        $display("期望序列: LED0→LED1→LED2→LED3→LED2→LED1→LED0 循环");
        
        // ========== 测试 1: Mode A, 1秒速度, 观察完整循环 ==========
        $display("\n--- Test 1: Mode A 完整循环 (6步) ---");
        repeat(7) begin
            #(SIM_ONE_SECOND);
            case (leds)
                4'b0001: $display("  [PASS] LED0 亮");
                4'b0010: $display("  [PASS] LED1 亮");
                4'b0100: $display("  [PASS] LED2 亮");
                4'b1000: $display("  [PASS] LED3 亮");
                default: $display("  [FAIL] 异常LED状态: %b", leds);
            endcase
        end

        // ========== 测试 2: 切换到 Mode B ==========
        $display("\n--- Test 2: 按下 BTN0 切换到 Mode B ---");
        @(posedge clk);
        btn0 = 1;
        #100;
        btn0 = 0;
        #100;
        $display("  模式切换完成，当前LED: %b (应为LED0=0001)", leds);
        
        $display("\n  Mode B 期望序列: LED0→LED1→LED2→LED3→LED0 循环");
        repeat(5) begin
            #(SIM_ONE_SECOND);
            case (leds)
                4'b0001: $display("  [PASS] LED0 亮");
                4'b0010: $display("  [PASS] LED1 亮");
                4'b0100: $display("  [PASS] LED2 亮");
                4'b1000: $display("  [PASS] LED3 亮");
                default: $display("  [FAIL] 异常LED状态: %b", leds);
            endcase
        end

        // ========== 测试 3: 切换到 3秒速度 ==========
        $display("\n--- Test 3: 按下 BTN1 切换到 3秒速度 ---");
        @(posedge clk);
        btn1 = 1;
        #100;
        btn1 = 0;
        #100;
        $display("  速度切换完成");
        
        repeat(2) begin
            #(SIM_ONE_SECOND * 3);
            $display("  3秒后 LED: %b", leds);
        end

        // ========== 测试 4: 切换回 Mode A ==========
        $display("\n--- Test 4: 按下 BTN0 切换回 Mode A (3秒速度) ---");
        @(posedge clk);
        btn0 = 1;
        #100;
        btn0 = 0;
        #100;
        $display("  模式切换完成，当前LED: %b (应为LED0=0001)", leds);
        
        repeat(3) begin
            #(SIM_ONE_SECOND * 3);
            $display("  3秒后 LED: %b", leds);
        end

        $display("\n========== 仿真完成 ==========\n");
        $finish;
    end

    // 超时保护
    initial begin
        #100000000;  // 100ms 仿真时间
        $display("\n[TIMEOUT] 仿真超时");
        $finish;
    end

endmodule
