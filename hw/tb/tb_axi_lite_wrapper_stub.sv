`timescale 1ns / 1ps

module tb_axi_lite_wrapper_stub;
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

  axi_lite_wrapper_stub dut (
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

  logic [31:0] readback;
  integer word_index;

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

    repeat (4) @(posedge clk);
    rst_n = 1'b1;

    axi_read(STATUS_ADDR, readback);
    expect_equal(readback, STATUS_IDLE_MASK, "reset status should be idle");

    for (word_index = 0; word_index < DIGEST_WORDS; word_index = word_index + 1) begin
      axi_write(DIGEST_BASE_ADDR + (word_index * 4), 32'h03020100 + (word_index * 32'h04040404));
    end

    axi_write(DIGEST_BASE_ADDR + 0, 32'h03020100);
    axi_write(DIGEST_BASE_ADDR + 4, 32'h07060504);
    axi_write(CONTROL_ADDR, CONTROL_START_MASK);

    axi_read(STATUS_ADDR, readback);
    if ((readback & STATUS_BUSY_MASK) == 0) begin
      $fatal(1, "busy bit was not asserted after start");
    end

    repeat (STUB_DELAY_CYCLES + 1) @(posedge clk);

    axi_read(STATUS_ADDR, readback);
    if ((readback & STATUS_DONE_MASK) == 0) begin
      $fatal(1, "done bit was not asserted after deterministic delay");
    end

    axi_read(SIG_LENGTH_ADDR, readback);
    expect_equal(readback, SIG_BYTES, "signature length should be fixed stub size");

    axi_read(SIG_DATA_BASE_ADDR, readback);
    expect_equal(readback, 32'h4255_5453, "first signature word should encode STUB");

    axi_read(SIG_DATA_BASE_ADDR + 4, readback);
    expect_equal(readback, 32'h0047_4953, "second signature word should encode SIG and digest byte 0");

    axi_write(CONTROL_ADDR, CONTROL_CLEAR_STATUS_MASK);
    axi_read(STATUS_ADDR, readback);
    expect_equal(readback, STATUS_IDLE_MASK, "clear_status should restore idle-only state");

    $display("tb_axi_lite_wrapper_stub: PASS");
    $finish;
  end
endmodule
