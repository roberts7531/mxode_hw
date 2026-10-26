//Copyright (C)2014-2025 Gowin Semiconductor Corporation.
//All rights reserved.
//File Title: IP file
//Tool Version: V1.9.12 (64-bit)
//Part Number: GW2AR-LV18QN88C8/I7
//Device: GW2AR-18
//Created Time: Thu Oct 22 19:46:06 2026

module Gowin_SDPB (dout, clka, cea, reseta, clkb, ceb, resetb, oce, ada, din, adb);

output [31:0] dout;
input clka;
input cea;
input reseta;
input clkb;
input ceb;
input resetb;
input oce;
input [14:0] ada;
input [7:0] din;
input [12:0] adb;

wire [27:0] sdpb_inst_0_dout_w;
wire [24:0] sdpb_inst_0_dout;
wire [27:0] sdpb_inst_1_dout_w;
wire [24:0] sdpb_inst_1_dout;
wire [27:0] sdpb_inst_2_dout_w;
wire [25:1] sdpb_inst_2_dout;
wire [27:0] sdpb_inst_3_dout_w;
wire [25:1] sdpb_inst_3_dout;
wire [27:0] sdpb_inst_4_dout_w;
wire [26:2] sdpb_inst_4_dout;
wire [27:0] sdpb_inst_5_dout_w;
wire [26:2] sdpb_inst_5_dout;
wire [27:0] sdpb_inst_6_dout_w;
wire [27:3] sdpb_inst_6_dout;
wire [27:0] sdpb_inst_7_dout_w;
wire [27:3] sdpb_inst_7_dout;
wire [27:0] sdpb_inst_8_dout_w;
wire [28:4] sdpb_inst_8_dout;
wire [27:0] sdpb_inst_9_dout_w;
wire [28:4] sdpb_inst_9_dout;
wire [27:0] sdpb_inst_10_dout_w;
wire [29:5] sdpb_inst_10_dout;
wire [27:0] sdpb_inst_11_dout_w;
wire [29:5] sdpb_inst_11_dout;
wire [27:0] sdpb_inst_12_dout_w;
wire [30:6] sdpb_inst_12_dout;
wire [27:0] sdpb_inst_13_dout_w;
wire [30:6] sdpb_inst_13_dout;
wire [27:0] sdpb_inst_14_dout_w;
wire [31:7] sdpb_inst_14_dout;
wire [27:0] sdpb_inst_15_dout_w;
wire [31:7] sdpb_inst_15_dout;
wire dff_q_0;
wire gw_gnd;

assign gw_gnd = 1'b0;

SDPB sdpb_inst_0 (
    .DO({sdpb_inst_0_dout_w[27:0],sdpb_inst_0_dout[24],sdpb_inst_0_dout[16],sdpb_inst_0_dout[8],sdpb_inst_0_dout[0]}),
    .CLKA(clka),
    .CEA(cea),
    .RESETA(reseta),
    .CLKB(clkb),
    .CEB(ceb),
    .RESETB(resetb),
    .OCE(oce),
    .BLKSELA({gw_gnd,gw_gnd,ada[14]}),
    .BLKSELB({gw_gnd,gw_gnd,adb[12]}),
    .ADA(ada[13:0]),
    .DI({gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,din[0]}),
    .ADB({adb[11:0],gw_gnd,gw_gnd})
);

defparam sdpb_inst_0.READ_MODE = 1'b0;
defparam sdpb_inst_0.BIT_WIDTH_0 = 1;
defparam sdpb_inst_0.BIT_WIDTH_1 = 4;
defparam sdpb_inst_0.BLK_SEL_0 = 3'b000;
defparam sdpb_inst_0.BLK_SEL_1 = 3'b000;
defparam sdpb_inst_0.RESET_MODE = "SYNC";

