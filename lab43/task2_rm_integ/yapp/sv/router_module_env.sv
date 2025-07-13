class router_module_env extends uvm_component;
	`uvm_component_utils(router_module_env)

	uvm_analysis_export #(yapp_packet) yapp_exp;
	uvm_analysis_export #(hbus_transaction) hbus_exp;
	uvm_analysis_export #(channel_packet)chan0_exp;
	uvm_analysis_export #(channel_packet)chan1_exp;
	uvm_analysis_export #(channel_packet)chan2_exp;	

	router_sb scoreboard;
	router_reference reference;

	function new(string name = "router_module_env", uvm_component parent);
		super.new(name, parent);
		yapp_exp = new("yapp_exp",this);
        hbus_exp = new("hbus_exp",this);
        chan0_exp = new("chan0_exp",this);
        chan1_exp = new("chan1_exp",this);
        chan2_exp = new("chan2_exp",this);
	endfunction
	
	function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		scoreboard = router_sb::type_id::create("scoreboard", this);
		reference = router_reference::type_id::create("reference", this);
	endfunction
	
	function void connect_phase(uvm_phase phase);		
		yapp_exp.connect(scoreboard.yapp_fifo.analysis_export);
        hbus_exp.connect(scoreboard.hbus_fifo.analysis_export);
        chan0_exp.connect(scoreboard.chan0_fifo.analysis_export);
        chan1_exp.connect(scoreboard.chan1_fifo.analysis_export);
        chan2_exp.connect(scoreboard.chan2_fifo.analysis_export);
	endfunction
endclass
