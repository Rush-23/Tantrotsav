`timescale 1ns/1ps

module tb;
    reg clk;
    reg reset; 
    reg [7:0] switches;
    reg btn_load_x, btn_load_y, btn_start, btn_toggle_k;
    wire [7:0] leds;

    // Decode LED outputs
    wire predicted_class = leds[0];  
    wire k_mode_status   = leds[1];  
    wire [5:0] latency   = leds[7:2]; 

    // Instantiate System
    top uut (
        .clk(clk),
        .reset(reset),
        .switches(switches),
        .btn_load_x(btn_load_x),
        .btn_load_y(btn_load_y),
        .btn_start(btn_start),
        .btn_toggle_k(btn_toggle_k),
        .leds(leds)
    );

    // Spy Signals for verification
    wire spy_done = uut.engine.done;
    wire [5:0] spy_addr = uut.engine.addr;

    // Clock Generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk; 
    end

    initial begin
        $display("===========================================================");
        $display("   STARTING MULTI-MODE K-NN VERIFICATION");
        $display("===========================================================");
        
        // Initialize
        reset = 0; 
        switches = 0;
        btn_load_x = 0; btn_load_y = 0; btn_start = 0; btn_toggle_k = 0;
        #100;
        reset = 1; 
        #50;

        // --------------------------------------------------------
        // TEST CASE 1: INPUT CLOSE TO CLASS 1, K=3
        // --------------------------------------------------------
        $display("[Time %t] Case 1: Input (1.1, 0.9), K=3 -> Expect Class 1", $time);
        switches = 8'h12; btn_load_x = 1; #20; btn_load_x = 0; #20;
        switches = 8'h0F; btn_load_y = 1; #20; btn_load_y = 0; #20;
        
        btn_start = 1; #20; btn_start = 0; // Trigger pulse
        wait(spy_done);
        #100;
        $display("   Result: Class %b, Latency: %d", predicted_class, latency);


        // --------------------------------------------------------
        // TEST CASE 2: SAME INPUT, TOGGLE TO K=5
        // --------------------------------------------------------
        $display("[Time %t] Case 2: Same Input, Toggling to K=5", $time);
        btn_toggle_k = 1; #20; btn_toggle_k = 0; #100;
        
        btn_start = 1; 
        // FIX: Wait for the hardware to recognize 'start' and pull 'done' to 0
        wait(uut.engine.done == 0); 
        #20; 
        btn_start = 0;
        
        // Now it is safe to wait for the actual completion
        wait(uut.engine.done == 1);
        #100;
        $display("   Result: Class %b", predicted_class);
        // --------------------------------------------------------
        // TEST CASE 3: INPUT FAR FROM CLASS 1, K=3
        // --------------------------------------------------------
        $display("[Time %t] Case 3: Input (-1.0, -1.0), K=3 -> Expect Class 0", $time);
        switches = 8'hF0; btn_load_x = 1; #20; btn_load_x = 0; #20;
        switches = 8'hF0; btn_load_y = 1; #20; btn_load_y = 0; #20;
        
        // Toggle back to K=3
        btn_toggle_k = 1; #20; btn_toggle_k = 0; #20;

        btn_start = 1; #20; btn_start = 0;
        wait(spy_done);
        #100;
        $display("   Result: Class %b", predicted_class);

        $display("===========================================================");
        $display("   VERIFICATION COMPLETE");
        $display("===========================================================");
        $finish;
    end
endmodule