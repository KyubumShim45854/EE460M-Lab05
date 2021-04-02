`timescale 1ns / 1ps
//Manages all of 7Seg
module SevenSegmentTotal(
    input [15:0] inVal,
    input reset, clk,altIn,
    output reg [3:0] an, //anode signal controller
    output reg [6:0] seg //LED signal controller
    );
    wire slow_clk;
    wire secondclk;
    reg [1:0] doublesec = 0;
    reg [15:0] sw=0;
    reg [3:0]tho;
    reg [3:0]hun;
    reg [3:0]ten;
    reg [3:0]one;
    reg [3:0]underBar= 4'b1010; 
    reg [3:0]clear=4'b1011;
    clkdiv divider(clk, reset,slow_clk);
  
    reg [2:0]anOrder;  
    reg [2:0] nextOrder;

   wire [6:0] data0;
   wire [6:0] data1;
   wire [6:0] data2;
   wire [6:0] data3;
 
   always@(inVal) begin
        tho=inVal/1000;
        hun=(inVal/100)%10;
        ten=(inVal/10)%10;
        one=inVal%10;
    end   
   
   always @ (posedge slow_clk) begin
        anOrder<=nextOrder;     
         begin
            sw[15:12]=tho;
            sw[11:8]=hun;
            sw[7:4]=ten;
            sw[3:0]=one;
            end
    end
    
    BCD bcd0(sw[15:12], data0);
   BCD bcd1(sw[11:8], data1);
   BCD bcd2(sw[7:4], data2);
   BCD bcd3(sw[3:0], data3);   
   
   
   //Cycle through the 4 digits by activating each an, update output seg 
    always @(*) begin
    
        case (anOrder)
            3'b000: begin
                an=4'b0111;//0th Activate
                seg<=data0;
                if (reset || altIn)  nextOrder=3'b111;
                else        nextOrder= 3'b100;
                end
                    
            3'b001: begin
                an=4'b1011; //1st Activate
                seg<=data1;
                if (reset || altIn)  nextOrder=3'b111;
                else        nextOrder=3'b101;
                end
                
             3'b010: begin
                an=4'b1101;//2nd Activate.
                seg<=data2;
                if (reset || altIn)  nextOrder=3'b111;
                else        nextOrder=3'b110;
                end
                    
            3'b011: begin
                an=4'b1110; //3rd Activate
                seg<=data3;
                if(reset || altIn)   nextOrder=3'b111;
                else        nextOrder=3'b111;
                end               
            
            3'b100: begin
                an=4'b1111; //no output
                seg<=data0;
                if (reset || altIn)  nextOrder=3'b111;
                else        nextOrder=3'b001;
                end
            3'b101: begin
                an=4'b1111; //no output
                seg<=data1;
                if (reset || altIn)  nextOrder=3'b111;
                else        nextOrder=3'b010;
                end
            3'b110: begin
                an=4'b1111; //no output
                seg<=data2;
                if (reset || altIn)  nextOrder=3'b111;
                else        nextOrder=3'b011;
                end
                
            3'b111: begin
                an=4'b1111; //no output
                seg<=data3;
                if (reset || altIn)  nextOrder=3'b111;
                else        nextOrder=3'b000;
                end
                  
            default: begin
                nextOrder=3'b000;
                an=4'b1111;
                seg<=clear;
            end 
        endcase        
        end
endmodule


`timescale 1ns / 1ps
module BCD(
    input [3:0]in,
    output [6:0]segment
    );
    
    reg [6:0]segData;
    assign segment=segData;
        
always@(*) begin    
    case (in) 
        4'b0000: segData = 7'b1000_000;
        4'b0001: segData = 7'b1111_001;
        4'b0010: segData = 7'b0100_100;
        4'b0011: segData = 7'b0110_000;
        4'b0100: segData = 7'b0011_001;
        4'b0101: segData = 7'b0010_010;
        4'b0110: segData = 7'b0000_010;
        4'b0111: segData = 7'b1111_000;
        4'b1000: segData = 7'b0000_000;
        4'b1001: segData = 7'b0010_000;
        4'b1010: segData=7'b1110_111;
        4'b1011: segData=7'b0000_000;
        default: segData=7'b0000001;

    endcase

 end       

endmodule

`timescale 1ns / 1ps
module clkdiv(
    input clk,
    input reset,
    output slow_clk
    );
    
    reg [5:0] count; //Div by 5 again
    assign slow_clk=~count[2];   
    initial  count = 5'b00000;
    
    always @ (posedge clk) begin
       if (reset) count<=5'b00000;  
        else if(count==5'b11111) count<=3'b00001;
        else count<=count+5'b001;
    end
endmodule