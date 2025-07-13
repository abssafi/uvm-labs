module top;
// import the UVM library

// include the UVM macros
 import uvm_pkg::*;
 `include "uvm_macros.svh"
// // import the YAPP package
 import yapp_pkg::*;
// generate 5 random packets and use the print method
// to display the results

yapp_packet y1, y2, y3;
int ok;

initial begin
    $display("Generating 5 random packets"); 
    for(int i=0; i < 5; i++) begin
        y1 = new($sformatf("Packet-%0d", i));
        ok = y1.randomize();
        y1.print();
    end

    $display("\nTesting COPY Method!");
    y2 = new("y2");
    y2.copy(y1);
    $display("\nPrinting table!");
    y2.print(uvm_default_table_printer);
    $display("\nPrinting tree!");
    y2.print(uvm_default_tree_printer);
    $display("\nPrinting line!");
    y2.print(uvm_default_line_printer);

    $display("\nTesting CLONE Method!");
    $cast(y3, y1.clone());
    y3.print();

    $display("\nTesting COMPARE Method!");
    A1: assert(y2.compare(y3))
    $warning("SUCCESS! Y1 and Y2 are equal!");
    else begin
        $warning("WARNING! Value not equal!");
    end
end

// experiment with the copy, clone and compare UVM method
endmodule : top
