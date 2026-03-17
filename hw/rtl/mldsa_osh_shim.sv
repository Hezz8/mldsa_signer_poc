`timescale 1ns / 1ps

module mldsa_osh_shim #(
  parameter string KEY_MEM_FILE = "hw/include/mldsa_osh_poc_sk_87.mem"
) (
  input  logic                                 clk,
  input  logic                                 rst,
  input  logic                                 start,
  input  logic [wrapper_pkg::DIGEST_BITS-1:0]  digest,
  output logic                                 busy,
  output logic                                 done,
  output logic                                 error,
  output logic [31:0]                          signature_length,
  output logic [wrapper_pkg::MAX_SIGNATURE_BITS-1:0] signature_buffer
);
  import wrapper_pkg::*;

  localparam int unsigned SEND_MLEN_WORDS = 1;
  localparam int unsigned FAILURE_DELAY_CYCLES = 1;

  logic [7:0] sk_bytes [0:MLDSA_OSH_SK_BYTES-1];
  logic [7:0] signature_bytes [0:MAX_SIGNATURE_BYTES-1];
  logic [15:0] word_index;
  logic [3:0] reset_countdown;
  integer byte_index;

  typedef enum logic [4:0] {
    STATE_IDLE,
    STATE_CORE_RESET,
    STATE_CORE_START,
    STATE_SEND_RHO,
    STATE_SEND_MLEN,
    STATE_SEND_TR,
    STATE_SEND_MESSAGE,
    STATE_SEND_K,
    STATE_SEND_RND,
    STATE_SEND_S1,
    STATE_SEND_S2,
    STATE_SEND_T0,
    STATE_RECV_Z,
    STATE_RECV_H,
    STATE_RECV_C,
    STATE_COMPLETE,
    STATE_FAILURE
  } shim_state_t;

  shim_state_t state;

`ifdef MLDSA_OSH_ENABLE_REAL_CORE
  logic [1:0] core_mode;
  logic [2:0] core_sec_lvl;
  logic       core_rst;
  logic       core_start;
  logic       core_valid_i;
  logic       core_ready_i;
  logic [63:0] core_data_i;
  logic       core_valid_o;
  logic       core_ready_o;
  logic [63:0] core_data_o;

  assign core_mode = MLDSA_OSH_MODE_SIGN[1:0];
  assign core_sec_lvl = MLDSA_OSH_SECURITY_LEVEL[2:0];

  combined_top core_sign_top (
    .clk(clk),
    .rst(core_rst),
    .start(core_start),
    .mode(core_mode),
    .sec_lvl(core_sec_lvl),
    .valid_i(core_valid_i),
    .ready_i(core_ready_i),
    .data_i(core_data_i),
    .valid_o(core_valid_o),
    .ready_o(core_ready_o),
    .data_o(core_data_o)
  );
`endif

  genvar sig_gen;
  generate
    for (sig_gen = 0; sig_gen < MAX_SIGNATURE_BYTES; sig_gen = sig_gen + 1) begin : gen_signature_buffer
      assign signature_buffer[(sig_gen * 8) +: 8] = signature_bytes[sig_gen];
    end
  endgenerate

  function automatic logic [7:0] digest_byte(input int unsigned index);
    digest_byte = digest[(index * 8) +: 8];
  endfunction

  function automatic logic [63:0] pack_sk_word(input int unsigned base_byte);
    logic [63:0] word_value;
    int unsigned lane;
    begin
      word_value = 64'h0;
      for (lane = 0; lane < 8; lane = lane + 1) begin
        if (base_byte + lane < MLDSA_OSH_SK_BYTES) begin
          word_value[(lane * 8) +: 8] = sk_bytes[base_byte + lane];
        end
      end
      pack_sk_word = word_value;
    end
  endfunction

  function automatic logic [63:0] pack_message_word(input int unsigned word_number);
    logic [63:0] word_value;
    int unsigned lane;
    int unsigned message_index;
    begin
      word_value = 64'h0;
      for (lane = 0; lane < 8; lane = lane + 1) begin
        message_index = (word_number * 8) + lane;
        if (message_index == 0) begin
          word_value[(lane * 8) +: 8] = 8'h00;
        end else if (message_index == 1) begin
          word_value[(lane * 8) +: 8] = 8'h00;
        end else if (message_index < MLDSA_OSH_FORMATTED_MESSAGE_BYTES) begin
          word_value[(lane * 8) +: 8] = digest_byte(message_index - 2);
        end
      end
      pack_message_word = word_value;
    end
  endfunction

  task automatic clear_signature_storage;
    begin
      for (byte_index = 0; byte_index < MAX_SIGNATURE_BYTES; byte_index = byte_index + 1) begin
        signature_bytes[byte_index] <= 8'h00;
      end
    end
  endtask

  task automatic store_output_word(
    input int unsigned base_byte,
    input logic [63:0] data_word
  );
    int unsigned lane;
    begin
      for (lane = 0; lane < 8; lane = lane + 1) begin
        if (base_byte + lane < MAX_SIGNATURE_BYTES) begin
          signature_bytes[base_byte + lane] <= data_word[(lane * 8) +: 8];
        end
      end
    end
  endtask

  initial begin
    $readmemh(KEY_MEM_FILE, sk_bytes);
  end

  always_ff @(posedge clk) begin
    if (rst) begin
      busy <= 1'b0;
      done <= 1'b0;
      error <= 1'b0;
      signature_length <= 32'h0;
      word_index <= '0;
      reset_countdown <= '0;
      state <= STATE_IDLE;
`ifdef MLDSA_OSH_ENABLE_REAL_CORE
      core_rst <= 1'b1;
      core_start <= 1'b0;
      core_valid_i <= 1'b0;
      core_data_i <= 64'h0;
      core_ready_o <= 1'b0;
