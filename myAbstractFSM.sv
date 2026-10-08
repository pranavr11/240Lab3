`default_nettype none
module myAbstractFSM(
  output logic [3:0] fMove,
  output logic win,
  input logic [3:0] hMove,
  input logic clock , reset );

  enum logic [2:0] { play5= 3'b000,  play1= 3'b001,
                      play3= 3'b010, play9_win= 3'b011,
                      play2_win = 3'b100, play7_win = 3'b101
                    } 
                    state, nextState;
  
//next State generator
  always_comb begin 
    unique case(state)
      //human can only take 6 which gives use play1
      //anyother move than that 
      play5:
        if (hMove == 4'd6) begin
          nextState = play1;
        end
        else begin 
          nextState = play5;
        end
      //if human moves 9, fpga moves to 3 so go to state play
      //if human goes 2,3,4,7,8
      //fpga moves 3 
      //
      play1: 
        unique case(hMove)
          4'd9 : 
            nextState = play3;
          4'd2, 4'd3, 4'd4, 4'd7, 4'd8:
            nextState = play9_win;
          default: 
            nextState = play1;
        endcase 
      play3:  
        unique case (hMove) 
          4'd7 : 
            nextState = play2_win;
          4'd2, 4'd4, 4'd8:
            nextState = play7_win;
          default : 
            nextState = play3;
        endcase
      play9_win:
        nextState = play9_win;
      play2_win: 
        nextState = play2_win;
      play7_win:
        nextState = play2_win;
      default: 
        nextState = play5;
    endcase        
  end 

  //output comb block

  always_comb begin
    fMove = 4'd0;
    win = 1'b1;

    unique case (state)
      //nonwin cases
      play5: fMove = 4'd5;
      play1: fMove = 4'd1;
      play3: fMove = 4'd3;
      //win cases
      play9_win:  begin
                    fMove = 4'd9;
                    win = 1'b1;
                  end 
      play2_win:  begin
                    fMove = 4'd2;
                    win = 1'b1;
                  end
      play7_win:  begin 
                    fMove = 4'd7;
                    win = 1'b1;
                  end
      default:  begin
                  fMove = 4'd0;
                  win = 1'b0;
                end
    endcase
  end

  // State register with asynchronous reset
  always_ff @(posedge clock, negedge reset)
    //reset state is play5
    if (reset)
      state <= play5;
    else
      state <= nextState;
      
endmodule: myAbstractFSM