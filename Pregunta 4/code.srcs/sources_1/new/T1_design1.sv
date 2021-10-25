// Module header:-----------------------------
module T1_design1
#(parameter
  N_DEBOUNCER_DELAY = 10,
  N_INCREMENT_DELAY_CONTINUOUS = 5
)
(
  input 	logic clk, 
  input   logic resetN,
  input 	logic PushButton,
  output 	logic IncPulse_out,
  output  logic pb_status
);

  // Declarations:------------------------------

  // FSM states type:
  typedef enum logic [3:0] {S0, S1, S2} state_type;
  state_type state, next_state;

  // Statements:--------------------------------
  localparam DELAY_WIDTH = $clog2(N_INCREMENT_DELAY_CONTINUOUS);
  logic [DELAY_WIDTH-1:0] increment_delay;

  // Commented in alarm mode
  // logic pb_status;
  // Check hoy to make it don't care when instantiate
  logic pb_press_pulse;
  logic pb_release_pulse;

  PB_Debouncer_FSM #(N_DEBOUNCER_DELAY) debouncer (
    .clk,
    .rst								(resetN),
    .PB									(PushButton),
    .PB_pressed_status	(pb_status),
    .PB_pressed_pulse		(pb_press_pulse),
    .PB_released_pulse	(pb_release_pulse)
  );

  // FSM state register:
  always_ff @(posedge clk) begin
    if (~resetN) increment_delay <= 0;
    else if (state != next_state) increment_delay <= 0;
    else increment_delay <= increment_delay + 1;
  end

  // FSM combinational logic:
  always_comb begin
    next_state = S0;
    IncPulse_out = 1'b0;

    case (state)
      S0: begin
        if (pb_status) next_state = S1;
      end

      S1: begin
        IncPulse_out = 1'b1;
        if (pb_status) next_state = S2;
        else next_state = S0;
      end

      S2: begin
        next_state = S2;
        if ((pb_status && (increment_delay >= N_INCREMENT_DELAY_CONTINUOUS - 1))) begin
          next_state = S1;
        end
        else if (~pb_status) next_state = S0;
      end
    endcase
  end

  // Optional output register (if required). It simply delays the combinational outputs to prevent propagation of glitches.
  always_ff @(posedge clk) begin
    if (~resetN) begin // resetN might be not needed here
      state <= S0;
    end
    else begin
      state <= next_state;
    end
  end
endmodule