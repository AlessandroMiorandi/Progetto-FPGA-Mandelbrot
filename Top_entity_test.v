


module Top_entity_test #(parameter N_INST = 48) (clk, reset, start_bus, n_max, c_re_bus, c_im_bus, done_bus, n_bus);
    input wire clk;
    input wire reset;
    input wire [N_INST-1:0] start_bus;
    input wire n_max;

    input wire [N_INST*37-1:0] c_re_bus;
    input wire [N_INST*37-1:0] c_im_bus;

    output wire [N_INST-1:0] done_bus;
    output wire [N_INST*16-1:0] n_bus;


    genvar i;

    generate
        for (i = 0; i < N_INST; i = i + 1) begin : GEN_MANDELBROT

            mandelbrot_pipeline m_p_inst (

                .clk(clk),
                .reset(reset),
					 .start (start_bus[i]),

                .c_re(c_re_bus[(i+1)*37-1:i*37]),
                .c_im(c_im_bus[(i+1)*37-1:i*37]),

                .n_max(n_max),

                .done(done_bus[i]),
                .n(n_bus[(i+1)*16-1:i*16])
            );

        end
    endgenerate

endmodule
