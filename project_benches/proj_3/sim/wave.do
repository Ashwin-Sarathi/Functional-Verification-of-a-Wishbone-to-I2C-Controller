onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate {/top/\test.env.monitor_i2c_agent.monitor.txn_stream}
add wave -noupdate {/top/\test.env.monitor_wb_agent.monitor.txn_stream}
add wave -noupdate /top/WB_ADDR_WIDTH
add wave -noupdate /top/WB_DATA_WIDTH
add wave -noupdate /top/NUM_I2C_BUSSES
add wave -noupdate /top/I2C_ADDR_WIDTH
add wave -noupdate /top/I2C_DATA_WIDTH
add wave -noupdate /top/I2C_SLAVE_ADDRESS
add wave -noupdate /top/clk
add wave -noupdate /top/rst
add wave -noupdate /top/cyc
add wave -noupdate /top/stb
add wave -noupdate /top/we
add wave -noupdate /top/ack
add wave -noupdate /top/adr
add wave -noupdate /top/dat_wr_o
add wave -noupdate /top/dat_rd_i
add wave -noupdate /top/irq
add wave -noupdate /top/scl
add wave -noupdate /top/sda
add wave -noupdate /top/test
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {0 ps} 0}
quietly wave cursor active 0
configure wave -namecolwidth 150
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 0
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ps
update
WaveRestoreZoom {0 ps} {1 ns}
