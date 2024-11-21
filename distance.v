`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/22/2024 07:29:04 PM
// Design Name: 
// Module Name: distance
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


module distance(
    input clk,
    input reset,
    input disF,
    input disB,
    output reg detF,
    output reg detB
    );
    
    initial begin
        detF = 0;
        detB = 0;
    end
    always @ (posedge clk) begin
        if (reset) begin
            detF = 0;
            detB = 0;
        end
        else if (disF == 0) begin
            detF = 1;
        end
        else if (disF == 1) begin
            detF = 0;
        end
        else if (disB == 0) begin
            detB = 1;
        end
        else begin
            detB = 0;
        end
    end
endmodule
