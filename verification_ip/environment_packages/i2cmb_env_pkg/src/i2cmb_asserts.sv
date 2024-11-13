import i2c_typedefs::*;

interface i2cmb_asserts (
    // System sigals
    input wire clk_i,
    input wire rst_i,
    input wire irq_i,
    // wb master sigals
    input wire cyc_o,
    input wire stb_o,
    input wire ack_i,
    input wire [WB_ADDRESS_WIDTH-1:0] adr_o,
    input wire we_o,
    // Shared signals
    input wire [WB_DATA_WIDTH-1:0] dat_o,
    input wire [WB_DATA_WIDTH-1:0] dat_i,
    // I2C sigals
    input wire [NUM_I2C_BUSSES-1:0] scl_i,
    input wire [NUM_I2C_BUSSES-1:0] sda_i
);

property lost_arbitration;
endproperty
assert property(lost_arbitration) else $fatal("ARBITRATION LOST");

property illegal_nak;
endproperty
assert property(illegal_nak) else $fatal("ILLEGAL NAK DETECTED");

property low_don_bit;
endproperty
assert property(low_don_bit) else $fatal("HIGH DONE BIT DETECTED DURING COMMAND EXECUTION");

property low_err_bit;
endproperty
assert property(low_err_bit) else $fatal("HIGH ERROR BIT DURING EXECUTION");

endinterface