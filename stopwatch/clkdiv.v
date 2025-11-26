module clkdiv(
    input clk,           // 100MHz input clock
    input rst,           // Reset signal
    output reg clk_100hz, // 100Hz for timing (0.01s resolution)
    output reg clk_200hz  // ~200Hz for display scan and debounce
);

    // For 100Hz: 100MHz / 100Hz = 1,000,000 cycles per period
    // Toggle at 500,000 cycles
    reg [19:0] cnt_100hz;
    
    // For 200Hz: 100MHz / 200Hz = 500,000 cycles per period
    // Toggle at 250,000 cycles
    reg [18:0] cnt_200hz;

    // 100Hz clock generation
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            cnt_100hz <= 20'd0;
            clk_100hz <= 1'b0;
        end
        else if (cnt_100hz >= 20'd499999) begin
            cnt_100hz <= 20'd0;
            clk_100hz <= ~clk_100hz;
        end
        else begin
            cnt_100hz <= cnt_100hz + 1'b1;
        end
    end

    // 200Hz clock generation
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            cnt_200hz <= 19'd0;
            clk_200hz <= 1'b0;
        end
        else if (cnt_200hz >= 19'd249999) begin
            cnt_200hz <= 19'd0;
            clk_200hz <= ~clk_200hz;
        end
        else begin
            cnt_200hz <= cnt_200hz + 1'b1;
        end
    end

endmodule
