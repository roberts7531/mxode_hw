module gw_gao(
    \nProc/dmaByteCount[31] ,
    \nProc/dmaByteCount[30] ,
    \nProc/dmaByteCount[29] ,
    \nProc/dmaByteCount[28] ,
    \nProc/dmaByteCount[27] ,
    \nProc/dmaByteCount[26] ,
    \nProc/dmaByteCount[25] ,
    \nProc/dmaByteCount[24] ,
    \nProc/dmaByteCount[23] ,
    \nProc/dmaByteCount[22] ,
    \nProc/dmaByteCount[21] ,
    \nProc/dmaByteCount[20] ,
    \nProc/dmaByteCount[19] ,
    \nProc/dmaByteCount[18] ,
    \nProc/dmaByteCount[17] ,
    \nProc/dmaByteCount[16] ,
    \nProc/dmaByteCount[15] ,
    \nProc/dmaByteCount[14] ,
    \nProc/dmaByteCount[13] ,
    \nProc/dmaByteCount[12] ,
    \nProc/dmaByteCount[11] ,
    \nProc/dmaByteCount[10] ,
    \nProc/dmaByteCount[9] ,
    \nProc/dmaByteCount[8] ,
    \nProc/dmaByteCount[7] ,
    \nProc/dmaByteCount[6] ,
    \nProc/dmaByteCount[5] ,
    \nProc/dmaByteCount[4] ,
    \nProc/dmaByteCount[3] ,
    \nProc/dmaByteCount[2] ,
    \nProc/dmaByteCount[1] ,
    \nProc/dmaByteCount[0] ,
    HACK,
    \nProc/ack_sampled ,
    dsp_cs_in,
    dsp_rd,
    dsp_wr,
    \nProc/cs_sync ,
    dma_clk,
    \dmaDataOut[31] ,
    \dmaDataOut[30] ,
    \dmaDataOut[29] ,
    \dmaDataOut[28] ,
    \dmaDataOut[27] ,
    \dmaDataOut[26] ,
    \dmaDataOut[25] ,
    \dmaDataOut[24] ,
    \dmaDataOut[23] ,
    \dmaDataOut[22] ,
    \dmaDataOut[21] ,
    \dmaDataOut[20] ,
    \dmaDataOut[19] ,
    \dmaDataOut[18] ,
    \dmaDataOut[17] ,
    \dmaDataOut[16] ,
    \dmaDataOut[15] ,
    \dmaDataOut[14] ,
    \dmaDataOut[13] ,
    \dmaDataOut[12] ,
    \dmaDataOut[11] ,
    \dmaDataOut[10] ,
    \dmaDataOut[9] ,
    \dmaDataOut[8] ,
    \dmaDataOut[7] ,
    \dmaDataOut[6] ,
    \dmaDataOut[5] ,
    \dmaDataOut[4] ,
    \dmaDataOut[3] ,
    \dmaDataOut[2] ,
    \dmaDataOut[1] ,
    \dmaDataOut[0] ,
    HDRQ,
    \nProc/currentDmaState[3] ,
    \nProc/currentDmaState[2] ,
    \nProc/currentDmaState[1] ,
    \nProc/currentDmaState[0] ,
    \nProc/intrStatus[1] ,
    tms_pad_i,
    tck_pad_i,
    tdi_pad_i,
    tdo_pad_o
);

input \nProc/dmaByteCount[31] ;
input \nProc/dmaByteCount[30] ;
input \nProc/dmaByteCount[29] ;
input \nProc/dmaByteCount[28] ;
input \nProc/dmaByteCount[27] ;
input \nProc/dmaByteCount[26] ;
input \nProc/dmaByteCount[25] ;
input \nProc/dmaByteCount[24] ;
input \nProc/dmaByteCount[23] ;
input \nProc/dmaByteCount[22] ;
input \nProc/dmaByteCount[21] ;
input \nProc/dmaByteCount[20] ;
input \nProc/dmaByteCount[19] ;
input \nProc/dmaByteCount[18] ;
input \nProc/dmaByteCount[17] ;
input \nProc/dmaByteCount[16] ;
input \nProc/dmaByteCount[15] ;
input \nProc/dmaByteCount[14] ;
input \nProc/dmaByteCount[13] ;
input \nProc/dmaByteCount[12] ;
input \nProc/dmaByteCount[11] ;
input \nProc/dmaByteCount[10] ;
input \nProc/dmaByteCount[9] ;
input \nProc/dmaByteCount[8] ;
input \nProc/dmaByteCount[7] ;
input \nProc/dmaByteCount[6] ;
input \nProc/dmaByteCount[5] ;
input \nProc/dmaByteCount[4] ;
input \nProc/dmaByteCount[3] ;
input \nProc/dmaByteCount[2] ;
input \nProc/dmaByteCount[1] ;
input \nProc/dmaByteCount[0] ;
input HACK;
input \nProc/ack_sampled ;
input dsp_cs_in;
input dsp_rd;
input dsp_wr;
input \nProc/cs_sync ;
input dma_clk;
input \dmaDataOut[31] ;
input \dmaDataOut[30] ;
input \dmaDataOut[29] ;
input \dmaDataOut[28] ;
input \dmaDataOut[27] ;
input \dmaDataOut[26] ;
input \dmaDataOut[25] ;
input \dmaDataOut[24] ;
input \dmaDataOut[23] ;
input \dmaDataOut[22] ;
input \dmaDataOut[21] ;
input \dmaDataOut[20] ;
input \dmaDataOut[19] ;
input \dmaDataOut[18] ;
input \dmaDataOut[17] ;
input \dmaDataOut[16] ;
input \dmaDataOut[15] ;
input \dmaDataOut[14] ;
input \dmaDataOut[13] ;
input \dmaDataOut[12] ;
input \dmaDataOut[11] ;
input \dmaDataOut[10] ;
input \dmaDataOut[9] ;
input \dmaDataOut[8] ;
input \dmaDataOut[7] ;
input \dmaDataOut[6] ;
input \dmaDataOut[5] ;
input \dmaDataOut[4] ;
input \dmaDataOut[3] ;
input \dmaDataOut[2] ;
input \dmaDataOut[1] ;
input \dmaDataOut[0] ;
input HDRQ;
input \nProc/currentDmaState[3] ;
input \nProc/currentDmaState[2] ;
input \nProc/currentDmaState[1] ;
input \nProc/currentDmaState[0] ;
input \nProc/intrStatus[1] ;
input tms_pad_i;
input tck_pad_i;
input tdi_pad_i;
output tdo_pad_o;