SDPB sdpb_inst_1 (
    .DO({sdpb_inst_1_dout_w[27:0],sdpb_inst_1_dout[24],sdpb_inst_1_dout[16],sdpb_inst_1_dout[8],sdpb_inst_1_dout[0]}),
    .CLKA(clka),
    .CEA(cea),
    .RESETA(reseta),
    .CLKB(clkb),
    .CEB(ceb),
    .RESETB(resetb),
    .OCE(oce),
    .BLKSELA({gw_gnd,gw_gnd,ada[14]}),
    .BLKSELB({gw_gnd,gw_gnd,adb[12]}),
    .ADA(ada[13:0]),
    .DI({gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,din[0]}),
    .ADB({adb[11:0],gw_gnd,gw_gnd})
);

defparam sdpb_inst_1.READ_MODE = 1'b0;
defparam sdpb_inst_1.BIT_WIDTH_0 = 1;
defparam sdpb_inst_1.BIT_WIDTH_1 = 4;
defparam sdpb_inst_1.BLK_SEL_0 = 3'b001;
defparam sdpb_inst_1.BLK_SEL_1 = 3'b001;
defparam sdpb_inst_1.RESET_MODE = "SYNC";

SDPB sdpb_inst_2 (
    .DO({sdpb_inst_2_dout_w[27:0],sdpb_inst_2_dout[25],sdpb_inst_2_dout[17],sdpb_inst_2_dout[9],sdpb_inst_2_dout[1]}),
    .CLKA(clka),
    .CEA(cea),
    .RESETA(reseta),
    .CLKB(clkb),
    .CEB(ceb),
    .RESETB(resetb),
    .OCE(oce),
    .BLKSELA({gw_gnd,gw_gnd,ada[14]}),
    .BLKSELB({gw_gnd,gw_gnd,adb[12]}),
    .ADA(ada[13:0]),
    .DI({gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,din[1]}),
    .ADB({adb[11:0],gw_gnd,gw_gnd})
);

defparam sdpb_inst_2.READ_MODE = 1'b0;
defparam sdpb_inst_2.BIT_WIDTH_0 = 1;
defparam sdpb_inst_2.BIT_WIDTH_1 = 4;
defparam sdpb_inst_2.BLK_SEL_0 = 3'b000;
defparam sdpb_inst_2.BLK_SEL_1 = 3'b000;
defparam sdpb_inst_2.RESET_MODE = "SYNC";

SDPB sdpb_inst_3 (
    .DO({sdpb_inst_3_dout_w[27:0],sdpb_inst_3_dout[25],sdpb_inst_3_dout[17],sdpb_inst_3_dout[9],sdpb_inst_3_dout[1]}),
    .CLKA(clka),
    .CEA(cea),
    .RESETA(reseta),
    .CLKB(clkb),
    .CEB(ceb),
    .RESETB(resetb),
    .OCE(oce),
    .BLKSELA({gw_gnd,gw_gnd,ada[14]}),
    .BLKSELB({gw_gnd,gw_gnd,adb[12]}),
    .ADA(ada[13:0]),
    .DI({gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,din[1]}),
    .ADB({adb[11:0],gw_gnd,gw_gnd})
);

defparam sdpb_inst_3.READ_MODE = 1'b0;
defparam sdpb_inst_3.BIT_WIDTH_0 = 1;
defparam sdpb_inst_3.BIT_WIDTH_1 = 4;
defparam sdpb_inst_3.BLK_SEL_0 = 3'b001;
defparam sdpb_inst_3.BLK_SEL_1 = 3'b001;
defparam sdpb_inst_3.RESET_MODE = "SYNC";

SDPB sdpb_inst_4 (
    .DO({sdpb_inst_4_dout_w[27:0],sdpb_inst_4_dout[26],sdpb_inst_4_dout[18],sdpb_inst_4_dout[10],sdpb_inst_4_dout[2]}),
    .CLKA(clka),
    .CEA(cea),
    .RESETA(reseta),
    .CLKB(clkb),
    .CEB(ceb),
    .RESETB(resetb),
    .OCE(oce),
    .BLKSELA({gw_gnd,gw_gnd,ada[14]}),
    .BLKSELB({gw_gnd,gw_gnd,adb[12]}),
    .ADA(ada[13:0]),
    .DI({gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,din[2]}),
    .ADB({adb[11:0],gw_gnd,gw_gnd})
);

