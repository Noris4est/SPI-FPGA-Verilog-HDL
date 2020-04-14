`timescale 1ns/1ps
module SPI_FPGA_TB1_CPOL_EQ_0_CPHA_EQ_1_M_TO_S_EQ_0_S_TO_M_EQ_1
#(
	parameter BIT_PER_SECOND			=	12500000,
	parameter CLOCK_FREQUENCY			=	50000000,
	parameter PACK_LENGTH				=	8,
	parameter CPOL							=	1'b0,
	parameter CPHA							=	1'b1,
	parameter CLKS_PER_BIT_LOG_2		=	$clog2(CLOCK_FREQUENCY/(BIT_PER_SECOND*2)),
	parameter PACK_LENGTH_LOG_2		=	$clog2(PACK_LENGTH),
	parameter MASTER_PACK_BIT_SEQUENCE_TRANSMIT=0,	//1-major bit forward;0-junior bit forward;
	parameter MASTER_PACK_BIT_SEQUENCE_RECEIVE=1,		//1-major bit forward;0-junior bit forward;
	parameter SLAVE_PACK_BIT_SEQUENCE_TRANSMIT=1,	//1-major bit forward;0-junior bit forward;
	parameter SLAVE_PACK_BIT_SEQUENCE_RECEIVE=0 	//1-major bit forward;0-junior bit forward;
);

	localparam PERIOD_IN_CLOCK_NS=1000000000/CLOCK_FREQUENCY;
	
	wire CS,	MISO,	MOSI, SCLK;
	reg [PACK_LENGTH-1:0]	IN_MASTER_DATA;
	wire [PACK_LENGTH-1:0]	OUT_MASTER_RECEIVE_DATA;
	reg IN_CLOCK, IN_LAUNCH;
	SPI_FPGA_MASTER
	#(
		.BIT_PER_SECOND(BIT_PER_SECOND),
		.CLOCK_FREQUENCY(CLOCK_FREQUENCY),
		.PACK_LENGTH(PACK_LENGTH),
		.CPOL(CPOL),
		.CPHA(CPHA),
		.PACK_BIT_SEQUENCE_TRANSMIT(MASTER_PACK_BIT_SEQUENCE_TRANSMIT),
		.PACK_BIT_SEQUENCE_RECEIVE(MASTER_PACK_BIT_SEQUENCE_RECEIVE)
	)
	MASTER
	(
		IN_CLOCK,
		IN_LAUNCH,
		IN_MASTER_DATA,
		MISO,
		MOSI,
		CS,
		SCLK,
		OUT_MASTER_RECEIVE_DATA,
		OUT_MASTER_ACTION_DONE
	);

	reg [PACK_LENGTH-1:0]	IN_SLAVE_TRANSMIT_DATA;
	wire [PACK_LENGTH-1:0]	OUT_SLAVE_RECEIVE_DATA;
	reg IN_SLAVE_RESET;
	SPI_FPGA_SLAVE
	#(
		.CPHA(CPHA),
		.CPOL(CPOL),
		.PACK_LENGTH(PACK_LENGTH),
		.PACK_BIT_SEQUENCE_TRANSMIT(SLAVE_PACK_BIT_SEQUENCE_TRANSMIT),
		.PACK_BIT_SEQUENCE_RECEIVE(SLAVE_PACK_BIT_SEQUENCE_RECEIVE)
	)
	SLAVE
	(
		IN_SLAVE_TRANSMIT_DATA,
		MOSI,
		CS,
		SCLK,
		IN_SLAVE_RESET,
		MISO,
		OUT_SLAVE_RECEIVE_DATA
	);
	
	initial begin
		//initial master
		IN_CLOCK=0;
		IN_MASTER_DATA=0;
		IN_LAUNCH=0;
		//initial slave
		IN_SLAVE_TRANSMIT_DATA=0;
		IN_SLAVE_RESET=0;
	end
	always begin
		#(PERIOD_IN_CLOCK_NS/2);
		IN_CLOCK=!IN_CLOCK;
	end
	event start;
	initial begin
		#(PERIOD_IN_CLOCK_NS*10);
		IN_SLAVE_RESET=1;
		#(PERIOD_IN_CLOCK_NS*3);
		IN_SLAVE_RESET=0;
		#(PERIOD_IN_CLOCK_NS*5);
		->start;
	end
	initial begin
		@(start)
		IN_MASTER_DATA=8'b11101010;
		#(PERIOD_IN_CLOCK_NS*3);
		IN_SLAVE_TRANSMIT_DATA=8'b01010011;
		#(PERIOD_IN_CLOCK_NS*3);
		IN_LAUNCH=1;
		@(negedge CS)
		#(PERIOD_IN_CLOCK_NS*5);
		IN_LAUNCH=0;
	end	
endmodule