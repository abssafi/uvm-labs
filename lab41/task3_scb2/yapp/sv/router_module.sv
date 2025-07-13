package router_module;
	import uvm_pkg::*;                                             

	// include the UVM macros
	`include "uvm_macros.svh"                                                         

	// import the YAPP package                                                                          
	import yapp_pkg::*;                                                                     
	import hbus_pkg::*;                                         
	import channel_pkg::*;                                                                             
	import clock_and_reset_pkg::*; 
	
	
	`include "../sv/router_reference.sv"
	`include "../sv/router_scoreboard.sv"
	`include "../sv/router_module_env.sv"


endpackage: router_module