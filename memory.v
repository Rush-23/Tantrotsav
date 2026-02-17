module memory #(
    parameter SAMPLE_WIDTH = 18,
    parameter ADDR_WIDTH   = 6
)(
    input  wire clk,
    // Port A
    input  wire [ADDR_WIDTH-1:0] addr_a,
    output reg  [SAMPLE_WIDTH-1:0] data_out_a,
    // Port B
    input  wire [ADDR_WIDTH-1:0] addr_b,
    output reg  [SAMPLE_WIDTH-1:0] data_out_b
);
    reg [SAMPLE_WIDTH-1:0] mem [0:(1<<ADDR_WIDTH)-1]; // [cite: 67]
    integer i;
    // ============================================================
    // DATASET (Geometric clustering)
    // Class 0 → Indices 0 to 31  (Cluster near -1, -1)
    // Class 1 → Indices 32 to 63 (Cluster near +1, +1)
    // Fixed-point format: Q4.4 signed
    // ============================================================
    initial begin
        // Keep your original data initialization here [cite: 68-81]
        // ... (Manual Class 0, Class 0 Expansion, and Class 1) ...
        // ---------------- CLASS 0 (Manual First 16) ----------------
        // Cluster around (-1, -1)
        mem[0]  = {8'b11110000, 8'b11110000, 1'b0, 1'b0}; // (-1.0 , -1.0)
        mem[1]  = {8'b11101101, 8'b11110110, 1'b0, 1'b0}; // (-1.2 , -0.8)
        mem[2]  = {8'b11111001, 8'b11101101, 1'b0, 1'b0}; // (-0.7 , -1.1)
        mem[3]  = {8'b11101011, 8'b11101011, 1'b0, 1'b0}; // (-1.3 , -1.3)
        mem[4]  = {8'b11110010, 8'b11111010, 1'b0, 1'b0}; // (-0.9 , -0.6)
        mem[5]  = {8'b11101001, 8'b11110010, 1'b0, 1'b0}; // (-1.4 , -0.9)
        mem[6]  = {8'b11111010, 8'b11101001, 1'b0, 1'b0}; // (-0.6 , -1.4)
        mem[7]  = {8'b11101110, 8'b11110101, 1'b0, 1'b0}; // (-1.1 , -0.7)
        
        // Slightly varied copies to fill up to index 15
        mem[8]  = {8'b11110000, 8'b11110000, 1'b0, 1'b0}; 
        mem[9]  = {8'b11101101, 8'b11110110, 1'b0, 1'b0}; 
        mem[10] = {8'b11111001, 8'b11101101, 1'b0, 1'b0}; 
        mem[11] = {8'b11101011, 8'b11101011, 1'b0, 1'b0}; 
        mem[12] = {8'b11110010, 8'b11111010, 1'b0, 1'b0}; 
        mem[13] = {8'b11101001, 8'b11110010, 1'b0, 1'b0}; 
        mem[14] = {8'b11111010, 8'b11101001, 1'b0, 1'b0}; 
        mem[15] = {8'b11101110, 8'b11110101, 1'b0, 1'b0}; 

        // ---------------- CLASS 0 EXPANSION (16-31) ----------------
        // Auto-fill remaining Class 0 slots with slight noise around -1.0 (F0)
        
        for (i = 16; i < 32; i = i + 1) begin
             mem[i] = { (8'hF0 + (i[3:0])), (8'hF0 - (i[3:0])), 1'b0, 1'b0 }; // [cite: 79]
        end

        // ---------------- CLASS 1 (32-63) ----------------
        // Cluster around (+1, +1) -> Hex 10
        // Auto-fill Class 1 slots with slight noise around +1.0 (10)
        for (i = 32; i < 64; i = i + 1) begin
             mem[i] = { (8'h10 + (i[3:0])), (8'h10 - (i[3:0])), 1'b1, 1'b0 };
        end

    end

    always @(posedge clk) begin
        data_out_a <= mem[addr_a];
        data_out_b <= mem[addr_b];
    end

endmodule

