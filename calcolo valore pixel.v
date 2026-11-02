
module mandelbrot_step #(parameter W = 24) (x, y, c_re, c_im, x_next, y_next, escape);
	 input  wire signed [W-1:0] x;
    input  wire signed [W-1:0] y;
    input  wire signed [W-1:0] c_re;
    input  wire signed [W-1:0] c_im;

    output wire signed [W-1:0] x_next;
    output wire signed [W-1:0] y_next;
    output escape;
	 
    // Q2.(W-2): due bit interi, incluso il segno.
    localparam F  = W - 2;
    localparam EW = W + 2;

    // Prodotti a piena precisione.
    wire signed [2*W-1:0] xx_full = x * x;
    wire signed [2*W-1:0] yy_full = y * y;
    wire signed [2*W-1:0] xy_full = x * y;

    // Prodotti riportati alla scala della virgola fissa.
    wire signed [W+1:0] xx = xx_full >>> (W-2);
    wire signed [W+1:0] yy = yy_full >>> (W-2);
    wire signed [W+1:0] xy = xy_full >>> (W-2);

    // Estensione del segno degli ingressi.
    wire signed [W+1:0] c_re_ext ={c_re[W-1], c_re[W-1], c_re};
    wire signed [W+1:0] c_im_ext ={c_im[W-1], c_im[W-1], c_im};

    // Risultato non ancora troncato.
    wire signed [W+1:0] x_ext = xx - yy + c_re_ext;
    wire signed [W+1:0] y_ext = (xy <<< 1) + c_im_ext;
	
    // Calcolo la condizione di escape (|z|^2 >= 4) basato sui valori in ingresso.
	 // Set dellla flag sulla condione di escape.
    wire [W+1:0] zz = xx + yy;
    assign escape = ((zz >>> W) !=0);

    // Le uscite sono troncate al formato W bit.
    // In caso di escape, il chiamante deve ignorarle.
    assign x_next = x_ext[W-1:0];
    assign y_next = y_ext[W-1:0];

endmodule
