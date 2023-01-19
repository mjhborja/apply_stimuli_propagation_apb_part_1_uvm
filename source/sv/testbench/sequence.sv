class apb_sequence extends uvm_sequence#(apb_trans);
	`uvm_object_utils(apb_sequence)
	
	int unsigned pkt_count;
apb_trans ref_pkt;
  
	function new(string name="apb_sequence");
		super.new(name);
	endfunction
	virtual task pre_start();
		pkt_count=10;
	endtask
  
  logic [31:0] exp_addr[];
  logic [4:0] exp_size;
  
	task body();
		int unsigned pkt_id;
      
     req = apb_trans::type_id::create("pkt");
      
      assert(req.randomize() with {req.mode == WRITE;});
     // req.addr[0] = 'd0;  // To test the un allined addredd write
         start_item(req);
     	// req.print();
        finish_item(req);       
      
      assert(req.randomize() with {req.mode == READ;});
      // req.addr[0] = 'd2;
         start_item(req);
     	// req.print();
        finish_item(req);
    
      req.valid_size.constraint_mode(0);
      
      assert(req.randomize() with {req.mode == READ; req.pkt_size == 1; req.addr.size()==1; req.wdata.size()==1;req.addr[0] == 'd2;});
     // req.addr[0] = 'd2;  // To test the un allined addredd write
         start_item(req);
     	// req.print();
        finish_item(req);
      
           req.valid_size.constraint_mode(0);
      assert(req.randomize() with {req.mode == WRITE; req.pkt_size == 4; req.addr.size()==4; req.wdata.size()==4;req.addr[0] == 'd2;});
      //req.addr[0] = 'd2;  // To test the un allined addredd write
         start_item(req);
     	// req.print();
        finish_item(req);
      
       req.valid_size.constraint_mode(0);
      assert(req.randomize() with {req.mode == READ; req.pkt_size == 2; req.addr.size()==2; req.wdata.size()==2; req.addr[0] == 'd3;});
      //req.addr[0] = 'd3;  // To test the un allined addredd write
         start_item(req);
     	// req.print();
      finish_item(req);   
    endtask
  
endclass