wire \nProc/dmaByteCount[31] ;
wire \nProc/dmaByteCount[30] ;
wire \nProc/dmaByteCount[29] ;
wire \nProc/dmaByteCount[28] ;
wire \nProc/dmaByteCount[27] ;
wire \nProc/dmaByteCount[26] ;
wire \nProc/dmaByteCount[25] ;
wire \nProc/dmaByteCount[24] ;
wire \nProc/dmaByteCount[23] ;
wire \nProc/dmaByteCount[22] ;
wire \nProc/dmaByteCount[21] ;
wire \nProc/dmaByteCount[20] ;
wire \nProc/dmaByteCount[19] ;
wire \nProc/dmaByteCount[18] ;
wire \nProc/dmaByteCount[17] ;
wire \nProc/dmaByteCount[16] ;
wire \nProc/dmaByteCount[15] ;
wire \nProc/dmaByteCount[14] ;
wire \nProc/dmaByteCount[13] ;
wire \nProc/dmaByteCount[12] ;
wire \nProc/dmaByteCount[11] ;
wire \nProc/dmaByteCount[10] ;
wire \nProc/dmaByteCount[9] ;
wire \nProc/dmaByteCount[8] ;
wire \nProc/dmaByteCount[7] ;
wire \nProc/dmaByteCount[6] ;
wire \nProc/dmaByteCount[5] ;
wire \nProc/dmaByteCount[4] ;
wire \nProc/dmaByteCount[3] ;
wire \nProc/dmaByteCount[2] ;
wire \nProc/dmaByteCount[1] ;
wire \nProc/dmaByteCount[0] ;
wire HACK;
wire \nProc/ack_sampled ;
wire dsp_cs_in;
wire dsp_rd;
wire dsp_wr;
wire \nProc/cs_sync ;
wire dma_clk;
wire \dmaDataOut[31] ;
wire \dmaDataOut[30] ;
wire \dmaDataOut[29] ;
wire \dmaDataOut[28] ;
wire \dmaDataOut[27] ;
wire \dmaDataOut[26] ;
wire \dmaDataOut[25] ;
wire \dmaDataOut[24] ;
wire \dmaDataOut[23] ;
wire \dmaDataOut[22] ;
wire \dmaDataOut[21] ;
wire \dmaDataOut[20] ;
wire \dmaDataOut[19] ;
wire \dmaDataOut[18] ;
wire \dmaDataOut[17] ;
wire \dmaDataOut[16] ;
wire \dmaDataOut[15] ;
wire \dmaDataOut[14] ;
wire \dmaDataOut[13] ;
wire \dmaDataOut[12] ;
wire \dmaDataOut[11] ;
wire \dmaDataOut[10] ;
wire \dmaDataOut[9] ;
wire \dmaDataOut[8] ;
wire \dmaDataOut[7] ;
wire \dmaDataOut[6] ;
wire \dmaDataOut[5] ;
wire \dmaDataOut[4] ;
wire \dmaDataOut[3] ;
wire \dmaDataOut[2] ;
wire \dmaDataOut[1] ;
wire \dmaDataOut[0] ;
wire HDRQ;
wire \nProc/currentDmaState[3] ;
wire \nProc/currentDmaState[2] ;
wire \nProc/currentDmaState[1] ;
wire \nProc/currentDmaState[0] ;
wire \nProc/intrStatus[1] ;
wire tms_pad_i;
wire tck_pad_i;
wire tdi_pad_i;
wire tdo_pad_o;
wire tms_i_c;
wire tck_i_c;
wire tdi_i_c;
wire tdo_o_c;
wire [9:0] control0;
wire gao_jtag_tck;
wire gao_jtag_reset;
wire run_test_idle_er1;
wire run_test_idle_er2;
wire shift_dr_capture_dr;
wire update_dr;
wire pause_dr;
wire enable_er1;
wire enable_er2;
wire gao_jtag_tdi;
wire tdo_er1;

