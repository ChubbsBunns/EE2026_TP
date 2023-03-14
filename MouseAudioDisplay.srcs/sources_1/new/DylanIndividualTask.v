`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/14/2023 10:18:22 AM
// Design Name: 
// Module Name: DylanIndividualTask
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


module DylanIndividualTask(

        input basys_clk,
        input switchedOn,
        input [3:0]my_sequence,
        output reg [3:0] led
    );
    
    always @ (posedge basys_clk) begin
    if (switchedOn == 1)
    begin
        case(my_sequence)
        4'b0000:
            begin
                led <= 4'b0100;
            end
        4'b0001:
            begin
                led <= 4'b1010;
            end
            
        endcase
    end
    else 
    begin
    end
    end
    
    
  
    
endmodule
