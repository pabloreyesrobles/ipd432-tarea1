`timescale 1us / 1us

module alarm_testbench ();
  logic clk, resetN, BTNR, BTNL, SW0, SW1, SW2, LED0, LED1;
  logic [6:0] CAT;
  logic [7:0] AN;
  
  localparam CLK_TEST = 'd1_000;

  main #(CLK_TEST) alarm (
    .clk,
    .resetN,
    .BTNR,
    .BTNL,
    .SW0,
    .SW1,
    .SW2,
    .LED0,
    .LED1,
    .CAT,
    .AN
  );

  // generate a clock signal that inverts its value every five time units
	always  #1 clk=~clk;

  initial begin
    clk = 1'b0;
    resetN = 1'b1;
    BTNL = 1'b0;
    BTNR = 1'b0;
    SW0 = 1'b1;
    SW1 = 1'b0;
    SW2 = 1'b0;
    
    #60 resetN = 1'b0;
    #40 resetN = 1'b1;
    #50 BTNL = 1'b1;
  end

endmodule