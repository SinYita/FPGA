`timescale 1ns / 1ps

module tb_lab1_top();

    reg clk;
    reg rst_n;
    reg btn;
    wire [3:0] leds;

    // 实例化顶层模块
    lab1_top uut (
        .clk(clk),
        .rst_n(rst_n),
        .btn(btn),
        .leds(leds)
    );

    // 125MHz 时钟 (周期 8ns)
    always #4 clk = ~clk;

    initial begin
        // 初始化
        clk = 0;
        rst_n = 0;
        btn = 0;
        #100 rst_n = 1; // 释放复位

        // --- 模拟第一次按键按下 (切换到模式 01: 全亮) ---
        #100 btn = 1; #10 btn = 0; #10 btn = 1; // 模拟抖动
        #20000000; // 等待去抖动完成 (注意：仿真时建议把代码里的 DEBOUNCE_MS 改小，否则要跑很久)
        
        // --- 模拟第二次按键按下 (切换到模式 10: 闪烁) ---
        #1000 btn = 1;
        #20000000;
        btn = 0;

        #1000000;
        $display("Checking LEDs: %b", leds);
        $stop;
    end

endmodule