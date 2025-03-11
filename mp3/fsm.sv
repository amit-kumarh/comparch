// FSM for the 4 sine wave states
`include "memory.sv"

module fsm #(
    parameter MEM_SIZE  = 128,
    parameter SINE_PATH = ""
) (
    input logic clk,
    output logic [9:0] out
);

  typedef enum logic [1:0] {
    SINE_1,
    SINE_2,
    SINE_3,
    SINE_4
  } state_t;

  logic [1:0] current_state;
  logic [1:0] next_state;
  logic [6:0] addr;
  logic [9:0] mem_out;
  logic [6:0] counter;
  logic time_to_change;

  initial begin
    current_state = SINE_1;
    addr = 0;
    counter = 0;
    time_to_change = 0;
  end

  memory #(
      .INIT_FILE(SINE_PATH)
  ) mem (
      .clk (clk),
      .addr(addr),
      .data(mem_out)
  );

  always_ff @(posedge clk) begin
    // advance the memory address
    case (current_state)
      SINE_1: begin
        out  <= mem_out;
        addr <= addr + 1;
      end
      SINE_2: begin
        out  <= mem_out;
        addr <= addr - 1;
      end
      SINE_3: begin
        out  <= 1024 - mem_out;
        addr <= addr + 1;
      end
      SINE_4: begin
        out  <= 1024 - mem_out;
        addr <= addr - 1;
      end
      default: begin
        out  <= 0;
        addr <= 0;
      end
    endcase

    counter <= counter + 1;
    if (counter == MEM_SIZE - 2) begin
      time_to_change <= 1;
    end
  end

  always_ff @(posedge clk) begin
    if (time_to_change == 1) begin
      case (current_state)
        SINE_1: begin
          current_state <= 2'b01;
          addr <= MEM_SIZE - 1;
          time_to_change <= 0;
        end
        SINE_2: begin
          current_state <= 2'b10;
          addr <= 0;
          time_to_change <= 0;
        end
        SINE_3: begin
          current_state <= 2'b11;
          addr <= MEM_SIZE - 1;
          time_to_change <= 0;
        end
        default: begin
          current_state <= 2'b00;
          addr <= 0;
          time_to_change <= 0;
        end
      endcase

      time_to_change <= 0;
    end
  end
endmodule
