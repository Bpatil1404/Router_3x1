module FSM(	input clk,resetn,pkt_valid,parity_done,fifo_full,low_pkt_valid,
            input [1:0] data_in,
			input [2:0] soft_reset,fifo_empty,
			output busy,detect_add,ld_state,laf_state,full_state,write_enb_reg,rst_int_reg,lfd_state);

parameter   DECODE_ADDRESS	 	= 3'B000,
			LOAD_FIRST_DATA 	= 3'B001,
			LOAD_DATA			= 3'B010,
			WAIT_TILL_EMPTY 	= 3'B011,
			CHECK_PARITY_ERROR	= 3'B100,
			LOAD_PARITY			= 3'B101,
			FIFO_FULL_STATE		= 3'B110,
			LOAD_AFTER_FULL		= 3'B111;

reg [2:0] PS,NS;




always@(posedge clk)
	begin
		if(!resetn)
			PS<=DECODE_ADDRESS;
		else if(soft_reset[0] || soft_reset[1] ||soft_reset[2])
			PS <= DECODE_ADDRESS;
		else
			PS <= NS;
	end
	
always@(*)
	begin
		NS = DECODE_ADDRESS;
		case(PS)
		
		DECODE_ADDRESS :	
						begin
							if(((pkt_valid) && (data_in[1:0] == 0) && (fifo_empty[0])) ||
							   ((pkt_valid) && (data_in[1:0] == 1) && (fifo_empty[1])) ||
							   ((pkt_valid) && (data_in[1:0] == 2) && (fifo_empty[2])))
							   
							   NS = LOAD_FIRST_DATA;
							else if(((pkt_valid) && (data_in[1:0] == 0) && (!fifo_empty[0])) ||
									((pkt_valid) && (data_in[1:0] == 1) && (!fifo_empty[1])) ||
									((pkt_valid) && (data_in[1:0] == 2) && (!fifo_empty[2])))
									
								NS = WAIT_TILL_EMPTY;
								
							else
								NS = DECODE_ADDRESS;
						end
		
		LOAD_FIRST_DATA : NS = LOAD_DATA;
		
		LOAD_DATA		:
						begin
							if (fifo_full)
								NS = FIFO_FULL_STATE;
							else if (!fifo_full && !pkt_valid)
								NS = LOAD_PARITY;
							else
								NS = LOAD_DATA;
						end
						
		WAIT_TILL_EMPTY	:
						begin
							if(fifo_empty[0] || fifo_empty[1] || fifo_empty[2])
								NS = LOAD_FIRST_DATA;
							else
								NS = WAIT_TILL_EMPTY;
						end
						
		CHECK_PARITY_ERROR:
						begin
							if(fifo_full)
								NS = FIFO_FULL_STATE;
							else if	(!fifo_full)
								NS = DECODE_ADDRESS;
						end
						
		LOAD_PARITY      :	NS = CHECK_PARITY_ERROR;
		
		FIFO_FULL_STATE	 : 
						begin
							if(!fifo_full)
								NS = LOAD_AFTER_FULL;
							else if(fifo_full)
								NS = FIFO_FULL_STATE;
						end
						
		LOAD_AFTER_FULL	  :
							begin
								if(!parity_done && low_pkt_valid)
									NS = LOAD_PARITY;
								else if(!parity_done && !low_pkt_valid)
									NS = LOAD_DATA;
								else if(parity_done)
									NS = DECODE_ADDRESS;
							end
							
		endcase
	end
	
	assign detect_add    =  ((PS == DECODE_ADDRESS )?1:0);
	assign write_enb_reg =  (((PS == LOAD_DATA) || (PS == LOAD_PARITY) || (PS == FIFO_FULL_STATE) || (PS == LOAD_AFTER_FULL) || (PS == WAIT_TILL_EMPTY))?1:0);
	assign full_state	 =  ((PS == FIFO_FULL_STATE) ?1:0);
	assign lfd_state	 =	((PS == LOAD_FIRST_DATA)?1:0);
	assign busy			 =	(((PS == LOAD_FIRST_DATA) || (PS == LOAD_DATA) || (PS == LOAD_PARITY) || (PS == FIFO_FULL_STATE) || (PS == LOAD_AFTER_FULL) || (PS == WAIT_TILL_EMPTY) || (PS == CHECK_PARITY_ERROR))?1:0);
	assign ld_state		 =	((PS == LOAD_DATA)?1:0);
	assign laf_state 	 =	((PS == LOAD_AFTER_FULL)?1:0); 
	assign rst_int_reg   =	((PS == CHECK_PARITY_ERROR)?1:0);
	
endmodule



  