IBUF tms_ibuf (
    .I(tms_pad_i),
    .O(tms_i_c)
);

IBUF tck_ibuf (
    .I(tck_pad_i),
    .O(tck_i_c)
);

IBUF tdi_ibuf (
    .I(tdi_pad_i),
    .O(tdi_i_c)
);

OBUF tdo_obuf (
    .I(tdo_o_c),
    .O(tdo_pad_o)
);

GW_JTAG  u_gw_jtag(
    .tms_pad_i(tms_i_c),
    .tck_pad_i(tck_i_c),
    .tdi_pad_i(tdi_i_c),
    .tdo_pad_o(tdo_o_c),
    .tck_o(gao_jtag_tck),
    .test_logic_reset_o(gao_jtag_reset),
    .run_test_idle_er1_o(run_test_idle_er1),
    .run_test_idle_er2_o(run_test_idle_er2),
    .shift_dr_capture_dr_o(shift_dr_capture_dr),
    .update_dr_o(update_dr),
    .pause_dr_o(pause_dr),
    .enable_er1_o(enable_er1),
    .enable_er2_o(enable_er2),
    .tdi_o(gao_jtag_tdi),
    .tdo_er1_i(tdo_er1),
    .tdo_er2_i(1'b0)
);

gw_con_top  u_icon_top(
    .tck_i(gao_jtag_tck),
    .tdi_i(gao_jtag_tdi),
    .tdo_o(tdo_er1),
    .rst_i(gao_jtag_reset),
    .control0(control0[9:0]),
    .enable_i(enable_er1),
    .shift_dr_capture_dr_i(shift_dr_capture_dr),
    .update_dr_i(update_dr)
);

ao_top_0  u_la0_top(
    .control(control0[9:0]),
    .trig0_i(\nProc/intrStatus[1] ),
    .data_i({\nProc/dmaByteCount[31] ,\nProc/dmaByteCount[30] ,\nProc/dmaByteCount[29] ,\nProc/dmaByteCount[28] ,\nProc/dmaByteCount[27] ,\nProc/dmaByteCount[26] ,\nProc/dmaByteCount[25] ,\nProc/dmaByteCount[24] ,\nProc/dmaByteCount[23] ,\nProc/dmaByteCount[22] ,\nProc/dmaByteCount[21] ,\nProc/dmaByteCount[20] ,\nProc/dmaByteCount[19] ,\nProc/dmaByteCount[18] ,\nProc/dmaByteCount[17] ,\nProc/dmaByteCount[16] ,\nProc/dmaByteCount[15] ,\nProc/dmaByteCount[14] ,\nProc/dmaByteCount[13] ,\nProc/dmaByteCount[12] ,\nProc/dmaByteCount[11] ,\nProc/dmaByteCount[10] ,\nProc/dmaByteCount[9] ,\nProc/dmaByteCount[8] ,\nProc/dmaByteCount[7] ,\nProc/dmaByteCount[6] ,\nProc/dmaByteCount[5] ,\nProc/dmaByteCount[4] ,\nProc/dmaByteCount[3] ,\nProc/dmaByteCount[2] ,\nProc/dmaByteCount[1] ,\nProc/dmaByteCount[0] ,HACK,\nProc/ack_sampled ,dsp_cs_in,dsp_rd,dsp_wr,\nProc/cs_sync ,dma_clk,\dmaDataOut[31] ,\dmaDataOut[30] ,\dmaDataOut[29] ,\dmaDataOut[28] ,\dmaDataOut[27] ,\dmaDataOut[26] ,\dmaDataOut[25] ,\dmaDataOut[24] ,\dmaDataOut[23] ,\dmaDataOut[22] ,\dmaDataOut[21] ,\dmaDataOut[20] ,\dmaDataOut[19] ,\dmaDataOut[18] ,\dmaDataOut[17] ,\dmaDataOut[16] ,\dmaDataOut[15] ,\dmaDataOut[14] ,\dmaDataOut[13] ,\dmaDataOut[12] ,\dmaDataOut[11] ,\dmaDataOut[10] ,\dmaDataOut[9] ,\dmaDataOut[8] ,\dmaDataOut[7] ,\dmaDataOut[6] ,\dmaDataOut[5] ,\dmaDataOut[4] ,\dmaDataOut[3] ,\dmaDataOut[2] ,\dmaDataOut[1] ,\dmaDataOut[0] ,HDRQ,\nProc/currentDmaState[3] ,\nProc/currentDmaState[2] ,\nProc/currentDmaState[1] ,\nProc/currentDmaState[0] }),
    .clk_i(dma_clk)
);

endmodule
