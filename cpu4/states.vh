    localparam STATE_FETCH_INSTR  = 0;
    localparam STATE_READ_INSTR   = 1;
    localparam STATE_WAIT_2       = 2;
    localparam STATE_READ_2       = 3;
    localparam STATE_WAIT_3       = 4;
    localparam STATE_READ_3       = 5;
    localparam STATE_DECODE       = 6;
    localparam STATE_ALU1_WORD    = 7;
    localparam STATE_ALU1_OP      = 8;
    localparam STATE_ALU1_DA      = 9;