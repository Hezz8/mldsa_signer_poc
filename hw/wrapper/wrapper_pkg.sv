package wrapper_pkg;
  localparam int unsigned CONTROL_ADDR = 'h000;
  localparam int unsigned STATUS_ADDR = 'h004;
  localparam int unsigned ERROR_CODE_ADDR = 'h008;
  localparam int unsigned SIG_LENGTH_ADDR = 'h00C;
  localparam int unsigned DIGEST_BASE_ADDR = 'h010;
  localparam int unsigned SIG_DATA_BASE_ADDR = 'h100;

  localparam int unsigned DIGEST_WORDS = 16;
  localparam int unsigned DIGEST_BYTES = 64;
  localparam int unsigned DIGEST_BITS = DIGEST_BYTES * 8;

  localparam int unsigned STUB_SIG_BYTES = 128;
  localparam int unsigned CORE_PLACEHOLDER_SIG_BYTES = 128;
  localparam int unsigned SIG_BYTES = STUB_SIG_BYTES;
  localparam int unsigned SIG_WORDS = SIG_BYTES / 4;

  localparam int unsigned MLDSA_OSH_SIG_BYTES = 4627;
  localparam int unsigned MLDSA_OSH_SIG_WORDS = (MLDSA_OSH_SIG_BYTES + 3) / 4;
  localparam int unsigned MAX_SIGNATURE_BYTES = MLDSA_OSH_SIG_BYTES;
  localparam int unsigned MAX_SIGNATURE_BITS = MAX_SIGNATURE_BYTES * 8;
  localparam int unsigned SIG_WINDOW_WORDS = MLDSA_OSH_SIG_WORDS;
  localparam int unsigned SIG_WINDOW_BYTES = SIG_WINDOW_WORDS * 4;

  localparam int unsigned STUB_DELAY_CYCLES = 2;
  localparam int unsigned CORE_PLACEHOLDER_DELAY_CYCLES = 4;
  localparam int unsigned MLDSA_OSH_RESET_CYCLES = 2;

  localparam int unsigned ENGINE_MODE_STUB = 0;
  localparam int unsigned ENGINE_MODE_CORE_PLACEHOLDER = 1;
  localparam int unsigned ENGINE_MODE_MLDSA_OSH = 2;

  localparam logic [31:0] CONTROL_START_MASK = 32'h0000_0001;
  localparam logic [31:0] CONTROL_CLEAR_STATUS_MASK = 32'h0000_0002;

  localparam logic [31:0] STATUS_IDLE_MASK = 32'h0000_0001;
  localparam logic [31:0] STATUS_BUSY_MASK = 32'h0000_0002;
  localparam logic [31:0] STATUS_DONE_MASK = 32'h0000_0004;
  localparam logic [31:0] STATUS_ERROR_MASK = 32'h0000_0008;

  localparam logic [31:0] ERROR_NONE = 32'h0000_0000;
  localparam logic [31:0] ERROR_START_WHILE_BUSY = 32'h0000_0001;
  localparam logic [31:0] ERROR_INVALID_OFFSET = 32'h0000_0002;
  localparam logic [31:0] ERROR_ENGINE = 32'h0000_0003;

  localparam int unsigned MLDSA_OSH_MODE_SIGN = 2;
  localparam int unsigned MLDSA_OSH_SECURITY_LEVEL = 5;
  localparam int unsigned MLDSA_OSH_MESSAGE_BYTES = 64;
  localparam int unsigned MLDSA_OSH_FORMATTED_MESSAGE_BYTES = 66;
  localparam int unsigned MLDSA_OSH_FORMATTED_MESSAGE_WORDS = (MLDSA_OSH_FORMATTED_MESSAGE_BYTES + 7) / 8;
  localparam int unsigned MLDSA_OSH_RND_BYTES = 32;
  localparam int unsigned MLDSA_OSH_RND_WORDS = MLDSA_OSH_RND_BYTES / 8;

  localparam int unsigned MLDSA_OSH_SK_BYTES = 4896;
  localparam int unsigned MLDSA_OSH_SK_RHO_BYTES = 32;
  localparam int unsigned MLDSA_OSH_SK_K_BYTES = 32;
  localparam int unsigned MLDSA_OSH_SK_TR_BYTES = 64;
  localparam int unsigned MLDSA_OSH_SK_S1_BYTES = 672;
  localparam int unsigned MLDSA_OSH_SK_S2_BYTES = 768;
  localparam int unsigned MLDSA_OSH_SK_T0_BYTES = 3328;

  localparam int unsigned MLDSA_OSH_SK_RHO_OFFSET = 0;
  localparam int unsigned MLDSA_OSH_SK_K_OFFSET = MLDSA_OSH_SK_RHO_OFFSET + MLDSA_OSH_SK_RHO_BYTES;
  localparam int unsigned MLDSA_OSH_SK_TR_OFFSET = MLDSA_OSH_SK_K_OFFSET + MLDSA_OSH_SK_K_BYTES;
  localparam int unsigned MLDSA_OSH_SK_S1_OFFSET = MLDSA_OSH_SK_TR_OFFSET + MLDSA_OSH_SK_TR_BYTES;
  localparam int unsigned MLDSA_OSH_SK_S2_OFFSET = MLDSA_OSH_SK_S1_OFFSET + MLDSA_OSH_SK_S1_BYTES;
  localparam int unsigned MLDSA_OSH_SK_T0_OFFSET = MLDSA_OSH_SK_S2_OFFSET + MLDSA_OSH_SK_S2_BYTES;

  localparam int unsigned MLDSA_OSH_RHO_WORDS = MLDSA_OSH_SK_RHO_BYTES / 8;
  localparam int unsigned MLDSA_OSH_TR_WORDS = MLDSA_OSH_SK_TR_BYTES / 8;
  localparam int unsigned MLDSA_OSH_K_WORDS = MLDSA_OSH_SK_K_BYTES / 8;
  localparam int unsigned MLDSA_OSH_S1_WORDS = MLDSA_OSH_SK_S1_BYTES / 8;
  localparam int unsigned MLDSA_OSH_S2_WORDS = MLDSA_OSH_SK_S2_BYTES / 8;
  localparam int unsigned MLDSA_OSH_T0_WORDS = MLDSA_OSH_SK_T0_BYTES / 8;

  localparam int unsigned MLDSA_OSH_CTILDE_BYTES = 64;
  localparam int unsigned MLDSA_OSH_Z_BYTES = 4480;
  localparam int unsigned MLDSA_OSH_H_BYTES = 83;
  localparam int unsigned MLDSA_OSH_CTILDE_WORDS = (MLDSA_OSH_CTILDE_BYTES + 7) / 8;
  localparam int unsigned MLDSA_OSH_Z_WORDS = (MLDSA_OSH_Z_BYTES + 7) / 8;
  localparam int unsigned MLDSA_OSH_H_WORDS = (MLDSA_OSH_H_BYTES + 7) / 8;
  localparam int unsigned MLDSA_OSH_SIGNATURE_C_OFFSET = 0;
  localparam int unsigned MLDSA_OSH_SIGNATURE_Z_OFFSET = MLDSA_OSH_CTILDE_BYTES;
  localparam int unsigned MLDSA_OSH_SIGNATURE_H_OFFSET = MLDSA_OSH_CTILDE_BYTES + MLDSA_OSH_Z_BYTES;

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