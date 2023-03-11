`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11.03.2023 16:24:38
// Design Name: 
// Module Name: clk6p25MHz
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


module clk6p25MHz(input basys_clock,output reg my_clk = 0);
    reg[3:0] COUNT = 4'b0000; // basys 100Mhz / 6.25Mhz = 16
    always @ (posedge basys_clock)
    begin 
        if (COUNT == 4'b1111) begin
        COUNT <= 0;
        my_clk = (my_clk == 1'b0) ? 1'b1 : 1'b0;
        end
        else begin
            COUNT = COUNT + 1;
        end
    end
   
endmodule
