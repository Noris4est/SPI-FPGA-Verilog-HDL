module SPI_SLAVE_PWM
#(
	parameter 	CPHA								=1,	//clock phase
	parameter	CPOL								=1,	//clock polarity
	parameter 	PACK_LENGTH 					=8,	//number of bits in package 
	parameter 	PACK_BIT_SEQUENCE_TRANSMIT	=1,	//1-major bit forward;0-junior bit forward;
	parameter 	PACK_BIT_SEQUENCE_RECEIVE	=1,	//1-major bit forward;0-junior bit forward;								
	parameter 	CLOCK_FREQUENCY				=50000000,
	parameter 	PWM_FREQUENCY					=CLOCK_FREQUENCY/(MAX_VALUE-1),
	parameter 	MAX_VALUE						=2**PACK_LENGTH-1,
	parameter 	DEEP_FILL_FACTOR				=PACK_LENGTH
)
(
	input IN_CLOCK,
	input MOSI,
	input CS,
	input IN_RESET,
	output OUT_PWM_SIGNAL
);
	wire IN_ENABLE;
	assign IN_ENABLE=1'b1;
	
	wire [DEEP_FILL_FACTOR-1:0] IN_PWM_FILL_FACTOR;
	wire [PACK_LENGTH-1:0] OUT_RECEIVE_DATA;
	assign IN_PWM_FILL_FACTOR=OUT_RECEIVE_DATA;
	
	assign IN_RESET_SLAVE=IN_RESET;
	assign IN_RESET_PWM=CS;
	
	PWM_FPGA
	#(
		.CLOCK_FREQUENCY(CLOCK_FREQUENCY),
		.PWM_FREQUENCY(PWM_FREQUENCY),
		.MAX_VALUE(MAX_VALUE),
		.DEEP_FILL_FACTOR(DEEP_FILL_FACTOR)
	)
	PWM_MODULE
	(
		IN_CLOCK,
		IN_RESET_PWM,
		IN_ENABLE,
		IN_PWM_FILL_FACTOR,
		OUT_PWM_SIGNAL
	);
	
	SPI_FPGA_SLAVE
	#(
		.CPHA(CPHA),
		.CPOL(CPOL),
		.PACK_LENGTH(PACK_LENGTH),
		.PACK_BIT_SEQUENCE_TRANSMIT(PACK_BIT_SEQUENCE_TRANSMIT),
		.PACK_BIT_SEQUENCE_RECEIVE(PACK_BIT_SEQUENCE_RECEIVE),
		
	)
	SLAVE_MODULE
	(
		IN_TRANSMIT_DATA,
		MOSI,
		CS,
		SCLK,
		IN_RESET_SLAVE,
		MISO,
		OUT_RECEIVE_DATA
	);
	

endmodule
