//`include "../../ncsu_pkg/ncsu_pkg.sv"
package wb_pkg;
	import ncsu_pkg::*;
	import i2c_typedefs::*;
	`include "../../ncsu_pkg/ncsu_macros.svh"
	//`include "src/wb_typedefs.svh"

	`include "src/wb_configuration.svh"
	`include "src/wb_transaction.svh"
	`include "src/wb_driver.svh"
	`include "src/wb_monitor.svh"
	`include "src/wb_agent.svh"
endpackage
