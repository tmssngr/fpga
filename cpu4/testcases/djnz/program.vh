initial begin
      default_interrupt_vectors();

// L0:
      asm_srp('h30);
      asm_ld_r_IM(0, 3);

// L1:
      asm_nop();
      asm_djnz(0, 8'hFD);       // L1

      asm_jr(JC_ALWAYS, 8'hF7); // L0
end
