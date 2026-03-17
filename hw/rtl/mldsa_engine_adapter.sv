`timescale 1ns / 1ps

module mldsa_engine_adapter #(
  parameter int unsigned ENGINE_MODE = wrapper_pkg::ENGINE_MODE_STUB
) (
  input  logic                                clk,
  input  logic                                rst,
  input  logic                                start,
  input  logic [wrapper_pkg::DIGEST_BITS-1:0] digest,
  output logic                                busy,
  output logic                                done,
  output logic                                error,
  output logic [31:0]                         signature_length,
  output logic [wrapper_pkg::SIG_BITS-1:0]    signature_buffer
);
  import wrapper_pkg::*;

  logic [31:0] countdown_reg;
  logic [7:0] signature_bytes [0:SIG_BYTES-1];
  integer byte_index;

  genvar sig_gen;
  generate
    for (sig_gen = 0; sig_gen < SIG_BYTES; sig_gen = sig_gen + 1) begin : gen_signature_buffer
      assign signature_buffer[(sig_gen * 8) +: 8] = signature_bytes[sig_gen];
    end
  endgenerate

  function automatic int unsigned completion_cycles;
    begin
      if (ENGINE_MODE == ENGINE_MODE_STUB) begin
        completion_cycles = STUB_DELAY_CYCLES;
      end else begin
        completion_cycles = CORE_PLACEHOLDER_DELAY_CYCLES;
      end
    end
  endfunction

  function automatic logic [7:0] digest_byte(
    input logic [DIGEST_BITS-1:0] digest_value,
    input int unsigned index
  );
    digest_byte = digest_value[(index * 8) +: 8];
  endfunction

  function automatic logic [7:0] stub_prefix_byte(input int unsigned index);
    case (index)
      0: stub_prefix_byte = 8'h53;
      1: stub_prefix_byte = 8'h54;
      2: stub_prefix_byte = 8'h55;
      3: stub_prefix_byte = 8'h42;
      4: stub_prefix_byte = 8'h53;
      5: stub_prefix_byte = 8'h49;
      6: stub_prefix_byte = 8'h47;
      default: stub_prefix_byte = 8'h00;
    endcase
  endfunction

  function automatic logic [7:0] placeholder_prefix_byte(input int unsigned index);
    case (index)
      0: placeholder_prefix_byte = 8'h43;
      1: placeholder_prefix_byte = 8'h4F;
      2: placeholder_prefix_byte = 8'h52;
      3: placeholder_prefix_byte = 8'h45;
      4: placeholder_prefix_byte = 8'h50;
      5: placeholder_prefix_byte = 8'h48;
      default: placeholder_prefix_byte = 8'h00;
    endcase
  endfunction

  function automatic logic [7:0] signature_byte_for_mode(
    input int unsigned index,
    input logic [DIGEST_BITS-1:0] digest_value
  );
    begin
      signature_byte_for_mode = 8'h00;
      if (ENGINE_MODE == ENGINE_MODE_STUB) begin
        if (index < 7) begin
          signature_byte_for_mode = stub_prefix_byte(index);
        end else if (index < 7 + DIGEST_BYTES) begin
          signature_byte_for_mode = digest_byte(digest_value, index - 7);
        end
      end else begin
        if (index < 6) begin
          signature_byte_for_mode = placeholder_prefix_byte(index);
        end else if (index < 6 + DIGEST_BYTES) begin
          signature_byte_for_mode = digest_byte(digest_value, index - 6);
        end
      end
    end
  endfunction

  always_ff @(posedge clk) begin
    if (rst) begin
      busy <= 1'b0;
      done <= 1'b0;
      error <= 1'b0;
      signature_length <= 32'h0;
      countdown_reg <= 32'h0;
      for (byte_index = 0; byte_index < SIG_BYTES; byte_index = byte_index + 1) begin
        signature_bytes[byte_index] <= 8'h00;
      end
    end else begin
      done <= 1'b0;
      error <= 1'b0;

      if (start && !busy) begin
        busy <= 1'b1;
        countdown_reg <= completion_cycles();
        signature_length <= 32'h0;
        for (byte_index = 0; byte_index < SIG_BYTES; byte_index = byte_index + 1) begin
          signature_bytes[byte_index] <= 8'h00;
        end
      end

      if (busy && (countdown_reg != 0)) begin
        countdown_reg <= countdown_reg - 1'b1;
        if (countdown_reg == 1) begin
          busy <= 1'b0;
          done <= 1'b1;
          signature_length <= SIG_BYTES;
          for (byte_index = 0; byte_index < SIG_BYTES; byte_index = byte_index + 1) begin
            signature_bytes[byte_index] <= signature_byte_for_mode(byte_index, digest);
          end
        end
      end
    end
  end
endmodule