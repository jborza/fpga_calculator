`timescale 1ns / 1ps

module calculator_top(
	input Clk,
	input reset,	
	output [7:0] SevenSegment,
	output [2:0] Enable, //7-segment enable bits
	output [7:0] LED,
	input [3:0] IO_P4_ROW,
	output [3:0] IO_P4_COL, //with PULLUP option,
	input [3:0] DPSwitch,
	output [7:0] led_ext,
	output [7:0] led_ext2
 );
 
 //signals
 wire[3:0] ones, tens, hundreds;
 wire[7:0] sseg_a, sseg_b, sseg_c;
 
 reg [9:0] counter;
 reg [19:0] clk_div_counter;
 
 //keypad wiring
 wire [3:0] keypad_out;
 wire [3:0] keypad_poller_row;
 wire [3:0] keypad_poller_column;
 
 wire keypad_key_pressed;
 reg keypad_key_pressed_prev;
 
 reg [7:0] keypress_counter;
 
 //calculator state
 reg [3:0] state;

//calculator registers
reg [15:0] reg_arg;
reg [15:0] reg_result;
reg [15:0] reg_display;
reg reg_operator;
reg reg_operator_next;
  
 
 //components
 
 seven_seg_4bit sseg_hundreds(
	.Number(hundreds),
	.SevenSegment(sseg_a)
 );

 seven_seg_4bit sseg_tens(
	.Number(tens),
	.SevenSegment(sseg_b)
 );
  
 seven_seg_4bit sseg_ones(
	.Number(ones),
	.SevenSegment(sseg_c)
 );
 
seven_seg_driver sseg_driver(
		.A(sseg_a),
		.B(sseg_b),
		.C(sseg_c),
		.SevenSegment(SevenSegment),
		.Enable(Enable),
		.Clk12Mhz(Clk)
 );
	
 bin2bcd_10bit inst_bin2bcd(
		.binIN(reg_display[9:0]),
		.ones(ones),
		.tens(tens),
		.hundreds(hundreds)
 );
 
 keypad_encoder inst_keypad_encoder(
		.clk(Clk),
		.reset(~reset),
		.rows(keypad_poller_row),
		.columns(keypad_poller_column),
		.keycode_output(keypad_out)
 );
 
 keypad_poller inst_poller (
    .clk(Clk), 
    .reset(~reset), 
    .keypad_row_in(IO_P4_ROW), 
    .keypad_col_out(keypad_poller_column), 
    .row_out(keypad_poller_row), 
    .key_pressed(keypad_key_pressed)
    );

localparam [3:0] 
	state_read_digit = 4'd0,
	state_digit_pressed = 4'd1,
	state_plus_pressed = 4'd2,
	state_minus_pressed = 4'd3,
	state_display_arg = 4'd4,
	state_calculate = 4'd5,
	state_display_result = 4'd6,
	state_clear = 4'd7;
	
localparam 
	OP_PLUS = 1'b0,
	OP_MINUS = 1'b1;
	

always @(posedge Clk or negedge reset)
begin
	if(~reset) begin
		state <= state_clear;
	end 
	else begin
		case(state)
			state_clear:
				begin
					reg_arg <= 0;
					reg_result <= 0;
					reg_display <= 0;
					reg_operator <= OP_PLUS;
					state <= state_read_digit;
				end
			state_read_digit:
				begin
					//check if a new key came in
					if(keypad_key_pressed && !keypad_key_pressed_prev)
					begin
						keypress_counter <= keypress_counter + 1;
						//check if our key is a digit?
						if(keypad_out < 4'hA) 
							state <= state_digit_pressed;
						else if(keypad_out == 4'hC) //clear
							state <= state_clear;
						else if(keypad_out == 4'hE) //plus
							state <= state_plus_pressed;
						else if(keypad_out == 4'hF) //minus
							state <= state_minus_pressed;
					end
					keypad_key_pressed_prev <= keypad_key_pressed;
				end
			state_digit_pressed:
				begin
					//don't consume another keypress after hundreds
					if(reg_arg < 16'd100) 
					begin
						reg_arg <= reg_arg * 10 + keypad_out;
					end
					state <= state_display_arg;					
				end
			state_plus_pressed:
				begin
					reg_operator_next <= OP_PLUS;
					state <= state_calculate; 
				end
			state_minus_pressed:
				begin
					reg_operator_next <= OP_MINUS;
					state <= state_calculate;
				end
			state_calculate:
				begin
					if(reg_operator == OP_PLUS)
						reg_result <= reg_result + reg_arg;
					else //OP_MINUS
						reg_result <= reg_result - reg_arg;
					reg_operator <= reg_operator_next;
					reg_arg <= 0;
					state <= state_display_result;
				end
			state_display_arg: 
				begin
					reg_display <= reg_arg;
					state <= state_read_digit;
				end
			state_display_result:
				begin
					reg_display <= reg_result;
					state <= state_read_digit;
				end
		endcase
	end
	
	/*clk_div_counter <= clk_div_counter + 1;
	if(clk_div_counter == 0) begin
		counter <= counter + 1;		
	end
	//keypress counter
	if (keypad_key_pressed && (keypad_key_pressed  != keypad_key_pressed_prev))
	begin
		keypress_counter <= keypress_counter + 1;
		//TODO increment my number register
	end
	keypad_key_pressed_prev <= keypad_key_pressed;*/
end

assign LED = {~reset, 1'b0, keypad_key_pressed, 1'b0, state};
assign led_ext = IO_P4_ROW;
assign led_ext2 = keypress_counter;
assign IO_P4_COL = keypad_poller_column;

endmodule
