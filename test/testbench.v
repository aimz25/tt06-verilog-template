`timescale 1ns / 1ps
module testbench;

    // Signals register_file
    reg reset;
    reg clock;
    reg we;
    reg [2:0] a1;
    reg [7:0] wd;
    reg [2:0] wa;
    wire [7:0] rd1;

    // Signals tt_um_opt_encryptor
    reg [7:0] ui_in;
    wire [7:0] uo_out;
    reg [7:0] uio_in;
    wire [7:0] uio_out;
    wire [7:0] uio_oe;
    reg ena;
    reg rst_n;

    register_file rf (
        .reset(reset),
        .clock(clock),
        .we(we),
        .a1(a1),
        .wd(wd),
        .wa(wa),
        .rd1(rd1)
    );

    tt_um_opt_encryptor encryptor (
        .ui_in(ui_in),
        .uo_out(uo_out),
        .uio_in(uio_in),
        .uio_out(uio_out),
        .uio_oe(uio_oe),
        .ena(ena),
        .clk(clock),
        .rst_n(rst_n)
    );

    //clock
    initial begin
        clock = 0;
        forever #5 clock = ~clock; // Generate a clock with a period of 10 ns
    end
    //tests
    initial begin
        // Initialize 
        reset = 1; we = 0; a1 = 0; wd = 0; wa = 0; ui_in = 0; uio_in = 0; ena = 0; rst_n = 0;
        #10;
        reset = 0; rst_n = 1;

        // Test writing to register file
        we = 1; wa = 3'd5; wd = 8'hAA;
        #10;
        we = 0; a1 = 3'd5; // Read from the same address

        // encryption
        ena = 1; ui_in = 8'hFF; uio_in = 8'b00000010; // simulate encryption request
        #20;

        //decryption
        ui_in = 8'h00; uio_in = 8'b10000010; // simulate decryption request

        
        #100 $finish; // End simulation after 100 ns
    end

endmodule
