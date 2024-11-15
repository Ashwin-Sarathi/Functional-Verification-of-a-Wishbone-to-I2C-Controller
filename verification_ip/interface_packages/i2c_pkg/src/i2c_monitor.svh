class i2c_monitor extends ncsu_component#(.T(i2c_transaction_base));

  i2c_configuration  configuration;
  virtual i2c_if bus;

  T monitored_trans;
  ncsu_component #(T) agent;

  function new(string name = "", ncsu_component_base  parent = null); 
    super.new(name,parent);
  endfunction

  function void set_configuration(i2c_configuration cfg);
    configuration = cfg;
  endfunction

  function void set_agent(ncsu_component#(T) agent);
    this.agent = agent;
  endfunction
  
  virtual task run ();
		forever begin
			monitored_trans = new("monitored_trans");
			bus.monitor(monitored_trans.i2c_address, monitored_trans.op, monitored_trans.i2c_data);
      // $display("MONITORED DATA: %p", monitored_trans.i2c_data);
			this.agent.nb_put(monitored_trans);
		end
  endtask

endclass
