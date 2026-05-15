/*
 * Copyright (c) 2026 Felix Gong
 *
 * This file is part of FFmpeg.
 *
 * FFmpeg is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License as published by the Free Software Foundation; either
 * version 2.1 of the License, or (at your option) any later version.
 *
 * FFmpeg is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public
 * License along with FFmpeg; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
 */

#include "libavutil/riscv/asm.S"

// void swri_oldapi_conv_flt_to_s16_rvv(int16_t *dst, const float *src, int len)
func swri_oldapi_conv_flt_to_s16_rvv, zve32f
    lpad    0
1:
    vsetvli t0, a2, e32, m8, ta, ma
    vle32.v v0, (a1)
    sub     a2, a2, t0
    slli    t1, t0, 2
    vfcvt.rtz.x.f.v v8, v0
    add     a1, a1, t1
    vsetvli zero, zero, e16, m4, ta, ma
    vnclip.wi v16, v8, 0
    slli    t1, t0, 1
    vse16.v v16, (a0)
    add     a0, a0, t1
    bnez    a2, 1b
    ret
endfunc

// void swri_oldapi_conv_fltp_to_s16_2ch_rvv(int16_t *dst, float *const *src,
//                                            int len, int channels)
func swri_oldapi_conv_fltp_to_s16_2ch_rvv, zve32f
    lpad    0
    ld      a4, 0(a1)
    ld      a5, 8(a1)
1:
    vsetvli t0, a2, e32, m4, ta, ma
    vle32.v v0, (a4)
    vle32.v v4, (a5)
    sub     a2, a2, t0
    slli    t1, t0, 2
    vfcvt.rtz.x.f.v v8, v0
    vfcvt.rtz.x.f.v v12, v4
    add     a4, a4, t1
    add     a5, a5, t1
    vsetvli zero, zero, e16, m2, ta, ma
    vnclip.wi v16, v8, 0
    vnclip.wi v18, v12, 0
    vsetvli zero, zero, e16, m4, ta, ma
    vmv.v.v v20, v16
    vslideup.vi v20, v18, 1
    slli    t2, t0, 1
    slli    t2, t2, 1
    vse16.v v20, (a0)
    add     a0, a0, t2
    bnez    a2, 1b
    ret
endfunc

// void swri_oldapi_conv_fltp_to_s16_nch_rvv(int16_t *dst, float *const *src,
//                                            int len, int channels)
func swri_oldapi_conv_fltp_to_s16_nch_rvv, zve32f
    lpad    0
    addi    sp, sp, -16
    sd      s0, 0(sp)
    sd      s1, 8(sp)
    mv      s0, a0
    mv      s1, a2
1:
    blez    a3, 4f
    ld      a4, 0(a1)
    addi    a1, a1, 8
    addi    a3, a3, -1
    mv      a0, s0
    mv      a2, s1
2:
    vsetvli t0, a2, e32, m8, ta, ma
    vle32.v v0, (a4)
    sub     a2, a2, t0
    slli    t1, t0, 2
    vfcvt.rtz.x.f.v v8, v0
    add     a4, a4, t1
    vsetvli zero, zero, e16, m4, ta, ma
    vnclip.wi v16, v8, 0
    slli    t2, a3, 1
    slli    t3, t0, 1
    mul     t4, t3, a3
    mv      t5, t0
3:
    vsetvli t0, t5, e16, m4, ta, ma
    vse16.v v16, (a0)
    sub     t5, t5, t0
    slli    t6, t0, 1
    add     a0, a0, t6
    bnez    t5, 3b
    bnez    a2, 2b
    j       1b
4:
    ld      s0, 0(sp)
    ld      s1, 8(sp)
    addi    sp, sp, 16
    ret
endfunc
