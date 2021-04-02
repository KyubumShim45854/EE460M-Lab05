`timescale 1ns / 1ps

module controller(clk, cs, we, address, data_in, data_out, btns, sw, leds, segs,an);
    input clk;
    output cs;
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
    ButtonFunctionallity btnAll(clk, btns[3],{mode,sel}); 
    
    //PLACEHOLDER
    reg [15:0] inVal;
    SevenSegmentTotal SST({8'h00,DVR}, 0, clk, 0, an, seg);
    
    reg [6:0]SPR=7'h7F;
    reg [6:0]DAR=7'h00;
    reg [7:0] DVR=8'h00;
    
    reg addOp=0;
    reg [1:0]waitB4=0;
    reg [3:0]state=0;
    reg [3:0]nextState=0;
    reg [7:0]tempReg1=0;
    reg [7:0]tempReg2=0;
    
       
    reg empty=0;
    assign leds[7]=empty;
    assign leds[6:0]=DAR[6:0];
    assign cs=0;
       
    
    always @ (posedge clk) begin
        state<=nextState;
        //Check if Empty
        empty<=(SPR==8'h7F)?1:0;       
    end
    
    always @ (*) begin
        we=0;
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
                    address<=DAR;             
                    if(!empty) begin
                        SPR<=SPR+1;
                        DAR<=SPR+2;
                    end
                end
                else begin
                    data_out<=0;
                    SPR<=SPR; //inc pointer
                    DAR<=DAR;
                end
                nextState<=mode;  //exit state                  
            end
            
            1: begin //Add/Sub
                address<=DAR;
                DVR<=data_in;
                nextState<=4;       // wait->pop->wait->calc
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
                address<=DAR;
                DVR<=data_in;
                if(sel==1) DAR<=SPR+1;
                else if(sel==2) begin
                     SPR<=8'h7F;
                     DAR<=0;
                     DVR<=0;
                end
                nextState<=mode; //Exit state
            end
            
            3: begin//Inc/Dec Adder
                DVR<=data_in;
                address<=DAR;
                state<=3;
                if(sel==1) DAR<=DAR+1;  //Inc adder
                else if(sel==2) DAR<=DAR-1; //Dec adder
                nextState<=mode;  //exit
            end
           
            4: begin //calc: order->(wait)->pop->(wait)->pop->(wait)->CALC->(wait)->mode
                if(!waitB4)nextState<=5;
                else if(waitB4==1) nextState<=6;
                else  if(waitB4==2)nextState<=7;
                else begin nextState<=0; waitB4<=0; end
                waitB4<=waitB4+1;
            end
            5: begin//calc: (pop)->wait->pop->wait->CALC
                tempReg1<=data_in;
                SPR<=SPR+1;
                DAR<=DAR+1;
                address<=DAR+1;
                nextState<=4;
            end                                            
            6: begin //calc: pop->wait->(pop)->wait->CALC
                tempReg2<=data_in;
                SPR<=SPR+1;
                nextState<=4;
            end
            7: begin      //calc: pop->wait->(pop)->wait->CALC)->wait->mode              
                we=1;
                address<=SPR;
                if(addOp) data_out<=tempReg1+tempReg2; //add
                else data_out<=tempReg1-tempReg2;       //sub
                SPR<=SPR-1;                                     
                nextState<=mode;
            end

            default: begin
                we=0;
                address<=0;
                SPR<=0;
                DAR<=0;
                DVR<=0;
                nextState<=0;
            end                    
    
    endcase
end
endmodule


