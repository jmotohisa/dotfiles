`timescale 1ns / 1ps
//--------------------------------------------------------------------------------
//  %file% - Time-stamp: <Tue Feb 26 19:08:43 JST 2019>
//
//   Copyright (c) %year%  %id% (%name%)  <%mail%>
//
//  $Id: %file% %date% %id% $
// Create Date: %date%
// Design Name:
// Module Name: %file-without-ext%
// Project Name: 
// Target Devices:
// Tool versions:
// Description: 
//
// Dependencies:
//
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
//
//--------------------------------------------------------------------------------

module modulename 
  #(
	parameter WIDTH= 8
	)
   (
    input wire 			   clk,
    input wire 			   rst,
	output reg 			   out1,
	output reg [WIDTH-1:0] out2
    );
   
endmodule // modulename
