`timescale 1ns / 1ps
//Reads in btn, Debounces, returns values in up, down left right
module ButtonFunctionallity(
    input clk,
    input [3:0]btnIn,
    output [3:0]mode
    );
    wire A,B,C,D,A2,B2,C2,D2,A1,B1,C1,D1;
    ButtonInterface btnUp(clk, btnIn[3],A1,A2);
    ButtonInterface btnLeft(clk, btnIn[2],B1,B2);
    ButtonInterface btnRight(clk, btnIn[1],C1,C2);
    ButtonInterface btnDown(clk, btnIn[0],D1,D2);
    
   
    
    
    
    reg[3:0] result; //0:null, 1:push, 2:del...
    assign mode=result;
  
    always @(posedge clk) begin
        case({A1,B1,C2,D2})
        4'b0000: result <=4'b0000;
        4'b0001: result <=4'b0001;
        4'b0010: result <=4'b0010;
        4'b1000: result <= 4'b1000;
        4'b1001: result <= 4'b1001;
        4'b1010: result <= 4'b1010;
        4'b0100: result <= 4'b0100;
        4'b0101: result <= 4'b0101;
        4'b0110: result <= 4'b0110;
        4'b1100: result <=4'b1100;
        4'b1101: result <= 4'b1101;
        4'b1110: result <= 4'b1110;
        default: result <= 4'b0000;
        endcase
        
    end
    
endmodule





module ButtonInterface(
    input clk, inVal,
    output outVal1, outVal2
    );
wire debounceClk;
wire Q1,Q2,Q0;
clkDivFF u1(clk,debounceClk);
//DebounceDelayFF d0(clk,debounceClk,inVal,Q0);

DebounceDelayFF d1(clk,debounceClk,inVal,Q1);
DebounceDelayFF d2(clk,debounceClk,Q1,Q2);

assign outVal2 = Q1 & ~Q2;
assign outVal1 = Q2;
endmodule
// Slow clock enable for debouncing button 
module clkDivFF(input clk,output debounceClk);
    reg [25:0]count=0;
    always @(posedge clk)
    begin
       count <= (count>=250_000)?26'b0:count+26'b1;
    end
    assign debounceClk = (count == 250_000)?1'b1:1'b0;
endmodule
// D-flip-flop with clock enable signal for debouncing module 
module DebounceDelayFF(input clk, debounceClk,inVal,
    output outVal
    );
    reg Q=0;
    assign outVal=Q;
    always @ (posedge clk) begin
        if(debounceClk==1) Q <= inVal;
         end
endmodule 



    