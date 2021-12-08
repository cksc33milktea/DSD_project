`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Module Name: pattern
// Module Description: generate the test pattern
// Project Name: final project of NYCU CS DSD course 
// 
// Company: Institute of Electronics, National Yang Ming Chiao Tung University 
// Engineer: Yi-Ting,Wu
//
//////////////////////////////////////////////////////////////////////////////////


module pattern(
               dart_come_o,
               dart_position_x_o,
               dart_position_y_o,
               game_set_i,
               player_1_done_i,
               player_2_done_i,
               player_1_win_i,
               player_2_win_i,
               player_1_pt_i,
               player_2_pt_i,
               clk,
               reset
               );
//port declaration
output               dart_come_o;
output  [7:0]        dart_position_x_o;
output  [7:0]        dart_position_y_o;
output               clk;
output               reset;
input                game_set_i;
input                player_1_done_i;
input                player_2_done_i;
input                player_1_win_i;
input                player_2_win_i;
input  [8:0]         player_1_pt_i;
input  [8:0]         player_2_pt_i;

//output reg declaration
reg                  dart_come_o;
reg     [7:0]        dart_position_x_o;
reg     [7:0]        dart_position_y_o;
reg                  clk;
reg                  reset;

initial clk=1'b0;//initialize clk

initial begin //system reset for first 100ns
    reset=1'b0;
    #100 reset=1'b1;
end

initial dart_come_o=1'b1;//initialize dart come
initial dart_position_x_o=9'd15;//initialize dart x position
initial dart_position_y_o=9'd29;//initialize dart y position

always #10 clk=~clk;//generate a 50MHz system clk without clock jitter

endmodule
