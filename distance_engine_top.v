module distance_engine_top (
    input  wire clk,
    input  wire reset, // Active Low (negedge)
    input  wire start,
    input  wire signed [7:0] x_input,
    input  wire signed [7:0] y_input,
    output wire class1, class2, class3, class4, class5, 
    output reg  done
);

    // =============================hi
    // Address Counter
    // =============================
    reg [5:0] addr;
    reg running;
    
    // Delayed valid signal to match pipeline depth
    reg valid_s1, valid_s2, valid_s3; 

    always @(posedge clk or negedge reset) begin
        if (!reset) begin
            addr    <= 0;
            running <= 0;
            done    <= 0;
        end
        else if (start) begin
            addr    <= 0;
            running <= 1;
            done    <= 0;
        end
        else if (running) begin
            addr <= addr + 1;
            if (addr == 6'd63)
                running <= 0;
        end
        else if (valid_s3 && !running) begin 
            // Assert done when the last valid data exits the pipeline
            done <= 1;
        end
    end

    // =============================
    // BRAM
    // =============================
    wire [17:0] bram_data;
    wire signed [7:0] x_train = bram_data[17:10];
    wire signed [7:0] y_train = bram_data[9:2];
    wire              class_train_raw = bram_data[1];

    memory bram_inst (
        .clk(clk),
        .addr(addr),
        .data_out(bram_data)
    );

    // =============================
    // Pipeline Alignment (CRITICAL FIX)
    // =============================
    // Delay class_train by 3 cycles to match the Sub->Mult->Add pipeline
    reg class_d1, class_d2, class_d3;
    always @(posedge clk or negedge reset) begin
        if(!reset) begin
            class_d1 <= 0; class_d2 <= 0; class_d3 <= 0;
        end else begin
            class_d1 <= class_train_raw;
            class_d2 <= class_d1;
            class_d3 <= class_d2; // This is now aligned with 'distance' output
        end
    end

    // =============================
    // Stage 1: Subtract
    // =============================
    wire signed [8:0] dx, dy;
    sub s1 (
        .clk(clk),
        .rst(reset),
        .x_input(x_input),
        .y_input(y_input),
        .x_train(x_train),
        .y_train(y_train),
        .dx(dx),
        .dy(dy)
    );

    // =============================
    // Stage 2: Square
    // =============================
    wire signed [17:0] dx_sq, dy_sq;
    multiplier s2 (
        .clk(clk),
        .rst(reset),
        .dx(dx),
        .dy(dy),
        .dx_sq(dx_sq),
        .dy_sq(dy_sq)
    );

    // =============================
    // Stage 3: Add
    // =============================
    wire signed [18:0] distance;
    // FIXED: Typo 'sdder' -> 'adder'
    adder s3 (
        .clk(clk),
        .rst(reset),
        .dx_sq(dx_sq),
        .dy_sq(dy_sq),
        .distance(distance)
    );

    // =============================
    // Valid Pipeline
    // =============================
    always @(posedge clk or negedge reset) begin
        if (!reset) begin
            valid_s1 <= 0; valid_s2 <= 0; valid_s3 <= 0; 
        end else begin
            valid_s1 <= running;   // Data read from BRAM
            valid_s2 <= valid_s1;  // Sub complete
            valid_s3 <= valid_s2;  // Mult complete
                                   // valid_s3 aligns with Adder complete
        end
    end

    // =============================
    // K-Selection
    // =============================
    k_sel ksel (
        .clk(clk),
        .reset(reset),
        .valid(valid_s3),     
        .distance(distance),
        .class_in(class_d3),  // Use the delayed class
        .class1(class1),
        .class2(class2),
        .class3(class3),
        .class4(class4),
        .class5(class5)
    );

endmodule