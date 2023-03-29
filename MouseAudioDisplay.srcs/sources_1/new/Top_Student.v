`timescale 1ns / 1ps

//////////////////////////////////////////////////////////////////////////////////
//
//  FILL IN THE FOLLOWING INFORMATION:
//  STUDENT A NAME: 
//  STUDENT B NAME:
//  STUDENT C NAME: 
//  STUDENT D NAME:  
//
//////////////////////////////////////////////////////////////////////////////////


module Top_Student (
    input basys_clk,
    input [15:0] sw,
    output J_MIC3_Pin1,   
    input  J_MIC3_Pin3,   
    output J_MIC3_Pin4,    
    output [3:0] JA, // 

    output [15:0] led,
    output reg [3:0] an = 4'b0000,
   
    output [7:0] JC,

    input btnC,
    input btnU,
    input btnL,
    input btnR,
    input btnD,
    
    inout ps2_clk,
    inout ps2_data
 );
 
     wire zr_task_on;
     assign zr_task_on = sw[0];
        
 //start of OLED display + mouse parts
     reg rst = 0;
     reg [11:0] value = 12'b0;
     reg setx = 0;
     reg sety = 0;
     reg setmax_x = 0;
     reg setmax_y = 0;
     wire [11:0] xpos;
     reg [11:0] xaxis = 12'b0;
     wire [11:0] ypos;
     reg [11:0] yaxis = 12'b0;
     wire [3:0] zpos;
     wire left;
     wire middle;
     wire right;
     wire new_event;
      reg [6:0] oledSeg = 7'b1111111;
//     reg [6:0] oledSeg = 7'b1111111;
 
     reg clk6p25m = 1'b0; //clk
     //reset = 0
     wire frame_begin;
     wire sending_pixels;
     wire sample_pixel;
     wire [12:0] pixel_index;
     reg [15:0] oled_data = 16'hFFFF; //pixel data
//     output [7:0] JC
     reg [3:0] COUNT = 4'b0000;
     reg A_empty;
     reg A_fill;
     reg B_empty;
     reg B_fill;
     reg C_empty;
     reg C_fill;
     reg D_empty;
     reg D_fill;
     reg E_empty;
     reg E_fill;
     reg F_empty;
     reg F_fill;
     reg G_empty;
     reg G_fill;
     reg cursor;
     
     //output value: 0 is off, 1 is on, the positions indicate the digit shown.
     reg [9:0] digit = 10'd0;
     reg [9:0] lastDigit = 10'd0; // stores the last known value of digit before clockedge. Used to check for changes in digit
     assign led[15] = (digit  == 10'd0) ? 1'b0 : 1'b1;
   //  assign led[14] = (beepState == 0) ? 1'b0 : 1'b1;
//     reg validDigit;
//     assign ledValid = (validDigit) ? 1'b0 : 1'b1;
 
     MouseCtl u1(basys_clk, rst, xpos, ypos, zpos, left, middle, right, new_event, value, setx, sety, setmax_x, setmax_y,
     ps2_clk, ps2_data);
 
     Oled_Display func (clk6p25m, 0, frame_begin, sending_pixels, sample_pixel, pixel_index, oled_data, JC[0],
     JC[1], JC[3], JC[4], JC[5], JC[6], JC[7]);
     
     
     
     
     // >>>> beep start
     reg [25:0] clk50Mcount = 0; //
                 reg clk50M = 0;  //
                 reg [25:0] clk20kcount = 0; // 
                 reg clk20k = 0;   
     reg [11:0] audio_out = 12'b000000000000;
     reg [31:0] beepCount = 0;
     reg beepState = 0;
     reg [31:0]clk380count = 0;
     reg clk380 = 0;
     
   
     
     reg [31:0] beepCountMax = (digit == 10'b0000000001) ? 10000000 : // 0.1 second for value of 0
                                                           (digit == 10'b0000000010) ? 20000000 : // 0.2 second for value of 1
                                                           (digit == 10'b0000000100) ? 30000000 : // 0.3 second
                                                           (digit == 10'b0000001000) ? 40000000 : // 0.4 second
                                                           (digit == 10'b0000010000) ? 50000000 : // 0.5 second
                                                           (digit == 10'b0000100000) ? 60000000 : // 0.6 second
                                                           (digit == 10'b0001000000) ? 70000000 : // 0.7 second
                                                           (digit == 10'b0010000000) ? 80000000 : // 0.8 second
                                                           (digit == 10'b0100000000) ? 90000000 : // 0.9 second
                                                           (digit == 10'b1000000000) ? 90000000 : // 1.0 second
                                                           0; // Default value of 0 second
     
     // << beep end
     
    

     always @(posedge basys_clk) begin
     
    
 
         if (COUNT == 4'b1111) begin
             COUNT <= 0;
             clk6p25m = ~clk6p25m;
         end
         else begin
             COUNT = COUNT + 1;
         end
         
         
     
         
 
         xaxis = xpos;
         yaxis = ypos;
 
         if (xpos >= 12'd95) begin
             xaxis = 12'd94;
         end
         if (ypos >= 12'd64) begin
             yaxis = 12'd63;
         end
         if (xpos <= 12'd0) begin
             xaxis = 12'd1;
         end
         if (ypos <= 12'd0) begin
             yaxis = 12'd1;
         end
         
         
         //mouse movement: Jared's individual task
    //     if (middle) begin
    //         if (pixel_index % 13'd96 >= xaxis - 13'd1 && pixel_index % 13'd96 <= xaxis + 13'd1 && //x axis
    //         pixel_index / 13'd96 >= yaxis - 13'd1 && pixel_index / 13'd96 <= yaxis + 13'd1) begin //yaxis
    //             oled_data =  16'h07E0;
    //         end else begin
    //             oled_data = 16'h0000;
    //         end
    //     end else begin
    //         if (pixel_index % 13'd96 >= xaxis && pixel_index % 13'd96 <= xaxis && //x axis
    //         pixel_index / 13'd96 >= yaxis && pixel_index / 13'd96 <= yaxis) begin //yaxis
    //             oled_data =  16'hFFFF;
    //         end else begin
    //             oled_data = 16'h0000;
    //         end
    //     end
        if (zr_task_on == 1'b0) begin
             if (left) begin
                if (xaxis >= 13'd18 && xaxis <= 13'd40 && yaxis >= 13'd8 && yaxis <= 13'd12) begin //A
                    oledSeg[0] = 0;
                end else if (xaxis >= 13'd18 && xaxis <= 13'd22 && yaxis >= 13'd8 && yaxis <= 13'd32) begin //F
                    oledSeg[5] = 0;
                end else if (xaxis >= 13'd36 && xaxis <= 13'd40 && yaxis >= 13'd8 && yaxis <= 13'd32) begin //B
                    oledSeg[1] = 0;
                end else if (xaxis >= 13'd18 && xaxis <= 13'd40 && yaxis >= 13'd28 && yaxis <= 13'd32) begin //G
                    oledSeg[6] = 0;
                end else if (xaxis >= 13'd18 && xaxis <= 13'd22 && yaxis >= 13'd28 && yaxis <= 13'd52) begin //E
                    oledSeg[4] = 0;
                end else if (xaxis >= 13'd36 && xaxis <= 13'd40 && yaxis >= 13'd28 && yaxis <= 13'd52) begin //C
                    oledSeg[2] = 0;
                end else if (xaxis >= 13'd18 && xaxis <= 13'd40 && yaxis >= 13'd48 && yaxis <= 13'd52) begin //D
                    oledSeg[3] = 0;
                end
            end else if (right) begin
                if (xaxis >= 13'd18 && xaxis <= 13'd40 && yaxis >= 13'd8 && yaxis <= 13'd12) begin //A
                    oledSeg[0] = 1;
                end else if (xaxis >= 13'd18 && xaxis <= 13'd22 && yaxis >= 13'd8 && yaxis <= 13'd32) begin //F
                    oledSeg[5] = 1;
                end else if (xaxis >= 13'd36 && xaxis <= 13'd40 && yaxis >= 13'd8 && yaxis <= 13'd32) begin //B
                    oledSeg[1] = 1;
                end else if (xaxis >= 13'd18 && xaxis <= 13'd40 && yaxis >= 13'd28 && yaxis <= 13'd32) begin //G
                    oledSeg[6] = 1;
                end else if (xaxis >= 13'd18 && xaxis <= 13'd22 && yaxis >= 13'd28 && yaxis <= 13'd52) begin //E
                    oledSeg[4] = 1;
                end else if (xaxis >= 13'd36 && xaxis <= 13'd40 && yaxis >= 13'd28 && yaxis <= 13'd52) begin //C
                    oledSeg[2] = 1;
                end else if (xaxis >= 13'd18 && xaxis <= 13'd40 && yaxis >= 13'd48 && yaxis <= 13'd52) begin //D
                    oledSeg[3] = 1;
                end
            end
     
             A_empty = ((pixel_index % 13'd96 == 13'd18 || pixel_index % 13'd96 == 13'd40) && //x axis
                        pixel_index / 13'd96 >= 13'd8 && pixel_index / 13'd96 <= 13'd12) ||
                       (pixel_index % 13'd96 >= 13'd18 && pixel_index % 13'd96 <= 13'd40 && //y axis
                       (pixel_index / 13'd96 == 13'd8 || pixel_index / 13'd96 == 13'd12));
             B_empty = ((pixel_index % 13'd96 == 13'd36 || pixel_index % 13'd96 == 13'd40) &&  // x axis
                        pixel_index / 13'd96 >= 13'd8 && pixel_index / 13'd96 <= 13'd32) ||
                       (pixel_index % 13'd96 >= 13'd36 && pixel_index % 13'd96 <= 13'd40 &&  // y axis
                       (pixel_index / 13'd96 == 13'd8 || pixel_index / 13'd96 == 13'd32));
             C_empty = ((pixel_index % 13'd96 == 13'd36 || pixel_index % 13'd96 == 13'd40) &&  // x axis
                        pixel_index / 13'd96 >= 13'd28 && pixel_index / 13'd96 <= 13'd52) ||
                       (pixel_index % 13'd96 >= 13'd36 && pixel_index % 13'd96 <= 13'd40 &&  // y axis
                       (pixel_index / 13'd96 == 13'd28 || pixel_index / 13'd96 == 13'd52));
             D_empty = ((pixel_index % 13'd96 == 13'd18 || pixel_index % 13'd96 == 13'd40) && //x axis
                        pixel_index / 13'd96 >= 13'd48 && pixel_index / 13'd96 <= 13'd52) ||
                       (pixel_index % 13'd96 >= 13'd18 && pixel_index % 13'd96 <= 13'd40 && // y axis
                       (pixel_index / 13'd96 == 13'd48 || pixel_index / 13'd96 == 13'd52));
             E_empty = ((pixel_index % 13'd96 == 13'd18 || pixel_index % 13'd96 == 13'd22) &&  // x axis
                        pixel_index / 13'd96 >= 13'd28 && pixel_index / 13'd96 <= 13'd52) ||
                       (pixel_index % 13'd96 >= 13'd18 && pixel_index % 13'd96 <= 13'd22 &&  // y axis
                       (pixel_index / 13'd96 == 13'd28 || pixel_index / 13'd96 == 13'd52));
             F_empty = ((pixel_index % 13'd96 == 13'd18 || pixel_index % 13'd96 == 13'd22) &&  // x axis
                        pixel_index / 13'd96 >= 13'd8 && pixel_index / 13'd96 <= 13'd32) ||
                       (pixel_index % 13'd96 >= 13'd18 && pixel_index % 13'd96 <= 13'd22 &&  // y axis
                       (pixel_index / 13'd96 == 13'd8 || pixel_index / 13'd96 == 13'd32));
             G_empty = ((pixel_index % 13'd96 == 13'd18 || pixel_index % 13'd96 == 13'd40) && //x axis
                        pixel_index / 13'd96 >= 13'd28 && pixel_index / 13'd96 <= 13'd32) ||
                       (pixel_index % 13'd96 >= 13'd18 && pixel_index % 13'd96 <= 13'd40 && // y axis
                       (pixel_index / 13'd96 == 13'd28 || pixel_index / 13'd96 == 13'd32));
             A_fill = pixel_index % 13'd96 >= 13'd18 && pixel_index % 13'd96 <= 13'd40 && //x axis
                      pixel_index / 13'd96 >= 13'd8 && pixel_index / 13'd96 <= 13'd12; //y axis
             B_fill = pixel_index % 13'd96 >= 13'd36 && pixel_index % 13'd96 <= 13'd40 &&  // x axis
                      pixel_index / 13'd96 >= 13'd8 && pixel_index / 13'd96 <= 13'd32; //y axis
             C_fill = pixel_index % 13'd96 >= 13'd36 && pixel_index % 13'd96 <= 13'd40 &&  // x axis
                      pixel_index / 13'd96 >= 13'd28 && pixel_index / 13'd96 <= 13'd52; //y axis
             D_fill = pixel_index % 13'd96 >= 13'd18 && pixel_index % 13'd96 <= 13'd40 && //x axis
                      pixel_index / 13'd96 >= 13'd48 && pixel_index / 13'd96 <= 13'd52; //y axis
             E_fill = pixel_index % 13'd96 >= 13'd18 && pixel_index % 13'd96 <= 13'd22 &&  // x axis
                      pixel_index / 13'd96 >= 13'd28 && pixel_index / 13'd96 <= 13'd52; // y axis
             F_fill = pixel_index % 13'd96 >= 13'd18 && pixel_index % 13'd96 <= 13'd22 &&  // x axis
                      pixel_index / 13'd96 >= 13'd8 && pixel_index / 13'd96 <= 13'd32; // y axis
             G_fill = pixel_index % 13'd96 >= 13'd18 && pixel_index % 13'd96 <= 13'd40 && //x axis
                      pixel_index / 13'd96 >= 13'd28 && pixel_index / 13'd96 <= 13'd32; // y axis
             cursor = pixel_index % 13'd96 >= xaxis && pixel_index % 13'd96 <= xaxis &&
                      pixel_index / 13'd96 >= yaxis && pixel_index / 13'd96 <= yaxis;
     
             //shape outline
             if (pixel_index % 13'd96 <= 13'd58 &&
                 pixel_index / 13'd96 >= 13'd57 &&
                 pixel_index / 13'd96 <= 13'd59 ) begin //hori green line
                 oled_data = 16'h07E0;
             end else
             if (pixel_index / 13'd96 <= 13'd59 &&
                 pixel_index % 13'd96 >= 13'd56 &&
                 pixel_index % 13'd96 <= 13'd58 ) begin //vert green line
                 oled_data = 16'h07E0;
             end else if (oledSeg == 7'b0) begin
                 oled_data = (A_fill || B_fill || C_fill || D_fill || E_fill || F_fill || G_fill || cursor) ? 16'hFFFF : 16'h0;
             end else if (oledSeg == 7'b1) begin
                 oled_data = (A_empty || B_fill || C_fill || D_fill || E_fill || F_fill || G_fill || cursor) ? 16'hFFFF : 16'h0;
             end else if (oledSeg == 7'b10) begin
                 oled_data = (A_fill || B_empty || C_fill || D_fill || E_fill || F_fill || G_fill || cursor) ? 16'hFFFF : 16'h0;
             end else if (oledSeg == 7'b11) begin
                 oled_data = (A_empty || B_empty || C_fill || D_fill || E_fill || F_fill || G_fill || cursor) ? 16'hFFFF : 16'h0;
             end else if (oledSeg == 7'b100) begin
                 oled_data = (A_fill || B_fill || C_empty || D_fill || E_fill || F_fill || G_fill || cursor) ? 16'hFFFF : 16'h0;
             end else if (oledSeg == 7'b101) begin
                 oled_data = (A_empty || B_fill || C_empty || D_fill || E_fill || F_fill || G_fill || cursor) ? 16'hFFFF : 16'h0;
             end else if (oledSeg == 7'b110) begin
                 oled_data = (A_fill || B_empty || C_empty || D_fill || E_fill || F_fill || G_fill || cursor) ? 16'hFFFF : 16'h0;
             end else if (oledSeg == 7'b111) begin
                 oled_data = (A_empty || B_empty || C_empty || D_fill || E_fill || F_fill || G_fill || cursor) ? 16'hFFFF : 16'h0;
             end else if (oledSeg == 7'b1000) begin
                 oled_data = (A_fill || B_fill || C_fill || D_empty || E_fill || F_fill || G_fill || cursor) ? 16'hFFFF : 16'h0;
             end else if (oledSeg == 7'b1001) begin
                 oled_data = (A_empty || B_fill || C_fill || D_empty || E_fill || F_fill || G_fill || cursor) ? 16'hFFFF : 16'h0;
             end else if (oledSeg == 7'b1010) begin
                 oled_data = (A_fill || B_empty || C_fill || D_empty || E_fill || F_fill || G_fill || cursor) ? 16'hFFFF : 16'h0;
             end else if (oledSeg == 7'b1011) begin
                 oled_data = (A_empty || B_empty || C_fill || D_empty || E_fill || F_fill || G_fill || cursor) ? 16'hFFFF : 16'h0;
             end else if (oledSeg == 7'b1100) begin
                 oled_data = (A_fill || B_fill || C_empty || D_empty || E_fill || F_fill || G_fill || cursor) ? 16'hFFFF : 16'h0;
             end else if (oledSeg == 7'b1101) begin
                 oled_data = (A_empty || B_fill || C_empty || D_empty || E_fill || F_fill || G_fill || cursor) ? 16'hFFFF : 16'h0;
             end else if (oledSeg == 7'b1110) begin
                 oled_data = (A_fill || B_empty || C_empty || D_empty || E_fill || F_fill || G_fill || cursor) ? 16'hFFFF : 16'h0;
             end else if (oledSeg == 7'b1111) begin
                 oled_data = (A_empty || B_empty || C_empty || D_empty || E_fill || F_fill || G_fill || cursor) ? 16'hFFFF : 16'h0;
             end else if (oledSeg == 7'b10000) begin
                 oled_data = (A_fill || B_fill || C_fill || D_fill || E_empty || F_fill || G_fill || cursor) ? 16'hFFFF : 16'h0;
             end else if (oledSeg == 7'b10001) begin
                 oled_data = (A_empty || B_fill || C_fill || D_fill || E_empty || F_fill || G_fill || cursor) ? 16'hFFFF : 16'h0;
             end else if (oledSeg == 7'b10010) begin
                 oled_data = (A_fill || B_empty || C_fill || D_fill || E_empty || F_fill || G_fill || cursor) ? 16'hFFFF : 16'h0;
             end else if (oledSeg == 7'b10011) begin
                 oled_data = (A_empty || B_empty || C_fill || D_fill || E_empty || F_fill || G_fill || cursor)? 16'hFFFF : 16'h0;
             end else if (oledSeg == 7'b10100) begin
                 oled_data = (A_fill || B_fill || C_empty || D_fill || E_empty || F_fill || G_fill || cursor) ? 16'hFFFF : 16'h0;
             end else if (oledSeg == 7'b10101) begin
                 oled_data = (A_empty || B_fill || C_empty || D_fill || E_empty || F_fill || G_fill || cursor) ? 16'hFFFF : 16'h0;
             end else if (oledSeg == 7'b10110) begin
                 oled_data = (A_fill || B_empty || C_empty || D_fill || E_empty || F_fill || G_fill || cursor) ? 16'hFFFF : 16'h0;
             end else if (oledSeg == 7'b10111) begin
                 oled_data = (A_empty || B_empty || C_empty || D_fill || E_empty || F_fill || G_fill || cursor) ? 16'hFFFF : 16'h0;
             end else if (oledSeg == 7'b11000) begin
                 oled_data = (A_fill || B_fill || C_fill || D_empty || E_empty || F_fill || G_fill || cursor) ? 16'hFFFF : 16'h0;
             end else if (oledSeg == 7'b11001) begin
                 oled_data = (A_empty || B_fill || C_fill || D_empty || E_empty || F_fill || G_fill || cursor) ? 16'hFFFF : 16'h0;
             end else if (oledSeg == 7'b11010) begin
                 oled_data = (A_fill || B_empty || C_fill || D_empty || E_empty || F_fill || G_fill || cursor) ? 16'hFFFF : 16'h0;
             end else if (oledSeg == 7'b11011) begin
                 oled_data = (A_empty || B_empty || C_fill || D_empty || E_empty || F_fill || G_fill || cursor) ? 16'hFFFF : 16'h0;
             end else if (oledSeg == 7'b11100) begin
                 oled_data = (A_fill || B_fill || C_empty || D_empty || E_empty || F_fill || G_fill || cursor) ? 16'hFFFF : 16'h0;
             end else if (oledSeg == 7'b11101) begin
                 oled_data = (A_empty || B_fill || C_empty || D_empty || E_empty || F_fill || G_fill || cursor) ? 16'hFFFF : 16'h0;
             end else if (oledSeg == 7'b11110) begin
                 oled_data = (A_fill || B_empty || C_empty || D_empty || E_empty || F_fill || G_fill || cursor) ? 16'hFFFF : 16'h0;
             end else if (oledSeg == 7'b11111) begin
                 oled_data = (A_empty || B_empty || C_empty || D_empty || E_empty || F_fill || G_fill || cursor) ? 16'hFFFF : 16'h0;
             end else if (oledSeg == 7'b100000) begin
                 oled_data = (A_fill || B_fill || C_fill || D_fill || E_fill || F_empty || G_fill || cursor) ? 16'hFFFF : 16'h0;
             end else if (oledSeg == 7'b100001) begin
                 oled_data = (A_empty || B_fill || C_fill || D_fill || E_fill || F_empty || G_fill || cursor) ? 16'hFFFF : 16'h0;
             end else if (oledSeg == 7'b100010) begin
                 oled_data = (A_fill || B_empty || C_fill || D_fill || E_fill || F_empty || G_fill || cursor) ? 16'hFFFF : 16'h0;
             end else if (oledSeg == 7'b100011) begin
                 oled_data = (A_empty || B_empty || C_fill || D_fill || E_fill | F_empty || G_fill || cursor) ? 16'hFFFF : 16'h0;
             end else if (oledSeg == 7'b100100) begin
                 oled_data = (A_fill || B_fill || C_empty || D_fill || E_fill || F_empty || G_fill || cursor) ? 16'hFFFF : 16'h0;
             end else if (oledSeg == 7'b100101) begin
                 oled_data = (A_empty || B_fill || C_empty || D_fill || E_fill || F_empty || G_fill || cursor) ? 16'hFFFF : 16'h0;
             end else if (oledSeg == 7'b100110) begin
                 oled_data = (A_fill || B_empty || C_empty || D_fill || E_fill || F_empty || G_fill || cursor) ? 16'hFFFF : 16'h0;
             end else if (oledSeg == 7'b100111) begin
                 oled_data = (A_empty || B_empty || C_empty || D_fill || E_fill || F_empty || G_fill || cursor) ? 16'hFFFF : 16'h0;
             end else if (oledSeg == 7'b101000) begin
                 oled_data = (A_fill || B_fill || C_fill || D_empty || E_fill || F_empty || G_fill || cursor) ? 16'hFFFF : 16'h0;
             end else if (oledSeg == 7'b101001) begin
                 oled_data = (A_empty || B_fill || C_fill || D_empty || E_fill || F_empty || G_fill || cursor) ? 16'hFFFF : 16'h0;
             end else if (oledSeg == 7'b101010) begin
                 oled_data = (A_fill || B_empty || C_fill || D_empty || E_fill || F_empty || G_fill || cursor) ? 16'hFFFF : 16'h0;
             end else if (oledSeg == 7'b101011) begin
                 oled_data = (A_empty || B_empty || C_fill || D_empty || E_fill || F_empty || G_fill || cursor) ? 16'hFFFF : 16'h0;
             end else if (oledSeg == 7'b101100) begin
                 oled_data = (A_fill || B_fill || C_empty || D_empty || E_fill || F_empty || G_fill || cursor) ? 16'hFFFF : 16'h0;
             end else if (oledSeg == 7'b101101) begin
                 oled_data = (A_empty || B_fill || C_empty || D_empty || E_fill || F_empty || G_fill || cursor) ? 16'hFFFF : 16'h0;
             end else if (oledSeg == 7'b101110) begin
                 oled_data = (A_fill || B_empty || C_empty || D_empty || E_fill || F_empty || G_fill || cursor) ? 16'hFFFF : 16'h0;
             end else if (oledSeg == 7'b101111) begin
                 oled_data = (A_empty || B_empty || C_empty || D_empty || E_fill || F_empty || G_fill || cursor) ? 16'hFFFF : 16'h0;
             end else if (oledSeg == 7'b110000) begin
                 oled_data = (A_fill || B_fill || C_fill || D_fill || E_empty || F_empty || G_fill || cursor) ? 16'hFFFF : 16'h0;
             end else if (oledSeg == 7'b110001) begin
                 oled_data = (A_empty || B_fill || C_fill || D_fill || E_empty || F_empty || G_fill || cursor) ? 16'hFFFF : 16'h0;
             end else if (oledSeg == 7'b110010) begin
                 oled_data = (A_fill || B_empty || C_fill || D_fill || E_empty || F_empty || G_fill || cursor) ? 16'hFFFF : 16'h0;
             end else if (oledSeg == 7'b110011) begin
                 oled_data = (A_empty || B_empty || C_fill || D_fill || E_empty || F_empty || G_fill || cursor) ? 16'hFFFF : 16'h0;
             end else if (oledSeg == 7'b110100) begin
                 oled_data = (A_fill || B_fill || C_empty || D_fill || E_empty || F_empty || G_fill || cursor) ? 16'hFFFF : 16'h0;
             end else if (oledSeg == 7'b110101) begin
                 oled_data = (A_empty || B_fill || C_empty || D_fill || E_empty || F_empty || G_fill || cursor) ? 16'hFFFF : 16'h0;
             end else if (oledSeg == 7'b110110) begin
                 oled_data = (A_fill || B_empty || C_empty || D_fill || E_empty || F_empty || G_fill || cursor) ? 16'hFFFF : 16'h0;
             end else if (oledSeg == 7'b110111) begin
                 oled_data = (A_empty || B_empty || C_empty || D_fill || E_empty || F_empty || G_fill || cursor) ? 16'hFFFF : 16'h0;
             end else if (oledSeg == 7'b111000) begin
                 oled_data = (A_fill || B_fill || C_fill || D_empty || E_empty || F_empty || G_fill || cursor) ? 16'hFFFF : 16'h0;
             end else if (oledSeg == 7'b111001) begin
                 oled_data = (A_empty || B_fill || C_fill || D_empty || E_empty || F_empty || G_fill || cursor) ? 16'hFFFF : 16'h0;
             end else if (oledSeg == 7'b111010) begin
                 oled_data = (A_fill || B_empty || C_fill || D_empty || E_empty || F_empty || G_fill || cursor) ? 16'hFFFF : 16'h0;
             end else if (oledSeg == 7'b111011) begin
                oled_data = (A_empty || B_empty || C_fill || D_empty || E_empty || F_empty || G_fill || cursor) ? 16'hFFFF : 16'h0;
             end else if (oledSeg == 7'b111100) begin
                 oled_data = (A_fill || B_fill || C_empty || D_empty || E_empty || F_empty || G_fill || cursor) ? 16'hFFFF : 16'h0;
             end else if (oledSeg == 7'b111101) begin
                 oled_data = (A_empty || B_fill || C_empty || D_empty || E_empty || F_empty || G_fill || cursor) ? 16'hFFFF : 16'h0;
             end else if (oledSeg == 7'b111110) begin
                 oled_data = (A_fill || B_empty || C_empty || D_empty || E_empty || F_empty || G_fill || cursor) ? 16'hFFFF : 16'h0;
             end else if (oledSeg == 7'b111111) begin
                 oled_data = (A_empty || B_empty || C_empty || D_empty || E_empty || F_empty || G_fill || cursor) ? 16'hFFFF : 16'h0;
             end else if (oledSeg == 7'b1000000) begin
                 oled_data = (A_fill || B_fill || C_fill || D_fill || E_fill || F_fill || G_empty || cursor) ? 16'hFFFF : 16'h0;
             end else if (oledSeg == 7'b1000001) begin
                 oled_data = (A_empty || B_fill || C_fill || D_fill || E_fill || F_fill || G_empty || cursor) ? 16'hFFFF : 16'h0;
             end else if (oledSeg == 7'b1000010) begin
                 oled_data = (A_fill || B_empty || C_fill || D_fill || E_fill || F_fill || G_empty || cursor) ? 16'hFFFF : 16'h0;
             end else if (oledSeg == 7'b1000011) begin
                 oled_data = (A_empty || B_empty || C_fill || D_fill || E_fill || F_fill || G_empty || cursor) ? 16'hFFFF : 16'h0;
             end else if (oledSeg == 7'b1000100) begin
                 oled_data = (A_fill || B_fill || C_empty || D_fill || E_fill || F_fill || G_empty || cursor) ? 16'hFFFF : 16'h0;
             end else if (oledSeg == 7'b1000101) begin
                 oled_data = (A_empty || B_fill || C_empty || D_fill || E_fill || F_fill || G_empty || cursor) ? 16'hFFFF : 16'h0;
             end else if (oledSeg == 7'b1000110) begin
                 oled_data = (A_fill || B_empty || C_empty || D_fill || E_fill || F_fill || G_empty || cursor) ? 16'hFFFF : 16'h0;
             end else if (oledSeg == 7'b1000111) begin
                 oled_data = (A_empty || B_empty || C_empty || D_fill || E_fill || F_fill || G_empty || cursor) ? 16'hFFFF : 16'h0;
             end else if (oledSeg == 7'b1001000) begin
                 oled_data = (A_fill || B_fill || C_fill || D_empty || E_fill || F_fill || G_empty || cursor) ? 16'hFFFF : 16'h0;
             end else if (oledSeg == 7'b1001001) begin
                 oled_data = (A_empty || B_fill || C_fill || D_empty || E_fill || F_fill || G_empty || cursor) ? 16'hFFFF : 16'h0;
             end else if (oledSeg == 7'b1001010) begin
                 oled_data = (A_fill || B_empty || C_fill || D_empty || E_fill || F_fill || G_empty || cursor) ? 16'hFFFF : 16'h0;
             end else if (oledSeg == 7'b1001011) begin
                 oled_data = (A_empty || B_empty || C_fill || D_empty || E_fill || F_fill || G_empty || cursor) ? 16'hFFFF : 16'h0;
             end else if (oledSeg == 7'b1001100) begin
                 oled_data = (A_fill || B_fill || C_empty || D_empty || E_fill || F_fill || G_empty || cursor) ? 16'hFFFF : 16'h0;
             end else if (oledSeg == 7'b1001101) begin
                 oled_data = (A_empty || B_fill || C_empty || D_empty || E_fill || F_fill || G_empty || cursor) ? 16'hFFFF : 16'h0;
             end else if (oledSeg == 7'b1001110) begin
                 oled_data = (A_fill || B_empty || C_empty || D_empty || E_fill || F_fill || G_empty || cursor) ? 16'hFFFF : 16'h0;
             end else if (oledSeg == 7'b1001111) begin
                 oled_data = (A_empty || B_empty || C_empty || D_empty || E_fill || F_fill || G_empty || cursor) ? 16'hFFFF : 16'h0;
             end else if (oledSeg == 7'b1010000) begin
                 oled_data = (A_fill || B_fill || C_fill || D_fill || E_empty || F_fill || G_empty || cursor) ? 16'hFFFF : 16'h0;
             end else if (oledSeg == 7'b1010001) begin
                 oled_data = (A_empty || B_fill || C_fill || D_fill || E_empty || F_fill || G_empty || cursor) ? 16'hFFFF : 16'h0;
             end else if (oledSeg == 7'b1010010) begin
                 oled_data = (A_fill || B_empty || C_fill || D_fill || E_empty || F_fill || G_empty || cursor) ? 16'hFFFF : 16'h0;
             end else if (oledSeg == 7'b1010011) begin
                 oled_data = (A_empty || B_empty || C_fill || D_fill || E_empty || F_fill || G_empty || cursor) ? 16'hFFFF : 16'h0;
             end else if (oledSeg == 7'b1010100) begin
                 oled_data = (A_fill || B_fill || C_empty || D_fill || E_empty || F_fill || G_empty || cursor) ? 16'hFFFF : 16'h0;
             end else if (oledSeg == 7'b1010101) begin
                 oled_data = (A_empty || B_fill || C_empty || D_fill || E_empty || F_fill || G_empty || cursor) ? 16'hFFFF : 16'h0;
             end else if (oledSeg == 7'b1010110) begin
                 oled_data = (A_fill || B_empty || C_empty || D_fill || E_empty || F_fill || G_empty || cursor) ? 16'hFFFF : 16'h0;
             end else if (oledSeg == 7'b1010111) begin
                 oled_data = (A_empty || B_empty || C_empty || D_fill || E_empty || F_fill || G_empty || cursor) ? 16'hFFFF : 16'h0;
             end else if (oledSeg == 7'b1011000) begin
                 oled_data = (A_fill || B_fill || C_fill || D_empty || E_empty || F_fill || G_empty || cursor) ? 16'hFFFF : 16'h0;
             end else if (oledSeg == 7'b1011001) begin
                 oled_data = (A_empty || B_fill || C_fill || D_empty || E_empty || F_fill || G_empty || cursor) ? 16'hFFFF : 16'h0;
             end else if (oledSeg == 7'b1011010) begin
                 oled_data = (A_fill || B_empty || C_fill || D_empty || E_empty || F_fill || G_empty || cursor) ? 16'hFFFF : 16'h0;
             end else if (oledSeg == 7'b1011011) begin
                 oled_data = (A_empty || B_empty || C_fill || D_empty || E_empty || F_fill || G_empty || cursor) ? 16'hFFFF : 16'h0;
             end else if (oledSeg == 7'b1011100) begin
                 oled_data = (A_fill || B_fill || C_empty || D_empty || E_empty || F_fill || G_empty || cursor) ? 16'hFFFF : 16'h0;
             end else if (oledSeg == 7'b1011101) begin
                 oled_data = (A_empty || B_fill || C_empty || D_empty || E_empty || F_fill || G_empty || cursor) ? 16'hFFFF : 16'h0;
             end else if (oledSeg == 7'b1011110) begin
                 oled_data = (A_fill || B_empty || C_empty || D_empty || E_empty || F_fill || G_empty || cursor) ? 16'hFFFF : 16'h0;
             end else if (oledSeg == 7'b1011111) begin
                 oled_data = (A_empty || B_empty || C_empty || D_empty || E_empty || F_fill || G_empty || cursor) ? 16'hFFFF : 16'h0;
             end else if (oledSeg == 7'b1100000) begin
                 oled_data = (A_fill || B_fill || C_fill || D_fill || E_fill || F_empty || G_empty || cursor) ? 16'hFFFF : 16'h0;
             end else if (oledSeg == 7'b1100001) begin
                 oled_data = (A_empty || B_fill || C_fill || D_fill || E_fill || F_empty || G_empty || cursor) ? 16'hFFFF : 16'h0;
             end else if (oledSeg == 7'b1100010) begin
                 oled_data = (A_fill || B_empty || C_fill || D_fill || E_fill || F_empty || G_empty || cursor) ? 16'hFFFF : 16'h0;
             end else if (oledSeg == 7'b1100011) begin
                 oled_data = (A_empty || B_empty || C_fill || D_fill || E_fill || F_empty || G_empty || cursor) ? 16'hFFFF : 16'h0;
             end else if (oledSeg == 7'b1100100) begin
                 oled_data = (A_fill || B_fill || C_empty || D_fill || E_fill || F_empty || G_empty || cursor) ? 16'hFFFF : 16'h0;
             end else if (oledSeg == 7'b1100101) begin
                 oled_data = (A_empty || B_fill || C_empty || D_fill || E_fill || F_empty || G_empty || cursor) ? 16'hFFFF : 16'h0;
             end else if (oledSeg == 7'b1100110) begin
                 oled_data = (A_fill || B_empty || C_empty || D_fill || E_fill || F_empty || G_empty || cursor) ? 16'hFFFF : 16'h0;
             end else if (oledSeg == 7'b1100111) begin
                 oled_data = (A_empty || B_empty || C_empty || D_fill || E_fill || F_empty || G_empty || cursor) ? 16'hFFFF : 16'h0;
             end else if (oledSeg == 7'b1101000) begin
                 oled_data = (A_fill || B_fill || C_fill || D_empty || E_fill || F_empty || G_empty || cursor) ? 16'hFFFF : 16'h0;
             end else if (oledSeg == 7'b1101001) begin
                 oled_data = (A_empty || B_fill || C_fill || D_empty || E_fill || F_empty || G_empty || cursor) ? 16'hFFFF : 16'h0;
             end else if (oledSeg == 7'b1101010) begin
                 oled_data = (A_fill || B_empty || C_fill || D_empty || E_fill || F_empty || G_empty || cursor) ? 16'hFFFF : 16'h0;
             end else if (oledSeg == 7'b1101011) begin
                 oled_data = (A_empty || B_empty || C_fill || D_empty || E_fill || F_empty || G_empty || cursor) ? 16'hFFFF : 16'h0;
             end else if (oledSeg == 7'b1101100) begin
                 oled_data = (A_fill || B_fill || C_empty || D_empty || E_fill || F_empty || G_empty || cursor) ? 16'hFFFF : 16'h0;
             end else if (oledSeg == 7'b1101101) begin
                 oled_data = (A_empty || B_fill || C_empty || D_empty || E_fill || F_empty || G_empty || cursor) ? 16'hFFFF : 16'h0;
             end else if (oledSeg == 7'b1101110) begin
                 oled_data = (A_fill || B_empty || C_empty || D_empty || E_fill || F_empty || G_empty || cursor) ? 16'hFFFF : 16'h0;
             end else if (oledSeg == 7'b1101111) begin
                 oled_data = (A_empty || B_empty || C_empty || D_empty || E_fill || F_empty || G_empty || cursor) ? 16'hFFFF : 16'h0;
             end else if (oledSeg == 7'b1110000) begin
                 oled_data = (A_fill || B_fill || C_fill || D_fill || E_empty || F_empty || G_empty || cursor) ? 16'hFFFF : 16'h0;
             end else if (oledSeg == 7'b1110001) begin
                 oled_data = (A_empty || B_fill || C_fill || D_fill || E_empty || F_empty || G_empty || cursor) ? 16'hFFFF : 16'h0;
             end else if (oledSeg == 7'b1110010) begin
                 oled_data = (A_fill || B_empty || C_fill || D_fill || E_empty || F_empty || G_empty || cursor) ? 16'hFFFF : 16'h0;
             end else if (oledSeg == 7'b1110011) begin
                 oled_data = (A_empty || B_empty || C_fill || D_fill || E_empty || F_empty || G_empty || cursor) ? 16'hFFFF : 16'h0;
             end else if (oledSeg == 7'b1110100) begin
                 oled_data = (A_fill || B_fill || C_empty || D_fill || E_empty || F_empty || G_empty || cursor) ? 16'hFFFF : 16'h0;
             end else if (oledSeg == 7'b1110101) begin
                 oled_data = (A_empty || B_fill || C_empty || D_fill || E_empty || F_empty || G_empty || cursor) ? 16'hFFFF : 16'h0;
             end else if (oledSeg == 7'b1110110) begin
                 oled_data = (A_fill || B_empty || C_empty || D_fill || E_empty || F_empty || G_empty || cursor) ? 16'hFFFF : 16'h0;
             end else if (oledSeg == 7'b1110111) begin
                 oled_data = (A_empty || B_empty || C_empty || D_fill || E_empty || F_empty || G_empty || cursor) ? 16'hFFFF : 16'h0;
             end else if (oledSeg == 7'b1111000) begin
                 oled_data = (A_fill || B_fill || C_fill || D_empty || E_empty || F_empty || G_empty || cursor) ? 16'hFFFF : 16'h0;
             end else if (oledSeg == 7'b1111001) begin
                 oled_data = (A_empty || B_fill || C_fill || D_empty || E_empty || F_empty || G_empty || cursor) ? 16'hFFFF : 16'h0;
             end else if (oledSeg == 7'b1111010) begin
                 oled_data = (A_fill || B_empty || C_fill || D_empty || E_empty || F_empty || G_empty || cursor) ? 16'hFFFF : 16'h0;
             end else if (oledSeg == 7'b1111011) begin
                 oled_data = (A_empty || B_empty || C_fill || D_empty || E_empty || F_empty || G_empty || cursor) ? 16'hFFFF : 16'h0;
             end else if (oledSeg == 7'b1111100) begin
                 oled_data = (A_fill || B_fill || C_empty || D_empty || E_empty || F_empty || G_empty || cursor) ? 16'hFFFF : 16'h0;
             end else if (oledSeg == 7'b1111101) begin
                 oled_data = (A_empty || B_fill || C_empty || D_empty || E_empty || F_empty || G_empty || cursor) ? 16'hFFFF : 16'h0;
             end else if (oledSeg == 7'b1111110) begin
                 oled_data = (A_fill || B_empty || C_empty || D_empty || E_empty || F_empty || G_empty || cursor) ? 16'hFFFF : 16'h0;
             end else if (oledSeg == 7'b1111111) begin
                 oled_data = (A_empty || B_empty || C_empty || D_empty || E_empty || F_empty || G_empty || cursor) ? 16'hFFFF : 16'h0;
             end
             
                 //off is 1, on is 0; A = 0, B = 1 C = 2 ...;  
             if (~oledSeg[0] && ~oledSeg[1] && ~oledSeg[2] && ~oledSeg[3] && ~oledSeg[4] && ~oledSeg[5] && oledSeg[6]) begin // 0     
                lastDigit = digit;               
                digit = 10'b0000000001;
                
             end else
             if (oledSeg[0] && ~oledSeg[1] && ~oledSeg[2] && oledSeg[3] && oledSeg[4] && oledSeg[5] && oledSeg[6]) begin // 1      
             lastDigit = digit;                 
                 digit = 10'b0000000010;
             end else
             if (~oledSeg[0] && ~oledSeg[1] && oledSeg[2] && ~oledSeg[3] && ~oledSeg[4] && oledSeg[5] && ~oledSeg[6]) begin // 2         
             lastDigit = digit;          
                digit = 10'b0000000100;
             end else 
             if (~oledSeg[0] && ~oledSeg[1] && ~oledSeg[2] && ~oledSeg[3] && oledSeg[4] && oledSeg[5] && ~oledSeg[6]) begin // 3    
             lastDigit = digit;                   
                digit = 10'b0000001000;
             end else
             if (oledSeg[0] && ~oledSeg[1] && ~oledSeg[2] && oledSeg[3] && oledSeg[4] && ~oledSeg[5] && ~oledSeg[6]) begin // 4  
             lastDigit = digit;                    
                digit = 10'b0000010000;
             end else 
             if (~oledSeg[0] && oledSeg[1] && ~oledSeg[2] && ~oledSeg[3] && oledSeg[4] && ~oledSeg[5] && ~oledSeg[6]) begin // 5
             lastDigit = digit;        
                digit = 10'b000010000;
             end else
             if (~oledSeg[0] && oledSeg[1] && ~oledSeg[2] && ~oledSeg[3] && ~oledSeg[4] && ~oledSeg[5] && ~oledSeg[6]) begin // 6
             lastDigit = digit;        
                digit = 10'b000100000;
             end else
             if (~oledSeg[0] && ~oledSeg[1] && ~oledSeg[2] && oledSeg[3] && oledSeg[4] && oledSeg[5] && ~oledSeg[6]) begin // 7
             lastDigit = digit;        
                digit = 10'b0010000000;
             end else
             if (~oledSeg[0] && ~oledSeg[1] && ~oledSeg[2] && ~oledSeg[3] && ~oledSeg[4] && ~oledSeg[5] && ~oledSeg[6]) begin // 8
             lastDigit = digit;        
                digit = 10'b0100000000;
             end else
             if (~oledSeg[0] && ~oledSeg[1] && ~oledSeg[2] && ~oledSeg[3] && oledSeg[4] && ~oledSeg[5] && ~oledSeg[6]) begin // 9    
             lastDigit = digit;                  
                digit = 10'b1000000000;
             end else begin
             lastDigit = digit;        
                digit = 10'd0;
             end
     
         end else
         if (zr_task_on == 1'b1) begin
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
          // <<< beeping code start
             
             if(lastDigit != digit) begin // check for change in digit
                 beepCount <= 0;
                 beepState <= 1;
              
             end
             
               if(beepState == 1) begin
                   beepCount <= beepCount + 1;
                                 
                                 
                   if(beepCount >= beepCountMax)begin
                      beepState <= 0;
                      audio_out[11] <= 0;
                      beepCount = 0;
                   end
                             
                            
                end
                
                // audio output
                clk50Mcount <= clk50Mcount + 1;
                               clk20kcount <= clk20kcount + 1; 
                               clk380count <= clk380count + 1;
                if (clk50Mcount >= 1) begin 
                                           
                                           clk50M <= ~clk50M;
                                           clk50Mcount <=  0;
                                end 
                                
                                if (clk20kcount >= 2500) begin 
                                             clk20k <= ~clk20k;
                                             clk20kcount <=  0;
                                end 
                 if (clk380count >= 131579 ) begin  // the clock that controls the audio frequency 
                                                       clk380 <= ~clk380;
                                                         clk380count <=  0;
                                                                              
                                                                              
                                                               if(beepState == 1) begin
                                                            audio_out[11:0] <= audio_out[11:0] ^ 12'b100000000001; // audio volume here
                                                            // audio_out[11] <= ~audio_out[11];// this works
                                                                   
                                                            end
                                                  end
                                
                                
                
                // << beeping code end
     
     end
      Audio_Output audio_output (
                .CLK(clk50M), // -- System Clock (50MHz)  
                .START(clk20k), // -- Sampling clock 20kHz
                .DATA1(audio_out[11:0]), //   12-bit digital data1
                .DATA2(audio_out[11:0]), // 12 bit digital data 2
                .RST(0), // input reset
                .D1(JA[1]), // -- PmodDA2 Pin2 (Serial data1)
                .D2(JA[2]), // -- PmodDA2 Pin3 (Serial data2)
                .CLK_OUT(JA[3]), //  -- PmodDA2 Pin4 (Serial Clock)
                .nSYNC(JA[0]), //  -- PmodDA2 Pin1 (Chip Select)
                .DONE(0)
            );

 

endmodule