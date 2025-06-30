module fifo_rot(
    clk, rst_n, sft_rst,
    write_en, read_en,
    data_in, data_out,
    empty, full, lfd_state);
    
    parameter width = 9;
    parameter depth = 16;

    input clk, rst_n, sft_rst, read_en, write_en, lfd_state;
    input [7:0] data_in;
    output empty, full;
    output reg [7:0] data_out;

    reg [width-1:0] mem[depth-1:0];
    reg [4:0] wr_pt, rd_pt;
    reg [5:0] count;
    integer i;

    assign empty = (wr_pt == rd_pt) ? 1'b1 : 1'b0;
    assign full  = ((wr_pt[4] != rd_pt[4]) && (wr_pt[3:0] == rd_pt[3:0])) ? 1'b1 : 1'b0;

    // Unified sequential logic for wr_pt, rd_pt, data_out, reset handling
    always @(posedge clk) 
    begin
        if (!rst_n) 
        begin
            wr_pt <= 5'b0;
            rd_pt <= 5'b0;
            data_out <= 8'b0;
            for (i = 0; i < depth; i = i + 1)
                mem[i] <= 9'b0;
        end 
        else if (sft_rst) 
        begin
            wr_pt <= 5'b0;
            rd_pt <= 5'b0;
            data_out <= 8'b0;
            for (i = 0; i < depth; i = i + 1)
                mem[i] <= 9'b0;
        end 
        else 
        begin
            // Write operation
            if (write_en && !full) 
            begin
                mem[wr_pt[3:0]] <= {lfd_state, data_in};
                wr_pt <= wr_pt + 1;
            end

            // Read operation
            if (read_en && !empty) 
            begin
                data_out <= mem[rd_pt[3:0]][7:0];
                rd_pt <= rd_pt + 1;
            end 
            else if (count == 6'b0) 
            begin

                data_out <= 8'b0;
            end
        end
    end

    // Counter logic for packet length
    always @(posedge clk) 
    begin
        if (full && read_en && !empty) 
        begin
            if (mem[rd_pt[3:0]][8]) 
            begin
                count <= mem[rd_pt[3:0]][7:2] + 1;
            end 
            else if (count > 0) 
            begin
                count <= count - 1;
            end 
            else 
            begin
                count <= 6'b0;
            end
        end
    end

endmodule
