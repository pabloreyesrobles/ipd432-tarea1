module second_gen
(
  input   logic clk,
  input   logic clk_1hz,
  input   logic resetN,
  output  logic [7:0] seconds,
  output  logic oversec
);

always_ff @(posedge clk) begin
  oversec <= 0;
  
  if (~resetN) seconds <= 0;
  else begin
    if (clk_1hz) begin
      if (seconds < 59) seconds <= seconds + 1;
      else begin
        seconds <= 0;
        oversec <= 1;
      end  
    end    
  end
end

endmodule