module voting (
    input  wire        K_mode,
    input  wire [1:0]  class1,
    input  wire [1:0]  class2,
    input  wire [1:0]  class3,
    input  wire [1:0]  class4,
    input  wire [1:0]  class5,

    output reg  [1:0]  predicted_class
);

    reg [2:0] c0,c1,c2,c3;

    always @(*) begin

        c0 = 0; c1 = 0; c2 = 0; c3 = 0;

        // K = 3 votes
        case(class1)
            2'd0: c0 = c0 + 1;
            2'd1: c1 = c1 + 1;
            2'd2: c2 = c2 + 1;
            2'd3: c3 = c3 + 1;
        endcase

        case(class2)
            2'd0: c0 = c0 + 1;
            2'd1: c1 = c1 + 1;
            2'd2: c2 = c2 + 1;
            2'd3: c3 = c3 + 1;
        endcase

        case(class3)
            2'd0: c0 = c0 + 1;
            2'd1: c1 = c1 + 1;
            2'd2: c2 = c2 + 1;
            2'd3: c3 = c3 + 1;
        endcase

        // K = 5 mode
        if(K_mode) begin

            case(class4)
                2'd0: c0 = c0 + 1;
                2'd1: c1 = c1 + 1;
                2'd2: c2 = c2 + 1;
                2'd3: c3 = c3 + 1;
            endcase

            case(class5)
                2'd0: c0 = c0 + 1;
                2'd1: c1 = c1 + 1;
                2'd2: c2 = c2 + 1;
                2'd3: c3 = c3 + 1;
            endcase
        end

        // Argmax
        predicted_class = 2'd0;

        

        if (c1 > c0 && c1 >= c2 && c1 >= c3)
            predicted_class = 2'd1;
        else if (c2 > c0 && c2 > c1 && c2 >= c3)
            predicted_class = 2'd2;
        else if (c3 > c0 && c3 > c1 && c3 > c2)
            predicted_class = 2'd3;
    end

endmodule
