`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/01/2023 12:01:11 PM
// Design Name: 
// Module Name: tb_top_student
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


module tb_top_student(

    );

        wire basys_clk;
        wire  J_MIC3_Pin1;
        wire  J_MIC3_Pin3;
        wire  J_MIC3_Pin4; 
        wire  [11:0]led;
        
        wire clk20khz;
        wire clk100Mhz;
        wire clk10hz;                      
        reg [11:0]mic_in = 12'b000000001010;
        wire [11:0]mic_out = 12'b111111111111;
        
        Top_Student dut(
             basys_clk,
             sw,
             J_MIC3_Pin1,   
            J_MIC3_Pin3,   
             J_MIC3_Pin4,    
             ]led
            );
endmodule
