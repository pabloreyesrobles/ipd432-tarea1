`timescale 1ns / 1ps

module alarm_testbench ();
  logic clk, resetN, BTNR, BTNL, SW0, SW1, LED;
  logic [6:0] cat_out;
  logic [7:0] an_out;

  main alarm (
    .clk,
    .resetN,
    .BTNR,
    .BTNL,
    .SW0,
    .SW1,
    .LED,
    .cat_out,
    .an_out
  );

  // generate a clock signal that inverts its value every five time units
	always  #1 clk=~clk;

  initial begin
    clk = 1'b0;
    resetN = 1'b1;
    BTNL = 1'b0;
    BTNR = 1'b0;
    SW0 = 1'b0;
    SW1 = 1'b0;
    
    #60 resetN = 1'b0;
    #30 resetN = 1'b1;
  end

endmodule