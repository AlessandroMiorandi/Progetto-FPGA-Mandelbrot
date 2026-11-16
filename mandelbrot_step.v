
module mandelbrot_step #(parameter W = 24) (x, y, c_re, c_im, x_next, y_next, escape);
	 input  wire signed [W-1:0] x;
    input  wire signed [W-1:0] y;
    input  wire signed [W-1:0] c_re;
    input  wire signed [W-1:0] c_im;

    output wire signed [W-1:0] x_next;
    output wire signed [W-1:0] y_next;
    output escape;
	 
	 // Risultati dei prodotti a piena precisione
    wire signed [2*W-1:0] xx_full;
    wire signed [2*W-1:0] yy_full;
    wire signed [2*W-1:0] xy_full;
	 
	 // Variabili per i risultati dei prodotti riportati alla scala della virgola fissa
    wire signed [W+1:0] xx;
    wire signed [W+1:0] yy;
    wire signed [W+1:0] xy;
	 
	 // Variabili per l'estensione del segno degli ingressi
    wire signed [W+1:0] c_re_ext;
    wire signed [W+1:0] c_im_ext;
	 
	 // Risultati della moltiplicazione, con ampiezza adeguata alla loro derivazione
    wire signed [W+1:0] x_ext;
    wire signed [W+1:0] y_ext;
	 
	 // Variabile per il calcolo della condizione di escape
    wire [W+1:0] zz;
	 
	 
	 // Svolgimento delle operazioni
    // Prodotti a piena precisione.
    assign	xx_full = x * x;
	 assign	yy_full = y * y;
    assign	xy_full = x * y;

    // Prodotti riportati alla scala della virgola fissa.
    assign	xx = xx_full >>> (W-2);
    assign	yy = yy_full >>> (W-2);
    assign	xy = xy_full >>> (W-2);

    // Estensione del segno degli ingressi.
    assign	c_re_ext = {c_re[W-1], c_re[W-1], c_re};
    assign	c_im_ext = {c_im[W-1], c_im[W-1], c_im};

    // Risultato non ancora troncato.
    wire signed [W+1:0] x_ext = xx - yy + c_re_ext;
    wire signed [W+1:0] y_ext = (xy <<< 1) + c_im_ext;
	
    // Calcolo la condizione di escape (|z|^2 >= 4) basato sui valori in ingresso.
	 // Set della flag sulla condione di escape.
    wire [W+1:0] zz = xx + yy;
    assign escape = ((zz >>> W) !=0);

    // Le uscite sono troncate al formato W bit.
    // In caso di escape, il chiamante deve ignorarle.
    assign x_next = x_ext[W-1:0];
    assign y_next = y_ext[W-1:0];

endmodule
