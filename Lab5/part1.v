module part1(Clock, Enable, Clear_b, CounterValue);
	input Clock, Enable, Clear_b;
	output [7:0] CounterValue;

	wire c1, c2, c3, c4, c5, c6, c7;

	assign c1 = CounterValue[0] & Enable;
	assign c2 = CounterValue[1] & c1;
	assign c3 = CounterValue[2] & c2;
	assign c4 = CounterValue[3] & c3;
	assign c5 = CounterValue[4] & c4;
	assign c6 = CounterValue[5] & c5;
	assign c7 = CounterValue[6] & c6;

	Tflipflop f1(.T(Enable), .Clock(Clock), .Reset(Clear_b), .Q(CounterValue[0]));
	Tflipflop f2(.T(c1), .Clock(Clock), .Reset(Clear_b), .Q(CounterValue[1]));
	Tflipflop f3(.T(c2), .Clock(Clock), .Reset(Clear_b), .Q(CounterValue[2]));
	Tflipflop f4(.T(c3), .Clock(Clock), .Reset(Clear_b), .Q(CounterValue[3]));
	Tflipflop f5(.T(c4), .Clock(Clock), .Reset(Clear_b), .Q(CounterValue[4]));
	Tflipflop f6(.T(c5), .Clock(Clock), .Reset(Clear_b), .Q(CounterValue[5]));
	Tflipflop f7(.T(c6), .Clock(Clock), .Reset(Clear_b), .Q(CounterValue[6]));
	Tflipflop f8(.T(c7), .Clock(Clock), .Reset(Clear_b), .Q(CounterValue[7]));
endmodule

module Tflipflop(T, Clock, Reset, Q);
	input T, Clock, Reset;
	output reg Q;

	always @(posedge Clock)
	begin
		if (!Reset)
			Q <= 0;
		else
			if (T)
				Q <= ~Q;
			else
				Q <= Q;
	end
endmodule

