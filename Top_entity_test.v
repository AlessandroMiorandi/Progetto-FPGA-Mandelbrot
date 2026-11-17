

module Top_entity_test #(parameter W = 27, parameter W_CONT = 8, parameter N_INST = 30)(clk, reset, start, n_max, c_re_bus, c_im_bus, stop_bus, n_bus);
    input wire clk;
    input wire reset;
    input wire start;

    input wire [W_CONT-1:0] n_max;

    input wire [N_INST*W-1:0] c_re_bus;
    input wire [N_INST*W-1:0] c_im_bus;

    output wire [N_INST-1:0] stop_bus;
    output wire [N_INST*W_CONT-1:0] n_bus;
	 
    genvar i;

    generate
        for (i = 0; i < N_INST; i = i + 1) begin : GEN_MANDELBROT

            mandelbrot_n_finder #(
                .W(W),
                .W_CONT(W_CONT)
            ) finder_inst (
                .c_re(c_re_bus[(i+1)*W-1:i*W]),
                .c_im(c_im_bus[(i+1)*W-1:i*W]),
                .n_max(n_max),
                .clk(clk),
                .reset(reset),
                .start(start),
                .stop(stop_bus[i]),
                .n(n_bus[(i+1)*W_CONT-1:i*W_CONT])
            );

        end
    endgenerate

endmodule
