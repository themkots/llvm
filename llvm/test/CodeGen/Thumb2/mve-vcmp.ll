; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: llc -mtriple=thumbv8.1m.main-arm-none-eabi -mattr=+mve -verify-machineinstrs %s -o - | FileCheck %s

define arm_aapcs_vfpcc <4 x i32> @vcmp_eq_v4i32(<4 x i32> %src, <4 x i32> %srcb, <4 x i32> %a, <4 x i32> %b) {
; CHECK-LABEL: vcmp_eq_v4i32:
; CHECK:       @ %bb.0: @ %entry
; CHECK-NEXT:    vcmp.i32 eq, q0, q1
; CHECK-NEXT:    vpsel q0, q2, q3
; CHECK-NEXT:    bx lr
entry:
  %c = icmp eq <4 x i32> %src, %srcb
  %s = select <4 x i1> %c, <4 x i32> %a, <4 x i32> %b
  ret <4 x i32> %s
}

define arm_aapcs_vfpcc <4 x i32> @vcmp_ne_v4i32(<4 x i32> %src, <4 x i32> %srcb, <4 x i32> %a, <4 x i32> %b) {
; CHECK-LABEL: vcmp_ne_v4i32:
; CHECK:       @ %bb.0: @ %entry
; CHECK-NEXT:    vcmp.i32 ne, q0, q1
; CHECK-NEXT:    vpsel q0, q2, q3
; CHECK-NEXT:    bx lr
entry:
  %c = icmp ne <4 x i32> %src, %srcb
  %s = select <4 x i1> %c, <4 x i32> %a, <4 x i32> %b
  ret <4 x i32> %s
}

define arm_aapcs_vfpcc <4 x i32> @vcmp_sgt_v4i32(<4 x i32> %src, <4 x i32> %srcb, <4 x i32> %a, <4 x i32> %b) {
; CHECK-LABEL: vcmp_sgt_v4i32:
; CHECK:       @ %bb.0: @ %entry
; CHECK-NEXT:    vcmp.s32 gt, q0, q1
; CHECK-NEXT:    vpsel q0, q2, q3
; CHECK-NEXT:    bx lr
entry:
  %c = icmp sgt <4 x i32> %src, %srcb
  %s = select <4 x i1> %c, <4 x i32> %a, <4 x i32> %b
  ret <4 x i32> %s
}

define arm_aapcs_vfpcc <4 x i32> @vcmp_sge_v4i32(<4 x i32> %src, <4 x i32> %srcb, <4 x i32> %a, <4 x i32> %b) {
; CHECK-LABEL: vcmp_sge_v4i32:
; CHECK:       @ %bb.0: @ %entry
; CHECK-NEXT:    vcmp.s32 ge, q0, q1
; CHECK-NEXT:    vpsel q0, q2, q3
; CHECK-NEXT:    bx lr
entry:
  %c = icmp sge <4 x i32> %src, %srcb
  %s = select <4 x i1> %c, <4 x i32> %a, <4 x i32> %b
  ret <4 x i32> %s
}

define arm_aapcs_vfpcc <4 x i32> @vcmp_slt_v4i32(<4 x i32> %src, <4 x i32> %srcb, <4 x i32> %a, <4 x i32> %b) {
; CHECK-LABEL: vcmp_slt_v4i32:
; CHECK:       @ %bb.0: @ %entry
; CHECK-NEXT:    vcmp.s32 gt, q1, q0
; CHECK-NEXT:    vpsel q0, q2, q3
; CHECK-NEXT:    bx lr
entry:
  %c = icmp slt <4 x i32> %src, %srcb
  %s = select <4 x i1> %c, <4 x i32> %a, <4 x i32> %b
  ret <4 x i32> %s
}

