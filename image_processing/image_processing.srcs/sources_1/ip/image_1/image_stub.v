// Copyright 1986-2014 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2014.4 (win64) Build 1071353 Tue Nov 18 18:29:27 MST 2014
// Date        : Thu Apr 09 10:32:40 2026
// Host        : Krushang running 64-bit major release  (build 9200)
// Command     : write_verilog -force -mode synth_stub
//               d:/krushang/VLSI/image_processing/image_processing/image_processing.srcs/sources_1/ip/image_1/image_stub.v
// Design      : image
// Purpose     : Stub declaration of top-level module interface
// Device      : xc7a35tcpg236-1
// --------------------------------------------------------------------------------

// This empty module with port declaration file causes synthesis tools to infer a black box for IP.
// The synthesis directives are for Synopsys Synplify support to prevent IO buffer insertion.
// Please paste the declaration into a Verilog source file or add the file as an additional source.
(* x_core_info = "blk_mem_gen_v8_2,Vivado 2014.4" *)
module image(clka, ena, addra, douta)
/* synthesis syn_black_box black_box_pad_pin="clka,ena,addra[14:0],douta[95:0]" */;
  input clka;
  input ena;
  input [14:0]addra;
  output [95:0]douta;
endmodule
