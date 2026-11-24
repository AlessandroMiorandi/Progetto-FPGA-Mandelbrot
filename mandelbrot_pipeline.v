
module mandelbrot_pipeline (clk, reset, c_re, c_im, n_max, start, done, n);
	
	input wire clk, reset, start;     //start = segnale da parte dello scheduler che indica che il nuovo c è pronto
	input wire signed [36:0] c_re;
	input wire signed [36:0] c_im;    //parte reale ed immaginaria di c (C2, 2.35)
	input wire [15:0] n_max;          //numero massimo di iterazioni prima di raggiungere la condizione di escape (non viene salvato internamente ma deve essere fornito durante tutto il calcolo dell'orbita)
	
	output reg done;                  //indica che una delle due orbite ha raggiunto la condizione di escape
	output reg [15:0] n;              //numero di iterazioni necesarie a raggiungere la condizione di escape

	// Definizione stati della MSF
	parameter S1=4'b0000, S2=4'b0001, S3=4'b0010, S4=4'b0011, S5=4'b0100, S6=4'b0101, S7=4'b0110, S8=4'b0111, S9=4'b1000, idle=4'b1001, SA1=4'b1010, SA2=4'b1011, SA3=4'b1100;
	// Definizione dei nodi interni del modulo
	
	// Segnali di ingresso e uscita dei registri
	reg signed [36:0] c_re_d, c_re_q;  //C2, 2.35
	reg signed [36:0] c_im_d, c_im_q;  //C2, 2.35
	reg signed [37:0] R1_1_d, R1_1_q;  //C2, 3.35
	reg signed [36:0] R1_2_d, R1_2_q;  //C2, 2.35
   reg        [35:0] R2_d,   R2_q;    //    1.35
	reg        [35:0] R3_1_d, R3_1_q;  //    1.35
	reg        [36:0] R3_2_d, R3_2_q;  //    2.35
	reg        [36:0] R4_1_d, R4_1_q;  //    2.35
	reg        [36:0] R4_2_d, R4_2_q;  //    2.35
	reg signed [38:0] R5_1_d, R5_1_q;  //C2, 4.35
	reg        [36:0] R5_2_d, R5_2_q;  //    2.35
	reg signed [37:0] R6_d,   R6_q;    //C2, 3.35
	reg signed [38:0] R7_d,   R7_q;    //C2, 4.35
	reg        [15:0] cont_d, cont_q;
	reg        [3:0]  st_d,   st_q;
	reg flag_of_d, flag_of_q;
	
	// Definizione di altri segnali utili alla logica combinatoria
	wire signed [38:0] x_next;         //C2, 4.35
	wire signed [38:0] y_next;         //C2, 4.35
	wire        [37:0] z2_next;        //    3.35
	wire signed [37:0] R1_ext;         //C2, 3.35
	wire signed [37:0] abs_ext;        //C2, 3.35
	wire        [37:0] R2_temp;        //    3.35
	wire        [17:0] in_mult_a;
	wire        [17:0] in_mult_b;
	
	

	// Definizione della logica combinatoria
	assign x_next = R5_1_q-{1'b0, 1'b0, R4_2_q};
	assign y_next = R7_q+{1'b0, flag_of_q, R4_1_q};
	assign z2_next = R4_1_q+R4_2_q;
	assign R1_ext = (st_q==S4) ? {R1_2_q[36], R1_2_q[36:0]} : {R1_1_q[36], R1_1_q[36:0]}; 
	assign abs_ext = (R1_ext[37]==1'b0) ? R1_ext : (-R1_ext);
	assign R2_temp = R2_q >> 2;
	assign in_mult_a = (st_q==S1||st_q==S4||st_q==S7) ? R2_q[35:18] : R2_q[17:0];
	assign in_mult_b = (st_q==S2||st_q==S5||st_q==S8||st_q==SA2) ? R2_q[17:0] : R2_q[35:18];
	
	
	
	// Calcolo del nuovo stato della macchina
	always @ (*) begin
	
		st_d = st_q;
	
		c_re_d=c_re_q;
		c_im_d=c_im_q;
		
		cont_d=cont_q;	
				
		R1_1_d=R1_1_q;
		R1_2_d=R1_2_q;
		
		R2_d=R2_q;
		
		R3_1_d=in_mult_a*in_mult_b;
		R3_2_d=R3_2_q;
					
		R4_1_d=R4_1_q;
		R4_2_d=R4_2_q;
		
		R5_1_d=R5_1_q;
		R5_2_d=R5_2_q;
		
		R6_d=R6_q;
		
		R7_d=R7_q;
		
		flag_of_d=flag_of_q;
				
				
		case (st_q)
		
			S1: begin						// Calcolo |x| e -(x^2+y^2) (+4(|x+y|+2))
				if (abs_ext[36]==1'b1)  // Controllo che x!=-2
					st_d = idle;
				else
					st_d = S2;
				
				R2_d=abs_ext[35:0];
				
				R3_2_d=(R3_2_q[18]==1'b1) ? R3_1_q+(R3_2_q>>19)+1 : R3_1_q+(R3_2_q>>19);
				
				R6_d = (flag_of_q==1'b1) ? (R2_temp[36:0])-R5_2_q : -R5_2_q;
			end
		
			S2: begin			// Calcolo (|x+y|(-2))^2 e -(x^2+y^2)+c_im (+4(|x+y|+2))
				st_d = S3;
				
				R3_2_d=37'b0;
				
				R4_1_d=(R3_2_q[16]==1'b1) ? R3_1_q+(R3_2_q>>17)+1 : R3_1_q+(R3_2_q>>17);
				
				R7_d = {c_im_q[36], c_im_q[36:0]} + R6_q;
			end
			
			S3: begin         // Calcolo y_next=-(x^2+y^2)+c_im (+4(|x+y|+2)) +(|x+y|(-2))^2
				// Controllo che -(x^2+y^2)+c_im(+4(|x+y|+2))<2 e che -2<=y_next<2
				if ((R7_q[38]==1'b0 && R7_q[37:36]!=2'b0) || (y_next[38]!=y_next[37] || y_next[37]!=y_next[36]))
					st_d = idle;
				else
				   st_d = S4;
				
				R1_2_d=y_next[36:0];

				R3_2_d=R3_1_q;
			end              
			
			S4: begin	   	// Calcolo x+y e |y|
				if (abs_ext[36]==1'b1)  // Controllo che y!=-2
					st_d = idle;
				else
					st_d = S5;
				
				R1_1_d=R1_1_q+R1_2_q;
				
				R2_d=abs_ext[35:0];

				R3_2_d=(R3_2_q[18]==1'b1) ? R3_1_q+(R3_2_q>>19)+1 : R3_1_q+(R3_2_q>>19);
			end
			
			S5: begin         // Calcolo x^2 e x+y(-2)
				st_d = S6;
				
				if (R1_1_q[37]!=R1_1_q[36]) begin  // Controllo che x+y non faccia OF
					flag_of_d=1'b1;
					R1_1_d[37]=1'b0;
					R1_1_d[36]=R1_1_q[37];
				end else begin
					flag_of_d=1'b0;
					R1_1_d[37:36]=R1_1_q[37:36];
				end
				R1_1_d[35:0]=R1_1_q[35:0];
				
				R3_2_d=37'b0;
				
				R4_1_d=(R3_2_q[16]==1'b1) ? R3_1_q+(R3_2_q>>17)+1 : R3_1_q+(R3_2_q>>17);
			end
			
			S6: begin        // Calcolo x^2+c_re
			   st_d = S7;

				R3_2_d=R3_1_q;
				
				R5_1_d={c_re_q[36], c_re_q[36:0]}-{1'b0, R4_1_q};
			end
			
			S7: begin       // Calcolo |x+y(-2)|
			   st_d = S8;
				
				R2_d=abs_ext[35:0];

				R3_2_d=(R3_2_q[18]==1'b1) ? R3_1_q+(R3_2_q>>19)+1 : R3_1_q+(R3_2_q>>19);
			end
			
			S8: begin        // Calcolo y^2
			   st_d = S9;

				R3_2_d=37'b0;
				
				R4_2_d=(R3_2_q[16]==1'b1) ? R3_1_q+(R3_2_q>>17)+1 : R3_1_q+(R3_2_q>>17);
			end
			
			S9: begin         // Calcolo x_next=x^2+c_re-y^2
				if (z2_next[37]!=1'b0) begin                            // Controllo che (x^2+y^2)<4
					st_d = idle;
					cont_d=cont_q;
				end else if (cont_q == n_max-1) begin								// Controllo di non essere arrivato a n_max
					st_d = idle;
					cont_d=cont_q+1;
				end else if (x_next[38]!=x_next[37] || x_next[37]!=x_next[36]) begin   // Controllo che -2<=x_next<2
					st_d = idle;
					cont_d=cont_q+1;
				end else begin
					st_d = S1;
					cont_d=cont_q+1;
				end
				
				R1_1_d={1'b0, x_next[36:0]};

				R3_2_d=R3_1_q;
			
				R5_2_d=z2_next[36:0];
			end
			
			idle: begin       // Restituisco il numero di iterazioni al quale mi sono fermato e attendo start=1
				if (start==1'b1) begin
					st_d = SA1;
					cont_d=16'b0000000000000000;
					
					R1_1_d={1'b0, c_re};
					R1_2_d=c_im;
					
					c_re_d=c_re;
					c_im_d=c_im;
				end else begin
					st_d = idle;	
				end 
				
				R3_2_d=R3_2_q;
			end
			
			SA1: begin						// Calcolo |x|
				if (abs_ext[36]==1'b1)  // Controllo che x!=-2
					st_d = idle;
				else
					st_d = SA2;
			
				R2_d=abs_ext[35:0];
					
				R3_1_d=R3_1_q;
				R3_2_d=R3_2_q;
			end
			
			SA2: begin                  // Inizio a calcolare x^2
				st_d = SA3;

				R3_2_d=37'b0;
			end
			
			SA3: begin                  // Continuo a calcolare x^2
				st_d = S4;

				R3_2_d=R3_1_q;
			end
			
			default: begin
				st_d = idle;
			end
			
		endcase
		
	end	
	
	
	// Definizione delle uscite in base allo stato
	always @ (*) begin
	 
		case (st_q)
				
			idle: begin
				done = 1'b1;
				n=cont_q;
			end
			
			default: begin
				done = 1'b0;
				n=16'b0000000000000000;
			end
			
		endcase
		
	end
	
	
	// Definizione dei d flip flop cor reset asincrono positivo
	always @ (posedge clk, posedge reset) begin

		if (reset) begin
			c_re_q  <= 37'sd0;
			c_im_q <= 37'sd0;
			R1_1_q  <= 38'sd0;
			R1_2_q  <= 37'sd0;
			R2_q    <= 36'd0;
			R3_1_q  <= 36'd0;
			R3_2_q  <= 37'd0;
			R4_1_q  <= 37'd0;
			R4_2_q  <= 37'd0;
			R5_1_q  <= 39'sd0;
			R5_2_q  <= 37'd0;
			R6_q    <= 38'sd0;
			R7_q    <= 39'sd0;
			cont_q  <= 16'd0;
			flag_of_q <= 1'b0;
			st_q <= idle;
		end else begin
			c_re_q  <= c_re_d;
			c_im_q <= c_im_d;
			R1_1_q  <= R1_1_d;
			R1_2_q  <= R1_2_d;
			R2_q    <= R2_d;
			R3_1_q  <= R3_1_d;
			R3_2_q  <= R3_2_d;
			R4_1_q  <= R4_1_d;
			R4_2_q  <= R4_2_d;
			R5_1_q  <= R5_1_d;
			R5_2_q  <= R5_2_d;
			R6_q    <= R6_d;
			R7_q    <= R7_d;
			cont_q  <= cont_d;
			flag_of_q <= flag_of_d;
			st_q <= st_d;
		end

	end
	
	
endmodule
