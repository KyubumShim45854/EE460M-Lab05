`timescale 1ns / 1ps
//Reads in btn, Debounces, returns values in up, down left right
module ButtonFunctionallity(
    input clk,
    input [3:0]btnIn,
    output [3:0]mode
    );
    wire A,B,C,D;
    ButtonInterface btnUp(clk, btnIn[3],A);
    ButtonInterface btnLeft(clk, btnIn[2],B);
    ButtonInterface btnRight(clk, btnIn[1],C);
    ButtonInterface btnDown(clk, btnIn[0],D);
    
    
    
    reg[3:0] result; //0:null, 1:push, 2:del...
    assign mode=result;
    reg A2,B2,C2,D2;
    wire newA,newB,newC,newD;
    assign newA = A2;
    assign newB = B2;
    assign newC = C2;
    assign newD = D2;
    clkDivFF u1(clk,debounceClk);
    always@(posedge debounceClk) begin
    A2 = A;
    B2 = B;
    C2 = C;
    D2 = D;
    end
    always @(posedge clk) begin
        result=0;       
        result=newA?result+4'b1000:result;
        result=newB?result+4'b0100:result;
        result=newC?result+4'b0010:result;
        result=newD?result+4'b0001:result;
    end
    
endmodule





module ButtonInterface(
    input clk, inVal,
    output outVal
    );
wire debounceClk;
wire Q1,Q2,Q0;
clkDivFF u1(clk,debounceClk);
//DebounceDelayFF d0(clk,debounceClk,inVal,Q0);

DebounceDelayFF d1(clk,debounceClk,inVal,Q1);
DebounceDelayFF d2(clk,debounceClk,Q1,Q2);

assign outVal = Q1 & ~Q2;
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



    