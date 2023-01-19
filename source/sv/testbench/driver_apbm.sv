class apbm_driver extends uvm_driver#(apb_trans);
	`uvm_component_utils(apbm_driver)

	virtual apb_if vif;
	bit [31:0] pkt_id;
  
  
	function new(string name="apbm_driver",uvm_component parent);
		super.new(name,parent);
	endfunction

	extern virtual task run_phase(uvm_phase phase);
	//extern virtual task reset_phase(uvm_phase phase);
	extern virtual function void build_phase(uvm_phase phase);
	extern virtual task write(input logic [31:0] addr_local,wdata_local);
	extern virtual task read(input logic [31:0] addr_local);
      extern virtual task reset();
        extern virtual task reset_drvr();
	extern virtual task drive(input logic [31:0] addr_local,wdata_local);
      
      extern virtual task wdata_write(input logic [31:0] addr_local,wdata_local);
endclass

function void apbm_driver::build_phase(uvm_phase phase);
	super.build_phase(phase);
  if(uvm_config_db#(virtual apb_if)::get(this,"","drvr_if",vif) == null) `uvm_fatal(get_type_name(),"Virtual interface in apb_driver is NULL")
//	assert(vif != null) else
//		`uvm_fatal(get_type_name(),"Virtual interface in apb_driver is NULL")
endfunction

task apbm_driver::run_phase(uvm_phase phase);
	super.run_phase(phase);
  reset_drvr();
  
  @(vif.cbm);
  
  forever begin
		seq_item_port.get_next_item(req);
	//	pkt_id++;
    //  `uvm_info(get_type_name(),$sformatf("[%0d] %s",pkt_id,req.convert2string()),UVM_MEDIUM)
    
    @(vif.cbm);
   
    for(int i=0; i<req.pkt_size;i++) begin
    
      drive(req.addr[i],req.wdata[i]);
  //  drive(req.addr,req.wdata);
      
        @(vif.cbm);
    	vif.cbm.penable <= 0;
    end
    
  		vif.cbm.psel <= 0;
      seq_item_port.item_done();

		
	end
endtask

  task apbm_driver::drive(input logic [31:0] addr_local,wdata_local);
    case(req.mode)
    //  RESET: reset();
   	 READ: read(addr_local);
      WRITE: write(addr_local,wdata_local);
	endcase
endtask

  task apbm_driver::write(input logic [31:0] addr_local,wdata_local);
    `uvm_info("Write","APB Write transaction started...",UVM_HIGH)

  	vif.cbm.psel <= 1;
  vif.cbm.pwrite <= 1;

  vif.cbm.paddr <= addr_local;
	
   wdata_write(addr_local, wdata_local);
  
    
    
  while(1) begin
  
  @(vif.cbm);
  vif.cbm.penable <=1;
  
    if(vif.pready == 1)  
      break;
  end
    
endtask

  task apbm_driver::read(input logic [31:0] addr_local);
    `uvm_info("Read","APB Read transaction started...",UVM_HIGH)

  	vif.cbm.psel <= 1;
  vif.cbm.pwrite <= 0;
  // vif.cbm.penable <= 0;
  vif.cbm.paddr <= addr_local;
  
  while(1) begin
  
  @(vif.cbm);
  vif.cbm.penable <=1;
 
    if(vif.pready == 1)
      break;
    //@(vif.cbm);
  
  end

    `uvm_info("Read","APB Read transaction ended...",UVM_HIGH)
endtask

  task apbm_driver::reset();
	
    `uvm_info("Driver","Applying reset to APB",UVM_HIGH)
	vif.cbm.psel <= 0;
	vif.cbm.penable <= 0;
	vif.reset_n <= 0;
    vif.cbm.paddr <= 0;
    vif.cbm.pwrite <=0;
   // vif.cbm.pwdata <= 0;
	@(vif.cbm);
    @(vif.cbm);
	vif.reset_n <= 1;
    vif.cbm.psel <= 0;
	vif.cbm.penable <= 0;
	@(vif.cbm);
    @(vif.cbm);
    `uvm_info("Driver","APB out of reset",UVM_HIGH)
	
endtask

  task apbm_driver::reset_drvr();
    @(negedge vif.reset_n)
    
    vif.cbm.psel <= 0;
	vif.cbm.penable <= 0;
	vif.reset_n <= 0;
    vif.cbm.paddr <= 0;
    vif.cbm.pwrite <=0;
    
  endtask
 
  task apbm_driver::wdata_write(input logic [31:0] addr_local, wdata_local);

    case(addr_local%4)
       0: 	begin
         
      		vif.cbm.pwdata <= wdata_local;
       		end
       1: 	begin
         		vif.cbm.pwdata[15:8] <= wdata_local[15:8];
         		vif.cbm.pwdata[23:16] <= wdata_local[23:16];
         		vif.cbm.pwdata[31:24] <= wdata_local[31:24];
        
            end
       2: 	begin
         		vif.cbm.pwdata[23:16] <= wdata_local[23:16];
         		vif.cbm.pwdata[31:24] <= wdata_local[31:24];
       
      		end
       3: 	begin
         		vif.cbm.pwdata[31:24] <= wdata_local[31:24];

      		end
      default: begin
        		$display("[Inside] Default");
      	 	   end
    endcase
    
    endtask
  