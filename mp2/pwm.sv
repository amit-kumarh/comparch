// PWM Generator

module pwm #(
    parameter PWM_INTERVAL = 1200  // CLK = 12MHz, 1200 cycles = 100us
) (
    input logic clk,
    input logic [$clog2(PWM_INTERVAL)-1:0] duty_cycle,
    output logic pwm_out
);

  logic [$clog2(PWM_INTERVAL)-1:0] counter = 0;

  always_ff @(posedge clk) begin
    if (counter == PWM_INTERVAL - 1) begin
      counter <= 0;
    end else begin
      counter <= counter + 1;
    end
  end

  assign pwm_out = counter < duty_cycle;

endmodule
