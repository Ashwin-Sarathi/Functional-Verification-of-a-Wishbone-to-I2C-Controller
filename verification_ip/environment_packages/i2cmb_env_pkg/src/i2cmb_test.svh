class i2cmb_test extends ncsu_component#(.T(i2c_transaction_base));

  env_configuration  cfg;
  environment        env;
  generator          gen;
  generator_register_tests gen_reg;


  function new(string name = "", ncsu_component_base parent = null); 
    super.new(name,parent);
    cfg = new("cfg");
    //cfg.sample_coverage();
    env = new("env",this);
    env.set_configuration(cfg);
    env.build();
    gen = new("gen",this);
    gen.set_i2c_agent(env.get_i2c_agent());
    gen.set_wb_agent(env.get_wb_agent());
    gen_reg = new("gen_reg", this);
  endfunction

  virtual task run();
     env.run();
     gen.run();
  endtask

endclass