defparam sdpb_inst_4.READ_MODE = 1'b0;
defparam sdpb_inst_4.BIT_WIDTH_0 = 1;
defparam sdpb_inst_4.BIT_WIDTH_1 = 4;
defparam sdpb_inst_4.BLK_SEL_0 = 3'b000;
defparam sdpb_inst_4.BLK_SEL_1 = 3'b000;
defparam sdpb_inst_4.RESET_MODE = "SYNC";

SDPB sdpb_inst_5 (
    .DO({sdpb_inst_5_dout_w[27:0],sdpb_inst_5_dout[26],sdpb_inst_5_dout[18],sdpb_inst_5_dout[10],sdpb_inst_5_dout[2]}),
    .CLKA(clka),
    .CEA(cea),
    .RESETA(reseta),
    .CLKB(clkb),
    .CEB(ceb),
    .RESETB(resetb),
    .OCE(oce),
    .BLKSELA({gw_gnd,gw_gnd,ada[14]}),
    .BLKSELB({gw_gnd,gw_gnd,adb[12]}),
    .ADA(ada[13:0]),
    .DI({gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,din[2]}),
    .ADB({adb[11:0],gw_gnd,gw_gnd})
);

defparam sdpb_inst_5.READ_MODE = 1'b0;
defparam sdpb_inst_5.BIT_WIDTH_0 = 1;
defparam sdpb_inst_5.BIT_WIDTH_1 = 4;
defparam sdpb_inst_5.BLK_SEL_0 = 3'b001;
defparam sdpb_inst_5.BLK_SEL_1 = 3'b001;
defparam sdpb_inst_5.RESET_MODE = "SYNC";

SDPB sdpb_inst_6 (
    .DO({sdpb_inst_6_dout_w[27:0],sdpb_inst_6_dout[27],sdpb_inst_6_dout[19],sdpb_inst_6_dout[11],sdpb_inst_6_dout[3]}),
    .CLKA(clka),
    .CEA(cea),
    .RESETA(reseta),
    .CLKB(clkb),
    .CEB(ceb),
    .RESETB(resetb),
    .OCE(oce),
    .BLKSELA({gw_gnd,gw_gnd,ada[14]}),
    .BLKSELB({gw_gnd,gw_gnd,adb[12]}),
    .ADA(ada[13:0]),
    .DI({gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,din[3]}),
    .ADB({adb[11:0],gw_gnd,gw_gnd})
);

defparam sdpb_inst_6.READ_MODE = 1'b0;
defparam sdpb_inst_6.BIT_WIDTH_0 = 1;
defparam sdpb_inst_6.BIT_WIDTH_1 = 4;
defparam sdpb_inst_6.BLK_SEL_0 = 3'b000;
defparam sdpb_inst_6.BLK_SEL_1 = 3'b000;
defparam sdpb_inst_6.RESET_MODE = "SYNC";

SDPB sdpb_inst_7 (
    .DO({sdpb_inst_7_dout_w[27:0],sdpb_inst_7_dout[27],sdpb_inst_7_dout[19],sdpb_inst_7_dout[11],sdpb_inst_7_dout[3]}),
    .CLKA(clka),
    .CEA(cea),
    .RESETA(reseta),
    .CLKB(clkb),
    .CEB(ceb),
    .RESETB(resetb),
    .OCE(oce),
    .BLKSELA({gw_gnd,gw_gnd,ada[14]}),
    .BLKSELB({gw_gnd,gw_gnd,adb[12]}),
    .ADA(ada[13:0]),
    .DI({gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,din[3]}),
    .ADB({adb[11:0],gw_gnd,gw_gnd})
);

defparam sdpb_inst_7.READ_MODE = 1'b0;
defparam sdpb_inst_7.BIT_WIDTH_0 = 1;
defparam sdpb_inst_7.BIT_WIDTH_1 = 4;
defparam sdpb_inst_7.BLK_SEL_0 = 3'b001;
defparam sdpb_inst_7.BLK_SEL_1 = 3'b001;
defparam sdpb_inst_7.RESET_MODE = "SYNC";

