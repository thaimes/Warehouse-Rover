    `timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/23/2024 06:50:21 PM
// Design Name: 
// Module Name: Top
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

module Top(
    //General inputs
    input clk,
    input [7:0] SW,
    input reset,
    //Overcurrent
    input sens,
    //Distance
    input disF,
    input disB,
    //Box
    input BOX,
    //Color
    input signal,
    //IPS line following
    input IPS_F,
    input IPS_L,
    input IPS_R,
    input IPS_TR,
    input IPS_TL,
    //IR Reciever
    input isig,
    //Motor movement
    output reg FORA,
    output reg BCKA,
    output reg FORB,
    output reg BCKB,
    output ENA,
    output ENB,
    //Color
    output s2, s3,
    //Storage
    output reg [7:0] led,
    output reg [1:0] spot,
    //IR Reciever
    output reg IWHITE,
    output reg IRED,
    output reg IGREEN,
    output reg IBLUE,
    //Forced motor output
    output reg drop

);
    wire PWM;                                       //Motor speed
    wire oc_flag;                                   //Overcurrent flag
    wire detF, detB;                                //IR distance
    wire FORA_IPS, BCKA_IPS, FORB_IPS, BCKB_IPS;    //Motor direction
    reg L, R;                                       //Enable turn register
    wire ER, EL;                                    //Enable turn wire
    reg TL, TR;                                     //Currently turning register
    wire ETL, ETR;                                  //Currently turning wire
    reg AL, AR;                                     //Enable line adjust register
    wire EAL, EAR;                                  //Enable line adjust wire
    reg FLIP;                                       //Turn around register
    wire EFLIP;                                     //Turn around wire
    reg FOR, REV;                                   //Forward & Reverse registers
    wire EFOR, EREV;                                 //Forward & Reverse wires
    wire led, IWHITE, IRED, IGREEN, IBLUE;          //IR reciever colors
    reg RED_LED, GREEN_LED, BLUE_LED, WHITE_LED;    //Color sensor registers
    wire RED, GREEN, BLUE, WHITE;                   //Color sensor wires
    reg [35:0] debounce;                            //SKIP debounce
    reg [35:0] revdeb;                              //REV debounce
    
    //ENABLES FOR NAVIGATION
    
    //TURN ENABLES
    assign EL = L;
    assign ER = R;

    //CURRENTLY TURNING
    assign ETL = TL;
    assign ETR = TR;
    
    //ADJUSTMENT ENABLE
    assign EAL = AL;
    assign EAR = AR;
    
    //180 TURN ENABLE
    assign EFLIP = FLIP;
    
    //FORWARD & REVERSE ENABLE
    assign EFOR = FOR;
    assign EREV = REV;
    
    // PWM generation
    PWMA pa (.clk(clk), .reset(reset), .SW(SW), .PWM(PWMA));
    PWMB pb (.clk(clk), .reset(reset), .SW(SW), .PWM(PWMB));
    
    // Distance sensing
    distance distance (
    .clk(clk),
    .reset(reset),
    .disF(disF),
    .disB(disB),
    .detF(detF),
    .detB(detB)
    );
    
    // Overcurrent protection
    Overcurrent oc_protection (
    .clk(clk), 
    .reset(reset), 
    .sens(sens), 
    .oc_flag(oc_flag)
    );
    
    //IPS line following
    IPS_Line ips_line (
        .clk(clk),
        .reset(reset),
        .IPS_F(IPS_F),
        .IPS_L(IPS_L),
        .IPS_R(IPS_R),
        .IPS_TR(IPS_TR),
        .IPS_TL(IPS_TL),
        .FORA(FORA_IPS),
        .BCKA(BCKA_IPS),
        .FORB(FORB_IPS),
        .BCKB(BCKB_IPS),
        .EFOR(EFOR),
        .EREV(EREV),
        .EL(EL),
        .ER(ER),
        .EAL(EAL),
        .EAR(EAR),
        .ETL(ETL),
        .ETR(ETR),
        .EFLIP(EFLIP)
    );
    
    //Color detection
    Color color (
        .clk(clk),
        .s2(s2),
        .s3(s3),
        .signal(signal),
        .WHITE_LED(WHITE),
        .RED_LED(RED),
        .GREEN_LED(GREEN),
        .BLUE_LED(BLUE),
        .led(led)
    );
    
    detect IR (
        .clk(clk),
        .isig(isig),
        .IWHITE(IWHITE),
        .IRED(IRED),
        .IGREEN(IGREEN),
        .IBLUE(IBLUE)
    );
    
    //START
    localparam START    = 5'd0;
    //ASSIGN COLOR
    localparam PRED     = 5'd1;         //If IR RED
    localparam PGREEN   = 5'd2;         //If IR GREEN
    localparam PBLUE    = 5'd3;         //If IR BLUE
    //TO PAD
    localparam ASSIGN   = 5'd4;         //ASSIGN PAD BASED ON POSITION
    localparam POS1     = 5'd5;         //No turn pad
    localparam POS2     = 5'd6;         //First right turn + pads
    localparam SKIP     = 5'd7;         //Skip line
    localparam POS3     = 5'd8;         //Third pad
    localparam RESTOCK  = 5'd9;         //Restock pad
    //TO DESK
    localparam DASSIGN  = 5'd10;        //ASSIGN PATH TO RETURN TO DESK
    localparam DPOS1    = 5'd11;        //Return from first pad
    localparam DPOS2    = 5'd12;        //Return from second pad
    localparam DPOS3    = 5'd13;        //Return from third pad
    //FROM RESTOCK
    localparam RASSIGN  = 5'd14;        //ASSIGN PATH FROM RESTOCK
    localparam RPOS1    = 5'd15;        //Restock to first pad
    localparam RPOS2    = 5'd16;        //Restock to second pad
    localparam RPOS3    = 5'd17;        //Restock to third pad
    //MISC
    localparam SPIN     = 5'd18;        //Back up and spin around
    localparam PICKUP   = 5'd19;        //Pickup box
    localparam DROPD    = 5'd20;        //Dropoff at desk
    localparam DROPR    = 5'd21;        //Dropoff after restock
    localparam END      = 5'd22;
    
    
    
    reg [5:0] state;
    reg pos1, pos2, pos3;
    reg restock;
    reg rpos1, rpos2, rpos3;
    reg dpos1, dpos2, dpos3;
    
    initial begin
        L = 0;
        R = 0;
        AL = 1;
        AR = 1;
        //Initially no positions
        pos1 = 0;
        pos2 = 0;
        pos3 = 0;
        restock = 0;
        FLIP = 0;
        debounce = 0;
        revdeb = 0;
        
    end
    
    always @(posedge clk) begin
    if (SW[0]) begin
        case(state)
            START: begin
            FOR = 0;
            REV = 0;
            //pos1 = 0;
            //pos2 = 0;
            //pos3 = 0;
            //state = ASSIGN;
            if (IRED) begin
                FOR = 1;
                state = PRED;
            end
            else if (IGREEN) begin
                FOR = 1;
                state = PGREEN;
            end 
            else if (IBLUE) begin
                FOR = 1;
                state = PBLUE;
            end
            else begin
                state = START;
            end
            end
            PRED: begin //Assign RED position
                FOR = 1;
                REV = 0;
                if (led[1:0] == 2'b01) begin
                    pos1 = 1;
                    pos2 = 0;
                    pos3 = 0;
                    spot [1:0] = 2'b01;
                    state = ASSIGN;
                end 
                else if (led[3:2] == 2'b01) begin
                    pos1 = 0;
                    pos2 = 1;
                    pos3 = 0;
                    spot [1:0] = 2'b10;
                    state = ASSIGN;
                end
                else if (led[5:4] == 2'b01) begin
                    pos1 = 0;
                    pos2 = 0;
                    pos3 = 1;
                    spot [1:0] = 2'b11;
                    state = ASSIGN;
                end
            end
            PGREEN: begin //Assign GREEN position
                FOR = 1;
                REV = 0;
                if (led [1:0] == 2'b10) begin
                    pos1 = 1;
                    pos2 = 0;
                    pos3 = 0;
                    spot = 2'b10;
                    state = ASSIGN;
                end 
                else if (led [3:2] == 2'b10) begin
                    pos1 = 0;
                    pos2 = 1;
                    pos3 = 0;
                    spot = 2'b10;
                    state = ASSIGN;
                end
                else if (led [5:4] == 2'b10) begin
                    pos1 = 0;
                    pos2 = 0;
                    pos3 = 1;
                    spot = 2'b10;
                    state = ASSIGN;
                end
            end
            PBLUE: begin //Assign BLUE position
                FOR = 1;
                REV = 0;
                if (led [1:0] == 2'b11) begin
                    pos1 = 1;
                    pos2 = 0;
                    pos3 = 0;
                    spot = 2'b01;
                    state = ASSIGN;
                end 
                else if (led [3:2] == 2'b11) begin
                    pos1 = 0;
                    pos2 = 1;
                    pos3 = 0;
                    spot = 2'b10;
                    state = ASSIGN;
                end
                else if (led [5:4] == 2'b11) begin
                    pos1 = 0;
                    pos2 = 0;
                    pos3 = 1;
                    spot = 2'b11;
                    state = ASSIGN;
                end
            end
////////////START NAVIGATION///////////////////////////////////////////////////////////////////////////////////////////////////
            ASSIGN: begin
                if (pos1 && ~pos2 && ~pos3) begin
                    state = POS1;
                end
                else if (~pos1 && pos2 && ~pos3 & ~restock || ~pos1 && ~pos2 && pos3 &&~restock
                ||~pos1 && ~pos2 && ~pos3 & restock ) begin
                    state = POS2; //ALL NEED FIRST RIGHT
                end
            end
            POS1: begin
            L = 0;
            R = 0;
            AL = 1;
            AR = 1;
            if (IPS_TR) begin
                AR = 0;
                state = SKIP;
            end
            else if (detF) begin
                dpos1 = 1;
                revdeb = 0;
                state = SPIN;
            end
            end
            POS2: begin
            if (pos2) begin
                L = 1;
                R = 1;
                AL = 1;
                AR = 1;
                if(detF) begin
                    dpos2 = 1;
                    revdeb = 0;
                    state = SPIN;
                end
            end
            else if (pos3) begin
                if (IPS_TL && L == 0 && TL == 0 && TR == 0) begin
                    AL = 0;
                    state = SKIP;
                end
                else begin
                    L = 0;
                    R = 1;
                    AR = 1;
                    AL = 1;
                end
            end
            
            else if (restock) begin
            if(IPS_TL && L == 0 && TL == 0 && TR == 0) begin
                    AL = 0;
                    state = SKIP;
                end
            
                else begin
                    L = 0;
                    R = 1;
                    AR = 1;
                    AL = 1;
                end
            end
            
                
             else begin 
                    L=1;
                    R=1;
                    AR=1;
                    AL=1;
                end
               
           
           end
           
            SKIP: begin
                if (debounce == 35'd50_000_000) begin
                    if (pos3) begin
                        if(IPS_TL) begin
                            state = POS3;
                        end
                    end
                    else if (pos1) begin
                        state = POS1;
                    end
                    else if (restock) begin
                        if(IPS_TL) begin
                            state = RESTOCK;
                        end
                    end
                    else if (dpos1) begin
                        state = DPOS1;
                    end
                end
                else begin
                    debounce = debounce + 1;        //Increment debounce
                    L = 0;                          //Disable left turn
                    R = 0;                          //Disable right turn
                end
          end
          
            POS3: begin
                R = 0;
                L = 1;
                AL = 1;
                AR = 1;
                if (detF) begin
                dpos3 = 1;
                    revdeb = 0;
                    state = SPIN;
                end
            end
            
            RESTOCK: begin
            //Desk to RESTOCK
            R=1;
            L=0;
            AL=1;
            AR=1;
            if (detF) begin
                if (pos1) begin
                    rpos1 = 1;
                    revdeb = 0;
                    state = SPIN;
                end
                else if (pos2) begin
                    rpos2 = 1;
                    revdeb = 0;
                    state = SPIN;
                end
                else if (pos3) begin
                    rpos3 = 1;
                    revdeb = 0;
                    state = SPIN;
                end
            end
            end
            
            DASSIGN: begin
            //Assign return to desk state
                if(~dpos2 && ~dpos3 && dpos1)begin
                    state=DPOS1;
                end    
                else if (~dpos1 && dpos2 && ~dpos3 || ~dpos1 && ~dpos2 && dpos3 )begin
                    state=DPOS2;
                end
            end
            
            DPOS1: begin
            //RETURN from PAD 1
            FOR = 1;
            REV = 0;
            L = 0;
            R = 0;
            AL = 1;
            AR = 1;
            if (IPS_TL) begin
                AL = 0;
                state = SKIP;
            end
            if (detF) begin
                state = DROPD;
            end
            end
            
            DPOS2: begin
            //RETURN from PAD 2 + start of 3
            
            end
            
            DPOS3: begin
            //RETURN from PAD 3
            
            end
            
            RASSIGN: begin
            //Assign RESTOCK state
            
            end
            
            RPOS1: begin
            //RESTOCK PAD 1 **INVERTED POS3**
            
            end
            
            RPOS2: begin
            //RESTOCK PAD 2 **INVERTED POS2**
            
            end
            
            RPOS3: begin
            //RESTOCK PAD 3 **INVERTED POS1**
            
            end
////////END NAVIGATION///////////////////////////////////////////////////////////////////////////////////////////////////
            SPIN: begin //SPIN STATE
            //Reverse for X time without regard to IPS sensors
                FOR = 0;
                REV = 1;
            //Start turn until IPS_F detected again after X time
                if (revdeb == 35'd250_000_000) begin
                    FLIP = 1;
                    FOR = 1;
                    REV = 0;
                    if (IPS_F) begin
                        FLIP = 0;
                    //If POS1 || POS2 || POS3 || RESTOCK -> PICKUP
                    if (pos1 || pos2 || pos3 || restock) begin
                        REV = 1;
                        state = PICKUP;
                    end
                    //If DPOS1 || DPOS2 || DPOS3 -> DASSIGN -> DROPD
                    else if (dpos1 || dpos2 || dpos3) begin
                        state = DASSIGN;
                    end
                    //If RPOS1 || RPOS2 || RPOS3 -> RASSIGN -> DROPR
                    else if (rpos1 || rpos2 || rpos3) begin
                        state = RASSIGN;
                    end
                    end
                end
                else begin
                    revdeb = revdeb + 1;
                end
            end
        
            PICKUP: begin //BOX PICKUP STATE
            //If box detected approach box
                if (detB) begin
                //Back up until box no longer detected
                    REV = 1;
                    FOR = 0;
                end
                else if (~detB && BOX) begin
                    REV = 0;
                    FOR = 1;
                //If POS1 || POS2 || POS3
                        if (pos1 || pos2 || pos3) begin
                            //State = RETURN from X position 
                            state = DASSIGN;
                        end
                //If RESTOCK
                        else if (dpos1 || dpos2 || dpos3) begin
                //State = RPOSX (where X is original position)
                            state = RASSIGN;
                        end
                end
            end
        
            DROPD: begin //BOX DROPOFF @ Desk
            //If no box
                if (detF) begin
                    FOR = 0;
                end
                if (~BOX) begin
                    state = SPIN;
                end
            end
            
            
            DROPR: begin //BOX DROPOFF @ PAD
                //If IPS_F not sensed
                if (~IPS_F) begin
                //Reverse for X time to drop off ON pad
                //Send signal to dropoff motor
                    if (~BOX) begin
                    //If no box
                        state = END;    //Unless we need to return to desk
                    end
                end
            end
            END: begin //END OF PROGRAM
                //STOP MOVING
                FOR = 0;
                REV = 0;
            end
        endcase
    end 
        FORA = FORA_IPS;
        BCKA = BCKA_IPS;
        FORB = FORB_IPS;
        BCKB = BCKB_IPS;
        
        
        WHITE_LED = WHITE;
        RED_LED = RED;
        GREEN_LED = GREEN;
        BLUE_LED = BLUE;
end

    assign ENA = PWMA && ~oc_flag;
    assign ENB = PWMB && ~oc_flag;
endmodule


