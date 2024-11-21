`timescale 1ns / 1ps



module detect(
input clk,
input isig,


//LED outputs
output reg IRED, 
output reg IGREEN, 
output reg IBLUE, 
output reg IWHITE


    );
    
   wire [31:0] freq1;
   wire done;
   reg reset=0;
   
    IR_Freq Freq(.clk(clk), .isig(isig), .frequency(freq1), .done(done), .reset(rst));
   
 //Set frequencies
   reg[31:0] Redd=0;
   reg [31:0] Bluee=0;
   reg [31:0] Greenn=0;
   reg [1:0] statee=0;
   reg [1:0] detected= 0; 
   reg [1:0] sa;
   reg [1:0] sb;

initial begin
      sa=statee[1];
      sb=statee[0];
    end
    
     always @ (posedge done) begin
     if(!detected) begin
     case (statee)
     
      2'b01:begin
     Bluee=freq1;
     end
     2'b00:begin
      Redd=freq1;
      end
    2'b11: begin
       Greenn=freq1;
       end
       
     2'b10: begin
                if(Redd>800 & Redd<1200) begin
        IRED=1; 
        IBLUE=0; 
        IGREEN=0; 
        IWHITE=0;
        detected=1;
        #200;
        end 
        
        else if (Bluee>2800 & Bluee<3200) begin
        IBLUE=1; 
        IRED=0; 
        IGREEN=0; 
        IWHITE=0;
        detected=1;
        #200;
        end
        
        else if (Greenn >1800 & Greenn<2300) begin
        IGREEN=1; 
        IRED=0; 
        IBLUE=0; 
        IWHITE=0;
        detected=1;
        end
        
        else begin
        IWHITE=1; 
        IRED=0;
        IGREEN=0; 
        IBLUE=0;
         detected=0;
        end 
     end
       endcase
     end

       statee=statee+1;
       
 
      end
endmodule