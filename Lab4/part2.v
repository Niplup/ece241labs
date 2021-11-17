module part2(Clock, Reset_b, Data, Function, ALUout);
	input [3:0] Data;
	input [2:0] Function;
	input Reset_b, Clock;

	wire [3:0] B;
	wire [3:0] s1, s2, c2;
	wire [7:0] cmult;
	wire c1;

	output reg [7:0] ALUout;

	assign B = ALUout[3:0];

	assign {c1, s2} = Data + B;
	assign cmult = Data * B;
	fourbitadder adder(Data, B, 0, s1, c2);


	always @(posedge Clock)
	begin
		if (Reset_b == 1'b0)
			ALUout <= 0;
		else
			begin
				case (Function[2:0])
					3'b000: ALUout = {3'b0, c2[3], s1};
					3'b001: ALUout = {3'b0, c1, s2};
					3'b010: ALUout = {{4{B[3]}}, B};
					3'b011: ALUout = {7'b0, | (Data | B)};
					3'b100: ALUout = {7'b0, & (Data & B)};
					3'b101: ALUout = B << Data;
					3'b110: ALUout = cmult;
					3'b111: ALUout = ALUout;
					default: ALUout = 8'b0;
				endcase
			end
	end
endmodule

module fourbitadder(a, b, c_in, s, c_out);
	input [3:0] a, b;
	input c_in;
	output [3:0] s, c_out;

	fulladder bit0(a[0], b[0], c_in, s[0], c_out[0]);
	fulladder bit1(a[1], b[1], c_out[0], s[1], c_out[1]);
	fulladder bit2(a[2], b[2], c_out[1], s[2], c_out[2]);
	fulladder bit3(a[3], b[3], c_out[2], s[3], c_out[3]);
endmodule

module fulladder(x, y, cin, t, cout);
	input x, y, cin;
	output t, cout;
	assign t = cin^x^y;
	assign cout = (x & y) | (cin & x) | (cin & y);
endmodule


