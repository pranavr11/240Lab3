module myAbstractFSM(
  output logic [3:0] fMove,
  output logic win,
  input logic [3:0] hMove,
  input logic clock , reset );

  enum logic [2:0] { play5= 3'b101,  play1= 3'b001,
                     play9_win= 3'b111, play= 3'b011,
                    s5 = 3'b100, s6 = 3'b101
                    } 
                    state, nextState;


  always_comb begin 
    unquie case(state) begin 

        
        
    end 

endmodule: myAbstractFSM