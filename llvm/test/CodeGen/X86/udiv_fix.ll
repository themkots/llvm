; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: llc < %s -mtriple=x86_64-linux | FileCheck %s --check-prefix=X64
; RUN: llc < %s -mtriple=i686 -mattr=cmov | FileCheck %s --check-prefix=X86

declare  i4  @llvm.udiv.fix.i4   (i4,  i4,  i32)
declare  i15 @llvm.udiv.fix.i15  (i15, i15, i32)
declare  i16 @llvm.udiv.fix.i16  (i16, i16, i32)
declare  i18 @llvm.udiv.fix.i18  (i18, i18, i32)
declare  i64 @llvm.udiv.fix.i64  (i64, i64, i32)
declare  <4 x i32> @llvm.udiv.fix.v4i32(<4 x i32>, <4 x i32>, i32)

define i16 @func(i16 %x, i16 %y) nounwind {
; X64-LABEL: func:
; X64:       # %bb.0:
; X64-NEXT:    movzwl %si, %ecx
; X64-NEXT:    movzwl %di, %eax
; X64-NEXT:    shll $7, %eax
; X64-NEXT:    xorl %edx, %edx
; X64-NEXT:    divl %ecx
; X64-NEXT:    # kill: def $ax killed $ax killed $eax
; X64-NEXT:    retq
;
; X86-LABEL: func:
; X86:       # %bb.0:
; X86-NEXT:    movzwl {{[0-9]+}}(%esp), %ecx
; X86-NEXT:    movzwl {{[0-9]+}}(%esp), %eax
; X86-NEXT:    shll $7, %eax
; X86-NEXT:    xorl %edx, %edx
; X86-NEXT:    divl %ecx
; X86-NEXT:    # kill: def $ax killed $ax killed $eax
; X86-NEXT:    retl
  %tmp = call i16 @llvm.udiv.fix.i16(i16 %x, i16 %y, i32 7)
  ret i16 %tmp
}

define i16 @func2(i8 %x, i8 %y) nounwind {
; X64-LABEL: func2:
; X64:       # %bb.0:
; X64-NEXT:    movsbl %dil, %eax
; X64-NEXT:    andl $32767, %eax # imm = 0x7FFF
; X64-NEXT:    movsbl %sil, %ecx
; X64-NEXT:    andl $32767, %ecx # imm = 0x7FFF
; X64-NEXT:    shll $14, %eax
; X64-NEXT:    xorl %edx, %edx
; X64-NEXT:    divl %ecx
; X64-NEXT:    addl %eax, %eax
; X64-NEXT:    cwtl
; X64-NEXT:    shrl %eax
; X64-NEXT:    # kill: def $ax killed $ax killed $eax
; X64-NEXT:    retq
;
; X86-LABEL: func2:
; X86:       # %bb.0:
; X86-NEXT:    movsbl {{[0-9]+}}(%esp), %ecx
; X86-NEXT:    andl $32767, %ecx # imm = 0x7FFF
; X86-NEXT:    movsbl {{[0-9]+}}(%esp), %eax
; X86-NEXT:    andl $32767, %eax # imm = 0x7FFF
; X86-NEXT:    shll $14, %eax
; X86-NEXT:    xorl %edx, %edx
; X86-NEXT:    divl %ecx
; X86-NEXT:    addl %eax, %eax
; X86-NEXT:    cwtl
; X86-NEXT:    shrl %eax
; X86-NEXT:    # kill: def $ax killed $ax killed $eax
; X86-NEXT:    retl
  %x2 = sext i8 %x to i15
  %y2 = sext i8 %y to i15
  %tmp = call i15 @llvm.udiv.fix.i15(i15 %x2, i15 %y2, i32 14)
  %tmp2 = sext i15 %tmp to i16
  ret i16 %tmp2
}

