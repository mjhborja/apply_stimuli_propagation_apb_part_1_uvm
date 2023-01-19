//


class apb_scoreboard extends uvm_scoreboard;
  `uvm_component_utils(apb_scoreboard)
  
  uvm_analysis_imp #(apb_trans,apb_scoreboard) mon;
  
  // Ref Mem
  bit [7:0] mem[*];
  logic [31:0] prdata;
  
  bit [31:0] matched, mis_matched;

  
function new(string name="apb_scoreboard",uvm_component parent=null);
    super.new(name,parent);
endfunction
  
virtual function void build_phase(uvm_phase phase);
	super.build_phase(phase);
  `uvm_info("[apb_scoreboard]","Build Phase Start",UVM_HIGH);
		mon=new("mon",this);
  `uvm_info("[apb_scoreboard]","Build Phase Stop",UVM_HIGH);
endfunction

  virtual function write(apb_trans tr);
    
    $display("[Receive_pkt] [%0s] paddr=%0p :: pdata=%0p size=%0d",tr.mode,tr.addr,tr.wdata,tr.pkt_size);
    
    if(tr.mode == WRITE) begin
      write_to_mem(tr);

    end
    
    else if(tr.mode == READ) begin
      read_from_mem(tr);

    end
    else begin
      `uvm_error("[apb_scoreboard]","Invalid mode");
    end
 
  endfunction
  
  function void write_to_mem(apb_trans tr1);
    for(int i=0;i<tr1.pkt_size;i++) begin

      write_mem(tr1.addr[i],tr1.wdata[i]);
    end
  endfunction
  
  function void read_from_mem(apb_trans tr1);

     	for(int i=0;i<tr1.pkt_size;i++) begin
          read_mem(tr1.addr[i],tr1.wdata[i]);
          $display("[Prdata]=%h",prdata);
          
          if(prdata === tr1.wdata[i]) begin
       
            matched++;
          end
          else begin
         
            mis_matched++;
          end
          
        end//end_of_for

  endfunction
  
  virtual function void final_phase(uvm_phase phase);
    $display("mem=%p",mem); 
    $display("Matched=%0d Mis_Matched=%0d",matched,mis_matched); 
  endfunction
  
  
  //*************************************mem_logic************************
  
  function void write_mem(input logic [31:0] paddr,pwdata);
    case(paddr%4)
       0: 	begin
         
         		mem[paddr] <= pwdata[7:0];
        	    mem[paddr+1] <= pwdata[15:8];
         	    mem[paddr+2] <= pwdata[23:16];
        	    mem[paddr+3] <= pwdata[31:24];
      	
       		end
       1: 	begin
         		mem[paddr] <= pwdata[15:8];
         		mem[paddr+1] <= pwdata[23:16];
        		mem[paddr+2] <= pwdata[31:24];
        
            end
       2: 	begin
       			mem[paddr] <= pwdata[23:16];
         		mem[paddr+1] <= pwdata[31:24];
       
      		end
       3: 	begin
         		mem[paddr] <= pwdata[31:24];

      		end
      default: begin
        $display("[Inside Write_mem] Default Addr=%0h",paddr);
      	 	   end
    endcase
  endfunction
  
    function void read_mem(input logic [31:0] paddr,pwdata);
    
    case(paddr%4)
      0: begin
  		 prdata[7:0] = mem[paddr];
         prdata[15:8] = mem[paddr+1];
         prdata[23:16] = mem[paddr+2];
         prdata[31:24] = mem[paddr+3];
      end
      1: begin
        prdata[7:0] = mem[paddr-1];
        prdata[15:8] = mem[paddr];
        prdata[23:16] = mem[paddr+1];
        prdata[31:24] = mem[paddr+2];
      end
      2: begin
        prdata[7:0] = mem[paddr-2];
        prdata[15:8] = mem[paddr-1];
         prdata[23:16] = mem[paddr];
        prdata[31:24] = mem[paddr+1];
      end
      3: begin
        prdata[7:0] = mem[paddr-3];
        prdata[15:8] = mem[paddr-2];
        prdata[23:16] = mem[paddr-1];
         prdata[31:24] = mem[paddr];
      end
      default: begin
        $display("[Inside Read_mem] Default Addr=%0h",paddr);
      end
    endcase
    endfunction
  
endclass

