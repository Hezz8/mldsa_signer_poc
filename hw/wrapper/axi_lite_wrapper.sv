`timescale 1ns / 1ps

module axi_lite_wrapper #(
  parameter int unsigned ENGINE_MODE = wrapper_pkg::ENGINE_MODE_STUB
) (
  input  logic        aclk,
  input  logic        aresetn,
  input  logic [31:0] s_axi_awaddr,
  input  logic        s_axi_awvalid,
  output logic        s_axi_awready,
  input  logic [31:0] s_axi_wdata,
  input  logic [3:0]  s_axi_wstrb,
  input  logic        s_axi_wvalid,
  output logic        s_axi_wready,
  output logic [1:0]  s_axi_bresp,
  output logic        s_axi_bvalid,
  input  logic        s_axi_bready,
  input  logic [31:0] s_axi_araddr,
  input  logic        s_axi_arvalid,
  output logic        s_axi_arready,
  output logic [31:0] s_axi_rdata,
  output logic [1:0]  s_axi_rresp,
  output logic        s_axi_rvalid,
  input  logic        s_axi_rready
);
  import wrapper_pkg::*;

  logic [7:0] digest_bytes [0:DIGEST_BYTES-1];
  logic [7:0] signature_bytes [0:SIG_BYTES-1];
  logic [DIGEST_BITS-1:0] digest_vector;
  logic engine_busy;
  logic engine_done;
  logic engine_error;
  logic [31:0] engine_signature_length;
  logic [SIG_BITS-1:0] engine_signature_buffer;
  logic operation_inflight_reg;
  logic done_reg;
  logic error_reg;
  logic [31:0] error_code_reg;
  logic [31:0] sig_length_reg;
  logic start_request;
  integer i;

  assign s_axi_awready = 1'b1;
  assign s_axi_wready = 1'b1;
  assign s_axi_bresp = 2'b00;
  assign s_axi_arready = 1'b1;
  assign s_axi_rresp = 2'b00;

  assign start_request = s_axi_awvalid && s_axi_wvalid && !s_axi_bvalid &&
                         (s_axi_awaddr == CONTROL_ADDR) &&
                         ((s_axi_wdata & CONTROL_START_MASK) != 32'h0) &&
                         !operation_inflight_reg;

  always_comb begin
    digest_vector = '0;
    for (int unsigned digest_index = 0; digest_index < DIGEST_BYTES; digest_index = digest_index + 1) begin
      digest_vector[(digest_index * 8) +: 8] = digest_bytes[digest_index];
    end
  end

  mldsa_engine_adapter #(
    .ENGINE_MODE(ENGINE_MODE)
  ) engine_adapter (
    .clk(aclk),
    .rst(!aresetn),
    .start(start_request),
    .digest(digest_vector),
    .busy(engine_busy),
    .done(engine_done),
    .error(engine_error),
    .signature_length(engine_signature_length),
    .signature_buffer(engine_signature_buffer)
  );

  function automatic logic [31:0] pack_bytes(
    input logic [7:0] b0,
    input logic [7:0] b1,
    input logic [7:0] b2,
    input logic [7:0] b3
  );
    pack_bytes = {b3, b2, b1, b0};
  endfunction

  function automatic logic [31:0] read_word(input logic [31:0] addr);
    int unsigned index;
    begin
      read_word = 32'h0;
      unique case (addr)
        CONTROL_ADDR: read_word = 32'h0;
        STATUS_ADDR: read_word = status_word(operation_inflight_reg, done_reg, error_reg);
        ERROR_CODE_ADDR: read_word = error_code_reg;
        SIG_LENGTH_ADDR: read_word = sig_length_reg;
        default: begin
          if ((addr >= DIGEST_BASE_ADDR) && (addr < DIGEST_BASE_ADDR + (DIGEST_WORDS * 4))) begin
            index = (addr - DIGEST_BASE_ADDR) >> 2;
            read_word = pack_bytes(
              digest_bytes[index * 4],
              digest_bytes[index * 4 + 1],
              digest_bytes[index * 4 + 2],
              digest_bytes[index * 4 + 3]
            );
          end else if ((addr >= SIG_DATA_BASE_ADDR) && (addr < SIG_DATA_BASE_ADDR + (SIG_WORDS * 4))) begin
            index = (addr - SIG_DATA_BASE_ADDR) >> 2;
            read_word = pack_bytes(
              signature_bytes[index * 4],
              signature_bytes[index * 4 + 1],
              signature_bytes[index * 4 + 2],
              signature_bytes[index * 4 + 3]
            );
          end
        end
      endcase
    end
  endfunction

  always_ff @(posedge aclk) begin
    if (!aresetn) begin
      s_axi_bvalid <= 1'b0;
      s_axi_rvalid <= 1'b0;
      s_axi_rdata <= 32'h0;
      operation_inflight_reg <= 1'b0;
      done_reg <= 1'b0;
      error_reg <= 1'b0;
      error_code_reg <= ERROR_NONE;
      sig_length_reg <= 32'h0;
      for (i = 0; i < DIGEST_BYTES; i = i + 1) begin
        digest_bytes[i] <= 8'h00;
      end
      for (i = 0; i < SIG_BYTES; i = i + 1) begin
        signature_bytes[i] <= 8'h00;
      end
    end else begin
      if (s_axi_bvalid && s_axi_bready) begin
        s_axi_bvalid <= 1'b0;
      end
      if (s_axi_rvalid && s_axi_rready) begin
        s_axi_rvalid <= 1'b0;
      end

      if (engine_done) begin
        operation_inflight_reg <= 1'b0;
        done_reg <= 1'b1;
        error_reg <= 1'b0;
        error_code_reg <= ERROR_NONE;
        sig_length_reg <= engine_signature_length;
        for (i = 0; i < SIG_BYTES; i = i + 1) begin
          signature_bytes[i] <= engine_signature_buffer[(i * 8) +: 8];
        end
      end

      if (engine_error) begin
        operation_inflight_reg <= 1'b0;
        done_reg <= 1'b0;
        error_reg <= 1'b1;
        error_code_reg <= ERROR_ENGINE;
      end

      if (s_axi_awvalid && s_axi_wvalid && !s_axi_bvalid) begin
        s_axi_bvalid <= 1'b1;
        unique case (s_axi_awaddr)
          CONTROL_ADDR: begin
            if ((s_axi_wdata & CONTROL_CLEAR_STATUS_MASK) != 32'h0) begin
              done_reg <= 1'b0;
              error_reg <= 1'b0;
              error_code_reg <= ERROR_NONE;
              if (!operation_inflight_reg) begin
                sig_length_reg <= 32'h0;
                for (i = 0; i < SIG_BYTES; i = i + 1) begin
                  signature_bytes[i] <= 8'h00;
                end
              end
            end
            if ((s_axi_wdata & CONTROL_START_MASK) != 32'h0) begin
              if (operation_inflight_reg) begin
                error_reg <= 1'b1;
                done_reg <= 1'b0;
                error_code_reg <= ERROR_START_WHILE_BUSY;
              end else begin
                operation_inflight_reg <= 1'b1;
                error_reg <= 1'b0;
                done_reg <= 1'b0;
                error_code_reg <= ERROR_NONE;
                sig_length_reg <= 32'h0;
                for (i = 0; i < SIG_BYTES; i = i + 1) begin
                  signature_bytes[i] <= 8'h00;
                end
              end
            end
          end
          default: begin
            if ((s_axi_awaddr >= DIGEST_BASE_ADDR) && (s_axi_awaddr < DIGEST_BASE_ADDR + (DIGEST_WORDS * 4))) begin
              int unsigned digest_word_index;
              digest_word_index = (s_axi_awaddr - DIGEST_BASE_ADDR) >> 2;
              if (s_axi_wstrb[0]) digest_bytes[digest_word_index * 4] <= s_axi_wdata[7:0];
              if (s_axi_wstrb[1]) digest_bytes[digest_word_index * 4 + 1] <= s_axi_wdata[15:8];
              if (s_axi_wstrb[2]) digest_bytes[digest_word_index * 4 + 2] <= s_axi_wdata[23:16];
              if (s_axi_wstrb[3]) digest_bytes[digest_word_index * 4 + 3] <= s_axi_wdata[31:24];
            end else begin
              error_reg <= 1'b1;
              error_code_reg <= ERROR_INVALID_OFFSET;
            end
          end
        endcase
      end

      if (s_axi_arvalid && !s_axi_rvalid) begin
        s_axi_rvalid <= 1'b1;
        s_axi_rdata <= read_word(s_axi_araddr);
      end
    end
  end
endmodule