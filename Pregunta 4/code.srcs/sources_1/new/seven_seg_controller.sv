module seven_seg_controller
(
  input   logic         clk,
  input   logic         resetN,
  input   logic [31:0]  val_in,
  output  logic [6:0]   cat_out,
  output  logic [7:0]   an_out
);
  
  logic [7:0]   segment_state;
  logic [31:0]  segment_counter;
  logic [3:0]   routed_vals;
  logic [6:0]   led_out;
  
  assign cat_out = ~led_out;
  assign an_out = ~segment_state;
  
  always_comb begin
    case(segment_state)
      8'b0000_0001: routed_vals = val_in[3:0];
      8'b0000_0010: routed_vals = val_in[7:4];
      8'b0000_0100: routed_vals = val_in[11:8];
      8'b0000_1000: routed_vals = val_in[15:12];
      8'b0001_0000: routed_vals = val_in[19:16];
      8'b0010_0000: routed_vals = val_in[23:20];
      8'b0100_0000: routed_vals = val_in[27:24];
      8'b1000_0000: routed_vals = val_in[31:28];
      default:      routed_vals = val_in[3:0];       
    endcase
  end

  binary_to_seven_seg my_converter (.val_in(routed_vals), .led_out(led_out));
  
  always_ff @(posedge clk)begin
    if (~resetN) begin
      segment_state <= 8'b0000_0001;
      segment_counter <= 32'b0;
    end 
    else begin
      if (segment_counter == 32'd100_000) begin
        segment_counter <= 32'd0;
        segment_state <= {segment_state[6:0], segment_state[7]};
      end 
      else begin
        segment_counter <= segment_counter + 1;
      end
    end
  end
      
endmodule //seven_seg_controller

module binary_to_seven_seg
(
  input   logic [3:0] val_in,
  output  logic [6:0] led_out
);

  always_comb begin
    case (val_in)
      4'd0: led_out = 7'b1000000;
      4'd1: led_out = 7'b1111001;
      4'd2: led_out = 7'b0100100;
      4'd3: led_out = 7'b0110000;
      4'd4: led_out = 7'b0011001;
      4'd5: led_out = 7'b0010010;
      4'd6: led_out = 7'b0000010;
      4'd7: led_out = 7'b1111000;
      4'd8: led_out = 7'b0000000;
      4'd9: led_out = 7'b0010000;
      'hA:  led_out = 7'b0001000; // A
      'hB:  led_out = 7'b0001100; // P
      'hC:  led_out = 7'b1111111;

      default: led_out = 7'b0000000; // U
    endcase    
  end

endmodule