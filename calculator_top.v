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
 
 wire [3:0] keypad_out;
 wire [3:0] keypad_poller_row;
 wire [3:0] keypad_poller_column;
 
 wire keypad_key_pressed;
 
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
		.binIN({6'b000000, keypad_out}),
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


  
always @(posedge Clk)
begin
	clk_div_counter <= clk_div_counter + 1;
	if(clk_div_counter == 0) begin
		counter <= counter + 1;		
	end
end

assign LED = {~reset, 1'b0, keypad_key_pressed, 1'b0, keypad_poller_column};
assign led_ext = IO_P4_ROW;
assign led_ext2 = keypad_poller_row;
assign IO_P4_COL = keypad_poller_column;

endmodule