define arm_aapcs_vfpcc <4 x i32> @vcmp_sle_v4i32(<4 x i32> %src, <4 x i32> %srcb, <4 x i32> %a, <4 x i32> %b) {
; CHECK-LABEL: vcmp_sle_v4i32:
; CHECK:       @ %bb.0: @ %entry
; CHECK-NEXT:    vcmp.s32 ge, q1, q0
; CHECK-NEXT:    vpsel q0, q2, q3
; CHECK-NEXT:    bx lr
entry:
  %c = icmp sle <4 x i32> %src, %srcb
  %s = select <4 x i1> %c, <4 x i32> %a, <4 x i32> %b
  ret <4 x i32> %s
}

define arm_aapcs_vfpcc <4 x i32> @vcmp_ugt_v4i32(<4 x i32> %src, <4 x i32> %srcb, <4 x i32> %a, <4 x i32> %b) {
; CHECK-LABEL: vcmp_ugt_v4i32:
; CHECK:       @ %bb.0: @ %entry
; CHECK-NEXT:    vcmp.u32 hi, q0, q1
; CHECK-NEXT:    vpsel q0, q2, q3
; CHECK-NEXT:    bx lr
entry:
  %c = icmp ugt <4 x i32> %src, %srcb
  %s = select <4 x i1> %c, <4 x i32> %a, <4 x i32> %b
  ret <4 x i32> %s
}

define arm_aapcs_vfpcc <4 x i32> @vcmp_uge_v4i32(<4 x i32> %src, <4 x i32> %srcb, <4 x i32> %a, <4 x i32> %b) {
; CHECK-LABEL: vcmp_uge_v4i32:
; CHECK:       @ %bb.0: @ %entry
; CHECK-NEXT:    vcmp.u32 cs, q0, q1
; CHECK-NEXT:    vpsel q0, q2, q3
; CHECK-NEXT:    bx lr
entry:
  %c = icmp uge <4 x i32> %src, %srcb
  %s = select <4 x i1> %c, <4 x i32> %a, <4 x i32> %b
  ret <4 x i32> %s
}

define arm_aapcs_vfpcc <4 x i32> @vcmp_ult_v4i32(<4 x i32> %src, <4 x i32> %srcb, <4 x i32> %a, <4 x i32> %b) {
; CHECK-LABEL: vcmp_ult_v4i32:
; CHECK:       @ %bb.0: @ %entry
; CHECK-NEXT:    vcmp.u32 hi, q1, q0
; CHECK-NEXT:    vpsel q0, q2, q3
; CHECK-NEXT:    bx lr
entry:
  %c = icmp ult <4 x i32> %src, %srcb
  %s = select <4 x i1> %c, <4 x i32> %a, <4 x i32> %b
  ret <4 x i32> %s
}

define arm_aapcs_vfpcc <4 x i32> @vcmp_ule_v4i32(<4 x i32> %src, <4 x i32> %srcb, <4 x i32> %a, <4 x i32> %b) {
; CHECK-LABEL: vcmp_ule_v4i32:
; CHECK:       @ %bb.0: @ %entry
; CHECK-NEXT:    vcmp.u32 cs, q1, q0
; CHECK-NEXT:    vpsel q0, q2, q3
; CHECK-NEXT:    bx lr
entry:
  %c = icmp ule <4 x i32> %src, %srcb
  %s = select <4 x i1> %c, <4 x i32> %a, <4 x i32> %b
  ret <4 x i32> %s
}


define arm_aapcs_vfpcc <8 x i16> @vcmp_eq_v8i16(<8 x i16> %src, <8 x i16> %srcb, <8 x i16> %a, <8 x i16> %b) {
; CHECK-LABEL: vcmp_eq_v8i16:
; CHECK:       @ %bb.0: @ %entry
; CHECK-NEXT:    vcmp.i16 eq, q0, q1
; CHECK-NEXT:    vpsel q0, q2, q3
; CHECK-NEXT:    bx lr
entry:
  %c = icmp eq <8 x i16> %src, %srcb
  %s = select <8 x i1> %c, <8 x i16> %a, <8 x i16> %b
  ret <8 x i16> %s
}

