module Router_1x3 (input clock,resetn,read_enb_0,read_enb_1,read_enb_2,pkt_valid,
				  input [7:0] data_in,
				  output valid_out_0,valid_out_1,valid_out_2,err,busy,
				  output [7:0] data_out_0,data_out_1,data_out_2);
				  
	wire [2:0] write_enb;
    wire fifo_full;
    wire       fifo_full_0, fifo_full_1, fifo_full_2;
    wire       fifo_empty_0, fifo_empty_1, fifo_empty_2;
	wire 	   soft_reset_0,soft_reset_1,soft_reset_2;
    wire       detect_add, ld_state, laf_state, full_state, lfd_state,
               rst_int_reg;
    
    wire       write_enb_reg;
    wire [7:0] dout;
    wire       parity_done,low_packet_valid;

    // Instantiate register
    register REGISTER (
        .clk(clock),
        .resetn(resetn),
        .pkt_valid(pkt_valid),
        .data_in(data_in),
        .fifo_full(fifo_full),
        .detect_add(detect_add),
        .ld_state(ld_state),
        .laf_state(laf_state),
        .full_state(full_state),
        .lfd_state(lfd_state),
        .rst_int_reg(rst_int_reg),
        .dout(dout),
        .err(err),
        .parity_done(parity_done),
        .low_pkt_valid(low_packet_valid)
    );

    // Instantiate FSM
    FSM FSM (
        .clk(clock),
        .resetn(resetn),
        .pkt_valid(pkt_valid),
        .data_in(data_in[1:0]),
        .fifo_full(fifo_full),
        .fifo_empty({fifo_empty_2,fifo_empty_1,fifo_empty_0}),
		.soft_reset({soft_reset_2,soft_reset_1,soft_reset_0}),
		.parity_done(parity_done),
		.low_pkt_valid(low_packet_valid),
        .detect_add(detect_add),
        .write_enb_reg(write_enb_reg),
        .ld_state(ld_state),
        .laf_state(laf_state),
        .full_state(full_state),
        .lfd_state(lfd_state),
        .rst_int_reg(rst_int_reg),
        .busy(busy)
		
    );

    // Instantiate Synchronizer
    synchronizer SYNCHRONIZER (
        .clk(clock),
        .resetn(resetn),
        .detect_add(detect_add),
		.write_enb_reg(write_enb_reg),
		.read_en({(read_enb_2),(read_enb_1),(read_enb_0)}),
		.full({(fifo_full_2),(fifo_full_1),(fifo_full_0)}),
		.empty({fifo_empty_2,fifo_empty_1,fifo_empty_0}),
		.data_in(data_in[1:0]),
		.soft_reset({soft_reset_2,soft_reset_1,soft_reset_0}),
		.write_enb(write_enb),
		.fifo_full(fifo_full),
		.vld_out({(valid_out_2),(valid_out_1),(valid_out_0)})
		
        
    );

    // Instantiate 3 FIFOs
    fifo_rot FIFO_0 (
        .clk(clock),
        .rst_n(resetn),
		.sft_rst(soft_reset_0),
        .write_en(write_enb[0]),
        .read_en(read_enb_0),
        .data_in(dout),
        .data_out(data_out_0),
        .empty(fifo_empty_0),
        .full(fifo_full_0),
        .lfd_state(lfd_state)
    );

    fifo_rot FIFO_1 (
        .clk(clock),
        .rst_n(resetn),
		.sft_rst(soft_reset_1),
        .write_en(write_enb[1]),
        .read_en(read_enb_1),
        .data_in(dout),
        .data_out(data_out_1),
        .empty(fifo_empty_1),
        .full(fifo_full_1),
        .lfd_state(lfd_state)
    );

    fifo_rot FIFO_2 (
        .clk(clock),
        .rst_n(resetn),
		.sft_rst(soft_reset_2),
        .write_en(write_enb[2]),
        .read_en(read_enb_2),
        .data_in(dout),
        .data_out(data_out_2),
        .empty(fifo_empty_2),
        .full(fifo_full_2),
        .lfd_state(lfd_state)
    );
    
endmodule