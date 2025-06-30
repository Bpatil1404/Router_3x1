module register (
    input clk, resetn, pkt_valid, fifo_full, rst_int_reg, detect_add, ld_state, laf_state, full_state, lfd_state,
    input [7:0] data_in,
    output reg parity_done, low_pkt_valid, err,
    output reg [7:0] dout
);
    reg [7:0] header, fifo_full_state, internal_parity, packet_parity;

    
    always @(posedge clk) begin
        if (!resetn) 
        begin
            dout <= 8'b0;
            parity_done <= 1'b0;
            low_pkt_valid <= 1'b0;
            err <= 1'b0;
            internal_parity <= 0;
            packet_parity <= 0;
            header <= 0;
            fifo_full_state <= 0;
        end 
        else 
        begin
            // Dout logic
            if (detect_add && pkt_valid && data_in[1:0] != 2'b11)
                header <= data_in;
            else if (lfd_state)
                dout <= header;
            else if (ld_state && !fifo_full)
                dout <= data_in;
            else if (ld_state && fifo_full)
                fifo_full_state <= data_in;
            else if (laf_state)
                dout <= fifo_full_state;

            // Internal parity calculation logic
            if (detect_add)
                internal_parity <= 0;
            else if (lfd_state)
                internal_parity <= internal_parity ^ header;
            else if (pkt_valid && ld_state && !full_state)
                internal_parity <= internal_parity ^ data_in;

            // Packet parity calculation
            if (detect_add)
                packet_parity <= 0;
            else if (ld_state && !pkt_valid)
                packet_parity <= data_in;

            // Error calculation
            if (parity_done) begin
                if (packet_parity != internal_parity)
                    err <= 1'b1;
                else
                    err <= 1'b0;
            end

            // Parity done logic
            if ((ld_state && !fifo_full && !pkt_valid) || (laf_state && low_pkt_valid && !parity_done))
                parity_done <= 1'b1;
            else
                parity_done <= 1'b0;

            // Low packet valid logic
            if (rst_int_reg)
                low_pkt_valid <= 1'b0;
            else if (ld_state && !pkt_valid)
                low_pkt_valid <= 1'b1;
            else
                low_pkt_valid <= 1'b0;
        end
    end
endmodule