define i16 @func3(i15 %x, i8 %y) nounwind {
; X64-LABEL: func3:
; X64:       # %bb.0:
; X64-NEXT:    # kill: def $edi killed $edi def $rdi
; X64-NEXT:    leal (%rdi,%rdi), %eax
; X64-NEXT:    movzbl %sil, %ecx
; X64-NEXT:    shll $4, %ecx
; X64-NEXT:    # kill: def $ax killed $ax killed $eax
; X64-NEXT:    xorl %edx, %edx
; X64-NEXT:    divw %cx
; X64-NEXT:    # kill: def $ax killed $ax def $eax
; X64-NEXT:    addl %eax, %eax
; X64-NEXT:    cwtl
; X64-NEXT:    shrl %eax
; X64-NEXT:    # kill: def $ax killed $ax killed $eax
; X64-NEXT:    retq
;
; X86-LABEL: func3:
; X86:       # %bb.0:
; X86-NEXT:    movl {{[0-9]+}}(%esp), %eax
; X86-NEXT:    movl {{[0-9]+}}(%esp), %ecx
; X86-NEXT:    addl %eax, %eax
; X86-NEXT:    movzbl %cl, %ecx
; X86-NEXT:    shll $4, %ecx
; X86-NEXT:    # kill: def $ax killed $ax killed $eax
; X86-NEXT:    xorl %edx, %edx
; X86-NEXT:    divw %cx
; X86-NEXT:    # kill: def $ax killed $ax def $eax
; X86-NEXT:    addl %eax, %eax
; X86-NEXT:    cwtl
; X86-NEXT:    shrl %eax
; X86-NEXT:    # kill: def $ax killed $ax killed $eax
; X86-NEXT:    retl
  %y2 = sext i8 %y to i15
  %y3 = shl i15 %y2, 7
  %tmp = call i15 @llvm.udiv.fix.i15(i15 %x, i15 %y3, i32 4)
  %tmp2 = sext i15 %tmp to i16
  ret i16 %tmp2
}

define i4 @func4(i4 %x, i4 %y) nounwind {
; X64-LABEL: func4:
; X64:       # %bb.0:
; X64-NEXT:    andb $15, %sil
; X64-NEXT:    andb $15, %dil
; X64-NEXT:    shlb $2, %dil
; X64-NEXT:    movzbl %dil, %eax
; X64-NEXT:    divb %sil
; X64-NEXT:    retq
;
; X86-LABEL: func4:
; X86:       # %bb.0:
; X86-NEXT:    movb {{[0-9]+}}(%esp), %cl
; X86-NEXT:    andb $15, %cl
; X86-NEXT:    movb {{[0-9]+}}(%esp), %al
; X86-NEXT:    andb $15, %al
; X86-NEXT:    shlb $2, %al
; X86-NEXT:    movzbl %al, %eax
; X86-NEXT:    divb %cl
; X86-NEXT:    retl
  %tmp = call i4 @llvm.udiv.fix.i4(i4 %x, i4 %y, i32 2)
  ret i4 %tmp
}

define i64 @func5(i64 %x, i64 %y) nounwind {
; X64-LABEL: func5:
; X64:       # %bb.0:
; X64-NEXT:    pushq %rax
; X64-NEXT:    movq %rsi, %rdx
; X64-NEXT:    movq %rdi, %rsi
; X64-NEXT:    shlq $31, %rdi
; X64-NEXT:    shrq $33, %rsi
; X64-NEXT:    xorl %ecx, %ecx
; X64-NEXT:    callq __udivti3
; X64-NEXT:    popq %rcx
; X64-NEXT:    retq
;
; X86-LABEL: func5:
; X86:       # %bb.0:
; X86-NEXT:    pushl %ebp
; X86-NEXT:    movl %esp, %ebp
; X86-NEXT:    pushl %esi
; X86-NEXT:    andl $-8, %esp
; X86-NEXT:    subl $24, %esp
; X86-NEXT:    movl 8(%ebp), %eax
; X86-NEXT:    movl 12(%ebp), %ecx
; X86-NEXT:    movl %ecx, %edx
; X86-NEXT:    shrl %edx
; X86-NEXT:    shldl $31, %eax, %ecx
; X86-NEXT:    shll $31, %eax
; X86-NEXT:    movl %esp, %esi
; X86-NEXT:    pushl $0
; X86-NEXT:    pushl $0
; X86-NEXT:    pushl 20(%ebp)
; X86-NEXT:    pushl 16(%ebp)
; X86-NEXT:    pushl $0
; X86-NEXT:    pushl %edx
; X86-NEXT:    pushl %ecx
; X86-NEXT:    pushl %eax
; X86-NEXT:    pushl %esi
; X86-NEXT:    calll __udivti3
; X86-NEXT:    addl $32, %esp
; X86-NEXT:    movl (%esp), %eax
; X86-NEXT:    movl {{[0-9]+}}(%esp), %edx
; X86-NEXT:    leal -4(%ebp), %esp
; X86-NEXT:    popl %esi
; X86-NEXT:    popl %ebp
; X86-NEXT:    retl
  %tmp = call i64 @llvm.udiv.fix.i64(i64 %x, i64 %y, i32 31)
  ret i64 %tmp
}

