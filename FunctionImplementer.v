`timescale 1ns / 1ps

module controller(clk, cs, we, address, data_in, data_out, btns, sw, leds, segs,an);
    input clk;
    output  cs;
    output reg we;//Write eneable 0-read, 1-write
    output reg[6:0]  address; //Actual outgoing address
    input[7:0] data_in;
    output reg [7:0] data_out;  //Actual outgoing data
    input[3:0] btns;            //Buttons pass through ButtonFunctionallity to return mode and sel
    input[7:0] sw;              //Actual input values, MSB->LSB
    output[7:0] leds;           //empty, DAR[6:0]
    output[6:0] segs;           
    output[3:0] an;
    
    
    wire [1:0] mode;
    wire [1:0] sel;
    ButtonFunctionallity btnAll(clk, btns,{mode,sel}); 
    
    //PLACEHOLDER
    reg [15:0] inVal;
   
    
    reg [6:0]SPR=7'h7F;
    reg [6:0]DAR=7'h00;
    reg [7:0] DVR=8'h00;
     SevenSegmentTotal SST({8'h00,DVR}, 0, clk, 0, an, segs);
    
    reg addOp=0;
    reg [1:0]waitB4=0;
    reg [3:0]state=0;
    reg [3:0]nextState=0;
    reg [7:0]tempReg1=0;
    reg [7:0]tempReg2=0;
    
       
    reg empty=0;
    assign leds[7]=empty;
    assign leds[6:0]=DAR[6:0];
    assign cs=1;
       
     wire slow_clk;
   clkDivFF u1(clk,slow_clk);
 /*   always @ (posedge slow_clk) begin
        state<=nextState;
        //Check if Empty
        empty<=(SPR==8'h7F)?1:0;       
    end */
    
    always @ (posedge slow_clk) begin
        
        empty <= (SPR == 8'h7F)?1:0;
        we = 0;
        case (state)
            0: begin //Mode 00: Push/POP 
                DVR<=data_in;
                if(sel==1) begin //Push
                    we=1;
                    address<=SPR;
                    data_out<=sw;
                    SPR<=SPR-1; //inc pointer
                    DAR<=SPR; 
                end
                else if(sel==2) begin//Pop 
                 we = 0;  
                                 
                    if(!empty) begin
                        address<=DAR;
                        SPR<=SPR+1;
                        DAR<=SPR+2;
                    end
                end
                else begin
                    we =0;
                    data_out<=0;
                    SPR<=SPR; //inc pointer
                    DAR<=DAR;
                end
                state<=mode;  //exit state                  
            end
            
            1: begin //Add/Sub
                we = 0;
                address<=DAR;
                DVR<=data_in;
                state<=4;       // wait->pop->wait->calc
                if(sel==1) begin        //add
                    DAR<=SPR+1;
                    address<=SPR+1;
                    addOp<=1;          //add
                end
                else if(sel==2) begin   //sub
                    DAR<=SPR+1;
                    address<=SPR+1;
                    addOp<=0;      //sub
                end
                else state<=0;  //exit state
            end
            
            2: begin//top/clr
                we = 0;
                address<=DAR;
                DVR<=data_in;
                if(sel==1) DAR<=SPR+1;
                else if(sel==2) begin
                     SPR<=8'h7F;
                     DAR<=0;
                     DVR<=0;
                end
                state<=mode; //Exit state
            end
            
            3: begin//Inc/Dec Adder
                we = 0;
                DVR<=data_in;
                address<=DAR;
                state<=3;
                if(sel==1) DAR<=DAR+1;  //Inc adder
                else if(sel==2) DAR<=DAR-1; //Dec adder
                state<=mode;  //exit
            end
           
            4: begin //calc: order->(wait)->pop->(wait)->pop->(wait)->CALC->(wait)->mode
                we = 0;
                state<=5;
            end
            5: begin//calc: (pop)->wait->pop->wait->CALC
                we = 0;
                tempReg1<=data_in;
                SPR<=SPR+1;
                DAR<=DAR+1;
                address<=DAR+1;
                state<=8;
            end                                            
            6: begin //calc: pop->wait->(pop)->wait->CALC
                we = 0;
                tempReg2<=data_in;
                SPR<=SPR+1;
                state<=9;
            end
            7: begin      //calc: pop->wait->(pop)->wait->CALC)->wait->mode              
                we=1;
                address<=SPR;
                if(addOp) data_out<=tempReg1+tempReg2; //add
                else data_out<=tempReg1-tempReg2;       //sub
                SPR<=SPR-1;                                     
                state<=mode;
            end
            8: state <= 6;
            9: state <= 7;
           
            default: begin
                we=0;
                address<=0;
                SPR<=0;
                DAR<=0;
                DVR<=0;
                state<=0;
            end                    
    
    endcase
end
endmodule


