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
    case(state)
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
        nextState = play7_win;
      default: 
        nextState = play5; 
    endcase        
  end 

  //output comb block

  always_comb begin
    fMove = 4'd0;
    win = 1'b0;

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

  // State register with synchronous reset
  always_ff @(posedge clock)
    //reset state is play5
    if (reset)
      state <= play5;
    else
      state <= nextState;
      
endmodule: myAbstractFSM



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
    case(state)
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
        nextState = play7_win;
      default: 
        nextState = play5; 
    endcase        
  end 

  //output comb block

  always_comb begin
    fMove = 4'd0;
    win = 1'b0;

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

  // State register with synchronous reset
  always_ff @(posedge clock)
    //reset state is play5
    if (reset)
      state <= play5;
    else
      state <= nextState;
      
endmodule: myAbstractFSM



module myFSM_testA;
   logic [3:0] fMove;
   logic win;
   logic [3:0] hMove;
   logic clock , reset;
   logic [5:0] vector;
   logic [5:0] ivector;


  myAbstractFSM DUT(.*);

  initial begin
  clock = 0;
  forever #5 clock = ~ clock ;
  end
  initial begin
    $monitor ( $time , , " state =%b , fMove=%d , hMove=%d , win=%b " ,
    DUT.state, fMove, hMove, win);
    // initialize values
    hMove <= 4'hF; reset <= 1'b1 ;
    // reset the FSM
    @ ( posedge clock ); // wait for a positive clock edge
    @ ( posedge clock ); // one edge is enough , but what the heck
    @ ( posedge clock );
    @ ( posedge clock ); // begin cycle 0
    reset <= 1'b0 ; // release the reset
    // start an example sequence -- not meaningful for the lab

    // We start in state 1 
    $display ( "we start in state 000" );

    // Test that anything but hMove <= 6 stays in state 000
    for(vector = 0; vector < 5'd16; vector++) begin 
      if(vector != 5'd6) begin 
        hMove <= vector[3:0];
        @ (posedge clock); 
        #1;
        if (DUT.state!= 3'b000)
          $display ("Error, invalid input should loop back");
        if (win) 
          $display ("Error, this is not a winning state");
        if (fMove != 4'd5)
          $display ("Error, FPGA should play optimal move of 5");


      end 
    end 
      // Test that hMove <= 6 means we go to state 001 
    hMove <= 4'd6;
    @ (posedge clock);
    #1;
    if (DUT.state!= 3'b001)
        $display ("Error, state 0 + hMove 6 --> state 1");
    if (win) 
        $display ("Error, this is not a winning state");
    
    // We are now in state 001
    $display("we are now in state 001");

    // Test that anything but hMove <= 2, 3, 4, 7, 8, 9 stays in state 001
    for(vector = 0; vector < 5'd16; vector++) begin
      if(vector != 5'd2 && vector != 5'd3 &&
        vector != 5'd4 && vector != 5'd7 &&
        vector != 5'd8 && vector != 5'd9) begin
        hMove <= vector[3:0];
        @(posedge clock);
        #1;
        if (DUT.state!= 3'b001)
          $display("Error, invalid input should loop back");
        if (win)
          $display("Error, this is not a winning state");
        if (fMove != 4'd1)
          $display("Error, FPGA should play optimal move of 1");
      end
    end

    // Test that hMove <= 9 means we go to state 010
    hMove <= 4'd9;
    @(posedge clock);
    #1;
    if (DUT.state!= 3'b010)
      $display("Error, state 001 + hMove 9 --> state 010");
    if (win)
      $display("Error, this is not a winning state");
    if (fMove != 4'd3)
      $display("Error, FPGA should play optimal move of 3");


    // We are now in state 010
    $display("we are now in state 010");

    // Test that anything but hMove <= 2, 4, 7, 8 stays in state 010
    for(vector = 0; vector < 5'd16; vector++) begin
      if(vector != 5'd2 && vector != 5'd4 &&
        vector != 5'd7 && vector != 5'd8) begin
        hMove <= vector[3:0];
        @(posedge clock);
        #1;
        if (DUT.state!= 3'b010)
          $display("Error, invalid input should loop back");
        if (win)
          $display("Error, this is not a winning state");
        if (fMove != 4'd3)
          $display("Error, FPGA should play optimal move of 3");
      end
    end

    // Test that hMove <= 7 means we go to state 100
    hMove <= 4'd7;
    @(posedge clock);
    #1;
    if (DUT.state!= 3'b100)
      $display("Error, state 010 + hMove 7 --> state 100");
    if (!win)
      $display("Error, this should be a winning state");
    if (fMove != 4'd2)
      $display("Error, FPGA should play optimal move of 2");


    // We are now in state 100
    $display("we are now in state 100");

    // Test that any hMove stays in state 100 since we already won
    for(vector = 0; vector < 5'd16; vector++) begin
      hMove <= vector[3:0];
      @(posedge clock);
      #1;
      if (DUT.state!= 3'b100)
        $display("Error, winning state should loop back");
      if (!win)
        $display("Error, this should be a winning state");
      if (fMove != 4'd2)
        $display("Error, FPGA should play optimal move of 2");
    end


    // Reset the FSM to test the other path from state 001
    $display("resetting to test state 001");

    // Test that hMove <= 2, 3, 4, 7, 8 means we go to state 011
    for(vector = 0; vector < 5'd16; vector++) begin
      if(vector == 5'd2 || vector == 5'd3 ||
        vector == 5'd4 || vector == 5'd7 ||
        vector == 5'd8) begin

        // Reset the FSM back to state 000
        hMove <= 4'hF; reset <= 1'b1;
        @(posedge clock);
        #1;
        reset <= 1'b0;
        if (DUT.state!= 3'b000)
          $display("Error, reset should go to state 000");
        if (win)
          $display("Error, this is not a winning state");
        if (fMove != 4'd5)
          $display("Error, FPGA should play optimal move of 5");

        // Test that hMove <= 6 means we go to state 001
        hMove <= 4'd6;
        @(posedge clock);
        #1;
        if (DUT.state!= 3'b001)
          $display("Error, state 000 + hMove 6 --> state 001");
        if (win)
          $display("Error, this is not a winning state");
        if (fMove != 4'd1)
          $display("Error, FPGA should play optimal move of 1");

        // Test that the current hMove means we go to state 011
        hMove <= vector[3:0];
        @(posedge clock);
        #1;
        if (DUT.state!= 3'b011)
          $display("Error, state 001 + hMove %0d --> state 011", vector);
        if (!win)
          $display("Error, this should be a winning state");
        if (fMove != 4'd9)
          $display("Error, FPGA should play optimal move of 9");

        // Test that any hMove stays in state 011 since we already won
        for(ivector = 0; ivector < 5'd16; ivector++) begin
          hMove <= ivector[3:0];
          @(posedge clock);
          #1;
          if (DUT.state!= 3'b011)
            $display("Error, winning state should loop back");
          if (!win)
            $display("Error, this should be a winning state");
          if (fMove != 4'd9)
            $display("Error, FPGA should play optimal move of 9");
        end
      end
    end


    // Reset the FSM to test the other path from state 010
    $display("resetting to test state 010");

    // Test that hMove <= 2, 4, 8 means we go to state 101
    for(vector = 0; vector < 5'd16; vector++) begin
      if(vector == 5'd2 || vector == 5'd4 ||
        vector == 5'd8) begin

        // Reset the FSM back to state 000
        hMove <= 4'hF; reset <= 1'b1;
        @(posedge clock);
        #1;
        reset <= 1'b0;
        if (DUT.state!= 3'b000)
          $display("Error, reset should go to state 000");
        if (win)
          $display("Error, this is not a winning state");
        if (fMove != 4'd5)
          $display("Error, FPGA should play optimal move of 5");

        // Test that hMove <= 6 means we go to state 001
        hMove <= 4'd6;
        @(posedge clock);
        #1;
        if (DUT.state!= 3'b001)
          $display("Error, state 000 + hMove 6 --> state 001");
        if (win)
          $display("Error, this is not a winning state");
        if (fMove != 4'd1)
          $display("Error, FPGA should play optimal move of 1");

        // Test that hMove <= 9 means we go to state 010
        hMove <= 4'd9;
        @(posedge clock);
        #1;
        if (DUT.state!= 3'b010)
          $display("Error, state 001 + hMove 9 --> state 010");
        if (win)
          $display("Error, this is not a winning state");
        if (fMove != 4'd3)
          $display("Error, FPGA should play optimal move of 3");

        // Test that the current hMove means we go to state 101
        hMove <= vector[3:0];
        @(posedge clock);
        #1;
        if (DUT.state!= 3'b101)
          $display("Error, state 010 + hMove %0d --> state 101", vector);
        if (!win)
          $display("Error, this should be a winning state");
        if (fMove != 4'd7)
          $display("Error, FPGA should play optimal move of 7");

        // Test that any hMove stays in state 101 since we already won
        for(ivector = 0; ivector < 5'd16; ivector++) begin
          hMove <= ivector[3:0];
          @(posedge clock);
          #1;
          if (DUT.state!= 3'b101)
            $display("Error, winning state should loop back");
          if (!win)
            $display("Error, this should be a winning state");
          if (fMove != 4'd7)
            $display("Error, FPGA should play optimal move of 7");
        end
      end
    end

    // Start a new game
    hMove <= 4'hF;
    reset <= 1'b1;
    @(posedge clock);
    #1;

    // go to play1
    reset <= 1'b0;
    hMove <= 4'd6;
    @(posedge clock);
    #1;
    if (DUT.state !== DUT.play1)
      $display("Error, expected play1 before reset");

    //test reset from play1 to play5.
    reset <= 1'b1;
    hMove <= 4'hF;
    @(posedge clock);
    #1;
    if (DUT.state !== DUT.play5)
      $display("Error, reset from play1 should go to play5");
    if (win !== 1'b0 || fMove !== 4'd5)
      $display("Error, reset should give fMove=5 and win=0");

    //enter play1 again
    reset <= 1'b0;
    hMove <= 4'd6;
    @(posedge clock);
    #1;

    //enter play3
    hMove <= 4'd9;
    @(posedge clock);
    #1;
    if (DUT.state !== DUT.play3)
      $display("Error, expected play3 before reset");

    //test reset from play3 to play5
    reset <= 1'b1;
    hMove <= 4'hF;
    @(posedge clock);
    #1;
    if (DUT.state !== DUT.play5)
      $display("Error, reset from play3 should go to play5");
    if (win !== 1'b0 || fMove !== 4'd5)
      $display("Error, reset should give fMove=5 and win=0");

    reset <= 1'b0;

    $display("All tests completed!");

    #1 $finish ;
  end
  endmodule : myFSM_testA