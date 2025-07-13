 import uvm_pkg::*;
 `include "uvm_macros.svh"
 import yapp_pkg::*;
class router_tb extends uvm_env;
    `uvm_component_utils(router_tb)

    yapp_env uvc;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction : new

    virtual function void build_phase (uvm_phase phase);
        super.build_phase(phase);
        `uvm_info(get_type_name(), $sformatf ("[Router TB] BUILD PHASE EXECUTING!"), UVM_HIGH)
        uvc = new("uvc", this);
    endfunction : build_phase

    function void start_of_simulation_phase(uvm_phase phase);
        super.start_of_simulation_phase(phase);
        `uvm_info(get_type_name(), "Running Simulation Router Tb!", UVM_HIGH)
    endfunction

endclass : router_tb