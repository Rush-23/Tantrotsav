module latency_counter #(
    parameter WIDTH = 16   // number of bits for counter
)(
    input  wire clk,
    input  wire reset,

    input  wire start,     // 1-cycle pulse to start counting
    input  wire done,      // goes high when inference completes

    output reg  [WIDTH-1:0] latency,
    output reg              running
);

    always @(posedge clk ) begin
        if (reset) begin
            latency <= 0;
            running <= 0;
        end
        else begin

            // Start counting
            if (start && !running) begin
                latency <= 0;
                running <= 1;
            end

            // While running, increment
            else if (running) begin
                latency <= latency + 1;

                // Stop when done is asserted
                if (done)
                    running <= 0;
            end

        end
    end

endmodule
