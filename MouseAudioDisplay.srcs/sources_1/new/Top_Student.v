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

    output reg [15:0] led,
    output reg [3:0] an = 4'b0000,
   
    output [7:0] JC,

    input btnC,
    input btnU,
    input btnL,
    input btnR,
    input btnD,
    
    
    inout ps2_clk,
    inout ps2_data,
    
    output reg [7:0] seg = 8'b11111111
 );
 
 //declaring variables for Audio Input task)
     wire clk100Mhz;
     wire clk20khz;
     reg [11:0]mic_in = 12'b000000000000;
     wire [11:0]mic_out;
     clk20k dut1(basys_clk, clk20khz);
     clk100MHz dut2(basys_clk, clk100Mhz);
     
 //This count variable is used for the Audio Volume Indicator Task
     reg [31:0] count_AVI = 0;
     reg [11:0] curr_mic_val = 0;
     reg [11:0] peak_val = 0;
     reg [8:0] state_val = 0;
     
 
     Audio_Input audioInput(basys_clk, clk20khz, J_MIC3_Pin3, J_MIC3_Pin1, J_MIC3_Pin4, mic_out); 
     
     
     always @ (posedge clk20khz)
     begin
         count_AVI <= count_AVI + 1;
         curr_mic_val <= mic_out;
         if (curr_mic_val > peak_val)
             peak_val <= curr_mic_val;
         if (count_AVI == 2000)
         begin
             if (peak_val < 2200)
                 state_val <= 0;
             else if (peak_val >= 2200 && peak_val < 2400)
                 state_val <= 1;
             else if (peak_val >= 2400 && peak_val < 2600)
                 state_val <= 2;
             else if (peak_val >= 2600 && peak_val < 2800)
                 state_val <= 3;
             else if (peak_val >= 2800 && peak_val < 3000)
                 state_val <= 4;                
             else if (peak_val >= 3000 && peak_val < 3200)
                 state_val <= 5;
             else if (peak_val >= 3200 && peak_val < 3400)
                 state_val <= 6;
             else if (peak_val >= 3400 && peak_val < 3600)
                 state_val <= 7;
             else if (peak_val >= 3600 && peak_val < 3800)
                 state_val <= 8;
             else
                 state_val <= 9;
             count_AVI <= 0;
             peak_val <= 0;
         end
     end
     

     
    
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
     //assign led[15] = (digit  == 10'd0 | sw[15] == 0) ? 1'b0 : 1'b1;
     reg unlock = 0;
     reg validNum = 0;
     //assign led[14] = (unlock == 0) ? 1'b0 : 1'b1;
     //assign led[13] = (validNum == 0) ? 1'b0 : 1'b1;
