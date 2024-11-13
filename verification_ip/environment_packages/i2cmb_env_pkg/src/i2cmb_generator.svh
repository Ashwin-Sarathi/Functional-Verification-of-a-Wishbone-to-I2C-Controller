import i2c_typedefs::*;
class generator extends ncsu_component;
	`ncsu_register_object(generator)

	wb_transaction_base trans_r[i2cmb_reg_addr_t];
	wb_transaction_base trans_w[i2cmb_reg_addr_t];

	i2c_agent i2c_agent_gen; 
	wb_agent wb_agent_gen; 

	i2c_transaction_base i2c_read_trans, i2c_write_trans, i2c_rw_trans[64];
	wb_transaction_base wb_write_trans[32], wb_rw_trans[64];
	wb_transaction_base cmd_start_trans, cmd_stop_trans, cmd_core_enable_trans, cmd_bus_select_trans, cmd_bus_set_trans, cmd_write_trans, cmd_read_ack_trans, cmd_read_nack_trans, cmd_core_disable_trans;
	wb_transaction_base cmd_address_store_trans, cmd_address_load_trans, cmd_dpr_load_trans;

	bit [I2C_DATA_WIDTH-1:0] i2c_data_q [$];

	function void set_i2c_agent(i2c_agent agt);
		this.i2c_agent_gen = agt;
	endfunction

	function void set_wb_agent(wb_agent agt);
		this.wb_agent_gen = agt;
	endfunction

	function new(string name="", ncsu_component_base parent=null);
		super.new(name,parent);
		init_trans();
		setup_wb_trans();
		setup_i2c_trans();
	endfunction

	function void init_trans();
		cmd_start_trans = new("cmd_start_trans");
		cmd_stop_trans = new("cmd_stop_trans");
		cmd_core_enable_trans = new("cmd_core_enable_trans");
		cmd_bus_select_trans = new("cmd_bus_select_trans");
		cmd_bus_set_trans = new("cmd_bus_set_trans");
		cmd_write_trans = new("cmd_write_trans");
		cmd_read_ack_trans = new("cmd_read_ack_trans");
		cmd_read_nack_trans = new("cmd_read_nack_trans");
		cmd_address_store_trans = new("cmd_address_store_trans");
		cmd_address_load_trans = new("cmd_address_load_trans");
		cmd_dpr_load_trans = new("cmd_dpr_load_trans");
		cmd_core_disable_trans = new("cmd_core_disable_trans");
	endfunction

	function void setup_wb_trans();
		cmd_start_trans.set_trans(START_COMMAND, CMDR, WRITE);
		cmd_stop_trans.set_trans(STOP_COMMAND, CMDR, WRITE);
		cmd_core_enable_trans.set_trans(CORE_ENABLE, CSR, WRITE);
		cmd_core_disable_trans.set_trans(8'b0xxxxxxx, CSR, WRITE);
		cmd_bus_select_trans.set_trans(SLAVE_BUS_SELECTED, DPR, WRITE);		
		cmd_bus_set_trans.set_trans(SET_BUS_COMMAND, CMDR, WRITE);
		cmd_write_trans.set_trans(WRITE_COMMAND, CMDR, WRITE);
		cmd_address_store_trans.set_trans({SLAVE_ADDRESS, WRITE}, DPR, WRITE);
		cmd_read_ack_trans.set_trans(READ_WITH_ACK_COMMAND, CMDR, WRITE);
		cmd_read_nack_trans.set_trans(READ_WITH_NACK_COMMAND, CMDR, WRITE);
		cmd_address_load_trans.set_trans({SLAVE_ADDRESS, READ}, DPR, WRITE);

		cmd_dpr_load_trans.wb_address = DPR;
		cmd_dpr_load_trans.op = READ;

		foreach(wb_write_trans[i]) begin
			wb_write_trans[i] = new("wb_write_trans");
			wb_write_trans[i].wb_address = DPR;
			wb_write_trans[i].op = WRITE;
		end		

		foreach(wb_rw_trans[i]) begin
			wb_rw_trans[i] = new("wb_rw_trans");
			wb_rw_trans[i].wb_address = DPR;
			wb_rw_trans[i].op = WRITE;
		end
	endfunction

	function void setup_i2c_trans();
		i2c_read_trans = new("i2c_read_trans");
		i2c_read_trans.op = READ;

		for (int i = 0; i < 64; i++) begin
			i2c_rw_trans[i] = new("i2c_rw_trans");
			i2c_rw_trans[i].op = READ;
		end
	endfunction

	task wait_for_interrupt();
		logic [WB_DATA_WIDTH-1:0] data_p;
		wb_agent_gen.wb_bus.wait_for_interrupt();
		wb_agent_gen.wb_bus.master_read(CMDR, data_p);
	endtask

	virtual task run();
		wb_agent_gen.wb_bus.wait_for_reset();
		
		foreach (wb_write_trans[i]) begin
			wb_write_trans[i].wb_data = i;
		end

		// foreach (wb_write_trans[i]) begin
		// 	$display("WB_WRITE_TRANS: %p", wb_write_trans[i].wb_data); // TESTING WB_WRITE
		// end		

		foreach(wb_rw_trans[i]) begin
			wb_rw_trans[i].wb_data = (64+i);
		end

		// foreach(wb_rw_trans[i]) begin
		// 	$display("WB_RW_TRANS: %p", wb_rw_trans[i].wb_data); // TESTING WB RW
		// end

		for(int i = 0; i < 32; i++) begin
		    i2c_data_q.push_back(100 + i); 
		end
		i2c_read_trans.i2c_data = i2c_data_q;

		// $display("I2C_READ TRANS: %p", i2c_read_trans.i2c_data); // TESTING I2C_READ

		for(int i = 0; i < 64; i++) begin
		    i2c_data_q.delete;
		    i2c_data_q.push_back(63 - i);    
		    i2c_rw_trans[i].i2c_data = i2c_data_q;
		end

		wb_agent_gen.bl_put(cmd_core_enable_trans);
		wb_agent_gen.bl_put(cmd_bus_select_trans);
		wb_agent_gen.bl_put(cmd_bus_set_trans);
		wait_for_interrupt();

		fork: FORK_WRITE_OPERATION
			begin
				i2c_write_trans = new("i2c_write_trans");
				i2c_write_trans.op = WRITE;
			end
			begin
				$display("\n********************************************************");
				$display("*********** Write 32 incrementing values ***************");
				$display("********************************************************");	

				wb_agent_gen.bl_put(cmd_start_trans);		    
				wait_for_interrupt();
				wb_agent_gen.bl_put(cmd_address_store_trans); 
				wb_agent_gen.bl_put(cmd_write_trans); 
				wait_for_interrupt();
				for(int i = 0; i < 32; i++) begin         	
					wb_agent_gen.bl_put(wb_write_trans[i]);
					wb_agent_gen.bl_put(cmd_write_trans);
					wait_for_interrupt();
				end
				wb_agent_gen.bl_put(cmd_stop_trans);		    
				wait_for_interrupt();
			end
		join
		$display("WRITE OPERATION COMPLETE\n");
		disable FORK_WRITE_OPERATION;

		fork: FORK_READ_OPERATION
			begin
				i2c_agent_gen.bl_put(i2c_read_trans);
			end
			begin
				$display("\n********************************************************");
				$display("*********** Read 32 incrementing values ****************");
				$display("********************************************************");

				wb_agent_gen.bl_put(cmd_start_trans);     
				wait_for_interrupt();
				wb_agent_gen.bl_put(cmd_address_load_trans);  
				wb_agent_gen.bl_put(cmd_write_trans); 
				wait_for_interrupt(); 
				for(int i = 0; i < 32; i++) begin           	
					wb_agent_gen.bl_put(cmd_read_ack_trans);
					wait_for_interrupt();
					wb_agent_gen.bl_put(cmd_dpr_load_trans);
				end
				wb_agent_gen.bl_put(cmd_stop_trans);			
				wait_for_interrupt();
			end
		join
		$display("READ OPERATION COMPLETE\n");
		disable FORK_READ_OPERATION;

		fork: FORK_RW_OPERATION
			begin
				// $display("START RW");
				for (int i = 0; i < 64; i++) begin
					i2c_agent_gen.bl_put(i2c_write_trans);
					i2c_agent_gen.bl_put(i2c_rw_trans[i]);
					// $display("TRANSACTIONS BEING WRITTEN TO: %d", i);
				end
			end
			begin
				$display("\n********************************************************");
				$display("****** Alternate write and read for 64 transfers *******");
				$display("********************************************************");
				for(int i = 0; i < 64; i++) begin
					wb_agent_gen.bl_put(cmd_start_trans);   
					// $display("cmd_start_trans");	
					wait_for_interrupt();
					// $display("LOOP ITERATION: %d", i);
					wb_agent_gen.bl_put(cmd_address_store_trans);
					// $display("cmd_address_store_trans");
					wb_agent_gen.bl_put(cmd_write_trans); 
					// $display("cmd_write_trans");
					wait_for_interrupt();
					wb_agent_gen.bl_put(wb_rw_trans[i]);
					// $display("does it get here?");
					wb_agent_gen.bl_put(cmd_write_trans);
					// $display("CMD_WRITE");
					wait_for_interrupt();
					wb_agent_gen.bl_put(cmd_start_trans);
					wait_for_interrupt();
					// $display("About to begin read");
					wb_agent_gen.bl_put(cmd_address_load_trans);
					wb_agent_gen.bl_put(cmd_write_trans); 
					wait_for_interrupt(); 
					// $display("cmd_load");
					wb_agent_gen.bl_put(cmd_read_ack_trans);
					// $display("read ack");
					wait_for_interrupt();
					wb_agent_gen.bl_put(cmd_dpr_load_trans);
					// $display("Completed read");
				end 
				// $display("Completed 64 iterations of alternate rw loop");
				wb_agent_gen.bl_put(cmd_stop_trans);	
				wait_for_interrupt();
			end
		join
		disable FORK_RW_OPERATION;
		$display("READ-WRITE OPERATION COMPLETE\n");
	endtask
endclass
