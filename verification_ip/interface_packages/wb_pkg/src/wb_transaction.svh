import i2c_typedefs::*;
class wb_transaction_base extends ncsu_transaction;
  `ncsu_register_object(wb_transaction_base)

	rand bit[7:0] wb_data;
	rand bit[6:0] wb_address;
	rand bit op;

  function new(string name=""); 
    super.new(name);
  endfunction

  virtual function string convert2string();
  	if(op == WRITE)
			return {super.convert2string(), $sformatf("	WB WRITE OPERATION		ADDRESS: 0x%x		DATA: %p	TIME: %t", wb_address, wb_data, $time)};
			//return {$display("	WB WRITE OPERATION		ADDRESS: 0x%x		DATA: %p	TIME: %t", wb_address, wb_data, $time)};
		else if(op == READ)
			return {super.convert2string(), $sformatf("	WB READ OPERATION		ADDRESS: 0x%x		DATA: %p	TIME: %t", wb_address, wb_data, $time)};
			//return {$display("	WB READ OPERATION		ADDRESS: 0x%x		DATA: %p	TIME: %t", wb_address, wb_data, $time)};
  endfunction

	function void print_wb_transaction(wb_transaction_base trans);
		if(op == WRITE)
			$display("  WB WRITE OPERATION		ADDRESS: %x		DATA: %d		TIME: %t", wb_address, wb_data, $time);
	endfunction

  function bit compare(wb_transaction_base rhs);
    return (this.wb_data = rhs.wb_data);
  endfunction

	function void set_trans(bit[7:0] data, bit[6:0] address, bit op);
		this.wb_data = data;
		this.wb_address = address;
		this.op = op;
	endfunction

  virtual function void set_data(bit [WB_DATA_WIDTH-1:0] data);
    this.wb_data = data;
    return;
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
