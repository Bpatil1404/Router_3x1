module synchronizer(
    input detect_add, write_enb_reg, clk, resetn,
    input [2:0] read_en, full, empty,
    input [1:0] data_in,
    output reg [2:0] soft_reset, write_enb,
    output reg fifo_full,
    output [2:0] vld_out);

    reg [4:0] count0, count1, count2;
    reg [1:0] int_addr;

    // Address latch logic
    always @(posedge clk ) 
        begin
        if (!resetn)
            int_addr <= 2'b11;
        else if (detect_add)
            int_addr <= data_in;
        end

    // Write enable and fifo full logic - registered for single driver
    always @(posedge clk) 
        begin
        if (!resetn) 
        begin
            write_enb <= 3'b000;
            fifo_full <= 1'b0;
        end 
        else if (write_enb_reg) 
        begin
            case (int_addr)
                2'b00: 
                begin
                    write_enb <= 3'b001;
                    fifo_full <= full[0];
                end
                2'b01: 
                begin
                    write_enb <= 3'b010;
                    fifo_full <= full[1];
                end
                2'b10: 
                begin
                    write_enb <= 3'b100;
                    fifo_full <= full[2];
                end
                default: 
                begin
                    write_enb <= 3'b000;
                    fifo_full <= 1'b0;
                end
            endcase
        end 
        else 
        begin
            write_enb <= 3'b000;
            fifo_full <= 1'b0;
        end
    end

    // vld_out generation
    assign vld_out = ~empty;

    // Soft reset for FIFO 0 - Sequential part
    always @(posedge clk) 
    begin
        if (!resetn) 
        begin
            count0 <= 5'd0;
            soft_reset[0] <= 1'b0;
        end 
        else 
        begin
            if (vld_out[0] && !read_en[0]) 
            begin
                if (count0 == 5'd29) 
                begin
                    soft_reset[0] <= 1'b1;
                    count0 <= 5'd0; // Reset counter
                end 
                else 
                begin
                    soft_reset[0] <= 1'b0;
                    count0 <= count0 + 1; // Increment counter
                end
            end 
            else 
            begin
                soft_reset[0] <= 1'b0;
                count0 <= 5'd0;
            end
        end
    end

    // Soft reset for FIFO 1 - Sequential part
    always @(posedge clk) 
    begin
        if (!resetn) 
        begin
            count1 <= 5'd0;
            soft_reset[1] <= 1'b0;
        end 
        else 
        begin
            if (vld_out[1] && !read_en[1]) 
            begin
                if (count1 == 5'd29) 
                begin
                    soft_reset[1] <= 1'b1;
                    count1 <= 5'd0; // Reset counter
                end 
                else 
                begin
                    soft_reset[1] <= 1'b0;
                    count1 <= count1 + 1; // Increment counter
                end
            end 
            else 
            begin
                soft_reset[1] <= 1'b0;
                count1 <= 5'd0;
            end
        end
    end

    // Soft reset for FIFO 2 - Sequential part
    always @(posedge clk) 
    begin
        if (!resetn) 
        begin
            count2 <= 5'd0;
            soft_reset[2] <= 1'b0;
        end 
        else 
        begin
            if (vld_out[2] && !read_en[2]) 
            begin
                if (count2 == 5'd29) 
                begin
                    soft_reset[2] <= 1'b1;
                    count2 <= 5'd0; // Reset counter
                end 
                else 
                begin
                    soft_reset[2] <= 1'b0;
                    count2 <= count2 + 1; // Increment counter
                end
            end 
            else 
            begin
                soft_reset[2] <= 1'b0;
                count2 <= 5'd0;
            end
        end
    end

endmodule
