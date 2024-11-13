class coverage extends ncsu_component#(.T(i2c_transaction_base));
  env_configuration       configuration;
  i2c_transaction_base test_trans;

  i2c_op_t op;
  bit [I2C_ADDR_WIDTH-1 : 0] addr;
  bit [I2C_DATA_WIDTH-1 : 0] data[];
  int count;
  
  covergroup i2c_coverage with function sample(i2c_transaction_base trans);
    option.per_instance = 1;
    option.name = get_full_name();
    option.auto_bin_max = 128;

    addr_test: coverpoint addr {
      option.auto_bin_max = 1;
    }

    op_test: coverpoint op {
      bins WRITE = {0};
      bins READ = {1};
    }
    
    value_test: coverpoint data[0] {
      bins low = {[0:9]};
      bins med = {[0:9]};
      bins high = {[10:20]};
      bins vvhigh = {[10:20]};
    }

    transfer_test: coverpoint count {
      option.auto_bin_max = 3;
    }

    addrXop: cross addr_test, op_test;

    addrXtransfer: cross addr_test, transfer_test;
  endgroup

  function void set_configuration(env_configuration cfg);
  	configuration = cfg;
  endfunction

  function new(string name = "", ncsu_component_base  parent = null); 
    super.new(name, parent);
    i2c_coverage = new;
  endfunction

  virtual function void nb_put(T trans);
    // $display({get_full_name()," ",trans.convert2string()});

    op = trans.op;
    addr = trans.i2c_address;
    count = data.size();
    i2c_coverage.sample(trans);
  endfunction

endclass
