module multiplier (

    input  wire clk,
    input  wire rst,

    // Inputs from subtraction stage
    input  wire signed [8:0] dx,
    input  wire signed [8:0] dy,

    // Outputs to next pipeline stage
    output reg  signed [17:0] dx_sq,
    output reg  signed [17:0] dy_sq
);

    // Pipeline register stage
    always @(posedge clk) begin
        if (rst) begin
            dx_sq <= 0;
            dy_sq <= 0;
        end else begin
            dx_sq <= dx * dx; // Square of dx
            dy_sq <= dy * dy; // Square of dy
        end
    end
endmodule
