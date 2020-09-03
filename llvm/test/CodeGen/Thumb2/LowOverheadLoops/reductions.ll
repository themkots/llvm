; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: llc -mtriple=thumbv8.1m.main -mattr=+mve -tail-predication=enabled %s -o - | FileCheck %s

define dso_local arm_aapcs_vfpcc zeroext i8 @one_loop_add_add_v16i8(i8* nocapture readonly %a, i8* nocapture readonly %b, i32 %N) local_unnamed_addr {
; CHECK-LABEL: one_loop_add_add_v16i8:
; CHECK:       @ %bb.0: @ %entry
; CHECK-NEXT:    cmp r2, #0
; CHECK-NEXT:    ittt eq
; CHECK-NEXT:    moveq r0, #0
; CHECK-NEXT:    uxtbeq r0, r0
; CHECK-NEXT:    bxeq lr
; CHECK-NEXT:  .LBB0_1: @ %vector.ph
; CHECK-NEXT:    push {r7, lr}
; CHECK-NEXT:    add.w r3, r2, #15
; CHECK-NEXT:    vmov.i32 q1, #0x0
; CHECK-NEXT:    bic r3, r3, #15
; CHECK-NEXT:    sub.w r12, r3, #16
; CHECK-NEXT:    movs r3, #1
; CHECK-NEXT:    add.w lr, r3, r12, lsr #4
; CHECK-NEXT:    dls lr, lr
; CHECK-NEXT:  .LBB0_2: @ %vector.body
; CHECK-NEXT:    @ =>This Inner Loop Header: Depth=1
; CHECK-NEXT:    vctp.8 r2
; CHECK-NEXT:    vmov q0, q1
; CHECK-NEXT:    vpst
; CHECK-NEXT:    vldrbt.u8 q1, [r0], #16
; CHECK-NEXT:    subs r2, #16
; CHECK-NEXT:    vadd.i8 q1, q1, q0
; CHECK-NEXT:    vpst
; CHECK-NEXT:    vldrbt.u8 q2, [r1], #16
; CHECK-NEXT:    vadd.i8 q1, q1, q2
; CHECK-NEXT:    le lr, .LBB0_2
; CHECK-NEXT:  @ %bb.3: @ %middle.block
; CHECK-NEXT:    vpsel q0, q1, q0
; CHECK-NEXT:    vaddv.u8 r0, q0
; CHECK-NEXT:    pop.w {r7, lr}
; CHECK-NEXT:    uxtb r0, r0
; CHECK-NEXT:    bx lr
entry:
  %cmp11 = icmp eq i32 %N, 0
  br i1 %cmp11, label %for.cond.cleanup, label %vector.ph

vector.ph:                                        ; preds = %entry
  %n.rnd.up = add i32 %N, 15
  %n.vec = and i32 %n.rnd.up, -16
  %trip.count.minus.1 = add i32 %N, -1
  br label %vector.body

vector.body:                                      ; preds = %vector.body, %vector.ph
  %index = phi i32 [ 0, %vector.ph ], [ %index.next, %vector.body ]
  %vec.phi = phi <16 x i8> [ zeroinitializer, %vector.ph ], [ %i5, %vector.body ]
  %i = getelementptr inbounds i8, i8* %a, i32 %index
  %active.lane.mask = call <16 x i1> @llvm.get.active.lane.mask.v16i1.i32(i32 %index, i32 %N)
  %i1 = bitcast i8* %i to <16 x i8>*
  %wide.masked.load = call <16 x i8> @llvm.masked.load.v16i8.p0v16i8(<16 x i8>* %i1, i32 1, <16 x i1> %active.lane.mask, <16 x i8> undef)
  %i2 = getelementptr inbounds i8, i8* %b, i32 %index
  %i3 = bitcast i8* %i2 to <16 x i8>*
  %wide.masked.load16 = call <16 x i8> @llvm.masked.load.v16i8.p0v16i8(<16 x i8>* %i3, i32 1, <16 x i1> %active.lane.mask, <16 x i8> undef)
  %i4 = add <16 x i8> %wide.masked.load, %vec.phi
  %i5 = add <16 x i8> %i4, %wide.masked.load16
  %index.next = add i32 %index, 16
  %i6 = icmp eq i32 %index.next, %n.vec
  br i1 %i6, label %middle.block, label %vector.body

middle.block:                                     ; preds = %vector.body
  %i7 = select <16 x i1> %active.lane.mask, <16 x i8> %i5, <16 x i8> %vec.phi
  %i8 = call i8 @llvm.experimental.vector.reduce.add.v16i8(<16 x i8> %i7)
  br label %for.cond.cleanup

for.cond.cleanup:                                 ; preds = %middle.block, %entry
  %res.0.lcssa = phi i8 [ 0, %entry ], [ %i8, %middle.block ]
  ret i8 %res.0.lcssa
}

