module SPI_FPGA_MASTER
#(
	parameter BIT_PER_SECOND			=	12500000,
	parameter CLOCK_FREQUENCY			=	50000000,
	parameter PACK_LENGTH				=	8,
	parameter CPOL							=	1'b0,
	parameter CPHA							=	1'b0,
	parameter CLKS_PER_BIT_LOG_2		=	$clog2(CLOCK_FREQUENCY/(BIT_PER_SECOND*2)),
	parameter PACK_LENGTH_LOG_2		=	$clog2(PACK_LENGTH)
)
(
input 									IN_CLOCK,								
input 									IN_LAUNCH,
input [PACK_LENGTH-1:0]				IN_DATA,
input										MISO,
output wire 							MOSI,
output reg 								CS,
output reg 								SCLK,
output [PACK_LENGTH-1:0]		   OUT_RECEIVE_DATA,
output reg							 	OUT_ACTION_DONE	
);
initial begin
	CS								=	1;
	SCLK							=	CPOL;
	REG_FSM_STATE				=  STATE_WAIT;
	REG_RECEIVE_DATA_2		=	0;
	REG_RECEIVE_DATA_1		=	0;
	REG_CLOCK_COUNT			=  0;
	REG_TRANSMIT_DATA			= 	0;
	REG_BIT_INDEX				=	PACK_LENGTH-1'b1;
	REG_RECEIVE_DATA_2		=	0;
	REG_RECEIVE_DATA_1		=	0;
	REG_TRANSMIT_BIT_1		= 	0;
	REG_TRANSMIT_BIT_2		=	0; 
	REG_MOSI_Z_STATE			=	1;
	REG_FLAG_START				=	0;
end
parameter BIT_PER_SECOND_MUL_2				=BIT_PER_SECOND*2;
parameter CLKS_PER_BIT							=CLOCK_FREQUENCY/BIT_PER_SECOND_MUL_2;
parameter STATE_WAIT								=2'b00;
parameter STATE_ACTION							=2'b01;
parameter STATE_WAIT_AFTER_TRANSACTION		=2'b10;
parameter RISE_EDGE								=1'b1;	
parameter FALLING_EDGE							=1'b0;	
parameter WRITE_MODE								=CPOL^CPHA;
parameter READ_MODE								=!WRITE_MODE;

reg [1:0]							REG_FSM_STATE;
reg [CLKS_PER_BIT_LOG_2:0]		REG_CLOCK_COUNT;
reg [PACK_LENGTH-1:0]			REG_TRANSMIT_DATA;
reg [PACK_LENGTH_LOG_2:0]		REG_BIT_INDEX;
reg [PACK_LENGTH-1:0]			REG_RECEIVE_DATA_2;
reg [PACK_LENGTH-1:0]			REG_RECEIVE_DATA_1;
reg									REG_TRANSMIT_BIT_1;
reg									REG_TRANSMIT_BIT_2;
reg									REG_MOSI_Z_STATE;
reg									REG_FLAG_START;
assign MOSI= REG_MOSI_Z_STATE ? 1'bZ: (WRITE_MODE==RISE_EDGE)?	REG_TRANSMIT_BIT_1:REG_TRANSMIT_BIT_2;
assign OUT_RECEIVE_DATA= (READ_MODE==RISE_EDGE)? REG_RECEIVE_DATA_1:REG_RECEIVE_DATA_2;
always@(posedge SCLK or posedge REG_FLAG_START)
begin
	if (REG_FLAG_START)		
	begin
		REG_TRANSMIT_BIT_1<=REG_TRANSMIT_DATA[PACK_LENGTH-1];
	end
	else
	begin
		if(WRITE_MODE==RISE_EDGE)
		begin
			if(!CPHA)
				REG_TRANSMIT_BIT_1<=REG_TRANSMIT_DATA[REG_BIT_INDEX-1];
			else
				REG_TRANSMIT_BIT_1<=REG_TRANSMIT_DATA[REG_BIT_INDEX];
		end
		else 
			REG_RECEIVE_DATA_1[REG_BIT_INDEX]<=MISO;
	end
end
always@(negedge SCLK or posedge REG_FLAG_START)
begin
	if(REG_FLAG_START)
	begin
		REG_TRANSMIT_BIT_2<=REG_TRANSMIT_DATA[PACK_LENGTH-1];
	end
	else
	begin
		if(WRITE_MODE==FALLING_EDGE)
		begin
			if(!CPHA)
				REG_TRANSMIT_BIT_2<=REG_TRANSMIT_DATA[REG_BIT_INDEX-1];
			else
				REG_TRANSMIT_BIT_2<=REG_TRANSMIT_DATA[REG_BIT_INDEX];
		end
		else
			REG_RECEIVE_DATA_2[REG_BIT_INDEX]<=MISO;		
	end
end
always @ (posedge IN_CLOCK)
begin
	case (REG_FSM_STATE)
		STATE_WAIT:
		begin
			REG_MOSI_Z_STATE=1;
			CS<=1; 
			SCLK<=CPOL;
			OUT_ACTION_DONE<=0;
			if(IN_LAUNCH)
				begin
					REG_FLAG_START<=1;
					REG_MOSI_Z_STATE<=0;
					CS<=0;
					REG_FSM_STATE<=STATE_ACTION;
					REG_BIT_INDEX<=PACK_LENGTH-1;
					REG_TRANSMIT_DATA<=IN_DATA;
				end
		end
		STATE_ACTION:
		begin		
			REG_FLAG_START<=0;
			if(REG_CLOCK_COUNT<CLKS_PER_BIT*2-1)
			begin
				REG_CLOCK_COUNT=REG_CLOCK_COUNT+1;
				if(REG_CLOCK_COUNT==CLKS_PER_BIT)
					SCLK=!SCLK;
			end
			else
			begin
				REG_CLOCK_COUNT<=0;
				SCLK<=!SCLK; 
				if(REG_BIT_INDEX>0)
				begin
					REG_BIT_INDEX=REG_BIT_INDEX-1'b1;
				end
				else
				begin
					REG_BIT_INDEX=PACK_LENGTH-1'b1;
					REG_FSM_STATE<=STATE_WAIT_AFTER_TRANSACTION;
					if (!CPHA)REG_MOSI_Z_STATE<=1;
				end
			end
		end
		STATE_WAIT_AFTER_TRANSACTION:
		begin
			if(REG_CLOCK_COUNT<CLKS_PER_BIT-1)
				REG_CLOCK_COUNT=REG_CLOCK_COUNT+1;
			else 
			begin
				OUT_ACTION_DONE<=1;
				CS<=1;
				REG_CLOCK_COUNT<=0;
				REG_FSM_STATE<=STATE_WAIT;
				REG_MOSI_Z_STATE<=1;
			end

		end
	endcase
end
endmodule
