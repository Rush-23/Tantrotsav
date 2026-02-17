module k_sel (
    input  wire clk,
    input  wire reset,
    input  wire valid,

    input  wire [18:0] dist_a,
    input  wire [18:0] dist_b,
    input  wire        class_a,
    input  wire        class_b,

    output reg         class1,
    output reg         class2,
    output reg         class3,
    output reg         class4,
    output reg         class5
);

    // Top-5 minimum distances
    reg [18:0] m1, m2, m3, m4, m5;
    localparam MAX = 19'h7FFFF;

    // temp registers for insertion pipeline
    reg [18:0] t1, t2, t3, t4, t5;
    reg tc1, tc2, tc3, tc4, tc5;

    always @(posedge clk) begin
        if (reset) begin
            m1 <= MAX; m2 <= MAX; m3 <= MAX; m4 <= MAX; m5 <= MAX;
            class1 <= 0; class2 <= 0; class3 <= 0; class4 <= 0; class5 <= 0;
        end
        else if (valid) begin

            // -------------------------------------------------
            // STEP-1 : Insert dist_a into sorted list
            // -------------------------------------------------
            if (dist_a < m1) begin
                t1 <= dist_a; t2 <= m1;    t3 <= m2;    t4 <= m3;    t5 <= m4;
                tc1 <= class_a; tc2 <= class1; tc3 <= class2; tc4 <= class3; tc5 <= class4;
            end
            else if (dist_a < m2) begin
                t1 <= m1;    t2 <= dist_a; t3 <= m2;    t4 <= m3;    t5 <= m4;
                tc1 <= class1; tc2 <= class_a; tc3 <= class2; tc4 <= class3; tc5 <= class4;
            end
            else if (dist_a < m3) begin
                t1 <= m1;    t2 <= m2;    t3 <= dist_a; t4 <= m3;    t5 <= m4;
                tc1 <= class1; tc2 <= class2; tc3 <= class_a; tc4 <= class3; tc5 <= class4;
            end
            else if (dist_a < m4) begin
                t1 <= m1;    t2 <= m2;    t3 <= m3;    t4 <= dist_a; t5 <= m4;
                tc1 <= class1; tc2 <= class2; tc3 <= class3; tc4 <= class_a; tc5 <= class4;
            end
            else if (dist_a < m5) begin
                t1 <= m1;    t2 <= m2;    t3 <= m3;    t4 <= m4;    t5 <= dist_a;
                tc1 <= class1; tc2 <= class2; tc3 <= class3; tc4 <= class4; tc5 <= class_a;
            end
            else begin
                t1 <= m1; t2 <= m2; t3 <= m3; t4 <= m4; t5 <= m5;
                tc1 <= class1; tc2 <= class2; tc3 <= class3; tc4 <= class4; tc5 <= class5;
            end

            // -------------------------------------------------
            // STEP-2 : Insert dist_b into result of STEP-1
            // -------------------------------------------------
            if (dist_b < t1) begin
                m1 <= dist_b; m2 <= t1; m3 <= t2; m4 <= t3; m5 <= t4;
                class1 <= class_b; class2 <= tc1; class3 <= tc2; class4 <= tc3; class5 <= tc4;
            end
            else if (dist_b < t2) begin
                m1 <= t1; m2 <= dist_b; m3 <= t2; m4 <= t3; m5 <= t4;
                class1 <= tc1; class2 <= class_b; class3 <= tc2; class4 <= tc3; class5 <= tc4;
            end
            else if (dist_b < t3) begin
                m1 <= t1; m2 <= t2; m3 <= dist_b; m4 <= t3; m5 <= t4;
                class1 <= tc1; class2 <= tc2; class3 <= class_b; class4 <= tc3; class5 <= tc4;
            end
            else if (dist_b < t4) begin
                m1 <= t1; m2 <= t2; m3 <= t3; m4 <= dist_b; m5 <= t4;
                class1 <= tc1; class2 <= tc2; class3 <= tc3; class4 <= class_b; class5 <= tc4;
            end
            else if (dist_b < t5) begin
                m1 <= t1; m2 <= t2; m3 <= t3; m4 <= t4; m5 <= dist_b;
                class1 <= tc1; class2 <= tc2; class3 <= tc3; class4 <= tc4; class5 <= class_b;
            end
            else begin
                m1 <= t1; m2 <= t2; m3 <= t3; m4 <= t4; m5 <= t5;
                class1 <= tc1; class2 <= tc2; class3 <= tc3; class4 <= tc4; class5 <= tc5;
            end
        end
    end

endmodule
