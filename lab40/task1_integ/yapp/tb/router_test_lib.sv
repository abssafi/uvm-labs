class base_test extends uvm_test;
    `uvm_component_utils(base_test)

    router_tb env;

    function new(string name = "base_test", uvm_component parent);
        super.new(name, parent);
    endfunction : new

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        uvm_config_int::set( this, "*", "recording_detail", 1); 
        `uvm_info(get_type_name(), $sformatf ("[BASE TEST] BUILD PHASE EXECUTING!"), UVM_HIGH)   
        uvm_config_wrapper::set(this, "env.uvc.agent.sequencer.run_phase",
                                 "default_sequence",
                                 yapp_5_packets::get_type());
        env = router_tb::type_id::create("env", this);  
        
    endfunction : build_phase

    task run_phase(uvm_phase phase);
        uvm_objection obj = phase.get_objection();
        obj.set_drain_time(this, 200ns);
    endtask

    function void end_of_elaboration_phase(uvm_phase phase);
        uvm_top.print_topology();
    endfunction : end_of_elaboration_phase

    function void start_of_simulation_phase(uvm_phase phase);
        super.start_of_simulation_phase(phase);
        `uvm_info(get_type_name(), "Running Simulation Base Test!", UVM_HIGH)
    endfunction

    function void check_phase(uvm_phase phase);
        check_config_usage();
    endfunction

endclass : base_test

class simple_test extends base_test;
    `uvm_component_utils(simple_test)

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction : new

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        uvm_config_wrapper::set(this, "env.uvc.agent.sequencer.run_phase",
                                "default_sequence",
                                yapp_012_seq::get_type());
        uvm_config_wrapper::set(this, "env.chan?.rx_agent.sequencer.run_phase",
                                "default_sequence",
                                 channel_rx_resp_seq::get_type());

        uvm_config_wrapper::set(this, "env.clkrst.agent.sequencer.run_phase",
                                "default_sequence", 
                                clk10_rst5_seq::get_type());

        set_type_override_by_type(yapp_packet::get_type(), short_packet::get_type());
    
    endfunction : build_phase
endclass : simple_test


class test_uvc_integration extends base_test;
    `uvm_component_utils(test_uvc_integration)

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction : new

    virtual function void build_phase(uvm_phase phase);
        set_type_override_by_type(yapp_packet::get_type(), short_packet::get_type());
        super.build_phase(phase);
        uvm_config_wrapper::set(this, "env.uvc.agent.sequencer.run_phase",
                                "default_sequence",
                                yapp_4_channel_seq::get_type());
        uvm_config_wrapper::set(this, "env.chan?.rx_agent.sequencer.run_phase",
                                "default_sequence",
                                channel_rx_resp_seq::get_type());

        uvm_config_wrapper::set(this, "env.clkrst.agent.sequencer.run_phase",
                                "default_sequence", 
                                clk10_rst5_seq::get_type());

        uvm_config_wrapper::set(this, "env.hbus.masters[0].sequencer.run_phase",
                                "default_sequence", 
                                hbus_small_packet_seq::get_type());

    endfunction : build_phase
endclass : test_uvc_integration

/*
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

class short_packet_test extends base_test;
    `uvm_component_utils(short_packet_test)
    
    function new(string name = "short_packet_test", uvm_component parent);
        super.new(name, parent);
    endfunction : new
    
    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        set_type_override_by_type(yapp_packet::get_type(), short_packet::get_type());
    endfunction

endclass : short_packet_test

class set_config_test extends base_test;
    `uvm_component_utils(set_config_test)
        
    function new(string name = "set_config_test", uvm_component parent);
        super.new(name, parent);
    endfunction : new

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        uvm_config_int::set(this, "env.uvc.agent", "is_active", UVM_PASSIVE);
    endfunction

endclass : set_config_test

class incr_payload_test extends base_test;
    `uvm_component_utils(incr_payload_test)

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction : new

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        uvm_config_wrapper::set(this, "env.uvc.agent.sequencer.run_phase",
                                 "default_sequence",
                                 yapp_incr_payload_seq::get_type());
        set_type_override_by_type(yapp_packet::get_type(), short_packet::get_type());
    endfunction : build_phase
endclass : incr_payload_test

class exhaustive_seq_test extends base_test;
    `uvm_component_utils(exhaustive_seq_test)

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction : new

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        uvm_config_wrapper::set(this, "env.uvc.agent.sequencer.run_phase",
                            "default_sequence", yapp_exhaustive_seq::get_type());
        set_type_override_by_type(yapp_packet::get_type(), short_packet::get_type());
    endfunction : build_phase
endclass : exhaustive_seq_test 

class connect_test extends base_test;
    `uvm_component_utils(connect_test)

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction : new

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        uvm_config_wrapper::set(this, "env.uvc.agent.sequencer.run_phase",
                                 "default_sequence",
                                 yapp_012_seq::get_type());

    endfunction : build_phase

   
endclass : connect_test
 */

