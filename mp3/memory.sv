// Memory module

module memory #(
    parameter INIT_FILE = ""
) (
    input logic clk,
    input logic [6:0] addr,
    output logic [8:0] data
);
  logic [8:0] mem[128];

  initial begin
    if (INIT_FILE != "") begin
      $readmemh(INIT_FILE, mem);
    end
  end

  assign data = mem[addr];

endmodule
