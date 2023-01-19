typedef enum {READ,WRITE} mode_e;
 
 class apb_trans extends uvm_sequence_item;
   rand logic [31:0] addr[];
   rand logic [31:0] wdata[];
	
   
	 rand mode_e mode;
	rand int unsigned pkt_size;
  
  constraint values{
    foreach(addr[i]) {
     soft addr[i] == 4*i; 
  
    }
      foreach(wdata[i]) {
        wdata[i] inside {[1000000000:1900000000]};
      }
  }
        
      constraint valid_size{
        addr.size == pkt_size;
        wdata.size == pkt_size;
        
        
       soft pkt_size == 3;
        
        solve pkt_size before addr, wdata;
      }
	 
	 `uvm_object_utils_begin(apb_trans)
	 `uvm_field_array_int(addr, UVM_ALL_ON)
	 `uvm_field_array_int(wdata, UVM_ALL_ON)

    `uvm_field_enum(mode_e,mode, UVM_ALL_ON)
        `uvm_field_int(pkt_size, UVM_ALL_ON);
	 `uvm_object_utils_end
	 function new(string name="apb_trans");
		 super.new(name);
	 endfunction
	
 endclass
