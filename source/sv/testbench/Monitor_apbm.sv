//
class apbm_monitor extends uvm_monitor;
  `uvm_component_utils(apbm_monitor);
  
  virtual apb_if.Mon vif;
  
  reg [31:0] prdata_q[$];
  reg [31:0] pwdata_q[$];
  
    reg [31:0] paddr_q[$];
 
  mode_e mode_q[$];
  
  reg [7:0] mem_mon[4];
  reg [31:0] mem;
  
  int transaction_pkt;
  
  int tr_no;
  
  function new(string name="apbm_monitor",uvm_component parent);
		super.new(name,parent);
	endfunction
  
  uvm_analysis_port #(apb_trans) analysis_port;
  
  protected apb_trans tr;
  
  extern virtual task run_phase(uvm_phase phase);
extern virtual function void build_phase(uvm_phase phase);
  extern virtual function void connect_phase(uvm_phase phase);
  
    extern task send_transaction(input int pkt_size);
  
        
endclass
  
  function void apbm_monitor::build_phase(uvm_phase phase) ;
	super.build_phase(phase);
if (!uvm_config_db#(virtual apb_if.Mon)::get(get_parent(), "", "Mon_if", vif)) begin
  `uvm_fatal("CFGERR", "Monitor DUT interface not set");
end

    analysis_port=new("analysis_port",this);
endfunction
  
     function void apbm_monitor::connect_phase(uvm_phase phase) ;
       super.connect_phase(phase);
       tr = apb_trans::type_id::create("tr",this);
     endfunction
    
    
  task apbm_monitor::run_phase(uvm_phase phase);
forever begin

  if(~vif.cb_Mon.psel) begin
  	send_transaction(transaction_pkt);
  end
  
  @(vif.cb_Mon);
  
  if(vif.cb_Mon.psel) begin // Check for transfer enable
    
    transaction_pkt++;// Size of the transaction
    
    if(vif.cb_Mon.pwrite) begin
    	//pwaddr_q.push_back(vif.cb_Mon.paddr);
      mode_q.push_back(WRITE);
    end
    else begin
        //praddr_q.push_back(vif.cb_Mon.paddr);
      mode_q.push_back(READ);
    end
    
    paddr_q.push_back(vif.cb_Mon.paddr);
    
    while(1) begin
      
      @(vif.cb_Mon);
      
      if(vif.cb_Mon.penable && vif.cb_Mon.pready) begin
     
          if(vif.cb_Mon.pwrite) begin
        
            pwdata_q.push_back(vif.cb_Mon.pwdata);
         
     	  end
      	  
          else begin
            prdata_q.push_back(vif.cb_Mon.prdata);
           
      	  end
        
        break;
      end
      
    end
    
  end
  
 
  
  
end
  endtask
  
  task apbm_monitor::send_transaction(input int pkt_size);
    if(pkt_size > 0) begin

      tr.pkt_size=pkt_size;
      tr.addr=new[pkt_size];
      tr.wdata=new[pkt_size];
      tr_no++;
      
      
      foreach(mode_q[i]) begin
      // Write address and data pop out
        if(mode_q[i] == WRITE) begin
       // for(int i=0;i<pkt_size;i++ ) begin
          tr.addr[i] = paddr_q.pop_front();
          tr.wdata[i] = pwdata_q.pop_front();
			tr.mode = WRITE;
          // end
      end
      // Read address and data pop out
      else begin
       // for(int i=0;i<pkt_size;i++ ) begin
          tr.addr[i] = paddr_q.pop_front();
          tr.wdata[i] = prdata_q.pop_front();
        tr.mode = READ;
       // end
      end
      end// Foreach
      $display("[Send_pkt] [%0s] paddr=%0p :: pdata=%0p",tr.mode,tr.addr,tr.wdata);
      
     // pwaddr_q.delete();
      pwdata_q.delete();
     // praddr_q.delete();
      prdata_q.delete();
      
      paddr_q.delete();
      mode_q.delete();
      transaction_pkt=0;
      
      //Broadcasting
      analysis_port.write(tr);
      
    
    end
  endtask

      
       