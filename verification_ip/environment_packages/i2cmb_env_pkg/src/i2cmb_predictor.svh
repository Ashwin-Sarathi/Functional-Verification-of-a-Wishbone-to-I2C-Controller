import i2c_typedefs:: *;
parameter int CMD_START_WB = 3'b100;
parameter int CMD_STOP_WB  = 3'b101;
class predictor extends ncsu_component#(.T(wb_transaction_base));

	ncsu_component#(i2c_transaction_base) scoreboard;
	i2c_transaction_base transport_trans;
	env_configuration configuration;
	longint bytes_of_data;
	i2c_transaction_base i2c_prediction;

	fsm_state_t current_state = START_CHECK;


	function new(string name = "", ncsu_component_base  parent = null); 
		super.new(name,parent);
		transport_trans = new("transport_trans");
		i2c_prediction = new("i2c_prediction");
  	endfunction

	function void set_configuration(env_configuration cfg);
    	configuration = cfg;
	endfunction

	virtual function void set_scoreboard(ncsu_component #(i2c_transaction_base) scoreboard);
    	this.scoreboard = scoreboard;
  	endfunction

	virtual function void nb_put(T trans);
    	static bit flag_wb_address;
		static bit check;

		if (current_state == ADDRESS_READ) begin
			flag_wb_address = (trans.wb_address == DPR);
			if (flag_wb_address) begin
				i2c_prediction.op = trans.wb_data[0] ? READ : WRITE;
				i2c_prediction.i2c_address = trans.wb_data >> 1;
				current_state = DATA_FLOW;
				bytes_of_data = 0;
			end
		end
		
		else if (current_state == START_CHECK) begin
			check = (trans.wb_data == CMD_START_WB) && (trans.wb_address == CMDR);
			// $display("THE VALUE OF TRANS.WB_DATA IN PREDICTOR IS: %d", trans.wb_data);
			current_state = (!check) ? current_state : ADDRESS_READ;
		end

		else if (current_state == DATA_FLOW) begin
			flag_wb_address = (trans.wb_address == CMDR);
			if (flag_wb_address) begin
					if (trans.wb_data == CMD_START_WB) begin
						// fsm_state_change(ADDRESS_READ);
						current_state = ADDRESS_READ;
						scoreboard.nb_transport(i2c_prediction, transport_trans);
					end
				
					else if (trans.wb_data == CMD_STOP_WB) begin
						// fsm_state_change(START_CHECK);
						current_state = START_CHECK;
						scoreboard.nb_transport(i2c_prediction, transport_trans);
					end
				
					else begin
						current_state = current_state;
					end
			end
			else begin
					i2c_prediction.i2c_data = new[bytes_of_data + 1](i2c_prediction.i2c_data);
					i2c_prediction.i2c_data[bytes_of_data] = trans.wb_data;
					bytes_of_data ++;
			end
		end

		else begin
			current_state = current_state;
		end
	endfunction

	function void fsm_state_change(input fsm_state_t result_state);
		this.current_state = result_state;
	endfunction

endclass