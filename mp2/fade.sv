// Single light fader with FSM

module fade #(
    parameter STEP_INTERVAL = 12000,  // 1ms
    parameter STEP_MAX = 166,  // 200 * INC_DEC_INTERVAL = 166 ms
    parameter HOLD_MAX = STEP_MAX * 2,  // 332 ms
    parameter PWM_INTERVAL = 1200,  // 100us
    parameter STEP_SIZE = PWM_INTERVAL / STEP_MAX,
    parameter INITIAL_STATE = 0,
    parameter INITIAL_STEP_COUNT = 0,
    parameter INITIAL_DUTY_CYCLE = 0
) (
    input logic clk,
    output logic [$clog2(PWM_INTERVAL) - 1:0] duty_cycle
);

  // FSM states
  localparam PWM_INC = 2'b00;
  localparam PWM_HOLD = 2'b01;
  localparam PWM_DEC = 2'b10;
  localparam PWM_HOLD2 = 2'b11;

  // FSM state register
  logic [1:0] current_state = INITIAL_STATE;
  logic [1:0] next_state;

  // Timing vars
  logic [$clog2(STEP_INTERVAL) - 1:0] count = 0;
  logic [$clog2(HOLD_MAX) - 1:0] step_count = INITIAL_STEP_COUNT * STEP_MAX;
  logic time_to_step = 1'b0;

  initial begin
    duty_cycle = INITIAL_DUTY_CYCLE * (STEP_MAX + 1) * STEP_SIZE;
  end

  // Calculate next state
  always_comb begin
    next_state = 1'bx;
    case (current_state)
      PWM_INC:   next_state = PWM_HOLD;
      PWM_HOLD:  next_state = PWM_DEC;
      PWM_DEC:   next_state = PWM_HOLD2;
      PWM_HOLD2: next_state = PWM_INC;
    endcase
  end

  // Track clock cycles until next step
  always_ff @(posedge clk) begin
    if (count == STEP_INTERVAL) begin
      count <= 0;
      time_to_step <= 1'b1;
    end else begin
      count <= count + 1;
      time_to_step <= 1'b0;
    end
  end

  // Take the next step
  always_ff @(posedge time_to_step) begin
    case (current_state)
      PWM_INC: duty_cycle <= duty_cycle + STEP_SIZE;
      PWM_DEC: duty_cycle <= duty_cycle - STEP_SIZE;
    endcase
  end

  // Check if it's time for a state transition
  always_ff @(posedge time_to_step) begin
    if (step_count == HOLD_MAX || (step_count == STEP_MAX && current_state[0] == 1'b0)) begin
      step_count <= 0;
      current_state <= next_state;
    end else begin
      step_count <= step_count + 1;
    end
  end
endmodule

