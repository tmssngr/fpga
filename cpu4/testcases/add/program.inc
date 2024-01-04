localparam L0_ = 16'h0;
initial begin
    label(L0_);
      asm_ldc(0, 9);  // 0C 09
      asm_ldc(1, 1);  // 1C 01
      asm_add(0, 1);  // 02 01

      asm_ldc(1, 6);  // 1C 06
      asm_add(0, 1);  // 02 01

      asm_ldc(1, 'h80);  // 1C 80
      asm_add(0, 1);  // 02 01

      asm_ldc(1, 'h70);  // 1C 70
      asm_add(0, 1);  // 02 01

      asm_ldc(0, -1);  // 0C FF
      asm_ldc(1, -1);  // 0C FF
      asm_add(1, 0);   // 02 10

      asm_jp(JC_ALWAYS, L0_);  // 8D 00 02
end
