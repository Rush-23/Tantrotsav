module voting (

    input  wire        K_mode,   // 0 = K3, 1 = K5
    input  wire        class1,
    input  wire        class2,
    input  wire        class3,
    input  wire        class4,
    input  wire        class5,

    output reg         predicted_class
);

    integer sum;

    always @(*) begin
        if (K_mode == 1'b0) begin
            // K = 3
            sum = class1 + class2 + class3;
            predicted_class = (sum >= 2);
        end
        else begin
            // K = 5
            sum = class1 + class2 + class3 + class4 + class5;
            predicted_class = (sum >= 3);
        end
    end

endmodule
