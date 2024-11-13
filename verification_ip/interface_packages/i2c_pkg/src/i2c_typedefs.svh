package i2c_typedefs;
parameter int I2C_ADDR_WIDTH = 7;
parameter int I2C_DATA_WIDTH = 8;
parameter int SLAVE_ADDRESS = 7'h22;
parameter int WB_DATA_WIDTH = 8;
parameter int SLAVE_BUS_SELECTED = 5;
parameter int WB_ADDRESS_WIDTH = 2;
parameter int NUM_I2C_BUSSES = 1;
parameter int sucess = 1;

typedef enum bit {
	WRITE = 1'b0,
	READ  = 1'b1
} i2c_op_t;

typedef enum bit[2:0] {
	START_CHECK,
	ADDRESS_READ,
	DATA_FLOW
} fsm_state_t;

typedef enum logic[3:0] {
	CSR,
	DPR,
	CMDR,
	FSMR,
	UNKNOWN = 4'bzzzz
} i2cmb_reg_addr_t;

typedef enum logic[7:0] {
	START_COMMAND = 8'bxxxxx100,
	STOP_COMMAND = 8'bxxxxx101,
	READ_WITH_ACK_COMMAND = 8'bxxxxx010,
	READ_WITH_NACK_COMMAND = 8'bxxxxx011,
	WRITE_COMMAND = 8'bxxxxx001,
	SET_BUS_COMMAND = 8'bxxxxx110,
	WAIT_COMMAND = 8'bxxxxx000,
	CORE_ENABLE = 8'b11xxxxxx
} cmdr_cmds_t;

string  map_reg_ofst_name [i2cmb_reg_addr_t] = '{
    CSR             :   "CSR" ,
    DPR             :   "DPR" ,
    CMDR            :   "CMDR",
    FSMR            :   "FSMR"
};
endpackage
