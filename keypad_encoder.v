`timescale 1ns / 1ps

/*
-- 16 digit keypad encoder module
-- 
-- 1 2 3 A
-- 4 5 6 B
-- 7 8 9 C
-- * 0 # D	

-- let's treat special characters: 
-- * = 0xE and # = 0xF
-- pins 1-4 from the keypad are column (output) pins
-- pins 5-8 from the keypad are the row (input) pins
*/

module keypad_encoder(
	input clk,
	input reset,
	input [3:0] rows,
	input [3:0] columns, 
	output reg [3:0] keycode_output
 );

localparam [3:0] 
	unknown = 4'bxxxx,
	none = 4'b0000,
	one = 4'b0001,
	two = 4'b0010,
	three = 4'b0100,
	four = 4'b1000;
	
always @(posedge clk) begin
	if(reset) begin
		keycode_output <= unknown;
	end else begin
		case(columns)
			one:
				case(rows)
					one: keycode_output   <= 4'h1;
					two: keycode_output   <= 4'h4;
					three: keycode_output <= 4'h7;
					four: keycode_output  <= 4'he;
					default: keycode_output <= unknown;
				endcase
			two:
				case(rows)
					one: keycode_output   <= 4'h2;
					two: keycode_output   <= 4'h5;
					three: keycode_output <= 4'h8;
					four: keycode_output  <= 4'h0;
					default: keycode_output <= unknown;
				endcase
			three:
				case(rows)
					one: keycode_output   <= 4'h3;
					two: keycode_output   <= 4'h6;
					three: keycode_output <= 4'h9;
					four: keycode_output  <= 4'hf;
					default: keycode_output <= unknown;
				endcase
			four:
				case(rows)
					one: keycode_output   <= 4'ha;
					two: keycode_output   <= 4'hb;
					three: keycode_output <= 4'hc;
					four: keycode_output  <= 4'hd;
					default: keycode_output <= unknown;
				endcase
			default: 
				keycode_output <= 4'bxxxx;
		endcase
	end
end
endmodule