//     reg validDigit;
//     assign ledValid = (validDigit) ? 1'b0 : 1'b1;
 
     MouseCtl u1(basys_clk, rst, xpos, ypos, zpos, left, middle, right, new_event, value, setx, sety, setmax_x, setmax_y,
     ps2_clk, ps2_data);
 
     Oled_Display func (clk6p25m, 0, frame_begin, sending_pixels, sample_pixel, pixel_index, oled_data, JC[0],
     JC[1], JC[3], JC[4], JC[5], JC[6], JC[7]);
     
     reg [1:0] digit_select; //This is a 2 bit counter
     reg [16:0] digit_timer; //this handles the refresh rate of the anodes
     
     
     always @ (posedge clk100Mhz) begin
        if (digit_timer == 99_999) 
        begin
            digit_timer <= 0;
            if (digit_select == 2'b10)
            begin
                digit_select <= 2'b00;
            end         
            else
            begin
                digit_select <= digit_select + 1;
            end
        end
        else
            digit_timer <= digit_timer + 1;
     end
 
 
 //This was just under the clk100Mhz clock
 //     assign led[15] = (digit  == 10'd0) ? 1'b0 : 1'b1;
     //     if (sw[15] == 1'b1)
     //        led[15] <= 1'b0;
     //     else
     //        led[15] <= 1'b1;    
     always @ (posedge clk100Mhz)begin

    
     case(digit_select)
        2'b00:
            begin
            if (validNum == 1)
                begin
                an <= 4'b0111;
                if (digit == 10'b0000000001)
                begin
                    seg <= 8'b01000000;
                end
                if (digit == 10'b0000000010)
                begin
                    seg <= 8'b01000000;
                end                
                if (digit == 10'b0000000100)
                begin
                    seg <= 8'b01000000;
                end      
                if (digit == 10'b0000001000)
                begin
                    seg <= 8'b01000000;
                end      
                if (digit == 10'b0000010000)
                begin
                    seg <= 8'b01000000;
                end      
                if (digit == 10'b0000100000)
                begin
                    seg <= 8'b01000000;
                end                      
                if (digit == 10'b0001000000)
                begin
                    seg <= 8'b01000000;
                end      
                if (digit == 10'b0010000000)
                begin
                    seg <= 8'b01000000;
                end      
                if (digit == 10'b0100000000)
                begin
                    seg <= 8'b01000000;
                end                      
                if (digit == 10'b1000000000)
                begin
                    seg <= 8'b01001111;
                end      

                end
            end
        2'b01:
            begin
            if (validNum == 1)
                begin
                    an <= 4'b1011;
                    if (digit == 10'b0000000001)
                    begin
                    //seg should be 1
                        seg <= 8'b11001111;
                    end

                    if (digit == 10'b0000000010)
                    begin
                    //seg should be 2
                        seg <= 8'b10100100;
                    end                
                    if (digit == 10'b0000000100)
                    begin
                    //seg should be 3
                        seg <= 8'b10110000;
                    end      
                    if (digit == 10'b0000001000)
                    begin
                    //seg should be 4
                        seg <= 8'b10011001;
                    end      
                    if (digit == 10'b0000010000)
                    begin
                    //seg should be 5
                        seg <= 8'b10010010;
                    end      
                    if (digit == 10'b0000100000)
                    begin //seg is 6 when digit is 5
                        seg <= 8'b10000010;
                    end  
                    if (digit == 10'b0001000000)
                    begin //seg is 7 when digit is 6
                        seg <= 8'b11111000;
                    end      
                    if (digit == 10'b0010000000)
                    begin //seg is 8 when digit is 7
                        seg <= 8'b10000000;
                    end      
                    if (digit == 10'b0100000000)
                    begin //seg is 9 when digit is 8
                        seg <= 8'b10010000;
                    end                      
                    if (digit == 10'b1000000000)
                    begin
                        seg <= 8'b11000000;
                    end  
                end
                
            end
        2'b10:
            begin
             case(state_val)
                 0:
                 begin
                     seg <= 8'b11000000;
                     an <= 4'b1110;
                     if (sw[15] == 1'b1 && validNum == 1) begin
                        led <= 16'b1000000000000000;
                        end
                     else begin
                        led <= 16'b0000000000000000;
                        end
                 end
                 1:
                 begin
                     seg <= 8'b11111001;
                     an <= 4'b1110;
                     if (sw[15] == 1'b1 && validNum == 1)
                        led <= 16'b1000000000000001;
                     else
                        led <= 16'b0000000000000001;
                 end
                 2:
                 begin
                     seg <= 8'b10100100;
                     an <= 4'b1110;
                     if (sw[15] == 1'b1 && validNum == 1)
                        led <= 16'b1000000000000011;
                     else
                        led <= 16'b0000000000000011;
                     
                 end
                 3:
                 begin
                     seg <= 8'b10110000;
                     an <= 4'b1110;
                     if (sw[15] == 1'b1 && validNum == 1) 
                        led <= 16'b1000000000000111;
                     else
                        led <= 16'b0000000000000111;
                 end
                 4:
                 begin
                     seg <= 8'b10011001;
                     an <= 4'b1110;
                     if (sw[15] == 1'b1 && validNum == 1)
                        led <= 16'b1000000000001111;
                     else
                        led <= 16'b0000000000001111;
                 end
                 5:
                 begin
                     seg <= 8'b10010010;
                     an <= 4'b1110;
                     if (sw[15] == 1'b1 && validNum == 1)
                        led <= 16'b1000000000011111;
                     else
                        led <= 16'b0000000000011111;
                 end
                 6:
                 begin
                     seg <= 8'b10000011;
                     an <= 4'b1110;
                     if (sw[15] == 1'b1 && validNum == 1)
                        led <= 16'b1000000000111111;
                     else
                        led <= 16'b0000000000111111;
                 end
                 7:
                 begin
                     seg <= 8'b11111000;
                     an <= 4'b1110;
                     if (sw[15] == 1'b1 && validNum == 1)
                        led <= 16'b1000000001111111;
                     else
                        led <= 16'b0000000001111111;
                 end
                 8:
                 begin
                     seg <= 8'b10000000;
                     an <= 4'b1110;
                     if (sw[15] == 1'b1 && validNum == 1)
                        led <= 16'b1000000011111111;
                     else
                        led <= 16'b0000000011111111;
                 end
                 9:
                 begin
                     seg <= 8'b10011000;
                     an <= 4'b1110;
                     if (sw[15] == 1'b1 && validNum == 1)
                        led <= 16'b1000000111111111;
                     else
                        led <= 16'b0000000111111111;
                 end
                 default:
                 begin
                     an <= 4'b1110;
                     if (sw[15] == 1'b1 && validNum == 1)
                        led <= 16'b1000000111111111;
                     else
                        led <= 16'b0000000111111111;
                 end
             endcase   
         end
     endcase
  end
     
     
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
     
    // >>>ian start
    reg [31:0] beepCountIan = 0;
         reg beepStateIan = 0;
         reg [31:0] debounceCountIan = 0;
               reg debouncewaitIan = 0;
               reg prevButtonStateIan =0;
              
               reg buttonStateIan = 0;
               reg debouncedButtonIan = 0;
               reg prevStableStateIan = 0; // previous debounced button state
               
               reg buttonCDIan = 0;
               reg [31:0] buttonCDCountIan = 0;
                reg [25:0] clk190count = 0; // 263158
                          reg clk190 = 0;   
                          reg [25:0] clk380count = 0; // 131579
                          reg clk380 = 0;
    
    //<< ian end

     always @(posedge basys_clk) begin
     
     
     //>> ian start
     if(sw[3] == 1) begin
      prevButtonStateIan = buttonStateIan;
                   buttonStateIan = btnC;
                   
                   if(prevButtonStateIan != buttonStateIan && buttonStateIan != debouncedButtonIan) begin // only trigger the code if there is an attempt to change buttonState
                     debounceCountIan = 0;
                   end else begin
                      if(debounceCountIan <= 2439024) begin//2439024
                        debounceCountIan <= debounceCountIan + 1;
                      end else begin
                        debounceCountIan <= 0;
                        prevStableStateIan = debouncedButtonIan; // store the previous stable state of the button
                        debouncedButtonIan = buttonStateIan;  
                                          
                      end
                   end 
                   
                    if(debouncedButtonIan == 1) begin
                                    beepStateIan = 1;
                                    beepCountIan = 0;
                                   // audio_out[11] <= 0;
                                    debouncewaitIan <= 1;
                                 //   100000000  
                                 end
                                 
                                
                                 
                                 if(beepStateIan == 1) begin
                                      beepCountIan <= beepCountIan + 1;
                                      
                                      
                                      if(beepCountIan >= 100000000)begin
                                          beepStateIan <= 0;
                                          audio_out[11] <= 0;
                                      end
                                  
                                 
                                 end
                                 
                                 
                                 clk190count <= clk190count + 1; 
                                                clk380count <= clk380count + 1;
                                 
                                 if (clk190count >= 263158 ) begin 
                                                               clk190 <= ~clk190;
                                                               clk190count <=  0;
                                                               
                                                               
                                                               if(beepStateIan == 1 && sw[0] == 1) begin
                                                                 audio_out[11] <= ~audio_out[11];
                                                               end
                                                 end
                                                 if (clk380count >= 131579 ) begin 
                                                        clk380 <= ~clk380;
                                                          clk380count <=  0;
                                                                               
                                                                               
                                                                if(beepStateIan == 1 && sw[0] == 0) begin
                                                             audio_out[11:0] <= audio_out[11:0] ^ 12'b100000000001;
                                                             // audio_out[11] <= ~audio_out[11];// this works
                                                                    
                                                              end
                                                   end
     end
     //<< ian end
     else begin // IF NO ONE ELSE'S TASK SWITCHES ARE ON: DEFAULT BEHAVIOUR
 
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
                validNum = 1;
                
             end else
             if (oledSeg[0] && ~oledSeg[1] && ~oledSeg[2] && oledSeg[3] && oledSeg[4] && oledSeg[5] && oledSeg[6]) begin // 1      
             lastDigit = digit;                 
                 digit = 10'b0000000010;
                 validNum = 1;
             end else
             if (~oledSeg[0] && ~oledSeg[1] && oledSeg[2] && ~oledSeg[3] && ~oledSeg[4] && oledSeg[5] && ~oledSeg[6]) begin // 2         
             lastDigit = digit;          
                digit = 10'b0000000100;
                validNum = 1;
             end else 
             if (~oledSeg[0] && ~oledSeg[1] && ~oledSeg[2] && ~oledSeg[3] && oledSeg[4] && oledSeg[5] && ~oledSeg[6]) begin // 3    
             lastDigit = digit;                   
                digit = 10'b0000001000;
                validNum = 1;
             end else
             if (oledSeg[0] && ~oledSeg[1] && ~oledSeg[2] && oledSeg[3] && oledSeg[4] && ~oledSeg[5] && ~oledSeg[6]) begin // 4  
             lastDigit = digit;                    
                digit = 10'b0000010000;
                validNum = 1;
             end else 
             if (~oledSeg[0] && oledSeg[1] && ~oledSeg[2] && ~oledSeg[3] && oledSeg[4] && ~oledSeg[5] && ~oledSeg[6]) begin // 5
             lastDigit = digit;        
                digit = 10'b0000100000;
                validNum = 1;
             end else
             if (~oledSeg[0] && oledSeg[1] && ~oledSeg[2] && ~oledSeg[3] && ~oledSeg[4] && ~oledSeg[5] && ~oledSeg[6]) begin // 6
             lastDigit = digit;        
                digit = 10'b0001000000;
                validNum = 1;
             end else
             if (~oledSeg[0] && ~oledSeg[1] && ~oledSeg[2] && oledSeg[3] && oledSeg[4] && oledSeg[5] && oledSeg[6]) begin // 7
             lastDigit = digit;        
                digit = 10'b0010000000;
                validNum = 1;
             end else
             if (~oledSeg[0] && ~oledSeg[1] && ~oledSeg[2] && ~oledSeg[3] && ~oledSeg[4] && ~oledSeg[5] && ~oledSeg[6]) begin // 8
             lastDigit = digit;        
                digit = 10'b0100000000;
                validNum = 1;
             end else
             if (~oledSeg[0] && ~oledSeg[1] && ~oledSeg[2] && ~oledSeg[3] && oledSeg[4] && ~oledSeg[5] && ~oledSeg[6]) begin // 9    
             lastDigit = digit;                  
                digit = 10'b1000000000;
                validNum = 1;
             end else begin
             validNum = 0;
             lastDigit = digit;        
                digit = 10'd0;
             end
             
//         if (digit == 10'd0000000001 || digit == 10'd0000000010 || digit == 10'd0000000100 || digit == 10'd0000001000 || digit == 10'd0000010000 || digit == 10'd0000100000 || digit == 10'd0001000000 || digit == 10'd0010000000 || digit == 10'd0100000000 || digit == 10'd0)
//         begin
//            sw[15] 
//         end
     
         end else
         
         //Anode stuff
         if (digit == 10'd0000000001)
         
         
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
             
//             if(lastDigit != digit  && sw[15] == 1) begin // check for change in digit
//                 beepCount <= 0;
//                 beepState <= 1;
              
//             end
             
               if(beepState == 1) begin
                   beepCount <= beepCount + 1;
                                 
                                 
                   if(beepCount >= beepCountMax)begin
                      beepState <= 0;
                      audio_out[11] <= 0;
                      beepCount = 0;
                          if(sw[15] == 1) begin
                          unlock = 1;
                          end
                   end
                             
                            
                end
                 if(sw[15] == 1 && validNum == 1 && beepState == 0 && unlock == 0) begin 
                     beepCount <= 0;
                     beepState <= 1;
                 
                 end
                
                
               if(sw[15] == 0 && unlock == 1) begin // if sw is 0, board is unlocked and there is a valid digit
                //led alr turns off
                //RESET THE OLED
                oledSeg = 7'b1111111;
                unlock = 0;
                validNum = 0;
               end
                // audio output
              
                                 clk380count <= clk380count + 1;
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
        // >> audio output module support code start
          clk50Mcount <= clk50Mcount + 1;
                                     clk20kcount <= clk20kcount + 1; 
                                    
                      if (clk50Mcount >= 1) begin 
                                                 
                                                 clk50M <= ~clk50M;
                                                 clk50Mcount <=  0;
                                      end 
                                      
                                      if (clk20kcount >= 2500) begin 
                                                   clk20k <= ~clk20k;
                                                   clk20kcount <=  0;
                                      end 
                                      // << audio output module support code end
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