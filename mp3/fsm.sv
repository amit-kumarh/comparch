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

  state_t current_state, next_state;
  logic [6:0] addr, next_addr;
  logic [6:0] counter;
  logic [8:0] mem_out;

  initial begin
    current_state = SINE_1;
    addr = 0;
    counter = 0;
  end

  memory #(
      .INIT_FILE(SINE_PATH)
  ) mem (
      .clk (clk),
      .addr(addr),
      .data(mem_out)
  );

  always_ff @(posedge clk) begin
    current_state <= next_state;
    addr <= next_addr;
    counter <= counter + 1;
  end

  always_comb begin
    next_state = current_state;
    next_addr  = addr;

    if (counter == MEM_SIZE - 1) begin
      case (current_state)
        SINE_1: begin
          next_state = SINE_2;
          next_addr  = MEM_SIZE - 1;
        end
        SINE_2: begin
          next_state = SINE_3;
          next_addr  = 0;
        end
        SINE_3: begin
          next_state = SINE_4;
          next_addr  = MEM_SIZE - 1;
        end
        SINE_4: begin
          next_state = SINE_1;
          next_addr  = 0;
        end
        default: begin
          next_state = SINE_1;
          next_addr  = 0;
        end
      endcase
    end else begin
      case (current_state)
        SINE_1, SINE_3: next_addr = addr + 1;
        SINE_2, SINE_4: next_addr = addr - 1;
        default: next_addr = 0;
      endcase
    end
  end

  always_comb begin
    case (current_state)
      SINE_1, SINE_2: out = mem_out + 512;
      SINE_3, SINE_4: out = 512 - mem_out;
      default: out = 0;
    endcase
  end

endmodule
