class apb_test extends uvm_test;
	`uvm_component_utils(apb_test)

	bit [31:0] pkt_count;

	virtual apb_if.master drvr_vif;

	apb_env env;
  apb_sequence apb_seq;

	function new(string name="apb_test",uvm_component parent);
		super.new(name,parent);
	endfunction
	extern virtual function void build_phase(uvm_phase phase);
      extern virtual  task run_phase(uvm_phase phase);

      
      virtual function void end_of_elaboration_phase(uvm_phase phase);
        print();
      endfunction
      
endclass

function void apb_test::build_phase(uvm_phase phase);
	super.build_phase(phase);
  `uvm_info("[apb_test]","Build Phase Start",UVM_HIGH);
	pkt_count=10;
  `uvm_info("Test",$sformatf("Pkt_count = %0d",pkt_count),UVM_HIGH);

 
	uvm_config_db#(int)::set(this,"env.m_agent.apbm_seqr","item_count",pkt_count);

	
  apb_seq=apb_sequence::type_id::create("seq_pkt",this);
  
  env=apb_env::type_id::create("apb_env",this);

  `uvm_info("[apb_test]",$sformatf("Build Phase End"),UVM_HIGH)
endfunction
      
        task apb_test::run_phase(uvm_phase phase);
          super.run_phase(phase);
          
          phase.phase_done.set_drain_time(this,10);
          
          `uvm_info("Apb_Test","Applying run phase to APB",UVM_HIGH)
	phase.raise_objection(this);
		

          `uvm_info("APb_Test","Out of phase objection",UVM_HIGH)
          
          
          
          apb_seq.start(env.m_agent.apbm_seqr);
          
   
          
          
          	phase.drop_objection(this);
        endtask
