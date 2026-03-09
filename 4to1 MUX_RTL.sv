module MUX41 (sel,ip,out);
  input [3:0] ip;
  input [1:0] sel;
  output reg out;
  always @(*) begin
  case(sel)
    2'b00:out = ip[0];
    2'b01:out = ip[1];
    2'b10:out = ip[2];
    2'b11:out = ip[3];
    default:out = ip[0];
  endcase
 end
endmodule

