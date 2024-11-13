class wb_monitor extends ncsu_component#(.T(wb_transaction_base));

  wb_configuration  configuration;
  virtual wb_if wb_bus;

  T monitored_trans;
  ncsu_component #(T) agent;

  function new(string name = "", ncsu_component_base  parent = null); 
    super.new(name,parent);
  endfunction

  function void set_configuration(wb_configuration cfg);
    configuration = cfg;
  endfunction

  function void set_agent(ncsu_component#(T) agent);
    this.agent = agent;
  endfunction
  
  virtual task run ();
    wb_bus.wait_for_reset();
    forever begin
			monitored_trans = new("monitored_trans");
			wb_bus.master_monitor(monitored_trans.wb_address, monitored_trans.wb_data, monitored_trans.op);
			this.agent.nb_put(monitored_trans);
    end
  endtask

endclass
