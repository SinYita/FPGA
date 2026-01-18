// 模块目标：物理按键输入 -> 10ms去抖动 -> 生成一个时钟周期的脉冲
module debouncer_edge_det #(
    parameter CLK_HZ = 125_000_000,
    parameter DEBOUNCE_MS = 10
)(
    input  wire clk,
    input  wire rst,
    input  wire btn_in,     // 物理按键输入
    output reg  btn_pulse   // 输出一个周期的脉冲
);

    // 计算 10ms 需要的计数次数：125,000,000 * 0.01 = 1,250,000
    localparam integer THRESHOLD = (CLK_HZ / 1000) * DEBOUNCE_MS;
    
    reg [20:0] count;       // 21位宽足以容纳 1,250,000
    reg btn_sync_0, btn_sync_1; // 同步寄存器，防止亚稳态
    reg btn_stable;         // 稳定后的电平状态
    reg btn_stable_prev;    // 用于边缘检测的上一个稳定状态

    // 1. 同步输入信号（跨时钟域处理的基础）
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            btn_sync_0 <= 0;
            btn_sync_1 <= 0;
        end else begin
            btn_sync_0 <= btn_in;
            btn_sync_1 <= btn_sync_0;
        end
    end

    // 2. 去抖动逻辑：只有当电平持续稳定 THRESHOLD 次时才更新 btn_stable
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            count <= 0;
            btn_stable <= 0;
        end else begin
            if (btn_sync_1 != btn_stable) begin
                if (count >= THRESHOLD) begin
                    btn_stable <= btn_sync_1;
                    count <= 0;
                end else begin
                    count <= count + 1;
                end
            end else begin
                count <= 0;
            end
        end
    end

    // 3. 上升沿检测：当 stable 从 0 变到 1 的那一刻，输出一个高电平脉冲
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            btn_stable_prev <= 0;
            btn_pulse <= 0;
        end else begin
            btn_stable_prev <= btn_stable;
            // 如果上个时刻是0，当前时刻是1，则产生一个周期脉冲
            btn_pulse <= btn_stable && !btn_stable_prev;
        end
    end

endmodule