define arm_aapcs_vfpcc <8 x i16> @vcmp_ne_v8i16(<8 x i16> %src, <8 x i16> %srcb, <8 x i16> %a, <8 x i16> %b) {
; CHECK-LABEL: vcmp_ne_v8i16:
; CHECK:       @ %bb.0: @ %entry
; CHECK-NEXT:    vcmp.i16 ne, q0, q1
; CHECK-NEXT:    vpsel q0, q2, q3
; CHECK-NEXT:    bx lr
entry:
  %c = icmp ne <8 x i16> %src, %srcb
  %s = select <8 x i1> %c, <8 x i16> %a, <8 x i16> %b
  ret <8 x i16> %s
}

define arm_aapcs_vfpcc <8 x i16> @vcmp_sgt_v8i16(<8 x i16> %src, <8 x i16> %srcb, <8 x i16> %a, <8 x i16> %b) {
; CHECK-LABEL: vcmp_sgt_v8i16:
; CHECK:       @ %bb.0: @ %entry
; CHECK-NEXT:    vcmp.s16 gt, q0, q1
; CHECK-NEXT:    vpsel q0, q2, q3
; CHECK-NEXT:    bx lr
entry:
  %c = icmp sgt <8 x i16> %src, %srcb
  %s = select <8 x i1> %c, <8 x i16> %a, <8 x i16> %b
  ret <8 x i16> %s
}

define arm_aapcs_vfpcc <8 x i16> @vcmp_sge_v8i16(<8 x i16> %src, <8 x i16> %srcb, <8 x i16> %a, <8 x i16> %b) {
; CHECK-LABEL: vcmp_sge_v8i16:
; CHECK:       @ %bb.0: @ %entry
; CHECK-NEXT:    vcmp.s16 ge, q0, q1
; CHECK-NEXT:    vpsel q0, q2, q3
; CHECK-NEXT:    bx lr
entry:
  %c = icmp sge <8 x i16> %src, %srcb
  %s = select <8 x i1> %c, <8 x i16> %a, <8 x i16> %b
  ret <8 x i16> %s
}

define arm_aapcs_vfpcc <8 x i16> @vcmp_slt_v8i16(<8 x i16> %src, <8 x i16> %srcb, <8 x i16> %a, <8 x i16> %b) {
; CHECK-LABEL: vcmp_slt_v8i16:
; CHECK:       @ %bb.0: @ %entry
; CHECK-NEXT:    vcmp.s16 gt, q1, q0
; CHECK-NEXT:    vpsel q0, q2, q3
; CHECK-NEXT:    bx lr
entry:
  %c = icmp slt <8 x i16> %src, %srcb
  %s = select <8 x i1> %c, <8 x i16> %a, <8 x i16> %b
  ret <8 x i16> %s
}

define arm_aapcs_vfpcc <8 x i16> @vcmp_sle_v8i16(<8 x i16> %src, <8 x i16> %srcb, <8 x i16> %a, <8 x i16> %b) {
; CHECK-LABEL: vcmp_sle_v8i16:
; CHECK:       @ %bb.0: @ %entry
; CHECK-NEXT:    vcmp.s16 ge, q1, q0
; CHECK-NEXT:    vpsel q0, q2, q3
; CHECK-NEXT:    bx lr
entry:
  %c = icmp sle <8 x i16> %src, %srcb
  %s = select <8 x i1> %c, <8 x i16> %a, <8 x i16> %b
  ret <8 x i16> %s
}

define arm_aapcs_vfpcc <8 x i16> @vcmp_ugt_v8i16(<8 x i16> %src, <8 x i16> %srcb, <8 x i16> %a, <8 x i16> %b) {
; CHECK-LABEL: vcmp_ugt_v8i16:
; CHECK:       @ %bb.0: @ %entry
; CHECK-NEXT:    vcmp.u16 hi, q0, q1
; CHECK-NEXT:    vpsel q0, q2, q3
; CHECK-NEXT:    bx lr
entry:
  %c = icmp ugt <8 x i16> %src, %srcb
  %s = select <8 x i1> %c, <8 x i16> %a, <8 x i16> %b
  ret <8 x i16> %s
}

