module input_file (

    input  wire clk,
    input  wire reset,

    input  wire [7:0] switches,
    input  wire btn_load_x,
    input  wire btn_load_y,
    input  wire btn_start,
    input  wire btn_toggle_k,

    output reg  signed [7:0] x_input,
    output reg  signed [7:0] y_input,
    output reg  start,
    output reg  K_mode
);

    always @(posedge clk or negedge reset) begin
        if (!reset) begin
            x_input <= 0;
            y_input <= 0;
            start   <= 0;
            K_mode  <= 0;
        end
        else begin
            start <= 0;  // default

            if (btn_load_x)
                x_input <= switches;

            if (btn_load_y)
                y_input <= switches;

            if (btn_start)
                start <= 1;

            if (btn_toggle_k)
                K_mode <= ~K_mode;
        end
    end

endmodule
