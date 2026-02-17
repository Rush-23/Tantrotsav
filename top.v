module top (
    input  wire clk,
    input  wire reset,

    input  wire [7:0] switches,
    input  wire btn_load_x,
    input  wire btn_load_y,
    input  wire btn_start,
    input  wire btn_toggle_k,

    output wire [7:0] leds // Updated to 8 bits for ZedBoard
);
    wire signed [7:0] x_input, y_input;
    wire start;
    wire K_mode;

    // Input Controller: Handles button debouncing and coordinate loading [cite: 93]
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

    wire [1:0] class1, class2, class3, class4, class5;
    wire done;
    wire [5:0]   debug_addr;

    // The Core Distance Engine (Updated for Dual-Port BRAM) 
    // This now processes the dataset in half the cycles
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
        .done(done),
        .debug_addr(debug_addr) // Optional: Connect to LEDs for debugging
    );

    wire [1:0] predicted_class;

    // Voting Logic: Decides the class based on the Top 5 distances [cite: 96]
    voting vote (
        .K_mode(K_mode),
        .class1(class1),
        .class2(class2),
        .class3(class3),
        .class4(class4),
        .class5(class5),
        .predicted_class(predicted_class)
    );

    wire [15:0] latency;
    wire running;

    // Performance Tracking: Measures cycles from Start to Done [cite: 98]
    latency_counter lc (
        .clk(clk),
        .reset(reset),
        .start(start),
        .done(done),
        .latency(latency),
        .running(running)
    );

    // =========================================================
    // ZEDBOARD LED MAPPING
    // =========================================================
    /*assign leds[0]   = predicted_class; // LD0: Result (0=Class A, 1=Class B) [cite: 103]
    assign leds[1]   = K_mode;          // LD1: K-Mode (Off=K3, On=K5) [cite: 104]
    
    // LD7-LD2: Shows the lower bits of the latency counter. 
    // With dual-port, you should see this value drop by ~50%.
    assign leds[7:2] = latency[5:0];    // LD2-LD7: Displays latency bits [cite: 103]*/


/*assign leds[0] = start;
assign leds[1] = running;
assign leds[2] = done;
assign leds[3] = reset;
assign leds[4] = predicted_class;
assign leds[7:5] = debug_addr[2:0];*/

assign leds[1:0] = predicted_class; // LD0-LD1: Result (00=Class A, 01=Class B, 10=Class C, 11=Class D)
assign leds[2]   = K_mode;          // LD2: K-Mode (Off=K3, On=K5) '
assign leds[7:3] = 5'b00000;     // LD3-LD7: Unused (Set to 0)

endmodule