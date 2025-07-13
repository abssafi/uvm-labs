class yapp_monitor extends uvm_monitor;
    `uvm_component_utils(yapp_monitor)

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction : new

    virtual task run_phase(uvm_phase phase);
        `uvm_info(get_type_name(), $sformatf("Executing Monitor Run Phase!"), UVM_LOW)
    endtask

    function void start_of_simulation_phase(uvm_phase phase);
        super.start_of_simulation_phase(phase);
        `uvm_info(get_type_name(), "Running Simulation Monitor!", UVM_HIGH)
    endfunction
endclass : yapp_monitor