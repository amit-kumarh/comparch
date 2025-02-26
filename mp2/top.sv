`include "light.sv"

module top #(
    parameter PWM_INTERVAL = 1200  // 1ms
) (
    input  logic clk,
    output logic RGB_R,
    output logic RGB_G,
    output logic RGB_B
);
  logic red, green, blue;

  light #(
      .PWM_INTERVAL(PWM_INTERVAL),
      .INITIAL_STATE(2'b01),  // HOLD1
      .INITIAL_STEP_COUNT(0.5),  // Start midway through cycle
      .INITIAL_DUTY_CYCLE(1)  // all 1s
  ) red_light (
      .clk(clk),
      .LED(red)
  );

  light #(PWM_INTERVAL) green_light (
      .clk(clk),
      .LED(green)
  );

  light #(
      .PWM_INTERVAL(PWM_INTERVAL),
      .INITIAL_STATE(2'b11)  // HOLD2
  ) blue_light (
      .clk(clk),
      .LED(blue)
  );

  assign RGB_R = ~red;
  assign RGB_G = ~green;
  assign RGB_B = ~blue;
endmodule
