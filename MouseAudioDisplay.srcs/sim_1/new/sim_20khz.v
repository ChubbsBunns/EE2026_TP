`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/01/2023 10:58:32 AM
// Design Name: 
// Module Name: sim_20khz
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module sim_20khz();
    reg clk;
    wire test_clk;
    
    clk20k dut(clk, test_clk);
    
    initial begin
            //test_CLOCK = 6'b0000000;
            //test_CLOCK = 3'd0;
            clk = 0;
                  
        end
        
        always //throughout the simulation, always do something 
        begin
            #5 clk = ~clk;
        end
    
endmodule
