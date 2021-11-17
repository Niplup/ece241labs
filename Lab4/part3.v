module part3 (clock, reset, ParallelLoadn, RotateRight, ASRight, Data_IN, Q);
	input [7:0] Data_IN;
	input clock, reset, ParallelLoadn, RotateRight, ASRight;

	output [7:0] Q;
	wire wir1;

	mux2to1 mux(Q[0], Q[7], ASRight, wir1);

	subcircuit sc1 (.right(Q[6]), .left(wir1), .LoadLeft(RotateRight), .D(Data_IN[7]), .loadn(ParallelLoadn), .Q(Q[7]), .clock(clock), .reset(reset));
	subcircuit sc2 (.right(Q[5]), .left(Q[7]), .LoadLeft(RotateRight), .D(Data_IN[6]), .loadn(ParallelLoadn), .Q(Q[6]), .clock(clock), .reset(reset));
	subcircuit sc3 (.right(Q[4]), .left(Q[6]), .LoadLeft(RotateRight), .D(Data_IN[5]), .loadn(ParallelLoadn), .Q(Q[5]), .clock(clock), .reset(reset));
	subcircuit sc4 (.right(Q[3]), .left(Q[5]), .LoadLeft(RotateRight), .D(Data_IN[4]), .loadn(ParallelLoadn), .Q(Q[4]), .clock(clock), .reset(reset));
	subcircuit sc5 (.right(Q[2]), .left(Q[4]), .LoadLeft(RotateRight), .D(Data_IN[3]), .loadn(ParallelLoadn), .Q(Q[3]), .clock(clock), .reset(reset));
	subcircuit sc6 (.right(Q[1]), .left(Q[3]), .LoadLeft(RotateRight), .D(Data_IN[2]), .loadn(ParallelLoadn), .Q(Q[2]), .clock(clock), .reset(reset));
	subcircuit sc7 (.right(Q[0]), .left(Q[2]), .LoadLeft(RotateRight), .D(Data_IN[1]), .loadn(ParallelLoadn), .Q(Q[1]), .clock(clock), .reset(reset));
	subcircuit sc8 (.right(Q[7]), .left(Q[1]), .LoadLeft(RotateRight), .D(Data_IN[0]), .loadn(ParallelLoadn), .Q(Q[0]), .clock(clock), .reset(reset));

endmodule


module subcircuit (right, left, LoadLeft, D, loadn, Q, clock, reset);
	input right, left, LoadLeft, D, loadn, clock, reset;
	output reg Q;
	//output Q;

	wire w1, w2;

	mux2to1 mux1 (right, left, LoadLeft, w1);
	mux2to1 mux2 (D, w1, loadn, w2);

	//Dlatch sublatch (clock, reset, w2, Q);
	always @(posedge clock)
	begin
		if (reset == 1'd1)
			Q <= 0;
		else
			Q <= w2;
	end	
endmodule;

/*module Dlatch (clock, reset, d, q);
	input clock, reset, d;
	output reg q;

	always @(posedge clock)
	begin
		if (reset == 1'b0)
			q <= 0;
		else
			q <= d;
	end
endmodule */

module mux2to1 (x, y, s, f);
    input x, y, s;
    output f;
    assign f = (~s & x) | (s & y);
endmodule
