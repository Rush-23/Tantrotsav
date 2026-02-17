module input_file (
    input  wire clk,
    input  wire reset,

    input  wire [7:0] switches,
    input  wire btn_load_x,
    input  wire btn_load_y,
    input  wire btn_start,      // The raw button input
    input  wire btn_toggle_k,   // The raw button input

    output reg  signed [7:0] x_input,
    output reg  signed [7:0] y_input,
    output reg  start,          // The clean 1-cycle pulse
    output reg  K_mode
);

    // Registers to store the "previous" state of the buttons
    reg btn_start_d;
    reg btn_toggle_d;
    reg btn_load_x_d;
    reg btn_load_y_d;

    always @(posedge clk) begin
        if (reset) begin
            x_input <= 0;
            y_input <= 0;
            start   <= 0;
            K_mode  <= 0;
            btn_start_d <= 0;
            btn_toggle_d <= 0;
        end
        else begin
            // 1. Capture the previous state of the buttons
            btn_start_d  <= btn_start;
            btn_toggle_d <= btn_toggle_k;
            btn_load_x_d <= btn_load_x;
            btn_load_y_d <= btn_load_y;

            // 2. Default Start to 0 (It should only be 1 for a single cycle)
            start <= 0;

            // 3. Load Logic (Level sensitive is fine here)
            if (btn_load_x_d) x_input <= switches; // For testing, we can hardcode a value instead of using the switches
            if (btn_load_y_d) y_input <= switches; // For testing, we can hardcode a value instead of using the switches
            //K_mode <= 1'b0;


            // 4. Start Logic: Rising Edge Detector
            // Only fire if button is NOW high, but was PREVIOUSLY low
            if (btn_start && !btn_start_d) begin
                start <= 1;
            end

            // 5. Toggle Logic: Rising Edge Detector
            // Prevents K_mode from flickering back and forth rapidly
            if (btn_toggle_k && !btn_toggle_d) begin
                K_mode <= ~K_mode;
            end
        end
    end

endmodule