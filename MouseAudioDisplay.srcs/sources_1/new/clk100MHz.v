`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/01/2023 09:52:30 AM
// Design Name: 
// Module Name: clk100MHz
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


module clk100MHz(input basys_clock, output reg my_clk = 0);
    reg[31:0] count = 0;
    always @ (posedge basys_clock)
    begin 
        count <= (count == 1) ? 0 : count + 1;
        my_clk <= (count == 0) ? ~my_clk : my_clk;
    end
    
endmodule

