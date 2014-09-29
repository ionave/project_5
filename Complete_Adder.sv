module Complete_Adder(input			Clk,	//Clock Signal
						    input			Reset_L,    //Push button 0
							 input         LoadB_L,    //Push button 1
							 input			Run,    //Push button 2
							 input 				 [15:0]  SW,    //Input Data
							 output logic					Cout,   // LED display
							 output logic 		 [6:0]   AhexL,  //Hex Display 1
																AhexU,  //Hex Display 2
																BhexL,  //Hex Display 3
																BhexU   //Hex Display 4
							 );
							 
logic reset, loadB, loadG;
logic [15:0] R, G;

always_comb
	begin
		reset = ~Reset_L;  // Push buttons are active low, but active-high logic is easier to deal with
		loadB = ~LoadB_L;
		loadG = ~Run;
	end
	
/*

button_debouncer	run_debounce( .Clk,
									 .Run,
									 .Q
									);
*/									 

register_unit  reg_unit( .loadB,
							  .loadG,
							  .reset,
							  .SW,
							  .G (G),
							  .R (R)							  
							  );



carry_ripple_adder cra (.T (R),
								.U (SW),
								.W (G),
								.v_out (Cout)
								);


/*

carry_select_adder csa (.T (R),
								.U (SW),
								.W (G),
								.v_out (Cout)
								);

*/

/*
carry_lookahead_adder cla (.T (R),
								.U (SW),
								.W (G),
								.v_out (Cout)
								);	
		
*/		
								
HexDriver		Hex0 ( .In0(R[3:0]),
							  .Out0(AhexL) );
							
HexDriver		Hex1 (.In0(R[7:4]),
							 .Out0(AhexU) );
							
HexDriver		Hex2 (.In0(R[11:8]),
							 .Out0(BhexL) );
							
HexDriver		Hex3 ( .In0(R[15:12]),
							  .Out0(BhexU) );
	
endmodule

module carry_ripple_adder (input [15:0] T, U,
								   output [15:0] W,
								output 			v_out);
								

		// Internal carries in the 16-bit CRA
		logic		v1, v2, v3;
					
				adder4 A41 (.A (T[3:0]), .B (U[3:0]), .S (W[3:0]), .c_in (0), .c_out (v1));
				adder4 A42 (.A (T[7:4]), .B (U[7:4]), .S (W[7:4]), .c_in (v1), .c_out (v2));
				adder4 A43 (.A (T[11:8]), .B (U[11:8]), .S (W[11:8]), .c_in (v2), .c_out (v3));
				adder4 A44 (.A (T[15:12]), .B (U[15:12]), .S (W[15:12]), .c_in (v3), .c_out (v_out));
								
endmodule

module two_one_mux (  input [3:0] M0,
							input [3:0] M1,
					 input		  Sel,
					 output [3:0] M
					 );
					 
always @ (M0 or M1 or Sel)
	begin	
		case (Sel)
			1'b0     : M = M0;
			default	: M = M1;
		endcase
	end
endmodule

module carry_select_adder (input 		[15:0] T, U,
								   output 		[15:0] W,
								   output 		v_out);
								
		// Internal values in the 16-bit CRA
		logic		v1, v2, v3, v4, v2_0, v2_1, v3_0, v3_1, v4_0, v4_1;
		logic    [15:0] W0, W1;
					
				adder4 A1 (.A (T[3:0]), .B (U[3:0]), .S (W[3:0]), .c_in (0), .c_out (v1));
				
				adder4 A2_0 (.A (T[7:4]), .B (U[7:4]), .S (W0[7:4]), .c_in (0), .c_out (v2_0));
				adder4 A2_1 (.A (T[7:4]), .B (U[7:4]), .S (W1[7:4]), .c_in (1), .c_out (v2_1));

				two_one_mux A2  (.M0 (W0[7:4]), .M1 (W1[7:4]), .Sel (v2), .M (W[7:4]));
				
				adder4 A3_0 (.A (T[11:8]), .B (U[11:8]), .S (W0[11:8]), .c_in (0), .c_out (v3_0));
				adder4 A3_1 (.A (T[11:8]), .B (U[11:8]), .S (W1[11:8]), .c_in (1), .c_out (v3_1));

				two_one_mux A3  (.M0 (W0[11:8]), .M1 (W1[11:8]), .Sel (v3), .M (W[11:8]));
				
				adder4 A4_0 (.A (T[15:12]), .B (U[15:12]), .S (W0[15:12]), .c_in (0), .c_out (v4_0));
				adder4 A4_1 (.A (T[15:12]), .B (U[15:12]), .S (W1[15:12]), .c_in (1), .c_out (v4_1));

				two_one_mux A4  (.M0 (W0[15:12]), .M1 (W1[15:12]), .Sel (v4), .M (W[15:12]));
				
always_comb
	begin
		v2 = (v1 & v2_1) | v2_0;
		v3 = (v2 & v3_1) | v3_0;
		v4 = (v3 & v4_1) | v4_0;
		v_out = v4;
	end
									
endmodule

