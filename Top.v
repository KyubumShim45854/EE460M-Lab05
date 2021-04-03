`timescale 1ns / 1ps
module top(clk, btns, swtchs, leds, segs, an);
    input clk;
    input[3:0] btns;
    input[7:0] swtchs;
    output[7:0] leds;
    output[6:0] segs;
    output[3:0] an;
    //might need to change some of these from wires to regs
   
    wire we;
    wire cs;
    wire[6:0] addr;
    wire[7:0] data_out_mem;
    wire[7:0] data_out_ctrl;
    wire[7:0] data_bus;
    //CHANGE THESE TWO LINES
    assign data_bus = we?data_out_ctrl: 8'bzzzz_zzzz; // 1st driver of the data bus -- tri state switches
    // function of we and data_out_ctrl
    assign data_bus = we?8'bzzzz_zzzz:data_out_mem; // 2nd driver of the data bus -- tri state switches
    // function of we and data_out_mem
    controller ctrl(clk, cs, we, addr, data_bus, data_out_ctrl, btns, swtchs, leds, segs, an);
    memory mem(clk, cs, we, addr, data_bus, data_out_mem);
    //add any other functions you need
    //(e.g. debouncing, multiplexing, clock-division, etc)
endmodule


module memory(clock, cs, we, address, data_in, data_out);
    input clock;
    input cs;
    input we;
    input[6:0] address;
    input[7:0] data_in;
    output[7:0] data_out;
    reg[7:0] data_out;
    reg[7:0] RAM[0:127];
    
    always @ (negedge clock)    begin
        if((we == 1) && (cs == 1))
        RAM[address] <= data_in[7:0];
        data_out <= RAM[address];
    end
endmodule