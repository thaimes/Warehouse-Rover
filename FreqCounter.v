`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/18/2024 12:57:18 PM
// Design Name: 
// Module Name: FreqCounter
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


module FreqCounter(
	input clk, signal, reset,
	output reg [31:0] frequency,
	output reg done);
	
	reg[31:0] counter =0;
	reg[31:0] freq_counter=0;
	reg pre_signal;
	reg pre_pre_signal;
	
	initial begin {frequency, counter,done} = 0; end
	
	always @ (posedge clk) begin
	
	if(reset) begin
	frequency = 0;
	counter=0;
	done=0;
	
	end
	
	counter=counter+1;
	pre_signal<= signal;
	pre_pre_signal<=pre_signal;
	done=0;
	
	if(pre_signal != pre_pre_signal) begin
	freq_counter=freq_counter+1;end
	
	if(counter>=12_500_000) begin
	counter=0;
	frequency=freq_counter;
	freq_counter=0;
	done=1;
	end
	
	end
	
endmodule
