`timescale 1ns / 1ps

module axi_lite_wrapper_stub (
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
  logic [31:0] error_code_reg;
  logic [31:0] sig_length_reg;
  logic busy_reg;
  logic done_reg;
  logic error_reg;
  logic [31:0] busy_countdown_reg;

  integer i;

  assign s_axi_awready = 1'b1;
  assign s_axi_wready = 1'b1;
  assign s_axi_bresp = 2'b00;
  assign s_axi_arready = 1'b1;
  assign s_axi_rresp = 2'b00;

  function automatic logic [31:0] pack_bytes(
    input logic [7:0] b0,
    input logic [7:0] b1,
    input logic [7:0] b2,
    input logic [7:0] b3
  );
    pack_bytes = {b3, b2, b1, b0};
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

  function automatic logic [31:0] read_word(input logic [31:0] addr);
    int unsigned index;
    begin
      read_word = 32'h0;
      unique case (addr)
        CONTROL_ADDR: read_word = 32'h0;
        STATUS_ADDR: read_word = status_word(busy_reg, done_reg, error_reg);
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
          end else begin
            read_word = 32'h0;
          end
        end
      endcase
    end
  endfunction

  task automatic build_stub_signature;
    int unsigned byte_index;
    begin
      for (byte_index = 0; byte_index < SIG_BYTES; byte_index = byte_index + 1) begin
        if (byte_index < 7) begin
          signature_bytes[byte_index] <= stub_prefix_byte(byte_index);
        end else if (byte_index < 7 + DIGEST_BYTES) begin
          signature_bytes[byte_index] <= digest_bytes[byte_index - 7];
        end else begin
          signature_bytes[byte_index] <= 8'h00;
        end
      end
      sig_length_reg <= SIG_BYTES;
    end
  endtask

  always_ff @(posedge aclk) begin
    if (!aresetn) begin
      s_axi_bvalid <= 1'b0;
      s_axi_rvalid <= 1'b0;
      s_axi_rdata <= 32'h0;
      error_code_reg <= ERROR_NONE;
      sig_length_reg <= 32'h0;
      busy_reg <= 1'b0;
      done_reg <= 1'b0;
      error_reg <= 1'b0;
      busy_countdown_reg <= 32'h0;
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

      if (busy_reg && (busy_countdown_reg != 0)) begin
        busy_countdown_reg <= busy_countdown_reg - 1'b1;
        if (busy_countdown_reg == 1) begin
          busy_reg <= 1'b0;
          done_reg <= 1'b1;
          build_stub_signature();
        end
      end

      if (s_axi_awvalid && s_axi_wvalid && !s_axi_bvalid) begin
        s_axi_bvalid <= 1'b1;
        unique case (s_axi_awaddr)
          CONTROL_ADDR: begin
            if (s_axi_wdata & CONTROL_CLEAR_STATUS_MASK) begin
              done_reg <= 1'b0;
              error_reg <= 1'b0;
              error_code_reg <= ERROR_NONE;
              if (!busy_reg) begin
                sig_length_reg <= 32'h0;
                for (i = 0; i < SIG_BYTES; i = i + 1) begin
                  signature_bytes[i] <= 8'h00;
                end
              end
            end
            if (s_axi_wdata & CONTROL_START_MASK) begin
              if (busy_reg) begin
                error_reg <= 1'b1;
                done_reg <= 1'b0;
                error_code_reg <= ERROR_START_WHILE_BUSY;
              end else begin
                error_reg <= 1'b0;
                done_reg <= 1'b0;
                error_code_reg <= ERROR_NONE;
                sig_length_reg <= 32'h0;
                for (i = 0; i < SIG_BYTES; i = i + 1) begin
                  signature_bytes[i] <= 8'h00;
                end
                busy_reg <= 1'b1;
                busy_countdown_reg <= STUB_DELAY_CYCLES;
              end
            end
          end
          default: begin
            if ((s_axi_awaddr >= DIGEST_BASE_ADDR) && (s_axi_awaddr < DIGEST_BASE_ADDR + (DIGEST_WORDS * 4))) begin
              int unsigned digest_index;
              digest_index = (s_axi_awaddr - DIGEST_BASE_ADDR) >> 2;
              if (s_axi_wstrb[0]) digest_bytes[digest_index * 4] <= s_axi_wdata[7:0];
              if (s_axi_wstrb[1]) digest_bytes[digest_index * 4 + 1] <= s_axi_wdata[15:8];
              if (s_axi_wstrb[2]) digest_bytes[digest_index * 4 + 2] <= s_axi_wdata[23:16];
              if (s_axi_wstrb[3]) digest_bytes[digest_index * 4 + 3] <= s_axi_wdata[31:24];
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
