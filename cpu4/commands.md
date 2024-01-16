## Alu1
### Alu1 direct
- `x0` R
1.
	- dstRegister = r8(second)
2.
	- aluA = readRegister(dstRegister)
	- aluMode = x
	- writeRegister = 1
	- writeFlags = 1


### Alu1 indirect
- `x1` R
1.
	- dstRegister = readRegister(r8(second))
2.
	- continue with *2. Alu1 direct*


## Alu2
### Alu2 r, r:
- `x2` {dst, src}
1.
	- dstRegister = r4(secondH)
	- srcRegister = r4(secondL)
2.
	- aluB = readRegister(srcRegister)
3.
	- aluA = readRegister(r8(dstRegister))
	- aluMode = instrH
	- writeRegister = 1
	- writeFlags = 1

### Alu2 r, Ir
- `x3` {dst, src}
1.
	- dstRegister = r4(secondH)
	- srcRegister = readRegister(r4(secondL))
2.
	- continue with *2. Alu2 r, r*

### Alu2 R, R
- `x4` src dst
1.
	- srcRegister = r8(second)
	- dstRegister = read mem
2.
	- continue with *2. Alu2 r, r*

### Alu2 R, IR
- `x5` src dst
1.
	- srcRegister = readRegister(r8(second)
	- dstRegister = r8(read mem)
2.
	- continue with *2. Alu2 r, r*

### Alu2 R, IM
- `x6` dst IM
1.
	- dstRegister = second
	- alu2 = read mem
2.
	- continue with *3. Alu2 r, r*

### Alu2 IR, IM
- `x7` dst IM
1.
	- dstRegister = second
	- alu2 = read mem
2.
	- continue with *3. Alu2 r, r*


## Jp IRR:
- `30` R
1.
	- dstRegister = r8(second)
	- fetchNext = 0
2.
	- pcH = readRegister(dstRegister)
	- srcRegister = srcRegister + 1
3.
	- pcL = readRegister(srcRegister)

## Srp:
- `31` IM
1.
	- aluA = second
	- dstRegister = FD
	- writeRegister = 1

## Pop R:
### Pop direct
- `50` R
1.
	- dstRegister = r8(second)
	- readMem = 1
	- addr = sp
	- sp = sp + 1
2.
	- aluA = memData
	- aluMode = LD
	- writeRegister = 1
	- fetchNext = 1

### Pop indirect
- `51` R
1.
	- dstRegister = readRegister(r8(second))
	- readMem = 1
	- addr = sp
	- sp = sp + 1
2.
	- aluA = memData
	- aluMode = LD
	- writeRegister = 1
	- fetchNext = 1

## Push
### Push direct
- `70` R
1.
	- srcRegister = r8(second)
	- fetchNext = 0
	- addr = sp - 1
	- sp = sp - 1
2.
	- memData = readRegister(srcRegister)
	- writeMem = 1

### Push indirect
- `71` reg
1.
	- srcRegister = readRegister(r8(second))
	- fetchNext = 0
	- addr = sp - 1
	- sp = sp - 1
2.
	- continue with *2. Push direct*

## Djnz
- `xA` RA
- 12/10+5 cyles
    - 3 cycles reading xA
    - 3 cycles reading RA
1.
	- dstRegister = r4(instrH)
2.
    - addrL = pcL + RA
3.
    - addrH = pcH + (sign-extend)RA[7] + carry
	- aluA = readRegister(dstRegister)
	- writeRegister = 1
4.
	- if (aluOut == z)
		fetchNext
5.
	- pc = addr


## Call
### Call direct
- `D6` daH daL
- 20/0 cycles
    - 3 cycles reading D6
    - 3 cycles reading daH (6)
    - 3 cycles reading daL (9)
    - 3 cycles writing pcL (12)
    - 3 cycles writing pcH (15)
1.
	- addr = sp - 1
	- sp = sp - 1
	- memData = pcL
	- pcL = daL
	- writeMem = 1
2.
	- addr = sp - 1
	- sp = sp - 1
	- memData = pcH
	- writeMem = pcH
3.
	- pc = DA

### Call indirect
- `D4` IRR
1.
	- see *1. Call direct*
2.
	- see *2. Call direct*
3.
	- srcRegister = r8(IRR)
4.
	- pcH = readRegister(r8(srcRegister))
	- srcRegister = srcRegister + 1
5.
	- pcL = readRegister(r8(srcRegister))

## Ret
- `AF`
- 14/0 cycles
	- 3 cycles reading AF
1.
	- addr = sp
	- sp = sp + 1
	- readMem = 1
2.
	- pcH = memData
	- addr = sp
	- sp = sp + 1
	- readMem = 1
3.
	- pcL = memData

## Iret
- `BF`
- 16/0 cycles
	- 3 cycles reading BF
1.
	- addr = sp
	- sp = sp + 1
	- readMem = 1
2.
	- flags = memData
	- addr = sp
	- sp = sp + 1
	- readMem = 1
3.
	- pcH = memData
	- addr = sp
	- sp = sp + 1
	- readMem = 1
4.
	- pcL = memData
	- enable interrupts

## Load
### ld r, X(r)
- `C7` {dst, src} X
- 10+5 cycles
1.
	- dstRegister = r4(secondH)
	- aluA = r4(secondL)
	- readThird
	- aluMode = ADD
2.
	- srcRegister = aluOut
	- aluB = third
3.
	- aluA = readRegister(srcRegister)
	- writeRegister = 1

### ld X(r), r
- `D7` {src, X] dst
