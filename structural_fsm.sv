`default_nettype none

module dFlipFlop
  (output logic q,
   input logic d, clock, reset);

  always_ff @ (posedge clock)
    if (reset == '1)
      q <= '0;
    else
      q <= d;
endmodule : dFlipFlop


module myExplicitFSM 
  (
  output logic [3:0] fMove,
  output logic win,
  output logic q0, q1, q2, // connect to FF outputs
  // add more if needed
  input logic [3:0] hMove,
  input logic clock, reset);
  logic d0, d1, d2; // connect to FF inputs ( add more if needed )
  logic valid;
  logic level_1, level_2, level_3;
  logic C0, C1, C2, n_win, n_valid;
  logic flip_q0;
  // Example instantiation of D - flip - flop .
  // Add more as necessary .
  dFlipFlop ff0 (.d(d0), .q(q0), .*),
  ff1 (.d(d1), .q(q1), .*), 
  ff2 (.d(d2), .q(q2), .*);

  // Next state logic goes here : combinational logic that drives
  // next state ( d0 , etc ) based upon input hMove and the
  // current state ( q0 , q1 , etc ).

  // d0 only changes if q1 == 1
  assign n_win = ~win;
  // Edge 1: state = 000 and hMove = 6
  assign level_1 = (~q0 & ~q1 & ~q2) & (~hMove[3] & hMove[2] & hMove[1] & ~hMove[0]);
  // Edge 2: state = 001 and hMove = 2, 3, 4, 5, 6, 7, 8 
  assign level_2 = (q0 & ~q1 & ~q2) & 
  (
  (~hMove[3] & ~hMove[2] &  hMove[1] & ~hMove[0]) | // 2
  (~hMove[3] & ~hMove[2] &  hMove[1] &  hMove[0]) | // 3
  (~hMove[3] &  hMove[2] & ~hMove[1] & ~hMove[0]) | // 4
  (~hMove[3] &  hMove[2] &  hMove[1] &  hMove[0]) | // 7
  ( hMove[3] & ~hMove[2] & ~hMove[1] &  hMove[0]) | // 9
  ( hMove[3] & ~hMove[2] & ~hMove[1] & ~hMove[0])   // 8
  );
  assign level_3 = (~q2 & q1 & ~q0) & (
    (~hMove[3] & ~hMove[2] &  hMove[1] & ~hMove[0]) | // 2
    (~hMove[3] &  hMove[2] & ~hMove[1] & ~hMove[0]) | // 4
    (~hMove[3] &  hMove[2] &  hMove[1] &  hMove[0]) | // 7
    ( hMove[3] & ~hMove[2] & ~hMove[1] & ~hMove[0])   // 8
  );

  assign valid = n_win & (level_1 | level_2 | level_3);
  assign n_valid = ~valid;
  assign C0 = q1 & 1;
  // If not valid then q2 else (q1 & 1)
  assign d2 = (n_valid & q2) | (valid & C0);


  // d1 is the opposite of q1 unless we are transitioning from 000

  // if A then B else C <--> (A and B) | (not A and C)
  // if not valid then q1 else ( C )
  // C --> if state == 0, then 0 -- else flip q1 
  // ((~q0 & ~q1 & ~q2) & 0 ) | ( (q0 | q1 | q2) & ~q1)
  assign C1 =  (q0 | q1 | q2) & ~q1;
  assign d1 = (n_valid & q1) | (valid & C1);


  // if hMove = 6 or 9, flip q2 
  // if 010 and (hMove = 2 or 4 or 8), flip q2 
  // else keep as q2 
  assign flip_q0 =
    (~hMove[3] &  hMove[2] &  hMove[1] & ~hMove[0]) | // 6
    ( hMove[3] & ~hMove[2] & ~hMove[1] &  hMove[0]) | // 9
    ((~q0 & q1 & ~q2) & (
      (~hMove[3] & ~hMove[2] &  hMove[1] & ~hMove[0]) | // 2
      (~hMove[3] &  hMove[2] & ~hMove[1] & ~hMove[0]) | // 4
      ( hMove[3] & ~hMove[2] & ~hMove[1] & ~hMove[0])   // 8
    ));
  assign C2 = (q0 & ~flip_q0) | (~q0 & flip_q0);
  assign d0 = (n_valid & q0) | (valid & C2);
  // Your output logic goes here : combinational logic that
  // drives fMove and win based upon
  // current state ( q0 , etc ) and hMove.


  // fMove[3] is high when the value is 9 (state 011)
  assign fMove[3] = (~q2 &  q1 &  q0);
  // fMove[2] is high when the value is 5 (000) or 7 (101)
  assign fMove[2] = (~q2 & ~q1 & ~q0) | (q2 & ~q1 & q0);
  // fMove[1] is high when the value is 3 (010), 2 (100), or 7 (101)
  assign fMove[1] = (~q2 &  q1 & ~q0) | (q2 & ~q1 & ~q0) | (q2 & ~q1 & q0);
  // fMove[0] is high when the value is 5 (000), 1 (001), 3 (010), 9 (011), or 7 (101)
  assign fMove[0] = (~q2 & ~q1 & ~q0) | (~q2 & ~q1 & q0) | (~q2 & q1 & ~q0) | (~q2 & q1 & q0) | (q2 & ~q1 & q0);

  // K-map for win, where ABC = q0, q1, q2, respectively
  //              BC
  //          00  01  11  10
  // A = 0     0   0   1   0
  // A = 1     1   1   0   0
  // win = AB' + A'BC
  assign win = (q2 & ~q1) | (~q2 & q1 & q0);
  endmodule : myExplicitFSM




module myFSM_testE;
   logic [3:0] fMove;
   logic win;
   logic [3:0] hMove;
   logic q2 , q1 , q0;
   logic clock , reset;
   logic [5:0] vector;
   logic [5:0] ivector;


  myExplicitFSM DUT(.*);

  initial begin
  clock = 0;
  forever #5 clock = ~ clock ;
  end
  initial begin
    $monitor ( $time , , " state =%b , fMove=%d , hMove=%d , win=%b " ,
    {q2, q1, q0}, fMove, hMove, win);
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
        if ({q2, q1, q0}!= 3'b000)
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
    if ({q2, q1, q0}!= 3'b001)
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
        if ({q2, q1, q0}!= 3'b001)
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
    if ({q2, q1, q0}!= 3'b010)
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
        if ({q2, q1, q0}!= 3'b010)
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
    if ({q2, q1, q0}!= 3'b100)
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
      if ({q2, q1, q0}!= 3'b100)
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
        if ({q2, q1, q0}!= 3'b000)
          $display("Error, reset should go to state 000");
        if (win)
          $display("Error, this is not a winning state");
        if (fMove != 4'd5)
          $display("Error, FPGA should play optimal move of 5");

        // Test that hMove <= 6 means we go to state 001
        hMove <= 4'd6;
        @(posedge clock);
        #1;
        if ({q2, q1, q0}!= 3'b001)
          $display("Error, state 000 + hMove 6 --> state 001");
        if (win)
          $display("Error, this is not a winning state");
        if (fMove != 4'd1)
          $display("Error, FPGA should play optimal move of 1");

        // Test that the current hMove means we go to state 011
        hMove <= vector[3:0];
        @(posedge clock);
        #1;
        if ({q2, q1, q0}!= 3'b011)
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
          if ({q2, q1, q0}!= 3'b011)
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
        if ({q2, q1, q0}!= 3'b000)
          $display("Error, reset should go to state 000");
        if (win)
          $display("Error, this is not a winning state");
        if (fMove != 4'd5)
          $display("Error, FPGA should play optimal move of 5");

        // Test that hMove <= 6 means we go to state 001
        hMove <= 4'd6;
        @(posedge clock);
        #1;
        if ({q2, q1, q0}!= 3'b001)
          $display("Error, state 000 + hMove 6 --> state 001");
        if (win)
          $display("Error, this is not a winning state");
        if (fMove != 4'd1)
          $display("Error, FPGA should play optimal move of 1");

        // Test that hMove <= 9 means we go to state 010
        hMove <= 4'd9;
        @(posedge clock);
        #1;
        if ({q2, q1, q0}!= 3'b010)
          $display("Error, state 001 + hMove 9 --> state 010");
        if (win)
          $display("Error, this is not a winning state");
        if (fMove != 4'd3)
          $display("Error, FPGA should play optimal move of 3");

        // Test that the current hMove means we go to state 101
        hMove <= vector[3:0];
        @(posedge clock);
        #1;
        if ({q2, q1, q0}!= 3'b101)
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
          if ({q2, q1, q0}!= 3'b101)
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
    if ({q2, q1, q0} !== 3'b001)
      $display("Error, expected play1 before reset");

    //test reset from play1 to play5.
    reset <= 1'b1;
    hMove <= 4'hF;
    @(posedge clock);
    #1;
    if ({q2, q1, q0} !== 3'b000)
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
    if ({q2, q1, q0} !== 3'b010)
      $display("Error, expected play3 before reset");

    //test reset from play3 to play5
    reset <= 1'b1;
    hMove <= 4'hF;
    @(posedge clock);
    #1;
    if ({q2, q1, q0} !== 3'b000)
      $display("Error, reset from play3 should go to play5");
    if (win !== 1'b0 || fMove !== 4'd5)
      $display("Error, reset should give fMove=5 and win=0");

    reset <= 1'b0;

    $display("All tests completed!");

    #1 $finish ;
  end
  endmodule : myFSM_testE