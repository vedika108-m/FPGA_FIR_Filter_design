module fir_filter #(
    parameter TAPS = 4,
    parameter DATA_WIDTH = 8,
    parameter COEFF_WIDTH = 8
)(
    input clk,
    input rst,
    input signed [DATA_WIDTH-1:0] x_in,
    output reg signed [DATA_WIDTH+COEFF_WIDTH+4:0] y_out
);

    // ----------------------------
    // Delay Line (Shift Register)
    // ----------------------------
    reg signed [DATA_WIDTH-1:0] shift_reg [0:TAPS-1];

    integer i;

    always @(posedge clk) begin
        if (rst) begin
            for(i=0;i<TAPS;i=i+1)
                shift_reg[i] <= 0;
        end
        else begin
            shift_reg[0] <= x_in;
            for(i=1;i<TAPS;i=i+1)
                shift_reg[i] <= shift_reg[i-1];
        end
    end

    // ----------------------------
    // Coefficient Storage
    // ----------------------------
    reg signed [COEFF_WIDTH-1:0] coeff [0:TAPS-1];

    initial begin
        coeff[0] = 2;
        coeff[1] = 4;
        coeff[2] = 4;
        coeff[3] = 2;
    end

    // ----------------------------
    // Multiply Stage
    // ----------------------------
    reg signed [DATA_WIDTH+COEFF_WIDTH-1:0] mult [0:TAPS-1];

    always @(*) begin
        for(i=0;i<TAPS;i=i+1)
            mult[i] = shift_reg[i] * coeff[i];
    end

    // ----------------------------
    // Accumulator (Adder Tree)
    // ----------------------------
    reg signed [DATA_WIDTH+COEFF_WIDTH+4:0] acc;

    always @(*) begin
        acc = 0;
        for(i=0;i<TAPS;i=i+1)
            acc = acc + mult[i];
    end

    // Registered Output (Timing Safe)
    always @(posedge clk)
        y_out <= acc;

endmodule
