module osc_1hz
#(parameter
  CLK_FREQUENCY = 'd100_000_000
)
(
  input		logic clk,
  input   logic resetN,
  output	logic clk_1hz
);
  
  logic counter;

  always_ff @(clk) begin
    if (~resetN) counter <= 0;
    else if (counter < CLK_FREQUENCY - 1) counter <= counter + 1;
    else counter <= 0;
  end

  assign clk_1hz = (counter == CLK_FREQUENCY - 1) ? 1 : 0;

endmodule