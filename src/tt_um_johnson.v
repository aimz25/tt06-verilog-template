module tt_um_johnson (    
    input  wire [7:0] ui_in,    // Dedicated inputs
    output wire [7:0] uo_out,   // Dedicated outputs
    input  wire [7:0] uio_in,   // IOs: Input path
    output wire [7:0] uio_out,  // IOs: Output path
    output wire [7:0] uio_oe,
    input  wire       ena,      // will go high when the design is enabled
    input  wire       clk,      // clock
    input  wire       rst_n,     // reset_n - low to reset
        );

    always @(posedge clk or posedge ui_in[0])
        begin
            if (ui_in[0])
                uo_out = 8'b0000_0000;
            else
                uo_out = {~uo_out[7],uo_out[0:6]};
        end
    
assign uo_out  = ui_in + uio_in;
assign uio_out = 0;
assign uio_oe  = 0;
    
endmodule
