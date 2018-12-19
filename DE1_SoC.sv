module DE1_SoC (CLOCK_50, HEX0, HEX1, HEX2, HEX3, HEX4, HEX5, KEY, LEDR, SW);
	 input logic 			CLOCK_50; // 50MHz clock.
	 output logic 	[6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5;
	 output logic 	[9:0] LEDR;
	 input logic 	[3:0] KEY; // True when not pressed, False when pressed
	 input logic 	[9:0] SW;
	 
	 // Generate clk off of CLOCK_50, whichClock picks rate.
	 logic [31:0] clk;
	 parameter whichClock = 15;
	 clock_divider cdiv (CLOCK_50, clk);
	 
	 //logic reset;
	 logic key0, key3;
	 logic key0_Stable, key3_Stable;
	 
	 logic cyber;

	 
	 //Assign HEX 5 - 1 to default display
	 
	 assign HEX4 = 7'b1111111;
	 assign HEX3 = 7'b1111111;
	 assign HEX2 = 7'b1111111;
	 assign HEX1 = 7'b1111111;
	 
	 doubleFlip ff1 (.clk(clk[whichClock]), .reset(SW[9]), .button(~KEY[0]), .out(key0_Stable));
	 doubleFlip ff2 (.clk(clk[whichClock]), .reset(SW[9]), .button(cyber), .out(key3_Stable));
	 
	 
	 userInput player (.clk(clk[whichClock]), .reset(SW[9]), .button(key0_Stable), .out(key0));
	 userInput cyborg (.clk(clk[whichClock]), .reset(SW[9]), .button(key3_Stable), .out(key3));
	
	 //Light instantiations
	 
	 normalLight one (.clk(clk[whichClock]), .reset(SW[9]), .L(key3), .R(key0), .NL(LEDR[2]), .NR(1'b0), .lightOn(LEDR[1]), .playAgain(playAgain));
	 normalLight two (.clk(clk[whichClock]), .reset(SW[9]), .L(key3), .R(key0), .NL(LEDR[3]), .NR(LEDR[1]), .lightOn(LEDR[2]), .playAgain(playAgain));
	 normalLight three (.clk(clk[whichClock]), .reset(SW[9]), .L(key3), .R(key0), .NL(LEDR[4]), .NR(LEDR[2]), .lightOn(LEDR[3]), .playAgain(playAgain));
	 normalLight four (.clk(clk[whichClock]), .reset(SW[9]), .L(key3), .R(key0), .NL(LEDR[5]), .NR(LEDR[3]), .lightOn(LEDR[4]), .playAgain(playAgain));
	 
	 centerLight five (.clk(clk[whichClock]), .reset(SW[9]), .L(key3), .R(key0), .NL(LEDR[6]), .NR(LEDR[4]), .lightOn(LEDR[5]), .playAgain(playAgain));
	 
	 normalLight six (.clk(clk[whichClock]), .reset(SW[9]), .L(key3), .R(key0), .NL(LEDR[7]), .NR(LEDR[5]), .lightOn(LEDR[6]), .playAgain(playAgain));
	 normalLight seven (.clk(clk[whichClock]), .reset(SW[9]), .L(key3), .R(key0), .NL(LEDR[8]), .NR(LEDR[6]), .lightOn(LEDR[7]), .playAgain(playAgain));
	 normalLight eight (.clk(clk[whichClock]), .reset(SW[9]), .L(key3), .R(key0), .NL(LEDR[9]), .NR(LEDR[7]), .lightOn(LEDR[8]), .playAgain(playAgain));
	 normalLight nine (.clk(clk[whichClock]), .reset(SW[9]), .L(key3), .R(key0), .NL(1'b0), .NR(LEDR[8]), .lightOn(LEDR[9]), .playAgain(playAgain));
	 
	 //computer button generator

	 logic [9:0] lfsr_out;
	 
	 LFSR random(.clk(clk[whichClock]), .reset(SW[9]), .Q(lfsr_out));
	 compButton comp(.clk(clk[whichClock]), .reset(SW[9]), .Q(lfsr_out), .SW(SW[8:0]), .out(cyber));
	 
	 //who wins?
	 
	 victory matchEnds (.clk(clk[whichClock]), .reset(SW[9]), .LED9(LEDR[9]), .LED1(LEDR[1]), .L(key3), .R(key0), .playAgain(playAgain), .HEX0(HEX0), .HEX5(HEX5));
	 //counter Player (.clk(clk[whichClock]), .reset(SW[9]), .LED9(1'b0), .LED1(LEDR[1]), .L(key3), .R(key0), .display(HEX0), .out(playAgain));
	 //counter Cyborg (.clk(clk[whichClock]), .reset(SW[9]), .LED9(LEDR[9]), .LED1(1'b0), .L(key3), .R(key0), .display(HEX5), .out(playAgain));
	 
	
	 
endmodule

 //divided_clocks[0] = 25MHz, [1] = 12.5Mhz, ... [23] = 3Hz, [24] = 1.5Hz, [25] = 0.75Hz, ...
module clock_divider (clock, divided_clocks);
	 input logic 			clock; //reset?
	 output logic [31:0] divided_clocks = 0; 

	 always_ff @(posedge clock) begin
		divided_clocks <= divided_clocks + 1;
	 end

endmodule 

module DE1_SoC_testbench();
	logic 		CLOCK_50;
	logic [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5;
	logic [9:0] LEDR;
	logic [3:0] KEY;
	logic [9:0] SW;
	
	DE1_SoC dut (.CLOCK_50, .HEX0, .HEX1, .HEX2, .HEX3, .HEX4, .HEX5, .KEY, .LEDR, .SW);
	
	parameter CLOCK_PERIOD = 100;
	initial begin
		CLOCK_50 <= 0;
		forever #(CLOCK_PERIOD / 2)
		CLOCK_50 <= ~CLOCK_50;
	end
	
	initial begin
																@(posedge CLOCK_50);
																@(posedge CLOCK_50);
		SW[9] <= 1;											@(posedge CLOCK_50);
																@(posedge CLOCK_50);
																@(posedge CLOCK_50);
																@(posedge CLOCK_50);
		SW[9] <= 0;											@(posedge CLOCK_50);
																@(posedge CLOCK_50);
																@(posedge CLOCK_50);
																@(posedge CLOCK_50);
		KEY[0] <= 1; SW[8:0] = 9'b000000000;		@(posedge CLOCK_50);
																@(posedge CLOCK_50);
		KEY[0] <= 0;										@(posedge CLOCK_50);
																@(posedge CLOCK_50);
		KEY[0] <= 1;										@(posedge CLOCK_50);
																@(posedge CLOCK_50);
		KEY[0] <= 0;										@(posedge CLOCK_50);
																@(posedge CLOCK_50);
		KEY[0] <= 1; 										@(posedge CLOCK_50);
																@(posedge CLOCK_50);
		KEY[0] <= 0;										@(posedge CLOCK_50);
																@(posedge CLOCK_50);
		KEY[0] <= 1;										@(posedge CLOCK_50);
																@(posedge CLOCK_50);
		KEY[0] <= 0;										@(posedge CLOCK_50);
																@(posedge CLOCK_50);
		KEY[0] <= 1;										@(posedge CLOCK_50);
																@(posedge CLOCK_50);
		KEY[0] <= 0;										@(posedge CLOCK_50);
																@(posedge CLOCK_50);
		KEY[0] <= 1;										@(posedge CLOCK_50);
																@(posedge CLOCK_50);
		KEY[0] <= 0;										@(posedge CLOCK_50);
																@(posedge CLOCK_50);
		KEY[0] <= 1;										@(posedge CLOCK_50);
																@(posedge CLOCK_50);
		KEY[0] <= 0; 										@(posedge CLOCK_50);
																@(posedge CLOCK_50);
																@(posedge CLOCK_50);
																@(posedge CLOCK_50);
																@(posedge CLOCK_50);
		SW[9] <= 1; 										@(posedge CLOCK_50);
																@(posedge CLOCK_50);
		SW[9] <= 0;											@(posedge CLOCK_50);
																@(posedge CLOCK_50);
		KEY[0] <= 0; SW[8:0] <= 9'b0111111110;		@(posedge CLOCK_50);
																@(posedge CLOCK_50);
																@(posedge CLOCK_50);
																@(posedge CLOCK_50);
																@(posedge CLOCK_50);
																@(posedge CLOCK_50);
																@(posedge CLOCK_50);
																@(posedge CLOCK_50);
																@(posedge CLOCK_50);
																@(posedge CLOCK_50);
		$stop;
	end
endmodule
