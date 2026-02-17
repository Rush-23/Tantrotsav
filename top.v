module top (
    input  wire clk,
    input  wire reset,

    input  wire [7:0] switches,
    input  wire btn_load_x,
    input  wire btn_load_y,
    input  wire btn_start,
    input  wire btn_toggle_k,

    output wire [7:0] leds // Reverted to 8 bits for ZedBoard
);
    wire signed [7:0] x_input, y_input;
    wire start;
    wire K_mode;

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

    wire class1, class2, class3, class4, class5, done;

    distance_engine_top engine (
        .clk(clk), .reset(reset), .start(start),
        .x_input(x_input), .y_input(y_input),
        .class1(class1), .class2(class2), .class3(class3),
        .class4(class4), .class5(class5), .done(done)
    );

    wire predicted_class;
    voting vote (
        .K_mode(K_mode), .class1(class1), .class2(class2), 
        .class3(class3), .class4(class4), .class5(class5),
        .predicted_class(predicted_class)
    );

    wire [15:0] latency;
    wire running;
    latency_counter lc (
        .clk(clk), .reset(reset), .start(start),
        .done(done), .latency(latency), .running(running)
    );

    // ZedBoard LED Mapping
    assign leds[0]   = predicted_class; // LD0: Result
    assign leds[1]   = K_mode;          // LD1: K-Value (OFF=3, ON=5)
    assign leds[7:2] = latency[6:1];    // LD2-LD7: Latency (divided by 2)
endmodule