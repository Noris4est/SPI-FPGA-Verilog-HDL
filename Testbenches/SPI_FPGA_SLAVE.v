module SPI_FPGA_SLAVE
#(
	parameter CPHA				=1,					//clock phase
	parameter CPOL				=1,					//clock polarity
	parameter PACK_LENGTH 	=8,					//number of bits in package 
	parameter PACK_BIT_SEQUENCE_TRANSMIT=1,	//1-major bit forward;0-junior bit forward;
	parameter PACK_BIT_SEQUENCE_RECEIVE=1,		//1-major bit forward;0-junior bit forward;
	parameter PACK_LENGTH_LOG_2=$clog2(PACK_LENGTH)
)
/*
		It is important that the PACK_BIT_SEQUENCE_TRANSMIT 
		characteristic of the master device matches the
		PACK_BIT_SEQUENCE_RECEIVE characteristic of the slave device 
		and, obviously, the PACK_BIT_SEQUENCE_RECEIVE master characteristic 
		coincides with the PACK_BIT_SEQUENCE_TRANSMIT
		characteristic of the slave device
*/
(
	input			 	[PACK_LENGTH-1:0] 	IN_TRANSMIT_DATA,
	input 										MOSI,
	input 										CS,
	input 										SCLK,
	input 										IN_RESET,
	output wire									MISO,
	output wire		[PACK_LENGTH-1:0]		OUT_RECEIVE_DATA
	);
	
	wire [PACK_LENGTH-1:0] IN_TRANSMIT_DATA_0_0;
	wire [PACK_LENGTH-1:0] OUT_RECEIVE_DATA_0_0;
	wire MISO_0_0;
	wire MOSI_0_0;
	wire CS_0_0;
	wire SCLK_0_0;
	wire IN_RESET_0_0;
	
	wire [PACK_LENGTH-1:0] IN_TRANSMIT_DATA_0_1;
	wire [PACK_LENGTH-1:0] OUT_RECEIVE_DATA_0_1;
	wire MISO_0_1;
	wire MOSI_0_1;
	wire CS_0_1;
	wire SCLK_0_1;
	wire IN_RESET_0_1;
	
	wire [PACK_LENGTH-1:0] IN_TRANSMIT_DATA_1_0;
	wire [PACK_LENGTH-1:0] OUT_RECEIVE_DATA_1_0;
	wire MISO_1_0;
	wire MOSI_1_0;
	wire CS_1_0;
	wire SCLK_1_0;
	wire IN_RESET_1_0;
	
	wire [PACK_LENGTH-1:0] IN_TRANSMIT_DATA_1_1;
	wire [PACK_LENGTH-1:0] OUT_RECEIVE_DATA_1_1;
	wire MISO_1_1;
	wire MOSI_1_1;
	wire CS_1_1;
	wire SCLK_1_1;
	wire IN_RESET_1_1;
	
	wire [PACK_LENGTH-1:0] TRANSMIT_TRANSFORM_DATA;
	assign TRANSMIT_TRANSFORM_DATA=PACK_BIT_SEQUENCE_TRANSMIT? IN_TRANSMIT_DATA: flip_backwards(IN_TRANSMIT_DATA,PACK_LENGTH);
	
	wire [PACK_LENGTH-1:0] RECEIVE_UNTRANSFORMED_DATA;
	assign OUT_RECEIVE_DATA= PACK_BIT_SEQUENCE_RECEIVE? RECEIVE_UNTRANSFORMED_DATA: flip_backwards(RECEIVE_UNTRANSFORMED_DATA,PACK_LENGTH);
	
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
	OUT_RECEIVE_DATA_0_1
	);
	
	SPI_FPGA_SLAVE_CPHA_EQ_1_CPOL_EQ_0 
	#(
	.PACK_LENGTH(PACK_LENGTH)
	)
	SLAVE_1_0
	(
	IN_TRANSMIT_DATA_1_0,
	MOSI_1_0,
	CS_1_0,
	SCLK_1_0,
	IN_RESET_1_0,
	MISO_1_0,
	OUT_RECEIVE_DATA_1_0
	);
	
	SPI_FPGA_SLAVE_CPHA_EQ_1_CPOL_EQ_1 
	#(
	.PACK_LENGTH(PACK_LENGTH)
	)
	SLAVE_1_1
	(
	IN_TRANSMIT_DATA_1_1,
	MOSI_1_1,
	CS_1_1,
	SCLK_1_1,
	IN_RESET_1_1,
	MISO_1_1,
	OUT_RECEIVE_DATA_1_1
	);
	
	
	assign IN_TRANSMIT_DATA_0_0	=		TRANSMIT_TRANSFORM_DATA	*(!CPHA)*(!CPOL);
	assign MOSI_0_0               =		MOSI							&(!CPHA)&(!CPOL);
	assign CS_0_0                 =		CS								&(!CPHA)&(!CPOL);
	assign SCLK_0_0               =		SCLK							&(!CPHA)&(!CPOL);
	assign IN_RESET_0_0           =		IN_RESET						&(!CPHA)&(!CPOL);
	
	assign IN_TRANSMIT_DATA_0_1	=		TRANSMIT_TRANSFORM_DATA	*(!CPHA)*(CPOL);
	assign MOSI_0_1					=		MOSI							&(!CPHA)&(CPOL);
	assign CS_0_1						=		CS								&(!CPHA)&(CPOL);
	assign SCLK_0_1					=		SCLK							&(!CPHA)&(CPOL);
	assign IN_RESET_0_1				=		IN_RESET						&(!CPHA)&(CPOL);
	
	assign IN_TRANSMIT_DATA_1_0	=		TRANSMIT_TRANSFORM_DATA	*(CPHA)*(!CPOL);
	assign MOSI_1_0					=		MOSI							&(CPHA)&(!CPOL);
	assign CS_1_0						=		CS								&(CPHA)&(!CPOL);
	assign SCLK_1_0					=		SCLK							&(CPHA)&(!CPOL);
	assign IN_RESET_1_0				=		IN_RESET						&(CPHA)&(!CPOL);
	
	assign IN_TRANSMIT_DATA_1_1	=		TRANSMIT_TRANSFORM_DATA	*(CPHA)*(CPOL);
	assign MOSI_1_1					=		MOSI							&(CPHA)&(CPOL);
	assign CS_1_1						=		CS								&(CPHA)&(CPOL);
	assign SCLK_1_1					=		SCLK							&(CPHA)&(CPOL);
	assign IN_RESET_1_1				=		IN_RESET						&(CPHA)&(CPOL);
	
	
	assign MISO = !CS?
		MISO_0_0&(!CPHA)&(!CPOL)|
		MISO_0_1&(!CPHA)&(CPOL)|
		MISO_1_0&(CPHA)&(!CPOL)|
		MISO_1_1&(CPHA)&(CPOL)	:	1'bz;		
	
	assign RECEIVE_UNTRANSFORMED_DATA=
		OUT_RECEIVE_DATA_0_0*(!CPHA)*(!CPOL)+
		OUT_RECEIVE_DATA_0_1*(!CPHA)*(CPOL)+
		OUT_RECEIVE_DATA_1_0*(CPHA)*(!CPOL)+
		OUT_RECEIVE_DATA_1_1*(CPHA)*(CPOL); 
		
	function [PACK_LENGTH-1:0] flip_backwards;
		input	[PACK_LENGTH-1:0] PACK;
		input [PACK_LENGTH_LOG_2:0] LENGTH;
		reg	[PACK_LENGTH-1:0] BUFER_PACK;
		reg 	[PACK_LENGTH_LOG_2:0] i;
		begin
			for(i=0;i<LENGTH;i=i+1)
				BUFER_PACK[i]=PACK[LENGTH-i-1];
			flip_backwards=BUFER_PACK;
		end
	endfunction
endmodule
