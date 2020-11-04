`timescale 1ns / 1ps
//https://en.wikipedia.org/wiki/Division_algorithm#Division_by_repeated_subtraction
/*
this algorithm finds a remainder
while N = D do
  N := N - D
  Q := Q + 1
end
R := N
return (Q,R)
*/

module integer_divider #(parameter SIZE=10) (
	input clk,
	input reset,
	input [SIZE-1:0] numerator,
	input [SIZE-1:0] denominator,
	input start,
	output [SIZE-1:0] quotient,
	output [SIZE-1:0] remainder,
	output reg done
 );

//working registers
reg [SIZE-1:0] n;
reg [SIZE-1:0] d;
reg [SIZE-1:0] q; //the quotient is the number of times we subtracted n - d
reg busy;


always @(posedge clk or posedge reset) 
begin
	if(reset) begin
		//reset working registers
		n <= 0;
		d <= 0;
		q <= 0;
		done <= 1'b0;
	end
	else begin
		if(start) begin
			n <= numerator;
			d <= denominator;
			busy <= 1'b1;
		end 
		else if(busy) begin
			if(n >= d) begin
				q <= q + 1;
				n <= n - d;
			end
			else begin
				busy <= 1'b0;
				done <= 1'b1;
			end
		end
	end
end

assign quotient = q;
assign remainder = n;

endmodule
