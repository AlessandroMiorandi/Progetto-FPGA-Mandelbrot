
module madelbrot_n_finder #(parameter W = 24, parameter W_cont=8) (c_re, c_im, n_max, clk, reset, start, stop, n);
   input  wire signed [W-1:0] c_re;
   input  wire signed [W-1:0] c_im;
	input  [W_cont-1:0] n_max;
	input  clk, reset, start;

   output reg stop;
	output reg [W_cont-1:0] n;
	 
	reg escape;
	reg [W-1:0] x_corr, y_corr;
	reg [W-1:0] x_next, y_next;
	reg [W-1:0] x_succ, y_succ;
	reg [W_cont:0] contatore_corr, contatore_succ;
	 
	mandelbrot_step #(.W(W)) next_step (.x(x_corr), .y(y_corr), .c_re(c_re), .c_im(c_im), .x_next(x_next), y_next(y_next), .escape(escape));
	 
	always @ (posedge clk, posedge reset)
		if (reset==1'b1)
			begin
			x_corr <= {W{1'b0}};
			y_corr <= {W{1'b0}};
			contatore_corr <= {1'b1, (W_cont){1'b0}};
			end
		else
			begin
			x_corr <= x_succ;
			y_corr <= y_succ;
			contatore_corr <= contatore_succ;
		end

	always @ (*)
		if (contatore_corr[W_cont]==1'b1)
			if (start==1'b1)
				begin
					contatore_succ = {(W_cont+1){1'b0}};
					x_succ = c_re;
					y_succ = c_im;
				end
			else
				begin
					contatore_succ = contatore_corr;
					x_succ = x_corr;
					y_succ = y_corr;
				end
		else
			if (contatore_corr < {1'b0, n_max} && escape == 0)
				begin
					contatore_succ = contatore_corr+1;
					x_succ = x_next;
					y_succ = y_next;
				end
			else
				begin
					contatore_succ = (contatore_corr|{1'b1, W_cont{1'b0}});
					x_succ = x_corr;
					y_succ = y_corr;
				end
	

	always @ (*)
		begin
		   stop = contatore_corr[W_cont];
			if (contatore_corr[W_cont]==1)
				n=contatore_corr[W_cont-1:0];
			else
				n={W_cont{1'b0}};
		end

endmodule
	 