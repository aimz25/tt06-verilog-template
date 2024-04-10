module otp_encryptor
(
    input  wire [7:0] ui_in,    // Dedicated inputs
    output wire [7:0] uo_out,   // Dedicated outputs
    input  wire [7:0] uio_in,   // IOs: Input path
    output wire [7:0] uio_out,  // IOs: Output path
    output wire [7:0] uio_oe,   // IOs: Enable path (active high: 0=input, 1=output)
    input  wire       ena,      // will go high when the design is enabled
    input  wire       clk,      // clock
    input  wire       rst_n     // reset_n - low to reset
);

wire [7:0] data;
wire [7:0] pad_read;
wire [7:0] pad_gen;
wire [3:0] r_num;
reg[3:0] count = 4'd0;
wire decrypt;

wire[7:0] out;
reg [3:0] index_out;


// io
assign data = ui_in[7:0];
assign decrypt = uio_in[0];
assign r_num = uio_in[4:1];

assign uo_out[7:0] = out[7:0];
assign uio_out[3:0] = index_out[3:0];
assign uio_out[7:4] = 4'h0;


register_file rf (
.reset(~rst_n),
.clock(clk),
.we(ena & decrypt),
.a1(r_num),
.wd(pad_gen),
.wa(count),
.rd1(pad_read));


LFSR_PRNG rng(
    .clk(clk),
    .rst(~rst_n),
    .prn(pad_gen));

assign out = ena ? (decrypt ? (pad_read ^ data) : (pad_gen ^ data)) : 8'h00;
	 
always @ (posedge clk) begin
	if (~rst_n) begin
		count = 4'd0;
	end
	else if (ena) begin
		if (decrypt) begin
			index_out = 4'h0;
		end
		else begin // encrypt
			index_out = count;
			count = count + 4'd1;
		end
	end
end

endmodule
