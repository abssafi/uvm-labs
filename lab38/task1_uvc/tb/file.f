// 64 bit option for AWS labs
-64

-uvmhome /home/cc/mnt/XCELIUM2309/tools/methodology/UVM/CDNS-1.1d


// include directories
//*** add incdir include directories here
-incdir ../sv 


// compile files
//*** add compile files here
// ../sv/yapp_pkg.sv 
../sv/yapp_pkg.sv
top.sv 

//+UVM_TESTNAME=test2
+UVM_TESTNAME=base_test
+UVM_VERBOSITY=UVM_HIGH
+SVSEED=random