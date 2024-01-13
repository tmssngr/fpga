localparam L0_ = 16'h0;
initial begin
    label(L0_);
      asm_srp('h20);
      asm_ld_r_IM(0, 'h12);
      asm_ld_r_IM(1, 'h34);
      asm_ld_R_IM('hFF, 'h80);
      asm_push('hE0);
      asm_push('hE1);
      asm_pop('hE0);
      asm_pop('hE1);

      asm_jp(JC_ALWAYS, L0_);
end
