typedef enum bit {EQUALITY, UVM} comp_t;

class router_sb extends uvm_scoreboard;
    comp_t comparer_policy = EQUALITY;

    `uvm_component_utils_begin(router_sb)
        `uvm_field_enum(comp_t, comparer_policy, UVM_ALL_ON)
    `uvm_component_utils_end 

    `uvm_analysis_imp_decl(_yapp)
    `uvm_analysis_imp_decl(_chan0)
    `uvm_analysis_imp_decl(_chan1)
    `uvm_analysis_imp_decl(_chan2)

    bit [7:0] maxpktsize;
    bit router_en;
    int invalid_packet_count;
    int dropped_pkt;
    int valid_pkt;

    uvm_tlm_analysis_fifo #(yapp_packet) yapp_fifo;    
    uvm_tlm_analysis_fifo #(channel_packet) chan0_fifo;
    uvm_tlm_analysis_fifo #(channel_packet) chan1_fifo;
    uvm_tlm_analysis_fifo #(channel_packet) chan2_fifo;
    uvm_tlm_analysis_fifo #(hbus_transaction) hbus_fifo;
       
     int packets_received0, packets_received1, packets_received2;                                                     
     int wrong_pkt0, wrong_pkt1, wrong_pkt2;                                                     
	int matched_pkt0, matched_pkt1, matched_pkt2;   

    function new(string name, uvm_component parent);
        super.new(name, parent);
        yapp_fifo = new("yapp_fifo", this);
        chan0_fifo = new("chan0_fifo", this);
        chan1_fifo = new("chan1_fifo", this);
        chan2_fifo = new("chan2_fifo", this);
        hbus_fifo = new("hbus_fifo", this);
    endfunction : new

    function bit comp_equal (input yapp_packet yp, input channel_packet cp);
        // returns first mismatch only
        if (yp.addr != cp.addr) begin
            `uvm_error("PKT_COMPARE",$sformatf("Address mismatch YAPP %0d Chan %0d",yp.addr,cp.addr))
            return(0);
        end
        if (yp.length != cp.length) begin
            `uvm_error("PKT_COMPARE",$sformatf("Length mismatch YAPP %0d Chan %0d",yp.length,cp.length))
            return(0);
        end
        foreach (yp.payload [i])
            if (yp.payload[i] != cp.payload[i]) begin
            `uvm_error("PKT_COMPARE",$sformatf("Payload[%0d] mismatch YAPP %0d Chan %0d",i,yp.payload[i],cp.payload[i]))
            return(0);
            end
        if (yp.parity != cp.parity) begin
            `uvm_error("PKT_COMPARE",$sformatf("Parity mismatch YAPP %0d Chan %0d",yp.parity,cp.parity))
            return(0);
        end
        return(1);
    endfunction

    function custom_com(input yapp_packet yp, channel_packet cp, uvm_comparer comparer = null);
        if (comparer == null)
            comparer = new();

        custom_com = comparer.compare_field("addr", yp.addr, cp.addr, 2);
        custom_com &= comparer.compare_field("length", yp.length, cp.length, 6);

        foreach (yp.payload[i]) begin
            custom_com &= comparer.compare_field("payload" , yp.payload[i], cp.payload[i], 8);
        end
            custom_com &= comparer.compare_field("parity", yp.parity, cp.parity, 1);

    endfunction
    
    task run_phase(uvm_phase phase);
     yapp_packet yp;
     channel_packet cp;
     fork
          forever begin
               yapp_fifo.get_peek_export.get(yp);
               
               if(router_en && yp.length <= maxpktsize && yp.addr < 3) begin
                    if(yp.addr == 0) begin
                         packets_received0++;
                         chan0_fifo.get_peek_export.get(cp);
                         
                         if (custom_com(yp, cp)) begin
                              matched_pkt0++;
                         end
                         
                         else begin
                              wrong_pkt0++;
                              `uvm_info("Channel 0", "Packet Received Wrong", UVM_LOW)
                         end
                    end
                    
                    else if(yp.addr == 1) begin
                         packets_received1++;
                         chan1_fifo.get_peek_export.get(cp);
                         
                         if (custom_com(yp, cp)) begin
                              matched_pkt1++;
                         end
                         
                         else begin
                              wrong_pkt1++;
                              `uvm_info("Channel 0", "Packet Received Wrong", UVM_LOW)
                         end
                    end
                    
                    else if(yp.addr == 2) begin
                         packets_received2++;
                         chan0_fifo.get_peek_export.get(cp);
                         
                         if (custom_com(yp, cp)) begin
                              matched_pkt2++;
                         end
                         
                         else begin
                              wrong_pkt2++;
                              `uvm_info("Channel 0", "Packet Received Wrong", UVM_LOW)
                         end
                    end
                    
                    else begin
                     `uvm_info("Router Scoreboard", "Invalid Address", UVM_LOW)
                    end

               end
               else begin
                     if (router_en == 0) begin
                         
                         `uvm_info("Writing Yapp", "Router is not enabled", UVM_HIGH)
                     end
                     `uvm_info("ROUTER_REF", "Invalid packet dropped", UVM_LOW);
                     `uvm_info("Reference Model", $sformatf("Maximum packet size is %0d and received packet size is %0d", maxpktsize, yp.length), UVM_LOW)
               end
          end
          
               forever begin
                 hbus_transaction packet;
                 hbus_fifo.get(packet);
                 if (packet.haddr == 16'h1000 && packet.hwr_rd == HBUS_WRITE)
                     maxpktsize = packet.hdata;
                 if (packet.haddr == 16'h1001 && packet.hwr_rd == HBUS_WRITE)
                     router_en = packet.hdata;
                 `uvm_info("Write HBUS", $sformatf("router_en = %0d and received packet size is %0d", router_en, maxpktsize), UVM_LOW)
               end
               
        join
     
    endtask

    function void check_phase(uvm_phase phase);
          if(!yapp_fifo.is_empty() || !chan0_fifo.is_empty() || !chan1_fifo.is_empty() || !chan2_fifo.is_empty()) begin
               `uvm_warning("Scoreboard", "Some FIFOs are not empty at check_phase.")
          end
    endfunction
     
    function void report_phase(uvm_phase phase);
        super.report_phase(phase);
        
        `uvm_info(get_type_name(), "===== ROUTER SCOREBOARD REPORT =====", UVM_LOW)
        `uvm_info("", $sformatf("Total Packets Received (Channel 0): %0d", packets_received0), UVM_LOW)
        `uvm_info("", $sformatf("Total Packets Received (Channel 1): %0d", packets_received1), UVM_LOW)
        `uvm_info("", $sformatf("Total Packets Received (Channel 2): %0d", packets_received2), UVM_LOW)
        `uvm_info("", $sformatf("Total Packets Matched (Channel 0) : %0d", matched_pkt0), UVM_LOW)
        `uvm_info("", $sformatf("Total Packets Matched (Channel 1) : %0d", matched_pkt1), UVM_LOW)
        `uvm_info("", $sformatf("Total Packets Matched (Channel 2) : %0d", matched_pkt2), UVM_LOW)
        `uvm_info("", $sformatf("Total Packets Mismatched (Channel 0): %0d", wrong_pkt0), UVM_LOW)
        `uvm_info("", $sformatf("Total Packets Mismatched (Channel 1): %0d", wrong_pkt1), UVM_LOW)
        `uvm_info("", $sformatf("Total Packets Mismatched (Channel 2): %0d", wrong_pkt2), UVM_LOW)
      
    endfunction    

endclass : router_sb
