class yapp_sequencer extends uvm_sequencer #(yapp_packet);
    `uvm_component_utils(yapp_sequencer)

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction : new

    function void start_of_simulation_phase(uvm_phase phase);
        super.start_of_simulation_phase(phase);
        `uvm_info(get_type_name(), "Running Simulation Sequencer!", UVM_HIGH)
    endfunction
    
endclass : yapp_sequencer 