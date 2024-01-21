localparam L0_ = 16'h0C;
initial begin
      default_interrupt_vectors();

label(L0_);
      asm_srp('h20);
      asm_ld_r_IM(0, L0_ >> 8);
      asm_ld_r_IM(1, L0_);
      asm_ld_r_IM(2, 'hA5);
      asm_ld_R_IM(SPL, 8'h80);
      asm_push('hE1);
      asm_push('hE0);
      asm_push('hE2);
      asm_iret();

      asm_jp(JC_ALWAYS, L0_);
end
