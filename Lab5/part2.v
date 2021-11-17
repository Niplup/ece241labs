module part2(ClockIn, Reset, Speed, CounterValue);
	input ClockIn, Reset;
	input [1:0] Speed;
	
	output [3:0] CounterValue;

	wire [10:0] CountRate;

	SpeedChoose s1(.Speed(Speed), .CountRate(CountRate));
	RateDivider r1(.ClockIn(ClockIn), .CountRate(CountRate), .CounterValue(CounterValue));

endmodule

module SpeedChoose(Speed, CountRate);
	input [1:0] Speed;
	output reg [10:0] CountRate;

	always @(*)
	begin
		case(Speed)
			2'b00: CountRate = 11'd0; //500 Hz
			2'b01: CountRate = 11'd499; //1 Hz
			2'b10: CountRate = 11'd999; //0.5 Hz
			2'b11: CountRate = 11'd1999; //0.25 Hz
			default: CountRate = 11'd0;
		endcase
	end
endmodule

module RateDivider(ClockIn, CountRate, CounterValue);
	input ClockIn;
	input [10:0] CountRate;

	output reg [3:0] CounterValue;

	wire Enable;
	reg [10:0] Q = 0;

	always @(posedge ClockIn)
	begin
		if (Q == 11'd0)
			Q <= CountRate;
		else
			Q <= Q - 1;
	end
	assign Enable = (Q == 4'b0000)?1:0;

	always @(posedge ClockIn)
	begin
		if (Enable)
			CounterValue <= CounterValue + 1;
	end
endmodule
