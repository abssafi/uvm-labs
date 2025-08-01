 import uvm_pkg::*;
 `include "uvm_macros.svh"
 import yapp_pkg::*;
 import clock_and_reset_pkg::*;
 import hbus_pkg::*;
 import channel_pkg::*;

class router_tb extends uvm_env;
    `uvm_component_utils(router_tb)

    yapp_env uvc;
    channel_env chan0, chan1, chan2;
    hbus_env hbus;
    clock_and_reset_env clkrst;
    router_mcsequencer mcseqr;
    router_sb sb;

    router_module_env router_env;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction : new

    virtual function void build_phase (uvm_phase phase);
        super.build_phase(phase);
        `uvm_info(get_type_name(), $sformatf ("[Router TB] BUILD PHASE EXECUTING!"), UVM_HIGH)
        uvc = yapp_env::type_id::create("uvc", this);

        uvm_config_int::set(this, "chan0", "channel_id", 0);
        uvm_config_int::set(this, "chan1", "channel_id", 1);
        uvm_config_int::set(this, "chan2", "channel_id", 2);

        chan0 = channel_env::type_id::create("chan0", this);
        chan1 = channel_env::type_id::create("chan1", this);
        chan2 = channel_env::type_id::create("chan2", this);

        uvm_config_int::set(this, "hbus", "num_masters", 1);
        uvm_config_int::set(this, "hbus", "num_slaves", 0);

        hbus = hbus_env::type_id::create("hbus", this);

        clkrst = clock_and_reset_env::type_id::create("clkrst", this);

        mcseqr = router_mcsequencer::type_id::create("mcseqr", this);

        sb = router_sb::type_id::create("sb", this);
        router_env = router_module_env::type_id::create("router_env", this);
 
    
    endfunction : build_phase

    virtual function void connect_phase (uvm_phase phase);
        mcseqr.hbus_seqr = hbus.masters[0].sequencer;
        mcseqr.yapp_seqr = uvc.agent.sequencer;
        uvc.agent.monitor.yapp_collected_port.connect(router_env.yapp_exp);
        chan0.rx_agent.monitor.item_collected_port.connect(router_env.chan0_exp);
        chan1.rx_agent.monitor.item_collected_port.connect(router_env.chan1_exp);
        chan2.rx_agent.monitor.item_collected_port.connect(router_env.chan2_exp);
    endfunction

    function void start_of_simulation_phase(uvm_phase phase);
        super.start_of_simulation_phase(phase);
        `uvm_info(get_type_name(), "Running Simulation Router Tb!", UVM_HIGH)
    endfunction

endclass : router_tb