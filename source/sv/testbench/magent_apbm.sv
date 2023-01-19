class apb_master_agent extends uvm_agent;
	`uvm_component_utils(apb_master_agent)

	apbm_sequencer apbm_seqr;
	apbm_driver apbm_drv;
	apbm_monitor  apbm_mon;	
  
	uvm_analysis_port#(apb_trans) ap;

	function new(string name="apb_master_agent",uvm_component parent);
		super.new(name,parent);
	endfunction

	extern virtual function void build_phase(uvm_phase phase);
	extern virtual function void connect_phase(uvm_phase phase);
endclass

function void apb_master_agent::build_phase(uvm_phase phase);
	super.build_phase(phase);
  `uvm_info("[m_agent]","Start",UVM_HIGH)
	ap=new("ap",this);
	if(is_active == UVM_ACTIVE) begin
		apbm_seqr=apbm_sequencer::type_id::create("apbm_seqr",this);
		apbm_drv=apbm_driver::type_id::create("apbm_drv",this);
	end
  apbm_mon=apbm_monitor::type_id::create("apbm_mon",this);
  `uvm_info("[m_agent]","END",UVM_HIGH)
endfunction

function void apb_master_agent::connect_phase(uvm_phase phase);
	super.connect_phase(phase);
	if(is_active == UVM_ACTIVE) begin
		apbm_drv.seq_item_port.connect(apbm_seqr.seq_item_export);
	end
  		apbm_mon.analysis_port.connect(ap);
endfunction

