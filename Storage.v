`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/18/2024 03:34:48 PM
// Design Name: 
// Module Name: c_store
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


module c_store(
    input clk,
    input RED,
    input GREEN,
    input BLUE,
    output reg [1:0] pos1, pos2, pos3
    );
    /*
    RED   = 01
    GREEN = 10
    BLUE  = 11
    pos[1] = [xx]
    pos[2] = [yy]
    pos[3] = [zz]
    */
   
   reg [1:0] state;
   
   
   initial begin
    pos1 = 2'b00;
    pos2 = 2'b00;
    pos3 = 2'b00;
   end
   
   localparam IDLE = 2'b00;
   localparam R = 2'b01;
   localparam G = 2'b10;
   localparam B = 2'b11;
   
   always @(posedge clk) begin
   //If RED detected and is not currently in use
    if (RED && pos1 != 2'b01 && pos2 != 2'b01 && pos3 != 2'b01) begin
        state = R;
    end 
   //If GREEN detected and is not currently in use
    else if (GREEN && pos1 != 2'b10 && pos2 != 2'b10 && pos3 != 2'b10
    ) begin
        state = G;
    end
   //If BLUE detected and is not currently in use
    else if (BLUE && pos1 != 2'b11 && pos2 != 2'b11 && pos3 != 2'b11
    ) begin
        state = B;
    end
    //If BGRG
    else if (GREEN && pos1 == 2'b11 && pos2 == 2'b10 && pos3 == 2'b01) begin
        pos1 = 2'b11;
        pos2 = 2'b01;
        pos3 = 2'b10;
    end
    //If BGRB
    else if (BLUE && pos1 == 2'b11 && pos2 == 2'b10 && pos3 == 2'b01) begin
        pos1 = 2'b10;
        pos2 = 2'b01;
        pos3 = 2'b11;
    end
    //If BGBR
    else if (BLUE && pos1 == 2'b11 && pos2 == 2'b10 && pos3 == 2'b00) begin
        pos1 = 2'b10;
        pos2 = 2'b11;
    end
    else begin
        state = IDLE;
    end

   
//   always @ (posedge clk) begin
    case (state)
        R: begin
            //pos[x] = 01
            if (pos1 == 2'b00) begin      //If position 1 not populated
                pos1 <= 2'b01;
            end
            else if (pos2 == 2'b00) begin //If position 2 not populated
                pos2 <= 2'b01;
            end
            else if (pos3 == 2'b00) begin                      //If position 3 not populated
                pos3 <= 2'b01;
            end
        end
        G: begin
            //pos[x] = 10
            if (pos1 == 2'b00) begin      //If position 1 not populated
                pos1 <= 2'b10;
            end
            else if (pos2 == 2'b00) begin //If position 2 not populated
                pos2 <= 2'b10;
            end
            else if (pos3 == 2'b00) begin                      //If position 3 not populated
                pos3 <= 2'b10;
            end
        end
        B: begin
            //pos[x] = 11
            if (pos1 == 2'b00) begin      //If position 1 not populated
                pos1 <= 2'b11;
            end
            else if (pos2 == 2'b00) begin //If position 2 not populated
                pos2 <= 2'b11;
            end
            else if (pos3 == 2'b00) begin                      //If position 3 not populated
                pos3 <= 2'b11;
            end
        end
    endcase
   end
endmodule