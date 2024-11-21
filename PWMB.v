`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/23/2024 06:53:21 PM
// Design Name: 
// Module Name: PWMB
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


module PWMB(
    input clk,
    input reset,
    input [7:0] SW,
    output reg PWM
    );
    
    reg [20:0] counter;
    reg [20:0] width;
    
    initial begin
        counter = 0;
        width = 0;
        PWM = 0;
    end

    always @(posedge clk) begin
        if (reset)
            counter = 0;
        else
            counter = counter + 1;

        if (counter < width)
            PWM = 1;
        else
            PWM = 0;
            
        case(SW[3:1])
               //3'd# is counting in binary
                3'd1 : width = 21'd650000; //65% speed
                3'd2 : width = 21'd750000; //75% speed
                3'd3 : width = 21'd850000; //85% speed
                3'd4 : width = 21'd950000; //95% speed

                default : width <= 21'd0;
                //Avoid using 100% speed per Jackson B's recommendation
         endcase
    end
        
endmodule
