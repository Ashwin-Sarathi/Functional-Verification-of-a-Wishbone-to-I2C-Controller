import i2c_typedefs:: *;

class scoreboard extends ncsu_component#(.T(i2c_transaction_base));

	T trans_in;
	T trans_out;
	T trans_user;

	event complete_i2c_trans;
	event complete_wb_trans;

	function new(string name = "", ncsu_component_base  parent = null); 
    	super.new(name,parent);
	endfunction

	virtual function void nb_transport(input T input_trans, output T output_trans);
		$display({get_full_name()," nb_transport: expected transaction ",input_trans.convert2string()});
		this.trans_in = input_trans;
		output_trans = trans_out;
		->complete_wb_trans;
	endfunction

	virtual function void nb_put(T trans);
		trans_user = trans;
		$display({get_full_name()," nb_put: actual transaction ",trans.convert2string()});
		->complete_i2c_trans;
	endfunction

	virtual task run();
		bit success;
		// bit p4 = 1'b0;
		forever begin
			fork
				wait(complete_i2c_trans.triggered);
				wait(complete_wb_trans.triggered);
			join
			
			success = this.trans_in.compare(trans_user);
			if (success) $display({"******************** ", get_full_name(), " compare: MATCH! ****************************\n"});
			else if (!sucess) $display({"******************** ", get_full_name(), " compare: MISMATCH! ****************************\n"});
		end
	endtask

endclass


