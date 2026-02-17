module top (
    input  wire clk,
    input  wire reset,

    input  wire [7:0] switches,
    input  wire btn_load_x,
    input  wire btn_load_y,
    input  wire btn_start,
    input  wire btn_toggle_k,

    output wire [7:0] leds
);

    wire signed [7:0] x_input, y_input;
    wire start;
    wire K_mode;

    // Input Controller
    input_file ic (
        .clk(clk),
        .reset(reset),
        .switches(switches),
        .btn_load_x(btn_load_x),
        .btn_load_y(btn_load_y),
        .btn_start(btn_start),
        .btn_toggle_k(btn_toggle_k),
        .x_input(x_input),
        .y_input(y_input),
        .start(start),
        .K_mode(K_mode)
    );

    wire class1, class2, class3, class4, class5;
    wire done;

    // The Core Distance Engine
    distance_engine_top engine (
        .clk(clk),
        .reset(reset),
        .start(start),
        .x_input(x_input),
        .y_input(y_input),
        .class1(class1),
        .class2(class2),
        .class3(class3),
        .class4(class4),
        .class5(class5),
        .done(done)
    );

    wire predicted_class;

    // Voting Logic
    voting vote (
        .K_mode(K_mode),
        .class1(class1),
        .class2(class2),
        .class3(class3),
        .class4(class4),
        .class5(class5),
        .predicted_class(predicted_class)
    );

    // Latency Counter (Kept internal, disconnected from LEDs)
    wire [15:0] latency;
    wire running;

    latency_counter lc (
        .clk(clk),
        .reset(reset),
        .start(start),
        .done(done),
        .latency(latency),
        .running(running)
    );

    // =========================================================
    // FINAL LED MAPPING (CLEAN MODE)
    // =========================================================
    // LED 0: The Result (0 = Class A, 1 = Class B)
    // LED 7-1: Forced OFF (No flickering debug data)
    // =========================================================
    
    
    /*assign leds[0]   = predicted_class; 
    assign leds[7:1] = 7'b0000000; */

    // =========================================================
    // LED MAPPING (Debug Mode)
    // =========================================================
    
    // LED 0: The Prediction (Class 0 or Class 1)
    //assign leds[0] = predicted_class; 

    // LED 1: The K-Mode (Just to verify button works)
    //assign leds[1] = K_mode;

    // LED 7-2: The Latency Counter (Bits 6 down to 1)
    // We shift by 1 bit (divide by 2) to fit "68" into 6 LEDs without wrapping.
    //assign leds[7:2] = latency[6:1];

    assign leds[0] = predicted_class; // LD0: Result
    assign leds[1] = K_mode;          // LD1: K-Mode (Off=K3, On=K5)
    assign leds[2] = done;            // LD2: Pulse when finished
    assign leds[3] = running;

endmodule