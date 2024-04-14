from myhdl import block, Signal, intbv, delay, ResetSignal, always_seq, always_comb, always, instance, StopSimulation

@block
def register_file(reset, clock, we, a1, wd, wa, rd1):
    """A simple register file with write and read functionalities."""
    mem = [Signal(intbv(0)[8:]) for _ in range(8)]

    @always_seq(clock.posedge, reset=reset)
    def logic():
        if we:
            mem[wa].next = wd
        rd1.next = mem[a1]

    return logic

# Defining encryption/decryption module
@block
def tt_um_opt_encryptor(ui_in, uo_out, uio_in, uio_out, uio_oe, ena, clk, rst_n):
    """A basic encryptor/decryptor logic."""
    data = Signal(intbv(0)[8:])
    pad_read = Signal(intbv(0)[8:])
    pad_gen = Signal(intbv(0)[8:])
    r_num = Signal(intbv(0)[3:])
    decrypt = Signal(bool(0))
    out = Signal(intbv(0)[8:])
    index_out = Signal(intbv(0)[3:])
    count = Signal(intbv(0)[4:])

    @always_comb
    def assign():
        data.next = ui_in
        decrypt.next = uio_in[0]
        r_num.next = uio_in[3:1]
        uio_oe.next = 0b11110000
        uio_out.next = intbv(0)[8:]  # Reset uio_out
        uio_out[6:4].next = index_out
        uio_out[3:0].next = uio_in[7:4]

    @always_seq(clk.posedge, reset=ResetSignal(rst_n, active=0, async=True))
    def logic():
        if ena:
            if decrypt:
                out.next = pad_read ^ data
            else:  # Encrypt
                out.next = pad_gen ^ data
                if count == 7:
                    index_out.next = count
                    count.next = 0
                else:
                    index_out.next = count
                    count.next = count + 1
        else:
            out.next = 0

    uo_out.next = out

    return assign, logic

# Pseudorandom number generator 
@block
def LFSR_PRNG(clk, rst, prn):
    """Linear Feedback Shift Register for generating pseudorandom numbers."""
    lfsr = Signal(intbv(0xA5)[8:])  # Example seed

    @always_seq(clk.posedge, reset=rst)
    def generator():
        # maximum-length LFSR with an 8-bit width
        xor = lfsr[7] ^ lfsr[5] ^ lfsr[4] ^ lfsr[3]
        lfsr.next[1:] = lfsr[:7]
        lfsr.next[0] = xor

    @always_comb
    def output():
        prn.next = lfsr

    return generator, output

# Testbench for simulations
@block
def testbench():
    # signals
    reset, clock, we, ena, rst_n = [Signal(bool(0)) for _ in range(5)]
    a1, wa = [Signal(intbv(0)[3:]) for _ in range(2)]
    wd, ui_in, uio_in = [Signal(intbv(0)[8:]) for _ in range(3)]
    rd1, uo_out, uio_out, uio_oe = [Signal(intbv(0)[8:]) for _ in range(4)]

    regfile = register_file(reset, clock, we, a1, wd, wa, rd1)
    encryptor = tt_um_opt_encryptor(ui_in, uo_out, uio_in, uio_out, uio_oe, ena, clock, rst_n)

    # Clock
    @always(delay(5))
    def clock_gen():
        clock.next = not clock

    # cases to test
    @instance
    def simulate():
        # Reset
        reset.next = 1
        rst_n.next = 0
        yield delay(10)
        reset.next = 0
        rst_n.next = 1

        # writing to register file
        we.next = 1
        wa.next = 5
        wd.next = 0xAA
        yield clock.posedge

        we.next = 0
        a1.next = 5
        yield clock.posedge

        #encryption
        ena.next = 1
        ui_in.next = 0xFF
        uio_in.next = 2  # adjust as needed
        yield clock.posedge

        #decryption
        ui_in.next = 0x00
        uio_in.next = 130  #adjust as needed
        yield clock.posedge

        # top
        raise StopSimulation

    return regfile, encryptor, clock_gen, simulate

# Run main test
if __name__ == "__main__":
    tb = testbench()
    tb.run_sim()
