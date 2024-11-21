`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/23/2024 06:53:21 PM
// Design Name: 
// Module Name: Overcurrent
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
module Overcurrent(
    input clk,
    input reset,
    input sens,
//    input sensB,
//    output ENA,
//    output ENB,
    output reg oc_flag
);
    reg [27:0] oc_timer;
    reg [27:0] debounce;
    
    initial begin
        oc_timer = 0;
        debounce = 0;
        oc_flag = 0;
    end
    
    always @(posedge clk) begin
            //If oc_flag tripped keep tripped
           if (reset) begin
                oc_flag = 0;
                oc_timer = 0;
           end else if (oc_flag == 1) begin
                if (debounce == 27'd10_000_000) begin
                    oc_flag = 0;
                    debounce = 0;
                end
                else begin
                    oc_flag = 1;
                    debounce = debounce + 1;
                end
           end 
             //If oc_timer equals 1sec
           else if (oc_timer == 27'd100_000_000) begin // Check once a second with 100MHz timer
                if (sens == 1) begin //If sens pin is HIGH
                    if (debounce == 27'd10_000_000) begin //Wait 10msec to check again
                        if (sens == 1) begin //If sens pin still HIGH
                            debounce = 0;
                            oc_flag = 1; //Trip overcurrent flag
                        end
                    end
                    else begin
                        debounce = debounce + 1;
                    end
                end else begin 
                    oc_timer = 0;
                end
           end else begin
                oc_timer = oc_timer + 1; //If sens pin is LOW increment timer
           end
       end
endmodule

