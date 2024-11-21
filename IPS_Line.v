`timescale 1ns / 1ps

module IPS_Line(
    input clk,
    input reset,
    input IPS_F,
    input IPS_L,
    input IPS_R,
    input IPS_TR,
    input IPS_TL,
    input EFOR,
    input EREV,
    input EL,
    input ER,
    input EAL,
    input EAR,
    input EFLIP,
    output ETL,
    output ETR,
    output reg FORA,
    output reg BCKA,
    output reg FORB,
    output reg BCKB
);
   
    localparam IDLE = 3'b000;
    localparam FORWARD = 3'b001;
    localparam ARIGHT = 3'b010;
    localparam ALEFT = 3'b011;
    localparam RIGHT = 3'b100;
    localparam LEFT = 3'b101;
    localparam SPIN = 3'b110;
    localparam REVERSE = 3'b111;
    
    reg FOR, REV;
    reg L, R;
    reg TL, TR;
    reg AL, AR;
    reg FLIP;
    reg right=0;
    reg left=0;
    reg [3:0] state;
    
    assign EFOR = FOR;
    assign EREV = REV;
    
    assign EL = L;
    assign ER = R;
    
    assign ETL = TL;
    assign ETR = TR;
    
    assign EAL = AL;
    assign EAR = AR;
    
    assign EFLIP = FLIP;
    
    always @ (posedge clk) begin
        if (reset) begin
            state = IDLE;
        end
        else begin
            case (state)
                IDLE: begin
                    TL = 0;
                    TR = 0;
                    FORA = 0;
                    FORB = 0;
                    BCKA = 0;
                    BCKB = 0;
                    if (IPS_F && FOR && ~REV) begin
                        state = FORWARD;
                    end
                    else if (IPS_F && ~FOR && ~REV) begin
                        state = IDLE;
                    end
                    else if (FLIP) begin
                        state = SPIN;
                    end
                    else if (REV) begin
                        state = REVERSE;
                    end
//                    else if (IPS_TR) begin
//                        state = RIGHT;
//                    end
//                    else if (IPS_TL) begin
//                        state = LEFT;
//                    end
                end
                FORWARD: begin
                    TL = 0;
                    TR = 0;
                    FORA = 1;
                    FORB = 1;
                    BCKA = 0;
                    BCKB = 0;
                    if (~IPS_F) begin
                        state = IDLE;
                    end
                    else if (IPS_TR && R == 1) begin
                        state = RIGHT;
                    end 
                    else if (IPS_TL && L == 1) begin
                        state = LEFT;
                    end
                    else if (IPS_R && AR == 1) begin
                        state = ARIGHT;
                    end
                    else if (IPS_L && AL == 1) begin
                        state = ALEFT;
                    end
                end
                ARIGHT: begin
                    FORA = 1;
                    FORB = 0;
                    BCKA = 0;
                    BCKB = 1;
                    if (IPS_F && ~IPS_R) begin
                        state = IDLE;
                    end
                end
                ALEFT: begin
                    FORA = 0;
                    FORB = 1;
                    BCKA = 1;
                    BCKB = 0;
                    if (IPS_F && ~IPS_L) begin
                        state = IDLE;
                    end
                end
                RIGHT: begin
                    //Turn right
                    TR = 1;
                    TL = 0;
                    FORA = 1;
                    FORB = 0;
                    BCKA = 0;
                    BCKB = 1;
                    //If IPS_F detected without turn IPS go FORWARD
                    if (IPS_F && ~IPS_L && ~IPS_TL && ~IPS_TR) begin
                        state = IDLE;
                    end
                    //If IPS_TL move forward slightly
                    if (IPS_TL) begin
                        FORA = 1;
                        FORB = 1;
                        BCKA = 0;
                        BCKB = 0;
                        state = RIGHT;
                    end

                end
                LEFT: begin
                    //Left turn
                    TR = 0;
                    TL = 1;
                    FORA = 0;
                    FORB = 1;
                    BCKA = 1;
                    BCKB = 0;
                    //If IPS_F detected without turn IPS go FORWARD
                    if (IPS_F && ~IPS_R && ~IPS_TR && ~IPS_TL) begin
                        state = IDLE;
                    end
                    //If IPS_TR move forward slightly
                    if (IPS_TR) begin
                        FORA = 1;
                        FORB = 1;
                        BCKA = 0;
                        BCKA = 0;
                        state = LEFT;
                    end
                 end
                 SPIN: begin
                 //180 degree turn
                 TR = 1;
                 TL = 0;
                 FORA = 1;
                 FORB = 0;
                 BCKA = 0;
                 BCKB = 1;
                 if (IPS_F) begin
                    state = IDLE;
                 end
                 end
                 
                 REVERSE: begin
                 //Reverse
                 FORA = 0;
                 FORB = 0;
                 BCKA = 1;
                 BCKB = 1;
                 if (REV == 0) begin
                    state = IDLE;
                 end
                 end
            endcase
    end
    end
endmodule