define arm_aapcs_vfpcc <8 x i16> @vcmp_uge_v8i16(<8 x i16> %src, <8 x i16> %srcb, <8 x i16> %a, <8 x i16> %b) {
; CHECK-LABEL: vcmp_uge_v8i16:
; CHECK:       @ %bb.0: @ %entry
; CHECK-NEXT:    vcmp.u16 cs, q0, q1
; CHECK-NEXT:    vpsel q0, q2, q3
; CHECK-NEXT:    bx lr
entry:
  %c = icmp uge <8 x i16> %src, %srcb
  %s = select <8 x i1> %c, <8 x i16> %a, <8 x i16> %b
  ret <8 x i16> %s
}

define arm_aapcs_vfpcc <8 x i16> @vcmp_ult_v8i16(<8 x i16> %src, <8 x i16> %srcb, <8 x i16> %a, <8 x i16> %b) {
; CHECK-LABEL: vcmp_ult_v8i16:
; CHECK:       @ %bb.0: @ %entry
; CHECK-NEXT:    vcmp.u16 hi, q1, q0
; CHECK-NEXT:    vpsel q0, q2, q3
; CHECK-NEXT:    bx lr
entry:
  %c = icmp ult <8 x i16> %src, %srcb
  %s = select <8 x i1> %c, <8 x i16> %a, <8 x i16> %b
  ret <8 x i16> %s
}

define arm_aapcs_vfpcc <8 x i16> @vcmp_ule_v8i16(<8 x i16> %src, <8 x i16> %srcb, <8 x i16> %a, <8 x i16> %b) {
; CHECK-LABEL: vcmp_ule_v8i16:
; CHECK:       @ %bb.0: @ %entry
; CHECK-NEXT:    vcmp.u16 cs, q1, q0
; CHECK-NEXT:    vpsel q0, q2, q3
; CHECK-NEXT:    bx lr
entry:
  %c = icmp ule <8 x i16> %src, %srcb
  %s = select <8 x i1> %c, <8 x i16> %a, <8 x i16> %b
  ret <8 x i16> %s
}


define arm_aapcs_vfpcc <16 x i8> @vcmp_eq_v16i8(<16 x i8> %src, <16 x i8> %srcb, <16 x i8> %a, <16 x i8> %b) {
; CHECK-LABEL: vcmp_eq_v16i8:
; CHECK:       @ %bb.0: @ %entry
; CHECK-NEXT:    vcmp.i8 eq, q0, q1
; CHECK-NEXT:    vpsel q0, q2, q3
; CHECK-NEXT:    bx lr
entry:
  %c = icmp eq <16 x i8> %src, %srcb
  %s = select <16 x i1> %c, <16 x i8> %a, <16 x i8> %b
  ret <16 x i8> %s
}

define arm_aapcs_vfpcc <16 x i8> @vcmp_ne_v16i8(<16 x i8> %src, <16 x i8> %srcb, <16 x i8> %a, <16 x i8> %b) {
; CHECK-LABEL: vcmp_ne_v16i8:
; CHECK:       @ %bb.0: @ %entry
; CHECK-NEXT:    vcmp.i8 ne, q0, q1
; CHECK-NEXT:    vpsel q0, q2, q3
; CHECK-NEXT:    bx lr
entry:
  %c = icmp ne <16 x i8> %src, %srcb
  %s = select <16 x i1> %c, <16 x i8> %a, <16 x i8> %b
  ret <16 x i8> %s
}

