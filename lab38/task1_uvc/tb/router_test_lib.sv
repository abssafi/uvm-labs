class base_test extends uvm_test;
    `uvm_component_utils(base_test)

    router_tb env;

    function new(string name = "base_test", uvm_component parent);
        super.new(name, parent);
    endfunction : new

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        `uvm_info(get_type_name(), $sformatf ("[BASE TEST] BUILD PHASE EXECUTING!"), UVM_HIGH)   
        uvm_config_wrapper::set(this, "env.uvc.agent.sequencer.run_phase",
                                 "default_sequence",
                                 yapp_5_packets::get_type());
        env = new("env", this);   
    endfunction : build_phase

    function void end_of_elaboration_phase(uvm_phase phase);
        uvm_top.print_topology();
    endfunction : end_of_elaboration_phase

    function void start_of_simulation_phase(uvm_phase phase);
        super.start_of_simulation_phase(phase);
        `uvm_info(get_type_name(), "Running Simulation Base Test!", UVM_HIGH)
    endfunction

endclass : base_test

class test2 extends base_test;
    `uvm_component_utils(test2)

    function new(string name = "test2", uvm_component parent);
        super.new(name, parent);
    endfunction : new

    function void start_of_simulation_phase(uvm_phase phase);
        super.start_of_simulation_phase(phase);
        `uvm_info(get_type_name(), "Running Simulation Test2!", UVM_HIGH)
    endfunction
    
endclass : test2