define dso_local arm_aapcs_vfpcc signext i16 @one_loop_add_add_v8i16(i8* nocapture readonly %a, i8* nocapture readonly %b, i32 %N) local_unnamed_addr {
; CHECK-LABEL: one_loop_add_add_v8i16:
; CHECK:       @ %bb.0: @ %entry
; CHECK-NEXT:    cmp r2, #0
; CHECK-NEXT:    ittt eq
; CHECK-NEXT:    moveq r0, #0
; CHECK-NEXT:    sxtheq r0, r0
; CHECK-NEXT:    bxeq lr
; CHECK-NEXT:  .LBB1_1: @ %vector.ph
; CHECK-NEXT:    push {r7, lr}
; CHECK-NEXT:    adds r3, r2, #7
; CHECK-NEXT:    vmov.i32 q1, #0x0
; CHECK-NEXT:    bic r3, r3, #7
; CHECK-NEXT:    sub.w r12, r3, #8
; CHECK-NEXT:    movs r3, #1
; CHECK-NEXT:    add.w lr, r3, r12, lsr #3
; CHECK-NEXT:    dls lr, lr
; CHECK-NEXT:  .LBB1_2: @ %vector.body
; CHECK-NEXT:    @ =>This Inner Loop Header: Depth=1
; CHECK-NEXT:    vctp.16 r2
; CHECK-NEXT:    vmov q0, q1
; CHECK-NEXT:    vpst
; CHECK-NEXT:    vldrbt.u16 q1, [r0], #8
; CHECK-NEXT:    subs r2, #8
; CHECK-NEXT:    vadd.i16 q1, q0, q1
; CHECK-NEXT:    vpst
; CHECK-NEXT:    vldrbt.u16 q2, [r1], #8
; CHECK-NEXT:    vadd.i16 q1, q1, q2
; CHECK-NEXT:    le lr, .LBB1_2
; CHECK-NEXT:  @ %bb.3: @ %middle.block
; CHECK-NEXT:    vpsel q0, q1, q0
; CHECK-NEXT:    vaddv.u16 r0, q0
; CHECK-NEXT:    pop.w {r7, lr}
; CHECK-NEXT:    sxth r0, r0
; CHECK-NEXT:    bx lr
entry:
  %cmp12 = icmp eq i32 %N, 0
  br i1 %cmp12, label %for.cond.cleanup, label %vector.ph

vector.ph:                                        ; preds = %entry
  %n.rnd.up = add i32 %N, 7
  %n.vec = and i32 %n.rnd.up, -8
  %trip.count.minus.1 = add i32 %N, -1
  br label %vector.body

vector.body:                                      ; preds = %vector.body, %vector.ph
  %index = phi i32 [ 0, %vector.ph ], [ %index.next, %vector.body ]
  %vec.phi = phi <8 x i16> [ zeroinitializer, %vector.ph ], [ %i7, %vector.body ]
  %i = getelementptr inbounds i8, i8* %a, i32 %index
  %active.lane.mask = call <8 x i1> @llvm.get.active.lane.mask.v8i1.i32(i32 %index, i32 %N)
  %i1 = bitcast i8* %i to <8 x i8>*
  %wide.masked.load = call <8 x i8> @llvm.masked.load.v8i8.p0v8i8(<8 x i8>* %i1, i32 1, <8 x i1> %active.lane.mask, <8 x i8> undef)
  %i2 = zext <8 x i8> %wide.masked.load to <8 x i16>
  %i3 = getelementptr inbounds i8, i8* %b, i32 %index
  %i4 = bitcast i8* %i3 to <8 x i8>*
  %wide.masked.load17 = call <8 x i8> @llvm.masked.load.v8i8.p0v8i8(<8 x i8>* %i4, i32 1, <8 x i1> %active.lane.mask, <8 x i8> undef)
  %i5 = zext <8 x i8> %wide.masked.load17 to <8 x i16>
  %i6 = add <8 x i16> %vec.phi, %i2
  %i7 = add <8 x i16> %i6, %i5
  %index.next = add i32 %index, 8
  %i8 = icmp eq i32 %index.next, %n.vec
  br i1 %i8, label %middle.block, label %vector.body

middle.block:                                     ; preds = %vector.body
  %i9 = select <8 x i1> %active.lane.mask, <8 x i16> %i7, <8 x i16> %vec.phi
  %i10 = call i16 @llvm.experimental.vector.reduce.add.v8i16(<8 x i16> %i9)
  br label %for.cond.cleanup

for.cond.cleanup:                                 ; preds = %middle.block, %entry
  %res.0.lcssa = phi i16 [ 0, %entry ], [ %i10, %middle.block ]
  ret i16 %res.0.lcssa
}

define dso_local arm_aapcs_vfpcc zeroext i8 @one_loop_sub_add_v16i8(i8* nocapture readonly %a, i8* nocapture readonly %b, i32 %N) local_unnamed_addr {
; CHECK-LABEL: one_loop_sub_add_v16i8:
; CHECK:       @ %bb.0: @ %entry
; CHECK-NEXT:    cmp r2, #0
; CHECK-NEXT:    ittt eq
; CHECK-NEXT:    moveq r0, #0
; CHECK-NEXT:    uxtbeq r0, r0
; CHECK-NEXT:    bxeq lr
; CHECK-NEXT:  .LBB2_1: @ %vector.ph
; CHECK-NEXT:    push {r7, lr}
; CHECK-NEXT:    vmov.i32 q0, #0x0
; CHECK-NEXT:    dlstp.8 lr, r2
; CHECK-NEXT:  .LBB2_2: @ %vector.body
; CHECK-NEXT:    @ =>This Inner Loop Header: Depth=1
; CHECK-NEXT:    vldrb.u8 q1, [r1], #16
; CHECK-NEXT:    vldrb.u8 q2, [r0], #16
; CHECK-NEXT:    vsub.i8 q1, q2, q1
; CHECK-NEXT:    vadd.i8 q0, q1, q0
; CHECK-NEXT:    letp lr, .LBB2_2
; CHECK-NEXT:  @ %bb.3: @ %middle.block
; CHECK-NEXT:    vaddv.u8 r0, q0
; CHECK-NEXT:    pop.w {r7, lr}
; CHECK-NEXT:    uxtb r0, r0
; CHECK-NEXT:    bx lr
entry:
  %cmp11 = icmp eq i32 %N, 0
  br i1 %cmp11, label %for.cond.cleanup, label %vector.ph

vector.ph:                                        ; preds = %entry
  %n.rnd.up = add i32 %N, 15
  %n.vec = and i32 %n.rnd.up, -16
  %trip.count.minus.1 = add i32 %N, -1
  br label %vector.body

vector.body:                                      ; preds = %vector.body, %vector.ph
  %index = phi i32 [ 0, %vector.ph ], [ %index.next, %vector.body ]
  %vec.phi = phi <16 x i8> [ zeroinitializer, %vector.ph ], [ %i5, %vector.body ]
  %i = getelementptr inbounds i8, i8* %a, i32 %index
  %active.lane.mask = call <16 x i1> @llvm.get.active.lane.mask.v16i1.i32(i32 %index, i32 %N)
  %i1 = bitcast i8* %i to <16 x i8>*
  %wide.masked.load = call <16 x i8> @llvm.masked.load.v16i8.p0v16i8(<16 x i8>* %i1, i32 1, <16 x i1> %active.lane.mask, <16 x i8> undef)
  %i2 = getelementptr inbounds i8, i8* %b, i32 %index
  %i3 = bitcast i8* %i2 to <16 x i8>*
  %wide.masked.load16 = call <16 x i8> @llvm.masked.load.v16i8.p0v16i8(<16 x i8>* %i3, i32 1, <16 x i1> %active.lane.mask, <16 x i8> undef)
  %i4 = sub <16 x i8> %wide.masked.load, %wide.masked.load16
  %i5 = add <16 x i8> %i4, %vec.phi
  %index.next = add i32 %index, 16
  %i6 = icmp eq i32 %index.next, %n.vec
  br i1 %i6, label %middle.block, label %vector.body

middle.block:                                     ; preds = %vector.body
  %i7 = select <16 x i1> %active.lane.mask, <16 x i8> %i5, <16 x i8> %vec.phi
  %i8 = call i8 @llvm.experimental.vector.reduce.add.v16i8(<16 x i8> %i7)
  br label %for.cond.cleanup

for.cond.cleanup:                                 ; preds = %middle.block, %entry
  %res.0.lcssa = phi i8 [ 0, %entry ], [ %i8, %middle.block ]
  ret i8 %res.0.lcssa
}

