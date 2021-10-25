module mux2to1(x, y, s, m);
    input x, y, s;
    output m;
	
	wire wireA, wireB, wireC;
	
	v7404 notgate (.pin1(s), .pin2(wireA));
	v7408 andgate (.pin1(x), .pin2(wireA), .pin3(wireB), 
				   .pin4(s), .pin5(y), .pin6(wireC));
	v7432 orgate (.pin1(wireB), .pin2(wireC), .pin3(m));
	
endmodule

module v7404 (pin1, pin3, pin5, pin9, pin11, pin13,
			  pin2, pin4, pin6, pin8, pin10, pin12);
// 7404 - 6 NOT gates

	input pin1, pin3, pin5, pin9, pin11, pin13;
	output pin2, pin4, pin6, pin8, pin10, pin12;
	
	assign pin2 = ~pin1;
	assign pin4 = ~pin3;
	assign pin6 = ~pin5;
	assign pin8 = ~pin9;
	assign pin10 = ~pin11;
	assign pin12 = ~pin13;
	
endmodule

module v7408 (pin1, pin3, pin5, pin9, pin11, pin13, 
			  pin2, pin4, pin6, pin8,pin10, pin12);
// 7408 - 4 AND gates

	input pin1, pin2, pin4, pin5, pin9, pin10, pin12, pin13;
	output pin3, pin6, pin8, pin11;
	
	assign pin3 = pin1 & pin2;
	assign pin6 = pin4 & pin5;
	assign pin8 = pin9 & pin10;
	assign pin11 = pin12 & pin13;

endmodule

module v7432 (pin1, pin3, pin5, pin9, pin11, pin13, 
			  pin2, pin4, pin6, pin8,pin10, pin12);
// 7432 - 4 OR gates

	input pin1, pin2, pin4, pin5, pin9, pin10, pin12, pin13;
	output pin3, pin6, pin8, pin11;
	
	assign pin3 = pin1 | pin2;
	assign pin6 = pin4 | pin5;
	assign pin8 = pin9 | pin10;
	assign pin11 = pin12 | pin13;

endmodule

