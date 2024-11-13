class i2c_driver extends ncsu_component#(.T(i2c_transaction_base));

  function new(string name = "", ncsu_component#(T)  parent = null); 
    super.new(name,parent);
  endfunction

  virtual i2c_if bus;
  i2c_configuration configuration;
  i2c_transaction_base i2c_trans;
  bit transfer_complete;

  function void set_configuration(i2c_configuration cfg);
    configuration = cfg;
  endfunction

  virtual task bl_put(T trans);
		bit [7:0] q[];
			if (trans.op == WRITE) begin
				bus.wait_for_i2c_transfer(trans.op, trans.i2c_data);
				// $display("I2C WRITE OPERATION DATA: %p", trans.i2c_data);
			end
			else begin
				bus.wait_for_i2c_transfer(trans.op, q);
				// $display("Wait for transfer complete");
				// $display("I2C READ OPERATION DATA: %p", trans.i2c_data);
				bus.provide_read_data(trans.i2c_data, transfer_complete);
				//bus.provide_read_data(q, transfer_complete);
				// $display("provide read data complete");
			end			
  endtask

endclass