define dso_local arm_aapcs_vfpcc signext i16 @one_loop_sub_add_v8i16(i8* nocapture readonly %a, i8* nocapture readonly %b, i32 %N) local_unnamed_addr {
; CHECK-LABEL: one_loop_sub_add_v8i16:
; CHECK:       @ %bb.0: @ %entry
; CHECK-NEXT:    cmp r2, #0
; CHECK-NEXT:    ittt eq
; CHECK-NEXT:    moveq r0, #0
; CHECK-NEXT:    sxtheq r0, r0
; CHECK-NEXT:    bxeq lr
; CHECK-NEXT:  .LBB3_1: @ %vector.ph
; CHECK-NEXT:    push {r7, lr}
; CHECK-NEXT:    vmov.i32 q0, #0x0
; CHECK-NEXT:    dlstp.16 lr, r2
; CHECK-NEXT:  .LBB3_2: @ %vector.body
; CHECK-NEXT:    @ =>This Inner Loop Header: Depth=1
; CHECK-NEXT:    vldrb.u16 q1, [r0], #8
; CHECK-NEXT:    vldrb.u16 q2, [r1], #8
; CHECK-NEXT:    vsub.i16 q1, q2, q1
; CHECK-NEXT:    vadd.i16 q0, q1, q0
; CHECK-NEXT:    letp lr, .LBB3_2
; CHECK-NEXT:  @ %bb.3: @ %middle.block
; CHECK-NEXT:    vaddv.u16 r0, q0
; CHECK-NEXT:    pop.w {r7, lr}
; CHECK-NEXT:    sxth r0, r0
; CHECK-NEXT:    bx lr
entry:
  %cmp12 = icmp eq i32 %N, 0
  br i1 %cmp12, label %for.cond.cleanup, label %vector.ph

vector.ph:                                        ; preds = %entry
  %n.rnd.up = add i32 %N, 7
  %n.vec = and i32 %n.rnd.up, -8
  %trip.count.minus.1 = add i32 %N, -1
  br label %vector.body

vector.body:                                      ; preds = %vector.body, %vector.ph
  %index = phi i32 [ 0, %vector.ph ], [ %index.next, %vector.body ]
  %vec.phi = phi <8 x i16> [ zeroinitializer, %vector.ph ], [ %i7, %vector.body ]
  %i = getelementptr inbounds i8, i8* %a, i32 %index
  %active.lane.mask = call <8 x i1> @llvm.get.active.lane.mask.v8i1.i32(i32 %index, i32 %N)
  %i1 = bitcast i8* %i to <8 x i8>*
  %wide.masked.load = call <8 x i8> @llvm.masked.load.v8i8.p0v8i8(<8 x i8>* %i1, i32 1, <8 x i1> %active.lane.mask, <8 x i8> undef)
  %i2 = zext <8 x i8> %wide.masked.load to <8 x i16>
  %i3 = getelementptr inbounds i8, i8* %b, i32 %index
  %i4 = bitcast i8* %i3 to <8 x i8>*
  %wide.masked.load17 = call <8 x i8> @llvm.masked.load.v8i8.p0v8i8(<8 x i8>* %i4, i32 1, <8 x i1> %active.lane.mask, <8 x i8> undef)
  %i5 = zext <8 x i8> %wide.masked.load17 to <8 x i16>
  %i6 = sub <8 x i16> %i5, %i2
  %i7 = add <8 x i16> %i6, %vec.phi
  %index.next = add i32 %index, 8
  %i8 = icmp eq i32 %index.next, %n.vec
  br i1 %i8, label %middle.block, label %vector.body

middle.block:                                     ; preds = %vector.body
  %i9 = select <8 x i1> %active.lane.mask, <8 x i16> %i7, <8 x i16> %vec.phi
  %i10 = call i16 @llvm.experimental.vector.reduce.add.v8i16(<8 x i16> %i9)
  br label %for.cond.cleanup

for.cond.cleanup:                                 ; preds = %middle.block, %entry
  %res.0.lcssa = phi i16 [ 0, %entry ], [ %i10, %middle.block ]
  ret i16 %res.0.lcssa
}

