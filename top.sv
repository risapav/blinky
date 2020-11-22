// Copyright (C) 1991-2013 Altera Corporation
// Your use of Altera Corporation's design tools, logic functions 
// and other software and tools, and its AMPP partner logic 
// functions, and any output files from any of the foregoing 
// (including device programming or simulation files), and any 
// associated documentation or information are expressly subject 
// to the terms and conditions of the Altera Program License 
// Subscription Agreement, Altera MegaCore Function License 
// Agreement, or other applicable license agreement, including, 
// without limitation, that your use is for the sole purpose of 
// programming logic devices manufactured by Altera and sold by 
// Altera or its authorized distributors.  Please refer to the 
// applicable agreement for further details.


//module Test05_project_CP2102_UART (
//    input sys_clk,
//    input sys_rst_n,
//    input uart_rx,
//    output uart_tx
//    );
//
//wire [7:0] uart_rx_data_o;
//wire uart_rx_done;
//
//uart_rx_path uart_rx_path_u (
//    .clk_i(sys_clk), 
//    .uart_rx_i(uart_rx), 
//    .uart_rx_data_o(uart_rx_data_o), 
//    .uart_rx_done(uart_rx_done)
//    );
//
//uart_tx_path uart_tx_path_u (
//    .clk_i(sys_clk), 
//    .uart_tx_data_i(uart_rx_data_o), 
//    .uart_tx_en_i(uart_rx_done), 
//    .uart_tx_o(uart_tx)
//    );
//
//endmodule

//'include "uart.sv"

module NumToBin(
	input logic clk,
	input logic tr_enable, 
	input logic [15:0] number,

	output logic finished,
	output logic [7:0] char
);

	logic [5:0] i=0;
	logic [15:0] num;
	logic completed = 1'b1;
	
	always_ff @(negedge clk) begin
		if(tr_enable && completed) begin
			completed <= ~completed;
			num <= number;
			i <= 19;
		end
		if(!completed) begin
			case(i)
				0:
					completed <= 1'b1;
				1:
					char <= 8'h0D;
				2:
					char <= 8'h0C;
				19: 
					char <= 8'h0D;
				default: 
					char <= 8'h30 + num[i] ;					
			endcase
			i <= i - 1;
		end
	end
	assign finished = completed;
endmodule


module top
(
// {ALTERA_ARGS_BEGIN} DO NOT REMOVE THIS LINE!

	sys_clk,
	uart_tx, uart_rx,
	// user interface
	button,
	led,
	SDRAM_A, SDRAM_DQ,
	sig,
//	uA,uB,uC
	uJ

	
// {ALTERA_ARGS_END} DO NOT REMOVE THIS LINE!

);

// {ALTERA_IO_BEGIN} DO NOT REMOVE THIS LINE!
input			sys_clk;
output uart_tx;
input uart_rx;

input SDRAM_A[12:0];
input SDRAM_DQ[15:0];

input		[0:2]	button;
output	[0:3]	led;
output	[11:0] sig;
//input 	[15:1] uA,uB;
input 	[16:1] uJ;

	
// {ALTERA_IO_END} DO NOT REMOVE THIS LINE!
// {ALTERA_MODULE_BEGIN} DO NOT REMOVE THIS LINE!

	//reset generator
	wire reset;
	wire blik;
	
	PushButton_Debouncer button_reset(
		.clk(sys_clk),
		.PB(button[0]),
		.PB_state(reset)
	);
	
	assign led[3] = reset;
	//end of reset
	

	Divider	#( 
		.DIVISOR(50000000) 
	) 
	blinky(
		.sig_in(sys_clk),
		.sig_out(blik)
	);
	
	assign led[0] = blik;
	logic [15:0] tmp = 0;
	logic [15:0] last = 0;
	
	
	assign tmp[0] = blik;
	//uart ///////////////////////
	
//	Test05_project_CP2102_UART uart (
//    .sys_clk,
//    .sys_rst_n(reset),
//    .uart_rx,
//    .uart_tx
//    );
	 
//	//	simple adder
//	always_ff @(posedge sys_clk, posedge reset)begin
//		tmp <= tmp + 12'd1;
//	end
	
	
	//	simple shifter
