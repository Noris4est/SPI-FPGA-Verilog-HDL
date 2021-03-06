module SPI_FPGA_SLAVE_CPHA_EQ_0_CPOL_EQ_1 //старший бит вперед
#(
	parameter PACK_LENGTH 				=8,
	parameter PACK_LENGTH_LOG_2		=$clog2(PACK_LENGTH)
)
(
	input          [PACK_LENGTH-1:0] 	IN_TRANSMIT_DATA,
	input 										MOSI,
	input 										CS,
	input 										SCLK,
	input 										IN_RESET,
	output 										MISO,
	output reg 		[PACK_LENGTH-1:0]		OUT_RECEIVE_DATA
);
	reg [PACK_LENGTH-1:0]			REG_TRANSMIT_DATA;
	reg [PACK_LENGTH_LOG_2:0]		REG_BIT_INDEX;
	
	initial begin
		REG_TRANSMIT_DATA=0;
		REG_BIT_INDEX=PACK_LENGTH;
		OUT_RECEIVE_DATA=0;
	end
	assign MISO=!CS ? (REG_TRANSMIT_DATA[REG_BIT_INDEX-1]&(REG_BIT_INDEX>0)|REG_TRANSMIT_DATA[0]&(REG_BIT_INDEX==0)) : 1'bZ;
		
	always @(negedge CS)
		REG_TRANSMIT_DATA<=IN_TRANSMIT_DATA;
	always @(posedge SCLK or posedge CS or posedge IN_RESET)
	begin
		if (IN_RESET)
			REG_BIT_INDEX=PACK_LENGTH;
		else if(CS)
			REG_BIT_INDEX=PACK_LENGTH;
		else 
			REG_BIT_INDEX=REG_BIT_INDEX-1;
	end
	
	always @(negedge SCLK or posedge IN_RESET)
	begin
		if (IN_RESET)
			OUT_RECEIVE_DATA=0;
		else if(!CS)
			OUT_RECEIVE_DATA[REG_BIT_INDEX-1]=MOSI;
	end

endmodule
