`include "apb_trans.sv"
`include "sequence.sv"
`include "sequencer_apbm.sv"
`include "driver_apbm.sv"
`include "Monitor_apbm.sv"
`include "magent_apbm.sv"
`include "Scoreboard_apb.sv"
`include "apb_env.sv"
program automatic pgm_test(apb_if pif);
	`include "apb_test.sv"
	initial begin
      uvm_config_db#(virtual apb_if)::set(null,"*","drvr_if",pif);
      uvm_config_db#(virtual apb_if.Mon)::set(null,"*","Mon_if",pif.Mon);
		run_test();

	end
endprogram
