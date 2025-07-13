module top;
// import the UVM library

// include the UVM macros
 import uvm_pkg::*;
 `include "uvm_macros.svh"
 `include "router_tb.sv"
 `include "router_test_lib.sv"

// // import the YAPP package
 import yapp_pkg::*;
// generate 5 random packets and use the print method
// to display the results

initial begin
    run_test ("base_test");
end

// experiment with the copy, clone and compare UVM method
endmodule : top
