`timescale 1ns / 10ps
module top();
parameter int WB_ADDR_WIDTH = 2;
parameter int WB_DATA_WIDTH = 8;

parameter int NUM_I2C_BUSSES = 1;
parameter int I2C_ADDR_WIDTH = 7;
parameter int I2C_DATA_WIDTH = 8;
parameter int I2C_SLAVE_ADDRESS = 7'h22;
// ****************************************************************************
// Define variable

bit  clk;
bit  rst;
wire cyc;
wire stb;
wire we;
tri ack;
wire [WB_ADDR_WIDTH-1:0] adr;
wire [WB_DATA_WIDTH-1:0] dat_wr_o;
wire [WB_DATA_WIDTH-1:0] dat_rd_i;
wire irq;
tri  [NUM_I2C_BUSSES-1:0] scl;
tri  [NUM_I2C_BUSSES-1:0] sda;

// ****************************************************************************
typedef enum bit {
    OP_READ     =1,
    OP_WRITE    =0
} i2c_op_t;

typedef enum logic [1:0] {
    CSR         = 2'd0,
    DPR         = 2'd1,
    CMDR        = 2'd2,
    FSMR        = 2'd3
} WB_REG;


// ****************************************************************************
// Instantiate the I2C slave Bus Functional Model
i2c_if      #(
    .I2C_ADDR_WIDTH(I2C_ADDR_WIDTH),
    .I2C_DATA_WIDTH(I2C_DATA_WIDTH),
    .SLAVE_ADDRESS(I2C_SLAVE_ADDRESS)
)
i2c_bus (
  // Slave signals
  .scl_s(scl[0]),
  .sda_s(sda[0])
);
// ****************************************************************************
// Instantiate the Wishbone master Bus Functional Model
wb_if       #(
      .ADDR_WIDTH(WB_ADDR_WIDTH),
      .DATA_WIDTH(WB_DATA_WIDTH)
)
wb_bus (
  // System sigals
  .clk_i(clk),
  .rst_i(rst),
  // Master signals
  .cyc_o(cyc),
  .stb_o(stb),
  .ack_i(ack),
  .adr_o(adr),
  .we_o(we),
  // Slave signals
  .cyc_i(),
  .stb_i(),
  .ack_o(),
  .adr_i(),
  .we_i(),
  // Shred signals
  .dat_o(dat_wr_o),
  .dat_i(dat_rd_i)
  );


// ****************************************************************************
// Instantiate the DUT - I2C Multi-Bus Controller
\work.iicmb_m_wb(str) #(.g_bus_num(NUM_I2C_BUSSES)) DUT
  (
    // ------------------------------------
    // -- Wishbone signals:
    .clk_i(clk),         // in    std_logic;                            -- Clock
    .rst_i(rst),         // in    std_logic;                            -- Synchronous reset (active high)
    // -------------
    .cyc_i(cyc),         // in    std_logic;                            -- Valid bus cycle indication
    .stb_i(stb),         // in    std_logic;                            -- Slave selection
    .ack_o(ack),         //   out std_logic;                            -- Acknowledge output
    .adr_i(adr),         // in    std_logic_vector(1 downto 0);         -- Low bits of Wishbone address
    .we_i(we),           // in    std_logic;                            -- Write enable
    .dat_i(dat_wr_o),    // in    std_logic_vector(7 downto 0);         -- Data input
    .dat_o(dat_rd_i),    //   out std_logic_vector(7 downto 0);         -- Data output
    // ------------------------------------
    // ------------------------------------
    // -- Interrupt request:
    .irq(irq),           //   out std_logic;                            -- Interrupt request
    // ------------------------------------
    // ------------------------------------
    // -- I2C master interfaces:
    .scl_i(scl),         // in    std_logic_vector(0 to g_bus_num - 1); -- I2C Clock inputs
    .sda_i(sda),         // in    std_logic_vector(0 to g_bus_num - 1); -- I2C Data inputs
    .scl_o(scl),         //   out std_logic_vector(0 to g_bus_num - 1); -- I2C Clock outputs
    .sda_o(sda)          //   out std_logic_vector(0 to g_bus_num - 1)  -- I2C Data outputs
    // ------------------------------------
  );

// ****************************************************************************
// Clock generator
initial begin : clk_gen
    clk = 0;
    forever #5 clk = ~clk;
end

// ****************************************************************************
// Reset generator
initial begin : rst_gen
	 rst = 1'b1;	
    #113 rst = 0;
end

// ****************************************************************************
// Monitor Wishbone bus and display transfers in the transcript
initial begin : wb_monitoring
    logic [WB_ADDR_WIDTH-1:0] addr_p;
    logic [WB_DATA_WIDTH-1:0] data_p;
    logic we_p;
	automatic bit	  print_flag = 1'b0;

	string rw;
	if (we_p)
		rw= "READ";
	else
		rw = "WRITE";

    #113 
    begin
        wb_bus.master_monitor(addr_p,data_p,we_p);
        if(print_flag) begin
            $display("================================================\n\
WB transaction at \n\
addr: %s\n\
data: %h\n\
we:   %s\n\
====================================================="
            , WB_REG'(addr_p), data_p, rw);
        end
    end
end
// ****************************************************************************
// Define the flow of the simulation
task wait_for_interrupt();
    logic [WB_DATA_WIDTH-1:0] data_p;
    wait(irq);
    wb_bus.master_read(CMDR,data_p);
endtask

initial begin : driver_wb_bus
    @(negedge rst);
    wb_bus.master_write( CSR, 8'b11xxxxxx );

    // set ID = 5
    wb_bus.master_write( DPR,8'h05 );

    wb_bus.master_write( CMDR, 8'bxxxxx110 );
    wait_for_interrupt();

//=============================================================
//  write 32 values from i2c bus
//=============================================================

    $display("\n\
 *************** WRITE 32 INCREMENTING VALUES *************** \n");
    wb_bus.master_write( CMDR, 8'bxxxxx100 );
    wait_for_interrupt();
    write_to_wishbone( {I2C_SLAVE_ADDRESS, OP_WRITE} );
    for(int i=0;i < 32 ;i++)
        write_to_wishbone( i);
    wb_bus.master_write( CMDR, {8'bxxxxx101} );
    wait_for_interrupt();

//=============================================================
//  read 32 values from i2c bus
//=============================================================
    $display("\n\
 *************** READ 32 VALUES FROM THE I2C_BUS *************** \n");
    wb_bus.master_write( CMDR, 8'bxxxxx100 );
    wait_for_interrupt();
    write_to_wishbone( {I2C_SLAVE_ADDRESS, OP_READ} );
    for(int i = 0;i < 32;i++) begin
        automatic bit [I2C_DATA_WIDTH-1:0] data;
        read_from_wishbone( data, (i==32-1) );
        assert( data == (8'd100 + i) ) begin end else $fatal("wrong data= %d, ans= %d",data,(8'd100 + i));
    end
    wb_bus.master_write( CMDR, 8'bxxxxx101);
    wait_for_interrupt();

//=============================================================
//  Alternate writes and reads for 64 transfers
//=============================================================
    $display("\n\
 *************** ALTERNATE WRITES AND READS FOR 64 TRANSFERS ***************\n");
    for(int i=0;i < 64 ;i=i+1) begin
        automatic bit [I2C_DATA_WIDTH-1:0] data;
        wb_bus.master_write(CMDR, 8'bxxxxx100);
    	wait_for_interrupt();
        write_to_wishbone( {I2C_SLAVE_ADDRESS, OP_WRITE} );
        write_to_wishbone( 8'd64 + i);
    	wb_bus.master_write(CMDR, 8'bxxxxx100);
    	wait_for_interrupt();
        write_to_wishbone( {I2C_SLAVE_ADDRESS, OP_READ} );
        read_from_wishbone(data);
        assert( data == (8'd63 - i) ) begin end else $fatal("wrong data= %d, ans= %d",data,(8'd63 - i));
    end
    wb_bus.master_write( CMDR, {8'bxxxxx101} );
    wait_for_interrupt();
    #2000 $finish;
end

task write_to_wishbone( input logic [WB_DATA_WIDTH-1:0] data_w);
    wb_bus.master_write(DPR, data_w );
    wb_bus.master_write(CMDR, {8'bxxxxx001} );
    wait_for_interrupt();
endtask

task read_from_wishbone( output logic [WB_DATA_WIDTH-1:0] data_r, input logic last=1  );
    wb_bus.master_write( CMDR, {5'bx, 3'b010 ^ last } );
    wait_for_interrupt();
    wb_bus.master_read( DPR, data_r );    
endtask

initial begin : time_limit_flow
#(100000000) $fatal("Watchdog timer expired");
$finish;
end

initial begin : monitor_i2c_bus
    bit [I2C_ADDR_WIDTH-1:0] addr;
    bit op;
    bit [I2C_DATA_WIDTH-1:0] data [];
	string rw;
    #113    forever begin
        i2c_bus.monitor(addr,op,data);
	foreach(data[i]) begin
	if (op)
		rw = "READ";
	else
		rw = "WRITE";
        $display("\
I2C_BUS %s Transfer: \
addr = %h\t\
data = %p\t\
at time [%0t]\n",rw,addr,data[i],$time);
	end
    end
end

initial begin : driver_i2c_bus
    bit i2c_op;
    bit [I2C_DATA_WIDTH-1:0] write_data [];
    bit [I2C_DATA_WIDTH-1:0] read_data [];
    bit transfer_complete;

    i2c_bus.wait_for_i2c_transfer(i2c_op,write_data);


    i2c_bus.wait_for_i2c_transfer(i2c_op,write_data);
    if( i2c_op == OP_READ ) begin
        read_data = new [1];
        read_data[0] = 8'd100;
        do begin
            i2c_bus.provide_read_data(read_data,transfer_complete);
            read_data[0] = read_data[0] + 1;
        end while(!transfer_complete);
    end

    read_data = new [1];
    for(int i=0;i< 64;i=i+1)begin

        i2c_bus.wait_for_i2c_transfer(i2c_op,write_data);

        i2c_bus.wait_for_i2c_transfer(i2c_op,write_data);
        read_data[0] = 8'd63 - i;
        i2c_bus.provide_read_data( read_data , transfer_complete );
    end
end

endmodule
