import i2c_typedefs::*;
class i2cmb_behaviour_test extends generator;

function new(string name="", ncsu_component_base parent=null);
	super.new(name, parent);

endfunction

virtual task run();

    $display("\n********************************************************");
    $display("************** I2CMB BEHAVIOUR TESTING ******************");
    $display("********************************************************");

endtask

endclass