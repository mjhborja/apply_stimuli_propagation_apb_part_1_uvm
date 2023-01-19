class apbm_sequencer extends uvm_sequencer#(apb_trans);
	`uvm_component_utils(apbm_sequencer);
	function new(string name="apbm_sequencer",uvm_component parent);
		super.new(name,parent);
	endfunction
endclass
