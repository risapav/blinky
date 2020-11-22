`include "uart_tx.sv"
`include "uart_rx.sv"
`include "../buffer/fifo.sv"

module Uart
# (
	parameter BAUD_DIV     = 13'd5208, //Hodiny prenosovej rýchlosti, 9600 b / s, 50 MHz / 9600 = 5208, prenosová rýchlosť je nastaviteľná
	parameter BAUD_DIV_CAP = 13'd2604, //Stredný bod vzorkovania hodín prenosovej rýchlosti, 50 MHz / 9600/2 = 2604, prenosová rýchlosť je nastaviteľná
	parameter ADDR_W = 4, DATA_W = 24
	)
(
	clk,
	reset,
	UART_RXD,
	UART_TXD,
	from_uart_ready_i,
	from_uart_data_o,
	from_uart_error_o,
	from_uart_valid_o,
	to_uart_data_i,
	to_uart_error_i,
	to_uart_valid_i,
	to_uart_ready_o
	);	

/*****************************************************************************
 *                           Parameter Declarations                          *
 *****************************************************************************/

parameter CW							= 0;		// Baud counter width
parameter BAUD_TICK_COUNT			= 0;
parameter HALF_BAUD_TICK_COUNT	= 0;

parameter TDW							= 10;		// Total data width
parameter DW							= 8;		// Data width
parameter ODD_PARITY					= 1'b0;

/*****************************************************************************
 *                             Port Declarations                             *
 *****************************************************************************/
// Inputs
	input	clk;
	input	reset;
	input	UART_RXD;
	
	input	[7:0] to_uart_data_i;
	input	to_uart_error_i;
	input	to_uart_valid_i;
	output to_uart_ready_o;	
// Outputs
	output UART_TXD;
	output [7:0] from_uart_data_o;
	input	from_uart_ready_i;
	output from_uart_error_o;
	output from_uart_valid_o;
	
/*****************************************************************************
 *                           Constant Declarations                           *
 *****************************************************************************/

/*****************************************************************************
 *                 Internal Wires and Registers Declarations                 *
 *****************************************************************************/

// Internal Wires
	logic uart_rx_done;
	logic uart_tx_en_i;
	
	logic rx_fifo_wr_en;
	logic rx_fifo_rd_en;
	logic rx_fifo_empty;
	logic rx_fifo_full;	

	logic tx_fifo_wr_en;
	logic tx_fifo_rd_en;
	logic tx_fifo_empty;
	logic tx_fifo_full;
	
// Internal Registers
	logic [7:0] rx_fifo_data_o;
	logic [7:0] uart_tx_data_i;
	logic [7:0] uart_rx_data_o;
	logic [7:0] tx_fifo_data_i;
	

// State Machine Registers

/*****************************************************************************
 *                         Finite State Machine(s)                           *
 *****************************************************************************/
 
/*****************************************************************************
 *                             Sequential Logic                              *
 *****************************************************************************/
// always_ff @(negedge clk) begin
// 
// end 
// 
// 	assign tx_fifo_rd_en = !tx_fifo_empty; 
//	assign from_uart_valid_o = !rx_fifo_empty & from_uart_ready_i;
//	assign rx_fifo_rd_en = !rx_fifo_empty & from_uart_ready_i;
//	
//	assign to_uart_ready_o = !tx_fifo_full;
//	assign rx_fifo_wr_en = !rx_fifo_full & uart_rx_done;
//	assign tx_fifo_wr_en = !tx_fifo_full & to_uart_valid_i;
//	assign uart_tx_en_i = !tx_fifo_empty;	
/*****************************************************************************
 *                            Combinational Logic                            *
 *****************************************************************************/
	
 assign tx_fifo_rd_en = !tx_fifo_empty; 
	assign from_uart_valid_o = !rx_fifo_empty & from_uart_ready_i;
	assign rx_fifo_rd_en = !rx_fifo_empty & from_uart_ready_i;
	
	assign to_uart_ready_o = !tx_fifo_full;
	assign rx_fifo_wr_en = !rx_fifo_full & uart_rx_done;
	assign tx_fifo_wr_en = !tx_fifo_full & to_uart_valid_i;
	assign uart_tx_en_i = !tx_fifo_empty;
	
/*****************************************************************************
 *                              Internal Modules                             *
 *****************************************************************************/
	// uart transmiter
	// transmit FIFO buffer

	FIFO_v #( 
		.ADDR_W( ADDR_W), 
		.DATA_W( DATA_W)	
		) 
	tx_fifo (
		.clk,
		.n_reset(~reset),
		.data_in(to_uart_data_i),
		.empty(tx_fifo_empty),
		.full(tx_fifo_full),
		.data_out(uart_tx_data_i),
		.rd_en(tx_fifo_rd_en),
		.wr_en(tx_fifo_wr_en)
	); 
	
	uart_tx_path  #(
		.BAUD_DIV(BAUD_DIV),
		.BAUD_DIV_CAP(BAUD_DIV_CAP)
		
	) uart_tx_path_u (
    .clk_i(clk), 
    .uart_tx_data_i, 
    .uart_tx_en_i, 
    .uart_tx_o(UART_TXD)
    );

	//uart receiver
	//receive char and put into FIFO buffer
	 
	FIFO_v #( 
		.ADDR_W( ADDR_W), 
		.DATA_W( DATA_W)	
	) rx_fifo (
		.clk,
		.n_reset(~reset),
		.data_in(uart_rx_data_o),
		.empty(rx_fifo_empty),
		.full(rx_fifo_full),
		.data_out(from_uart_data_o),
		.rd_en(rx_fifo_rd_en),
		.wr_en(rx_fifo_wr_en)
	); 

	uart_rx_path #(
		.BAUD_DIV(BAUD_DIV),
		.BAUD_DIV_CAP(BAUD_DIV_CAP)	
	) uart_rx_path_u (
		.clk_i(clk), 
		.uart_rx_i(UART_RXD), 
		.uart_rx_data_o, 
		.uart_rx_done
		);
		
 
endmodule