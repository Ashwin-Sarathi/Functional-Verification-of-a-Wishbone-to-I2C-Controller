class environment extends ncsu_component#(.T(i2c_transaction_base));

  env_configuration configuration;
  i2c_agent         monitor_i2c_agent;
  wb_agent	        monitor_wb_agent;
  predictor         pred;
  scoreboard        scbd;
  coverage          cov;

  function new(string name = "", ncsu_component_base  parent = null); 
    super.new(name,parent);
  endfunction 

  function void set_configuration(env_configuration cfg);
    configuration = cfg;
  endfunction

  virtual function void build();
    monitor_wb_agent = new("monitor_wb_agent",this);
    monitor_wb_agent.set_configuration(configuration.wb_agent_config);
    monitor_wb_agent.build();
    monitor_i2c_agent = new("monitor_i2c_agent",this);
    monitor_i2c_agent.set_configuration(configuration.i2c_agent_config);
    monitor_i2c_agent.build();
    cov = new("coverage", this);
    cov.set_configuration(configuration);
    cov.build();
    pred  = new("pred", this);
    pred.set_configuration(configuration);
    pred.build();
    scbd  = new("scbd", this);
    scbd.build();
    monitor_wb_agent.connect_subscriber(pred);
    pred.set_scoreboard(scbd);
    monitor_i2c_agent.connect_subscriber(scbd);
    // monitor_wb_agent.connect_subscriber(cov);
    monitor_i2c_agent.connect_subscriber(cov);
  endfunction

  function wb_agent get_wb_agent();
    return monitor_wb_agent;
  endfunction

  function i2c_agent get_i2c_agent();
    return monitor_i2c_agent;
  endfunction

  virtual task run();
     monitor_wb_agent.run();
     monitor_i2c_agent.run();
		 fork
			scbd.run();
		 join_none
  endtask

endclass
