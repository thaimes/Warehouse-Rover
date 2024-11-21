`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/30/2024 12:54:30 PM
// Design Name: Color Order
// Module Name: color
// Project Name: Group 6 Warehouse
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


module Color(
output s2, s3,
input clk,
input signal,

//LED outputs
output reg RED_LED, 
output reg GREEN_LED, 
output reg BLUE_LED, 
output reg WHITE_LED,
output reg [5:0] led,
output reg [1:0] c1, c2 ,c3
    );
    
   wire [31:0] freq;
   wire done;
   reg reset=0;
   wire [1:0] pos1, pos2, pos3;
   
   
   parameter RED_THRESHOLD = 32'd5000;
   parameter BLUE_THRESHOLD=32'd6200;
   parameter GREEN_THRESHOLD=32'd5000;
   
    FreqCounter freqcount(.clk(clk), .signal(signal), .frequency(freq), .done(done),.reset(rst));
    
    c_store cstore(
        .clk(clk),
        .RED(RED_LED),
        .GREEN(GREEN_LED),
        .BLUE(BLUE_LED),
        .pos1(pos1),
        .pos2(pos2),
        .pos3(pos3)
    );
    

    
 //Set frequencies
   reg[31:0] Red=0;
   reg [31:0] Blue=0;
   reg clear;
   reg [31:0] Green=0;
   reg on;
   reg [1:0] state=0;
   

     assign s2=state[1];
     assign s3=state[0];
    
     always @ (posedge done) begin
     case (state)
     
      2'b01:begin
     Blue=freq;
     end
     2'b00:begin
      Red=freq;
      end
    2'b11: begin
       Green=freq;
       end
       
     2'b10: begin
      if(Red>Blue & Red > Green & Red>5000) begin
        RED_LED=1; 
        BLUE_LED=0; 
        GREEN_LED=0; 
        WHITE_LED=0;
        end 
        
        else if (Blue> Red & Blue> Green & Blue>5000) begin
        BLUE_LED=1; 
        RED_LED=0; 
        GREEN_LED=0; 
        WHITE_LED=0;
        end
        
        else if (Green> Red & Green > Blue & Green>5000) begin
        GREEN_LED=1; 
        RED_LED=0; 
        BLUE_LED=0; 
        WHITE_LED=0;
        end
        
        else begin
        WHITE_LED=1; 
        RED_LED=0;
         GREEN_LED=0; 
         BLUE_LED=0;
        end  
          end
       endcase
       
       state=state+1;
      end
    
    always @ (posedge clk) begin
    
        led [1:0] <= pos1;
        led [3:2] <= pos2;
        led [5:4] <= pos3;
    end
endmodule
