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
        // uvm_config_wrapper::set(this, "env.uvc.agent.sequencer.run_phase",
        //                          "default_sequence",
        //                          yapp_5_packets::get_type());
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

class simple_mcseq_test extends base_test;
    `uvm_component_utils(simple_mcseq_test)
    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction : new

    virtual function void build_phase(uvm_phase phase);
        set_type_override_by_type(yapp_packet::get_type(), short_packet::get_type());
        
        super.build_phase(phase);

        uvm_config_wrapper::set(this, "env.chan?.rx_agent.sequencer.run_phase",
                                "default_sequence",
                                channel_rx_resp_seq::get_type());

        uvm_config_wrapper::set(this, "env.clkrst.agent.sequencer.run_phase",
                                "default_sequence", 
                                clk10_rst5_seq::get_type());

        uvm_config_wrapper::set(this, "env.mcseqr.run_phase",
                                "default_sequence", 
                                router_simple_mcseq::get_type());

    endfunction
endclass : simple_mcseq_test

class  uvm_reset_test extends base_test;

    uvm_reg_hw_reset_seq reset_seq;

  // component macro
  `uvm_component_utils(uvm_reset_test)

  // component constructor
  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction : new

  function void build_phase(uvm_phase phase);
      uvm_reg::include_coverage("*", UVM_NO_COVERAGE);
      reset_seq = uvm_reg_hw_reset_seq::type_id::create("uvm_reset_seq");
      uvm_config_wrapper::set(this, "env.chan?.rx_agent.sequencer.run_phase",
                                "default_sequence",
                                channel_rx_resp_seq::get_type());

      uvm_config_wrapper::set(this, "env.clkrst.agent.sequencer.run_phase",
                                "default_sequence", 
                                clk10_rst5_seq::get_type());
      super.build_phase(phase);
      
  endfunction : build_phase

  virtual task run_phase (uvm_phase phase);
     phase.raise_objection(this, "Raising Objection to run uvm built in reset test");
     // Set the model property of the sequence to our Register Model instance
     // Update the RHS of this assignment to match your instance names. Syntax is:
     //  <testbench instance>.<register model instance>
     reset_seq.model = env.yapp_rm;
     // Execute the sequence (sequencer is already set in the testbench)
     reset_seq.start(null);
     phase.drop_objection(this," Dropping Objection to uvm built reset test finished");
     
     
  endtask

endclass : uvm_reset_test

