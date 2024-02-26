module tt_um_johnson (clk, r, ena, rst_n, out);

parameter size =7;
input clk;
input r;
input ena, rst_n;
output [0:size] out;

reg [0:size] out;

always @(posedge clk or posedge r)
        begin
            if (r)
                out = 8'b0000_0000;
            else
                out ={~out[size],out[0:size-1]};
        end

endmodule
