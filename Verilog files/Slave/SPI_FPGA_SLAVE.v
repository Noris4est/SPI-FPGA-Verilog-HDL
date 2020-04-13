module SPI_FPGA_SLAVE
#(
	parameter CPHA				=0,
	parameter CPOL				=0,
	parameter PACK_LENGTH 	=8,
	parameter PACK_LENGTH_LOG_2=$clog2(PACK_LENGTH)
)
(
	input			 	[PACK_LENGTH-1:0] 	IN_TRANSMIT_DATA,
	input 										MOSI,
	input 										CS,
	input 										SCLK,
	input 										IN_RESET,
	output wire									MISO,
	output wire										OUT_DATA_READY,
	output wire			[PACK_LENGTH-1:0]		OUT_RECEIVE_DATA
	);
	
	wire [PACK_LENGTH-1:0] IN_TRANSMIT_DATA_0_0;
	wire [PACK_LENGTH-1:0] OUT_RECEIVE_DATA_0_0;
	wire MISO_0_0;
	wire MOSI_0_0;
	wire CS_0_0;
	wire SCLK_0_0;
	wire OUT_DATA_READY_0_0;
	wire IN_RESET_0_0;
	
	
	wire [PACK_LENGTH-1:0] IN_TRANSMIT_DATA_0_1;
	wire [PACK_LENGTH-1:0] OUT_RECEIVE_DATA_0_1;
	wire MISO_0_1;
	wire MOSI_0_1;
	wire CS_0_1;
	wire SCLK_0_1;
	wire OUT_DATA_READY_0_1;
	wire IN_RESET_0_1;
	
	
	
	
	SPI_FPGA_SLAVE_CPHA_EQ_0_CPOL_EQ_0 
	#(
	.PACK_LENGTH(PACK_LENGTH)
	)
	SLAVE_0_0
	(
	IN_TRANSMIT_DATA_0_0,
	MOSI_0_0,
	CS_0_0,
	SCLK_0_0,
	IN_RESET_0_0,
	MISO_0_0,
	OUT_DATA_READY_0_0,
	OUT_RECEIVE_DATA_0_0
	);
	
	SPI_FPGA_SLAVE_CPHA_EQ_0_CPOL_EQ_1
	#(
	.PACK_LENGTH(PACK_LENGTH)
	)
	SLAVE_0_1
	(
	IN_TRANSMIT_DATA_0_1,
	MOSI_0_1,
	CS_0_1,
	SCLK_0_1,
	IN_RESET_0_1,
	MISO_0_1,
	OUT_DATA_READY_0_1,
	OUT_RECEIVE_DATA_0_1
	);
	
	assign IN_TRANSMIT_DATA_0_0=IN_TRANSMIT_DATA;
	assign MOSI_0_0=MOSI	;
	assign CS_0_0=CS	;
	assign SCLK_0_0=SCLK;
	assign IN_RESET_0_0=IN_RESET;
	assign MISO=MISO_0_0&(!CPHA)&(!CPOL) |
	MISO_0_1&(!CPHA)&(CPOL);		//тут будут добваления 
	assign OUT_DATA_READY=
	OUT_DATA_READY_0_0*(!CPHA)*(!CPOL) +
	OUT_DATA_READY_0_1*(!CPHA)*(CPOL) ;//тут будут добваления 
	assign OUT_RECEIVE_DATA=
	OUT_RECEIVE_DATA_0_0*(!CPHA)*(!CPOL) +
	OUT_RECEIVE_DATA_0_1*(!CPHA)*(CPOL);//тут будут добваления 
endmodule
