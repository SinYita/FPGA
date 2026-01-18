`timescale 1ns / 1ps

module tb_lab1();

    reg clk;
    reg rst;
    reg btn_in;
    wire btn_pulse;

    // 实例化被测模块
    // 为了缩短仿真时间，我们将 DEBOUNCE_MS 设小一点（例如 0.001ms 或减小计数阈值）
    // 否则仿真 10ms 需要很久
    debouncer_edge_det #(
        .CLK_HZ(1000000), // 模拟 1MHz 时钟
        .DEBOUNCE_MS(1)   // 1ms 阈值
    ) dut (
        .clk(clk),
        .rst(rst),
        .btn_in(btn_in),
        .btn_pulse(btn_pulse)
    );

    // 生成时钟 (125MHz 大约是 8ns 周期)
    always #4 clk = ~clk;

    initial begin
        // 初始化
        clk = 0;
        rst = 1;
        btn_in = 0;
        #100;
        rst = 0;
        
        // 模拟按键按下时的抖动 (Bouncing)
        #50  btn_in = 1; #20  btn_in = 0;
        #30  btn_in = 1; #10  btn_in = 0;
        #40  btn_in = 1; // 最终稳定在 1
        
        // 等待足够长的时间让去抖动计数器溢出
        // 阈值是 1000 个时钟周期，约 8000ns
        #15000; 
        
        // 模拟按键松开
        btn_in = 0;
        #10000;
        
        $display("Simulation Finished");
        $stop;
    end

endmodule