SDPB sdpb_inst_8 (
    .DO({sdpb_inst_8_dout_w[27:0],sdpb_inst_8_dout[28],sdpb_inst_8_dout[20],sdpb_inst_8_dout[12],sdpb_inst_8_dout[4]}),
    .CLKA(clka),
    .CEA(cea),
    .RESETA(reseta),
    .CLKB(clkb),
    .CEB(ceb),
    .RESETB(resetb),
    .OCE(oce),
    .BLKSELA({gw_gnd,gw_gnd,ada[14]}),
    .BLKSELB({gw_gnd,gw_gnd,adb[12]}),
    .ADA(ada[13:0]),
    .DI({gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,din[4]}),
    .ADB({adb[11:0],gw_gnd,gw_gnd})
);

defparam sdpb_inst_8.READ_MODE = 1'b0;
defparam sdpb_inst_8.BIT_WIDTH_0 = 1;
defparam sdpb_inst_8.BIT_WIDTH_1 = 4;
defparam sdpb_inst_8.BLK_SEL_0 = 3'b000;
defparam sdpb_inst_8.BLK_SEL_1 = 3'b000;
defparam sdpb_inst_8.RESET_MODE = "SYNC";

SDPB sdpb_inst_9 (
    .DO({sdpb_inst_9_dout_w[27:0],sdpb_inst_9_dout[28],sdpb_inst_9_dout[20],sdpb_inst_9_dout[12],sdpb_inst_9_dout[4]}),
    .CLKA(clka),
    .CEA(cea),
    .RESETA(reseta),
    .CLKB(clkb),
    .CEB(ceb),
    .RESETB(resetb),
    .OCE(oce),
    .BLKSELA({gw_gnd,gw_gnd,ada[14]}),
    .BLKSELB({gw_gnd,gw_gnd,adb[12]}),
    .ADA(ada[13:0]),
    .DI({gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,din[4]}),
    .ADB({adb[11:0],gw_gnd,gw_gnd})
);

defparam sdpb_inst_9.READ_MODE = 1'b0;
defparam sdpb_inst_9.BIT_WIDTH_0 = 1;
defparam sdpb_inst_9.BIT_WIDTH_1 = 4;
defparam sdpb_inst_9.BLK_SEL_0 = 3'b001;
defparam sdpb_inst_9.BLK_SEL_1 = 3'b001;
defparam sdpb_inst_9.RESET_MODE = "SYNC";

SDPB sdpb_inst_10 (
    .DO({sdpb_inst_10_dout_w[27:0],sdpb_inst_10_dout[29],sdpb_inst_10_dout[21],sdpb_inst_10_dout[13],sdpb_inst_10_dout[5]}),
    .CLKA(clka),
    .CEA(cea),
    .RESETA(reseta),
    .CLKB(clkb),
    .CEB(ceb),
    .RESETB(resetb),
    .OCE(oce),
    .BLKSELA({gw_gnd,gw_gnd,ada[14]}),
    .BLKSELB({gw_gnd,gw_gnd,adb[12]}),
    .ADA(ada[13:0]),
    .DI({gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,din[5]}),
    .ADB({adb[11:0],gw_gnd,gw_gnd})
);

defparam sdpb_inst_10.READ_MODE = 1'b0;
defparam sdpb_inst_10.BIT_WIDTH_0 = 1;
defparam sdpb_inst_10.BIT_WIDTH_1 = 4;
defparam sdpb_inst_10.BLK_SEL_0 = 3'b000;
defparam sdpb_inst_10.BLK_SEL_1 = 3'b000;
defparam sdpb_inst_10.RESET_MODE = "SYNC";

SDPB sdpb_inst_11 (
    .DO({sdpb_inst_11_dout_w[27:0],sdpb_inst_11_dout[29],sdpb_inst_11_dout[21],sdpb_inst_11_dout[13],sdpb_inst_11_dout[5]}),
    .CLKA(clka),
    .CEA(cea),
    .RESETA(reseta),
    .CLKB(clkb),
    .CEB(ceb),
    .RESETB(resetb),
    .OCE(oce),
    .BLKSELA({gw_gnd,gw_gnd,ada[14]}),
    .BLKSELB({gw_gnd,gw_gnd,adb[12]}),
    .ADA(ada[13:0]),
    .DI({gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,din[5]}),
    .ADB({adb[11:0],gw_gnd,gw_gnd})
);

