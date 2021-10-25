module bcd
(
  input   logic [7:0] data,
  output  logic [7:0] out,
);

  integer i;
  logic [4:0] tens, ones;

  always_comb begin
    tens = 4'd0
    ones = 4'd0

    for (i = 7; i >= 0; i = i - 1) begin
      if (tens >= 5) tens = tens + 3
      if (ones >= 5) ones = ones + 3
      
      tens = tens << 1;
      tens[0] = ones[3];

      ones = ones << 1;
      ones[0] = data[i];
    end

    out[7:4] = tens
    out[3:0] = ones
  end

endmodule