// Define your enumerated type(s) here

typedef enum bit {GOOD_PARITY, BAD_PARITY  } parity_type_e;

class yapp_packet extends uvm_sequence_item;

// Follow the lab instructions to create the packet.
// Place the packet declarations in the following order:
  
  // Define protocol data
  rand bit [1:0] addr;
  rand bit [5:0] length;
  rand bit [7:0] payload [];
       bit [7:0] parity;

  // Define control knobs
  rand parity_type_e parity_type;
  rand int packet_delay;

  // Enable automation of the packet's fields

  `uvm_object_utils_begin(yapp_packet)
    `uvm_field_int(addr, UVM_ALL_ON)
    `uvm_field_int(length, UVM_ALL_ON)
    `uvm_field_array_int(payload, UVM_ALL_ON)
    `uvm_field_int(parity, UVM_ALL_ON + UVM_BIN)
    `uvm_field_enum(parity_type_e, parity_type, UVM_ALL_ON)
    `uvm_field_int(packet_delay, UVM_ALL_ON + UVM_NOCOMPARE )
  `uvm_object_utils_end

  // Define packet constraints
  constraint addr_limits { addr != 3; }
  constraint length_limits { length inside {[1:63]}; }
  constraint payload_limits { payload.size() == length; }
  constraint parity_dist { parity_type dist { GOOD_PARITY:=5, BAD_PARITY:=1}; }
  constraint pkt_delay { packet_delay inside {[1:20]}; }


  // Add methods for parity calculation and class construction

  function new(string name = "yapp_packet");
    super.new(name);
  endfunction : new

  function bit [7:0] calc_parity();
    parity = { length, addr };
    foreach ( payload[i] )
      parity = parity ^ payload[i];
    return parity;
    
  endfunction : calc_parity

  function void set_parity();
    if (parity_type == GOOD_PARITY) begin
      parity = calc_parity();
    end

    else if (parity_type == BAD_PARITY) begin
      parity = ~parity;
    end
    
  endfunction : set_parity

  function post_randomize();
    set_parity();
  endfunction : post_randomize


endclass: yapp_packet

class short_packet extends yapp_packet;
    `uvm_object_utils(short_packet)
    function new(string name = "short_packet");
        super.new(name);
    endfunction : new

    constraint short_len { length < 15; }
    constraint addr_limit { addr != 2; }
endclass : short_packet 
