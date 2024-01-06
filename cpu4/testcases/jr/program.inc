initial begin
// L0:
      asm_jr(JC_NEVER, 8'hFE); // 0B ..

      asm_ldc(0, 3);

// L1:
      asm_add_R_IM(0, 8'hFF);
      asm_jr(JC_NZ, 8'hFB);     // L1

      asm_jr(JC_ALWAYS, 8'hF5); // L0
end
