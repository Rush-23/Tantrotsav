`timescale 1ns / 1ps

module tb_1024;

    // =========================================================
    // 1. Inputs & Outputs
    // =========================================================
    reg clk;
    reg reset;
    reg [7:0] switches;
    reg btn_load_x;
    reg btn_load_y;
    reg btn_start;
    reg btn_toggle_k;

    wire [7:0] leds;

    // =========================================================
    // 2. Instantiate Top Module
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
    // 3. Simulation Signals (For Waveform)
    // =========================================================
    wire [1:0] pred_class = leds[1:0]; 
    wire [15:0] latency   = uut.lc.latency;
    wire        is_done   = uut.engine.done;

    // Clock Generation
    always #5 clk = ~clk;

    // =========================================================
    // 4. Hierarchical Signals (FOR LOGGING ONLY)
    // =========================================================
    wire [18:0] t1_d = uut.engine.ksel.m1;
    wire [18:0] t2_d = uut.engine.ksel.m2;
    wire [18:0] t3_d = uut.engine.ksel.m3;
    wire [18:0] t4_d = uut.engine.ksel.m4;
    wire [18:0] t5_d = uut.engine.ksel.m5;
    
    wire [1:0]  t1_c = uut.engine.ksel.class1;
    wire [1:0]  t2_c = uut.engine.ksel.class2;
    wire [1:0]  t3_c = uut.engine.ksel.class3;
    wire [1:0]  t4_c = uut.engine.ksel.class4;
    wire [1:0]  t5_c = uut.engine.ksel.class5;

    // =========================================================
    // 5. Helper Tasks
    // =========================================================
    task load_patient_data;
        input [7:0] age;        
        input [7:0] heart_rate; 
        begin
            $display("\n[TEST START] Loading Patient: Age %d, HR %d", age, heart_rate);
            
            // 1. Load Age (X)
            // UPDATED DELAY: #100 to ensure FPGA captures the button press
            switches = age;
            btn_load_x = 1; #100; btn_load_x = 0; #100;

            // 2. Load HR - 100 (Y)
            switches = heart_rate - 100; 
            btn_load_y = 1; #100; btn_load_y = 0; #100;
            
            switches = 1;
            btn_toggle_k = 1; #100; btn_toggle_k = 0;#100;
        end
    endtask

    task run_inference;
        begin
            // Pulse Start
            btn_start = 1; #100; btn_start = 0;

            // Wait for Done
            wait (uut.engine.running == 1); 
            wait (uut.engine.running == 0); 
            #50; // Wait a bit for signals to settle
            
            log_results();
        end
    endtask

    task log_results;
        begin
            $display("--------------------------------------------------");
            $display(" RESULT: Predicted Class = %d (0=Health, 1=Mild, 2=Mod, 3=Sev)", pred_class);
            $display("--------------------------------------------------");
            $display(" TOP 5 NEIGHBORS (From Engine Internals):");
            $display(" 1. Class %d | Dist: %d", t1_c, t1_d);
            $display(" 2. Class %d | Dist: %d", t2_c, t2_d);
            $display(" 3. Class %d | Dist: %d", t3_c, t3_d);
            $display(" 4. Class %d | Dist: %d", t4_c, t4_d);
            $display(" 5. Class %d | Dist: %d", t5_c, t5_d);
            $display("--------------------------------------------------");
        end
    endtask

    // =========================================================
    // 6. Test Vectors (Single Case)
    // =========================================================
    initial begin
        clk = 0; reset = 1; 
        switches = 0; btn_load_x = 0; btn_load_y = 0; btn_start = 0; btn_toggle_k = 0;
        
        #100; reset = 0; #100;
        $display("--- SIMULATION STARTED (Single Point) ---");

        // ----------------------------------------------------
        // CASE 1: HEALTHY (Class 0)
        // Young (29) with High Heart Rate (180)
        // ----------------------------------------------------
        load_patient_data(8'h3F, 8'h36);
        run_inference();

        $display("--- SIMULATION FINISHED ---");
        $stop;
    end

endmodule