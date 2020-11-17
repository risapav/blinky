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

module top
(
// {ALTERA_ARGS_BEGIN} DO NOT REMOVE THIS LINE!

	sys_clk,

	// user interface
	button,
	led,
	sig,
	uA,uB

	
// {ALTERA_ARGS_END} DO NOT REMOVE THIS LINE!

);

// {ALTERA_IO_BEGIN} DO NOT REMOVE THIS LINE!
input			sys_clk;

input		[0:2]	button;
output	[0:3]	led;
output	[11:0] sig;
input 	[1:15] uA,uB;

	
// {ALTERA_IO_END} DO NOT REMOVE THIS LINE!
// {ALTERA_MODULE_BEGIN} DO NOT REMOVE THIS LINE!

	//reset generator
	wire	reset;
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
	reg [11:0] tmp = 1;
	
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

	always_comb begin
		tmp = {uA[2:7],uA[9:14]};
	end
	
	
//	assign sig = ~tmp;
	assign sig = tmp;
	//end of test clock

// {ALTERA_MODULE_END} DO NOT REMOVE THIS LINE!
endmodule