module register_unit( input		loadB, 
											loadG,
											reset,
						input logic [15:0] SW,
						input logic [15:0] G,
						output logic[15:0] R);
						
	always_ff @ (posedge loadB or posedge loadG or posedge reset)
	begin
		if(reset)
			R <= 16'b0000000000000000;
		else if (loadB)
			R <= SW;
		else if (loadG)
			R <= G;
	end
endmodule

module full_adder (input x, y, z,
							output s, c);
		
		assign s = x^y;
		assign c = (x&y)|(y&z)|(x&z);

endmodule

module half_adder (input a, b,
						 output p, g);

		assign p = a^b;
		assign g = (a&b);
		
endmodule

module cla_adder4 (input [3:0] A, B,
						 input		   c_in,
						 output [3:0] S,
						 output		c_out);
					
		// Internal carries in the 4-bit adder
		logic		c1, c2, c3, p1, p2, p3, p4, g1, g2, g3, g4, g0_0, g1_0, g2_0, g3_0;
		half_adder A1 (.a (A[0]), .b (B[0]), .p (p1), .g (g1));
		half_adder A2 (.a (A[1]), .b (B[1]), .p (p2), .g (g2));
		half_adder A3 (.a (A[2]), .b (B[2]), .p (p3), .g (g3));
		half_adder A4 (.a (A[3]), .b (B[3]), .p (p4), .g (g4));
		
always_comb
	begin	
		g0_0 = c_in;
		S[0] = g0_0 ^ p1;
		g1_0 = (c_in & p1)|g1;
		S[1] = g1_0 ^ p2;
		g2_0 = (g1_0 & p2)|g2;
		S[2] = g2_0 ^ p3;
		g3_0 = (g2_0 & p3)|g3;
		S[3] = g3_0 ^ p4;
		c_out = (g3_0 & p4)|g4;		
	end
endmodule

module carry_lookahead_adder (input 		[15:0] T, U,
								      output 		[15:0] W,
								      output 		v_out);
										
		// Internal carries in the 4-bit adder
		logic		v1, v2, v3;								

		cla_adder4 A41 (.A (T[3:0]), .B (U[3:0]), .S (W[3:0]), .c_in (0), .c_out (v1));
		cla_adder4 A42 (.A (T[7:4]), .B (U[7:4]), .S (W[7:4]), .c_in (v1), .c_out (v2));
		cla_adder4 A43 (.A (T[11:8]), .B (U[11:8]), .S (W[11:8]), .c_in (v2), .c_out (v3));
		cla_adder4 A44 (.A (T[15:12]), .B (U[15:12]), .S (W[15:12]), .c_in (v3), .c_out (v_out));
		
endmodule

module adder4 (input [3:0] A, B,
					input		   c_in,
					output [3:0] S,
					output		c_out);
					
		// Internal carries in the 4-bit adder
		logic		c1, c2, c3;
		
		full_adder FA0 (.x (A[0]), .y (B[0]), .z (c_in), .s (S[0]), .c (c1));
		full_adder FA1 (.x (A[1]), .y (B[1]), .z (c1), .s (S[1]), .c (c2));
		full_adder FA2 (.x (A[2]), .y (B[2]), .z (c2), .s (S[2]), .c (c3));
		full_adder FA3 (.x (A[3]), .y (B[3]), .z (c3), .s (S[3]), .c (c_out));
		
endmodule

module HexDriver (input [3:0] In0,
						output logic [6:0] Out0);
						
always_comb
begin
	unique case (In0)
		8'b00000000 : Out0 = 7'b1000000; // 0
		8'b00000001 : Out0 = 7'b1111001; // 1
		8'b00000010 : Out0 = 7'b0100100; // 2
		8'b00000011 : Out0 = 7'b0110000; // 3
		8'b00000100 : Out0 = 7'b0011001; // 4
		8'b00000101 : Out0 = 7'b0010010; // 5
		8'b00000110 : Out0 = 7'b0000010; // 6
		8'b00000111 : Out0 = 7'b1111000; // 7
		8'b00001000 : Out0 = 7'b0000000; // 8
		8'b00001001 : Out0 = 7'b0010000; // 9
		8'b00001010 : Out0 = 7'b0001000; // A
		8'b00001011 : Out0 = 7'b0000011; // b
		8'b00001100 : Out0 = 7'b1000110; // C
		8'b00001101 : Out0 = 7'b0100001; // d
		8'b00001110 : Out0 = 7'b0000110; // E
		8'b00001111 : Out0 = 7'b0001110; // F
		default : Out0 = 7'bX;
		
	endcase
end

endmodule

/*

module button_debouncer (	input			Clk,	
									input			Reset_L,
									input			Run,    		//Push button 2
									output [19:0] Q
								);
								
enum logic [2:0] {A, B, C} curr_state, next_state;

always_ff @ (posedge Clk or posedge Reset_L)
	begin	
			if(Reset_L)
				curr_state = A;
			else
				curr_state = next_state;
	end
	
always_comb 
	begin	
			next_state = curr_state;
			unique case (curr_state)
				A : Q <= 20'b0 ;
						if (~Run)
							next_state = B;
				B : Q <= Q + 1'b1 ;
						if (~Run)
							next_state = A;
						else (Q[19])
							next_stare = A;
							
							
	end
	
	
endmodule
*/
