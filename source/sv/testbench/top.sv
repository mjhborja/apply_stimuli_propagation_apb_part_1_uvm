
import uvm_pkg::*;
//`include "uvm_macros.svh"
`include "apb_if.sv"

`include "pgm_test.sv"


module top;
bit clk=0;

apb_if intf_apb(clk);

apb_slave dut_slave(
.paddr(intf_apb.paddr),
.psel(intf_apb.psel),
.penable(intf_apb.penable),
.pwrite(intf_apb.pwrite),
.prdata(intf_apb.prdata), 
.pwdata(intf_apb.pwdata),
.pclk(intf_apb.pclk),
.prst(intf_apb.reset_n),
.pready(intf_apb.pready)

);

pgm_test pgm_test_inst(intf_apb);
always #5 clk = ~clk;
  

  
  initial begin
    $dumpvars();
    $dumpfile("apb.vcd");
 
    
    intf_apb.reset_n <=1;
    @(posedge clk);
    intf_apb.reset_n <=0;
    @(posedge clk);
    intf_apb.reset_n <=1;
  end

endmodule
