`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Module Name: test
// Module Description: link the pattern and the design in simulation
// Project Name: final project of NYCU CS DSD course 
// 
// Company: Institute of Electronics, National Yang Ming Chiao Tung University 
// Engineer: Yi-Ting,Wu
//
//////////////////////////////////////////////////////////////////////////////////


module test;
//internal wire declaration
wire              game_set;
wire              player_1_done;
wire              player_2_done;
wire              player_1_win;
wire              player_2_win;
wire  [8:0]       player_1_pt;
wire  [8:0]       player_2_pt;
wire              dart_come;
wire  [7:0]       dart_position_x;
wire  [7:0]       dart_position_y;
wire              clk;
wire              reset;

//submodule declaration
dart d1     (
             .game_set_o(game_set),
             .player_1_done_o(player_1_done),
             .player_2_done_o(player_2_done),
             .player_1_win_o(player_1_win),
             .player_2_win_o(player_2_win),
             .player_1_pt_o(player_1_pt),
             .player_2_pt_o(player_2_pt),
             .dart_come_i(dart_come),
             .dart_position_x_i(dart_position_x),
             .dart_position_y_i(dart_position_y),
             .clk(clk),
             .reset(reset)
             );
             
pattern p1  (
             .dart_come_o(dart_come),
             .dart_position_x_o(dart_position_x),
             .dart_position_y_o(dart_position_y),
             .game_set_i(game_set),
             .player_1_done_i(player_1_done),
             .player_2_done_i(player_2_done),
             .player_1_win_i(player_1_win),
             .player_2_win_i(player_2_win),
             .player_1_pt_i(player_1_pt),
             .player_2_pt_i(player_2_pt),
             .clk(clk),
             .reset(reset)
             );

endmodule
