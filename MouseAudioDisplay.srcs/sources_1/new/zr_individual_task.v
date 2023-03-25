`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 25.03.2023 18:21:59
// Design Name: 
// Module Name: zr_individual_task
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


module zr_individual_task(
    input basys_clk,
output [7:0] JC,
input [15:0] sw
);

reg clk6p25m = 1'b0; //clk
//reset = 0
wire frame_begin; 
wire sending_pixels;
wire sample_pixel;
wire [12:0] pixel_index;
reg [15:0] oled_data = 16'h0000; //pixel data
//output [7:0] JC

reg [3:0] COUNT = 4'b0000;
always @ (posedge basys_clk) 
begin    
    if (COUNT == 4'b1111) begin
        COUNT <= 0;
        clk6p25m = ~clk6p25m;
    end
    else begin
        COUNT = COUNT + 1;
    end
    
    if (sw[11] && 
            pixel_index % 13'd96 <= 13'd58 && 
            pixel_index / 13'd96 >= 13'd57 && pixel_index / 13'd96 <= 13'd59 
            ) begin //hori
        oled_data = 16'h07E0; 
    end else
    if (sw[10] && 
            pixel_index / 13'd96 <= 13'd59 && 
            pixel_index % 13'd96 >= 13'd56 && pixel_index % 13'd96 <= 13'd58                
            ) begin //vert
        oled_data = 16'h07E0;
    end else
    if (sw[6:4] == 3'b100 && ( // sw6, b
            // A 
            (pixel_index % 13'd96 >= 13'd18 && pixel_index % 13'd96 <= 13'd40 && //x axis 
            pixel_index / 13'd96 >= 13'd8 && pixel_index / 13'd96 <= 13'd12) // y axis
            || // F
            (pixel_index % 13'd96 >= 13'd17 && pixel_index % 13'd96 <= 13'd21 &&  // x axis
            pixel_index / 13'd96 >= 13'd8 && pixel_index / 13'd96 <= 13'd32) // y axis
//                || // B
//                (pixel_index % 13'd96 >= 13'd36 && pixel_index % 13'd96 <= 13'd40 &&  // x axis
//                pixel_index / 13'd96 >= 13'd10 && pixel_index / 13'd96 <= 13'd34) // y axis
            || // G
            (pixel_index % 13'd96 >= 13'd18 && pixel_index % 13'd96 <= 13'd37 && //x axis 
            pixel_index / 13'd96 >= 13'd28 && pixel_index / 13'd96 <= 13'd32) // y axis
            || // E
            (pixel_index % 13'd96 >= 13'd17 && pixel_index % 13'd96 <= 13'd21 &&  // x axis
            pixel_index / 13'd96 >= 13'd28 && pixel_index / 13'd96 <= 13'd52) // y axis
            || // C
            (pixel_index % 13'd96 >= 13'd36 && pixel_index % 13'd96 <= 13'd40 &&  // x axis
            pixel_index / 13'd96 >= 13'd28 && pixel_index / 13'd96 <= 13'd52) // y axis            
            || // D
            (pixel_index % 13'd96 >= 13'd18 && pixel_index % 13'd96 <= 13'd39 && //x axis 
            pixel_index / 13'd96 >= 13'd48 && pixel_index / 13'd96 <= 13'd52) // y axis
           )) begin //hori
       oled_data = 16'hFFFF; 
   end else
   if (sw[6:4] == 3'b010 && ( // sw5, b,e
            // A 
            (pixel_index % 13'd96 >= 13'd18 && pixel_index % 13'd96 <= 13'd40 && //x axis 
            pixel_index / 13'd96 >= 13'd8 && pixel_index / 13'd96 <= 13'd12) // y axis
            || // F
            (pixel_index % 13'd96 >= 13'd17 && pixel_index % 13'd96 <= 13'd21 &&  // x axis
            pixel_index / 13'd96 >= 13'd8 && pixel_index / 13'd96 <= 13'd32) // y axis
//                || // B
//                (pixel_index % 13'd96 >= 13'd36 && pixel_index % 13'd96 <= 13'd40 &&  // x axis
//                pixel_index / 13'd96 >= 13'd8 && pixel_index / 13'd96 <= 13'd32) // y axis
            || // G
            (pixel_index % 13'd96 >= 13'd18 && pixel_index % 13'd96 <= 13'd37 && //x axis 
            pixel_index / 13'd96 >= 13'd28 && pixel_index / 13'd96 <= 13'd32) // y axis
//                || // E
//                (pixel_index % 13'd96 >= 13'd17 && pixel_index % 13'd96 <= 13'd21 &&  // x axis
//                pixel_index / 13'd96 >= 13'd28 && pixel_index / 13'd96 <= 13'd52) // y axis
            || // C
            (pixel_index % 13'd96 >= 13'd36 && pixel_index % 13'd96 <= 13'd40 &&  // x axis
            pixel_index / 13'd96 >= 13'd28 && pixel_index / 13'd96 <= 13'd52) // y axis            
            || // D
            (pixel_index % 13'd96 >= 13'd18 && pixel_index % 13'd96 <= 13'd39 && //x axis 
            pixel_index / 13'd96 >= 13'd48 && pixel_index / 13'd96 <= 13'd52) // y axis
            )) begin //hori
        oled_data = 16'hFFFF;
     end else
    if (sw[6:4] == 3'b001 && ( // sw4, a,e,d
//                // A 
//                (pixel_index % 13'd96 >= 13'd18 && pixel_index % 13'd96 <= 13'd40 && //x axis 
//                pixel_index / 13'd96 >= 13'd8 && pixel_index / 13'd96 <= 13'd12) // y axis
//                || // F
            (pixel_index % 13'd96 >= 13'd17 && pixel_index % 13'd96 <= 13'd21 &&  // x axis
            pixel_index / 13'd96 >= 13'd8 && pixel_index / 13'd96 <= 13'd32) // y axis
            || // B
            (pixel_index % 13'd96 >= 13'd36 && pixel_index % 13'd96 <= 13'd40 &&  // x axis
            pixel_index / 13'd96 >= 13'd8 && pixel_index / 13'd96 <= 13'd32) // y axis
            || // G
            (pixel_index % 13'd96 >= 13'd18 && pixel_index % 13'd96 <= 13'd37 && //x axis 
            pixel_index / 13'd96 >= 13'd28 && pixel_index / 13'd96 <= 13'd32) // y axis
//                || // E
//                (pixel_index % 13'd96 >= 13'd17 && pixel_index % 13'd96 <= 13'd21 &&  // x axis
//                pixel_index / 13'd96 >= 13'd28 && pixel_index / 13'd96 <= 13'd52) // y axis
            || // C
            (pixel_index % 13'd96 >= 13'd36 && pixel_index % 13'd96 <= 13'd40 &&  // x axis
            pixel_index / 13'd96 >= 13'd28 && pixel_index / 13'd96 <= 13'd52) // y axis            
//                || // D
//                (pixel_index % 13'd96 >= 13'd18 && pixel_index % 13'd96 <= 13'd39 && //x axis 
//                pixel_index / 13'd96 >= 13'd48 && pixel_index / 13'd96 <= 13'd52) // y axis
            )) begin //hori
        oled_data = 16'hFFFF;
    end 
    else begin 
        // 0 as default, g
        if ( (sw[6:4] != 3'b100 && sw[6:4] != 3'b010 && sw[6:4] != 3'b001) && (
            // A 
        (pixel_index % 13'd96 >= 13'd18 && pixel_index % 13'd96 <= 13'd39 && //x axis 
        pixel_index / 13'd96 >= 13'd8 && pixel_index / 13'd96 <= 13'd12) // y axis
        || // F
        (pixel_index % 13'd96 >= 13'd17 && pixel_index % 13'd96 <= 13'd21 &&  // x axis
        pixel_index / 13'd96 >= 13'd8 && pixel_index / 13'd96 <= 13'd32) // y axis
        || // B
        (pixel_index % 13'd96 >= 13'd36 && pixel_index % 13'd96 <= 13'd40 &&  // x axis
        pixel_index / 13'd96 >= 13'd8 && pixel_index / 13'd96 <= 13'd32) // y axis
//            || // G
//            (pixel_index % 13'd96 >= 13'd18 && pixel_index % 13'd96 <= 13'd37 && //x axis 
//            pixel_index / 13'd96 >= 13'd17 && pixel_index / 13'd96 <= 13'd32) // y axis
        || // E
        (pixel_index % 13'd96 >= 13'd17 && pixel_index % 13'd96 <= 13'd21 &&  // x axis
        pixel_index / 13'd96 >= 13'd28 && pixel_index / 13'd96 <= 13'd52) // y axis
        || // C
        (pixel_index % 13'd96 >= 13'd36 && pixel_index % 13'd96 <= 13'd40 &&  // x axis
        pixel_index / 13'd96 >= 13'd28 && pixel_index / 13'd96 <= 13'd52) // y axis            
        || // D
        (pixel_index % 13'd96 >= 13'd18 && pixel_index % 13'd96 <= 13'd39 && //x axis 
        pixel_index / 13'd96 >= 13'd48 && pixel_index / 13'd96 <= 13'd52) // y axis
            )) begin //hori
                oled_data = 16'hFFFF;
        end else begin
            oled_data = 16'h0000;
        end
    end

end

//    parameter ClkFreq = 6250000; // Hz
//    input clk, reset;
//    output frame_begin, sending_pixels, sample_pixel;
//    output [PixelCountWidth-1:0] pixel_index;
//    input [15:0] pixel_data;
//    output cs, sdin, sclk, d_cn, resn, vccen, pmoden;

Oled_Display func (clk6p25m, 0, frame_begin, sending_pixels, 
            sample_pixel, pixel_index, oled_data, JC[0], 
            JC[1], JC[3], JC[4], JC[5], JC[6], JC[7]);
        

endmodule