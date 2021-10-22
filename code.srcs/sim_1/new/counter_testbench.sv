`timescale 1ns / 1ps

//////////////////////////////////////////////////////////////////////////////////
// testbenches requires a module without inputs or outputs
// It's only a "virtual" module. We cannot implement hardware with this!!!
module counter_testbench();
  
    // We need to give values at the inputs, so we define them as registers  
	logic clk, resetN, PushButton;
	logic IncPulse_out;
	
	T1_design1 DUT_FSM(
		.clk,
		.resetN,
		.PushButton,
		.IncPulse_out
	);

	// generate a clock signal that inverts its value every five time units
	always  #1 clk=~clk;
	
	//here we assign values to the inputs
	initial begin
		clk = 1'b0;
		resetN = 1'b1;
		PushButton = 1'b0;
		#60 resetN = 1'b0;
		#30 resetN = 1'b1;
		#50 PushButton = 1'b1;
		#100 PushButton = 1'b0;
		#50 PushButton = 1'b1;
		#3  PushButton = 1'b0;
		#20 PushButton = 1'b1;
		#80 PushButton = 1'b0;
	end

endmodule