`timescale 1ns / 1ps



module integer_divider_test;

	// Inputs
	reg clk;
	reg reset;
	reg [9:0] numerator;
	reg [9:0] denominator;
	reg start;

	// Outputs
	wire [9:0] quotient;
	wire [9:0] remainder;
	wire done;

	// Instantiate the Unit Under Test (UUT)
	integer_divider #(10) uut (
		.clk(clk), 
		.reset(reset), 
		.numerator(numerator), 
		.denominator(denominator), 
		.start(start), 
		.quotient(quotient), 
		.remainder(remainder), 
		.done(done)
	);
	
	always begin
    #10 clk = ~clk;
	end

	initial begin
		// Initialize Inputs
		clk = 1;
		reset = 1;
		numerator = 0;
		denominator = 0;
		start = 0;

		// Wait 20 ns for global reset to finish
		#20;
		reset = 0;
		#20;
        
		// Add stimulus here
		numerator = 57;
		denominator = 13;
		start = 1; //signal the divider to start dividing
		#20;
		start = 0;
		
		
		#160;
	end
      
endmodule

