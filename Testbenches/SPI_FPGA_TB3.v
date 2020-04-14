`timescale 1ns/1ps
module SPI_FPGA_TB3
#(
	parameter BIT_PER_SECOND			=	12500000,
	parameter CLOCK_FREQUENCY			=	50000000,
	parameter PACK_LENGTH				=	8,
	parameter CPOL							=	1'b0,
	parameter CPHA							=	1'b0,
	parameter CLKS_PER_BIT_LOG_2		=	$clog2(CLOCK_FREQUENCY/(BIT_PER_SECOND*2)),
	parameter PACK_LENGTH_LOG_2		=	$clog2(PACK_LENGTH),
	parameter MASTER_PACK_BIT_SEQUENCE_TRANSMIT=1,	//1-major bit forward;0-junior bit forward;
	parameter MASTER_PACK_BIT_SEQUENCE_RECEIVE=1,		//1-major bit forward;0-junior bit forward;
	parameter SLAVE_PACK_BIT_SEQUENCE_TRANSMIT=1,	//1-major bit forward;0-junior bit forward;
	parameter SLAVE_PACK_BIT_SEQUENCE_RECEIVE=1 	//1-major bit forward;0-junior bit forward;
);

	localparam PERIOD_IN_CLOCK_NS=1000000000/CLOCK_FREQUENCY;
	
	wire CS,	MISO,	MOSI, SCLK;
	reg [PACK_LENGTH-1:0]	IN_MASTER_DATA;
	reg IN_CLOCK_MASTER, IN_LAUNCH_MASTER;
	wire [PACK_LENGTH-1:0] OUT_MASTER_RECEIVE_DATA;
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
		IN_CLOCK_MASTER,
		IN_LAUNCH_MASTER,
		IN_MASTER_DATA,
		MISO,
		MOSI,
		CS,
		SCLK,
		OUT_MASTER_RECEIVE_DATA,
		OUT_MASTER_ACTION_DONE
	);
	reg IN_CLOCK_PWM, IN_RESET_PWM;
	SPI_SLAVE_PWM
	#(
		.CPHA(CPHA),
		.CPOL(CPOL),
		.PACK_LENGTH(PACK_LENGTH),
		.PACK_BIT_SEQUENCE_TRANSMIT(SLAVE_PACK_BIT_SEQUENCE_TRANSMIT),
		.PACK_BIT_SEQUENCE_RECEIVE(SLAVE_PACK_BIT_SEQUENCE_RECEIVE),
		.CLOCK_FREQUENCY(CLOCK_FREQUENCY)
	)
	SLAVE_PWM
	(
		IN_CLOCK_PWM,
		MOSI,
		CS,
		SCLK,
		IN_RESET_PWM,
		OUT_PWM_SIGNAL
	);
	
	initial begin
		//initial master
		IN_CLOCK_MASTER=1;
		IN_MASTER_DATA=0;
		IN_LAUNCH_MASTER=0;
		//initial PWM slave
		IN_RESET_PWM=0;
		IN_CLOCK_PWM=0;
	end
	always begin
		#(PERIOD_IN_CLOCK_NS/2);
		IN_CLOCK_MASTER=!IN_CLOCK_MASTER;
		IN_CLOCK_PWM=!IN_CLOCK_PWM;
	end
	reg start;
	initial begin
		start=0;
		#(PERIOD_IN_CLOCK_NS*10);
		IN_RESET_PWM=1;
		#(PERIOD_IN_CLOCK_NS*2);
		IN_RESET_PWM=0;
		#(PERIOD_IN_CLOCK_NS*6);
		start=1;
	end
	integer i=0;
	integer step=25;
	initial
	begin
		@(posedge start)
		forever 
		begin
			#(PERIOD_IN_CLOCK_NS*10);
			IN_MASTER_DATA=i;
			#(PERIOD_IN_CLOCK_NS*3);
			IN_LAUNCH_MASTER=1;
			@(negedge CS)
			#(PERIOD_IN_CLOCK_NS*3);
			IN_LAUNCH_MASTER=0;
			@(posedge CS)
			#(PERIOD_IN_CLOCK_NS*64);
			i=i+step;	
			if(i>255)
			begin
				#(PERIOD_IN_CLOCK_NS*500);
				i=0;
			end
		end
	end
endmodule
