module SPI_SLAVE_BOT_1_LATE_DATA_REFLECTOR
#(
	parameter CPHA				=1,	//clock phase
	parameter CPOL				=1,	//clock polarity
	parameter PACK_LENGTH 	=8,	//number of bits in package 
	parameter PACK_BIT_SEQUENCE_TRANSMIT=1,//1-major bit forward;0-junior bit forward;
	parameter PACK_BIT_SEQUENCE_RECEIVE=1//1-major bit forward;0-junior bit forward;
)
(
	input wire MOSI,
	input wire CS,
	input wire SCLK,
	input wire IN_RESET,
	output wire MISO
);
	reg [PACK_LENGTH-1:0]	REG_DATA;
	initial begin
		REG_DATA=0;
	end
	wire [PACK_LENGTH-1:0]	OUT_RECEIVE_DATA,IN_TRANSMIT_DATA;
	
		
	SPI_FPGA_SLAVE
	#(
		.CPHA(CPHA),
		.CPOL(CPOL),
		.PACK_LENGTH(PACK_LENGTH),
		.PACK_BIT_SEQUENCE_TRANSMIT(PACK_BIT_SEQUENCE_TRANSMIT),
		.PACK_BIT_SEQUENCE_RECEIVE(PACK_BIT_SEQUENCE_RECEIVE)
	)
	SLAVE
	(
		IN_TRANSMIT_DATA,
		MOSI,
		CS,
		SCLK,
		IN_RESET,
		MISO,
		OUT_RECEIVE_DATA
	);
	
	always @(posedge CS)
	begin
		REG_DATA<=OUT_RECEIVE_DATA;
	end
	assign IN_TRANSMIT_DATA = REG_DATA;
endmodule 