`endif
      for (byte_index = 0; byte_index < MAX_SIGNATURE_BYTES; byte_index = byte_index + 1) begin
        signature_bytes[byte_index] <= 8'h00;
      end
    end else begin
      done <= 1'b0;
      error <= 1'b0;
`ifdef MLDSA_OSH_ENABLE_REAL_CORE
      core_rst <= 1'b0;
      core_start <= 1'b0;
      core_valid_i <= 1'b0;
      core_data_i <= 64'h0;
      core_ready_o <= 1'b0;
`endif

      case (state)
        STATE_IDLE: begin
          if (start) begin
            busy <= 1'b1;
            signature_length <= 32'h0;
            word_index <= '0;
            clear_signature_storage();
`ifdef MLDSA_OSH_ENABLE_REAL_CORE
            reset_countdown <= MLDSA_OSH_RESET_CYCLES;
            state <= STATE_CORE_RESET;
`else
            reset_countdown <= FAILURE_DELAY_CYCLES;
            state <= STATE_FAILURE;
`endif
          end
        end

`ifdef MLDSA_OSH_ENABLE_REAL_CORE
        STATE_CORE_RESET: begin
          core_rst <= 1'b1;
          if (reset_countdown == 0) begin
            state <= STATE_CORE_START;
          end else begin
            reset_countdown <= reset_countdown - 1'b1;
          end
        end

        STATE_CORE_START: begin
          core_start <= 1'b1;
          word_index <= '0;
          state <= STATE_SEND_RHO;
        end

        STATE_SEND_RHO: begin
          core_valid_i <= 1'b1;
          core_data_i <= pack_sk_word(MLDSA_OSH_SK_RHO_OFFSET + (word_index * 8));
          if (core_ready_i) begin
            if (word_index == MLDSA_OSH_RHO_WORDS - 1) begin
              word_index <= '0;
              state <= STATE_SEND_MLEN;
            end else begin
              word_index <= word_index + 1'b1;
            end
          end
        end

        STATE_SEND_MLEN: begin
          core_valid_i <= 1'b1;
          core_data_i <= {32'h0, 32'(MLDSA_OSH_MESSAGE_BYTES)};
          if (core_ready_i) begin
            word_index <= '0;
            state <= STATE_SEND_TR;
          end
        end

        STATE_SEND_TR: begin
          core_valid_i <= 1'b1;
          core_data_i <= pack_sk_word(MLDSA_OSH_SK_TR_OFFSET + (word_index * 8));
          if (core_ready_i) begin
            if (word_index == MLDSA_OSH_TR_WORDS - 1) begin
              word_index <= '0;
              state <= STATE_SEND_MESSAGE;
            end else begin
              word_index <= word_index + 1'b1;
            end
          end
        end

        STATE_SEND_MESSAGE: begin
          core_valid_i <= 1'b1;
          core_data_i <= pack_message_word(word_index);
          if (core_ready_i) begin
            if (word_index == MLDSA_OSH_FORMATTED_MESSAGE_WORDS - 1) begin
              word_index <= '0;
              state <= STATE_SEND_K;
            end else begin
              word_index <= word_index + 1'b1;
            end
          end
        end

        STATE_SEND_K: begin
          core_valid_i <= 1'b1;
          core_data_i <= pack_sk_word(MLDSA_OSH_SK_K_OFFSET + (word_index * 8));
          if (core_ready_i) begin
            if (word_index == MLDSA_OSH_K_WORDS - 1) begin
              word_index <= '0;
              state <= STATE_SEND_RND;
            end else begin
              word_index <= word_index + 1'b1;
            end
          end
        end

        STATE_SEND_RND: begin
          core_valid_i <= 1'b1;
          core_data_i <= 64'h0;
          if (core_ready_i) begin
            if (word_index == MLDSA_OSH_RND_WORDS - 1) begin
              word_index <= '0;
              state <= STATE_SEND_S1;
            end else begin
              word_index <= word_index + 1'b1;
            end
          end
        end

        STATE_SEND_S1: begin
          core_valid_i <= 1'b1;
          core_data_i <= pack_sk_word(MLDSA_OSH_SK_S1_OFFSET + (word_index * 8));
          if (core_ready_i) begin
            if (word_index == MLDSA_OSH_S1_WORDS - 1) begin
              word_index <= '0;
              state <= STATE_SEND_S2;
            end else begin
              word_index <= word_index + 1'b1;
            end
          end
        end

        STATE_SEND_S2: begin
          core_valid_i <= 1'b1;
          core_data_i <= pack_sk_word(MLDSA_OSH_SK_S2_OFFSET + (word_index * 8));
          if (core_ready_i) begin
            if (word_index == MLDSA_OSH_S2_WORDS - 1) begin
              word_index <= '0;
              state <= STATE_SEND_T0;
            end else begin
              word_index <= word_index + 1'b1;
            end
          end
        end

        STATE_SEND_T0: begin
          core_valid_i <= 1'b1;
          core_data_i <= pack_sk_word(MLDSA_OSH_SK_T0_OFFSET + (word_index * 8));
          if (core_ready_i) begin
            if (word_index == MLDSA_OSH_T0_WORDS - 1) begin
              word_index <= '0;
              state <= STATE_RECV_Z;
            end else begin
              word_index <= word_index + 1'b1;
            end
          end
        end

        STATE_RECV_Z: begin
          core_ready_o <= 1'b1;
          if (core_valid_o) begin
            store_output_word(MLDSA_OSH_SIGNATURE_Z_OFFSET + (word_index * 8), core_data_o);
            if (word_index == MLDSA_OSH_Z_WORDS - 1) begin
              word_index <= '0;
              state <= STATE_RECV_H;
            end else begin
              word_index <= word_index + 1'b1;
            end
          end
        end

        STATE_RECV_H: begin
          core_ready_o <= 1'b1;
          if (core_valid_o) begin
            store_output_word(MLDSA_OSH_SIGNATURE_H_OFFSET + (word_index * 8), core_data_o);
            if (word_index == MLDSA_OSH_H_WORDS - 1) begin
              word_index <= '0;
              state <= STATE_RECV_C;
            end else begin
              word_index <= word_index + 1'b1;
            end
          end
        end

        STATE_RECV_C: begin
          core_ready_o <= 1'b1;
          if (core_valid_o) begin
            store_output_word(MLDSA_OSH_SIGNATURE_C_OFFSET + (word_index * 8), core_data_o);
            if (word_index == MLDSA_OSH_CTILDE_WORDS - 1) begin
              word_index <= '0;
              state <= STATE_COMPLETE;
            end else begin
              word_index <= word_index + 1'b1;
            end
          end
        end
`endif

        STATE_COMPLETE: begin
          busy <= 1'b0;
          done <= 1'b1;
          signature_length <= MLDSA_OSH_SIG_BYTES;
          state <= STATE_IDLE;
        end

        STATE_FAILURE: begin
          if (reset_countdown == 0) begin
            busy <= 1'b0;
            error <= 1'b1;
            signature_length <= 32'h0;
            state <= STATE_IDLE;
          end else begin
            reset_countdown <= reset_countdown - 1'b1;
          end
        end

        default: begin
          busy <= 1'b0;
          error <= 1'b1;
          signature_length <= 32'h0;
          state <= STATE_IDLE;
        end
      endcase
    end
  end
endmodule