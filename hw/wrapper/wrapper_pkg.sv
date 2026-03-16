package wrapper_pkg;
  localparam int unsigned CONTROL_ADDR = 'h000;
  localparam int unsigned STATUS_ADDR = 'h004;
  localparam int unsigned ERROR_CODE_ADDR = 'h008;
  localparam int unsigned SIG_LENGTH_ADDR = 'h00C;
  localparam int unsigned DIGEST_BASE_ADDR = 'h010;
  localparam int unsigned SIG_DATA_BASE_ADDR = 'h100;

  localparam int unsigned DIGEST_WORDS = 16;
  localparam int unsigned DIGEST_BYTES = 64;
  localparam int unsigned SIG_WORDS = 32;
  localparam int unsigned SIG_BYTES = 128;
  localparam int unsigned STUB_DELAY_CYCLES = 2;

  localparam logic [31:0] CONTROL_START_MASK = 32'h0000_0001;
  localparam logic [31:0] CONTROL_CLEAR_STATUS_MASK = 32'h0000_0002;

  localparam logic [31:0] STATUS_IDLE_MASK = 32'h0000_0001;
  localparam logic [31:0] STATUS_BUSY_MASK = 32'h0000_0002;
  localparam logic [31:0] STATUS_DONE_MASK = 32'h0000_0004;
  localparam logic [31:0] STATUS_ERROR_MASK = 32'h0000_0008;

  localparam logic [31:0] ERROR_NONE = 32'h0000_0000;
  localparam logic [31:0] ERROR_START_WHILE_BUSY = 32'h0000_0001;
  localparam logic [31:0] ERROR_INVALID_OFFSET = 32'h0000_0002;

  function automatic logic [31:0] status_word(
    input logic busy,
    input logic done,
    input logic error
  );
    status_word = 32'h0;
    if (!busy) begin
      status_word |= STATUS_IDLE_MASK;
    end
    if (busy) begin
      status_word |= STATUS_BUSY_MASK;
    end
    if (done) begin
      status_word |= STATUS_DONE_MASK;
    end
    if (error) begin
      status_word |= STATUS_ERROR_MASK;
    end
  endfunction
endpackage
