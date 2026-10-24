//Copyright (C)2014-2026 GOWIN Semiconductor Corporation.
//All rights reserved.
//File Title: Timing Constraints file
//Tool Version: V1.9.12 (64-bit) 
//Created Time: 2026-10-22 23:15:39
create_clock -name ps2_dma_clock -period 27.778 -waveform {0 13.889} [get_ports {dma_clk}]
create_clock -name main -period 37.037 -waveform {0 18.518} [get_ports {clk}]