define dso_local arm_aapcs_vfpcc zeroext i8 @one_loop_mul_add_v16i8(i8* nocapture readonly %a, i8* nocapture readonly %b, i32 %N) local_unnamed_addr {
; CHECK-LABEL: one_loop_mul_add_v16i8:
; CHECK:       @ %bb.0: @ %entry
; CHECK-NEXT:    cmp r2, #0
; CHECK-NEXT:    ittt eq
; CHECK-NEXT:    moveq r0, #0
; CHECK-NEXT:    uxtbeq r0, r0
; CHECK-NEXT:    bxeq lr
; CHECK-NEXT:  .LBB4_1: @ %vector.ph
; CHECK-NEXT:    push {r7, lr}
; CHECK-NEXT:    vmov.i32 q0, #0x0
; CHECK-NEXT:    dlstp.8 lr, r2
; CHECK-NEXT:  .LBB4_2: @ %vector.body
; CHECK-NEXT:    @ =>This Inner Loop Header: Depth=1
; CHECK-NEXT:    vldrb.u8 q1, [r0], #16
; CHECK-NEXT:    vldrb.u8 q2, [r1], #16
; CHECK-NEXT:    vmul.i8 q1, q2, q1
; CHECK-NEXT:    vadd.i8 q0, q1, q0
; CHECK-NEXT:    letp lr, .LBB4_2
; CHECK-NEXT:  @ %bb.3: @ %middle.block
; CHECK-NEXT:    vaddv.u8 r0, q0
; CHECK-NEXT:    pop.w {r7, lr}
; CHECK-NEXT:    uxtb r0, r0
; CHECK-NEXT:    bx lr
entry:
  %cmp10 = icmp eq i32 %N, 0
  br i1 %cmp10, label %for.cond.cleanup, label %vector.ph

vector.ph:                                        ; preds = %entry
  %n.rnd.up = add i32 %N, 15
  %n.vec = and i32 %n.rnd.up, -16
  %trip.count.minus.1 = add i32 %N, -1
  br label %vector.body

vector.body:                                      ; preds = %vector.body, %vector.ph
  %index = phi i32 [ 0, %vector.ph ], [ %index.next, %vector.body ]
  %vec.phi = phi <16 x i8> [ zeroinitializer, %vector.ph ], [ %i5, %vector.body ]
  %i = getelementptr inbounds i8, i8* %a, i32 %index
  %active.lane.mask = call <16 x i1> @llvm.get.active.lane.mask.v16i1.i32(i32 %index, i32 %N)
  %i1 = bitcast i8* %i to <16 x i8>*
  %wide.masked.load = call <16 x i8> @llvm.masked.load.v16i8.p0v16i8(<16 x i8>* %i1, i32 1, <16 x i1> %active.lane.mask, <16 x i8> undef)
  %i2 = getelementptr inbounds i8, i8* %b, i32 %index
  %i3 = bitcast i8* %i2 to <16 x i8>*
  %wide.masked.load15 = call <16 x i8> @llvm.masked.load.v16i8.p0v16i8(<16 x i8>* %i3, i32 1, <16 x i1> %active.lane.mask, <16 x i8> undef)
  %i4 = mul <16 x i8> %wide.masked.load15, %wide.masked.load
  %i5 = add <16 x i8> %i4, %vec.phi
  %index.next = add i32 %index, 16
  %i6 = icmp eq i32 %index.next, %n.vec
  br i1 %i6, label %middle.block, label %vector.body

middle.block:                                     ; preds = %vector.body
  %i7 = select <16 x i1> %active.lane.mask, <16 x i8> %i5, <16 x i8> %vec.phi
  %i8 = call i8 @llvm.experimental.vector.reduce.add.v16i8(<16 x i8> %i7)
  br label %for.cond.cleanup

for.cond.cleanup:                                 ; preds = %middle.block, %entry
  %res.0.lcssa = phi i8 [ 0, %entry ], [ %i8, %middle.block ]
  ret i8 %res.0.lcssa
}

define dso_local arm_aapcs_vfpcc signext i16 @one_loop_mul_add_v8i16(i8* nocapture readonly %a, i8* nocapture readonly %b, i32 %N) local_unnamed_addr {
; CHECK-LABEL: one_loop_mul_add_v8i16:
; CHECK:       @ %bb.0: @ %entry
; CHECK-NEXT:    cmp r2, #0
; CHECK-NEXT:    ittt eq
; CHECK-NEXT:    moveq r0, #0
; CHECK-NEXT:    sxtheq r0, r0
; CHECK-NEXT:    bxeq lr
; CHECK-NEXT:  .LBB5_1: @ %vector.ph
; CHECK-NEXT:    push {r7, lr}
; CHECK-NEXT:    vmov.i32 q0, #0x0
; CHECK-NEXT:    dlstp.16 lr, r2
; CHECK-NEXT:  .LBB5_2: @ %vector.body
; CHECK-NEXT:    @ =>This Inner Loop Header: Depth=1
; CHECK-NEXT:    vldrb.u16 q1, [r0], #8
; CHECK-NEXT:    vldrb.u16 q2, [r1], #8
; CHECK-NEXT:    vmul.i16 q1, q2, q1
; CHECK-NEXT:    vadd.i16 q0, q1, q0
; CHECK-NEXT:    letp lr, .LBB5_2
; CHECK-NEXT:  @ %bb.3: @ %middle.block
; CHECK-NEXT:    vaddv.u16 r0, q0
; CHECK-NEXT:    pop.w {r7, lr}
; CHECK-NEXT:    sxth r0, r0
; CHECK-NEXT:    bx lr
entry:
  %cmp12 = icmp eq i32 %N, 0
  br i1 %cmp12, label %for.cond.cleanup, label %vector.ph

vector.ph:                                        ; preds = %entry
  %n.rnd.up = add i32 %N, 7
  %n.vec = and i32 %n.rnd.up, -8
  %trip.count.minus.1 = add i32 %N, -1
  br label %vector.body

vector.body:                                      ; preds = %vector.body, %vector.ph
  %index = phi i32 [ 0, %vector.ph ], [ %index.next, %vector.body ]
  %vec.phi = phi <8 x i16> [ zeroinitializer, %vector.ph ], [ %i7, %vector.body ]
  %i = getelementptr inbounds i8, i8* %a, i32 %index
  %active.lane.mask = call <8 x i1> @llvm.get.active.lane.mask.v8i1.i32(i32 %index, i32 %N)
  %i1 = bitcast i8* %i to <8 x i8>*
  %wide.masked.load = call <8 x i8> @llvm.masked.load.v8i8.p0v8i8(<8 x i8>* %i1, i32 1, <8 x i1> %active.lane.mask, <8 x i8> undef)
  %i2 = zext <8 x i8> %wide.masked.load to <8 x i16>
  %i3 = getelementptr inbounds i8, i8* %b, i32 %index
  %i4 = bitcast i8* %i3 to <8 x i8>*
  %wide.masked.load17 = call <8 x i8> @llvm.masked.load.v8i8.p0v8i8(<8 x i8>* %i4, i32 1, <8 x i1> %active.lane.mask, <8 x i8> undef)
  %i5 = zext <8 x i8> %wide.masked.load17 to <8 x i16>
  %i6 = mul <8 x i16> %i5, %i2
  %i7 = add <8 x i16> %i6, %vec.phi
  %index.next = add i32 %index, 8
  %i8 = icmp eq i32 %index.next, %n.vec
  br i1 %i8, label %middle.block, label %vector.body

middle.block:                                     ; preds = %vector.body
  %i9 = select <8 x i1> %active.lane.mask, <8 x i16> %i7, <8 x i16> %vec.phi
  %i10 = call i16 @llvm.experimental.vector.reduce.add.v8i16(<8 x i16> %i9)
  br label %for.cond.cleanup

for.cond.cleanup:                                 ; preds = %middle.block, %entry
  %res.0.lcssa = phi i16 [ 0, %entry ], [ %i10, %middle.block ]
  ret i16 %res.0.lcssa
}