defparam sdpb_inst_11.READ_MODE = 1'b0;
defparam sdpb_inst_11.BIT_WIDTH_0 = 1;
defparam sdpb_inst_11.BIT_WIDTH_1 = 4;
defparam sdpb_inst_11.BLK_SEL_0 = 3'b001;
defparam sdpb_inst_11.BLK_SEL_1 = 3'b001;
defparam sdpb_inst_11.RESET_MODE = "SYNC";

SDPB sdpb_inst_12 (
    .DO({sdpb_inst_12_dout_w[27:0],sdpb_inst_12_dout[30],sdpb_inst_12_dout[22],sdpb_inst_12_dout[14],sdpb_inst_12_dout[6]}),
    .CLKA(clka),
    .CEA(cea),
    .RESETA(reseta),
    .CLKB(clkb),
    .CEB(ceb),
    .RESETB(resetb),
    .OCE(oce),
    .BLKSELA({gw_gnd,gw_gnd,ada[14]}),
    .BLKSELB({gw_gnd,gw_gnd,adb[12]}),
    .ADA(ada[13:0]),
    .DI({gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,din[6]}),
    .ADB({adb[11:0],gw_gnd,gw_gnd})
);

defparam sdpb_inst_12.READ_MODE = 1'b0;
defparam sdpb_inst_12.BIT_WIDTH_0 = 1;
defparam sdpb_inst_12.BIT_WIDTH_1 = 4;
defparam sdpb_inst_12.BLK_SEL_0 = 3'b000;
defparam sdpb_inst_12.BLK_SEL_1 = 3'b000;
defparam sdpb_inst_12.RESET_MODE = "SYNC";

SDPB sdpb_inst_13 (
    .DO({sdpb_inst_13_dout_w[27:0],sdpb_inst_13_dout[30],sdpb_inst_13_dout[22],sdpb_inst_13_dout[14],sdpb_inst_13_dout[6]}),
    .CLKA(clka),
    .CEA(cea),
    .RESETA(reseta),
    .CLKB(clkb),
    .CEB(ceb),
    .RESETB(resetb),
    .OCE(oce),
    .BLKSELA({gw_gnd,gw_gnd,ada[14]}),
    .BLKSELB({gw_gnd,gw_gnd,adb[12]}),
    .ADA(ada[13:0]),
    .DI({gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,din[6]}),
    .ADB({adb[11:0],gw_gnd,gw_gnd})
);

defparam sdpb_inst_13.READ_MODE = 1'b0;
defparam sdpb_inst_13.BIT_WIDTH_0 = 1;
defparam sdpb_inst_13.BIT_WIDTH_1 = 4;
defparam sdpb_inst_13.BLK_SEL_0 = 3'b001;
defparam sdpb_inst_13.BLK_SEL_1 = 3'b001;
defparam sdpb_inst_13.RESET_MODE = "SYNC";

SDPB sdpb_inst_14 (
    .DO({sdpb_inst_14_dout_w[27:0],sdpb_inst_14_dout[31],sdpb_inst_14_dout[23],sdpb_inst_14_dout[15],sdpb_inst_14_dout[7]}),
    .CLKA(clka),
    .CEA(cea),
    .RESETA(reseta),
    .CLKB(clkb),
    .CEB(ceb),
    .RESETB(resetb),
    .OCE(oce),
    .BLKSELA({gw_gnd,gw_gnd,ada[14]}),
    .BLKSELB({gw_gnd,gw_gnd,adb[12]}),
    .ADA(ada[13:0]),
    .DI({gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,din[7]}),
    .ADB({adb[11:0],gw_gnd,gw_gnd})
);

defparam sdpb_inst_14.READ_MODE = 1'b0;
defparam sdpb_inst_14.BIT_WIDTH_0 = 1;
defparam sdpb_inst_14.BIT_WIDTH_1 = 4;
defparam sdpb_inst_14.BLK_SEL_0 = 3'b000;
defparam sdpb_inst_14.BLK_SEL_1 = 3'b000;
defparam sdpb_inst_14.RESET_MODE = "SYNC";