define arm_aapcs_vfpcc <16 x i8> @vcmp_sgt_v16i8(<16 x i8> %src, <16 x i8> %srcb, <16 x i8> %a, <16 x i8> %b) {
; CHECK-LABEL: vcmp_sgt_v16i8:
; CHECK:       @ %bb.0: @ %entry
; CHECK-NEXT:    vcmp.s8 gt, q0, q1
; CHECK-NEXT:    vpsel q0, q2, q3
; CHECK-NEXT:    bx lr
entry:
  %c = icmp sgt <16 x i8> %src, %srcb
  %s = select <16 x i1> %c, <16 x i8> %a, <16 x i8> %b
  ret <16 x i8> %s
}

define arm_aapcs_vfpcc <16 x i8> @vcmp_sge_v16i8(<16 x i8> %src, <16 x i8> %srcb, <16 x i8> %a, <16 x i8> %b) {
; CHECK-LABEL: vcmp_sge_v16i8:
; CHECK:       @ %bb.0: @ %entry
; CHECK-NEXT:    vcmp.s8 ge, q0, q1
; CHECK-NEXT:    vpsel q0, q2, q3
; CHECK-NEXT:    bx lr
entry:
  %c = icmp sge <16 x i8> %src, %srcb
  %s = select <16 x i1> %c, <16 x i8> %a, <16 x i8> %b
  ret <16 x i8> %s
}

define arm_aapcs_vfpcc <16 x i8> @vcmp_slt_v16i8(<16 x i8> %src, <16 x i8> %srcb, <16 x i8> %a, <16 x i8> %b) {
; CHECK-LABEL: vcmp_slt_v16i8:
; CHECK:       @ %bb.0: @ %entry
; CHECK-NEXT:    vcmp.s8 gt, q1, q0
; CHECK-NEXT:    vpsel q0, q2, q3
; CHECK-NEXT:    bx lr
entry:
  %c = icmp slt <16 x i8> %src, %srcb
  %s = select <16 x i1> %c, <16 x i8> %a, <16 x i8> %b
  ret <16 x i8> %s
}

define arm_aapcs_vfpcc <16 x i8> @vcmp_sle_v16i8(<16 x i8> %src, <16 x i8> %srcb, <16 x i8> %a, <16 x i8> %b) {
; CHECK-LABEL: vcmp_sle_v16i8:
; CHECK:       @ %bb.0: @ %entry
; CHECK-NEXT:    vcmp.s8 ge, q1, q0
; CHECK-NEXT:    vpsel q0, q2, q3
; CHECK-NEXT:    bx lr
entry:
  %c = icmp sle <16 x i8> %src, %srcb
  %s = select <16 x i1> %c, <16 x i8> %a, <16 x i8> %b
  ret <16 x i8> %s
}

define arm_aapcs_vfpcc <16 x i8> @vcmp_ugt_v16i8(<16 x i8> %src, <16 x i8> %srcb, <16 x i8> %a, <16 x i8> %b) {
; CHECK-LABEL: vcmp_ugt_v16i8:
; CHECK:       @ %bb.0: @ %entry
; CHECK-NEXT:    vcmp.u8 hi, q0, q1
; CHECK-NEXT:    vpsel q0, q2, q3
; CHECK-NEXT:    bx lr
entry:
  %c = icmp ugt <16 x i8> %src, %srcb
  %s = select <16 x i1> %c, <16 x i8> %a, <16 x i8> %b
  ret <16 x i8> %s
}

define arm_aapcs_vfpcc <16 x i8> @vcmp_uge_v16i8(<16 x i8> %src, <16 x i8> %srcb, <16 x i8> %a, <16 x i8> %b) {
; CHECK-LABEL: vcmp_uge_v16i8:
; CHECK:       @ %bb.0: @ %entry
; CHECK-NEXT:    vcmp.u8 cs, q0, q1
; CHECK-NEXT:    vpsel q0, q2, q3
; CHECK-NEXT:    bx lr
entry:
  %c = icmp uge <16 x i8> %src, %srcb
  %s = select <16 x i1> %c, <16 x i8> %a, <16 x i8> %b
  ret <16 x i8> %s
}

