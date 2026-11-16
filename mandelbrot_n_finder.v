
module mandelbrot_n_finder #(parameter W = 24, parameter W_CONT = 8) (c_re, c_im, n_max, clk, reset, start, stop, n);
   input	wire signed [W-1:0] c_re;
   input	wire signed [W-1:0] c_im;
	input	[W_CONT-1:0] n_max;				// Massimo numero di iterazioni
	input	clk, reset;
	input	start;

   output reg stop;
	output reg [W_CONT-1:0] n;
	 
	wire	escape;										// Flag di raggiungimento di |z| >= 2
	reg 	[W-1:0] x_corr, y_corr;					// Coordinate punto z[n] in ingresso al moltiplicatore
	wire	[W-1:0] x_next, y_next;					//	Coordinate punto z[n+1] in uscita dal moltiplicatore
	reg 	[W-1:0] x_succ, y_succ;					// Coordinate punto z[n+1] in ingresso ad un FF davanti al moltiplicatore
	// Contatori corrente e aggiornaton n° iterazioni
	reg	[W_CONT-1:0] contatore_corr, contatore_succ;
	// Segnale di fine conteggio del registro e di attesa nuovo start
	reg	waiting_corr, waiting_succ;
	

	mandelbrot_step #(.W(W)) next_step (.x(x_corr), .y(y_corr), .c_re(c_re), .c_im(c_im), .x_next(x_next), .y_next(y_next), .escape(escape));
	 
	// Aggiornamento dello stato della macchina
	always @ (posedge clk, posedge reset)
		if (reset == 1'b1)
			begin
				x_corr <= {W{1'b0}};
				y_corr <= {W{1'b0}};
				contatore_corr <= {(W_CONT){1'b0}};
				waiting_corr <= 1'b1;
			end
		else
			begin
				x_corr <= x_succ;
				y_corr <= y_succ;
				contatore_corr <= contatore_succ;
				waiting_corr <= waiting_succ;
		end

	// Calcolo dello stato aggiornato
	always @ (*)
		if (waiting_corr == 1'b1)
			if (start == 1'b1)
				// Inizio del calcolo dell'orbita di un punto
				begin
					contatore_succ = {W_CONT{1'b0}};
					x_succ = c_re;
					y_succ = c_im;
					waiting_succ = 1'b0;
				end
			else
				// Mantenimento dello stato corrente
				begin
					contatore_succ = contatore_corr;
					x_succ = x_corr;
					y_succ = y_corr;
					waiting_succ = 1'b1;
				end
		else
			if ((contatore_corr < n_max) && (escape == 0))
				// Passaggio all'iterazione successiva
				begin
					contatore_succ = contatore_corr + 1;
					x_succ = x_next;
					y_succ = y_next;
					waiting_succ = 1'b0;
				end
			else
				begin
					contatore_succ = contatore_corr;
					x_succ = x_corr;
					y_succ = y_corr;
					waiting_succ = 1'b1;
				end
	
	// Calcolo dei segnali in uscita dal circuito
	always @ (*)
		begin
		   stop = waiting_corr;
			if (waiting_corr == 1'b1)
				n = contatore_corr;
			else
				n = {W_CONT{1'b0}};
		end

endmodule
	 