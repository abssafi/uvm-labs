class router_simple_mcseq extends uvm_sequence;
    `uvm_object_utils(router_simple_mcseq)
    `uvm_declare_p_sequencer(router_mcsequencer)

    hbus_small_packet_seq h_small;
    hbus_read_max_pkt_seq h_read_max;
    hbus_set_default_regs_seq h_large;

    six_yapp_seq ysix_seq;
    yapp_012_seq yapp_012;
    function new(string name = "router_simple_mcseq");
        super.new(name);
    endfunction :new

    virtual task pre_body();
        if(starting_phase != null)
            starting_phase.raise_objection(this, get_type_name());

    endtask
    virtual task body();
        `uvm_do_on(h_small, p_sequencer.hbus_seqr)
        `uvm_do_on(h_read_max, p_sequencer.hbus_seqr)
        repeat(2) begin
            `uvm_do_on(yapp_012, p_sequencer.yapp_seqr)
        end
        //`uvm_do_on(h_large, p_sequencer.hbus_seqr)
        //`uvm_do_on(h_read_max, p_sequencer.hbus_seqr)
        `uvm_do_on(ysix_seq, p_sequencer.yapp_seqr)

    endtask : body

    virtual task post_body();
        if(starting_phase != null)
            starting_phase.drop_objection(this, get_type_name());
    endtask
endclass : router_simple_mcseq