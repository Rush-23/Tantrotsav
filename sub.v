module sub (

    input  wire clk,
    input  wire rst,

    // Input feature vector (from switches/registers)
    input  wire signed [7:0] x_input,
    input  wire signed [7:0] y_input,

    // Training sample (from BRAM)
    input  wire signed [7:0] x_train,
    input  wire signed [7:0] y_train,

    // Outputs to next pipeline stage
    output reg  signed [8:0] dx,
    output reg  signed [8:0] dy
);

    // Pipeline register stage
    always @(posedge clk or negedge rst) begin
        if (!rst) begin
            dx <= 0;
            dy <= 0;
        end else begin
            dx <= x_input - x_train;
            dy <= y_input - y_train;
        end
    end

endmodule