define dso_local arm_aapcs_vfpcc i32 @two_loops_mul_add_v4i32(i8* nocapture readonly %a, i8* nocapture readonly %b, i32 %N) local_unnamed_addr {
; CHECK-LABEL: two_loops_mul_add_v4i32:
; CHECK:       @ %bb.0: @ %entry
; CHECK-NEXT:    push {r4, r5, r6, lr}
; CHECK-NEXT:    cmp r2, #0
; CHECK-NEXT:    beq .LBB6_8
; CHECK-NEXT:  @ %bb.1: @ %vector.ph
; CHECK-NEXT:    adds r3, r2, #3
; CHECK-NEXT:    vmov.i32 q1, #0x0
; CHECK-NEXT:    bic r3, r3, #3
; CHECK-NEXT:    mov r4, r0
; CHECK-NEXT:    subs r6, r3, #4
; CHECK-NEXT:    movs r3, #1
; CHECK-NEXT:    mov r5, r1
; CHECK-NEXT:    add.w lr, r3, r6, lsr #2
; CHECK-NEXT:    mov r3, r2
; CHECK-NEXT:    dls lr, lr
; CHECK-NEXT:  .LBB6_2: @ %vector.body
; CHECK-NEXT:    @ =>This Inner Loop Header: Depth=1
; CHECK-NEXT:    vctp.32 r3
; CHECK-NEXT:    vmov q0, q1
; CHECK-NEXT:    vpstt
; CHECK-NEXT:    vldrbt.u32 q1, [r4], #4
; CHECK-NEXT:    vldrbt.u32 q2, [r5], #4
; CHECK-NEXT:    subs r3, #4
; CHECK-NEXT:    vmul.i32 q1, q2, q1
; CHECK-NEXT:    vadd.i32 q1, q1, q0
; CHECK-NEXT:    le lr, .LBB6_2
; CHECK-NEXT:  @ %bb.3: @ %middle.block
; CHECK-NEXT:    vpsel q0, q1, q0
; CHECK-NEXT:    vaddv.u32 r12, q0
; CHECK-NEXT:    cbz r2, .LBB6_7
; CHECK-NEXT:  @ %bb.4: @ %vector.ph47
; CHECK-NEXT:    movs r3, #0
; CHECK-NEXT:    dlstp.32 lr, r2
; CHECK-NEXT:    vdup.32 q0, r3
; CHECK-NEXT:    vmov.32 q1[0], r12
; CHECK-NEXT:  .LBB6_5: @ %vector.body46
; CHECK-NEXT:    @ =>This Inner Loop Header: Depth=1
; CHECK-NEXT:    vldrb.u32 q0, [r0], #4
; CHECK-NEXT:    vldrb.u32 q2, [r1], #4
; CHECK-NEXT:    vmul.i32 q0, q2, q0
; CHECK-NEXT:    vadd.i32 q1, q0, q1
; CHECK-NEXT:    letp lr, .LBB6_5
; CHECK-NEXT:  @ %bb.6: @ %middle.block44
; CHECK-NEXT:    vmov q0, q1
; CHECK-NEXT:    vaddv.u32 r12, q0
; CHECK-NEXT:  .LBB6_7: @ %for.cond.cleanup7
; CHECK-NEXT:    mov r0, r12
; CHECK-NEXT:    pop {r4, r5, r6, pc}
; CHECK-NEXT:  .LBB6_8:
; CHECK-NEXT:    movs r0, #0
; CHECK-NEXT:    pop {r4, r5, r6, pc}
entry:
  %cmp35 = icmp eq i32 %N, 0
  br i1 %cmp35, label %for.cond.cleanup7, label %vector.ph

vector.ph:                                        ; preds = %entry
  %n.rnd.up = add i32 %N, 3
  %n.vec = and i32 %n.rnd.up, -4
  %trip.count.minus.1 = add i32 %N, -1
  br label %vector.body

vector.body:                                      ; preds = %vector.body, %vector.ph
  %index = phi i32 [ 0, %vector.ph ], [ %index.next, %vector.body ]
  %vec.phi = phi <4 x i32> [ zeroinitializer, %vector.ph ], [ %i7, %vector.body ]
  %i = getelementptr inbounds i8, i8* %a, i32 %index
  %active.lane.mask = call <4 x i1> @llvm.get.active.lane.mask.v4i1.i32(i32 %index, i32 %N)
  %i1 = bitcast i8* %i to <4 x i8>*
  %wide.masked.load = call <4 x i8> @llvm.masked.load.v4i8.p0v4i8(<4 x i8>* %i1, i32 1, <4 x i1> %active.lane.mask, <4 x i8> undef)
  %i2 = zext <4 x i8> %wide.masked.load to <4 x i32>
  %i3 = getelementptr inbounds i8, i8* %b, i32 %index
  %i4 = bitcast i8* %i3 to <4 x i8>*
  %wide.masked.load43 = call <4 x i8> @llvm.masked.load.v4i8.p0v4i8(<4 x i8>* %i4, i32 1, <4 x i1> %active.lane.mask, <4 x i8> undef)
  %i5 = zext <4 x i8> %wide.masked.load43 to <4 x i32>
  %i6 = mul nuw nsw <4 x i32> %i5, %i2
  %i7 = add <4 x i32> %i6, %vec.phi
  %index.next = add i32 %index, 4
  %i8 = icmp eq i32 %index.next, %n.vec
  br i1 %i8, label %middle.block, label %vector.body

middle.block:                                     ; preds = %vector.body
  %i9 = select <4 x i1> %active.lane.mask, <4 x i32> %i7, <4 x i32> %vec.phi
  %i10 = call i32 @llvm.experimental.vector.reduce.add.v4i32(<4 x i32> %i9)
  br i1 %cmp35, label %for.cond.cleanup7, label %vector.ph47

vector.ph47:                                      ; preds = %middle.block
  %n.rnd.up48 = add i32 %N, 3
  %n.vec50 = and i32 %n.rnd.up48, -4
  %trip.count.minus.154 = add i32 %N, -1
  %i11 = insertelement <4 x i32> <i32 undef, i32 0, i32 0, i32 0>, i32 %i10, i32 0
  br label %vector.body46

vector.body46:                                    ; preds = %vector.body46, %vector.ph47
  %index51 = phi i32 [ 0, %vector.ph47 ], [ %index.next52, %vector.body46 ]
  %vec.phi60 = phi <4 x i32> [ %i11, %vector.ph47 ], [ %i19, %vector.body46 ]
  %i12 = getelementptr inbounds i8, i8* %a, i32 %index51
  %active.lane.mask61 = call <4 x i1> @llvm.get.active.lane.mask.v4i1.i32(i32 %index51, i32 %N)
  %i13 = bitcast i8* %i12 to <4 x i8>*
  %wide.masked.load62 = call <4 x i8> @llvm.masked.load.v4i8.p0v4i8(<4 x i8>* %i13, i32 1, <4 x i1> %active.lane.mask61, <4 x i8> undef)
  %i14 = zext <4 x i8> %wide.masked.load62 to <4 x i32>
  %i15 = getelementptr inbounds i8, i8* %b, i32 %index51
  %i16 = bitcast i8* %i15 to <4 x i8>*
  %wide.masked.load63 = call <4 x i8> @llvm.masked.load.v4i8.p0v4i8(<4 x i8>* %i16, i32 1, <4 x i1> %active.lane.mask61, <4 x i8> undef)
  %i17 = zext <4 x i8> %wide.masked.load63 to <4 x i32>
  %i18 = mul nuw nsw <4 x i32> %i17, %i14
  %i19 = add <4 x i32> %i18, %vec.phi60
  %index.next52 = add i32 %index51, 4
  %i20 = icmp eq i32 %index.next52, %n.vec50
  br i1 %i20, label %middle.block44, label %vector.body46

middle.block44:                                   ; preds = %vector.body46
  %i21 = select <4 x i1> %active.lane.mask61, <4 x i32> %i19, <4 x i32> %vec.phi60
  %i22 = call i32 @llvm.experimental.vector.reduce.add.v4i32(<4 x i32> %i21)
  br label %for.cond.cleanup7

for.cond.cleanup7:                                ; preds = %middle.block44, %middle.block, %entry
  %res.1.lcssa = phi i32 [ %i10, %middle.block ], [ 0, %entry ], [ %i22, %middle.block44 ]
  ret i32 %res.1.lcssa
}

