`timescale 1ns / 1ps

module keypad_poller(
	input clk,
	input reset, //active low
	input [3:0] keypad_row_in, //TODO input synchronized with two flip flops
	output reg [3:0] keypad_col_out,
	output reg [3:0] row_out,
	output reg key_pressed
);

//TODO parametrize debounce and hold time

localparam [2:0]
	state_init      = 3'd0,
	state_shift_column  = 3'd1, //shift and write column
	state_wait_debounce = 3'd2,
	state_check_row = 3'd3,
	state_next_row  = 3'd4,
	state_wait_hold   = 3'd5,
	state_check_row2= 3'd6,
	state_return    = 3'd7;
	
localparam [3:0] NO_KEY = 4'b0000;
	
reg [2:0] state;

reg [15:0] timer_counter;
localparam [15:0] 
	ticks_hold = 19'd24000,     // 2 ms
	ticks_debounce = 19'd120000; // 10 ms

// rotate column (0001, 0010, 0100, 1000)
// check if we get any output - if not, rotate again
// check if the output is held, emit the read row pins

always @(posedge clk or posedge reset) 
begin
	if(reset) begin
		row_out <= NO_KEY;
		state <= state_init;
		keypad_col_out <= 4'b0001;
		key_pressed <= 1'b0;
	end else begin
		case(state)
			state_init:
				begin
					row_out <= NO_KEY;
					state <= state_shift_column;
					key_pressed <= 1'b0;
				end
			state_shift_column:
				begin
					keypad_col_out <= { keypad_col_out[2:0], keypad_col_out[3] };
					timer_counter <= 15'h0;
					state <= state_wait_debounce;
				end
			state_wait_debounce:
				begin
					timer_counter <= timer_counter + 1;
					if(timer_counter == ticks_debounce)
						state <= state_check_row;
				end
			state_check_row:
				//if no key pressed, check next column
				if(keypad_row_in == NO_KEY) 
					state <= state_shift_column;
				else begin
					row_out <= keypad_row_in;
					state <= state_wait_hold;
					timer_counter <= 15'h0;
				end
			state_wait_hold:
				begin
					timer_counter <= timer_counter + 1;
					if(timer_counter == ticks_hold)
						state <= state_check_row2;
				end
			state_check_row2:
				//if a key is held, don't advance the state
				//TODO we should have some signal that the key is 
				begin
					if (keypad_row_in != NO_KEY)
					begin
						state <= state_wait_hold;
						key_pressed <= 1'b1;
					end else
					begin
						state <= state_init;
					end
				end
		endcase
	end
	
end


endmodule