SDPB sdpb_inst_15 (
    .DO({sdpb_inst_15_dout_w[27:0],sdpb_inst_15_dout[31],sdpb_inst_15_dout[23],sdpb_inst_15_dout[15],sdpb_inst_15_dout[7]}),
    .CLKA(clka),
    .CEA(cea),
    .RESETA(reseta),
    .CLKB(clkb),
    .CEB(ceb),
    .RESETB(resetb),
    .OCE(oce),
    .BLKSELA({gw_gnd,gw_gnd,ada[14]}),
    .BLKSELB({gw_gnd,gw_gnd,adb[12]}),
    .ADA(ada[13:0]),
    .DI({gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,gw_gnd,din[7]}),
    .ADB({adb[11:0],gw_gnd,gw_gnd})
);

defparam sdpb_inst_15.READ_MODE = 1'b0;
defparam sdpb_inst_15.BIT_WIDTH_0 = 1;
defparam sdpb_inst_15.BIT_WIDTH_1 = 4;
defparam sdpb_inst_15.BLK_SEL_0 = 3'b001;
defparam sdpb_inst_15.BLK_SEL_1 = 3'b001;
defparam sdpb_inst_15.RESET_MODE = "SYNC";

DFFE dff_inst_0 (
  .Q(dff_q_0),
  .D(adb[12]),
  .CLK(clkb),
  .CE(ceb)
);
MUX2 mux_inst_0 (
  .O(dout[0]),
  .I0(sdpb_inst_0_dout[0]),
  .I1(sdpb_inst_1_dout[0]),
  .S0(dff_q_0)
);
MUX2 mux_inst_1 (
  .O(dout[1]),
  .I0(sdpb_inst_2_dout[1]),
  .I1(sdpb_inst_3_dout[1]),
  .S0(dff_q_0)
);
MUX2 mux_inst_2 (
  .O(dout[2]),
  .I0(sdpb_inst_4_dout[2]),
  .I1(sdpb_inst_5_dout[2]),
  .S0(dff_q_0)
);
MUX2 mux_inst_3 (
  .O(dout[3]),
  .I0(sdpb_inst_6_dout[3]),
  .I1(sdpb_inst_7_dout[3]),
  .S0(dff_q_0)
);
MUX2 mux_inst_4 (
  .O(dout[4]),
  .I0(sdpb_inst_8_dout[4]),
  .I1(sdpb_inst_9_dout[4]),
  .S0(dff_q_0)
);
MUX2 mux_inst_5 (
  .O(dout[5]),
  .I0(sdpb_inst_10_dout[5]),
  .I1(sdpb_inst_11_dout[5]),
  .S0(dff_q_0)
);
MUX2 mux_inst_6 (
  .O(dout[6]),
  .I0(sdpb_inst_12_dout[6]),
  .I1(sdpb_inst_13_dout[6]),
  .S0(dff_q_0)
);
MUX2 mux_inst_7 (
  .O(dout[7]),
  .I0(sdpb_inst_14_dout[7]),
  .I1(sdpb_inst_15_dout[7]),
  .S0(dff_q_0)
);
MUX2 mux_inst_8 (
  .O(dout[8]),
  .I0(sdpb_inst_0_dout[8]),
  .I1(sdpb_inst_1_dout[8]),
  .S0(dff_q_0)
);
MUX2 mux_inst_9 (
  .O(dout[9]),
  .I0(sdpb_inst_2_dout[9]),
  .I1(sdpb_inst_3_dout[9]),
  .S0(dff_q_0)
);
MUX2 mux_inst_10 (
  .O(dout[10]),
  .I0(sdpb_inst_4_dout[10]),
  .I1(sdpb_inst_5_dout[10]),
  .S0(dff_q_0)
);
MUX2 mux_inst_11 (
  .O(dout[11]),
  .I0(sdpb_inst_6_dout[11]),
  .I1(sdpb_inst_7_dout[11]),
  .S0(dff_q_0)
);
MUX2 mux_inst_12 (
  .O(dout[12]),
  .I0(sdpb_inst_8_dout[12]),
  .I1(sdpb_inst_9_dout[12]),
  .S0(dff_q_0)
);
MUX2 mux_inst_13 (
  .O(dout[13]),
  .I0(sdpb_inst_10_dout[13]),
  .I1(sdpb_inst_11_dout[13]),
  .S0(dff_q_0)
);
MUX2 mux_inst_14 (
  .O(dout[14]),
  .I0(sdpb_inst_12_dout[14]),
  .I1(sdpb_inst_13_dout[14]),
  .S0(dff_q_0)
);
MUX2 mux_inst_15 (
  .O(dout[15]),
  .I0(sdpb_inst_14_dout[15]),
  .I1(sdpb_inst_15_dout[15]),
  .S0(dff_q_0)
);
MUX2 mux_inst_16 (
  .O(dout[16]),
  .I0(sdpb_inst_0_dout[16]),
  .I1(sdpb_inst_1_dout[16]),
  .S0(dff_q_0)
);
MUX2 mux_inst_17 (
  .O(dout[17]),
  .I0(sdpb_inst_2_dout[17]),
  .I1(sdpb_inst_3_dout[17]),
  .S0(dff_q_0)
);
MUX2 mux_inst_18 (
  .O(dout[18]),
  .I0(sdpb_inst_4_dout[18]),
  .I1(sdpb_inst_5_dout[18]),
  .S0(dff_q_0)
);
MUX2 mux_inst_19 (
  .O(dout[19]),
  .I0(sdpb_inst_6_dout[19]),
  .I1(sdpb_inst_7_dout[19]),
  .S0(dff_q_0)
);
MUX2 mux_inst_20 (
  .O(dout[20]),
  .I0(sdpb_inst_8_dout[20]),
  .I1(sdpb_inst_9_dout[20]),
  .S0(dff_q_0)
);
MUX2 mux_inst_21 (
  .O(dout[21]),
  .I0(sdpb_inst_10_dout[21]),
  .I1(sdpb_inst_11_dout[21]),
  .S0(dff_q_0)
);
MUX2 mux_inst_22 (
  .O(dout[22]),
  .I0(sdpb_inst_12_dout[22]),
  .I1(sdpb_inst_13_dout[22]),
  .S0(dff_q_0)
);
MUX2 mux_inst_23 (
  .O(dout[23]),
  .I0(sdpb_inst_14_dout[23]),
  .I1(sdpb_inst_15_dout[23]),
  .S0(dff_q_0)
);
MUX2 mux_inst_24 (
  .O(dout[24]),
  .I0(sdpb_inst_0_dout[24]),
  .I1(sdpb_inst_1_dout[24]),
  .S0(dff_q_0)
);
MUX2 mux_inst_25 (
  .O(dout[25]),
  .I0(sdpb_inst_2_dout[25]),
  .I1(sdpb_inst_3_dout[25]),
  .S0(dff_q_0)
);
MUX2 mux_inst_26 (
  .O(dout[26]),
  .I0(sdpb_inst_4_dout[26]),
  .I1(sdpb_inst_5_dout[26]),
  .S0(dff_q_0)
);
MUX2 mux_inst_27 (
  .O(dout[27]),
  .I0(sdpb_inst_6_dout[27]),
  .I1(sdpb_inst_7_dout[27]),
  .S0(dff_q_0)
);
MUX2 mux_inst_28 (
  .O(dout[28]),
  .I0(sdpb_inst_8_dout[28]),
  .I1(sdpb_inst_9_dout[28]),
  .S0(dff_q_0)
);
MUX2 mux_inst_29 (
  .O(dout[29]),
  .I0(sdpb_inst_10_dout[29]),
  .I1(sdpb_inst_11_dout[29]),
  .S0(dff_q_0)
);
MUX2 mux_inst_30 (
  .O(dout[30]),
  .I0(sdpb_inst_12_dout[30]),
  .I1(sdpb_inst_13_dout[30]),
  .S0(dff_q_0)
);
MUX2 mux_inst_31 (
  .O(dout[31]),
  .I0(sdpb_inst_14_dout[31]),
  .I1(sdpb_inst_15_dout[31]),
  .S0(dff_q_0)
);
endmodule //Gowin_SDPB
