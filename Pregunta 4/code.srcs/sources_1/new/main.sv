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
  output  logic LED
  output  logic [6:0] cat_out,
  output  logic [7:0] an_out
);

  logic clk_1hz;

  logic [7:0] seconds;
  logic [7:0] minutes;
  logic [7:0] hours;
  logic [7:0] seconds_bcd;
  logic [7:0] minutes_bcd;
  logic [7:0] hours_bcd;

  logic oversec;
  logic overmin;

  logic min_flag;
  logic hour_flag;

  logic min_pulse_out;
  logic btnr_status;
  logic hour_pulse_out;
  logic btnl_status;

  logic [7:0] f_hours;
  logic [3:0] day_period;

  // Hour formatter
  always_comb begin
    day_period = 4'hC;
    f_hours = hours;
    if (SW) begin
      day_period = (hours < 12) ? 4'hA : 4'hB;
      f_hours = (hours < 12) ? hours : hours - 12;
    end
  end

  // Minutes and hours increase selector: 
  // - if button pressed, minutes increase with T1 pulse generator
  // - else increase with the 1hz clock
  assign min_flag = btnr_status ? min_pulse_out : oversec;
  assign hour_flag = btnl_status ? hour_pulse_out : overmin;

  osc_1hz osc_1hz (
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
    .data(seconds),
    .out(seconds_bcd)
  );

  bcd min_to_bcd (
    .data(minutes),
    .out(minutes_bcd)
  );

  bcd hour_to_bcd (
    .data(hours),
    .out(hours_bcd)
  );

  seven_seg_controller data_to_lcd (
    .clk,
    .resetN,
    .val_in({hours_bcd, minutes_bcd, seconds_bcd, 'hC, day_period}),
    .cat_out,
    .an_out
  );

endmodule