define dso_local arm_aapcs_vfpcc void @two_reductions_mul_add_v8i16(i8* nocapture readonly %a, i8* nocapture readonly %b, i32 %N) local_unnamed_addr {
; CHECK-LABEL: two_reductions_mul_add_v8i16:
; CHECK:       @ %bb.0: @ %entry
; CHECK-NEXT:    push {r4, lr}
; CHECK-NEXT:    vpush {d8, d9}
; CHECK-NEXT:    cbz r2, .LBB7_4
; CHECK-NEXT:  @ %bb.1: @ %vector.ph
; CHECK-NEXT:    adds r3, r2, #7
; CHECK-NEXT:    vmov.i32 q1, #0x0
; CHECK-NEXT:    bic r3, r3, #7
; CHECK-NEXT:    movs r4, #1
; CHECK-NEXT:    subs r3, #8
; CHECK-NEXT:    vmov q3, q1
; CHECK-NEXT:    add.w lr, r4, r3, lsr #3
; CHECK-NEXT:    mov r3, r0
; CHECK-NEXT:    mov r4, r1
; CHECK-NEXT:    dls lr, lr
; CHECK-NEXT:  .LBB7_2: @ %vector.body
; CHECK-NEXT:    @ =>This Inner Loop Header: Depth=1
; CHECK-NEXT:    vctp.16 r2
; CHECK-NEXT:    vmov q0, q1
; CHECK-NEXT:    vpstt
; CHECK-NEXT:    vldrbt.u16 q1, [r3], #8
; CHECK-NEXT:    vldrbt.u16 q4, [r4], #8
; CHECK-NEXT:    vmov q2, q3
; CHECK-NEXT:    vsub.i16 q3, q4, q1
; CHECK-NEXT:    vmul.i16 q1, q4, q1
; CHECK-NEXT:    subs r2, #8
; CHECK-NEXT:    vadd.i16 q3, q3, q2
; CHECK-NEXT:    vadd.i16 q1, q1, q0
; CHECK-NEXT:    le lr, .LBB7_2
; CHECK-NEXT:  @ %bb.3: @ %middle.block
; CHECK-NEXT:    vpsel q2, q3, q2
; CHECK-NEXT:    vpsel q0, q1, q0
; CHECK-NEXT:    vaddv.u16 r4, q2
; CHECK-NEXT:    vaddv.u16 r2, q0
; CHECK-NEXT:    b .LBB7_5
; CHECK-NEXT:  .LBB7_4:
; CHECK-NEXT:    movs r2, #0
; CHECK-NEXT:    movs r4, #0
; CHECK-NEXT:  .LBB7_5: @ %for.cond.cleanup
; CHECK-NEXT:    strb r2, [r0]
; CHECK-NEXT:    strb r4, [r1]
; CHECK-NEXT:    vpop {d8, d9}
; CHECK-NEXT:    pop {r4, pc}
entry:
  %cmp12 = icmp eq i32 %N, 0
  br i1 %cmp12, label %for.cond.cleanup, label %vector.ph

vector.ph:                                        ; preds = %entry
  %n.rnd.up = add i32 %N, 7
  %n.vec = and i32 %n.rnd.up, -8
  %trip.count.minus.1 = add i32 %N, -1
  br label %vector.body

vector.body:                                      ; preds = %vector.body, %vector.ph
  %index = phi i32 [ 0, %vector.ph ], [ %index.next, %vector.body ]
  %vec.phi = phi <8 x i16> [ zeroinitializer, %vector.ph ], [ %i8, %vector.body ]
  %vec.phi.1 = phi <8 x i16> [ zeroinitializer, %vector.ph ], [ %i9, %vector.body ]
  %i = getelementptr inbounds i8, i8* %a, i32 %index
  %active.lane.mask = call <8 x i1> @llvm.get.active.lane.mask.v8i1.i32(i32 %index, i32 %N)
  %i1 = bitcast i8* %i to <8 x i8>*
  %wide.masked.load = call <8 x i8> @llvm.masked.load.v8i8.p0v8i8(<8 x i8>* %i1, i32 1, <8 x i1> %active.lane.mask, <8 x i8> undef)
  %i2 = zext <8 x i8> %wide.masked.load to <8 x i16>
  %i3 = getelementptr inbounds i8, i8* %b, i32 %index
  %i4 = bitcast i8* %i3 to <8 x i8>*
  %wide.masked.load17 = call <8 x i8> @llvm.masked.load.v8i8.p0v8i8(<8 x i8>* %i4, i32 1, <8 x i1> %active.lane.mask, <8 x i8> undef)
  %i5 = zext <8 x i8> %wide.masked.load17 to <8 x i16>
  %i6 = mul <8 x i16> %i5, %i2
  %i7 = sub <8 x i16> %i5, %i2
  %i8 = add <8 x i16> %i6, %vec.phi
  %i9 = add <8 x i16> %i7, %vec.phi.1
  %index.next = add i32 %index, 8
  %i10 = icmp eq i32 %index.next, %n.vec
  br i1 %i10, label %middle.block, label %vector.body

middle.block:                                     ; preds = %vector.body
  %i11 = select <8 x i1> %active.lane.mask, <8 x i16> %i8, <8 x i16> %vec.phi
  %i12 = call i16 @llvm.experimental.vector.reduce.add.v8i16(<8 x i16> %i11)
  %i13 = select <8 x i1> %active.lane.mask, <8 x i16> %i9, <8 x i16> %vec.phi.1
  %i14 = call i16 @llvm.experimental.vector.reduce.add.v8i16(<8 x i16> %i13)
  br label %for.cond.cleanup

for.cond.cleanup:                                 ; preds = %middle.block, %entry
  %res.0.lcssa = phi i16 [ 0, %entry ], [ %i12, %middle.block ]
  %res.1.lcssa = phi i16 [ 0, %entry ], [ %i14, %middle.block ]
  %trunc.res.0 = trunc i16 %res.0.lcssa to i8
  store i8 %trunc.res.0, i8* %a
  %trunc.res.1 = trunc i16 %res.1.lcssa to i8
  store i8 %trunc.res.1, i8* %b
  ret void
}

