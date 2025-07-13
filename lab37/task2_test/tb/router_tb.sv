class yapp_env extends uvm_env;
    `uvm_component_utils(yapp_env)

    function new(string name = "yapp_env", uvm_component parent=null);
        super.new(name, parent);
    endfunction : new

    virtual function void build_phase (uvm_phase phase);
        super.build_phase(phase);
        `uvm_info(get_type_name(), $sformatf ("[Enviornment] BUILD PHASE EXECUTING!"), UVM_HIGH)
    endfunction : build_phase

endclass : yapp_env