define i18 @func6(i16 %x, i16 %y) nounwind {
; X64-LABEL: func6:
; X64:       # %bb.0:
; X64-NEXT:    movswl %di, %eax
; X64-NEXT:    andl $262143, %eax # imm = 0x3FFFF
; X64-NEXT:    movswl %si, %ecx
; X64-NEXT:    andl $262143, %ecx # imm = 0x3FFFF
; X64-NEXT:    shll $7, %eax
; X64-NEXT:    xorl %edx, %edx
; X64-NEXT:    divl %ecx
; X64-NEXT:    retq
;
; X86-LABEL: func6:
; X86:       # %bb.0:
; X86-NEXT:    movswl {{[0-9]+}}(%esp), %ecx
; X86-NEXT:    andl $262143, %ecx # imm = 0x3FFFF
; X86-NEXT:    movswl {{[0-9]+}}(%esp), %eax
; X86-NEXT:    andl $262143, %eax # imm = 0x3FFFF
; X86-NEXT:    shll $7, %eax
; X86-NEXT:    xorl %edx, %edx
; X86-NEXT:    divl %ecx
; X86-NEXT:    retl
  %x2 = sext i16 %x to i18
  %y2 = sext i16 %y to i18
  %tmp = call i18 @llvm.udiv.fix.i18(i18 %x2, i18 %y2, i32 7)
  ret i18 %tmp
}

define i16 @func7(i16 %x, i16 %y) nounwind {
; X64-LABEL: func7:
; X64:       # %bb.0:
; X64-NEXT:    movl %edi, %eax
; X64-NEXT:    shll $16, %eax
; X64-NEXT:    movzwl %si, %ecx
; X64-NEXT:    xorl %edx, %edx
; X64-NEXT:    divl %ecx
; X64-NEXT:    # kill: def $ax killed $ax killed $eax
; X64-NEXT:    retq
;
; X86-LABEL: func7:
; X86:       # %bb.0:
; X86-NEXT:    movzwl {{[0-9]+}}(%esp), %ecx
; X86-NEXT:    movzwl {{[0-9]+}}(%esp), %eax
; X86-NEXT:    shll $16, %eax
; X86-NEXT:    xorl %edx, %edx
; X86-NEXT:    divl %ecx
; X86-NEXT:    # kill: def $ax killed $ax killed $eax
; X86-NEXT:    retl
  %tmp = call i16 @llvm.udiv.fix.i16(i16 %x, i16 %y, i32 16)
  ret i16 %tmp
}

