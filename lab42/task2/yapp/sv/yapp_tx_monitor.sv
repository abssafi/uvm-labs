class yapp_monitor extends uvm_monitor;
    `uvm_component_utils(yapp_monitor)
    virtual interface yapp_if vif;
    yapp_packet pkt;
    int num_pkt_col;

    uvm_analysis_port #(yapp_packet) yapp_collected_port;

    function new(string name, uvm_component parent);
        super.new(name, parent);
        yapp_collected_port = new("yapp_collected_port", this);
    endfunction : new

    virtual task run_phase(uvm_phase phase);
        `uvm_info(get_type_name(), $sformatf("Executing Monitor Run Phase!"), UVM_LOW)
        @(posedge vif.reset)
        @(negedge vif.reset)
        `uvm_info(get_type_name(), "Detected Reset Done", UVM_MEDIUM)
        forever begin 
        
        pkt = yapp_packet::type_id::create("pkt", this);

        fork
            vif.collect_packet(pkt.length, pkt.addr, pkt.payload, pkt.parity);
            @(posedge vif.monstart) void'(begin_tr(pkt, "Monitor_YAPP_Packet"));
        join

        pkt.parity_type = (pkt.parity == pkt.calc_parity()) ? GOOD_PARITY : BAD_PARITY;
        
        end_tr(pkt);
        `uvm_info(get_type_name(), $sformatf("Packet Collected :\n%s", pkt.sprint()), UVM_LOW)
        yapp_collected_port.write(pkt);
        num_pkt_col++;
        end 
    endtask

    virtual function void connect_phase(uvm_phase phase);
        if (!yapp_vif_config::get(this,"","vif", vif))
            `uvm_error("NOVIF","vif not set")
    endfunction

    function void start_of_simulation_phase(uvm_phase phase);
        super.start_of_simulation_phase(phase);
        `uvm_info(get_type_name(), "Running Simulation Monitor!", UVM_HIGH)
    endfunction

    function void report_phase(uvm_phase phase);
        `uvm_info(get_type_name(), $sformatf("Report: YAPP Monitor Collected %0d Packets", num_pkt_col), UVM_LOW)
    endfunction : report_phase
endclass : yapp_monitor