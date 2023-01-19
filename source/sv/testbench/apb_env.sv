class apb_env extends uvm_env;
	`uvm_component_utils(apb_env)

	apb_master_agent m_agent;
  	apb_scoreboard   apb_scb;
	
	function new(string name="apb_env",uvm_component parent);
		super.new(name,parent);
	endfunction

	extern virtual function void build_phase(uvm_phase phase);
      extern virtual function void connect_phase(uvm_phase phase);
endclass

function void apb_env::build_phase(uvm_phase phase);
	super.build_phase(phase);
	m_agent=apb_master_agent::type_id::create("m_agent",this);
    apb_scb=apb_scoreboard::type_id::create("apb_scb",this);
endfunction

function void apb_env::connect_phase(uvm_phase phase);
    m_agent.ap.connect(apb_scb.mon);
endfunction