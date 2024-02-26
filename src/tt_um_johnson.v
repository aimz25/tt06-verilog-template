module tt_um_johnson (    
    input  wire [7:0] ui_in,    // Dedicated inputs
    output wire [7:0] uo_out,   // Dedicated outputs
    input  wire [7:0] uio_in,   // IOs: Input path
    output wire [7:0] uio_out,  // IOs: Output path
    output wire [7:0] uio_oe,
    output reg  [7:0] out,
    input  wire       ena,      // will go high when the design is enabled
    input  wire       clk,      // clock
    input  wire       rst_n,     // reset_n - low to reset
    input  wire       r
        );

always @(posedge clk or posedge r)
        begin
            if (r)
                out = 8'b0000_0000;
            else
                    out ={~out[7],out[0:7-1]};
        end

endmodule
