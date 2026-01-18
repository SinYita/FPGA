module lab1_top (
    input  wire        clk,      // 125 MHz
    input  wire        rst_n,    // 低电平复位
    input  wire        btn0,     // BTN0: 切换 Mode A/B
    input  wire        btn1,     // BTN1: 切换速度 1s/3s
    output reg  [3:0]  leds      // 4个板载 LED (一次只有一个亮)
);

    // ============ 状态定义 (FSM) ============
    // 使用独热码定义状态，便于FPGA优化
    localparam [2:0] S0 = 3'b000;  // LED0
    localparam [2:0] S1 = 3'b001;  // LED1
    localparam [2:0] S2 = 3'b010;  // LED2
    localparam [2:0] S3 = 3'b011;  // LED3
    localparam [2:0] S4 = 3'b100;  // LED2 (Mode A 回程)
    localparam [2:0] S5 = 3'b101;  // LED1 (Mode A 回程)
    
    reg [2:0] current_state;
    reg [2:0] next_state;
    
    wire btn0_pulse;
    wire btn1_pulse;
    
    reg mode_a;              // 1=Mode A (弹跳模式), 0=Mode B (循环模式)
    reg speed_fast;          // 1=1秒, 0=3秒
    
    // 秒级计时器
    reg [28:0] tick_counter; // 足以容纳 375_000_000 (3秒 @ 125MHz)
    wire tick;               // 时间到达时产生脉冲
    
    // 硬件参数 (烧录到板子时使用)
    // localparam ONE_SECOND = 125_000_000 - 1;
    // localparam THREE_SECOND = 375_000_000 - 1;
    
    // 仿真参数 (仿真时使用，缩小1000倍)
    localparam ONE_SECOND = 125_000 - 1;
    localparam THREE_SECOND = 375_000 - 1;

    // ============ 1. 实例化两个去抖动和边缘检测模块 ============
    debouncer_edge_det #(
        .CLK_HZ(125_000_000),
        .DEBOUNCE_MS(10)
    ) btn0_inst (
        .clk(clk),
        .rst(!rst_n),
        .btn_in(btn0),
        .btn_pulse(btn0_pulse)
    );

    debouncer_edge_det #(
        .CLK_HZ(125_000_000),
        .DEBOUNCE_MS(10)
    ) btn1_inst (
        .clk(clk),
        .rst(!rst_n),
        .btn_in(btn1),
        .btn_pulse(btn1_pulse)
    );

    // ============ 2. 定时器逻辑 ============
    assign tick = (speed_fast) ? (tick_counter == ONE_SECOND) : (tick_counter == THREE_SECOND);
    
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            tick_counter <= 0;
        end else begin
            if (tick) begin
                tick_counter <= 0;
            end else begin
                tick_counter <= tick_counter + 1;
            end
        end
    end

    // ============ 3. 模式切换逻辑 (BTN0) ============
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            mode_a <= 1'b1;  // 默认 Mode A
        end else if (btn0_pulse) begin
            mode_a <= ~mode_a;  // 切换模式
        end
    end

    // ============ 4. 速度切换逻辑 (BTN1) ============
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            speed_fast <= 1'b1;  // 默认 1秒速度
        end else if (btn1_pulse) begin
            speed_fast <= ~speed_fast;  // 切换速度
        end
    end

    // ============ 5. FSM: 状态寄存器 (时序逻辑) ============
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            current_state <= S0;
        end else if (btn0_pulse) begin
            // 模式切换时，重置到初始状态
            current_state <= S0;
        end else if (tick) begin
            // 时间到达，跳转到下一状态
            current_state <= next_state;
        end
    end

    // ============ 6. FSM: 次态逻辑 (组合逻辑) ============
    always @(*) begin
        if (mode_a) begin
            // Mode A: S0 → S1 → S2 → S3 → S4 → S5 → S0 (弹跳模式)
            case (current_state)
                S0: next_state = S1;
                S1: next_state = S2;
                S2: next_state = S3;
                S3: next_state = S4;
                S4: next_state = S5;
                S5: next_state = S0;
                default: next_state = S0;
            endcase
        end else begin
            // Mode B: S0 → S1 → S2 → S3 → S0 (循环模式)
            case (current_state)
                S0: next_state = S1;
                S1: next_state = S2;
                S2: next_state = S3;
                S3: next_state = S0;
                default: next_state = S0;
            endcase
        end
    end

    // ============ 7. FSM: 输出逻辑 (组合逻辑) ============
    always @(*) begin
        case (current_state)
            S0: leds = 4'b0001;  // LED0
            S1: leds = 4'b0010;  // LED1
            S2: leds = 4'b0100;  // LED2
            S3: leds = 4'b1000;  // LED3
            S4: leds = 4'b0100;  // LED2 (回程)
            S5: leds = 4'b0010;  // LED1 (回程)
            default: leds = 4'b0000;
        endcase
    end

endmodule