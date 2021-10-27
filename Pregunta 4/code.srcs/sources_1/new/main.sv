module main 
#(parameter
  CLK_FREQUENCY = 'd100_000_000
)
(
  input   logic clk,
  input   logic resetN,
  input   logic BTNR,
  input   logic BTNL,
  input   logic SW0,
  input   logic SW1,
  input   logic SW2,
  output  logic LED,
  output  logic [6:0] CAT,
  output  logic [7:0] AN
);

  logic clk_1hz;

  logic [7:0] seconds;
  logic [7:0] minutes;
  logic [7:0] hours;

  logic [7:0] seconds_bcd;
  logic [7:0] minutes_bcd;
  logic [7:0] hours_bcd;
  
  logic [31:0] seg_data;

  // Alarm variables
  logic alarm_status; // Initially off
  logic alarm_ring;
  logic [3:0] alarm_period;

  logic [7:0] alarm_minutes;
  logic [7:0] alarm_hours;

  // Printable variables. Multiplexes for printing
  logic [7:0] p_seconds;
  logic [7:0] p_minutes;
  logic [7:0] p_hours;

  logic [3:0] day_period;

  logic oversec;
  logic overmin;

  logic min_flag;
  logic hour_flag;

  logic alarm_min_flag;
  logic alarm_hour_flag;

  logic min_pulse_out;
  logic btnr_status;
  logic hour_pulse_out;
  logic btnl_status;
  
  always_comb begin
    min_flag = oversec;
    hour_flag = overmin;

    alarm_min_flag = 0;
    alarm_hour_flag = 0;

    day_period = 4'hC;
    LED = 0;

    if (SW1) begin
      alarm_status = 0;

      p_seconds = 8'd0;
      p_minutes = alarm_minutes;
      p_hours = alarm_hours;

      alarm_min_flag = min_pulse_out;
      alarm_hour_flag = hour_pulse_out;
    end
    else begin
      alarm_status = SW2;

      p_seconds = seconds;
      p_minutes = minutes;
      p_hours = hours;

      // Minutes and hours increase selector: 
      // - if button pressed, minutes increase with T1 pulse generator
      // - else increase with the 1hz clock
      if (btnr_status) begin 
        min_flag = min_pulse_out;
        hour_flag = 0;
      end
      if (btnl_status) hour_flag = hour_pulse_out;
    end
    
    if (SW0) begin
      day_period = 4'hA;
      if (p_hours >= 12) begin
        p_hours = p_hours - 12;
        day_period = 4'hB;
        LED = 1;
      end        
    end
  end
  
  assign alarm_ring = (minutes == alarm_minutes) && (hours == alarm_hours);

  always_ff @(posedge clk) begin
    if (oversec) alarm_period = 4'd5;

    if (alarm_status && alarm_ring && (alarm_period > 0)) begin
      seg_data[31:24] = 'hD;
      seg_data[23:16] = 4'd0;
      seg_data[15:8] = 'hE;
      seg_data[7:4] = 'hF;
      seg_data[3:0] = 'hC;

      if (clk_1hz) alarm_period = (alarm_period > 0) ? alarm_period - 1 : 0;
    end
    else begin
      seg_data[31:24] = hours_bcd;
      seg_data[23:16] = minutes_bcd;
      seg_data[15:8] = seconds_bcd;
      seg_data[7:4] = 'hC;
      seg_data[3:0] = day_period;
    end
  end

  osc_1hz #(CLK_FREQUENCY) osc_1hz (
    .clk,
    .resetN,
    .clk_1hz
  );

  second_gen second_gen (
    .clk,
    .clk_1hz,
    .resetN,
    .seconds,
    .oversec
  );

  minute_gen minute_gen (
    .clk,
    .min_flag,
    .resetN,
    .minutes,
    .overmin
  );

  hour_gen hour_gen (
    .clk,
    .hour_flag,
    .resetN,
    .hours
  );

  minute_gen alarm_minute_gen (
    .clk,
    .min_flag(alarm_min_flag),
    .resetN,
    .minutes(alarm_minutes),
    .overmin(x)
  );

  hour_gen alarm_hour_gen (
    .clk,
    .hour_flag(alarm_hour_flag),
    .resetN,
    .hours(alarm_hours)
  );

  T1_design1 #(10, CLK_FREQUENCY >> 1) btnr_pulse (
    .clk,
    .resetN,
    .PushButton(BTNR),
    .IncPulse_out(min_pulse_out),
    .pb_status(btnr_status)
  );

  T1_design1 #(10, CLK_FREQUENCY >> 1) btnl_pulse (
    .clk,
    .resetN,
    .PushButton(BTNL),
    .IncPulse_out(hour_pulse_out),
    .pb_status(btnl_status)
  );

  bcd sec_to_bcd (
    .data(p_seconds),
    .out(seconds_bcd)
  );

  bcd min_to_bcd (
    .data(p_minutes),
    .out(minutes_bcd)
  );

  bcd hour_to_bcd (
    .data(p_hours),
    .out(hours_bcd)
  );

  seven_seg_controller data_to_lcd (
    .clk,
    .resetN,
    .data(seg_data),
    .cat_out(CAT),
    .an_out(AN)
  );
  
  always_ff @(posedge clk) begin
    if (~resetN) begin
      alarm_period = 4'd5;
    end
  end

endmodule