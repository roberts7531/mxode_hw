package ps2_types_pkg;

    typedef logic [7:0] disc_type_t;

    localparam disc_type_t DISC_NO_DISC          = 8'h00;
    localparam disc_type_t DISC_DETECTING        = 8'h01;
    localparam disc_type_t DISC_DETECTING_CD     = 8'h02;
    localparam disc_type_t DISC_DETECTING_DVD    = 8'h03;
    localparam disc_type_t DISC_DETECTING_DVD_DL = 8'h04;
    localparam disc_type_t DISC_UNKNOWN          = 8'h05;

    localparam disc_type_t DISC_PSX_CD           = 8'h10;
    localparam disc_type_t DISC_PSX_CDDA         = 8'h11;
    localparam disc_type_t DISC_PS2_CD            = 8'h12;
    localparam disc_type_t DISC_PS2_CDDA          = 8'h13;
    localparam disc_type_t DISC_PS2_DVD           = 8'h14;

    localparam disc_type_t DISC_CDDA_MUSIC        = 8'hFD;
    localparam disc_type_t DISC_DVD_VIDEO         = 8'hFE;
    localparam disc_type_t DISC_ILLEGAL           = 8'hFF;

endpackage