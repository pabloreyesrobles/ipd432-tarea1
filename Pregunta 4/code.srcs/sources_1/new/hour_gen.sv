module hour_gen
(
  input   logic clk,
  input   logic hour_flag,
  input   logic resetN,
  output  logic [7:0] hours
);

always_ff @(posedge clk) begin
  if (~resetN) hours <= 0;
  else begin
    if (hour_flag) begin
      if (hours < 23) hours <= hours + 1;
      else begin
        hours <= 0;
      end
    end
  end
end

endmodule