define arm_aapcs_vfpcc <16 x i8> @vcmp_ult_v16i8(<16 x i8> %src, <16 x i8> %srcb, <16 x i8> %a, <16 x i8> %b) {
; CHECK-LABEL: vcmp_ult_v16i8:
; CHECK:       @ %bb.0: @ %entry
; CHECK-NEXT:    vcmp.u8 hi, q1, q0
; CHECK-NEXT:    vpsel q0, q2, q3
; CHECK-NEXT:    bx lr
entry:
  %c = icmp ult <16 x i8> %src, %srcb
  %s = select <16 x i1> %c, <16 x i8> %a, <16 x i8> %b
  ret <16 x i8> %s
}

define arm_aapcs_vfpcc <16 x i8> @vcmp_ule_v16i8(<16 x i8> %src, <16 x i8> %srcb, <16 x i8> %a, <16 x i8> %b) {
; CHECK-LABEL: vcmp_ule_v16i8:
; CHECK:       @ %bb.0: @ %entry
; CHECK-NEXT:    vcmp.u8 cs, q1, q0
; CHECK-NEXT:    vpsel q0, q2, q3
; CHECK-NEXT:    bx lr
entry:
  %c = icmp ule <16 x i8> %src, %srcb
  %s = select <16 x i1> %c, <16 x i8> %a, <16 x i8> %b
  ret <16 x i8> %s
}


define arm_aapcs_vfpcc <2 x i64> @vcmp_eq_v2i64(<2 x i64> %src, <2 x i64> %srcb, <2 x i64> %a, <2 x i64> %b) {
; CHECK-LABEL: vcmp_eq_v2i64:
; CHECK:       @ %bb.0: @ %entry
; CHECK-NEXT:    .vsave {d8, d9}
; CHECK-NEXT:    vpush {d8, d9}
; CHECK-NEXT:    vmov r0, s5
; CHECK-NEXT:    vmov r1, s1
; CHECK-NEXT:    vmov r2, s0
; CHECK-NEXT:    eors r0, r1
; CHECK-NEXT:    vmov r1, s4
; CHECK-NEXT:    eors r1, r2
; CHECK-NEXT:    vmov r2, s2
; CHECK-NEXT:    orrs r0, r1
; CHECK-NEXT:    vmov r1, s3
; CHECK-NEXT:    clz r0, r0
; CHECK-NEXT:    lsrs r0, r0, #5
; CHECK-NEXT:    it ne
; CHECK-NEXT:    movne.w r0, #-1
; CHECK-NEXT:    vmov.32 q4[0], r0
; CHECK-NEXT:    vmov.32 q4[1], r0
; CHECK-NEXT:    vmov r0, s7
; CHECK-NEXT:    eors r0, r1
; CHECK-NEXT:    vmov r1, s6
; CHECK-NEXT:    eors r1, r2
; CHECK-NEXT:    orrs r0, r1
; CHECK-NEXT:    clz r0, r0
; CHECK-NEXT:    lsrs r0, r0, #5
; CHECK-NEXT:    it ne
; CHECK-NEXT:    movne.w r0, #-1
; CHECK-NEXT:    vmov.32 q4[2], r0
; CHECK-NEXT:    vmov.32 q4[3], r0
; CHECK-NEXT:    vbic q0, q3, q4
; CHECK-NEXT:    vand q1, q2, q4
; CHECK-NEXT:    vorr q0, q1, q0
; CHECK-NEXT:    vpop {d8, d9}
; CHECK-NEXT:    bx lr
entry:
  %c = icmp eq <2 x i64> %src, %srcb
  %s = select <2 x i1> %c, <2 x i64> %a, <2 x i64> %b
  ret <2 x i64> %s
}

