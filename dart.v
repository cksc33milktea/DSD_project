`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Module Name: dart
// Module Description: model the dart machine
// Project Name: final project of NYCU CS DSD course 
// 
// Company: Institute of Electronics, National Yang Ming Chiao Tung University 
// Engineer: Yi-Ting,Wu
//
//////////////////////////////////////////////////////////////////////////////////


module dart(
            game_set_o,//hi when someone's point reach 0
            player_1_done_o,//hi when player1's turn ends
            player_2_done_o,//hi when player2's turn ends
            player_1_win_o,//hi when player1's point reach 0
            player_2_win_o,//hi when player2's point reach 0
            player_1_pt_o,
            player_2_pt_o,
            dart_come_i,//hi when the dart comes
            dart_position_x_i,//dart x position
            dart_position_y_i,//dart y position
            clk,
            reset
            );
//assign numbers to the states of finite state machine
parameter [3:0] START         =4'b0000;//start
parameter [3:0] INITIALIZE    =4'b0001;//initialize player1's and player2's point to 501
parameter [3:0] IDLE          =4'b0010;//wait player's dart coming
parameter [3:0] TOUCH         =4'b0011;//use the position to get the point by LUT
parameter [3:0] COUNT         =4'b0100;//minus player's point, and see if it is smaller than 0
parameter [3:0] COMPARE       =4'b0101;//not used
parameter [3:0] PLAYER_DONE   =4'b0110;//let pattern to know player's throw is finished
parameter [3:0] RESULT        =4'b1100;//output result
parameter [3:0] FINISH        =4'b1101;//finish, wait for reset

//port declaration
output              game_set_o;
output              player_1_done_o;
output              player_2_done_o;
output              player_1_win_o;
output              player_2_win_o;
output [8:0]        player_1_pt_o;
output [8:0]        player_2_pt_o;
input               dart_come_i;
input  [7:0]        dart_position_x_i;
input  [7:0]        dart_position_y_i;
input               clk;
input               reset;

//output reg declaration

//internal reg declaration
reg  [3:0]          state;//current state
reg  [3:0]          next_state;//next state
reg  [9-1:0]        player_1_point;//player1's point
reg  [9-1:0]        player_2_point;//player2's point
reg  [9-1:0]        dart_point;//dart point, obtained by LUT
reg  [1:0]          counter;
reg                 who_turn;

//internal wire declaration
wire  [9-1:0]       point_table[0:30][0:30];//10x10 LUT
wire  [961*9-1:0]   temp_table;//used to build LUT, ignore it 
                              
//ouput wire assignment
assign player_1_done_o=(state==PLAYER_DONE&&who_turn==1'b0)?1'b1:1'b0;
assign player_2_done_o=(state==PLAYER_DONE&&who_turn==1'b1)?1'b1:1'b0;
assign player_1_win_o=(player_1_point==9'd0)?1'b1:1'b0;
assign player_2_win_o=(player_2_point==9'd0)?1'b1:1'b0;
assign player_1_pt_o=player_1_point;
assign player_2_pt_o=player_2_point;
assign game_set_o=(next_state==RESULT)?1'b1:1'b0;

//internal wire assignment
assign temp_table={ 9'd0, 9'd0, 9'd0, 9'd0, 9'd0, 9'd0, 9'd0, 9'd0, 9'd0, 9'd0, 9'd0, 9'd0, 9'd0, 9'd0, 9'd0, 9'd40, 9'd0, 9'd0, 9'd0, 9'd0, 9'd0, 9'd0, 9'd0, 9'd0, 9'd0, 9'd0, 9'd0, 9'd0, 9'd0, 9'd0, 9'd0,
                    9'd0, 9'd0, 9'd0, 9'd0, 9'd0, 9'd0, 9'd0, 9'd0, 9'd0, 9'd0, 9'd10, 9'd10, 9'd10, 9'd40, 9'd40, 9'd20, 9'd40, 9'd40, 9'd2, 9'd2, 9'd2, 9'd0, 9'd0, 9'd0, 9'd0, 9'd0, 9'd0, 9'd0, 9'd0, 9'd0, 9'd0,
                    9'd0, 9'd0, 9'd0, 9'd0, 9'd0, 9'd0, 9'd0, 9'd0, 9'd24, 9'd10, 9'd5, 9'd5, 9'd5, 9'd20, 9'd20, 9'd20, 9'd20, 9'd20, 9'd1, 9'd1, 9'd1, 9'd2, 9'd36, 9'd0, 9'd0, 9'd0, 9'd0, 9'd0, 9'd0, 9'd0, 9'd0,
                    9'd0, 9'd0, 9'd0, 9'd0, 9'd0, 9'd0, 9'd24, 9'd24, 9'd12, 9'd5, 9'd5, 9'd5, 9'd5, 9'd5, 9'd60, 9'd60, 9'd60, 9'd1, 9'd1, 9'd1, 9'd1, 9'd1, 9'd18, 9'd36, 9'd36, 9'd0, 9'd0, 9'd0, 9'd0, 9'd0, 9'd0,
                    9'd0, 9'd0, 9'd0, 9'd0, 9'd0, 9'd24, 9'd24, 9'd12, 9'd12, 9'd12, 9'd15, 9'd15, 9'd15, 9'd15, 9'd20, 9'd20, 9'd20, 9'd3, 9'd3, 9'd3, 9'd3, 9'd18, 9'd18, 9'd18, 9'd36, 9'd36, 9'd0, 9'd0, 9'd0, 9'd0, 9'd0,
                    9'd0, 9'd0, 9'd0, 9'd0, 9'd18, 9'd24, 9'd12, 9'd12, 9'd12, 9'd36, 9'd15, 9'd5, 9'd5, 9'd5, 9'd20, 9'd20, 9'd20, 9'd1, 9'd1, 9'd1, 9'd3, 9'd54, 9'd18, 9'd18, 9'd18, 9'd8, 9'd8, 9'd0, 9'd0, 9'd0, 9'd0,
                    9'd0, 9'd0, 9'd0, 9'd18, 9'd18, 9'd9, 9'd12, 9'd36, 9'd36, 9'd12, 9'd12, 9'd5, 9'd5, 9'd5, 9'd20, 9'd20, 9'd20, 9'd1, 9'd1, 9'd1, 9'd18, 9'd18, 9'd54, 9'd54, 9'd4, 9'd4, 9'd8, 9'd8, 9'd0, 9'd0, 9'd0,
                    9'd0, 9'd0, 9'd0, 9'd18, 9'd9, 9'd9, 9'd27, 9'd36, 9'd12, 9'd12, 9'd12, 9'd5, 9'd5, 9'd5, 9'd20, 9'd20, 9'd20, 9'd1, 9'd1, 9'd1, 9'd18, 9'd18, 9'd18, 9'd12, 9'd12, 9'd4, 9'd4, 9'd8, 9'd0, 9'd0, 9'd0,
                    9'd0, 9'd0, 9'd18, 9'd9, 9'd9, 9'd9, 9'd27, 9'd9, 9'd12, 9'd12, 9'd12, 9'd12, 9'd5, 9'd5, 9'd20, 9'd20, 9'd20, 9'd1, 9'd1, 9'd18, 9'd18, 9'd18, 9'd4, 9'd4, 9'd12, 9'd4, 9'd4, 9'd4, 9'd8, 9'd0, 9'd0,
                    9'd0, 9'd0, 9'd28, 9'd14, 9'd9, 9'd27, 9'd9, 9'd9, 9'd9, 9'd12, 9'd12, 9'd12, 9'd5, 9'd5, 9'd5, 9'd20, 9'd1, 9'd1, 9'd1, 9'd18, 9'd18, 9'd4, 9'd4, 9'd4, 9'd4, 9'd12, 9'd4, 9'd13, 9'd26, 9'd0, 9'd0,
                    9'd0, 9'd28, 9'd14, 9'd14, 9'd42, 9'd42, 9'd9, 9'd9, 9'd9, 9'd9, 9'd12, 9'd12, 9'd12, 9'd5, 9'd5, 9'd20, 9'd1, 9'd1, 9'd18, 9'd18, 9'd4, 9'd4, 9'd4, 9'd4, 9'd4, 9'd39, 9'd39, 9'd13, 9'd13, 9'd26, 9'd0,
                    9'd0, 9'd28, 9'd14, 9'd14, 9'd42, 9'd14, 9'd14, 9'd14, 9'd9, 9'd9, 9'd9, 9'd12, 9'd12, 9'd5, 9'd5, 9'd20, 9'd1, 9'd1, 9'd18, 9'd4, 9'd4, 9'd4, 9'd4, 9'd13, 9'd13, 9'd13, 9'd39, 9'd13, 9'd13, 9'd26, 9'd0,
                    9'd0, 9'd28, 9'd14, 9'd14, 9'd42, 9'd14, 9'd14, 9'd14, 9'd14, 9'd14, 9'd9, 9'd9, 9'd12, 9'd12, 9'd5, 9'd20, 9'd1, 9'd18, 9'd4, 9'd4, 9'd4, 9'd13, 9'd13, 9'd13, 9'd13, 9'd13, 9'd39, 9'd13, 9'd13, 9'd26, 9'd0,
                    9'd0, 9'd22, 9'd11, 9'd14, 9'd42, 9'd14, 9'd14, 9'd14, 9'd14, 9'd14, 9'd14, 9'd14, 9'd9, 9'd12, 9'd50, 9'd50, 9'd50, 9'd4, 9'd4, 9'd13, 9'd13, 9'd13, 9'd13, 9'd13, 9'd13, 9'd13, 9'd39, 9'd13, 9'd6, 9'd12, 9'd0,
                    9'd0, 9'd22, 9'd11, 9'd33, 9'd11, 9'd11, 9'd11, 9'd11, 9'd11, 9'd14, 9'd14, 9'd14, 9'd14, 9'd50, 9'd50, 9'd50, 9'd50, 9'd50, 9'd13, 9'd13, 9'd13, 9'd13, 9'd6, 9'd6, 9'd6, 9'd6, 9'd6, 9'd18, 9'd6, 9'd12, 9'd0,
                    9'd22, 9'd11, 9'd11, 9'd33, 9'd11, 9'd11, 9'd11, 9'd11, 9'd11, 9'd11, 9'd11, 9'd11, 9'd11, 9'd50, 9'd50, 9'd50, 9'd50, 9'd50, 9'd6, 9'd6, 9'd6, 9'd6, 9'd6, 9'd6, 9'd6, 9'd6, 9'd6, 9'd18, 9'd6, 9'd6, 9'd12, 
                    9'd0, 9'd22, 9'd11, 9'd33, 9'd11, 9'd11, 9'd11, 9'd11, 9'd11, 9'd8, 9'd8, 9'd8, 9'd8, 9'd50, 9'd50, 9'd50, 9'd50, 9'd50, 9'd10, 9'd10, 9'd10, 9'd10, 9'd6, 9'd6, 9'd6, 9'd6, 9'd6, 9'd18, 9'd6, 9'd12, 9'd0,
                    9'd0, 9'd22, 9'd11, 9'd8, 9'd24, 9'd8, 9'd8, 9'd8, 9'd8, 9'd8, 9'd8, 9'd8, 9'd16, 9'd16, 9'd50, 9'd50, 9'd50, 9'd2, 9'd15, 9'd10, 9'd10, 9'd10, 9'd10, 9'd10, 9'd10, 9'd10, 9'd30, 9'd10, 9'd6, 9'd12, 9'd0,
                    9'd0, 9'd16, 9'd8, 9'd8, 9'd24, 9'd8, 9'd8, 9'd8, 9'd8, 9'd8, 9'd16, 9'd16, 9'd16, 9'd7, 9'd19, 9'd3, 9'd17, 9'd2, 9'd2, 9'd15, 9'd15, 9'd10, 9'd10, 9'd10, 9'd10, 9'd10, 9'd30, 9'd10, 9'd10, 9'd20, 9'd0,
                    9'd0, 9'd16, 9'd8, 9'd8, 9'd24, 9'd8, 9'd8, 9'd8, 9'd16, 9'd16, 9'd16, 9'd16, 9'd7, 9'd19, 9'd19, 9'd3, 9'd17, 9'd17, 9'd2, 9'd2, 9'd15, 9'd15, 9'd15, 9'd10, 9'd10, 9'd10, 9'd30, 9'd10, 9'd10, 9'd20, 9'd0,
                    9'd0, 9'd16, 9'd8, 9'd8, 9'd24, 9'd24, 9'd16, 9'd16, 9'd16, 9'd16, 9'd16, 9'd7, 9'd7, 9'd19, 9'd19, 9'd3, 9'd17, 9'd17, 9'd2, 9'd2, 9'd2, 9'd15, 9'd15, 9'd15, 9'd15, 9'd30, 9'd30, 9'd10, 9'd10, 9'd20, 9'd0,
                    9'd0, 9'd0, 9'd16, 9'd8, 9'd16, 9'd48, 9'd16, 9'd16, 9'd16, 9'd16, 9'd7, 9'd7, 9'd19, 9'd19, 9'd19, 9'd3, 9'd17, 9'd17, 9'd17, 9'd2, 9'd2, 9'd2, 9'd15, 9'd15, 9'd15, 9'd45, 9'd15, 9'd10, 9'd20, 9'd0, 9'd0,
                    9'd0, 9'd0, 9'd32, 9'd16, 9'd16, 9'd16, 9'd48, 9'd16, 9'd16, 9'd7, 9'd7, 9'd7, 9'd19, 9'd19, 9'd3, 9'd3, 9'd3, 9'd17, 9'd17, 9'd2, 9'd2, 9'd2, 9'd2, 9'd15, 9'd45, 9'd15, 9'd15, 9'd15, 9'd30, 9'd0, 9'd0,
                    9'd0, 9'd0, 9'd0, 9'd32, 9'd16, 9'd16, 9'd48, 9'd48, 9'd7, 9'd7, 9'd7, 9'd19, 9'd19, 9'd19, 9'd3, 9'd3, 9'd3, 9'd17, 9'd17, 9'd17, 9'd2, 9'd2, 9'd2, 9'd6, 9'd45, 9'd15, 9'd15, 9'd30, 9'd0, 9'd0, 9'd0,
                    9'd0, 9'd0, 9'd0, 9'd32, 9'd32, 9'd16, 9'd16, 9'd21, 9'd21, 9'd7, 9'd7, 9'd19, 9'd19, 9'd19, 9'd3, 9'd3, 9'd3, 9'd17, 9'd17, 9'd17, 9'd2, 9'd2, 9'd6, 9'd6, 9'd2, 9'd15, 9'd30, 9'd30, 9'd0, 9'd0, 9'd0,
                    9'd0, 9'd0, 9'd0, 9'd0, 9'd32, 9'd32, 9'd7, 9'd7, 9'd7, 9'd21, 9'd57, 9'd19, 9'd19, 9'd19, 9'd3, 9'd3, 9'd3, 9'd17, 9'd17, 9'd17, 9'd51, 9'd6, 9'd2, 9'd2, 9'd2, 9'd4, 9'd30, 9'd0, 9'd0, 9'd0, 9'd0,
                    9'd0, 9'd0, 9'd0, 9'd0, 9'd0, 9'd14, 9'd14, 9'd7, 9'd7, 9'd7, 9'd57, 9'd57, 9'd57, 9'd57, 9'd3, 9'd3, 9'd3, 9'd51, 9'd51, 9'd51, 9'd51, 9'd2, 9'd2, 9'd2, 9'd4, 9'd4, 9'd0, 9'd0, 9'd0, 9'd0, 9'd0,
                    9'd0, 9'd0, 9'd0, 9'd0, 9'd0, 9'd0, 9'd14, 9'd14, 9'd7, 9'd19, 9'd19, 9'd19, 9'd19, 9'd19, 9'd9, 9'd9, 9'd9, 9'd17, 9'd17, 9'd17, 9'd17, 9'd17, 9'd2, 9'd4, 9'd4, 9'd0, 9'd0, 9'd0, 9'd0, 9'd0, 9'd0,
                    9'd0, 9'd0, 9'd0, 9'd0, 9'd0, 9'd0, 9'd0, 9'd0, 9'd14, 9'd38, 9'd19, 9'd19, 9'd19, 9'd3, 9'd3, 9'd3, 9'd3, 9'd3, 9'd17, 9'd17, 9'd17, 9'd34, 9'd4, 9'd0, 9'd0, 9'd0, 9'd0, 9'd0, 9'd0, 9'd0, 9'd0,
                    9'd0, 9'd0, 9'd0, 9'd0, 9'd0, 9'd0, 9'd0, 9'd0, 9'd0, 9'd0, 9'd38, 9'd38, 9'd38, 9'd6, 9'd6, 9'd3, 9'd6, 9'd6, 9'd34, 9'd34, 9'd34, 9'd0, 9'd0, 9'd0, 9'd0, 9'd0, 9'd0, 9'd0, 9'd0, 9'd0, 9'd0,
                    9'd0, 9'd0, 9'd0, 9'd0, 9'd0, 9'd0, 9'd0, 9'd0, 9'd0, 9'd0, 9'd0, 9'd0, 9'd0, 9'd0, 9'd0, 9'd6, 9'd0, 9'd0, 9'd0, 9'd0, 9'd0, 9'd0, 9'd0, 9'd0, 9'd0, 9'd0, 9'd0, 9'd0, 9'd0, 9'd0, 9'd0
                    };
genvar i;
generate//used to build LUT, ignore it
    for(i=0; i<31; i=i+1) begin 
        assign point_table[0][i]=temp_table[8648-279*0-i*9:8640-279*0-i*9];
        assign point_table[1][i]=temp_table[8648-279*1-i*9:8640-279*1-i*9];
        assign point_table[2][i]=temp_table[8648-279*2-i*9:8640-279*2-i*9];
        assign point_table[3][i]=temp_table[8648-279*3-i*9:8640-279*3-i*9];
        assign point_table[4][i]=temp_table[8648-279*4-i*9:8640-279*4-i*9];
        assign point_table[5][i]=temp_table[8648-279*5-i*9:8640-279*5-i*9];
        assign point_table[6][i]=temp_table[8648-279*6-i*9:8640-279*6-i*9];
        assign point_table[7][i]=temp_table[8648-279*7-i*9:8640-279*7-i*9];
        assign point_table[8][i]=temp_table[8648-279*8-i*9:8640-279*8-i*9];
        assign point_table[9][i]=temp_table[8648-279*9-i*9:8640-279*9-i*9];
        assign point_table[10][i]=temp_table[8648-279*10-i*9:8640-279*10-i*9];
        assign point_table[11][i]=temp_table[8648-279*11-i*9:8640-279*11-i*9];
        assign point_table[12][i]=temp_table[8648-279*12-i*9:8640-279*12-i*9];
        assign point_table[13][i]=temp_table[8648-279*13-i*9:8640-279*13-i*9];
        assign point_table[14][i]=temp_table[8648-279*14-i*9:8640-279*14-i*9];
        assign point_table[15][i]=temp_table[8648-279*15-i*9:8640-279*15-i*9];
        assign point_table[16][i]=temp_table[8648-279*16-i*9:8640-279*16-i*9];
        assign point_table[17][i]=temp_table[8648-279*17-i*9:8640-279*17-i*9];
        assign point_table[18][i]=temp_table[8648-279*18-i*9:8640-279*18-i*9];
        assign point_table[19][i]=temp_table[8648-279*19-i*9:8640-279*19-i*9];
        assign point_table[20][i]=temp_table[8648-279*20-i*9:8640-279*20-i*9];
        assign point_table[21][i]=temp_table[8648-279*21-i*9:8640-279*21-i*9];
        assign point_table[22][i]=temp_table[8648-279*22-i*9:8640-279*22-i*9];
        assign point_table[23][i]=temp_table[8648-279*23-i*9:8640-279*23-i*9];
        assign point_table[24][i]=temp_table[8648-279*24-i*9:8640-279*24-i*9];
        assign point_table[25][i]=temp_table[8648-279*25-i*9:8640-279*25-i*9];
        assign point_table[26][i]=temp_table[8648-279*26-i*9:8640-279*26-i*9];
        assign point_table[27][i]=temp_table[8648-279*27-i*9:8640-279*27-i*9];
        assign point_table[28][i]=temp_table[8648-279*28-i*9:8640-279*28-i*9];
        assign point_table[29][i]=temp_table[8648-279*29-i*9:8640-279*29-i*9];
        assign point_table[30][i]=temp_table[8648-279*30-i*9:8640-279*30-i*9];
    end
endgenerate

always@(*)begin//FSM next state assignment
    case (state)
        START:
            next_state=INITIALIZE;
        INITIALIZE:
            next_state=IDLE;
        IDLE:
            if(dart_come_i)next_state=TOUCH;
            else next_state=IDLE;
        TOUCH:
            next_state=COUNT;
        COUNT:
            next_state=PLAYER_DONE;
        PLAYER_DONE:
            if(player_1_win_o||player_2_win_o)next_state=RESULT;
            else next_state=IDLE;
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
    else if(state==TOUCH)dart_point<=point_table[dart_position_y_i][dart_position_x_i];
    else dart_point<=dart_point;
end

always@(posedge clk)begin//update player1's point
    if(~reset)player_1_point<=9'd0;
    else if(state==INITIALIZE)player_1_point<=9'd501;
    else if(state==COUNT&&who_turn==1'b0)player_1_point<=(player_1_point>=dart_point)?player_1_point-dart_point:player_1_point;
    else player_1_point<=player_1_point;
end

always@(posedge clk)begin//update player2's point
    if(~reset)player_2_point<=9'd0;
    else if(state==INITIALIZE)player_2_point<=9'd501;
    else if(state==COUNT&&who_turn==1'b1)player_2_point<=(player_2_point>=dart_point)?player_2_point-dart_point:player_2_point;
    else player_2_point<=player_2_point;
end

always@(posedge clk)begin//update counter
    if(~reset)counter<=2'b00;
    else if(state==TOUCH)counter=(counter==2'b10)?2'b00:counter+2'b01;
    else counter<=counter;
end

always@(posedge clk)begin//update turn flag
    if(~reset)who_turn<=1'b0;
    else if(state==PLAYER_DONE&&counter==2'b00)who_turn<=~who_turn;
    else who_turn<=who_turn;
end

endmodule