define <4 x i32> @vec(<4 x i32> %x, <4 x i32> %y) nounwind {
; X64-LABEL: vec:
; X64:       # %bb.0:
; X64-NEXT:    pxor %xmm2, %xmm2
; X64-NEXT:    movdqa %xmm1, %xmm4
; X64-NEXT:    punpckhdq {{.*#+}} xmm4 = xmm4[2],xmm2[2],xmm4[3],xmm2[3]
; X64-NEXT:    movq %xmm4, %rcx
; X64-NEXT:    movdqa %xmm0, %xmm5
; X64-NEXT:    punpckhdq {{.*#+}} xmm5 = xmm5[2],xmm2[2],xmm5[3],xmm2[3]
; X64-NEXT:    psllq $31, %xmm5
; X64-NEXT:    movq %xmm5, %rax
; X64-NEXT:    xorl %edx, %edx
; X64-NEXT:    divq %rcx
; X64-NEXT:    movq %rax, %xmm3
; X64-NEXT:    pshufd {{.*#+}} xmm4 = xmm4[2,3,2,3]
; X64-NEXT:    movq %xmm4, %rcx
; X64-NEXT:    pshufd {{.*#+}} xmm4 = xmm5[2,3,2,3]
; X64-NEXT:    movq %xmm4, %rax
; X64-NEXT:    xorl %edx, %edx
; X64-NEXT:    divq %rcx
; X64-NEXT:    movq %rax, %xmm4
; X64-NEXT:    punpcklqdq {{.*#+}} xmm3 = xmm3[0],xmm4[0]
; X64-NEXT:    punpckldq {{.*#+}} xmm1 = xmm1[0],xmm2[0],xmm1[1],xmm2[1]
; X64-NEXT:    movq %xmm1, %rcx
; X64-NEXT:    punpckldq {{.*#+}} xmm0 = xmm0[0],xmm2[0],xmm0[1],xmm2[1]
; X64-NEXT:    psllq $31, %xmm0
; X64-NEXT:    movq %xmm0, %rax
; X64-NEXT:    xorl %edx, %edx
; X64-NEXT:    divq %rcx
; X64-NEXT:    movq %rax, %xmm2
; X64-NEXT:    pshufd {{.*#+}} xmm1 = xmm1[2,3,2,3]
; X64-NEXT:    movq %xmm1, %rcx
; X64-NEXT:    pshufd {{.*#+}} xmm0 = xmm0[2,3,2,3]
; X64-NEXT:    movq %xmm0, %rax
; X64-NEXT:    xorl %edx, %edx
; X64-NEXT:    divq %rcx
; X64-NEXT:    movq %rax, %xmm0
; X64-NEXT:    punpcklqdq {{.*#+}} xmm2 = xmm2[0],xmm0[0]
; X64-NEXT:    shufps {{.*#+}} xmm2 = xmm2[0,2],xmm3[0,2]
; X64-NEXT:    movaps %xmm2, %xmm0
; X64-NEXT:    retq
;
; X86-LABEL: vec:
; X86:       # %bb.0:
; X86-NEXT:    pushl %ebp
; X86-NEXT:    pushl %ebx
; X86-NEXT:    pushl %edi
; X86-NEXT:    pushl %esi
; X86-NEXT:    pushl %eax
; X86-NEXT:    movl {{[0-9]+}}(%esp), %esi
; X86-NEXT:    movl {{[0-9]+}}(%esp), %edi
; X86-NEXT:    movl {{[0-9]+}}(%esp), %ebp
; X86-NEXT:    movl {{[0-9]+}}(%esp), %ebx
; X86-NEXT:    movl {{[0-9]+}}(%esp), %eax
; X86-NEXT:    movl %eax, %ecx
; X86-NEXT:    shrl %ecx
; X86-NEXT:    shll $31, %eax
; X86-NEXT:    pushl $0
; X86-NEXT:    pushl {{[0-9]+}}(%esp)
; X86-NEXT:    pushl %ecx
; X86-NEXT:    pushl %eax
; X86-NEXT:    calll __udivdi3
; X86-NEXT:    addl $16, %esp
; X86-NEXT:    movl %eax, (%esp) # 4-byte Spill
; X86-NEXT:    movl %ebx, %eax
; X86-NEXT:    shrl %eax
; X86-NEXT:    shll $31, %ebx
; X86-NEXT:    pushl $0
; X86-NEXT:    pushl {{[0-9]+}}(%esp)
; X86-NEXT:    pushl %eax
; X86-NEXT:    pushl %ebx
; X86-NEXT:    calll __udivdi3
; X86-NEXT:    addl $16, %esp
; X86-NEXT:    movl %eax, %ebx
; X86-NEXT:    movl %ebp, %eax
; X86-NEXT:    shrl %eax
; X86-NEXT:    shll $31, %ebp
; X86-NEXT:    pushl $0
; X86-NEXT:    pushl {{[0-9]+}}(%esp)
; X86-NEXT:    pushl %eax
; X86-NEXT:    pushl %ebp
; X86-NEXT:    calll __udivdi3
; X86-NEXT:    addl $16, %esp
; X86-NEXT:    movl %eax, %ebp
; X86-NEXT:    movl %edi, %eax
; X86-NEXT:    shrl %eax
; X86-NEXT:    shll $31, %edi
; X86-NEXT:    pushl $0
; X86-NEXT:    pushl {{[0-9]+}}(%esp)
; X86-NEXT:    pushl %eax
; X86-NEXT:    pushl %edi
; X86-NEXT:    calll __udivdi3
; X86-NEXT:    addl $16, %esp
; X86-NEXT:    movl %eax, 12(%esi)
; X86-NEXT:    movl %ebp, 8(%esi)
; X86-NEXT:    movl %ebx, 4(%esi)
; X86-NEXT:    movl (%esp), %eax # 4-byte Reload
; X86-NEXT:    movl %eax, (%esi)
; X86-NEXT:    movl %esi, %eax
; X86-NEXT:    addl $4, %esp
; X86-NEXT:    popl %esi
; X86-NEXT:    popl %edi
; X86-NEXT:    popl %ebx
; X86-NEXT:    popl %ebp
; X86-NEXT:    retl $4
  %tmp = call <4 x i32> @llvm.udiv.fix.v4i32(<4 x i32> %x, <4 x i32> %y, i32 31)
  ret <4 x i32> %tmp
}