//	always_ff @(negedge blik) begin
//		if(reset)begin
//			tmp = 1;
//			end 
//		else begin
//			tmp <= {tmp[10:0],tmp[11]};
//			end
//
//	end

//	always_comb begin
////		tmp = {uA[14],uA[13],uA[12],uA[11],uA[10],uA[9],uA[7],uA[6],uA[5],uA[4],uA[3],uA[2]};	
////		tmp = {uB[14],uB[13],uB[12],uB[11],uB[10],uB[9],uB[7],uB[6],uB[5],uB[4],uB[3],uB[1]};
////		tmp = {uC[16],1'b0,uC[14],1'b0,uC[9],uC[8],1'b0,1'b0,1'b0,uC[3],uC[2],1'b0};
//
//		tmp = {uJ[16],1'b0,uJ[14],uJ[13],uJ[12],uJ[11],uJ[6],uJ[2],uJ[1],3'b000};
//	end
	
	
//	assign sig = ~tmp;
//	assign sig = {1'b0,11'b1};
//	assign sig = tmp;
	
	logic tr_enable;
	always_ff @(posedge sys_clk)
		if(tmp != last) begin
			last <= tmp;
			tr_enable <= 1'b1;
		end else
			tr_enable <= 1'b0;
			
	logic finished;
	logic [7:0] char;
	
	NumToBin numtobin(
		.clk(sys_clk),
		.tr_enable, 
		.number(last),
		.finished,
		.char
	);
	
//	////////////////////
//	logic [7 : 0] data_out;
//	logic [3 : 0] data_count;
//	logic empty;
//	logic full;
//	logic almst_empty;
//	logic almst_full;
//	logic	err;
//	logic [7 : 0] data_in;
//	logic wr_en;
//	logic rd_en;
//	
//	FIFO_v #(
//		.ADDR_W( 32), 
//		.DATA_W( 8)
//		) 
//	fifo (
//		.clk(sys_clk),
//		.n_reset(~reset),
//		.data_in,
//		.empty,
//		.full,
//		.data_out,
//		.rd_en,
//		.wr_en
//	);
	

	
//	always_ff @(posedge sys_clk)
//		if(tx_fifo_wr_en)
//			tx_fifo_data_i <= rx_fifo_data_o;
	//end of test clock
/*****************************************************************************
 *                           Constant Declarations                           *
 *****************************************************************************/

/*****************************************************************************
 *                 Internal Wires and Registers Declarations                 *
 *****************************************************************************/
 
	logic	from_uart_error_o;
	logic	from_uart_valid_o;
 	logic	from_uart_ready_i;
	logic	[7:0] from_uart_data_o;
	
	logic	[7:0] to_uart_data_i;
	logic	to_uart_error_i;
	logic	to_uart_valid_i;
	logic	to_uart_ready_o;	
	
/*****************************************************************************
 *                         Finite State Machine(s)                           *
 *****************************************************************************/
 
/*****************************************************************************
 *                             Sequential Logic                              *
 *****************************************************************************/
	
/*****************************************************************************
 *                            Combinational Logic                            *
 *****************************************************************************/
 
assign to_uart_data_i = from_uart_data_o;
assign to_uart_valid_i = from_uart_valid_o;
assign led[1] =  from_uart_data_o;

assign sig = {from_uart_data_o,from_uart_valid_o, to_uart_ready_o, from_uart_error_o};

/*****************************************************************************
 *                              Internal Modules                             *
 *****************************************************************************/
 
 Uart #( 
		.ADDR_W( 32), 
		.DATA_W( 8)	
	) uart(
	.clk(sys_clk), 
	.reset(reset),
	.UART_TXD(uart_tx),
	.UART_RXD(uart_rx),
	.from_uart_ready_i,
	.from_uart_data_o,
	.from_uart_error_o,
	.from_uart_valid_o,
	.to_uart_data_i,
	.to_uart_error_i,
	.to_uart_valid_i,
	.to_uart_ready_o
 );
 
// {ALTERA_MODULE_END} DO NOT REMOVE THIS LINE!
endmodule