define arm_aapcs_vfpcc <2 x i32> @vcmp_eq_v2i32(<2 x i64> %src, <2 x i64> %srcb, <2 x i32> %a, <2 x i32> %b) {
; CHECK-LABEL: vcmp_eq_v2i32:
; CHECK:       @ %bb.0: @ %entry
; CHECK-NEXT:    .vsave {d8, d9}
; CHECK-NEXT:    vpush {d8, d9}
; CHECK-NEXT:    vmov r0, s5
; CHECK-NEXT:    vmov r1, s1
; CHECK-NEXT:    vmov r2, s0
; CHECK-NEXT:    eors r0, r1
; CHECK-NEXT:    vmov r1, s4
; CHECK-NEXT:    eors r1, r2
; CHECK-NEXT:    vmov r2, s2
; CHECK-NEXT:    orrs r0, r1
; CHECK-NEXT:    vmov r1, s3
; CHECK-NEXT:    clz r0, r0
; CHECK-NEXT:    lsrs r0, r0, #5
; CHECK-NEXT:    it ne
; CHECK-NEXT:    movne.w r0, #-1
; CHECK-NEXT:    vmov.32 q4[0], r0
; CHECK-NEXT:    vmov.32 q4[1], r0
; CHECK-NEXT:    vmov r0, s7
; CHECK-NEXT:    eors r0, r1
; CHECK-NEXT:    vmov r1, s6
; CHECK-NEXT:    eors r1, r2
; CHECK-NEXT:    orrs r0, r1
; CHECK-NEXT:    clz r0, r0
; CHECK-NEXT:    lsrs r0, r0, #5
; CHECK-NEXT:    it ne
; CHECK-NEXT:    movne.w r0, #-1
; CHECK-NEXT:    vmov.32 q4[2], r0
; CHECK-NEXT:    vmov.32 q4[3], r0
; CHECK-NEXT:    vbic q0, q3, q4
; CHECK-NEXT:    vand q1, q2, q4
; CHECK-NEXT:    vorr q0, q1, q0
; CHECK-NEXT:    vpop {d8, d9}
; CHECK-NEXT:    bx lr
entry:
  %c = icmp eq <2 x i64> %src, %srcb
  %s = select <2 x i1> %c, <2 x i32> %a, <2 x i32> %b
  ret <2 x i32> %s
}

