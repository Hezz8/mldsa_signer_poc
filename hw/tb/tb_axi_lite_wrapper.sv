`timescale 1ns / 1ps

module wrapper_mode_runner #(
  parameter int unsigned ENGINE_MODE = wrapper_pkg::ENGINE_MODE_STUB
) (
  output logic test_done
);
  import wrapper_pkg::*;

  logic clk;
  logic rst_n;
  logic [31:0] awaddr;
  logic awvalid;
  logic awready;
  logic [31:0] wdata;
  logic [3:0] wstrb;
  logic wvalid;
  logic wready;
  logic [1:0] bresp;
  logic bvalid;
  logic bready;
  logic [31:0] araddr;
  logic arvalid;
  logic arready;
  logic [31:0] rdata;
  logic [1:0] rresp;
  logic rvalid;
  logic rready;
  logic [31:0] readback;
  integer word_index;

  axi_lite_wrapper #(
    .ENGINE_MODE(ENGINE_MODE)
  ) dut (
    .aclk(clk),
    .aresetn(rst_n),
    .s_axi_awaddr(awaddr),
    .s_axi_awvalid(awvalid),
    .s_axi_awready(awready),
    .s_axi_wdata(wdata),
    .s_axi_wstrb(wstrb),
    .s_axi_wvalid(wvalid),
    .s_axi_wready(wready),
    .s_axi_bresp(bresp),
    .s_axi_bvalid(bvalid),
    .s_axi_bready(bready),
    .s_axi_araddr(araddr),
    .s_axi_arvalid(arvalid),
    .s_axi_arready(arready),
    .s_axi_rdata(rdata),
    .s_axi_rresp(rresp),
    .s_axi_rvalid(rvalid),
    .s_axi_rready(rready)
  );

  initial clk = 1'b0;
  always #5 clk = ~clk;

  task automatic axi_write(input logic [31:0] addr, input logic [31:0] data);
    begin
      @(posedge clk);
      awaddr <= addr;
      awvalid <= 1'b1;
      wdata <= data;
      wstrb <= 4'hF;
      wvalid <= 1'b1;
      bready <= 1'b1;
      wait (bvalid == 1'b1);
      @(posedge clk);
      awvalid <= 1'b0;
      wvalid <= 1'b0;
      bready <= 1'b0;
    end
  endtask

  task automatic axi_read(input logic [31:0] addr, output logic [31:0] data);
    begin
      @(posedge clk);
      araddr <= addr;
      arvalid <= 1'b1;
      rready <= 1'b1;
      wait (rvalid == 1'b1);
      data = rdata;
      @(posedge clk);
      arvalid <= 1'b0;
      rready <= 1'b0;
    end
  endtask

  task automatic expect_equal(input logic [31:0] actual, input logic [31:0] expected, input string message);
    begin
      if (actual !== expected) begin
        $fatal(1, "%s: expected 0x%08x got 0x%08x", message, expected, actual);
      end
    end
  endtask

  function automatic int unsigned expected_wait_cycles;
    begin
      case (ENGINE_MODE)
        ENGINE_MODE_STUB: expected_wait_cycles = STUB_DELAY_CYCLES + 1;
        ENGINE_MODE_CORE_PLACEHOLDER: expected_wait_cycles = CORE_PLACEHOLDER_DELAY_CYCLES + 1;
        default: expected_wait_cycles = MLDSA_OSH_RESET_CYCLES + 4;
      endcase
    end
  endfunction

  function automatic logic [31:0] expected_sig_word0;
    begin
      if (ENGINE_MODE == ENGINE_MODE_STUB) begin
        expected_sig_word0 = 32'h4255_5453;
      end else begin
        expected_sig_word0 = 32'h4552_4F43;
      end
    end
  endfunction

  function automatic logic [31:0] expected_sig_word1;
    begin
      if (ENGINE_MODE == ENGINE_MODE_STUB) begin
        expected_sig_word1 = 32'h0047_4953;
      end else begin
        expected_sig_word1 = 32'h0100_4850;
      end
    end
  endfunction

  initial begin
    awaddr = '0;
    awvalid = 1'b0;
    wdata = '0;
    wstrb = 4'h0;
    wvalid = 1'b0;
    bready = 1'b0;
    araddr = '0;
    arvalid = 1'b0;
    rready = 1'b0;
    rst_n = 1'b0;
    test_done = 1'b0;

    repeat (4) @(posedge clk);
    rst_n = 1'b1;

    axi_read(STATUS_ADDR, readback);
    expect_equal(readback, STATUS_IDLE_MASK, "reset status should be idle");

    for (word_index = 0; word_index < DIGEST_WORDS; word_index = word_index + 1) begin
      axi_write(DIGEST_BASE_ADDR + (word_index * 4), 32'h03020100 + (word_index * 32'h04040404));
    end

    axi_write(CONTROL_ADDR, CONTROL_START_MASK);

    axi_read(STATUS_ADDR, readback);
    if ((readback & STATUS_BUSY_MASK) == 0) begin
      $fatal(1, "start did not assert busy in mode %0d", ENGINE_MODE);
    end

    repeat (expected_wait_cycles()) @(posedge clk);

    axi_read(STATUS_ADDR, readback);
    if (ENGINE_MODE == ENGINE_MODE_MLDSA_OSH) begin
      if ((readback & STATUS_ERROR_MASK) == 0) begin
        $fatal(1, "MLDSA_OSH fallback mode did not assert error when real core was not compiled in");
      end
      if ((readback & STATUS_BUSY_MASK) != 0) begin
        $fatal(1, "MLDSA_OSH fallback mode remained busy after failure path");
      end
      axi_read(ERROR_CODE_ADDR, readback);
      expect_equal(readback, ERROR_ENGINE, "MLDSA_OSH fallback should surface engine error code");

      axi_read(SIG_LENGTH_ADDR, readback);
      expect_equal(readback, 32'h0, "MLDSA_OSH fallback should not report signature data");

      axi_read(SIG_DATA_BASE_ADDR, readback);
      expect_equal(readback, 32'h0, "MLDSA_OSH fallback should expose zeroed signature data");
    end else begin
      if ((readback & STATUS_DONE_MASK) == 0) begin
        $fatal(1, "done bit was not asserted after deterministic delay in mode %0d", ENGINE_MODE);
      end

      axi_read(SIG_LENGTH_ADDR, readback);
      expect_equal(readback, SIG_BYTES, "signature length should remain fixed in deterministic modes");

      axi_read(SIG_DATA_BASE_ADDR, readback);
      expect_equal(readback, expected_sig_word0(), "first signature word mismatch");

      axi_read(SIG_DATA_BASE_ADDR + 4, readback);
      expect_equal(readback, expected_sig_word1(), "second signature word mismatch");
    end

    axi_write(CONTROL_ADDR, CONTROL_CLEAR_STATUS_MASK);
    axi_read(STATUS_ADDR, readback);
    expect_equal(readback, STATUS_IDLE_MASK, "clear_status should restore idle-only state");

    case (ENGINE_MODE)
      ENGINE_MODE_STUB: $display("wrapper_mode_runner STUB: PASS");
      ENGINE_MODE_CORE_PLACEHOLDER: $display("wrapper_mode_runner CORE_PLACEHOLDER: PASS");
      default: $display("wrapper_mode_runner MLDSA_OSH_FALLBACK: PASS");
    endcase
    test_done = 1'b1;
  end
endmodule

module tb_axi_lite_wrapper;
  logic stub_done;
  logic placeholder_done;
  logic mldsa_osh_done;

  wrapper_mode_runner #(
    .ENGINE_MODE(wrapper_pkg::ENGINE_MODE_STUB)
  ) stub_runner (
    .test_done(stub_done)
  );

  wrapper_mode_runner #(
    .ENGINE_MODE(wrapper_pkg::ENGINE_MODE_CORE_PLACEHOLDER)
  ) placeholder_runner (
    .test_done(placeholder_done)
  );

  wrapper_mode_runner #(
    .ENGINE_MODE(wrapper_pkg::ENGINE_MODE_MLDSA_OSH)
  ) mldsa_osh_runner (
    .test_done(mldsa_osh_done)
  );

  initial begin
    wait (stub_done && placeholder_done && mldsa_osh_done);
    $display("tb_axi_lite_wrapper: PASS");
    $finish;
  end
endmodule