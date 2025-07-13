module top;
// import the UVM library

// include the UVM macros
 import uvm_pkg::*;
 `include "uvm_macros.svh"
 import yapp_pkg::*;
 import clock_and_reset_pkg::*;
 import hbus_pkg::*;
 import channel_pkg::*;
 
 `include "router_mcsequencer.sv"
 `include "router_mcseqs_lib.sv"
 `include "router_scoreboard.sv"
 `include "router_tb.sv"
 `include "router_test_lib.sv"
 

// // import the package


 hw_top hardware();
 
initial begin
    yapp_vif_config::set(null, "*.env.uvc.agent.*", "vif", hardware.in0);
    
    channel_vif_config::set(null, "*.env.chan0.*", "vif", hardware.chan0_in);
    channel_vif_config::set(null, "*.env.chan1.*", "vif", hardware.chan1_in);
    channel_vif_config::set(null, "*.env.chan2.*", "vif", hardware.chan2_in);
    
    hbus_vif_config::set(null, "*.env.hbus.*", "vif", hardware.hbus_in0);
    
    clock_and_reset_vif_config::set(null, "*.env.clkrst.*", "vif", hardware.clk_rst_inst);
    
    run_test ("");
end

endmodule : top
