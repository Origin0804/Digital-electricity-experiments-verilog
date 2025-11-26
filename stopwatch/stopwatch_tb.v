`timescale 1ns/1ps

module stopwatch_tb;

    // Inputs
    reg clk;
    reg rst;
    reg start;
    reg stop;
    reg set_min;
    reg set_hour;
    reg countdown_sw;
    
    // Outputs
    wire [3:0] wei;
    wire [7:0] duan;
    wire [7:0] duan1;
    
    // Instantiate the Unit Under Test (UUT)
    top uut (
        .clk(clk),
        .rst(rst),
        .start(start),
        .stop(stop),
        .set_min(set_min),
        .set_hour(set_hour),
        .countdown_sw(countdown_sw),
        .wei(wei),
        .duan(duan),
        .duan1(duan1)
    );
    
    // Clock generation - 100MHz (10ns period)
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end
    
    // Test sequence
    initial begin
        // Initialize inputs
        rst = 0;
        start = 0;
        stop = 0;
        set_min = 0;
        set_hour = 0;
        countdown_sw = 0;
        
        // Wait for global reset
        #100;
        
        // Test 1: Reset
        $display("Test 1: Reset");
        rst = 1;
        #50_000; // Wait for debounce
        rst = 0;
        #50_000;
        
        // Test 2: Start the stopwatch
        $display("Test 2: Start stopwatch");
        start = 1;
        #50_000;
        start = 0;
        
        // Let it run for a bit
        #100_000_000; // 100ms in simulation time
        
        // Test 3: Stop the stopwatch
        $display("Test 3: Stop stopwatch");
        stop = 1;
        #50_000;
        stop = 0;
        #50_000;
        
        // Test 4: Resume
        $display("Test 4: Resume stopwatch");
        start = 1;
        #50_000;
        start = 0;
        #50_000_000; // 50ms more
        
        // Test 5: Switch to countdown mode
        $display("Test 5: Switch to countdown mode");
        countdown_sw = 1;
        #50_000;
        
        // Test 6: Increment minutes
        $display("Test 6: Increment minutes");
        set_min = 1;
        #50_000;
        set_min = 0;
        #50_000;
        
        set_min = 1;
        #50_000;
        set_min = 0;
        #50_000;
        
        // Test 7: Increment hours
        $display("Test 7: Increment hours");
        set_hour = 1;
        #50_000;
        set_hour = 0;
        #50_000;
        
        // Test 8: Start countdown
        $display("Test 8: Start countdown");
        start = 1;
        #50_000;
        start = 0;
        #100_000_000; // 100ms
        
        // Test 9: Stop countdown
        $display("Test 9: Stop countdown");
        stop = 1;
        #50_000;
        stop = 0;
        
        #100_000;
        
        $display("All tests completed");
        $finish;
    end
    
    // Monitor key signals
    initial begin
        $monitor("Time=%0t rst=%b start=%b stop=%b countdown=%b wei=%b", 
                 $time, rst, start, stop, countdown_sw, wei);
    end

endmodule
