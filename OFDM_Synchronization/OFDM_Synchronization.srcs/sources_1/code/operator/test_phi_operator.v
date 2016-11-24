`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Neil Judson
// 
// Create Date: 2016/11/21 20:34:29
// Design Name: 
// Module Name: test_phi_operator
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module test_phi_operator;

	// Inputs
	reg clk;
	reg reset;
	reg i_start_work;
	reg i_stop_work;
	reg i_data_valid;
	reg [31:0] i_data;

	// Outputs
	wire o_data_valid;
	wire [33:0] o_data;
	
	reg [39:0] count;

	// Instantiate the Unit Under Test (UUT)
	phi_operator #(
		.SYNC_DATA_WIDTH(16)
	)uut(
		.clk(clk), 
		.reset(reset), 
		.i_start_work(i_start_work),
		.i_stop_work(i_stop_work),
		.i_data_valid(i_data_valid), 
		.i_data(i_data), 
		.o_data_valid(o_data_valid), 
		.o_data(o_data)
	);

	initial begin
		// Initialize Inputs
		clk = 0;
		reset = 0;
		i_start_work = 0;
		i_stop_work = 0;
		i_data_valid = 0;
		i_data = 0;

		// Wait 100 ns for global reset to finish
		#10;
		reset = 1;
		#10;
		reset = 0;
		#10;
		i_start_work =1;
		#10;
        
		// Add stimulus here

	end
	
	always
		#5 clk = ~clk;
	
	always @(posedge clk or posedge reset) begin
		if(reset == 1'b1) begin
			count <= 40'd0;
		end
		else begin
			count <= count + 1'd1;
		end
	end
	
	always @(posedge clk or posedge reset) begin
		if(reset == 1'b1) begin
			i_data_valid	<= 1'b0;
			i_data			<= 32'd0;
		end
		else if(count[2:0] == 3'd7) begin
			i_data_valid	<= 1'b1;
			i_data			<= count[34:3];
		end
		else begin
			i_data_valid	<= 1'b0;
			i_data			<= i_data;
		end
	end
	
	
	
      
endmodule