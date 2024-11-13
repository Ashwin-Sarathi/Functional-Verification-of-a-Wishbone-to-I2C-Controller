export ECE745_PROJECT_HOME ?= $(PWD)/../../..

GEN_TRANS_TYPE ?= BASE_GENERATE
TEST_SEED ?= 1234567890
CLI_DO_COMMANDS = -do " \
                    set NoQuitOnFinish 1; \
                    run -all; \
					coverage attribute -name TESTNAME -value generator;\
					coverage save generator.ucdb;\
					coverage attribute -name TESTNAME -value random_generator;\
					coverage save random_generator.ucdb;\
					coverage attribute -name TESTNAME -value i2cmb_generator_register_tests;\
					coverage save i2cmb_generator_register_tests.ucdb;\
                    quit -f;" 

DEBUG_DO_COMMANDS = -do " \
                    set NoQuitOnFinish 1; \
					run 0; \
                    do wave.do;\
                    run -a; \
					coverage attribute -name TESTNAME -value generator;\
					coverage save generator.ucdb;\
					coverage attribute -name TESTNAME -value random_generator;\
					coverage save random_generator.ucdb;"
					# do save_coverage.do $(GEN_TRANS_TYPE);"

include $(ECE745_PROJECT_HOME)/verification_ip/ncsu_pkg/Makefile
include $(ECE745_PROJECT_HOME)/verification_ip/interface_packages/wb_pkg/Makefile
include $(ECE745_PROJECT_HOME)/verification_ip/interface_packages/i2c_pkg/Makefile
include $(ECE745_PROJECT_HOME)/verification_ip/environment_packages/i2cmb_env_pkg/Makefile

clean: 
	rm -rf work *.wlf transcript 

clean_ucdb: 
	rm -f *.ucdb

clean_coverage: 
	rm -rf covhtmlreport

clean_all:
	rm -rf work *.wlf transcript 
	rm -f *.ucdb
	rm -rf covhtmlreport

comp_I2C_MB:
	vcom +cover=bcefsx ../rtl/iicmb_int_pkg.vhd
	vcom +cover=bcefsx ../rtl/iicmb_pkg.vhd
	vcom +cover=bcefsx ../rtl/mbyte.vhd
	vcom +cover=bcefsx ../rtl/mbit.vhd
	vcom +cover=bcefsx ../rtl/bus_state.vhd
	vcom +cover=bcefsx ../rtl/filter.vhd
	vcom +cover=bcefsx ../rtl/conditioner.vhd
	vcom +cover=bcefsx ../rtl/conditioner_mux.vhd
	vcom +cover=bcefsx ../rtl/iicmb_m.vhd
	vcom +cover=bcefsx ../rtl/regblock.vhd
	vcom +cover=bcefsx ../rtl/wishbone.vhd
	vcom +cover=bcefsx ../rtl/iicmb_m_wb.vhd


comp_bench: comp_ncsu_pkg comp_wb_pkg comp_i2c_pkg comp_i2cmb_env_pkg 
	vlog ../testbench/top.sv

optimize:
	vopt +cover=bcefsx +acc top -o optimized_debug_top_tb
	#vopt +acc top -o optimized_debug_top_tb
  	#vopt -64 +cover=bcefsx +acc top -o optimized_debug_top_tb

compile: comp_I2C_MB comp_bench optimize

simulate:
	vsim  -i -classdebug -msgmode both -do "set NoQuitOnFinish 1; do wave.do" optimized_debug_top_tb

debug_3step: clean compile simulate

debug:
	clean compile optimize run_gui

run_cli:
	vsim -c -coverage -sv_seed $(TEST_SEED) $(CLI_DO_COMMANDS) +GEN_TRANS_TYPE=$(GEN_TRANS_TYPE) optimized_debug_top_tb

run_gui:
	vsim -coverage -sv_seed $(TEST_SEED) $(DEBUG_DO_COMMANDS) +GEN_TRANS_TYPE=$(GEN_TRANS_TYPE) optimized_debug_top_tb

cli: clean compile optimize run_cli

debug: clean compile optimize run_gui

merge_coverage:
	xml2ucdb -format Excel ./test_plan_layered_testbench.xml ./test_plan_layered_testbench.ucdb
	vcover merge -stats=none -strip 0 -totals sim_and_testplan_merged.ucdb ./*.ucdb 

regress:
	./regress.sh

view_coverage:
	vsim -viewcov ./sim_and_testplan_merged.ucdb