define arm_aapcs_vfpcc <2 x i32> @vcmp_multi_v2i32(<2 x i64> %a, <2 x i32> %b, <2 x i32> %c) {
; CHECK-LABEL: vcmp_multi_v2i32:
; CHECK:       @ %bb.0:
; CHECK-NEXT:    .save {r7, lr}
; CHECK-NEXT:    push {r7, lr}
; CHECK-NEXT:    .vsave {d8, d9, d10, d11}
; CHECK-NEXT:    vpush {d8, d9, d10, d11}
; CHECK-NEXT:    vmov r0, s1
; CHECK-NEXT:    movs r3, #0
; CHECK-NEXT:    vmov r1, s0
; CHECK-NEXT:    vmov r2, s8
; CHECK-NEXT:    vmov lr, s10
; CHECK-NEXT:    orrs r0, r1
; CHECK-NEXT:    vmov r1, s2
; CHECK-NEXT:    clz r0, r0
; CHECK-NEXT:    lsrs r0, r0, #5
; CHECK-NEXT:    it ne
; CHECK-NEXT:    movne.w r0, #-1
; CHECK-NEXT:    vmov.32 q3[0], r0
; CHECK-NEXT:    vmov.32 q3[1], r0
; CHECK-NEXT:    vmov r0, s3
; CHECK-NEXT:    orrs r0, r1
; CHECK-NEXT:    clz r0, r0
; CHECK-NEXT:    lsrs r0, r0, #5
; CHECK-NEXT:    it ne
; CHECK-NEXT:    movne.w r0, #-1
; CHECK-NEXT:    vmov.32 q3[2], r0
; CHECK-NEXT:    vmov.32 q3[3], r0
; CHECK-NEXT:    vbic q0, q2, q3
; CHECK-NEXT:    vmov r0, s0
; CHECK-NEXT:    subs r1, r0, r2
; CHECK-NEXT:    asr.w r12, r0, #31
; CHECK-NEXT:    sbcs.w r1, r12, r2, asr #31
; CHECK-NEXT:    mov.w r1, #0
; CHECK-NEXT:    it lt
; CHECK-NEXT:    movlt r1, #1
; CHECK-NEXT:    cmp r1, #0
; CHECK-NEXT:    it ne
; CHECK-NEXT:    movne.w r1, #-1
; CHECK-NEXT:    vmov.32 q3[0], r1
; CHECK-NEXT:    vmov.32 q3[1], r1
; CHECK-NEXT:    vmov r1, s2
; CHECK-NEXT:    subs.w r2, r1, lr
; CHECK-NEXT:    asr.w r12, r1, #31
; CHECK-NEXT:    sbcs.w r2, r12, lr, asr #31
; CHECK-NEXT:    it lt
; CHECK-NEXT:    movlt r3, #1
; CHECK-NEXT:    cmp r3, #0
; CHECK-NEXT:    it ne
; CHECK-NEXT:    movne.w r3, #-1
; CHECK-NEXT:    cmp r0, #0
; CHECK-NEXT:    it ne
; CHECK-NEXT:    movne r0, #1
; CHECK-NEXT:    cmp r0, #0
; CHECK-NEXT:    it ne
; CHECK-NEXT:    movne.w r0, #-1
; CHECK-NEXT:    vmov.32 q4[0], r0
; CHECK-NEXT:    vmov.32 q4[1], r0
; CHECK-NEXT:    vmov r0, s4
; CHECK-NEXT:    cmp r1, #0
; CHECK-NEXT:    it ne
; CHECK-NEXT:    movne r1, #1
; CHECK-NEXT:    cmp r1, #0
; CHECK-NEXT:    it ne
; CHECK-NEXT:    movne.w r1, #-1
; CHECK-NEXT:    vmov.32 q4[2], r1
; CHECK-NEXT:    vmov.32 q3[2], r3
; CHECK-NEXT:    vmov.32 q4[3], r1
; CHECK-NEXT:    vmov.32 q3[3], r3
; CHECK-NEXT:    cmp r0, #0
; CHECK-NEXT:    it ne
; CHECK-NEXT:    movne r0, #1
; CHECK-NEXT:    cmp r0, #0
; CHECK-NEXT:    it ne
; CHECK-NEXT:    movne.w r0, #-1
; CHECK-NEXT:    vmov.32 q5[0], r0
; CHECK-NEXT:    vmov.32 q5[1], r0
; CHECK-NEXT:    vmov r0, s6
; CHECK-NEXT:    cmp r0, #0
; CHECK-NEXT:    it ne
; CHECK-NEXT:    movne r0, #1
; CHECK-NEXT:    cmp r0, #0
; CHECK-NEXT:    it ne
; CHECK-NEXT:    movne.w r0, #-1
; CHECK-NEXT:    vmov.32 q5[2], r0
; CHECK-NEXT:    vmov.32 q5[3], r0
; CHECK-NEXT:    vand q1, q5, q4
; CHECK-NEXT:    vand q1, q3, q1
; CHECK-NEXT:    vbic q0, q0, q1
; CHECK-NEXT:    vand q1, q2, q1
; CHECK-NEXT:    vorr q0, q1, q0
; CHECK-NEXT:    vpop {d8, d9, d10, d11}
; CHECK-NEXT:    pop {r7, pc}
  %a4 = icmp eq <2 x i64> %a, zeroinitializer
  %a5 = select <2 x i1> %a4, <2 x i32> zeroinitializer, <2 x i32> %c
  %a6 = icmp ne <2 x i32> %b, zeroinitializer
  %a7 = icmp slt <2 x i32> %a5, %c
  %a8 = icmp ne <2 x i32> %a5, zeroinitializer
  %a9 = and <2 x i1> %a6, %a8
  %a10 = and <2 x i1> %a7, %a9
  %a11 = select <2 x i1> %a10, <2 x i32> %c, <2 x i32> %a5
  ret <2 x i32> %a11
}
