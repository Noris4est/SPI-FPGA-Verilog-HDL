module PWM_FPGA
#(
	parameter 							CLOCK_FREQUENCY			=400000,
	parameter 							PWM_FREQUENCY				=100000,
	parameter 							MAX_VALUE					=16,
	parameter 							DEEP_FILL_FACTOR			=$clog2(MAX_VALUE)+1
)	
(
	input 								IN_CLOCK,
	input									IN_RESET,	
	input 								IN_ENABLE,
	input [DEEP_FILL_FACTOR-1:0] 	IN_FILL_FACTOR,
	output wire 						OUT_PWM_SIGNAL
);
localparam PERIOD_NUMBER_CLOCKS			=CLOCK_FREQUENCY/PWM_FREQUENCY;

reg [$clog2(PERIOD_NUMBER_CLOCKS):0]	REG_NUMBER_CLOCKS_HIGH_SIGNAL;
reg [$clog2(PERIOD_NUMBER_CLOCKS):0] 	REG_PERIOD_COUNTER ;
reg 												REG_PWM_SIGNAL;
reg 												FIRST_CLOCK_WHEN_IN_RESET_EQ_1;
reg 												REG_RESET_SEPARATE;
reg	[DEEP_FILL_FACTOR-1:0]				REG_FILL_FACTOR;
initial begin
	REG_PWM_SIGNAL=0;
	REG_PERIOD_COUNTER=0;
	REG_NUMBER_CLOCKS_HIGH_SIGNAL=0;
	FIRST_CLOCK_WHEN_IN_RESET_EQ_1=0;
	REG_RESET_SEPARATE=0;
	REG_FILL_FACTOR=0;
end

assign OUT_PWM_SIGNAL=REG_PWM_SIGNAL&IN_ENABLE;

//separate IN_CLOCK to REG_RESET_SEPARATE
always @(posedge IN_CLOCK or posedge IN_RESET)
begin
	if(IN_RESET)
	begin
		if(!FIRST_CLOCK_WHEN_IN_RESET_EQ_1)
		begin
			FIRST_CLOCK_WHEN_IN_RESET_EQ_1<=1;
			REG_RESET_SEPARATE<=1;
		end
		else
		begin
			REG_RESET_SEPARATE<=0;
		end
	end
	else
	begin
		FIRST_CLOCK_WHEN_IN_RESET_EQ_1<=0;
		REG_RESET_SEPARATE<=0;
	end
end


always @(posedge IN_CLOCK or posedge REG_RESET_SEPARATE)
begin
	if(REG_RESET_SEPARATE)
	begin
		REG_FILL_FACTOR=IN_FILL_FACTOR;
		
		REG_PWM_SIGNAL<=(PERIOD_NUMBER_CLOCKS*REG_FILL_FACTOR/MAX_VALUE!=0)?1:0;
		REG_PERIOD_COUNTER<=0;
		REG_NUMBER_CLOCKS_HIGH_SIGNAL<=PERIOD_NUMBER_CLOCKS*REG_FILL_FACTOR/MAX_VALUE;
	end
	else 
	begin
		if(REG_PERIOD_COUNTER<PERIOD_NUMBER_CLOCKS-1)
		begin
			REG_PERIOD_COUNTER<=REG_PERIOD_COUNTER+1;
			if(REG_NUMBER_CLOCKS_HIGH_SIGNAL-1<=REG_PERIOD_COUNTER)
				REG_PWM_SIGNAL<=0;
		end
		else
		begin
			REG_PWM_SIGNAL<=(PERIOD_NUMBER_CLOCKS*REG_FILL_FACTOR/MAX_VALUE!=0)?1:0;
			REG_PERIOD_COUNTER<=0;
		end
	end
end
endmodule
