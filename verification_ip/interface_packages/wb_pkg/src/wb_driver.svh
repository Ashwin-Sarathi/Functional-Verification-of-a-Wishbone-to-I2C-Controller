import i2c_typedefs::*;
class wb_driver extends ncsu_component#(.T(wb_transaction_base));

  function new(string name = "", ncsu_component_base  parent = null); 
    super.new(name,parent);
  endfunction

  virtual wb_if#(2, 8) wb_bus;
  wb_configuration configuration;
  wb_transaction_base wb_trans;

  function void set_configuration(wb_configuration cfg);
    this.configuration = cfg;
  endfunction

  virtual task bl_put(T trans);
		if (trans.op == WRITE) begin
			wb_bus.master_write(trans.wb_address, trans.wb_data);
		end
		else begin
			wb_bus.master_read(trans.wb_address, trans.wb_data);
		end
	endtask
endclass
