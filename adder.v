module adder (
    input wire clk,
    input wire rst,

    input wire signed [17:0] dx_sq,
    input wire signed [17:0] dy_sq,

    output reg signed [18:0] distance
);

    always @ (posedge clk or negedge rst) begin
        if(!rst) begin
            distance <= 0;
        end else begin
            distance <= dx_sq + dy_sq; // Sum of squares 
        end
    end

endmodule   


