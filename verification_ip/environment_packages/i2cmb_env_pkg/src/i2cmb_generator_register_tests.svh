import i2c_typedefs::*;
class generator_register_tests extends generator;

bit [7:0] reg_reset[i2cmb_reg_addr_t];
bit [7:0] reg_access_array[i2cmb_reg_addr_t]; 

function new(string name="", ncsu_component_base parent=null);
	super.new(name, parent);

	reg_reset[CSR] = 8'h00;
	reg_reset[DPR] = 8'h00;
	reg_reset[CMDR] = 8'h80;
	reg_reset[FSMR] = 8'h00;
	reg_access_array[CSR] = 8'hc0;
	reg_access_array[DPR] = 8'h00; 
	reg_access_array[CMDR] = 8'h17;
	reg_access_array[FSMR] = 8'h00;

endfunction

virtual task run();

    $display("\n********************************************************");
    $display("************** REGISTER BLOCK TESTING ******************");
    $display("********************************************************");


    $display("************ REGISTER CORE DISABLE CHECK ******************");

    super.wb_agent_gen.bl_put(cmd_core_disable_trans);
    assert(trans_r[0].wb_data == 0) $display("CSR ENABLE BIT SET TO 0");
    else $display("CSR ENABLE BIT NOT SET TO 0");


    super.wb_agent_gen.bl_put(cmd_core_enable_trans);


    // test purpose: CMDR, DPR, FSMR registers should be reset value after enable
    $display("************ REGISTER ACCESSIBILITY TEST ******************");

    // test order: FSMR(3) -> CMDR(2) -> DPR(1)-> CSR(0)
    for(int i=3; i>=0 ;i--)begin
        automatic i2cmb_reg_addr_t addr = i2cmb_reg_addr_t'(i);
        super.wb_agent_gen.bl_put(trans_r[addr]);
        if(addr == CSR)begin
            assert(trans_r[addr].wb_data == 8'b11000000 )  $display("LEGALLY ACCESSING REGISTER : %s", map_reg_ofst_name[i2cmb_reg_addr_t'(addr)]);
            else $display("ILLEGALLY ACCESSING REGISTER : %s", map_reg_ofst_name[i2cmb_reg_addr_t'(addr)]);
        end else begin
            assert(trans_r[addr].wb_data == reg_reset[addr])  $display("LEGALLY ACCESSING REGISTER : %s", map_reg_ofst_name[i2cmb_reg_addr_t'(addr)]);
            else $display("ILLEGALLY ACCESSING REGISTER : %s", map_reg_ofst_name[i2cmb_reg_addr_t'(addr)]);
        end
    end

    // test purpose: all register except CSR should not be able to be written "AFTER RESET CORE, before enable core!"
    // access permission of CSR should follow specification.
    $display("************ FIELD ALIASING TEST ******************");

    // reset core
    super.wb_agent_gen.bl_put(cmd_core_disable_trans);

    for(int i=0; i<4 ;i++)begin
        automatic i2cmb_reg_addr_t addr_1 = i2cmb_reg_addr_t'(i);
        automatic i2cmb_reg_addr_t addr_2;

        void'(trans_w[addr_1].set_data( 8'hff ));
        super.wb_agent_gen.bl_put(trans_w[addr_1]);
        for(int k=0; k<4 ;k++)begin
            if( k == i ) continue;
            addr_2 = i2cmb_reg_addr_t'(k);
            assert(trans_r[addr_2].wb_data == reg_access_array[addr_2])  $display("{%s UNCHANGED WHEN WRITING TO %s} PASSED ", map_reg_ofst_name[addr_2],map_reg_ofst_name[addr_1] );
            else $display("{%s ALIASED WHEN WRITING TO %s} FAILED ", map_reg_ofst_name[addr_2], map_reg_ofst_name[addr_1] );
        end
    end

    // test purpose: test access permission AFTER ENABLE CORE
    // access permission of DPR, FSMR should follow specification.
    $display("************ INVALID ADDRESS HANDLING ******************");

    // enable core
    super.wb_agent_gen.bl_put(cmd_core_enable_trans);
    

    $display("************ REGISTER DEFAULT VALUES TEST ******************");
    
    super.wb_agent_gen.bl_put(cmd_core_disable_trans);
    for(int i=3; i>=0 ;i--)begin
        automatic i2cmb_reg_addr_t addr = i2cmb_reg_addr_t'(i);
        void'(trans_w[addr].set_data( 8'hff ));
        super.wb_agent_gen.bl_put(trans_w[addr]);

        super.wb_agent_gen.bl_put(trans_r[addr]);
        if(addr == CSR)begin
            assert(trans_r[addr].wb_data == 8'b11000000 )  $display("{%s REGISTER DEFAULT VALUE AFTER RESET CORE} : %b CORRECT", map_reg_ofst_name[addr], trans_r[addr].wb_data);
            else $display("{%s REGISTER DEFAULT VALUE AFTER RESET CORE} : %b INCORRECT", map_reg_ofst_name[addr],trans_r[addr].wb_data);
        end else begin
            assert(trans_r[addr].wb_data == reg_reset[addr])  $display("{%s REGISTER DEFAULT VALUE AFTER RESET CORE} : %b CORRECT", map_reg_ofst_name[addr], trans_r[addr].wb_data);
            else $display("{%s REGISTER DEFAULT VALUE AFTER RESET CORE} : %b INCORRECT", map_reg_ofst_name[addr],trans_r[addr].wb_data);
        end
    end

    $display("\n********************************************************");
    $display("********** REGISTER BLOCK TESTING COMPLETE *************");
    $display("********************************************************");

 endtask

endclass