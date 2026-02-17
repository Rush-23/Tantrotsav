module distance_engine_top (
    input  wire clk,
    input  wire reset, // Active Low (negedge) 
    input  wire start, 
    input  wire signed [7:0] x_input, 
    input  wire signed [7:0] y_input, 
    output wire [1:0] class1,
    output wire [1:0] class2,
    output wire [1:0] class3,
    output wire [1:0] class4,
    output wire [1:0] class5,
    output reg  done,
    output wire [9:0] debug_addr

);

    // =============================
    // Address Counter (Updated for +2)
    // =============================
    reg [9:0] addr; 
    reg running; 
    assign debug_addr = addr; // Expose address for debugging
    
    // Delayed valid signal to match pipeline depth
    reg valid_s1, valid_s2, valid_s3, valid_s4;

    always @(posedge clk) begin
        if (reset) begin
            addr    <= 0;
            running <= 0;
            done    <= 0;
        end 
        else begin
            if (start) begin
                addr    <= 0;
                running <= 1;
                done    <= 0;
            end
            else if (running) begin
                // Dual-port: increment by 2
                addr <= addr + 2;

                // Stop at 1022 (so next +1 covers 1023)
                // 1024 samples total -> Indices 0 to 1023
                if (addr == 10'd1022) 
                    running <= 0;
            end

            // Completion signal
            done <= (valid_s4 && !running); 
        end
    end

    

    // =============================
    // Dual-Port BRAM
    // =============================
    wire [17:0] bram_data_a, bram_data_b; 

    // Instantiate modular two-port memory
    memory bram_inst (
        .clk(clk),
        .addr_a(addr),         // Even/Base address
        .data_out_a(bram_data_a),
        .addr_b(addr + 1'b1),  // Odd/Next address
        .data_out_b(bram_data_b)
    );

    // Pipeline A Signals
    wire signed [7:0] x_train_a = bram_data_a[17:10]; 
    wire signed [7:0] y_train_a = bram_data_a[9:2]; 
    wire [1:0] class_raw_a = bram_data_a[1:0]; 

    // Pipeline B Signals
    wire signed [7:0] x_train_b = bram_data_b[17:10];
    wire signed [7:0] y_train_b = bram_data_b[9:2];
    wire [1:0] class_raw_b = bram_data_b[1:0];

    // =============================
    // Pipeline Alignment (Two Channels)
    // =============================
    reg [1:0] class_a_d1, class_a_d2, class_a_d3;
    reg [1:0] class_b_d1, class_b_d2, class_b_d3;

    always @(posedge clk) begin
        if(reset) begin
            {class_a_d1, class_a_d2, class_a_d3} <= 0; 
            {class_b_d1, class_b_d2, class_b_d3} <= 0;
        end else begin
            class_a_d1 <= class_raw_a; 
            class_a_d2 <= class_a_d1; 
            class_a_d3 <= class_a_d2; 
            
            class_b_d1 <= class_raw_b;
            class_b_d2 <= class_b_d1;
            class_b_d3 <= class_b_d2;
        end
    end

    // =============================
    // Stage 1: Subtract (Parallel)
    // =============================
    wire signed [8:0] dx_a, dy_a, dx_b, dy_b; 
    sub s1a (.clk(clk), .rst(reset), .x_input(x_input), .y_input(y_input), .x_train(x_train_a), .y_train(y_train_a), .dx(dx_a), .dy(dy_a)); 
    sub s1b (.clk(clk), .rst(reset), .x_input(x_input), .y_input(y_input), .x_train(x_train_b), .y_train(y_train_b), .dx(dx_b), .dy(dy_b));

    // =============================
    // Stage 2: Square (Parallel)
    // =============================
    wire signed [17:0] dx_sq_a, dy_sq_a, dx_sq_b, dy_sq_b; 
    multiplier s2a (.clk(clk), .rst(reset), .dx(dx_a), .dy(dy_a), .dx_sq(dx_sq_a), .dy_sq(dy_sq_a)); 
    multiplier s2b (.clk(clk), .rst(reset), .dx(dx_b), .dy(dy_b), .dx_sq(dx_sq_b), .dy_sq(dy_sq_b));

    // =============================
    // Stage 3: Add (Parallel)
    // =============================
    wire signed [18:0] dist_a, dist_b; 
    adder s3a (.clk(clk), .rst(reset), .dx_sq(dx_sq_a), .dy_sq(dy_sq_a), .distance(dist_a)); 
    adder s3b (.clk(clk), .rst(reset), .dx_sq(dx_sq_b), .dy_sq(dy_sq_b), .distance(dist_b));

    // =============================
    // Valid Pipeline
    // =============================
    

always @(posedge clk) begin
    if(reset) begin
        valid_s1 <= 0;
        valid_s2 <= 0;
        valid_s3 <= 0;
        valid_s4 <= 0;
    end else begin
        valid_s1 <= running;      // after BRAM
        valid_s2 <= valid_s1;     // after SUB
        valid_s3 <= valid_s2;     // after MUL
        valid_s4 <= valid_s3;     // after ADD
    end
end


    // =============================
    // K-Selection (Two-Input)
    // =============================
    k_sel ksel (
        .clk(clk),
        .reset(reset),
        .valid(valid_s4), 
        .dist_a(dist_a),      // Even distance
        .class_a(class_a_d3), // Even class
        .dist_b(dist_b),      // Odd distance
        .class_b(class_b_d3), // Odd class
        .class1(class1),
        .class2(class2),
        .class3(class3),
        .class4(class4),
        .class5(class5)
    );

endmodule