%struct.date = type { i32, i32, i32, i32 }
@days = internal unnamed_addr constant [2 x [13 x i32]] [[13 x i32] [i32 0, i32 31, i32 28, i32 31, i32 30, i32 31, i32 30, i32 31, i32 31, i32 30, i32 31, i32 30, i32 31], [13 x i32] [i32 0, i32 31, i32 29, i32 31, i32 30, i32 31, i32 30, i32 31, i32 31, i32 30, i32 31, i32 30, i32 31]], align 4
define i32 @wrongop(%struct.date* nocapture readonly %pd) {
; CHECK-LABEL: wrongop:
; CHECK:       @ %bb.0: @ %entry
; CHECK-NEXT:    push {r4, lr}
; CHECK-NEXT:    mov r12, r0
; CHECK-NEXT:    ldr r0, [r0]
; CHECK-NEXT:    ldr.w r2, [r12, #8]
; CHECK-NEXT:    lsls r3, r2, #30
; CHECK-NEXT:    bne .LBB8_3
; CHECK-NEXT:  @ %bb.1: @ %entry
; CHECK-NEXT:    movw r3, #34079
; CHECK-NEXT:    movt r3, #20971
; CHECK-NEXT:    smmul r3, r2, r3
; CHECK-NEXT:    asrs r1, r3, #5
; CHECK-NEXT:    add.w r1, r1, r3, lsr #31
; CHECK-NEXT:    movs r3, #100
; CHECK-NEXT:    mls r1, r1, r3, r2
; CHECK-NEXT:    cbz r1, .LBB8_3
; CHECK-NEXT:  @ %bb.2:
; CHECK-NEXT:    movs r4, #1
; CHECK-NEXT:    b .LBB8_4
; CHECK-NEXT:  .LBB8_3: @ %lor.rhs
; CHECK-NEXT:    movw r1, #47184
; CHECK-NEXT:    movw r3, #23593
; CHECK-NEXT:    movt r1, #1310
; CHECK-NEXT:    movt r3, #49807
; CHECK-NEXT:    mla r1, r2, r3, r1
; CHECK-NEXT:    movw r2, #55051
; CHECK-NEXT:    movt r2, #163
; CHECK-NEXT:    ror.w r1, r1, #4
; CHECK-NEXT:    cmp r1, r2
; CHECK-NEXT:    cset r4, lo
; CHECK-NEXT:  .LBB8_4: @ %lor.end
; CHECK-NEXT:    ldr.w r3, [r12, #4]
; CHECK-NEXT:    cmp r3, #1
; CHECK-NEXT:    it lt
; CHECK-NEXT:    poplt {r4, pc}
; CHECK-NEXT:  .LBB8_5: @ %vector.ph
; CHECK-NEXT:    movw r1, :lower16:days
; CHECK-NEXT:    movt r1, :upper16:days
; CHECK-NEXT:    movs r2, #52
; CHECK-NEXT:    mla r1, r4, r2, r1
; CHECK-NEXT:    movs r2, #0
; CHECK-NEXT:    vdup.32 q0, r2
; CHECK-NEXT:    vmov.32 q1[0], r0
; CHECK-NEXT:    subs r0, r3, #1
; CHECK-NEXT:    dlstp.32 lr, r0
; CHECK-NEXT:  .LBB8_6: @ %vector.body
; CHECK-NEXT:    @ =>This Inner Loop Header: Depth=1
; CHECK-NEXT:    vldrw.u32 q0, [r1], #16
; CHECK-NEXT:    vadd.i32 q1, q0, q1
; CHECK-NEXT:    letp lr, .LBB8_6
; CHECK-NEXT:  @ %bb.7: @ %middle.block
; CHECK-NEXT:    vmov q0, q1
; CHECK-NEXT:    vaddv.u32 r0, q0
; CHECK-NEXT:    pop {r4, pc}
entry:
  %day1 = getelementptr inbounds %struct.date, %struct.date* %pd, i32 0, i32 0
  %0 = load i32, i32* %day1, align 4
  %year = getelementptr inbounds %struct.date, %struct.date* %pd, i32 0, i32 2
  %1 = load i32, i32* %year, align 4
  %2 = and i32 %1, 3
  %cmp = icmp ne i32 %2, 0
  %rem3 = srem i32 %1, 100
  %cmp4.not = icmp eq i32 %rem3, 0
  %or.cond = or i1 %cmp, %cmp4.not
  br i1 %or.cond, label %lor.rhs, label %lor.end

lor.rhs:                                          ; preds = %entry
  %rem6 = srem i32 %1, 400
  %cmp7 = icmp eq i32 %rem6, 0
  %phi.cast = zext i1 %cmp7 to i32
  br label %lor.end

lor.end:                                          ; preds = %entry, %lor.rhs
  %3 = phi i32 [ %phi.cast, %lor.rhs ], [ 1, %entry ]
  %month = getelementptr inbounds %struct.date, %struct.date* %pd, i32 0, i32 1
  %4 = load i32, i32* %month, align 4
  %cmp820 = icmp sgt i32 %4, 0
  br i1 %cmp820, label %vector.ph, label %for.end

vector.ph:                                        ; preds = %lor.end
  %n.rnd.up = add i32 %4, 3
  %n.vec = and i32 %n.rnd.up, -4
  %trip.count.minus.1 = add i32 %4, -1
  %5 = insertelement <4 x i32> <i32 undef, i32 0, i32 0, i32 0>, i32 %0, i32 0
  br label %vector.body

vector.body:                                      ; preds = %vector.body, %vector.ph
  %index = phi i32 [ 0, %vector.ph ], [ %index.next, %vector.body ]
  %vec.phi = phi <4 x i32> [ %5, %vector.ph ], [ %8, %vector.body ]
  %6 = getelementptr inbounds [2 x [13 x i32]], [2 x [13 x i32]]* @days, i32 0, i32 %3, i32 %index
  %active.lane.mask = call <4 x i1> @llvm.get.active.lane.mask.v4i1.i32(i32 %index, i32 %trip.count.minus.1)
  %7 = bitcast i32* %6 to <4 x i32>*
  %wide.masked.load = call <4 x i32> @llvm.masked.load.v4i32.p0v4i32(<4 x i32>* nonnull %7, i32 4, <4 x i1> %active.lane.mask, <4 x i32> undef)
  %8 = add <4 x i32> %wide.masked.load, %vec.phi
  %index.next = add i32 %index, 4
  %9 = icmp eq i32 %index.next, %n.vec
  br i1 %9, label %middle.block, label %vector.body

middle.block:                                     ; preds = %vector.body
  %10 = select <4 x i1> %active.lane.mask, <4 x i32> %8, <4 x i32> %vec.phi
  %11 = call i32 @llvm.experimental.vector.reduce.add.v4i32(<4 x i32> %10)
  br label %for.end

for.end:                                          ; preds = %middle.block, %lor.end
  %day.0.lcssa = phi i32 [ %0, %lor.end ], [ %11, %middle.block ]
  ret i32 %day.0.lcssa
}

declare <4 x i32> @llvm.masked.load.v4i32.p0v4i32(<4 x i32>*, i32 immarg, <4 x i1>, <4 x i32>)
declare <16 x i1> @llvm.get.active.lane.mask.v16i1.i32(i32, i32)
declare <16 x i8> @llvm.masked.load.v16i8.p0v16i8(<16 x i8>*, i32 immarg, <16 x i1>, <16 x i8>)
declare i8 @llvm.experimental.vector.reduce.add.v16i8(<16 x i8>)
declare <8 x i1> @llvm.get.active.lane.mask.v8i1.i32(i32, i32)
declare <8 x i8> @llvm.masked.load.v8i8.p0v8i8(<8 x i8>*, i32 immarg, <8 x i1>, <8 x i8>)
declare i16 @llvm.experimental.vector.reduce.add.v8i16(<8 x i16>)
declare <4 x i1> @llvm.get.active.lane.mask.v4i1.i32(i32, i32)
declare <4 x i8> @llvm.masked.load.v4i8.p0v4i8(<4 x i8>*, i32 immarg, <4 x i1>, <4 x i8>)
declare i32 @llvm.experimental.vector.reduce.add.v4i32(<4 x i32>)
