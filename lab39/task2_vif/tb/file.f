// 64 bit option for AWS labs
-64

-uvmhome /home/cc/mnt/XCELIUM2309/tools/methodology/UVM/CDNS-1.1d


// include directories
//*** add incdir include directories here
-incdir ../sv 


// set default timescale
-timescale 1ns/1ns


// compile files
//*** add compile files here
// ../sv/yapp_pkg.sv 

../sv/yapp_pkg.sv
../sv/yapp_if.sv
../router_rtl/yapp_router.sv
clkgen.sv
hw_top.sv
tb_top.sv 

//+UVM_TESTNAME=test2
+UVM_TESTNAME=connect_test
+UVM_VERBOSITY=UVM_FULL
//+SVSEED=random