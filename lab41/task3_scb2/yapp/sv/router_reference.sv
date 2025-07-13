class router_reference extends uvm_component;
    `uvm_component_utils(router_reference)
    `uvm_analysis_imp_decl(_yapp)
    `uvm_analysis_imp_decl(_hbus)

    uvm_analysis_imp_yapp #(yapp_packet, router_reference) yapp_in;    
    uvm_analysis_imp_hbus #(hbus_transaction, router_reference) hbus_in;
    uvm_analysis_port #(yapp_packet) yapp_out;

    bit [7:0] maxpktsize;
	bit router_en;
	int invalid_packet_count;
	int dropped_pkt;
	int valid_pkt;
    
    function new(string name, uvm_component parent);
        super.new(name, parent);
        yapp_in = new("yapp_in", this);
        hbus_in = new("hbus_in", this);
        yapp_out = new("yapp_out", this);
    endfunction : new

    function void write_hbus (input hbus_transaction hb);
        hbus_transaction packet;
        $cast(packet, hb.clone());
        if (packet.haddr == 16'h1000 && packet.hwr_rd == HBUS_WRITE)
            maxpktsize = packet.hdata;
        if (packet.haddr == 16'h1001 && packet.hwr_rd == HBUS_WRITE)
            router_en = packet.hdata;
        `uvm_info("Write HBUS", $sformatf("router_en = %0d and received packet size is %0d", router_en, maxpktsize), UVM_LOW)
    endfunction

    function void write_yapp(input yapp_packet trans);
		yapp_packet packet;
		$cast(packet, trans.clone());

		if (router_en && packet.length <= maxpktsize && (packet.addr < 3)) begin
		    yapp_out.write(packet);  
		    valid_pkt++;
		end else begin
		    invalid_packet_count++;
		    if (router_en == 0) begin
		    	
		    	`uvm_info("Writing Yapp", "Router is not enabled", UVM_HIGH)
		    end
		    `uvm_info("ROUTER_REF", "Invalid packet dropped", UVM_LOW);
		    `uvm_info("Reference Model", $sformatf("Maximum packet size is %0d and received packet size is %0d", maxpktsize, packet.length), UVM_LOW)
		end
	endfunction

	function void report_phase(uvm_phase phase);
		super.report_phase(phase);
		`uvm_info(get_type_name(), $sformatf("Router Reference Report: Valid Packets = %0d and Invalid Packets = %0d", valid_pkt, invalid_packet_count), UVM_LOW)
	endfunction

endclass : router_reference