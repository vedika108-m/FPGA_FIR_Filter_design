`timescale 1ns/1ps

module fir_tb;

reg clk;
reg rst;
reg signed [7:0] x_in;
wire signed [20:0] y_out;

integer expected;
integer i;

fir_filter DUT (
    .clk(clk),
    .rst(rst),
    .x_in(x_in),
    .y_out(y_out)
);

// Clock
always #5 clk = ~clk;

// Reference model
reg signed [7:0] ref_delay[0:3];
reg signed [7:0] coeff[0:3];

initial begin
    coeff[0]=2;
    coeff[1]=4;
    coeff[2]=4;
    coeff[3]=2;
end

initial begin
    clk=0;
    rst=1;
    x_in=0;

    #20 rst=0;

    for(i=0;i<20;i=i+1) begin
        @(posedge clk);
        x_in = i;

        // shift reference
        ref_delay[3]=ref_delay[2];
        ref_delay[2]=ref_delay[1];
        ref_delay[1]=ref_delay[0];
        ref_delay[0]=x_in;

        expected =
            ref_delay[0]*coeff[0] +
            ref_delay[1]*coeff[1] +
            ref_delay[2]*coeff[2] +
            ref_delay[3]*coeff[3];

        #1;

        if(y_out !== expected)
            $display("ERROR at %0d Expected=%0d Got=%0d",
                     i, expected, y_out);
        else
            $display("PASS %0d Output=%0d", i, y_out);
    end

    $finish;
end

endmodule
