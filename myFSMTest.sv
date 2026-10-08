`default_nettype none
module myFSM_test (
  input logic [3:0] fMove,
  input logic win,
  input logic q2 , q1 , q0 ,
  output logic [3:0] hMove,
  output logic clock , reset );
  initial begin
  clock = 0;
  forever #5 clock = ~ clock ;
  end
  initial begin
    $monitor ( $time , , " state =%b , fMove=%d , hMove=%d , win=%b " ,
               { q2 , q1 , q0 } , fMove, hMove, win);
    // initialize values
    hMove <= 4’hF; reset <= 1'b1 ;
    // reset the FSM
    @( posedge clock ); // wait for a positive clock edge
    @( posedge clock ); // one edge is enough , but what the heck
@ ( posedge clock );
@ ( posedge clock ); // begin cycle 0
reset <= 1'b0 ; // release the reset
// start an example sequence -- not meaningful for the lab
hMove <= 4’hF; // these changes are after the clock edge
// which means the state change happens
// AFTER the next clock edge
@ ( posedge clock ); // begin cycle 1
hMove <= 4’h6;
@ ( posedge clock ); // begin cycle 2
hMove <= 4’hF;
@ ( posedge clock ); // begin cycle 3
hMove <= 4’h6;
// could check FSM outputs like so . Be careful about timing
#1 if (~win)
$display ( " Oops , incorrect hMove value at cycle 3" );
@ ( posedge clock );
#1 $finish ;
end
endmodule : myFSM_test