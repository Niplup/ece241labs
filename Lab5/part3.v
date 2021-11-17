module part3(ClockIn, Resetn, Start, Letter, DotDashOut);
	input ClockIn, Resetn, Start;
	input [2:0] Letter;

	wire [11:0] CountRate, HexLet;
	wire w1 = HexLet[11];

	reg [11:0] Morse;

	output DotDashOut;
	
	always @(*)
		begin
			case (Letter)
				3'b000: Morse = 12'b101110000000; 
				3'b001: Morse = 12'b111010101000;
				3'b010: Morse = 12'b111010111010;
				3'b011: Morse = 12'b111010100000;
				3'b100: Morse = 12'b100000000000;
				3'b101: Morse = 12'b101011101000;
				3'b110: Morse = 12'b111011101000;
				3'b111: Morse = 12'b101010100000;
				default: Morse = 12'b0;
			endcase
		end

	ShiftDivider s1 (.ClockIn(ClockIn), .Resetn(Resetn), .Start(Start), .Morse(Morse), .CountRate(CountRate), .Q(HexLet));
	LetterOut lo1 (.ClockIn(ClockIn), .Resetn(Resetn), .Start(Start), .CountRate(CountRate), .w1(w1), .DotDashOut(DotDashOut));
endmodule


module ShiftDivider(ClockIn, Resetn, Start, Morse, CountRate, Q);
	input ClockIn, Resetn, Start;
	input [11:0] Morse;

	output reg [11:0] CountRate, Q;

	always @(posedge ClockIn)
	begin
		if (Start)
			CountRate <= 12'd249;
		else if (CountRate == 12'd0)
			CountRate <= 12'd249;
		else
			CountRate <= CountRate - 1;
	end

	always @(posedge ClockIn, negedge Resetn)
	begin
		if (Resetn == 0)
			Q <= 0;
		else if (Start)
			Q <= Morse;	
		else if (CountRate == 12'd0)
		begin
			Q <= Q << 1;
			Q[0] <= Q[11];
		end
	end
endmodule

module LetterOut (ClockIn, Resetn, Start, CountRate, w1, DotDashOut);
	input ClockIn, Resetn, Start, w1;
	input [11:0] CountRate;

	output reg DotDashOut;

	always @(posedge ClockIn, negedge Resetn)
	begin
		if (Start == 1)
			DotDashOut <= 0;
		else if (Resetn == 0)
			DotDashOut <= 0;
		else if (CountRate == 12'd0)
			DotDashOut <= w1;
	end
endmodule
