`timescale 1ns / 10ps
import i2c_typedefs::*;
//parameter int I2C_ADDR_WIDTH = 7;
//parameter int I2C_DATA_WIDTH = 8;
//parameter int SLAVE_ADDRESS = 7'h22;
interface i2c_if       #(
    I2C_ADDR_WIDTH = 7,
    I2C_DATA_WIDTH = 8,
    SLAVE_ADDRESS = 7'h22
)(
    // Slave signals
    input           scl_s,
    inout   triand  sda_s
);
    //typedef enum bit { READ=1,WRITE=0} i2c_op_t;

    // global signals
    logic ack_for_sda   = 0;
    logic drive_sda     = 0;
    assign sda_s = ack_for_sda ? drive_sda : 'bz;


    bit     start = 0;
    bit     stop  = 0;
    bit     data_remaining  = 0;

    bit     start_monitor = 0;
    bit     stop_monitor  = 0;
    bit     data_monitor  = 0;

    task wait_for_i2c_transfer ( output i2c_op_t op, output bit [I2C_DATA_WIDTH-1:0] write_data []);
		automatic bit [I2C_DATA_WIDTH-1:0] 		data;
        automatic bit [I2C_ADDR_WIDTH-1:0]      slave_addr;
        automatic bit [I2C_DATA_WIDTH-1:0]      q [$];

		detect_start(start);
		get_address(op, slave_addr);
		gen_ack();
	
		if (op == WRITE) begin
			@(negedge scl_s) ack_for_sda = 0;
			obtain_data(q);
			gen_ack();
			@(negedge scl_s) ack_for_sda = 0;
			
			do begin
				data_remaining = 0;
				fork: fork_start_stop_repeated
					begin
						detect_start(start);
						start = 1;
					end

					begin
						enforce_stop(stop);
					end
					begin
						obtain_data(q);
						data_remaining = 1;
						gen_ack();
						@(negedge scl_s) ack_for_sda = 0;
					end
				join_any
				disable fork_start_stop_repeated;
			end while(data_remaining);
			
			write_data = new[q.size()];
			write_data = {>>{q}};
		end
    endtask

    task provide_read_data ( input bit [I2C_DATA_WIDTH-1:0] read_data [], output bit transfer_complete);
        automatic bit ack = 0; 
        // $display("Enters the function: provide_read_data");
        // $display("READ_DATA[] IN PROVIDE_READ_DATA: %p", read_data);
        foreach(read_data[i]) begin
            // $display("LOOP ITERATION: %d", i);
            if (i == 31) read_given_data2(read_data[i]);
            else read_given_data(read_data[i]);
            // if (i == 31) $display("READ_DATA LOOP ITERATION 31");
            // $display("%p", read_data[i]);
            @(negedge scl_s) ack_for_sda <= 0;
            @(posedge scl_s) ack = !sda_s;
            if(!ack) begin 
                fork : fork_read_data
                    begin 
                        detect_start(start); 
                        start = 1; 
                    end
                    begin 
                        enforce_stop(stop); 
                    end
                join_any
                disable fork_read_data;
                break;
            end 
        end
        transfer_complete = !ack;
    endtask

    task monitor ( output bit [I2C_ADDR_WIDTH-1:0] addr, output i2c_op_t op, output bit [I2C_DATA_WIDTH-1:0] data []);
        automatic bit [I2C_DATA_WIDTH-1:0] trans_data;
        automatic bit [I2C_DATA_WIDTH-1:0] q [$];
        automatic bit check = 0;
        automatic bit ack = 0;

        detect_start( start_monitor );
        get_address2( op, check, addr );
        @(posedge scl_s);
        if(!check) begin
            enforce_stop( stop_monitor );
        end else begin
            automatic bit hold = 0;
            do begin
                data_monitor = 0;
                fork : fork_in_monitor
                    begin   
						wait(hold); 
			    		detect_start( start_monitor ); 
						start_monitor = 1; 
					end

                    begin   
						wait(hold); 
						enforce_stop( stop_monitor ); 
					end

                    begin   
						obtain_data2( trans_data );
                        q.push_back( trans_data );
                        @(posedge scl_s);
                        data_monitor = 1;
                    end
                join_any
                disable fork_in_monitor;
                hold = 1;
            end while( data_monitor );
        end 
        data = new [ q.size() ];
        data = {>>{q}};
        // $display("DATA FROM MONITOR: %p", data);
    endtask

    task automatic detect_start( ref bit start_flag );
        while( !start_flag ) @(negedge sda_s) if(scl_s) start_flag = 1'b1;
        start_flag = 1'b0;
    endtask

     task automatic enforce_stop( ref bit stop_flag);
        while( !stop_flag) @(posedge sda_s) if(scl_s) stop_flag = 1'b1;
        stop_flag = 1'b0;
    endtask

     task automatic get_address( output i2c_op_t operation, output bit [I2C_ADDR_WIDTH-1:0] addr );
        automatic bit q[$];
        repeat(I2C_ADDR_WIDTH) @(posedge scl_s) begin q.push_back(sda_s); end
        addr = {>>{q}};
        @(posedge scl_s) operation = i2c_op_t'(sda_s);
    endtask

     task automatic obtain_data( output bit [I2C_DATA_WIDTH-1:0] data[$] );
        automatic bit q[$];
        repeat(I2C_DATA_WIDTH) @(posedge scl_s) begin q.push_back(sda_s); end
        data = {>>{q}};
    endtask

     task automatic gen_ack();
        @(negedge scl_s) begin 
            drive_sda <= 0; 
            ack_for_sda <= 0;
        end
        @(posedge scl_s);
    endtask

     task automatic read_given_data(input bit [I2C_DATA_WIDTH-1:0] data);
        // $display("%p", data);
        foreach(data[i]) begin
            @(negedge scl_s) ack_for_sda <= 1; drive_sda <= data[i];
        end
        // $display("EXITS READ_GIVEN_DATA");
    endtask

     task automatic read_given_data2(input bit [I2C_DATA_WIDTH-1:0] data);
        foreach(data[i]) begin
            @(negedge scl_s) ack_for_sda <= 1; drive_sda <= data[i];
        end
    endtask

     task automatic obtain_data2( output bit [I2C_DATA_WIDTH-1:0] data );
        automatic bit q[$];
        repeat(I2C_DATA_WIDTH) @(posedge scl_s) begin q.push_back(sda_s); end
        data = {>>{q}};
    endtask

     task automatic get_address2( output i2c_op_t operation, output bit ack_check , output bit [I2C_ADDR_WIDTH-1:0] addr );
        automatic bit q[$];
        repeat(I2C_ADDR_WIDTH) @(posedge scl_s) begin q.push_back(sda_s); end
        addr = {>>{q}};
        @(posedge scl_s) operation = i2c_op_t'(sda_s);
        ack_check = 1'b1;
    endtask


endinterface