module k_sel (

    input  wire clk,
    input  wire reset,
    input  wire valid,

    input  wire [18:0] distance,
    input  wire        class_in,

    output reg         class1,
    output reg         class2,
    output reg         class3,
    output reg         class4,
    output reg         class5
);

    reg [18:0] min1, min2, min3, min4, min5;

    localparam MAX_DIST = 19'h7FFFF;

    always @(posedge clk or negedge reset) begin
        if (!reset) begin
            min1 <= MAX_DIST;
            min2 <= MAX_DIST;
            min3 <= MAX_DIST;
            min4 <= MAX_DIST;
            min5 <= MAX_DIST;

            class1 <= 0;
            class2 <= 0;
            class3 <= 0;
            class4 <= 0;
            class5 <= 0;
        end
        else if (valid) begin

            if (distance < min1) begin
                min5 <= min4; class5 <= class4;
                min4 <= min3; class4 <= class3;
                min3 <= min2; class3 <= class2;
                min2 <= min1; class2 <= class1;
                min1 <= distance; class1 <= class_in;
            end

            else if (distance < min2) begin
                min5 <= min4; class5 <= class4;
                min4 <= min3; class4 <= class3;
                min3 <= min2; class3 <= class2;
                min2 <= distance; class2 <= class_in;
            end

            else if (distance < min3) begin
                min5 <= min4; class5 <= class4;
                min4 <= min3; class4 <= class3;
                min3 <= distance; class3 <= class_in;
            end

            else if (distance < min4) begin
                min5 <= min4; class5 <= class4;
                min4 <= distance; class4 <= class_in;
            end

            else if (distance < min5) begin
                min5 <= distance;
                class5 <= class_in;
            end
        end
    end

endmodule
