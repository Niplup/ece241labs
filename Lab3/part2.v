module part2(a, b, c_in, s, c_out);
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