class  uvm_mem_walk_test extends base_test;

    uvm_mem_walk_seq mem_seq;

  // component macro
  `uvm_component_utils(uvm_mem_walk_test)

  // component constructor
  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction : new

  function void build_phase(uvm_phase phase);
      uvm_reg::include_coverage("*", UVM_NO_COVERAGE);
      mem_seq = uvm_mem_walk_seq::type_id::create("mem_seq");
      uvm_config_wrapper::set(this, "env.chan?.rx_agent.sequencer.run_phase",
                                "default_sequence",
                                channel_rx_resp_seq::get_type());

      uvm_config_wrapper::set(this, "env.clkrst.agent.sequencer.run_phase",
                                "default_sequence", 
                                clk10_rst5_seq::get_type());
      super.build_phase(phase);
      
  endfunction : build_phase

  virtual task run_phase (uvm_phase phase);
     phase.raise_objection(this, "Raising Objection to run uvm built in reset test");
     // Set the model property of the sequence to our Register Model instance
     // Update the RHS of this assignment to match your instance names. Syntax is:
     //  <testbench instance>.<register model instance>
     mem_seq.model = env.yapp_rm;
     // Execute the sequence (sequencer is already set in the testbench)
     mem_seq.start(null);
     phase.drop_objection(this," Dropping Objection to uvm built reset test finished");
     
     
  endtask

endclass : uvm_mem_walk_test

class reg_access_test extends base_test;
    yapp_regs_c reg_c;
    int rdata;
    uvm_status_e status;

    `uvm_component_utils(reg_access_test)

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction : new

    function void build_phase(uvm_phase phase);
        uvm_reg::include_coverage("*", UVM_NO_COVERAGE);
        reg_c = yapp_regs_c::type_id::create("reg_c");
        // uvm_config_wrapper::set(this, "env.chan?.rx_agent.sequencer.run_phase",
        //                             "default_sequence",
        //                             channel_rx_resp_seq::get_type());

        uvm_config_wrapper::set(this, "env.clkrst.agent.sequencer.run_phase",
                                    "default_sequence", 
                                    clk10_rst5_seq::get_type());
        super.build_phase(phase);
      
    endfunction : build_phase

    function void connect_phase(uvm_phase phase);
        reg_c = env.yapp_rm.router_yapp_regs;
    endfunction
    uvm_objection obj;
    virtual task run_phase (uvm_phase phase);
        phase.raise_objection(this, "Raising Objection to run uvm built in reset test");
        // Set the model property of the sequence to our Register Model instance
        // Update the RHS of this assignment to match your instance names. Syntax is:
        //  <testbench instance>.<register model instance>
        //mem_seq.model = env.yapp_rm;
        // Execute the sequence (sequencer is already set in the testbench)
        //mem_seq.start(null);
        obj=phase.get_objection();
        `uvm_info(get_type_name(), "Starting Run Phase of Register Model", UVM_NONE)
        reg_c.ctrl_reg.write(status, 8'h20);
        reg_c.ctrl_reg.peek(status, rdata);
        A0: assert(rdata == 8'h20)
            $display("RW Register Check Passed");
        else begin
            $error("Register failed RW Register Check!");
        end
        reg_c.ctrl_reg.poke(status, 8'h30);
        reg_c.ctrl_reg.read(status, rdata);
        
        A1: assert(rdata == 8'h30)
            $display("RW Register Check Passed");
        else begin
            $error("Register failed RW Register Check!");
        end
        `uvm_info(get_type_name(), $sformatf("rdata=%0h", rdata), UVM_NONE)
        obj.set_drain_time(this, 200ns);
        
        reg_c.addr1_cnt_reg.poke(status, 8'h5A);
        reg_c.addr1_cnt_reg.read(status, rdata);

        A2: assert(rdata == 8'h5A)
        else begin
             $error("Register failed RO Register Check!");
        end
        reg_c.addr1_cnt_reg.write(status, 8'hA5);
        reg_c.addr1_cnt_reg.peek(status, rdata);

        `uvm_info(get_type_name(), $sformatf("rdata=%0h", rdata), UVM_NONE)

        A3: assert(rdata == 8'h5A)
             $display("RO Register Check Passed");
         else begin
             $error("Register failed RO Register Check!");
         end
        phase.drop_objection(this," Dropping Objection to uvm built reset test finished"); 
    endtask

endclass : reg_access_test

class reg_function_test extends base_test;
    yapp_regs_c reg_c;
    int rdata, rdata0, rdata1, rdata2, rdata3;
    uvm_status_e status;
    yapp_sequencer yp_seqr;
    yapp_012_seq seq_012;

    `uvm_component_utils(reg_function_test)

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction : new

    function void build_phase(uvm_phase phase);
        uvm_reg::include_coverage("*", UVM_NO_COVERAGE);
        reg_c = yapp_regs_c::type_id::create("reg_c");
        uvm_config_wrapper::set(this, "env.chan?.rx_agent.sequencer.run_phase",
                                    "default_sequence",
                                    channel_rx_resp_seq::get_type());

        uvm_config_wrapper::set(this, "env.clkrst.agent.sequencer.run_phase",
                                    "default_sequence", 
                                    clk10_rst5_seq::get_type());

        
        super.build_phase(phase);
        seq_012 = yapp_012_seq::type_id::create("seq_012");
      
    endfunction : build_phase

    function void connect_phase(uvm_phase phase);
        reg_c = env.yapp_rm.router_yapp_regs;
        yp_seqr = env.uvc.agent.sequencer;
    endfunction
    uvm_objection obj;
    virtual task run_phase (uvm_phase phase);
        
        phase.raise_objection(this, "Raising Objection to run uvm built in reset test");
        // Set the model property of the sequence to our Register Model instance
        // Update the RHS of this assignment to match your instance names. Syntax is:
        //  <testbench instance>.<register model instance>
        //mem_seq.model = env.yapp_rm;
        // Execute the sequence (sequencer is already set in the testbench)
        //mem_seq.start(null);
        env.yapp_rm.default_map.set_check_on_read(1);
        obj=phase.get_objection();
        `uvm_info(get_type_name(), "Starting Run Phase of Register Model", UVM_NONE)
        
        //reg_c.en_reg.write(status, 8'h01);
        //reg_c.en_reg.read(status, rdata);
        
        reg_c.en_reg.predict(8'h01);
        rdata = reg_c.en_reg.get_mirrored_value();


        A0: assert(rdata == 8'h01)
            $display("Router En Check Passed");
        else begin
            $error("Register failed Router En Check!");
        end

        seq_012.start(yp_seqr);

        // reg_c.addr0_cnt_reg.read(status, rdata0);
        // reg_c.addr1_cnt_reg.read(status, rdata1);
        // reg_c.addr2_cnt_reg.read(status, rdata2);
        // reg_c.addr3_cnt_reg.read(status, rdata3);

        reg_c.addr0_cnt_reg.predict(8'h00);
        reg_c.addr1_cnt_reg.predict(8'h00);
        reg_c.addr2_cnt_reg.predict(8'h00);
        reg_c.addr3_cnt_reg.predict(8'h00);

        rdata0 = reg_c.addr0_cnt_reg.get_mirrored_value();
        rdata1 = reg_c.addr1_cnt_reg.get_mirrored_value();
        rdata2 = reg_c.addr2_cnt_reg.get_mirrored_value();
        rdata3 = reg_c.addr3_cnt_reg.get_mirrored_value();
        
        A1: assert((rdata0 == 8'h00) && (rdata1 == 8'h00) && (rdata2 == 8'h00) && (rdata3 == 8'h00))
            $display("Addr Registers NOT Incremented Check Passed");
        else begin
            $error("Register failed Addr Registers NOT Incremented Check!");
        end

        // reg_c.en_reg.write(status, 8'hf7);
        // reg_c.en_reg.read(status, rdata);

        reg_c.en_reg.predict(8'hf7);
        rdata = reg_c.en_reg.get_mirrored_value();

        A2: assert(rdata == 8'hf7)
            $display("ALL Router En Check Passed");
        else begin
            $error("Register failed ALL Router En Check!");
        end

        repeat(2) begin
            seq_012.start(yp_seqr);
        end

        reg_c.addr0_cnt_reg.read(status, rdata0);
        reg_c.addr1_cnt_reg.read(status, rdata1);
        reg_c.addr2_cnt_reg.read(status, rdata2);
        reg_c.addr3_cnt_reg.read(status, rdata3);

        reg_c.addr0_cnt_reg.predict(8'h02);
        reg_c.addr1_cnt_reg.predict(8'h02);
        reg_c.addr2_cnt_reg.predict(8'h02);
        reg_c.addr3_cnt_reg.predict(8'h00);
        
        rdata0 = reg_c.addr0_cnt_reg.get_mirrored_value();
        rdata1 = reg_c.addr1_cnt_reg.get_mirrored_value();
        rdata2 = reg_c.addr2_cnt_reg.get_mirrored_value();
        rdata3 = reg_c.addr3_cnt_reg.get_mirrored_value();

        A3: assert((rdata0 == 8'h02) && (rdata1 == 8'h02) && (rdata2 == 8'h02) && (rdata3 == 8'h00))
            $display("Addr Registers Incremented Check Passed");
        else begin
            $error("Register failed Addr Registers Incremented Check!");
        end


        `uvm_info(get_type_name(), $sformatf("rdata=%0h", rdata), UVM_NONE)
        obj.set_drain_time(this, 200ns);
        
        phase.drop_objection(this," Dropping Objection to uvm built reset test finished"); 
    endtask

endclass : reg_function_test

/* ---------------------------------INTROSPECT TEST------------------------------------*/

class reg_introspect_test extends base_test;
    yapp_regs_c reg_c;
    int rdata, rdata0, rdata1, rdata2, rdata3;
    uvm_status_e status;
    yapp_sequencer yp_seqr;
    yapp_012_seq seq_012;
    uvm_reg qreg[$], rwregs[$], roregs[$];

    `uvm_component_utils(reg_introspect_test)

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction : new

    function void build_phase(uvm_phase phase);
        uvm_reg::include_coverage("*", UVM_NO_COVERAGE);
        reg_c = yapp_regs_c::type_id::create("reg_c");
        uvm_config_wrapper::set(this, "env.chan?.rx_agent.sequencer.run_phase",
                                    "default_sequence",
                                    channel_rx_resp_seq::get_type());

        uvm_config_wrapper::set(this, "env.clkrst.agent.sequencer.run_phase",
                                    "default_sequence", 
                                    clk10_rst5_seq::get_type());

        
        super.build_phase(phase);
        seq_012 = yapp_012_seq::type_id::create("seq_012");
      
    endfunction : build_phase

    function void connect_phase(uvm_phase phase);
        reg_c = env.yapp_rm.router_yapp_regs;
        yp_seqr = env.uvc.agent.sequencer;
    endfunction

    uvm_objection obj;
    virtual task run_phase (uvm_phase phase);
        
        phase.raise_objection(this, "Raising Objection to run uvm built in reset test");

        reg_c.get_registers(qreg);

        foreach (qreg[i]) begin
            if(qreg[i].get_rights() == "RO")
                roregs.push_back(qreg[i]);             
        end

        rwregs = qreg.find(i) with (i.get_rights() == "RW");

        foreach(rwregs[i]) begin
            if(rwregs[i] == null) begin
                `uvm_error("REG_DEBUG", $sformatf("RW reg %0d is null", i))
                continue;
            end
            `uvm_info("REG_DEBUG_RW", $sformatf("RW Register: %0d, Name: %s" , i, rwregs[i].get_name()), UVM_LOW)
        end

        foreach(roregs[i]) begin
            if(roregs[i] == null) begin
                `uvm_error("REG_DEBUG", $sformatf("RO reg %0d is null", i))
                continue;
            end
            `uvm_info("REG_DEBUG_RO", $sformatf("RO Register: %0d, Name: %s" , i, roregs[i].get_name()), UVM_LOW)
        end
        
        phase.drop_objection(this," Dropping Objection to uvm built reset test finished"); 
    endtask

endclass : reg_introspect_test

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

