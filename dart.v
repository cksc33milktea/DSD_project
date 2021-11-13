`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Module Name: dart
// Module Description: model the dart machine
// Project Name: final project of NYCU CS DSD course 
// 
// Company: Institute of Electronics, National Yang Ming Chiao Tung University 
// Engineer: Yi Ting,Wu
//
//////////////////////////////////////////////////////////////////////////////////


module dart(
            game_set_o,//high when someone's point reach 0
            player_1_done_o,//high when player1's turn ends
            player_2_done_o,//high when player2's turn ends
            player_1_win_o,//high when player1's point reach 0
            player_2_win_o,//high when player2's point reach 0
            dart_come_i,//high when the dart comes
            dart_position_x_i,//dart x position
            dart_position_y_i,//dart y position
            clk,
            reset
            );
//assign numbers to the states of finite state machine
parameter [3:0] START         =4'b0000;//start
parameter [3:0] INITIALIZE    =4'b0001;//initialize player1's and player2's point to 501
parameter [3:0] IDLE_1        =4'b0010;//wait player1's dart coming
parameter [3:0] TOUCH_1       =4'b0011;//use the position to get the point by LUT
parameter [3:0] COUNT_1       =4'b0100;//minus player1's point ,and then see if it is smaller than 0
parameter [3:0] COMPARE_1     =4'b0101;//not used
parameter [3:0] PLAYER_1_DONE =4'b0110;//let pattern to know player1's round is finished
parameter [3:0] IDLE_2        =4'b0111;//wait player2's dart coming
parameter [3:0] TOUCH_2       =4'b1000;//use the position to get the point by LUT
parameter [3:0] COUNT_2       =4'b1001;//minus player2's point ,and then see if it is smaller than 0
parameter [3:0] COMPARE_2     =4'b1010;//not used
parameter [3:0] PLAYER_2_DONE =4'b1011;//let pattern to know player2's round is finished
parameter [3:0] RESULT        =4'b1100;//output result
parameter [3:0] FINISH        =4'b1101;//finish ,wait for reset

//port declaration
output              game_set_o;
output              player_1_done_o;
output              player_2_done_o;
output              player_1_win_o;
output              player_2_win_o;
input               dart_come_i;
input  [3:0]        dart_position_x_i;
input  [3:0]        dart_position_y_i;
input               clk;
input               reset;

//output reg declaration

//internal reg declaration
reg  [3:0]          state;//current state
reg  [3:0]          next_state;//next state
reg  [9-1:0]        player_1_point;//player1's point
reg  [9-1:0]        player_2_point;//player2's point
reg  [9-1:0]        dart_point;//dart point ,obtained by LUT

//internal wire declaration
wire  [9-1:0]       point_table[0:9][0:9];//10x10 LUT
wire  [100*9-1:0]   temp_table;//used to build LUT ,ignore it 
                              
//ouput wire assignment
assign player_1_done_o=(state==PLAYER_1_DONE)?1'b1:1'b0;
assign player_2_done_o=(state==PLAYER_2_DONE)?1'b1:1'b0;
assign player_1_win_o=(player_1_point==9'd0)?1'b1:1'b0;
assign player_2_win_o=(player_2_point==9'd0)?1'b1:1'b0;
assign game_set_o=(next_state==RESULT)?1'b1:1'b0;

//internal wire assignment
assign temp_table={     9'd0,  9'd0,  9'd0,  9'd0,  9'd0,  9'd0,  9'd0,  9'd0,  9'd0,  9'd0,
                        9'd0,  9'd0,  9'd12, 9'd5,  9'd20, 9'd20, 9'd1,  9'd18, 9'd0,  9'd0,
                        9'd0,  9'd9,  9'd12, 9'd12, 9'd5,  9'd1,  9'd18, 9'd4,  9'd4,  9'd0,
                        9'd0,  9'd14, 9'd9,  9'd12, 9'd5,  9'd1,  9'd4,  9'd4,  9'd13, 9'd0,
                        9'd0,  9'd11, 9'd14, 9'd14, 9'd12, 9'd4,  9'd13, 9'd13, 9'd6,  9'd0,
                        9'd0,  9'd11, 9'd8,  9'd8,  9'd16, 9'd2,  9'd10, 9'd10, 9'd6,  9'd0,
                        9'd0,  9'd8,  9'd16, 9'd16, 9'd19, 9'd17, 9'd2,  9'd15, 9'd10, 9'd0,
                        9'd0,  9'd16, 9'd16, 9'd7,  9'd19, 9'd17, 9'd2,  9'd2,  9'd15, 9'd0,
                        9'd0,  9'd0,  9'd7,  9'd19, 9'd3,  9'd3,  9'd17, 9'd2,  9'd0,  9'd0,
                        9'd0,  9'd0,  9'd0,  9'd0,  9'd0,  9'd0,  9'd0,  9'd0,  9'd0,  9'd0,};
genvar i;
generate//used to build LUT ,ignore it
    for(i=0; i<10; i=i+1) begin 
        assign point_table[0][i]=temp_table[899-i*9:891-i*9];
        assign point_table[1][i]=temp_table[809-i*9:801-i*9];
        assign point_table[2][i]=temp_table[719-i*9:711-i*9];
        assign point_table[3][i]=temp_table[629-i*9:621-i*9];
        assign point_table[4][i]=temp_table[539-i*9:531-i*9];
        assign point_table[5][i]=temp_table[449-i*9:441-i*9];
        assign point_table[6][i]=temp_table[359-i*9:351-i*9];
        assign point_table[7][i]=temp_table[269-i*9:261-i*9];
        assign point_table[8][i]=temp_table[179-i*9:171-i*9];
        assign point_table[9][i]=temp_table[89-i*9:81-i*9];
    end
endgenerate

always@(*)begin//FSM next state assignment
    case (state)
        START:
            next_state=INITIALIZE;
        INITIALIZE:
            next_state=IDLE_1;
        IDLE_1:
            if(dart_come_i)next_state=TOUCH_1;
            else next_state=IDLE_1;
        TOUCH_1:
            next_state=COUNT_1;
        COUNT_1:
            next_state=PLAYER_1_DONE;
        PLAYER_1_DONE:
            if(player_1_win_o)next_state=RESULT;
            else next_state=IDLE_2;
        IDLE_2:
            if(dart_come_i)next_state=TOUCH_2;
            else next_state=IDLE_2;
        TOUCH_2:
            next_state=COUNT_2;
        COUNT_2:
            next_state=PLAYER_2_DONE;
        PLAYER_2_DONE:
            if(player_2_win_o)next_state=RESULT;
            else next_state=IDLE_1;
        RESULT:
            next_state=FINISH;
        FINISH:
            next_state=FINISH;
        default:
            next_state=START;
    endcase
end

always@(posedge clk)begin//update state
    if(~reset)state<=START;
    else state<=next_state;
end

always@(posedge clk)begin//get the dart point
    if(~reset)dart_point<=9'd0;
    else if(state==TOUCH_1||state==TOUCH_2)dart_point<=point_table[dart_position_y_i][dart_position_x_i];
    else dart_point<=dart_point;
end

always@(posedge clk)begin//update player1's point
    if(~reset)player_1_point<=9'd0;
    else if(state==INITIALIZE)player_1_point<=9'd501;
    else if(state==COUNT_1)player_1_point<=(player_1_point>=dart_point)?player_1_point-dart_point:player_1_point;
    else player_1_point<=player_1_point;
end

always@(posedge clk)begin//update player2's point
    if(~reset)player_2_point<=9'd0;
    else if(state==INITIALIZE)player_2_point<=9'd501;
    else if(state==COUNT_2)player_2_point<=(player_2_point>=dart_point)?player_2_point-dart_point:player_2_point;
    else player_2_point<=player_2_point;
end

endmodule

