import i2c_typedefs::*;
class i2c_transaction_base extends ncsu_transaction;
  `ncsu_register_object(i2c_transaction_base)
	
	rand bit[7:0] i2c_data[];
	rand bit[6:0] i2c_address;
  i2c_op_t op;

  function new(string name=""); 
    super.new(name);
  endfunction

  virtual function string convert2string();
  	if(op == WRITE)
			return {super.convert2string(), $sformatf("	I2C WRITE OPERATION		ADDRESS: 0x%x		DATA: %p	TIME: %t", i2c_address, i2c_data, $time)};
		else if(op == READ)
			return {super.convert2string(), $sformatf("	I2C READ OPERATION		ADDRESS: 0x%x		DATA: %p	TIME: %t", i2c_address, i2c_data, $time)};
  endfunction

  function bit compare(i2c_transaction_base rhs);
    return (this.i2c_data == rhs.i2c_data);
  endfunction

  function void set_trans(bit[6:0] address, i2c_op_t op);
    this.i2c_address = address;
    this.op = op;
  endfunction

  /*virtual function void add_to_wave(int transaction_viewing_stream_h);
     super.add_to_wave(transaction_viewing_stream_h);
     $add_attribute(transaction_view_h,header,"header");
     $add_attribute(transaction_view_h,payload,"payload");
     $add_attribute(transaction_view_h,trailer,"trailer");
     $add_attribute(transaction_view_h,delay,"delay");
     $end_transaction(transaction_view_h,end_time);
     $free_transaction(transaction_view_h);
  endfunction*/

endclass
