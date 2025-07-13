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

    uvm_analysis_imp_yapp #(yapp_packet, router_sb) yapp_in;    
    uvm_analysis_imp_chan0 #(channel_packet, router_sb) chan0_in;
    uvm_analysis_imp_chan1 #(channel_packet, router_sb) chan1_in;
    uvm_analysis_imp_chan2 #(channel_packet, router_sb) chan2_in;
    
    yapp_packet queue0[$];
    yapp_packet queue1[$];
    yapp_packet queue2[$];

    int received_in, dropped_in, matched_pkt0, wrong_pkt0, matched_pkt1, wrong_pkt1, matched_pkt2, wrong_pkt2;


    function new(string name, uvm_component parent);
        super.new(name, parent);
        yapp_in = new("yapp_in", this);
        chan0_in = new("chan0_in", this);
        chan1_in = new("chan1_in", this);
        chan2_in = new("chan2_in", this);
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


    function void write_yapp(input yapp_packet pkt);
        automatic yapp_packet yapp_pkt;

        $cast(yapp_pkt , pkt.clone());
        //received_packets++;
        case(yapp_pkt.addr)
            2'b00: begin    
                queue0.push_back(yapp_pkt);
                `uvm_info(get_type_name(), "Added to Queue 0", UVM_HIGH)
            end
            2'b01: begin    
                queue1.push_back(yapp_pkt);
                `uvm_info(get_type_name(), "Added to Queue 1", UVM_HIGH)
            end
            2'b10: begin    
                queue2.push_back(yapp_pkt);
                `uvm_info(get_type_name(), "Added to Queue 2", UVM_HIGH)
            end
            default: begin
                `uvm_info(get_type_name(), "Packet dropped due to illegal address", UVM_HIGH)
            end
        endcase

    endfunction : write_yapp

    function void write_chan0(input channel_packet cp);
        yapp_packet yp;
        bit compare;

        if(cp.addr == 2'b00) begin
            yp = queue0.pop_front();
            received_in++;

            if (comparer_policy == UVM) begin
                compare = custom_com(yp, cp);
            end 
            
            else begin
                compare = comp_equal(yp, cp);
            end

            if(compare)
                matched_pkt0++;

            else begin
                `uvm_error(get_type_name(), "Channel 0: No expected packet to compare!")
                wrong_pkt0++;
            end
        end 
        
        else
            `uvm_error(get_type_name(), $sformatf("Scoreboard Error: Channel 0 received UNEXPECTED packet: \n%s", cp.sprint()))


        /*received_packets++;
        if(sb_queue0.size() == 0) begin
            `uvm_error(get_type_name(), "Channel 0: No expected packet to compare!")
            wrong_packets++;
            return;
        end
        y_packet = sb_queue0.pop_front();
        if(comp_equal(packet , y_packet)) begin
            matching_packets++;
        end 
        else begin
            `uvm_error(get_type_name(), $sformatf("Scoreboard Error: Channel 0 received UNEXPECTED packet: \n%s", packet.sprint()))
            wrong_packets++;
        end */

    endfunction : write_chan0

    function void write_chan1(input channel_packet cp);
        yapp_packet yp; 
        bit compare;

        if(cp.addr == 2'b01) begin
            yp = queue1.pop_front();
            received_in++;

            if (comparer_policy == UVM) begin
                compare = custom_com(yp, cp);
            end 
            
            else begin
                compare = comp_equal(yp, cp);
            end

            if(compare)
                matched_pkt1++;

            else begin
                `uvm_error(get_type_name(), "Channel 1: No expected packet to compare!")
                wrong_pkt1++;
            end
        end 
        
        else
            `uvm_error(get_type_name(), $sformatf("Scoreboard Error: Channel 1 received UNEXPECTED packet: \n%s", cp.sprint()))
    endfunction : write_chan1

    function void write_chan2(input channel_packet cp);
        yapp_packet yp;
        bit compare;

        if(cp.addr == 2'b10) begin
            yp = queue2.pop_front();
            received_in++;

            if (comparer_policy == UVM) begin
                compare = custom_com(yp, cp);
            end 
            
            else begin
                compare = comp_equal(yp, cp);
            end

            if(compare)
                matched_pkt2++;

            else begin
                `uvm_error(get_type_name(), "Channel 2: No expected packet to compare!")
                wrong_pkt2++;
            end
        end 
        
        else
            `uvm_error(get_type_name(), $sformatf("Scoreboard Error: Channel 2 received UNEXPECTED packet: \n%s", cp.sprint()))
    endfunction : write_chan2

    function void report_phase(uvm_phase phase);
        super.report_phase(phase);
        
        `uvm_info(get_type_name(), "===== ROUTER SCOREBOARD REPORT =====", UVM_LOW)
        `uvm_info("", $sformatf("Total Packets Received : %0d", received_in), UVM_LOW)
        `uvm_info("", $sformatf("Total Packets Matched (Channel 0) : %0d", matched_pkt0), UVM_LOW)
        `uvm_info("", $sformatf("Total Packets Matched (Channel 1) : %0d", matched_pkt1), UVM_LOW)
        `uvm_info("", $sformatf("Total Packets Matched (Channel 2) : %0d", matched_pkt2), UVM_LOW)
        `uvm_info("", $sformatf("Total Packets Mismatched (Channel 0): %0d", wrong_pkt0), UVM_LOW)
        `uvm_info("", $sformatf("Total Packets Mismatched (Channel 1): %0d", wrong_pkt1), UVM_LOW)
        `uvm_info("", $sformatf("Total Packets Mismatched (Channel 2): %0d", wrong_pkt2), UVM_LOW)
        `uvm_info("", $sformatf("Queue 0 Left: %0d | Queue 1 Left: %0d | Queue 2 Left: %0d", 
        queue0.size(), queue1.size(), queue2.size()), UVM_LOW)
    endfunction    

endclass : router_sb