interface apb_if(input logic pclk);
	logic reset_n;
	logic psel;
	logic pready;
	logic penable;
	logic pwrite;
	logic [31:0] paddr;
	logic [31:0] pwdata;
	logic [31:0] prdata;
	//logic pslverr;
  
	clocking cbm @(posedge pclk);
		output psel;
		input pready;
		output penable; 
		output pwrite; 
		output paddr;
		output  pwdata;
		input  prdata;
	//	input pslverr;
	endclocking
  
  	//Monitor clocking block
  	clocking cb_Mon @(posedge pclk);
      	input psel;
		input pready;
      	input penable; 
		input pwrite; 
		input paddr;
		input  pwdata;
		input  prdata;
	endclocking
  
	modport master(clocking cbm, output reset_n);
     
      modport Mon(clocking cb_Mon);
      
endinterface
