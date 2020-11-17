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
	led
	// spi interface

	
// {ALTERA_ARGS_END} DO NOT REMOVE THIS LINE!

);

// {ALTERA_IO_BEGIN} DO NOT REMOVE THIS LINE!
input			sys_clk;

input		[0:2]	button;
output	[0:3]	led;

	
// {ALTERA_IO_END} DO NOT REMOVE THIS LINE!
// {ALTERA_MODULE_BEGIN} DO NOT REMOVE THIS LINE!

	//reset generator
	wire	reset;
	
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
		.sig_out(led[0])
	);
	//end of test clock

// {ALTERA_MODULE_END} DO NOT REMOVE THIS LINE!
endmodule

