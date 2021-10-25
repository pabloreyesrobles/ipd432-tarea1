module minute_gen
(
  input   logic clk,
  input   logic min_flag,
  input   logic resetN,
  output  logic [7:0] minutes,
  output  logic overmin
);

always_ff @(posedge clk) begin
  overmin <= 0;

  if (~resetN) minutes <= 0;
  else begin
    if (min_flag) begin
      if (minutes < 59) minutes <= minutes + 1;
      else begin
        minutes <= 0;
        overmin <= 1;
      end
    end
  end
end

endmodule