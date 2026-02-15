`timescale 1ns/1ps

module tb;

    // =========================================================
    // 1. TOP LEVEL CONNECTIONS
    // =========================================================
    reg clk;
    reg reset; 
    reg [7:0] switches;
    reg btn_load_x, btn_load_y, btn_start, btn_toggle_k;
    wire [7:0] leds;

    // Decode LED outputs
    wire predicted_class = leds[0];  // 0=Class0, 1=Class1
    wire k_mode_status   = leds[1];  // 0=K3, 1=K5
    wire [5:0] latency   = leds[7:2]; // Latency count

    // =========================================================
    // 2. INSTANTIATE THE SYSTEM
    // =========================================================
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

    // =========================================================
    // 3. SPY SIGNALS (Debugging)
    // =========================================================
    // Peek inside the engine to see when it finishes
    wire spy_done = uut.engine.done;
    wire [5:0] spy_addr = uut.engine.addr; // Verify it goes to 63

    // =========================================================
    // 4. CLOCK GENERATION (100 MHz)
    // =========================================================
    initial begin
        clk = 0;
        forever #5 clk = ~clk; 
    end

    // =========================================================
    // 5. MAIN TEST PROCEDURE
    // =========================================================
    initial begin
        $display("===========================================================");
        $display("   STARTING FINAL SYSTEM VERIFICATION (64 SAMPLES)");
        $display("===========================================================");
        
        // Initialize
        reset = 0; // Active Low Reset asserted
        switches = 0;
        btn_load_x = 0; btn_load_y = 0; btn_start = 0; btn_toggle_k = 0;

        #100;
        reset = 1; // Release Reset
        #20;

        // --------------------------------------------------------
        // TEST CASE 1: TARGET CLASS 1 (1.0, 1.0)
        // Hex: 0x10, 0x10
        // --------------------------------------------------------
        $display("[Time %t] Test Case 1: Input (1.0, 1.0) -> Expect Class 1", $time);
        
        // Load X = 0x10
        switches = 8'h10; 
        btn_load_x = 1; #10; btn_load_x = 0;
        #10;

        // Load Y = 0x10
        switches = 8'h10;
        btn_load_y = 1; #10; btn_load_y = 0;
        #10;

        // Start Inference
        btn_start = 1; #10; btn_start = 0;

        // Wait for Done
        wait(spy_done);
        #50; // Allow voting logic to settle

        // Verify Results
        if (predicted_class == 1) 
            $display("   [PASS] Correctly classified as Class 1.");
        else 
            $display("   [FAIL] Incorrectly classified as Class 0.");

        // Check Latency
        $display("   Latency Count: %d cycles (Expected ~68)", latency);


        // --------------------------------------------------------
        // TEST CASE 2: TARGET CLASS 0 (-1.0, -1.0)
        // Hex: 0xF0, 0xF0
        // --------------------------------------------------------
        #100;
        $display("[Time %t] Test Case 2: Input (-1.0, -1.0) -> Expect Class 0", $time);

        switches = 8'hF0; // Load X
        btn_load_x = 1; #10; btn_load_x = 0;
        #10;

        switches = 8'hF0; // Load Y
        btn_load_y = 1; #10; btn_load_y = 0;
        #10;

        // Toggle to K=5 mode just to test functionality
        btn_toggle_k = 1; #10; btn_toggle_k = 0;
        #10;

        btn_start = 1; #10; btn_start = 0;

        wait(spy_done);
        #50;

        if (predicted_class == 0) 
            $display("   [PASS] Correctly classified as Class 0.");
        else 
            $display("   [FAIL] Incorrectly classified as Class 1.");

        
        // --------------------------------------------------------
        // TEST CASE 3: NOISY INPUT (-1.25, -0.75) -> Expect Class 0
        // Hex: 0xEC, 0xF4
        // --------------------------------------------------------
        #100;
        $display("[Time %t] Test Case 3: Noisy Input (-1.25, -0.75) -> Expect Class 0", $time);

        switches = 8'hEC; // Load X (-1.25)
        btn_load_x = 1; #10; btn_load_x = 0;
        #10;

        switches = 8'hF4; // Load Y (-0.75)
        btn_load_y = 1; #10; btn_load_y = 0;
        #10;

        btn_start = 1; #10; btn_start = 0;

        wait(spy_done);
        #50;

        if (predicted_class == 0) 
            $display("   [PASS] Correctly classified Noisy Input as Class 0.");
        else 
            $display("   [FAIL] Incorrectly classified Noisy Input as Class 1.");


        $display("===========================================================");
        $display("   VERIFICATION COMPLETE");
        $display("===========================================================");
        $finish;
    end

endmodule