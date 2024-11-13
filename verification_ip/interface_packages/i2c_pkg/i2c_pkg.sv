//`include "../../ncsu_pkg/ncsu_pkg.sv"

package i2c_pkg;
	import ncsu_pkg::*;
	import i2c_typedefs::*; 
	`include "../../ncsu_pkg/ncsu_macros.svh"

	`include "src/i2c_configuration.svh"
	`include "src/i2c_transaction.svh"
	`include "src/i2c_driver.svh"
	`include "src/i2c_monitor.svh"
	`include "src/i2c_agent.svh"
	

endpackage