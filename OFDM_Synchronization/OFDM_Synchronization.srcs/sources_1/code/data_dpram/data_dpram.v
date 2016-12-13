`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Neil Judson
// 
// Create Date: 2016/06/05 20:04:56
// Design Name: 
// Module Name: data_dpram
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


module data_dpram #(
	parameter SYNC_DATA_WIDTH	= 16,
	parameter RAM_ADDR_WIDTH	= 10
	)
	(
	axis_aclk			,
	axis_areset			,
	
	s_axis_ctrl_tvalid	,
	s_axis_ctrl_tlast	,
	s_axis_ctrl_tdata	,
	s_axis_ctrl_trdy	,
	
	s_axis_data_tvalid	,
	s_axis_data_tlast	,
	s_axis_data_tdata	,
	s_axis_data_trdy	,
	
	m_axis_ctrl_tvalid	,
	m_axis_ctrl_tlast	,
	m_axis_ctrl_tdata	,
	m_axis_ctrl_trdy	,
	
	m_axis_data_tvalid	,
	m_axis_data_tlast	,
	m_axis_data_tdata	, // [63:32]：延时数据，[31:0]：原始数据
	m_axis_data_trdy
    );
	input				axis_aclk			;
	input				axis_areset			;
	
	input				s_axis_ctrl_tvalid	;
	input				s_axis_ctrl_tlast	;
	input		[31:0]	s_axis_ctrl_tdata	;
	output				s_axis_ctrl_trdy	;
	
	input				s_axis_data_tvalid	;
	input				s_axis_data_tlast	;
	input		[31:0]	s_axis_data_tdata	;
	output	reg			s_axis_data_trdy	;
	
	output				m_axis_ctrl_tvalid	;
	output				m_axis_ctrl_tlast	;
	output		[31:0]	m_axis_ctrl_tdata	;
	input				m_axis_ctrl_trdy	;
	
	output				m_axis_data_tvalid	;
	output				m_axis_data_tlast	;
	output		[63:0]	m_axis_data_tdata	;
	input				m_axis_data_trdy	;
	
//================================================================================
// variable
//================================================================================
	localparam	DPRAM_ADDR_WIDTH	= 10;
	localparam	DPRAM_DATA_WIDTH	= 36;
	// sync_state
	localparam	SYNC_IDLE			= 3'd0,
				SYNC_COARSE_SEARCH	= 3'd1,
				SYNC_COARSE_DONE	= 3'd2,
				SYNC_FINE_SEARCH	= 3'd3,
				SYNC_FINE_DONE		= 3'd4,
				SYNC_DATA_OUTPUT	= 3'd5;
	
	wire	[2:0]					sync_state			;
	
	reg								u1_dpram_wea		;
	reg		[DPRAM_ADDR_WIDTH-1:0]	u1_dpram_addra_wr	;
	reg		[DPRAM_ADDR_WIDTH-1:0]	u1_dpram_addra_rd	;
	wire	[DPRAM_ADDR_WIDTH-1:0]	u1_dpram_addra		;
	reg		[DPRAM_DATA_WIDTH-1:0]	u1_dpram_dina		;
	wire	[DPRAM_DATA_WIDTH-1:0]	u1_dpram_douta		;
	reg		[DPRAM_ADDR_WIDTH-1:0]	u1_dpram_addrb		;
	wire	[DPRAM_DATA_WIDTH-1:0]	u1_dpram_doutb		;
	
	reg								u1_dpram_wea_dly1	;
	reg								u1_dpram_wea_dly2	;
	reg								u1_dpram_wea_dly3	;
	
/* 	wire							u2_dpram_wea		;
	wire	[9:0]					u2_dpram_addra		;
	wire	[31:0]					u2_dpram_dina		;
	wire	[31:0]					u2_dpram_douta		;
	reg		[9:0]					u2_dpram_addrb		;
	wire	[31:0]					u2_dpram_doutb		;
*/
	wire							u3_data_valid		;
	wire	[4*SYNC_DATA_WIDTH-1:0]	u3_data				;
	wire							u3_almost_full		;
	
//================================================================================
// s_axis_ctrl_tdata
//================================================================================
	// assign sync_state = s_axis_ctrl_tdata[2:0];
	
//================================================================================
// coarse synchronization
//================================================================================
	always @(posedge axis_aclk or posedge axis_areset) begin
		if(axis_areset == 1'b1) begin
			u1_dpram_wea		<= 1'b0;
			u1_dpram_addra_wr	<= 'd0;
			u1_dpram_dina		<= 'd0;
		end
		else if(s_axis_data_tvalid == 1'b1) begin
			u1_dpram_wea		<= 1'b1;
			u1_dpram_addra_wr	<= u1_dpram_addra_wr + 1'd1;
			u1_dpram_dina		<= {{(DPRAM_DATA_WIDTH-32){1'b0}},s_axis_data_tdata};
		end
		else begin
			u1_dpram_wea		<= 1'b0;
			u1_dpram_addra_wr	<= u1_dpram_addra_wr;
			u1_dpram_dina		<= {{(DPRAM_DATA_WIDTH-32){1'b0}},s_axis_data_tdata};
			end
	end
	
	always @(posedge axis_aclk or posedge axis_areset) begin
		if(axis_areset == 1'b1) begin
			u1_dpram_addra_rd <= 10'd0;
		end 
		else if(s_axis_data_tvalid == 1'b1) begin
			u1_dpram_addra_rd <= u1_dpram_addra_wr - 10'd2;
		end
		else begin
			u1_dpram_addra_rd <= u1_dpram_addra_rd;
		end
	end
	
	assign u1_dpram_addra = (u1_dpram_wea == 1'b1) ? u1_dpram_addra_wr : u1_dpram_addra_rd;
	
	always @(posedge axis_aclk or posedge axis_areset) begin
		if(axis_areset == 1'b1) begin
			u1_dpram_addrb <= 10'd0;
		end 
		else if(s_axis_data_tvalid == 1'b1) begin
			u1_dpram_addrb <= u1_dpram_addra_rd - 10'd31;
		end
		else begin
			u1_dpram_addrb <= u1_dpram_addrb;
		end
	end
	
	dpram_36_1024_ip u1_dpram_36_1024_ip (
		.clka	(axis_aclk		),	// input clka;
		.wea	(u1_dpram_wea	),	// input [0:0]wea;
		.addra	(u1_dpram_addra	),	// input [9:0]addra;
		.dina	(u1_dpram_dina	),	// input [35:0]dina;
		.douta	(u1_dpram_douta	),	// output [35:0]douta;
		.clkb	(axis_aclk		),	// input clkb;
		.web	(1'b0			),	// input [0:0]web;
		.addrb	(u1_dpram_addrb	),	// input [9:0]addrb;
		.dinb	('d0			),	// input [35:0]dinb;
		.doutb	(u1_dpram_doutb	)	// output [35:0]doutb;
	);
	
	always @(posedge axis_aclk or posedge axis_areset) begin
		if(axis_areset == 1'b1) begin
			u1_dpram_wea_dly1	<= 1'b0;
			u1_dpram_wea_dly2	<= 1'b0;
			// u1_dpram_wea_dly3	<= 1'b0;
		end
		else begin
			u1_dpram_wea_dly1	<= u1_dpram_wea;
			u1_dpram_wea_dly2	<= u1_dpram_wea_dly1;
			// u1_dpram_wea_dly3	<= u1_dpram_wea_dly2;
		end
	end
	
/*
//================================================================================
// fine syn & syn data output
//================================================================================
	assign u2_dpram_wea = u1_dpram_wea;
	assign u2_dpram_addra = u1_dpram_addra_wr;
	assign u2_dpram_dina = u1_dpram_dina;
	
	always @(posedge axis_aclk or posedge axis_areset) begin
		if(axis_areset == 1'b1) begin
			u2_dpram_addrb <= 10'd0;
		end
		else begin
			case(sync_state)
				SYNC_COARSE_DONE: begin
					u2_dpram_addrb <= coarse_sync_addr;
				end
				SYNC_FINE_SEARCH: begin
					u2_dpram_addrb <= u2_dpram_addrb + 10'd1;
				end
				SYNC_FINE_DONE: begin
					u2_dpram_addrb <= fine_sync_addr;
				end
				SYNC_DATA_OUTPUT: begin
					u2_dpram_addrb <= u2_dpram_addrb + 10'd1;
				end
				default: begin
					u2_dpram_addrb <= 10'd0;
				end
			endcase
		end
	end
	
	dpram_1024_ip u2_dpram_1024_ip (
		.clka	(axis_aclk		),	// input wire clka
		.wea	(u2_dpram_wea	),	// input wire [0 : 0] wea
		.addra	(u2_dpram_addra	),	// input wire [9 : 0] addra
		.dina	(u2_dpram_dina	),	// input wire [31 : 0] dina
		.douta	(u2_dpram_douta	),	// output wire [31 : 0] douta
		.clkb	(axis_aclk		),	// input wire clkb
		.web	(1'b0			),	// input wire [0 : 0] web
		.addrb	(u2_dpram_addrb	),	// input wire [9 : 0] addrb
		.dinb	(32'd0			),	// input wire [31 : 0] dinb
		.doutb	(u2_dpram_doutb	)	// output wire [31 : 0] doutb
	);
*/
	
	always @(posedge axis_aclk or posedge axis_areset) begin
		if(axis_areset == 1'b1) begin
			s_axis_data_trdy <= 1'b0;
		end
		else if(u3_almost_full != 1'b1) begin
			s_axis_data_trdy <= 1'b1;
		end
		else begin
			s_axis_data_trdy <= 1'b0;
		end
	end
	
//================================================================================
// axis_interface_fifo
//================================================================================
	assign u3_data_valid	= u1_dpram_wea_dly2;
	assign u3_data			= {u1_dpram_doutb[2*SYNC_DATA_WIDTH-1:0],u1_dpram_douta[2*SYNC_DATA_WIDTH-1:0]};
	
	axis_interface_fifo #(
		.DATA_IN_WIDTH		(4*SYNC_DATA_WIDTH	),
		.DATA_OUT_WIDTH		(64					)
	)u3_axis_interface_fifo(
		.axis_aclk			(axis_aclk			),
		.axis_areset		(axis_areset		),
		.data_valid			(u3_data_valid		),
		.data_last			(1'b0				),
		.data				(u3_data			), // [63:32]：延时数据，[31:0]：原始数据
		.almost_full		(u3_almost_full		),
		.m_axis_data_tvalid	(m_axis_data_tvalid	),
		.m_axis_data_tlast	(m_axis_data_tlast	),
		.m_axis_data_tdata	(m_axis_data_tdata	),
		.m_axis_data_trdy	(m_axis_data_trdy	)
	);
	
endmodule
