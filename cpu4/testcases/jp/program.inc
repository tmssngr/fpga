localparam L0_ = 16'h0;
localparam L1_ = 16'h7;
initial begin
    label(L0_);
      asm_jp(JC_NEVER, 16'hFFFE); // 0D FF FE

      asm_ldc(0, 3);     // 0C 03
      asm_ldc(1, 8'hFF); // 1C FF

    label(L1_);
      asm_add(0, 1);       // 02 01
      asm_jp(JC_NZ, L1_);  // ED 00 02

      asm_jp(JC_ALWAYS, L0_);  // 8D 00 02
end
