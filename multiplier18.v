
module multiplier18 (clk, A1, A2, B1, B2, P, SEL);

    input  wire      clk;
    input  wire signed [37:0] A1, A2, B1, B2;
	 input  wire SEL;	 
    output wire signed [38:0] P;


       reg signed [37:0] A1_reg, A2_reg, B1_reg, B2_reg;
       reg signed [38:0] P_comb;
		 reg SEL_reg;

       always @(posedge clk) begin
           A1_reg <= A1;
			  A2_reg <= A2;
           B1_reg <= B1;
           B2_reg <= B2;
			  SEL_reg <= SEL;
           P_comb <= 0 ? (A1_reg + B1_reg) : (A2_reg + B2_reg);
       end

       assign P = P_comb;

endmodule
