`timescale 1ns / 1ps


module IR_Freq(
	input clk, isig, reset,
	output reg [31:0] frequency,
	output reg done);
	
	reg[31:0] counter =0;
	reg[31:0] freq_counter=0;
	reg pre_signal = 0;
	reg pre_pre_signal = 0;
	
	initial begin {frequency, counter,done} = 0; end
	
	always @ (posedge clk) begin
	
	if(reset) begin
	frequency = 0;
	counter=0;
	done=0;
	
	end
	
	counter=counter+1;
pre_pre_signal = pre_signal;
	pre_signal = isig;
	done=0;
	
	if(pre_signal != pre_pre_signal) begin
	freq_counter=freq_counter+1;end
	
	if(counter>=50_000_000) begin
	counter=0;
	frequency=freq_counter;
	freq_counter=0;
	done=1;
	end
	
	end
	
endmodule