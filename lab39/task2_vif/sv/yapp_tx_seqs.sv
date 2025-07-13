class yapp_base_seq extends uvm_sequence #(yapp_packet);
  
  // Required macro for sequences automation
  `uvm_object_utils(yapp_base_seq)

  // Constructor
  function new(string name="yapp_base_seq");
    super.new(name);
  endfunction

  task pre_body();
    uvm_phase phase;
    `ifdef UVM_VERSION_1_2
      // in UVM1.2, get starting phase from method
      phase = get_starting_phase();
    `else
      phase = starting_phase;
    `endif
    if (phase != null) begin
      phase.raise_objection(this, get_type_name());
      `uvm_info(get_type_name(), "raise objection", UVM_MEDIUM)
    end
  endtask : pre_body

  task post_body();
    uvm_phase phase;
    `ifdef UVM_VERSION_1_2
      // in UVM1.2, get starting phase from method
      phase = get_starting_phase();
    `else
      phase = starting_phase;
    `endif
    if (phase != null) begin
      phase.drop_objection(this, get_type_name());
      `uvm_info(get_type_name(), "drop objection", UVM_MEDIUM)
    end
  endtask : post_body

endclass : yapp_base_seq

//------------------------------------------------------------------------------
//
// SEQUENCE: yapp_5_packets
//
//  Configuration setting for this sequence
//    - update <path> to be hierarchial path to sequencer 
//
//  uvm_config_wrapper::set(this, "uvm_test_top.env.uvc.agent.sequencer.run_phase",
//                                 "default_sequence",
//                                 yapp_5_packets::get_type());

//uvm_test_top.env.uvc.agent.sequencer
//------------------------------------------------------------------------------
class yapp_5_packets extends yapp_base_seq;
  
  // Required macro for sequences automation
  `uvm_object_utils(yapp_5_packets)

  // Constructor
  function new(string name="yapp_5_packets");
    super.new(name);
  endfunction

  // Sequence body definition
  virtual task body();
    `uvm_info(get_type_name(), "Executing yapp_5_packets sequence", UVM_LOW)
     repeat(5)
      `uvm_do(req)
  endtask
  
endclass : yapp_5_packets

class yapp_1_seq extends yapp_base_seq;
  `uvm_object_utils(yapp_1_seq)

  function new(string name ="yapp_1_seq");
    super.new(name);   
  endfunction : new

  virtual task body();
    `uvm_info(get_type_name(), "Executing yapp_1_seq sequence", UVM_LOW)
    `uvm_do_with(req, {req.addr == 1;})
  endtask : body
endclass : yapp_1_seq

class yapp_012_seq extends yapp_base_seq;
  `uvm_object_utils(yapp_012_seq)
  short_packet sreq;
  int ok;
  function new(string name="yapp_012_seq");
    super.new(name);
  endfunction : new

  virtual task body();
    `uvm_info(get_type_name(), "Executing yapp_012_seq sequence", UVM_LOW)
    `uvm_do_with(req, {req.addr == 0;})
    `uvm_do_with(req, {req.addr == 1;})
    //`uvm_do_with(req, {req.addr == 2;})
    `uvm_create(sreq)
      sreq.addr_limit.constraint_mode(0);
      ok = sreq.randomize() with {sreq.addr == 2;};
    `uvm_send(sreq)
  endtask : body
endclass : yapp_012_seq

class yapp_111_seq extends yapp_base_seq;
  `uvm_object_utils(yapp_111_seq)
  yapp_1_seq yp1;
  
  function new(string name = "yapp_111_seq");
    super.new(name);
  endfunction : new

  virtual task body();
    `uvm_info(get_type_name(), "Executing yapp_111_seq sequence", UVM_LOW)
    repeat(3) begin
      `uvm_do(yp1)
    end
  endtask : body
endclass : yapp_111_seq

class yapp_repeat_addr_seq extends yapp_base_seq;
  `uvm_object_utils(yapp_repeat_addr_seq)
  short_packet sreq;

  function new(string name = "yapp_repeat_addr_seq");
    super.new(name);
  endfunction : new

  rand bit [1:0] seqaddr;
  int ok;
  constraint valid_addr { seqaddr != 3; }

  virtual task body();
    `uvm_info(get_type_name(), "Executing yapp_repeat_addr_seq sequence", UVM_LOW)
    `uvm_create(sreq)
      sreq.addr_limit.constraint_mode(0);
      ok = sreq.randomize() with {sreq.addr == seqaddr;};
    `uvm_send(sreq)

    `uvm_create(sreq)
      sreq.addr_limit.constraint_mode(0);
      ok = sreq.randomize() with {sreq.addr == seqaddr;};
    `uvm_send(sreq)
  
    //`uvm_do_with(req, {req.addr == seqaddr;})
    //`uvm_do_with(req, {req.addr == seqaddr;})
  endtask : body
endclass : yapp_repeat_addr_seq

class yapp_incr_payload_seq extends yapp_base_seq;
  int ok;
  `uvm_object_utils(yapp_incr_payload_seq)

  function new(string name = "yapp_incr_payload_seq");
    super.new(name);
  endfunction : new

  virtual task body();
    `uvm_info(get_type_name(), "Executing yapp_incr_payload_seq sequence", UVM_LOW)   
    `uvm_create(req)
    ok = req.randomize();

    for(int i=0; i < req.length; i++) begin
      req.payload[i] = i;
    end

    req.set_parity();
    `uvm_send(req);
  endtask : body
endclass : yapp_incr_payload_seq

class yapp_rnd_seq extends yapp_base_seq;
  `uvm_object_utils(yapp_rnd_seq)

  rand int count;
  constraint count_limit {count inside {[1:10]};}

  function new(string name = "yapp_rnd_seq");
    super.new(name);
  endfunction : new

  virtual task body();
    `uvm_info(get_type_name(), "Executing yapp_rnd_seq sequence.", UVM_LOW)
    `uvm_info("", $psprintf("count=%0d .....", count), UVM_LOW)
    repeat(count) begin
      `uvm_do(req)
    end
  endtask
endclass : yapp_rnd_seq

class six_yapp_seq extends yapp_base_seq;
  `uvm_object_utils(six_yapp_seq)
  yapp_rnd_seq ypseq;

  function new(string name = "six_yapp_seq");
    super.new(name);
  endfunction : new

  virtual task body();
    `uvm_info(get_type_name(), "Executing six_yapp_seq sequence.", UVM_LOW)
    `uvm_do_with(ypseq, {count == 6;}) 
    `uvm_info("", $psprintf("count=%0d .....", ypseq.count), UVM_LOW)
  endtask

endclass : six_yapp_seq

class yapp_exhaustive_seq extends yapp_base_seq;
  `uvm_object_utils(yapp_exhaustive_seq)

  yapp_1_seq seq1;
  yapp_012_seq seq2;
  yapp_111_seq seq3;
  yapp_repeat_addr_seq seq4;
  yapp_incr_payload_seq seq5;
  yapp_rnd_seq seq6;
  six_yapp_seq seq7;

  function new(string name = "yapp_exhaustive_seq");
    super.new(name);
  endfunction : new

  virtual task body();
    `uvm_do(seq1)
    `uvm_do(seq2)
    `uvm_do(seq3)
    `uvm_do(seq4)
    `uvm_do(seq5)
    `uvm_do(seq6)
    `uvm_do(seq7)
  endtask : body

endclass : yapp_exhaustive_seq

