`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/01/2023 10:41:29 AM
// Design Name: 
// Module Name: clk10Hz
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


module clk10Hz(input basys_clock,output reg my_clk = 0);
    //10hz clock
    reg [31:0] count = 0;
    
    always @ (posedge basys_clock)
        begin
            count <= (count == 4999999) ? 0 : count + 1;
            my_clk <= (count == 0) ? ~my_clk : my_clk;
        end
    
endmodule
