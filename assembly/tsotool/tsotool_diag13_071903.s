// Modified by Princeton University on June 9th, 2015
/*
* ========== Copyright Header Begin ==========================================
* 
* OpenSPARC T1 Processor File: tsotool_diag13_071903.s
* Copyright (c) 2006 Sun Microsystems, Inc.  All Rights Reserved.
* DO NOT ALTER OR REMOVE COPYRIGHT NOTICES.
* 
* The above named program is free software; you can redistribute it and/or
* modify it under the terms of the GNU General Public
* License version 2 as published by the Free Software Foundation.
* 
* The above named program is distributed in the hope that it will be 
* useful, but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
* General Public License for more details.
* 
* You should have received a copy of the GNU General Public
* License along with this work; if not, write to the Free Software
* Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA 02110-1301, USA.
* 
* ========== Copyright Header End ============================================
*/
! no tsotool postprocessing
! TSOTOOL.PROCESSOR niagara.rtl
! TSOTOOL.MODE GEN
! TSOTOOL.READ_EGI 
! TSOTOOL.WRITE_EGI diag.egi
! TSOTOOL.N_PROCS 8
! TSOTOOL.TEST_NAME diag
! TSOTOOL.BATCH Y
! TSOTOOL.VERBOSE Y
! GEN.N_INSTR_PER_PROC 1000
! GEN.AVG_LOOP_SIZE 512
! GEN.AVG_LOOP_ITER 10
! ADMAP.REGION_SIZE 64
! ADMAP.REGION_OFFSETS 0-4-12-32-64,76-80-84-256-512,32-64,0-64-128-192
! ADMAP.ATTRIBUTES CV=0111,CP=1111
! ADMAP.N_ALIASES 0
! ADMAP.ALIAS_FREQUENCY 64
! ADMAP.ALIAS_OFFSET 8388608
! WT.PCT_FP_INSTR 100
! WT.PCT_LITTLE_ENDIAN 5
! WT.PCT_LOADS_NF 0
! WT.PCT_NFS_FAULT 0
! WT.PCT_PREFETCH_FAULT 0
! WT.PCT_PREFETCH_UNIMP 0
! WT.PCT_CBRANCH 5
! WT.PCT_SECONDARY_CTX 0
! WT.PCT_NUCLEUS_CTX 0
! WT.REPLACEMENT 10
! WT.INTERRUPT 0
! WT.LD 10
! WT.BLD 0
! WT.DWLD 10
! WT.QWLD 0
! WT.AQLD 0
! WT.ST 10
! WT.BST 0
! WT.BSTC 0
! WT.DWST 10
! WT.QWST 0
! WT.SWAP 3
! WT.CAS 3
! WT.CASX 3
! WT.ASI_L2_FLUSH 0
! WT.FLUSHI 0
! WT.MEMBAR 2
! WT.PREFETCH 10
! WT.NOP 1
! DBG.WRITE_RESULTS_FILE Y
! ADV.L2_WAYS 4
! ADV.TEST_ITERATIONS 1
! ADV.RESULTS_TO_MEM N
! ADV.BST_MEMBARS Y
! ADV.BLD_MEMBARS Y
! ADV.PREFETCH_FCNS fcn_1=5
! ADV.SAME_TEST_ALL_CPUS N
! ADV.ANALYSIS_EFFORT max
! ADV.ONLINE_PASSES 10
! GEN.SEED 19


#define N_CPUS  8
#define REGION_SIZE_RTL (64 * 1024)
!====#define RESULTS_BUF_SIZE_PER_CPU_RTL 128
#define RESULTS_BUF_SIZE_PER_CPU_RTL 1024
#define PRIVATE_DATA_AREA_PER_CPU_RTL 64

#define ALIGN_PAGE_8K .align 8192
#define ALIGN_PAGE_512K .align 524288
#define ALIGN_PAGE_4M .align 4194304
SECTION .MY_HYP_SEC TEXT_VA = 0x1100150000
attr_text {
        Name=.MY_HYP_SEC,
        hypervisor
	}
.text
.global intr0x60_custom_trap
intr0x60_custom_trap:
	ldxa	[%g0] 0x72, %g2;
	ldxa	[%g0] 0x74, %g1;	
	retry;

.global intr0x190_custom_trap
intr0x190_custom_trap:
	stxa	%i0, [%g0] 0x73;	
	done;

!============================================================================

#define ENABLE_T0_Fp_exception_ieee_754_0x21
#define ENABLE_T0_Fp_exception_other_0x22
#define ENABLE_T0_Fp_disabled_0x20
#define ENABLE_T0_Illegal_instruction_0x10
#define ENABLE_T0_Clean_Window_0x24

#define H_T0_Trap_Instruction_0
#define My_T0_Trap_Instruction_0	\
	ta      0x90;			\
	done;

#define H_HT0_HTrap_Instruction_0 intr0x190_custom_trap
#define H_HT0_Interrupt_0x60 intr0x60_custom_trap

#include "custom_page1.h"

#define B_TRAP T_BAD_TRAP
#define G_TRAP T_GOOD_TRAP

define(EXIT_GOOD, `ta G_TRAP')
define(EXIT_BAD, `ta B_TRAP')

!try later:
!	stxa    %l6, [$8] (0x22 | ($2 & 0x9)) ! ASI is randomly set
!===========
define(BST_INIT, `
	add     $6, ($7 & 0xfff0), $8	! 4-byte align the offset
	stxa    %l6, [$8] 0x22		! ASI is randomly set
')

!try later:
!ldda    [$8] (0x22 | ($2 & 0x9)), %l6 ! ASI is randomly set
!===========
define(BLD_INIT, `
        add     $6, ($7 & 0xfff0), $8 	! 4-byte align the offset
        ldda    [$8] 0x22, %l6 		! ASI is randomly set
')

define(CHECK_PROC_ID,`
check_cpu_id: 

	wr	%g0, 0x4, %fprs         /* make sure fef is 1 */
	mov 	THREAD_STRIDE, %l2
	th_fork(thread,%l0)

thread_0:
	mov 	0, %g1 
        udivx 	%g1, %l2, %g1
	ba	entry_point; nop
	
	
thread_1:
	mov 	1, %g1 
        udivx 	%g1, %l2, %g1
	ba	entry_point; nop
	
thread_2:
	mov 	2, %g1 
        udivx 	%g1, %l2, %g1
	ba	entry_point; nop
	
thread_3:
	mov 	3, %g1 
        udivx 	%g1, %l2, %g1
	ba	entry_point; nop
	
thread_4:
	mov 	4, %g1 
        udivx 	%g1, %l2, %g1
	ba	entry_point; nop
	
thread_5:
	mov 	5, %g1 
        udivx 	%g1, %l2, %g1
	ba	entry_point; nop
	
thread_6:
	mov 	6, %g1 
        udivx 	%g1, %l2, %g1
	ba	entry_point; nop
	
thread_7:
	mov 	7, %g1 
        udivx 	%g1, %l2, %g1
	ba	entry_point; nop
	
thread_8:
	mov 	8, %g1 
        udivx 	%g1, %l2, %g1
	ba	entry_point; nop
	
thread_9:
	mov 	9, %g1 
        udivx 	%g1, %l2, %g1
	ba	entry_point; nop
	
thread_10:
	mov 	10, %g1 
        udivx 	%g1, %l2, %g1
	ba	entry_point; nop
	
thread_11:
	mov 	11, %g1 
        udivx 	%g1, %l2, %g1
	ba	entry_point; nop
	
thread_12:
	mov 	12, %g1 
        udivx 	%g1, %l2, %g1
	ba	entry_point; nop
	
thread_13:
	mov 	13, %g1 
        udivx 	%g1, %l2, %g1
	ba	entry_point; nop
	
thread_14:
	mov 	14, %g1 
        udivx 	%g1, %l2, %g1
	ba	entry_point; nop
	
thread_15:
	mov 	15, %g1 
        udivx 	%g1, %l2, %g1
	ba	entry_point; nop
	
thread_16:
	mov 	16, %g1 
        udivx 	%g1, %l2, %g1
	ba	entry_point; nop
	
thread_17:
	mov 	17, %g1 
        udivx 	%g1, %l2, %g1
	ba	entry_point; nop
	
thread_18:
	mov 	18, %g1 
        udivx 	%g1, %l2, %g1
	ba	entry_point; nop
	
thread_19:
	mov 	19, %g1 
        udivx 	%g1, %l2, %g1
	ba	entry_point; nop
	
thread_20:
	mov 	20, %g1 
        udivx 	%g1, %l2, %g1
	ba	entry_point; nop
	
thread_21:
	mov 	21, %g1 
        udivx 	%g1, %l2, %g1
	ba	entry_point; nop
	
thread_22:
	mov 	22, %g1 
        udivx 	%g1, %l2, %g1
	ba	entry_point; nop
	
thread_23:
	mov 	23, %g1 
        udivx 	%g1, %l2, %g1
	ba	entry_point; nop
	
thread_24:
	mov 	24, %g1 
        udivx 	%g1, %l2, %g1
	ba	entry_point; nop
	
thread_25:
	mov 	25, %g1 
        udivx 	%g1, %l2, %g1
	ba	entry_point; nop
	
thread_26:
	mov 	26, %g1 
        udivx 	%g1, %l2, %g1
	ba	entry_point; nop
	
	
thread_27:
	mov 	27, %g1 
        udivx 	%g1, %l2, %g1
	ba	entry_point; nop
	
thread_28:
	mov 	28, %g1 
        udivx 	%g1, %l2, %g1
	ba	entry_point; nop
	
thread_29:
	mov 	29, %g1 
        udivx 	%g1, %l2, %g1
	ba	entry_point; nop
	
thread_30:
	mov 	30, %g1 
        udivx 	%g1, %l2, %g1
	ba	entry_point; nop
	
thread_31:
	mov 	31, %g1 
        udivx 	%g1, %l2, %g1
	ba	entry_point; nop

entry_point:
#ifdef RTGPRIV
	ta	T_CHANGE_PRIV
#endif
	
')
define(EN_INTERRUPTS,`
nop
')

define(DIS_INTERRUPTS,`
nop
')

define(CHECK_DISPATCH_STATUS,`
nop
')

define(CHECK_RECEIVE_STATUS,`
nop
')

define(WRITE_INTR_DATA_REGS,`
nop
')

define(INTR_SET_DISPATCH_VECTOR,`
add      %g0,$3,$4
sllx    $4, 8, $5      ! DEST ID
add      %g0,$2,$4	! VECTOR NUMBER
or      $5,$4,$5
mov %i0, $4
mov $5, %i0
ta 0x30
mov $4, %i0
')

define(DSPCH_INTERRUPT,`
nop
')

.seg "text"
ALIGN_PAGE_8K
local_trap_handlers_start:

.align 64
extern_interrupt_handler:
stxa  %g0, [%g0]ASI_INTR_RECEIVE
retry

local_trap_handlers_end:


!------------------------------------------------------------------------

.seg "data"
ALIGN_PAGE_512K
tsotool_unshared_data_start:
!-- label names of res_buf must match with extract_loads_m64.pl --
.align 64 ! for self bcopy()
res_buf_fp_p_0:
	.skip RESULTS_BUF_SIZE_PER_CPU_RTL/2
.align 64 ! for self bcopy()
res_buf_int_p_0:
	.skip RESULTS_BUF_SIZE_PER_CPU_RTL/2
.align 64 ! for self bcopy()
res_buf_fp_p_1:
	.skip RESULTS_BUF_SIZE_PER_CPU_RTL/2
.align 64 ! for self bcopy()
res_buf_int_p_1:
	.skip RESULTS_BUF_SIZE_PER_CPU_RTL/2
.align 64 ! for self bcopy()
res_buf_fp_p_2:
	.skip RESULTS_BUF_SIZE_PER_CPU_RTL/2
.align 64 ! for self bcopy()
res_buf_int_p_2:
	.skip RESULTS_BUF_SIZE_PER_CPU_RTL/2
.align 64 ! for self bcopy()
res_buf_fp_p_3:
	.skip RESULTS_BUF_SIZE_PER_CPU_RTL/2
.align 64 ! for self bcopy()
res_buf_int_p_3:
	.skip RESULTS_BUF_SIZE_PER_CPU_RTL/2
.align 64 ! for self bcopy()
res_buf_fp_p_4:
	.skip RESULTS_BUF_SIZE_PER_CPU_RTL/2
.align 64 ! for self bcopy()
res_buf_int_p_4:
	.skip RESULTS_BUF_SIZE_PER_CPU_RTL/2
.align 64 ! for self bcopy()
res_buf_fp_p_5:
	.skip RESULTS_BUF_SIZE_PER_CPU_RTL/2
.align 64 ! for self bcopy()
res_buf_int_p_5:
	.skip RESULTS_BUF_SIZE_PER_CPU_RTL/2
.align 64 ! for self bcopy()
res_buf_fp_p_6:
	.skip RESULTS_BUF_SIZE_PER_CPU_RTL/2
.align 64 ! for self bcopy()
res_buf_int_p_6:
	.skip RESULTS_BUF_SIZE_PER_CPU_RTL/2
.align 64 ! for self bcopy()
res_buf_fp_p_7:
	.skip RESULTS_BUF_SIZE_PER_CPU_RTL/2
.align 64 ! for self bcopy()
res_buf_int_p_7:
	.skip RESULTS_BUF_SIZE_PER_CPU_RTL/2
private_data_p0:
	.skip PRIVATE_DATA_AREA_PER_CPU_RTL
private_data_p1:
	.skip PRIVATE_DATA_AREA_PER_CPU_RTL
private_data_p2:
	.skip PRIVATE_DATA_AREA_PER_CPU_RTL
private_data_p3:
	.skip PRIVATE_DATA_AREA_PER_CPU_RTL
private_data_p4:
	.skip PRIVATE_DATA_AREA_PER_CPU_RTL
private_data_p5:
	.skip PRIVATE_DATA_AREA_PER_CPU_RTL
private_data_p6:
	.skip PRIVATE_DATA_AREA_PER_CPU_RTL
private_data_p7:
	.skip PRIVATE_DATA_AREA_PER_CPU_RTL
stack_top_p0:
	.skip 2048
stack_top_p1:
	.skip 2048
stack_top_p2:
	.skip 2048
stack_top_p3:
	.skip 2048
stack_top_p4:
	.skip 2048
stack_top_p5:
	.skip 2048
stack_top_p6:
	.skip 2048
stack_top_p7:
	.skip 2048
tsotool_unshared_data_end:

!------------------------------------------------------------------------

.seg "data"
! 4 shared memory regions, 0 alias(es) each (Alias 0 is normal VA)

ALIGN_PAGE_8K
REGION0_ALIAS0_START:
	.skip REGION_SIZE_RTL
REGION0_ALIAS0_END:

ALIGN_PAGE_8K
REGION1_ALIAS0_START:
	.skip REGION_SIZE_RTL
REGION1_ALIAS0_END:

ALIGN_PAGE_8K
REGION2_ALIAS0_START:
	.skip REGION_SIZE_RTL
REGION2_ALIAS0_END:

ALIGN_PAGE_8K
REGION3_ALIAS0_START:
	.skip REGION_SIZE_RTL
REGION3_ALIAS0_END:

ALIGN_PAGE_8K
REPLACEMENT_ALIAS0_START:
	.skip 4 * REGION_SIZE_RTL	 ! replacement area
REPLACEMENT_ALIAS0_END:

.global main
.seg "text"
ALIGN_PAGE_8K
user_text_start:
main:
	mov     0, %o0
	mov     0, %o1
	CHECK_PROC_ID
! at this point, g1 should have CPU id (0, 1, 2, ...)
	set     REGION0_ALIAS0_START, %o0	! shared address 0
	set     REGION1_ALIAS0_START, %o1	! shared address 1
	set     REGION2_ALIAS0_START, %o2	! shared address 2
	set     REGION3_ALIAS0_START, %o3	! shared address 3
	cmp     %g1, 0x7
	be      setup_p7
	nop
	cmp     %g1, 0x6
	be      setup_p6
	nop
	cmp     %g1, 0x5
	be      setup_p5
	nop
	cmp     %g1, 0x4
	be      setup_p4
	nop
	cmp     %g1, 0x3
	be      setup_p3
	nop
	cmp     %g1, 0x2
	be      setup_p2
	nop
	cmp     %g1, 0x1
	be      setup_p1
	nop
	cmp     %g1, 0x0
	be      setup_p0
	nop
	EXIT_BAD   ! Should never reach here
	nop

setup_p0:
	set     stack_top_p0, %l1
	add     %l1, 1024, %sp
	set     res_buf_fp_p_0, %o4
	set     private_data_p0, %o5
	set     func0, %l4
	call    %l4
	nop
	EXIT_GOOD
	nop

setup_p1:
	set     stack_top_p1, %l1
	add     %l1, 1024, %sp
	set     res_buf_fp_p_1, %o4
	set     private_data_p1, %o5
	set     func1, %l4
	call    %l4
	nop
	EXIT_GOOD
	nop

setup_p2:
	set     stack_top_p2, %l1
	add     %l1, 1024, %sp
	set     res_buf_fp_p_2, %o4
	set     private_data_p2, %o5
	set     func2, %l4
	call    %l4
	nop
	EXIT_GOOD
	nop

setup_p3:
	set     stack_top_p3, %l1
	add     %l1, 1024, %sp
	set     res_buf_fp_p_3, %o4
	set     private_data_p3, %o5
	set     func3, %l4
	call    %l4
	nop
	EXIT_GOOD
	nop

setup_p4:
	set     stack_top_p4, %l1
	add     %l1, 1024, %sp
	set     res_buf_fp_p_4, %o4
	set     private_data_p4, %o5
	set     func4, %l4
	call    %l4
	nop
	EXIT_GOOD
	nop

setup_p5:
	set     stack_top_p5, %l1
	add     %l1, 1024, %sp
	set     res_buf_fp_p_5, %o4
	set     private_data_p5, %o5
	set     func5, %l4
	call    %l4
	nop
	EXIT_GOOD
	nop

setup_p6:
	set     stack_top_p6, %l1
	add     %l1, 1024, %sp
	set     res_buf_fp_p_6, %o4
	set     private_data_p6, %o5
	set     func6, %l4
	call    %l4
	nop
	EXIT_GOOD
	nop

setup_p7:
	set     stack_top_p7, %l1
	add     %l1, 1024, %sp
	set     res_buf_fp_p_7, %o4
	set     private_data_p7, %o5
	set     func7, %l4
	call    %l4
	nop
	EXIT_GOOD
	nop
!-----------------

! register usage:
! %i0 %i1 %i2 %i3 : base registers for 4 regions
! %i4 fixed pointer to per-cpu results area
! %l1 moving pointer to per-cpu FP results area
! %o7 moving pointer to per-cpu integer results area
! %i5 pointer to per-cpu private area
! %l0 holds lfsr, used as source of random bits 
! %l2 loop count register
! %f16 running counter for unique fp store values
! %f17 holds increment value for fp counter
! %l4 running counter for unique integer store values (increment value is always 1)
! %l5 move-to register for load values (simulation only)
! %f30 move-to register for FP values (simulation only)
! %l3 %l6 %l7 %o5 : 4 temporary registers
! %o0 %o1 %o2 %o3 %o4 : 5 integer results buffer registers
! %f0-f15 FP results buffer registers
! %f32-f47 FP block load/store registers

func0:
! 1000 (dynamic) instruction sequence begins
save   %sp, -192, %sp

! Force %i0-%i3 to be 64-byte aligned
add %i0, 63, %i0
andn %i0, 63, %i0

add %i1, 63, %i1
andn %i1, 63, %i1

add %i2, 63, %i2
andn %i2, 63, %i2

add %i3, 63, %i3
andn %i3, 63, %i3

add %i4, 63, %i4
andn %i4, 63, %i4

add %i5, 63, %i5
andn %i5, 63, %i5


! Initialize pointer to FP load results area
mov   %i4, %l1

! Initialize pointer to integer load results area
sethi %hi(0x80000), %o7
or    %o7, %lo(0x80000), %o7
add  %o7, %l1, %o7 

! Initialize %f0-%f62 to 0xdeadbee0deadbee1
sethi %hi(0xdeadbee0), %l6
or    %l6, %lo(0xdeadbee0), %l6
stw   %l6, [%i5]
sethi %hi(0xdeadbee1), %l6
or    %l6, %lo(0xdeadbee1), %l6
stw   %l6, [%i5+4]
ldd [%i5], %f0
fmovd %f0, %f2
fmovd %f0, %f4
fmovd %f0, %f6
fmovd %f0, %f8
fmovd %f0, %f10
fmovd %f0, %f12
fmovd %f0, %f14
fmovd %f0, %f16
fmovd %f0, %f18
fmovd %f0, %f20
fmovd %f0, %f22
fmovd %f0, %f24
fmovd %f0, %f26
fmovd %f0, %f28
fmovd %f0, %f30
fmovd %f0, %f32
fmovd %f0, %f34
fmovd %f0, %f36
fmovd %f0, %f38
fmovd %f0, %f40
fmovd %f0, %f42
fmovd %f0, %f44
fmovd %f0, %f46
fmovd %f0, %f48
fmovd %f0, %f50
fmovd %f0, %f52
fmovd %f0, %f54
fmovd %f0, %f56
fmovd %f0, %f58
fmovd %f0, %f60
fmovd %f0, %f62

! Signature for extract_loads script to start extracting load values for this stream
sethi %hi(0x00deade1), %l6
or    %l6, %lo(0x00deade1), %l6
stw %l6, [%i5] 
ld [%i5], %f16

! Initialize running integer counter in register %l4
sethi %hi(0x1), %l4
or    %l4, %lo(0x1), %l4

! Initialize running FP counter in register %f16
sethi %hi(0x3f800001), %l6
or    %l6, %lo(0x3f800001), %l6
stw %l6, [%i5] 
ld [%i5], %f16

! Initialize FP counter increment value in register %f17 (constant)
sethi %hi(0x34000000), %l6
or    %l6, %lo(0x34000000), %l6
stw %l6, [%i5] 
ld [%i5], %f17 

! Initialize LFSR to 0x5bb0^4
sethi %hi(0x5bb0), %l0
or    %l0, %lo(0x5bb0), %l0
mulx  %l0, %l0, %l0
mulx  %l0, %l0, %l0

!-- init shared addrs 0 to 1 ---
stx %g0, [%i0+0]

! use untouched cache-line (offset 4K) in replacement area for sync
sub %i1, %i0, %l7
add %i3, %l7, %l7
sub %l7, -4096, %l7

!-- master of sync_init ---
or %g0, 7, %o5
swap [%l7], %o5
sync_init_0:
swap [%l7+4], %g0
lduw [%l7], %o5
brnz,pt %o5, sync_init_0
membar #Sync ! delay slot
!-- end of sync_init ---


BEGIN_NODES0: ! Test istream for CPU 0 begins

P1: !_DWST [10] (maybe <- 0x3f800001) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
std %f20, [%i2 + 32]

P2: !_PREFETCH [12] (Int)
prefetch [%i3 + 0], 1

P3: !_LD [10] (FP)
ld [%i2 + 32], %f0
! 1 addresses covered

P4: !_PREFETCH [5] (Int)
prefetch [%i1 + 76], 1

P5: !_PREFETCH [5] (Int) (LE)
wr %g0, 0x88, %asi
prefetcha [%i1 + 76] %asi, 1

P6: !_ST [14] (maybe <- 0x3f800002) (FP) (Branch target of P487)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i3 + 128 ]
ba P7
nop

TARGET487:
ba RET487
nop


P7: !_PREFETCH [12] (Int)
prefetch [%i3 + 0], 1

P8: !_PREFETCH [10] (Int)
prefetch [%i2 + 32], 1

P9: !_PREFETCH [14] (Int)
prefetch [%i3 + 128], 1

P10: !_DWST [4] (maybe <- 0x3f800003) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
std %f20, [%i0 + 64]

P11: !_MEMBAR (Int) (CBR) (Branch target of P415)
membar #StoreLoad

! cbranch
andcc %l0, 1, %g0
be,pn  %xcc, TARGET11
nop
RET11:

! lfsr step begin
srlx %l0, 1, %l7
xnor %l7, %l0, %l7
sllx %l7, 63, %l7
or  %l7, %l0, %l0
srlx %l0, 1, %l0

ba P12
nop

TARGET415:
ba RET415
nop


P12: !_CASX [10] (maybe <- 0x1) (Int)
add %i2, 32, %l3
ldx [%l3], %o0
! move %o0(upper) -> %o0(upper)
! move %o0(lower) -> %o0(lower)
mov  %o0, %o5
sllx %l4, 32, %o1
casx [%l3], %o5, %o1
! move %o1(upper) -> %o1(upper)
! move %o1(lower) -> %o1(lower)
add  %l4, 1, %l4

P13: !_PREFETCH [5] (Int)
prefetch [%i1 + 76], 1

P14: !_CASX [5] (maybe <- 0x2) (Int)
add %i1, 72, %l3
ldx [%l3], %o2
! move %o2(upper) -> %o2(upper)
! move %o2(lower) -> %o2(lower)
mov  %o2, %o5
mov %l4, %o3
casx [%l3], %o5, %o3
! move %o3(upper) -> %o3(upper)
! move %o3(lower) -> %o3(lower)
add  %l4, 1, %l4

P15: !_REPLACEMENT [8] (Int)
sethi %hi(0x100), %o5
or %o5, %lo(0x100),  %o5
sethi %hi(0x10000), %l3
or %l3, %lo(0x10000),  %l3
add %i3, %o5, %o5
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]

P16: !_PREFETCH [2] (Int)
prefetch [%i0 + 12], 1

P17: !_LD [9] (FP)
ld [%i1 + 512], %f1
! 1 addresses covered

P18: !_LD [2] (FP)
ld [%i0 + 12], %f2
! 1 addresses covered

P19: !_DWLD [12] (FP)
ldd [%i3 + 0], %f18
! 1 addresses covered
fmovs %f18, %f3

P20: !_DWST [4] (maybe <- 0x3f800004) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
std %f20, [%i0 + 64]

P21: !_DWST [4] (maybe <- 0x3f800005) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
std %f20, [%i0 + 64]

P22: !_DWLD [7] (FP)
ldd [%i1 + 80], %f4
! 2 addresses covered

P23: !_LD [7] (FP)
ld [%i1 + 84], %f6
! 1 addresses covered

P24: !_REPLACEMENT [9] (Int)
sethi %hi(0x200), %l3
or %l3, %lo(0x200),  %l3
sethi %hi(0x10000), %l6
or %l6, %lo(0x10000),  %l6
add %i3, %l3, %l3
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]

P25: !_DWST [9] (maybe <- 0x3f800006) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
std %f20, [%i1 + 512]

P26: !_PREFETCH [14] (Int)
prefetch [%i3 + 128], 1

P27: !_DWLD [11] (FP)
ldd [%i2 + 64], %f18
! 1 addresses covered
fmovs %f18, %f7

P28: !_DWST [1] (maybe <- 0x3f800007) (FP) (CBR)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
! 1 th moved, current_fp_src=21 
fmovs  %f16, %f21
fadds  %f16, %f17, %f16
std %f20, [%i0 + 0]

! cbranch
andcc %l0, 1, %g0
be,pn  %xcc, TARGET28
nop
RET28:

! lfsr step begin
srlx %l0, 1, %l6
xnor %l6, %l0, %l6
sllx %l6, 63, %l6
or  %l6, %l0, %l0
srlx %l0, 1, %l0


P29: !_CAS [3] (maybe <- 0x3) (Int)
add %i0, 32, %o5
lduw [%o5], %o4
mov %o4, %l7
! move %l7(lower) -> %o4(upper)
sllx %l7, 32, %o4
mov %l4, %l6
cas [%o5], %l7, %l6
! move %l6(lower) -> %o4(lower)
srl %l6, 0, %o5
or %o5, %o4, %o4
!---- flushing int results buffer----
mov %o0, %l5
mov %o1, %l5
mov %o2, %l5
mov %o3, %l5
mov %o4, %l5
add   %l4, 1, %l4

P30: !_ST [9] (maybe <- 0x3f800009) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i1 + 512 ]

P31: !_PREFETCH [5] (Int)
prefetch [%i1 + 76], 1

P32: !_LD [1] (FP) (Branch target of P184)
ld [%i0 + 4], %f8
! 1 addresses covered
ba P33
nop

TARGET184:
ba RET184
nop


P33: !_PREFETCH [13] (Int)
prefetch [%i3 + 64], 1

P34: !_PREFETCH [9] (Int)
prefetch [%i1 + 512], 1

P35: !_REPLACEMENT [14] (Int)
sethi %hi(0x80), %l6
or %l6, %lo(0x80),  %l6
sethi %hi(0x10000), %l7
or %l7, %lo(0x10000),  %l7
add %i3, %l6, %l6
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]

P36: !_DWLD [1] (FP)
ldd [%i0 + 0], %f18
! 2 addresses covered
fmovs %f18, %f9
fmovs %f19, %f10

P37: !_DWST [1] (maybe <- 0x3f80000a) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
! 1 th moved, current_fp_src=21 
fmovs  %f16, %f21
fadds  %f16, %f17, %f16
std %f20, [%i0 + 0]

P38: !_SWAP [7] (maybe <- 0x4) (Int)
mov %l4, %o0
swap  [%i1 + 84], %o0
! move %o0(lower) -> %o0(upper)
sllx %o0, 32, %o0
add   %l4, 1, %l4

P39: !_REPLACEMENT [9] (Int)
sethi %hi(0x200), %l7
or %l7, %lo(0x200),  %l7
sethi %hi(0x10000), %o5
or %o5, %lo(0x10000),  %o5
add %i3, %l7, %l7
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]

P40: !_DWST [13] (maybe <- 0x3f80000c) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
std %f20, [%i3 + 64]

P41: !_DWST [9] (maybe <- 0x3f80000d) (FP) (Branch target of P511)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
std %f20, [%i1 + 512]
ba P42
nop

TARGET511:
ba RET511
nop


P42: !_SWAP [13] (maybe <- 0x5) (Int)
mov %l4, %l6
swap  [%i3 + 64], %l6
! move %l6(lower) -> %o0(lower)
srl %l6, 0, %o5
or %o5, %o0, %o0
add   %l4, 1, %l4

P43: !_REPLACEMENT [9] (Int)
sethi %hi(0x200), %l7
or %l7, %lo(0x200),  %l7
sethi %hi(0x10000), %o5
or %o5, %lo(0x10000),  %o5
add %i3, %l7, %l7
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]

P44: !_DWLD [10] (FP)
ldd [%i2 + 32], %f18
! 1 addresses covered
fmovs %f18, %f11

P45: !_REPLACEMENT [9] (Int)
sethi %hi(0x200), %l6
or %l6, %lo(0x200),  %l6
sethi %hi(0x10000), %l7
or %l7, %lo(0x10000),  %l7
add %i3, %l6, %l6
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]

P46: !_ST [14] (maybe <- 0x3f80000e) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i3 + 128 ]

P47: !_LD [13] (FP)
ld [%i3 + 64], %f12
! 1 addresses covered

P48: !_LD [0] (FP) (CBR)
ld [%i0 + 0], %f13
! 1 addresses covered

! cbranch
andcc %l0, 1, %g0
be,pt  %xcc, TARGET48
nop
RET48:

! lfsr step begin
srlx %l0, 1, %o5
xnor %o5, %l0, %o5
sllx %o5, 63, %o5
or  %o5, %l0, %l0
srlx %l0, 1, %l0


P49: !_DWST [9] (maybe <- 0x3f80000f) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
std %f20, [%i1 + 512]

P50: !_REPLACEMENT [10] (Int)
sethi %hi(0x20), %o5
or %o5, %lo(0x20),  %o5
sethi %hi(0x10000), %l3
or %l3, %lo(0x10000),  %l3
add %i3, %o5, %o5
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]

P51: !_REPLACEMENT [10] (Int) (CBR)
sethi %hi(0x20), %l7
or %l7, %lo(0x20),  %l7
sethi %hi(0x10000), %o5
or %o5, %lo(0x10000),  %o5
add %i3, %l7, %l7
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]

! cbranch
andcc %l0, 1, %g0
be,pn  %xcc, TARGET51
nop
RET51:

! lfsr step begin
srlx %l0, 1, %l6
xnor %l6, %l0, %l6
sllx %l6, 63, %l6
or  %l6, %l0, %l0
srlx %l0, 1, %l0


P52: !_ST [1] (maybe <- 0x3f800010) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i0 + 4 ]

P53: !_REPLACEMENT [2] (Int)
sethi %hi(0xc), %l6
or %l6, %lo(0xc),  %l6
sethi %hi(0x10000), %l7
or %l7, %lo(0x10000),  %l7
add %i3, %l6, %l6
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]

P54: !_REPLACEMENT [3] (Int)
sethi %hi(0x20), %l3
or %l3, %lo(0x20),  %l3
sethi %hi(0x10000), %l6
or %l6, %lo(0x10000),  %l6
add %i3, %l3, %l3
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]

P55: !_CASX [6] (maybe <- 0x6) (Int) (Branch target of P248)
add %i1, 80, %l3
ldx [%l3], %o1
! move %o1(upper) -> %o1(upper)
! move %o1(lower) -> %o1(lower)
mov %o1, %o5
sllx %l4, 32, %o2
add  %l4, 1, %l4
or   %l4, %o2, %o2
casx [%l3], %o5, %o2
! move %o2(upper) -> %o2(upper)
! move %o2(lower) -> %o2(lower)
add  %l4, 1, %l4
ba P56
nop

TARGET248:
ba RET248
nop


P56: !_REPLACEMENT [3] (Int)
sethi %hi(0x20), %o5
or %o5, %lo(0x20),  %o5
sethi %hi(0x10000), %l3
or %l3, %lo(0x10000),  %l3
add %i3, %o5, %o5
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]

P57: !_CAS [10] (maybe <- 0x8) (Int)
add %i2, 32, %o5
lduw [%o5], %o3
mov %o3, %l7
! move %l7(lower) -> %o3(upper)
sllx %l7, 32, %o3
mov %l4, %l6
cas [%o5], %l7, %l6
! move %l6(lower) -> %o3(lower)
srl %l6, 0, %o5
or %o5, %o3, %o3
add   %l4, 1, %l4

P58: !_ST [7] (maybe <- 0x3f800011) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i1 + 84 ]

P59: !_DWST [4] (maybe <- 0x3f800012) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
std %f20, [%i0 + 64]

P60: !_DWLD [0] (FP)
ldd [%i0 + 0], %f14
! 2 addresses covered
!---- flushing fp results buffer to %f30 ----
fmovd %f0, %f30
fmovd %f2, %f30
fmovd %f4, %f30
fmovd %f6, %f30
fmovd %f8, %f30
fmovd %f10, %f30
fmovd %f12, %f30
fmovd %f14, %f30

P61: !_DWLD [0] (FP)
ldd [%i0 + 0], %f0
! 2 addresses covered

P62: !_DWLD [2] (FP)
ldd [%i0 + 8], %f2
! 1 addresses covered
fmovs %f3, %f2

P63: !_LD [13] (FP)
ld [%i3 + 64], %f3
! 1 addresses covered

P64: !_PREFETCH [2] (Int)
prefetch [%i0 + 12], 1

P65: !_CASX [3] (maybe <- 0x9) (Int)
add %i0, 32, %l6
ldx [%l6], %o4
! move %o4(upper) -> %o4(upper)
! move %o4(lower) -> %o4(lower)
!---- flushing int results buffer----
mov %o0, %l5
mov %o1, %l5
mov %o2, %l5
mov %o3, %l5
mov %o4, %l5
mov  %o4, %l3
sllx %l4, 32, %o0
casx [%l6], %l3, %o0
! move %o0(upper) -> %o0(upper)
! move %o0(lower) -> %o0(lower)
add  %l4, 1, %l4

P66: !_DWST [14] (maybe <- 0x3f800013) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
std %f20, [%i3 + 128]

P67: !_PREFETCH [2] (Int)
prefetch [%i0 + 12], 1

P68: !_DWST [8] (maybe <- 0x3f800014) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
std %f20, [%i1 + 256]

P69: !_LD [7] (FP)
ld [%i1 + 84], %f4
! 1 addresses covered

P70: !_LD [6] (FP)
ld [%i1 + 80], %f5
! 1 addresses covered

P71: !_LD [5] (FP)
ld [%i1 + 76], %f6
! 1 addresses covered

P72: !_PREFETCH [10] (Int)
prefetch [%i2 + 32], 1

P73: !_PREFETCH [11] (Int)
prefetch [%i2 + 64], 1

P74: !_PREFETCH [4] (Int)
prefetch [%i0 + 64], 1

P75: !_PREFETCH [11] (Int)
prefetch [%i2 + 64], 1

P76: !_DWLD [12] (FP)
ldd [%i3 + 0], %f18
! 1 addresses covered
fmovs %f18, %f7

P77: !_ST [10] (maybe <- 0x3f800015) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i2 + 32 ]

P78: !_LD [6] (FP)
ld [%i1 + 80], %f8
! 1 addresses covered

P79: !_LD [14] (FP)
ld [%i3 + 128], %f9
! 1 addresses covered

P80: !_LD [3] (FP)
ld [%i0 + 32], %f10
! 1 addresses covered

P81: !_PREFETCH [6] (Int)
prefetch [%i1 + 80], 1

P82: !_CASX [0] (maybe <- 0xa) (Int)
add %i0, 0, %l7
ldx [%l7], %o1
! move %o1(upper) -> %o1(upper)
! move %o1(lower) -> %o1(lower)
mov %o1, %l6
sllx %l4, 32, %o2
add  %l4, 1, %l4
or   %l4, %o2, %o2
casx [%l7], %l6, %o2
! move %o2(upper) -> %o2(upper)
! move %o2(lower) -> %o2(lower)
add  %l4, 1, %l4

P83: !_NOP (Int)
nop

P84: !_SWAP [2] (maybe <- 0xc) (Int)
mov %l4, %o3
swap  [%i0 + 12], %o3
! move %o3(lower) -> %o3(upper)
sllx %o3, 32, %o3
add   %l4, 1, %l4

P85: !_DWLD [15] (FP)
ldd [%i3 + 192], %f18
! 1 addresses covered
fmovs %f18, %f11

P86: !_DWST [11] (maybe <- 0x3f800016) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
std %f20, [%i2 + 64]

P87: !_ST [13] (maybe <- 0x3f800017) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i3 + 64 ]

P88: !_MEMBAR (Int)
membar #StoreLoad

P89: !_DWLD [8] (FP)
ldd [%i1 + 256], %f12
! 1 addresses covered

P90: !_REPLACEMENT [9] (Int)
sethi %hi(0x200), %l7
or %l7, %lo(0x200),  %l7
sethi %hi(0x10000), %o5
or %o5, %lo(0x10000),  %o5
add %i3, %l7, %l7
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]

P91: !_MEMBAR (Int)
membar #StoreLoad

P92: !_ST [5] (maybe <- 0x3f800018) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i1 + 76 ]

P93: !_REPLACEMENT [5] (Int)
sethi %hi(0x4c), %l3
or %l3, %lo(0x4c),  %l3
sethi %hi(0x10000), %l6
or %l6, %lo(0x10000),  %l6
add %i3, %l3, %l3
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]

P94: !_ST [7] (maybe <- 0x3f800019) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i1 + 84 ]

P95: !_DWLD [10] (FP)
ldd [%i2 + 32], %f18
! 1 addresses covered
fmovs %f18, %f13

P96: !_MEMBAR (Int)
membar #StoreLoad

P97: !_LD [7] (FP)
ld [%i1 + 84], %f14
! 1 addresses covered

P98: !_LD [4] (FP)
ld [%i0 + 64], %f15
! 1 addresses covered
!---- flushing fp results buffer to %f30 ----
fmovd %f0, %f30
fmovd %f2, %f30
fmovd %f4, %f30
fmovd %f6, %f30
fmovd %f8, %f30
fmovd %f10, %f30
fmovd %f12, %f30
fmovd %f14, %f30

P99: !_PREFETCH [3] (Int)
prefetch [%i0 + 32], 1

P100: !_ST [13] (maybe <- 0x3f80001a) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i3 + 64 ]

P101: !_CASX [15] (maybe <- 0xd) (Int) (Branch target of P345)
add %i3, 192, %l7
ldx [%l7], %l3
! move %l3(upper) -> %o3(lower)
srlx %l3, 32, %l6
or %l6, %o3, %o3
! move %l3(lower) -> %o4(upper)
sllx %l3, 32, %o4
mov  %l3, %l6
sllx %l4, 32, %l3
casx [%l7], %l6, %l3
! move %l3(upper) -> %o4(lower)
srlx %l3, 32, %l7
or %l7, %o4, %o4
!---- flushing int results buffer----
mov %o0, %l5
mov %o1, %l5
mov %o2, %l5
mov %o3, %l5
mov %o4, %l5
! move %l3(lower) -> %o0(upper)
sllx %l3, 32, %o0
add  %l4, 1, %l4
ba P102
nop

TARGET345:
ba RET345
nop


P102: !_REPLACEMENT [0] (Int)
sethi %hi(0x0), %l6
or %l6, %lo(0x0),  %l6
sethi %hi(0x10000), %l7
or %l7, %lo(0x10000),  %l7
add %i3, %l6, %l6
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]

P103: !_DWST [15] (maybe <- 0x3f80001b) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
std %f20, [%i3 + 192]

P104: !_REPLACEMENT [15] (Int)
sethi %hi(0xc0), %o5
or %o5, %lo(0xc0),  %o5
sethi %hi(0x10000), %l3
or %l3, %lo(0x10000),  %l3
add %i3, %o5, %o5
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]

P105: !_CAS [13] (maybe <- 0xe) (Int)
add %i3, 64, %o5
lduw [%o5], %l6
mov %l6, %l7
! move %l7(lower) -> %o0(lower)
or %l7, %o0, %o0
mov %l4, %o1
cas [%o5], %l7, %o1
! move %o1(lower) -> %o1(upper)
sllx %o1, 32, %o1
add   %l4, 1, %l4

P106: !_LD [6] (FP)
ld [%i1 + 80], %f0
! 1 addresses covered

P107: !_LD [14] (FP)
ld [%i3 + 128], %f1
! 1 addresses covered

P108: !_PREFETCH [7] (Int)
prefetch [%i1 + 84], 1

P109: !_LD [14] (FP)
ld [%i3 + 128], %f2
! 1 addresses covered

P110: !_DWST [11] (maybe <- 0x3f80001c) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
std %f20, [%i2 + 64]

P111: !_REPLACEMENT [7] (Int)
sethi %hi(0x54), %l6
or %l6, %lo(0x54),  %l6
sethi %hi(0x10000), %l7
or %l7, %lo(0x10000),  %l7
add %i3, %l6, %l6
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]

P112: !_PREFETCH [3] (Int)
prefetch [%i0 + 32], 1

P113: !_PREFETCH [3] (Int)
prefetch [%i0 + 32], 1

P114: !_DWST [14] (maybe <- 0x3f80001d) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
std %f20, [%i3 + 128]

P115: !_CAS [3] (maybe <- 0xf) (Int)
add %i0, 32, %l3
lduw [%l3], %l7
mov %l7, %o5
! move %o5(lower) -> %o1(lower)
or %o5, %o1, %o1
mov %l4, %o2
cas [%l3], %o5, %o2
! move %o2(lower) -> %o2(upper)
sllx %o2, 32, %o2
add   %l4, 1, %l4

P116: !_LD [4] (FP)
ld [%i0 + 64], %f3
! 1 addresses covered

P117: !_DWST [9] (maybe <- 0x3f80001e) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
std %f20, [%i1 + 512]

P118: !_ST [15] (maybe <- 0x3f80001f) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i3 + 192 ]

P119: !_REPLACEMENT [15] (Int)
sethi %hi(0xc0), %l6
or %l6, %lo(0xc0),  %l6
sethi %hi(0x10000), %l7
or %l7, %lo(0x10000),  %l7
add %i3, %l6, %l6
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]

P120: !_DWST [1] (maybe <- 0x3f800020) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
! 1 th moved, current_fp_src=21 
fmovs  %f16, %f21
fadds  %f16, %f17, %f16
std %f20, [%i0 + 0]

P121: !_LD [9] (FP)
ld [%i1 + 512], %f4
! 1 addresses covered

P122: !_ST [8] (maybe <- 0x3f800022) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i1 + 256 ]

P123: !_SWAP [5] (maybe <- 0x10) (Int)
mov %l4, %l3
swap  [%i1 + 76], %l3
! move %l3(lower) -> %o2(lower)
srl %l3, 0, %l7
or %l7, %o2, %o2
add   %l4, 1, %l4

P124: !_ST [1] (maybe <- 0x3f800023) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i0 + 4 ]

P125: !_PREFETCH [6] (Int)
prefetch [%i1 + 80], 1

P126: !_CASX [6] (maybe <- 0x11) (Int)
add %i1, 80, %l6
ldx [%l6], %o3
! move %o3(upper) -> %o3(upper)
! move %o3(lower) -> %o3(lower)
mov %o3, %l3
sllx %l4, 32, %o4
add  %l4, 1, %l4
or   %l4, %o4, %o4
casx [%l6], %l3, %o4
! move %o4(upper) -> %o4(upper)
! move %o4(lower) -> %o4(lower)
!---- flushing int results buffer----
mov %o0, %l5
mov %o1, %l5
mov %o2, %l5
mov %o3, %l5
mov %o4, %l5
add  %l4, 1, %l4

P127: !_PREFETCH [4] (Int)
prefetch [%i0 + 64], 1

P128: !_CASX [7] (maybe <- 0x13) (Int)
add %i1, 80, %l6
ldx [%l6], %o0
! move %o0(upper) -> %o0(upper)
! move %o0(lower) -> %o0(lower)
mov %o0, %l3
sllx %l4, 32, %o1
add  %l4, 1, %l4
or   %l4, %o1, %o1
casx [%l6], %l3, %o1
! move %o1(upper) -> %o1(upper)
! move %o1(lower) -> %o1(lower)
add  %l4, 1, %l4

P129: !_DWST [4] (maybe <- 0x3f800024) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
std %f20, [%i0 + 64]

P130: !_LD [10] (FP)
ld [%i2 + 32], %f5
! 1 addresses covered

P131: !_PREFETCH [10] (Int)
prefetch [%i2 + 32], 1

P132: !_DWLD [1] (FP)
ldd [%i0 + 0], %f6
! 2 addresses covered

P133: !_PREFETCH [14] (Int)
prefetch [%i3 + 128], 1

P134: !_PREFETCH [14] (Int)
prefetch [%i3 + 128], 1

P135: !_LD [4] (FP)
ld [%i0 + 64], %f8
! 1 addresses covered

P136: !_ST [3] (maybe <- 0x3f800025) (FP) (CBR)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i0 + 32 ]

! cbranch
andcc %l0, 1, %g0
be,pn  %xcc, TARGET136
nop
RET136:

! lfsr step begin
srlx %l0, 1, %l7
xnor %l7, %l0, %l7
sllx %l7, 63, %l7
or  %l7, %l0, %l0
srlx %l0, 1, %l0


P137: !_DWST [3] (maybe <- 0x3f800026) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
std %f20, [%i0 + 32]

P138: !_DWST [7] (maybe <- 0x3f800027) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
! 1 th moved, current_fp_src=21 
fmovs  %f16, %f21
fadds  %f16, %f17, %f16
std %f20, [%i1 + 80]

P139: !_REPLACEMENT [13] (Int)
sethi %hi(0x40), %l6
or %l6, %lo(0x40),  %l6
sethi %hi(0x10000), %l7
or %l7, %lo(0x10000),  %l7
add %i3, %l6, %l6
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]

P140: !_MEMBAR (Int)
membar #StoreLoad

P141: !_PREFETCH [0] (Int)
prefetch [%i0 + 0], 1

P142: !_DWST [4] (maybe <- 0x3f800029) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
std %f20, [%i0 + 64]

P143: !_SWAP [13] (maybe <- 0x15) (Int)
mov %l4, %o2
swap  [%i3 + 64], %o2
! move %o2(lower) -> %o2(upper)
sllx %o2, 32, %o2
add   %l4, 1, %l4

P144: !_REPLACEMENT [9] (Int)
sethi %hi(0x200), %l7
or %l7, %lo(0x200),  %l7
sethi %hi(0x10000), %o5
or %o5, %lo(0x10000),  %o5
add %i3, %l7, %l7
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]

P145: !_PREFETCH [10] (Int) (LE)
wr %g0, 0x88, %asi
prefetcha [%i2 + 32] %asi, 1

P146: !_REPLACEMENT [13] (Int)
sethi %hi(0x40), %l6
or %l6, %lo(0x40),  %l6
sethi %hi(0x10000), %l7
or %l7, %lo(0x10000),  %l7
add %i3, %l6, %l6
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]

P147: !_PREFETCH [8] (Int)
prefetch [%i1 + 256], 1

P148: !_PREFETCH [12] (Int)
prefetch [%i3 + 0], 1

P149: !_REPLACEMENT [13] (Int)
sethi %hi(0x40), %l3
or %l3, %lo(0x40),  %l3
sethi %hi(0x10000), %l6
or %l6, %lo(0x10000),  %l6
add %i3, %l3, %l3
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]

P150: !_DWLD [13] (FP)
ldd [%i3 + 64], %f18
! 1 addresses covered
fmovs %f18, %f9

P151: !_REPLACEMENT [2] (Int)
sethi %hi(0xc), %o5
or %o5, %lo(0xc),  %o5
sethi %hi(0x10000), %l3
or %l3, %lo(0x10000),  %l3
add %i3, %o5, %o5
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]

P152: !_ST [5] (maybe <- 0x3f80002a) (FP) (CBR)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i1 + 76 ]

! cbranch
andcc %l0, 1, %g0
be,pt  %xcc, TARGET152
nop
RET152:

! lfsr step begin
srlx %l0, 1, %l6
xnor %l6, %l0, %l6
sllx %l6, 63, %l6
or  %l6, %l0, %l0
srlx %l0, 1, %l0


P153: !_LD [10] (FP)
ld [%i2 + 32], %f10
! 1 addresses covered

P154: !_CAS [7] (maybe <- 0x16) (Int)
add %i1, 84, %o5
lduw [%o5], %l6
mov %l6, %l7
! move %l7(lower) -> %o2(lower)
or %l7, %o2, %o2
mov %l4, %o3
cas [%o5], %l7, %o3
! move %o3(lower) -> %o3(upper)
sllx %o3, 32, %o3
add   %l4, 1, %l4

P155: !_REPLACEMENT [7] (Int) (Branch target of P218)
sethi %hi(0x54), %l7
or %l7, %lo(0x54),  %l7
sethi %hi(0x10000), %o5
or %o5, %lo(0x10000),  %o5
add %i3, %l7, %l7
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]
ba P156
nop

TARGET218:
ba RET218
nop


P156: !_CASX [0] (maybe <- 0x17) (Int)
add %i0, 0, %l7
ldx [%l7], %l3
! move %l3(upper) -> %o3(lower)
srlx %l3, 32, %l6
or %l6, %o3, %o3
! move %l3(lower) -> %o4(upper)
sllx %l3, 32, %o4
mov %l3, %l6
sllx %l4, 32, %l3
add  %l4, 1, %l4
or   %l4, %l3, %l3
casx [%l7], %l6, %l3
! move %l3(upper) -> %o4(lower)
srlx %l3, 32, %l7
or %l7, %o4, %o4
!---- flushing int results buffer----
mov %o0, %l5
mov %o1, %l5
mov %o2, %l5
mov %o3, %l5
mov %o4, %l5
! move %l3(lower) -> %o0(upper)
sllx %l3, 32, %o0
add  %l4, 1, %l4

P157: !_PREFETCH [14] (Int)
prefetch [%i3 + 128], 1

P158: !_PREFETCH [6] (Int) (LE)
wr %g0, 0x88, %asi
prefetcha [%i1 + 80] %asi, 1

P159: !_SWAP [3] (maybe <- 0x19) (Int)
mov %l4, %o5
swap  [%i0 + 32], %o5
! move %o5(lower) -> %o0(lower)
srl %o5, 0, %l6
or %l6, %o0, %o0
add   %l4, 1, %l4

P160: !_PREFETCH [15] (Int)
prefetch [%i3 + 192], 1

P161: !_ST [12] (maybe <- 0x3f80002b) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i3 + 0 ]

P162: !_REPLACEMENT [13] (Int)
sethi %hi(0x40), %o5
or %o5, %lo(0x40),  %o5
sethi %hi(0x10000), %l3
or %l3, %lo(0x10000),  %l3
add %i3, %o5, %o5
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]

P163: !_ST [9] (maybe <- 0x3f80002c) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i1 + 512 ]

P164: !_REPLACEMENT [7] (Int)
sethi %hi(0x54), %l6
or %l6, %lo(0x54),  %l6
sethi %hi(0x10000), %l7
or %l7, %lo(0x10000),  %l7
add %i3, %l6, %l6
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]

P165: !_PREFETCH [9] (Int)
prefetch [%i1 + 512], 1

P166: !_DWLD [6] (FP)
ldd [%i1 + 80], %f18
! 2 addresses covered
fmovs %f18, %f11
fmovs %f19, %f12

P167: !_CASX [10] (maybe <- 0x1a) (Int)
add %i2, 32, %l6
ldx [%l6], %o1
! move %o1(upper) -> %o1(upper)
! move %o1(lower) -> %o1(lower)
mov  %o1, %l3
sllx %l4, 32, %o2
casx [%l6], %l3, %o2
! move %o2(upper) -> %o2(upper)
! move %o2(lower) -> %o2(lower)
add  %l4, 1, %l4

P168: !_CASX [12] (maybe <- 0x1b) (Int)
add %i3, 0, %l6
ldx [%l6], %o3
! move %o3(upper) -> %o3(upper)
! move %o3(lower) -> %o3(lower)
mov  %o3, %l3
sllx %l4, 32, %o4
casx [%l6], %l3, %o4
! move %o4(upper) -> %o4(upper)
! move %o4(lower) -> %o4(lower)
!---- flushing int results buffer----
mov %o0, %l5
mov %o1, %l5
mov %o2, %l5
mov %o3, %l5
mov %o4, %l5
add  %l4, 1, %l4

P169: !_LD [0] (FP)
ld [%i0 + 0], %f13
! 1 addresses covered

P170: !_REPLACEMENT [6] (Int)
sethi %hi(0x50), %l3
or %l3, %lo(0x50),  %l3
sethi %hi(0x10000), %l6
or %l6, %lo(0x10000),  %l6
add %i3, %l3, %l3
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]

P171: !_LD [13] (FP)
ld [%i3 + 64], %f14
! 1 addresses covered

P172: !_MEMBAR (Int)
membar #StoreLoad

P173: !_LD [5] (FP) (CBR)
ld [%i1 + 76], %f15
! 1 addresses covered
!---- flushing fp results buffer to %f30 ----
fmovd %f0, %f30
fmovd %f2, %f30
fmovd %f4, %f30
fmovd %f6, %f30
fmovd %f8, %f30
fmovd %f10, %f30
fmovd %f12, %f30
fmovd %f14, %f30

! cbranch
andcc %l0, 1, %g0
be,pn  %xcc, TARGET173
nop
RET173:

! lfsr step begin
srlx %l0, 1, %o5
xnor %o5, %l0, %o5
sllx %o5, 63, %o5
or  %o5, %l0, %l0
srlx %l0, 1, %l0


P174: !_PREFETCH [10] (Int)
prefetch [%i2 + 32], 1

P175: !_CASX [3] (maybe <- 0x1c) (Int)
add %i0, 32, %l6
ldx [%l6], %o0
! move %o0(upper) -> %o0(upper)
! move %o0(lower) -> %o0(lower)
mov  %o0, %l3
sllx %l4, 32, %o1
casx [%l6], %l3, %o1
! move %o1(upper) -> %o1(upper)
! move %o1(lower) -> %o1(lower)
add  %l4, 1, %l4

P176: !_ST [4] (maybe <- 0x3f80002d) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i0 + 64 ]

P177: !_DWLD [13] (FP) (Branch target of P447)
ldd [%i3 + 64], %f0
! 1 addresses covered
ba P178
nop

TARGET447:
ba RET447
nop


P178: !_ST [12] (maybe <- 0x3f80002e) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i3 + 0 ]

P179: !_MEMBAR (Int)
membar #StoreLoad

P180: !_DWLD [14] (FP)
ldd [%i3 + 128], %f18
! 1 addresses covered
fmovs %f18, %f1

P181: !_SWAP [8] (maybe <- 0x1d) (Int)
mov %l4, %o2
swap  [%i1 + 256], %o2
! move %o2(lower) -> %o2(upper)
sllx %o2, 32, %o2
add   %l4, 1, %l4

P182: !_PREFETCH [14] (Int)
prefetch [%i3 + 128], 1

P183: !_REPLACEMENT [2] (Int)
sethi %hi(0xc), %l6
or %l6, %lo(0xc),  %l6
sethi %hi(0x10000), %l7
or %l7, %lo(0x10000),  %l7
add %i3, %l6, %l6
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]

P184: !_DWLD [4] (FP) (CBR)
ldd [%i0 + 64], %f2
! 1 addresses covered

! cbranch
andcc %l0, 1, %g0
be,pn  %xcc, TARGET184
nop
RET184:

! lfsr step begin
srlx %l0, 1, %l3
xnor %l3, %l0, %l3
sllx %l3, 63, %l3
or  %l3, %l0, %l0
srlx %l0, 1, %l0


P185: !_CASX [15] (maybe <- 0x1e) (Int) (Branch target of P11)
add %i3, 192, %l7
ldx [%l7], %l3
! move %l3(upper) -> %o2(lower)
srlx %l3, 32, %l6
or %l6, %o2, %o2
! move %l3(lower) -> %o3(upper)
sllx %l3, 32, %o3
mov  %l3, %l6
sllx %l4, 32, %l3
casx [%l7], %l6, %l3
! move %l3(upper) -> %o3(lower)
srlx %l3, 32, %l7
or %l7, %o3, %o3
! move %l3(lower) -> %o4(upper)
sllx %l3, 32, %o4
add  %l4, 1, %l4
ba P186
nop

TARGET11:
ba RET11
nop


P186: !_LD [10] (FP)
ld [%i2 + 32], %f3
! 1 addresses covered

P187: !_CASX [13] (maybe <- 0x1f) (Int)
add %i3, 64, %l7
ldx [%l7], %l3
! move %l3(upper) -> %o4(lower)
srlx %l3, 32, %l6
or %l6, %o4, %o4
!---- flushing int results buffer----
mov %o0, %l5
mov %o1, %l5
mov %o2, %l5
mov %o3, %l5
mov %o4, %l5
! move %l3(lower) -> %o0(upper)
sllx %l3, 32, %o0
mov  %l3, %l6
sllx %l4, 32, %l3
casx [%l7], %l6, %l3
! move %l3(upper) -> %o0(lower)
srlx %l3, 32, %l7
or %l7, %o0, %o0
! move %l3(lower) -> %o1(upper)
sllx %l3, 32, %o1
add  %l4, 1, %l4

P188: !_DWLD [10] (FP)
ldd [%i2 + 32], %f4
! 1 addresses covered

P189: !_PREFETCH [0] (Int)
prefetch [%i0 + 0], 1

P190: !_SWAP [8] (maybe <- 0x20) (Int) (CBR)
mov %l4, %o5
swap  [%i1 + 256], %o5
! move %o5(lower) -> %o1(lower)
srl %o5, 0, %l6
or %l6, %o1, %o1
add   %l4, 1, %l4

! cbranch
andcc %l0, 1, %g0
be,pn  %xcc, TARGET190
nop
RET190:

! lfsr step begin
srlx %l0, 1, %l3
xnor %l3, %l0, %l3
sllx %l3, 63, %l3
or  %l3, %l0, %l0
srlx %l0, 1, %l0


P191: !_DWST [4] (maybe <- 0x3f80002f) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
std %f20, [%i0 + 64]

P192: !_LD [5] (FP) (Branch target of P865)
ld [%i1 + 76], %f5
! 1 addresses covered
ba P193
nop

TARGET865:
ba RET865
nop


P193: !_MEMBAR (Int)
membar #StoreLoad

P194: !_CAS [4] (maybe <- 0x21) (Int)
add %i0, 64, %l6
lduw [%l6], %o2
mov %o2, %l3
! move %l3(lower) -> %o2(upper)
sllx %l3, 32, %o2
mov %l4, %o5
cas [%l6], %l3, %o5
! move %o5(lower) -> %o2(lower)
srl %o5, 0, %l6
or %l6, %o2, %o2
add   %l4, 1, %l4

P195: !_LD [13] (FP)
ld [%i3 + 64], %f6
! 1 addresses covered

P196: !_PREFETCH [7] (Int)
prefetch [%i1 + 84], 1

P197: !_DWST [12] (maybe <- 0x3f800030) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
std %f20, [%i3 + 0]

P198: !_LD [9] (FP)
ld [%i1 + 512], %f7
! 1 addresses covered

P199: !_REPLACEMENT [11] (Int)
sethi %hi(0x40), %o5
or %o5, %lo(0x40),  %o5
sethi %hi(0x10000), %l3
or %l3, %lo(0x10000),  %l3
add %i3, %o5, %o5
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]

P200: !_PREFETCH [10] (Int)
prefetch [%i2 + 32], 1

P201: !_REPLACEMENT [1] (Int)
sethi %hi(0x4), %l7
or %l7, %lo(0x4),  %l7
sethi %hi(0x10000), %o5
or %o5, %lo(0x10000),  %o5
add %i3, %l7, %l7
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]

P202: !_PREFETCH [14] (Int)
prefetch [%i3 + 128], 1

P203: !_REPLACEMENT [4] (Int) (Branch target of P668)
sethi %hi(0x40), %l6
or %l6, %lo(0x40),  %l6
sethi %hi(0x10000), %l7
or %l7, %lo(0x10000),  %l7
add %i3, %l6, %l6
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
ba P204
nop

TARGET668:
ba RET668
nop


P204: !_PREFETCH [12] (Int)
prefetch [%i3 + 0], 1

P205: !_DWLD [9] (FP)
ldd [%i1 + 512], %f8
! 1 addresses covered

P206: !_REPLACEMENT [4] (Int)
sethi %hi(0x40), %l3
or %l3, %lo(0x40),  %l3
sethi %hi(0x10000), %l6
or %l6, %lo(0x10000),  %l6
add %i3, %l3, %l3
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]

P207: !_DWST [13] (maybe <- 0x3f800031) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
std %f20, [%i3 + 64]

P208: !_MEMBAR (Int)
membar #StoreLoad

P209: !_DWST [6] (maybe <- 0x3f800032) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
! 1 th moved, current_fp_src=21 
fmovs  %f16, %f21
fadds  %f16, %f17, %f16
std %f20, [%i1 + 80]

P210: !_PREFETCH [4] (Int)
prefetch [%i0 + 64], 1

P211: !_REPLACEMENT [2] (Int)
sethi %hi(0xc), %l6
or %l6, %lo(0xc),  %l6
sethi %hi(0x10000), %l7
or %l7, %lo(0x10000),  %l7
add %i3, %l6, %l6
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]

P212: !_DWST [1] (maybe <- 0x3f800034) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
! 1 th moved, current_fp_src=21 
fmovs  %f16, %f21
fadds  %f16, %f17, %f16
std %f20, [%i0 + 0]

P213: !_DWLD [13] (FP)
ldd [%i3 + 64], %f18
! 1 addresses covered
fmovs %f18, %f9

P214: !_PREFETCH [15] (Int)
prefetch [%i3 + 192], 1

P215: !_LD [10] (FP)
ld [%i2 + 32], %f10
! 1 addresses covered

P216: !_DWST [4] (maybe <- 0x3f800036) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
std %f20, [%i0 + 64]

P217: !_CAS [9] (maybe <- 0x22) (Int)
add %i1, 512, %o5
lduw [%o5], %o3
mov %o3, %l7
! move %l7(lower) -> %o3(upper)
sllx %l7, 32, %o3
mov %l4, %l6
cas [%o5], %l7, %l6
! move %l6(lower) -> %o3(lower)
srl %l6, 0, %o5
or %o5, %o3, %o3
add   %l4, 1, %l4

P218: !_PREFETCH [13] (Int) (CBR)
prefetch [%i3 + 64], 1

! cbranch
andcc %l0, 1, %g0
be,pt  %xcc, TARGET218
nop
RET218:

! lfsr step begin
srlx %l0, 1, %l7
xnor %l7, %l0, %l7
sllx %l7, 63, %l7
or  %l7, %l0, %l0
srlx %l0, 1, %l0


P219: !_DWST [14] (maybe <- 0x3f800037) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
std %f20, [%i3 + 128]

P220: !_REPLACEMENT [10] (Int)
sethi %hi(0x20), %l7
or %l7, %lo(0x20),  %l7
sethi %hi(0x10000), %o5
or %o5, %lo(0x10000),  %o5
add %i3, %l7, %l7
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]

P221: !_PREFETCH [13] (Int)
prefetch [%i3 + 64], 1

P222: !_DWLD [15] (FP)
ldd [%i3 + 192], %f18
! 1 addresses covered
fmovs %f18, %f11

P223: !_CAS [6] (maybe <- 0x23) (Int)
add %i1, 80, %l7
lduw [%l7], %o4
mov %o4, %l6
! move %l6(lower) -> %o4(upper)
sllx %l6, 32, %o4
mov %l4, %l3
cas [%l7], %l6, %l3
! move %l3(lower) -> %o4(lower)
srl %l3, 0, %l7
or %l7, %o4, %o4
!---- flushing int results buffer----
mov %o0, %l5
mov %o1, %l5
mov %o2, %l5
mov %o3, %l5
mov %o4, %l5
add   %l4, 1, %l4

P224: !_REPLACEMENT [11] (Int)
sethi %hi(0x40), %l6
or %l6, %lo(0x40),  %l6
sethi %hi(0x10000), %l7
or %l7, %lo(0x10000),  %l7
add %i3, %l6, %l6
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]

P225: !_PREFETCH [15] (Int)
prefetch [%i3 + 192], 1

P226: !_LD [8] (FP)
ld [%i1 + 256], %f12
! 1 addresses covered

P227: !_LD [10] (FP)
ld [%i2 + 32], %f13
! 1 addresses covered

P228: !_PREFETCH [7] (Int) (CBR)
prefetch [%i1 + 84], 1

! cbranch
andcc %l0, 1, %g0
be,pt  %xcc, TARGET228
nop
RET228:

! lfsr step begin
srlx %l0, 1, %l3
xnor %l3, %l0, %l3
sllx %l3, 63, %l3
or  %l3, %l0, %l0
srlx %l0, 1, %l0


P229: !_REPLACEMENT [4] (Int)
sethi %hi(0x40), %l6
or %l6, %lo(0x40),  %l6
sethi %hi(0x10000), %l7
or %l7, %lo(0x10000),  %l7
add %i3, %l6, %l6
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]

P230: !_LD [0] (FP)
ld [%i0 + 0], %f14
! 1 addresses covered

P231: !_LD [3] (FP)
ld [%i0 + 32], %f15
! 1 addresses covered
!---- flushing fp results buffer to %f30 ----
fmovd %f0, %f30
fmovd %f2, %f30
fmovd %f4, %f30
fmovd %f6, %f30
fmovd %f8, %f30
fmovd %f10, %f30
fmovd %f12, %f30
fmovd %f14, %f30

P232: !_DWST [1] (maybe <- 0x3f800038) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
! 1 th moved, current_fp_src=21 
fmovs  %f16, %f21
fadds  %f16, %f17, %f16
std %f20, [%i0 + 0]

P233: !_REPLACEMENT [10] (Int)
sethi %hi(0x20), %o5
or %o5, %lo(0x20),  %o5
sethi %hi(0x10000), %l3
or %l3, %lo(0x10000),  %l3
add %i3, %o5, %o5
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]

P234: !_PREFETCH [9] (Int)
prefetch [%i1 + 512], 1

P235: !_DWST [6] (maybe <- 0x3f80003a) (FP) (Branch target of P921)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
! 1 th moved, current_fp_src=21 
fmovs  %f16, %f21
fadds  %f16, %f17, %f16
std %f20, [%i1 + 80]
ba P236
nop

TARGET921:
ba RET921
nop


P236: !_REPLACEMENT [2] (Int)
sethi %hi(0xc), %l6
or %l6, %lo(0xc),  %l6
sethi %hi(0x10000), %l7
or %l7, %lo(0x10000),  %l7
add %i3, %l6, %l6
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]

P237: !_REPLACEMENT [5] (Int)
sethi %hi(0x4c), %l3
or %l3, %lo(0x4c),  %l3
sethi %hi(0x10000), %l6
or %l6, %lo(0x10000),  %l6
add %i3, %l3, %l3
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]

P238: !_PREFETCH [12] (Int) (LE)
wr %g0, 0x88, %asi
prefetcha [%i3 + 0] %asi, 1

P239: !_REPLACEMENT [13] (Int)
sethi %hi(0x40), %o5
or %o5, %lo(0x40),  %o5
sethi %hi(0x10000), %l3
or %l3, %lo(0x10000),  %l3
add %i3, %o5, %o5
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]

P240: !_CAS [4] (maybe <- 0x24) (Int)
add %i0, 64, %o5
lduw [%o5], %o0
mov %o0, %l7
! move %l7(lower) -> %o0(upper)
sllx %l7, 32, %o0
mov %l4, %l6
cas [%o5], %l7, %l6
! move %l6(lower) -> %o0(lower)
srl %l6, 0, %o5
or %o5, %o0, %o0
add   %l4, 1, %l4

P241: !_LD [13] (FP)
ld [%i3 + 64], %f0
! 1 addresses covered

P242: !_CAS [10] (maybe <- 0x25) (Int)
add %i2, 32, %o5
lduw [%o5], %o1
mov %o1, %l7
! move %l7(lower) -> %o1(upper)
sllx %l7, 32, %o1
mov %l4, %l6
cas [%o5], %l7, %l6
! move %l6(lower) -> %o1(lower)
srl %l6, 0, %o5
or %o5, %o1, %o1
add   %l4, 1, %l4

P243: !_DWST [12] (maybe <- 0x3f80003c) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
std %f20, [%i3 + 0]

P244: !_ST [4] (maybe <- 0x3f80003d) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i0 + 64 ]

P245: !_ST [9] (maybe <- 0x3f80003e) (FP) (Branch target of P1003)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i1 + 512 ]
ba P246
nop

TARGET1003:
ba RET1003
nop


P246: !_PREFETCH [8] (Int)
prefetch [%i1 + 256], 1

P247: !_NOP (Int)
nop

P248: !_ST [9] (maybe <- 0x3f80003f) (FP) (CBR)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i1 + 512 ]

! cbranch
andcc %l0, 1, %g0
be,pn  %xcc, TARGET248
nop
RET248:

! lfsr step begin
srlx %l0, 1, %l7
xnor %l7, %l0, %l7
sllx %l7, 63, %l7
or  %l7, %l0, %l0
srlx %l0, 1, %l0


P249: !_ST [0] (maybe <- 0x3f800040) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i0 + 0 ]

P250: !_ST [6] (maybe <- 0x3f800041) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i1 + 80 ]

P251: !_REPLACEMENT [0] (Int)
sethi %hi(0x0), %l6
or %l6, %lo(0x0),  %l6
sethi %hi(0x10000), %l7
or %l7, %lo(0x10000),  %l7
add %i3, %l6, %l6
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]

P252: !_CAS [14] (maybe <- 0x26) (Int)
add %i3, 128, %l6
lduw [%l6], %o2
mov %o2, %l3
! move %l3(lower) -> %o2(upper)
sllx %l3, 32, %o2
mov %l4, %o5
cas [%l6], %l3, %o5
! move %o5(lower) -> %o2(lower)
srl %o5, 0, %l6
or %l6, %o2, %o2
add   %l4, 1, %l4

P253: !_DWLD [1] (FP)
ldd [%i0 + 0], %f18
! 2 addresses covered
fmovs %f18, %f1
fmovs %f19, %f2

P254: !_REPLACEMENT [4] (Int)
sethi %hi(0x40), %l3
or %l3, %lo(0x40),  %l3
sethi %hi(0x10000), %l6
or %l6, %lo(0x10000),  %l6
add %i3, %l3, %l3
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]

P255: !_REPLACEMENT [13] (Int)
sethi %hi(0x40), %o5
or %o5, %lo(0x40),  %o5
sethi %hi(0x10000), %l3
or %l3, %lo(0x10000),  %l3
add %i3, %o5, %o5
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]

P256: !_DWLD [15] (FP)
ldd [%i3 + 192], %f18
! 1 addresses covered
fmovs %f18, %f3

P257: !_ST [4] (maybe <- 0x3f800042) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i0 + 64 ]

P258: !_ST [1] (maybe <- 0x3f800043) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i0 + 4 ]

P259: !_PREFETCH [0] (Int)
prefetch [%i0 + 0], 1

P260: !_CASX [4] (maybe <- 0x27) (Int)
add %i0, 64, %l6
ldx [%l6], %o3
! move %o3(upper) -> %o3(upper)
! move %o3(lower) -> %o3(lower)
mov  %o3, %l3
sllx %l4, 32, %o4
casx [%l6], %l3, %o4
! move %o4(upper) -> %o4(upper)
! move %o4(lower) -> %o4(lower)
!---- flushing int results buffer----
mov %o0, %l5
mov %o1, %l5
mov %o2, %l5
mov %o3, %l5
mov %o4, %l5
add  %l4, 1, %l4

P261: !_DWST [2] (maybe <- 0x3f800044) (FP)
! 0 th moved, current_fp_src=21 
fmovs  %f16, %f21
fadds  %f16, %f17, %f16
std %f20, [%i0 + 8]

P262: !_SWAP [9] (maybe <- 0x28) (Int)
mov %l4, %o0
swap  [%i1 + 512], %o0
! move %o0(lower) -> %o0(upper)
sllx %o0, 32, %o0
add   %l4, 1, %l4

P263: !_PREFETCH [4] (Int)
prefetch [%i0 + 64], 1

P264: !_PREFETCH [6] (Int)
prefetch [%i1 + 80], 1

P265: !_ST [3] (maybe <- 0x3f800045) (FP) (CBR) (Branch target of P880)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i0 + 32 ]

! cbranch
andcc %l0, 1, %g0
be,pt  %xcc, TARGET265
nop
RET265:

! lfsr step begin
srlx %l0, 1, %l6
xnor %l6, %l0, %l6
sllx %l6, 63, %l6
or  %l6, %l0, %l0
srlx %l0, 1, %l0

ba P266
nop

TARGET880:
ba RET880
nop


P266: !_CAS [15] (maybe <- 0x29) (Int)
add %i3, 192, %o5
lduw [%o5], %l6
mov %l6, %l7
! move %l7(lower) -> %o0(lower)
or %l7, %o0, %o0
mov %l4, %o1
cas [%o5], %l7, %o1
! move %o1(lower) -> %o1(upper)
sllx %o1, 32, %o1
add   %l4, 1, %l4

P267: !_LD [8] (FP)
ld [%i1 + 256], %f4
! 1 addresses covered

P268: !_REPLACEMENT [12] (Int)
sethi %hi(0x0), %l7
or %l7, %lo(0x0),  %l7
sethi %hi(0x10000), %o5
or %o5, %lo(0x10000),  %o5
add %i3, %l7, %l7
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]

P269: !_DWLD [1] (FP)
ldd [%i0 + 0], %f18
! 2 addresses covered
fmovs %f18, %f5
fmovs %f19, %f6

P270: !_DWLD [13] (FP)
ldd [%i3 + 64], %f18
! 1 addresses covered
fmovs %f18, %f7

P271: !_REPLACEMENT [15] (Int)
sethi %hi(0xc0), %l6
or %l6, %lo(0xc0),  %l6
sethi %hi(0x10000), %l7
or %l7, %lo(0x10000),  %l7
add %i3, %l6, %l6
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]

P272: !_CASX [13] (maybe <- 0x2a) (Int)
add %i3, 64, %l6
ldx [%l6], %o5
! move %o5(upper) -> %o1(lower)
srlx %o5, 32, %l3
or %l3, %o1, %o1
! move %o5(lower) -> %o2(upper)
sllx %o5, 32, %o2
mov  %o5, %l3
sllx %l4, 32, %o5
casx [%l6], %l3, %o5
! move %o5(upper) -> %o2(lower)
srlx %o5, 32, %l6
or %l6, %o2, %o2
! move %o5(lower) -> %o3(upper)
sllx %o5, 32, %o3
add  %l4, 1, %l4

P273: !_DWLD [11] (FP)
ldd [%i2 + 64], %f8
! 1 addresses covered

P274: !_ST [4] (maybe <- 0x3f800046) (FP) (Branch target of P770)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i0 + 64 ]
ba P275
nop

TARGET770:
ba RET770
nop


P275: !_DWST [6] (maybe <- 0x3f800047) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
! 1 th moved, current_fp_src=21 
fmovs  %f16, %f21
fadds  %f16, %f17, %f16
std %f20, [%i1 + 80]

P276: !_LD [13] (FP)
ld [%i3 + 64], %f9
! 1 addresses covered

P277: !_DWST [11] (maybe <- 0x3f800049) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
std %f20, [%i2 + 64]

P278: !_ST [10] (maybe <- 0x3f80004a) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i2 + 32 ]

P279: !_DWLD [7] (FP)
ldd [%i1 + 80], %f10
! 2 addresses covered

P280: !_REPLACEMENT [8] (Int)
sethi %hi(0x100), %l3
or %l3, %lo(0x100),  %l3
sethi %hi(0x10000), %l6
or %l6, %lo(0x10000),  %l6
add %i3, %l3, %l3
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]

P281: !_REPLACEMENT [9] (Int)
sethi %hi(0x200), %o5
or %o5, %lo(0x200),  %o5
sethi %hi(0x10000), %l3
or %l3, %lo(0x10000),  %l3
add %i3, %o5, %o5
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]

P282: !_LD [2] (FP)
ld [%i0 + 12], %f12
! 1 addresses covered

P283: !_SWAP [9] (maybe <- 0x2b) (Int)
mov %l4, %l3
swap  [%i1 + 512], %l3
! move %l3(lower) -> %o3(lower)
srl %l3, 0, %l7
or %l7, %o3, %o3
add   %l4, 1, %l4

P284: !_REPLACEMENT [12] (Int)
sethi %hi(0x0), %l6
or %l6, %lo(0x0),  %l6
sethi %hi(0x10000), %l7
or %l7, %lo(0x10000),  %l7
add %i3, %l6, %l6
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]

P285: !_LD [11] (FP)
ld [%i2 + 64], %f13
! 1 addresses covered

P286: !_DWLD [3] (FP)
ldd [%i0 + 32], %f14
! 1 addresses covered

P287: !_CASX [0] (maybe <- 0x2c) (Int) (CBR)
add %i0, 0, %l6
ldx [%l6], %o4
! move %o4(upper) -> %o4(upper)
! move %o4(lower) -> %o4(lower)
!---- flushing int results buffer----
mov %o0, %l5
mov %o1, %l5
mov %o2, %l5
mov %o3, %l5
mov %o4, %l5
mov %o4, %l3
sllx %l4, 32, %o0
add  %l4, 1, %l4
or   %l4, %o0, %o0
casx [%l6], %l3, %o0
! move %o0(upper) -> %o0(upper)
! move %o0(lower) -> %o0(lower)
add  %l4, 1, %l4

! cbranch
andcc %l0, 1, %g0
be,pn  %xcc, TARGET287
nop
RET287:

! lfsr step begin
srlx %l0, 1, %l3
xnor %l3, %l0, %l3
sllx %l3, 63, %l3
or  %l3, %l0, %l0
srlx %l0, 1, %l0


P288: !_LD [7] (FP)
ld [%i1 + 84], %f15
! 1 addresses covered
!---- flushing fp results buffer to %f30 ----
fmovd %f0, %f30
fmovd %f2, %f30
fmovd %f4, %f30
fmovd %f6, %f30
fmovd %f8, %f30
fmovd %f10, %f30
fmovd %f12, %f30
fmovd %f14, %f30

P289: !_DWLD [12] (FP)
ldd [%i3 + 0], %f0
! 1 addresses covered

P290: !_SWAP [3] (maybe <- 0x2e) (Int)
mov %l4, %o1
swap  [%i0 + 32], %o1
! move %o1(lower) -> %o1(upper)
sllx %o1, 32, %o1
add   %l4, 1, %l4

P291: !_CAS [15] (maybe <- 0x2f) (Int)
add %i3, 192, %l6
lduw [%l6], %o5
mov %o5, %l3
! move %l3(lower) -> %o1(lower)
or %l3, %o1, %o1
mov %l4, %o2
cas [%l6], %l3, %o2
! move %o2(lower) -> %o2(upper)
sllx %o2, 32, %o2
add   %l4, 1, %l4

P292: !_DWST [15] (maybe <- 0x3f80004b) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
std %f20, [%i3 + 192]

P293: !_DWST [2] (maybe <- 0x3f80004c) (FP)
! 0 th moved, current_fp_src=21 
fmovs  %f16, %f21
fadds  %f16, %f17, %f16
std %f20, [%i0 + 8]

P294: !_ST [1] (maybe <- 0x3f80004d) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i0 + 4 ]

P295: !_LD [8] (FP)
ld [%i1 + 256], %f1
! 1 addresses covered

P296: !_NOP (Int)
nop

P297: !_LD [2] (FP)
ld [%i0 + 12], %f2
! 1 addresses covered

P298: !_REPLACEMENT [8] (Int)
sethi %hi(0x100), %l6
or %l6, %lo(0x100),  %l6
sethi %hi(0x10000), %l7
or %l7, %lo(0x10000),  %l7
add %i3, %l6, %l6
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]

P299: !_DWLD [1] (FP)
ldd [%i0 + 0], %f18
! 2 addresses covered
fmovs %f18, %f3
fmovs %f19, %f4

P300: !_DWLD [10] (FP)
ldd [%i2 + 32], %f18
! 1 addresses covered
fmovs %f18, %f5

P301: !_ST [9] (maybe <- 0x3f80004e) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i1 + 512 ]

P302: !_REPLACEMENT [6] (Int)
sethi %hi(0x50), %o5
or %o5, %lo(0x50),  %o5
sethi %hi(0x10000), %l3
or %l3, %lo(0x10000),  %l3
add %i3, %o5, %o5
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]

P303: !_DWST [5] (maybe <- 0x3f80004f) (FP)
! 0 th moved, current_fp_src=21 
fmovs  %f16, %f21
fadds  %f16, %f17, %f16
std %f20, [%i1 + 72]

P304: !_LD [3] (FP)
ld [%i0 + 32], %f6
! 1 addresses covered

P305: !_REPLACEMENT [13] (Int)
sethi %hi(0x40), %l6
or %l6, %lo(0x40),  %l6
sethi %hi(0x10000), %l7
or %l7, %lo(0x10000),  %l7
add %i3, %l6, %l6
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]

P306: !_DWLD [14] (FP)
ldd [%i3 + 128], %f18
! 1 addresses covered
fmovs %f18, %f7

P307: !_MEMBAR (Int)
membar #StoreLoad

P308: !_REPLACEMENT [8] (Int)
sethi %hi(0x100), %l3
or %l3, %lo(0x100),  %l3
sethi %hi(0x10000), %l6
or %l6, %lo(0x10000),  %l6
add %i3, %l3, %l3
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]

P309: !_NOP (Int)
nop

P310: !_LD [1] (FP)
ld [%i0 + 4], %f8
! 1 addresses covered

P311: !_ST [8] (maybe <- 0x3f800050) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i1 + 256 ]

P312: !_ST [2] (maybe <- 0x3f800051) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i0 + 12 ]

P313: !_DWST [8] (maybe <- 0x3f800052) (FP) (CBR)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
std %f20, [%i1 + 256]

! cbranch
andcc %l0, 1, %g0
be,pn  %xcc, TARGET313
nop
RET313:

! lfsr step begin
srlx %l0, 1, %l3
xnor %l3, %l0, %l3
sllx %l3, 63, %l3
or  %l3, %l0, %l0
srlx %l0, 1, %l0


P314: !_SWAP [11] (maybe <- 0x30) (Int)
mov %l4, %o5
swap  [%i2 + 64], %o5
! move %o5(lower) -> %o2(lower)
srl %o5, 0, %l6
or %l6, %o2, %o2
add   %l4, 1, %l4

P315: !_CASX [15] (maybe <- 0x31) (Int)
add %i3, 192, %l6
ldx [%l6], %o3
! move %o3(upper) -> %o3(upper)
! move %o3(lower) -> %o3(lower)
mov  %o3, %l3
sllx %l4, 32, %o4
casx [%l6], %l3, %o4
! move %o4(upper) -> %o4(upper)
! move %o4(lower) -> %o4(lower)
!---- flushing int results buffer----
mov %o0, %l5
mov %o1, %l5
mov %o2, %l5
mov %o3, %l5
mov %o4, %l5
add  %l4, 1, %l4

P316: !_ST [3] (maybe <- 0x3f800053) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i0 + 32 ]

P317: !_LD [10] (FP)
ld [%i2 + 32], %f9
! 1 addresses covered

P318: !_ST [6] (maybe <- 0x3f800054) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i1 + 80 ]

P319: !_DWST [15] (maybe <- 0x3f800055) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
std %f20, [%i3 + 192]

P320: !_DWST [10] (maybe <- 0x3f800056) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
std %f20, [%i2 + 32]

P321: !_REPLACEMENT [10] (Int)
sethi %hi(0x20), %l3
or %l3, %lo(0x20),  %l3
sethi %hi(0x10000), %l6
or %l6, %lo(0x10000),  %l6
add %i3, %l3, %l3
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]

P322: !_LD [11] (FP)
ld [%i2 + 64], %f10
! 1 addresses covered

P323: !_DWST [1] (maybe <- 0x3f800057) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
! 1 th moved, current_fp_src=21 
fmovs  %f16, %f21
fadds  %f16, %f17, %f16
std %f20, [%i0 + 0]

P324: !_CAS [14] (maybe <- 0x32) (Int)
add %i3, 128, %o5
lduw [%o5], %o0
mov %o0, %l7
! move %l7(lower) -> %o0(upper)
sllx %l7, 32, %o0
mov %l4, %l6
cas [%o5], %l7, %l6
! move %l6(lower) -> %o0(lower)
srl %l6, 0, %o5
or %o5, %o0, %o0
add   %l4, 1, %l4

P325: !_REPLACEMENT [2] (Int)
sethi %hi(0xc), %l7
or %l7, %lo(0xc),  %l7
sethi %hi(0x10000), %o5
or %o5, %lo(0x10000),  %o5
add %i3, %l7, %l7
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]

P326: !_SWAP [0] (maybe <- 0x33) (Int)
mov %l4, %o1
swap  [%i0 + 0], %o1
! move %o1(lower) -> %o1(upper)
sllx %o1, 32, %o1
add   %l4, 1, %l4

P327: !_DWST [5] (maybe <- 0x3f800059) (FP)
! 0 th moved, current_fp_src=21 
fmovs  %f16, %f21
fadds  %f16, %f17, %f16
std %f20, [%i1 + 72]

P328: !_REPLACEMENT [11] (Int)
sethi %hi(0x40), %o5
or %o5, %lo(0x40),  %o5
sethi %hi(0x10000), %l3
or %l3, %lo(0x10000),  %l3
add %i3, %o5, %o5
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]

P329: !_PREFETCH [2] (Int)
prefetch [%i0 + 12], 1

P330: !_ST [6] (maybe <- 0x3f80005a) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i1 + 80 ]

P331: !_DWST [3] (maybe <- 0x3f80005b) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
std %f20, [%i0 + 32]

P332: !_LD [8] (FP)
ld [%i1 + 256], %f11
! 1 addresses covered

P333: !_REPLACEMENT [6] (Int)
sethi %hi(0x50), %l3
or %l3, %lo(0x50),  %l3
sethi %hi(0x10000), %l6
or %l6, %lo(0x10000),  %l6
add %i3, %l3, %l3
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]

P334: !_REPLACEMENT [11] (Int)
sethi %hi(0x40), %o5
or %o5, %lo(0x40),  %o5
sethi %hi(0x10000), %l3
or %l3, %lo(0x10000),  %l3
add %i3, %o5, %o5
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]

P335: !_DWST [14] (maybe <- 0x3f80005c) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
std %f20, [%i3 + 128]

P336: !_LD [13] (FP)
ld [%i3 + 64], %f12
! 1 addresses covered

P337: !_LD [14] (FP)
ld [%i3 + 128], %f13
! 1 addresses covered

P338: !_LD [4] (FP)
ld [%i0 + 64], %f14
! 1 addresses covered

P339: !_PREFETCH [10] (Int) (Branch target of P727)
prefetch [%i2 + 32], 1
ba P340
nop

TARGET727:
ba RET727
nop


P340: !_DWLD [13] (FP)
ldd [%i3 + 64], %f18
! 1 addresses covered
fmovs %f18, %f15
!---- flushing fp results buffer to %f30 ----
fmovd %f0, %f30
fmovd %f2, %f30
fmovd %f4, %f30
fmovd %f6, %f30
fmovd %f8, %f30
fmovd %f10, %f30
fmovd %f12, %f30
fmovd %f14, %f30

P341: !_REPLACEMENT [13] (Int)
sethi %hi(0x40), %l6
or %l6, %lo(0x40),  %l6
sethi %hi(0x10000), %l7
or %l7, %lo(0x10000),  %l7
add %i3, %l6, %l6
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]

P342: !_LD [4] (FP)
ld [%i0 + 64], %f0
! 1 addresses covered

P343: !_ST [8] (maybe <- 0x3f80005d) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i1 + 256 ]

P344: !_PREFETCH [5] (Int) (CBR)
prefetch [%i1 + 76], 1

! cbranch
andcc %l0, 1, %g0
be,pn  %xcc, TARGET344
nop
RET344:

! lfsr step begin
srlx %l0, 1, %o5
xnor %o5, %l0, %o5
sllx %o5, 63, %o5
or  %o5, %l0, %l0
srlx %l0, 1, %l0


P345: !_SWAP [12] (maybe <- 0x34) (Int) (CBR)
mov %l4, %l7
swap  [%i3 + 0], %l7
! move %l7(lower) -> %o1(lower)
srl %l7, 0, %l3
or %l3, %o1, %o1
add   %l4, 1, %l4

! cbranch
andcc %l0, 1, %g0
be,pt  %xcc, TARGET345
nop
RET345:

! lfsr step begin
srlx %l0, 1, %o5
xnor %o5, %l0, %o5
sllx %o5, 63, %o5
or  %o5, %l0, %l0
srlx %l0, 1, %l0


P346: !_MEMBAR (Int)
membar #StoreLoad

P347: !_CASX [8] (maybe <- 0x35) (Int)
add %i1, 256, %l6
ldx [%l6], %o2
! move %o2(upper) -> %o2(upper)
! move %o2(lower) -> %o2(lower)
mov  %o2, %l3
sllx %l4, 32, %o3
casx [%l6], %l3, %o3
! move %o3(upper) -> %o3(upper)
! move %o3(lower) -> %o3(lower)
add  %l4, 1, %l4

P348: !_DWST [9] (maybe <- 0x3f80005e) (FP) (Branch target of P922)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
std %f20, [%i1 + 512]
ba P349
nop

TARGET922:
ba RET922
nop


P349: !_LD [2] (FP)
ld [%i0 + 12], %f1
! 1 addresses covered

P350: !_REPLACEMENT [9] (Int)
sethi %hi(0x200), %o5
or %o5, %lo(0x200),  %o5
sethi %hi(0x10000), %l3
or %l3, %lo(0x10000),  %l3
add %i3, %o5, %o5
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]

P351: !_ST [0] (maybe <- 0x3f80005f) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i0 + 0 ]

P352: !_REPLACEMENT [11] (Int)
sethi %hi(0x40), %l6
or %l6, %lo(0x40),  %l6
sethi %hi(0x10000), %l7
or %l7, %lo(0x10000),  %l7
add %i3, %l6, %l6
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]

P353: !_DWLD [1] (FP)
ldd [%i0 + 0], %f2
! 2 addresses covered

P354: !_LD [4] (FP)
ld [%i0 + 64], %f4
! 1 addresses covered

P355: !_ST [5] (maybe <- 0x3f800060) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i1 + 76 ]

P356: !_REPLACEMENT [3] (Int)
sethi %hi(0x20), %o5
or %o5, %lo(0x20),  %o5
sethi %hi(0x10000), %l3
or %l3, %lo(0x10000),  %l3
add %i3, %o5, %o5
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]

P357: !_ST [10] (maybe <- 0x3f800061) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i2 + 32 ]

P358: !_ST [4] (maybe <- 0x3f800062) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i0 + 64 ]

P359: !_LD [4] (FP)
ld [%i0 + 64], %f5
! 1 addresses covered

P360: !_PREFETCH [12] (Int)
prefetch [%i3 + 0], 1

P361: !_DWST [13] (maybe <- 0x3f800063) (FP) (CBR) (Branch target of P423)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
std %f20, [%i3 + 64]

! cbranch
andcc %l0, 1, %g0
be,pn  %xcc, TARGET361
nop
RET361:

! lfsr step begin
srlx %l0, 1, %o5
xnor %o5, %l0, %o5
sllx %o5, 63, %o5
or  %o5, %l0, %l0
srlx %l0, 1, %l0

ba P362
nop

TARGET423:
ba RET423
nop


P362: !_REPLACEMENT [1] (Int)
sethi %hi(0x4), %l3
or %l3, %lo(0x4),  %l3
sethi %hi(0x10000), %l6
or %l6, %lo(0x10000),  %l6
add %i3, %l3, %l3
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]

P363: !_REPLACEMENT [4] (Int)
sethi %hi(0x40), %o5
or %o5, %lo(0x40),  %o5
sethi %hi(0x10000), %l3
or %l3, %lo(0x10000),  %l3
add %i3, %o5, %o5
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]

P364: !_LD [12] (FP)
ld [%i3 + 0], %f6
! 1 addresses covered

P365: !_DWLD [3] (FP)
ldd [%i0 + 32], %f18
! 1 addresses covered
fmovs %f18, %f7

P366: !_CASX [3] (maybe <- 0x36) (Int) (Branch target of P706)
add %i0, 32, %o5
ldx [%o5], %o4
! move %o4(upper) -> %o4(upper)
! move %o4(lower) -> %o4(lower)
!---- flushing int results buffer----
mov %o0, %l5
mov %o1, %l5
mov %o2, %l5
mov %o3, %l5
mov %o4, %l5
mov  %o4, %l7
sllx %l4, 32, %o0
casx [%o5], %l7, %o0
! move %o0(upper) -> %o0(upper)
! move %o0(lower) -> %o0(lower)
add  %l4, 1, %l4
ba P367
nop

TARGET706:
ba RET706
nop


P367: !_PREFETCH [10] (Int)
prefetch [%i2 + 32], 1

P368: !_DWLD [12] (FP)
ldd [%i3 + 0], %f8
! 1 addresses covered

P369: !_REPLACEMENT [5] (Int)
sethi %hi(0x4c), %l7
or %l7, %lo(0x4c),  %l7
sethi %hi(0x10000), %o5
or %o5, %lo(0x10000),  %o5
add %i3, %l7, %l7
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]

P370: !_SWAP [14] (maybe <- 0x37) (Int)
mov %l4, %o1
swap  [%i3 + 128], %o1
! move %o1(lower) -> %o1(upper)
sllx %o1, 32, %o1
add   %l4, 1, %l4

P371: !_PREFETCH [14] (Int) (LE)
wr %g0, 0x88, %asi
prefetcha [%i3 + 128] %asi, 1

P372: !_REPLACEMENT [9] (Int)
sethi %hi(0x200), %l3
or %l3, %lo(0x200),  %l3
sethi %hi(0x10000), %l6
or %l6, %lo(0x10000),  %l6
add %i3, %l3, %l3
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]

P373: !_PREFETCH [13] (Int)
prefetch [%i3 + 64], 1

P374: !_SWAP [7] (maybe <- 0x38) (Int)
mov %l4, %l6
swap  [%i1 + 84], %l6
! move %l6(lower) -> %o1(lower)
srl %l6, 0, %o5
or %o5, %o1, %o1
add   %l4, 1, %l4

P375: !_DWLD [14] (FP)
ldd [%i3 + 128], %f18
! 1 addresses covered
fmovs %f18, %f9

P376: !_LD [8] (FP)
ld [%i1 + 256], %f10
! 1 addresses covered

P377: !_SWAP [2] (maybe <- 0x39) (Int)
mov %l4, %o2
swap  [%i0 + 12], %o2
! move %o2(lower) -> %o2(upper)
sllx %o2, 32, %o2
add   %l4, 1, %l4

P378: !_SWAP [8] (maybe <- 0x3a) (Int)
mov %l4, %o5
swap  [%i1 + 256], %o5
! move %o5(lower) -> %o2(lower)
srl %o5, 0, %l6
or %l6, %o2, %o2
add   %l4, 1, %l4

P379: !_REPLACEMENT [8] (Int)
sethi %hi(0x100), %l3
or %l3, %lo(0x100),  %l3
sethi %hi(0x10000), %l6
or %l6, %lo(0x10000),  %l6
add %i3, %l3, %l3
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]

P380: !_DWLD [14] (FP) (CBR)
ldd [%i3 + 128], %f18
! 1 addresses covered
fmovs %f18, %f11

! cbranch
andcc %l0, 1, %g0
be,pn  %xcc, TARGET380
nop
RET380:

! lfsr step begin
srlx %l0, 1, %o5
xnor %o5, %l0, %o5
sllx %o5, 63, %o5
or  %o5, %l0, %l0
srlx %l0, 1, %l0


P381: !_DWLD [11] (FP)
ldd [%i2 + 64], %f12
! 1 addresses covered

P382: !_DWLD [5] (FP)
ldd [%i1 + 72], %f18
! 1 addresses covered
fmovs %f19, %f13

P383: !_LD [2] (FP)
ld [%i0 + 12], %f14
! 1 addresses covered

P384: !_LD [14] (FP)
ld [%i3 + 128], %f15
! 1 addresses covered
!---- flushing fp results buffer to %f30 ----
fmovd %f0, %f30
fmovd %f2, %f30
fmovd %f4, %f30
fmovd %f6, %f30
fmovd %f8, %f30
fmovd %f10, %f30
fmovd %f12, %f30
fmovd %f14, %f30

P385: !_LD [2] (FP)
ld [%i0 + 12], %f0
! 1 addresses covered

P386: !_LD [1] (FP)
ld [%i0 + 4], %f1
! 1 addresses covered

P387: !_DWLD [15] (FP)
ldd [%i3 + 192], %f2
! 1 addresses covered

P388: !_PREFETCH [15] (Int)
prefetch [%i3 + 192], 1

P389: !_SWAP [6] (maybe <- 0x3b) (Int)
mov %l4, %o3
swap  [%i1 + 80], %o3
! move %o3(lower) -> %o3(upper)
sllx %o3, 32, %o3
add   %l4, 1, %l4

P390: !_PREFETCH [7] (Int)
prefetch [%i1 + 84], 1

P391: !_DWLD [15] (FP)
ldd [%i3 + 192], %f18
! 1 addresses covered
fmovs %f18, %f3

P392: !_REPLACEMENT [3] (Int)
sethi %hi(0x20), %o5
or %o5, %lo(0x20),  %o5
sethi %hi(0x10000), %l3
or %l3, %lo(0x10000),  %l3
add %i3, %o5, %o5
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]

P393: !_DWLD [3] (FP)
ldd [%i0 + 32], %f4
! 1 addresses covered

P394: !_CASX [12] (maybe <- 0x3c) (Int)
add %i3, 0, %o5
ldx [%o5], %l6
! move %l6(upper) -> %o3(lower)
srlx %l6, 32, %l7
or %l7, %o3, %o3
! move %l6(lower) -> %o4(upper)
sllx %l6, 32, %o4
mov  %l6, %l7
sllx %l4, 32, %l6
casx [%o5], %l7, %l6
! move %l6(upper) -> %o4(lower)
srlx %l6, 32, %o5
or %o5, %o4, %o4
!---- flushing int results buffer----
mov %o0, %l5
mov %o1, %l5
mov %o2, %l5
mov %o3, %l5
mov %o4, %l5
! move %l6(lower) -> %o0(upper)
sllx %l6, 32, %o0
add  %l4, 1, %l4

P395: !_CAS [8] (maybe <- 0x3d) (Int)
add %i1, 256, %o5
lduw [%o5], %l6
mov %l6, %l7
! move %l7(lower) -> %o0(lower)
or %l7, %o0, %o0
mov %l4, %o1
cas [%o5], %l7, %o1
! move %o1(lower) -> %o1(upper)
sllx %o1, 32, %o1
add   %l4, 1, %l4

P396: !_PREFETCH [0] (Int) (LE)
wr %g0, 0x88, %asi
prefetcha [%i0 + 0] %asi, 1

P397: !_ST [0] (maybe <- 0x3f800064) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i0 + 0 ]

P398: !_ST [11] (maybe <- 0x3f800065) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i2 + 64 ]

P399: !_REPLACEMENT [5] (Int)
sethi %hi(0x4c), %l3
or %l3, %lo(0x4c),  %l3
sethi %hi(0x10000), %l6
or %l6, %lo(0x10000),  %l6
add %i3, %l3, %l3
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]

P400: !_DWLD [13] (FP)
ldd [%i3 + 64], %f18
! 1 addresses covered
fmovs %f18, %f5

P401: !_DWLD [3] (FP)
ldd [%i0 + 32], %f6
! 1 addresses covered

P402: !_PREFETCH [13] (Int)
prefetch [%i3 + 64], 1

P403: !_DWLD [9] (FP)
ldd [%i1 + 512], %f18
! 1 addresses covered
fmovs %f18, %f7

P404: !_CAS [0] (maybe <- 0x3e) (Int)
add %i0, 0, %l3
lduw [%l3], %l7
mov %l7, %o5
! move %o5(lower) -> %o1(lower)
or %o5, %o1, %o1
mov %l4, %o2
cas [%l3], %o5, %o2
! move %o2(lower) -> %o2(upper)
sllx %o2, 32, %o2
add   %l4, 1, %l4

P405: !_NOP (Int)
nop

P406: !_LD [14] (FP)
ld [%i3 + 128], %f8
! 1 addresses covered

P407: !_REPLACEMENT [0] (Int)
sethi %hi(0x0), %o5
or %o5, %lo(0x0),  %o5
sethi %hi(0x10000), %l3
or %l3, %lo(0x10000),  %l3
add %i3, %o5, %o5
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]

P408: !_REPLACEMENT [13] (Int)
sethi %hi(0x40), %l7
or %l7, %lo(0x40),  %l7
sethi %hi(0x10000), %o5
or %o5, %lo(0x10000),  %o5
add %i3, %l7, %l7
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]

P409: !_ST [2] (maybe <- 0x3f800066) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i0 + 12 ]

P410: !_ST [15] (maybe <- 0x3f800067) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i3 + 192 ]

P411: !_ST [8] (maybe <- 0x3f800068) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i1 + 256 ]

P412: !_CAS [13] (maybe <- 0x3f) (Int)
add %i3, 64, %o5
lduw [%o5], %l6
mov %l6, %l7
! move %l7(lower) -> %o2(lower)
or %l7, %o2, %o2
mov %l4, %o3
cas [%o5], %l7, %o3
! move %o3(lower) -> %o3(upper)
sllx %o3, 32, %o3
add   %l4, 1, %l4

P413: !_REPLACEMENT [14] (Int)
sethi %hi(0x80), %l7
or %l7, %lo(0x80),  %l7
sethi %hi(0x10000), %o5
or %o5, %lo(0x10000),  %o5
add %i3, %l7, %l7
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]

P414: !_MEMBAR (Int)
membar #StoreLoad

P415: !_ST [0] (maybe <- 0x3f800069) (FP) (CBR)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i0 + 0 ]

! cbranch
andcc %l0, 1, %g0
be,pn  %xcc, TARGET415
nop
RET415:

! lfsr step begin
srlx %l0, 1, %l3
xnor %l3, %l0, %l3
sllx %l3, 63, %l3
or  %l3, %l0, %l0
srlx %l0, 1, %l0


P416: !_LD [9] (FP)
ld [%i1 + 512], %f9
! 1 addresses covered

P417: !_ST [15] (maybe <- 0x3f80006a) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i3 + 192 ]

P418: !_REPLACEMENT [11] (Int)
sethi %hi(0x40), %l3
or %l3, %lo(0x40),  %l3
sethi %hi(0x10000), %l6
or %l6, %lo(0x10000),  %l6
add %i3, %l3, %l3
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]

P419: !_PREFETCH [1] (Int)
prefetch [%i0 + 4], 1

P420: !_DWST [2] (maybe <- 0x3f80006b) (FP)
! 0 th moved, current_fp_src=21 
fmovs  %f16, %f21
fadds  %f16, %f17, %f16
std %f20, [%i0 + 8]

P421: !_CAS [15] (maybe <- 0x40) (Int)
add %i3, 192, %o5
lduw [%o5], %l6
mov %l6, %l7
! move %l7(lower) -> %o3(lower)
or %l7, %o3, %o3
mov %l4, %o4
cas [%o5], %l7, %o4
! move %o4(lower) -> %o4(upper)
sllx %o4, 32, %o4
add   %l4, 1, %l4

P422: !_DWST [11] (maybe <- 0x3f80006c) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
std %f20, [%i2 + 64]

P423: !_ST [7] (maybe <- 0x3f80006d) (FP) (CBR)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i1 + 84 ]

! cbranch
andcc %l0, 1, %g0
be,pt  %xcc, TARGET423
nop
RET423:

! lfsr step begin
srlx %l0, 1, %l3
xnor %l3, %l0, %l3
sllx %l3, 63, %l3
or  %l3, %l0, %l0
srlx %l0, 1, %l0


P424: !_DWLD [3] (FP)
ldd [%i0 + 32], %f10
! 1 addresses covered

P425: !_DWLD [6] (FP)
ldd [%i1 + 80], %f18
! 2 addresses covered
fmovs %f18, %f11
fmovs %f19, %f12

P426: !_REPLACEMENT [7] (Int) (Branch target of P502)
sethi %hi(0x54), %l6
or %l6, %lo(0x54),  %l6
sethi %hi(0x10000), %l7
or %l7, %lo(0x10000),  %l7
add %i3, %l6, %l6
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
ba P427
nop

TARGET502:
ba RET502
nop


P427: !_DWLD [14] (FP)
ldd [%i3 + 128], %f18
! 1 addresses covered
fmovs %f18, %f13

P428: !_LD [0] (FP)
ld [%i0 + 0], %f14
! 1 addresses covered

P429: !_PREFETCH [1] (Int)
prefetch [%i0 + 4], 1

P430: !_ST [9] (maybe <- 0x3f80006e) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i1 + 512 ]

P431: !_SWAP [14] (maybe <- 0x41) (Int)
mov %l4, %l6
swap  [%i3 + 128], %l6
! move %l6(lower) -> %o4(lower)
srl %l6, 0, %o5
or %o5, %o4, %o4
!---- flushing int results buffer----
mov %o0, %l5
mov %o1, %l5
mov %o2, %l5
mov %o3, %l5
mov %o4, %l5
add   %l4, 1, %l4

P432: !_LD [6] (FP)
ld [%i1 + 80], %f15
! 1 addresses covered
!---- flushing fp results buffer to %f30 ----
fmovd %f0, %f30
fmovd %f2, %f30
fmovd %f4, %f30
fmovd %f6, %f30
fmovd %f8, %f30
fmovd %f10, %f30
fmovd %f12, %f30
fmovd %f14, %f30

P433: !_ST [9] (maybe <- 0x3f80006f) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i1 + 512 ]

P434: !_DWLD [0] (FP)
ldd [%i0 + 0], %f0
! 2 addresses covered

P435: !_DWST [4] (maybe <- 0x3f800070) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
std %f20, [%i0 + 64]

P436: !_PREFETCH [9] (Int)
prefetch [%i1 + 512], 1

P437: !_REPLACEMENT [0] (Int)
sethi %hi(0x0), %l3
or %l3, %lo(0x0),  %l3
sethi %hi(0x10000), %l6
or %l6, %lo(0x10000),  %l6
add %i3, %l3, %l3
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]

P438: !_DWLD [13] (FP)
ldd [%i3 + 64], %f2
! 1 addresses covered

P439: !_DWLD [6] (FP) (CBR)
ldd [%i1 + 80], %f18
! 2 addresses covered
fmovs %f18, %f3
fmovs %f19, %f4

! cbranch
andcc %l0, 1, %g0
be,pt  %xcc, TARGET439
nop
RET439:

! lfsr step begin
srlx %l0, 1, %o5
xnor %o5, %l0, %o5
sllx %o5, 63, %o5
or  %o5, %l0, %l0
srlx %l0, 1, %l0


P440: !_DWLD [8] (FP)
ldd [%i1 + 256], %f18
! 1 addresses covered
fmovs %f18, %f5

P441: !_PREFETCH [3] (Int)
prefetch [%i0 + 32], 1

P442: !_DWLD [8] (FP)
ldd [%i1 + 256], %f6
! 1 addresses covered

P443: !_LD [9] (FP)
ld [%i1 + 512], %f7
! 1 addresses covered

P444: !_REPLACEMENT [14] (Int)
sethi %hi(0x80), %l3
or %l3, %lo(0x80),  %l3
sethi %hi(0x10000), %l6
or %l6, %lo(0x10000),  %l6
add %i3, %l3, %l3
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]

P445: !_CAS [7] (maybe <- 0x42) (Int)
add %i1, 84, %l3
lduw [%l3], %o0
mov %o0, %o5
! move %o5(lower) -> %o0(upper)
sllx %o5, 32, %o0
mov %l4, %l7
cas [%l3], %o5, %l7
! move %l7(lower) -> %o0(lower)
srl %l7, 0, %l3
or %l3, %o0, %o0
add   %l4, 1, %l4

P446: !_LD [8] (FP)
ld [%i1 + 256], %f8
! 1 addresses covered

P447: !_REPLACEMENT [11] (Int) (CBR)
sethi %hi(0x40), %o5
or %o5, %lo(0x40),  %o5
sethi %hi(0x10000), %l3
or %l3, %lo(0x10000),  %l3
add %i3, %o5, %o5
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]

! cbranch
andcc %l0, 1, %g0
be,pn  %xcc, TARGET447
nop
RET447:

! lfsr step begin
srlx %l0, 1, %l7
xnor %l7, %l0, %l7
sllx %l7, 63, %l7
or  %l7, %l0, %l0
srlx %l0, 1, %l0


P448: !_ST [7] (maybe <- 0x3f800071) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i1 + 84 ]

P449: !_ST [13] (maybe <- 0x3f800072) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i3 + 64 ]

P450: !_REPLACEMENT [5] (Int)
sethi %hi(0x4c), %l6
or %l6, %lo(0x4c),  %l6
sethi %hi(0x10000), %l7
or %l7, %lo(0x10000),  %l7
add %i3, %l6, %l6
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]

P451: !_LD [13] (FP)
ld [%i3 + 64], %f9
! 1 addresses covered

P452: !_DWLD [0] (FP)
ldd [%i0 + 0], %f10
! 2 addresses covered

P453: !_ST [3] (maybe <- 0x3f800073) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i0 + 32 ]

P454: !_LD [2] (FP)
ld [%i0 + 12], %f12
! 1 addresses covered

P455: !_ST [3] (maybe <- 0x3f800074) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i0 + 32 ]

P456: !_DWLD [13] (FP)
ldd [%i3 + 64], %f18
! 1 addresses covered
fmovs %f18, %f13

P457: !_CASX [0] (maybe <- 0x43) (Int)
add %i0, 0, %o5
ldx [%o5], %o1
! move %o1(upper) -> %o1(upper)
! move %o1(lower) -> %o1(lower)
mov %o1, %l7
sllx %l4, 32, %o2
add  %l4, 1, %l4
or   %l4, %o2, %o2
casx [%o5], %l7, %o2
! move %o2(upper) -> %o2(upper)
! move %o2(lower) -> %o2(lower)
add  %l4, 1, %l4

P458: !_REPLACEMENT [1] (Int)
sethi %hi(0x4), %l7
or %l7, %lo(0x4),  %l7
sethi %hi(0x10000), %o5
or %o5, %lo(0x10000),  %o5
add %i3, %l7, %l7
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]

P459: !_CASX [2] (maybe <- 0x45) (Int)
add %i0, 8, %l7
ldx [%l7], %o3
! move %o3(upper) -> %o3(upper)
! move %o3(lower) -> %o3(lower)
mov  %o3, %l6
mov %l4, %o4
casx [%l7], %l6, %o4
! move %o4(upper) -> %o4(upper)
! move %o4(lower) -> %o4(lower)
!---- flushing int results buffer----
mov %o0, %l5
mov %o1, %l5
mov %o2, %l5
mov %o3, %l5
mov %o4, %l5
add  %l4, 1, %l4

P460: !_PREFETCH [12] (Int)
prefetch [%i3 + 0], 1

P461: !_ST [6] (maybe <- 0x3f800075) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i1 + 80 ]

P462: !_DWST [5] (maybe <- 0x3f800076) (FP)
! 0 th moved, current_fp_src=21 
fmovs  %f16, %f21
fadds  %f16, %f17, %f16
std %f20, [%i1 + 72]

P463: !_ST [7] (maybe <- 0x3f800077) (FP) (Branch target of P712)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i1 + 84 ]
ba P464
nop

TARGET712:
ba RET712
nop


P464: !_SWAP [8] (maybe <- 0x46) (Int)
mov %l4, %o0
swap  [%i1 + 256], %o0
! move %o0(lower) -> %o0(upper)
sllx %o0, 32, %o0
add   %l4, 1, %l4

P465: !_LD [4] (FP)
ld [%i0 + 64], %f14
! 1 addresses covered

P466: !_REPLACEMENT [11] (Int)
sethi %hi(0x40), %l6
or %l6, %lo(0x40),  %l6
sethi %hi(0x10000), %l7
or %l7, %lo(0x10000),  %l7
add %i3, %l6, %l6
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]

P467: !_REPLACEMENT [7] (Int)
sethi %hi(0x54), %l3
or %l3, %lo(0x54),  %l3
sethi %hi(0x10000), %l6
or %l6, %lo(0x10000),  %l6
add %i3, %l3, %l3
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]

P468: !_CAS [3] (maybe <- 0x47) (Int)
add %i0, 32, %l3
lduw [%l3], %l7
mov %l7, %o5
! move %o5(lower) -> %o0(lower)
or %o5, %o0, %o0
mov %l4, %o1
cas [%l3], %o5, %o1
! move %o1(lower) -> %o1(upper)
sllx %o1, 32, %o1
add   %l4, 1, %l4

P469: !_DWST [2] (maybe <- 0x3f800078) (FP)
! 0 th moved, current_fp_src=21 
fmovs  %f16, %f21
fadds  %f16, %f17, %f16
std %f20, [%i0 + 8]

P470: !_PREFETCH [9] (Int)
prefetch [%i1 + 512], 1

P471: !_ST [13] (maybe <- 0x3f800079) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i3 + 64 ]

P472: !_PREFETCH [14] (Int)
prefetch [%i3 + 128], 1

P473: !_REPLACEMENT [0] (Int) (CBR)
sethi %hi(0x0), %l6
or %l6, %lo(0x0),  %l6
sethi %hi(0x10000), %l7
or %l7, %lo(0x10000),  %l7
add %i3, %l6, %l6
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]

! cbranch
andcc %l0, 1, %g0
be,pn  %xcc, TARGET473
nop
RET473:

! lfsr step begin
srlx %l0, 1, %l3
xnor %l3, %l0, %l3
sllx %l3, 63, %l3
or  %l3, %l0, %l0
srlx %l0, 1, %l0


P474: !_DWST [13] (maybe <- 0x3f80007a) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
std %f20, [%i3 + 64]

P475: !_SWAP [13] (maybe <- 0x48) (Int)
mov %l4, %l7
swap  [%i3 + 64], %l7
! move %l7(lower) -> %o1(lower)
srl %l7, 0, %l3
or %l3, %o1, %o1
add   %l4, 1, %l4

P476: !_ST [15] (maybe <- 0x3f80007b) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i3 + 192 ]

P477: !_DWLD [6] (FP) (Branch target of P610)
ldd [%i1 + 80], %f18
! 2 addresses covered
fmovs %f18, %f15
!---- flushing fp results buffer to %f30 ----
fmovd %f0, %f30
fmovd %f2, %f30
fmovd %f4, %f30
fmovd %f6, %f30
fmovd %f8, %f30
fmovd %f10, %f30
fmovd %f12, %f30
fmovd %f14, %f30
fmovs %f19, %f0
ba P478
nop

TARGET610:
ba RET610
nop


P478: !_PREFETCH [12] (Int) (Branch target of P48)
prefetch [%i3 + 0], 1
ba P479
nop

TARGET48:
ba RET48
nop


P479: !_LD [2] (FP) (Branch target of P173)
ld [%i0 + 12], %f1
! 1 addresses covered
ba P480
nop

TARGET173:
ba RET173
nop


P480: !_DWLD [10] (FP)
ldd [%i2 + 32], %f2
! 1 addresses covered

P481: !_SWAP [9] (maybe <- 0x49) (Int)
mov %l4, %o2
swap  [%i1 + 512], %o2
! move %o2(lower) -> %o2(upper)
sllx %o2, 32, %o2
add   %l4, 1, %l4

P482: !_ST [13] (maybe <- 0x3f80007c) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i3 + 64 ]

P483: !_DWLD [15] (FP)
ldd [%i3 + 192], %f18
! 1 addresses covered
fmovs %f18, %f3

P484: !_DWLD [3] (FP)
ldd [%i0 + 32], %f4
! 1 addresses covered

P485: !_DWLD [0] (FP)
ldd [%i0 + 0], %f18
! 2 addresses covered
fmovs %f18, %f5
fmovs %f19, %f6

P486: !_REPLACEMENT [7] (Int)
sethi %hi(0x54), %l3
or %l3, %lo(0x54),  %l3
sethi %hi(0x10000), %l6
or %l6, %lo(0x10000),  %l6
add %i3, %l3, %l3
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]

P487: !_DWST [8] (maybe <- 0x3f80007d) (FP) (CBR) (Branch target of P287)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
std %f20, [%i1 + 256]

! cbranch
andcc %l0, 1, %g0
be,pt  %xcc, TARGET487
nop
RET487:

! lfsr step begin
srlx %l0, 1, %l7
xnor %l7, %l0, %l7
sllx %l7, 63, %l7
or  %l7, %l0, %l0
srlx %l0, 1, %l0

ba P488
nop

TARGET287:
ba RET287
nop


P488: !_CAS [9] (maybe <- 0x4a) (Int)
add %i1, 512, %l3
lduw [%l3], %l7
mov %l7, %o5
! move %o5(lower) -> %o2(lower)
or %o5, %o2, %o2
mov %l4, %o3
cas [%l3], %o5, %o3
! move %o3(lower) -> %o3(upper)
sllx %o3, 32, %o3
add   %l4, 1, %l4

P489: !_PREFETCH [1] (Int)
prefetch [%i0 + 4], 1

P490: !_DWST [10] (maybe <- 0x3f80007e) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
std %f20, [%i2 + 32]

P491: !_ST [4] (maybe <- 0x3f80007f) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i0 + 64 ]

P492: !_REPLACEMENT [15] (Int)
sethi %hi(0xc0), %l6
or %l6, %lo(0xc0),  %l6
sethi %hi(0x10000), %l7
or %l7, %lo(0x10000),  %l7
add %i3, %l6, %l6
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]

P493: !_CAS [15] (maybe <- 0x4b) (Int)
add %i3, 192, %l6
lduw [%l6], %o5
mov %o5, %l3
! move %l3(lower) -> %o3(lower)
or %l3, %o3, %o3
mov %l4, %o4
cas [%l6], %l3, %o4
! move %o4(lower) -> %o4(upper)
sllx %o4, 32, %o4
add   %l4, 1, %l4

P494: !_LD [9] (FP) (Branch target of P678)
ld [%i1 + 512], %f7
! 1 addresses covered
ba P495
nop

TARGET678:
ba RET678
nop


P495: !_DWST [12] (maybe <- 0x3f800080) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
std %f20, [%i3 + 0]

P496: !_MEMBAR (Int)
membar #StoreLoad

P497: !_LD [2] (FP)
ld [%i0 + 12], %f8
! 1 addresses covered

P498: !_PREFETCH [1] (Int)
prefetch [%i0 + 4], 1

P499: !_DWST [3] (maybe <- 0x3f800081) (FP) (CBR)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
std %f20, [%i0 + 32]

! cbranch
andcc %l0, 1, %g0
be,pn  %xcc, TARGET499
nop
RET499:

! lfsr step begin
srlx %l0, 1, %l7
xnor %l7, %l0, %l7
sllx %l7, 63, %l7
or  %l7, %l0, %l0
srlx %l0, 1, %l0


P500: !_PREFETCH [10] (Int)
prefetch [%i2 + 32], 1

P501: !_PREFETCH [14] (Int)
prefetch [%i3 + 128], 1

P502: !_DWST [4] (maybe <- 0x3f800082) (FP) (CBR)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
std %f20, [%i0 + 64]

! cbranch
andcc %l0, 1, %g0
be,pn  %xcc, TARGET502
nop
RET502:

! lfsr step begin
srlx %l0, 1, %l7
xnor %l7, %l0, %l7
sllx %l7, 63, %l7
or  %l7, %l0, %l0
srlx %l0, 1, %l0


P503: !_ST [0] (maybe <- 0x3f800083) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i0 + 0 ]

P504: !_DWLD [1] (FP)
ldd [%i0 + 0], %f18
! 2 addresses covered
fmovs %f18, %f9
fmovs %f19, %f10

P505: !_PREFETCH [7] (Int)
prefetch [%i1 + 84], 1

P506: !_CASX [14] (maybe <- 0x4c) (Int)
add %i3, 128, %o5
ldx [%o5], %l6
! move %l6(upper) -> %o4(lower)
srlx %l6, 32, %l7
or %l7, %o4, %o4
!---- flushing int results buffer----
mov %o0, %l5
mov %o1, %l5
mov %o2, %l5
mov %o3, %l5
mov %o4, %l5
! move %l6(lower) -> %o0(upper)
sllx %l6, 32, %o0
mov  %l6, %l7
sllx %l4, 32, %l6
casx [%o5], %l7, %l6
! move %l6(upper) -> %o0(lower)
srlx %l6, 32, %o5
or %o5, %o0, %o0
! move %l6(lower) -> %o1(upper)
sllx %l6, 32, %o1
add  %l4, 1, %l4

P507: !_LD [4] (FP)
ld [%i0 + 64], %f11
! 1 addresses covered

P508: !_DWLD [13] (FP)
ldd [%i3 + 64], %f12
! 1 addresses covered

P509: !_MEMBAR (Int) (Branch target of P566)
membar #StoreLoad
ba P510
nop

TARGET566:
ba RET566
nop


P510: !_PREFETCH [14] (Int)
prefetch [%i3 + 128], 1

P511: !_MEMBAR (Int) (CBR)
membar #StoreLoad

! cbranch
andcc %l0, 1, %g0
be,pn  %xcc, TARGET511
nop
RET511:

! lfsr step begin
srlx %l0, 1, %l7
xnor %l7, %l0, %l7
sllx %l7, 63, %l7
or  %l7, %l0, %l0
srlx %l0, 1, %l0


P512: !_ST [8] (maybe <- 0x3f800084) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i1 + 256 ]

P513: !_DWST [11] (maybe <- 0x3f800085) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
std %f20, [%i2 + 64]

P514: !_PREFETCH [14] (Int)
prefetch [%i3 + 128], 1

P515: !_DWST [8] (maybe <- 0x3f800086) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
std %f20, [%i1 + 256]

P516: !_LD [13] (FP)
ld [%i3 + 64], %f13
! 1 addresses covered

P517: !_LD [3] (FP)
ld [%i0 + 32], %f14
! 1 addresses covered

P518: !_ST [11] (maybe <- 0x3f800087) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i2 + 64 ]

P519: !_DWLD [0] (FP)
ldd [%i0 + 0], %f18
! 2 addresses covered
fmovs %f18, %f15
!---- flushing fp results buffer to %f30 ----
fmovd %f0, %f30
fmovd %f2, %f30
fmovd %f4, %f30
fmovd %f6, %f30
fmovd %f8, %f30
fmovd %f10, %f30
fmovd %f12, %f30
fmovd %f14, %f30
fmovs %f19, %f0

P520: !_PREFETCH [9] (Int)
prefetch [%i1 + 512], 1

P521: !_REPLACEMENT [4] (Int)
sethi %hi(0x40), %o5
or %o5, %lo(0x40),  %o5
sethi %hi(0x10000), %l3
or %l3, %lo(0x10000),  %l3
add %i3, %o5, %o5
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]

P522: !_DWST [12] (maybe <- 0x3f800088) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
std %f20, [%i3 + 0]

P523: !_REPLACEMENT [10] (Int)
sethi %hi(0x20), %l6
or %l6, %lo(0x20),  %l6
sethi %hi(0x10000), %l7
or %l7, %lo(0x10000),  %l7
add %i3, %l6, %l6
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]

P524: !_LD [9] (FP)
ld [%i1 + 512], %f1
! 1 addresses covered

P525: !_LD [13] (FP)
ld [%i3 + 64], %f2
! 1 addresses covered

P526: !_ST [7] (maybe <- 0x3f800089) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i1 + 84 ]

P527: !_LD [9] (FP)
ld [%i1 + 512], %f3
! 1 addresses covered

P528: !_DWLD [9] (FP)
ldd [%i1 + 512], %f4
! 1 addresses covered

P529: !_DWLD [7] (FP)
ldd [%i1 + 80], %f18
! 2 addresses covered
fmovs %f18, %f5
fmovs %f19, %f6

P530: !_DWST [6] (maybe <- 0x3f80008a) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
! 1 th moved, current_fp_src=21 
fmovs  %f16, %f21
fadds  %f16, %f17, %f16
std %f20, [%i1 + 80]

P531: !_DWLD [11] (FP)
ldd [%i2 + 64], %f18
! 1 addresses covered
fmovs %f18, %f7

P532: !_SWAP [14] (maybe <- 0x4d) (Int)
mov %l4, %l3
swap  [%i3 + 128], %l3
! move %l3(lower) -> %o1(lower)
srl %l3, 0, %l7
or %l7, %o1, %o1
add   %l4, 1, %l4

P533: !_LD [15] (FP)
ld [%i3 + 192], %f8
! 1 addresses covered

P534: !_LD [15] (FP)
ld [%i3 + 192], %f9
! 1 addresses covered

P535: !_LD [4] (FP)
ld [%i0 + 64], %f10
! 1 addresses covered

P536: !_PREFETCH [7] (Int)
prefetch [%i1 + 84], 1

P537: !_PREFETCH [2] (Int)
prefetch [%i0 + 12], 1

P538: !_CASX [14] (maybe <- 0x4e) (Int)
add %i3, 128, %l7
ldx [%l7], %o2
! move %o2(upper) -> %o2(upper)
! move %o2(lower) -> %o2(lower)
mov  %o2, %l6
sllx %l4, 32, %o3
casx [%l7], %l6, %o3
! move %o3(upper) -> %o3(upper)
! move %o3(lower) -> %o3(lower)
add  %l4, 1, %l4

P539: !_DWLD [6] (FP)
ldd [%i1 + 80], %f18
! 2 addresses covered
fmovs %f18, %f11
fmovs %f19, %f12

P540: !_ST [6] (maybe <- 0x3f80008c) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i1 + 80 ]

P541: !_DWST [13] (maybe <- 0x3f80008d) (FP) (CBR)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
std %f20, [%i3 + 64]

! cbranch
andcc %l0, 1, %g0
be,pt  %xcc, TARGET541
nop
RET541:

! lfsr step begin
srlx %l0, 1, %o5
xnor %o5, %l0, %o5
sllx %o5, 63, %o5
or  %o5, %l0, %l0
srlx %l0, 1, %l0


P542: !_REPLACEMENT [10] (Int) (Branch target of P917)
sethi %hi(0x20), %l3
or %l3, %lo(0x20),  %l3
sethi %hi(0x10000), %l6
or %l6, %lo(0x10000),  %l6
add %i3, %l3, %l3
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
ba P543
nop

TARGET917:
ba RET917
nop


P543: !_ST [4] (maybe <- 0x3f80008e) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i0 + 64 ]

P544: !_LD [13] (FP)
ld [%i3 + 64], %f13
! 1 addresses covered

P545: !_LD [13] (FP) (Branch target of P152)
ld [%i3 + 64], %f14
! 1 addresses covered
ba P546
nop

TARGET152:
ba RET152
nop


P546: !_REPLACEMENT [12] (Int)
sethi %hi(0x0), %l7
or %l7, %lo(0x0),  %l7
sethi %hi(0x10000), %o5
or %o5, %lo(0x10000),  %o5
add %i3, %l7, %l7
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]

P547: !_CASX [2] (maybe <- 0x4f) (Int) (LE)
! Change single-word-level endianess (big endian <-> little endian) 
sethi %hi(0xff00ff00), %l7
or %l7, %lo(0xff00ff00), %l7
and %l4, %l7, %l6
srl %l6, 8, %l6
sll %l4, 8, %o5
and %o5, %l7, %o5
or %o5, %l6, %o5
srl %o5, 16, %l6
sll %o5, 16, %o5
srl %o5, 0, %o5
or %o5, %l6, %o5
sllx %o5, 32, %o5
wr %g0, 0x88, %asi
add %i0, 8, %l7
ldxa [%l7] %asi, %l3
! move %l3(lower) -> %o4(upper)
sllx %l3, 32, %o4
! move %l3(upper) -> %o4(lower)
srlx %l3, 32, %l6
or %l6, %o4, %o4
!---- flushing int results buffer----
mov %o0, %l5
mov %o1, %l5
mov %o2, %l5
mov %o3, %l5
mov %o4, %l5
mov  %l3, %l6
mov  %o5, %l3
casxa [%l7] %asi, %l6, %l3
! move %l3(lower) -> %o0(upper)
sllx %l3, 32, %o0
! move %l3(upper) -> %o0(lower)
srlx %l3, 32, %l7
or %l7, %o0, %o0
add  %l4, 1, %l4

P548: !_LD [6] (FP)
ld [%i1 + 80], %f15
! 1 addresses covered
!---- flushing fp results buffer to %f30 ----
fmovd %f0, %f30
fmovd %f2, %f30
fmovd %f4, %f30
fmovd %f6, %f30
fmovd %f8, %f30
fmovd %f10, %f30
fmovd %f12, %f30
fmovd %f14, %f30

P549: !_DWLD [2] (FP)
ldd [%i0 + 8], %f0
! 1 addresses covered
fmovs %f1, %f0

P550: !_SWAP [11] (maybe <- 0x50) (Int)
mov %l4, %o1
swap  [%i2 + 64], %o1
! move %o1(lower) -> %o1(upper)
sllx %o1, 32, %o1
add   %l4, 1, %l4

P551: !_LD [14] (FP)
ld [%i3 + 128], %f1
! 1 addresses covered

P552: !_NOP (Int)
nop

P553: !_DWST [0] (maybe <- 0x3f80008f) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
! 1 th moved, current_fp_src=21 
fmovs  %f16, %f21
fadds  %f16, %f17, %f16
std %f20, [%i0 + 0]

P554: !_ST [10] (maybe <- 0x3f800091) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i2 + 32 ]

P555: !_LD [15] (FP)
ld [%i3 + 192], %f2
! 1 addresses covered

P556: !_DWST [6] (maybe <- 0x3f800092) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
! 1 th moved, current_fp_src=21 
fmovs  %f16, %f21
fadds  %f16, %f17, %f16
std %f20, [%i1 + 80]

P557: !_SWAP [10] (maybe <- 0x51) (Int)
mov %l4, %o5
swap  [%i2 + 32], %o5
! move %o5(lower) -> %o1(lower)
srl %o5, 0, %l6
or %l6, %o1, %o1
add   %l4, 1, %l4

P558: !_SWAP [12] (maybe <- 0x52) (Int)
mov %l4, %o2
swap  [%i3 + 0], %o2
! move %o2(lower) -> %o2(upper)
sllx %o2, 32, %o2
add   %l4, 1, %l4

P559: !_PREFETCH [8] (Int)
prefetch [%i1 + 256], 1

P560: !_LD [9] (FP) (CBR)
ld [%i1 + 512], %f3
! 1 addresses covered

! cbranch
andcc %l0, 1, %g0
be,pt  %xcc, TARGET560
nop
RET560:

! lfsr step begin
srlx %l0, 1, %o5
xnor %o5, %l0, %o5
sllx %o5, 63, %o5
or  %o5, %l0, %l0
srlx %l0, 1, %l0


P561: !_LD [3] (FP)
ld [%i0 + 32], %f4
! 1 addresses covered

P562: !_DWST [10] (maybe <- 0x3f800094) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
std %f20, [%i2 + 32]

P563: !_REPLACEMENT [14] (Int) (CBR)
sethi %hi(0x80), %o5
or %o5, %lo(0x80),  %o5
sethi %hi(0x10000), %l3
or %l3, %lo(0x10000),  %l3
add %i3, %o5, %o5
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]

! cbranch
andcc %l0, 1, %g0
be,pn  %xcc, TARGET563
nop
RET563:

! lfsr step begin
srlx %l0, 1, %l7
xnor %l7, %l0, %l7
sllx %l7, 63, %l7
or  %l7, %l0, %l0
srlx %l0, 1, %l0


P564: !_REPLACEMENT [1] (Int)
sethi %hi(0x4), %o5
or %o5, %lo(0x4),  %o5
sethi %hi(0x10000), %l3
or %l3, %lo(0x10000),  %l3
add %i3, %o5, %o5
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]

P565: !_CASX [7] (maybe <- 0x53) (Int)
add %i1, 80, %o5
ldx [%o5], %l6
! move %l6(upper) -> %o2(lower)
srlx %l6, 32, %l7
or %l7, %o2, %o2
! move %l6(lower) -> %o3(upper)
sllx %l6, 32, %o3
mov %l6, %l7
sllx %l4, 32, %l6
add  %l4, 1, %l4
or   %l4, %l6, %l6
casx [%o5], %l7, %l6
! move %l6(upper) -> %o3(lower)
srlx %l6, 32, %o5
or %o5, %o3, %o3
! move %l6(lower) -> %o4(upper)
sllx %l6, 32, %o4
add  %l4, 1, %l4

P566: !_ST [6] (maybe <- 0x3f800095) (FP) (CBR)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i1 + 80 ]

! cbranch
andcc %l0, 1, %g0
be,pt  %xcc, TARGET566
nop
RET566:

! lfsr step begin
srlx %l0, 1, %l6
xnor %l6, %l0, %l6
sllx %l6, 63, %l6
or  %l6, %l0, %l0
srlx %l0, 1, %l0


P567: !_ST [11] (maybe <- 0x3f800096) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i2 + 64 ]

P568: !_ST [13] (maybe <- 0x3f800097) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i3 + 64 ]

P569: !_DWLD [5] (FP)
ldd [%i1 + 72], %f18
! 1 addresses covered
fmovs %f19, %f5

P570: !_PREFETCH [9] (Int)
prefetch [%i1 + 512], 1

P571: !_ST [9] (maybe <- 0x3f800098) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i1 + 512 ]

P572: !_ST [8] (maybe <- 0x3f800099) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i1 + 256 ]

P573: !_LD [3] (FP)
ld [%i0 + 32], %f6
! 1 addresses covered

P574: !_CASX [2] (maybe <- 0x55) (Int)
add %i0, 8, %o5
ldx [%o5], %l6
! move %l6(upper) -> %o4(lower)
srlx %l6, 32, %l7
or %l7, %o4, %o4
!---- flushing int results buffer----
mov %o0, %l5
mov %o1, %l5
mov %o2, %l5
mov %o3, %l5
mov %o4, %l5
! move %l6(lower) -> %o0(upper)
sllx %l6, 32, %o0
mov  %l6, %l7
mov %l4, %l6
casx [%o5], %l7, %l6
! move %l6(upper) -> %o0(lower)
srlx %l6, 32, %o5
or %o5, %o0, %o0
! move %l6(lower) -> %o1(upper)
sllx %l6, 32, %o1
add  %l4, 1, %l4

P575: !_LD [5] (FP)
ld [%i1 + 76], %f7
! 1 addresses covered

P576: !_CASX [7] (maybe <- 0x56) (Int) (CBR)
add %i1, 80, %o5
ldx [%o5], %l6
! move %l6(upper) -> %o1(lower)
srlx %l6, 32, %l7
or %l7, %o1, %o1
! move %l6(lower) -> %o2(upper)
sllx %l6, 32, %o2
mov %l6, %l7
sllx %l4, 32, %l6
add  %l4, 1, %l4
or   %l4, %l6, %l6
casx [%o5], %l7, %l6
! move %l6(upper) -> %o2(lower)
srlx %l6, 32, %o5
or %o5, %o2, %o2
! move %l6(lower) -> %o3(upper)
sllx %l6, 32, %o3
add  %l4, 1, %l4

! cbranch
andcc %l0, 1, %g0
be,pt  %xcc, TARGET576
nop
RET576:

! lfsr step begin
srlx %l0, 1, %l7
xnor %l7, %l0, %l7
sllx %l7, 63, %l7
or  %l7, %l0, %l0
srlx %l0, 1, %l0


P577: !_ST [14] (maybe <- 0x3f80009a) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i3 + 128 ]

P578: !_PREFETCH [1] (Int)
prefetch [%i0 + 4], 1

P579: !_LD [9] (FP) (Branch target of P819)
ld [%i1 + 512], %f8
! 1 addresses covered
ba P580
nop

TARGET819:
ba RET819
nop


P580: !_LD [2] (FP)
ld [%i0 + 12], %f9
! 1 addresses covered

P581: !_ST [12] (maybe <- 0x3f80009b) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i3 + 0 ]

P582: !_LD [6] (FP) (Branch target of P190)
ld [%i1 + 80], %f10
! 1 addresses covered
ba P583
nop

TARGET190:
ba RET190
nop


P583: !_LD [8] (FP)
ld [%i1 + 256], %f11
! 1 addresses covered

P584: !_PREFETCH [13] (Int)
prefetch [%i3 + 64], 1

P585: !_DWST [11] (maybe <- 0x3f80009c) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
std %f20, [%i2 + 64]

P586: !_DWLD [13] (FP)
ldd [%i3 + 64], %f12
! 1 addresses covered

P587: !_REPLACEMENT [1] (Int) (Branch target of P28)
sethi %hi(0x4), %l3
or %l3, %lo(0x4),  %l3
sethi %hi(0x10000), %l6
or %l6, %lo(0x10000),  %l6
add %i3, %l3, %l3
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
ba P588
nop

TARGET28:
ba RET28
nop


P588: !_PREFETCH [2] (Int) (Branch target of P759)
prefetch [%i0 + 12], 1
ba P589
nop

TARGET759:
ba RET759
nop


P589: !_LD [12] (FP)
ld [%i3 + 0], %f13
! 1 addresses covered

P590: !_MEMBAR (Int)
membar #StoreLoad

P591: !_ST [13] (maybe <- 0x3f80009d) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i3 + 64 ]

P592: !_DWLD [7] (FP)
ldd [%i1 + 80], %f14
! 2 addresses covered
!---- flushing fp results buffer to %f30 ----
fmovd %f0, %f30
fmovd %f2, %f30
fmovd %f4, %f30
fmovd %f6, %f30
fmovd %f8, %f30
fmovd %f10, %f30
fmovd %f12, %f30
fmovd %f14, %f30

P593: !_ST [14] (maybe <- 0x3f80009e) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i3 + 128 ]

P594: !_DWLD [4] (FP)
ldd [%i0 + 64], %f0
! 1 addresses covered

P595: !_DWLD [0] (FP)
ldd [%i0 + 0], %f18
! 2 addresses covered
fmovs %f18, %f1
fmovs %f19, %f2

P596: !_LD [9] (FP)
ld [%i1 + 512], %f3
! 1 addresses covered

P597: !_CAS [10] (maybe <- 0x58) (Int)
add %i2, 32, %l7
lduw [%l7], %l3
mov %l3, %l6
! move %l6(lower) -> %o3(lower)
or %l6, %o3, %o3
mov %l4, %o4
cas [%l7], %l6, %o4
! move %o4(lower) -> %o4(upper)
sllx %o4, 32, %o4
add   %l4, 1, %l4

P598: !_PREFETCH [11] (Int)
prefetch [%i2 + 64], 1

P599: !_ST [9] (maybe <- 0x3f80009f) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i1 + 512 ]

P600: !_REPLACEMENT [12] (Int)
sethi %hi(0x0), %l3
or %l3, %lo(0x0),  %l3
sethi %hi(0x10000), %l6
or %l6, %lo(0x10000),  %l6
add %i3, %l3, %l3
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]

P601: !_DWLD [8] (FP)
ldd [%i1 + 256], %f4
! 1 addresses covered

P602: !_PREFETCH [8] (Int)
prefetch [%i1 + 256], 1

P603: !_PREFETCH [5] (Int)
prefetch [%i1 + 76], 1

P604: !_DWLD [1] (FP)
ldd [%i0 + 0], %f18
! 2 addresses covered
fmovs %f18, %f5
fmovs %f19, %f6

P605: !_REPLACEMENT [14] (Int)
sethi %hi(0x80), %o5
or %o5, %lo(0x80),  %o5
sethi %hi(0x10000), %l3
or %l3, %lo(0x10000),  %l3
add %i3, %o5, %o5
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]

P606: !_MEMBAR (Int)
membar #StoreLoad

P607: !_MEMBAR (Int) (CBR)
membar #StoreLoad

! cbranch
andcc %l0, 1, %g0
be,pt  %xcc, TARGET607
nop
RET607:

! lfsr step begin
srlx %l0, 1, %l7
xnor %l7, %l0, %l7
sllx %l7, 63, %l7
or  %l7, %l0, %l0
srlx %l0, 1, %l0


P608: !_DWST [11] (maybe <- 0x3f8000a0) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
std %f20, [%i2 + 64]

P609: !_LD [7] (FP)
ld [%i1 + 84], %f7
! 1 addresses covered

P610: !_LD [3] (FP) (CBR)
ld [%i0 + 32], %f8
! 1 addresses covered

! cbranch
andcc %l0, 1, %g0
be,pt  %xcc, TARGET610
nop
RET610:

! lfsr step begin
srlx %l0, 1, %l7
xnor %l7, %l0, %l7
sllx %l7, 63, %l7
or  %l7, %l0, %l0
srlx %l0, 1, %l0


P611: !_DWST [5] (maybe <- 0x3f8000a1) (FP)
! 0 th moved, current_fp_src=21 
fmovs  %f16, %f21
fadds  %f16, %f17, %f16
std %f20, [%i1 + 72]

P612: !_ST [4] (maybe <- 0x3f8000a2) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i0 + 64 ]

P613: !_PREFETCH [10] (Int) (Branch target of P560)
prefetch [%i2 + 32], 1
ba P614
nop

TARGET560:
ba RET560
nop


P614: !_CAS [8] (maybe <- 0x59) (Int)
add %i1, 256, %l7
lduw [%l7], %l3
mov %l3, %l6
! move %l6(lower) -> %o4(lower)
or %l6, %o4, %o4
!---- flushing int results buffer----
mov %o0, %l5
mov %o1, %l5
mov %o2, %l5
mov %o3, %l5
mov %o4, %l5
mov %l4, %o0
cas [%l7], %l6, %o0
! move %o0(lower) -> %o0(upper)
sllx %o0, 32, %o0
add   %l4, 1, %l4

P615: !_LD [4] (FP)
ld [%i0 + 64], %f9
! 1 addresses covered

P616: !_CASX [6] (maybe <- 0x5a) (Int) (Branch target of P473)
add %i1, 80, %l7
ldx [%l7], %l3
! move %l3(upper) -> %o0(lower)
srlx %l3, 32, %l6
or %l6, %o0, %o0
! move %l3(lower) -> %o1(upper)
sllx %l3, 32, %o1
mov %l3, %l6
sllx %l4, 32, %l3
add  %l4, 1, %l4
or   %l4, %l3, %l3
casx [%l7], %l6, %l3
! move %l3(upper) -> %o1(lower)
srlx %l3, 32, %l7
or %l7, %o1, %o1
! move %l3(lower) -> %o2(upper)
sllx %l3, 32, %o2
add  %l4, 1, %l4
ba P617
nop

TARGET473:
ba RET473
nop


P617: !_PREFETCH [15] (Int)
prefetch [%i3 + 192], 1

P618: !_DWST [4] (maybe <- 0x3f8000a3) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
std %f20, [%i0 + 64]

P619: !_PREFETCH [5] (Int)
prefetch [%i1 + 76], 1

P620: !_PREFETCH [15] (Int)
prefetch [%i3 + 192], 1

P621: !_MEMBAR (Int)
membar #StoreLoad

P622: !_REPLACEMENT [5] (Int)
sethi %hi(0x4c), %l3
or %l3, %lo(0x4c),  %l3
sethi %hi(0x10000), %l6
or %l6, %lo(0x10000),  %l6
add %i3, %l3, %l3
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]

P623: !_DWST [14] (maybe <- 0x3f8000a4) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
std %f20, [%i3 + 128]

P624: !_ST [11] (maybe <- 0x3f8000a5) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i2 + 64 ]

P625: !_REPLACEMENT [6] (Int)
sethi %hi(0x50), %l6
or %l6, %lo(0x50),  %l6
sethi %hi(0x10000), %l7
or %l7, %lo(0x10000),  %l7
add %i3, %l6, %l6
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]

P626: !_DWST [1] (maybe <- 0x3f8000a6) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
! 1 th moved, current_fp_src=21 
fmovs  %f16, %f21
fadds  %f16, %f17, %f16
std %f20, [%i0 + 0]

P627: !_DWLD [3] (FP)
ldd [%i0 + 32], %f10
! 1 addresses covered

P628: !_REPLACEMENT [2] (Int)
sethi %hi(0xc), %o5
or %o5, %lo(0xc),  %o5
sethi %hi(0x10000), %l3
or %l3, %lo(0x10000),  %l3
add %i3, %o5, %o5
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]

P629: !_DWST [5] (maybe <- 0x3f8000a8) (FP)
! 0 th moved, current_fp_src=21 
fmovs  %f16, %f21
fadds  %f16, %f17, %f16
std %f20, [%i1 + 72]

P630: !_PREFETCH [15] (Int)
prefetch [%i3 + 192], 1

P631: !_ST [7] (maybe <- 0x3f8000a9) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i1 + 84 ]

P632: !_LD [7] (FP)
ld [%i1 + 84], %f11
! 1 addresses covered

P633: !_ST [10] (maybe <- 0x3f8000aa) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i2 + 32 ]

P634: !_SWAP [3] (maybe <- 0x5c) (Int)
mov %l4, %l6
swap  [%i0 + 32], %l6
! move %l6(lower) -> %o2(lower)
srl %l6, 0, %o5
or %o5, %o2, %o2
add   %l4, 1, %l4

P635: !_ST [7] (maybe <- 0x3f8000ab) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i1 + 84 ]

P636: !_DWST [0] (maybe <- 0x3f8000ac) (FP) (CBR)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
! 1 th moved, current_fp_src=21 
fmovs  %f16, %f21
fadds  %f16, %f17, %f16
std %f20, [%i0 + 0]

! cbranch
andcc %l0, 1, %g0
be,pt  %xcc, TARGET636
nop
RET636:

! lfsr step begin
srlx %l0, 1, %l3
xnor %l3, %l0, %l3
sllx %l3, 63, %l3
or  %l3, %l0, %l0
srlx %l0, 1, %l0


P637: !_CASX [1] (maybe <- 0x5d) (Int)
add %i0, 0, %l7
ldx [%l7], %o3
! move %o3(upper) -> %o3(upper)
! move %o3(lower) -> %o3(lower)
mov %o3, %l6
sllx %l4, 32, %o4
add  %l4, 1, %l4
or   %l4, %o4, %o4
casx [%l7], %l6, %o4
! move %o4(upper) -> %o4(upper)
! move %o4(lower) -> %o4(lower)
!---- flushing int results buffer----
mov %o0, %l5
mov %o1, %l5
mov %o2, %l5
mov %o3, %l5
mov %o4, %l5
add  %l4, 1, %l4

P638: !_PREFETCH [12] (Int)
prefetch [%i3 + 0], 1

P639: !_REPLACEMENT [15] (Int)
sethi %hi(0xc0), %l6
or %l6, %lo(0xc0),  %l6
sethi %hi(0x10000), %l7
or %l7, %lo(0x10000),  %l7
add %i3, %l6, %l6
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]

P640: !_CASX [9] (maybe <- 0x5f) (Int)
add %i1, 512, %l6
ldx [%l6], %o0
! move %o0(upper) -> %o0(upper)
! move %o0(lower) -> %o0(lower)
mov  %o0, %l3
sllx %l4, 32, %o1
casx [%l6], %l3, %o1
! move %o1(upper) -> %o1(upper)
! move %o1(lower) -> %o1(lower)
add  %l4, 1, %l4

P641: !_LD [0] (FP)
ld [%i0 + 0], %f12
! 1 addresses covered

P642: !_DWLD [4] (FP)
ldd [%i0 + 64], %f18
! 1 addresses covered
fmovs %f18, %f13

P643: !_SWAP [4] (maybe <- 0x60) (Int)
mov %l4, %o2
swap  [%i0 + 64], %o2
! move %o2(lower) -> %o2(upper)
sllx %o2, 32, %o2
add   %l4, 1, %l4

P644: !_DWST [15] (maybe <- 0x3f8000ae) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
std %f20, [%i3 + 192]

P645: !_PREFETCH [1] (Int)
prefetch [%i0 + 4], 1

P646: !_REPLACEMENT [0] (Int)
sethi %hi(0x0), %l7
or %l7, %lo(0x0),  %l7
sethi %hi(0x10000), %o5
or %o5, %lo(0x10000),  %o5
add %i3, %l7, %l7
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]

P647: !_DWLD [13] (FP) (Branch target of P499)
ldd [%i3 + 64], %f14
! 1 addresses covered
ba P648
nop

TARGET499:
ba RET499
nop


P648: !_DWST [9] (maybe <- 0x3f8000af) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
std %f20, [%i1 + 512]

P649: !_LD [14] (FP)
ld [%i3 + 128], %f15
! 1 addresses covered
!---- flushing fp results buffer to %f30 ----
fmovd %f0, %f30
fmovd %f2, %f30
fmovd %f4, %f30
fmovd %f6, %f30
fmovd %f8, %f30
fmovd %f10, %f30
fmovd %f12, %f30
fmovd %f14, %f30

P650: !_DWLD [14] (FP)
ldd [%i3 + 128], %f0
! 1 addresses covered

P651: !_CAS [4] (maybe <- 0x61) (Int)
add %i0, 64, %l6
lduw [%l6], %o5
mov %o5, %l3
! move %l3(lower) -> %o2(lower)
or %l3, %o2, %o2
mov %l4, %o3
cas [%l6], %l3, %o3
! move %o3(lower) -> %o3(upper)
sllx %o3, 32, %o3
add   %l4, 1, %l4

P652: !_DWST [6] (maybe <- 0x3f8000b0) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
! 1 th moved, current_fp_src=21 
fmovs  %f16, %f21
fadds  %f16, %f17, %f16
std %f20, [%i1 + 80]

P653: !_ST [5] (maybe <- 0x3f8000b2) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i1 + 76 ]

P654: !_SWAP [4] (maybe <- 0x62) (Int)
mov %l4, %l3
swap  [%i0 + 64], %l3
! move %l3(lower) -> %o3(lower)
srl %l3, 0, %l7
or %l7, %o3, %o3
add   %l4, 1, %l4

P655: !_DWLD [5] (FP)
ldd [%i1 + 72], %f18
! 1 addresses covered
fmovs %f19, %f1

P656: !_DWLD [7] (FP)
ldd [%i1 + 80], %f2
! 2 addresses covered

P657: !_REPLACEMENT [11] (Int)
sethi %hi(0x40), %l6
or %l6, %lo(0x40),  %l6
sethi %hi(0x10000), %l7
or %l7, %lo(0x10000),  %l7
add %i3, %l6, %l6
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]

P658: !_LD [7] (FP)
ld [%i1 + 84], %f4
! 1 addresses covered

P659: !_REPLACEMENT [11] (Int)
sethi %hi(0x40), %l3
or %l3, %lo(0x40),  %l3
sethi %hi(0x10000), %l6
or %l6, %lo(0x10000),  %l6
add %i3, %l3, %l3
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]

P660: !_DWST [15] (maybe <- 0x3f8000b3) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
std %f20, [%i3 + 192]

P661: !_DWLD [13] (FP)
ldd [%i3 + 64], %f18
! 1 addresses covered
fmovs %f18, %f5

P662: !_MEMBAR (Int)
membar #StoreLoad

P663: !_PREFETCH [1] (Int)
prefetch [%i0 + 4], 1

P664: !_PREFETCH [2] (Int)
prefetch [%i0 + 12], 1

P665: !_DWLD [15] (FP)
ldd [%i3 + 192], %f6
! 1 addresses covered

P666: !_DWST [3] (maybe <- 0x3f8000b4) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
std %f20, [%i0 + 32]

P667: !_REPLACEMENT [3] (Int)
sethi %hi(0x20), %l6
or %l6, %lo(0x20),  %l6
sethi %hi(0x10000), %l7
or %l7, %lo(0x10000),  %l7
add %i3, %l6, %l6
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]

P668: !_ST [4] (maybe <- 0x3f8000b5) (FP) (CBR)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i0 + 64 ]

! cbranch
andcc %l0, 1, %g0
be,pn  %xcc, TARGET668
nop
RET668:

! lfsr step begin
srlx %l0, 1, %o5
xnor %o5, %l0, %o5
sllx %o5, 63, %o5
or  %o5, %l0, %l0
srlx %l0, 1, %l0


P669: !_PREFETCH [7] (Int)
prefetch [%i1 + 84], 1

P670: !_PREFETCH [15] (Int)
prefetch [%i3 + 192], 1

P671: !_SWAP [15] (maybe <- 0x63) (Int)
mov %l4, %o4
swap  [%i3 + 192], %o4
! move %o4(lower) -> %o4(upper)
sllx %o4, 32, %o4
add   %l4, 1, %l4

P672: !_ST [0] (maybe <- 0x3f8000b6) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i0 + 0 ]

P673: !_DWST [9] (maybe <- 0x3f8000b7) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
std %f20, [%i1 + 512]

P674: !_PREFETCH [11] (Int)
prefetch [%i2 + 64], 1

P675: !_DWLD [10] (FP)
ldd [%i2 + 32], %f18
! 1 addresses covered
fmovs %f18, %f7

P676: !_DWST [15] (maybe <- 0x3f8000b8) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
std %f20, [%i3 + 192]

P677: !_DWLD [9] (FP)
ldd [%i1 + 512], %f8
! 1 addresses covered

P678: !_DWST [1] (maybe <- 0x3f8000b9) (FP) (CBR)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
! 1 th moved, current_fp_src=21 
fmovs  %f16, %f21
fadds  %f16, %f17, %f16
std %f20, [%i0 + 0]

! cbranch
andcc %l0, 1, %g0
be,pt  %xcc, TARGET678
nop
RET678:

! lfsr step begin
srlx %l0, 1, %o5
xnor %o5, %l0, %o5
sllx %o5, 63, %o5
or  %o5, %l0, %l0
srlx %l0, 1, %l0


P679: !_PREFETCH [7] (Int)
prefetch [%i1 + 84], 1

P680: !_PREFETCH [1] (Int)
prefetch [%i0 + 4], 1

P681: !_LD [10] (FP)
ld [%i2 + 32], %f9
! 1 addresses covered

P682: !_REPLACEMENT [6] (Int)
sethi %hi(0x50), %l3
or %l3, %lo(0x50),  %l3
sethi %hi(0x10000), %l6
or %l6, %lo(0x10000),  %l6
add %i3, %l3, %l3
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]

P683: !_PREFETCH [2] (Int)
prefetch [%i0 + 12], 1

P684: !_DWLD [15] (FP)
ldd [%i3 + 192], %f10
! 1 addresses covered

P685: !_DWLD [8] (FP)
ldd [%i1 + 256], %f18
! 1 addresses covered
fmovs %f18, %f11

P686: !_DWLD [9] (FP)
ldd [%i1 + 512], %f12
! 1 addresses covered

P687: !_REPLACEMENT [11] (Int)
sethi %hi(0x40), %o5
or %o5, %lo(0x40),  %o5
sethi %hi(0x10000), %l3
or %l3, %lo(0x10000),  %l3
add %i3, %o5, %o5
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]

P688: !_NOP (Int)
nop

P689: !_DWST [0] (maybe <- 0x3f8000bb) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
! 1 th moved, current_fp_src=21 
fmovs  %f16, %f21
fadds  %f16, %f17, %f16
std %f20, [%i0 + 0]

P690: !_DWST [10] (maybe <- 0x3f8000bd) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
std %f20, [%i2 + 32]

P691: !_DWLD [10] (FP)
ldd [%i2 + 32], %f18
! 1 addresses covered
fmovs %f18, %f13

P692: !_DWLD [0] (FP)
ldd [%i0 + 0], %f14
! 2 addresses covered
!---- flushing fp results buffer to %f30 ----
fmovd %f0, %f30
fmovd %f2, %f30
fmovd %f4, %f30
fmovd %f6, %f30
fmovd %f8, %f30
fmovd %f10, %f30
fmovd %f12, %f30
fmovd %f14, %f30

P693: !_LD [4] (FP)
ld [%i0 + 64], %f0
! 1 addresses covered

P694: !_ST [1] (maybe <- 0x3f8000be) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i0 + 4 ]

P695: !_CAS [3] (maybe <- 0x64) (Int) (LE)
! Change single-word-level endianess (big endian <-> little endian) 
sethi %hi(0xff00ff00), %l3
or %l3, %lo(0xff00ff00), %l3
and %l4, %l3, %o5
srl %o5, 8, %o5
sll %l4, 8, %l6
and %l6, %l3, %l6
or %l6, %o5, %l6
srl %l6, 16, %o5
sll %l6, 16, %l6
srl %l6, 0, %l6
or %l6, %o5, %l6
wr %g0, 0x88, %asi
add %i0, 32, %l3
lduwa [%l3] %asi, %l7
mov %l7, %o5
! move %o5(lower) -> %o4(lower)
or %o5, %o4, %o4
!---- flushing int results buffer----
mov %o0, %l5
mov %o1, %l5
mov %o2, %l5
mov %o3, %l5
mov %o4, %l5
mov %l6, %o0
casa [%l3] %asi, %o5, %o0
! move %o0(lower) -> %o0(upper)
sllx %o0, 32, %o0
add   %l4, 1, %l4

P696: !_PREFETCH [0] (Int)
prefetch [%i0 + 0], 1

P697: !_ST [9] (maybe <- 0x3f8000bf) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i1 + 512 ]

P698: !_DWLD [8] (FP) (CBR)
ldd [%i1 + 256], %f18
! 1 addresses covered
fmovs %f18, %f1

! cbranch
andcc %l0, 1, %g0
be,pt  %xcc, TARGET698
nop
RET698:

! lfsr step begin
srlx %l0, 1, %l7
xnor %l7, %l0, %l7
sllx %l7, 63, %l7
or  %l7, %l0, %l0
srlx %l0, 1, %l0


P699: !_DWST [7] (maybe <- 0x3f8000c0) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
! 1 th moved, current_fp_src=21 
fmovs  %f16, %f21
fadds  %f16, %f17, %f16
std %f20, [%i1 + 80]

P700: !_LD [2] (FP) (Branch target of P228)
ld [%i0 + 12], %f2
! 1 addresses covered
ba P701
nop

TARGET228:
ba RET228
nop


P701: !_CAS [12] (maybe <- 0x65) (Int)
add %i3, 0, %o5
lduw [%o5], %l6
mov %l6, %l7
! move %l7(lower) -> %o0(lower)
or %l7, %o0, %o0
mov %l4, %o1
cas [%o5], %l7, %o1
! move %o1(lower) -> %o1(upper)
sllx %o1, 32, %o1
add   %l4, 1, %l4

P702: !_REPLACEMENT [1] (Int)
sethi %hi(0x4), %l7
or %l7, %lo(0x4),  %l7
sethi %hi(0x10000), %o5
or %o5, %lo(0x10000),  %o5
add %i3, %l7, %l7
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]

P703: !_ST [6] (maybe <- 0x3f8000c2) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i1 + 80 ]

P704: !_DWLD [0] (FP)
ldd [%i0 + 0], %f18
! 2 addresses covered
fmovs %f18, %f3
fmovs %f19, %f4

P705: !_PREFETCH [8] (Int)
prefetch [%i1 + 256], 1

P706: !_DWST [14] (maybe <- 0x3f8000c3) (FP) (CBR)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
std %f20, [%i3 + 128]

! cbranch
andcc %l0, 1, %g0
be,pn  %xcc, TARGET706
nop
RET706:

! lfsr step begin
srlx %l0, 1, %o5
xnor %o5, %l0, %o5
sllx %o5, 63, %o5
or  %o5, %l0, %l0
srlx %l0, 1, %l0


P707: !_DWST [9] (maybe <- 0x3f8000c4) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
std %f20, [%i1 + 512]

P708: !_CASX [0] (maybe <- 0x66) (Int)
add %i0, 0, %l3
ldx [%l3], %l7
! move %l7(upper) -> %o1(lower)
srlx %l7, 32, %o5
or %o5, %o1, %o1
! move %l7(lower) -> %o2(upper)
sllx %l7, 32, %o2
mov %l7, %o5
sllx %l4, 32, %l7
add  %l4, 1, %l4
or   %l4, %l7, %l7
casx [%l3], %o5, %l7
! move %l7(upper) -> %o2(lower)
srlx %l7, 32, %l3
or %l3, %o2, %o2
! move %l7(lower) -> %o3(upper)
sllx %l7, 32, %o3
add  %l4, 1, %l4

P709: !_DWLD [3] (FP)
ldd [%i0 + 32], %f18
! 1 addresses covered
fmovs %f18, %f5

P710: !_DWST [1] (maybe <- 0x3f8000c5) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
! 1 th moved, current_fp_src=21 
fmovs  %f16, %f21
fadds  %f16, %f17, %f16
std %f20, [%i0 + 0]

P711: !_MEMBAR (Int)
membar #StoreLoad

P712: !_DWLD [1] (FP) (CBR)
ldd [%i0 + 0], %f6
! 2 addresses covered

! cbranch
andcc %l0, 1, %g0
be,pt  %xcc, TARGET712
nop
RET712:

! lfsr step begin
srlx %l0, 1, %l7
xnor %l7, %l0, %l7
sllx %l7, 63, %l7
or  %l7, %l0, %l0
srlx %l0, 1, %l0


P713: !_PREFETCH [7] (Int)
prefetch [%i1 + 84], 1

P714: !_PREFETCH [3] (Int)
prefetch [%i0 + 32], 1

P715: !_MEMBAR (Int)
membar #StoreLoad

P716: !_ST [7] (maybe <- 0x3f8000c7) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i1 + 84 ]

P717: !_LD [1] (FP)
ld [%i0 + 4], %f8
! 1 addresses covered

P718: !_DWST [0] (maybe <- 0x3f8000c8) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
! 1 th moved, current_fp_src=21 
fmovs  %f16, %f21
fadds  %f16, %f17, %f16
std %f20, [%i0 + 0]

P719: !_ST [10] (maybe <- 0x3f8000ca) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i2 + 32 ]

P720: !_PREFETCH [6] (Int)
prefetch [%i1 + 80], 1

P721: !_REPLACEMENT [13] (Int) (Branch target of P361)
sethi %hi(0x40), %l3
or %l3, %lo(0x40),  %l3
sethi %hi(0x10000), %l6
or %l6, %lo(0x10000),  %l6
add %i3, %l3, %l3
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
ba P722
nop

TARGET361:
ba RET361
nop


P722: !_DWLD [3] (FP)
ldd [%i0 + 32], %f18
! 1 addresses covered
fmovs %f18, %f9

P723: !_DWST [7] (maybe <- 0x3f8000cb) (FP) (Branch target of P607)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
! 1 th moved, current_fp_src=21 
fmovs  %f16, %f21
fadds  %f16, %f17, %f16
std %f20, [%i1 + 80]
ba P724
nop

TARGET607:
ba RET607
nop


P724: !_DWLD [8] (FP) (Branch target of P576)
ldd [%i1 + 256], %f10
! 1 addresses covered
ba P725
nop

TARGET576:
ba RET576
nop


P725: !_PREFETCH [10] (Int)
prefetch [%i2 + 32], 1

P726: !_DWLD [1] (FP)
ldd [%i0 + 0], %f18
! 2 addresses covered
fmovs %f18, %f11
fmovs %f19, %f12

P727: !_LD [12] (FP) (CBR)
ld [%i3 + 0], %f13
! 1 addresses covered

! cbranch
andcc %l0, 1, %g0
be,pn  %xcc, TARGET727
nop
RET727:

! lfsr step begin
srlx %l0, 1, %l7
xnor %l7, %l0, %l7
sllx %l7, 63, %l7
or  %l7, %l0, %l0
srlx %l0, 1, %l0


P728: !_SWAP [0] (maybe <- 0x68) (Int)
mov %l4, %l6
swap  [%i0 + 0], %l6
! move %l6(lower) -> %o3(lower)
srl %l6, 0, %o5
or %o5, %o3, %o3
add   %l4, 1, %l4

P729: !_PREFETCH [14] (Int)
prefetch [%i3 + 128], 1

P730: !_REPLACEMENT [14] (Int)
sethi %hi(0x80), %l7
or %l7, %lo(0x80),  %l7
sethi %hi(0x10000), %o5
or %o5, %lo(0x10000),  %o5
add %i3, %l7, %l7
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]

P731: !_DWST [2] (maybe <- 0x3f8000cd) (FP)
! 0 th moved, current_fp_src=21 
fmovs  %f16, %f21
fadds  %f16, %f17, %f16
std %f20, [%i0 + 8]

P732: !_DWST [2] (maybe <- 0x3f8000ce) (FP)
! 0 th moved, current_fp_src=21 
fmovs  %f16, %f21
fadds  %f16, %f17, %f16
std %f20, [%i0 + 8]

P733: !_DWLD [3] (FP)
ldd [%i0 + 32], %f14
! 1 addresses covered

P734: !_DWLD [2] (FP)
ldd [%i0 + 8], %f18
! 1 addresses covered
fmovs %f19, %f15
!---- flushing fp results buffer to %f30 ----
fmovd %f0, %f30
fmovd %f2, %f30
fmovd %f4, %f30
fmovd %f6, %f30
fmovd %f8, %f30
fmovd %f10, %f30
fmovd %f12, %f30
fmovd %f14, %f30

P735: !_ST [8] (maybe <- 0x3f8000cf) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i1 + 256 ]

P736: !_PREFETCH [15] (Int)
prefetch [%i3 + 192], 1

P737: !_DWLD [13] (FP)
ldd [%i3 + 64], %f0
! 1 addresses covered

P738: !_SWAP [5] (maybe <- 0x69) (Int)
mov %l4, %o4
swap  [%i1 + 76], %o4
! move %o4(lower) -> %o4(upper)
sllx %o4, 32, %o4
add   %l4, 1, %l4

P739: !_PREFETCH [5] (Int)
prefetch [%i1 + 76], 1

P740: !_PREFETCH [13] (Int)
prefetch [%i3 + 64], 1

P741: !_LD [14] (FP)
ld [%i3 + 128], %f1
! 1 addresses covered

P742: !_CASX [9] (maybe <- 0x6a) (Int)
add %i1, 512, %l7
ldx [%l7], %l3
! move %l3(upper) -> %o4(lower)
srlx %l3, 32, %l6
or %l6, %o4, %o4
!---- flushing int results buffer----
mov %o0, %l5
mov %o1, %l5
mov %o2, %l5
mov %o3, %l5
mov %o4, %l5
! move %l3(lower) -> %o0(upper)
sllx %l3, 32, %o0
mov  %l3, %l6
sllx %l4, 32, %l3
casx [%l7], %l6, %l3
! move %l3(upper) -> %o0(lower)
srlx %l3, 32, %l7
or %l7, %o0, %o0
! move %l3(lower) -> %o1(upper)
sllx %l3, 32, %o1
add  %l4, 1, %l4

P743: !_PREFETCH [14] (Int)
prefetch [%i3 + 128], 1

P744: !_CASX [14] (maybe <- 0x6b) (Int)
add %i3, 128, %l7
ldx [%l7], %l3
! move %l3(upper) -> %o1(lower)
srlx %l3, 32, %l6
or %l6, %o1, %o1
! move %l3(lower) -> %o2(upper)
sllx %l3, 32, %o2
mov  %l3, %l6
sllx %l4, 32, %l3
casx [%l7], %l6, %l3
! move %l3(upper) -> %o2(lower)
srlx %l3, 32, %l7
or %l7, %o2, %o2
! move %l3(lower) -> %o3(upper)
sllx %l3, 32, %o3
add  %l4, 1, %l4

P745: !_DWLD [12] (FP)
ldd [%i3 + 0], %f2
! 1 addresses covered

P746: !_SWAP [9] (maybe <- 0x6c) (Int) (CBR)
mov %l4, %o5
swap  [%i1 + 512], %o5
! move %o5(lower) -> %o3(lower)
srl %o5, 0, %l6
or %l6, %o3, %o3
add   %l4, 1, %l4

! cbranch
andcc %l0, 1, %g0
be,pt  %xcc, TARGET746
nop
RET746:

! lfsr step begin
srlx %l0, 1, %l3
xnor %l3, %l0, %l3
sllx %l3, 63, %l3
or  %l3, %l0, %l0
srlx %l0, 1, %l0


P747: !_SWAP [6] (maybe <- 0x6d) (Int)
mov %l4, %o4
swap  [%i1 + 80], %o4
! move %o4(lower) -> %o4(upper)
sllx %o4, 32, %o4
add   %l4, 1, %l4

P748: !_DWST [5] (maybe <- 0x3f8000d0) (FP)
! 0 th moved, current_fp_src=21 
fmovs  %f16, %f21
fadds  %f16, %f17, %f16
std %f20, [%i1 + 72]

P749: !_REPLACEMENT [11] (Int)
sethi %hi(0x40), %o5
or %o5, %lo(0x40),  %o5
sethi %hi(0x10000), %l3
or %l3, %lo(0x10000),  %l3
add %i3, %o5, %o5
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]

P750: !_DWLD [11] (FP)
ldd [%i2 + 64], %f18
! 1 addresses covered
fmovs %f18, %f3

P751: !_CASX [1] (maybe <- 0x6e) (Int)
add %i0, 0, %o5
ldx [%o5], %l6
! move %l6(upper) -> %o4(lower)
srlx %l6, 32, %l7
or %l7, %o4, %o4
!---- flushing int results buffer----
mov %o0, %l5
mov %o1, %l5
mov %o2, %l5
mov %o3, %l5
mov %o4, %l5
! move %l6(lower) -> %o0(upper)
sllx %l6, 32, %o0
mov %l6, %l7
sllx %l4, 32, %l6
add  %l4, 1, %l4
or   %l4, %l6, %l6
casx [%o5], %l7, %l6
! move %l6(upper) -> %o0(lower)
srlx %l6, 32, %o5
or %o5, %o0, %o0
! move %l6(lower) -> %o1(upper)
sllx %l6, 32, %o1
add  %l4, 1, %l4

P752: !_DWLD [14] (FP)
ldd [%i3 + 128], %f4
! 1 addresses covered

P753: !_LD [1] (FP)
ld [%i0 + 4], %f5
! 1 addresses covered

P754: !_ST [5] (maybe <- 0x3f8000d1) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i1 + 76 ]

P755: !_REPLACEMENT [8] (Int)
sethi %hi(0x100), %l6
or %l6, %lo(0x100),  %l6
sethi %hi(0x10000), %l7
or %l7, %lo(0x10000),  %l7
add %i3, %l6, %l6
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]

P756: !_DWST [11] (maybe <- 0x3f8000d2) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
std %f20, [%i2 + 64]

P757: !_DWST [12] (maybe <- 0x3f8000d3) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
std %f20, [%i3 + 0]

P758: !_ST [2] (maybe <- 0x3f8000d4) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i0 + 12 ]

P759: !_PREFETCH [5] (Int) (CBR) (Branch target of P746)
prefetch [%i1 + 76], 1

! cbranch
andcc %l0, 1, %g0
be,pt  %xcc, TARGET759
nop
RET759:

! lfsr step begin
srlx %l0, 1, %l6
xnor %l6, %l0, %l6
sllx %l6, 63, %l6
or  %l6, %l0, %l0
srlx %l0, 1, %l0

ba P760
nop

TARGET746:
ba RET746
nop


P760: !_REPLACEMENT [15] (Int)
sethi %hi(0xc0), %l7
or %l7, %lo(0xc0),  %l7
sethi %hi(0x10000), %o5
or %o5, %lo(0x10000),  %o5
add %i3, %l7, %l7
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]

P761: !_REPLACEMENT [6] (Int)
sethi %hi(0x50), %l6
or %l6, %lo(0x50),  %l6
sethi %hi(0x10000), %l7
or %l7, %lo(0x10000),  %l7
add %i3, %l6, %l6
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]

P762: !_PREFETCH [1] (Int)
prefetch [%i0 + 4], 1

P763: !_DWST [2] (maybe <- 0x3f8000d5) (FP)
! 0 th moved, current_fp_src=21 
fmovs  %f16, %f21
fadds  %f16, %f17, %f16
std %f20, [%i0 + 8]

P764: !_ST [0] (maybe <- 0x3f8000d6) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i0 + 0 ]

P765: !_CAS [3] (maybe <- 0x70) (Int) (Branch target of P265)
add %i0, 32, %o5
lduw [%o5], %l6
mov %l6, %l7
! move %l7(lower) -> %o1(lower)
or %l7, %o1, %o1
mov %l4, %o2
cas [%o5], %l7, %o2
! move %o2(lower) -> %o2(upper)
sllx %o2, 32, %o2
add   %l4, 1, %l4
ba P766
nop

TARGET265:
ba RET265
nop


P766: !_LD [5] (FP)
ld [%i1 + 76], %f6
! 1 addresses covered

P767: !_DWLD [5] (FP)
ldd [%i1 + 72], %f18
! 1 addresses covered
fmovs %f19, %f7

P768: !_LD [8] (FP)
ld [%i1 + 256], %f8
! 1 addresses covered

P769: !_REPLACEMENT [15] (Int)
sethi %hi(0xc0), %l7
or %l7, %lo(0xc0),  %l7
sethi %hi(0x10000), %o5
or %o5, %lo(0x10000),  %o5
add %i3, %l7, %l7
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]

P770: !_CAS [10] (maybe <- 0x71) (Int) (CBR)
add %i2, 32, %l7
lduw [%l7], %l3
mov %l3, %l6
! move %l6(lower) -> %o2(lower)
or %l6, %o2, %o2
mov %l4, %o3
cas [%l7], %l6, %o3
! move %o3(lower) -> %o3(upper)
sllx %o3, 32, %o3
add   %l4, 1, %l4

! cbranch
andcc %l0, 1, %g0
be,pt  %xcc, TARGET770
nop
RET770:

! lfsr step begin
srlx %l0, 1, %l6
xnor %l6, %l0, %l6
sllx %l6, 63, %l6
or  %l6, %l0, %l0
srlx %l0, 1, %l0


P771: !_ST [5] (maybe <- 0x3f8000d7) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i1 + 76 ]

P772: !_PREFETCH [15] (Int)
prefetch [%i3 + 192], 1

P773: !_DWLD [14] (FP)
ldd [%i3 + 128], %f18
! 1 addresses covered
fmovs %f18, %f9

P774: !_PREFETCH [12] (Int)
prefetch [%i3 + 0], 1

P775: !_PREFETCH [8] (Int)
prefetch [%i1 + 256], 1

P776: !_DWLD [11] (FP)
ldd [%i2 + 64], %f10
! 1 addresses covered

P777: !_PREFETCH [13] (Int)
prefetch [%i3 + 64], 1

P778: !_PREFETCH [2] (Int)
prefetch [%i0 + 12], 1

P779: !_NOP (Int)
nop

P780: !_REPLACEMENT [11] (Int)
sethi %hi(0x40), %l6
or %l6, %lo(0x40),  %l6
sethi %hi(0x10000), %l7
or %l7, %lo(0x10000),  %l7
add %i3, %l6, %l6
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]

P781: !_ST [6] (maybe <- 0x3f8000d8) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i1 + 80 ]

P782: !_ST [8] (maybe <- 0x3f8000d9) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i1 + 256 ]

P783: !_CAS [7] (maybe <- 0x72) (Int)
add %i1, 84, %o5
lduw [%o5], %l6
mov %l6, %l7
! move %l7(lower) -> %o3(lower)
or %l7, %o3, %o3
mov %l4, %o4
cas [%o5], %l7, %o4
! move %o4(lower) -> %o4(upper)
sllx %o4, 32, %o4
add   %l4, 1, %l4

P784: !_LD [3] (FP)
ld [%i0 + 32], %f11
! 1 addresses covered

P785: !_REPLACEMENT [5] (Int)
sethi %hi(0x4c), %l7
or %l7, %lo(0x4c),  %l7
sethi %hi(0x10000), %o5
or %o5, %lo(0x10000),  %o5
add %i3, %l7, %l7
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]

P786: !_LD [12] (FP) (Branch target of P698)
ld [%i3 + 0], %f12
! 1 addresses covered
ba P787
nop

TARGET698:
ba RET698
nop


P787: !_PREFETCH [13] (Int)
prefetch [%i3 + 64], 1

P788: !_ST [2] (maybe <- 0x3f8000da) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i0 + 12 ]

P789: !_PREFETCH [12] (Int) (LE)
wr %g0, 0x88, %asi
prefetcha [%i3 + 0] %asi, 1

P790: !_REPLACEMENT [15] (Int)
sethi %hi(0xc0), %l3
or %l3, %lo(0xc0),  %l3
sethi %hi(0x10000), %l6
or %l6, %lo(0x10000),  %l6
add %i3, %l3, %l3
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]

P791: !_DWLD [8] (FP)
ldd [%i1 + 256], %f18
! 1 addresses covered
fmovs %f18, %f13

P792: !_DWST [5] (maybe <- 0x3f8000db) (FP)
! 0 th moved, current_fp_src=21 
fmovs  %f16, %f21
fadds  %f16, %f17, %f16
std %f20, [%i1 + 72]

P793: !_CAS [11] (maybe <- 0x73) (Int)
add %i2, 64, %o5
lduw [%o5], %l6
mov %l6, %l7
! move %l7(lower) -> %o4(lower)
or %l7, %o4, %o4
!---- flushing int results buffer----
mov %o0, %l5
mov %o1, %l5
mov %o2, %l5
mov %o3, %l5
mov %o4, %l5
mov %l4, %o0
cas [%o5], %l7, %o0
! move %o0(lower) -> %o0(upper)
sllx %o0, 32, %o0
add   %l4, 1, %l4

P794: !_CASX [9] (maybe <- 0x74) (Int)
add %i1, 512, %o5
ldx [%o5], %l6
! move %l6(upper) -> %o0(lower)
srlx %l6, 32, %l7
or %l7, %o0, %o0
! move %l6(lower) -> %o1(upper)
sllx %l6, 32, %o1
mov  %l6, %l7
sllx %l4, 32, %l6
casx [%o5], %l7, %l6
! move %l6(upper) -> %o1(lower)
srlx %l6, 32, %o5
or %o5, %o1, %o1
! move %l6(lower) -> %o2(upper)
sllx %l6, 32, %o2
add  %l4, 1, %l4

P795: !_DWLD [6] (FP)
ldd [%i1 + 80], %f14
! 2 addresses covered
!---- flushing fp results buffer to %f30 ----
fmovd %f0, %f30
fmovd %f2, %f30
fmovd %f4, %f30
fmovd %f6, %f30
fmovd %f8, %f30
fmovd %f10, %f30
fmovd %f12, %f30
fmovd %f14, %f30

P796: !_DWST [7] (maybe <- 0x3f8000dc) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
! 1 th moved, current_fp_src=21 
fmovs  %f16, %f21
fadds  %f16, %f17, %f16
std %f20, [%i1 + 80]

P797: !_PREFETCH [8] (Int)
prefetch [%i1 + 256], 1

P798: !_REPLACEMENT [5] (Int)
sethi %hi(0x4c), %l6
or %l6, %lo(0x4c),  %l6
sethi %hi(0x10000), %l7
or %l7, %lo(0x10000),  %l7
add %i3, %l6, %l6
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]

P799: !_CAS [0] (maybe <- 0x75) (Int)
add %i0, 0, %l6
lduw [%l6], %o5
mov %o5, %l3
! move %l3(lower) -> %o2(lower)
or %l3, %o2, %o2
mov %l4, %o3
cas [%l6], %l3, %o3
! move %o3(lower) -> %o3(upper)
sllx %o3, 32, %o3
add   %l4, 1, %l4

P800: !_LD [1] (FP)
ld [%i0 + 4], %f0
! 1 addresses covered

P801: !_DWST [13] (maybe <- 0x3f8000de) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
std %f20, [%i3 + 64]

P802: !_REPLACEMENT [9] (Int)
sethi %hi(0x200), %o5
or %o5, %lo(0x200),  %o5
sethi %hi(0x10000), %l3
or %l3, %lo(0x10000),  %l3
add %i3, %o5, %o5
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]

P803: !_CAS [6] (maybe <- 0x76) (Int)
add %i1, 80, %o5
lduw [%o5], %l6
mov %l6, %l7
! move %l7(lower) -> %o3(lower)
or %l7, %o3, %o3
mov %l4, %o4
cas [%o5], %l7, %o4
! move %o4(lower) -> %o4(upper)
sllx %o4, 32, %o4
add   %l4, 1, %l4

P804: !_CASX [7] (maybe <- 0x77) (Int)
add %i1, 80, %o5
ldx [%o5], %l6
! move %l6(upper) -> %o4(lower)
srlx %l6, 32, %l7
or %l7, %o4, %o4
!---- flushing int results buffer----
mov %o0, %l5
mov %o1, %l5
mov %o2, %l5
mov %o3, %l5
mov %o4, %l5
! move %l6(lower) -> %o0(upper)
sllx %l6, 32, %o0
mov %l6, %l7
sllx %l4, 32, %l6
add  %l4, 1, %l4
or   %l4, %l6, %l6
casx [%o5], %l7, %l6
! move %l6(upper) -> %o0(lower)
srlx %l6, 32, %o5
or %o5, %o0, %o0
! move %l6(lower) -> %o1(upper)
sllx %l6, 32, %o1
add  %l4, 1, %l4

P805: !_DWLD [0] (FP)
ldd [%i0 + 0], %f18
! 2 addresses covered
fmovs %f18, %f1
fmovs %f19, %f2

P806: !_MEMBAR (Int) (Branch target of P136)
membar #StoreLoad
ba P807
nop

TARGET136:
ba RET136
nop


P807: !_LD [5] (FP)
ld [%i1 + 76], %f3
! 1 addresses covered

P808: !_DWLD [5] (FP)
ldd [%i1 + 72], %f4
! 1 addresses covered
fmovs %f5, %f4

P809: !_DWLD [12] (FP)
ldd [%i3 + 0], %f18
! 1 addresses covered
fmovs %f18, %f5

P810: !_PREFETCH [15] (Int)
prefetch [%i3 + 192], 1

P811: !_ST [6] (maybe <- 0x3f8000df) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i1 + 80 ]

P812: !_ST [12] (maybe <- 0x3f8000e0) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i3 + 0 ]

P813: !_PREFETCH [9] (Int)
prefetch [%i1 + 512], 1

P814: !_DWLD [6] (FP)
ldd [%i1 + 80], %f6
! 2 addresses covered

P815: !_PREFETCH [4] (Int)
prefetch [%i0 + 64], 1

P816: !_ST [6] (maybe <- 0x3f8000e1) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i1 + 80 ]

P817: !_DWLD [13] (FP)
ldd [%i3 + 64], %f8
! 1 addresses covered

P818: !_DWLD [15] (FP)
ldd [%i3 + 192], %f18
! 1 addresses covered
fmovs %f18, %f9

P819: !_PREFETCH [0] (Int) (CBR)
prefetch [%i0 + 0], 1

! cbranch
andcc %l0, 1, %g0
be,pn  %xcc, TARGET819
nop
RET819:

! lfsr step begin
srlx %l0, 1, %o5
xnor %o5, %l0, %o5
sllx %o5, 63, %o5
or  %o5, %l0, %l0
srlx %l0, 1, %l0


P820: !_REPLACEMENT [4] (Int)
sethi %hi(0x40), %l3
or %l3, %lo(0x40),  %l3
sethi %hi(0x10000), %l6
or %l6, %lo(0x10000),  %l6
add %i3, %l3, %l3
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]

P821: !_PREFETCH [7] (Int)
prefetch [%i1 + 84], 1

P822: !_DWLD [6] (FP)
ldd [%i1 + 80], %f10
! 2 addresses covered

P823: !_DWLD [7] (FP)
ldd [%i1 + 80], %f12
! 2 addresses covered

P824: !_PREFETCH [3] (Int) (Branch target of P313)
prefetch [%i0 + 32], 1
ba P825
nop

TARGET313:
ba RET313
nop


P825: !_DWST [8] (maybe <- 0x3f8000e2) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
std %f20, [%i1 + 256]

P826: !_PREFETCH [13] (Int)
prefetch [%i3 + 64], 1

P827: !_PREFETCH [10] (Int)
prefetch [%i2 + 32], 1

P828: !_DWLD [8] (FP)
ldd [%i1 + 256], %f14
! 1 addresses covered

P829: !_SWAP [7] (maybe <- 0x79) (Int)
mov %l4, %l3
swap  [%i1 + 84], %l3
! move %l3(lower) -> %o1(lower)
srl %l3, 0, %l7
or %l7, %o1, %o1
add   %l4, 1, %l4

P830: !_LD [9] (FP)
ld [%i1 + 512], %f15
! 1 addresses covered
!---- flushing fp results buffer to %f30 ----
fmovd %f0, %f30
fmovd %f2, %f30
fmovd %f4, %f30
fmovd %f6, %f30
fmovd %f8, %f30
fmovd %f10, %f30
fmovd %f12, %f30
fmovd %f14, %f30

P831: !_DWLD [9] (FP)
ldd [%i1 + 512], %f0
! 1 addresses covered

P832: !_PREFETCH [11] (Int)
prefetch [%i2 + 64], 1

P833: !_ST [4] (maybe <- 0x3f8000e3) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i0 + 64 ]

P834: !_DWLD [2] (FP)
ldd [%i0 + 8], %f18
! 1 addresses covered
fmovs %f19, %f1

P835: !_PREFETCH [9] (Int)
prefetch [%i1 + 512], 1

P836: !_LD [11] (FP)
ld [%i2 + 64], %f2
! 1 addresses covered

P837: !_SWAP [3] (maybe <- 0x7a) (Int)
mov %l4, %o2
swap  [%i0 + 32], %o2
! move %o2(lower) -> %o2(upper)
sllx %o2, 32, %o2
add   %l4, 1, %l4

P838: !_PREFETCH [14] (Int)
prefetch [%i3 + 128], 1

P839: !_DWST [3] (maybe <- 0x3f8000e4) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
std %f20, [%i0 + 32]

P840: !_NOP (Int)
nop

P841: !_SWAP [10] (maybe <- 0x7b) (Int)
mov %l4, %l3
swap  [%i2 + 32], %l3
! move %l3(lower) -> %o2(lower)
srl %l3, 0, %l7
or %l7, %o2, %o2
add   %l4, 1, %l4

P842: !_LD [10] (FP)
ld [%i2 + 32], %f3
! 1 addresses covered

P843: !_LD [0] (FP)
ld [%i0 + 0], %f4
! 1 addresses covered

P844: !_SWAP [14] (maybe <- 0x7c) (Int) (LE)
wr %g0, 0x88, %asi
mov %l4, %o3
! Change single-word-level endianess (big endian <-> little endian) 
sethi %hi(0xff00ff00), %l6
or %l6, %lo(0xff00ff00), %l6
and %o3, %l6, %l7
srl %l7, 8, %l7
sll %o3, 8, %o3
and %o3, %l6, %o3
or %o3, %l7, %o3
srl %o3, 16, %l7
sll %o3, 16, %o3
srl %o3, 0, %o3
or %o3, %l7, %o3
swapa  [%i3 + 128] %asi, %o3
! move %o3(lower) -> %o3(upper)
sllx %o3, 32, %o3
add   %l4, 1, %l4

P845: !_PREFETCH [8] (Int)
prefetch [%i1 + 256], 1

P846: !_MEMBAR (Int)
membar #StoreLoad

P847: !_DWLD [15] (FP)
ldd [%i3 + 192], %f18
! 1 addresses covered
fmovs %f18, %f5

P848: !_LD [3] (FP)
ld [%i0 + 32], %f6
! 1 addresses covered

P849: !_PREFETCH [3] (Int)
prefetch [%i0 + 32], 1

P850: !_PREFETCH [12] (Int)
prefetch [%i3 + 0], 1

P851: !_ST [0] (maybe <- 0x3f8000e5) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i0 + 0 ]

P852: !_REPLACEMENT [15] (Int)
sethi %hi(0xc0), %o5
or %o5, %lo(0xc0),  %o5
sethi %hi(0x10000), %l3
or %l3, %lo(0x10000),  %l3
add %i3, %o5, %o5
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]

P853: !_CAS [7] (maybe <- 0x7d) (Int)
add %i1, 84, %o5
lduw [%o5], %l6
mov %l6, %l7
! move %l7(lower) -> %o3(lower)
or %l7, %o3, %o3
mov %l4, %o4
cas [%o5], %l7, %o4
! move %o4(lower) -> %o4(upper)
sllx %o4, 32, %o4
add   %l4, 1, %l4

P854: !_PREFETCH [14] (Int)
prefetch [%i3 + 128], 1

P855: !_DWLD [3] (FP)
ldd [%i0 + 32], %f18
! 1 addresses covered
fmovs %f18, %f7

P856: !_SWAP [13] (maybe <- 0x7e) (Int)
mov %l4, %l3
swap  [%i3 + 64], %l3
! move %l3(lower) -> %o4(lower)
srl %l3, 0, %l7
or %l7, %o4, %o4
!---- flushing int results buffer----
mov %o0, %l5
mov %o1, %l5
mov %o2, %l5
mov %o3, %l5
mov %o4, %l5
add   %l4, 1, %l4

P857: !_DWST [10] (maybe <- 0x3f8000e6) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
std %f20, [%i2 + 32]

P858: !_PREFETCH [2] (Int)
prefetch [%i0 + 12], 1

P859: !_DWST [8] (maybe <- 0x3f8000e7) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
std %f20, [%i1 + 256]

P860: !_CASX [2] (maybe <- 0x7f) (Int)
add %i0, 8, %l3
ldx [%l3], %o0
! move %o0(upper) -> %o0(upper)
! move %o0(lower) -> %o0(lower)
mov  %o0, %o5
mov %l4, %o1
casx [%l3], %o5, %o1
! move %o1(upper) -> %o1(upper)
! move %o1(lower) -> %o1(lower)
add  %l4, 1, %l4

P861: !_PREFETCH [3] (Int) (Branch target of P541)
prefetch [%i0 + 32], 1
ba P862
nop

TARGET541:
ba RET541
nop


P862: !_DWST [10] (maybe <- 0x3f8000e8) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
std %f20, [%i2 + 32]

P863: !_ST [11] (maybe <- 0x3f8000e9) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i2 + 64 ]

P864: !_ST [10] (maybe <- 0x3f8000ea) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i2 + 32 ]

P865: !_ST [12] (maybe <- 0x3f8000eb) (FP) (CBR)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i3 + 0 ]

! cbranch
andcc %l0, 1, %g0
be,pt  %xcc, TARGET865
nop
RET865:

! lfsr step begin
srlx %l0, 1, %o5
xnor %o5, %l0, %o5
sllx %o5, 63, %o5
or  %o5, %l0, %l0
srlx %l0, 1, %l0


P866: !_DWST [15] (maybe <- 0x3f8000ec) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
std %f20, [%i3 + 192]

P867: !_LD [10] (FP)
ld [%i2 + 32], %f8
! 1 addresses covered

P868: !_MEMBAR (Int)
membar #StoreLoad

P869: !_DWST [14] (maybe <- 0x3f8000ed) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
std %f20, [%i3 + 128]

P870: !_LD [15] (FP)
ld [%i3 + 192], %f9
! 1 addresses covered

P871: !_DWLD [7] (FP)
ldd [%i1 + 80], %f10
! 2 addresses covered

P872: !_ST [13] (maybe <- 0x3f8000ee) (FP) (Branch target of P380)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i3 + 64 ]
ba P873
nop

TARGET380:
ba RET380
nop


P873: !_ST [11] (maybe <- 0x3f8000ef) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i2 + 64 ]

P874: !_DWST [12] (maybe <- 0x3f8000f0) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
std %f20, [%i3 + 0]

P875: !_REPLACEMENT [13] (Int)
sethi %hi(0x40), %o5
or %o5, %lo(0x40),  %o5
sethi %hi(0x10000), %l3
or %l3, %lo(0x10000),  %l3
add %i3, %o5, %o5
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]

P876: !_REPLACEMENT [13] (Int)
sethi %hi(0x40), %l7
or %l7, %lo(0x40),  %l7
sethi %hi(0x10000), %o5
or %o5, %lo(0x10000),  %o5
add %i3, %l7, %l7
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]

P877: !_ST [5] (maybe <- 0x3f8000f1) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i1 + 76 ]

P878: !_PREFETCH [8] (Int)
prefetch [%i1 + 256], 1

P879: !_MEMBAR (Int)
membar #StoreLoad

P880: !_SWAP [0] (maybe <- 0x80) (Int) (CBR)
mov %l4, %o2
swap  [%i0 + 0], %o2
! move %o2(lower) -> %o2(upper)
sllx %o2, 32, %o2
add   %l4, 1, %l4

! cbranch
andcc %l0, 1, %g0
be,pt  %xcc, TARGET880
nop
RET880:

! lfsr step begin
srlx %l0, 1, %o5
xnor %o5, %l0, %o5
sllx %o5, 63, %o5
or  %o5, %l0, %l0
srlx %l0, 1, %l0


P881: !_PREFETCH [10] (Int)
prefetch [%i2 + 32], 1

P882: !_DWLD [6] (FP)
ldd [%i1 + 80], %f12
! 2 addresses covered

P883: !_DWST [13] (maybe <- 0x3f8000f2) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
std %f20, [%i3 + 64]

P884: !_DWLD [8] (FP)
ldd [%i1 + 256], %f14
! 1 addresses covered

P885: !_DWLD [15] (FP)
ldd [%i3 + 192], %f18
! 1 addresses covered
fmovs %f18, %f15
!---- flushing fp results buffer to %f30 ----
fmovd %f0, %f30
fmovd %f2, %f30
fmovd %f4, %f30
fmovd %f6, %f30
fmovd %f8, %f30
fmovd %f10, %f30
fmovd %f12, %f30
fmovd %f14, %f30

P886: !_PREFETCH [14] (Int)
prefetch [%i3 + 128], 1

P887: !_DWLD [2] (FP)
ldd [%i0 + 8], %f0
! 1 addresses covered
fmovs %f1, %f0

P888: !_PREFETCH [11] (Int)
prefetch [%i2 + 64], 1

P889: !_DWLD [8] (FP) (Branch target of P439)
ldd [%i1 + 256], %f18
! 1 addresses covered
fmovs %f18, %f1
ba P890
nop

TARGET439:
ba RET439
nop


P890: !_DWLD [7] (FP)
ldd [%i1 + 80], %f2
! 2 addresses covered

P891: !_LD [3] (FP)
ld [%i0 + 32], %f4
! 1 addresses covered

P892: !_DWLD [4] (FP)
ldd [%i0 + 64], %f18
! 1 addresses covered
fmovs %f18, %f5

P893: !_DWLD [7] (FP) (Branch target of P636)
ldd [%i1 + 80], %f6
! 2 addresses covered
ba P894
nop

TARGET636:
ba RET636
nop


P894: !_DWLD [3] (FP)
ldd [%i0 + 32], %f8
! 1 addresses covered

P895: !_DWST [13] (maybe <- 0x3f8000f3) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
std %f20, [%i3 + 64]

P896: !_REPLACEMENT [1] (Int)
sethi %hi(0x4), %l7
or %l7, %lo(0x4),  %l7
sethi %hi(0x10000), %o5
or %o5, %lo(0x10000),  %o5
add %i3, %l7, %l7
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]

P897: !_SWAP [6] (maybe <- 0x81) (Int)
mov %l4, %o5
swap  [%i1 + 80], %o5
! move %o5(lower) -> %o2(lower)
srl %o5, 0, %l6
or %l6, %o2, %o2
add   %l4, 1, %l4

P898: !_MEMBAR (Int)
membar #StoreLoad

P899: !_REPLACEMENT [5] (Int)
sethi %hi(0x4c), %l3
or %l3, %lo(0x4c),  %l3
sethi %hi(0x10000), %l6
or %l6, %lo(0x10000),  %l6
add %i3, %l3, %l3
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]

P900: !_LD [4] (FP)
ld [%i0 + 64], %f9
! 1 addresses covered

P901: !_DWLD [14] (FP)
ldd [%i3 + 128], %f10
! 1 addresses covered

P902: !_PREFETCH [4] (Int)
prefetch [%i0 + 64], 1

P903: !_DWST [12] (maybe <- 0x3f8000f4) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
std %f20, [%i3 + 0]

P904: !_LD [15] (FP)
ld [%i3 + 192], %f11
! 1 addresses covered

P905: !_REPLACEMENT [9] (Int)
sethi %hi(0x200), %l7
or %l7, %lo(0x200),  %l7
sethi %hi(0x10000), %o5
or %o5, %lo(0x10000),  %o5
add %i3, %l7, %l7
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]

P906: !_REPLACEMENT [6] (Int)
sethi %hi(0x50), %l6
or %l6, %lo(0x50),  %l6
sethi %hi(0x10000), %l7
or %l7, %lo(0x10000),  %l7
add %i3, %l6, %l6
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]

P907: !_ST [13] (maybe <- 0x3f8000f5) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i3 + 64 ]

P908: !_DWST [8] (maybe <- 0x3f8000f6) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
std %f20, [%i1 + 256]

P909: !_DWST [2] (maybe <- 0x3f8000f7) (FP)
! 0 th moved, current_fp_src=21 
fmovs  %f16, %f21
fadds  %f16, %f17, %f16
std %f20, [%i0 + 8]

P910: !_ST [10] (maybe <- 0x3f8000f8) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i2 + 32 ]

P911: !_REPLACEMENT [4] (Int)
sethi %hi(0x40), %l3
or %l3, %lo(0x40),  %l3
sethi %hi(0x10000), %l6
or %l6, %lo(0x10000),  %l6
add %i3, %l3, %l3
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]

P912: !_DWLD [12] (FP)
ldd [%i3 + 0], %f12
! 1 addresses covered

P913: !_MEMBAR (Int)
membar #StoreLoad

P914: !_CASX [7] (maybe <- 0x82) (Int) (LE) (Branch target of P344)
sllx %l4, 32, %l3
add  %l4, 1, %l4
or   %l4, %l3, %l3
! Change double-word-level endianess (big endian <-> little endian) 
sethi %hi(0xff00ff00), %o5
or %o5, %lo(0xff00ff00), %o5
sllx %o5, 32, %l6
or %o5, %l6, %o5 
and %l3, %o5, %l6
srlx %l6, 8, %l6
sllx %l3, 8, %l3
and %l3, %o5, %l3
or %l3, %l6, %l3 
sethi %hi(0xffff0000), %o5
or %o5, %lo(0xffff0000), %o5
srlx %l3, 16, %l6
andn %l6, %o5, %l6
andn %l3, %o5, %l3
sllx %l3, 16, %l3
or %l3, %l6, %l3 
srlx %l3, 32, %l6
sllx %l3, 32, %l3
or %l3, %l6, %l6 
wr %g0, 0x88, %asi
add %i1, 80, %l3
ldxa [%l3] %asi, %l7
! move %l7(lower) -> %o3(upper)
sllx %l7, 32, %o3
! move %l7(upper) -> %o3(lower)
srlx %l7, 32, %o5
or %o5, %o3, %o3
mov %l7, %o5
mov  %l6, %l7
casxa [%l3] %asi, %o5, %l7
! move %l7(lower) -> %o4(upper)
sllx %l7, 32, %o4
! move %l7(upper) -> %o4(lower)
srlx %l7, 32, %l3
or %l3, %o4, %o4
!---- flushing int results buffer----
mov %o0, %l5
mov %o1, %l5
mov %o2, %l5
mov %o3, %l5
mov %o4, %l5
add  %l4, 1, %l4
ba P915
nop

TARGET344:
ba RET344
nop


P915: !_DWLD [8] (FP)
ldd [%i1 + 256], %f18
! 1 addresses covered
fmovs %f18, %f13

P916: !_DWST [14] (maybe <- 0x3f8000f9) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
std %f20, [%i3 + 128]

P917: !_DWST [12] (maybe <- 0x3f8000fa) (FP) (CBR)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
std %f20, [%i3 + 0]

! cbranch
andcc %l0, 1, %g0
be,pt  %xcc, TARGET917
nop
RET917:

! lfsr step begin
srlx %l0, 1, %l6
xnor %l6, %l0, %l6
sllx %l6, 63, %l6
or  %l6, %l0, %l0
srlx %l0, 1, %l0


P918: !_DWST [5] (maybe <- 0x3f8000fb) (FP)
! 0 th moved, current_fp_src=21 
fmovs  %f16, %f21
fadds  %f16, %f17, %f16
std %f20, [%i1 + 72]

P919: !_CAS [5] (maybe <- 0x84) (Int)
add %i1, 76, %l7
lduw [%l7], %o0
mov %o0, %l6
! move %l6(lower) -> %o0(upper)
sllx %l6, 32, %o0
mov %l4, %l3
cas [%l7], %l6, %l3
! move %l3(lower) -> %o0(lower)
srl %l3, 0, %l7
or %l7, %o0, %o0
add   %l4, 1, %l4

P920: !_PREFETCH [6] (Int)
prefetch [%i1 + 80], 1

P921: !_DWST [1] (maybe <- 0x3f8000fc) (FP) (CBR)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
! 1 th moved, current_fp_src=21 
fmovs  %f16, %f21
fadds  %f16, %f17, %f16
std %f20, [%i0 + 0]

! cbranch
andcc %l0, 1, %g0
be,pn  %xcc, TARGET921
nop
RET921:

! lfsr step begin
srlx %l0, 1, %l3
xnor %l3, %l0, %l3
sllx %l3, 63, %l3
or  %l3, %l0, %l0
srlx %l0, 1, %l0


P922: !_LD [12] (FP) (CBR)
ld [%i3 + 0], %f14
! 1 addresses covered

! cbranch
andcc %l0, 1, %g0
be,pt  %xcc, TARGET922
nop
RET922:

! lfsr step begin
srlx %l0, 1, %l6
xnor %l6, %l0, %l6
sllx %l6, 63, %l6
or  %l6, %l0, %l0
srlx %l0, 1, %l0


P923: !_REPLACEMENT [9] (Int)
sethi %hi(0x200), %l7
or %l7, %lo(0x200),  %l7
sethi %hi(0x10000), %o5
or %o5, %lo(0x10000),  %o5
add %i3, %l7, %l7
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]

P924: !_CASX [13] (maybe <- 0x85) (Int)
add %i3, 64, %l7
ldx [%l7], %o1
! move %o1(upper) -> %o1(upper)
! move %o1(lower) -> %o1(lower)
mov  %o1, %l6
sllx %l4, 32, %o2
casx [%l7], %l6, %o2
! move %o2(upper) -> %o2(upper)
! move %o2(lower) -> %o2(lower)
add  %l4, 1, %l4

P925: !_DWLD [8] (FP)
ldd [%i1 + 256], %f18
! 1 addresses covered
fmovs %f18, %f15
!---- flushing fp results buffer to %f30 ----
fmovd %f0, %f30
fmovd %f2, %f30
fmovd %f4, %f30
fmovd %f6, %f30
fmovd %f8, %f30
fmovd %f10, %f30
fmovd %f12, %f30
fmovd %f14, %f30

P926: !_LD [13] (FP) (Branch target of P51)
ld [%i3 + 64], %f0
! 1 addresses covered
ba P927
nop

TARGET51:
ba RET51
nop


P927: !_ST [13] (maybe <- 0x3f8000fe) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i3 + 64 ]

P928: !_DWLD [12] (FP)
ldd [%i3 + 0], %f18
! 1 addresses covered
fmovs %f18, %f1

P929: !_PREFETCH [14] (Int)
prefetch [%i3 + 128], 1

P930: !_DWST [12] (maybe <- 0x3f8000ff) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
std %f20, [%i3 + 0]

P931: !_MEMBAR (Int)
membar #StoreLoad

P932: !_DWLD [13] (FP)
ldd [%i3 + 64], %f2
! 1 addresses covered

P933: !_ST [15] (maybe <- 0x3f800100) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i3 + 192 ]

P934: !_CAS [11] (maybe <- 0x86) (Int)
add %i2, 64, %o5
lduw [%o5], %o3
mov %o3, %l7
! move %l7(lower) -> %o3(upper)
sllx %l7, 32, %o3
mov %l4, %l6
cas [%o5], %l7, %l6
! move %l6(lower) -> %o3(lower)
srl %l6, 0, %o5
or %o5, %o3, %o3
add   %l4, 1, %l4

P935: !_REPLACEMENT [10] (Int)
sethi %hi(0x20), %l7
or %l7, %lo(0x20),  %l7
sethi %hi(0x10000), %o5
or %o5, %lo(0x10000),  %o5
add %i3, %l7, %l7
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]

P936: !_REPLACEMENT [13] (Int)
sethi %hi(0x40), %l6
or %l6, %lo(0x40),  %l6
sethi %hi(0x10000), %l7
or %l7, %lo(0x10000),  %l7
add %i3, %l6, %l6
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]

P937: !_LD [13] (FP)
ld [%i3 + 64], %f3
! 1 addresses covered

P938: !_ST [3] (maybe <- 0x3f800101) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i0 + 32 ]

P939: !_PREFETCH [9] (Int)
prefetch [%i1 + 512], 1

P940: !_DWST [15] (maybe <- 0x3f800102) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
std %f20, [%i3 + 192]

P941: !_LD [3] (FP)
ld [%i0 + 32], %f4
! 1 addresses covered

P942: !_PREFETCH [5] (Int)
prefetch [%i1 + 76], 1

P943: !_LD [14] (FP)
ld [%i3 + 128], %f5
! 1 addresses covered

P944: !_MEMBAR (Int)
membar #StoreLoad

P945: !_ST [1] (maybe <- 0x3f800103) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i0 + 4 ]

P946: !_PREFETCH [9] (Int)
prefetch [%i1 + 512], 1

P947: !_PREFETCH [6] (Int)
prefetch [%i1 + 80], 1

P948: !_MEMBAR (Int)
membar #StoreLoad

P949: !_PREFETCH [3] (Int)
prefetch [%i0 + 32], 1

P950: !_LD [8] (FP)
ld [%i1 + 256], %f6
! 1 addresses covered

P951: !_CASX [3] (maybe <- 0x87) (Int)
add %i0, 32, %l7
ldx [%l7], %o4
! move %o4(upper) -> %o4(upper)
! move %o4(lower) -> %o4(lower)
!---- flushing int results buffer----
mov %o0, %l5
mov %o1, %l5
mov %o2, %l5
mov %o3, %l5
mov %o4, %l5
mov  %o4, %l6
sllx %l4, 32, %o0
casx [%l7], %l6, %o0
! move %o0(upper) -> %o0(upper)
! move %o0(lower) -> %o0(lower)
add  %l4, 1, %l4

P952: !_CAS [7] (maybe <- 0x88) (Int)
add %i1, 84, %l7
lduw [%l7], %o1
mov %o1, %l6
! move %l6(lower) -> %o1(upper)
sllx %l6, 32, %o1
mov %l4, %l3
cas [%l7], %l6, %l3
! move %l3(lower) -> %o1(lower)
srl %l3, 0, %l7
or %l7, %o1, %o1
add   %l4, 1, %l4

P953: !_DWST [14] (maybe <- 0x3f800104) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
std %f20, [%i3 + 128]

P954: !_DWLD [11] (FP)
ldd [%i2 + 64], %f18
! 1 addresses covered
fmovs %f18, %f7

P955: !_PREFETCH [2] (Int)
prefetch [%i0 + 12], 1

P956: !_SWAP [13] (maybe <- 0x89) (Int)
mov %l4, %o2
swap  [%i3 + 64], %o2
! move %o2(lower) -> %o2(upper)
sllx %o2, 32, %o2
add   %l4, 1, %l4

P957: !_PREFETCH [10] (Int)
prefetch [%i2 + 32], 1

P958: !_LD [10] (FP)
ld [%i2 + 32], %f8
! 1 addresses covered

P959: !_REPLACEMENT [9] (Int)
sethi %hi(0x200), %o5
or %o5, %lo(0x200),  %o5
sethi %hi(0x10000), %l3
or %l3, %lo(0x10000),  %l3
add %i3, %o5, %o5
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]

P960: !_DWLD [9] (FP)
ldd [%i1 + 512], %f18
! 1 addresses covered
fmovs %f18, %f9

P961: !_ST [12] (maybe <- 0x3f800105) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i3 + 0 ]

P962: !_ST [15] (maybe <- 0x3f800106) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i3 + 192 ]

P963: !_PREFETCH [1] (Int)
prefetch [%i0 + 4], 1

P964: !_LD [12] (FP)
ld [%i3 + 0], %f10
! 1 addresses covered

P965: !_SWAP [8] (maybe <- 0x8a) (Int)
mov %l4, %l7
swap  [%i1 + 256], %l7
! move %l7(lower) -> %o2(lower)
srl %l7, 0, %l3
or %l3, %o2, %o2
add   %l4, 1, %l4

P966: !_DWST [13] (maybe <- 0x3f800107) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
std %f20, [%i3 + 64]

P967: !_CASX [13] (maybe <- 0x8b) (Int) (LE)
! Change single-word-level endianess (big endian <-> little endian) 
sethi %hi(0xff00ff00), %o5
or %o5, %lo(0xff00ff00), %o5
and %l4, %o5, %l7
srl %l7, 8, %l7
sll %l4, 8, %l3
and %l3, %o5, %l3
or %l3, %l7, %l3
srl %l3, 16, %l7
sll %l3, 16, %l3
srl %l3, 0, %l3
or %l3, %l7, %l3
wr %g0, 0x88, %asi
add %i3, 64, %o5
ldxa [%o5] %asi, %l6
! move %l6(lower) -> %o3(upper)
sllx %l6, 32, %o3
! move %l6(upper) -> %o3(lower)
srlx %l6, 32, %l7
or %l7, %o3, %o3
mov  %l6, %l7
mov  %l3, %l6
casxa [%o5] %asi, %l7, %l6
! move %l6(lower) -> %o4(upper)
sllx %l6, 32, %o4
! move %l6(upper) -> %o4(lower)
srlx %l6, 32, %o5
or %o5, %o4, %o4
!---- flushing int results buffer----
mov %o0, %l5
mov %o1, %l5
mov %o2, %l5
mov %o3, %l5
mov %o4, %l5
add  %l4, 1, %l4

P968: !_LD [0] (FP)
ld [%i0 + 0], %f11
! 1 addresses covered

P969: !_DWST [5] (maybe <- 0x3f800108) (FP)
! 0 th moved, current_fp_src=21 
fmovs  %f16, %f21
fadds  %f16, %f17, %f16
std %f20, [%i1 + 72]

P970: !_LD [10] (FP)
ld [%i2 + 32], %f12
! 1 addresses covered

P971: !_DWST [11] (maybe <- 0x3f800109) (FP) (CBR)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
std %f20, [%i2 + 64]

! cbranch
andcc %l0, 1, %g0
be,pt  %xcc, TARGET971
nop
RET971:

! lfsr step begin
srlx %l0, 1, %l3
xnor %l3, %l0, %l3
sllx %l3, 63, %l3
or  %l3, %l0, %l0
srlx %l0, 1, %l0


P972: !_CAS [13] (maybe <- 0x8c) (Int)
add %i3, 64, %l7
lduw [%l7], %o0
mov %o0, %l6
! move %l6(lower) -> %o0(upper)
sllx %l6, 32, %o0
mov %l4, %l3
cas [%l7], %l6, %l3
! move %l3(lower) -> %o0(lower)
srl %l3, 0, %l7
or %l7, %o0, %o0
add   %l4, 1, %l4

P973: !_CASX [12] (maybe <- 0x8d) (Int)
add %i3, 0, %l7
ldx [%l7], %o1
! move %o1(upper) -> %o1(upper)
! move %o1(lower) -> %o1(lower)
mov  %o1, %l6
sllx %l4, 32, %o2
casx [%l7], %l6, %o2
! move %o2(upper) -> %o2(upper)
! move %o2(lower) -> %o2(lower)
add  %l4, 1, %l4

P974: !_LD [13] (FP)
ld [%i3 + 64], %f13
! 1 addresses covered

P975: !_DWLD [11] (FP)
ldd [%i2 + 64], %f14
! 1 addresses covered

P976: !_NOP (Int)
nop

P977: !_DWLD [8] (FP)
ldd [%i1 + 256], %f18
! 1 addresses covered
fmovs %f18, %f15
!---- flushing fp results buffer to %f30 ----
fmovd %f0, %f30
fmovd %f2, %f30
fmovd %f4, %f30
fmovd %f6, %f30
fmovd %f8, %f30
fmovd %f10, %f30
fmovd %f12, %f30
fmovd %f14, %f30

P978: !_DWST [8] (maybe <- 0x3f80010a) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
std %f20, [%i1 + 256]

P979: !_DWST [9] (maybe <- 0x3f80010b) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
std %f20, [%i1 + 512]

P980: !_ST [13] (maybe <- 0x3f80010c) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i3 + 64 ]

P981: !_PREFETCH [15] (Int)
prefetch [%i3 + 192], 1

P982: !_DWST [2] (maybe <- 0x3f80010d) (FP)
! 0 th moved, current_fp_src=21 
fmovs  %f16, %f21
fadds  %f16, %f17, %f16
std %f20, [%i0 + 8]

P983: !_DWLD [3] (FP) (Branch target of P971)
ldd [%i0 + 32], %f0
! 1 addresses covered
ba P984
nop

TARGET971:
ba RET971
nop


P984: !_DWST [7] (maybe <- 0x3f80010e) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
! 1 th moved, current_fp_src=21 
fmovs  %f16, %f21
fadds  %f16, %f17, %f16
std %f20, [%i1 + 80]

P985: !_REPLACEMENT [0] (Int) (Branch target of P563)
sethi %hi(0x0), %l3
or %l3, %lo(0x0),  %l3
sethi %hi(0x10000), %l6
or %l6, %lo(0x10000),  %l6
add %i3, %l3, %l3
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
ba P986
nop

TARGET563:
ba RET563
nop


P986: !_MEMBAR (Int)
membar #StoreLoad

P987: !_LD [4] (FP)
ld [%i0 + 64], %f1
! 1 addresses covered

P988: !_PREFETCH [4] (Int)
prefetch [%i0 + 64], 1

P989: !_DWLD [10] (FP)
ldd [%i2 + 32], %f2
! 1 addresses covered

P990: !_DWLD [12] (FP)
ldd [%i3 + 0], %f18
! 1 addresses covered
fmovs %f18, %f3

P991: !_ST [15] (maybe <- 0x3f800110) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i3 + 192 ]

P992: !_DWST [1] (maybe <- 0x3f800111) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
! 1 th moved, current_fp_src=21 
fmovs  %f16, %f21
fadds  %f16, %f17, %f16
std %f20, [%i0 + 0]

P993: !_LD [2] (FP)
ld [%i0 + 12], %f4
! 1 addresses covered

P994: !_LD [15] (FP)
ld [%i3 + 192], %f5
! 1 addresses covered

P995: !_DWST [4] (maybe <- 0x3f800113) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
std %f20, [%i0 + 64]

P996: !_LD [12] (FP)
ld [%i3 + 0], %f6
! 1 addresses covered

P997: !_PREFETCH [4] (Int)
prefetch [%i0 + 64], 1

P998: !_NOP (Int)
nop

P999: !_REPLACEMENT [13] (Int)
sethi %hi(0x40), %l3
or %l3, %lo(0x40),  %l3
sethi %hi(0x10000), %l6
or %l6, %lo(0x10000),  %l6
add %i3, %l3, %l3
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]

P1000: !_MEMBAR (Int)
membar #StoreLoad

P1001: !_MEMBAR (Int)
membar #StoreLoad

P1002: !_LD [0] (FP)
ld [%i0 + 0], %f7
! 1 addresses covered

P1003: !_LD [1] (FP) (CBR)
ld [%i0 + 4], %f8
! 1 addresses covered

! cbranch
andcc %l0, 1, %g0
be,pt  %xcc, TARGET1003
nop
RET1003:

! lfsr step begin
srlx %l0, 1, %o5
xnor %o5, %l0, %o5
sllx %o5, 63, %o5
or  %o5, %l0, %l0
srlx %l0, 1, %l0


P1004: !_LD [2] (FP)
ld [%i0 + 12], %f9
! 1 addresses covered

P1005: !_LD [3] (FP)
ld [%i0 + 32], %f10
! 1 addresses covered

P1006: !_LD [4] (FP)
ld [%i0 + 64], %f11
! 1 addresses covered

P1007: !_LD [5] (FP)
ld [%i1 + 76], %f12
! 1 addresses covered

P1008: !_LD [6] (FP)
ld [%i1 + 80], %f13
! 1 addresses covered

P1009: !_LD [7] (FP)
ld [%i1 + 84], %f14
! 1 addresses covered

P1010: !_LD [8] (FP)
ld [%i1 + 256], %f15
! 1 addresses covered
!---- flushing fp results buffer to %f30 ----
fmovd %f0, %f30
fmovd %f2, %f30
fmovd %f4, %f30
fmovd %f6, %f30
fmovd %f8, %f30
fmovd %f10, %f30
fmovd %f12, %f30
fmovd %f14, %f30

P1011: !_LD [9] (FP)
ld [%i1 + 512], %f0
! 1 addresses covered

P1012: !_LD [10] (FP)
ld [%i2 + 32], %f1
! 1 addresses covered

P1013: !_LD [11] (FP)
ld [%i2 + 64], %f2
! 1 addresses covered

P1014: !_LD [12] (FP)
ld [%i3 + 0], %f3
! 1 addresses covered

P1015: !_LD [13] (FP)
ld [%i3 + 64], %f4
! 1 addresses covered

P1016: !_LD [14] (FP)
ld [%i3 + 128], %f5
! 1 addresses covered

P1017: !_LD [15] (FP)
ld [%i3 + 192], %f6
! 1 addresses covered

END_NODES0: ! Test istream for CPU 0 ends
sethi %hi(0xdead0e0f), %l3
or    %l3, %lo(0xdead0e0f), %l3
! move %l3(lower) -> %o3(upper)
sllx %l3, 32, %o3
stw %l3, [%i5] 
ld [%i5], %f7
!---- flushing int results buffer----
mov %o0, %l5
mov %o1, %l5
mov %o2, %l5
mov %o3, %l5
!---- flushing fp results buffer to %f30 ----
fmovd %f0, %f30
fmovd %f2, %f30
fmovd %f4, %f30
fmovd %f6, %f30

restore
retl
nop
!-----------------

! register usage:
! %i0 %i1 %i2 %i3 : base registers for 4 regions
! %i4 fixed pointer to per-cpu results area
! %l1 moving pointer to per-cpu FP results area
! %o7 moving pointer to per-cpu integer results area
! %i5 pointer to per-cpu private area
! %l0 holds lfsr, used as source of random bits 
! %l2 loop count register
! %f16 running counter for unique fp store values
! %f17 holds increment value for fp counter
! %l4 running counter for unique integer store values (increment value is always 1)
! %l5 move-to register for load values (simulation only)
! %f30 move-to register for FP values (simulation only)
! %l3 %l6 %l7 %o5 : 4 temporary registers
! %o0 %o1 %o2 %o3 %o4 : 5 integer results buffer registers
! %f0-f15 FP results buffer registers
! %f32-f47 FP block load/store registers

func1:
! 1000 (dynamic) instruction sequence begins
save   %sp, -192, %sp

! Force %i0-%i3 to be 64-byte aligned
add %i0, 63, %i0
andn %i0, 63, %i0

add %i1, 63, %i1
andn %i1, 63, %i1

add %i2, 63, %i2
andn %i2, 63, %i2

add %i3, 63, %i3
andn %i3, 63, %i3

add %i4, 63, %i4
andn %i4, 63, %i4

add %i5, 63, %i5
andn %i5, 63, %i5


! Initialize pointer to FP load results area
mov   %i4, %l1

! Initialize pointer to integer load results area
sethi %hi(0x80000), %o7
or    %o7, %lo(0x80000), %o7
add  %o7, %l1, %o7 

! Initialize %f0-%f62 to 0xdeadbee0deadbee1
sethi %hi(0xdeadbee0), %o5
or    %o5, %lo(0xdeadbee0), %o5
stw   %o5, [%i5]
sethi %hi(0xdeadbee1), %o5
or    %o5, %lo(0xdeadbee1), %o5
stw   %o5, [%i5+4]
ldd [%i5], %f0
fmovd %f0, %f2
fmovd %f0, %f4
fmovd %f0, %f6
fmovd %f0, %f8
fmovd %f0, %f10
fmovd %f0, %f12
fmovd %f0, %f14
fmovd %f0, %f16
fmovd %f0, %f18
fmovd %f0, %f20
fmovd %f0, %f22
fmovd %f0, %f24
fmovd %f0, %f26
fmovd %f0, %f28
fmovd %f0, %f30
fmovd %f0, %f32
fmovd %f0, %f34
fmovd %f0, %f36
fmovd %f0, %f38
fmovd %f0, %f40
fmovd %f0, %f42
fmovd %f0, %f44
fmovd %f0, %f46
fmovd %f0, %f48
fmovd %f0, %f50
fmovd %f0, %f52
fmovd %f0, %f54
fmovd %f0, %f56
fmovd %f0, %f58
fmovd %f0, %f60
fmovd %f0, %f62

! Signature for extract_loads script to start extracting load values for this stream
sethi %hi(0x01deade1), %o5
or    %o5, %lo(0x01deade1), %o5
stw %o5, [%i5] 
ld [%i5], %f16

! Initialize running integer counter in register %l4
sethi %hi(0x800001), %l4
or    %l4, %lo(0x800001), %l4

! Initialize running FP counter in register %f16
sethi %hi(0x40000001), %o5
or    %o5, %lo(0x40000001), %o5
stw %o5, [%i5] 
ld [%i5], %f16

! Initialize FP counter increment value in register %f17 (constant)
sethi %hi(0x34800000), %o5
or    %o5, %lo(0x34800000), %o5
stw %o5, [%i5] 
ld [%i5], %f17 

! Initialize LFSR to 0x1c0e^4
sethi %hi(0x1c0e), %l0
or    %l0, %lo(0x1c0e), %l0
mulx  %l0, %l0, %l0
mulx  %l0, %l0, %l0

!-- init shared addrs 2 to 3 ---
stx %g0, [%i0+8]
stx %g0, [%i0+32]

! use untouched cache-line (offset 4K) in replacement area for sync
sub %i1, %i0, %l3
add %i3, %l3, %l3
sub %l3, -4096, %l3

!-- begin of sync_init ---
or %g0, 1, %l6
or %g0, %l6, %l7
swap [%l3+4], %l7
membar #Sync
sync_init_1_1:
brnz,pt %l6, sync_init_1_1
lduw [%l3+4], %l6 ! delay slot
sync_init_2_1:
lduw [%l3], %l6
sub %l6, 1, %l7
cas [%l3], %l6, %l7
cmp %l6, %l7
bne,pt %xcc, sync_init_2_1
nop
membar #Sync
sync_init_3_1:
lduw [%l3], %l6 ! delay slot
brnz,pt %l6, sync_init_3_1
nop
!-- end of sync_init ---


BEGIN_NODES1: ! Test istream for CPU 1 begins

P1018: !_DWLD [7] (FP)
ldd [%i1 + 80], %f0
! 2 addresses covered

P1019: !_ST [2] (maybe <- 0x40000001) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i0 + 12 ]

P1020: !_LD [2] (FP)
ld [%i0 + 12], %f2
! 1 addresses covered

P1021: !_ST [10] (maybe <- 0x40000002) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i2 + 32 ]

P1022: !_PREFETCH [13] (Int)
prefetch [%i3 + 64], 1

P1023: !_PREFETCH [1] (Int)
prefetch [%i0 + 4], 1

P1024: !_ST [15] (maybe <- 0x40000003) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i3 + 192 ]

P1025: !_DWST [2] (maybe <- 0x40000004) (FP)
! 0 th moved, current_fp_src=21 
fmovs  %f16, %f21
fadds  %f16, %f17, %f16
std %f20, [%i0 + 8]

P1026: !_CAS [9] (maybe <- 0x800001) (Int) (LE)
! Change single-word-level endianess (big endian <-> little endian) 
sethi %hi(0xff00ff00), %l3
or %l3, %lo(0xff00ff00), %l3
and %l4, %l3, %o5
srl %o5, 8, %o5
sll %l4, 8, %l6
and %l6, %l3, %l6
or %l6, %o5, %l6
srl %l6, 16, %o5
sll %l6, 16, %l6
srl %l6, 0, %l6
or %l6, %o5, %l6
wr %g0, 0x88, %asi
add %i1, 512, %l3
lduwa [%l3] %asi, %o0
mov %o0, %o5
! move %o5(lower) -> %o0(upper)
sllx %o5, 32, %o0
mov %l6, %l7
casa [%l3] %asi, %o5, %l7
! move %l7(lower) -> %o0(lower)
srl %l7, 0, %l3
or %l3, %o0, %o0
add   %l4, 1, %l4

P1027: !_REPLACEMENT [14] (Int)
sethi %hi(0x80), %o5
or %o5, %lo(0x80),  %o5
sethi %hi(0x10000), %l3
or %l3, %lo(0x10000),  %l3
add %i3, %o5, %o5
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]

P1028: !_DWLD [10] (FP)
ldd [%i2 + 32], %f18
! 1 addresses covered
fmovs %f18, %f3

P1029: !_DWST [8] (maybe <- 0x40000005) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
std %f20, [%i1 + 256]

P1030: !_PREFETCH [0] (Int)
prefetch [%i0 + 0], 1

P1031: !_SWAP [11] (maybe <- 0x800002) (Int)
mov %l4, %o1
swap  [%i2 + 64], %o1
! move %o1(lower) -> %o1(upper)
sllx %o1, 32, %o1
add   %l4, 1, %l4

P1032: !_PREFETCH [5] (Int) (CBR)
prefetch [%i1 + 76], 1

! cbranch
andcc %l0, 1, %g0
be,pt  %xcc, TARGET1032
nop
RET1032:

! lfsr step begin
srlx %l0, 1, %l3
xnor %l3, %l0, %l3
sllx %l3, 63, %l3
or  %l3, %l0, %l0
srlx %l0, 1, %l0


P1033: !_REPLACEMENT [3] (Int)
sethi %hi(0x20), %l6
or %l6, %lo(0x20),  %l6
sethi %hi(0x10000), %l7
or %l7, %lo(0x10000),  %l7
add %i3, %l6, %l6
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]

P1034: !_LD [10] (FP)
ld [%i2 + 32], %f4
! 1 addresses covered

P1035: !_DWLD [2] (FP)
ldd [%i0 + 8], %f18
! 1 addresses covered
fmovs %f19, %f5

P1036: !_LD [1] (FP)
ld [%i0 + 4], %f6
! 1 addresses covered

P1037: !_ST [13] (maybe <- 0x40000006) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i3 + 64 ]

P1038: !_CASX [9] (maybe <- 0x800003) (Int)
add %i1, 512, %l3
ldx [%l3], %l7
! move %l7(upper) -> %o1(lower)
srlx %l7, 32, %o5
or %o5, %o1, %o1
! move %l7(lower) -> %o2(upper)
sllx %l7, 32, %o2
mov  %l7, %o5
sllx %l4, 32, %l7
casx [%l3], %o5, %l7
! move %l7(upper) -> %o2(lower)
srlx %l7, 32, %l3
or %l3, %o2, %o2
! move %l7(lower) -> %o3(upper)
sllx %l7, 32, %o3
add  %l4, 1, %l4

P1039: !_LD [8] (FP)
ld [%i1 + 256], %f7
! 1 addresses covered

P1040: !_REPLACEMENT [14] (Int)
sethi %hi(0x80), %o5
or %o5, %lo(0x80),  %o5
sethi %hi(0x10000), %l3
or %l3, %lo(0x10000),  %l3
add %i3, %o5, %o5
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]

P1041: !_LD [11] (FP)
ld [%i2 + 64], %f8
! 1 addresses covered

P1042: !_SWAP [11] (maybe <- 0x800004) (Int)
mov %l4, %l3
swap  [%i2 + 64], %l3
! move %l3(lower) -> %o3(lower)
srl %l3, 0, %l7
or %l7, %o3, %o3
add   %l4, 1, %l4

P1043: !_REPLACEMENT [4] (Int)
sethi %hi(0x40), %l6
or %l6, %lo(0x40),  %l6
sethi %hi(0x10000), %l7
or %l7, %lo(0x10000),  %l7
add %i3, %l6, %l6
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]

P1044: !_PREFETCH [11] (Int)
prefetch [%i2 + 64], 1

P1045: !_CAS [8] (maybe <- 0x800005) (Int)
add %i1, 256, %l6
lduw [%l6], %o4
mov %o4, %l3
! move %l3(lower) -> %o4(upper)
sllx %l3, 32, %o4
mov %l4, %o5
cas [%l6], %l3, %o5
! move %o5(lower) -> %o4(lower)
srl %o5, 0, %l6
or %l6, %o4, %o4
!---- flushing int results buffer----
mov %o0, %l5
mov %o1, %l5
mov %o2, %l5
mov %o3, %l5
mov %o4, %l5
add   %l4, 1, %l4

P1046: !_PREFETCH [13] (Int)
prefetch [%i3 + 64], 1

P1047: !_LD [15] (FP)
ld [%i3 + 192], %f9
! 1 addresses covered

P1048: !_ST [5] (maybe <- 0x40000007) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i1 + 76 ]

P1049: !_SWAP [8] (maybe <- 0x800006) (Int)
mov %l4, %o0
swap  [%i1 + 256], %o0
! move %o0(lower) -> %o0(upper)
sllx %o0, 32, %o0
add   %l4, 1, %l4

P1050: !_DWST [4] (maybe <- 0x40000008) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
std %f20, [%i0 + 64]

P1051: !_PREFETCH [4] (Int)
prefetch [%i0 + 64], 1

P1052: !_DWLD [6] (FP)
ldd [%i1 + 80], %f10
! 2 addresses covered

P1053: !_DWST [2] (maybe <- 0x40000009) (FP)
! 0 th moved, current_fp_src=21 
fmovs  %f16, %f21
fadds  %f16, %f17, %f16
std %f20, [%i0 + 8]

P1054: !_SWAP [2] (maybe <- 0x800007) (Int)
mov %l4, %l7
swap  [%i0 + 12], %l7
! move %l7(lower) -> %o0(lower)
srl %l7, 0, %l3
or %l3, %o0, %o0
add   %l4, 1, %l4

P1055: !_REPLACEMENT [6] (Int)
sethi %hi(0x50), %o5
or %o5, %lo(0x50),  %o5
sethi %hi(0x10000), %l3
or %l3, %lo(0x10000),  %l3
add %i3, %o5, %o5
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]

P1056: !_DWLD [10] (FP)
ldd [%i2 + 32], %f12
! 1 addresses covered

P1057: !_LD [1] (FP)
ld [%i0 + 4], %f13
! 1 addresses covered

P1058: !_DWST [14] (maybe <- 0x4000000a) (FP) (Branch target of P1590)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
std %f20, [%i3 + 128]
ba P1059
nop

TARGET1590:
ba RET1590
nop


P1059: !_REPLACEMENT [12] (Int) (Branch target of P1535)
sethi %hi(0x0), %l6
or %l6, %lo(0x0),  %l6
sethi %hi(0x10000), %l7
or %l7, %lo(0x10000),  %l7
add %i3, %l6, %l6
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
ba P1060
nop

TARGET1535:
ba RET1535
nop


P1060: !_REPLACEMENT [3] (Int)
sethi %hi(0x20), %l3
or %l3, %lo(0x20),  %l3
sethi %hi(0x10000), %l6
or %l6, %lo(0x10000),  %l6
add %i3, %l3, %l3
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]

P1061: !_LD [10] (FP)
ld [%i2 + 32], %f14
! 1 addresses covered

P1062: !_REPLACEMENT [3] (Int)
sethi %hi(0x20), %o5
or %o5, %lo(0x20),  %o5
sethi %hi(0x10000), %l3
or %l3, %lo(0x10000),  %l3
add %i3, %o5, %o5
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]

P1063: !_DWLD [12] (FP)
ldd [%i3 + 0], %f18
! 1 addresses covered
fmovs %f18, %f15
!---- flushing fp results buffer to %f30 ----
fmovd %f0, %f30
fmovd %f2, %f30
fmovd %f4, %f30
fmovd %f6, %f30
fmovd %f8, %f30
fmovd %f10, %f30
fmovd %f12, %f30
fmovd %f14, %f30

P1064: !_SWAP [4] (maybe <- 0x800008) (Int)
mov %l4, %o1
swap  [%i0 + 64], %o1
! move %o1(lower) -> %o1(upper)
sllx %o1, 32, %o1
add   %l4, 1, %l4

P1065: !_LD [12] (FP)
ld [%i3 + 0], %f0
! 1 addresses covered

P1066: !_ST [8] (maybe <- 0x4000000b) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i1 + 256 ]

P1067: !_PREFETCH [4] (Int)
prefetch [%i0 + 64], 1

P1068: !_DWLD [9] (FP)
ldd [%i1 + 512], %f18
! 1 addresses covered
fmovs %f18, %f1

P1069: !_PREFETCH [3] (Int)
prefetch [%i0 + 32], 1

P1070: !_LD [8] (FP)
ld [%i1 + 256], %f2
! 1 addresses covered

P1071: !_DWLD [2] (FP)
ldd [%i0 + 8], %f18
! 1 addresses covered
fmovs %f19, %f3

P1072: !_ST [1] (maybe <- 0x4000000c) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i0 + 4 ]

P1073: !_ST [5] (maybe <- 0x4000000d) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i1 + 76 ]

P1074: !_ST [5] (maybe <- 0x4000000e) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i1 + 76 ]

P1075: !_SWAP [4] (maybe <- 0x800009) (Int)
mov %l4, %o5
swap  [%i0 + 64], %o5
! move %o5(lower) -> %o1(lower)
srl %o5, 0, %l6
or %l6, %o1, %o1
add   %l4, 1, %l4

P1076: !_DWST [8] (maybe <- 0x4000000f) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
std %f20, [%i1 + 256]

P1077: !_LD [6] (FP)
ld [%i1 + 80], %f4
! 1 addresses covered

P1078: !_REPLACEMENT [11] (Int) (Branch target of P1517)
sethi %hi(0x40), %o5
or %o5, %lo(0x40),  %o5
sethi %hi(0x10000), %l3
or %l3, %lo(0x10000),  %l3
add %i3, %o5, %o5
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
ba P1079
nop

TARGET1517:
ba RET1517
nop


P1079: !_ST [4] (maybe <- 0x40000010) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i0 + 64 ]

P1080: !_ST [12] (maybe <- 0x40000011) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i3 + 0 ]

P1081: !_LD [2] (FP)
ld [%i0 + 12], %f5
! 1 addresses covered

P1082: !_LD [6] (FP)
ld [%i1 + 80], %f6
! 1 addresses covered

P1083: !_SWAP [8] (maybe <- 0x80000a) (Int) (Branch target of P1758)
mov %l4, %o2
swap  [%i1 + 256], %o2
! move %o2(lower) -> %o2(upper)
sllx %o2, 32, %o2
add   %l4, 1, %l4
ba P1084
nop

TARGET1758:
ba RET1758
nop


P1084: !_REPLACEMENT [2] (Int)
sethi %hi(0xc), %o5
or %o5, %lo(0xc),  %o5
sethi %hi(0x10000), %l3
or %l3, %lo(0x10000),  %l3
add %i3, %o5, %o5
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]

P1085: !_SWAP [0] (maybe <- 0x80000b) (Int)
mov %l4, %l3
swap  [%i0 + 0], %l3
! move %l3(lower) -> %o2(lower)
srl %l3, 0, %l7
or %l7, %o2, %o2
add   %l4, 1, %l4

P1086: !_REPLACEMENT [5] (Int)
sethi %hi(0x4c), %l6
or %l6, %lo(0x4c),  %l6
sethi %hi(0x10000), %l7
or %l7, %lo(0x10000),  %l7
add %i3, %l6, %l6
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]

P1087: !_REPLACEMENT [14] (Int)
sethi %hi(0x80), %l3
or %l3, %lo(0x80),  %l3
sethi %hi(0x10000), %l6
or %l6, %lo(0x10000),  %l6
add %i3, %l3, %l3
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]

P1088: !_PREFETCH [0] (Int)
prefetch [%i0 + 0], 1

P1089: !_DWST [12] (maybe <- 0x40000012) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
std %f20, [%i3 + 0]

P1090: !_DWLD [3] (FP)
ldd [%i0 + 32], %f18
! 1 addresses covered
fmovs %f18, %f7

P1091: !_LD [5] (FP)
ld [%i1 + 76], %f8
! 1 addresses covered

P1092: !_SWAP [7] (maybe <- 0x80000c) (Int) (Branch target of P1149)
mov %l4, %o3
swap  [%i1 + 84], %o3
! move %o3(lower) -> %o3(upper)
sllx %o3, 32, %o3
add   %l4, 1, %l4
ba P1093
nop

TARGET1149:
ba RET1149
nop


P1093: !_CASX [4] (maybe <- 0x80000d) (Int)
add %i0, 64, %l7
ldx [%l7], %l3
! move %l3(upper) -> %o3(lower)
srlx %l3, 32, %l6
or %l6, %o3, %o3
! move %l3(lower) -> %o4(upper)
sllx %l3, 32, %o4
mov  %l3, %l6
sllx %l4, 32, %l3
casx [%l7], %l6, %l3
! move %l3(upper) -> %o4(lower)
srlx %l3, 32, %l7
or %l7, %o4, %o4
!---- flushing int results buffer----
mov %o0, %l5
mov %o1, %l5
mov %o2, %l5
mov %o3, %l5
mov %o4, %l5
! move %l3(lower) -> %o0(upper)
sllx %l3, 32, %o0
add  %l4, 1, %l4

P1094: !_LD [5] (FP)
ld [%i1 + 76], %f9
! 1 addresses covered

P1095: !_DWLD [6] (FP)
ldd [%i1 + 80], %f10
! 2 addresses covered

P1096: !_DWST [6] (maybe <- 0x40000013) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
! 1 th moved, current_fp_src=21 
fmovs  %f16, %f21
fadds  %f16, %f17, %f16
std %f20, [%i1 + 80]

P1097: !_ST [14] (maybe <- 0x40000015) (FP) (Branch target of P1400)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i3 + 128 ]
ba P1098
nop

TARGET1400:
ba RET1400
nop


P1098: !_ST [3] (maybe <- 0x40000016) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i0 + 32 ]

P1099: !_DWLD [8] (FP)
ldd [%i1 + 256], %f12
! 1 addresses covered

P1100: !_PREFETCH [2] (Int)
prefetch [%i0 + 12], 1

P1101: !_LD [11] (FP)
ld [%i2 + 64], %f13
! 1 addresses covered

P1102: !_CASX [2] (maybe <- 0x80000e) (Int)
add %i0, 8, %o5
ldx [%o5], %l6
! move %l6(upper) -> %o0(lower)
srlx %l6, 32, %l7
or %l7, %o0, %o0
! move %l6(lower) -> %o1(upper)
sllx %l6, 32, %o1
mov  %l6, %l7
mov %l4, %l6
casx [%o5], %l7, %l6
! move %l6(upper) -> %o1(lower)
srlx %l6, 32, %o5
or %o5, %o1, %o1
! move %l6(lower) -> %o2(upper)
sllx %l6, 32, %o2
add  %l4, 1, %l4

P1103: !_DWST [13] (maybe <- 0x40000017) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
std %f20, [%i3 + 64]

P1104: !_SWAP [8] (maybe <- 0x80000f) (Int) (LE)
wr %g0, 0x88, %asi
mov %l4, %o5
! Change single-word-level endianess (big endian <-> little endian) 
sethi %hi(0xff00ff00), %l6
or %l6, %lo(0xff00ff00), %l6
and %o5, %l6, %l7
srl %l7, 8, %l7
sll %o5, 8, %o5
and %o5, %l6, %o5
or %o5, %l7, %o5
srl %o5, 16, %l7
sll %o5, 16, %o5
srl %o5, 0, %o5
or %o5, %l7, %o5
swapa  [%i1 + 256] %asi, %o5
! move %o5(lower) -> %o2(lower)
srl %o5, 0, %l6
or %l6, %o2, %o2
add   %l4, 1, %l4

P1105: !_LD [1] (FP)
ld [%i0 + 4], %f14
! 1 addresses covered

P1106: !_DWLD [8] (FP)
ldd [%i1 + 256], %f18
! 1 addresses covered
fmovs %f18, %f15
!---- flushing fp results buffer to %f30 ----
fmovd %f0, %f30
fmovd %f2, %f30
fmovd %f4, %f30
fmovd %f6, %f30
fmovd %f8, %f30
fmovd %f10, %f30
fmovd %f12, %f30
fmovd %f14, %f30

P1107: !_DWLD [2] (FP)
ldd [%i0 + 8], %f0
! 1 addresses covered
fmovs %f1, %f0

P1108: !_PREFETCH [5] (Int)
prefetch [%i1 + 76], 1

P1109: !_ST [3] (maybe <- 0x40000018) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i0 + 32 ]

P1110: !_REPLACEMENT [13] (Int)
sethi %hi(0x40), %o5
or %o5, %lo(0x40),  %o5
sethi %hi(0x10000), %l3
or %l3, %lo(0x10000),  %l3
add %i3, %o5, %o5
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]

P1111: !_DWLD [5] (FP)
ldd [%i1 + 72], %f18
! 1 addresses covered
fmovs %f19, %f1

P1112: !_DWLD [6] (FP)
ldd [%i1 + 80], %f2
! 2 addresses covered

P1113: !_ST [10] (maybe <- 0x40000019) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i2 + 32 ]

P1114: !_REPLACEMENT [8] (Int)
sethi %hi(0x100), %l6
or %l6, %lo(0x100),  %l6
sethi %hi(0x10000), %l7
or %l7, %lo(0x10000),  %l7
add %i3, %l6, %l6
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]

P1115: !_DWLD [12] (FP)
ldd [%i3 + 0], %f4
! 1 addresses covered

P1116: !_ST [8] (maybe <- 0x4000001a) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i1 + 256 ]

P1117: !_ST [10] (maybe <- 0x4000001b) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i2 + 32 ]

P1118: !_LD [0] (FP)
ld [%i0 + 0], %f5
! 1 addresses covered

P1119: !_LD [1] (FP)
ld [%i0 + 4], %f6
! 1 addresses covered

P1120: !_CAS [1] (maybe <- 0x800010) (Int) (LE)
! Change single-word-level endianess (big endian <-> little endian) 
sethi %hi(0xff00ff00), %o5
or %o5, %lo(0xff00ff00), %o5
and %l4, %o5, %l7
srl %l7, 8, %l7
sll %l4, 8, %l3
and %l3, %o5, %l3
or %l3, %l7, %l3
srl %l3, 16, %l7
sll %l3, 16, %l3
srl %l3, 0, %l3
or %l3, %l7, %l3
wr %g0, 0x88, %asi
add %i0, 4, %o5
lduwa [%o5] %asi, %o3
mov %o3, %l7
! move %l7(lower) -> %o3(upper)
sllx %l7, 32, %o3
mov %l3, %l6
casa [%o5] %asi, %l7, %l6
! move %l6(lower) -> %o3(lower)
srl %l6, 0, %o5
or %o5, %o3, %o3
add   %l4, 1, %l4

P1121: !_ST [11] (maybe <- 0x4000001c) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i2 + 64 ]

P1122: !_PREFETCH [14] (Int)
prefetch [%i3 + 128], 1

P1123: !_CASX [15] (maybe <- 0x800011) (Int)
add %i3, 192, %l7
ldx [%l7], %o4
! move %o4(upper) -> %o4(upper)
! move %o4(lower) -> %o4(lower)
!---- flushing int results buffer----
mov %o0, %l5
mov %o1, %l5
mov %o2, %l5
mov %o3, %l5
mov %o4, %l5
mov  %o4, %l6
sllx %l4, 32, %o0
casx [%l7], %l6, %o0
! move %o0(upper) -> %o0(upper)
! move %o0(lower) -> %o0(lower)
add  %l4, 1, %l4

P1124: !_DWLD [14] (FP)
ldd [%i3 + 128], %f18
! 1 addresses covered
fmovs %f18, %f7

P1125: !_DWLD [15] (FP)
ldd [%i3 + 192], %f8
! 1 addresses covered

P1126: !_PREFETCH [10] (Int)
prefetch [%i2 + 32], 1

P1127: !_REPLACEMENT [6] (Int)
sethi %hi(0x50), %l6
or %l6, %lo(0x50),  %l6
sethi %hi(0x10000), %l7
or %l7, %lo(0x10000),  %l7
add %i3, %l6, %l6
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]

P1128: !_DWST [11] (maybe <- 0x4000001d) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
std %f20, [%i2 + 64]

P1129: !_CASX [3] (maybe <- 0x800012) (Int)
add %i0, 32, %l3
ldx [%l3], %o1
! move %o1(upper) -> %o1(upper)
! move %o1(lower) -> %o1(lower)
mov  %o1, %o5
sllx %l4, 32, %o2
casx [%l3], %o5, %o2
! move %o2(upper) -> %o2(upper)
! move %o2(lower) -> %o2(lower)
add  %l4, 1, %l4

P1130: !_LD [2] (FP)
ld [%i0 + 12], %f9
! 1 addresses covered

P1131: !_DWST [8] (maybe <- 0x4000001e) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
std %f20, [%i1 + 256]

P1132: !_PREFETCH [0] (Int)
prefetch [%i0 + 0], 1

P1133: !_DWLD [1] (FP)
ldd [%i0 + 0], %f10
! 2 addresses covered

P1134: !_REPLACEMENT [7] (Int)
sethi %hi(0x54), %l7
or %l7, %lo(0x54),  %l7
sethi %hi(0x10000), %o5
or %o5, %lo(0x10000),  %o5
add %i3, %l7, %l7
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]

P1135: !_CAS [9] (maybe <- 0x800013) (Int)
add %i1, 512, %l7
lduw [%l7], %o3
mov %o3, %l6
! move %l6(lower) -> %o3(upper)
sllx %l6, 32, %o3
mov %l4, %l3
cas [%l7], %l6, %l3
! move %l3(lower) -> %o3(lower)
srl %l3, 0, %l7
or %l7, %o3, %o3
add   %l4, 1, %l4

P1136: !_CASX [1] (maybe <- 0x800014) (Int)
add %i0, 0, %l7
ldx [%l7], %o4
! move %o4(upper) -> %o4(upper)
! move %o4(lower) -> %o4(lower)
!---- flushing int results buffer----
mov %o0, %l5
mov %o1, %l5
mov %o2, %l5
mov %o3, %l5
mov %o4, %l5
mov %o4, %l6
sllx %l4, 32, %o0
add  %l4, 1, %l4
or   %l4, %o0, %o0
casx [%l7], %l6, %o0
! move %o0(upper) -> %o0(upper)
! move %o0(lower) -> %o0(lower)
add  %l4, 1, %l4

P1137: !_PREFETCH [15] (Int)
prefetch [%i3 + 192], 1

P1138: !_SWAP [3] (maybe <- 0x800016) (Int)
mov %l4, %o1
swap  [%i0 + 32], %o1
! move %o1(lower) -> %o1(upper)
sllx %o1, 32, %o1
add   %l4, 1, %l4

P1139: !_DWST [12] (maybe <- 0x4000001f) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
std %f20, [%i3 + 0]

P1140: !_REPLACEMENT [5] (Int)
sethi %hi(0x4c), %o5
or %o5, %lo(0x4c),  %o5
sethi %hi(0x10000), %l3
or %l3, %lo(0x10000),  %l3
add %i3, %o5, %o5
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]

P1141: !_PREFETCH [0] (Int)
prefetch [%i0 + 0], 1

P1142: !_DWLD [7] (FP)
ldd [%i1 + 80], %f12
! 2 addresses covered

P1143: !_DWLD [4] (FP)
ldd [%i0 + 64], %f14
! 1 addresses covered

P1144: !_DWLD [9] (FP)
ldd [%i1 + 512], %f18
! 1 addresses covered
fmovs %f18, %f15
!---- flushing fp results buffer to %f30 ----
fmovd %f0, %f30
fmovd %f2, %f30
fmovd %f4, %f30
fmovd %f6, %f30
fmovd %f8, %f30
fmovd %f10, %f30
fmovd %f12, %f30
fmovd %f14, %f30

P1145: !_ST [7] (maybe <- 0x40000020) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i1 + 84 ]

P1146: !_REPLACEMENT [11] (Int)
sethi %hi(0x40), %l6
or %l6, %lo(0x40),  %l6
sethi %hi(0x10000), %l7
or %l7, %lo(0x10000),  %l7
add %i3, %l6, %l6
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]

P1147: !_CASX [0] (maybe <- 0x800017) (Int)
add %i0, 0, %l6
ldx [%l6], %o5
! move %o5(upper) -> %o1(lower)
srlx %o5, 32, %l3
or %l3, %o1, %o1
! move %o5(lower) -> %o2(upper)
sllx %o5, 32, %o2
mov %o5, %l3
sllx %l4, 32, %o5
add  %l4, 1, %l4
or   %l4, %o5, %o5
casx [%l6], %l3, %o5
! move %o5(upper) -> %o2(lower)
srlx %o5, 32, %l6
or %l6, %o2, %o2
! move %o5(lower) -> %o3(upper)
sllx %o5, 32, %o3
add  %l4, 1, %l4

P1148: !_DWST [8] (maybe <- 0x40000021) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
std %f20, [%i1 + 256]

P1149: !_ST [0] (maybe <- 0x40000022) (FP) (CBR)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i0 + 0 ]

! cbranch
andcc %l0, 1, %g0
be,pt  %xcc, TARGET1149
nop
RET1149:

! lfsr step begin
srlx %l0, 1, %l7
xnor %l7, %l0, %l7
sllx %l7, 63, %l7
or  %l7, %l0, %l0
srlx %l0, 1, %l0


P1150: !_LD [0] (FP)
ld [%i0 + 0], %f0
! 1 addresses covered

P1151: !_REPLACEMENT [10] (Int)
sethi %hi(0x20), %o5
or %o5, %lo(0x20),  %o5
sethi %hi(0x10000), %l3
or %l3, %lo(0x10000),  %l3
add %i3, %o5, %o5
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]

P1152: !_DWLD [5] (FP)
ldd [%i1 + 72], %f18
! 1 addresses covered
fmovs %f19, %f1

P1153: !_DWST [7] (maybe <- 0x40000023) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
! 1 th moved, current_fp_src=21 
fmovs  %f16, %f21
fadds  %f16, %f17, %f16
std %f20, [%i1 + 80]

P1154: !_DWLD [12] (FP)
ldd [%i3 + 0], %f2
! 1 addresses covered

P1155: !_DWST [6] (maybe <- 0x40000025) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
! 1 th moved, current_fp_src=21 
fmovs  %f16, %f21
fadds  %f16, %f17, %f16
std %f20, [%i1 + 80]

P1156: !_DWST [7] (maybe <- 0x40000027) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
! 1 th moved, current_fp_src=21 
fmovs  %f16, %f21
fadds  %f16, %f17, %f16
std %f20, [%i1 + 80]

P1157: !_MEMBAR (Int)
membar #StoreLoad

P1158: !_PREFETCH [10] (Int) (LE)
wr %g0, 0x88, %asi
prefetcha [%i2 + 32] %asi, 1

P1159: !_REPLACEMENT [6] (Int)
sethi %hi(0x50), %o5
or %o5, %lo(0x50),  %o5
sethi %hi(0x10000), %l3
or %l3, %lo(0x10000),  %l3
add %i3, %o5, %o5
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]

P1160: !_DWLD [8] (FP)
ldd [%i1 + 256], %f18
! 1 addresses covered
fmovs %f18, %f3

P1161: !_ST [4] (maybe <- 0x40000029) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i0 + 64 ]

P1162: !_REPLACEMENT [8] (Int)
sethi %hi(0x100), %l6
or %l6, %lo(0x100),  %l6
sethi %hi(0x10000), %l7
or %l7, %lo(0x10000),  %l7
add %i3, %l6, %l6
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]

P1163: !_CAS [4] (maybe <- 0x800019) (Int)
add %i0, 64, %l6
lduw [%l6], %o5
mov %o5, %l3
! move %l3(lower) -> %o3(lower)
or %l3, %o3, %o3
mov %l4, %o4
cas [%l6], %l3, %o4
! move %o4(lower) -> %o4(upper)
sllx %o4, 32, %o4
add   %l4, 1, %l4

P1164: !_PREFETCH [13] (Int) (Branch target of P1739)
prefetch [%i3 + 64], 1
ba P1165
nop

TARGET1739:
ba RET1739
nop


P1165: !_REPLACEMENT [5] (Int)
sethi %hi(0x4c), %l3
or %l3, %lo(0x4c),  %l3
sethi %hi(0x10000), %l6
or %l6, %lo(0x10000),  %l6
add %i3, %l3, %l3
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]

P1166: !_DWST [2] (maybe <- 0x4000002a) (FP)
! 0 th moved, current_fp_src=21 
fmovs  %f16, %f21
fadds  %f16, %f17, %f16
std %f20, [%i0 + 8]

P1167: !_DWLD [6] (FP)
ldd [%i1 + 80], %f4
! 2 addresses covered

P1168: !_MEMBAR (Int)
membar #StoreLoad

P1169: !_PREFETCH [11] (Int)
prefetch [%i2 + 64], 1

P1170: !_DWST [14] (maybe <- 0x4000002b) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
std %f20, [%i3 + 128]

P1171: !_LD [6] (FP)
ld [%i1 + 80], %f6
! 1 addresses covered

P1172: !_DWLD [7] (FP)
ldd [%i1 + 80], %f18
! 2 addresses covered
fmovs %f18, %f7
fmovs %f19, %f8

P1173: !_ST [2] (maybe <- 0x4000002c) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i0 + 12 ]

P1174: !_REPLACEMENT [5] (Int) (Branch target of P1835)
sethi %hi(0x4c), %l3
or %l3, %lo(0x4c),  %l3
sethi %hi(0x10000), %l6
or %l6, %lo(0x10000),  %l6
add %i3, %l3, %l3
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
ba P1175
nop

TARGET1835:
ba RET1835
nop


P1175: !_ST [1] (maybe <- 0x4000002d) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i0 + 4 ]

P1176: !_LD [14] (FP) (Branch target of P1973)
ld [%i3 + 128], %f9
! 1 addresses covered
ba P1177
nop

TARGET1973:
ba RET1973
nop


P1177: !_DWST [8] (maybe <- 0x4000002e) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
std %f20, [%i1 + 256]

P1178: !_NOP (Int)
nop

P1179: !_ST [6] (maybe <- 0x4000002f) (FP) (CBR)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i1 + 80 ]

! cbranch
andcc %l0, 1, %g0
be,pt  %xcc, TARGET1179
nop
RET1179:

! lfsr step begin
srlx %l0, 1, %l3
xnor %l3, %l0, %l3
sllx %l3, 63, %l3
or  %l3, %l0, %l0
srlx %l0, 1, %l0


P1180: !_LD [4] (FP)
ld [%i0 + 64], %f10
! 1 addresses covered

P1181: !_ST [1] (maybe <- 0x40000030) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i0 + 4 ]

P1182: !_ST [14] (maybe <- 0x40000031) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i3 + 128 ]

P1183: !_DWLD [6] (FP)
ldd [%i1 + 80], %f18
! 2 addresses covered
fmovs %f18, %f11
fmovs %f19, %f12

P1184: !_LD [9] (FP)
ld [%i1 + 512], %f13
! 1 addresses covered

P1185: !_PREFETCH [4] (Int)
prefetch [%i0 + 64], 1

P1186: !_ST [6] (maybe <- 0x40000032) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i1 + 80 ]

P1187: !_REPLACEMENT [9] (Int)
sethi %hi(0x200), %l7
or %l7, %lo(0x200),  %l7
sethi %hi(0x10000), %o5
or %o5, %lo(0x10000),  %o5
add %i3, %l7, %l7
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]

P1188: !_ST [15] (maybe <- 0x40000033) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i3 + 192 ]

P1189: !_ST [1] (maybe <- 0x40000034) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i0 + 4 ]

P1190: !_DWLD [14] (FP)
ldd [%i3 + 128], %f14
! 1 addresses covered

P1191: !_REPLACEMENT [13] (Int)
sethi %hi(0x40), %o5
or %o5, %lo(0x40),  %o5
sethi %hi(0x10000), %l3
or %l3, %lo(0x10000),  %l3
add %i3, %o5, %o5
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]

P1192: !_LD [15] (FP)
ld [%i3 + 192], %f15
! 1 addresses covered
!---- flushing fp results buffer to %f30 ----
fmovd %f0, %f30
fmovd %f2, %f30
fmovd %f4, %f30
fmovd %f6, %f30
fmovd %f8, %f30
fmovd %f10, %f30
fmovd %f12, %f30
fmovd %f14, %f30

P1193: !_DWST [8] (maybe <- 0x40000035) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
std %f20, [%i1 + 256]

P1194: !_ST [6] (maybe <- 0x40000036) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i1 + 80 ]

P1195: !_PREFETCH [6] (Int)
prefetch [%i1 + 80], 1

P1196: !_PREFETCH [5] (Int)
prefetch [%i1 + 76], 1

P1197: !_PREFETCH [10] (Int)
prefetch [%i2 + 32], 1

P1198: !_REPLACEMENT [11] (Int)
sethi %hi(0x40), %l3
or %l3, %lo(0x40),  %l3
sethi %hi(0x10000), %l6
or %l6, %lo(0x10000),  %l6
add %i3, %l3, %l3
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]

P1199: !_SWAP [15] (maybe <- 0x80001a) (Int)
mov %l4, %l6
swap  [%i3 + 192], %l6
! move %l6(lower) -> %o4(lower)
srl %l6, 0, %o5
or %o5, %o4, %o4
!---- flushing int results buffer----
mov %o0, %l5
mov %o1, %l5
mov %o2, %l5
mov %o3, %l5
mov %o4, %l5
add   %l4, 1, %l4

P1200: !_LD [8] (FP)
ld [%i1 + 256], %f0
! 1 addresses covered

P1201: !_ST [4] (maybe <- 0x40000037) (FP) (CBR)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i0 + 64 ]

! cbranch
andcc %l0, 1, %g0
be,pt  %xcc, TARGET1201
nop
RET1201:

! lfsr step begin
srlx %l0, 1, %l6
xnor %l6, %l0, %l6
sllx %l6, 63, %l6
or  %l6, %l0, %l0
srlx %l0, 1, %l0


P1202: !_DWST [9] (maybe <- 0x40000038) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
std %f20, [%i1 + 512]

P1203: !_LD [3] (FP)
ld [%i0 + 32], %f1
! 1 addresses covered

P1204: !_PREFETCH [4] (Int)
prefetch [%i0 + 64], 1

P1205: !_LD [10] (FP)
ld [%i2 + 32], %f2
! 1 addresses covered

P1206: !_DWLD [6] (FP)
ldd [%i1 + 80], %f18
! 2 addresses covered
fmovs %f18, %f3
fmovs %f19, %f4

P1207: !_ST [2] (maybe <- 0x40000039) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i0 + 12 ]

P1208: !_DWST [1] (maybe <- 0x4000003a) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
! 1 th moved, current_fp_src=21 
fmovs  %f16, %f21
fadds  %f16, %f17, %f16
std %f20, [%i0 + 0]

P1209: !_REPLACEMENT [4] (Int)
sethi %hi(0x40), %o5
or %o5, %lo(0x40),  %o5
sethi %hi(0x10000), %l3
or %l3, %lo(0x10000),  %l3
add %i3, %o5, %o5
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]

P1210: !_LD [6] (FP)
ld [%i1 + 80], %f5
! 1 addresses covered

P1211: !_ST [11] (maybe <- 0x4000003c) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i2 + 64 ]

P1212: !_LD [2] (FP)
ld [%i0 + 12], %f6
! 1 addresses covered

P1213: !_LD [9] (FP) (Branch target of P1401)
ld [%i1 + 512], %f7
! 1 addresses covered
ba P1214
nop

TARGET1401:
ba RET1401
nop


P1214: !_CAS [5] (maybe <- 0x80001b) (Int)
add %i1, 76, %l7
lduw [%l7], %o0
mov %o0, %l6
! move %l6(lower) -> %o0(upper)
sllx %l6, 32, %o0
mov %l4, %l3
cas [%l7], %l6, %l3
! move %l3(lower) -> %o0(lower)
srl %l3, 0, %l7
or %l7, %o0, %o0
add   %l4, 1, %l4

P1215: !_LD [1] (FP)
ld [%i0 + 4], %f8
! 1 addresses covered

P1216: !_REPLACEMENT [5] (Int)
sethi %hi(0x4c), %l6
or %l6, %lo(0x4c),  %l6
sethi %hi(0x10000), %l7
or %l7, %lo(0x10000),  %l7
add %i3, %l6, %l6
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]

P1217: !_DWST [0] (maybe <- 0x4000003d) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
! 1 th moved, current_fp_src=21 
fmovs  %f16, %f21
fadds  %f16, %f17, %f16
std %f20, [%i0 + 0]

P1218: !_REPLACEMENT [3] (Int)
sethi %hi(0x20), %o5
or %o5, %lo(0x20),  %o5
sethi %hi(0x10000), %l3
or %l3, %lo(0x10000),  %l3
add %i3, %o5, %o5
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]

P1219: !_ST [15] (maybe <- 0x4000003f) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i3 + 192 ]

P1220: !_DWLD [0] (FP)
ldd [%i0 + 0], %f18
! 2 addresses covered
fmovs %f18, %f9
fmovs %f19, %f10

P1221: !_REPLACEMENT [0] (Int)
sethi %hi(0x0), %l6
or %l6, %lo(0x0),  %l6
sethi %hi(0x10000), %l7
or %l7, %lo(0x10000),  %l7
add %i3, %l6, %l6
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]

P1222: !_REPLACEMENT [14] (Int) (Branch target of P1529)
sethi %hi(0x80), %l3
or %l3, %lo(0x80),  %l3
sethi %hi(0x10000), %l6
or %l6, %lo(0x10000),  %l6
add %i3, %l3, %l3
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
ba P1223
nop

TARGET1529:
ba RET1529
nop


P1223: !_LD [12] (FP)
ld [%i3 + 0], %f11
! 1 addresses covered

P1224: !_REPLACEMENT [1] (Int)
sethi %hi(0x4), %o5
or %o5, %lo(0x4),  %o5
sethi %hi(0x10000), %l3
or %l3, %lo(0x10000),  %l3
add %i3, %o5, %o5
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]

P1225: !_ST [5] (maybe <- 0x40000040) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i1 + 76 ]

P1226: !_ST [7] (maybe <- 0x40000041) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i1 + 84 ]

P1227: !_SWAP [10] (maybe <- 0x80001c) (Int)
mov %l4, %o1
swap  [%i2 + 32], %o1
! move %o1(lower) -> %o1(upper)
sllx %o1, 32, %o1
add   %l4, 1, %l4

P1228: !_DWST [8] (maybe <- 0x40000042) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
std %f20, [%i1 + 256]

P1229: !_DWST [0] (maybe <- 0x40000043) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
! 1 th moved, current_fp_src=21 
fmovs  %f16, %f21
fadds  %f16, %f17, %f16
std %f20, [%i0 + 0]

P1230: !_DWLD [9] (FP)
ldd [%i1 + 512], %f12
! 1 addresses covered

P1231: !_PREFETCH [12] (Int) (CBR)
prefetch [%i3 + 0], 1

! cbranch
andcc %l0, 1, %g0
be,pn  %xcc, TARGET1231
nop
RET1231:

! lfsr step begin
srlx %l0, 1, %l6
xnor %l6, %l0, %l6
sllx %l6, 63, %l6
or  %l6, %l0, %l0
srlx %l0, 1, %l0


P1232: !_PREFETCH [8] (Int)
prefetch [%i1 + 256], 1

P1233: !_DWLD [0] (FP)
ldd [%i0 + 0], %f18
! 2 addresses covered
fmovs %f18, %f13
fmovs %f19, %f14

P1234: !_REPLACEMENT [13] (Int)
sethi %hi(0x40), %l7
or %l7, %lo(0x40),  %l7
sethi %hi(0x10000), %o5
or %o5, %lo(0x10000),  %o5
add %i3, %l7, %l7
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]

P1235: !_PREFETCH [10] (Int)
prefetch [%i2 + 32], 1

P1236: !_CAS [5] (maybe <- 0x80001d) (Int)
add %i1, 76, %l7
lduw [%l7], %l3
mov %l3, %l6
! move %l6(lower) -> %o1(lower)
or %l6, %o1, %o1
mov %l4, %o2
cas [%l7], %l6, %o2
! move %o2(lower) -> %o2(upper)
sllx %o2, 32, %o2
add   %l4, 1, %l4

P1237: !_REPLACEMENT [10] (Int)
sethi %hi(0x20), %l6
or %l6, %lo(0x20),  %l6
sethi %hi(0x10000), %l7
or %l7, %lo(0x10000),  %l7
add %i3, %l6, %l6
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]

P1238: !_DWLD [2] (FP)
ldd [%i0 + 8], %f18
! 1 addresses covered
fmovs %f19, %f15
!---- flushing fp results buffer to %f30 ----
fmovd %f0, %f30
fmovd %f2, %f30
fmovd %f4, %f30
fmovd %f6, %f30
fmovd %f8, %f30
fmovd %f10, %f30
fmovd %f12, %f30
fmovd %f14, %f30

P1239: !_DWST [2] (maybe <- 0x40000045) (FP)
! 0 th moved, current_fp_src=21 
fmovs  %f16, %f21
fadds  %f16, %f17, %f16
std %f20, [%i0 + 8]

P1240: !_DWLD [9] (FP)
ldd [%i1 + 512], %f0
! 1 addresses covered

P1241: !_CASX [15] (maybe <- 0x80001e) (Int)
add %i3, 192, %l3
ldx [%l3], %l7
! move %l7(upper) -> %o2(lower)
srlx %l7, 32, %o5
or %o5, %o2, %o2
! move %l7(lower) -> %o3(upper)
sllx %l7, 32, %o3
mov  %l7, %o5
sllx %l4, 32, %l7
casx [%l3], %o5, %l7
! move %l7(upper) -> %o3(lower)
srlx %l7, 32, %l3
or %l3, %o3, %o3
! move %l7(lower) -> %o4(upper)
sllx %l7, 32, %o4
add  %l4, 1, %l4

P1242: !_PREFETCH [8] (Int)
prefetch [%i1 + 256], 1

P1243: !_ST [1] (maybe <- 0x40000046) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i0 + 4 ]

P1244: !_DWLD [11] (FP)
ldd [%i2 + 64], %f18
! 1 addresses covered
fmovs %f18, %f1

P1245: !_DWST [12] (maybe <- 0x40000047) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
std %f20, [%i3 + 0]

P1246: !_DWLD [10] (FP)
ldd [%i2 + 32], %f2
! 1 addresses covered

P1247: !_PREFETCH [4] (Int)
prefetch [%i0 + 64], 1

P1248: !_REPLACEMENT [12] (Int)
sethi %hi(0x0), %l6
or %l6, %lo(0x0),  %l6
sethi %hi(0x10000), %l7
or %l7, %lo(0x10000),  %l7
add %i3, %l6, %l6
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]

P1249: !_PREFETCH [5] (Int)
prefetch [%i1 + 76], 1

P1250: !_REPLACEMENT [7] (Int) (CBR)
sethi %hi(0x54), %l3
or %l3, %lo(0x54),  %l3
sethi %hi(0x10000), %l6
or %l6, %lo(0x10000),  %l6
add %i3, %l3, %l3
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]

! cbranch
andcc %l0, 1, %g0
be,pt  %xcc, TARGET1250
nop
RET1250:

! lfsr step begin
srlx %l0, 1, %o5
xnor %o5, %l0, %o5
sllx %o5, 63, %o5
or  %o5, %l0, %l0
srlx %l0, 1, %l0


P1251: !_DWST [15] (maybe <- 0x40000048) (FP) (Branch target of P1933)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
std %f20, [%i3 + 192]
ba P1252
nop

TARGET1933:
ba RET1933
nop


P1252: !_LD [11] (FP)
ld [%i2 + 64], %f3
! 1 addresses covered

P1253: !_ST [2] (maybe <- 0x40000049) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i0 + 12 ]

P1254: !_LD [1] (FP)
ld [%i0 + 4], %f4
! 1 addresses covered

P1255: !_CASX [4] (maybe <- 0x80001f) (Int)
add %i0, 64, %o5
ldx [%o5], %l6
! move %l6(upper) -> %o4(lower)
srlx %l6, 32, %l7
or %l7, %o4, %o4
!---- flushing int results buffer----
mov %o0, %l5
mov %o1, %l5
mov %o2, %l5
mov %o3, %l5
mov %o4, %l5
! move %l6(lower) -> %o0(upper)
sllx %l6, 32, %o0
mov  %l6, %l7
sllx %l4, 32, %l6
casx [%o5], %l7, %l6
! move %l6(upper) -> %o0(lower)
srlx %l6, 32, %o5
or %o5, %o0, %o0
! move %l6(lower) -> %o1(upper)
sllx %l6, 32, %o1
add  %l4, 1, %l4

P1256: !_ST [0] (maybe <- 0x4000004a) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i0 + 0 ]

P1257: !_SWAP [1] (maybe <- 0x800020) (Int)
mov %l4, %o5
swap  [%i0 + 4], %o5
! move %o5(lower) -> %o1(lower)
srl %o5, 0, %l6
or %l6, %o1, %o1
add   %l4, 1, %l4

P1258: !_DWLD [15] (FP)
ldd [%i3 + 192], %f18
! 1 addresses covered
fmovs %f18, %f5

P1259: !_ST [13] (maybe <- 0x4000004b) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i3 + 64 ]

P1260: !_DWST [2] (maybe <- 0x4000004c) (FP)
! 0 th moved, current_fp_src=21 
fmovs  %f16, %f21
fadds  %f16, %f17, %f16
std %f20, [%i0 + 8]

P1261: !_LD [5] (FP)
ld [%i1 + 76], %f6
! 1 addresses covered

P1262: !_LD [1] (FP)
ld [%i0 + 4], %f7
! 1 addresses covered

P1263: !_SWAP [0] (maybe <- 0x800021) (Int) (LE)
wr %g0, 0x88, %asi
mov %l4, %o2
! Change single-word-level endianess (big endian <-> little endian) 
sethi %hi(0xff00ff00), %l7
or %l7, %lo(0xff00ff00), %l7
and %o2, %l7, %o5
srl %o5, 8, %o5
sll %o2, 8, %o2
and %o2, %l7, %o2
or %o2, %o5, %o2
srl %o2, 16, %o5
sll %o2, 16, %o2
srl %o2, 0, %o2
or %o2, %o5, %o2
swapa  [%i0 + 0] %asi, %o2
! move %o2(lower) -> %o2(upper)
sllx %o2, 32, %o2
add   %l4, 1, %l4

P1264: !_CASX [4] (maybe <- 0x800022) (Int)
add %i0, 64, %l7
ldx [%l7], %l3
! move %l3(upper) -> %o2(lower)
srlx %l3, 32, %l6
or %l6, %o2, %o2
! move %l3(lower) -> %o3(upper)
sllx %l3, 32, %o3
mov  %l3, %l6
sllx %l4, 32, %l3
casx [%l7], %l6, %l3
! move %l3(upper) -> %o3(lower)
srlx %l3, 32, %l7
or %l7, %o3, %o3
! move %l3(lower) -> %o4(upper)
sllx %l3, 32, %o4
add  %l4, 1, %l4

P1265: !_REPLACEMENT [9] (Int) (Branch target of P1456)
sethi %hi(0x200), %l6
or %l6, %lo(0x200),  %l6
sethi %hi(0x10000), %l7
or %l7, %lo(0x10000),  %l7
add %i3, %l6, %l6
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
ba P1266
nop

TARGET1456:
ba RET1456
nop


P1266: !_DWST [9] (maybe <- 0x4000004d) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
std %f20, [%i1 + 512]

P1267: !_REPLACEMENT [15] (Int)
sethi %hi(0xc0), %o5
or %o5, %lo(0xc0),  %o5
sethi %hi(0x10000), %l3
or %l3, %lo(0x10000),  %l3
add %i3, %o5, %o5
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]

P1268: !_ST [2] (maybe <- 0x4000004e) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i0 + 12 ]

P1269: !_DWLD [11] (FP)
ldd [%i2 + 64], %f8
! 1 addresses covered

P1270: !_LD [1] (FP)
ld [%i0 + 4], %f9
! 1 addresses covered

P1271: !_CASX [7] (maybe <- 0x800023) (Int)
add %i1, 80, %l7
ldx [%l7], %l3
! move %l3(upper) -> %o4(lower)
srlx %l3, 32, %l6
or %l6, %o4, %o4
!---- flushing int results buffer----
mov %o0, %l5
mov %o1, %l5
mov %o2, %l5
mov %o3, %l5
mov %o4, %l5
! move %l3(lower) -> %o0(upper)
sllx %l3, 32, %o0
mov %l3, %l6
sllx %l4, 32, %l3
add  %l4, 1, %l4
or   %l4, %l3, %l3
casx [%l7], %l6, %l3
! move %l3(upper) -> %o0(lower)
srlx %l3, 32, %l7
or %l7, %o0, %o0
! move %l3(lower) -> %o1(upper)
sllx %l3, 32, %o1
add  %l4, 1, %l4

P1272: !_LD [1] (FP) (CBR)
ld [%i0 + 4], %f10
! 1 addresses covered

! cbranch
andcc %l0, 1, %g0
be,pn  %xcc, TARGET1272
nop
RET1272:

! lfsr step begin
srlx %l0, 1, %l6
xnor %l6, %l0, %l6
sllx %l6, 63, %l6
or  %l6, %l0, %l0
srlx %l0, 1, %l0


P1273: !_DWLD [12] (FP)
ldd [%i3 + 0], %f18
! 1 addresses covered
fmovs %f18, %f11

P1274: !_PREFETCH [6] (Int)
prefetch [%i1 + 80], 1

P1275: !_DWLD [6] (FP)
ldd [%i1 + 80], %f12
! 2 addresses covered

P1276: !_PREFETCH [15] (Int)
prefetch [%i3 + 192], 1

P1277: !_MEMBAR (Int)
membar #StoreLoad

P1278: !_PREFETCH [7] (Int)
prefetch [%i1 + 84], 1

P1279: !_PREFETCH [14] (Int) (Branch target of P1179)
prefetch [%i3 + 128], 1
ba P1280
nop

TARGET1179:
ba RET1179
nop


P1280: !_REPLACEMENT [11] (Int)
sethi %hi(0x40), %l7
or %l7, %lo(0x40),  %l7
sethi %hi(0x10000), %o5
or %o5, %lo(0x10000),  %o5
add %i3, %l7, %l7
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]

P1281: !_DWST [10] (maybe <- 0x4000004f) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
std %f20, [%i2 + 32]

P1282: !_MEMBAR (Int)
membar #StoreLoad

P1283: !_SWAP [14] (maybe <- 0x800025) (Int)
mov %l4, %l7
swap  [%i3 + 128], %l7
! move %l7(lower) -> %o1(lower)
srl %l7, 0, %l3
or %l3, %o1, %o1
add   %l4, 1, %l4

P1284: !_REPLACEMENT [15] (Int)
sethi %hi(0xc0), %o5
or %o5, %lo(0xc0),  %o5
sethi %hi(0x10000), %l3
or %l3, %lo(0x10000),  %l3
add %i3, %o5, %o5
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]

P1285: !_PREFETCH [15] (Int)
prefetch [%i3 + 192], 1

P1286: !_DWST [13] (maybe <- 0x40000050) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
std %f20, [%i3 + 64]

P1287: !_LD [12] (FP)
ld [%i3 + 0], %f14
! 1 addresses covered

P1288: !_REPLACEMENT [0] (Int) (Branch target of P1708)
sethi %hi(0x0), %l6
or %l6, %lo(0x0),  %l6
sethi %hi(0x10000), %l7
or %l7, %lo(0x10000),  %l7
add %i3, %l6, %l6
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
ba P1289
nop

TARGET1708:
ba RET1708
nop


P1289: !_MEMBAR (Int) (CBR)
membar #StoreLoad

! cbranch
andcc %l0, 1, %g0
be,pt  %xcc, TARGET1289
nop
RET1289:

! lfsr step begin
srlx %l0, 1, %l3
xnor %l3, %l0, %l3
sllx %l3, 63, %l3
or  %l3, %l0, %l0
srlx %l0, 1, %l0


P1290: !_PREFETCH [3] (Int)
prefetch [%i0 + 32], 1

P1291: !_CAS [13] (maybe <- 0x800026) (Int) (Branch target of P1528)
add %i3, 64, %l7
lduw [%l7], %o2
mov %o2, %l6
! move %l6(lower) -> %o2(upper)
sllx %l6, 32, %o2
mov %l4, %l3
cas [%l7], %l6, %l3
! move %l3(lower) -> %o2(lower)
srl %l3, 0, %l7
or %l7, %o2, %o2
add   %l4, 1, %l4
ba P1292
nop

TARGET1528:
ba RET1528
nop


P1292: !_DWST [12] (maybe <- 0x40000051) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
std %f20, [%i3 + 0]

P1293: !_CAS [7] (maybe <- 0x800027) (Int)
add %i1, 84, %l6
lduw [%l6], %o3
mov %o3, %l3
! move %l3(lower) -> %o3(upper)
sllx %l3, 32, %o3
mov %l4, %o5
cas [%l6], %l3, %o5
! move %o5(lower) -> %o3(lower)
srl %o5, 0, %l6
or %l6, %o3, %o3
add   %l4, 1, %l4

P1294: !_DWST [4] (maybe <- 0x40000052) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
std %f20, [%i0 + 64]

P1295: !_CASX [8] (maybe <- 0x800028) (Int)
add %i1, 256, %l3
ldx [%l3], %o4
! move %o4(upper) -> %o4(upper)
! move %o4(lower) -> %o4(lower)
!---- flushing int results buffer----
mov %o0, %l5
mov %o1, %l5
mov %o2, %l5
mov %o3, %l5
mov %o4, %l5
mov  %o4, %o5
sllx %l4, 32, %o0
casx [%l3], %o5, %o0
! move %o0(upper) -> %o0(upper)
! move %o0(lower) -> %o0(lower)
add  %l4, 1, %l4

P1296: !_REPLACEMENT [14] (Int)
sethi %hi(0x80), %o5
or %o5, %lo(0x80),  %o5
sethi %hi(0x10000), %l3
or %l3, %lo(0x10000),  %l3
add %i3, %o5, %o5
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]

P1297: !_PREFETCH [4] (Int)
prefetch [%i0 + 64], 1

P1298: !_ST [13] (maybe <- 0x40000053) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i3 + 64 ]

P1299: !_DWLD [13] (FP)
ldd [%i3 + 64], %f18
! 1 addresses covered
fmovs %f18, %f15
!---- flushing fp results buffer to %f30 ----
fmovd %f0, %f30
fmovd %f2, %f30
fmovd %f4, %f30
fmovd %f6, %f30
fmovd %f8, %f30
fmovd %f10, %f30
fmovd %f12, %f30
fmovd %f14, %f30

P1300: !_DWST [2] (maybe <- 0x40000054) (FP)
! 0 th moved, current_fp_src=21 
fmovs  %f16, %f21
fadds  %f16, %f17, %f16
std %f20, [%i0 + 8]

P1301: !_LD [9] (FP)
ld [%i1 + 512], %f0
! 1 addresses covered

P1302: !_DWST [3] (maybe <- 0x40000055) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
std %f20, [%i0 + 32]

P1303: !_DWST [5] (maybe <- 0x40000056) (FP) (Branch target of P1998)
! 0 th moved, current_fp_src=21 
fmovs  %f16, %f21
fadds  %f16, %f17, %f16
std %f20, [%i1 + 72]
ba P1304
nop

TARGET1998:
ba RET1998
nop


P1304: !_PREFETCH [10] (Int)
prefetch [%i2 + 32], 1

P1305: !_ST [0] (maybe <- 0x40000057) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i0 + 0 ]

P1306: !_DWST [12] (maybe <- 0x40000058) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
std %f20, [%i3 + 0]

P1307: !_LD [4] (FP)
ld [%i0 + 64], %f1
! 1 addresses covered

P1308: !_LD [3] (FP)
ld [%i0 + 32], %f2
! 1 addresses covered

P1309: !_REPLACEMENT [12] (Int)
sethi %hi(0x0), %l3
or %l3, %lo(0x0),  %l3
sethi %hi(0x10000), %l6
or %l6, %lo(0x10000),  %l6
add %i3, %l3, %l3
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]

P1310: !_DWLD [9] (FP)
ldd [%i1 + 512], %f18
! 1 addresses covered
fmovs %f18, %f3

P1311: !_PREFETCH [8] (Int)
prefetch [%i1 + 256], 1

P1312: !_PREFETCH [1] (Int)
prefetch [%i0 + 4], 1

P1313: !_DWST [13] (maybe <- 0x40000059) (FP) (Branch target of P1272)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
std %f20, [%i3 + 64]
ba P1314
nop

TARGET1272:
ba RET1272
nop


P1314: !_REPLACEMENT [14] (Int)
sethi %hi(0x80), %l7
or %l7, %lo(0x80),  %l7
sethi %hi(0x10000), %o5
or %o5, %lo(0x10000),  %o5
add %i3, %l7, %l7
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]

P1315: !_LD [0] (FP)
ld [%i0 + 0], %f4
! 1 addresses covered

P1316: !_DWST [2] (maybe <- 0x4000005a) (FP)
! 0 th moved, current_fp_src=21 
fmovs  %f16, %f21
fadds  %f16, %f17, %f16
std %f20, [%i0 + 8]

P1317: !_DWLD [8] (FP)
ldd [%i1 + 256], %f18
! 1 addresses covered
fmovs %f18, %f5

P1318: !_DWST [5] (maybe <- 0x4000005b) (FP)
! 0 th moved, current_fp_src=21 
fmovs  %f16, %f21
fadds  %f16, %f17, %f16
std %f20, [%i1 + 72]

P1319: !_PREFETCH [0] (Int)
prefetch [%i0 + 0], 1

P1320: !_REPLACEMENT [8] (Int)
sethi %hi(0x100), %o5
or %o5, %lo(0x100),  %o5
sethi %hi(0x10000), %l3
or %l3, %lo(0x10000),  %l3
add %i3, %o5, %o5
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]

P1321: !_LD [9] (FP)
ld [%i1 + 512], %f6
! 1 addresses covered

P1322: !_REPLACEMENT [6] (Int)
sethi %hi(0x50), %l7
or %l7, %lo(0x50),  %l7
sethi %hi(0x10000), %o5
or %o5, %lo(0x10000),  %o5
add %i3, %l7, %l7
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]

P1323: !_PREFETCH [8] (Int)
prefetch [%i1 + 256], 1

P1324: !_CAS [13] (maybe <- 0x800029) (Int)
add %i3, 64, %l7
lduw [%l7], %o1
mov %o1, %l6
! move %l6(lower) -> %o1(upper)
sllx %l6, 32, %o1
mov %l4, %l3
cas [%l7], %l6, %l3
! move %l3(lower) -> %o1(lower)
srl %l3, 0, %l7
or %l7, %o1, %o1
add   %l4, 1, %l4

P1325: !_MEMBAR (Int)
membar #StoreLoad

P1326: !_REPLACEMENT [9] (Int)
sethi %hi(0x200), %l6
or %l6, %lo(0x200),  %l6
sethi %hi(0x10000), %l7
or %l7, %lo(0x10000),  %l7
add %i3, %l6, %l6
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]

P1327: !_DWST [9] (maybe <- 0x4000005c) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
std %f20, [%i1 + 512]

P1328: !_DWLD [13] (FP)
ldd [%i3 + 64], %f18
! 1 addresses covered
fmovs %f18, %f7

P1329: !_DWST [14] (maybe <- 0x4000005d) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
std %f20, [%i3 + 128]

P1330: !_CASX [0] (maybe <- 0x80002a) (Int)
add %i0, 0, %o5
ldx [%o5], %o2
! move %o2(upper) -> %o2(upper)
! move %o2(lower) -> %o2(lower)
mov %o2, %l7
sllx %l4, 32, %o3
add  %l4, 1, %l4
or   %l4, %o3, %o3
casx [%o5], %l7, %o3
! move %o3(upper) -> %o3(upper)
! move %o3(lower) -> %o3(lower)
add  %l4, 1, %l4

P1331: !_CASX [13] (maybe <- 0x80002c) (Int)
add %i3, 64, %o5
ldx [%o5], %o4
! move %o4(upper) -> %o4(upper)
! move %o4(lower) -> %o4(lower)
!---- flushing int results buffer----
mov %o0, %l5
mov %o1, %l5
mov %o2, %l5
mov %o3, %l5
mov %o4, %l5
mov  %o4, %l7
sllx %l4, 32, %o0
casx [%o5], %l7, %o0
! move %o0(upper) -> %o0(upper)
! move %o0(lower) -> %o0(lower)
add  %l4, 1, %l4

P1332: !_PREFETCH [9] (Int)
prefetch [%i1 + 512], 1

P1333: !_ST [8] (maybe <- 0x4000005e) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i1 + 256 ]

P1334: !_PREFETCH [4] (Int)
prefetch [%i0 + 64], 1

P1335: !_ST [3] (maybe <- 0x4000005f) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i0 + 32 ]

P1336: !_REPLACEMENT [6] (Int)
sethi %hi(0x50), %l3
or %l3, %lo(0x50),  %l3
sethi %hi(0x10000), %l6
or %l6, %lo(0x10000),  %l6
add %i3, %l3, %l3
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]

P1337: !_DWLD [14] (FP) (Branch target of P1289)
ldd [%i3 + 128], %f8
! 1 addresses covered
ba P1338
nop

TARGET1289:
ba RET1289
nop


P1338: !_ST [0] (maybe <- 0x40000060) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i0 + 0 ]

P1339: !_DWST [10] (maybe <- 0x40000061) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
std %f20, [%i2 + 32]

P1340: !_DWLD [13] (FP)
ldd [%i3 + 64], %f18
! 1 addresses covered
fmovs %f18, %f9

P1341: !_PREFETCH [8] (Int)
prefetch [%i1 + 256], 1

P1342: !_CAS [14] (maybe <- 0x80002d) (Int)
add %i3, 128, %l7
lduw [%l7], %o1
mov %o1, %l6
! move %l6(lower) -> %o1(upper)
sllx %l6, 32, %o1
mov %l4, %l3
cas [%l7], %l6, %l3
! move %l3(lower) -> %o1(lower)
srl %l3, 0, %l7
or %l7, %o1, %o1
add   %l4, 1, %l4

P1343: !_REPLACEMENT [4] (Int)
sethi %hi(0x40), %l6
or %l6, %lo(0x40),  %l6
sethi %hi(0x10000), %l7
or %l7, %lo(0x10000),  %l7
add %i3, %l6, %l6
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]

P1344: !_LD [15] (FP)
ld [%i3 + 192], %f10
! 1 addresses covered

P1345: !_ST [13] (maybe <- 0x40000062) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i3 + 64 ]

P1346: !_PREFETCH [12] (Int)
prefetch [%i3 + 0], 1

P1347: !_DWLD [4] (FP)
ldd [%i0 + 64], %f18
! 1 addresses covered
fmovs %f18, %f11

P1348: !_DWLD [3] (FP)
ldd [%i0 + 32], %f12
! 1 addresses covered

P1349: !_DWST [11] (maybe <- 0x40000063) (FP) (Branch target of P2030)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
std %f20, [%i2 + 64]
ba P1350
nop

TARGET2030:
ba RET2030
nop


P1350: !_DWLD [14] (FP)
ldd [%i3 + 128], %f18
! 1 addresses covered
fmovs %f18, %f13

P1351: !_REPLACEMENT [0] (Int)
sethi %hi(0x0), %l7
or %l7, %lo(0x0),  %l7
sethi %hi(0x10000), %o5
or %o5, %lo(0x10000),  %o5
add %i3, %l7, %l7
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]

P1352: !_PREFETCH [7] (Int)
prefetch [%i1 + 84], 1

P1353: !_ST [7] (maybe <- 0x40000064) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i1 + 84 ]

P1354: !_REPLACEMENT [2] (Int)
sethi %hi(0xc), %l3
or %l3, %lo(0xc),  %l3
sethi %hi(0x10000), %l6
or %l6, %lo(0x10000),  %l6
add %i3, %l3, %l3
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]

P1355: !_ST [0] (maybe <- 0x40000065) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i0 + 0 ]

P1356: !_DWLD [9] (FP)
ldd [%i1 + 512], %f14
! 1 addresses covered

P1357: !_ST [5] (maybe <- 0x40000066) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i1 + 76 ]

P1358: !_DWST [12] (maybe <- 0x40000067) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
std %f20, [%i3 + 0]

P1359: !_REPLACEMENT [7] (Int) (Branch target of P1761)
sethi %hi(0x54), %l3
or %l3, %lo(0x54),  %l3
sethi %hi(0x10000), %l6
or %l6, %lo(0x10000),  %l6
add %i3, %l3, %l3
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
ba P1360
nop

TARGET1761:
ba RET1761
nop


P1360: !_DWST [7] (maybe <- 0x40000068) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
! 1 th moved, current_fp_src=21 
fmovs  %f16, %f21
fadds  %f16, %f17, %f16
std %f20, [%i1 + 80]

P1361: !_REPLACEMENT [3] (Int)
sethi %hi(0x20), %l7
or %l7, %lo(0x20),  %l7
sethi %hi(0x10000), %o5
or %o5, %lo(0x10000),  %o5
add %i3, %l7, %l7
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]

P1362: !_ST [7] (maybe <- 0x4000006a) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i1 + 84 ]

P1363: !_ST [12] (maybe <- 0x4000006b) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i3 + 0 ]

P1364: !_PREFETCH [15] (Int)
prefetch [%i3 + 192], 1

P1365: !_ST [5] (maybe <- 0x4000006c) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i1 + 76 ]

P1366: !_ST [4] (maybe <- 0x4000006d) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i0 + 64 ]

P1367: !_DWST [9] (maybe <- 0x4000006e) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
std %f20, [%i1 + 512]

P1368: !_DWST [12] (maybe <- 0x4000006f) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
std %f20, [%i3 + 0]

P1369: !_REPLACEMENT [4] (Int)
sethi %hi(0x40), %o5
or %o5, %lo(0x40),  %o5
sethi %hi(0x10000), %l3
or %l3, %lo(0x10000),  %l3
add %i3, %o5, %o5
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]

P1370: !_DWLD [1] (FP)
ldd [%i0 + 0], %f18
! 2 addresses covered
fmovs %f18, %f15
!---- flushing fp results buffer to %f30 ----
fmovd %f0, %f30
fmovd %f2, %f30
fmovd %f4, %f30
fmovd %f6, %f30
fmovd %f8, %f30
fmovd %f10, %f30
fmovd %f12, %f30
fmovd %f14, %f30
fmovs %f19, %f0

P1371: !_DWST [6] (maybe <- 0x40000070) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
! 1 th moved, current_fp_src=21 
fmovs  %f16, %f21
fadds  %f16, %f17, %f16
std %f20, [%i1 + 80]

P1372: !_LD [14] (FP)
ld [%i3 + 128], %f1
! 1 addresses covered

P1373: !_ST [11] (maybe <- 0x40000072) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i2 + 64 ]

P1374: !_LD [10] (FP)
ld [%i2 + 32], %f2
! 1 addresses covered

P1375: !_ST [7] (maybe <- 0x40000073) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i1 + 84 ]

P1376: !_PREFETCH [13] (Int)
prefetch [%i3 + 64], 1

P1377: !_ST [3] (maybe <- 0x40000074) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i0 + 32 ]

P1378: !_PREFETCH [10] (Int)
prefetch [%i2 + 32], 1

P1379: !_DWLD [10] (FP)
ldd [%i2 + 32], %f18
! 1 addresses covered
fmovs %f18, %f3

P1380: !_REPLACEMENT [8] (Int)
sethi %hi(0x100), %l7
or %l7, %lo(0x100),  %l7
sethi %hi(0x10000), %o5
or %o5, %lo(0x10000),  %o5
add %i3, %l7, %l7
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]

P1381: !_REPLACEMENT [8] (Int)
sethi %hi(0x100), %l6
or %l6, %lo(0x100),  %l6
sethi %hi(0x10000), %l7
or %l7, %lo(0x10000),  %l7
add %i3, %l6, %l6
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]

P1382: !_DWST [6] (maybe <- 0x40000075) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
! 1 th moved, current_fp_src=21 
fmovs  %f16, %f21
fadds  %f16, %f17, %f16
std %f20, [%i1 + 80]

P1383: !_ST [9] (maybe <- 0x40000077) (FP) (Branch target of P1420)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i1 + 512 ]
ba P1384
nop

TARGET1420:
ba RET1420
nop


P1384: !_SWAP [11] (maybe <- 0x80002e) (Int)
mov %l4, %o2
swap  [%i2 + 64], %o2
! move %o2(lower) -> %o2(upper)
sllx %o2, 32, %o2
add   %l4, 1, %l4

P1385: !_DWLD [7] (FP)
ldd [%i1 + 80], %f4
! 2 addresses covered

P1386: !_DWLD [11] (FP)
ldd [%i2 + 64], %f6
! 1 addresses covered

P1387: !_CAS [2] (maybe <- 0x80002f) (Int)
add %i0, 12, %l7
lduw [%l7], %l3
mov %l3, %l6
! move %l6(lower) -> %o2(lower)
or %l6, %o2, %o2
mov %l4, %o3
cas [%l7], %l6, %o3
! move %o3(lower) -> %o3(upper)
sllx %o3, 32, %o3
add   %l4, 1, %l4

P1388: !_DWLD [9] (FP)
ldd [%i1 + 512], %f18
! 1 addresses covered
fmovs %f18, %f7

P1389: !_LD [3] (FP)
ld [%i0 + 32], %f8
! 1 addresses covered

P1390: !_CASX [6] (maybe <- 0x800030) (Int)
add %i1, 80, %l7
ldx [%l7], %l3
! move %l3(upper) -> %o3(lower)
srlx %l3, 32, %l6
or %l6, %o3, %o3
! move %l3(lower) -> %o4(upper)
sllx %l3, 32, %o4
mov %l3, %l6
sllx %l4, 32, %l3
add  %l4, 1, %l4
or   %l4, %l3, %l3
casx [%l7], %l6, %l3
! move %l3(upper) -> %o4(lower)
srlx %l3, 32, %l7
or %l7, %o4, %o4
!---- flushing int results buffer----
mov %o0, %l5
mov %o1, %l5
mov %o2, %l5
mov %o3, %l5
mov %o4, %l5
! move %l3(lower) -> %o0(upper)
sllx %l3, 32, %o0
add  %l4, 1, %l4

P1391: !_DWLD [9] (FP)
ldd [%i1 + 512], %f18
! 1 addresses covered
fmovs %f18, %f9

P1392: !_REPLACEMENT [2] (Int)
sethi %hi(0xc), %l6
or %l6, %lo(0xc),  %l6
sethi %hi(0x10000), %l7
or %l7, %lo(0x10000),  %l7
add %i3, %l6, %l6
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]

P1393: !_LD [14] (FP)
ld [%i3 + 128], %f10
! 1 addresses covered

P1394: !_REPLACEMENT [6] (Int)
sethi %hi(0x50), %l3
or %l3, %lo(0x50),  %l3
sethi %hi(0x10000), %l6
or %l6, %lo(0x10000),  %l6
add %i3, %l3, %l3
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]

P1395: !_DWST [14] (maybe <- 0x40000078) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
std %f20, [%i3 + 128]

P1396: !_ST [4] (maybe <- 0x40000079) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i0 + 64 ]

P1397: !_CAS [12] (maybe <- 0x800032) (Int)
add %i3, 0, %l7
lduw [%l7], %l3
mov %l3, %l6
! move %l6(lower) -> %o0(lower)
or %l6, %o0, %o0
mov %l4, %o1
cas [%l7], %l6, %o1
! move %o1(lower) -> %o1(upper)
sllx %o1, 32, %o1
add   %l4, 1, %l4

P1398: !_LD [13] (FP)
ld [%i3 + 64], %f11
! 1 addresses covered

P1399: !_LD [8] (FP)
ld [%i1 + 256], %f12
! 1 addresses covered

P1400: !_LD [8] (FP) (CBR)
ld [%i1 + 256], %f13
! 1 addresses covered

! cbranch
andcc %l0, 1, %g0
be,pn  %xcc, TARGET1400
nop
RET1400:

! lfsr step begin
srlx %l0, 1, %l6
xnor %l6, %l0, %l6
sllx %l6, 63, %l6
or  %l6, %l0, %l0
srlx %l0, 1, %l0


P1401: !_ST [11] (maybe <- 0x4000007a) (FP) (CBR)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i2 + 64 ]

! cbranch
andcc %l0, 1, %g0
be,pn  %xcc, TARGET1401
nop
RET1401:

! lfsr step begin
srlx %l0, 1, %l6
xnor %l6, %l0, %l6
sllx %l6, 63, %l6
or  %l6, %l0, %l0
srlx %l0, 1, %l0


P1402: !_REPLACEMENT [14] (Int)
sethi %hi(0x80), %l7
or %l7, %lo(0x80),  %l7
sethi %hi(0x10000), %o5
or %o5, %lo(0x10000),  %o5
add %i3, %l7, %l7
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]

P1403: !_CASX [13] (maybe <- 0x800033) (Int) (LE)
! Change single-word-level endianess (big endian <-> little endian) 
sethi %hi(0xff00ff00), %l7
or %l7, %lo(0xff00ff00), %l7
and %l4, %l7, %l6
srl %l6, 8, %l6
sll %l4, 8, %o5
and %o5, %l7, %o5
or %o5, %l6, %o5
srl %o5, 16, %l6
sll %o5, 16, %o5
srl %o5, 0, %o5
or %o5, %l6, %o5
wr %g0, 0x88, %asi
add %i3, 64, %l7
ldxa [%l7] %asi, %l3
! move %l3(lower) -> %o1(lower)
srl %l3, 0, %l6
or %l6, %o1, %o1
! move %l3(upper) -> %o2(upper)
or %l3, %g0, %o2
mov  %l3, %l6
mov  %o5, %l3
casxa [%l7] %asi, %l6, %l3
! move %l3(lower) -> %o2(lower)
srlx %o2, 32, %o2
sllx %o2, 32, %o2
srl %l3, 0, %l7
or %l7, %o2, %o2
! move %l3(upper) -> %o3(upper)
or %l3, %g0, %o3
add  %l4, 1, %l4

P1404: !_MEMBAR (Int)
membar #StoreLoad

P1405: !_REPLACEMENT [0] (Int)
sethi %hi(0x0), %l6
or %l6, %lo(0x0),  %l6
sethi %hi(0x10000), %l7
or %l7, %lo(0x10000),  %l7
add %i3, %l6, %l6
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]

P1406: !_LD [1] (FP)
ld [%i0 + 4], %f14
! 1 addresses covered

P1407: !_ST [13] (maybe <- 0x4000007b) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i3 + 64 ]

P1408: !_REPLACEMENT [12] (Int)
sethi %hi(0x0), %o5
or %o5, %lo(0x0),  %o5
sethi %hi(0x10000), %l3
or %l3, %lo(0x10000),  %l3
add %i3, %o5, %o5
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]

P1409: !_PREFETCH [13] (Int) (Branch target of P1825)
prefetch [%i3 + 64], 1
ba P1410
nop

TARGET1825:
ba RET1825
nop


P1410: !_DWST [10] (maybe <- 0x4000007c) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
std %f20, [%i2 + 32]

P1411: !_REPLACEMENT [14] (Int)
sethi %hi(0x80), %l6
or %l6, %lo(0x80),  %l6
sethi %hi(0x10000), %l7
or %l7, %lo(0x10000),  %l7
add %i3, %l6, %l6
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]

P1412: !_REPLACEMENT [8] (Int) (CBR)
sethi %hi(0x100), %l3
or %l3, %lo(0x100),  %l3
sethi %hi(0x10000), %l6
or %l6, %lo(0x10000),  %l6
add %i3, %l3, %l3
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]

! cbranch
andcc %l0, 1, %g0
be,pn  %xcc, TARGET1412
nop
RET1412:

! lfsr step begin
srlx %l0, 1, %o5
xnor %o5, %l0, %o5
sllx %o5, 63, %o5
or  %o5, %l0, %l0
srlx %l0, 1, %l0


P1413: !_LD [0] (FP)
ld [%i0 + 0], %f15
! 1 addresses covered
!---- flushing fp results buffer to %f30 ----
fmovd %f0, %f30
fmovd %f2, %f30
fmovd %f4, %f30
fmovd %f6, %f30
fmovd %f8, %f30
fmovd %f10, %f30
fmovd %f12, %f30
fmovd %f14, %f30

P1414: !_LD [8] (FP)
ld [%i1 + 256], %f0
! 1 addresses covered

P1415: !_DWLD [0] (FP) (Branch target of P1412)
ldd [%i0 + 0], %f18
! 2 addresses covered
fmovs %f18, %f1
fmovs %f19, %f2
ba P1416
nop

TARGET1412:
ba RET1412
nop


P1416: !_MEMBAR (Int)
membar #StoreLoad

P1417: !_DWST [15] (maybe <- 0x4000007d) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
std %f20, [%i3 + 192]

P1418: !_NOP (Int) (Branch target of P1441)
nop
ba P1419
nop

TARGET1441:
ba RET1441
nop


P1419: !_SWAP [7] (maybe <- 0x800034) (Int)
mov %l4, %l6
swap  [%i1 + 84], %l6
! move %l6(lower) -> %o3(lower)
srlx %o3, 32, %o3
sllx %o3, 32, %o3
srl %l6, 0, %o5
or %o5, %o3, %o3
add   %l4, 1, %l4

P1420: !_REPLACEMENT [9] (Int) (CBR)
sethi %hi(0x200), %l7
or %l7, %lo(0x200),  %l7
sethi %hi(0x10000), %o5
or %o5, %lo(0x10000),  %o5
add %i3, %l7, %l7
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]

! cbranch
andcc %l0, 1, %g0
be,pn  %xcc, TARGET1420
nop
RET1420:

! lfsr step begin
srlx %l0, 1, %l6
xnor %l6, %l0, %l6
sllx %l6, 63, %l6
or  %l6, %l0, %l0
srlx %l0, 1, %l0


P1421: !_MEMBAR (Int)
membar #StoreLoad

P1422: !_LD [1] (FP)
ld [%i0 + 4], %f3
! 1 addresses covered

P1423: !_ST [15] (maybe <- 0x4000007e) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i3 + 192 ]

P1424: !_DWST [0] (maybe <- 0x4000007f) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
! 1 th moved, current_fp_src=21 
fmovs  %f16, %f21
fadds  %f16, %f17, %f16
std %f20, [%i0 + 0]

P1425: !_ST [5] (maybe <- 0x40000081) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i1 + 76 ]

P1426: !_PREFETCH [15] (Int)
prefetch [%i3 + 192], 1

P1427: !_LD [5] (FP)
ld [%i1 + 76], %f4
! 1 addresses covered

P1428: !_CAS [13] (maybe <- 0x800035) (Int)
add %i3, 64, %l3
lduw [%l3], %o4
mov %o4, %o5
! move %o5(lower) -> %o4(upper)
sllx %o5, 32, %o4
mov %l4, %l7
cas [%l3], %o5, %l7
! move %l7(lower) -> %o4(lower)
srl %l7, 0, %l3
or %l3, %o4, %o4
!---- flushing int results buffer----
mov %o0, %l5
mov %o1, %l5
mov %o2, %l5
mov %o3, %l5
mov %o4, %l5
add   %l4, 1, %l4

P1429: !_PREFETCH [3] (Int)
prefetch [%i0 + 32], 1

P1430: !_ST [2] (maybe <- 0x40000082) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i0 + 12 ]

P1431: !_ST [8] (maybe <- 0x40000083) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i1 + 256 ]

P1432: !_ST [2] (maybe <- 0x40000084) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i0 + 12 ]

P1433: !_ST [4] (maybe <- 0x40000085) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i0 + 64 ]

P1434: !_LD [9] (FP)
ld [%i1 + 512], %f5
! 1 addresses covered

P1435: !_DWST [2] (maybe <- 0x40000086) (FP)
! 0 th moved, current_fp_src=21 
fmovs  %f16, %f21
fadds  %f16, %f17, %f16
std %f20, [%i0 + 8]

P1436: !_NOP (Int) (Branch target of P1573)
nop
ba P1437
nop

TARGET1573:
ba RET1573
nop


P1437: !_REPLACEMENT [10] (Int)
sethi %hi(0x20), %l7
or %l7, %lo(0x20),  %l7
sethi %hi(0x10000), %o5
or %o5, %lo(0x10000),  %o5
add %i3, %l7, %l7
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]

P1438: !_LD [1] (FP)
ld [%i0 + 4], %f6
! 1 addresses covered

P1439: !_REPLACEMENT [0] (Int)
sethi %hi(0x0), %l6
or %l6, %lo(0x0),  %l6
sethi %hi(0x10000), %l7
or %l7, %lo(0x10000),  %l7
add %i3, %l6, %l6
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]

P1440: !_REPLACEMENT [15] (Int)
sethi %hi(0xc0), %l3
or %l3, %lo(0xc0),  %l3
sethi %hi(0x10000), %l6
or %l6, %lo(0x10000),  %l6
add %i3, %l3, %l3
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]

P1441: !_CAS [0] (maybe <- 0x800036) (Int) (CBR)
add %i0, 0, %l3
lduw [%l3], %o0
mov %o0, %o5
! move %o5(lower) -> %o0(upper)
sllx %o5, 32, %o0
mov %l4, %l7
cas [%l3], %o5, %l7
! move %l7(lower) -> %o0(lower)
srl %l7, 0, %l3
or %l3, %o0, %o0
add   %l4, 1, %l4

! cbranch
andcc %l0, 1, %g0
be,pn  %xcc, TARGET1441
nop
RET1441:

! lfsr step begin
srlx %l0, 1, %o5
xnor %o5, %l0, %o5
sllx %o5, 63, %o5
or  %o5, %l0, %l0
srlx %l0, 1, %l0


P1442: !_ST [0] (maybe <- 0x40000087) (FP) (Branch target of P1597)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i0 + 0 ]
ba P1443
nop

TARGET1597:
ba RET1597
nop


P1443: !_DWST [1] (maybe <- 0x40000088) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
! 1 th moved, current_fp_src=21 
fmovs  %f16, %f21
fadds  %f16, %f17, %f16
std %f20, [%i0 + 0]

P1444: !_CAS [14] (maybe <- 0x800037) (Int) (Branch target of P1935)
add %i3, 128, %o5
lduw [%o5], %o1
mov %o1, %l7
! move %l7(lower) -> %o1(upper)
sllx %l7, 32, %o1
mov %l4, %l6
cas [%o5], %l7, %l6
! move %l6(lower) -> %o1(lower)
srl %l6, 0, %o5
or %o5, %o1, %o1
add   %l4, 1, %l4
ba P1445
nop

TARGET1935:
ba RET1935
nop


P1445: !_LD [2] (FP) (Branch target of P1724)
ld [%i0 + 12], %f7
! 1 addresses covered
ba P1446
nop

TARGET1724:
ba RET1724
nop


P1446: !_ST [1] (maybe <- 0x4000008a) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i0 + 4 ]

P1447: !_PREFETCH [15] (Int)
prefetch [%i3 + 192], 1

P1448: !_DWST [4] (maybe <- 0x4000008b) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
std %f20, [%i0 + 64]

P1449: !_DWLD [9] (FP)
ldd [%i1 + 512], %f8
! 1 addresses covered

P1450: !_DWLD [7] (FP)
ldd [%i1 + 80], %f18
! 2 addresses covered
fmovs %f18, %f9
fmovs %f19, %f10

P1451: !_ST [6] (maybe <- 0x4000008c) (FP) (CBR)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i1 + 80 ]

! cbranch
andcc %l0, 1, %g0
be,pn  %xcc, TARGET1451
nop
RET1451:

! lfsr step begin
srlx %l0, 1, %o5
xnor %o5, %l0, %o5
sllx %o5, 63, %o5
or  %o5, %l0, %l0
srlx %l0, 1, %l0


P1452: !_CAS [11] (maybe <- 0x800038) (Int)
add %i2, 64, %l6
lduw [%l6], %o2
mov %o2, %l3
! move %l3(lower) -> %o2(upper)
sllx %l3, 32, %o2
mov %l4, %o5
cas [%l6], %l3, %o5
! move %o5(lower) -> %o2(lower)
srl %o5, 0, %l6
or %l6, %o2, %o2
add   %l4, 1, %l4

P1453: !_DWST [13] (maybe <- 0x4000008d) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
std %f20, [%i3 + 64]

P1454: !_PREFETCH [2] (Int)
prefetch [%i0 + 12], 1

P1455: !_SWAP [15] (maybe <- 0x800039) (Int)
mov %l4, %o3
swap  [%i3 + 192], %o3
! move %o3(lower) -> %o3(upper)
sllx %o3, 32, %o3
add   %l4, 1, %l4

P1456: !_CAS [8] (maybe <- 0x80003a) (Int) (CBR)
add %i1, 256, %o5
lduw [%o5], %l6
mov %l6, %l7
! move %l7(lower) -> %o3(lower)
or %l7, %o3, %o3
mov %l4, %o4
cas [%o5], %l7, %o4
! move %o4(lower) -> %o4(upper)
sllx %o4, 32, %o4
add   %l4, 1, %l4

! cbranch
andcc %l0, 1, %g0
be,pt  %xcc, TARGET1456
nop
RET1456:

! lfsr step begin
srlx %l0, 1, %l7
xnor %l7, %l0, %l7
sllx %l7, 63, %l7
or  %l7, %l0, %l0
srlx %l0, 1, %l0


P1457: !_PREFETCH [0] (Int)
prefetch [%i0 + 0], 1

P1458: !_REPLACEMENT [11] (Int)
sethi %hi(0x40), %o5
or %o5, %lo(0x40),  %o5
sethi %hi(0x10000), %l3
or %l3, %lo(0x10000),  %l3
add %i3, %o5, %o5
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]

P1459: !_ST [2] (maybe <- 0x4000008e) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i0 + 12 ]

P1460: !_ST [9] (maybe <- 0x4000008f) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i1 + 512 ]

P1461: !_LD [6] (FP)
ld [%i1 + 80], %f11
! 1 addresses covered

P1462: !_LD [6] (FP)
ld [%i1 + 80], %f12
! 1 addresses covered

P1463: !_DWST [12] (maybe <- 0x40000090) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
std %f20, [%i3 + 0]

P1464: !_DWLD [14] (FP)
ldd [%i3 + 128], %f18
! 1 addresses covered
fmovs %f18, %f13

P1465: !_PREFETCH [12] (Int) (CBR)
prefetch [%i3 + 0], 1

! cbranch
andcc %l0, 1, %g0
be,pt  %xcc, TARGET1465
nop
RET1465:

! lfsr step begin
srlx %l0, 1, %o5
xnor %o5, %l0, %o5
sllx %o5, 63, %o5
or  %o5, %l0, %l0
srlx %l0, 1, %l0


P1466: !_PREFETCH [9] (Int) (LE)
wr %g0, 0x88, %asi
prefetcha [%i1 + 512] %asi, 1

P1467: !_REPLACEMENT [1] (Int)
sethi %hi(0x4), %l3
or %l3, %lo(0x4),  %l3
sethi %hi(0x10000), %l6
or %l6, %lo(0x10000),  %l6
add %i3, %l3, %l3
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]

P1468: !_NOP (Int)
nop

P1469: !_PREFETCH [11] (Int)
prefetch [%i2 + 64], 1

P1470: !_ST [5] (maybe <- 0x40000091) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i1 + 76 ]

P1471: !_LD [6] (FP)
ld [%i1 + 80], %f14
! 1 addresses covered

P1472: !_SWAP [15] (maybe <- 0x80003b) (Int)
mov %l4, %l3
swap  [%i3 + 192], %l3
! move %l3(lower) -> %o4(lower)
srl %l3, 0, %l7
or %l7, %o4, %o4
!---- flushing int results buffer----
mov %o0, %l5
mov %o1, %l5
mov %o2, %l5
mov %o3, %l5
mov %o4, %l5
add   %l4, 1, %l4

P1473: !_REPLACEMENT [13] (Int)
sethi %hi(0x40), %l6
or %l6, %lo(0x40),  %l6
sethi %hi(0x10000), %l7
or %l7, %lo(0x10000),  %l7
add %i3, %l6, %l6
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]

P1474: !_ST [5] (maybe <- 0x40000092) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i1 + 76 ]

P1475: !_LD [1] (FP)
ld [%i0 + 4], %f15
! 1 addresses covered
!---- flushing fp results buffer to %f30 ----
fmovd %f0, %f30
fmovd %f2, %f30
fmovd %f4, %f30
fmovd %f6, %f30
fmovd %f8, %f30
fmovd %f10, %f30
fmovd %f12, %f30
fmovd %f14, %f30

P1476: !_CAS [14] (maybe <- 0x80003c) (Int)
add %i3, 128, %l3
lduw [%l3], %o0
mov %o0, %o5
! move %o5(lower) -> %o0(upper)
sllx %o5, 32, %o0
mov %l4, %l7
cas [%l3], %o5, %l7
! move %l7(lower) -> %o0(lower)
srl %l7, 0, %l3
or %l3, %o0, %o0
add   %l4, 1, %l4

P1477: !_NOP (Int)
nop

P1478: !_LD [1] (FP)
ld [%i0 + 4], %f0
! 1 addresses covered

P1479: !_REPLACEMENT [13] (Int)
sethi %hi(0x40), %o5
or %o5, %lo(0x40),  %o5
sethi %hi(0x10000), %l3
or %l3, %lo(0x10000),  %l3
add %i3, %o5, %o5
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]

P1480: !_REPLACEMENT [1] (Int)
sethi %hi(0x4), %l7
or %l7, %lo(0x4),  %l7
sethi %hi(0x10000), %o5
or %o5, %lo(0x10000),  %o5
add %i3, %l7, %l7
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]

P1481: !_ST [10] (maybe <- 0x40000093) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i2 + 32 ]

P1482: !_REPLACEMENT [2] (Int)
sethi %hi(0xc), %l3
or %l3, %lo(0xc),  %l3
sethi %hi(0x10000), %l6
or %l6, %lo(0x10000),  %l6
add %i3, %l3, %l3
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]

P1483: !_DWST [4] (maybe <- 0x40000094) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
std %f20, [%i0 + 64]

P1484: !_LD [0] (FP)
ld [%i0 + 0], %f1
! 1 addresses covered

P1485: !_PREFETCH [5] (Int)
prefetch [%i1 + 76], 1

P1486: !_ST [4] (maybe <- 0x40000095) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i0 + 64 ]

P1487: !_LD [12] (FP) (CBR)
ld [%i3 + 0], %f2
! 1 addresses covered

! cbranch
andcc %l0, 1, %g0
be,pt  %xcc, TARGET1487
nop
RET1487:

! lfsr step begin
srlx %l0, 1, %l6
xnor %l6, %l0, %l6
sllx %l6, 63, %l6
or  %l6, %l0, %l0
srlx %l0, 1, %l0


P1488: !_ST [12] (maybe <- 0x40000096) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i3 + 0 ]

P1489: !_DWLD [14] (FP)
ldd [%i3 + 128], %f18
! 1 addresses covered
fmovs %f18, %f3

P1490: !_LD [4] (FP)
ld [%i0 + 64], %f4
! 1 addresses covered

P1491: !_DWST [4] (maybe <- 0x40000097) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
std %f20, [%i0 + 64]

P1492: !_DWLD [6] (FP)
ldd [%i1 + 80], %f18
! 2 addresses covered
fmovs %f18, %f5
fmovs %f19, %f6

P1493: !_LD [1] (FP)
ld [%i0 + 4], %f7
! 1 addresses covered

P1494: !_ST [8] (maybe <- 0x40000098) (FP) (CBR)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i1 + 256 ]

! cbranch
andcc %l0, 1, %g0
be,pt  %xcc, TARGET1494
nop
RET1494:

! lfsr step begin
srlx %l0, 1, %o5
xnor %o5, %l0, %o5
sllx %o5, 63, %o5
or  %o5, %l0, %l0
srlx %l0, 1, %l0


P1495: !_PREFETCH [6] (Int)
prefetch [%i1 + 80], 1

P1496: !_REPLACEMENT [3] (Int)
sethi %hi(0x20), %l3
or %l3, %lo(0x20),  %l3
sethi %hi(0x10000), %l6
or %l6, %lo(0x10000),  %l6
add %i3, %l3, %l3
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]

P1497: !_DWLD [10] (FP)
ldd [%i2 + 32], %f8
! 1 addresses covered

P1498: !_ST [7] (maybe <- 0x40000099) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i1 + 84 ]

P1499: !_ST [4] (maybe <- 0x4000009a) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i0 + 64 ]

P1500: !_DWLD [2] (FP)
ldd [%i0 + 8], %f18
! 1 addresses covered
fmovs %f19, %f9

P1501: !_CAS [6] (maybe <- 0x80003d) (Int)
add %i1, 80, %l7
lduw [%l7], %o1
mov %o1, %l6
! move %l6(lower) -> %o1(upper)
sllx %l6, 32, %o1
mov %l4, %l3
cas [%l7], %l6, %l3
! move %l3(lower) -> %o1(lower)
srl %l3, 0, %l7
or %l7, %o1, %o1
add   %l4, 1, %l4

P1502: !_ST [13] (maybe <- 0x4000009b) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i3 + 64 ]

P1503: !_REPLACEMENT [6] (Int)
sethi %hi(0x50), %l3
or %l3, %lo(0x50),  %l3
sethi %hi(0x10000), %l6
or %l6, %lo(0x10000),  %l6
add %i3, %l3, %l3
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]

P1504: !_DWLD [13] (FP) (CBR)
ldd [%i3 + 64], %f10
! 1 addresses covered

! cbranch
andcc %l0, 1, %g0
be,pn  %xcc, TARGET1504
nop
RET1504:

! lfsr step begin
srlx %l0, 1, %o5
xnor %o5, %l0, %o5
sllx %o5, 63, %o5
or  %o5, %l0, %l0
srlx %l0, 1, %l0


P1505: !_ST [11] (maybe <- 0x4000009c) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i2 + 64 ]

P1506: !_ST [1] (maybe <- 0x4000009d) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i0 + 4 ]

P1507: !_DWLD [9] (FP)
ldd [%i1 + 512], %f18
! 1 addresses covered
fmovs %f18, %f11

P1508: !_DWST [11] (maybe <- 0x4000009e) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
std %f20, [%i2 + 64]

P1509: !_DWLD [14] (FP)
ldd [%i3 + 128], %f12
! 1 addresses covered

P1510: !_LD [5] (FP)
ld [%i1 + 76], %f13
! 1 addresses covered

P1511: !_ST [9] (maybe <- 0x4000009f) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i1 + 512 ]

P1512: !_LD [5] (FP)
ld [%i1 + 76], %f14
! 1 addresses covered

P1513: !_PREFETCH [10] (Int) (LE)
wr %g0, 0x88, %asi
prefetcha [%i2 + 32] %asi, 1

P1514: !_ST [3] (maybe <- 0x400000a0) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i0 + 32 ]

P1515: !_LD [3] (FP)
ld [%i0 + 32], %f15
! 1 addresses covered
!---- flushing fp results buffer to %f30 ----
fmovd %f0, %f30
fmovd %f2, %f30
fmovd %f4, %f30
fmovd %f6, %f30
fmovd %f8, %f30
fmovd %f10, %f30
fmovd %f12, %f30
fmovd %f14, %f30

P1516: !_REPLACEMENT [11] (Int)
sethi %hi(0x40), %o5
or %o5, %lo(0x40),  %o5
sethi %hi(0x10000), %l3
or %l3, %lo(0x10000),  %l3
add %i3, %o5, %o5
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]

P1517: !_DWST [3] (maybe <- 0x400000a1) (FP) (CBR)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
std %f20, [%i0 + 32]

! cbranch
andcc %l0, 1, %g0
be,pt  %xcc, TARGET1517
nop
RET1517:

! lfsr step begin
srlx %l0, 1, %l6
xnor %l6, %l0, %l6
sllx %l6, 63, %l6
or  %l6, %l0, %l0
srlx %l0, 1, %l0


P1518: !_REPLACEMENT [5] (Int)
sethi %hi(0x4c), %l7
or %l7, %lo(0x4c),  %l7
sethi %hi(0x10000), %o5
or %o5, %lo(0x10000),  %o5
add %i3, %l7, %l7
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]

P1519: !_PREFETCH [14] (Int)
prefetch [%i3 + 128], 1

P1520: !_REPLACEMENT [14] (Int)
sethi %hi(0x80), %l6
or %l6, %lo(0x80),  %l6
sethi %hi(0x10000), %l7
or %l7, %lo(0x10000),  %l7
add %i3, %l6, %l6
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]

P1521: !_DWST [6] (maybe <- 0x400000a2) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
! 1 th moved, current_fp_src=21 
fmovs  %f16, %f21
fadds  %f16, %f17, %f16
std %f20, [%i1 + 80]

P1522: !_LD [6] (FP)
ld [%i1 + 80], %f0
! 1 addresses covered

P1523: !_DWLD [11] (FP)
ldd [%i2 + 64], %f18
! 1 addresses covered
fmovs %f18, %f1

P1524: !_ST [1] (maybe <- 0x400000a4) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i0 + 4 ]

P1525: !_MEMBAR (Int)
membar #StoreLoad

P1526: !_REPLACEMENT [8] (Int)
sethi %hi(0x100), %l7
or %l7, %lo(0x100),  %l7
sethi %hi(0x10000), %o5
or %o5, %lo(0x10000),  %o5
add %i3, %l7, %l7
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]

P1527: !_PREFETCH [13] (Int)
prefetch [%i3 + 64], 1

P1528: !_CASX [0] (maybe <- 0x80003e) (Int) (CBR)
add %i0, 0, %l7
ldx [%l7], %o2
! move %o2(upper) -> %o2(upper)
! move %o2(lower) -> %o2(lower)
mov %o2, %l6
sllx %l4, 32, %o3
add  %l4, 1, %l4
or   %l4, %o3, %o3
casx [%l7], %l6, %o3
! move %o3(upper) -> %o3(upper)
! move %o3(lower) -> %o3(lower)
add  %l4, 1, %l4

! cbranch
andcc %l0, 1, %g0
be,pn  %xcc, TARGET1528
nop
RET1528:

! lfsr step begin
srlx %l0, 1, %l6
xnor %l6, %l0, %l6
sllx %l6, 63, %l6
or  %l6, %l0, %l0
srlx %l0, 1, %l0


P1529: !_REPLACEMENT [5] (Int) (CBR)
sethi %hi(0x4c), %l7
or %l7, %lo(0x4c),  %l7
sethi %hi(0x10000), %o5
or %o5, %lo(0x10000),  %o5
add %i3, %l7, %l7
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]

! cbranch
andcc %l0, 1, %g0
be,pt  %xcc, TARGET1529
nop
RET1529:

! lfsr step begin
srlx %l0, 1, %l6
xnor %l6, %l0, %l6
sllx %l6, 63, %l6
or  %l6, %l0, %l0
srlx %l0, 1, %l0


P1530: !_REPLACEMENT [11] (Int)
sethi %hi(0x40), %l7
or %l7, %lo(0x40),  %l7
sethi %hi(0x10000), %o5
or %o5, %lo(0x10000),  %o5
add %i3, %l7, %l7
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]

P1531: !_DWLD [14] (FP)
ldd [%i3 + 128], %f2
! 1 addresses covered

P1532: !_REPLACEMENT [12] (Int)
sethi %hi(0x0), %l6
or %l6, %lo(0x0),  %l6
sethi %hi(0x10000), %l7
or %l7, %lo(0x10000),  %l7
add %i3, %l6, %l6
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]

P1533: !_REPLACEMENT [5] (Int)
sethi %hi(0x4c), %l3
or %l3, %lo(0x4c),  %l3
sethi %hi(0x10000), %l6
or %l6, %lo(0x10000),  %l6
add %i3, %l3, %l3
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]

P1534: !_LD [0] (FP)
ld [%i0 + 0], %f3
! 1 addresses covered

P1535: !_DWST [9] (maybe <- 0x400000a5) (FP) (CBR)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
std %f20, [%i1 + 512]

! cbranch
andcc %l0, 1, %g0
be,pt  %xcc, TARGET1535
nop
RET1535:

! lfsr step begin
srlx %l0, 1, %l7
xnor %l7, %l0, %l7
sllx %l7, 63, %l7
or  %l7, %l0, %l0
srlx %l0, 1, %l0


P1536: !_DWST [15] (maybe <- 0x400000a6) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
std %f20, [%i3 + 192]

P1537: !_DWST [11] (maybe <- 0x400000a7) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
std %f20, [%i2 + 64]

P1538: !_PREFETCH [3] (Int)
prefetch [%i0 + 32], 1

P1539: !_PREFETCH [15] (Int)
prefetch [%i3 + 192], 1

P1540: !_DWST [4] (maybe <- 0x400000a8) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
std %f20, [%i0 + 64]

P1541: !_LD [12] (FP)
ld [%i3 + 0], %f4
! 1 addresses covered

P1542: !_SWAP [9] (maybe <- 0x800040) (Int)
mov %l4, %o4
swap  [%i1 + 512], %o4
! move %o4(lower) -> %o4(upper)
sllx %o4, 32, %o4
add   %l4, 1, %l4

P1543: !_REPLACEMENT [8] (Int)
sethi %hi(0x100), %o5
or %o5, %lo(0x100),  %o5
sethi %hi(0x10000), %l3
or %l3, %lo(0x10000),  %l3
add %i3, %o5, %o5
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]

P1544: !_ST [13] (maybe <- 0x400000a9) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i3 + 64 ]

P1545: !_DWST [5] (maybe <- 0x400000aa) (FP)
! 0 th moved, current_fp_src=21 
fmovs  %f16, %f21
fadds  %f16, %f17, %f16
std %f20, [%i1 + 72]

P1546: !_DWST [7] (maybe <- 0x400000ab) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
! 1 th moved, current_fp_src=21 
fmovs  %f16, %f21
fadds  %f16, %f17, %f16
std %f20, [%i1 + 80]

P1547: !_ST [13] (maybe <- 0x400000ad) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i3 + 64 ]

P1548: !_PREFETCH [0] (Int)
prefetch [%i0 + 0], 1

P1549: !_ST [7] (maybe <- 0x400000ae) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i1 + 84 ]

P1550: !_DWLD [1] (FP)
ldd [%i0 + 0], %f18
! 2 addresses covered
fmovs %f18, %f5
fmovs %f19, %f6

P1551: !_DWLD [1] (FP)
ldd [%i0 + 0], %f18
! 2 addresses covered
fmovs %f18, %f7
fmovs %f19, %f8

P1552: !_PREFETCH [1] (Int)
prefetch [%i0 + 4], 1

P1553: !_PREFETCH [14] (Int) (LE)
wr %g0, 0x88, %asi
prefetcha [%i3 + 128] %asi, 1

P1554: !_LD [6] (FP)
ld [%i1 + 80], %f9
! 1 addresses covered

P1555: !_PREFETCH [5] (Int)
prefetch [%i1 + 76], 1

P1556: !_DWST [8] (maybe <- 0x400000af) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
std %f20, [%i1 + 256]

P1557: !_DWLD [13] (FP)
ldd [%i3 + 64], %f10
! 1 addresses covered

P1558: !_REPLACEMENT [11] (Int)
sethi %hi(0x40), %l3
or %l3, %lo(0x40),  %l3
sethi %hi(0x10000), %l6
or %l6, %lo(0x10000),  %l6
add %i3, %l3, %l3
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]

P1559: !_PREFETCH [15] (Int)
prefetch [%i3 + 192], 1

P1560: !_LD [1] (FP)
ld [%i0 + 4], %f11
! 1 addresses covered

P1561: !_ST [0] (maybe <- 0x400000b0) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i0 + 0 ]

P1562: !_REPLACEMENT [14] (Int)
sethi %hi(0x80), %l7
or %l7, %lo(0x80),  %l7
sethi %hi(0x10000), %o5
or %o5, %lo(0x10000),  %o5
add %i3, %l7, %l7
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]

P1563: !_PREFETCH [8] (Int) (Branch target of P1231)
prefetch [%i1 + 256], 1
ba P1564
nop

TARGET1231:
ba RET1231
nop


P1564: !_DWST [10] (maybe <- 0x400000b1) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
std %f20, [%i2 + 32]

P1565: !_DWST [12] (maybe <- 0x400000b2) (FP) (Branch target of P1885)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
std %f20, [%i3 + 0]
ba P1566
nop

TARGET1885:
ba RET1885
nop


P1566: !_DWLD [5] (FP)
ldd [%i1 + 72], %f12
! 1 addresses covered
fmovs %f13, %f12

P1567: !_DWST [1] (maybe <- 0x400000b3) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
! 1 th moved, current_fp_src=21 
fmovs  %f16, %f21
fadds  %f16, %f17, %f16
std %f20, [%i0 + 0]

P1568: !_CASX [14] (maybe <- 0x800041) (Int)
add %i3, 128, %o5
ldx [%o5], %l6
! move %l6(upper) -> %o4(lower)
srlx %l6, 32, %l7
or %l7, %o4, %o4
!---- flushing int results buffer----
mov %o0, %l5
mov %o1, %l5
mov %o2, %l5
mov %o3, %l5
mov %o4, %l5
! move %l6(lower) -> %o0(upper)
sllx %l6, 32, %o0
mov  %l6, %l7
sllx %l4, 32, %l6
casx [%o5], %l7, %l6
! move %l6(upper) -> %o0(lower)
srlx %l6, 32, %o5
or %o5, %o0, %o0
! move %l6(lower) -> %o1(upper)
sllx %l6, 32, %o1
add  %l4, 1, %l4

P1569: !_LD [0] (FP)
ld [%i0 + 0], %f13
! 1 addresses covered

P1570: !_DWST [14] (maybe <- 0x400000b5) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
std %f20, [%i3 + 128]

P1571: !_PREFETCH [5] (Int)
prefetch [%i1 + 76], 1

P1572: !_PREFETCH [3] (Int)
prefetch [%i0 + 32], 1

P1573: !_ST [7] (maybe <- 0x400000b6) (FP) (CBR)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i1 + 84 ]

! cbranch
andcc %l0, 1, %g0
be,pt  %xcc, TARGET1573
nop
RET1573:

! lfsr step begin
srlx %l0, 1, %l3
xnor %l3, %l0, %l3
sllx %l3, 63, %l3
or  %l3, %l0, %l0
srlx %l0, 1, %l0


P1574: !_CASX [13] (maybe <- 0x800042) (Int)
add %i3, 64, %l7
ldx [%l7], %l3
! move %l3(upper) -> %o1(lower)
srlx %l3, 32, %l6
or %l6, %o1, %o1
! move %l3(lower) -> %o2(upper)
sllx %l3, 32, %o2
mov  %l3, %l6
sllx %l4, 32, %l3
casx [%l7], %l6, %l3
! move %l3(upper) -> %o2(lower)
srlx %l3, 32, %l7
or %l7, %o2, %o2
! move %l3(lower) -> %o3(upper)
sllx %l3, 32, %o3
add  %l4, 1, %l4

P1575: !_REPLACEMENT [7] (Int)
sethi %hi(0x54), %l6
or %l6, %lo(0x54),  %l6
sethi %hi(0x10000), %l7
or %l7, %lo(0x10000),  %l7
add %i3, %l6, %l6
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]

P1576: !_DWLD [9] (FP)
ldd [%i1 + 512], %f14
! 1 addresses covered

P1577: !_ST [11] (maybe <- 0x400000b7) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i2 + 64 ]

P1578: !_CAS [10] (maybe <- 0x800043) (Int)
add %i2, 32, %l3
lduw [%l3], %l7
mov %l7, %o5
! move %o5(lower) -> %o3(lower)
or %o5, %o3, %o3
mov %l4, %o4
cas [%l3], %o5, %o4
! move %o4(lower) -> %o4(upper)
sllx %o4, 32, %o4
add   %l4, 1, %l4

P1579: !_REPLACEMENT [13] (Int)
sethi %hi(0x40), %o5
or %o5, %lo(0x40),  %o5
sethi %hi(0x10000), %l3
or %l3, %lo(0x10000),  %l3
add %i3, %o5, %o5
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]

P1580: !_LD [4] (FP)
ld [%i0 + 64], %f15
! 1 addresses covered
!---- flushing fp results buffer to %f30 ----
fmovd %f0, %f30
fmovd %f2, %f30
fmovd %f4, %f30
fmovd %f6, %f30
fmovd %f8, %f30
fmovd %f10, %f30
fmovd %f12, %f30
fmovd %f14, %f30

P1581: !_REPLACEMENT [15] (Int)
sethi %hi(0xc0), %l7
or %l7, %lo(0xc0),  %l7
sethi %hi(0x10000), %o5
or %o5, %lo(0x10000),  %o5
add %i3, %l7, %l7
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]

P1582: !_NOP (Int)
nop

P1583: !_DWLD [2] (FP) (Branch target of P1250)
ldd [%i0 + 8], %f0
! 1 addresses covered
fmovs %f1, %f0
ba P1584
nop

TARGET1250:
ba RET1250
nop


P1584: !_DWLD [3] (FP)
ldd [%i0 + 32], %f18
! 1 addresses covered
fmovs %f18, %f1

P1585: !_PREFETCH [13] (Int)
prefetch [%i3 + 64], 1

P1586: !_LD [12] (FP)
ld [%i3 + 0], %f2
! 1 addresses covered

P1587: !_DWST [1] (maybe <- 0x400000b8) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
! 1 th moved, current_fp_src=21 
fmovs  %f16, %f21
fadds  %f16, %f17, %f16
std %f20, [%i0 + 0]

P1588: !_ST [6] (maybe <- 0x400000ba) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i1 + 80 ]

P1589: !_DWST [6] (maybe <- 0x400000bb) (FP) (Branch target of P1201)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
! 1 th moved, current_fp_src=21 
fmovs  %f16, %f21
fadds  %f16, %f17, %f16
std %f20, [%i1 + 80]
ba P1590
nop

TARGET1201:
ba RET1201
nop


P1590: !_SWAP [9] (maybe <- 0x800044) (Int) (CBR)
mov %l4, %l3
swap  [%i1 + 512], %l3
! move %l3(lower) -> %o4(lower)
srl %l3, 0, %l7
or %l7, %o4, %o4
!---- flushing int results buffer----
mov %o0, %l5
mov %o1, %l5
mov %o2, %l5
mov %o3, %l5
mov %o4, %l5
add   %l4, 1, %l4

! cbranch
andcc %l0, 1, %g0
be,pt  %xcc, TARGET1590
nop
RET1590:

! lfsr step begin
srlx %l0, 1, %l6
xnor %l6, %l0, %l6
sllx %l6, 63, %l6
or  %l6, %l0, %l0
srlx %l0, 1, %l0


P1591: !_LD [9] (FP)
ld [%i1 + 512], %f3
! 1 addresses covered

P1592: !_PREFETCH [6] (Int)
prefetch [%i1 + 80], 1

P1593: !_REPLACEMENT [11] (Int)
sethi %hi(0x40), %l7
or %l7, %lo(0x40),  %l7
sethi %hi(0x10000), %o5
or %o5, %lo(0x10000),  %o5
add %i3, %l7, %l7
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]

P1594: !_REPLACEMENT [7] (Int)
sethi %hi(0x54), %l6
or %l6, %lo(0x54),  %l6
sethi %hi(0x10000), %l7
or %l7, %lo(0x10000),  %l7
add %i3, %l6, %l6
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]

P1595: !_LD [0] (FP)
ld [%i0 + 0], %f4
! 1 addresses covered

P1596: !_PREFETCH [0] (Int) (LE)
wr %g0, 0x88, %asi
prefetcha [%i0 + 0] %asi, 1

P1597: !_ST [7] (maybe <- 0x400000bd) (FP) (CBR)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i1 + 84 ]

! cbranch
andcc %l0, 1, %g0
be,pt  %xcc, TARGET1597
nop
RET1597:

! lfsr step begin
srlx %l0, 1, %o5
xnor %o5, %l0, %o5
sllx %o5, 63, %o5
or  %o5, %l0, %l0
srlx %l0, 1, %l0


P1598: !_CASX [4] (maybe <- 0x800045) (Int)
add %i0, 64, %l6
ldx [%l6], %o0
! move %o0(upper) -> %o0(upper)
! move %o0(lower) -> %o0(lower)
mov  %o0, %l3
sllx %l4, 32, %o1
casx [%l6], %l3, %o1
! move %o1(upper) -> %o1(upper)
! move %o1(lower) -> %o1(lower)
add  %l4, 1, %l4

P1599: !_SWAP [4] (maybe <- 0x800046) (Int)
mov %l4, %o2
swap  [%i0 + 64], %o2
! move %o2(lower) -> %o2(upper)
sllx %o2, 32, %o2
add   %l4, 1, %l4

P1600: !_DWST [0] (maybe <- 0x400000be) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
! 1 th moved, current_fp_src=21 
fmovs  %f16, %f21
fadds  %f16, %f17, %f16
std %f20, [%i0 + 0]

P1601: !_LD [10] (FP)
ld [%i2 + 32], %f5
! 1 addresses covered

P1602: !_ST [11] (maybe <- 0x400000c0) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i2 + 64 ]

P1603: !_DWLD [11] (FP)
ldd [%i2 + 64], %f6
! 1 addresses covered

P1604: !_LD [11] (FP)
ld [%i2 + 64], %f7
! 1 addresses covered

P1605: !_DWLD [15] (FP)
ldd [%i3 + 192], %f8
! 1 addresses covered

P1606: !_CASX [6] (maybe <- 0x800047) (Int) (LE)
sllx %l4, 32, %l7
add  %l4, 1, %l4
or   %l4, %l7, %l7
! Change double-word-level endianess (big endian <-> little endian) 
sethi %hi(0xff00ff00), %l6
or %l6, %lo(0xff00ff00), %l6
sllx %l6, 32, %o5
or %l6, %o5, %l6 
and %l7, %l6, %o5
srlx %o5, 8, %o5
sllx %l7, 8, %l7
and %l7, %l6, %l7
or %l7, %o5, %l7 
sethi %hi(0xffff0000), %l6
or %l6, %lo(0xffff0000), %l6
srlx %l7, 16, %o5
andn %o5, %l6, %o5
andn %l7, %l6, %l7
sllx %l7, 16, %l7
or %l7, %o5, %l7 
srlx %l7, 32, %o5
sllx %l7, 32, %l7
or %l7, %o5, %o5 
wr %g0, 0x88, %asi
add %i1, 80, %l7
ldxa [%l7] %asi, %l3
! move %l3(lower) -> %o2(lower)
srl %l3, 0, %l6
or %l6, %o2, %o2
! move %l3(upper) -> %o3(upper)
or %l3, %g0, %o3
mov %l3, %l6
mov  %o5, %l3
casxa [%l7] %asi, %l6, %l3
! move %l3(lower) -> %o3(lower)
srlx %o3, 32, %o3
sllx %o3, 32, %o3
srl %l3, 0, %l7
or %l7, %o3, %o3
! move %l3(upper) -> %o4(upper)
or %l3, %g0, %o4
add  %l4, 1, %l4

P1607: !_REPLACEMENT [4] (Int)
sethi %hi(0x40), %l6
or %l6, %lo(0x40),  %l6
sethi %hi(0x10000), %l7
or %l7, %lo(0x10000),  %l7
add %i3, %l6, %l6
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]

P1608: !_LD [9] (FP)
ld [%i1 + 512], %f9
! 1 addresses covered

P1609: !_REPLACEMENT [7] (Int)
sethi %hi(0x54), %l3
or %l3, %lo(0x54),  %l3
sethi %hi(0x10000), %l6
or %l6, %lo(0x10000),  %l6
add %i3, %l3, %l3
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]

P1610: !_DWST [3] (maybe <- 0x400000c1) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
std %f20, [%i0 + 32]

P1611: !_DWLD [4] (FP)
ldd [%i0 + 64], %f10
! 1 addresses covered

P1612: !_CASX [9] (maybe <- 0x800049) (Int)
add %i1, 512, %o5
ldx [%o5], %l6
! move %l6(upper) -> %o4(lower)
srlx %o4, 32, %o4
sllx %o4, 32, %o4
srlx %l6, 32, %l7
or %l7, %o4, %o4
!---- flushing int results buffer----
mov %o0, %l5
mov %o1, %l5
mov %o2, %l5
mov %o3, %l5
mov %o4, %l5
! move %l6(lower) -> %o0(upper)
sllx %l6, 32, %o0
mov  %l6, %l7
sllx %l4, 32, %l6
casx [%o5], %l7, %l6
! move %l6(upper) -> %o0(lower)
srlx %l6, 32, %o5
or %o5, %o0, %o0
! move %l6(lower) -> %o1(upper)
sllx %l6, 32, %o1
add  %l4, 1, %l4

P1613: !_REPLACEMENT [6] (Int)
sethi %hi(0x50), %l7
or %l7, %lo(0x50),  %l7
sethi %hi(0x10000), %o5
or %o5, %lo(0x10000),  %o5
add %i3, %l7, %l7
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]

P1614: !_ST [14] (maybe <- 0x400000c2) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i3 + 128 ]

P1615: !_LD [14] (FP)
ld [%i3 + 128], %f11
! 1 addresses covered

P1616: !_REPLACEMENT [9] (Int)
sethi %hi(0x200), %l3
or %l3, %lo(0x200),  %l3
sethi %hi(0x10000), %l6
or %l6, %lo(0x10000),  %l6
add %i3, %l3, %l3
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]

P1617: !_CASX [3] (maybe <- 0x80004a) (Int)
add %i0, 32, %l3
ldx [%l3], %l7
! move %l7(upper) -> %o1(lower)
srlx %l7, 32, %o5
or %o5, %o1, %o1
! move %l7(lower) -> %o2(upper)
sllx %l7, 32, %o2
mov  %l7, %o5
sllx %l4, 32, %l7
casx [%l3], %o5, %l7
! move %l7(upper) -> %o2(lower)
srlx %l7, 32, %l3
or %l3, %o2, %o2
! move %l7(lower) -> %o3(upper)
sllx %l7, 32, %o3
add  %l4, 1, %l4

P1618: !_REPLACEMENT [5] (Int)
sethi %hi(0x4c), %o5
or %o5, %lo(0x4c),  %o5
sethi %hi(0x10000), %l3
or %l3, %lo(0x10000),  %l3
add %i3, %o5, %o5
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]

P1619: !_LD [4] (FP)
ld [%i0 + 64], %f12
! 1 addresses covered

P1620: !_PREFETCH [10] (Int)
prefetch [%i2 + 32], 1

P1621: !_CAS [1] (maybe <- 0x80004b) (Int)
add %i0, 4, %o5
lduw [%o5], %l6
mov %l6, %l7
! move %l7(lower) -> %o3(lower)
or %l7, %o3, %o3
mov %l4, %o4
cas [%o5], %l7, %o4
! move %o4(lower) -> %o4(upper)
sllx %o4, 32, %o4
add   %l4, 1, %l4

P1622: !_PREFETCH [14] (Int)
prefetch [%i3 + 128], 1

P1623: !_ST [5] (maybe <- 0x400000c3) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i1 + 76 ]

P1624: !_PREFETCH [13] (Int)
prefetch [%i3 + 64], 1

P1625: !_LD [10] (FP)
ld [%i2 + 32], %f13
! 1 addresses covered

P1626: !_LD [13] (FP)
ld [%i3 + 64], %f14
! 1 addresses covered

P1627: !_CAS [10] (maybe <- 0x80004c) (Int)
add %i2, 32, %l7
lduw [%l7], %l3
mov %l3, %l6
! move %l6(lower) -> %o4(lower)
or %l6, %o4, %o4
!---- flushing int results buffer----
mov %o0, %l5
mov %o1, %l5
mov %o2, %l5
mov %o3, %l5
mov %o4, %l5
mov %l4, %o0
cas [%l7], %l6, %o0
! move %o0(lower) -> %o0(upper)
sllx %o0, 32, %o0
add   %l4, 1, %l4

P1628: !_CASX [5] (maybe <- 0x80004d) (Int)
add %i1, 72, %l7
ldx [%l7], %l3
! move %l3(upper) -> %o0(lower)
srlx %l3, 32, %l6
or %l6, %o0, %o0
! move %l3(lower) -> %o1(upper)
sllx %l3, 32, %o1
mov  %l3, %l6
mov %l4, %l3
casx [%l7], %l6, %l3
! move %l3(upper) -> %o1(lower)
srlx %l3, 32, %l7
or %l7, %o1, %o1
! move %l3(lower) -> %o2(upper)
sllx %l3, 32, %o2
add  %l4, 1, %l4

P1629: !_DWST [11] (maybe <- 0x400000c4) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
std %f20, [%i2 + 64]

P1630: !_LD [8] (FP)
ld [%i1 + 256], %f15
! 1 addresses covered
!---- flushing fp results buffer to %f30 ----
fmovd %f0, %f30
fmovd %f2, %f30
fmovd %f4, %f30
fmovd %f6, %f30
fmovd %f8, %f30
fmovd %f10, %f30
fmovd %f12, %f30
fmovd %f14, %f30

P1631: !_DWST [2] (maybe <- 0x400000c5) (FP)
! 0 th moved, current_fp_src=21 
fmovs  %f16, %f21
fadds  %f16, %f17, %f16
std %f20, [%i0 + 8]

P1632: !_PREFETCH [0] (Int)
prefetch [%i0 + 0], 1

P1633: !_DWLD [13] (FP)
ldd [%i3 + 64], %f0
! 1 addresses covered

P1634: !_LD [4] (FP)
ld [%i0 + 64], %f1
! 1 addresses covered

P1635: !_LD [7] (FP)
ld [%i1 + 84], %f2
! 1 addresses covered

P1636: !_DWLD [1] (FP)
ldd [%i0 + 0], %f18
! 2 addresses covered
fmovs %f18, %f3
fmovs %f19, %f4

P1637: !_DWST [11] (maybe <- 0x400000c6) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
std %f20, [%i2 + 64]

P1638: !_MEMBAR (Int)
membar #StoreLoad

P1639: !_DWST [2] (maybe <- 0x400000c7) (FP)
! 0 th moved, current_fp_src=21 
fmovs  %f16, %f21
fadds  %f16, %f17, %f16
std %f20, [%i0 + 8]

P1640: !_PREFETCH [12] (Int)
prefetch [%i3 + 0], 1

P1641: !_LD [3] (FP)
ld [%i0 + 32], %f5
! 1 addresses covered

P1642: !_SWAP [13] (maybe <- 0x80004e) (Int)
mov %l4, %o5
swap  [%i3 + 64], %o5
! move %o5(lower) -> %o2(lower)
srl %o5, 0, %l6
or %l6, %o2, %o2
add   %l4, 1, %l4

P1643: !_DWLD [3] (FP)
ldd [%i0 + 32], %f6
! 1 addresses covered

P1644: !_LD [5] (FP)
ld [%i1 + 76], %f7
! 1 addresses covered

P1645: !_ST [2] (maybe <- 0x400000c8) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i0 + 12 ]

P1646: !_MEMBAR (Int)
membar #StoreLoad

P1647: !_ST [0] (maybe <- 0x400000c9) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i0 + 0 ]

P1648: !_CAS [5] (maybe <- 0x80004f) (Int)
add %i1, 76, %o5
lduw [%o5], %o3
mov %o3, %l7
! move %l7(lower) -> %o3(upper)
sllx %l7, 32, %o3
mov %l4, %l6
cas [%o5], %l7, %l6
! move %l6(lower) -> %o3(lower)
srl %l6, 0, %o5
or %o5, %o3, %o3
add   %l4, 1, %l4

P1649: !_LD [6] (FP)
ld [%i1 + 80], %f8
! 1 addresses covered

P1650: !_PREFETCH [14] (Int) (LE)
wr %g0, 0x88, %asi
prefetcha [%i3 + 128] %asi, 1

P1651: !_DWST [5] (maybe <- 0x400000ca) (FP)
! 0 th moved, current_fp_src=21 
fmovs  %f16, %f21
fadds  %f16, %f17, %f16
std %f20, [%i1 + 72]

P1652: !_DWLD [2] (FP)
ldd [%i0 + 8], %f18
! 1 addresses covered
fmovs %f19, %f9

P1653: !_LD [15] (FP)
ld [%i3 + 192], %f10
! 1 addresses covered

P1654: !_PREFETCH [2] (Int)
prefetch [%i0 + 12], 1

P1655: !_SWAP [5] (maybe <- 0x800050) (Int)
mov %l4, %o4
swap  [%i1 + 76], %o4
! move %o4(lower) -> %o4(upper)
sllx %o4, 32, %o4
add   %l4, 1, %l4

P1656: !_CAS [1] (maybe <- 0x800051) (Int)
add %i0, 4, %l6
lduw [%l6], %o5
mov %o5, %l3
! move %l3(lower) -> %o4(lower)
or %l3, %o4, %o4
!---- flushing int results buffer----
mov %o0, %l5
mov %o1, %l5
mov %o2, %l5
mov %o3, %l5
mov %o4, %l5
mov %l4, %o0
cas [%l6], %l3, %o0
! move %o0(lower) -> %o0(upper)
sllx %o0, 32, %o0
add   %l4, 1, %l4

P1657: !_DWLD [11] (FP)
ldd [%i2 + 64], %f18
! 1 addresses covered
fmovs %f18, %f11

P1658: !_ST [2] (maybe <- 0x400000cb) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i0 + 12 ]

P1659: !_CASX [2] (maybe <- 0x800052) (Int)
add %i0, 8, %l3
ldx [%l3], %l7
! move %l7(upper) -> %o0(lower)
srlx %l7, 32, %o5
or %o5, %o0, %o0
! move %l7(lower) -> %o1(upper)
sllx %l7, 32, %o1
mov  %l7, %o5
mov %l4, %l7
casx [%l3], %o5, %l7
! move %l7(upper) -> %o1(lower)
srlx %l7, 32, %l3
or %l3, %o1, %o1
! move %l7(lower) -> %o2(upper)
sllx %l7, 32, %o2
add  %l4, 1, %l4

P1660: !_SWAP [0] (maybe <- 0x800053) (Int)
mov %l4, %l6
swap  [%i0 + 0], %l6
! move %l6(lower) -> %o2(lower)
srl %l6, 0, %o5
or %o5, %o2, %o2
add   %l4, 1, %l4

P1661: !_SWAP [8] (maybe <- 0x800054) (Int)
mov %l4, %o3
swap  [%i1 + 256], %o3
! move %o3(lower) -> %o3(upper)
sllx %o3, 32, %o3
add   %l4, 1, %l4

P1662: !_REPLACEMENT [2] (Int)
sethi %hi(0xc), %l6
or %l6, %lo(0xc),  %l6
sethi %hi(0x10000), %l7
or %l7, %lo(0x10000),  %l7
add %i3, %l6, %l6
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]

P1663: !_SWAP [9] (maybe <- 0x800055) (Int)
mov %l4, %l7
swap  [%i1 + 512], %l7
! move %l7(lower) -> %o3(lower)
srl %l7, 0, %l3
or %l3, %o3, %o3
add   %l4, 1, %l4

P1664: !_LD [2] (FP)
ld [%i0 + 12], %f12
! 1 addresses covered

P1665: !_DWLD [6] (FP)
ldd [%i1 + 80], %f18
! 2 addresses covered
fmovs %f18, %f13
fmovs %f19, %f14

P1666: !_ST [12] (maybe <- 0x400000cc) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i3 + 0 ]

P1667: !_PREFETCH [4] (Int)
prefetch [%i0 + 64], 1

P1668: !_DWST [6] (maybe <- 0x400000cd) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
! 1 th moved, current_fp_src=21 
fmovs  %f16, %f21
fadds  %f16, %f17, %f16
std %f20, [%i1 + 80]

P1669: !_ST [13] (maybe <- 0x400000cf) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i3 + 64 ]

P1670: !_REPLACEMENT [14] (Int)
sethi %hi(0x80), %l3
or %l3, %lo(0x80),  %l3
sethi %hi(0x10000), %l6
or %l6, %lo(0x10000),  %l6
add %i3, %l3, %l3
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]

P1671: !_DWLD [10] (FP)
ldd [%i2 + 32], %f18
! 1 addresses covered
fmovs %f18, %f15
!---- flushing fp results buffer to %f30 ----
fmovd %f0, %f30
fmovd %f2, %f30
fmovd %f4, %f30
fmovd %f6, %f30
fmovd %f8, %f30
fmovd %f10, %f30
fmovd %f12, %f30
fmovd %f14, %f30

P1672: !_DWLD [11] (FP)
ldd [%i2 + 64], %f0
! 1 addresses covered

P1673: !_CAS [6] (maybe <- 0x800056) (Int)
add %i1, 80, %l3
lduw [%l3], %o4
mov %o4, %o5
! move %o5(lower) -> %o4(upper)
sllx %o5, 32, %o4
mov %l4, %l7
cas [%l3], %o5, %l7
! move %l7(lower) -> %o4(lower)
srl %l7, 0, %l3
or %l3, %o4, %o4
!---- flushing int results buffer----
mov %o0, %l5
mov %o1, %l5
mov %o2, %l5
mov %o3, %l5
mov %o4, %l5
add   %l4, 1, %l4

P1674: !_MEMBAR (Int)
membar #StoreLoad

P1675: !_PREFETCH [4] (Int)
prefetch [%i0 + 64], 1

P1676: !_REPLACEMENT [8] (Int) (Branch target of P1032)
sethi %hi(0x100), %o5
or %o5, %lo(0x100),  %o5
sethi %hi(0x10000), %l3
or %l3, %lo(0x10000),  %l3
add %i3, %o5, %o5
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
ba P1677
nop

TARGET1032:
ba RET1032
nop


P1677: !_DWLD [1] (FP)
ldd [%i0 + 0], %f18
! 2 addresses covered
fmovs %f18, %f1
fmovs %f19, %f2

P1678: !_DWST [1] (maybe <- 0x400000d0) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
! 1 th moved, current_fp_src=21 
fmovs  %f16, %f21
fadds  %f16, %f17, %f16
std %f20, [%i0 + 0]

P1679: !_REPLACEMENT [5] (Int)
sethi %hi(0x4c), %l6
or %l6, %lo(0x4c),  %l6
sethi %hi(0x10000), %l7
or %l7, %lo(0x10000),  %l7
add %i3, %l6, %l6
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]

P1680: !_CASX [7] (maybe <- 0x800057) (Int)
add %i1, 80, %l6
ldx [%l6], %o0
! move %o0(upper) -> %o0(upper)
! move %o0(lower) -> %o0(lower)
mov %o0, %l3
sllx %l4, 32, %o1
add  %l4, 1, %l4
or   %l4, %o1, %o1
casx [%l6], %l3, %o1
! move %o1(upper) -> %o1(upper)
! move %o1(lower) -> %o1(lower)
add  %l4, 1, %l4

P1681: !_CASX [6] (maybe <- 0x800059) (Int)
add %i1, 80, %l6
ldx [%l6], %o2
! move %o2(upper) -> %o2(upper)
! move %o2(lower) -> %o2(lower)
mov %o2, %l3
sllx %l4, 32, %o3
add  %l4, 1, %l4
or   %l4, %o3, %o3
casx [%l6], %l3, %o3
! move %o3(upper) -> %o3(upper)
! move %o3(lower) -> %o3(lower)
add  %l4, 1, %l4

P1682: !_LD [8] (FP)
ld [%i1 + 256], %f3
! 1 addresses covered

P1683: !_PREFETCH [11] (Int)
prefetch [%i2 + 64], 1

P1684: !_REPLACEMENT [0] (Int)
sethi %hi(0x0), %l3
or %l3, %lo(0x0),  %l3
sethi %hi(0x10000), %l6
or %l6, %lo(0x10000),  %l6
add %i3, %l3, %l3
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]

P1685: !_REPLACEMENT [13] (Int)
sethi %hi(0x40), %o5
or %o5, %lo(0x40),  %o5
sethi %hi(0x10000), %l3
or %l3, %lo(0x10000),  %l3
add %i3, %o5, %o5
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]

P1686: !_LD [2] (FP)
ld [%i0 + 12], %f4
! 1 addresses covered

P1687: !_DWLD [11] (FP)
ldd [%i2 + 64], %f18
! 1 addresses covered
fmovs %f18, %f5

P1688: !_ST [9] (maybe <- 0x400000d2) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i1 + 512 ]

P1689: !_CAS [7] (maybe <- 0x80005b) (Int)
add %i1, 84, %l7
lduw [%l7], %o4
mov %o4, %l6
! move %l6(lower) -> %o4(upper)
sllx %l6, 32, %o4
mov %l4, %l3
cas [%l7], %l6, %l3
! move %l3(lower) -> %o4(lower)
srl %l3, 0, %l7
or %l7, %o4, %o4
!---- flushing int results buffer----
mov %o0, %l5
mov %o1, %l5
mov %o2, %l5
mov %o3, %l5
mov %o4, %l5
add   %l4, 1, %l4

P1690: !_DWST [12] (maybe <- 0x400000d3) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
std %f20, [%i3 + 0]

P1691: !_DWST [0] (maybe <- 0x400000d4) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
! 1 th moved, current_fp_src=21 
fmovs  %f16, %f21
fadds  %f16, %f17, %f16
std %f20, [%i0 + 0]

P1692: !_PREFETCH [8] (Int)
prefetch [%i1 + 256], 1

P1693: !_ST [1] (maybe <- 0x400000d6) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i0 + 4 ]

P1694: !_REPLACEMENT [2] (Int)
sethi %hi(0xc), %l7
or %l7, %lo(0xc),  %l7
sethi %hi(0x10000), %o5
or %o5, %lo(0x10000),  %o5
add %i3, %l7, %l7
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]

P1695: !_MEMBAR (Int)
membar #StoreLoad

P1696: !_ST [7] (maybe <- 0x400000d7) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i1 + 84 ]

P1697: !_LD [7] (FP)
ld [%i1 + 84], %f6
! 1 addresses covered

P1698: !_PREFETCH [9] (Int)
prefetch [%i1 + 512], 1

P1699: !_CAS [4] (maybe <- 0x80005c) (Int)
add %i0, 64, %l6
lduw [%l6], %o0
mov %o0, %l3
! move %l3(lower) -> %o0(upper)
sllx %l3, 32, %o0
mov %l4, %o5
cas [%l6], %l3, %o5
! move %o5(lower) -> %o0(lower)
srl %o5, 0, %l6
or %l6, %o0, %o0
add   %l4, 1, %l4

P1700: !_CAS [10] (maybe <- 0x80005d) (Int)
add %i2, 32, %l6
lduw [%l6], %o1
mov %o1, %l3
! move %l3(lower) -> %o1(upper)
sllx %l3, 32, %o1
mov %l4, %o5
cas [%l6], %l3, %o5
! move %o5(lower) -> %o1(lower)
srl %o5, 0, %l6
or %l6, %o1, %o1
add   %l4, 1, %l4

P1701: !_CASX [3] (maybe <- 0x80005e) (Int)
add %i0, 32, %l6
ldx [%l6], %o2
! move %o2(upper) -> %o2(upper)
! move %o2(lower) -> %o2(lower)
mov  %o2, %l3
sllx %l4, 32, %o3
casx [%l6], %l3, %o3
! move %o3(upper) -> %o3(upper)
! move %o3(lower) -> %o3(lower)
add  %l4, 1, %l4

P1702: !_ST [1] (maybe <- 0x400000d8) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i0 + 4 ]

P1703: !_PREFETCH [2] (Int)
prefetch [%i0 + 12], 1

P1704: !_DWLD [7] (FP) (CBR)
ldd [%i1 + 80], %f18
! 2 addresses covered
fmovs %f18, %f7
fmovs %f19, %f8

! cbranch
andcc %l0, 1, %g0
be,pn  %xcc, TARGET1704
nop
RET1704:

! lfsr step begin
srlx %l0, 1, %o5
xnor %o5, %l0, %o5
sllx %o5, 63, %o5
or  %o5, %l0, %l0
srlx %l0, 1, %l0


P1705: !_CAS [15] (maybe <- 0x80005f) (Int) (Branch target of P1996)
add %i3, 192, %l6
lduw [%l6], %o4
mov %o4, %l3
! move %l3(lower) -> %o4(upper)
sllx %l3, 32, %o4
mov %l4, %o5
cas [%l6], %l3, %o5
! move %o5(lower) -> %o4(lower)
srl %o5, 0, %l6
or %l6, %o4, %o4
!---- flushing int results buffer----
mov %o0, %l5
mov %o1, %l5
mov %o2, %l5
mov %o3, %l5
mov %o4, %l5
add   %l4, 1, %l4
ba P1706
nop

TARGET1996:
ba RET1996
nop


P1706: !_REPLACEMENT [2] (Int) (CBR)
sethi %hi(0xc), %l3
or %l3, %lo(0xc),  %l3
sethi %hi(0x10000), %l6
or %l6, %lo(0x10000),  %l6
add %i3, %l3, %l3
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]

! cbranch
andcc %l0, 1, %g0
be,pn  %xcc, TARGET1706
nop
RET1706:

! lfsr step begin
srlx %l0, 1, %o5
xnor %o5, %l0, %o5
sllx %o5, 63, %o5
or  %o5, %l0, %l0
srlx %l0, 1, %l0


P1707: !_ST [7] (maybe <- 0x400000d9) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i1 + 84 ]

P1708: !_ST [11] (maybe <- 0x400000da) (FP) (CBR)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i2 + 64 ]

! cbranch
andcc %l0, 1, %g0
be,pt  %xcc, TARGET1708
nop
RET1708:

! lfsr step begin
srlx %l0, 1, %l7
xnor %l7, %l0, %l7
sllx %l7, 63, %l7
or  %l7, %l0, %l0
srlx %l0, 1, %l0


P1709: !_REPLACEMENT [1] (Int)
sethi %hi(0x4), %o5
or %o5, %lo(0x4),  %o5
sethi %hi(0x10000), %l3
or %l3, %lo(0x10000),  %l3
add %i3, %o5, %o5
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]

P1710: !_ST [3] (maybe <- 0x400000db) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i0 + 32 ]

P1711: !_MEMBAR (Int)
membar #StoreLoad

P1712: !_DWST [1] (maybe <- 0x400000dc) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
! 1 th moved, current_fp_src=21 
fmovs  %f16, %f21
fadds  %f16, %f17, %f16
std %f20, [%i0 + 0]

P1713: !_LD [1] (FP)
ld [%i0 + 4], %f9
! 1 addresses covered

P1714: !_PREFETCH [3] (Int) (LE)
wr %g0, 0x88, %asi
prefetcha [%i0 + 32] %asi, 1

P1715: !_ST [9] (maybe <- 0x400000de) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i1 + 512 ]

P1716: !_DWST [9] (maybe <- 0x400000df) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
std %f20, [%i1 + 512]

P1717: !_MEMBAR (Int)
membar #StoreLoad

P1718: !_REPLACEMENT [9] (Int)
sethi %hi(0x200), %l7
or %l7, %lo(0x200),  %l7
sethi %hi(0x10000), %o5
or %o5, %lo(0x10000),  %o5
add %i3, %l7, %l7
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]

P1719: !_DWST [1] (maybe <- 0x400000e0) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
! 1 th moved, current_fp_src=21 
fmovs  %f16, %f21
fadds  %f16, %f17, %f16
std %f20, [%i0 + 0]

P1720: !_LD [15] (FP)
ld [%i3 + 192], %f10
! 1 addresses covered

P1721: !_PREFETCH [12] (Int)
prefetch [%i3 + 0], 1

P1722: !_CAS [5] (maybe <- 0x800060) (Int)
add %i1, 76, %l6
lduw [%l6], %o0
mov %o0, %l3
! move %l3(lower) -> %o0(upper)
sllx %l3, 32, %o0
mov %l4, %o5
cas [%l6], %l3, %o5
! move %o5(lower) -> %o0(lower)
srl %o5, 0, %l6
or %l6, %o0, %o0
add   %l4, 1, %l4

P1723: !_DWLD [15] (FP)
ldd [%i3 + 192], %f18
! 1 addresses covered
fmovs %f18, %f11

P1724: !_PREFETCH [2] (Int) (CBR)
prefetch [%i0 + 12], 1

! cbranch
andcc %l0, 1, %g0
be,pt  %xcc, TARGET1724
nop
RET1724:

! lfsr step begin
srlx %l0, 1, %l3
xnor %l3, %l0, %l3
sllx %l3, 63, %l3
or  %l3, %l0, %l0
srlx %l0, 1, %l0


P1725: !_LD [1] (FP)
ld [%i0 + 4], %f12
! 1 addresses covered

P1726: !_MEMBAR (Int)
membar #StoreLoad

P1727: !_PREFETCH [6] (Int)
prefetch [%i1 + 80], 1

P1728: !_DWST [0] (maybe <- 0x400000e2) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
! 1 th moved, current_fp_src=21 
fmovs  %f16, %f21
fadds  %f16, %f17, %f16
std %f20, [%i0 + 0]

P1729: !_LD [12] (FP)
ld [%i3 + 0], %f13
! 1 addresses covered

P1730: !_ST [5] (maybe <- 0x400000e4) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i1 + 76 ]

P1731: !_ST [4] (maybe <- 0x400000e5) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i0 + 64 ]

P1732: !_ST [7] (maybe <- 0x400000e6) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i1 + 84 ]

P1733: !_DWLD [7] (FP)
ldd [%i1 + 80], %f14
! 2 addresses covered
!---- flushing fp results buffer to %f30 ----
fmovd %f0, %f30
fmovd %f2, %f30
fmovd %f4, %f30
fmovd %f6, %f30
fmovd %f8, %f30
fmovd %f10, %f30
fmovd %f12, %f30
fmovd %f14, %f30

P1734: !_PREFETCH [11] (Int)
prefetch [%i2 + 64], 1

P1735: !_DWLD [9] (FP)
ldd [%i1 + 512], %f0
! 1 addresses covered

P1736: !_REPLACEMENT [13] (Int)
sethi %hi(0x40), %l6
or %l6, %lo(0x40),  %l6
sethi %hi(0x10000), %l7
or %l7, %lo(0x10000),  %l7
add %i3, %l6, %l6
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]

P1737: !_LD [12] (FP)
ld [%i3 + 0], %f1
! 1 addresses covered

P1738: !_DWLD [12] (FP)
ldd [%i3 + 0], %f2
! 1 addresses covered

P1739: !_DWLD [4] (FP) (CBR)
ldd [%i0 + 64], %f18
! 1 addresses covered
fmovs %f18, %f3

! cbranch
andcc %l0, 1, %g0
be,pn  %xcc, TARGET1739
nop
RET1739:

! lfsr step begin
srlx %l0, 1, %l3
xnor %l3, %l0, %l3
sllx %l3, 63, %l3
or  %l3, %l0, %l0
srlx %l0, 1, %l0


P1740: !_REPLACEMENT [14] (Int)
sethi %hi(0x80), %l6
or %l6, %lo(0x80),  %l6
sethi %hi(0x10000), %l7
or %l7, %lo(0x10000),  %l7
add %i3, %l6, %l6
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]

P1741: !_DWLD [15] (FP)
ldd [%i3 + 192], %f4
! 1 addresses covered

P1742: !_DWLD [9] (FP)
ldd [%i1 + 512], %f18
! 1 addresses covered
fmovs %f18, %f5

P1743: !_CASX [1] (maybe <- 0x800061) (Int)
add %i0, 0, %l6
ldx [%l6], %o1
! move %o1(upper) -> %o1(upper)
! move %o1(lower) -> %o1(lower)
mov %o1, %l3
sllx %l4, 32, %o2
add  %l4, 1, %l4
or   %l4, %o2, %o2
casx [%l6], %l3, %o2
! move %o2(upper) -> %o2(upper)
! move %o2(lower) -> %o2(lower)
add  %l4, 1, %l4

P1744: !_DWLD [1] (FP)
ldd [%i0 + 0], %f6
! 2 addresses covered

P1745: !_REPLACEMENT [2] (Int)
sethi %hi(0xc), %l3
or %l3, %lo(0xc),  %l3
sethi %hi(0x10000), %l6
or %l6, %lo(0x10000),  %l6
add %i3, %l3, %l3
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]

P1746: !_ST [11] (maybe <- 0x400000e7) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i2 + 64 ]

P1747: !_ST [15] (maybe <- 0x400000e8) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i3 + 192 ]

P1748: !_PREFETCH [0] (Int) (Branch target of P1704)
prefetch [%i0 + 0], 1
ba P1749
nop

TARGET1704:
ba RET1704
nop


P1749: !_SWAP [15] (maybe <- 0x800063) (Int)
mov %l4, %o3
swap  [%i3 + 192], %o3
! move %o3(lower) -> %o3(upper)
sllx %o3, 32, %o3
add   %l4, 1, %l4

P1750: !_ST [7] (maybe <- 0x400000e9) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i1 + 84 ]

P1751: !_REPLACEMENT [13] (Int)
sethi %hi(0x40), %o5
or %o5, %lo(0x40),  %o5
sethi %hi(0x10000), %l3
or %l3, %lo(0x10000),  %l3
add %i3, %o5, %o5
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]

P1752: !_PREFETCH [2] (Int)
prefetch [%i0 + 12], 1

P1753: !_REPLACEMENT [2] (Int)
sethi %hi(0xc), %l7
or %l7, %lo(0xc),  %l7
sethi %hi(0x10000), %o5
or %o5, %lo(0x10000),  %o5
add %i3, %l7, %l7
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]

P1754: !_DWST [8] (maybe <- 0x400000ea) (FP) (Branch target of P1487)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
std %f20, [%i1 + 256]
ba P1755
nop

TARGET1487:
ba RET1487
nop


P1755: !_CAS [14] (maybe <- 0x800064) (Int)
add %i3, 128, %l6
lduw [%l6], %o5
mov %o5, %l3
! move %l3(lower) -> %o3(lower)
or %l3, %o3, %o3
mov %l4, %o4
cas [%l6], %l3, %o4
! move %o4(lower) -> %o4(upper)
sllx %o4, 32, %o4
add   %l4, 1, %l4

P1756: !_PREFETCH [11] (Int)
prefetch [%i2 + 64], 1

P1757: !_PREFETCH [15] (Int)
prefetch [%i3 + 192], 1

P1758: !_ST [4] (maybe <- 0x400000eb) (FP) (CBR)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i0 + 64 ]

! cbranch
andcc %l0, 1, %g0
be,pn  %xcc, TARGET1758
nop
RET1758:

! lfsr step begin
srlx %l0, 1, %o5
xnor %o5, %l0, %o5
sllx %o5, 63, %o5
or  %o5, %l0, %l0
srlx %l0, 1, %l0


P1759: !_ST [12] (maybe <- 0x400000ec) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i3 + 0 ]

P1760: !_DWLD [1] (FP)
ldd [%i0 + 0], %f8
! 2 addresses covered

P1761: !_ST [9] (maybe <- 0x400000ed) (FP) (CBR)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i1 + 512 ]

! cbranch
andcc %l0, 1, %g0
be,pn  %xcc, TARGET1761
nop
RET1761:

! lfsr step begin
srlx %l0, 1, %l7
xnor %l7, %l0, %l7
sllx %l7, 63, %l7
or  %l7, %l0, %l0
srlx %l0, 1, %l0


P1762: !_LD [12] (FP)
ld [%i3 + 0], %f10
! 1 addresses covered

P1763: !_REPLACEMENT [5] (Int)
sethi %hi(0x4c), %o5
or %o5, %lo(0x4c),  %o5
sethi %hi(0x10000), %l3
or %l3, %lo(0x10000),  %l3
add %i3, %o5, %o5
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]

P1764: !_REPLACEMENT [11] (Int) (CBR)
sethi %hi(0x40), %l7
or %l7, %lo(0x40),  %l7
sethi %hi(0x10000), %o5
or %o5, %lo(0x10000),  %o5
add %i3, %l7, %l7
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]

! cbranch
andcc %l0, 1, %g0
be,pn  %xcc, TARGET1764
nop
RET1764:

! lfsr step begin
srlx %l0, 1, %l6
xnor %l6, %l0, %l6
sllx %l6, 63, %l6
or  %l6, %l0, %l0
srlx %l0, 1, %l0


P1765: !_DWLD [14] (FP)
ldd [%i3 + 128], %f18
! 1 addresses covered
fmovs %f18, %f11

P1766: !_LD [13] (FP)
ld [%i3 + 64], %f12
! 1 addresses covered

P1767: !_DWLD [8] (FP)
ldd [%i1 + 256], %f18
! 1 addresses covered
fmovs %f18, %f13

P1768: !_PREFETCH [13] (Int)
prefetch [%i3 + 64], 1

P1769: !_PREFETCH [9] (Int)
prefetch [%i1 + 512], 1

P1770: !_LD [12] (FP)
ld [%i3 + 0], %f14
! 1 addresses covered

P1771: !_CAS [9] (maybe <- 0x800065) (Int)
add %i1, 512, %o5
lduw [%o5], %l6
mov %l6, %l7
! move %l7(lower) -> %o4(lower)
or %l7, %o4, %o4
!---- flushing int results buffer----
mov %o0, %l5
mov %o1, %l5
mov %o2, %l5
mov %o3, %l5
mov %o4, %l5
mov %l4, %o0
cas [%o5], %l7, %o0
! move %o0(lower) -> %o0(upper)
sllx %o0, 32, %o0
add   %l4, 1, %l4

P1772: !_DWST [12] (maybe <- 0x400000ee) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
std %f20, [%i3 + 0]

P1773: !_LD [1] (FP)
ld [%i0 + 4], %f15
! 1 addresses covered
!---- flushing fp results buffer to %f30 ----
fmovd %f0, %f30
fmovd %f2, %f30
fmovd %f4, %f30
fmovd %f6, %f30
fmovd %f8, %f30
fmovd %f10, %f30
fmovd %f12, %f30
fmovd %f14, %f30

P1774: !_ST [3] (maybe <- 0x400000ef) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i0 + 32 ]

P1775: !_DWST [8] (maybe <- 0x400000f0) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
std %f20, [%i1 + 256]

P1776: !_REPLACEMENT [6] (Int)
sethi %hi(0x50), %o5
or %o5, %lo(0x50),  %o5
sethi %hi(0x10000), %l3
or %l3, %lo(0x10000),  %l3
add %i3, %o5, %o5
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]

P1777: !_ST [4] (maybe <- 0x400000f1) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i0 + 64 ]

P1778: !_SWAP [1] (maybe <- 0x800066) (Int)
mov %l4, %o5
swap  [%i0 + 4], %o5
! move %o5(lower) -> %o0(lower)
srl %o5, 0, %l6
or %l6, %o0, %o0
add   %l4, 1, %l4

P1779: !_PREFETCH [0] (Int) (LE)
wr %g0, 0x88, %asi
prefetcha [%i0 + 0] %asi, 1

P1780: !_CASX [10] (maybe <- 0x800067) (Int)
add %i2, 32, %l6
ldx [%l6], %o1
! move %o1(upper) -> %o1(upper)
! move %o1(lower) -> %o1(lower)
mov  %o1, %l3
sllx %l4, 32, %o2
casx [%l6], %l3, %o2
! move %o2(upper) -> %o2(upper)
! move %o2(lower) -> %o2(lower)
add  %l4, 1, %l4

P1781: !_DWST [3] (maybe <- 0x400000f2) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
std %f20, [%i0 + 32]

P1782: !_DWST [6] (maybe <- 0x400000f3) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
! 1 th moved, current_fp_src=21 
fmovs  %f16, %f21
fadds  %f16, %f17, %f16
std %f20, [%i1 + 80]

P1783: !_MEMBAR (Int)
membar #StoreLoad

P1784: !_DWST [9] (maybe <- 0x400000f5) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
std %f20, [%i1 + 512]

P1785: !_PREFETCH [11] (Int)
prefetch [%i2 + 64], 1

P1786: !_DWLD [11] (FP)
ldd [%i2 + 64], %f0
! 1 addresses covered

P1787: !_DWST [13] (maybe <- 0x400000f6) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
std %f20, [%i3 + 64]

P1788: !_DWLD [4] (FP)
ldd [%i0 + 64], %f18
! 1 addresses covered
fmovs %f18, %f1

P1789: !_LD [3] (FP)
ld [%i0 + 32], %f2
! 1 addresses covered

P1790: !_CASX [7] (maybe <- 0x800068) (Int)
add %i1, 80, %l6
ldx [%l6], %o3
! move %o3(upper) -> %o3(upper)
! move %o3(lower) -> %o3(lower)
mov %o3, %l3
sllx %l4, 32, %o4
add  %l4, 1, %l4
or   %l4, %o4, %o4
casx [%l6], %l3, %o4
! move %o4(upper) -> %o4(upper)
! move %o4(lower) -> %o4(lower)
!---- flushing int results buffer----
mov %o0, %l5
mov %o1, %l5
mov %o2, %l5
mov %o3, %l5
mov %o4, %l5
add  %l4, 1, %l4

P1791: !_ST [12] (maybe <- 0x400000f7) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i3 + 0 ]

P1792: !_CAS [13] (maybe <- 0x80006a) (Int)
add %i3, 64, %l3
lduw [%l3], %o0
mov %o0, %o5
! move %o5(lower) -> %o0(upper)
sllx %o5, 32, %o0
mov %l4, %l7
cas [%l3], %o5, %l7
! move %l7(lower) -> %o0(lower)
srl %l7, 0, %l3
or %l3, %o0, %o0
add   %l4, 1, %l4

P1793: !_CAS [4] (maybe <- 0x80006b) (Int)
add %i0, 64, %l3
lduw [%l3], %o1
mov %o1, %o5
! move %o5(lower) -> %o1(upper)
sllx %o5, 32, %o1
mov %l4, %l7
cas [%l3], %o5, %l7
! move %l7(lower) -> %o1(lower)
srl %l7, 0, %l3
or %l3, %o1, %o1
add   %l4, 1, %l4

P1794: !_REPLACEMENT [10] (Int)
sethi %hi(0x20), %o5
or %o5, %lo(0x20),  %o5
sethi %hi(0x10000), %l3
or %l3, %lo(0x10000),  %l3
add %i3, %o5, %o5
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]

P1795: !_LD [13] (FP) (Branch target of P1837)
ld [%i3 + 64], %f3
! 1 addresses covered
ba P1796
nop

TARGET1837:
ba RET1837
nop


P1796: !_SWAP [7] (maybe <- 0x80006c) (Int)
mov %l4, %o2
swap  [%i1 + 84], %o2
! move %o2(lower) -> %o2(upper)
sllx %o2, 32, %o2
add   %l4, 1, %l4

P1797: !_DWLD [8] (FP)
ldd [%i1 + 256], %f4
! 1 addresses covered

P1798: !_LD [1] (FP) (Branch target of P1764)
ld [%i0 + 4], %f5
! 1 addresses covered
ba P1799
nop

TARGET1764:
ba RET1764
nop


P1799: !_ST [7] (maybe <- 0x400000f8) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i1 + 84 ]

P1800: !_LD [7] (FP)
ld [%i1 + 84], %f6
! 1 addresses covered

P1801: !_DWLD [8] (FP)
ldd [%i1 + 256], %f18
! 1 addresses covered
fmovs %f18, %f7

P1802: !_REPLACEMENT [2] (Int) (Branch target of P1451)
sethi %hi(0xc), %l3
or %l3, %lo(0xc),  %l3
sethi %hi(0x10000), %l6
or %l6, %lo(0x10000),  %l6
add %i3, %l3, %l3
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
ba P1803
nop

TARGET1451:
ba RET1451
nop


P1803: !_DWST [1] (maybe <- 0x400000f9) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
! 1 th moved, current_fp_src=21 
fmovs  %f16, %f21
fadds  %f16, %f17, %f16
std %f20, [%i0 + 0]

P1804: !_DWLD [11] (FP)
ldd [%i2 + 64], %f8
! 1 addresses covered

P1805: !_LD [11] (FP)
ld [%i2 + 64], %f9
! 1 addresses covered

P1806: !_MEMBAR (Int)
membar #StoreLoad

P1807: !_CASX [3] (maybe <- 0x80006d) (Int)
add %i0, 32, %o5
ldx [%o5], %l6
! move %l6(upper) -> %o2(lower)
srlx %l6, 32, %l7
or %l7, %o2, %o2
! move %l6(lower) -> %o3(upper)
sllx %l6, 32, %o3
mov  %l6, %l7
sllx %l4, 32, %l6
casx [%o5], %l7, %l6
! move %l6(upper) -> %o3(lower)
srlx %l6, 32, %o5
or %o5, %o3, %o3
! move %l6(lower) -> %o4(upper)
sllx %l6, 32, %o4
add  %l4, 1, %l4

P1808: !_ST [2] (maybe <- 0x400000fb) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i0 + 12 ]

P1809: !_SWAP [5] (maybe <- 0x80006e) (Int)
mov %l4, %o5
swap  [%i1 + 76], %o5
! move %o5(lower) -> %o4(lower)
srl %o5, 0, %l6
or %l6, %o4, %o4
!---- flushing int results buffer----
mov %o0, %l5
mov %o1, %l5
mov %o2, %l5
mov %o3, %l5
mov %o4, %l5
add   %l4, 1, %l4

P1810: !_DWST [12] (maybe <- 0x400000fc) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
std %f20, [%i3 + 0]

P1811: !_DWST [6] (maybe <- 0x400000fd) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
! 1 th moved, current_fp_src=21 
fmovs  %f16, %f21
fadds  %f16, %f17, %f16
std %f20, [%i1 + 80]

P1812: !_SWAP [4] (maybe <- 0x80006f) (Int)
mov %l4, %o0
swap  [%i0 + 64], %o0
! move %o0(lower) -> %o0(upper)
sllx %o0, 32, %o0
add   %l4, 1, %l4

P1813: !_PREFETCH [12] (Int)
prefetch [%i3 + 0], 1

P1814: !_DWLD [15] (FP)
ldd [%i3 + 192], %f10
! 1 addresses covered

P1815: !_REPLACEMENT [5] (Int)
sethi %hi(0x4c), %l6
or %l6, %lo(0x4c),  %l6
sethi %hi(0x10000), %l7
or %l7, %lo(0x10000),  %l7
add %i3, %l6, %l6
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]

P1816: !_LD [7] (FP)
ld [%i1 + 84], %f11
! 1 addresses covered

P1817: !_ST [15] (maybe <- 0x400000ff) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i3 + 192 ]

P1818: !_ST [0] (maybe <- 0x40000100) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i0 + 0 ]

P1819: !_REPLACEMENT [7] (Int) (Branch target of P1706)
sethi %hi(0x54), %l7
or %l7, %lo(0x54),  %l7
sethi %hi(0x10000), %o5
or %o5, %lo(0x10000),  %o5
add %i3, %l7, %l7
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]
ba P1820
nop

TARGET1706:
ba RET1706
nop


P1820: !_ST [8] (maybe <- 0x40000101) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i1 + 256 ]

P1821: !_CAS [2] (maybe <- 0x800070) (Int)
add %i0, 12, %l6
lduw [%l6], %o5
mov %o5, %l3
! move %l3(lower) -> %o0(lower)
or %l3, %o0, %o0
mov %l4, %o1
cas [%l6], %l3, %o1
! move %o1(lower) -> %o1(upper)
sllx %o1, 32, %o1
add   %l4, 1, %l4

P1822: !_CASX [7] (maybe <- 0x800071) (Int)
add %i1, 80, %l6
ldx [%l6], %o5
! move %o5(upper) -> %o1(lower)
srlx %o5, 32, %l3
or %l3, %o1, %o1
! move %o5(lower) -> %o2(upper)
sllx %o5, 32, %o2
mov %o5, %l3
sllx %l4, 32, %o5
add  %l4, 1, %l4
or   %l4, %o5, %o5
casx [%l6], %l3, %o5
! move %o5(upper) -> %o2(lower)
srlx %o5, 32, %l6
or %l6, %o2, %o2
! move %o5(lower) -> %o3(upper)
sllx %o5, 32, %o3
add  %l4, 1, %l4

P1823: !_DWLD [5] (FP)
ldd [%i1 + 72], %f12
! 1 addresses covered
fmovs %f13, %f12

P1824: !_REPLACEMENT [15] (Int)
sethi %hi(0xc0), %l3
or %l3, %lo(0xc0),  %l3
sethi %hi(0x10000), %l6
or %l6, %lo(0x10000),  %l6
add %i3, %l3, %l3
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]

P1825: !_REPLACEMENT [5] (Int) (CBR)
sethi %hi(0x4c), %o5
or %o5, %lo(0x4c),  %o5
sethi %hi(0x10000), %l3
or %l3, %lo(0x10000),  %l3
add %i3, %o5, %o5
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]

! cbranch
andcc %l0, 1, %g0
be,pt  %xcc, TARGET1825
nop
RET1825:

! lfsr step begin
srlx %l0, 1, %l7
xnor %l7, %l0, %l7
sllx %l7, 63, %l7
or  %l7, %l0, %l0
srlx %l0, 1, %l0


P1826: !_LD [4] (FP)
ld [%i0 + 64], %f13
! 1 addresses covered

P1827: !_DWLD [2] (FP)
ldd [%i0 + 8], %f14
! 1 addresses covered
fmovs %f15, %f14

P1828: !_ST [13] (maybe <- 0x40000102) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i3 + 64 ]

P1829: !_PREFETCH [6] (Int)
prefetch [%i1 + 80], 1

P1830: !_LD [13] (FP)
ld [%i3 + 64], %f15
! 1 addresses covered
!---- flushing fp results buffer to %f30 ----
fmovd %f0, %f30
fmovd %f2, %f30
fmovd %f4, %f30
fmovd %f6, %f30
fmovd %f8, %f30
fmovd %f10, %f30
fmovd %f12, %f30
fmovd %f14, %f30

P1831: !_LD [5] (FP)
ld [%i1 + 76], %f0
! 1 addresses covered

P1832: !_REPLACEMENT [12] (Int)
sethi %hi(0x0), %l7
or %l7, %lo(0x0),  %l7
sethi %hi(0x10000), %o5
or %o5, %lo(0x10000),  %o5
add %i3, %l7, %l7
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]

P1833: !_DWST [8] (maybe <- 0x40000103) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
std %f20, [%i1 + 256]

P1834: !_DWLD [7] (FP)
ldd [%i1 + 80], %f18
! 2 addresses covered
fmovs %f18, %f1
fmovs %f19, %f2

P1835: !_DWST [14] (maybe <- 0x40000104) (FP) (CBR)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
std %f20, [%i3 + 128]

! cbranch
andcc %l0, 1, %g0
be,pt  %xcc, TARGET1835
nop
RET1835:

! lfsr step begin
srlx %l0, 1, %o5
xnor %o5, %l0, %o5
sllx %o5, 63, %o5
or  %o5, %l0, %l0
srlx %l0, 1, %l0


P1836: !_ST [10] (maybe <- 0x40000105) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i2 + 32 ]

P1837: !_DWST [2] (maybe <- 0x40000106) (FP) (CBR)
! 0 th moved, current_fp_src=21 
fmovs  %f16, %f21
fadds  %f16, %f17, %f16
std %f20, [%i0 + 8]

! cbranch
andcc %l0, 1, %g0
be,pn  %xcc, TARGET1837
nop
RET1837:

! lfsr step begin
srlx %l0, 1, %l7
xnor %l7, %l0, %l7
sllx %l7, 63, %l7
or  %l7, %l0, %l0
srlx %l0, 1, %l0


P1838: !_DWLD [6] (FP)
ldd [%i1 + 80], %f18
! 2 addresses covered
fmovs %f18, %f3
fmovs %f19, %f4

P1839: !_REPLACEMENT [4] (Int)
sethi %hi(0x40), %o5
or %o5, %lo(0x40),  %o5
sethi %hi(0x10000), %l3
or %l3, %lo(0x10000),  %l3
add %i3, %o5, %o5
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]

P1840: !_PREFETCH [5] (Int)
prefetch [%i1 + 76], 1

P1841: !_LD [13] (FP)
ld [%i3 + 64], %f5
! 1 addresses covered

P1842: !_DWST [7] (maybe <- 0x40000107) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
! 1 th moved, current_fp_src=21 
fmovs  %f16, %f21
fadds  %f16, %f17, %f16
std %f20, [%i1 + 80]

P1843: !_REPLACEMENT [9] (Int)
sethi %hi(0x200), %l6
or %l6, %lo(0x200),  %l6
sethi %hi(0x10000), %l7
or %l7, %lo(0x10000),  %l7
add %i3, %l6, %l6
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]

P1844: !_LD [5] (FP)
ld [%i1 + 76], %f6
! 1 addresses covered

P1845: !_LD [1] (FP)
ld [%i0 + 4], %f7
! 1 addresses covered

P1846: !_PREFETCH [11] (Int)
prefetch [%i2 + 64], 1

P1847: !_ST [2] (maybe <- 0x40000109) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i0 + 12 ]

P1848: !_ST [9] (maybe <- 0x4000010a) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i1 + 512 ]

P1849: !_MEMBAR (Int)
membar #StoreLoad

P1850: !_SWAP [6] (maybe <- 0x800073) (Int)
mov %l4, %l3
swap  [%i1 + 80], %l3
! move %l3(lower) -> %o3(lower)
srl %l3, 0, %l7
or %l7, %o3, %o3
add   %l4, 1, %l4

P1851: !_SWAP [8] (maybe <- 0x800074) (Int)
mov %l4, %o4
swap  [%i1 + 256], %o4
! move %o4(lower) -> %o4(upper)
sllx %o4, 32, %o4
add   %l4, 1, %l4

P1852: !_LD [6] (FP)
ld [%i1 + 80], %f8
! 1 addresses covered

P1853: !_SWAP [6] (maybe <- 0x800075) (Int)
mov %l4, %l7
swap  [%i1 + 80], %l7
! move %l7(lower) -> %o4(lower)
srl %l7, 0, %l3
or %l3, %o4, %o4
!---- flushing int results buffer----
mov %o0, %l5
mov %o1, %l5
mov %o2, %l5
mov %o3, %l5
mov %o4, %l5
add   %l4, 1, %l4

P1854: !_DWLD [12] (FP)
ldd [%i3 + 0], %f18
! 1 addresses covered
fmovs %f18, %f9

P1855: !_PREFETCH [6] (Int) (LE)
wr %g0, 0x88, %asi
prefetcha [%i1 + 80] %asi, 1

P1856: !_CASX [4] (maybe <- 0x800076) (Int)
add %i0, 64, %l3
ldx [%l3], %o0
! move %o0(upper) -> %o0(upper)
! move %o0(lower) -> %o0(lower)
mov  %o0, %o5
sllx %l4, 32, %o1
casx [%l3], %o5, %o1
! move %o1(upper) -> %o1(upper)
! move %o1(lower) -> %o1(lower)
add  %l4, 1, %l4

P1857: !_DWST [14] (maybe <- 0x4000010b) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
std %f20, [%i3 + 128]

P1858: !_DWST [5] (maybe <- 0x4000010c) (FP) (Branch target of P1957)
! 0 th moved, current_fp_src=21 
fmovs  %f16, %f21
fadds  %f16, %f17, %f16
std %f20, [%i1 + 72]
ba P1859
nop

TARGET1957:
ba RET1957
nop


P1859: !_REPLACEMENT [1] (Int)
sethi %hi(0x4), %l6
or %l6, %lo(0x4),  %l6
sethi %hi(0x10000), %l7
or %l7, %lo(0x10000),  %l7
add %i3, %l6, %l6
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]

P1860: !_REPLACEMENT [10] (Int)
sethi %hi(0x20), %l3
or %l3, %lo(0x20),  %l3
sethi %hi(0x10000), %l6
or %l6, %lo(0x10000),  %l6
add %i3, %l3, %l3
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]

P1861: !_CAS [9] (maybe <- 0x800077) (Int)
add %i1, 512, %l3
lduw [%l3], %o2
mov %o2, %o5
! move %o5(lower) -> %o2(upper)
sllx %o5, 32, %o2
mov %l4, %l7
cas [%l3], %o5, %l7
! move %l7(lower) -> %o2(lower)
srl %l7, 0, %l3
or %l3, %o2, %o2
add   %l4, 1, %l4

P1862: !_DWST [15] (maybe <- 0x4000010d) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
std %f20, [%i3 + 192]

P1863: !_LD [5] (FP)
ld [%i1 + 76], %f10
! 1 addresses covered

P1864: !_CASX [2] (maybe <- 0x800078) (Int)
add %i0, 8, %o5
ldx [%o5], %o3
! move %o3(upper) -> %o3(upper)
! move %o3(lower) -> %o3(lower)
mov  %o3, %l7
mov %l4, %o4
casx [%o5], %l7, %o4
! move %o4(upper) -> %o4(upper)
! move %o4(lower) -> %o4(lower)
!---- flushing int results buffer----
mov %o0, %l5
mov %o1, %l5
mov %o2, %l5
mov %o3, %l5
mov %o4, %l5
add  %l4, 1, %l4

P1865: !_REPLACEMENT [6] (Int)
sethi %hi(0x50), %l7
or %l7, %lo(0x50),  %l7
sethi %hi(0x10000), %o5
or %o5, %lo(0x10000),  %o5
add %i3, %l7, %l7
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]

P1866: !_LD [7] (FP)
ld [%i1 + 84], %f11
! 1 addresses covered

P1867: !_ST [10] (maybe <- 0x4000010e) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i2 + 32 ]

P1868: !_ST [14] (maybe <- 0x4000010f) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i3 + 128 ]

P1869: !_DWLD [7] (FP)
ldd [%i1 + 80], %f12
! 2 addresses covered

P1870: !_DWLD [4] (FP)
ldd [%i0 + 64], %f14
! 1 addresses covered

P1871: !_CAS [1] (maybe <- 0x800079) (Int)
add %i0, 4, %l3
lduw [%l3], %o0
mov %o0, %o5
! move %o5(lower) -> %o0(upper)
sllx %o5, 32, %o0
mov %l4, %l7
cas [%l3], %o5, %l7
! move %l7(lower) -> %o0(lower)
srl %l7, 0, %l3
or %l3, %o0, %o0
add   %l4, 1, %l4

P1872: !_DWLD [0] (FP)
ldd [%i0 + 0], %f18
! 2 addresses covered
fmovs %f18, %f15
!---- flushing fp results buffer to %f30 ----
fmovd %f0, %f30
fmovd %f2, %f30
fmovd %f4, %f30
fmovd %f6, %f30
fmovd %f8, %f30
fmovd %f10, %f30
fmovd %f12, %f30
fmovd %f14, %f30
fmovs %f19, %f0

P1873: !_PREFETCH [2] (Int) (LE)
wr %g0, 0x88, %asi
prefetcha [%i0 + 12] %asi, 1

P1874: !_CASX [0] (maybe <- 0x80007a) (Int)
add %i0, 0, %l3
ldx [%l3], %o1
! move %o1(upper) -> %o1(upper)
! move %o1(lower) -> %o1(lower)
mov %o1, %o5
sllx %l4, 32, %o2
add  %l4, 1, %l4
or   %l4, %o2, %o2
casx [%l3], %o5, %o2
! move %o2(upper) -> %o2(upper)
! move %o2(lower) -> %o2(lower)
add  %l4, 1, %l4

P1875: !_LD [0] (FP)
ld [%i0 + 0], %f1
! 1 addresses covered

P1876: !_LD [1] (FP)
ld [%i0 + 4], %f2
! 1 addresses covered

P1877: !_LD [0] (FP)
ld [%i0 + 0], %f3
! 1 addresses covered

P1878: !_REPLACEMENT [5] (Int)
sethi %hi(0x4c), %o5
or %o5, %lo(0x4c),  %o5
sethi %hi(0x10000), %l3
or %l3, %lo(0x10000),  %l3
add %i3, %o5, %o5
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]

P1879: !_DWST [5] (maybe <- 0x40000110) (FP)
! 0 th moved, current_fp_src=21 
fmovs  %f16, %f21
fadds  %f16, %f17, %f16
std %f20, [%i1 + 72]

P1880: !_PREFETCH [1] (Int)
prefetch [%i0 + 4], 1

P1881: !_ST [8] (maybe <- 0x40000111) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i1 + 256 ]

P1882: !_LD [6] (FP)
ld [%i1 + 80], %f4
! 1 addresses covered

P1883: !_SWAP [15] (maybe <- 0x80007c) (Int)
mov %l4, %o3
swap  [%i3 + 192], %o3
! move %o3(lower) -> %o3(upper)
sllx %o3, 32, %o3
add   %l4, 1, %l4

P1884: !_PREFETCH [11] (Int)
prefetch [%i2 + 64], 1

P1885: !_LD [9] (FP) (CBR)
ld [%i1 + 512], %f5
! 1 addresses covered

! cbranch
andcc %l0, 1, %g0
be,pn  %xcc, TARGET1885
nop
RET1885:

! lfsr step begin
srlx %l0, 1, %o5
xnor %o5, %l0, %o5
sllx %o5, 63, %o5
or  %o5, %l0, %l0
srlx %l0, 1, %l0


P1886: !_LD [6] (FP)
ld [%i1 + 80], %f6
! 1 addresses covered

P1887: !_DWLD [8] (FP)
ldd [%i1 + 256], %f18
! 1 addresses covered
fmovs %f18, %f7

P1888: !_PREFETCH [14] (Int)
prefetch [%i3 + 128], 1

P1889: !_DWLD [15] (FP)
ldd [%i3 + 192], %f8
! 1 addresses covered

P1890: !_LD [5] (FP)
ld [%i1 + 76], %f9
! 1 addresses covered

P1891: !_CAS [10] (maybe <- 0x80007d) (Int)
add %i2, 32, %l6
lduw [%l6], %o5
mov %o5, %l3
! move %l3(lower) -> %o3(lower)
or %l3, %o3, %o3
mov %l4, %o4
cas [%l6], %l3, %o4
! move %o4(lower) -> %o4(upper)
sllx %o4, 32, %o4
add   %l4, 1, %l4

P1892: !_LD [13] (FP)
ld [%i3 + 64], %f10
! 1 addresses covered

P1893: !_DWLD [4] (FP)
ldd [%i0 + 64], %f18
! 1 addresses covered
fmovs %f18, %f11

P1894: !_REPLACEMENT [9] (Int)
sethi %hi(0x200), %l3
or %l3, %lo(0x200),  %l3
sethi %hi(0x10000), %l6
or %l6, %lo(0x10000),  %l6
add %i3, %l3, %l3
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]

P1895: !_PREFETCH [8] (Int)
prefetch [%i1 + 256], 1

P1896: !_PREFETCH [14] (Int)
prefetch [%i3 + 128], 1

P1897: !_CAS [12] (maybe <- 0x80007e) (Int)
add %i3, 0, %l3
lduw [%l3], %l7
mov %l7, %o5
! move %o5(lower) -> %o4(lower)
or %o5, %o4, %o4
!---- flushing int results buffer----
mov %o0, %l5
mov %o1, %l5
mov %o2, %l5
mov %o3, %l5
mov %o4, %l5
mov %l4, %o0
cas [%l3], %o5, %o0
! move %o0(lower) -> %o0(upper)
sllx %o0, 32, %o0
add   %l4, 1, %l4

P1898: !_CASX [11] (maybe <- 0x80007f) (Int)
add %i2, 64, %l3
ldx [%l3], %l7
! move %l7(upper) -> %o0(lower)
srlx %l7, 32, %o5
or %o5, %o0, %o0
! move %l7(lower) -> %o1(upper)
sllx %l7, 32, %o1
mov  %l7, %o5
sllx %l4, 32, %l7
casx [%l3], %o5, %l7
! move %l7(upper) -> %o1(lower)
srlx %l7, 32, %l3
or %l3, %o1, %o1
! move %l7(lower) -> %o2(upper)
sllx %l7, 32, %o2
add  %l4, 1, %l4

P1899: !_ST [7] (maybe <- 0x40000112) (FP) (Branch target of P1494)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i1 + 84 ]
ba P1900
nop

TARGET1494:
ba RET1494
nop


P1900: !_ST [0] (maybe <- 0x40000113) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i0 + 0 ]

P1901: !_SWAP [8] (maybe <- 0x800080) (Int)
mov %l4, %o5
swap  [%i1 + 256], %o5
! move %o5(lower) -> %o2(lower)
srl %o5, 0, %l6
or %l6, %o2, %o2
add   %l4, 1, %l4

P1902: !_ST [6] (maybe <- 0x40000114) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i1 + 80 ]

P1903: !_DWLD [15] (FP)
ldd [%i3 + 192], %f12
! 1 addresses covered

P1904: !_DWLD [8] (FP)
ldd [%i1 + 256], %f18
! 1 addresses covered
fmovs %f18, %f13

P1905: !_SWAP [6] (maybe <- 0x800081) (Int)
mov %l4, %o3
swap  [%i1 + 80], %o3
! move %o3(lower) -> %o3(upper)
sllx %o3, 32, %o3
add   %l4, 1, %l4

P1906: !_ST [7] (maybe <- 0x40000115) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i1 + 84 ]

P1907: !_DWST [13] (maybe <- 0x40000116) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
std %f20, [%i3 + 64]

P1908: !_LD [5] (FP)
ld [%i1 + 76], %f14
! 1 addresses covered

P1909: !_DWST [12] (maybe <- 0x40000117) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
std %f20, [%i3 + 0]

P1910: !_MEMBAR (Int)
membar #StoreLoad

P1911: !_DWST [10] (maybe <- 0x40000118) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
std %f20, [%i2 + 32]

P1912: !_MEMBAR (Int)
membar #StoreLoad

P1913: !_DWLD [4] (FP)
ldd [%i0 + 64], %f18
! 1 addresses covered
fmovs %f18, %f15
!---- flushing fp results buffer to %f30 ----
fmovd %f0, %f30
fmovd %f2, %f30
fmovd %f4, %f30
fmovd %f6, %f30
fmovd %f8, %f30
fmovd %f10, %f30
fmovd %f12, %f30
fmovd %f14, %f30

P1914: !_CASX [12] (maybe <- 0x800082) (Int)
add %i3, 0, %o5
ldx [%o5], %l6
! move %l6(upper) -> %o3(lower)
srlx %l6, 32, %l7
or %l7, %o3, %o3
! move %l6(lower) -> %o4(upper)
sllx %l6, 32, %o4
mov  %l6, %l7
sllx %l4, 32, %l6
casx [%o5], %l7, %l6
! move %l6(upper) -> %o4(lower)
srlx %l6, 32, %o5
or %o5, %o4, %o4
!---- flushing int results buffer----
mov %o0, %l5
mov %o1, %l5
mov %o2, %l5
mov %o3, %l5
mov %o4, %l5
! move %l6(lower) -> %o0(upper)
sllx %l6, 32, %o0
add  %l4, 1, %l4

P1915: !_LD [2] (FP)
ld [%i0 + 12], %f0
! 1 addresses covered

P1916: !_ST [1] (maybe <- 0x40000119) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i0 + 4 ]

P1917: !_CASX [2] (maybe <- 0x800083) (Int)
add %i0, 8, %l7
ldx [%l7], %l3
! move %l3(upper) -> %o0(lower)
srlx %l3, 32, %l6
or %l6, %o0, %o0
! move %l3(lower) -> %o1(upper)
sllx %l3, 32, %o1
mov  %l3, %l6
mov %l4, %l3
casx [%l7], %l6, %l3
! move %l3(upper) -> %o1(lower)
srlx %l3, 32, %l7
or %l7, %o1, %o1
! move %l3(lower) -> %o2(upper)
sllx %l3, 32, %o2
add  %l4, 1, %l4

P1918: !_ST [0] (maybe <- 0x4000011a) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i0 + 0 ]

P1919: !_ST [4] (maybe <- 0x4000011b) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i0 + 64 ]

P1920: !_DWST [5] (maybe <- 0x4000011c) (FP)
! 0 th moved, current_fp_src=21 
fmovs  %f16, %f21
fadds  %f16, %f17, %f16
std %f20, [%i1 + 72]

P1921: !_LD [0] (FP) (Branch target of P1465)
ld [%i0 + 0], %f1
! 1 addresses covered
ba P1922
nop

TARGET1465:
ba RET1465
nop


P1922: !_ST [14] (maybe <- 0x4000011d) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i3 + 128 ]

P1923: !_PREFETCH [3] (Int)
prefetch [%i0 + 32], 1

P1924: !_REPLACEMENT [2] (Int)
sethi %hi(0xc), %l6
or %l6, %lo(0xc),  %l6
sethi %hi(0x10000), %l7
or %l7, %lo(0x10000),  %l7
add %i3, %l6, %l6
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]

P1925: !_PREFETCH [13] (Int)
prefetch [%i3 + 64], 1

P1926: !_PREFETCH [14] (Int)
prefetch [%i3 + 128], 1

P1927: !_DWLD [5] (FP)
ldd [%i1 + 72], %f2
! 1 addresses covered
fmovs %f3, %f2

P1928: !_DWST [15] (maybe <- 0x4000011e) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
std %f20, [%i3 + 192]

P1929: !_ST [11] (maybe <- 0x4000011f) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i2 + 64 ]

P1930: !_ST [10] (maybe <- 0x40000120) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i2 + 32 ]

P1931: !_CAS [1] (maybe <- 0x800084) (Int)
add %i0, 4, %l7
lduw [%l7], %l3
mov %l3, %l6
! move %l6(lower) -> %o2(lower)
or %l6, %o2, %o2
mov %l4, %o3
cas [%l7], %l6, %o3
! move %o3(lower) -> %o3(upper)
sllx %o3, 32, %o3
add   %l4, 1, %l4

P1932: !_DWLD [4] (FP)
ldd [%i0 + 64], %f18
! 1 addresses covered
fmovs %f18, %f3

P1933: !_DWST [15] (maybe <- 0x40000121) (FP) (CBR) (Branch target of P1974)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
std %f20, [%i3 + 192]

! cbranch
andcc %l0, 1, %g0
be,pt  %xcc, TARGET1933
nop
RET1933:

! lfsr step begin
srlx %l0, 1, %l3
xnor %l3, %l0, %l3
sllx %l3, 63, %l3
or  %l3, %l0, %l0
srlx %l0, 1, %l0

ba P1934
nop

TARGET1974:
ba RET1974
nop


P1934: !_DWST [14] (maybe <- 0x40000122) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
std %f20, [%i3 + 128]

P1935: !_LD [1] (FP) (CBR)
ld [%i0 + 4], %f4
! 1 addresses covered

! cbranch
andcc %l0, 1, %g0
be,pt  %xcc, TARGET1935
nop
RET1935:

! lfsr step begin
srlx %l0, 1, %l3
xnor %l3, %l0, %l3
sllx %l3, 63, %l3
or  %l3, %l0, %l0
srlx %l0, 1, %l0


P1936: !_LD [0] (FP)
ld [%i0 + 0], %f5
! 1 addresses covered

P1937: !_ST [5] (maybe <- 0x40000123) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i1 + 76 ]

P1938: !_PREFETCH [13] (Int)
prefetch [%i3 + 64], 1

P1939: !_CASX [6] (maybe <- 0x800085) (Int)
add %i1, 80, %l6
ldx [%l6], %o5
! move %o5(upper) -> %o3(lower)
srlx %o5, 32, %l3
or %l3, %o3, %o3
! move %o5(lower) -> %o4(upper)
sllx %o5, 32, %o4
mov %o5, %l3
sllx %l4, 32, %o5
add  %l4, 1, %l4
or   %l4, %o5, %o5
casx [%l6], %l3, %o5
! move %o5(upper) -> %o4(lower)
srlx %o5, 32, %l6
or %l6, %o4, %o4
!---- flushing int results buffer----
mov %o0, %l5
mov %o1, %l5
mov %o2, %l5
mov %o3, %l5
mov %o4, %l5
! move %o5(lower) -> %o0(upper)
sllx %o5, 32, %o0
add  %l4, 1, %l4

P1940: !_REPLACEMENT [7] (Int)
sethi %hi(0x54), %l3
or %l3, %lo(0x54),  %l3
sethi %hi(0x10000), %l6
or %l6, %lo(0x10000),  %l6
add %i3, %l3, %l3
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]

P1941: !_LD [10] (FP)
ld [%i2 + 32], %f6
! 1 addresses covered

P1942: !_NOP (Int)
nop

P1943: !_LD [8] (FP)
ld [%i1 + 256], %f7
! 1 addresses covered

P1944: !_REPLACEMENT [14] (Int)
sethi %hi(0x80), %o5
or %o5, %lo(0x80),  %o5
sethi %hi(0x10000), %l3
or %l3, %lo(0x10000),  %l3
add %i3, %o5, %o5
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]

P1945: !_ST [12] (maybe <- 0x40000124) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i3 + 0 ]

P1946: !_DWLD [3] (FP)
ldd [%i0 + 32], %f8
! 1 addresses covered

P1947: !_REPLACEMENT [1] (Int)
sethi %hi(0x4), %l6
or %l6, %lo(0x4),  %l6
sethi %hi(0x10000), %l7
or %l7, %lo(0x10000),  %l7
add %i3, %l6, %l6
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]

P1948: !_LD [4] (FP)
ld [%i0 + 64], %f9
! 1 addresses covered

P1949: !_PREFETCH [10] (Int)
prefetch [%i2 + 32], 1

P1950: !_ST [6] (maybe <- 0x40000125) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i1 + 80 ]

P1951: !_CASX [0] (maybe <- 0x800087) (Int)
add %i0, 0, %l3
ldx [%l3], %l7
! move %l7(upper) -> %o0(lower)
srlx %l7, 32, %o5
or %o5, %o0, %o0
! move %l7(lower) -> %o1(upper)
sllx %l7, 32, %o1
mov %l7, %o5
sllx %l4, 32, %l7
add  %l4, 1, %l4
or   %l4, %l7, %l7
casx [%l3], %o5, %l7
! move %l7(upper) -> %o1(lower)
srlx %l7, 32, %l3
or %l3, %o1, %o1
! move %l7(lower) -> %o2(upper)
sllx %l7, 32, %o2
add  %l4, 1, %l4

P1952: !_LD [0] (FP)
ld [%i0 + 0], %f10
! 1 addresses covered

P1953: !_ST [1] (maybe <- 0x40000126) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i0 + 4 ]

P1954: !_DWLD [14] (FP)
ldd [%i3 + 128], %f18
! 1 addresses covered
fmovs %f18, %f11

P1955: !_PREFETCH [3] (Int)
prefetch [%i0 + 32], 1

P1956: !_CAS [6] (maybe <- 0x800089) (Int)
add %i1, 80, %o5
lduw [%o5], %l6
mov %l6, %l7
! move %l7(lower) -> %o2(lower)
or %l7, %o2, %o2
mov %l4, %o3
cas [%o5], %l7, %o3
! move %o3(lower) -> %o3(upper)
sllx %o3, 32, %o3
add   %l4, 1, %l4

P1957: !_ST [15] (maybe <- 0x40000127) (FP) (CBR)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i3 + 192 ]

! cbranch
andcc %l0, 1, %g0
be,pn  %xcc, TARGET1957
nop
RET1957:

! lfsr step begin
srlx %l0, 1, %l6
xnor %l6, %l0, %l6
sllx %l6, 63, %l6
or  %l6, %l0, %l0
srlx %l0, 1, %l0


P1958: !_LD [15] (FP)
ld [%i3 + 192], %f12
! 1 addresses covered

P1959: !_PREFETCH [4] (Int)
prefetch [%i0 + 64], 1

P1960: !_PREFETCH [4] (Int)
prefetch [%i0 + 64], 1

P1961: !_ST [11] (maybe <- 0x40000128) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i2 + 64 ]

P1962: !_PREFETCH [4] (Int)
prefetch [%i0 + 64], 1

P1963: !_REPLACEMENT [0] (Int)
sethi %hi(0x0), %l6
or %l6, %lo(0x0),  %l6
sethi %hi(0x10000), %l7
or %l7, %lo(0x10000),  %l7
add %i3, %l6, %l6
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]

P1964: !_DWLD [0] (FP)
ldd [%i0 + 0], %f18
! 2 addresses covered
fmovs %f18, %f13
fmovs %f19, %f14

P1965: !_DWLD [7] (FP)
ldd [%i1 + 80], %f18
! 2 addresses covered
fmovs %f18, %f15
!---- flushing fp results buffer to %f30 ----
fmovd %f0, %f30
fmovd %f2, %f30
fmovd %f4, %f30
fmovd %f6, %f30
fmovd %f8, %f30
fmovd %f10, %f30
fmovd %f12, %f30
fmovd %f14, %f30
fmovs %f19, %f0

P1966: !_DWST [4] (maybe <- 0x40000129) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
std %f20, [%i0 + 64]

P1967: !_DWST [6] (maybe <- 0x4000012a) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
! 1 th moved, current_fp_src=21 
fmovs  %f16, %f21
fadds  %f16, %f17, %f16
std %f20, [%i1 + 80]

P1968: !_SWAP [7] (maybe <- 0x80008a) (Int) (LE)
wr %g0, 0x88, %asi
mov %l4, %l3
! Change single-word-level endianess (big endian <-> little endian) 
sethi %hi(0xff00ff00), %l7
or %l7, %lo(0xff00ff00), %l7
and %l3, %l7, %o5
srl %o5, 8, %o5
sll %l3, 8, %l3
and %l3, %l7, %l3
or %l3, %o5, %l3
srl %l3, 16, %o5
sll %l3, 16, %l3
srl %l3, 0, %l3
or %l3, %o5, %l3
swapa  [%i1 + 84] %asi, %l3
! move %l3(lower) -> %o3(lower)
srl %l3, 0, %l7
or %l7, %o3, %o3
add   %l4, 1, %l4

P1969: !_SWAP [4] (maybe <- 0x80008b) (Int)
mov %l4, %o4
swap  [%i0 + 64], %o4
! move %o4(lower) -> %o4(upper)
sllx %o4, 32, %o4
add   %l4, 1, %l4

P1970: !_REPLACEMENT [10] (Int)
sethi %hi(0x20), %l3
or %l3, %lo(0x20),  %l3
sethi %hi(0x10000), %l6
or %l6, %lo(0x10000),  %l6
add %i3, %l3, %l3
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]

P1971: !_REPLACEMENT [8] (Int)
sethi %hi(0x100), %o5
or %o5, %lo(0x100),  %o5
sethi %hi(0x10000), %l3
or %l3, %lo(0x10000),  %l3
add %i3, %o5, %o5
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]

P1972: !_REPLACEMENT [6] (Int)
sethi %hi(0x50), %l7
or %l7, %lo(0x50),  %l7
sethi %hi(0x10000), %o5
or %o5, %lo(0x10000),  %o5
add %i3, %l7, %l7
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]

P1973: !_REPLACEMENT [15] (Int) (CBR)
sethi %hi(0xc0), %l6
or %l6, %lo(0xc0),  %l6
sethi %hi(0x10000), %l7
or %l7, %lo(0x10000),  %l7
add %i3, %l6, %l6
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]

! cbranch
andcc %l0, 1, %g0
be,pn  %xcc, TARGET1973
nop
RET1973:

! lfsr step begin
srlx %l0, 1, %l3
xnor %l3, %l0, %l3
sllx %l3, 63, %l3
or  %l3, %l0, %l0
srlx %l0, 1, %l0


P1974: !_ST [4] (maybe <- 0x4000012c) (FP) (CBR)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i0 + 64 ]

! cbranch
andcc %l0, 1, %g0
be,pt  %xcc, TARGET1974
nop
RET1974:

! lfsr step begin
srlx %l0, 1, %l3
xnor %l3, %l0, %l3
sllx %l3, 63, %l3
or  %l3, %l0, %l0
srlx %l0, 1, %l0


P1975: !_REPLACEMENT [2] (Int)
sethi %hi(0xc), %l6
or %l6, %lo(0xc),  %l6
sethi %hi(0x10000), %l7
or %l7, %lo(0x10000),  %l7
add %i3, %l6, %l6
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]

P1976: !_DWST [9] (maybe <- 0x4000012d) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
std %f20, [%i1 + 512]

P1977: !_SWAP [8] (maybe <- 0x80008c) (Int)
mov %l4, %l6
swap  [%i1 + 256], %l6
! move %l6(lower) -> %o4(lower)
srl %l6, 0, %o5
or %o5, %o4, %o4
!---- flushing int results buffer----
mov %o0, %l5
mov %o1, %l5
mov %o2, %l5
mov %o3, %l5
mov %o4, %l5
add   %l4, 1, %l4

P1978: !_LD [0] (FP)
ld [%i0 + 0], %f1
! 1 addresses covered

P1979: !_LD [5] (FP)
ld [%i1 + 76], %f2
! 1 addresses covered

P1980: !_REPLACEMENT [2] (Int)
sethi %hi(0xc), %l7
or %l7, %lo(0xc),  %l7
sethi %hi(0x10000), %o5
or %o5, %lo(0x10000),  %o5
add %i3, %l7, %l7
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]

P1981: !_ST [12] (maybe <- 0x4000012e) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i3 + 0 ]

P1982: !_PREFETCH [3] (Int)
prefetch [%i0 + 32], 1

P1983: !_LD [12] (FP)
ld [%i3 + 0], %f3
! 1 addresses covered

P1984: !_MEMBAR (Int)
membar #StoreLoad

P1985: !_DWLD [10] (FP)
ldd [%i2 + 32], %f4
! 1 addresses covered

P1986: !_REPLACEMENT [6] (Int)
sethi %hi(0x50), %l3
or %l3, %lo(0x50),  %l3
sethi %hi(0x10000), %l6
or %l6, %lo(0x10000),  %l6
add %i3, %l3, %l3
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]

P1987: !_DWST [5] (maybe <- 0x4000012f) (FP)
! 0 th moved, current_fp_src=21 
fmovs  %f16, %f21
fadds  %f16, %f17, %f16
std %f20, [%i1 + 72]

P1988: !_DWST [9] (maybe <- 0x40000130) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
std %f20, [%i1 + 512]

P1989: !_PREFETCH [4] (Int)
prefetch [%i0 + 64], 1

P1990: !_LD [12] (FP)
ld [%i3 + 0], %f5
! 1 addresses covered

P1991: !_PREFETCH [12] (Int)
prefetch [%i3 + 0], 1

P1992: !_LD [9] (FP)
ld [%i1 + 512], %f6
! 1 addresses covered

P1993: !_DWLD [7] (FP)
ldd [%i1 + 80], %f18
! 2 addresses covered
fmovs %f18, %f7
fmovs %f19, %f8

P1994: !_ST [15] (maybe <- 0x40000131) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i3 + 192 ]

P1995: !_REPLACEMENT [3] (Int)
sethi %hi(0x20), %l3
or %l3, %lo(0x20),  %l3
sethi %hi(0x10000), %l6
or %l6, %lo(0x10000),  %l6
add %i3, %l3, %l3
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]

P1996: !_REPLACEMENT [2] (Int) (CBR)
sethi %hi(0xc), %o5
or %o5, %lo(0xc),  %o5
sethi %hi(0x10000), %l3
or %l3, %lo(0x10000),  %l3
add %i3, %o5, %o5
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]

! cbranch
andcc %l0, 1, %g0
be,pn  %xcc, TARGET1996
nop
RET1996:

! lfsr step begin
srlx %l0, 1, %l7
xnor %l7, %l0, %l7
sllx %l7, 63, %l7
or  %l7, %l0, %l0
srlx %l0, 1, %l0


P1997: !_LD [0] (FP)
ld [%i0 + 0], %f9
! 1 addresses covered

P1998: !_LD [9] (FP) (CBR)
ld [%i1 + 512], %f10
! 1 addresses covered

! cbranch
andcc %l0, 1, %g0
be,pt  %xcc, TARGET1998
nop
RET1998:

! lfsr step begin
srlx %l0, 1, %o5
xnor %o5, %l0, %o5
sllx %o5, 63, %o5
or  %o5, %l0, %l0
srlx %l0, 1, %l0


P1999: !_DWLD [13] (FP)
ldd [%i3 + 64], %f18
! 1 addresses covered
fmovs %f18, %f11

P2000: !_PREFETCH [14] (Int)
prefetch [%i3 + 128], 1

P2001: !_PREFETCH [1] (Int)
prefetch [%i0 + 4], 1

P2002: !_REPLACEMENT [10] (Int)
sethi %hi(0x20), %l3
or %l3, %lo(0x20),  %l3
sethi %hi(0x10000), %l6
or %l6, %lo(0x10000),  %l6
add %i3, %l3, %l3
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]

P2003: !_LD [4] (FP)
ld [%i0 + 64], %f12
! 1 addresses covered

P2004: !_PREFETCH [12] (Int)
prefetch [%i3 + 0], 1

P2005: !_REPLACEMENT [15] (Int)
sethi %hi(0xc0), %o5
or %o5, %lo(0xc0),  %o5
sethi %hi(0x10000), %l3
or %l3, %lo(0x10000),  %l3
add %i3, %o5, %o5
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]

P2006: !_NOP (Int)
nop

P2007: !_DWLD [7] (FP)
ldd [%i1 + 80], %f18
! 2 addresses covered
fmovs %f18, %f13
fmovs %f19, %f14

P2008: !_DWST [12] (maybe <- 0x40000132) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
std %f20, [%i3 + 0]

P2009: !_DWST [7] (maybe <- 0x40000133) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
! 1 th moved, current_fp_src=21 
fmovs  %f16, %f21
fadds  %f16, %f17, %f16
std %f20, [%i1 + 80]

P2010: !_DWLD [3] (FP) (Branch target of P1504)
ldd [%i0 + 32], %f18
! 1 addresses covered
fmovs %f18, %f15
!---- flushing fp results buffer to %f30 ----
fmovd %f0, %f30
fmovd %f2, %f30
fmovd %f4, %f30
fmovd %f6, %f30
fmovd %f8, %f30
fmovd %f10, %f30
fmovd %f12, %f30
fmovd %f14, %f30
ba P2011
nop

TARGET1504:
ba RET1504
nop


P2011: !_LD [3] (FP)
ld [%i0 + 32], %f0
! 1 addresses covered

P2012: !_REPLACEMENT [3] (Int)
sethi %hi(0x20), %l3
or %l3, %lo(0x20),  %l3
sethi %hi(0x10000), %l6
or %l6, %lo(0x10000),  %l6
add %i3, %l3, %l3
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]

P2013: !_ST [7] (maybe <- 0x40000135) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i1 + 84 ]

P2014: !_DWLD [14] (FP)
ldd [%i3 + 128], %f18
! 1 addresses covered
fmovs %f18, %f1

P2015: !_LD [3] (FP)
ld [%i0 + 32], %f2
! 1 addresses covered

P2016: !_LD [7] (FP)
ld [%i1 + 84], %f3
! 1 addresses covered

P2017: !_CASX [6] (maybe <- 0x80008d) (Int)
add %i1, 80, %o5
ldx [%o5], %o0
! move %o0(upper) -> %o0(upper)
! move %o0(lower) -> %o0(lower)
mov %o0, %l7
sllx %l4, 32, %o1
add  %l4, 1, %l4
or   %l4, %o1, %o1
casx [%o5], %l7, %o1
! move %o1(upper) -> %o1(upper)
! move %o1(lower) -> %o1(lower)
add  %l4, 1, %l4

P2018: !_MEMBAR (Int)
membar #StoreLoad

P2019: !_LD [0] (FP)
ld [%i0 + 0], %f4
! 1 addresses covered

P2020: !_LD [1] (FP)
ld [%i0 + 4], %f5
! 1 addresses covered

P2021: !_LD [2] (FP)
ld [%i0 + 12], %f6
! 1 addresses covered

P2022: !_LD [3] (FP)
ld [%i0 + 32], %f7
! 1 addresses covered

P2023: !_LD [4] (FP)
ld [%i0 + 64], %f8
! 1 addresses covered

P2024: !_LD [5] (FP)
ld [%i1 + 76], %f9
! 1 addresses covered

P2025: !_LD [6] (FP)
ld [%i1 + 80], %f10
! 1 addresses covered

P2026: !_LD [7] (FP)
ld [%i1 + 84], %f11
! 1 addresses covered

P2027: !_LD [8] (FP)
ld [%i1 + 256], %f12
! 1 addresses covered

P2028: !_LD [9] (FP)
ld [%i1 + 512], %f13
! 1 addresses covered

P2029: !_LD [10] (FP)
ld [%i2 + 32], %f14
! 1 addresses covered

P2030: !_LD [11] (FP) (CBR)
ld [%i2 + 64], %f15
! 1 addresses covered
!---- flushing fp results buffer to %f30 ----
fmovd %f0, %f30
fmovd %f2, %f30
fmovd %f4, %f30
fmovd %f6, %f30
fmovd %f8, %f30
fmovd %f10, %f30
fmovd %f12, %f30
fmovd %f14, %f30

! cbranch
andcc %l0, 1, %g0
be,pn  %xcc, TARGET2030
nop
RET2030:

! lfsr step begin
srlx %l0, 1, %l7
xnor %l7, %l0, %l7
sllx %l7, 63, %l7
or  %l7, %l0, %l0
srlx %l0, 1, %l0


P2031: !_LD [12] (FP)
ld [%i3 + 0], %f0
! 1 addresses covered

P2032: !_LD [13] (FP)
ld [%i3 + 64], %f1
! 1 addresses covered

P2033: !_LD [14] (FP)
ld [%i3 + 128], %f2
! 1 addresses covered

P2034: !_LD [15] (FP)
ld [%i3 + 192], %f3
! 1 addresses covered

END_NODES1: ! Test istream for CPU 1 ends
sethi %hi(0xdead0e0f), %o5
or    %o5, %lo(0xdead0e0f), %o5
! move %o5(lower) -> %o2(upper)
sllx %o5, 32, %o2
stw %o5, [%i5] 
ld [%i5], %f4
!---- flushing int results buffer----
mov %o0, %l5
mov %o1, %l5
mov %o2, %l5
!---- flushing fp results buffer to %f30 ----
fmovd %f0, %f30
fmovd %f2, %f30
fmovd %f4, %f30

restore
retl
nop
!-----------------

! register usage:
! %i0 %i1 %i2 %i3 : base registers for 4 regions
! %i4 fixed pointer to per-cpu results area
! %l1 moving pointer to per-cpu FP results area
! %o7 moving pointer to per-cpu integer results area
! %i5 pointer to per-cpu private area
! %l0 holds lfsr, used as source of random bits 
! %l2 loop count register
! %f16 running counter for unique fp store values
! %f17 holds increment value for fp counter
! %l4 running counter for unique integer store values (increment value is always 1)
! %l5 move-to register for load values (simulation only)
! %f30 move-to register for FP values (simulation only)
! %l3 %l6 %l7 %o5 : 4 temporary registers
! %o0 %o1 %o2 %o3 %o4 : 5 integer results buffer registers
! %f0-f15 FP results buffer registers
! %f32-f47 FP block load/store registers

func2:
! 1000 (dynamic) instruction sequence begins
save   %sp, -192, %sp

! Force %i0-%i3 to be 64-byte aligned
add %i0, 63, %i0
andn %i0, 63, %i0

add %i1, 63, %i1
andn %i1, 63, %i1

add %i2, 63, %i2
andn %i2, 63, %i2

add %i3, 63, %i3
andn %i3, 63, %i3

add %i4, 63, %i4
andn %i4, 63, %i4

add %i5, 63, %i5
andn %i5, 63, %i5


! Initialize pointer to FP load results area
mov   %i4, %l1

! Initialize pointer to integer load results area
sethi %hi(0x80000), %o7
or    %o7, %lo(0x80000), %o7
add  %o7, %l1, %o7 

! Initialize %f0-%f62 to 0xdeadbee0deadbee1
sethi %hi(0xdeadbee0), %l7
or    %l7, %lo(0xdeadbee0), %l7
stw   %l7, [%i5]
sethi %hi(0xdeadbee1), %l7
or    %l7, %lo(0xdeadbee1), %l7
stw   %l7, [%i5+4]
ldd [%i5], %f0
fmovd %f0, %f2
fmovd %f0, %f4
fmovd %f0, %f6
fmovd %f0, %f8
fmovd %f0, %f10
fmovd %f0, %f12
fmovd %f0, %f14
fmovd %f0, %f16
fmovd %f0, %f18
fmovd %f0, %f20
fmovd %f0, %f22
fmovd %f0, %f24
fmovd %f0, %f26
fmovd %f0, %f28
fmovd %f0, %f30
fmovd %f0, %f32
fmovd %f0, %f34
fmovd %f0, %f36
fmovd %f0, %f38
fmovd %f0, %f40
fmovd %f0, %f42
fmovd %f0, %f44
fmovd %f0, %f46
fmovd %f0, %f48
fmovd %f0, %f50
fmovd %f0, %f52
fmovd %f0, %f54
fmovd %f0, %f56
fmovd %f0, %f58
fmovd %f0, %f60
fmovd %f0, %f62

! Signature for extract_loads script to start extracting load values for this stream
sethi %hi(0x02deade1), %l7
or    %l7, %lo(0x02deade1), %l7
stw %l7, [%i5] 
ld [%i5], %f16

! Initialize running integer counter in register %l4
sethi %hi(0x1000001), %l4
or    %l4, %lo(0x1000001), %l4

! Initialize running FP counter in register %f16
sethi %hi(0x40800001), %l7
or    %l7, %lo(0x40800001), %l7
stw %l7, [%i5] 
ld [%i5], %f16

! Initialize FP counter increment value in register %f17 (constant)
sethi %hi(0x35000000), %l7
or    %l7, %lo(0x35000000), %l7
stw %l7, [%i5] 
ld [%i5], %f17 

! Initialize LFSR to 0x294b^4
sethi %hi(0x294b), %l0
or    %l0, %lo(0x294b), %l0
mulx  %l0, %l0, %l0
mulx  %l0, %l0, %l0

!-- init shared addrs 4 to 5 ---
stx %g0, [%i0+64]
stx %g0, [%i1+72]

! use untouched cache-line (offset 4K) in replacement area for sync
sub %i1, %i0, %o5
add %i3, %o5, %o5
sub %o5, -4096, %o5

!-- begin of sync_init ---
or %g0, 1, %l3
or %g0, %l3, %l6
swap [%o5+4], %l6
membar #Sync
sync_init_1_2:
brnz,pt %l3, sync_init_1_2
lduw [%o5+4], %l3 ! delay slot
sync_init_2_2:
lduw [%o5], %l3
sub %l3, 1, %l6
cas [%o5], %l3, %l6
cmp %l3, %l6
bne,pt %xcc, sync_init_2_2
nop
membar #Sync
sync_init_3_2:
lduw [%o5], %l3 ! delay slot
brnz,pt %l3, sync_init_3_2
nop
!-- end of sync_init ---


BEGIN_NODES2: ! Test istream for CPU 2 begins

P2035: !_DWST [14] (maybe <- 0x40800001) (FP) (Loop entry)
sethi %hi(0x1), %l2
or %l2, %lo(0x1),  %l2
loop_entry_2_0:
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
std %f20, [%i3 + 128]

P2036: !_PREFETCH [13] (Int)
prefetch [%i3 + 64], 1

P2037: !_CASX [2] (maybe <- 0x1000001) (Int)
add %i0, 8, %l7
ldx [%l7], %o0
! move %o0(upper) -> %o0(upper)
! move %o0(lower) -> %o0(lower)
mov  %o0, %l6
mov %l4, %o1
casx [%l7], %l6, %o1
! move %o1(upper) -> %o1(upper)
! move %o1(lower) -> %o1(lower)
add  %l4, 1, %l4

P2038: !_DWST [10] (maybe <- 0x40800002) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
std %f20, [%i2 + 32]

P2039: !_DWST [15] (maybe <- 0x40800003) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
std %f20, [%i3 + 192]

P2040: !_PREFETCH [10] (Int) (CBR)
prefetch [%i2 + 32], 1

! cbranch
andcc %l0, 1, %g0
be,pt  %xcc, TARGET2040
nop
RET2040:

! lfsr step begin
srlx %l0, 1, %o5
xnor %o5, %l0, %o5
sllx %o5, 63, %o5
or  %o5, %l0, %l0
srlx %l0, 1, %l0


P2041: !_REPLACEMENT [12] (Int) (Branch target of P2066)
sethi %hi(0x0), %l3
or %l3, %lo(0x0),  %l3
sethi %hi(0x10000), %l6
or %l6, %lo(0x10000),  %l6
add %i3, %l3, %l3
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
ba P2042
nop

TARGET2066:
ba RET2066
nop


P2042: !_CAS [8] (maybe <- 0x1000002) (Int)
add %i1, 256, %l3
lduw [%l3], %o2
mov %o2, %o5
! move %o5(lower) -> %o2(upper)
sllx %o5, 32, %o2
mov %l4, %l7
cas [%l3], %o5, %l7
! move %l7(lower) -> %o2(lower)
srl %l7, 0, %l3
or %l3, %o2, %o2
add   %l4, 1, %l4

P2043: !_LD [11] (FP)
ld [%i2 + 64], %f0
! 1 addresses covered

P2044: !_LD [1] (FP)
ld [%i0 + 4], %f1
! 1 addresses covered

P2045: !_ST [7] (maybe <- 0x40800004) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i1 + 84 ]

P2046: !_CAS [4] (maybe <- 0x1000003) (Int)
add %i0, 64, %o5
lduw [%o5], %o3
mov %o3, %l7
! move %l7(lower) -> %o3(upper)
sllx %l7, 32, %o3
mov %l4, %l6
cas [%o5], %l7, %l6
! move %l6(lower) -> %o3(lower)
srl %l6, 0, %o5
or %o5, %o3, %o3
add   %l4, 1, %l4

P2047: !_REPLACEMENT [1] (Int)
sethi %hi(0x4), %l7
or %l7, %lo(0x4),  %l7
sethi %hi(0x10000), %o5
or %o5, %lo(0x10000),  %o5
add %i3, %l7, %l7
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]

P2048: !_DWLD [11] (FP) (Branch target of P2499)
ldd [%i2 + 64], %f2
! 1 addresses covered
ba P2049
nop

TARGET2499:
ba RET2499
nop


P2049: !_DWST [4] (maybe <- 0x40800005) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
std %f20, [%i0 + 64]

P2050: !_LD [6] (FP)
ld [%i1 + 80], %f3
! 1 addresses covered

P2051: !_REPLACEMENT [0] (Int)
sethi %hi(0x0), %l3
or %l3, %lo(0x0),  %l3
sethi %hi(0x10000), %l6
or %l6, %lo(0x10000),  %l6
add %i3, %l3, %l3
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]

P2052: !_PREFETCH [9] (Int)
prefetch [%i1 + 512], 1

P2053: !_DWST [0] (maybe <- 0x40800006) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
! 1 th moved, current_fp_src=21 
fmovs  %f16, %f21
fadds  %f16, %f17, %f16
std %f20, [%i0 + 0]

P2054: !_CAS [2] (maybe <- 0x1000004) (Int)
add %i0, 12, %o5
lduw [%o5], %o4
mov %o4, %l7
! move %l7(lower) -> %o4(upper)
sllx %l7, 32, %o4
mov %l4, %l6
cas [%o5], %l7, %l6
! move %l6(lower) -> %o4(lower)
srl %l6, 0, %o5
or %o5, %o4, %o4
!---- flushing int results buffer----
mov %o0, %l5
mov %o1, %l5
mov %o2, %l5
mov %o3, %l5
mov %o4, %l5
add   %l4, 1, %l4

P2055: !_LD [12] (FP)
ld [%i3 + 0], %f4
! 1 addresses covered

P2056: !_ST [7] (maybe <- 0x40800008) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i1 + 84 ]

P2057: !_DWLD [3] (FP)
ldd [%i0 + 32], %f18
! 1 addresses covered
fmovs %f18, %f5

P2058: !_LD [1] (FP)
ld [%i0 + 4], %f6
! 1 addresses covered

P2059: !_DWST [10] (maybe <- 0x40800009) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
std %f20, [%i2 + 32]

P2060: !_PREFETCH [11] (Int)
prefetch [%i2 + 64], 1

P2061: !_LD [11] (FP)
ld [%i2 + 64], %f7
! 1 addresses covered

P2062: !_DWLD [5] (FP)
ldd [%i1 + 72], %f8
! 1 addresses covered
fmovs %f9, %f8

P2063: !_DWLD [9] (FP)
ldd [%i1 + 512], %f18
! 1 addresses covered
fmovs %f18, %f9

P2064: !_PREFETCH [8] (Int)
prefetch [%i1 + 256], 1

P2065: !_PREFETCH [1] (Int)
prefetch [%i0 + 4], 1

P2066: !_PREFETCH [0] (Int) (CBR)
prefetch [%i0 + 0], 1

! cbranch
andcc %l0, 1, %g0
be,pt  %xcc, TARGET2066
nop
RET2066:

! lfsr step begin
srlx %l0, 1, %l3
xnor %l3, %l0, %l3
sllx %l3, 63, %l3
or  %l3, %l0, %l0
srlx %l0, 1, %l0


P2067: !_ST [8] (maybe <- 0x4080000a) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i1 + 256 ]

P2068: !_ST [14] (maybe <- 0x4080000b) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i3 + 128 ]

P2069: !_DWLD [0] (FP)
ldd [%i0 + 0], %f10
! 2 addresses covered

P2070: !_NOP (Int) (CBR)
nop

! cbranch
andcc %l0, 1, %g0
be,pt  %xcc, TARGET2070
nop
RET2070:

! lfsr step begin
srlx %l0, 1, %o5
xnor %o5, %l0, %o5
sllx %o5, 63, %o5
or  %o5, %l0, %l0
srlx %l0, 1, %l0


P2071: !_ST [10] (maybe <- 0x4080000c) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i2 + 32 ]

P2072: !_REPLACEMENT [15] (Int)
sethi %hi(0xc0), %o5
or %o5, %lo(0xc0),  %o5
sethi %hi(0x10000), %l3
or %l3, %lo(0x10000),  %l3
add %i3, %o5, %o5
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]

P2073: !_NOP (Int)
nop

P2074: !_ST [1] (maybe <- 0x4080000d) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i0 + 4 ]

P2075: !_DWLD [0] (FP)
ldd [%i0 + 0], %f12
! 2 addresses covered

P2076: !_ST [6] (maybe <- 0x4080000e) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i1 + 80 ]

P2077: !_LD [11] (FP)
ld [%i2 + 64], %f14
! 1 addresses covered

P2078: !_CAS [10] (maybe <- 0x1000005) (Int)
add %i2, 32, %l6
lduw [%l6], %o0
mov %o0, %l3
! move %l3(lower) -> %o0(upper)
sllx %l3, 32, %o0
mov %l4, %o5
cas [%l6], %l3, %o5
! move %o5(lower) -> %o0(lower)
srl %o5, 0, %l6
or %l6, %o0, %o0
add   %l4, 1, %l4

P2079: !_LD [5] (FP)
ld [%i1 + 76], %f15
! 1 addresses covered
!---- flushing fp results buffer to %f30 ----
fmovd %f0, %f30
fmovd %f2, %f30
fmovd %f4, %f30
fmovd %f6, %f30
fmovd %f8, %f30
fmovd %f10, %f30
fmovd %f12, %f30
fmovd %f14, %f30

P2080: !_PREFETCH [9] (Int)
prefetch [%i1 + 512], 1

P2081: !_PREFETCH [15] (Int)
prefetch [%i3 + 192], 1

P2082: !_NOP (Int)
nop

P2083: !_DWLD [15] (FP)
ldd [%i3 + 192], %f0
! 1 addresses covered

P2084: !_DWST [9] (maybe <- 0x4080000f) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
std %f20, [%i1 + 512]

P2085: !_ST [6] (maybe <- 0x40800010) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i1 + 80 ]

P2086: !_ST [8] (maybe <- 0x40800011) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i1 + 256 ]

P2087: !_DWST [8] (maybe <- 0x40800012) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
std %f20, [%i1 + 256]

P2088: !_DWST [2] (maybe <- 0x40800013) (FP)
! 0 th moved, current_fp_src=21 
fmovs  %f16, %f21
fadds  %f16, %f17, %f16
std %f20, [%i0 + 8]

P2089: !_DWLD [2] (FP)
ldd [%i0 + 8], %f18
! 1 addresses covered
fmovs %f19, %f1

P2090: !_DWLD [4] (FP)
ldd [%i0 + 64], %f2
! 1 addresses covered

P2091: !_LD [11] (FP)
ld [%i2 + 64], %f3
! 1 addresses covered

P2092: !_REPLACEMENT [5] (Int)
sethi %hi(0x4c), %o5
or %o5, %lo(0x4c),  %o5
sethi %hi(0x10000), %l3
or %l3, %lo(0x10000),  %l3
add %i3, %o5, %o5
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]

P2093: !_LD [8] (FP)
ld [%i1 + 256], %f4
! 1 addresses covered

P2094: !_SWAP [11] (maybe <- 0x1000006) (Int)
mov %l4, %o1
swap  [%i2 + 64], %o1
! move %o1(lower) -> %o1(upper)
sllx %o1, 32, %o1
add   %l4, 1, %l4

P2095: !_REPLACEMENT [3] (Int)
sethi %hi(0x20), %l6
or %l6, %lo(0x20),  %l6
sethi %hi(0x10000), %l7
or %l7, %lo(0x10000),  %l7
add %i3, %l6, %l6
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]

P2096: !_DWST [10] (maybe <- 0x40800014) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
std %f20, [%i2 + 32]

P2097: !_SWAP [14] (maybe <- 0x1000007) (Int)
mov %l4, %l6
swap  [%i3 + 128], %l6
! move %l6(lower) -> %o1(lower)
srl %l6, 0, %o5
or %o5, %o1, %o1
add   %l4, 1, %l4

P2098: !_DWST [15] (maybe <- 0x40800015) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
std %f20, [%i3 + 192]

P2099: !_PREFETCH [9] (Int) (Branch target of P2134)
prefetch [%i1 + 512], 1
ba P2100
nop

TARGET2134:
ba RET2134
nop


P2100: !_DWST [2] (maybe <- 0x40800016) (FP)
! 0 th moved, current_fp_src=21 
fmovs  %f16, %f21
fadds  %f16, %f17, %f16
std %f20, [%i0 + 8]

P2101: !_DWST [8] (maybe <- 0x40800017) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
std %f20, [%i1 + 256]

P2102: !_DWST [4] (maybe <- 0x40800018) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
std %f20, [%i0 + 64]

P2103: !_REPLACEMENT [9] (Int) (CBR)
sethi %hi(0x200), %l7
or %l7, %lo(0x200),  %l7
sethi %hi(0x10000), %o5
or %o5, %lo(0x10000),  %o5
add %i3, %l7, %l7
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]

! cbranch
andcc %l0, 1, %g0
be,pn  %xcc, TARGET2103
nop
RET2103:

! lfsr step begin
srlx %l0, 1, %l6
xnor %l6, %l0, %l6
sllx %l6, 63, %l6
or  %l6, %l0, %l0
srlx %l0, 1, %l0


P2104: !_ST [9] (maybe <- 0x40800019) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i1 + 512 ]

P2105: !_REPLACEMENT [6] (Int)
sethi %hi(0x50), %l6
or %l6, %lo(0x50),  %l6
sethi %hi(0x10000), %l7
or %l7, %lo(0x10000),  %l7
add %i3, %l6, %l6
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]

P2106: !_PREFETCH [1] (Int)
prefetch [%i0 + 4], 1

P2107: !_CASX [15] (maybe <- 0x1000008) (Int)
add %i3, 192, %l6
ldx [%l6], %o2
! move %o2(upper) -> %o2(upper)
! move %o2(lower) -> %o2(lower)
mov  %o2, %l3
sllx %l4, 32, %o3
casx [%l6], %l3, %o3
! move %o3(upper) -> %o3(upper)
! move %o3(lower) -> %o3(lower)
add  %l4, 1, %l4

P2108: !_PREFETCH [12] (Int)
prefetch [%i3 + 0], 1

P2109: !_MEMBAR (Int)
membar #StoreLoad

P2110: !_LD [12] (FP)
ld [%i3 + 0], %f5
! 1 addresses covered

P2111: !_DWLD [11] (FP)
ldd [%i2 + 64], %f6
! 1 addresses covered

P2112: !_DWST [0] (maybe <- 0x4080001a) (FP) (CBR) (Branch target of P2821)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
! 1 th moved, current_fp_src=21 
fmovs  %f16, %f21
fadds  %f16, %f17, %f16
std %f20, [%i0 + 0]

! cbranch
andcc %l0, 1, %g0
be,pn  %xcc, TARGET2112
nop
RET2112:

! lfsr step begin
srlx %l0, 1, %o5
xnor %o5, %l0, %o5
sllx %o5, 63, %o5
or  %o5, %l0, %l0
srlx %l0, 1, %l0

ba P2113
nop

TARGET2821:
ba RET2821
nop


P2113: !_ST [6] (maybe <- 0x4080001c) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i1 + 80 ]

P2114: !_DWLD [1] (FP)
ldd [%i0 + 0], %f18
! 2 addresses covered
fmovs %f18, %f7
fmovs %f19, %f8

P2115: !_DWLD [9] (FP)
ldd [%i1 + 512], %f18
! 1 addresses covered
fmovs %f18, %f9

P2116: !_DWST [15] (maybe <- 0x4080001d) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
std %f20, [%i3 + 192]

P2117: !_PREFETCH [10] (Int)
prefetch [%i2 + 32], 1

P2118: !_LD [15] (FP)
ld [%i3 + 192], %f10
! 1 addresses covered

P2119: !_REPLACEMENT [8] (Int)
sethi %hi(0x100), %l7
or %l7, %lo(0x100),  %l7
sethi %hi(0x10000), %o5
or %o5, %lo(0x10000),  %o5
add %i3, %l7, %l7
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]

P2120: !_LD [10] (FP)
ld [%i2 + 32], %f11
! 1 addresses covered

P2121: !_CASX [11] (maybe <- 0x1000009) (Int)
add %i2, 64, %l7
ldx [%l7], %o4
! move %o4(upper) -> %o4(upper)
! move %o4(lower) -> %o4(lower)
!---- flushing int results buffer----
mov %o0, %l5
mov %o1, %l5
mov %o2, %l5
mov %o3, %l5
mov %o4, %l5
mov  %o4, %l6
sllx %l4, 32, %o0
casx [%l7], %l6, %o0
! move %o0(upper) -> %o0(upper)
! move %o0(lower) -> %o0(lower)
add  %l4, 1, %l4

P2122: !_ST [3] (maybe <- 0x4080001e) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i0 + 32 ]

P2123: !_REPLACEMENT [14] (Int)
sethi %hi(0x80), %l3
or %l3, %lo(0x80),  %l3
sethi %hi(0x10000), %l6
or %l6, %lo(0x10000),  %l6
add %i3, %l3, %l3
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]

P2124: !_REPLACEMENT [2] (Int)
sethi %hi(0xc), %o5
or %o5, %lo(0xc),  %o5
sethi %hi(0x10000), %l3
or %l3, %lo(0x10000),  %l3
add %i3, %o5, %o5
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]

P2125: !_REPLACEMENT [1] (Int)
sethi %hi(0x4), %l7
or %l7, %lo(0x4),  %l7
sethi %hi(0x10000), %o5
or %o5, %lo(0x10000),  %o5
add %i3, %l7, %l7
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]

P2126: !_ST [13] (maybe <- 0x4080001f) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i3 + 64 ]

P2127: !_LD [6] (FP)
ld [%i1 + 80], %f12
! 1 addresses covered

P2128: !_ST [12] (maybe <- 0x40800020) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i3 + 0 ]

P2129: !_ST [8] (maybe <- 0x40800021) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i1 + 256 ]

P2130: !_DWLD [13] (FP)
ldd [%i3 + 64], %f18
! 1 addresses covered
fmovs %f18, %f13

P2131: !_ST [3] (maybe <- 0x40800022) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i0 + 32 ]

P2132: !_CAS [7] (maybe <- 0x100000a) (Int)
add %i1, 84, %l7
lduw [%l7], %o1
mov %o1, %l6
! move %l6(lower) -> %o1(upper)
sllx %l6, 32, %o1
mov %l4, %l3
cas [%l7], %l6, %l3
! move %l3(lower) -> %o1(lower)
srl %l3, 0, %l7
or %l7, %o1, %o1
add   %l4, 1, %l4

P2133: !_DWST [4] (maybe <- 0x40800023) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
std %f20, [%i0 + 64]

P2134: !_DWLD [11] (FP) (CBR)
ldd [%i2 + 64], %f14
! 1 addresses covered

! cbranch
andcc %l0, 1, %g0
be,pt  %xcc, TARGET2134
nop
RET2134:

! lfsr step begin
srlx %l0, 1, %l3
xnor %l3, %l0, %l3
sllx %l3, 63, %l3
or  %l3, %l0, %l0
srlx %l0, 1, %l0


P2135: !_SWAP [11] (maybe <- 0x100000b) (Int)
mov %l4, %o2
swap  [%i2 + 64], %o2
! move %o2(lower) -> %o2(upper)
sllx %o2, 32, %o2
add   %l4, 1, %l4

P2136: !_DWST [3] (maybe <- 0x40800024) (FP) (Branch target of P2112)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
std %f20, [%i0 + 32]
ba P2137
nop

TARGET2112:
ba RET2112
nop


P2137: !_DWST [0] (maybe <- 0x40800025) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
! 1 th moved, current_fp_src=21 
fmovs  %f16, %f21
fadds  %f16, %f17, %f16
std %f20, [%i0 + 0]

P2138: !_CASX [4] (maybe <- 0x100000c) (Int)
add %i0, 64, %o5
ldx [%o5], %l6
! move %l6(upper) -> %o2(lower)
srlx %l6, 32, %l7
or %l7, %o2, %o2
! move %l6(lower) -> %o3(upper)
sllx %l6, 32, %o3
mov  %l6, %l7
sllx %l4, 32, %l6
casx [%o5], %l7, %l6
! move %l6(upper) -> %o3(lower)
srlx %l6, 32, %o5
or %o5, %o3, %o3
! move %l6(lower) -> %o4(upper)
sllx %l6, 32, %o4
add  %l4, 1, %l4

P2139: !_DWST [5] (maybe <- 0x40800027) (FP) (CBR)
! 0 th moved, current_fp_src=21 
fmovs  %f16, %f21
fadds  %f16, %f17, %f16
std %f20, [%i1 + 72]

! cbranch
andcc %l0, 1, %g0
be,pn  %xcc, TARGET2139
nop
RET2139:

! lfsr step begin
srlx %l0, 1, %l6
xnor %l6, %l0, %l6
sllx %l6, 63, %l6
or  %l6, %l0, %l0
srlx %l0, 1, %l0


P2140: !_SWAP [2] (maybe <- 0x100000d) (Int)
mov %l4, %l3
swap  [%i0 + 12], %l3
! move %l3(lower) -> %o4(lower)
srl %l3, 0, %l7
or %l7, %o4, %o4
!---- flushing int results buffer----
mov %o0, %l5
mov %o1, %l5
mov %o2, %l5
mov %o3, %l5
mov %o4, %l5
add   %l4, 1, %l4

P2141: !_REPLACEMENT [5] (Int)
sethi %hi(0x4c), %l6
or %l6, %lo(0x4c),  %l6
sethi %hi(0x10000), %l7
or %l7, %lo(0x10000),  %l7
add %i3, %l6, %l6
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]

P2142: !_LD [14] (FP)
ld [%i3 + 128], %f15
! 1 addresses covered
!---- flushing fp results buffer to %f30 ----
fmovd %f0, %f30
fmovd %f2, %f30
fmovd %f4, %f30
fmovd %f6, %f30
fmovd %f8, %f30
fmovd %f10, %f30
fmovd %f12, %f30
fmovd %f14, %f30

P2143: !_CAS [13] (maybe <- 0x100000e) (Int) (CBR)
add %i3, 64, %l6
lduw [%l6], %o0
mov %o0, %l3
! move %l3(lower) -> %o0(upper)
sllx %l3, 32, %o0
mov %l4, %o5
cas [%l6], %l3, %o5
! move %o5(lower) -> %o0(lower)
srl %o5, 0, %l6
or %l6, %o0, %o0
add   %l4, 1, %l4

! cbranch
andcc %l0, 1, %g0
be,pn  %xcc, TARGET2143
nop
RET2143:

! lfsr step begin
srlx %l0, 1, %l3
xnor %l3, %l0, %l3
sllx %l3, 63, %l3
or  %l3, %l0, %l0
srlx %l0, 1, %l0


P2144: !_CASX [1] (maybe <- 0x100000f) (Int)
add %i0, 0, %l7
ldx [%l7], %o1
! move %o1(upper) -> %o1(upper)
! move %o1(lower) -> %o1(lower)
mov %o1, %l6
sllx %l4, 32, %o2
add  %l4, 1, %l4
or   %l4, %o2, %o2
casx [%l7], %l6, %o2
! move %o2(upper) -> %o2(upper)
! move %o2(lower) -> %o2(lower)
add  %l4, 1, %l4

P2145: !_REPLACEMENT [5] (Int)
sethi %hi(0x4c), %l6
or %l6, %lo(0x4c),  %l6
sethi %hi(0x10000), %l7
or %l7, %lo(0x10000),  %l7
add %i3, %l6, %l6
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]

P2146: !_MEMBAR (Int)
membar #StoreLoad

P2147: !_DWLD [5] (FP)
ldd [%i1 + 72], %f0
! 1 addresses covered
fmovs %f1, %f0

P2148: !_DWLD [7] (FP)
ldd [%i1 + 80], %f18
! 2 addresses covered
fmovs %f18, %f1
fmovs %f19, %f2

P2149: !_ST [13] (maybe <- 0x40800028) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i3 + 64 ]

P2150: !_DWLD [12] (FP)
ldd [%i3 + 0], %f18
! 1 addresses covered
fmovs %f18, %f3

P2151: !_PREFETCH [15] (Int)
prefetch [%i3 + 192], 1

P2152: !_REPLACEMENT [6] (Int)
sethi %hi(0x50), %o5
or %o5, %lo(0x50),  %o5
sethi %hi(0x10000), %l3
or %l3, %lo(0x10000),  %l3
add %i3, %o5, %o5
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]

P2153: !_LD [5] (FP)
ld [%i1 + 76], %f4
! 1 addresses covered

P2154: !_DWST [10] (maybe <- 0x40800029) (FP) (CBR)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
std %f20, [%i2 + 32]

! cbranch
andcc %l0, 1, %g0
be,pt  %xcc, TARGET2154
nop
RET2154:

! lfsr step begin
srlx %l0, 1, %l6
xnor %l6, %l0, %l6
sllx %l6, 63, %l6
or  %l6, %l0, %l0
srlx %l0, 1, %l0


P2155: !_REPLACEMENT [1] (Int)
sethi %hi(0x4), %l7
or %l7, %lo(0x4),  %l7
sethi %hi(0x10000), %o5
or %o5, %lo(0x10000),  %o5
add %i3, %l7, %l7
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]

P2156: !_LD [11] (FP)
ld [%i2 + 64], %f5
! 1 addresses covered

P2157: !_ST [4] (maybe <- 0x4080002a) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i0 + 64 ]

P2158: !_CAS [6] (maybe <- 0x1000011) (Int)
add %i1, 80, %l6
lduw [%l6], %o3
mov %o3, %l3
! move %l3(lower) -> %o3(upper)
sllx %l3, 32, %o3
mov %l4, %o5
cas [%l6], %l3, %o5
! move %o5(lower) -> %o3(lower)
srl %o5, 0, %l6
or %l6, %o3, %o3
add   %l4, 1, %l4

P2159: !_SWAP [10] (maybe <- 0x1000012) (Int)
mov %l4, %o4
swap  [%i2 + 32], %o4
! move %o4(lower) -> %o4(upper)
sllx %o4, 32, %o4
add   %l4, 1, %l4

P2160: !_DWLD [5] (FP)
ldd [%i1 + 72], %f6
! 1 addresses covered
fmovs %f7, %f6

P2161: !_REPLACEMENT [9] (Int)
sethi %hi(0x200), %o5
or %o5, %lo(0x200),  %o5
sethi %hi(0x10000), %l3
or %l3, %lo(0x10000),  %l3
add %i3, %o5, %o5
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]

P2162: !_PREFETCH [2] (Int)
prefetch [%i0 + 12], 1

P2163: !_SWAP [10] (maybe <- 0x1000013) (Int)
mov %l4, %l3
swap  [%i2 + 32], %l3
! move %l3(lower) -> %o4(lower)
srl %l3, 0, %l7
or %l7, %o4, %o4
!---- flushing int results buffer----
mov %o0, %l5
mov %o1, %l5
mov %o2, %l5
mov %o3, %l5
mov %o4, %l5
add   %l4, 1, %l4

P2164: !_DWST [11] (maybe <- 0x4080002b) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
std %f20, [%i2 + 64]

P2165: !_PREFETCH [5] (Int)
prefetch [%i1 + 76], 1

P2166: !_LD [12] (FP)
ld [%i3 + 0], %f7
! 1 addresses covered

P2167: !_REPLACEMENT [5] (Int)
sethi %hi(0x4c), %l3
or %l3, %lo(0x4c),  %l3
sethi %hi(0x10000), %l6
or %l6, %lo(0x10000),  %l6
add %i3, %l3, %l3
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]

P2168: !_NOP (Int)
nop

P2169: !_PREFETCH [9] (Int)
prefetch [%i1 + 512], 1

P2170: !_DWLD [10] (FP)
ldd [%i2 + 32], %f8
! 1 addresses covered

P2171: !_ST [5] (maybe <- 0x4080002c) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i1 + 76 ]

P2172: !_DWST [6] (maybe <- 0x4080002d) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
! 1 th moved, current_fp_src=21 
fmovs  %f16, %f21
fadds  %f16, %f17, %f16
std %f20, [%i1 + 80]

P2173: !_PREFETCH [15] (Int)
prefetch [%i3 + 192], 1

P2174: !_CAS [1] (maybe <- 0x1000014) (Int)
add %i0, 4, %l7
lduw [%l7], %o0
mov %o0, %l6
! move %l6(lower) -> %o0(upper)
sllx %l6, 32, %o0
mov %l4, %l3
cas [%l7], %l6, %l3
! move %l3(lower) -> %o0(lower)
srl %l3, 0, %l7
or %l7, %o0, %o0
add   %l4, 1, %l4

P2175: !_ST [7] (maybe <- 0x4080002f) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i1 + 84 ]

P2176: !_DWLD [5] (FP)
ldd [%i1 + 72], %f18
! 1 addresses covered
fmovs %f19, %f9

P2177: !_LD [6] (FP)
ld [%i1 + 80], %f10
! 1 addresses covered

P2178: !_PREFETCH [10] (Int)
prefetch [%i2 + 32], 1

P2179: !_CAS [6] (maybe <- 0x1000015) (Int)
add %i1, 80, %l6
lduw [%l6], %o1
mov %o1, %l3
! move %l3(lower) -> %o1(upper)
sllx %l3, 32, %o1
mov %l4, %o5
cas [%l6], %l3, %o5
! move %o5(lower) -> %o1(lower)
srl %o5, 0, %l6
or %l6, %o1, %o1
add   %l4, 1, %l4

P2180: !_DWLD [4] (FP)
ldd [%i0 + 64], %f18
! 1 addresses covered
fmovs %f18, %f11

P2181: !_REPLACEMENT [5] (Int)
sethi %hi(0x4c), %l3
or %l3, %lo(0x4c),  %l3
sethi %hi(0x10000), %l6
or %l6, %lo(0x10000),  %l6
add %i3, %l3, %l3
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]

P2182: !_PREFETCH [15] (Int)
prefetch [%i3 + 192], 1

P2183: !_DWLD [2] (FP) (CBR)
ldd [%i0 + 8], %f12
! 1 addresses covered
fmovs %f13, %f12

! cbranch
andcc %l0, 1, %g0
be,pt  %xcc, TARGET2183
nop
RET2183:

! lfsr step begin
srlx %l0, 1, %o5
xnor %o5, %l0, %o5
sllx %o5, 63, %o5
or  %o5, %l0, %l0
srlx %l0, 1, %l0


P2184: !_CASX [7] (maybe <- 0x1000016) (Int)
add %i1, 80, %l6
ldx [%l6], %o2
! move %o2(upper) -> %o2(upper)
! move %o2(lower) -> %o2(lower)
mov %o2, %l3
sllx %l4, 32, %o3
add  %l4, 1, %l4
or   %l4, %o3, %o3
casx [%l6], %l3, %o3
! move %o3(upper) -> %o3(upper)
! move %o3(lower) -> %o3(lower)
add  %l4, 1, %l4

P2185: !_PREFETCH [11] (Int)
prefetch [%i2 + 64], 1

P2186: !_CAS [2] (maybe <- 0x1000018) (Int)
add %i0, 12, %l6
lduw [%l6], %o4
mov %o4, %l3
! move %l3(lower) -> %o4(upper)
sllx %l3, 32, %o4
mov %l4, %o5
cas [%l6], %l3, %o5
! move %o5(lower) -> %o4(lower)
srl %o5, 0, %l6
or %l6, %o4, %o4
!---- flushing int results buffer----
mov %o0, %l5
mov %o1, %l5
mov %o2, %l5
mov %o3, %l5
mov %o4, %l5
add   %l4, 1, %l4

P2187: !_CASX [7] (maybe <- 0x1000019) (Int)
add %i1, 80, %l6
ldx [%l6], %o0
! move %o0(upper) -> %o0(upper)
! move %o0(lower) -> %o0(lower)
mov %o0, %l3
sllx %l4, 32, %o1
add  %l4, 1, %l4
or   %l4, %o1, %o1
casx [%l6], %l3, %o1
! move %o1(upper) -> %o1(upper)
! move %o1(lower) -> %o1(lower)
add  %l4, 1, %l4

P2188: !_PREFETCH [3] (Int)
prefetch [%i0 + 32], 1

P2189: !_PREFETCH [2] (Int)
prefetch [%i0 + 12], 1

P2190: !_ST [6] (maybe <- 0x40800030) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i1 + 80 ]

P2191: !_ST [5] (maybe <- 0x40800031) (FP) (CBR)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i1 + 76 ]

! cbranch
andcc %l0, 1, %g0
be,pn  %xcc, TARGET2191
nop
RET2191:

! lfsr step begin
srlx %l0, 1, %l7
xnor %l7, %l0, %l7
sllx %l7, 63, %l7
or  %l7, %l0, %l0
srlx %l0, 1, %l0


P2192: !_LD [11] (FP)
ld [%i2 + 64], %f13
! 1 addresses covered

P2193: !_LD [5] (FP)
ld [%i1 + 76], %f14
! 1 addresses covered

P2194: !_REPLACEMENT [2] (Int)
sethi %hi(0xc), %o5
or %o5, %lo(0xc),  %o5
sethi %hi(0x10000), %l3
or %l3, %lo(0x10000),  %l3
add %i3, %o5, %o5
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]

P2195: !_DWLD [15] (FP)
ldd [%i3 + 192], %f18
! 1 addresses covered
fmovs %f18, %f15
!---- flushing fp results buffer to %f30 ----
fmovd %f0, %f30
fmovd %f2, %f30
fmovd %f4, %f30
fmovd %f6, %f30
fmovd %f8, %f30
fmovd %f10, %f30
fmovd %f12, %f30
fmovd %f14, %f30

P2196: !_DWLD [6] (FP)
ldd [%i1 + 80], %f0
! 2 addresses covered

P2197: !_DWST [1] (maybe <- 0x40800032) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
! 1 th moved, current_fp_src=21 
fmovs  %f16, %f21
fadds  %f16, %f17, %f16
std %f20, [%i0 + 0]

P2198: !_LD [5] (FP) (Branch target of P2467)
ld [%i1 + 76], %f2
! 1 addresses covered
ba P2199
nop

TARGET2467:
ba RET2467
nop


P2199: !_ST [12] (maybe <- 0x40800034) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i3 + 0 ]

P2200: !_CASX [6] (maybe <- 0x100001b) (Int)
add %i1, 80, %l6
ldx [%l6], %o2
! move %o2(upper) -> %o2(upper)
! move %o2(lower) -> %o2(lower)
mov %o2, %l3
sllx %l4, 32, %o3
add  %l4, 1, %l4
or   %l4, %o3, %o3
casx [%l6], %l3, %o3
! move %o3(upper) -> %o3(upper)
! move %o3(lower) -> %o3(lower)
add  %l4, 1, %l4

P2201: !_REPLACEMENT [14] (Int)
sethi %hi(0x80), %l3
or %l3, %lo(0x80),  %l3
sethi %hi(0x10000), %l6
or %l6, %lo(0x10000),  %l6
add %i3, %l3, %l3
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]

P2202: !_REPLACEMENT [8] (Int)
sethi %hi(0x100), %o5
or %o5, %lo(0x100),  %o5
sethi %hi(0x10000), %l3
or %l3, %lo(0x10000),  %l3
add %i3, %o5, %o5
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]

P2203: !_PREFETCH [6] (Int)
prefetch [%i1 + 80], 1

P2204: !_DWST [9] (maybe <- 0x40800035) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
std %f20, [%i1 + 512]

P2205: !_DWST [7] (maybe <- 0x40800036) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
! 1 th moved, current_fp_src=21 
fmovs  %f16, %f21
fadds  %f16, %f17, %f16
std %f20, [%i1 + 80]

P2206: !_DWST [5] (maybe <- 0x40800038) (FP)
! 0 th moved, current_fp_src=21 
fmovs  %f16, %f21
fadds  %f16, %f17, %f16
std %f20, [%i1 + 72]

P2207: !_REPLACEMENT [10] (Int)
sethi %hi(0x20), %o5
or %o5, %lo(0x20),  %o5
sethi %hi(0x10000), %l3
or %l3, %lo(0x10000),  %l3
add %i3, %o5, %o5
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]

P2208: !_DWST [6] (maybe <- 0x40800039) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
! 1 th moved, current_fp_src=21 
fmovs  %f16, %f21
fadds  %f16, %f17, %f16
std %f20, [%i1 + 80]

P2209: !_PREFETCH [12] (Int)
prefetch [%i3 + 0], 1

P2210: !_PREFETCH [8] (Int)
prefetch [%i1 + 256], 1

P2211: !_PREFETCH [6] (Int) (LE) (CBR)
wr %g0, 0x88, %asi
prefetcha [%i1 + 80] %asi, 1

! cbranch
andcc %l0, 1, %g0
be,pt  %xcc, TARGET2211
nop
RET2211:

! lfsr step begin
srlx %l0, 1, %l6
xnor %l6, %l0, %l6
sllx %l6, 63, %l6
or  %l6, %l0, %l0
srlx %l0, 1, %l0


P2212: !_LD [15] (FP)
ld [%i3 + 192], %f3
! 1 addresses covered

P2213: !_REPLACEMENT [2] (Int)
sethi %hi(0xc), %l7
or %l7, %lo(0xc),  %l7
sethi %hi(0x10000), %o5
or %o5, %lo(0x10000),  %o5
add %i3, %l7, %l7
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]

P2214: !_DWLD [2] (FP)
ldd [%i0 + 8], %f4
! 1 addresses covered
fmovs %f5, %f4

P2215: !_REPLACEMENT [6] (Int)
sethi %hi(0x50), %l6
or %l6, %lo(0x50),  %l6
sethi %hi(0x10000), %l7
or %l7, %lo(0x10000),  %l7
add %i3, %l6, %l6
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]

P2216: !_REPLACEMENT [2] (Int)
sethi %hi(0xc), %l3
or %l3, %lo(0xc),  %l3
sethi %hi(0x10000), %l6
or %l6, %lo(0x10000),  %l6
add %i3, %l3, %l3
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]

P2217: !_DWLD [7] (FP)
ldd [%i1 + 80], %f18
! 2 addresses covered
fmovs %f18, %f5
fmovs %f19, %f6

P2218: !_ST [13] (maybe <- 0x4080003b) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i3 + 64 ]

P2219: !_REPLACEMENT [4] (Int)
sethi %hi(0x40), %l7
or %l7, %lo(0x40),  %l7
sethi %hi(0x10000), %o5
or %o5, %lo(0x10000),  %o5
add %i3, %l7, %l7
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]

P2220: !_CAS [5] (maybe <- 0x100001d) (Int) (Branch target of P2895)
add %i1, 76, %l7
lduw [%l7], %o4
mov %o4, %l6
! move %l6(lower) -> %o4(upper)
sllx %l6, 32, %o4
mov %l4, %l3
cas [%l7], %l6, %l3
! move %l3(lower) -> %o4(lower)
srl %l3, 0, %l7
or %l7, %o4, %o4
!---- flushing int results buffer----
mov %o0, %l5
mov %o1, %l5
mov %o2, %l5
mov %o3, %l5
mov %o4, %l5
add   %l4, 1, %l4
ba P2221
nop

TARGET2895:
ba RET2895
nop


P2221: !_DWST [2] (maybe <- 0x4080003c) (FP)
! 0 th moved, current_fp_src=21 
fmovs  %f16, %f21
fadds  %f16, %f17, %f16
std %f20, [%i0 + 8]

P2222: !_ST [10] (maybe <- 0x4080003d) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i2 + 32 ]

P2223: !_LD [7] (FP)
ld [%i1 + 84], %f7
! 1 addresses covered

P2224: !_ST [2] (maybe <- 0x4080003e) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i0 + 12 ]

P2225: !_LD [11] (FP)
ld [%i2 + 64], %f8
! 1 addresses covered

P2226: !_REPLACEMENT [11] (Int)
sethi %hi(0x40), %l7
or %l7, %lo(0x40),  %l7
sethi %hi(0x10000), %o5
or %o5, %lo(0x10000),  %o5
add %i3, %l7, %l7
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]

P2227: !_ST [9] (maybe <- 0x4080003f) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i1 + 512 ]

P2228: !_PREFETCH [0] (Int) (Branch target of P2561)
prefetch [%i0 + 0], 1
ba P2229
nop

TARGET2561:
ba RET2561
nop


P2229: !_LD [9] (FP)
ld [%i1 + 512], %f9
! 1 addresses covered

P2230: !_REPLACEMENT [12] (Int)
sethi %hi(0x0), %l3
or %l3, %lo(0x0),  %l3
sethi %hi(0x10000), %l6
or %l6, %lo(0x10000),  %l6
add %i3, %l3, %l3
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]

P2231: !_LD [6] (FP)
ld [%i1 + 80], %f10
! 1 addresses covered

P2232: !_LD [3] (FP)
ld [%i0 + 32], %f11
! 1 addresses covered

P2233: !_ST [15] (maybe <- 0x40800040) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i3 + 192 ]

P2234: !_PREFETCH [10] (Int) (Branch target of P2651)
prefetch [%i2 + 32], 1
ba P2235
nop

TARGET2651:
ba RET2651
nop


P2235: !_LD [10] (FP)
ld [%i2 + 32], %f12
! 1 addresses covered

P2236: !_MEMBAR (Int)
membar #StoreLoad

P2237: !_REPLACEMENT [8] (Int)
sethi %hi(0x100), %l7
or %l7, %lo(0x100),  %l7
sethi %hi(0x10000), %o5
or %o5, %lo(0x10000),  %o5
add %i3, %l7, %l7
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]

P2238: !_DWLD [11] (FP)
ldd [%i2 + 64], %f18
! 1 addresses covered
fmovs %f18, %f13

P2239: !_PREFETCH [15] (Int) (CBR) (Branch target of P2251)
prefetch [%i3 + 192], 1

! cbranch
andcc %l0, 1, %g0
be,pn  %xcc, TARGET2239
nop
RET2239:

! lfsr step begin
srlx %l0, 1, %l6
xnor %l6, %l0, %l6
sllx %l6, 63, %l6
or  %l6, %l0, %l0
srlx %l0, 1, %l0

ba P2240
nop

TARGET2251:
ba RET2251
nop


P2240: !_DWST [3] (maybe <- 0x40800041) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
std %f20, [%i0 + 32]

P2241: !_PREFETCH [8] (Int)
prefetch [%i1 + 256], 1

P2242: !_LD [0] (FP) (Branch target of P2183)
ld [%i0 + 0], %f14
! 1 addresses covered
ba P2243
nop

TARGET2183:
ba RET2183
nop


P2243: !_SWAP [9] (maybe <- 0x100001e) (Int) (LE)
wr %g0, 0x88, %asi
mov %l4, %o0
! Change single-word-level endianess (big endian <-> little endian) 
sethi %hi(0xff00ff00), %l6
or %l6, %lo(0xff00ff00), %l6
and %o0, %l6, %l7
srl %l7, 8, %l7
sll %o0, 8, %o0
and %o0, %l6, %o0
or %o0, %l7, %o0
srl %o0, 16, %l7
sll %o0, 16, %o0
srl %o0, 0, %o0
or %o0, %l7, %o0
swapa  [%i1 + 512] %asi, %o0
! move %o0(lower) -> %o0(upper)
sllx %o0, 32, %o0
add   %l4, 1, %l4

P2244: !_CASX [5] (maybe <- 0x100001f) (Int)
add %i1, 72, %l6
ldx [%l6], %o5
! move %o5(upper) -> %o0(lower)
srlx %o5, 32, %l3
or %l3, %o0, %o0
! move %o5(lower) -> %o1(upper)
sllx %o5, 32, %o1
mov  %o5, %l3
mov %l4, %o5
casx [%l6], %l3, %o5
! move %o5(upper) -> %o1(lower)
srlx %o5, 32, %l6
or %l6, %o1, %o1
! move %o5(lower) -> %o2(upper)
sllx %o5, 32, %o2
add  %l4, 1, %l4

P2245: !_ST [2] (maybe <- 0x40800042) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i0 + 12 ]

P2246: !_CAS [2] (maybe <- 0x1000020) (Int)
add %i0, 12, %l3
lduw [%l3], %l7
mov %l7, %o5
! move %o5(lower) -> %o2(lower)
or %o5, %o2, %o2
mov %l4, %o3
cas [%l3], %o5, %o3
! move %o3(lower) -> %o3(upper)
sllx %o3, 32, %o3
add   %l4, 1, %l4

P2247: !_REPLACEMENT [4] (Int)
sethi %hi(0x40), %o5
or %o5, %lo(0x40),  %o5
sethi %hi(0x10000), %l3
or %l3, %lo(0x10000),  %l3
add %i3, %o5, %o5
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]

P2248: !_MEMBAR (Int)
membar #StoreLoad

P2249: !_MEMBAR (Int)
membar #StoreLoad

P2250: !_LD [0] (FP)
ld [%i0 + 0], %f15
! 1 addresses covered
!---- flushing fp results buffer to %f30 ----
fmovd %f0, %f30
fmovd %f2, %f30
fmovd %f4, %f30
fmovd %f6, %f30
fmovd %f8, %f30
fmovd %f10, %f30
fmovd %f12, %f30
fmovd %f14, %f30

P2251: !_MEMBAR (Int) (CBR)
membar #StoreLoad

! cbranch
andcc %l0, 1, %g0
be,pt  %xcc, TARGET2251
nop
RET2251:

! lfsr step begin
srlx %l0, 1, %l7
xnor %l7, %l0, %l7
sllx %l7, 63, %l7
or  %l7, %l0, %l0
srlx %l0, 1, %l0


P2252: !_DWST [4] (maybe <- 0x40800043) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
std %f20, [%i0 + 64]

P2253: !_DWST [6] (maybe <- 0x40800044) (FP) (Branch target of P2553)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
! 1 th moved, current_fp_src=21 
fmovs  %f16, %f21
fadds  %f16, %f17, %f16
std %f20, [%i1 + 80]
ba P2254
nop

TARGET2553:
ba RET2553
nop


P2254: !_DWLD [7] (FP)
ldd [%i1 + 80], %f0
! 2 addresses covered

P2255: !_PREFETCH [6] (Int)
prefetch [%i1 + 80], 1

P2256: !_LD [9] (FP)
ld [%i1 + 512], %f2
! 1 addresses covered

P2257: !_DWLD [5] (FP)
ldd [%i1 + 72], %f18
! 1 addresses covered
fmovs %f19, %f3

P2258: !_REPLACEMENT [10] (Int)
sethi %hi(0x20), %l6
or %l6, %lo(0x20),  %l6
sethi %hi(0x10000), %l7
or %l7, %lo(0x10000),  %l7
add %i3, %l6, %l6
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]

P2259: !_ST [1] (maybe <- 0x40800046) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i0 + 4 ]

P2260: !_ST [8] (maybe <- 0x40800047) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i1 + 256 ]

P2261: !_PREFETCH [0] (Int)
prefetch [%i0 + 0], 1

P2262: !_DWLD [8] (FP)
ldd [%i1 + 256], %f4
! 1 addresses covered

P2263: !_CAS [10] (maybe <- 0x1000021) (Int)
add %i2, 32, %o5
lduw [%o5], %l6
mov %l6, %l7
! move %l7(lower) -> %o3(lower)
or %l7, %o3, %o3
mov %l4, %o4
cas [%o5], %l7, %o4
! move %o4(lower) -> %o4(upper)
sllx %o4, 32, %o4
add   %l4, 1, %l4

P2264: !_REPLACEMENT [6] (Int)
sethi %hi(0x50), %l7
or %l7, %lo(0x50),  %l7
sethi %hi(0x10000), %o5
or %o5, %lo(0x10000),  %o5
add %i3, %l7, %l7
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]

P2265: !_ST [4] (maybe <- 0x40800048) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i0 + 64 ]

P2266: !_ST [11] (maybe <- 0x40800049) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i2 + 64 ]

P2267: !_REPLACEMENT [1] (Int)
sethi %hi(0x4), %o5
or %o5, %lo(0x4),  %o5
sethi %hi(0x10000), %l3
or %l3, %lo(0x10000),  %l3
add %i3, %o5, %o5
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]

P2268: !_MEMBAR (Int)
membar #StoreLoad

P2269: !_PREFETCH [12] (Int) (CBR)
prefetch [%i3 + 0], 1

! cbranch
andcc %l0, 1, %g0
be,pn  %xcc, TARGET2269
nop
RET2269:

! lfsr step begin
srlx %l0, 1, %l7
xnor %l7, %l0, %l7
sllx %l7, 63, %l7
or  %l7, %l0, %l0
srlx %l0, 1, %l0


P2270: !_REPLACEMENT [4] (Int)
sethi %hi(0x40), %o5
or %o5, %lo(0x40),  %o5
sethi %hi(0x10000), %l3
or %l3, %lo(0x10000),  %l3
add %i3, %o5, %o5
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]

P2271: !_DWST [4] (maybe <- 0x4080004a) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
std %f20, [%i0 + 64]

P2272: !_LD [10] (FP)
ld [%i2 + 32], %f5
! 1 addresses covered

P2273: !_SWAP [6] (maybe <- 0x1000022) (Int) (Branch target of P2457)
mov %l4, %o5
swap  [%i1 + 80], %o5
! move %o5(lower) -> %o4(lower)
srl %o5, 0, %l6
or %l6, %o4, %o4
!---- flushing int results buffer----
mov %o0, %l5
mov %o1, %l5
mov %o2, %l5
mov %o3, %l5
mov %o4, %l5
add   %l4, 1, %l4
ba P2274
nop

TARGET2457:
ba RET2457
nop


P2274: !_PREFETCH [0] (Int) (Branch target of P2239)
prefetch [%i0 + 0], 1
ba P2275
nop

TARGET2239:
ba RET2239
nop


P2275: !_CAS [12] (maybe <- 0x1000023) (Int)
add %i3, 0, %l6
lduw [%l6], %o0
mov %o0, %l3
! move %l3(lower) -> %o0(upper)
sllx %l3, 32, %o0
mov %l4, %o5
cas [%l6], %l3, %o5
! move %o5(lower) -> %o0(lower)
srl %o5, 0, %l6
or %l6, %o0, %o0
add   %l4, 1, %l4

P2276: !_REPLACEMENT [3] (Int) (CBR)
sethi %hi(0x20), %l3
or %l3, %lo(0x20),  %l3
sethi %hi(0x10000), %l6
or %l6, %lo(0x10000),  %l6
add %i3, %l3, %l3
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]

! cbranch
andcc %l0, 1, %g0
be,pn  %xcc, TARGET2276
nop
RET2276:

! lfsr step begin
srlx %l0, 1, %o5
xnor %o5, %l0, %o5
sllx %o5, 63, %o5
or  %o5, %l0, %l0
srlx %l0, 1, %l0


P2277: !_DWLD [11] (FP)
ldd [%i2 + 64], %f6
! 1 addresses covered

P2278: !_LD [7] (FP)
ld [%i1 + 84], %f7
! 1 addresses covered

P2279: !_REPLACEMENT [10] (Int)
sethi %hi(0x20), %l3
or %l3, %lo(0x20),  %l3
sethi %hi(0x10000), %l6
or %l6, %lo(0x10000),  %l6
add %i3, %l3, %l3
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]

P2280: !_REPLACEMENT [8] (Int)
sethi %hi(0x100), %o5
or %o5, %lo(0x100),  %o5
sethi %hi(0x10000), %l3
or %l3, %lo(0x10000),  %l3
add %i3, %o5, %o5
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]

P2281: !_DWLD [3] (FP)
ldd [%i0 + 32], %f8
! 1 addresses covered

P2282: !_PREFETCH [11] (Int) (CBR)
prefetch [%i2 + 64], 1

! cbranch
andcc %l0, 1, %g0
be,pt  %xcc, TARGET2282
nop
RET2282:

! lfsr step begin
srlx %l0, 1, %l7
xnor %l7, %l0, %l7
sllx %l7, 63, %l7
or  %l7, %l0, %l0
srlx %l0, 1, %l0


P2283: !_DWST [9] (maybe <- 0x4080004b) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
std %f20, [%i1 + 512]

P2284: !_ST [3] (maybe <- 0x4080004c) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i0 + 32 ]

P2285: !_REPLACEMENT [1] (Int)
sethi %hi(0x4), %l6
or %l6, %lo(0x4),  %l6
sethi %hi(0x10000), %l7
or %l7, %lo(0x10000),  %l7
add %i3, %l6, %l6
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]

P2286: !_REPLACEMENT [13] (Int)
sethi %hi(0x40), %l3
or %l3, %lo(0x40),  %l3
sethi %hi(0x10000), %l6
or %l6, %lo(0x10000),  %l6
add %i3, %l3, %l3
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]

P2287: !_LD [6] (FP)
ld [%i1 + 80], %f9
! 1 addresses covered

P2288: !_PREFETCH [4] (Int)
prefetch [%i0 + 64], 1

P2289: !_LD [2] (FP)
ld [%i0 + 12], %f10
! 1 addresses covered

P2290: !_REPLACEMENT [0] (Int)
sethi %hi(0x0), %o5
or %o5, %lo(0x0),  %o5
sethi %hi(0x10000), %l3
or %l3, %lo(0x10000),  %l3
add %i3, %o5, %o5
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]

P2291: !_CASX [9] (maybe <- 0x1000024) (Int)
add %i1, 512, %o5
ldx [%o5], %o1
! move %o1(upper) -> %o1(upper)
! move %o1(lower) -> %o1(lower)
mov  %o1, %l7
sllx %l4, 32, %o2
casx [%o5], %l7, %o2
! move %o2(upper) -> %o2(upper)
! move %o2(lower) -> %o2(lower)
add  %l4, 1, %l4

P2292: !_REPLACEMENT [1] (Int)
sethi %hi(0x4), %l7
or %l7, %lo(0x4),  %l7
sethi %hi(0x10000), %o5
or %o5, %lo(0x10000),  %o5
add %i3, %l7, %l7
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]

P2293: !_DWST [14] (maybe <- 0x4080004d) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
std %f20, [%i3 + 128]

P2294: !_REPLACEMENT [9] (Int)
sethi %hi(0x200), %l3
or %l3, %lo(0x200),  %l3
sethi %hi(0x10000), %l6
or %l6, %lo(0x10000),  %l6
add %i3, %l3, %l3
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]

P2295: !_MEMBAR (Int)
membar #StoreLoad

P2296: !_LD [12] (FP)
ld [%i3 + 0], %f11
! 1 addresses covered

P2297: !_LD [2] (FP)
ld [%i0 + 12], %f12
! 1 addresses covered

P2298: !_DWLD [2] (FP)
ldd [%i0 + 8], %f18
! 1 addresses covered
fmovs %f19, %f13

P2299: !_CASX [0] (maybe <- 0x1000025) (Int) (CBR)
add %i0, 0, %l3
ldx [%l3], %o3
! move %o3(upper) -> %o3(upper)
! move %o3(lower) -> %o3(lower)
mov %o3, %o5
sllx %l4, 32, %o4
add  %l4, 1, %l4
or   %l4, %o4, %o4
casx [%l3], %o5, %o4
! move %o4(upper) -> %o4(upper)
! move %o4(lower) -> %o4(lower)
!---- flushing int results buffer----
mov %o0, %l5
mov %o1, %l5
mov %o2, %l5
mov %o3, %l5
mov %o4, %l5
add  %l4, 1, %l4

! cbranch
andcc %l0, 1, %g0
be,pn  %xcc, TARGET2299
nop
RET2299:

! lfsr step begin
srlx %l0, 1, %o5
xnor %o5, %l0, %o5
sllx %o5, 63, %o5
or  %o5, %l0, %l0
srlx %l0, 1, %l0


P2300: !_CAS [9] (maybe <- 0x1000027) (Int) (LE)
! Change single-word-level endianess (big endian <-> little endian) 
sethi %hi(0xff00ff00), %l6
or %l6, %lo(0xff00ff00), %l6
and %l4, %l6, %l3
srl %l3, 8, %l3
sll %l4, 8, %l7
and %l7, %l6, %l7
or %l7, %l3, %l7
srl %l7, 16, %l3
sll %l7, 16, %l7
srl %l7, 0, %l7
or %l7, %l3, %l7
wr %g0, 0x88, %asi
add %i1, 512, %l6
lduwa [%l6] %asi, %o0
mov %o0, %l3
! move %l3(lower) -> %o0(upper)
sllx %l3, 32, %o0
mov %l7, %o5
casa [%l6] %asi, %l3, %o5
! move %o5(lower) -> %o0(lower)
srl %o5, 0, %l6
or %l6, %o0, %o0
add   %l4, 1, %l4

P2301: !_DWST [1] (maybe <- 0x4080004e) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
! 1 th moved, current_fp_src=21 
fmovs  %f16, %f21
fadds  %f16, %f17, %f16
std %f20, [%i0 + 0]

P2302: !_LD [0] (FP)
ld [%i0 + 0], %f14
! 1 addresses covered

P2303: !_CASX [11] (maybe <- 0x1000028) (Int)
add %i2, 64, %l3
ldx [%l3], %o1
! move %o1(upper) -> %o1(upper)
! move %o1(lower) -> %o1(lower)
mov  %o1, %o5
sllx %l4, 32, %o2
casx [%l3], %o5, %o2
! move %o2(upper) -> %o2(upper)
! move %o2(lower) -> %o2(lower)
add  %l4, 1, %l4

P2304: !_CAS [11] (maybe <- 0x1000029) (Int)
add %i2, 64, %l3
lduw [%l3], %o3
mov %o3, %o5
! move %o5(lower) -> %o3(upper)
sllx %o5, 32, %o3
mov %l4, %l7
cas [%l3], %o5, %l7
! move %l7(lower) -> %o3(lower)
srl %l7, 0, %l3
or %l3, %o3, %o3
add   %l4, 1, %l4

P2305: !_DWST [4] (maybe <- 0x40800050) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
std %f20, [%i0 + 64]

P2306: !_PREFETCH [5] (Int)
prefetch [%i1 + 76], 1

P2307: !_DWLD [13] (FP)
ldd [%i3 + 64], %f18
! 1 addresses covered
fmovs %f18, %f15
!---- flushing fp results buffer to %f30 ----
fmovd %f0, %f30
fmovd %f2, %f30
fmovd %f4, %f30
fmovd %f6, %f30
fmovd %f8, %f30
fmovd %f10, %f30
fmovd %f12, %f30
fmovd %f14, %f30

P2308: !_LD [13] (FP) (CBR)
ld [%i3 + 64], %f0
! 1 addresses covered

! cbranch
andcc %l0, 1, %g0
be,pt  %xcc, TARGET2308
nop
RET2308:

! lfsr step begin
srlx %l0, 1, %l7
xnor %l7, %l0, %l7
sllx %l7, 63, %l7
or  %l7, %l0, %l0
srlx %l0, 1, %l0


P2309: !_REPLACEMENT [9] (Int)
sethi %hi(0x200), %o5
or %o5, %lo(0x200),  %o5
sethi %hi(0x10000), %l3
or %l3, %lo(0x10000),  %l3
add %i3, %o5, %o5
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]

P2310: !_DWLD [0] (FP)
ldd [%i0 + 0], %f18
! 2 addresses covered
fmovs %f18, %f1
fmovs %f19, %f2

P2311: !_ST [15] (maybe <- 0x40800051) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i3 + 192 ]

P2312: !_DWLD [9] (FP)
ldd [%i1 + 512], %f18
! 1 addresses covered
fmovs %f18, %f3

P2313: !_REPLACEMENT [4] (Int) (Branch target of P2576)
sethi %hi(0x40), %l6
or %l6, %lo(0x40),  %l6
sethi %hi(0x10000), %l7
or %l7, %lo(0x10000),  %l7
add %i3, %l6, %l6
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
ba P2314
nop

TARGET2576:
ba RET2576
nop


P2314: !_PREFETCH [0] (Int)
prefetch [%i0 + 0], 1

P2315: !_DWLD [3] (FP)
ldd [%i0 + 32], %f4
! 1 addresses covered

P2316: !_ST [8] (maybe <- 0x40800052) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i1 + 256 ]

P2317: !_DWLD [7] (FP)
ldd [%i1 + 80], %f18
! 2 addresses covered
fmovs %f18, %f5
fmovs %f19, %f6

P2318: !_CAS [4] (maybe <- 0x100002a) (Int)
add %i0, 64, %l3
lduw [%l3], %o4
mov %o4, %o5
! move %o5(lower) -> %o4(upper)
sllx %o5, 32, %o4
mov %l4, %l7
cas [%l3], %o5, %l7
! move %l7(lower) -> %o4(lower)
srl %l7, 0, %l3
or %l3, %o4, %o4
!---- flushing int results buffer----
mov %o0, %l5
mov %o1, %l5
mov %o2, %l5
mov %o3, %l5
mov %o4, %l5
add   %l4, 1, %l4

P2319: !_PREFETCH [0] (Int)
prefetch [%i0 + 0], 1

P2320: !_REPLACEMENT [7] (Int)
sethi %hi(0x54), %o5
or %o5, %lo(0x54),  %o5
sethi %hi(0x10000), %l3
or %l3, %lo(0x10000),  %l3
add %i3, %o5, %o5
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]

P2321: !_SWAP [0] (maybe <- 0x100002b) (Int)
mov %l4, %o0
swap  [%i0 + 0], %o0
! move %o0(lower) -> %o0(upper)
sllx %o0, 32, %o0
add   %l4, 1, %l4

P2322: !_DWLD [9] (FP)
ldd [%i1 + 512], %f18
! 1 addresses covered
fmovs %f18, %f7

P2323: !_PREFETCH [10] (Int)
prefetch [%i2 + 32], 1

P2324: !_DWST [4] (maybe <- 0x40800053) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
std %f20, [%i0 + 64]

P2325: !_PREFETCH [0] (Int)
prefetch [%i0 + 0], 1

P2326: !_REPLACEMENT [13] (Int)
sethi %hi(0x40), %l3
or %l3, %lo(0x40),  %l3
sethi %hi(0x10000), %l6
or %l6, %lo(0x10000),  %l6
add %i3, %l3, %l3
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]

P2327: !_DWLD [0] (FP)
ldd [%i0 + 0], %f8
! 2 addresses covered

P2328: !_LD [0] (FP)
ld [%i0 + 0], %f10
! 1 addresses covered

P2329: !_SWAP [9] (maybe <- 0x100002c) (Int)
mov %l4, %l6
swap  [%i1 + 512], %l6
! move %l6(lower) -> %o0(lower)
srl %l6, 0, %o5
or %o5, %o0, %o0
add   %l4, 1, %l4

P2330: !_PREFETCH [2] (Int)
prefetch [%i0 + 12], 1

P2331: !_LD [11] (FP)
ld [%i2 + 64], %f11
! 1 addresses covered

P2332: !_LD [8] (FP)
ld [%i1 + 256], %f12
! 1 addresses covered

P2333: !_DWST [7] (maybe <- 0x40800054) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
! 1 th moved, current_fp_src=21 
fmovs  %f16, %f21
fadds  %f16, %f17, %f16
std %f20, [%i1 + 80]

P2334: !_DWST [0] (maybe <- 0x40800056) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
! 1 th moved, current_fp_src=21 
fmovs  %f16, %f21
fadds  %f16, %f17, %f16
std %f20, [%i0 + 0]

P2335: !_PREFETCH [15] (Int)
prefetch [%i3 + 192], 1

P2336: !_DWLD [7] (FP)
ldd [%i1 + 80], %f18
! 2 addresses covered
fmovs %f18, %f13
fmovs %f19, %f14

P2337: !_REPLACEMENT [14] (Int)
sethi %hi(0x80), %l3
or %l3, %lo(0x80),  %l3
sethi %hi(0x10000), %l6
or %l6, %lo(0x10000),  %l6
add %i3, %l3, %l3
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]

P2338: !_LD [6] (FP)
ld [%i1 + 80], %f15
! 1 addresses covered
!---- flushing fp results buffer to %f30 ----
fmovd %f0, %f30
fmovd %f2, %f30
fmovd %f4, %f30
fmovd %f6, %f30
fmovd %f8, %f30
fmovd %f10, %f30
fmovd %f12, %f30
fmovd %f14, %f30

P2339: !_PREFETCH [9] (Int)
prefetch [%i1 + 512], 1

P2340: !_PREFETCH [5] (Int)
prefetch [%i1 + 76], 1

P2341: !_DWLD [3] (FP) (CBR)
ldd [%i0 + 32], %f0
! 1 addresses covered

! cbranch
andcc %l0, 1, %g0
be,pn  %xcc, TARGET2341
nop
RET2341:

! lfsr step begin
srlx %l0, 1, %o5
xnor %o5, %l0, %o5
sllx %o5, 63, %o5
or  %o5, %l0, %l0
srlx %l0, 1, %l0


P2342: !_REPLACEMENT [8] (Int)
sethi %hi(0x100), %l3
or %l3, %lo(0x100),  %l3
sethi %hi(0x10000), %l6
or %l6, %lo(0x10000),  %l6
add %i3, %l3, %l3
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]

P2343: !_DWST [14] (maybe <- 0x40800058) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
std %f20, [%i3 + 128]

P2344: !_PREFETCH [2] (Int)
prefetch [%i0 + 12], 1

P2345: !_ST [1] (maybe <- 0x40800059) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i0 + 4 ]

P2346: !_ST [10] (maybe <- 0x4080005a) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i2 + 32 ]

P2347: !_DWST [5] (maybe <- 0x4080005b) (FP)
! 0 th moved, current_fp_src=21 
fmovs  %f16, %f21
fadds  %f16, %f17, %f16
std %f20, [%i1 + 72]

P2348: !_PREFETCH [13] (Int)
prefetch [%i3 + 64], 1

P2349: !_DWLD [8] (FP)
ldd [%i1 + 256], %f18
! 1 addresses covered
fmovs %f18, %f1

P2350: !_MEMBAR (Int)
membar #StoreLoad

P2351: !_DWLD [7] (FP)
ldd [%i1 + 80], %f2
! 2 addresses covered

P2352: !_DWST [6] (maybe <- 0x4080005c) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
! 1 th moved, current_fp_src=21 
fmovs  %f16, %f21
fadds  %f16, %f17, %f16
std %f20, [%i1 + 80]

P2353: !_PREFETCH [13] (Int)
prefetch [%i3 + 64], 1

P2354: !_PREFETCH [6] (Int)
prefetch [%i1 + 80], 1

P2355: !_DWLD [10] (FP)
ldd [%i2 + 32], %f4
! 1 addresses covered

P2356: !_SWAP [6] (maybe <- 0x100002d) (Int)
mov %l4, %o1
swap  [%i1 + 80], %o1
! move %o1(lower) -> %o1(upper)
sllx %o1, 32, %o1
add   %l4, 1, %l4

P2357: !_DWLD [6] (FP)
ldd [%i1 + 80], %f18
! 2 addresses covered
fmovs %f18, %f5
fmovs %f19, %f6

P2358: !_PREFETCH [2] (Int)
prefetch [%i0 + 12], 1

P2359: !_PREFETCH [11] (Int)
prefetch [%i2 + 64], 1

P2360: !_ST [3] (maybe <- 0x4080005e) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i0 + 32 ]

P2361: !_ST [10] (maybe <- 0x4080005f) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i2 + 32 ]

P2362: !_PREFETCH [14] (Int)
prefetch [%i3 + 128], 1

P2363: !_REPLACEMENT [11] (Int)
sethi %hi(0x40), %o5
or %o5, %lo(0x40),  %o5
sethi %hi(0x10000), %l3
or %l3, %lo(0x10000),  %l3
add %i3, %o5, %o5
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]

P2364: !_REPLACEMENT [8] (Int)
sethi %hi(0x100), %l7
or %l7, %lo(0x100),  %l7
sethi %hi(0x10000), %o5
or %o5, %lo(0x10000),  %o5
add %i3, %l7, %l7
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]

P2365: !_LD [10] (FP)
ld [%i2 + 32], %f7
! 1 addresses covered

P2366: !_MEMBAR (Int)
membar #StoreLoad

P2367: !_PREFETCH [9] (Int)
prefetch [%i1 + 512], 1

P2368: !_REPLACEMENT [10] (Int)
sethi %hi(0x20), %l6
or %l6, %lo(0x20),  %l6
sethi %hi(0x10000), %l7
or %l7, %lo(0x10000),  %l7
add %i3, %l6, %l6
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]

P2369: !_DWLD [12] (FP)
ldd [%i3 + 0], %f8
! 1 addresses covered

P2370: !_REPLACEMENT [9] (Int)
sethi %hi(0x200), %l3
or %l3, %lo(0x200),  %l3
sethi %hi(0x10000), %l6
or %l6, %lo(0x10000),  %l6
add %i3, %l3, %l3
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]

P2371: !_DWLD [4] (FP)
ldd [%i0 + 64], %f18
! 1 addresses covered
fmovs %f18, %f9

P2372: !_SWAP [2] (maybe <- 0x100002e) (Int)
mov %l4, %l6
swap  [%i0 + 12], %l6
! move %l6(lower) -> %o1(lower)
srl %l6, 0, %o5
or %o5, %o1, %o1
add   %l4, 1, %l4

P2373: !_PREFETCH [11] (Int)
prefetch [%i2 + 64], 1

P2374: !_LD [15] (FP)
ld [%i3 + 192], %f10
! 1 addresses covered

P2375: !_DWLD [11] (FP) (CBR)
ldd [%i2 + 64], %f18
! 1 addresses covered
fmovs %f18, %f11

! cbranch
andcc %l0, 1, %g0
be,pn  %xcc, TARGET2375
nop
RET2375:

! lfsr step begin
srlx %l0, 1, %l7
xnor %l7, %l0, %l7
sllx %l7, 63, %l7
or  %l7, %l0, %l0
srlx %l0, 1, %l0


P2376: !_DWST [4] (maybe <- 0x40800060) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
std %f20, [%i0 + 64]

P2377: !_DWST [11] (maybe <- 0x40800061) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
std %f20, [%i2 + 64]

P2378: !_LD [7] (FP)
ld [%i1 + 84], %f12
! 1 addresses covered

P2379: !_SWAP [4] (maybe <- 0x100002f) (Int)
mov %l4, %o2
swap  [%i0 + 64], %o2
! move %o2(lower) -> %o2(upper)
sllx %o2, 32, %o2
add   %l4, 1, %l4

P2380: !_REPLACEMENT [2] (Int)
sethi %hi(0xc), %l3
or %l3, %lo(0xc),  %l3
sethi %hi(0x10000), %l6
or %l6, %lo(0x10000),  %l6
add %i3, %l3, %l3
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]

P2381: !_DWST [6] (maybe <- 0x40800062) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
! 1 th moved, current_fp_src=21 
fmovs  %f16, %f21
fadds  %f16, %f17, %f16
std %f20, [%i1 + 80]

P2382: !_REPLACEMENT [12] (Int) (Branch target of P2776)
sethi %hi(0x0), %l7
or %l7, %lo(0x0),  %l7
sethi %hi(0x10000), %o5
or %o5, %lo(0x10000),  %o5
add %i3, %l7, %l7
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]
ba P2383
nop

TARGET2776:
ba RET2776
nop


P2383: !_PREFETCH [9] (Int) (CBR)
prefetch [%i1 + 512], 1

! cbranch
andcc %l0, 1, %g0
be,pn  %xcc, TARGET2383
nop
RET2383:

! lfsr step begin
srlx %l0, 1, %l6
xnor %l6, %l0, %l6
sllx %l6, 63, %l6
or  %l6, %l0, %l0
srlx %l0, 1, %l0


P2384: !_DWLD [15] (FP)
ldd [%i3 + 192], %f18
! 1 addresses covered
fmovs %f18, %f13

P2385: !_DWLD [11] (FP)
ldd [%i2 + 64], %f14
! 1 addresses covered

P2386: !_PREFETCH [2] (Int)
prefetch [%i0 + 12], 1

P2387: !_LD [3] (FP)
ld [%i0 + 32], %f15
! 1 addresses covered
!---- flushing fp results buffer to %f30 ----
fmovd %f0, %f30
fmovd %f2, %f30
fmovd %f4, %f30
fmovd %f6, %f30
fmovd %f8, %f30
fmovd %f10, %f30
fmovd %f12, %f30
fmovd %f14, %f30

P2388: !_DWST [12] (maybe <- 0x40800064) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
std %f20, [%i3 + 0]

P2389: !_CASX [11] (maybe <- 0x1000030) (Int)
add %i2, 64, %l7
ldx [%l7], %l3
! move %l3(upper) -> %o2(lower)
srlx %l3, 32, %l6
or %l6, %o2, %o2
! move %l3(lower) -> %o3(upper)
sllx %l3, 32, %o3
mov  %l3, %l6
sllx %l4, 32, %l3
casx [%l7], %l6, %l3
! move %l3(upper) -> %o3(lower)
srlx %l3, 32, %l7
or %l7, %o3, %o3
! move %l3(lower) -> %o4(upper)
sllx %l3, 32, %o4
add  %l4, 1, %l4

P2390: !_PREFETCH [12] (Int)
prefetch [%i3 + 0], 1

P2391: !_LD [12] (FP)
ld [%i3 + 0], %f0
! 1 addresses covered

P2392: !_REPLACEMENT [3] (Int)
sethi %hi(0x20), %l6
or %l6, %lo(0x20),  %l6
sethi %hi(0x10000), %l7
or %l7, %lo(0x10000),  %l7
add %i3, %l6, %l6
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]

P2393: !_REPLACEMENT [11] (Int) (Branch target of P2154)
sethi %hi(0x40), %l3
or %l3, %lo(0x40),  %l3
sethi %hi(0x10000), %l6
or %l6, %lo(0x10000),  %l6
add %i3, %l3, %l3
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
ba P2394
nop

TARGET2154:
ba RET2154
nop


P2394: !_LD [14] (FP)
ld [%i3 + 128], %f1
! 1 addresses covered

P2395: !_LD [8] (FP)
ld [%i1 + 256], %f2
! 1 addresses covered

P2396: !_DWST [14] (maybe <- 0x40800065) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
std %f20, [%i3 + 128]

P2397: !_REPLACEMENT [14] (Int)
sethi %hi(0x80), %l7
or %l7, %lo(0x80),  %l7
sethi %hi(0x10000), %o5
or %o5, %lo(0x10000),  %o5
add %i3, %l7, %l7
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]

P2398: !_REPLACEMENT [7] (Int)
sethi %hi(0x54), %l6
or %l6, %lo(0x54),  %l6
sethi %hi(0x10000), %l7
or %l7, %lo(0x10000),  %l7
add %i3, %l6, %l6
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]

P2399: !_DWST [5] (maybe <- 0x40800066) (FP) (Branch target of P2103)
! 0 th moved, current_fp_src=21 
fmovs  %f16, %f21
fadds  %f16, %f17, %f16
std %f20, [%i1 + 72]
ba P2400
nop

TARGET2103:
ba RET2103
nop


P2400: !_ST [8] (maybe <- 0x40800067) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i1 + 256 ]

P2401: !_DWLD [2] (FP)
ldd [%i0 + 8], %f18
! 1 addresses covered
fmovs %f19, %f3

P2402: !_DWST [3] (maybe <- 0x40800068) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
std %f20, [%i0 + 32]

P2403: !_ST [1] (maybe <- 0x40800069) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i0 + 4 ]

P2404: !_CAS [11] (maybe <- 0x1000031) (Int) (Branch target of P2643)
add %i2, 64, %l6
lduw [%l6], %o5
mov %o5, %l3
! move %l3(lower) -> %o4(lower)
or %l3, %o4, %o4
!---- flushing int results buffer----
mov %o0, %l5
mov %o1, %l5
mov %o2, %l5
mov %o3, %l5
mov %o4, %l5
mov %l4, %o0
cas [%l6], %l3, %o0
! move %o0(lower) -> %o0(upper)
sllx %o0, 32, %o0
add   %l4, 1, %l4
ba P2405
nop

TARGET2643:
ba RET2643
nop


P2405: !_PREFETCH [4] (Int)
prefetch [%i0 + 64], 1

P2406: !_DWST [15] (maybe <- 0x4080006a) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
std %f20, [%i3 + 192]

P2407: !_DWST [7] (maybe <- 0x4080006b) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
! 1 th moved, current_fp_src=21 
fmovs  %f16, %f21
fadds  %f16, %f17, %f16
std %f20, [%i1 + 80]

P2408: !_ST [2] (maybe <- 0x4080006d) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i0 + 12 ]

P2409: !_DWLD [4] (FP)
ldd [%i0 + 64], %f4
! 1 addresses covered

P2410: !_LD [1] (FP)
ld [%i0 + 4], %f5
! 1 addresses covered

P2411: !_REPLACEMENT [11] (Int)
sethi %hi(0x40), %l6
or %l6, %lo(0x40),  %l6
sethi %hi(0x10000), %l7
or %l7, %lo(0x10000),  %l7
add %i3, %l6, %l6
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]

P2412: !_PREFETCH [0] (Int) (Branch target of P2601)
prefetch [%i0 + 0], 1
ba P2413
nop

TARGET2601:
ba RET2601
nop


P2413: !_PREFETCH [0] (Int)
prefetch [%i0 + 0], 1

P2414: !_DWLD [3] (FP)
ldd [%i0 + 32], %f6
! 1 addresses covered

P2415: !_ST [12] (maybe <- 0x4080006e) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i3 + 0 ]

P2416: !_ST [8] (maybe <- 0x4080006f) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i1 + 256 ]

P2417: !_ST [13] (maybe <- 0x40800070) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i3 + 64 ]

P2418: !_PREFETCH [8] (Int)
prefetch [%i1 + 256], 1

P2419: !_ST [11] (maybe <- 0x40800071) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i2 + 64 ]

P2420: !_MEMBAR (Int)
membar #StoreLoad

P2421: !_PREFETCH [0] (Int)
prefetch [%i0 + 0], 1

P2422: !_DWLD [1] (FP)
ldd [%i0 + 0], %f18
! 2 addresses covered
fmovs %f18, %f7
fmovs %f19, %f8

P2423: !_SWAP [3] (maybe <- 0x1000032) (Int)
mov %l4, %l7
swap  [%i0 + 32], %l7
! move %l7(lower) -> %o0(lower)
srl %l7, 0, %l3
or %l3, %o0, %o0
add   %l4, 1, %l4

P2424: !_CAS [4] (maybe <- 0x1000033) (Int)
add %i0, 64, %l3
lduw [%l3], %o1
mov %o1, %o5
! move %o5(lower) -> %o1(upper)
sllx %o5, 32, %o1
mov %l4, %l7
cas [%l3], %o5, %l7
! move %l7(lower) -> %o1(lower)
srl %l7, 0, %l3
or %l3, %o1, %o1
add   %l4, 1, %l4

P2425: !_REPLACEMENT [14] (Int)
sethi %hi(0x80), %o5
or %o5, %lo(0x80),  %o5
sethi %hi(0x10000), %l3
or %l3, %lo(0x10000),  %l3
add %i3, %o5, %o5
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]

P2426: !_ST [2] (maybe <- 0x40800072) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i0 + 12 ]

P2427: !_LD [7] (FP)
ld [%i1 + 84], %f9
! 1 addresses covered

P2428: !_PREFETCH [11] (Int)
prefetch [%i2 + 64], 1

P2429: !_CASX [3] (maybe <- 0x1000034) (Int) (Branch target of P2191)
add %i0, 32, %l7
ldx [%l7], %o2
! move %o2(upper) -> %o2(upper)
! move %o2(lower) -> %o2(lower)
mov  %o2, %l6
sllx %l4, 32, %o3
casx [%l7], %l6, %o3
! move %o3(upper) -> %o3(upper)
! move %o3(lower) -> %o3(lower)
add  %l4, 1, %l4
ba P2430
nop

TARGET2191:
ba RET2191
nop


P2430: !_PREFETCH [7] (Int)
prefetch [%i1 + 84], 1

P2431: !_DWST [12] (maybe <- 0x40800073) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
std %f20, [%i3 + 0]

P2432: !_REPLACEMENT [6] (Int)
sethi %hi(0x50), %l3
or %l3, %lo(0x50),  %l3
sethi %hi(0x10000), %l6
or %l6, %lo(0x10000),  %l6
add %i3, %l3, %l3
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]

P2433: !_LD [13] (FP)
ld [%i3 + 64], %f10
! 1 addresses covered

P2434: !_PREFETCH [13] (Int)
prefetch [%i3 + 64], 1

P2435: !_DWLD [7] (FP) (Branch target of P2836)
ldd [%i1 + 80], %f18
! 2 addresses covered
fmovs %f18, %f11
fmovs %f19, %f12
ba P2436
nop

TARGET2836:
ba RET2836
nop


P2436: !_DWLD [1] (FP)
ldd [%i0 + 0], %f18
! 2 addresses covered
fmovs %f18, %f13
fmovs %f19, %f14

P2437: !_REPLACEMENT [8] (Int)
sethi %hi(0x100), %o5
or %o5, %lo(0x100),  %o5
sethi %hi(0x10000), %l3
or %l3, %lo(0x10000),  %l3
add %i3, %o5, %o5
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]

P2438: !_ST [11] (maybe <- 0x40800074) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i2 + 64 ]

P2439: !_CASX [12] (maybe <- 0x1000035) (Int)
add %i3, 0, %l7
ldx [%l7], %o4
! move %o4(upper) -> %o4(upper)
! move %o4(lower) -> %o4(lower)
!---- flushing int results buffer----
mov %o0, %l5
mov %o1, %l5
mov %o2, %l5
mov %o3, %l5
mov %o4, %l5
mov  %o4, %l6
sllx %l4, 32, %o0
casx [%l7], %l6, %o0
! move %o0(upper) -> %o0(upper)
! move %o0(lower) -> %o0(lower)
add  %l4, 1, %l4

P2440: !_PREFETCH [11] (Int) (Branch target of P2605)
prefetch [%i2 + 64], 1
ba P2441
nop

TARGET2605:
ba RET2605
nop


P2441: !_CASX [11] (maybe <- 0x1000036) (Int)
add %i2, 64, %l7
ldx [%l7], %o1
! move %o1(upper) -> %o1(upper)
! move %o1(lower) -> %o1(lower)
mov  %o1, %l6
sllx %l4, 32, %o2
casx [%l7], %l6, %o2
! move %o2(upper) -> %o2(upper)
! move %o2(lower) -> %o2(lower)
add  %l4, 1, %l4

P2442: !_LD [2] (FP)
ld [%i0 + 12], %f15
! 1 addresses covered
!---- flushing fp results buffer to %f30 ----
fmovd %f0, %f30
fmovd %f2, %f30
fmovd %f4, %f30
fmovd %f6, %f30
fmovd %f8, %f30
fmovd %f10, %f30
fmovd %f12, %f30
fmovd %f14, %f30

P2443: !_PREFETCH [8] (Int)
prefetch [%i1 + 256], 1

P2444: !_PREFETCH [9] (Int)
prefetch [%i1 + 512], 1

P2445: !_PREFETCH [6] (Int)
prefetch [%i1 + 80], 1

P2446: !_LD [2] (FP)
ld [%i0 + 12], %f0
! 1 addresses covered

P2447: !_DWLD [7] (FP)
ldd [%i1 + 80], %f18
! 2 addresses covered
fmovs %f18, %f1
fmovs %f19, %f2

P2448: !_DWST [8] (maybe <- 0x40800075) (FP) (CBR)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
std %f20, [%i1 + 256]

! cbranch
andcc %l0, 1, %g0
be,pt  %xcc, TARGET2448
nop
RET2448:

! lfsr step begin
srlx %l0, 1, %l3
xnor %l3, %l0, %l3
sllx %l3, 63, %l3
or  %l3, %l0, %l0
srlx %l0, 1, %l0


P2449: !_MEMBAR (Int)
membar #StoreLoad

P2450: !_DWST [14] (maybe <- 0x40800076) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
std %f20, [%i3 + 128]

P2451: !_DWST [2] (maybe <- 0x40800077) (FP)
! 0 th moved, current_fp_src=21 
fmovs  %f16, %f21
fadds  %f16, %f17, %f16
std %f20, [%i0 + 8]

P2452: !_PREFETCH [2] (Int)
prefetch [%i0 + 12], 1

P2453: !_REPLACEMENT [13] (Int)
sethi %hi(0x40), %o5
or %o5, %lo(0x40),  %o5
sethi %hi(0x10000), %l3
or %l3, %lo(0x10000),  %l3
add %i3, %o5, %o5
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]

P2454: !_ST [10] (maybe <- 0x40800078) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i2 + 32 ]

P2455: !_PREFETCH [7] (Int)
prefetch [%i1 + 84], 1

P2456: !_LD [0] (FP)
ld [%i0 + 0], %f3
! 1 addresses covered

P2457: !_DWLD [5] (FP) (CBR)
ldd [%i1 + 72], %f4
! 1 addresses covered
fmovs %f5, %f4

! cbranch
andcc %l0, 1, %g0
be,pt  %xcc, TARGET2457
nop
RET2457:

! lfsr step begin
srlx %l0, 1, %l6
xnor %l6, %l0, %l6
sllx %l6, 63, %l6
or  %l6, %l0, %l0
srlx %l0, 1, %l0


P2458: !_SWAP [15] (maybe <- 0x1000037) (Int)
mov %l4, %o3
swap  [%i3 + 192], %o3
! move %o3(lower) -> %o3(upper)
sllx %o3, 32, %o3
add   %l4, 1, %l4

P2459: !_DWLD [13] (FP)
ldd [%i3 + 64], %f18
! 1 addresses covered
fmovs %f18, %f5

P2460: !_REPLACEMENT [10] (Int)
sethi %hi(0x20), %l6
or %l6, %lo(0x20),  %l6
sethi %hi(0x10000), %l7
or %l7, %lo(0x10000),  %l7
add %i3, %l6, %l6
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]

P2461: !_DWLD [11] (FP)
ldd [%i2 + 64], %f6
! 1 addresses covered

P2462: !_REPLACEMENT [7] (Int)
sethi %hi(0x54), %l3
or %l3, %lo(0x54),  %l3
sethi %hi(0x10000), %l6
or %l6, %lo(0x10000),  %l6
add %i3, %l3, %l3
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]

P2463: !_LD [12] (FP)
ld [%i3 + 0], %f7
! 1 addresses covered

P2464: !_LD [15] (FP)
ld [%i3 + 192], %f8
! 1 addresses covered

P2465: !_ST [0] (maybe <- 0x40800079) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i0 + 0 ]

P2466: !_CAS [2] (maybe <- 0x1000038) (Int)
add %i0, 12, %o5
lduw [%o5], %l6
mov %l6, %l7
! move %l7(lower) -> %o3(lower)
or %l7, %o3, %o3
mov %l4, %o4
cas [%o5], %l7, %o4
! move %o4(lower) -> %o4(upper)
sllx %o4, 32, %o4
add   %l4, 1, %l4

P2467: !_REPLACEMENT [5] (Int) (CBR)
sethi %hi(0x4c), %l7
or %l7, %lo(0x4c),  %l7
sethi %hi(0x10000), %o5
or %o5, %lo(0x10000),  %o5
add %i3, %l7, %l7
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]

! cbranch
andcc %l0, 1, %g0
be,pt  %xcc, TARGET2467
nop
RET2467:

! lfsr step begin
srlx %l0, 1, %l6
xnor %l6, %l0, %l6
sllx %l6, 63, %l6
or  %l6, %l0, %l0
srlx %l0, 1, %l0


P2468: !_REPLACEMENT [13] (Int)
sethi %hi(0x40), %l7
or %l7, %lo(0x40),  %l7
sethi %hi(0x10000), %o5
or %o5, %lo(0x10000),  %o5
add %i3, %l7, %l7
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]

P2469: !_DWLD [0] (FP)
ldd [%i0 + 0], %f18
! 2 addresses covered
fmovs %f18, %f9
fmovs %f19, %f10

P2470: !_CAS [6] (maybe <- 0x1000039) (Int)
add %i1, 80, %l7
lduw [%l7], %l3
mov %l3, %l6
! move %l6(lower) -> %o4(lower)
or %l6, %o4, %o4
!---- flushing int results buffer----
mov %o0, %l5
mov %o1, %l5
mov %o2, %l5
mov %o3, %l5
mov %o4, %l5
mov %l4, %o0
cas [%l7], %l6, %o0
! move %o0(lower) -> %o0(upper)
sllx %o0, 32, %o0
add   %l4, 1, %l4

P2471: !_REPLACEMENT [13] (Int)
sethi %hi(0x40), %l6
or %l6, %lo(0x40),  %l6
sethi %hi(0x10000), %l7
or %l7, %lo(0x10000),  %l7
add %i3, %l6, %l6
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]

P2472: !_DWST [13] (maybe <- 0x4080007a) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
std %f20, [%i3 + 64]

P2473: !_DWST [0] (maybe <- 0x4080007b) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
! 1 th moved, current_fp_src=21 
fmovs  %f16, %f21
fadds  %f16, %f17, %f16
std %f20, [%i0 + 0]

P2474: !_LD [5] (FP)
ld [%i1 + 76], %f11
! 1 addresses covered

P2475: !_PREFETCH [14] (Int)
prefetch [%i3 + 128], 1

P2476: !_DWLD [5] (FP)
ldd [%i1 + 72], %f12
! 1 addresses covered
fmovs %f13, %f12

P2477: !_DWST [7] (maybe <- 0x4080007d) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
! 1 th moved, current_fp_src=21 
fmovs  %f16, %f21
fadds  %f16, %f17, %f16
std %f20, [%i1 + 80]

P2478: !_DWST [2] (maybe <- 0x4080007f) (FP) (Branch target of P2282)
! 0 th moved, current_fp_src=21 
fmovs  %f16, %f21
fadds  %f16, %f17, %f16
std %f20, [%i0 + 8]
ba P2479
nop

TARGET2282:
ba RET2282
nop


P2479: !_DWLD [13] (FP)
ldd [%i3 + 64], %f18
! 1 addresses covered
fmovs %f18, %f13

P2480: !_DWLD [4] (FP)
ldd [%i0 + 64], %f14
! 1 addresses covered

P2481: !_SWAP [0] (maybe <- 0x100003a) (Int)
mov %l4, %l7
swap  [%i0 + 0], %l7
! move %l7(lower) -> %o0(lower)
srl %l7, 0, %l3
or %l3, %o0, %o0
add   %l4, 1, %l4

P2482: !_ST [15] (maybe <- 0x40800080) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i3 + 192 ]

P2483: !_REPLACEMENT [13] (Int)
sethi %hi(0x40), %l7
or %l7, %lo(0x40),  %l7
sethi %hi(0x10000), %o5
or %o5, %lo(0x10000),  %o5
add %i3, %l7, %l7
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]

P2484: !_PREFETCH [6] (Int) (CBR)
prefetch [%i1 + 80], 1

! cbranch
andcc %l0, 1, %g0
be,pt  %xcc, TARGET2484
nop
RET2484:

! lfsr step begin
srlx %l0, 1, %l6
xnor %l6, %l0, %l6
sllx %l6, 63, %l6
or  %l6, %l0, %l0
srlx %l0, 1, %l0


P2485: !_CAS [8] (maybe <- 0x100003b) (Int)
add %i1, 256, %o5
lduw [%o5], %o1
mov %o1, %l7
! move %l7(lower) -> %o1(upper)
sllx %l7, 32, %o1
mov %l4, %l6
cas [%o5], %l7, %l6
! move %l6(lower) -> %o1(lower)
srl %l6, 0, %o5
or %o5, %o1, %o1
add   %l4, 1, %l4

P2486: !_LD [0] (FP)
ld [%i0 + 0], %f15
! 1 addresses covered
!---- flushing fp results buffer to %f30 ----
fmovd %f0, %f30
fmovd %f2, %f30
fmovd %f4, %f30
fmovd %f6, %f30
fmovd %f8, %f30
fmovd %f10, %f30
fmovd %f12, %f30
fmovd %f14, %f30

P2487: !_CASX [0] (maybe <- 0x100003c) (Int)
add %i0, 0, %o5
ldx [%o5], %o2
! move %o2(upper) -> %o2(upper)
! move %o2(lower) -> %o2(lower)
mov %o2, %l7
sllx %l4, 32, %o3
add  %l4, 1, %l4
or   %l4, %o3, %o3
casx [%o5], %l7, %o3
! move %o3(upper) -> %o3(upper)
! move %o3(lower) -> %o3(lower)
add  %l4, 1, %l4

P2488: !_ST [0] (maybe <- 0x40800081) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i0 + 0 ]

P2489: !_DWST [10] (maybe <- 0x40800082) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
std %f20, [%i2 + 32]

P2490: !_CASX [2] (maybe <- 0x100003e) (Int)
add %i0, 8, %l6
ldx [%l6], %o4
! move %o4(upper) -> %o4(upper)
! move %o4(lower) -> %o4(lower)
!---- flushing int results buffer----
mov %o0, %l5
mov %o1, %l5
mov %o2, %l5
mov %o3, %l5
mov %o4, %l5
mov  %o4, %l3
mov %l4, %o0
casx [%l6], %l3, %o0
! move %o0(upper) -> %o0(upper)
! move %o0(lower) -> %o0(lower)
add  %l4, 1, %l4

P2491: !_LD [13] (FP)
ld [%i3 + 64], %f0
! 1 addresses covered

P2492: !_SWAP [7] (maybe <- 0x100003f) (Int)
mov %l4, %o1
swap  [%i1 + 84], %o1
! move %o1(lower) -> %o1(upper)
sllx %o1, 32, %o1
add   %l4, 1, %l4

P2493: !_REPLACEMENT [4] (Int)
sethi %hi(0x40), %o5
or %o5, %lo(0x40),  %o5
sethi %hi(0x10000), %l3
or %l3, %lo(0x10000),  %l3
add %i3, %o5, %o5
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]

P2494: !_LD [11] (FP) (Branch target of P2719)
ld [%i2 + 64], %f1
! 1 addresses covered
ba P2495
nop

TARGET2719:
ba RET2719
nop


P2495: !_LD [7] (FP)
ld [%i1 + 84], %f2
! 1 addresses covered

P2496: !_PREFETCH [5] (Int)
prefetch [%i1 + 76], 1

P2497: !_PREFETCH [7] (Int)
prefetch [%i1 + 84], 1

P2498: !_DWLD [8] (FP)
ldd [%i1 + 256], %f18
! 1 addresses covered
fmovs %f18, %f3

P2499: !_PREFETCH [12] (Int) (CBR)
prefetch [%i3 + 0], 1

! cbranch
andcc %l0, 1, %g0
be,pn  %xcc, TARGET2499
nop
RET2499:

! lfsr step begin
srlx %l0, 1, %l7
xnor %l7, %l0, %l7
sllx %l7, 63, %l7
or  %l7, %l0, %l0
srlx %l0, 1, %l0


P2500: !_DWLD [2] (FP)
ldd [%i0 + 8], %f4
! 1 addresses covered
fmovs %f5, %f4

P2501: !_MEMBAR (Int)
membar #StoreLoad

P2502: !_LD [4] (FP)
ld [%i0 + 64], %f5
! 1 addresses covered

P2503: !_DWST [0] (maybe <- 0x40800083) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
! 1 th moved, current_fp_src=21 
fmovs  %f16, %f21
fadds  %f16, %f17, %f16
std %f20, [%i0 + 0]

P2504: !_CAS [7] (maybe <- 0x1000040) (Int)
add %i1, 84, %o5
lduw [%o5], %l6
mov %l6, %l7
! move %l7(lower) -> %o1(lower)
or %l7, %o1, %o1
mov %l4, %o2
cas [%o5], %l7, %o2
! move %o2(lower) -> %o2(upper)
sllx %o2, 32, %o2
add   %l4, 1, %l4

P2505: !_MEMBAR (Int)
membar #StoreLoad

P2506: !_DWST [11] (maybe <- 0x40800085) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
std %f20, [%i2 + 64]

P2507: !_MEMBAR (Int)
membar #StoreLoad

P2508: !_LD [14] (FP)
ld [%i3 + 128], %f6
! 1 addresses covered

P2509: !_PREFETCH [0] (Int)
prefetch [%i0 + 0], 1

P2510: !_DWLD [4] (FP)
ldd [%i0 + 64], %f18
! 1 addresses covered
fmovs %f18, %f7

P2511: !_DWLD [9] (FP)
ldd [%i1 + 512], %f8
! 1 addresses covered

P2512: !_NOP (Int)
nop

P2513: !_MEMBAR (Int)
membar #StoreLoad

P2514: !_CAS [0] (maybe <- 0x1000041) (Int)
add %i0, 0, %l7
lduw [%l7], %l3
mov %l3, %l6
! move %l6(lower) -> %o2(lower)
or %l6, %o2, %o2
mov %l4, %o3
cas [%l7], %l6, %o3
! move %o3(lower) -> %o3(upper)
sllx %o3, 32, %o3
add   %l4, 1, %l4

P2515: !_LD [7] (FP)
ld [%i1 + 84], %f9
! 1 addresses covered

P2516: !_REPLACEMENT [10] (Int)
sethi %hi(0x20), %l6
or %l6, %lo(0x20),  %l6
sethi %hi(0x10000), %l7
or %l7, %lo(0x10000),  %l7
add %i3, %l6, %l6
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]

P2517: !_DWST [14] (maybe <- 0x40800086) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
std %f20, [%i3 + 128]

P2518: !_CASX [0] (maybe <- 0x1000042) (Int)
add %i0, 0, %l3
ldx [%l3], %l7
! move %l7(upper) -> %o3(lower)
srlx %l7, 32, %o5
or %o5, %o3, %o3
! move %l7(lower) -> %o4(upper)
sllx %l7, 32, %o4
mov %l7, %o5
sllx %l4, 32, %l7
add  %l4, 1, %l4
or   %l4, %l7, %l7
casx [%l3], %o5, %l7
! move %l7(upper) -> %o4(lower)
srlx %l7, 32, %l3
or %l3, %o4, %o4
!---- flushing int results buffer----
mov %o0, %l5
mov %o1, %l5
mov %o2, %l5
mov %o3, %l5
mov %o4, %l5
! move %l7(lower) -> %o0(upper)
sllx %l7, 32, %o0
add  %l4, 1, %l4

P2519: !_PREFETCH [3] (Int)
prefetch [%i0 + 32], 1

P2520: !_REPLACEMENT [4] (Int)
sethi %hi(0x40), %o5
or %o5, %lo(0x40),  %o5
sethi %hi(0x10000), %l3
or %l3, %lo(0x10000),  %l3
add %i3, %o5, %o5
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]

P2521: !_CASX [2] (maybe <- 0x1000044) (Int) (CBR)
add %i0, 8, %o5
ldx [%o5], %l6
! move %l6(upper) -> %o0(lower)
srlx %l6, 32, %l7
or %l7, %o0, %o0
! move %l6(lower) -> %o1(upper)
sllx %l6, 32, %o1
mov  %l6, %l7
mov %l4, %l6
casx [%o5], %l7, %l6
! move %l6(upper) -> %o1(lower)
srlx %l6, 32, %o5
or %o5, %o1, %o1
! move %l6(lower) -> %o2(upper)
sllx %l6, 32, %o2
add  %l4, 1, %l4

! cbranch
andcc %l0, 1, %g0
be,pn  %xcc, TARGET2521
nop
RET2521:

! lfsr step begin
srlx %l0, 1, %l7
xnor %l7, %l0, %l7
sllx %l7, 63, %l7
or  %l7, %l0, %l0
srlx %l0, 1, %l0


P2522: !_PREFETCH [11] (Int) (LE)
wr %g0, 0x88, %asi
prefetcha [%i2 + 64] %asi, 1

P2523: !_DWLD [8] (FP)
ldd [%i1 + 256], %f10
! 1 addresses covered

P2524: !_DWST [14] (maybe <- 0x40800087) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
std %f20, [%i3 + 128]

P2525: !_PREFETCH [1] (Int) (CBR)
prefetch [%i0 + 4], 1

! cbranch
andcc %l0, 1, %g0
be,pt  %xcc, TARGET2525
nop
RET2525:

! lfsr step begin
srlx %l0, 1, %l7
xnor %l7, %l0, %l7
sllx %l7, 63, %l7
or  %l7, %l0, %l0
srlx %l0, 1, %l0


P2526: !_PREFETCH [1] (Int)
prefetch [%i0 + 4], 1

P2527: !_LD [15] (FP)
ld [%i3 + 192], %f11
! 1 addresses covered

P2528: !_CAS [1] (maybe <- 0x1000045) (Int)
add %i0, 4, %l3
lduw [%l3], %l7
mov %l7, %o5
! move %o5(lower) -> %o2(lower)
or %o5, %o2, %o2
mov %l4, %o3
cas [%l3], %o5, %o3
! move %o3(lower) -> %o3(upper)
sllx %o3, 32, %o3
add   %l4, 1, %l4

P2529: !_CAS [8] (maybe <- 0x1000046) (Int)
add %i1, 256, %l3
lduw [%l3], %l7
mov %l7, %o5
! move %o5(lower) -> %o3(lower)
or %o5, %o3, %o3
mov %l4, %o4
cas [%l3], %o5, %o4
! move %o4(lower) -> %o4(upper)
sllx %o4, 32, %o4
add   %l4, 1, %l4

P2530: !_LD [15] (FP) (Branch target of P2341)
ld [%i3 + 192], %f12
! 1 addresses covered
ba P2531
nop

TARGET2341:
ba RET2341
nop


P2531: !_ST [14] (maybe <- 0x40800088) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i3 + 128 ]

P2532: !_REPLACEMENT [7] (Int) (Branch target of P2143)
sethi %hi(0x54), %l7
or %l7, %lo(0x54),  %l7
sethi %hi(0x10000), %o5
or %o5, %lo(0x10000),  %o5
add %i3, %l7, %l7
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]
ba P2533
nop

TARGET2143:
ba RET2143
nop


P2533: !_DWLD [2] (FP)
ldd [%i0 + 8], %f18
! 1 addresses covered
fmovs %f19, %f13

P2534: !_MEMBAR (Int)
membar #StoreLoad

P2535: !_LD [4] (FP)
ld [%i0 + 64], %f14
! 1 addresses covered

P2536: !_REPLACEMENT [13] (Int)
sethi %hi(0x40), %l6
or %l6, %lo(0x40),  %l6
sethi %hi(0x10000), %l7
or %l7, %lo(0x10000),  %l7
add %i3, %l6, %l6
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]

P2537: !_DWLD [8] (FP)
ldd [%i1 + 256], %f18
! 1 addresses covered
fmovs %f18, %f15
!---- flushing fp results buffer to %f30 ----
fmovd %f0, %f30
fmovd %f2, %f30
fmovd %f4, %f30
fmovd %f6, %f30
fmovd %f8, %f30
fmovd %f10, %f30
fmovd %f12, %f30
fmovd %f14, %f30

P2538: !_LD [15] (FP)
ld [%i3 + 192], %f0
! 1 addresses covered

P2539: !_PREFETCH [4] (Int)
prefetch [%i0 + 64], 1

P2540: !_SWAP [12] (maybe <- 0x1000047) (Int) (LE)
wr %g0, 0x88, %asi
mov %l4, %l7
! Change single-word-level endianess (big endian <-> little endian) 
sethi %hi(0xff00ff00), %l3
or %l3, %lo(0xff00ff00), %l3
and %l7, %l3, %l6
srl %l6, 8, %l6
sll %l7, 8, %l7
and %l7, %l3, %l7
or %l7, %l6, %l7
srl %l7, 16, %l6
sll %l7, 16, %l7
srl %l7, 0, %l7
or %l7, %l6, %l7
swapa  [%i3 + 0] %asi, %l7
! move %l7(lower) -> %o4(lower)
srl %l7, 0, %l3
or %l3, %o4, %o4
!---- flushing int results buffer----
mov %o0, %l5
mov %o1, %l5
mov %o2, %l5
mov %o3, %l5
mov %o4, %l5
add   %l4, 1, %l4

P2541: !_CASX [5] (maybe <- 0x1000048) (Int)
add %i1, 72, %l3
ldx [%l3], %o0
! move %o0(upper) -> %o0(upper)
! move %o0(lower) -> %o0(lower)
mov  %o0, %o5
mov %l4, %o1
casx [%l3], %o5, %o1
! move %o1(upper) -> %o1(upper)
! move %o1(lower) -> %o1(lower)
add  %l4, 1, %l4

P2542: !_DWLD [0] (FP)
ldd [%i0 + 0], %f18
! 2 addresses covered
fmovs %f18, %f1
fmovs %f19, %f2

P2543: !_DWST [7] (maybe <- 0x40800089) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
! 1 th moved, current_fp_src=21 
fmovs  %f16, %f21
fadds  %f16, %f17, %f16
std %f20, [%i1 + 80]

P2544: !_CASX [10] (maybe <- 0x1000049) (Int) (LE)
! Change single-word-level endianess (big endian <-> little endian) 
sethi %hi(0xff00ff00), %o5
or %o5, %lo(0xff00ff00), %o5
and %l4, %o5, %l7
srl %l7, 8, %l7
sll %l4, 8, %l3
and %l3, %o5, %l3
or %l3, %l7, %l3
srl %l3, 16, %l7
sll %l3, 16, %l3
srl %l3, 0, %l3
or %l3, %l7, %l3
wr %g0, 0x88, %asi
add %i2, 32, %o5
ldxa [%o5] %asi, %l6
! move %l6(lower) -> %o2(upper)
sllx %l6, 32, %o2
! move %l6(upper) -> %o2(lower)
srlx %l6, 32, %l7
or %l7, %o2, %o2
mov  %l6, %l7
mov  %l3, %l6
casxa [%o5] %asi, %l7, %l6
! move %l6(lower) -> %o3(upper)
sllx %l6, 32, %o3
! move %l6(upper) -> %o3(lower)
srlx %l6, 32, %o5
or %o5, %o3, %o3
add  %l4, 1, %l4

P2545: !_PREFETCH [5] (Int)
prefetch [%i1 + 76], 1

P2546: !_LD [3] (Int)
lduw [%i0 + 32], %o4
! move %o4(lower) -> %o4(upper)
sllx %o4, 32, %o4

P2547: !_LD [7] (Int)
lduw [%i1 + 84], %l6
! move %l6(lower) -> %o4(lower)
or %l6, %o4, %o4
!---- flushing int results buffer----
mov %o0, %l5
mov %o1, %l5
mov %o2, %l5
mov %o3, %l5
mov %o4, %l5

P2548: !_LD [1] (FP)
ld [%i0 + 4], %f3
! 1 addresses covered

P2549: !_LD [8] (FP)
ld [%i1 + 256], %f4
! 1 addresses covered

P2550: !_LD [10] (FP)
ld [%i2 + 32], %f5
! 1 addresses covered

P2551: !_LD [9] (FP)
ld [%i1 + 512], %f6
! 1 addresses covered

P2552: !_LD [2] (FP)
ld [%i0 + 12], %f7
! 1 addresses covered

P2553: !_LD [8] (FP) (CBR)
ld [%i1 + 256], %f8
! 1 addresses covered

! cbranch
andcc %l0, 1, %g0
be,pt  %xcc, TARGET2553
nop
RET2553:

! lfsr step begin
srlx %l0, 1, %l7
xnor %l7, %l0, %l7
sllx %l7, 63, %l7
or  %l7, %l0, %l0
srlx %l0, 1, %l0


P2554: !_LD [3] (FP)
ld [%i0 + 32], %f9
! 1 addresses covered

P2555: !_LD [15] (FP)
ld [%i3 + 192], %f10
! 1 addresses covered

P2556: !_LD [11] (FP)
ld [%i2 + 64], %f11
! 1 addresses covered

P2557: !_LD [0] (FP)
ld [%i0 + 0], %f12
! 1 addresses covered

P2558: !_LD [10] (FP)
ld [%i2 + 32], %f13
! 1 addresses covered

P2559: !_LD [12] (FP) (CBR)
ld [%i3 + 0], %f14
! 1 addresses covered

! cbranch
andcc %l0, 1, %g0
be,pn  %xcc, TARGET2559
nop
RET2559:

! lfsr step begin
srlx %l0, 1, %o5
xnor %o5, %l0, %o5
sllx %o5, 63, %o5
or  %o5, %l0, %l0
srlx %l0, 1, %l0


P2560: !_LD [6] (FP)
ld [%i1 + 80], %f15
! 1 addresses covered
!---- flushing fp results buffer to %f30 ----
fmovd %f0, %f30
fmovd %f2, %f30
fmovd %f4, %f30
fmovd %f6, %f30
fmovd %f8, %f30
fmovd %f10, %f30
fmovd %f12, %f30
fmovd %f14, %f30

P2561: !_MEMBAR (Int) (Loop exit) (CBR) (Branch target of P2521)
membar #StoreLoad

! cbranch
andcc %l0, 1, %g0
be,pt  %xcc, TARGET2561
nop
RET2561:

! lfsr step begin
srlx %l0, 1, %l3
xnor %l3, %l0, %l3
sllx %l3, 63, %l3
or  %l3, %l0, %l0
srlx %l0, 1, %l0

loop_exit_2_0:
sub %l2, 1, %l2
cmp %l2, 0
bg loop_entry_2_0
nop
ba P2562
nop

TARGET2521:
ba RET2521
nop


P2562: !_CASX [7] (maybe <- 0x100004a) (Int)
add %i1, 80, %o5
ldx [%o5], %o0
! move %o0(upper) -> %o0(upper)
! move %o0(lower) -> %o0(lower)
mov %o0, %l7
sllx %l4, 32, %o1
add  %l4, 1, %l4
or   %l4, %o1, %o1
casx [%o5], %l7, %o1
! move %o1(upper) -> %o1(upper)
! move %o1(lower) -> %o1(lower)
add  %l4, 1, %l4

P2563: !_PREFETCH [12] (Int)
prefetch [%i3 + 0], 1

P2564: !_DWST [7] (maybe <- 0x4080008b) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
! 1 th moved, current_fp_src=21 
fmovs  %f16, %f21
fadds  %f16, %f17, %f16
std %f20, [%i1 + 80]

P2565: !_MEMBAR (Int)
membar #StoreLoad

P2566: !_DWST [9] (maybe <- 0x4080008d) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
std %f20, [%i1 + 512]

P2567: !_CAS [0] (maybe <- 0x100004c) (Int)
add %i0, 0, %l6
lduw [%l6], %o2
mov %o2, %l3
! move %l3(lower) -> %o2(upper)
sllx %l3, 32, %o2
mov %l4, %o5
cas [%l6], %l3, %o5
! move %o5(lower) -> %o2(lower)
srl %o5, 0, %l6
or %l6, %o2, %o2
add   %l4, 1, %l4

P2568: !_PREFETCH [14] (Int)
prefetch [%i3 + 128], 1

P2569: !_LD [9] (FP)
ld [%i1 + 512], %f0
! 1 addresses covered

P2570: !_REPLACEMENT [4] (Int)
sethi %hi(0x40), %l3
or %l3, %lo(0x40),  %l3
sethi %hi(0x10000), %l6
or %l6, %lo(0x10000),  %l6
add %i3, %l3, %l3
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]

P2571: !_LD [1] (FP) (CBR)
ld [%i0 + 4], %f1
! 1 addresses covered

! cbranch
andcc %l0, 1, %g0
be,pt  %xcc, TARGET2571
nop
RET2571:

! lfsr step begin
srlx %l0, 1, %o5
xnor %o5, %l0, %o5
sllx %o5, 63, %o5
or  %o5, %l0, %l0
srlx %l0, 1, %l0


P2572: !_REPLACEMENT [3] (Int) (Branch target of P2692)
sethi %hi(0x20), %l3
or %l3, %lo(0x20),  %l3
sethi %hi(0x10000), %l6
or %l6, %lo(0x10000),  %l6
add %i3, %l3, %l3
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
ba P2573
nop

TARGET2692:
ba RET2692
nop


P2573: !_CAS [15] (maybe <- 0x100004d) (Int)
add %i3, 192, %l3
lduw [%l3], %o3
mov %o3, %o5
! move %o5(lower) -> %o3(upper)
sllx %o5, 32, %o3
mov %l4, %l7
cas [%l3], %o5, %l7
! move %l7(lower) -> %o3(lower)
srl %l7, 0, %l3
or %l3, %o3, %o3
add   %l4, 1, %l4

P2574: !_ST [10] (maybe <- 0x4080008e) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i2 + 32 ]

P2575: !_PREFETCH [12] (Int)
prefetch [%i3 + 0], 1

P2576: !_ST [13] (maybe <- 0x4080008f) (FP) (CBR)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i3 + 64 ]

! cbranch
andcc %l0, 1, %g0
be,pt  %xcc, TARGET2576
nop
RET2576:

! lfsr step begin
srlx %l0, 1, %l6
xnor %l6, %l0, %l6
sllx %l6, 63, %l6
or  %l6, %l0, %l0
srlx %l0, 1, %l0


P2577: !_DWST [6] (maybe <- 0x40800090) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
! 1 th moved, current_fp_src=21 
fmovs  %f16, %f21
fadds  %f16, %f17, %f16
std %f20, [%i1 + 80]

P2578: !_PREFETCH [2] (Int)
prefetch [%i0 + 12], 1

P2579: !_CAS [7] (maybe <- 0x100004e) (Int)
add %i1, 84, %l7
lduw [%l7], %o4
mov %o4, %l6
! move %l6(lower) -> %o4(upper)
sllx %l6, 32, %o4
mov %l4, %l3
cas [%l7], %l6, %l3
! move %l3(lower) -> %o4(lower)
srl %l3, 0, %l7
or %l7, %o4, %o4
!---- flushing int results buffer----
mov %o0, %l5
mov %o1, %l5
mov %o2, %l5
mov %o3, %l5
mov %o4, %l5
add   %l4, 1, %l4

P2580: !_LD [3] (FP)
ld [%i0 + 32], %f2
! 1 addresses covered

P2581: !_DWST [14] (maybe <- 0x40800092) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
std %f20, [%i3 + 128]

P2582: !_MEMBAR (Int)
membar #StoreLoad

P2583: !_LD [3] (FP)
ld [%i0 + 32], %f3
! 1 addresses covered

P2584: !_DWST [11] (maybe <- 0x40800093) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
std %f20, [%i2 + 64]

P2585: !_REPLACEMENT [13] (Int)
sethi %hi(0x40), %o5
or %o5, %lo(0x40),  %o5
sethi %hi(0x10000), %l3
or %l3, %lo(0x10000),  %l3
add %i3, %o5, %o5
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]

P2586: !_DWLD [5] (FP)
ldd [%i1 + 72], %f4
! 1 addresses covered
fmovs %f5, %f4

P2587: !_NOP (Int)
nop

P2588: !_DWLD [13] (FP)
ldd [%i3 + 64], %f18
! 1 addresses covered
fmovs %f18, %f5

P2589: !_MEMBAR (Int)
membar #StoreLoad

P2590: !_LD [12] (FP)
ld [%i3 + 0], %f6
! 1 addresses covered

P2591: !_PREFETCH [11] (Int)
prefetch [%i2 + 64], 1

P2592: !_CAS [14] (maybe <- 0x100004f) (Int)
add %i3, 128, %o5
lduw [%o5], %o0
mov %o0, %l7
! move %l7(lower) -> %o0(upper)
sllx %l7, 32, %o0
mov %l4, %l6
cas [%o5], %l7, %l6
! move %l6(lower) -> %o0(lower)
srl %l6, 0, %o5
or %o5, %o0, %o0
add   %l4, 1, %l4

P2593: !_PREFETCH [14] (Int)
prefetch [%i3 + 128], 1

P2594: !_DWLD [11] (FP)
ldd [%i2 + 64], %f18
! 1 addresses covered
fmovs %f18, %f7

P2595: !_DWLD [0] (FP)
ldd [%i0 + 0], %f8
! 2 addresses covered

P2596: !_PREFETCH [8] (Int)
prefetch [%i1 + 256], 1

P2597: !_DWST [5] (maybe <- 0x40800094) (FP) (CBR)
! 0 th moved, current_fp_src=21 
fmovs  %f16, %f21
fadds  %f16, %f17, %f16
std %f20, [%i1 + 72]

! cbranch
andcc %l0, 1, %g0
be,pt  %xcc, TARGET2597
nop
RET2597:

! lfsr step begin
srlx %l0, 1, %l6
xnor %l6, %l0, %l6
sllx %l6, 63, %l6
or  %l6, %l0, %l0
srlx %l0, 1, %l0


P2598: !_LD [13] (FP)
ld [%i3 + 64], %f10
! 1 addresses covered

P2599: !_DWST [5] (maybe <- 0x40800095) (FP)
! 0 th moved, current_fp_src=21 
fmovs  %f16, %f21
fadds  %f16, %f17, %f16
std %f20, [%i1 + 72]

P2600: !_SWAP [3] (maybe <- 0x1000050) (Int)
mov %l4, %o1
swap  [%i0 + 32], %o1
! move %o1(lower) -> %o1(upper)
sllx %o1, 32, %o1
add   %l4, 1, %l4

P2601: !_ST [7] (maybe <- 0x40800096) (FP) (CBR)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i1 + 84 ]

! cbranch
andcc %l0, 1, %g0
be,pn  %xcc, TARGET2601
nop
RET2601:

! lfsr step begin
srlx %l0, 1, %o5
xnor %o5, %l0, %o5
sllx %o5, 63, %o5
or  %o5, %l0, %l0
srlx %l0, 1, %l0


P2602: !_ST [15] (maybe <- 0x40800097) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i3 + 192 ]

P2603: !_CASX [13] (maybe <- 0x1000051) (Int) (Branch target of P2040)
add %i3, 64, %l3
ldx [%l3], %l7
! move %l7(upper) -> %o1(lower)
srlx %l7, 32, %o5
or %o5, %o1, %o1
! move %l7(lower) -> %o2(upper)
sllx %l7, 32, %o2
mov  %l7, %o5
sllx %l4, 32, %l7
casx [%l3], %o5, %l7
! move %l7(upper) -> %o2(lower)
srlx %l7, 32, %l3
or %l3, %o2, %o2
! move %l7(lower) -> %o3(upper)
sllx %l7, 32, %o3
add  %l4, 1, %l4
ba P2604
nop

TARGET2040:
ba RET2040
nop


P2604: !_ST [7] (maybe <- 0x40800098) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i1 + 84 ]

P2605: !_DWST [15] (maybe <- 0x40800099) (FP) (CBR)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
std %f20, [%i3 + 192]

! cbranch
andcc %l0, 1, %g0
be,pt  %xcc, TARGET2605
nop
RET2605:

! lfsr step begin
srlx %l0, 1, %l6
xnor %l6, %l0, %l6
sllx %l6, 63, %l6
or  %l6, %l0, %l0
srlx %l0, 1, %l0


P2606: !_ST [9] (maybe <- 0x4080009a) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i1 + 512 ]

P2607: !_MEMBAR (Int)
membar #StoreLoad

P2608: !_ST [3] (maybe <- 0x4080009b) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i0 + 32 ]

P2609: !_PREFETCH [2] (Int)
prefetch [%i0 + 12], 1

P2610: !_SWAP [7] (maybe <- 0x1000052) (Int)
mov %l4, %l7
swap  [%i1 + 84], %l7
! move %l7(lower) -> %o3(lower)
srl %l7, 0, %l3
or %l3, %o3, %o3
add   %l4, 1, %l4

P2611: !_DWST [1] (maybe <- 0x4080009c) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
! 1 th moved, current_fp_src=21 
fmovs  %f16, %f21
fadds  %f16, %f17, %f16
std %f20, [%i0 + 0]

P2612: !_CASX [11] (maybe <- 0x1000053) (Int)
add %i2, 64, %o5
ldx [%o5], %o4
! move %o4(upper) -> %o4(upper)
! move %o4(lower) -> %o4(lower)
!---- flushing int results buffer----
mov %o0, %l5
mov %o1, %l5
mov %o2, %l5
mov %o3, %l5
mov %o4, %l5
mov  %o4, %l7
sllx %l4, 32, %o0
casx [%o5], %l7, %o0
! move %o0(upper) -> %o0(upper)
! move %o0(lower) -> %o0(lower)
add  %l4, 1, %l4

P2613: !_DWST [14] (maybe <- 0x4080009e) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
std %f20, [%i3 + 128]

P2614: !_PREFETCH [2] (Int)
prefetch [%i0 + 12], 1

P2615: !_PREFETCH [1] (Int)
prefetch [%i0 + 4], 1

P2616: !_ST [6] (maybe <- 0x4080009f) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i1 + 80 ]

P2617: !_DWLD [11] (FP)
ldd [%i2 + 64], %f18
! 1 addresses covered
fmovs %f18, %f11

P2618: !_DWLD [3] (FP)
ldd [%i0 + 32], %f12
! 1 addresses covered

P2619: !_REPLACEMENT [1] (Int)
sethi %hi(0x4), %l3
or %l3, %lo(0x4),  %l3
sethi %hi(0x10000), %l6
or %l6, %lo(0x10000),  %l6
add %i3, %l3, %l3
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]

P2620: !_ST [8] (maybe <- 0x408000a0) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i1 + 256 ]

P2621: !_ST [12] (maybe <- 0x408000a1) (FP) (Branch target of P2484)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i3 + 0 ]
ba P2622
nop

TARGET2484:
ba RET2484
nop


P2622: !_SWAP [3] (maybe <- 0x1000054) (Int)
mov %l4, %o1
swap  [%i0 + 32], %o1
! move %o1(lower) -> %o1(upper)
sllx %o1, 32, %o1
add   %l4, 1, %l4

P2623: !_DWLD [6] (FP)
ldd [%i1 + 80], %f18
! 2 addresses covered
fmovs %f18, %f13
fmovs %f19, %f14

P2624: !_CASX [4] (maybe <- 0x1000055) (Int) (Branch target of P2070)
add %i0, 64, %l6
ldx [%l6], %o5
! move %o5(upper) -> %o1(lower)
srlx %o5, 32, %l3
or %l3, %o1, %o1
! move %o5(lower) -> %o2(upper)
sllx %o5, 32, %o2
mov  %o5, %l3
sllx %l4, 32, %o5
casx [%l6], %l3, %o5
! move %o5(upper) -> %o2(lower)
srlx %o5, 32, %l6
or %l6, %o2, %o2
! move %o5(lower) -> %o3(upper)
sllx %o5, 32, %o3
add  %l4, 1, %l4
ba P2625
nop

TARGET2070:
ba RET2070
nop


P2625: !_SWAP [15] (maybe <- 0x1000056) (Int)
mov %l4, %l7
swap  [%i3 + 192], %l7
! move %l7(lower) -> %o3(lower)
srl %l7, 0, %l3
or %l3, %o3, %o3
add   %l4, 1, %l4

P2626: !_LD [10] (FP) (Branch target of P2948)
ld [%i2 + 32], %f15
! 1 addresses covered
!---- flushing fp results buffer to %f30 ----
fmovd %f0, %f30
fmovd %f2, %f30
fmovd %f4, %f30
fmovd %f6, %f30
fmovd %f8, %f30
fmovd %f10, %f30
fmovd %f12, %f30
fmovd %f14, %f30
ba P2627
nop

TARGET2948:
ba RET2948
nop


P2627: !_PREFETCH [0] (Int)
prefetch [%i0 + 0], 1

P2628: !_MEMBAR (Int) (CBR)
membar #StoreLoad

! cbranch
andcc %l0, 1, %g0
be,pt  %xcc, TARGET2628
nop
RET2628:

! lfsr step begin
srlx %l0, 1, %o5
xnor %o5, %l0, %o5
sllx %o5, 63, %o5
or  %o5, %l0, %l0
srlx %l0, 1, %l0


P2629: !_ST [8] (maybe <- 0x408000a2) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i1 + 256 ]

P2630: !_ST [11] (maybe <- 0x408000a3) (FP) (Branch target of P3029)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i2 + 64 ]
ba P2631
nop

TARGET3029:
ba RET3029
nop


P2631: !_DWLD [3] (FP)
ldd [%i0 + 32], %f0
! 1 addresses covered

P2632: !_REPLACEMENT [8] (Int)
sethi %hi(0x100), %l7
or %l7, %lo(0x100),  %l7
sethi %hi(0x10000), %o5
or %o5, %lo(0x10000),  %o5
add %i3, %l7, %l7
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]

P2633: !_SWAP [3] (maybe <- 0x1000057) (Int)
mov %l4, %o4
swap  [%i0 + 32], %o4
! move %o4(lower) -> %o4(upper)
sllx %o4, 32, %o4
add   %l4, 1, %l4

P2634: !_PREFETCH [8] (Int)
prefetch [%i1 + 256], 1

P2635: !_REPLACEMENT [12] (Int)
sethi %hi(0x0), %l3
or %l3, %lo(0x0),  %l3
sethi %hi(0x10000), %l6
or %l6, %lo(0x10000),  %l6
add %i3, %l3, %l3
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]

P2636: !_ST [13] (maybe <- 0x408000a4) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i3 + 64 ]

P2637: !_LD [11] (FP) (Branch target of P2276)
ld [%i2 + 64], %f1
! 1 addresses covered
ba P2638
nop

TARGET2276:
ba RET2276
nop


P2638: !_REPLACEMENT [14] (Int)
sethi %hi(0x80), %l7
or %l7, %lo(0x80),  %l7
sethi %hi(0x10000), %o5
or %o5, %lo(0x10000),  %o5
add %i3, %l7, %l7
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]

P2639: !_PREFETCH [12] (Int) (CBR)
prefetch [%i3 + 0], 1

! cbranch
andcc %l0, 1, %g0
be,pn  %xcc, TARGET2639
nop
RET2639:

! lfsr step begin
srlx %l0, 1, %l6
xnor %l6, %l0, %l6
sllx %l6, 63, %l6
or  %l6, %l0, %l0
srlx %l0, 1, %l0


P2640: !_LD [3] (FP)
ld [%i0 + 32], %f2
! 1 addresses covered

P2641: !_REPLACEMENT [0] (Int)
sethi %hi(0x0), %l7
or %l7, %lo(0x0),  %l7
sethi %hi(0x10000), %o5
or %o5, %lo(0x10000),  %o5
add %i3, %l7, %l7
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]

P2642: !_DWLD [12] (FP)
ldd [%i3 + 0], %f18
! 1 addresses covered
fmovs %f18, %f3

P2643: !_REPLACEMENT [15] (Int) (CBR)
sethi %hi(0xc0), %l6
or %l6, %lo(0xc0),  %l6
sethi %hi(0x10000), %l7
or %l7, %lo(0x10000),  %l7
add %i3, %l6, %l6
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]

! cbranch
andcc %l0, 1, %g0
be,pn  %xcc, TARGET2643
nop
RET2643:

! lfsr step begin
srlx %l0, 1, %l3
xnor %l3, %l0, %l3
sllx %l3, 63, %l3
or  %l3, %l0, %l0
srlx %l0, 1, %l0


P2644: !_LD [4] (FP)
ld [%i0 + 64], %f4
! 1 addresses covered

P2645: !_DWLD [5] (FP)
ldd [%i1 + 72], %f18
! 1 addresses covered
fmovs %f19, %f5

P2646: !_ST [12] (maybe <- 0x408000a5) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i3 + 0 ]

P2647: !_NOP (Int)
nop

P2648: !_PREFETCH [8] (Int)
prefetch [%i1 + 256], 1

P2649: !_LD [7] (FP)
ld [%i1 + 84], %f6
! 1 addresses covered

P2650: !_ST [13] (maybe <- 0x408000a6) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i3 + 64 ]

P2651: !_CAS [2] (maybe <- 0x1000058) (Int) (CBR)
add %i0, 12, %l3
lduw [%l3], %l7
mov %l7, %o5
! move %o5(lower) -> %o4(lower)
or %o5, %o4, %o4
!---- flushing int results buffer----
mov %o0, %l5
mov %o1, %l5
mov %o2, %l5
mov %o3, %l5
mov %o4, %l5
mov %l4, %o0
cas [%l3], %o5, %o0
! move %o0(lower) -> %o0(upper)
sllx %o0, 32, %o0
add   %l4, 1, %l4

! cbranch
andcc %l0, 1, %g0
be,pn  %xcc, TARGET2651
nop
RET2651:

! lfsr step begin
srlx %l0, 1, %o5
xnor %o5, %l0, %o5
sllx %o5, 63, %o5
or  %o5, %l0, %l0
srlx %l0, 1, %l0


P2652: !_DWLD [5] (FP)
ldd [%i1 + 72], %f18
! 1 addresses covered
fmovs %f19, %f7

P2653: !_DWLD [13] (FP)
ldd [%i3 + 64], %f8
! 1 addresses covered

P2654: !_REPLACEMENT [6] (Int)
sethi %hi(0x50), %l3
or %l3, %lo(0x50),  %l3
sethi %hi(0x10000), %l6
or %l6, %lo(0x10000),  %l6
add %i3, %l3, %l3
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]

P2655: !_LD [15] (FP) (Branch target of P2139)
ld [%i3 + 192], %f9
! 1 addresses covered
ba P2656
nop

TARGET2139:
ba RET2139
nop


P2656: !_DWLD [1] (FP)
ldd [%i0 + 0], %f10
! 2 addresses covered

P2657: !_DWLD [5] (FP)
ldd [%i1 + 72], %f12
! 1 addresses covered
fmovs %f13, %f12

P2658: !_LD [9] (FP)
ld [%i1 + 512], %f13
! 1 addresses covered

P2659: !_ST [10] (maybe <- 0x408000a7) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i2 + 32 ]

P2660: !_PREFETCH [8] (Int)
prefetch [%i1 + 256], 1

P2661: !_CASX [1] (maybe <- 0x1000059) (Int) (Branch target of P2597)
add %i0, 0, %o5
ldx [%o5], %l6
! move %l6(upper) -> %o0(lower)
srlx %l6, 32, %l7
or %l7, %o0, %o0
! move %l6(lower) -> %o1(upper)
sllx %l6, 32, %o1
mov %l6, %l7
sllx %l4, 32, %l6
add  %l4, 1, %l4
or   %l4, %l6, %l6
casx [%o5], %l7, %l6
! move %l6(upper) -> %o1(lower)
srlx %l6, 32, %o5
or %o5, %o1, %o1
! move %l6(lower) -> %o2(upper)
sllx %l6, 32, %o2
add  %l4, 1, %l4
ba P2662
nop

TARGET2597:
ba RET2597
nop


P2662: !_DWST [11] (maybe <- 0x408000a8) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
std %f20, [%i2 + 64]

P2663: !_LD [13] (FP) (CBR)
ld [%i3 + 64], %f14
! 1 addresses covered

! cbranch
andcc %l0, 1, %g0
be,pn  %xcc, TARGET2663
nop
RET2663:

! lfsr step begin
srlx %l0, 1, %l6
xnor %l6, %l0, %l6
sllx %l6, 63, %l6
or  %l6, %l0, %l0
srlx %l0, 1, %l0


P2664: !_CASX [12] (maybe <- 0x100005b) (Int) (CBR)
add %i3, 0, %o5
ldx [%o5], %l6
! move %l6(upper) -> %o2(lower)
srlx %l6, 32, %l7
or %l7, %o2, %o2
! move %l6(lower) -> %o3(upper)
sllx %l6, 32, %o3
mov  %l6, %l7
sllx %l4, 32, %l6
casx [%o5], %l7, %l6
! move %l6(upper) -> %o3(lower)
srlx %l6, 32, %o5
or %o5, %o3, %o3
! move %l6(lower) -> %o4(upper)
sllx %l6, 32, %o4
add  %l4, 1, %l4

! cbranch
andcc %l0, 1, %g0
be,pt  %xcc, TARGET2664
nop
RET2664:

! lfsr step begin
srlx %l0, 1, %l7
xnor %l7, %l0, %l7
sllx %l7, 63, %l7
or  %l7, %l0, %l0
srlx %l0, 1, %l0


P2665: !_DWST [12] (maybe <- 0x408000a9) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
std %f20, [%i3 + 0]

P2666: !_DWST [9] (maybe <- 0x408000aa) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
std %f20, [%i1 + 512]

P2667: !_ST [2] (maybe <- 0x408000ab) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i0 + 12 ]

P2668: !_LD [12] (FP)
ld [%i3 + 0], %f15
! 1 addresses covered
!---- flushing fp results buffer to %f30 ----
fmovd %f0, %f30
fmovd %f2, %f30
fmovd %f4, %f30
fmovd %f6, %f30
fmovd %f8, %f30
fmovd %f10, %f30
fmovd %f12, %f30
fmovd %f14, %f30

P2669: !_DWST [5] (maybe <- 0x408000ac) (FP) (CBR)
! 0 th moved, current_fp_src=21 
fmovs  %f16, %f21
fadds  %f16, %f17, %f16
std %f20, [%i1 + 72]

! cbranch
andcc %l0, 1, %g0
be,pn  %xcc, TARGET2669
nop
RET2669:

! lfsr step begin
srlx %l0, 1, %o5
xnor %o5, %l0, %o5
sllx %o5, 63, %o5
or  %o5, %l0, %l0
srlx %l0, 1, %l0


P2670: !_DWLD [10] (FP)
ldd [%i2 + 32], %f0
! 1 addresses covered

P2671: !_DWLD [7] (FP)
ldd [%i1 + 80], %f18
! 2 addresses covered
fmovs %f18, %f1
fmovs %f19, %f2

P2672: !_DWST [2] (maybe <- 0x408000ad) (FP)
! 0 th moved, current_fp_src=21 
fmovs  %f16, %f21
fadds  %f16, %f17, %f16
std %f20, [%i0 + 8]

P2673: !_DWST [3] (maybe <- 0x408000ae) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
std %f20, [%i0 + 32]

P2674: !_DWLD [7] (FP)
ldd [%i1 + 80], %f18
! 2 addresses covered
fmovs %f18, %f3
fmovs %f19, %f4

P2675: !_SWAP [3] (maybe <- 0x100005c) (Int)
mov %l4, %l3
swap  [%i0 + 32], %l3
! move %l3(lower) -> %o4(lower)
srl %l3, 0, %l7
or %l7, %o4, %o4
!---- flushing int results buffer----
mov %o0, %l5
mov %o1, %l5
mov %o2, %l5
mov %o3, %l5
mov %o4, %l5
add   %l4, 1, %l4

P2676: !_DWST [7] (maybe <- 0x408000af) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
! 1 th moved, current_fp_src=21 
fmovs  %f16, %f21
fadds  %f16, %f17, %f16
std %f20, [%i1 + 80]

P2677: !_LD [11] (FP)
ld [%i2 + 64], %f5
! 1 addresses covered

P2678: !_DWLD [10] (FP)
ldd [%i2 + 32], %f6
! 1 addresses covered

P2679: !_SWAP [1] (maybe <- 0x100005d) (Int)
mov %l4, %o0
swap  [%i0 + 4], %o0
! move %o0(lower) -> %o0(upper)
sllx %o0, 32, %o0
add   %l4, 1, %l4

P2680: !_ST [8] (maybe <- 0x408000b1) (FP) (Branch target of P2883)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i1 + 256 ]
ba P2681
nop

TARGET2883:
ba RET2883
nop


P2681: !_LD [15] (FP)
ld [%i3 + 192], %f7
! 1 addresses covered

P2682: !_DWST [2] (maybe <- 0x408000b2) (FP)
! 0 th moved, current_fp_src=21 
fmovs  %f16, %f21
fadds  %f16, %f17, %f16
std %f20, [%i0 + 8]

P2683: !_LD [9] (FP)
ld [%i1 + 512], %f8
! 1 addresses covered

P2684: !_DWLD [8] (FP)
ldd [%i1 + 256], %f18
! 1 addresses covered
fmovs %f18, %f9

P2685: !_DWST [14] (maybe <- 0x408000b3) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
std %f20, [%i3 + 128]

P2686: !_CASX [14] (maybe <- 0x100005e) (Int)
add %i3, 128, %l6
ldx [%l6], %o5
! move %o5(upper) -> %o0(lower)
srlx %o5, 32, %l3
or %l3, %o0, %o0
! move %o5(lower) -> %o1(upper)
sllx %o5, 32, %o1
mov  %o5, %l3
sllx %l4, 32, %o5
casx [%l6], %l3, %o5
! move %o5(upper) -> %o1(lower)
srlx %o5, 32, %l6
or %l6, %o1, %o1
! move %o5(lower) -> %o2(upper)
sllx %o5, 32, %o2
add  %l4, 1, %l4

P2687: !_CASX [4] (maybe <- 0x100005f) (Int)
add %i0, 64, %l6
ldx [%l6], %o5
! move %o5(upper) -> %o2(lower)
srlx %o5, 32, %l3
or %l3, %o2, %o2
! move %o5(lower) -> %o3(upper)
sllx %o5, 32, %o3
mov  %o5, %l3
sllx %l4, 32, %o5
casx [%l6], %l3, %o5
! move %o5(upper) -> %o3(lower)
srlx %o5, 32, %l6
or %l6, %o3, %o3
! move %o5(lower) -> %o4(upper)
sllx %o5, 32, %o4
add  %l4, 1, %l4

P2688: !_MEMBAR (Int)
membar #StoreLoad

P2689: !_CAS [0] (maybe <- 0x1000060) (Int)
add %i0, 0, %l6
lduw [%l6], %o5
mov %o5, %l3
! move %l3(lower) -> %o4(lower)
or %l3, %o4, %o4
!---- flushing int results buffer----
mov %o0, %l5
mov %o1, %l5
mov %o2, %l5
mov %o3, %l5
mov %o4, %l5
mov %l4, %o0
cas [%l6], %l3, %o0
! move %o0(lower) -> %o0(upper)
sllx %o0, 32, %o0
add   %l4, 1, %l4

P2690: !_ST [9] (maybe <- 0x408000b4) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i1 + 512 ]

P2691: !_SWAP [11] (maybe <- 0x1000061) (Int)
mov %l4, %l6
swap  [%i2 + 64], %l6
! move %l6(lower) -> %o0(lower)
srl %l6, 0, %o5
or %o5, %o0, %o0
add   %l4, 1, %l4

P2692: !_PREFETCH [3] (Int) (CBR)
prefetch [%i0 + 32], 1

! cbranch
andcc %l0, 1, %g0
be,pt  %xcc, TARGET2692
nop
RET2692:

! lfsr step begin
srlx %l0, 1, %l7
xnor %l7, %l0, %l7
sllx %l7, 63, %l7
or  %l7, %l0, %l0
srlx %l0, 1, %l0


P2693: !_PREFETCH [7] (Int) (LE)
wr %g0, 0x88, %asi
prefetcha [%i1 + 84] %asi, 1

P2694: !_DWLD [1] (FP)
ldd [%i0 + 0], %f10
! 2 addresses covered

P2695: !_DWST [2] (maybe <- 0x408000b5) (FP)
! 0 th moved, current_fp_src=21 
fmovs  %f16, %f21
fadds  %f16, %f17, %f16
std %f20, [%i0 + 8]

P2696: !_LD [4] (FP)
ld [%i0 + 64], %f12
! 1 addresses covered

P2697: !_REPLACEMENT [9] (Int)
sethi %hi(0x200), %l7
or %l7, %lo(0x200),  %l7
sethi %hi(0x10000), %o5
or %o5, %lo(0x10000),  %o5
add %i3, %l7, %l7
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]

P2698: !_REPLACEMENT [14] (Int)
sethi %hi(0x80), %l6
or %l6, %lo(0x80),  %l6
sethi %hi(0x10000), %l7
or %l7, %lo(0x10000),  %l7
add %i3, %l6, %l6
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]

P2699: !_DWST [1] (maybe <- 0x408000b6) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
! 1 th moved, current_fp_src=21 
fmovs  %f16, %f21
fadds  %f16, %f17, %f16
std %f20, [%i0 + 0]

P2700: !_LD [15] (FP)
ld [%i3 + 192], %f13
! 1 addresses covered

P2701: !_REPLACEMENT [1] (Int)
sethi %hi(0x4), %o5
or %o5, %lo(0x4),  %o5
sethi %hi(0x10000), %l3
or %l3, %lo(0x10000),  %l3
add %i3, %o5, %o5
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]

P2702: !_MEMBAR (Int)
membar #StoreLoad

P2703: !_ST [8] (maybe <- 0x408000b8) (FP) (CBR)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i1 + 256 ]

! cbranch
andcc %l0, 1, %g0
be,pn  %xcc, TARGET2703
nop
RET2703:

! lfsr step begin
srlx %l0, 1, %l6
xnor %l6, %l0, %l6
sllx %l6, 63, %l6
or  %l6, %l0, %l0
srlx %l0, 1, %l0


P2704: !_ST [4] (maybe <- 0x408000b9) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i0 + 64 ]

P2705: !_PREFETCH [14] (Int)
prefetch [%i3 + 128], 1

P2706: !_PREFETCH [15] (Int)
prefetch [%i3 + 192], 1

P2707: !_PREFETCH [1] (Int)
prefetch [%i0 + 4], 1

P2708: !_MEMBAR (Int)
membar #StoreLoad

P2709: !_CASX [15] (maybe <- 0x1000062) (Int) (LE)
! Change single-word-level endianess (big endian <-> little endian) 
sethi %hi(0xff00ff00), %l7
or %l7, %lo(0xff00ff00), %l7
and %l4, %l7, %l6
srl %l6, 8, %l6
sll %l4, 8, %o5
and %o5, %l7, %o5
or %o5, %l6, %o5
srl %o5, 16, %l6
sll %o5, 16, %o5
srl %o5, 0, %o5
or %o5, %l6, %o5
wr %g0, 0x88, %asi
add %i3, 192, %l7
ldxa [%l7] %asi, %l3
! move %l3(lower) -> %o1(upper)
sllx %l3, 32, %o1
! move %l3(upper) -> %o1(lower)
srlx %l3, 32, %l6
or %l6, %o1, %o1
mov  %l3, %l6
mov  %o5, %l3
casxa [%l7] %asi, %l6, %l3
! move %l3(lower) -> %o2(upper)
sllx %l3, 32, %o2
! move %l3(upper) -> %o2(lower)
srlx %l3, 32, %l7
or %l7, %o2, %o2
add  %l4, 1, %l4

P2710: !_DWLD [11] (FP)
ldd [%i2 + 64], %f14
! 1 addresses covered

P2711: !_DWST [0] (maybe <- 0x408000ba) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
! 1 th moved, current_fp_src=21 
fmovs  %f16, %f21
fadds  %f16, %f17, %f16
std %f20, [%i0 + 0]

P2712: !_PREFETCH [10] (Int)
prefetch [%i2 + 32], 1

P2713: !_REPLACEMENT [4] (Int)
sethi %hi(0x40), %l3
or %l3, %lo(0x40),  %l3
sethi %hi(0x10000), %l6
or %l6, %lo(0x10000),  %l6
add %i3, %l3, %l3
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]

P2714: !_CAS [10] (maybe <- 0x1000063) (Int)
add %i2, 32, %l3
lduw [%l3], %o3
mov %o3, %o5
! move %o5(lower) -> %o3(upper)
sllx %o5, 32, %o3
mov %l4, %l7
cas [%l3], %o5, %l7
! move %l7(lower) -> %o3(lower)
srl %l7, 0, %l3
or %l3, %o3, %o3
add   %l4, 1, %l4

P2715: !_ST [15] (maybe <- 0x408000bc) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i3 + 192 ]

P2716: !_REPLACEMENT [15] (Int)
sethi %hi(0xc0), %l7
or %l7, %lo(0xc0),  %l7
sethi %hi(0x10000), %o5
or %o5, %lo(0x10000),  %o5
add %i3, %l7, %l7
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]

P2717: !_CAS [0] (maybe <- 0x1000064) (Int)
add %i0, 0, %l7
lduw [%l7], %o4
mov %o4, %l6
! move %l6(lower) -> %o4(upper)
sllx %l6, 32, %o4
mov %l4, %l3
cas [%l7], %l6, %l3
! move %l3(lower) -> %o4(lower)
srl %l3, 0, %l7
or %l7, %o4, %o4
!---- flushing int results buffer----
mov %o0, %l5
mov %o1, %l5
mov %o2, %l5
mov %o3, %l5
mov %o4, %l5
add   %l4, 1, %l4

P2718: !_NOP (Int)
nop

P2719: !_DWST [1] (maybe <- 0x408000bd) (FP) (CBR)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
! 1 th moved, current_fp_src=21 
fmovs  %f16, %f21
fadds  %f16, %f17, %f16
std %f20, [%i0 + 0]

! cbranch
andcc %l0, 1, %g0
be,pt  %xcc, TARGET2719
nop
RET2719:

! lfsr step begin
srlx %l0, 1, %l3
xnor %l3, %l0, %l3
sllx %l3, 63, %l3
or  %l3, %l0, %l0
srlx %l0, 1, %l0


P2720: !_PREFETCH [7] (Int)
prefetch [%i1 + 84], 1

P2721: !_DWLD [14] (FP)
ldd [%i3 + 128], %f18
! 1 addresses covered
fmovs %f18, %f15
!---- flushing fp results buffer to %f30 ----
fmovd %f0, %f30
fmovd %f2, %f30
fmovd %f4, %f30
fmovd %f6, %f30
fmovd %f8, %f30
fmovd %f10, %f30
fmovd %f12, %f30
fmovd %f14, %f30

P2722: !_DWLD [13] (FP)
ldd [%i3 + 64], %f0
! 1 addresses covered

P2723: !_CAS [6] (maybe <- 0x1000065) (Int)
add %i1, 80, %l7
lduw [%l7], %o0
mov %o0, %l6
! move %l6(lower) -> %o0(upper)
sllx %l6, 32, %o0
mov %l4, %l3
cas [%l7], %l6, %l3
! move %l3(lower) -> %o0(lower)
srl %l3, 0, %l7
or %l7, %o0, %o0
add   %l4, 1, %l4

P2724: !_DWST [0] (maybe <- 0x408000bf) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
! 1 th moved, current_fp_src=21 
fmovs  %f16, %f21
fadds  %f16, %f17, %f16
std %f20, [%i0 + 0]

P2725: !_SWAP [0] (maybe <- 0x1000066) (Int)
mov %l4, %o1
swap  [%i0 + 0], %o1
! move %o1(lower) -> %o1(upper)
sllx %o1, 32, %o1
add   %l4, 1, %l4

P2726: !_DWLD [1] (FP)
ldd [%i0 + 0], %f18
! 2 addresses covered
fmovs %f18, %f1
fmovs %f19, %f2

P2727: !_DWLD [2] (FP)
ldd [%i0 + 8], %f18
! 1 addresses covered
fmovs %f19, %f3

P2728: !_LD [2] (FP)
ld [%i0 + 12], %f4
! 1 addresses covered

P2729: !_REPLACEMENT [11] (Int)
sethi %hi(0x40), %o5
or %o5, %lo(0x40),  %o5
sethi %hi(0x10000), %l3
or %l3, %lo(0x10000),  %l3
add %i3, %o5, %o5
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]

P2730: !_CAS [5] (maybe <- 0x1000067) (Int) (Branch target of P2559)
add %i1, 76, %o5
lduw [%o5], %l6
mov %l6, %l7
! move %l7(lower) -> %o1(lower)
or %l7, %o1, %o1
mov %l4, %o2
cas [%o5], %l7, %o2
! move %o2(lower) -> %o2(upper)
sllx %o2, 32, %o2
add   %l4, 1, %l4
ba P2731
nop

TARGET2559:
ba RET2559
nop


P2731: !_REPLACEMENT [0] (Int)
sethi %hi(0x0), %l7
or %l7, %lo(0x0),  %l7
sethi %hi(0x10000), %o5
or %o5, %lo(0x10000),  %o5
add %i3, %l7, %l7
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]

P2732: !_ST [7] (maybe <- 0x408000c1) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i1 + 84 ]

P2733: !_PREFETCH [14] (Int)
prefetch [%i3 + 128], 1

P2734: !_PREFETCH [4] (Int)
prefetch [%i0 + 64], 1

P2735: !_PREFETCH [1] (Int)
prefetch [%i0 + 4], 1

P2736: !_DWST [11] (maybe <- 0x408000c2) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
std %f20, [%i2 + 64]

P2737: !_ST [11] (maybe <- 0x408000c3) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i2 + 64 ]

P2738: !_ST [11] (maybe <- 0x408000c4) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i2 + 64 ]

P2739: !_CAS [2] (maybe <- 0x1000068) (Int)
add %i0, 12, %l7
lduw [%l7], %l3
mov %l3, %l6
! move %l6(lower) -> %o2(lower)
or %l6, %o2, %o2
mov %l4, %o3
cas [%l7], %l6, %o3
! move %o3(lower) -> %o3(upper)
sllx %o3, 32, %o3
add   %l4, 1, %l4

P2740: !_DWLD [0] (FP)
ldd [%i0 + 0], %f18
! 2 addresses covered
fmovs %f18, %f5
fmovs %f19, %f6

P2741: !_CASX [5] (maybe <- 0x1000069) (Int)
add %i1, 72, %l7
ldx [%l7], %l3
! move %l3(upper) -> %o3(lower)
srlx %l3, 32, %l6
or %l6, %o3, %o3
! move %l3(lower) -> %o4(upper)
sllx %l3, 32, %o4
mov  %l3, %l6
mov %l4, %l3
casx [%l7], %l6, %l3
! move %l3(upper) -> %o4(lower)
srlx %l3, 32, %l7
or %l7, %o4, %o4
!---- flushing int results buffer----
mov %o0, %l5
mov %o1, %l5
mov %o2, %l5
mov %o3, %l5
mov %o4, %l5
! move %l3(lower) -> %o0(upper)
sllx %l3, 32, %o0
add  %l4, 1, %l4

P2742: !_PREFETCH [15] (Int)
prefetch [%i3 + 192], 1

P2743: !_LD [13] (FP)
ld [%i3 + 64], %f7
! 1 addresses covered

P2744: !_CAS [7] (maybe <- 0x100006a) (Int)
add %i1, 84, %l7
lduw [%l7], %l3
mov %l3, %l6
! move %l6(lower) -> %o0(lower)
or %l6, %o0, %o0
mov %l4, %o1
cas [%l7], %l6, %o1
! move %o1(lower) -> %o1(upper)
sllx %o1, 32, %o1
add   %l4, 1, %l4

P2745: !_ST [4] (maybe <- 0x408000c5) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i0 + 64 ]

P2746: !_ST [12] (maybe <- 0x408000c6) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i3 + 0 ]

P2747: !_PREFETCH [14] (Int)
prefetch [%i3 + 128], 1

P2748: !_DWLD [8] (FP)
ldd [%i1 + 256], %f8
! 1 addresses covered

P2749: !_DWST [1] (maybe <- 0x408000c7) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
! 1 th moved, current_fp_src=21 
fmovs  %f16, %f21
fadds  %f16, %f17, %f16
std %f20, [%i0 + 0]

P2750: !_REPLACEMENT [11] (Int)
sethi %hi(0x40), %l7
or %l7, %lo(0x40),  %l7
sethi %hi(0x10000), %o5
or %o5, %lo(0x10000),  %o5
add %i3, %l7, %l7
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]

P2751: !_DWST [11] (maybe <- 0x408000c9) (FP) (CBR)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
std %f20, [%i2 + 64]

! cbranch
andcc %l0, 1, %g0
be,pn  %xcc, TARGET2751
nop
RET2751:

! lfsr step begin
srlx %l0, 1, %l3
xnor %l3, %l0, %l3
sllx %l3, 63, %l3
or  %l3, %l0, %l0
srlx %l0, 1, %l0


P2752: !_LD [7] (FP) (Branch target of P2299)
ld [%i1 + 84], %f9
! 1 addresses covered
ba P2753
nop

TARGET2299:
ba RET2299
nop


P2753: !_ST [2] (maybe <- 0x408000ca) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i0 + 12 ]

P2754: !_CASX [2] (maybe <- 0x100006b) (Int)
add %i0, 8, %l6
ldx [%l6], %o5
! move %o5(upper) -> %o1(lower)
srlx %o5, 32, %l3
or %l3, %o1, %o1
! move %o5(lower) -> %o2(upper)
sllx %o5, 32, %o2
mov  %o5, %l3
mov %l4, %o5
casx [%l6], %l3, %o5
! move %o5(upper) -> %o2(lower)
srlx %o5, 32, %l6
or %l6, %o2, %o2
! move %o5(lower) -> %o3(upper)
sllx %o5, 32, %o3
add  %l4, 1, %l4

P2755: !_PREFETCH [8] (Int)
prefetch [%i1 + 256], 1

P2756: !_LD [3] (FP)
ld [%i0 + 32], %f10
! 1 addresses covered

P2757: !_CASX [14] (maybe <- 0x100006c) (Int)
add %i3, 128, %l6
ldx [%l6], %o5
! move %o5(upper) -> %o3(lower)
srlx %o5, 32, %l3
or %l3, %o3, %o3
! move %o5(lower) -> %o4(upper)
sllx %o5, 32, %o4
mov  %o5, %l3
sllx %l4, 32, %o5
casx [%l6], %l3, %o5
! move %o5(upper) -> %o4(lower)
srlx %o5, 32, %l6
or %l6, %o4, %o4
!---- flushing int results buffer----
mov %o0, %l5
mov %o1, %l5
mov %o2, %l5
mov %o3, %l5
mov %o4, %l5
! move %o5(lower) -> %o0(upper)
sllx %o5, 32, %o0
add  %l4, 1, %l4

P2758: !_DWST [12] (maybe <- 0x408000cb) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
std %f20, [%i3 + 0]

P2759: !_DWLD [12] (FP)
ldd [%i3 + 0], %f18
! 1 addresses covered
fmovs %f18, %f11

P2760: !_DWLD [6] (FP)
ldd [%i1 + 80], %f12
! 2 addresses covered

P2761: !_ST [15] (maybe <- 0x408000cc) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i3 + 192 ]

P2762: !_PREFETCH [11] (Int)
prefetch [%i2 + 64], 1

P2763: !_LD [6] (FP)
ld [%i1 + 80], %f14
! 1 addresses covered

P2764: !_LD [11] (FP)
ld [%i2 + 64], %f15
! 1 addresses covered
!---- flushing fp results buffer to %f30 ----
fmovd %f0, %f30
fmovd %f2, %f30
fmovd %f4, %f30
fmovd %f6, %f30
fmovd %f8, %f30
fmovd %f10, %f30
fmovd %f12, %f30
fmovd %f14, %f30

P2765: !_PREFETCH [10] (Int)
prefetch [%i2 + 32], 1

P2766: !_ST [0] (maybe <- 0x408000cd) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i0 + 0 ]

P2767: !_DWST [2] (maybe <- 0x408000ce) (FP)
! 0 th moved, current_fp_src=21 
fmovs  %f16, %f21
fadds  %f16, %f17, %f16
std %f20, [%i0 + 8]

P2768: !_DWLD [11] (FP)
ldd [%i2 + 64], %f0
! 1 addresses covered

P2769: !_PREFETCH [14] (Int)
prefetch [%i3 + 128], 1

P2770: !_DWLD [13] (FP)
ldd [%i3 + 64], %f18
! 1 addresses covered
fmovs %f18, %f1

P2771: !_CASX [12] (maybe <- 0x100006d) (Int)
add %i3, 0, %l6
ldx [%l6], %o5
! move %o5(upper) -> %o0(lower)
srlx %o5, 32, %l3
or %l3, %o0, %o0
! move %o5(lower) -> %o1(upper)
sllx %o5, 32, %o1
mov  %o5, %l3
sllx %l4, 32, %o5
casx [%l6], %l3, %o5
! move %o5(upper) -> %o1(lower)
srlx %o5, 32, %l6
or %l6, %o1, %o1
! move %o5(lower) -> %o2(upper)
sllx %o5, 32, %o2
add  %l4, 1, %l4

P2772: !_PREFETCH [11] (Int)
prefetch [%i2 + 64], 1

P2773: !_ST [15] (maybe <- 0x408000cf) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i3 + 192 ]

P2774: !_DWST [2] (maybe <- 0x408000d0) (FP)
! 0 th moved, current_fp_src=21 
fmovs  %f16, %f21
fadds  %f16, %f17, %f16
std %f20, [%i0 + 8]

P2775: !_REPLACEMENT [1] (Int)
sethi %hi(0x4), %l7
or %l7, %lo(0x4),  %l7
sethi %hi(0x10000), %o5
or %o5, %lo(0x10000),  %o5
add %i3, %l7, %l7
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]

P2776: !_LD [4] (FP) (CBR)
ld [%i0 + 64], %f2
! 1 addresses covered

! cbranch
andcc %l0, 1, %g0
be,pt  %xcc, TARGET2776
nop
RET2776:

! lfsr step begin
srlx %l0, 1, %l6
xnor %l6, %l0, %l6
sllx %l6, 63, %l6
or  %l6, %l0, %l0
srlx %l0, 1, %l0


P2777: !_REPLACEMENT [6] (Int)
sethi %hi(0x50), %l7
or %l7, %lo(0x50),  %l7
sethi %hi(0x10000), %o5
or %o5, %lo(0x10000),  %o5
add %i3, %l7, %l7
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]

P2778: !_ST [3] (maybe <- 0x408000d1) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i0 + 32 ]

P2779: !_DWLD [10] (FP)
ldd [%i2 + 32], %f18
! 1 addresses covered
fmovs %f18, %f3

P2780: !_ST [15] (maybe <- 0x408000d2) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i3 + 192 ]

P2781: !_CAS [12] (maybe <- 0x100006e) (Int)
add %i3, 0, %l3
lduw [%l3], %l7
mov %l7, %o5
! move %o5(lower) -> %o2(lower)
or %o5, %o2, %o2
mov %l4, %o3
cas [%l3], %o5, %o3
! move %o3(lower) -> %o3(upper)
sllx %o3, 32, %o3
add   %l4, 1, %l4

P2782: !_ST [13] (maybe <- 0x408000d3) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i3 + 64 ]

P2783: !_CASX [15] (maybe <- 0x100006f) (Int)
add %i3, 192, %o5
ldx [%o5], %l6
! move %l6(upper) -> %o3(lower)
srlx %l6, 32, %l7
or %l7, %o3, %o3
! move %l6(lower) -> %o4(upper)
sllx %l6, 32, %o4
mov  %l6, %l7
sllx %l4, 32, %l6
casx [%o5], %l7, %l6
! move %l6(upper) -> %o4(lower)
srlx %l6, 32, %o5
or %o5, %o4, %o4
!---- flushing int results buffer----
mov %o0, %l5
mov %o1, %l5
mov %o2, %l5
mov %o3, %l5
mov %o4, %l5
! move %l6(lower) -> %o0(upper)
sllx %l6, 32, %o0
add  %l4, 1, %l4

P2784: !_DWLD [15] (FP)
ldd [%i3 + 192], %f4
! 1 addresses covered

P2785: !_ST [10] (maybe <- 0x408000d4) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i2 + 32 ]

P2786: !_PREFETCH [10] (Int)
prefetch [%i2 + 32], 1

P2787: !_ST [2] (maybe <- 0x408000d5) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i0 + 12 ]

P2788: !_CASX [1] (maybe <- 0x1000070) (Int)
add %i0, 0, %l6
ldx [%l6], %o5
! move %o5(upper) -> %o0(lower)
srlx %o5, 32, %l3
or %l3, %o0, %o0
! move %o5(lower) -> %o1(upper)
sllx %o5, 32, %o1
mov %o5, %l3
sllx %l4, 32, %o5
add  %l4, 1, %l4
or   %l4, %o5, %o5
casx [%l6], %l3, %o5
! move %o5(upper) -> %o1(lower)
srlx %o5, 32, %l6
or %l6, %o1, %o1
! move %o5(lower) -> %o2(upper)
sllx %o5, 32, %o2
add  %l4, 1, %l4

P2789: !_ST [2] (maybe <- 0x408000d6) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i0 + 12 ]

P2790: !_DWST [5] (maybe <- 0x408000d7) (FP)
! 0 th moved, current_fp_src=21 
fmovs  %f16, %f21
fadds  %f16, %f17, %f16
std %f20, [%i1 + 72]

P2791: !_PREFETCH [11] (Int)
prefetch [%i2 + 64], 1

P2792: !_ST [9] (maybe <- 0x408000d8) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i1 + 512 ]

P2793: !_REPLACEMENT [9] (Int)
sethi %hi(0x200), %l6
or %l6, %lo(0x200),  %l6
sethi %hi(0x10000), %l7
or %l7, %lo(0x10000),  %l7
add %i3, %l6, %l6
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]

P2794: !_LD [13] (FP)
ld [%i3 + 64], %f5
! 1 addresses covered

P2795: !_CASX [5] (maybe <- 0x1000072) (Int)
add %i1, 72, %l6
ldx [%l6], %o5
! move %o5(upper) -> %o2(lower)
srlx %o5, 32, %l3
or %l3, %o2, %o2
! move %o5(lower) -> %o3(upper)
sllx %o5, 32, %o3
mov  %o5, %l3
mov %l4, %o5
casx [%l6], %l3, %o5
! move %o5(upper) -> %o3(lower)
srlx %o5, 32, %l6
or %l6, %o3, %o3
! move %o5(lower) -> %o4(upper)
sllx %o5, 32, %o4
add  %l4, 1, %l4

P2796: !_REPLACEMENT [1] (Int)
sethi %hi(0x4), %l3
or %l3, %lo(0x4),  %l3
sethi %hi(0x10000), %l6
or %l6, %lo(0x10000),  %l6
add %i3, %l3, %l3
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]

P2797: !_LD [10] (FP)
ld [%i2 + 32], %f6
! 1 addresses covered

P2798: !_MEMBAR (Int)
membar #StoreLoad

P2799: !_PREFETCH [11] (Int)
prefetch [%i2 + 64], 1

P2800: !_LD [10] (FP)
ld [%i2 + 32], %f7
! 1 addresses covered

P2801: !_LD [15] (FP)
ld [%i3 + 192], %f8
! 1 addresses covered

P2802: !_ST [5] (maybe <- 0x408000d9) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i1 + 76 ]

P2803: !_ST [5] (maybe <- 0x408000da) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i1 + 76 ]

P2804: !_ST [9] (maybe <- 0x408000db) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i1 + 512 ]

P2805: !_LD [4] (FP)
ld [%i0 + 64], %f9
! 1 addresses covered

P2806: !_ST [7] (maybe <- 0x408000dc) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i1 + 84 ]

P2807: !_DWST [6] (maybe <- 0x408000dd) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
! 1 th moved, current_fp_src=21 
fmovs  %f16, %f21
fadds  %f16, %f17, %f16
std %f20, [%i1 + 80]

P2808: !_REPLACEMENT [4] (Int)
sethi %hi(0x40), %l7
or %l7, %lo(0x40),  %l7
sethi %hi(0x10000), %o5
or %o5, %lo(0x10000),  %o5
add %i3, %l7, %l7
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]

P2809: !_DWST [10] (maybe <- 0x408000df) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
std %f20, [%i2 + 32]

P2810: !_PREFETCH [3] (Int) (Branch target of P2751)
prefetch [%i0 + 32], 1
ba P2811
nop

TARGET2751:
ba RET2751
nop


P2811: !_LD [0] (FP)
ld [%i0 + 0], %f10
! 1 addresses covered

P2812: !_ST [7] (maybe <- 0x408000e0) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i1 + 84 ]

P2813: !_DWLD [10] (FP)
ldd [%i2 + 32], %f18
! 1 addresses covered
fmovs %f18, %f11

P2814: !_REPLACEMENT [15] (Int)
sethi %hi(0xc0), %o5
or %o5, %lo(0xc0),  %o5
sethi %hi(0x10000), %l3
or %l3, %lo(0x10000),  %l3
add %i3, %o5, %o5
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]

P2815: !_MEMBAR (Int)
membar #StoreLoad

P2816: !_LD [8] (FP)
ld [%i1 + 256], %f12
! 1 addresses covered

P2817: !_ST [5] (maybe <- 0x408000e1) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i1 + 76 ]

P2818: !_CASX [13] (maybe <- 0x1000073) (Int)
add %i3, 64, %l7
ldx [%l7], %l3
! move %l3(upper) -> %o4(lower)
srlx %l3, 32, %l6
or %l6, %o4, %o4
!---- flushing int results buffer----
mov %o0, %l5
mov %o1, %l5
mov %o2, %l5
mov %o3, %l5
mov %o4, %l5
! move %l3(lower) -> %o0(upper)
sllx %l3, 32, %o0
mov  %l3, %l6
sllx %l4, 32, %l3
casx [%l7], %l6, %l3
! move %l3(upper) -> %o0(lower)
srlx %l3, 32, %l7
or %l7, %o0, %o0
! move %l3(lower) -> %o1(upper)
sllx %l3, 32, %o1
add  %l4, 1, %l4

P2819: !_REPLACEMENT [9] (Int)
sethi %hi(0x200), %l6
or %l6, %lo(0x200),  %l6
sethi %hi(0x10000), %l7
or %l7, %lo(0x10000),  %l7
add %i3, %l6, %l6
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]

P2820: !_DWST [6] (maybe <- 0x408000e2) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
! 1 th moved, current_fp_src=21 
fmovs  %f16, %f21
fadds  %f16, %f17, %f16
std %f20, [%i1 + 80]

P2821: !_DWLD [11] (FP) (CBR)
ldd [%i2 + 64], %f18
! 1 addresses covered
fmovs %f18, %f13

! cbranch
andcc %l0, 1, %g0
be,pn  %xcc, TARGET2821
nop
RET2821:

! lfsr step begin
srlx %l0, 1, %o5
xnor %o5, %l0, %o5
sllx %o5, 63, %o5
or  %o5, %l0, %l0
srlx %l0, 1, %l0


P2822: !_CAS [1] (maybe <- 0x1000074) (Int)
add %i0, 4, %l6
lduw [%l6], %o5
mov %o5, %l3
! move %l3(lower) -> %o1(lower)
or %l3, %o1, %o1
mov %l4, %o2
cas [%l6], %l3, %o2
! move %o2(lower) -> %o2(upper)
sllx %o2, 32, %o2
add   %l4, 1, %l4

P2823: !_DWST [2] (maybe <- 0x408000e4) (FP)
! 0 th moved, current_fp_src=21 
fmovs  %f16, %f21
fadds  %f16, %f17, %f16
std %f20, [%i0 + 8]

P2824: !_DWLD [4] (FP) (Branch target of P2571)
ldd [%i0 + 64], %f14
! 1 addresses covered
ba P2825
nop

TARGET2571:
ba RET2571
nop


P2825: !_DWLD [7] (FP)
ldd [%i1 + 80], %f18
! 2 addresses covered
fmovs %f18, %f15
!---- flushing fp results buffer to %f30 ----
fmovd %f0, %f30
fmovd %f2, %f30
fmovd %f4, %f30
fmovd %f6, %f30
fmovd %f8, %f30
fmovd %f10, %f30
fmovd %f12, %f30
fmovd %f14, %f30
fmovs %f19, %f0

P2826: !_ST [14] (maybe <- 0x408000e5) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i3 + 128 ]

P2827: !_REPLACEMENT [10] (Int)
sethi %hi(0x20), %l7
or %l7, %lo(0x20),  %l7
sethi %hi(0x10000), %o5
or %o5, %lo(0x10000),  %o5
add %i3, %l7, %l7
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]

P2828: !_REPLACEMENT [13] (Int)
sethi %hi(0x40), %l6
or %l6, %lo(0x40),  %l6
sethi %hi(0x10000), %l7
or %l7, %lo(0x10000),  %l7
add %i3, %l6, %l6
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]

P2829: !_DWLD [15] (FP) (Branch target of P2897)
ldd [%i3 + 192], %f18
! 1 addresses covered
fmovs %f18, %f1
ba P2830
nop

TARGET2897:
ba RET2897
nop


P2830: !_REPLACEMENT [14] (Int)
sethi %hi(0x80), %l3
or %l3, %lo(0x80),  %l3
sethi %hi(0x10000), %l6
or %l6, %lo(0x10000),  %l6
add %i3, %l3, %l3
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]

P2831: !_REPLACEMENT [1] (Int) (CBR)
sethi %hi(0x4), %o5
or %o5, %lo(0x4),  %o5
sethi %hi(0x10000), %l3
or %l3, %lo(0x10000),  %l3
add %i3, %o5, %o5
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]

! cbranch
andcc %l0, 1, %g0
be,pt  %xcc, TARGET2831
nop
RET2831:

! lfsr step begin
srlx %l0, 1, %l7
xnor %l7, %l0, %l7
sllx %l7, 63, %l7
or  %l7, %l0, %l0
srlx %l0, 1, %l0


P2832: !_LD [10] (FP)
ld [%i2 + 32], %f2
! 1 addresses covered

P2833: !_PREFETCH [0] (Int)
prefetch [%i0 + 0], 1

P2834: !_DWST [7] (maybe <- 0x408000e6) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
! 1 th moved, current_fp_src=21 
fmovs  %f16, %f21
fadds  %f16, %f17, %f16
std %f20, [%i1 + 80]

P2835: !_LD [1] (FP)
ld [%i0 + 4], %f3
! 1 addresses covered

P2836: !_LD [13] (FP) (CBR)
ld [%i3 + 64], %f4
! 1 addresses covered

! cbranch
andcc %l0, 1, %g0
be,pt  %xcc, TARGET2836
nop
RET2836:

! lfsr step begin
srlx %l0, 1, %l7
xnor %l7, %l0, %l7
sllx %l7, 63, %l7
or  %l7, %l0, %l0
srlx %l0, 1, %l0


P2837: !_LD [10] (FP)
ld [%i2 + 32], %f5
! 1 addresses covered

P2838: !_LD [10] (FP)
ld [%i2 + 32], %f6
! 1 addresses covered

P2839: !_DWST [7] (maybe <- 0x408000e8) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
! 1 th moved, current_fp_src=21 
fmovs  %f16, %f21
fadds  %f16, %f17, %f16
std %f20, [%i1 + 80]

P2840: !_DWLD [9] (FP)
ldd [%i1 + 512], %f18
! 1 addresses covered
fmovs %f18, %f7

P2841: !_REPLACEMENT [2] (Int)
sethi %hi(0xc), %l7
or %l7, %lo(0xc),  %l7
sethi %hi(0x10000), %o5
or %o5, %lo(0x10000),  %o5
add %i3, %l7, %l7
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]

P2842: !_DWLD [15] (FP) (Branch target of P2269)
ldd [%i3 + 192], %f8
! 1 addresses covered
ba P2843
nop

TARGET2269:
ba RET2269
nop


P2843: !_DWLD [13] (FP)
ldd [%i3 + 64], %f18
! 1 addresses covered
fmovs %f18, %f9

P2844: !_LD [4] (FP)
ld [%i0 + 64], %f10
! 1 addresses covered

P2845: !_PREFETCH [8] (Int)
prefetch [%i1 + 256], 1

P2846: !_REPLACEMENT [1] (Int)
sethi %hi(0x4), %l6
or %l6, %lo(0x4),  %l6
sethi %hi(0x10000), %l7
or %l7, %lo(0x10000),  %l7
add %i3, %l6, %l6
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]

P2847: !_CASX [8] (maybe <- 0x1000075) (Int)
add %i1, 256, %l6
ldx [%l6], %o5
! move %o5(upper) -> %o2(lower)
srlx %o5, 32, %l3
or %l3, %o2, %o2
! move %o5(lower) -> %o3(upper)
sllx %o5, 32, %o3
mov  %o5, %l3
sllx %l4, 32, %o5
casx [%l6], %l3, %o5
! move %o5(upper) -> %o3(lower)
srlx %o5, 32, %l6
or %l6, %o3, %o3
! move %o5(lower) -> %o4(upper)
sllx %o5, 32, %o4
add  %l4, 1, %l4

P2848: !_DWST [4] (maybe <- 0x408000ea) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
std %f20, [%i0 + 64]

P2849: !_DWLD [14] (FP)
ldd [%i3 + 128], %f18
! 1 addresses covered
fmovs %f18, %f11

P2850: !_DWST [13] (maybe <- 0x408000eb) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
std %f20, [%i3 + 64]

P2851: !_NOP (Int)
nop

P2852: !_NOP (Int)
nop

P2853: !_LD [6] (FP)
ld [%i1 + 80], %f12
! 1 addresses covered

P2854: !_LD [8] (FP)
ld [%i1 + 256], %f13
! 1 addresses covered

P2855: !_PREFETCH [10] (Int)
prefetch [%i2 + 32], 1

P2856: !_CAS [7] (maybe <- 0x1000076) (Int)
add %i1, 84, %o5
lduw [%o5], %l6
mov %l6, %l7
! move %l7(lower) -> %o4(lower)
or %l7, %o4, %o4
!---- flushing int results buffer----
mov %o0, %l5
mov %o1, %l5
mov %o2, %l5
mov %o3, %l5
mov %o4, %l5
mov %l4, %o0
cas [%o5], %l7, %o0
! move %o0(lower) -> %o0(upper)
sllx %o0, 32, %o0
add   %l4, 1, %l4

P2857: !_MEMBAR (Int)
membar #StoreLoad

P2858: !_DWST [5] (maybe <- 0x408000ec) (FP)
! 0 th moved, current_fp_src=21 
fmovs  %f16, %f21
fadds  %f16, %f17, %f16
std %f20, [%i1 + 72]

P2859: !_LD [6] (FP)
ld [%i1 + 80], %f14
! 1 addresses covered

P2860: !_REPLACEMENT [3] (Int)
sethi %hi(0x20), %l6
or %l6, %lo(0x20),  %l6
sethi %hi(0x10000), %l7
or %l7, %lo(0x10000),  %l7
add %i3, %l6, %l6
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]

P2861: !_SWAP [0] (maybe <- 0x1000077) (Int)
mov %l4, %l7
swap  [%i0 + 0], %l7
! move %l7(lower) -> %o0(lower)
srl %l7, 0, %l3
or %l3, %o0, %o0
add   %l4, 1, %l4

P2862: !_DWLD [13] (FP)
ldd [%i3 + 64], %f18
! 1 addresses covered
fmovs %f18, %f15
!---- flushing fp results buffer to %f30 ----
fmovd %f0, %f30
fmovd %f2, %f30
fmovd %f4, %f30
fmovd %f6, %f30
fmovd %f8, %f30
fmovd %f10, %f30
fmovd %f12, %f30
fmovd %f14, %f30

P2863: !_DWST [2] (maybe <- 0x408000ed) (FP)
! 0 th moved, current_fp_src=21 
fmovs  %f16, %f21
fadds  %f16, %f17, %f16
std %f20, [%i0 + 8]

P2864: !_PREFETCH [3] (Int)
prefetch [%i0 + 32], 1

P2865: !_LD [7] (FP)
ld [%i1 + 84], %f0
! 1 addresses covered

P2866: !_ST [0] (maybe <- 0x408000ee) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i0 + 0 ]

P2867: !_DWLD [15] (FP)
ldd [%i3 + 192], %f18
! 1 addresses covered
fmovs %f18, %f1

P2868: !_MEMBAR (Int)
membar #StoreLoad

P2869: !_DWLD [11] (FP)
ldd [%i2 + 64], %f2
! 1 addresses covered

P2870: !_REPLACEMENT [0] (Int)
sethi %hi(0x0), %l6
or %l6, %lo(0x0),  %l6
sethi %hi(0x10000), %l7
or %l7, %lo(0x10000),  %l7
add %i3, %l6, %l6
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]

P2871: !_DWLD [13] (FP)
ldd [%i3 + 64], %f18
! 1 addresses covered
fmovs %f18, %f3

P2872: !_SWAP [12] (maybe <- 0x1000078) (Int)
mov %l4, %o1
swap  [%i3 + 0], %o1
! move %o1(lower) -> %o1(upper)
sllx %o1, 32, %o1
add   %l4, 1, %l4

P2873: !_PREFETCH [6] (Int)
prefetch [%i1 + 80], 1

P2874: !_CASX [15] (maybe <- 0x1000079) (Int)
add %i3, 192, %l3
ldx [%l3], %l7
! move %l7(upper) -> %o1(lower)
srlx %l7, 32, %o5
or %o5, %o1, %o1
! move %l7(lower) -> %o2(upper)
sllx %l7, 32, %o2
mov  %l7, %o5
sllx %l4, 32, %l7
casx [%l3], %o5, %l7
! move %l7(upper) -> %o2(lower)
srlx %l7, 32, %l3
or %l3, %o2, %o2
! move %l7(lower) -> %o3(upper)
sllx %l7, 32, %o3
add  %l4, 1, %l4

P2875: !_ST [3] (maybe <- 0x408000ef) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i0 + 32 ]

P2876: !_REPLACEMENT [5] (Int)
sethi %hi(0x4c), %l7
or %l7, %lo(0x4c),  %l7
sethi %hi(0x10000), %o5
or %o5, %lo(0x10000),  %o5
add %i3, %l7, %l7
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]

P2877: !_DWST [14] (maybe <- 0x408000f0) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
std %f20, [%i3 + 128]

P2878: !_REPLACEMENT [0] (Int)
sethi %hi(0x0), %l3
or %l3, %lo(0x0),  %l3
sethi %hi(0x10000), %l6
or %l6, %lo(0x10000),  %l6
add %i3, %l3, %l3
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]

P2879: !_DWLD [0] (FP)
ldd [%i0 + 0], %f4
! 2 addresses covered

P2880: !_DWLD [0] (FP)
ldd [%i0 + 0], %f6
! 2 addresses covered

P2881: !_LD [3] (FP)
ld [%i0 + 32], %f8
! 1 addresses covered

P2882: !_DWST [4] (maybe <- 0x408000f1) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
std %f20, [%i0 + 64]

P2883: !_ST [15] (maybe <- 0x408000f2) (FP) (CBR)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i3 + 192 ]

! cbranch
andcc %l0, 1, %g0
be,pn  %xcc, TARGET2883
nop
RET2883:

! lfsr step begin
srlx %l0, 1, %l6
xnor %l6, %l0, %l6
sllx %l6, 63, %l6
or  %l6, %l0, %l0
srlx %l0, 1, %l0


P2884: !_PREFETCH [14] (Int)
prefetch [%i3 + 128], 1

P2885: !_REPLACEMENT [11] (Int)
sethi %hi(0x40), %l7
or %l7, %lo(0x40),  %l7
sethi %hi(0x10000), %o5
or %o5, %lo(0x10000),  %o5
add %i3, %l7, %l7
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]

P2886: !_LD [2] (FP)
ld [%i0 + 12], %f9
! 1 addresses covered

P2887: !_LD [4] (FP)
ld [%i0 + 64], %f10
! 1 addresses covered

P2888: !_REPLACEMENT [14] (Int) (Branch target of P2525)
sethi %hi(0x80), %l6
or %l6, %lo(0x80),  %l6
sethi %hi(0x10000), %l7
or %l7, %lo(0x10000),  %l7
add %i3, %l6, %l6
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
ba P2889
nop

TARGET2525:
ba RET2525
nop


P2889: !_PREFETCH [12] (Int)
prefetch [%i3 + 0], 1

P2890: !_NOP (Int)
nop

P2891: !_CASX [15] (maybe <- 0x100007a) (Int)
add %i3, 192, %l6
ldx [%l6], %o5
! move %o5(upper) -> %o3(lower)
srlx %o5, 32, %l3
or %l3, %o3, %o3
! move %o5(lower) -> %o4(upper)
sllx %o5, 32, %o4
mov  %o5, %l3
sllx %l4, 32, %o5
casx [%l6], %l3, %o5
! move %o5(upper) -> %o4(lower)
srlx %o5, 32, %l6
or %l6, %o4, %o4
!---- flushing int results buffer----
mov %o0, %l5
mov %o1, %l5
mov %o2, %l5
mov %o3, %l5
mov %o4, %l5
! move %o5(lower) -> %o0(upper)
sllx %o5, 32, %o0
add  %l4, 1, %l4

P2892: !_DWST [0] (maybe <- 0x408000f3) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
! 1 th moved, current_fp_src=21 
fmovs  %f16, %f21
fadds  %f16, %f17, %f16
std %f20, [%i0 + 0]

P2893: !_SWAP [9] (maybe <- 0x100007b) (Int)
mov %l4, %l6
swap  [%i1 + 512], %l6
! move %l6(lower) -> %o0(lower)
srl %l6, 0, %o5
or %o5, %o0, %o0
add   %l4, 1, %l4

P2894: !_ST [1] (maybe <- 0x408000f5) (FP) (Branch target of P2669)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i0 + 4 ]
ba P2895
nop

TARGET2669:
ba RET2669
nop


P2895: !_SWAP [3] (maybe <- 0x100007c) (Int) (CBR)
mov %l4, %o1
swap  [%i0 + 32], %o1
! move %o1(lower) -> %o1(upper)
sllx %o1, 32, %o1
add   %l4, 1, %l4

! cbranch
andcc %l0, 1, %g0
be,pt  %xcc, TARGET2895
nop
RET2895:

! lfsr step begin
srlx %l0, 1, %l3
xnor %l3, %l0, %l3
sllx %l3, 63, %l3
or  %l3, %l0, %l0
srlx %l0, 1, %l0


P2896: !_DWLD [10] (FP)
ldd [%i2 + 32], %f18
! 1 addresses covered
fmovs %f18, %f11

P2897: !_DWST [1] (maybe <- 0x408000f6) (FP) (CBR) (Branch target of P3049)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
! 1 th moved, current_fp_src=21 
fmovs  %f16, %f21
fadds  %f16, %f17, %f16
std %f20, [%i0 + 0]

! cbranch
andcc %l0, 1, %g0
be,pt  %xcc, TARGET2897
nop
RET2897:

! lfsr step begin
srlx %l0, 1, %l3
xnor %l3, %l0, %l3
sllx %l3, 63, %l3
or  %l3, %l0, %l0
srlx %l0, 1, %l0

ba P2898
nop

TARGET3049:
ba RET3049
nop


P2898: !_CAS [3] (maybe <- 0x100007d) (Int)
add %i0, 32, %l7
lduw [%l7], %l3
mov %l3, %l6
! move %l6(lower) -> %o1(lower)
or %l6, %o1, %o1
mov %l4, %o2
cas [%l7], %l6, %o2
! move %o2(lower) -> %o2(upper)
sllx %o2, 32, %o2
add   %l4, 1, %l4

P2899: !_SWAP [1] (maybe <- 0x100007e) (Int)
mov %l4, %o5
swap  [%i0 + 4], %o5
! move %o5(lower) -> %o2(lower)
srl %o5, 0, %l6
or %l6, %o2, %o2
add   %l4, 1, %l4

P2900: !_LD [8] (FP)
ld [%i1 + 256], %f12
! 1 addresses covered

P2901: !_LD [12] (FP)
ld [%i3 + 0], %f13
! 1 addresses covered

P2902: !_CAS [2] (maybe <- 0x100007f) (Int)
add %i0, 12, %l6
lduw [%l6], %o3
mov %o3, %l3
! move %l3(lower) -> %o3(upper)
sllx %l3, 32, %o3
mov %l4, %o5
cas [%l6], %l3, %o5
! move %o5(lower) -> %o3(lower)
srl %o5, 0, %l6
or %l6, %o3, %o3
add   %l4, 1, %l4

P2903: !_REPLACEMENT [7] (Int)
sethi %hi(0x54), %l3
or %l3, %lo(0x54),  %l3
sethi %hi(0x10000), %l6
or %l6, %lo(0x10000),  %l6
add %i3, %l3, %l3
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]

P2904: !_LD [14] (FP)
ld [%i3 + 128], %f14
! 1 addresses covered

P2905: !_CASX [3] (maybe <- 0x1000080) (Int)
add %i0, 32, %l3
ldx [%l3], %o4
! move %o4(upper) -> %o4(upper)
! move %o4(lower) -> %o4(lower)
!---- flushing int results buffer----
mov %o0, %l5
mov %o1, %l5
mov %o2, %l5
mov %o3, %l5
mov %o4, %l5
mov  %o4, %o5
sllx %l4, 32, %o0
casx [%l3], %o5, %o0
! move %o0(upper) -> %o0(upper)
! move %o0(lower) -> %o0(lower)
add  %l4, 1, %l4

P2906: !_ST [6] (maybe <- 0x408000f8) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i1 + 80 ]

P2907: !_ST [12] (maybe <- 0x408000f9) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i3 + 0 ]

P2908: !_REPLACEMENT [4] (Int)
sethi %hi(0x40), %l6
or %l6, %lo(0x40),  %l6
sethi %hi(0x10000), %l7
or %l7, %lo(0x10000),  %l7
add %i3, %l6, %l6
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]

P2909: !_DWLD [5] (FP)
ldd [%i1 + 72], %f18
! 1 addresses covered
fmovs %f19, %f15
!---- flushing fp results buffer to %f30 ----
fmovd %f0, %f30
fmovd %f2, %f30
fmovd %f4, %f30
fmovd %f6, %f30
fmovd %f8, %f30
fmovd %f10, %f30
fmovd %f12, %f30
fmovd %f14, %f30

P2910: !_PREFETCH [7] (Int)
prefetch [%i1 + 84], 1

P2911: !_MEMBAR (Int)
membar #StoreLoad

P2912: !_ST [12] (maybe <- 0x408000fa) (FP) (Branch target of P2628)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i3 + 0 ]
ba P2913
nop

TARGET2628:
ba RET2628
nop


P2913: !_REPLACEMENT [2] (Int)
sethi %hi(0xc), %o5
or %o5, %lo(0xc),  %o5
sethi %hi(0x10000), %l3
or %l3, %lo(0x10000),  %l3
add %i3, %o5, %o5
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]

P2914: !_LD [2] (FP)
ld [%i0 + 12], %f0
! 1 addresses covered

P2915: !_REPLACEMENT [9] (Int)
sethi %hi(0x200), %l7
or %l7, %lo(0x200),  %l7
sethi %hi(0x10000), %o5
or %o5, %lo(0x10000),  %o5
add %i3, %l7, %l7
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]

P2916: !_REPLACEMENT [11] (Int) (Branch target of P3064)
sethi %hi(0x40), %l6
or %l6, %lo(0x40),  %l6
sethi %hi(0x10000), %l7
or %l7, %lo(0x10000),  %l7
add %i3, %l6, %l6
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
ba P2917
nop

TARGET3064:
ba RET3064
nop


P2917: !_ST [11] (maybe <- 0x408000fb) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i2 + 64 ]

P2918: !_LD [6] (FP)
ld [%i1 + 80], %f1
! 1 addresses covered

P2919: !_DWLD [3] (FP)
ldd [%i0 + 32], %f2
! 1 addresses covered

P2920: !_REPLACEMENT [4] (Int)
sethi %hi(0x40), %o5
or %o5, %lo(0x40),  %o5
sethi %hi(0x10000), %l3
or %l3, %lo(0x10000),  %l3
add %i3, %o5, %o5
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]

P2921: !_SWAP [12] (maybe <- 0x1000081) (Int)
mov %l4, %o1
swap  [%i3 + 0], %o1
! move %o1(lower) -> %o1(upper)
sllx %o1, 32, %o1
add   %l4, 1, %l4

P2922: !_DWST [7] (maybe <- 0x408000fc) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
! 1 th moved, current_fp_src=21 
fmovs  %f16, %f21
fadds  %f16, %f17, %f16
std %f20, [%i1 + 80]

P2923: !_LD [13] (FP)
ld [%i3 + 64], %f3
! 1 addresses covered

P2924: !_DWLD [10] (FP)
ldd [%i2 + 32], %f4
! 1 addresses covered

P2925: !_ST [5] (maybe <- 0x408000fe) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i1 + 76 ]

P2926: !_ST [6] (maybe <- 0x408000ff) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i1 + 80 ]

P2927: !_CASX [9] (maybe <- 0x1000082) (Int)
add %i1, 512, %o5
ldx [%o5], %l6
! move %l6(upper) -> %o1(lower)
srlx %l6, 32, %l7
or %l7, %o1, %o1
! move %l6(lower) -> %o2(upper)
sllx %l6, 32, %o2
mov  %l6, %l7
sllx %l4, 32, %l6
casx [%o5], %l7, %l6
! move %l6(upper) -> %o2(lower)
srlx %l6, 32, %o5
or %o5, %o2, %o2
! move %l6(lower) -> %o3(upper)
sllx %l6, 32, %o3
add  %l4, 1, %l4

P2928: !_DWST [9] (maybe <- 0x40800100) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
std %f20, [%i1 + 512]

P2929: !_LD [13] (FP)
ld [%i3 + 64], %f5
! 1 addresses covered

P2930: !_DWST [6] (maybe <- 0x40800101) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
! 1 th moved, current_fp_src=21 
fmovs  %f16, %f21
fadds  %f16, %f17, %f16
std %f20, [%i1 + 80]

P2931: !_ST [15] (maybe <- 0x40800103) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i3 + 192 ]

P2932: !_DWST [1] (maybe <- 0x40800104) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
! 1 th moved, current_fp_src=21 
fmovs  %f16, %f21
fadds  %f16, %f17, %f16
std %f20, [%i0 + 0]

P2933: !_DWLD [12] (FP)
ldd [%i3 + 0], %f6
! 1 addresses covered

P2934: !_DWLD [15] (FP)
ldd [%i3 + 192], %f18
! 1 addresses covered
fmovs %f18, %f7

P2935: !_SWAP [13] (maybe <- 0x1000083) (Int)
mov %l4, %l3
swap  [%i3 + 64], %l3
! move %l3(lower) -> %o3(lower)
srl %l3, 0, %l7
or %l7, %o3, %o3
add   %l4, 1, %l4

P2936: !_LD [1] (FP)
ld [%i0 + 4], %f8
! 1 addresses covered

P2937: !_REPLACEMENT [13] (Int)
sethi %hi(0x40), %l6
or %l6, %lo(0x40),  %l6
sethi %hi(0x10000), %l7
or %l7, %lo(0x10000),  %l7
add %i3, %l6, %l6
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]

P2938: !_DWLD [0] (FP)
ldd [%i0 + 0], %f18
! 2 addresses covered
fmovs %f18, %f9
fmovs %f19, %f10

P2939: !_PREFETCH [4] (Int)
prefetch [%i0 + 64], 1

P2940: !_LD [11] (FP)
ld [%i2 + 64], %f11
! 1 addresses covered

P2941: !_CAS [4] (maybe <- 0x1000084) (Int)
add %i0, 64, %l6
lduw [%l6], %o4
mov %o4, %l3
! move %l3(lower) -> %o4(upper)
sllx %l3, 32, %o4
mov %l4, %o5
cas [%l6], %l3, %o5
! move %o5(lower) -> %o4(lower)
srl %o5, 0, %l6
or %l6, %o4, %o4
!---- flushing int results buffer----
mov %o0, %l5
mov %o1, %l5
mov %o2, %l5
mov %o3, %l5
mov %o4, %l5
add   %l4, 1, %l4

P2942: !_REPLACEMENT [15] (Int)
sethi %hi(0xc0), %l3
or %l3, %lo(0xc0),  %l3
sethi %hi(0x10000), %l6
or %l6, %lo(0x10000),  %l6
add %i3, %l3, %l3
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]

P2943: !_LD [12] (FP)
ld [%i3 + 0], %f12
! 1 addresses covered

P2944: !_REPLACEMENT [15] (Int) (Branch target of P2639)
sethi %hi(0xc0), %o5
or %o5, %lo(0xc0),  %o5
sethi %hi(0x10000), %l3
or %l3, %lo(0x10000),  %l3
add %i3, %o5, %o5
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
ba P2945
nop

TARGET2639:
ba RET2639
nop


P2945: !_LD [9] (FP)
ld [%i1 + 512], %f13
! 1 addresses covered

P2946: !_DWST [6] (maybe <- 0x40800106) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
! 1 th moved, current_fp_src=21 
fmovs  %f16, %f21
fadds  %f16, %f17, %f16
std %f20, [%i1 + 80]

P2947: !_LD [11] (FP) (Branch target of P2972)
ld [%i2 + 64], %f14
! 1 addresses covered
ba P2948
nop

TARGET2972:
ba RET2972
nop


P2948: !_DWLD [1] (FP) (CBR)
ldd [%i0 + 0], %f18
! 2 addresses covered
fmovs %f18, %f15
!---- flushing fp results buffer to %f30 ----
fmovd %f0, %f30
fmovd %f2, %f30
fmovd %f4, %f30
fmovd %f6, %f30
fmovd %f8, %f30
fmovd %f10, %f30
fmovd %f12, %f30
fmovd %f14, %f30
fmovs %f19, %f0

! cbranch
andcc %l0, 1, %g0
be,pn  %xcc, TARGET2948
nop
RET2948:

! lfsr step begin
srlx %l0, 1, %l6
xnor %l6, %l0, %l6
sllx %l6, 63, %l6
or  %l6, %l0, %l0
srlx %l0, 1, %l0


P2949: !_DWLD [13] (FP)
ldd [%i3 + 64], %f18
! 1 addresses covered
fmovs %f18, %f1

P2950: !_CASX [3] (maybe <- 0x1000085) (Int)
add %i0, 32, %o5
ldx [%o5], %o0
! move %o0(upper) -> %o0(upper)
! move %o0(lower) -> %o0(lower)
mov  %o0, %l7
sllx %l4, 32, %o1
casx [%o5], %l7, %o1
! move %o1(upper) -> %o1(upper)
! move %o1(lower) -> %o1(lower)
add  %l4, 1, %l4

P2951: !_PREFETCH [3] (Int)
prefetch [%i0 + 32], 1

P2952: !_SWAP [1] (maybe <- 0x1000086) (Int)
mov %l4, %o2
swap  [%i0 + 4], %o2
! move %o2(lower) -> %o2(upper)
sllx %o2, 32, %o2
add   %l4, 1, %l4

P2953: !_PREFETCH [11] (Int)
prefetch [%i2 + 64], 1

P2954: !_DWST [0] (maybe <- 0x40800108) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
! 1 th moved, current_fp_src=21 
fmovs  %f16, %f21
fadds  %f16, %f17, %f16
std %f20, [%i0 + 0]

P2955: !_DWLD [12] (FP) (Branch target of P2664)
ldd [%i3 + 0], %f2
! 1 addresses covered
ba P2956
nop

TARGET2664:
ba RET2664
nop


P2956: !_REPLACEMENT [3] (Int)
sethi %hi(0x20), %l3
or %l3, %lo(0x20),  %l3
sethi %hi(0x10000), %l6
or %l6, %lo(0x10000),  %l6
add %i3, %l3, %l3
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]

P2957: !_REPLACEMENT [1] (Int)
sethi %hi(0x4), %o5
or %o5, %lo(0x4),  %o5
sethi %hi(0x10000), %l3
or %l3, %lo(0x10000),  %l3
add %i3, %o5, %o5
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]

P2958: !_PREFETCH [4] (Int)
prefetch [%i0 + 64], 1

P2959: !_DWST [8] (maybe <- 0x4080010a) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
std %f20, [%i1 + 256]

P2960: !_REPLACEMENT [4] (Int) (Branch target of P2448)
sethi %hi(0x40), %l6
or %l6, %lo(0x40),  %l6
sethi %hi(0x10000), %l7
or %l7, %lo(0x10000),  %l7
add %i3, %l6, %l6
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
ba P2961
nop

TARGET2448:
ba RET2448
nop


P2961: !_DWST [12] (maybe <- 0x4080010b) (FP) (CBR)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
std %f20, [%i3 + 0]

! cbranch
andcc %l0, 1, %g0
be,pt  %xcc, TARGET2961
nop
RET2961:

! lfsr step begin
srlx %l0, 1, %o5
xnor %o5, %l0, %o5
sllx %o5, 63, %o5
or  %o5, %l0, %l0
srlx %l0, 1, %l0


P2962: !_DWST [3] (maybe <- 0x4080010c) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
std %f20, [%i0 + 32]

P2963: !_DWST [10] (maybe <- 0x4080010d) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
std %f20, [%i2 + 32]

P2964: !_CAS [13] (maybe <- 0x1000087) (Int)
add %i3, 64, %o5
lduw [%o5], %l6
mov %l6, %l7
! move %l7(lower) -> %o2(lower)
or %l7, %o2, %o2
mov %l4, %o3
cas [%o5], %l7, %o3
! move %o3(lower) -> %o3(upper)
sllx %o3, 32, %o3
add   %l4, 1, %l4

P2965: !_DWLD [1] (FP)
ldd [%i0 + 0], %f18
! 2 addresses covered
fmovs %f18, %f3
fmovs %f19, %f4

P2966: !_MEMBAR (Int)
membar #StoreLoad

P2967: !_LD [6] (FP)
ld [%i1 + 80], %f5
! 1 addresses covered

P2968: !_LD [15] (FP)
ld [%i3 + 192], %f6
! 1 addresses covered

P2969: !_ST [15] (maybe <- 0x4080010e) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i3 + 192 ]

P2970: !_LD [7] (FP)
ld [%i1 + 84], %f7
! 1 addresses covered

P2971: !_SWAP [4] (maybe <- 0x1000088) (Int)
mov %l4, %o5
swap  [%i0 + 64], %o5
! move %o5(lower) -> %o3(lower)
srl %o5, 0, %l6
or %l6, %o3, %o3
add   %l4, 1, %l4

P2972: !_PREFETCH [7] (Int) (CBR)
prefetch [%i1 + 84], 1

! cbranch
andcc %l0, 1, %g0
be,pn  %xcc, TARGET2972
nop
RET2972:

! lfsr step begin
srlx %l0, 1, %l3
xnor %l3, %l0, %l3
sllx %l3, 63, %l3
or  %l3, %l0, %l0
srlx %l0, 1, %l0


P2973: !_DWST [13] (maybe <- 0x4080010f) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
std %f20, [%i3 + 64]

P2974: !_DWLD [13] (FP)
ldd [%i3 + 64], %f8
! 1 addresses covered

P2975: !_DWST [14] (maybe <- 0x40800110) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
std %f20, [%i3 + 128]

P2976: !_DWST [1] (maybe <- 0x40800111) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
! 1 th moved, current_fp_src=21 
fmovs  %f16, %f21
fadds  %f16, %f17, %f16
std %f20, [%i0 + 0]

P2977: !_REPLACEMENT [8] (Int)
sethi %hi(0x100), %l7
or %l7, %lo(0x100),  %l7
sethi %hi(0x10000), %o5
or %o5, %lo(0x10000),  %o5
add %i3, %l7, %l7
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]

P2978: !_LD [15] (FP)
ld [%i3 + 192], %f9
! 1 addresses covered

P2979: !_ST [12] (maybe <- 0x40800113) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i3 + 0 ]

P2980: !_ST [0] (maybe <- 0x40800114) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i0 + 0 ]

P2981: !_REPLACEMENT [5] (Int)
sethi %hi(0x4c), %o5
or %o5, %lo(0x4c),  %o5
sethi %hi(0x10000), %l3
or %l3, %lo(0x10000),  %l3
add %i3, %o5, %o5
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]

P2982: !_ST [7] (maybe <- 0x40800115) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i1 + 84 ]

P2983: !_REPLACEMENT [5] (Int)
sethi %hi(0x4c), %l6
or %l6, %lo(0x4c),  %l6
sethi %hi(0x10000), %l7
or %l7, %lo(0x10000),  %l7
add %i3, %l6, %l6
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]

P2984: !_DWLD [8] (FP)
ldd [%i1 + 256], %f10
! 1 addresses covered

P2985: !_REPLACEMENT [2] (Int)
sethi %hi(0xc), %l3
or %l3, %lo(0xc),  %l3
sethi %hi(0x10000), %l6
or %l6, %lo(0x10000),  %l6
add %i3, %l3, %l3
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]

P2986: !_DWLD [7] (FP)
ldd [%i1 + 80], %f18
! 2 addresses covered
fmovs %f18, %f11
fmovs %f19, %f12

P2987: !_ST [2] (maybe <- 0x40800116) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i0 + 12 ]

P2988: !_CASX [0] (maybe <- 0x1000089) (Int)
add %i0, 0, %o5
ldx [%o5], %o4
! move %o4(upper) -> %o4(upper)
! move %o4(lower) -> %o4(lower)
!---- flushing int results buffer----
mov %o0, %l5
mov %o1, %l5
mov %o2, %l5
mov %o3, %l5
mov %o4, %l5
mov %o4, %l7
sllx %l4, 32, %o0
add  %l4, 1, %l4
or   %l4, %o0, %o0
casx [%o5], %l7, %o0
! move %o0(upper) -> %o0(upper)
! move %o0(lower) -> %o0(lower)
add  %l4, 1, %l4

P2989: !_ST [4] (maybe <- 0x40800117) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i0 + 64 ]

P2990: !_ST [12] (maybe <- 0x40800118) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i3 + 0 ]

P2991: !_REPLACEMENT [13] (Int)
sethi %hi(0x40), %l3
or %l3, %lo(0x40),  %l3
sethi %hi(0x10000), %l6
or %l6, %lo(0x10000),  %l6
add %i3, %l3, %l3
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]

P2992: !_ST [2] (maybe <- 0x40800119) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i0 + 12 ]

P2993: !_REPLACEMENT [2] (Int)
sethi %hi(0xc), %l7
or %l7, %lo(0xc),  %l7
sethi %hi(0x10000), %o5
or %o5, %lo(0x10000),  %o5
add %i3, %l7, %l7
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]

P2994: !_SWAP [8] (maybe <- 0x100008b) (Int) (Branch target of P2308)
mov %l4, %o1
swap  [%i1 + 256], %o1
! move %o1(lower) -> %o1(upper)
sllx %o1, 32, %o1
add   %l4, 1, %l4
ba P2995
nop

TARGET2308:
ba RET2308
nop


P2995: !_LD [10] (FP)
ld [%i2 + 32], %f13
! 1 addresses covered

P2996: !_PREFETCH [13] (Int) (Branch target of P2375)
prefetch [%i3 + 64], 1
ba P2997
nop

TARGET2375:
ba RET2375
nop


P2997: !_LD [15] (FP)
ld [%i3 + 192], %f14
! 1 addresses covered

P2998: !_ST [11] (maybe <- 0x4080011a) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i2 + 64 ]

P2999: !_DWST [5] (maybe <- 0x4080011b) (FP)
! 0 th moved, current_fp_src=21 
fmovs  %f16, %f21
fadds  %f16, %f17, %f16
std %f20, [%i1 + 72]

P3000: !_DWLD [3] (FP)
ldd [%i0 + 32], %f18
! 1 addresses covered
fmovs %f18, %f15
!---- flushing fp results buffer to %f30 ----
fmovd %f0, %f30
fmovd %f2, %f30
fmovd %f4, %f30
fmovd %f6, %f30
fmovd %f8, %f30
fmovd %f10, %f30
fmovd %f12, %f30
fmovd %f14, %f30

P3001: !_PREFETCH [0] (Int)
prefetch [%i0 + 0], 1

P3002: !_DWST [1] (maybe <- 0x4080011c) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
! 1 th moved, current_fp_src=21 
fmovs  %f16, %f21
fadds  %f16, %f17, %f16
std %f20, [%i0 + 0]

P3003: !_NOP (Int)
nop

P3004: !_CASX [10] (maybe <- 0x100008c) (Int)
add %i2, 32, %l7
ldx [%l7], %l3
! move %l3(upper) -> %o1(lower)
srlx %l3, 32, %l6
or %l6, %o1, %o1
! move %l3(lower) -> %o2(upper)
sllx %l3, 32, %o2
mov  %l3, %l6
sllx %l4, 32, %l3
casx [%l7], %l6, %l3
! move %l3(upper) -> %o2(lower)
srlx %l3, 32, %l7
or %l7, %o2, %o2
! move %l3(lower) -> %o3(upper)
sllx %l3, 32, %o3
add  %l4, 1, %l4

P3005: !_CAS [1] (maybe <- 0x100008d) (Int)
add %i0, 4, %l7
lduw [%l7], %l3
mov %l3, %l6
! move %l6(lower) -> %o3(lower)
or %l6, %o3, %o3
mov %l4, %o4
cas [%l7], %l6, %o4
! move %o4(lower) -> %o4(upper)
sllx %o4, 32, %o4
add   %l4, 1, %l4

P3006: !_CASX [11] (maybe <- 0x100008e) (Int)
add %i2, 64, %l7
ldx [%l7], %l3
! move %l3(upper) -> %o4(lower)
srlx %l3, 32, %l6
or %l6, %o4, %o4
!---- flushing int results buffer----
mov %o0, %l5
mov %o1, %l5
mov %o2, %l5
mov %o3, %l5
mov %o4, %l5
! move %l3(lower) -> %o0(upper)
sllx %l3, 32, %o0
mov  %l3, %l6
sllx %l4, 32, %l3
casx [%l7], %l6, %l3
! move %l3(upper) -> %o0(lower)
srlx %l3, 32, %l7
or %l7, %o0, %o0
! move %l3(lower) -> %o1(upper)
sllx %l3, 32, %o1
add  %l4, 1, %l4

P3007: !_ST [5] (maybe <- 0x4080011e) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i1 + 76 ]

P3008: !_REPLACEMENT [15] (Int)
sethi %hi(0xc0), %l3
or %l3, %lo(0xc0),  %l3
sethi %hi(0x10000), %l6
or %l6, %lo(0x10000),  %l6
add %i3, %l3, %l3
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]

P3009: !_REPLACEMENT [2] (Int)
sethi %hi(0xc), %o5
or %o5, %lo(0xc),  %o5
sethi %hi(0x10000), %l3
or %l3, %lo(0x10000),  %l3
add %i3, %o5, %o5
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]

P3010: !_DWLD [10] (FP)
ldd [%i2 + 32], %f0
! 1 addresses covered

P3011: !_LD [7] (FP)
ld [%i1 + 84], %f1
! 1 addresses covered

P3012: !_CAS [14] (maybe <- 0x100008f) (Int)
add %i3, 128, %o5
lduw [%o5], %l6
mov %l6, %l7
! move %l7(lower) -> %o1(lower)
or %l7, %o1, %o1
mov %l4, %o2
cas [%o5], %l7, %o2
! move %o2(lower) -> %o2(upper)
sllx %o2, 32, %o2
add   %l4, 1, %l4

P3013: !_LD [4] (FP)
ld [%i0 + 64], %f2
! 1 addresses covered

P3014: !_REPLACEMENT [12] (Int)
sethi %hi(0x0), %l7
or %l7, %lo(0x0),  %l7
sethi %hi(0x10000), %o5
or %o5, %lo(0x10000),  %o5
add %i3, %l7, %l7
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]

P3015: !_REPLACEMENT [9] (Int)
sethi %hi(0x200), %l6
or %l6, %lo(0x200),  %l6
sethi %hi(0x10000), %l7
or %l7, %lo(0x10000),  %l7
add %i3, %l6, %l6
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]

P3016: !_PREFETCH [9] (Int)
prefetch [%i1 + 512], 1

P3017: !_ST [11] (maybe <- 0x4080011f) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i2 + 64 ]

P3018: !_SWAP [10] (maybe <- 0x1000090) (Int)
mov %l4, %l6
swap  [%i2 + 32], %l6
! move %l6(lower) -> %o2(lower)
srl %l6, 0, %o5
or %o5, %o2, %o2
add   %l4, 1, %l4

P3019: !_DWLD [4] (FP)
ldd [%i0 + 64], %f18
! 1 addresses covered
fmovs %f18, %f3

P3020: !_NOP (Int)
nop

P3021: !_PREFETCH [10] (Int)
prefetch [%i2 + 32], 1

P3022: !_DWST [2] (maybe <- 0x40800120) (FP) (Branch target of P2961)
! 0 th moved, current_fp_src=21 
fmovs  %f16, %f21
fadds  %f16, %f17, %f16
std %f20, [%i0 + 8]
ba P3023
nop

TARGET2961:
ba RET2961
nop


P3023: !_PREFETCH [1] (Int) (Branch target of P2703)
prefetch [%i0 + 4], 1
ba P3024
nop

TARGET2703:
ba RET2703
nop


P3024: !_MEMBAR (Int)
membar #StoreLoad

P3025: !_DWLD [2] (FP)
ldd [%i0 + 8], %f4
! 1 addresses covered
fmovs %f5, %f4

P3026: !_ST [2] (maybe <- 0x40800121) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i0 + 12 ]

P3027: !_ST [9] (maybe <- 0x40800122) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i1 + 512 ]

P3028: !_REPLACEMENT [2] (Int)
sethi %hi(0xc), %o5
or %o5, %lo(0xc),  %o5
sethi %hi(0x10000), %l3
or %l3, %lo(0x10000),  %l3
add %i3, %o5, %o5
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]

P3029: !_DWLD [3] (FP) (CBR)
ldd [%i0 + 32], %f18
! 1 addresses covered
fmovs %f18, %f5

! cbranch
andcc %l0, 1, %g0
be,pn  %xcc, TARGET3029
nop
RET3029:

! lfsr step begin
srlx %l0, 1, %l7
xnor %l7, %l0, %l7
sllx %l7, 63, %l7
or  %l7, %l0, %l0
srlx %l0, 1, %l0


P3030: !_LD [1] (FP)
ld [%i0 + 4], %f6
! 1 addresses covered

P3031: !_LD [11] (FP)
ld [%i2 + 64], %f7
! 1 addresses covered

P3032: !_PREFETCH [0] (Int)
prefetch [%i0 + 0], 1

P3033: !_ST [8] (maybe <- 0x40800123) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i1 + 256 ]

P3034: !_DWLD [3] (FP)
ldd [%i0 + 32], %f8
! 1 addresses covered

P3035: !_LD [6] (FP)
ld [%i1 + 80], %f9
! 1 addresses covered

P3036: !_ST [15] (maybe <- 0x40800124) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i3 + 192 ]

P3037: !_REPLACEMENT [4] (Int)
sethi %hi(0x40), %l6
or %l6, %lo(0x40),  %l6
sethi %hi(0x10000), %l7
or %l7, %lo(0x10000),  %l7
add %i3, %l6, %l6
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]

P3038: !_REPLACEMENT [13] (Int)
sethi %hi(0x40), %l3
or %l3, %lo(0x40),  %l3
sethi %hi(0x10000), %l6
or %l6, %lo(0x10000),  %l6
add %i3, %l3, %l3
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]

P3039: !_LD [8] (FP)
ld [%i1 + 256], %f10
! 1 addresses covered

P3040: !_ST [5] (maybe <- 0x40800125) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i1 + 76 ]

P3041: !_ST [3] (maybe <- 0x40800126) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i0 + 32 ]

P3042: !_DWLD [5] (FP) (Branch target of P2383)
ldd [%i1 + 72], %f18
! 1 addresses covered
fmovs %f19, %f11
ba P3043
nop

TARGET2383:
ba RET2383
nop


P3043: !_CASX [1] (maybe <- 0x1000091) (Int)
add %i0, 0, %l7
ldx [%l7], %o3
! move %o3(upper) -> %o3(upper)
! move %o3(lower) -> %o3(lower)
mov %o3, %l6
sllx %l4, 32, %o4
add  %l4, 1, %l4
or   %l4, %o4, %o4
casx [%l7], %l6, %o4
! move %o4(upper) -> %o4(upper)
! move %o4(lower) -> %o4(lower)
!---- flushing int results buffer----
mov %o0, %l5
mov %o1, %l5
mov %o2, %l5
mov %o3, %l5
mov %o4, %l5
add  %l4, 1, %l4

P3044: !_DWLD [13] (FP)
ldd [%i3 + 64], %f12
! 1 addresses covered

P3045: !_DWLD [4] (FP)
ldd [%i0 + 64], %f18
! 1 addresses covered
fmovs %f18, %f13

P3046: !_DWLD [9] (FP)
ldd [%i1 + 512], %f14
! 1 addresses covered

P3047: !_REPLACEMENT [0] (Int) (Branch target of P2831)
sethi %hi(0x0), %l6
or %l6, %lo(0x0),  %l6
sethi %hi(0x10000), %l7
or %l7, %lo(0x10000),  %l7
add %i3, %l6, %l6
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
ba P3048
nop

TARGET2831:
ba RET2831
nop


P3048: !_SWAP [11] (maybe <- 0x1000093) (Int)
mov %l4, %o0
swap  [%i2 + 64], %o0
! move %o0(lower) -> %o0(upper)
sllx %o0, 32, %o0
add   %l4, 1, %l4

P3049: !_REPLACEMENT [13] (Int) (CBR)
sethi %hi(0x40), %o5
or %o5, %lo(0x40),  %o5
sethi %hi(0x10000), %l3
or %l3, %lo(0x10000),  %l3
add %i3, %o5, %o5
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]

! cbranch
andcc %l0, 1, %g0
be,pn  %xcc, TARGET3049
nop
RET3049:

! lfsr step begin
srlx %l0, 1, %l7
xnor %l7, %l0, %l7
sllx %l7, 63, %l7
or  %l7, %l0, %l0
srlx %l0, 1, %l0


P3050: !_MEMBAR (Int)
membar #StoreLoad

P3051: !_LD [0] (FP)
ld [%i0 + 0], %f15
! 1 addresses covered
!---- flushing fp results buffer to %f30 ----
fmovd %f0, %f30
fmovd %f2, %f30
fmovd %f4, %f30
fmovd %f6, %f30
fmovd %f8, %f30
fmovd %f10, %f30
fmovd %f12, %f30
fmovd %f14, %f30

P3052: !_LD [1] (FP)
ld [%i0 + 4], %f0
! 1 addresses covered

P3053: !_LD [2] (FP)
ld [%i0 + 12], %f1
! 1 addresses covered

P3054: !_LD [3] (FP)
ld [%i0 + 32], %f2
! 1 addresses covered

P3055: !_LD [4] (FP)
ld [%i0 + 64], %f3
! 1 addresses covered

P3056: !_LD [5] (FP)
ld [%i1 + 76], %f4
! 1 addresses covered

P3057: !_LD [6] (FP)
ld [%i1 + 80], %f5
! 1 addresses covered

P3058: !_LD [7] (FP)
ld [%i1 + 84], %f6
! 1 addresses covered

P3059: !_LD [8] (FP)
ld [%i1 + 256], %f7
! 1 addresses covered

P3060: !_LD [9] (FP)
ld [%i1 + 512], %f8
! 1 addresses covered

P3061: !_LD [10] (FP)
ld [%i2 + 32], %f9
! 1 addresses covered

P3062: !_LD [11] (FP) (Branch target of P2211)
ld [%i2 + 64], %f10
! 1 addresses covered
ba P3063
nop

TARGET2211:
ba RET2211
nop


P3063: !_LD [12] (FP)
ld [%i3 + 0], %f11
! 1 addresses covered

P3064: !_LD [13] (FP) (CBR) (Branch target of P2663)
ld [%i3 + 64], %f12
! 1 addresses covered

! cbranch
andcc %l0, 1, %g0
be,pt  %xcc, TARGET3064
nop
RET3064:

! lfsr step begin
srlx %l0, 1, %o5
xnor %o5, %l0, %o5
sllx %o5, 63, %o5
or  %o5, %l0, %l0
srlx %l0, 1, %l0

ba P3065
nop

TARGET2663:
ba RET2663
nop


P3065: !_LD [14] (FP)
ld [%i3 + 128], %f13
! 1 addresses covered

P3066: !_LD [15] (FP)
ld [%i3 + 192], %f14
! 1 addresses covered

END_NODES2: ! Test istream for CPU 2 ends
sethi %hi(0xdead0e0f), %l3
or    %l3, %lo(0xdead0e0f), %l3
! move %l3(lower) -> %o0(lower)
or %l3, %o0, %o0
stw %l3, [%i5] 
ld [%i5], %f15
!---- flushing int results buffer----
mov %o0, %l5
!---- flushing fp results buffer to %f30 ----
fmovd %f0, %f30
fmovd %f2, %f30
fmovd %f4, %f30
fmovd %f6, %f30
fmovd %f8, %f30
fmovd %f10, %f30
fmovd %f12, %f30
fmovd %f14, %f30

restore
retl
nop
!-----------------

! register usage:
! %i0 %i1 %i2 %i3 : base registers for 4 regions
! %i4 fixed pointer to per-cpu results area
! %l1 moving pointer to per-cpu FP results area
! %o7 moving pointer to per-cpu integer results area
! %i5 pointer to per-cpu private area
! %l0 holds lfsr, used as source of random bits 
! %l2 loop count register
! %f16 running counter for unique fp store values
! %f17 holds increment value for fp counter
! %l4 running counter for unique integer store values (increment value is always 1)
! %l5 move-to register for load values (simulation only)
! %f30 move-to register for FP values (simulation only)
! %l3 %l6 %l7 %o5 : 4 temporary registers
! %o0 %o1 %o2 %o3 %o4 : 5 integer results buffer registers
! %f0-f15 FP results buffer registers
! %f32-f47 FP block load/store registers

func3:
! 1000 (dynamic) instruction sequence begins
save   %sp, -192, %sp

! Force %i0-%i3 to be 64-byte aligned
add %i0, 63, %i0
andn %i0, 63, %i0

add %i1, 63, %i1
andn %i1, 63, %i1

add %i2, 63, %i2
andn %i2, 63, %i2

add %i3, 63, %i3
andn %i3, 63, %i3

add %i4, 63, %i4
andn %i4, 63, %i4

add %i5, 63, %i5
andn %i5, 63, %i5


! Initialize pointer to FP load results area
mov   %i4, %l1

! Initialize pointer to integer load results area
sethi %hi(0x80000), %o7
or    %o7, %lo(0x80000), %o7
add  %o7, %l1, %o7 

! Initialize %f0-%f62 to 0xdeadbee0deadbee1
sethi %hi(0xdeadbee0), %o5
or    %o5, %lo(0xdeadbee0), %o5
stw   %o5, [%i5]
sethi %hi(0xdeadbee1), %o5
or    %o5, %lo(0xdeadbee1), %o5
stw   %o5, [%i5+4]
ldd [%i5], %f0
fmovd %f0, %f2
fmovd %f0, %f4
fmovd %f0, %f6
fmovd %f0, %f8
fmovd %f0, %f10
fmovd %f0, %f12
fmovd %f0, %f14
fmovd %f0, %f16
fmovd %f0, %f18
fmovd %f0, %f20
fmovd %f0, %f22
fmovd %f0, %f24
fmovd %f0, %f26
fmovd %f0, %f28
fmovd %f0, %f30
fmovd %f0, %f32
fmovd %f0, %f34
fmovd %f0, %f36
fmovd %f0, %f38
fmovd %f0, %f40
fmovd %f0, %f42
fmovd %f0, %f44
fmovd %f0, %f46
fmovd %f0, %f48
fmovd %f0, %f50
fmovd %f0, %f52
fmovd %f0, %f54
fmovd %f0, %f56
fmovd %f0, %f58
fmovd %f0, %f60
fmovd %f0, %f62

! Signature for extract_loads script to start extracting load values for this stream
sethi %hi(0x03deade1), %o5
or    %o5, %lo(0x03deade1), %o5
stw %o5, [%i5] 
ld [%i5], %f16

! Initialize running integer counter in register %l4
sethi %hi(0x1800001), %l4
or    %l4, %lo(0x1800001), %l4

! Initialize running FP counter in register %f16
sethi %hi(0x41000001), %o5
or    %o5, %lo(0x41000001), %o5
stw %o5, [%i5] 
ld [%i5], %f16

! Initialize FP counter increment value in register %f17 (constant)
sethi %hi(0x35800000), %o5
or    %o5, %lo(0x35800000), %o5
stw %o5, [%i5] 
ld [%i5], %f17 

! Initialize LFSR to 0x23db^4
sethi %hi(0x23db), %l0
or    %l0, %lo(0x23db), %l0
mulx  %l0, %l0, %l0
mulx  %l0, %l0, %l0

!-- init shared addrs 6 to 7 ---
stx %g0, [%i1+80]

! use untouched cache-line (offset 4K) in replacement area for sync
sub %i1, %i0, %l3
add %i3, %l3, %l3
sub %l3, -4096, %l3

!-- begin of sync_init ---
or %g0, 1, %l6
or %g0, %l6, %l7
swap [%l3+4], %l7
membar #Sync
sync_init_1_3:
brnz,pt %l6, sync_init_1_3
lduw [%l3+4], %l6 ! delay slot
sync_init_2_3:
lduw [%l3], %l6
sub %l6, 1, %l7
cas [%l3], %l6, %l7
cmp %l6, %l7
bne,pt %xcc, sync_init_2_3
nop
membar #Sync
sync_init_3_3:
lduw [%l3], %l6 ! delay slot
brnz,pt %l6, sync_init_3_3
nop
!-- end of sync_init ---


BEGIN_NODES3: ! Test istream for CPU 3 begins

P3067: !_CAS [0] (maybe <- 0x1800001) (Int) (Loop entry)
sethi %hi(0x1), %l2
or %l2, %lo(0x1),  %l2
loop_entry_3_0:
add %i0, 0, %l3
lduw [%l3], %o0
mov %o0, %o5
! move %o5(lower) -> %o0(upper)
sllx %o5, 32, %o0
mov %l4, %l7
cas [%l3], %o5, %l7
! move %l7(lower) -> %o0(lower)
srl %l7, 0, %l3
or %l3, %o0, %o0
add   %l4, 1, %l4

P3068: !_ST [3] (maybe <- 0x41000001) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i0 + 32 ]

P3069: !_LD [3] (FP)
ld [%i0 + 32], %f0
! 1 addresses covered

P3070: !_CAS [1] (maybe <- 0x1800002) (Int)
add %i0, 4, %o5
lduw [%o5], %o1
mov %o1, %l7
! move %l7(lower) -> %o1(upper)
sllx %l7, 32, %o1
mov %l4, %l6
cas [%o5], %l7, %l6
! move %l6(lower) -> %o1(lower)
srl %l6, 0, %o5
or %o5, %o1, %o1
add   %l4, 1, %l4

P3071: !_DWLD [11] (FP)
ldd [%i2 + 64], %f18
! 1 addresses covered
fmovs %f18, %f1

P3072: !_CAS [13] (maybe <- 0x1800003) (Int) (LE)
! Change single-word-level endianess (big endian <-> little endian) 
sethi %hi(0xff00ff00), %o5
or %o5, %lo(0xff00ff00), %o5
and %l4, %o5, %l7
srl %l7, 8, %l7
sll %l4, 8, %l3
and %l3, %o5, %l3
or %l3, %l7, %l3
srl %l3, 16, %l7
sll %l3, 16, %l3
srl %l3, 0, %l3
or %l3, %l7, %l3
wr %g0, 0x88, %asi
add %i3, 64, %o5
lduwa [%o5] %asi, %o2
mov %o2, %l7
! move %l7(lower) -> %o2(upper)
sllx %l7, 32, %o2
mov %l3, %l6
casa [%o5] %asi, %l7, %l6
! move %l6(lower) -> %o2(lower)
srl %l6, 0, %o5
or %o5, %o2, %o2
add   %l4, 1, %l4

P3073: !_PREFETCH [8] (Int) (Branch target of P3932)
prefetch [%i1 + 256], 1
ba P3074
nop

TARGET3932:
ba RET3932
nop


P3074: !_REPLACEMENT [14] (Int)
sethi %hi(0x80), %l7
or %l7, %lo(0x80),  %l7
sethi %hi(0x10000), %o5
or %o5, %lo(0x10000),  %o5
add %i3, %l7, %l7
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]

P3075: !_MEMBAR (Int)
membar #StoreLoad

P3076: !_DWLD [13] (FP)
ldd [%i3 + 64], %f2
! 1 addresses covered

P3077: !_DWST [6] (maybe <- 0x41000002) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
! 1 th moved, current_fp_src=21 
fmovs  %f16, %f21
fadds  %f16, %f17, %f16
std %f20, [%i1 + 80]

P3078: !_LD [2] (FP)
ld [%i0 + 12], %f3
! 1 addresses covered

P3079: !_NOP (Int)
nop

P3080: !_DWST [2] (maybe <- 0x41000004) (FP)
! 0 th moved, current_fp_src=21 
fmovs  %f16, %f21
fadds  %f16, %f17, %f16
std %f20, [%i0 + 8]

P3081: !_ST [12] (maybe <- 0x41000005) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i3 + 0 ]

P3082: !_SWAP [11] (maybe <- 0x1800004) (Int)
mov %l4, %o3
swap  [%i2 + 64], %o3
! move %o3(lower) -> %o3(upper)
sllx %o3, 32, %o3
add   %l4, 1, %l4

P3083: !_ST [1] (maybe <- 0x41000006) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i0 + 4 ]

P3084: !_MEMBAR (Int)
membar #StoreLoad

P3085: !_LD [6] (FP)
ld [%i1 + 80], %f4
! 1 addresses covered

P3086: !_ST [9] (maybe <- 0x41000007) (FP) (CBR)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i1 + 512 ]

! cbranch
andcc %l0, 1, %g0
be,pn  %xcc, TARGET3086
nop
RET3086:

! lfsr step begin
srlx %l0, 1, %o5
xnor %o5, %l0, %o5
sllx %o5, 63, %o5
or  %o5, %l0, %l0
srlx %l0, 1, %l0


P3087: !_REPLACEMENT [5] (Int)
sethi %hi(0x4c), %l3
or %l3, %lo(0x4c),  %l3
sethi %hi(0x10000), %l6
or %l6, %lo(0x10000),  %l6
add %i3, %l3, %l3
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]

P3088: !_REPLACEMENT [4] (Int)
sethi %hi(0x40), %o5
or %o5, %lo(0x40),  %o5
sethi %hi(0x10000), %l3
or %l3, %lo(0x10000),  %l3
add %i3, %o5, %o5
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]

P3089: !_CAS [14] (maybe <- 0x1800005) (Int)
add %i3, 128, %o5
lduw [%o5], %l6
mov %l6, %l7
! move %l7(lower) -> %o3(lower)
or %l7, %o3, %o3
mov %l4, %o4
cas [%o5], %l7, %o4
! move %o4(lower) -> %o4(upper)
sllx %o4, 32, %o4
add   %l4, 1, %l4

P3090: !_DWST [6] (maybe <- 0x41000008) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
! 1 th moved, current_fp_src=21 
fmovs  %f16, %f21
fadds  %f16, %f17, %f16
std %f20, [%i1 + 80]

P3091: !_DWLD [0] (FP) (Branch target of P3998)
ldd [%i0 + 0], %f18
! 2 addresses covered
fmovs %f18, %f5
fmovs %f19, %f6
ba P3092
nop

TARGET3998:
ba RET3998
nop


P3092: !_LD [14] (FP) (Branch target of P3485)
ld [%i3 + 128], %f7
! 1 addresses covered
ba P3093
nop

TARGET3485:
ba RET3485
nop


P3093: !_REPLACEMENT [2] (Int) (Branch target of P3805)
sethi %hi(0xc), %l6
or %l6, %lo(0xc),  %l6
sethi %hi(0x10000), %l7
or %l7, %lo(0x10000),  %l7
add %i3, %l6, %l6
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
ba P3094
nop

TARGET3805:
ba RET3805
nop


P3094: !_DWST [5] (maybe <- 0x4100000a) (FP)
! 0 th moved, current_fp_src=21 
fmovs  %f16, %f21
fadds  %f16, %f17, %f16
std %f20, [%i1 + 72]

P3095: !_LD [5] (FP)
ld [%i1 + 76], %f8
! 1 addresses covered

P3096: !_REPLACEMENT [9] (Int)
sethi %hi(0x200), %o5
or %o5, %lo(0x200),  %o5
sethi %hi(0x10000), %l3
or %l3, %lo(0x10000),  %l3
add %i3, %o5, %o5
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]

P3097: !_LD [13] (FP)
ld [%i3 + 64], %f9
! 1 addresses covered

P3098: !_DWST [12] (maybe <- 0x4100000b) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
std %f20, [%i3 + 0]

P3099: !_LD [13] (FP)
ld [%i3 + 64], %f10
! 1 addresses covered

P3100: !_NOP (Int)
nop

P3101: !_REPLACEMENT [1] (Int)
sethi %hi(0x4), %l6
or %l6, %lo(0x4),  %l6
sethi %hi(0x10000), %l7
or %l7, %lo(0x10000),  %l7
add %i3, %l6, %l6
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]

P3102: !_LD [13] (FP)
ld [%i3 + 64], %f11
! 1 addresses covered

P3103: !_DWLD [6] (FP) (CBR)
ldd [%i1 + 80], %f12
! 2 addresses covered

! cbranch
andcc %l0, 1, %g0
be,pn  %xcc, TARGET3103
nop
RET3103:

! lfsr step begin
srlx %l0, 1, %l3
xnor %l3, %l0, %l3
sllx %l3, 63, %l3
or  %l3, %l0, %l0
srlx %l0, 1, %l0


P3104: !_LD [10] (FP)
ld [%i2 + 32], %f14
! 1 addresses covered

P3105: !_SWAP [3] (maybe <- 0x1800006) (Int)
mov %l4, %o5
swap  [%i0 + 32], %o5
! move %o5(lower) -> %o4(lower)
srl %o5, 0, %l6
or %l6, %o4, %o4
!---- flushing int results buffer----
mov %o0, %l5
mov %o1, %l5
mov %o2, %l5
mov %o3, %l5
mov %o4, %l5
add   %l4, 1, %l4

P3106: !_LD [8] (FP)
ld [%i1 + 256], %f15
! 1 addresses covered
!---- flushing fp results buffer to %f30 ----
fmovd %f0, %f30
fmovd %f2, %f30
fmovd %f4, %f30
fmovd %f6, %f30
fmovd %f8, %f30
fmovd %f10, %f30
fmovd %f12, %f30
fmovd %f14, %f30

P3107: !_PREFETCH [11] (Int) (CBR) (Branch target of P4004)
prefetch [%i2 + 64], 1

! cbranch
andcc %l0, 1, %g0
be,pt  %xcc, TARGET3107
nop
RET3107:

! lfsr step begin
srlx %l0, 1, %l3
xnor %l3, %l0, %l3
sllx %l3, 63, %l3
or  %l3, %l0, %l0
srlx %l0, 1, %l0

ba P3108
nop

TARGET4004:
ba RET4004
nop


P3108: !_DWST [5] (maybe <- 0x4100000c) (FP)
! 0 th moved, current_fp_src=21 
fmovs  %f16, %f21
fadds  %f16, %f17, %f16
std %f20, [%i1 + 72]

P3109: !_REPLACEMENT [14] (Int)
sethi %hi(0x80), %l3
or %l3, %lo(0x80),  %l3
sethi %hi(0x10000), %l6
or %l6, %lo(0x10000),  %l6
add %i3, %l3, %l3
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]

P3110: !_DWLD [8] (FP)
ldd [%i1 + 256], %f0
! 1 addresses covered

P3111: !_DWST [11] (maybe <- 0x4100000d) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
std %f20, [%i2 + 64]

P3112: !_ST [4] (maybe <- 0x4100000e) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i0 + 64 ]

P3113: !_REPLACEMENT [8] (Int)
sethi %hi(0x100), %l6
or %l6, %lo(0x100),  %l6
sethi %hi(0x10000), %l7
or %l7, %lo(0x10000),  %l7
add %i3, %l6, %l6
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]

P3114: !_PREFETCH [13] (Int)
prefetch [%i3 + 64], 1

P3115: !_PREFETCH [0] (Int)
prefetch [%i0 + 0], 1

P3116: !_DWLD [12] (FP)
ldd [%i3 + 0], %f18
! 1 addresses covered
fmovs %f18, %f1

P3117: !_DWST [12] (maybe <- 0x4100000f) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
std %f20, [%i3 + 0]

P3118: !_REPLACEMENT [13] (Int)
sethi %hi(0x40), %o5
or %o5, %lo(0x40),  %o5
sethi %hi(0x10000), %l3
or %l3, %lo(0x10000),  %l3
add %i3, %o5, %o5
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]

P3119: !_LD [4] (FP)
ld [%i0 + 64], %f2
! 1 addresses covered

P3120: !_CAS [6] (maybe <- 0x1800007) (Int)
add %i1, 80, %o5
lduw [%o5], %o0
mov %o0, %l7
! move %l7(lower) -> %o0(upper)
sllx %l7, 32, %o0
mov %l4, %l6
cas [%o5], %l7, %l6
! move %l6(lower) -> %o0(lower)
srl %l6, 0, %o5
or %o5, %o0, %o0
add   %l4, 1, %l4

P3121: !_LD [0] (FP) (Branch target of P4028)
ld [%i0 + 0], %f3
! 1 addresses covered
ba P3122
nop

TARGET4028:
ba RET4028
nop


P3122: !_LD [10] (FP)
ld [%i2 + 32], %f4
! 1 addresses covered

P3123: !_SWAP [10] (maybe <- 0x1800008) (Int)
mov %l4, %o1
swap  [%i2 + 32], %o1
! move %o1(lower) -> %o1(upper)
sllx %o1, 32, %o1
add   %l4, 1, %l4

P3124: !_REPLACEMENT [5] (Int)
sethi %hi(0x4c), %l6
or %l6, %lo(0x4c),  %l6
sethi %hi(0x10000), %l7
or %l7, %lo(0x10000),  %l7
add %i3, %l6, %l6
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]

P3125: !_PREFETCH [12] (Int)
prefetch [%i3 + 0], 1

P3126: !_DWLD [12] (FP)
ldd [%i3 + 0], %f18
! 1 addresses covered
fmovs %f18, %f5

P3127: !_PREFETCH [10] (Int)
prefetch [%i2 + 32], 1

P3128: !_REPLACEMENT [13] (Int)
sethi %hi(0x40), %l3
or %l3, %lo(0x40),  %l3
sethi %hi(0x10000), %l6
or %l6, %lo(0x10000),  %l6
add %i3, %l3, %l3
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]

P3129: !_LD [12] (FP) (Branch target of P3148)
ld [%i3 + 0], %f6
! 1 addresses covered
ba P3130
nop

TARGET3148:
ba RET3148
nop


P3130: !_NOP (Int)
nop

P3131: !_DWST [2] (maybe <- 0x41000010) (FP)
! 0 th moved, current_fp_src=21 
fmovs  %f16, %f21
fadds  %f16, %f17, %f16
std %f20, [%i0 + 8]

P3132: !_REPLACEMENT [7] (Int)
sethi %hi(0x54), %l7
or %l7, %lo(0x54),  %l7
sethi %hi(0x10000), %o5
or %o5, %lo(0x10000),  %o5
add %i3, %l7, %l7
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]

P3133: !_DWLD [5] (FP)
ldd [%i1 + 72], %f18
! 1 addresses covered
fmovs %f19, %f7

P3134: !_REPLACEMENT [2] (Int)
sethi %hi(0xc), %l6
or %l6, %lo(0xc),  %l6
sethi %hi(0x10000), %l7
or %l7, %lo(0x10000),  %l7
add %i3, %l6, %l6
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]

P3135: !_NOP (Int)
nop

P3136: !_ST [7] (maybe <- 0x41000011) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i1 + 84 ]

P3137: !_ST [9] (maybe <- 0x41000012) (FP) (Branch target of P3684)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i1 + 512 ]
ba P3138
nop

TARGET3684:
ba RET3684
nop


P3138: !_LD [4] (FP)
ld [%i0 + 64], %f8
! 1 addresses covered

P3139: !_CASX [13] (maybe <- 0x1800009) (Int)
add %i3, 64, %o5
ldx [%o5], %l6
! move %l6(upper) -> %o1(lower)
srlx %l6, 32, %l7
or %l7, %o1, %o1
! move %l6(lower) -> %o2(upper)
sllx %l6, 32, %o2
mov  %l6, %l7
sllx %l4, 32, %l6
casx [%o5], %l7, %l6
! move %l6(upper) -> %o2(lower)
srlx %l6, 32, %o5
or %o5, %o2, %o2
! move %l6(lower) -> %o3(upper)
sllx %l6, 32, %o3
add  %l4, 1, %l4

P3140: !_PREFETCH [8] (Int)
prefetch [%i1 + 256], 1

P3141: !_CASX [15] (maybe <- 0x180000a) (Int)
add %i3, 192, %o5
ldx [%o5], %l6
! move %l6(upper) -> %o3(lower)
srlx %l6, 32, %l7
or %l7, %o3, %o3
! move %l6(lower) -> %o4(upper)
sllx %l6, 32, %o4
mov  %l6, %l7
sllx %l4, 32, %l6
casx [%o5], %l7, %l6
! move %l6(upper) -> %o4(lower)
srlx %l6, 32, %o5
or %o5, %o4, %o4
!---- flushing int results buffer----
mov %o0, %l5
mov %o1, %l5
mov %o2, %l5
mov %o3, %l5
mov %o4, %l5
! move %l6(lower) -> %o0(upper)
sllx %l6, 32, %o0
add  %l4, 1, %l4

P3142: !_ST [13] (maybe <- 0x41000013) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i3 + 64 ]

P3143: !_REPLACEMENT [1] (Int)
sethi %hi(0x4), %l6
or %l6, %lo(0x4),  %l6
sethi %hi(0x10000), %l7
or %l7, %lo(0x10000),  %l7
add %i3, %l6, %l6
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]

P3144: !_CASX [9] (maybe <- 0x180000b) (Int)
add %i1, 512, %l6
ldx [%l6], %o5
! move %o5(upper) -> %o0(lower)
srlx %o5, 32, %l3
or %l3, %o0, %o0
! move %o5(lower) -> %o1(upper)
sllx %o5, 32, %o1
mov  %o5, %l3
sllx %l4, 32, %o5
casx [%l6], %l3, %o5
! move %o5(upper) -> %o1(lower)
srlx %o5, 32, %l6
or %l6, %o1, %o1
! move %o5(lower) -> %o2(upper)
sllx %o5, 32, %o2
add  %l4, 1, %l4

P3145: !_LD [4] (FP)
ld [%i0 + 64], %f9
! 1 addresses covered

P3146: !_DWST [14] (maybe <- 0x41000014) (FP) (Branch target of P3584)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
std %f20, [%i3 + 128]
ba P3147
nop

TARGET3584:
ba RET3584
nop


P3147: !_DWLD [7] (FP)
ldd [%i1 + 80], %f10
! 2 addresses covered

P3148: !_DWLD [14] (FP) (CBR) (Branch target of P3562)
ldd [%i3 + 128], %f12
! 1 addresses covered

! cbranch
andcc %l0, 1, %g0
be,pt  %xcc, TARGET3148
nop
RET3148:

! lfsr step begin
srlx %l0, 1, %o5
xnor %o5, %l0, %o5
sllx %o5, 63, %o5
or  %o5, %l0, %l0
srlx %l0, 1, %l0

ba P3149
nop

TARGET3562:
ba RET3562
nop


P3149: !_REPLACEMENT [8] (Int)
sethi %hi(0x100), %l3
or %l3, %lo(0x100),  %l3
sethi %hi(0x10000), %l6
or %l6, %lo(0x10000),  %l6
add %i3, %l3, %l3
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]

P3150: !_DWST [0] (maybe <- 0x41000015) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
! 1 th moved, current_fp_src=21 
fmovs  %f16, %f21
fadds  %f16, %f17, %f16
std %f20, [%i0 + 0]

P3151: !_REPLACEMENT [4] (Int) (CBR)
sethi %hi(0x40), %l7
or %l7, %lo(0x40),  %l7
sethi %hi(0x10000), %o5
or %o5, %lo(0x10000),  %o5
add %i3, %l7, %l7
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]

! cbranch
andcc %l0, 1, %g0
be,pt  %xcc, TARGET3151
nop
RET3151:

! lfsr step begin
srlx %l0, 1, %l6
xnor %l6, %l0, %l6
sllx %l6, 63, %l6
or  %l6, %l0, %l0
srlx %l0, 1, %l0


P3152: !_DWLD [7] (FP)
ldd [%i1 + 80], %f18
! 2 addresses covered
fmovs %f18, %f13
fmovs %f19, %f14

P3153: !_ST [1] (maybe <- 0x41000017) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i0 + 4 ]

P3154: !_ST [6] (maybe <- 0x41000018) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i1 + 80 ]

P3155: !_LD [3] (FP)
ld [%i0 + 32], %f15
! 1 addresses covered
!---- flushing fp results buffer to %f30 ----
fmovd %f0, %f30
fmovd %f2, %f30
fmovd %f4, %f30
fmovd %f6, %f30
fmovd %f8, %f30
fmovd %f10, %f30
fmovd %f12, %f30
fmovd %f14, %f30

P3156: !_DWLD [5] (FP)
ldd [%i1 + 72], %f0
! 1 addresses covered
fmovs %f1, %f0

P3157: !_DWLD [8] (FP)
ldd [%i1 + 256], %f18
! 1 addresses covered
fmovs %f18, %f1

P3158: !_DWST [2] (maybe <- 0x41000019) (FP)
! 0 th moved, current_fp_src=21 
fmovs  %f16, %f21
fadds  %f16, %f17, %f16
std %f20, [%i0 + 8]

P3159: !_ST [14] (maybe <- 0x4100001a) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i3 + 128 ]

P3160: !_ST [13] (maybe <- 0x4100001b) (FP) (Branch target of P3618)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i3 + 64 ]
ba P3161
nop

TARGET3618:
ba RET3618
nop


P3161: !_DWLD [5] (FP)
ldd [%i1 + 72], %f2
! 1 addresses covered
fmovs %f3, %f2

P3162: !_DWLD [11] (FP)
ldd [%i2 + 64], %f18
! 1 addresses covered
fmovs %f18, %f3

P3163: !_PREFETCH [4] (Int)
prefetch [%i0 + 64], 1

P3164: !_LD [15] (FP)
ld [%i3 + 192], %f4
! 1 addresses covered

P3165: !_PREFETCH [6] (Int)
prefetch [%i1 + 80], 1

P3166: !_LD [8] (FP)
ld [%i1 + 256], %f5
! 1 addresses covered

P3167: !_DWLD [13] (FP)
ldd [%i3 + 64], %f6
! 1 addresses covered

P3168: !_MEMBAR (Int)
membar #StoreLoad

P3169: !_DWST [4] (maybe <- 0x4100001c) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
std %f20, [%i0 + 64]

P3170: !_NOP (Int)
nop

P3171: !_PREFETCH [12] (Int)
prefetch [%i3 + 0], 1

P3172: !_ST [0] (maybe <- 0x4100001d) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i0 + 0 ]

P3173: !_REPLACEMENT [9] (Int)
sethi %hi(0x200), %o5
or %o5, %lo(0x200),  %o5
sethi %hi(0x10000), %l3
or %l3, %lo(0x10000),  %l3
add %i3, %o5, %o5
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]

P3174: !_LD [10] (FP)
ld [%i2 + 32], %f7
! 1 addresses covered

P3175: !_DWLD [8] (FP)
ldd [%i1 + 256], %f8
! 1 addresses covered

P3176: !_MEMBAR (Int)
membar #StoreLoad

P3177: !_ST [15] (maybe <- 0x4100001e) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i3 + 192 ]

P3178: !_LD [5] (FP)
ld [%i1 + 76], %f9
! 1 addresses covered

P3179: !_NOP (Int)
nop

P3180: !_CAS [6] (maybe <- 0x180000c) (Int)
add %i1, 80, %l7
lduw [%l7], %l3
mov %l3, %l6
! move %l6(lower) -> %o2(lower)
or %l6, %o2, %o2
mov %l4, %o3
cas [%l7], %l6, %o3
! move %o3(lower) -> %o3(upper)
sllx %o3, 32, %o3
add   %l4, 1, %l4

P3181: !_DWLD [11] (FP)
ldd [%i2 + 64], %f10
! 1 addresses covered

P3182: !_DWLD [12] (FP)
ldd [%i3 + 0], %f18
! 1 addresses covered
fmovs %f18, %f11

P3183: !_DWST [2] (maybe <- 0x4100001f) (FP)
! 0 th moved, current_fp_src=21 
fmovs  %f16, %f21
fadds  %f16, %f17, %f16
std %f20, [%i0 + 8]

P3184: !_SWAP [5] (maybe <- 0x180000d) (Int)
mov %l4, %l7
swap  [%i1 + 76], %l7
! move %l7(lower) -> %o3(lower)
srl %l7, 0, %l3
or %l3, %o3, %o3
add   %l4, 1, %l4

P3185: !_MEMBAR (Int)
membar #StoreLoad

P3186: !_SWAP [0] (maybe <- 0x180000e) (Int) (LE)
wr %g0, 0x88, %asi
mov %l4, %o4
! Change single-word-level endianess (big endian <-> little endian) 
sethi %hi(0xff00ff00), %o5
or %o5, %lo(0xff00ff00), %o5
and %o4, %o5, %l3
srl %l3, 8, %l3
sll %o4, 8, %o4
and %o4, %o5, %o4
or %o4, %l3, %o4
srl %o4, 16, %l3
sll %o4, 16, %o4
srl %o4, 0, %o4
or %o4, %l3, %o4
swapa  [%i0 + 0] %asi, %o4
! move %o4(lower) -> %o4(upper)
sllx %o4, 32, %o4
add   %l4, 1, %l4

P3187: !_ST [4] (maybe <- 0x41000020) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i0 + 64 ]

P3188: !_DWLD [2] (FP) (Branch target of P3740)
ldd [%i0 + 8], %f12
! 1 addresses covered
fmovs %f13, %f12
ba P3189
nop

TARGET3740:
ba RET3740
nop


P3189: !_REPLACEMENT [9] (Int)
sethi %hi(0x200), %l6
or %l6, %lo(0x200),  %l6
sethi %hi(0x10000), %l7
or %l7, %lo(0x10000),  %l7
add %i3, %l6, %l6
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]

P3190: !_DWLD [8] (FP)
ldd [%i1 + 256], %f18
! 1 addresses covered
fmovs %f18, %f13

P3191: !_PREFETCH [4] (Int) (LE)
wr %g0, 0x88, %asi
prefetcha [%i0 + 64] %asi, 1

P3192: !_DWLD [3] (FP)
ldd [%i0 + 32], %f14
! 1 addresses covered

P3193: !_DWST [0] (maybe <- 0x41000021) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
! 1 th moved, current_fp_src=21 
fmovs  %f16, %f21
fadds  %f16, %f17, %f16
std %f20, [%i0 + 0]

P3194: !_DWST [7] (maybe <- 0x41000023) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
! 1 th moved, current_fp_src=21 
fmovs  %f16, %f21
fadds  %f16, %f17, %f16
std %f20, [%i1 + 80]

P3195: !_ST [8] (maybe <- 0x41000025) (FP) (CBR)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i1 + 256 ]

! cbranch
andcc %l0, 1, %g0
be,pn  %xcc, TARGET3195
nop
RET3195:

! lfsr step begin
srlx %l0, 1, %l6
xnor %l6, %l0, %l6
sllx %l6, 63, %l6
or  %l6, %l0, %l0
srlx %l0, 1, %l0


P3196: !_DWST [14] (maybe <- 0x41000026) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
std %f20, [%i3 + 128]

P3197: !_REPLACEMENT [0] (Int)
sethi %hi(0x0), %l6
or %l6, %lo(0x0),  %l6
sethi %hi(0x10000), %l7
or %l7, %lo(0x10000),  %l7
add %i3, %l6, %l6
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]

P3198: !_DWST [13] (maybe <- 0x41000027) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
std %f20, [%i3 + 64]

P3199: !_DWST [13] (maybe <- 0x41000028) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
std %f20, [%i3 + 64]

P3200: !_PREFETCH [1] (Int)
prefetch [%i0 + 4], 1

P3201: !_DWST [1] (maybe <- 0x41000029) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
! 1 th moved, current_fp_src=21 
fmovs  %f16, %f21
fadds  %f16, %f17, %f16
std %f20, [%i0 + 0]

P3202: !_LD [0] (FP)
ld [%i0 + 0], %f15
! 1 addresses covered
!---- flushing fp results buffer to %f30 ----
fmovd %f0, %f30
fmovd %f2, %f30
fmovd %f4, %f30
fmovd %f6, %f30
fmovd %f8, %f30
fmovd %f10, %f30
fmovd %f12, %f30
fmovd %f14, %f30

P3203: !_DWLD [10] (FP)
ldd [%i2 + 32], %f0
! 1 addresses covered

P3204: !_MEMBAR (Int)
membar #StoreLoad

P3205: !_ST [10] (maybe <- 0x4100002b) (FP) (CBR)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i2 + 32 ]

! cbranch
andcc %l0, 1, %g0
be,pt  %xcc, TARGET3205
nop
RET3205:

! lfsr step begin
srlx %l0, 1, %l3
xnor %l3, %l0, %l3
sllx %l3, 63, %l3
or  %l3, %l0, %l0
srlx %l0, 1, %l0


P3206: !_REPLACEMENT [13] (Int)
sethi %hi(0x40), %l6
or %l6, %lo(0x40),  %l6
sethi %hi(0x10000), %l7
or %l7, %lo(0x10000),  %l7
add %i3, %l6, %l6
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]

P3207: !_DWLD [13] (FP)
ldd [%i3 + 64], %f18
! 1 addresses covered
fmovs %f18, %f1

P3208: !_SWAP [14] (maybe <- 0x180000f) (Int)
mov %l4, %l7
swap  [%i3 + 128], %l7
! move %l7(lower) -> %o4(lower)
srl %l7, 0, %l3
or %l3, %o4, %o4
!---- flushing int results buffer----
mov %o0, %l5
mov %o1, %l5
mov %o2, %l5
mov %o3, %l5
mov %o4, %l5
add   %l4, 1, %l4

P3209: !_MEMBAR (Int)
membar #StoreLoad

P3210: !_ST [14] (maybe <- 0x4100002c) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i3 + 128 ]

P3211: !_REPLACEMENT [11] (Int) (CBR)
sethi %hi(0x40), %l7
or %l7, %lo(0x40),  %l7
sethi %hi(0x10000), %o5
or %o5, %lo(0x10000),  %o5
add %i3, %l7, %l7
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]

! cbranch
andcc %l0, 1, %g0
be,pn  %xcc, TARGET3211
nop
RET3211:

! lfsr step begin
srlx %l0, 1, %l6
xnor %l6, %l0, %l6
sllx %l6, 63, %l6
or  %l6, %l0, %l0
srlx %l0, 1, %l0


P3212: !_NOP (Int)
nop

P3213: !_SWAP [10] (maybe <- 0x1800010) (Int) (LE)
wr %g0, 0x88, %asi
mov %l4, %o0
! Change single-word-level endianess (big endian <-> little endian) 
sethi %hi(0xff00ff00), %l7
or %l7, %lo(0xff00ff00), %l7
and %o0, %l7, %o5
srl %o5, 8, %o5
sll %o0, 8, %o0
and %o0, %l7, %o0
or %o0, %o5, %o0
srl %o0, 16, %o5
sll %o0, 16, %o0
srl %o0, 0, %o0
or %o0, %o5, %o0
swapa  [%i2 + 32] %asi, %o0
! move %o0(lower) -> %o0(upper)
sllx %o0, 32, %o0
add   %l4, 1, %l4

P3214: !_PREFETCH [13] (Int) (CBR)
prefetch [%i3 + 64], 1

! cbranch
andcc %l0, 1, %g0
be,pt  %xcc, TARGET3214
nop
RET3214:

! lfsr step begin
srlx %l0, 1, %l6
xnor %l6, %l0, %l6
sllx %l6, 63, %l6
or  %l6, %l0, %l0
srlx %l0, 1, %l0


P3215: !_DWST [2] (maybe <- 0x4100002d) (FP)
! 0 th moved, current_fp_src=21 
fmovs  %f16, %f21
fadds  %f16, %f17, %f16
std %f20, [%i0 + 8]

P3216: !_REPLACEMENT [2] (Int)
sethi %hi(0xc), %l6
or %l6, %lo(0xc),  %l6
sethi %hi(0x10000), %l7
or %l7, %lo(0x10000),  %l7
add %i3, %l6, %l6
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]

P3217: !_DWLD [4] (FP)
ldd [%i0 + 64], %f2
! 1 addresses covered

P3218: !_MEMBAR (Int)
membar #StoreLoad

P3219: !_ST [4] (maybe <- 0x4100002e) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i0 + 64 ]

P3220: !_PREFETCH [3] (Int)
prefetch [%i0 + 32], 1

P3221: !_DWST [4] (maybe <- 0x4100002f) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
std %f20, [%i0 + 64]

P3222: !_ST [1] (maybe <- 0x41000030) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i0 + 4 ]

P3223: !_DWST [8] (maybe <- 0x41000031) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
std %f20, [%i1 + 256]

P3224: !_SWAP [13] (maybe <- 0x1800011) (Int)
mov %l4, %l7
swap  [%i3 + 64], %l7
! move %l7(lower) -> %o0(lower)
srl %l7, 0, %l3
or %l3, %o0, %o0
add   %l4, 1, %l4

P3225: !_DWLD [0] (FP)
ldd [%i0 + 0], %f18
! 2 addresses covered
fmovs %f18, %f3
fmovs %f19, %f4

P3226: !_CAS [9] (maybe <- 0x1800012) (Int)
add %i1, 512, %l3
lduw [%l3], %o1
mov %o1, %o5
! move %o5(lower) -> %o1(upper)
sllx %o5, 32, %o1
mov %l4, %l7
cas [%l3], %o5, %l7
! move %l7(lower) -> %o1(lower)
srl %l7, 0, %l3
or %l3, %o1, %o1
add   %l4, 1, %l4

P3227: !_DWLD [9] (FP)
ldd [%i1 + 512], %f18
! 1 addresses covered
fmovs %f18, %f5

P3228: !_PREFETCH [10] (Int)
prefetch [%i2 + 32], 1

P3229: !_REPLACEMENT [11] (Int)
sethi %hi(0x40), %o5
or %o5, %lo(0x40),  %o5
sethi %hi(0x10000), %l3
or %l3, %lo(0x10000),  %l3
add %i3, %o5, %o5
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]

P3230: !_LD [1] (FP)
ld [%i0 + 4], %f6
! 1 addresses covered

P3231: !_SWAP [15] (maybe <- 0x1800013) (Int)
mov %l4, %o2
swap  [%i3 + 192], %o2
! move %o2(lower) -> %o2(upper)
sllx %o2, 32, %o2
add   %l4, 1, %l4

P3232: !_CASX [6] (maybe <- 0x1800014) (Int) (Branch target of P3351)
add %i1, 80, %l7
ldx [%l7], %l3
! move %l3(upper) -> %o2(lower)
srlx %l3, 32, %l6
or %l6, %o2, %o2
! move %l3(lower) -> %o3(upper)
sllx %l3, 32, %o3
mov %l3, %l6
sllx %l4, 32, %l3
add  %l4, 1, %l4
or   %l4, %l3, %l3
casx [%l7], %l6, %l3
! move %l3(upper) -> %o3(lower)
srlx %l3, 32, %l7
or %l7, %o3, %o3
! move %l3(lower) -> %o4(upper)
sllx %l3, 32, %o4
add  %l4, 1, %l4
ba P3233
nop

TARGET3351:
ba RET3351
nop


P3233: !_LD [12] (FP) (CBR) (Branch target of P3340)
ld [%i3 + 0], %f7
! 1 addresses covered

! cbranch
andcc %l0, 1, %g0
be,pt  %xcc, TARGET3233
nop
RET3233:

! lfsr step begin
srlx %l0, 1, %l6
xnor %l6, %l0, %l6
sllx %l6, 63, %l6
or  %l6, %l0, %l0
srlx %l0, 1, %l0

ba P3234
nop

TARGET3340:
ba RET3340
nop


P3234: !_PREFETCH [10] (Int)
prefetch [%i2 + 32], 1

P3235: !_DWST [10] (maybe <- 0x41000032) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
std %f20, [%i2 + 32]

P3236: !_DWLD [1] (FP)
ldd [%i0 + 0], %f8
! 2 addresses covered

P3237: !_DWST [14] (maybe <- 0x41000033) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
std %f20, [%i3 + 128]

P3238: !_REPLACEMENT [2] (Int)
sethi %hi(0xc), %l3
or %l3, %lo(0xc),  %l3
sethi %hi(0x10000), %l6
or %l6, %lo(0x10000),  %l6
add %i3, %l3, %l3
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]

P3239: !_LD [0] (FP)
ld [%i0 + 0], %f10
! 1 addresses covered

P3240: !_ST [8] (maybe <- 0x41000034) (FP) (Branch target of P3874)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i1 + 256 ]
ba P3241
nop

TARGET3874:
ba RET3874
nop


P3241: !_REPLACEMENT [14] (Int)
sethi %hi(0x80), %l7
or %l7, %lo(0x80),  %l7
sethi %hi(0x10000), %o5
or %o5, %lo(0x10000),  %o5
add %i3, %l7, %l7
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]

P3242: !_LD [1] (FP)
ld [%i0 + 4], %f11
! 1 addresses covered

P3243: !_PREFETCH [3] (Int)
prefetch [%i0 + 32], 1

P3244: !_ST [9] (maybe <- 0x41000035) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i1 + 512 ]

P3245: !_LD [8] (FP)
ld [%i1 + 256], %f12
! 1 addresses covered

P3246: !_REPLACEMENT [15] (Int)
sethi %hi(0xc0), %l3
or %l3, %lo(0xc0),  %l3
sethi %hi(0x10000), %l6
or %l6, %lo(0x10000),  %l6
add %i3, %l3, %l3
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]

P3247: !_REPLACEMENT [4] (Int)
sethi %hi(0x40), %o5
or %o5, %lo(0x40),  %o5
sethi %hi(0x10000), %l3
or %l3, %lo(0x10000),  %l3
add %i3, %o5, %o5
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]

P3248: !_DWST [7] (maybe <- 0x41000036) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
! 1 th moved, current_fp_src=21 
fmovs  %f16, %f21
fadds  %f16, %f17, %f16
std %f20, [%i1 + 80]

P3249: !_REPLACEMENT [5] (Int) (CBR)
sethi %hi(0x4c), %l6
or %l6, %lo(0x4c),  %l6
sethi %hi(0x10000), %l7
or %l7, %lo(0x10000),  %l7
add %i3, %l6, %l6
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]

! cbranch
andcc %l0, 1, %g0
be,pn  %xcc, TARGET3249
nop
RET3249:

! lfsr step begin
srlx %l0, 1, %l3
xnor %l3, %l0, %l3
sllx %l3, 63, %l3
or  %l3, %l0, %l0
srlx %l0, 1, %l0


P3250: !_DWST [0] (maybe <- 0x41000038) (FP) (Branch target of P3464)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
! 1 th moved, current_fp_src=21 
fmovs  %f16, %f21
fadds  %f16, %f17, %f16
std %f20, [%i0 + 0]
ba P3251
nop

TARGET3464:
ba RET3464
nop


P3251: !_ST [7] (maybe <- 0x4100003a) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i1 + 84 ]

P3252: !_ST [1] (maybe <- 0x4100003b) (FP) (Branch target of P3107)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i0 + 4 ]
ba P3253
nop

TARGET3107:
ba RET3107
nop


P3253: !_SWAP [7] (maybe <- 0x1800016) (Int)
mov %l4, %l3
swap  [%i1 + 84], %l3
! move %l3(lower) -> %o4(lower)
srl %l3, 0, %l7
or %l7, %o4, %o4
!---- flushing int results buffer----
mov %o0, %l5
mov %o1, %l5
mov %o2, %l5
mov %o3, %l5
mov %o4, %l5
add   %l4, 1, %l4

P3254: !_REPLACEMENT [11] (Int)
sethi %hi(0x40), %l6
or %l6, %lo(0x40),  %l6
sethi %hi(0x10000), %l7
or %l7, %lo(0x10000),  %l7
add %i3, %l6, %l6
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]

P3255: !_PREFETCH [2] (Int)
prefetch [%i0 + 12], 1

P3256: !_DWLD [13] (FP)
ldd [%i3 + 64], %f18
! 1 addresses covered
fmovs %f18, %f13

P3257: !_ST [3] (maybe <- 0x4100003c) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i0 + 32 ]

P3258: !_REPLACEMENT [12] (Int)
sethi %hi(0x0), %o5
or %o5, %lo(0x0),  %o5
sethi %hi(0x10000), %l3
or %l3, %lo(0x10000),  %l3
add %i3, %o5, %o5
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]

P3259: !_DWLD [8] (FP)
ldd [%i1 + 256], %f14
! 1 addresses covered

P3260: !_PREFETCH [10] (Int)
prefetch [%i2 + 32], 1

P3261: !_DWST [15] (maybe <- 0x4100003d) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
std %f20, [%i3 + 192]

P3262: !_LD [2] (FP)
ld [%i0 + 12], %f15
! 1 addresses covered
!---- flushing fp results buffer to %f30 ----
fmovd %f0, %f30
fmovd %f2, %f30
fmovd %f4, %f30
fmovd %f6, %f30
fmovd %f8, %f30
fmovd %f10, %f30
fmovd %f12, %f30
fmovd %f14, %f30

P3263: !_ST [5] (maybe <- 0x4100003e) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i1 + 76 ]

P3264: !_DWLD [14] (FP)
ldd [%i3 + 128], %f0
! 1 addresses covered

P3265: !_CASX [9] (maybe <- 0x1800017) (Int)
add %i1, 512, %l6
ldx [%l6], %o0
! move %o0(upper) -> %o0(upper)
! move %o0(lower) -> %o0(lower)
mov  %o0, %l3
sllx %l4, 32, %o1
casx [%l6], %l3, %o1
! move %o1(upper) -> %o1(upper)
! move %o1(lower) -> %o1(lower)
add  %l4, 1, %l4

P3266: !_REPLACEMENT [12] (Int)
sethi %hi(0x0), %l3
or %l3, %lo(0x0),  %l3
sethi %hi(0x10000), %l6
or %l6, %lo(0x10000),  %l6
add %i3, %l3, %l3
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]

P3267: !_REPLACEMENT [4] (Int)
sethi %hi(0x40), %o5
or %o5, %lo(0x40),  %o5
sethi %hi(0x10000), %l3
or %l3, %lo(0x10000),  %l3
add %i3, %o5, %o5
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]

P3268: !_DWLD [0] (FP)
ldd [%i0 + 0], %f18
! 2 addresses covered
fmovs %f18, %f1
fmovs %f19, %f2

P3269: !_LD [13] (FP)
ld [%i3 + 64], %f3
! 1 addresses covered

P3270: !_DWST [7] (maybe <- 0x4100003f) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
! 1 th moved, current_fp_src=21 
fmovs  %f16, %f21
fadds  %f16, %f17, %f16
std %f20, [%i1 + 80]

P3271: !_ST [8] (maybe <- 0x41000041) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i1 + 256 ]

P3272: !_LD [2] (FP)
ld [%i0 + 12], %f4
! 1 addresses covered

P3273: !_ST [15] (maybe <- 0x41000042) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i3 + 192 ]

P3274: !_PREFETCH [4] (Int)
prefetch [%i0 + 64], 1

P3275: !_DWLD [2] (FP)
ldd [%i0 + 8], %f18
! 1 addresses covered
fmovs %f19, %f5

P3276: !_REPLACEMENT [11] (Int)
sethi %hi(0x40), %o5
or %o5, %lo(0x40),  %o5
sethi %hi(0x10000), %l3
or %l3, %lo(0x10000),  %l3
add %i3, %o5, %o5
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]

P3277: !_DWLD [6] (FP)
ldd [%i1 + 80], %f6
! 2 addresses covered

P3278: !_ST [15] (maybe <- 0x41000043) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i3 + 192 ]

P3279: !_DWLD [14] (FP) (CBR) (Branch target of P3279)
ldd [%i3 + 128], %f8
! 1 addresses covered

! cbranch
andcc %l0, 1, %g0
be,pt  %xcc, TARGET3279
nop
RET3279:

! lfsr step begin
srlx %l0, 1, %l6
xnor %l6, %l0, %l6
sllx %l6, 63, %l6
or  %l6, %l0, %l0
srlx %l0, 1, %l0

ba P3280
nop

TARGET3279:
ba RET3279
nop


P3280: !_LD [15] (FP)
ld [%i3 + 192], %f9
! 1 addresses covered

P3281: !_LD [13] (FP)
ld [%i3 + 64], %f10
! 1 addresses covered

P3282: !_DWST [3] (maybe <- 0x41000044) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
std %f20, [%i0 + 32]

P3283: !_CAS [11] (maybe <- 0x1800018) (Int)
add %i2, 64, %l7
lduw [%l7], %o2
mov %o2, %l6
! move %l6(lower) -> %o2(upper)
sllx %l6, 32, %o2
mov %l4, %l3
cas [%l7], %l6, %l3
! move %l3(lower) -> %o2(lower)
srl %l3, 0, %l7
or %l7, %o2, %o2
add   %l4, 1, %l4

P3284: !_NOP (Int)
nop

P3285: !_PREFETCH [12] (Int) (LE)
wr %g0, 0x88, %asi
prefetcha [%i3 + 0] %asi, 1

P3286: !_DWST [3] (maybe <- 0x41000045) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
std %f20, [%i0 + 32]

P3287: !_PREFETCH [4] (Int)
prefetch [%i0 + 64], 1

P3288: !_SWAP [15] (maybe <- 0x1800019) (Int) (CBR)
mov %l4, %o3
swap  [%i3 + 192], %o3
! move %o3(lower) -> %o3(upper)
sllx %o3, 32, %o3
add   %l4, 1, %l4

! cbranch
andcc %l0, 1, %g0
be,pn  %xcc, TARGET3288
nop
RET3288:

! lfsr step begin
srlx %l0, 1, %o5
xnor %o5, %l0, %o5
sllx %o5, 63, %o5
or  %o5, %l0, %l0
srlx %l0, 1, %l0


P3289: !_PREFETCH [11] (Int)
prefetch [%i2 + 64], 1

P3290: !_REPLACEMENT [10] (Int)
sethi %hi(0x20), %l3
or %l3, %lo(0x20),  %l3
sethi %hi(0x10000), %l6
or %l6, %lo(0x10000),  %l6
add %i3, %l3, %l3
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]

P3291: !_PREFETCH [0] (Int)
prefetch [%i0 + 0], 1

P3292: !_LD [3] (FP)
ld [%i0 + 32], %f11
! 1 addresses covered

P3293: !_PREFETCH [10] (Int)
prefetch [%i2 + 32], 1

P3294: !_PREFETCH [9] (Int)
prefetch [%i1 + 512], 1

P3295: !_LD [6] (FP)
ld [%i1 + 80], %f12
! 1 addresses covered

P3296: !_ST [12] (maybe <- 0x41000046) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i3 + 0 ]

P3297: !_ST [10] (maybe <- 0x41000047) (FP) (Branch target of P3103)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i2 + 32 ]
ba P3298
nop

TARGET3103:
ba RET3103
nop


P3298: !_CAS [10] (maybe <- 0x180001a) (Int)
add %i2, 32, %l7
lduw [%l7], %l3
mov %l3, %l6
! move %l6(lower) -> %o3(lower)
or %l6, %o3, %o3
mov %l4, %o4
cas [%l7], %l6, %o4
! move %o4(lower) -> %o4(upper)
sllx %o4, 32, %o4
add   %l4, 1, %l4

P3299: !_DWLD [13] (FP)
ldd [%i3 + 64], %f18
! 1 addresses covered
fmovs %f18, %f13

P3300: !_CAS [1] (maybe <- 0x180001b) (Int)
add %i0, 4, %l7
lduw [%l7], %l3
mov %l3, %l6
! move %l6(lower) -> %o4(lower)
or %l6, %o4, %o4
!---- flushing int results buffer----
mov %o0, %l5
mov %o1, %l5
mov %o2, %l5
mov %o3, %l5
mov %o4, %l5
mov %l4, %o0
cas [%l7], %l6, %o0
! move %o0(lower) -> %o0(upper)
sllx %o0, 32, %o0
add   %l4, 1, %l4

P3301: !_REPLACEMENT [5] (Int)
sethi %hi(0x4c), %l6
or %l6, %lo(0x4c),  %l6
sethi %hi(0x10000), %l7
or %l7, %lo(0x10000),  %l7
add %i3, %l6, %l6
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]

P3302: !_LD [13] (FP) (Branch target of P3305)
ld [%i3 + 64], %f14
! 1 addresses covered
ba P3303
nop

TARGET3305:
ba RET3305
nop


P3303: !_DWST [1] (maybe <- 0x41000048) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
! 1 th moved, current_fp_src=21 
fmovs  %f16, %f21
fadds  %f16, %f17, %f16
std %f20, [%i0 + 0]

P3304: !_LD [14] (FP)
ld [%i3 + 128], %f15
! 1 addresses covered
!---- flushing fp results buffer to %f30 ----
fmovd %f0, %f30
fmovd %f2, %f30
fmovd %f4, %f30
fmovd %f6, %f30
fmovd %f8, %f30
fmovd %f10, %f30
fmovd %f12, %f30
fmovd %f14, %f30

P3305: !_CAS [2] (maybe <- 0x180001c) (Int) (CBR)
add %i0, 12, %l3
lduw [%l3], %l7
mov %l7, %o5
! move %o5(lower) -> %o0(lower)
or %o5, %o0, %o0
mov %l4, %o1
cas [%l3], %o5, %o1
! move %o1(lower) -> %o1(upper)
sllx %o1, 32, %o1
add   %l4, 1, %l4

! cbranch
andcc %l0, 1, %g0
be,pn  %xcc, TARGET3305
nop
RET3305:

! lfsr step begin
srlx %l0, 1, %o5
xnor %o5, %l0, %o5
sllx %o5, 63, %o5
or  %o5, %l0, %l0
srlx %l0, 1, %l0


P3306: !_REPLACEMENT [6] (Int)
sethi %hi(0x50), %l3
or %l3, %lo(0x50),  %l3
sethi %hi(0x10000), %l6
or %l6, %lo(0x10000),  %l6
add %i3, %l3, %l3
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]

P3307: !_DWLD [4] (FP)
ldd [%i0 + 64], %f0
! 1 addresses covered

P3308: !_ST [4] (maybe <- 0x4100004a) (FP) (CBR) (Branch target of P3722)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i0 + 64 ]

! cbranch
andcc %l0, 1, %g0
be,pt  %xcc, TARGET3308
nop
RET3308:

! lfsr step begin
srlx %l0, 1, %l7
xnor %l7, %l0, %l7
sllx %l7, 63, %l7
or  %l7, %l0, %l0
srlx %l0, 1, %l0

ba P3309
nop

TARGET3722:
ba RET3722
nop


P3309: !_REPLACEMENT [9] (Int)
sethi %hi(0x200), %o5
or %o5, %lo(0x200),  %o5
sethi %hi(0x10000), %l3
or %l3, %lo(0x10000),  %l3
add %i3, %o5, %o5
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]

P3310: !_DWLD [15] (FP)
ldd [%i3 + 192], %f18
! 1 addresses covered
fmovs %f18, %f1

P3311: !_ST [13] (maybe <- 0x4100004b) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i3 + 64 ]

P3312: !_LD [11] (FP)
ld [%i2 + 64], %f2
! 1 addresses covered

P3313: !_PREFETCH [7] (Int)
prefetch [%i1 + 84], 1

P3314: !_REPLACEMENT [10] (Int)
sethi %hi(0x20), %l6
or %l6, %lo(0x20),  %l6
sethi %hi(0x10000), %l7
or %l7, %lo(0x10000),  %l7
add %i3, %l6, %l6
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]

P3315: !_ST [4] (maybe <- 0x4100004c) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i0 + 64 ]

P3316: !_ST [0] (maybe <- 0x4100004d) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i0 + 0 ]

P3317: !_DWST [8] (maybe <- 0x4100004e) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
std %f20, [%i1 + 256]

P3318: !_DWST [12] (maybe <- 0x4100004f) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
std %f20, [%i3 + 0]

P3319: !_DWLD [1] (FP)
ldd [%i0 + 0], %f18
! 2 addresses covered
fmovs %f18, %f3
fmovs %f19, %f4

P3320: !_CASX [3] (maybe <- 0x180001d) (Int)
add %i0, 32, %l6
ldx [%l6], %o5
! move %o5(upper) -> %o1(lower)
srlx %o5, 32, %l3
or %l3, %o1, %o1
! move %o5(lower) -> %o2(upper)
sllx %o5, 32, %o2
mov  %o5, %l3
sllx %l4, 32, %o5
casx [%l6], %l3, %o5
! move %o5(upper) -> %o2(lower)
srlx %o5, 32, %l6
or %l6, %o2, %o2
! move %o5(lower) -> %o3(upper)
sllx %o5, 32, %o3
add  %l4, 1, %l4

P3321: !_CAS [9] (maybe <- 0x180001e) (Int)
add %i1, 512, %l6
lduw [%l6], %o5
mov %o5, %l3
! move %l3(lower) -> %o3(lower)
or %l3, %o3, %o3
mov %l4, %o4
cas [%l6], %l3, %o4
! move %o4(lower) -> %o4(upper)
sllx %o4, 32, %o4
add   %l4, 1, %l4

P3322: !_LD [4] (FP)
ld [%i0 + 64], %f5
! 1 addresses covered

P3323: !_LD [5] (FP)
ld [%i1 + 76], %f6
! 1 addresses covered

P3324: !_REPLACEMENT [0] (Int)
sethi %hi(0x0), %l3
or %l3, %lo(0x0),  %l3
sethi %hi(0x10000), %l6
or %l6, %lo(0x10000),  %l6
add %i3, %l3, %l3
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]

P3325: !_DWLD [4] (FP)
ldd [%i0 + 64], %f18
! 1 addresses covered
fmovs %f18, %f7

P3326: !_REPLACEMENT [8] (Int)
sethi %hi(0x100), %o5
or %o5, %lo(0x100),  %o5
sethi %hi(0x10000), %l3
or %l3, %lo(0x10000),  %l3
add %i3, %o5, %o5
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]

P3327: !_PREFETCH [10] (Int)
prefetch [%i2 + 32], 1

P3328: !_REPLACEMENT [2] (Int)
sethi %hi(0xc), %l7
or %l7, %lo(0xc),  %l7
sethi %hi(0x10000), %o5
or %o5, %lo(0x10000),  %o5
add %i3, %l7, %l7
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]

P3329: !_REPLACEMENT [0] (Int) (Branch target of P3908)
sethi %hi(0x0), %l6
or %l6, %lo(0x0),  %l6
sethi %hi(0x10000), %l7
or %l7, %lo(0x10000),  %l7
add %i3, %l6, %l6
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
ba P3330
nop

TARGET3908:
ba RET3908
nop


P3330: !_ST [10] (maybe <- 0x41000050) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i2 + 32 ]

P3331: !_DWLD [3] (FP)
ldd [%i0 + 32], %f8
! 1 addresses covered

P3332: !_DWST [3] (maybe <- 0x41000051) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
std %f20, [%i0 + 32]

P3333: !_CAS [2] (maybe <- 0x180001f) (Int) (LE)
! Change single-word-level endianess (big endian <-> little endian) 
sethi %hi(0xff00ff00), %o5
or %o5, %lo(0xff00ff00), %o5
and %l4, %o5, %l7
srl %l7, 8, %l7
sll %l4, 8, %l3
and %l3, %o5, %l3
or %l3, %l7, %l3
srl %l3, 16, %l7
sll %l3, 16, %l3
srl %l3, 0, %l3
or %l3, %l7, %l3
wr %g0, 0x88, %asi
add %i0, 12, %o5
lduwa [%o5] %asi, %l6
mov %l6, %l7
! move %l7(lower) -> %o4(lower)
or %l7, %o4, %o4
!---- flushing int results buffer----
mov %o0, %l5
mov %o1, %l5
mov %o2, %l5
mov %o3, %l5
mov %o4, %l5
mov %l3, %o0
casa [%o5] %asi, %l7, %o0
! move %o0(lower) -> %o0(upper)
sllx %o0, 32, %o0
add   %l4, 1, %l4

P3334: !_REPLACEMENT [6] (Int)
sethi %hi(0x50), %l7
or %l7, %lo(0x50),  %l7
sethi %hi(0x10000), %o5
or %o5, %lo(0x10000),  %o5
add %i3, %l7, %l7
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]

P3335: !_DWST [0] (maybe <- 0x41000052) (FP) (Branch target of P3640)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
! 1 th moved, current_fp_src=21 
fmovs  %f16, %f21
fadds  %f16, %f17, %f16
std %f20, [%i0 + 0]
ba P3336
nop

TARGET3640:
ba RET3640
nop


P3336: !_ST [8] (maybe <- 0x41000054) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i1 + 256 ]

P3337: !_LD [1] (FP)
ld [%i0 + 4], %f9
! 1 addresses covered

P3338: !_DWLD [10] (FP)
ldd [%i2 + 32], %f10
! 1 addresses covered

P3339: !_REPLACEMENT [12] (Int)
sethi %hi(0x0), %o5
or %o5, %lo(0x0),  %o5
sethi %hi(0x10000), %l3
or %l3, %lo(0x10000),  %l3
add %i3, %o5, %o5
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]

P3340: !_DWLD [8] (FP) (CBR)
ldd [%i1 + 256], %f18
! 1 addresses covered
fmovs %f18, %f11

! cbranch
andcc %l0, 1, %g0
be,pt  %xcc, TARGET3340
nop
RET3340:

! lfsr step begin
srlx %l0, 1, %l7
xnor %l7, %l0, %l7
sllx %l7, 63, %l7
or  %l7, %l0, %l0
srlx %l0, 1, %l0


P3341: !_DWST [9] (maybe <- 0x41000055) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
std %f20, [%i1 + 512]

P3342: !_SWAP [0] (maybe <- 0x1800020) (Int)
mov %l4, %l3
swap  [%i0 + 0], %l3
! move %l3(lower) -> %o0(lower)
srl %l3, 0, %l7
or %l7, %o0, %o0
add   %l4, 1, %l4

P3343: !_DWST [11] (maybe <- 0x41000056) (FP) (Branch target of P3682)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
std %f20, [%i2 + 64]
ba P3344
nop

TARGET3682:
ba RET3682
nop


P3344: !_CAS [10] (maybe <- 0x1800021) (Int)
add %i2, 32, %l6
lduw [%l6], %o1
mov %o1, %l3
! move %l3(lower) -> %o1(upper)
sllx %l3, 32, %o1
mov %l4, %o5
cas [%l6], %l3, %o5
! move %o5(lower) -> %o1(lower)
srl %o5, 0, %l6
or %l6, %o1, %o1
add   %l4, 1, %l4

P3345: !_LD [8] (FP)
ld [%i1 + 256], %f12
! 1 addresses covered

P3346: !_CAS [10] (maybe <- 0x1800022) (Int)
add %i2, 32, %l6
lduw [%l6], %o2
mov %o2, %l3
! move %l3(lower) -> %o2(upper)
sllx %l3, 32, %o2
mov %l4, %o5
cas [%l6], %l3, %o5
! move %o5(lower) -> %o2(lower)
srl %o5, 0, %l6
or %l6, %o2, %o2
add   %l4, 1, %l4

P3347: !_CAS [5] (maybe <- 0x1800023) (Int)
add %i1, 76, %l6
lduw [%l6], %o3
mov %o3, %l3
! move %l3(lower) -> %o3(upper)
sllx %l3, 32, %o3
mov %l4, %o5
cas [%l6], %l3, %o5
! move %o5(lower) -> %o3(lower)
srl %o5, 0, %l6
or %l6, %o3, %o3
add   %l4, 1, %l4

P3348: !_REPLACEMENT [4] (Int)
sethi %hi(0x40), %l3
or %l3, %lo(0x40),  %l3
sethi %hi(0x10000), %l6
or %l6, %lo(0x10000),  %l6
add %i3, %l3, %l3
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]

P3349: !_DWLD [7] (FP)
ldd [%i1 + 80], %f18
! 2 addresses covered
fmovs %f18, %f13
fmovs %f19, %f14

P3350: !_DWLD [14] (FP)
ldd [%i3 + 128], %f18
! 1 addresses covered
fmovs %f18, %f15
!---- flushing fp results buffer to %f30 ----
fmovd %f0, %f30
fmovd %f2, %f30
fmovd %f4, %f30
fmovd %f6, %f30
fmovd %f8, %f30
fmovd %f10, %f30
fmovd %f12, %f30
fmovd %f14, %f30

P3351: !_DWLD [2] (FP) (CBR)
ldd [%i0 + 8], %f0
! 1 addresses covered
fmovs %f1, %f0

! cbranch
andcc %l0, 1, %g0
be,pt  %xcc, TARGET3351
nop
RET3351:

! lfsr step begin
srlx %l0, 1, %o5
xnor %o5, %l0, %o5
sllx %o5, 63, %o5
or  %o5, %l0, %l0
srlx %l0, 1, %l0


P3352: !_SWAP [10] (maybe <- 0x1800024) (Int)
mov %l4, %o4
swap  [%i2 + 32], %o4
! move %o4(lower) -> %o4(upper)
sllx %o4, 32, %o4
add   %l4, 1, %l4

P3353: !_DWST [11] (maybe <- 0x41000057) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
std %f20, [%i2 + 64]

P3354: !_DWLD [14] (FP)
ldd [%i3 + 128], %f18
! 1 addresses covered
fmovs %f18, %f1

P3355: !_DWST [9] (maybe <- 0x41000058) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
std %f20, [%i1 + 512]

P3356: !_DWST [1] (maybe <- 0x41000059) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
! 1 th moved, current_fp_src=21 
fmovs  %f16, %f21
fadds  %f16, %f17, %f16
std %f20, [%i0 + 0]

P3357: !_LD [13] (FP)
ld [%i3 + 64], %f2
! 1 addresses covered

P3358: !_LD [0] (FP)
ld [%i0 + 0], %f3
! 1 addresses covered

P3359: !_ST [8] (maybe <- 0x4100005b) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i1 + 256 ]

P3360: !_CAS [2] (maybe <- 0x1800025) (Int) (Branch target of P3650)
add %i0, 12, %l3
lduw [%l3], %l7
mov %l7, %o5
! move %o5(lower) -> %o4(lower)
or %o5, %o4, %o4
!---- flushing int results buffer----
mov %o0, %l5
mov %o1, %l5
mov %o2, %l5
mov %o3, %l5
mov %o4, %l5
mov %l4, %o0
cas [%l3], %o5, %o0
! move %o0(lower) -> %o0(upper)
sllx %o0, 32, %o0
add   %l4, 1, %l4
ba P3361
nop

TARGET3650:
ba RET3650
nop


P3361: !_DWLD [7] (FP)
ldd [%i1 + 80], %f4
! 2 addresses covered

P3362: !_DWST [12] (maybe <- 0x4100005c) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
std %f20, [%i3 + 0]

P3363: !_LD [2] (FP)
ld [%i0 + 12], %f6
! 1 addresses covered

P3364: !_PREFETCH [4] (Int)
prefetch [%i0 + 64], 1

P3365: !_DWLD [5] (FP)
ldd [%i1 + 72], %f18
! 1 addresses covered
fmovs %f19, %f7

P3366: !_REPLACEMENT [12] (Int)
sethi %hi(0x0), %l7
or %l7, %lo(0x0),  %l7
sethi %hi(0x10000), %o5
or %o5, %lo(0x10000),  %o5
add %i3, %l7, %l7
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]

P3367: !_DWST [8] (maybe <- 0x4100005d) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
std %f20, [%i1 + 256]

P3368: !_PREFETCH [13] (Int)
prefetch [%i3 + 64], 1

P3369: !_PREFETCH [5] (Int)
prefetch [%i1 + 76], 1

P3370: !_DWST [2] (maybe <- 0x4100005e) (FP)
! 0 th moved, current_fp_src=21 
fmovs  %f16, %f21
fadds  %f16, %f17, %f16
std %f20, [%i0 + 8]

P3371: !_DWST [1] (maybe <- 0x4100005f) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
! 1 th moved, current_fp_src=21 
fmovs  %f16, %f21
fadds  %f16, %f17, %f16
std %f20, [%i0 + 0]

P3372: !_LD [10] (FP)
ld [%i2 + 32], %f8
! 1 addresses covered

P3373: !_ST [12] (maybe <- 0x41000061) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i3 + 0 ]

P3374: !_SWAP [6] (maybe <- 0x1800026) (Int)
mov %l4, %o5
swap  [%i1 + 80], %o5
! move %o5(lower) -> %o0(lower)
srl %o5, 0, %l6
or %l6, %o0, %o0
add   %l4, 1, %l4

P3375: !_DWST [15] (maybe <- 0x41000062) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
std %f20, [%i3 + 192]

P3376: !_DWLD [7] (FP) (Branch target of P3564)
ldd [%i1 + 80], %f18
! 2 addresses covered
fmovs %f18, %f9
fmovs %f19, %f10
ba P3377
nop

TARGET3564:
ba RET3564
nop


P3377: !_DWST [12] (maybe <- 0x41000063) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
std %f20, [%i3 + 0]

P3378: !_LD [2] (FP)
ld [%i0 + 12], %f11
! 1 addresses covered

P3379: !_CASX [9] (maybe <- 0x1800027) (Int)
add %i1, 512, %o5
ldx [%o5], %o1
! move %o1(upper) -> %o1(upper)
! move %o1(lower) -> %o1(lower)
mov  %o1, %l7
sllx %l4, 32, %o2
casx [%o5], %l7, %o2
! move %o2(upper) -> %o2(upper)
! move %o2(lower) -> %o2(lower)
add  %l4, 1, %l4

P3380: !_ST [3] (maybe <- 0x41000064) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i0 + 32 ]

P3381: !_LD [4] (FP)
ld [%i0 + 64], %f12
! 1 addresses covered

P3382: !_ST [13] (maybe <- 0x41000065) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i3 + 64 ]

P3383: !_MEMBAR (Int)
membar #StoreLoad

P3384: !_REPLACEMENT [4] (Int) (Branch target of P3997)
sethi %hi(0x40), %l3
or %l3, %lo(0x40),  %l3
sethi %hi(0x10000), %l6
or %l6, %lo(0x10000),  %l6
add %i3, %l3, %l3
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
ba P3385
nop

TARGET3997:
ba RET3997
nop


P3385: !_REPLACEMENT [11] (Int)
sethi %hi(0x40), %o5
or %o5, %lo(0x40),  %o5
sethi %hi(0x10000), %l3
or %l3, %lo(0x10000),  %l3
add %i3, %o5, %o5
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]

P3386: !_REPLACEMENT [7] (Int)
sethi %hi(0x54), %l7
or %l7, %lo(0x54),  %l7
sethi %hi(0x10000), %o5
or %o5, %lo(0x10000),  %o5
add %i3, %l7, %l7
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]

P3387: !_LD [11] (FP)
ld [%i2 + 64], %f13
! 1 addresses covered

P3388: !_ST [12] (maybe <- 0x41000066) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i3 + 0 ]

P3389: !_LD [3] (FP)
ld [%i0 + 32], %f14
! 1 addresses covered

P3390: !_PREFETCH [4] (Int)
prefetch [%i0 + 64], 1

P3391: !_PREFETCH [11] (Int)
prefetch [%i2 + 64], 1

P3392: !_ST [13] (maybe <- 0x41000067) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i3 + 64 ]

P3393: !_DWST [7] (maybe <- 0x41000068) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
! 1 th moved, current_fp_src=21 
fmovs  %f16, %f21
fadds  %f16, %f17, %f16
std %f20, [%i1 + 80]

P3394: !_DWLD [4] (FP)
ldd [%i0 + 64], %f18
! 1 addresses covered
fmovs %f18, %f15
!---- flushing fp results buffer to %f30 ----
fmovd %f0, %f30
fmovd %f2, %f30
fmovd %f4, %f30
fmovd %f6, %f30
fmovd %f8, %f30
fmovd %f10, %f30
fmovd %f12, %f30
fmovd %f14, %f30

P3395: !_ST [4] (maybe <- 0x4100006a) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i0 + 64 ]

P3396: !_PREFETCH [3] (Int)
prefetch [%i0 + 32], 1

P3397: !_LD [5] (FP)
ld [%i1 + 76], %f0
! 1 addresses covered

P3398: !_CASX [15] (maybe <- 0x1800028) (Int) (LE)
! Change single-word-level endianess (big endian <-> little endian) 
sethi %hi(0xff00ff00), %l7
or %l7, %lo(0xff00ff00), %l7
and %l4, %l7, %l6
srl %l6, 8, %l6
sll %l4, 8, %o5
and %o5, %l7, %o5
or %o5, %l6, %o5
srl %o5, 16, %l6
sll %o5, 16, %o5
srl %o5, 0, %o5
or %o5, %l6, %o5
wr %g0, 0x88, %asi
add %i3, 192, %l7
ldxa [%l7] %asi, %l3
! move %l3(lower) -> %o3(upper)
sllx %l3, 32, %o3
! move %l3(upper) -> %o3(lower)
srlx %l3, 32, %l6
or %l6, %o3, %o3
mov  %l3, %l6
mov  %o5, %l3
casxa [%l7] %asi, %l6, %l3
! move %l3(lower) -> %o4(upper)
sllx %l3, 32, %o4
! move %l3(upper) -> %o4(lower)
srlx %l3, 32, %l7
or %l7, %o4, %o4
!---- flushing int results buffer----
mov %o0, %l5
mov %o1, %l5
mov %o2, %l5
mov %o3, %l5
mov %o4, %l5
add  %l4, 1, %l4

P3399: !_DWLD [7] (FP)
ldd [%i1 + 80], %f18
! 2 addresses covered
fmovs %f18, %f1
fmovs %f19, %f2

P3400: !_ST [11] (maybe <- 0x4100006b) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i2 + 64 ]

P3401: !_LD [5] (FP)
ld [%i1 + 76], %f3
! 1 addresses covered

P3402: !_ST [7] (maybe <- 0x4100006c) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i1 + 84 ]

P3403: !_LD [0] (FP)
ld [%i0 + 0], %f4
! 1 addresses covered

P3404: !_PREFETCH [6] (Int)
prefetch [%i1 + 80], 1

P3405: !_ST [3] (maybe <- 0x4100006d) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i0 + 32 ]

P3406: !_PREFETCH [13] (Int)
prefetch [%i3 + 64], 1

P3407: !_DWLD [15] (FP)
ldd [%i3 + 192], %f18
! 1 addresses covered
fmovs %f18, %f5

P3408: !_LD [4] (FP)
ld [%i0 + 64], %f6
! 1 addresses covered

P3409: !_DWST [15] (maybe <- 0x4100006e) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
std %f20, [%i3 + 192]

P3410: !_DWLD [8] (FP)
ldd [%i1 + 256], %f18
! 1 addresses covered
fmovs %f18, %f7

P3411: !_DWLD [3] (FP)
ldd [%i0 + 32], %f8
! 1 addresses covered

P3412: !_PREFETCH [8] (Int)
prefetch [%i1 + 256], 1

P3413: !_DWLD [6] (FP)
ldd [%i1 + 80], %f18
! 2 addresses covered
fmovs %f18, %f9
fmovs %f19, %f10

P3414: !_DWLD [10] (FP)
ldd [%i2 + 32], %f18
! 1 addresses covered
fmovs %f18, %f11

P3415: !_PREFETCH [10] (Int)
prefetch [%i2 + 32], 1

P3416: !_DWST [4] (maybe <- 0x4100006f) (FP) (CBR)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
std %f20, [%i0 + 64]

! cbranch
andcc %l0, 1, %g0
be,pn  %xcc, TARGET3416
nop
RET3416:

! lfsr step begin
srlx %l0, 1, %l3
xnor %l3, %l0, %l3
sllx %l3, 63, %l3
or  %l3, %l0, %l0
srlx %l0, 1, %l0


P3417: !_ST [9] (maybe <- 0x41000070) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i1 + 512 ]

P3418: !_PREFETCH [3] (Int)
prefetch [%i0 + 32], 1

P3419: !_ST [7] (maybe <- 0x41000071) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i1 + 84 ]

P3420: !_DWST [12] (maybe <- 0x41000072) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
std %f20, [%i3 + 0]

P3421: !_DWLD [10] (FP)
ldd [%i2 + 32], %f12
! 1 addresses covered

P3422: !_SWAP [14] (maybe <- 0x1800029) (Int)
mov %l4, %o0
swap  [%i3 + 128], %o0
! move %o0(lower) -> %o0(upper)
sllx %o0, 32, %o0
add   %l4, 1, %l4

P3423: !_PREFETCH [15] (Int)
prefetch [%i3 + 192], 1

P3424: !_DWST [2] (maybe <- 0x41000073) (FP)
! 0 th moved, current_fp_src=21 
fmovs  %f16, %f21
fadds  %f16, %f17, %f16
std %f20, [%i0 + 8]

P3425: !_DWST [15] (maybe <- 0x41000074) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
std %f20, [%i3 + 192]

P3426: !_REPLACEMENT [14] (Int)
sethi %hi(0x80), %o5
or %o5, %lo(0x80),  %o5
sethi %hi(0x10000), %l3
or %l3, %lo(0x10000),  %l3
add %i3, %o5, %o5
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]

P3427: !_DWLD [15] (FP)
ldd [%i3 + 192], %f18
! 1 addresses covered
fmovs %f18, %f13

P3428: !_LD [1] (FP) (CBR)
ld [%i0 + 4], %f14
! 1 addresses covered

! cbranch
andcc %l0, 1, %g0
be,pt  %xcc, TARGET3428
nop
RET3428:

! lfsr step begin
srlx %l0, 1, %l7
xnor %l7, %l0, %l7
sllx %l7, 63, %l7
or  %l7, %l0, %l0
srlx %l0, 1, %l0


P3429: !_DWST [10] (maybe <- 0x41000075) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
std %f20, [%i2 + 32]

P3430: !_DWST [6] (maybe <- 0x41000076) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
! 1 th moved, current_fp_src=21 
fmovs  %f16, %f21
fadds  %f16, %f17, %f16
std %f20, [%i1 + 80]

P3431: !_LD [4] (FP)
ld [%i0 + 64], %f15
! 1 addresses covered
!---- flushing fp results buffer to %f30 ----
fmovd %f0, %f30
fmovd %f2, %f30
fmovd %f4, %f30
fmovd %f6, %f30
fmovd %f8, %f30
fmovd %f10, %f30
fmovd %f12, %f30
fmovd %f14, %f30

P3432: !_CASX [1] (maybe <- 0x180002a) (Int)
add %i0, 0, %l7
ldx [%l7], %l3
! move %l3(upper) -> %o0(lower)
srlx %l3, 32, %l6
or %l6, %o0, %o0
! move %l3(lower) -> %o1(upper)
sllx %l3, 32, %o1
mov %l3, %l6
sllx %l4, 32, %l3
add  %l4, 1, %l4
or   %l4, %l3, %l3
casx [%l7], %l6, %l3
! move %l3(upper) -> %o1(lower)
srlx %l3, 32, %l7
or %l7, %o1, %o1
! move %l3(lower) -> %o2(upper)
sllx %l3, 32, %o2
add  %l4, 1, %l4

P3433: !_ST [4] (maybe <- 0x41000078) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i0 + 64 ]

P3434: !_ST [8] (maybe <- 0x41000079) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i1 + 256 ]

P3435: !_DWST [4] (maybe <- 0x4100007a) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
std %f20, [%i0 + 64]

P3436: !_CASX [0] (maybe <- 0x180002c) (Int)
add %i0, 0, %o5
ldx [%o5], %l6
! move %l6(upper) -> %o2(lower)
srlx %l6, 32, %l7
or %l7, %o2, %o2
! move %l6(lower) -> %o3(upper)
sllx %l6, 32, %o3
mov %l6, %l7
sllx %l4, 32, %l6
add  %l4, 1, %l4
or   %l4, %l6, %l6
casx [%o5], %l7, %l6
! move %l6(upper) -> %o3(lower)
srlx %l6, 32, %o5
or %o5, %o3, %o3
! move %l6(lower) -> %o4(upper)
sllx %l6, 32, %o4
add  %l4, 1, %l4

P3437: !_DWLD [2] (FP)
ldd [%i0 + 8], %f0
! 1 addresses covered
fmovs %f1, %f0

P3438: !_LD [0] (FP)
ld [%i0 + 0], %f1
! 1 addresses covered

P3439: !_DWLD [14] (FP)
ldd [%i3 + 128], %f2
! 1 addresses covered

P3440: !_NOP (Int)
nop

P3441: !_REPLACEMENT [9] (Int)
sethi %hi(0x200), %l7
or %l7, %lo(0x200),  %l7
sethi %hi(0x10000), %o5
or %o5, %lo(0x10000),  %o5
add %i3, %l7, %l7
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]

P3442: !_PREFETCH [7] (Int)
prefetch [%i1 + 84], 1

P3443: !_MEMBAR (Int)
membar #StoreLoad

P3444: !_DWLD [10] (FP)
ldd [%i2 + 32], %f18
! 1 addresses covered
fmovs %f18, %f3

P3445: !_PREFETCH [12] (Int)
prefetch [%i3 + 0], 1

P3446: !_DWST [1] (maybe <- 0x4100007b) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
! 1 th moved, current_fp_src=21 
fmovs  %f16, %f21
fadds  %f16, %f17, %f16
std %f20, [%i0 + 0]

P3447: !_REPLACEMENT [11] (Int)
sethi %hi(0x40), %l3
or %l3, %lo(0x40),  %l3
sethi %hi(0x10000), %l6
or %l6, %lo(0x10000),  %l6
add %i3, %l3, %l3
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]

P3448: !_ST [13] (maybe <- 0x4100007d) (FP) (CBR)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i3 + 64 ]

! cbranch
andcc %l0, 1, %g0
be,pt  %xcc, TARGET3448
nop
RET3448:

! lfsr step begin
srlx %l0, 1, %l7
xnor %l7, %l0, %l7
sllx %l7, 63, %l7
or  %l7, %l0, %l0
srlx %l0, 1, %l0


P3449: !_LD [2] (FP)
ld [%i0 + 12], %f4
! 1 addresses covered

P3450: !_PREFETCH [7] (Int)
prefetch [%i1 + 84], 1

P3451: !_PREFETCH [10] (Int)
prefetch [%i2 + 32], 1

P3452: !_DWLD [9] (FP)
ldd [%i1 + 512], %f18
! 1 addresses covered
fmovs %f18, %f5

P3453: !_REPLACEMENT [12] (Int)
sethi %hi(0x0), %o5
or %o5, %lo(0x0),  %o5
sethi %hi(0x10000), %l3
or %l3, %lo(0x10000),  %l3
add %i3, %o5, %o5
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]

P3454: !_PREFETCH [8] (Int)
prefetch [%i1 + 256], 1

P3455: !_LD [14] (FP)
ld [%i3 + 128], %f6
! 1 addresses covered

P3456: !_LD [1] (FP)
ld [%i0 + 4], %f7
! 1 addresses covered

P3457: !_CAS [14] (maybe <- 0x180002e) (Int)
add %i3, 128, %o5
lduw [%o5], %l6
mov %l6, %l7
! move %l7(lower) -> %o4(lower)
or %l7, %o4, %o4
!---- flushing int results buffer----
mov %o0, %l5
mov %o1, %l5
mov %o2, %l5
mov %o3, %l5
mov %o4, %l5
mov %l4, %o0
cas [%o5], %l7, %o0
! move %o0(lower) -> %o0(upper)
sllx %o0, 32, %o0
add   %l4, 1, %l4

P3458: !_PREFETCH [8] (Int)
prefetch [%i1 + 256], 1

P3459: !_DWST [15] (maybe <- 0x4100007e) (FP) (CBR)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
std %f20, [%i3 + 192]

! cbranch
andcc %l0, 1, %g0
be,pn  %xcc, TARGET3459
nop
RET3459:

! lfsr step begin
srlx %l0, 1, %l6
xnor %l6, %l0, %l6
sllx %l6, 63, %l6
or  %l6, %l0, %l0
srlx %l0, 1, %l0


P3460: !_PREFETCH [11] (Int)
prefetch [%i2 + 64], 1

P3461: !_DWLD [7] (FP)
ldd [%i1 + 80], %f8
! 2 addresses covered

P3462: !_CAS [10] (maybe <- 0x180002f) (Int)
add %i2, 32, %o5
lduw [%o5], %l6
mov %l6, %l7
! move %l7(lower) -> %o0(lower)
or %l7, %o0, %o0
mov %l4, %o1
cas [%o5], %l7, %o1
! move %o1(lower) -> %o1(upper)
sllx %o1, 32, %o1
add   %l4, 1, %l4

P3463: !_LD [14] (FP)
ld [%i3 + 128], %f10
! 1 addresses covered

P3464: !_REPLACEMENT [14] (Int) (CBR)
sethi %hi(0x80), %l7
or %l7, %lo(0x80),  %l7
sethi %hi(0x10000), %o5
or %o5, %lo(0x10000),  %o5
add %i3, %l7, %l7
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]

! cbranch
andcc %l0, 1, %g0
be,pn  %xcc, TARGET3464
nop
RET3464:

! lfsr step begin
srlx %l0, 1, %l6
xnor %l6, %l0, %l6
sllx %l6, 63, %l6
or  %l6, %l0, %l0
srlx %l0, 1, %l0


P3465: !_LD [14] (FP)
ld [%i3 + 128], %f11
! 1 addresses covered

P3466: !_NOP (Int)
nop

P3467: !_LD [11] (FP)
ld [%i2 + 64], %f12
! 1 addresses covered

P3468: !_ST [2] (maybe <- 0x4100007f) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i0 + 12 ]

P3469: !_DWST [11] (maybe <- 0x41000080) (FP) (Branch target of P3249)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
std %f20, [%i2 + 64]
ba P3470
nop

TARGET3249:
ba RET3249
nop


P3470: !_DWST [1] (maybe <- 0x41000081) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
! 1 th moved, current_fp_src=21 
fmovs  %f16, %f21
fadds  %f16, %f17, %f16
std %f20, [%i0 + 0]

P3471: !_ST [8] (maybe <- 0x41000083) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i1 + 256 ]

P3472: !_PREFETCH [6] (Int)
prefetch [%i1 + 80], 1

P3473: !_DWLD [15] (FP)
ldd [%i3 + 192], %f18
! 1 addresses covered
fmovs %f18, %f13

P3474: !_DWLD [14] (FP)
ldd [%i3 + 128], %f14
! 1 addresses covered

P3475: !_PREFETCH [15] (Int)
prefetch [%i3 + 192], 1

P3476: !_DWST [3] (maybe <- 0x41000084) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
std %f20, [%i0 + 32]

P3477: !_LD [12] (FP)
ld [%i3 + 0], %f15
! 1 addresses covered
!---- flushing fp results buffer to %f30 ----
fmovd %f0, %f30
fmovd %f2, %f30
fmovd %f4, %f30
fmovd %f6, %f30
fmovd %f8, %f30
fmovd %f10, %f30
fmovd %f12, %f30
fmovd %f14, %f30

P3478: !_LD [10] (FP)
ld [%i2 + 32], %f0
! 1 addresses covered

P3479: !_PREFETCH [3] (Int)
prefetch [%i0 + 32], 1

P3480: !_REPLACEMENT [5] (Int)
sethi %hi(0x4c), %l6
or %l6, %lo(0x4c),  %l6
sethi %hi(0x10000), %l7
or %l7, %lo(0x10000),  %l7
add %i3, %l6, %l6
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]

P3481: !_ST [6] (maybe <- 0x41000085) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i1 + 80 ]

P3482: !_LD [3] (FP)
ld [%i0 + 32], %f1
! 1 addresses covered

P3483: !_DWST [12] (maybe <- 0x41000086) (FP) (Branch target of P3288)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
std %f20, [%i3 + 0]
ba P3484
nop

TARGET3288:
ba RET3288
nop


P3484: !_PREFETCH [7] (Int)
prefetch [%i1 + 84], 1

P3485: !_LD [9] (FP) (CBR)
ld [%i1 + 512], %f2
! 1 addresses covered

! cbranch
andcc %l0, 1, %g0
be,pt  %xcc, TARGET3485
nop
RET3485:

! lfsr step begin
srlx %l0, 1, %l7
xnor %l7, %l0, %l7
sllx %l7, 63, %l7
or  %l7, %l0, %l0
srlx %l0, 1, %l0


P3486: !_SWAP [2] (maybe <- 0x1800030) (Int)
mov %l4, %l6
swap  [%i0 + 12], %l6
! move %l6(lower) -> %o1(lower)
srl %l6, 0, %o5
or %o5, %o1, %o1
add   %l4, 1, %l4

P3487: !_LD [15] (FP)
ld [%i3 + 192], %f3
! 1 addresses covered

P3488: !_DWST [14] (maybe <- 0x41000087) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
std %f20, [%i3 + 128]

P3489: !_DWST [9] (maybe <- 0x41000088) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
std %f20, [%i1 + 512]

P3490: !_NOP (Int)
nop

P3491: !_DWLD [0] (FP)
ldd [%i0 + 0], %f4
! 2 addresses covered

P3492: !_PREFETCH [4] (Int)
prefetch [%i0 + 64], 1

P3493: !_ST [9] (maybe <- 0x41000089) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i1 + 512 ]

P3494: !_DWLD [8] (FP) (Branch target of P3308)
ldd [%i1 + 256], %f6
! 1 addresses covered
ba P3495
nop

TARGET3308:
ba RET3308
nop


P3495: !_DWST [2] (maybe <- 0x4100008a) (FP)
! 0 th moved, current_fp_src=21 
fmovs  %f16, %f21
fadds  %f16, %f17, %f16
std %f20, [%i0 + 8]

P3496: !_REPLACEMENT [10] (Int)
sethi %hi(0x20), %l7
or %l7, %lo(0x20),  %l7
sethi %hi(0x10000), %o5
or %o5, %lo(0x10000),  %o5
add %i3, %l7, %l7
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]

P3497: !_PREFETCH [13] (Int)
prefetch [%i3 + 64], 1

P3498: !_MEMBAR (Int)
membar #StoreLoad

P3499: !_PREFETCH [3] (Int) (Branch target of P3459)
prefetch [%i0 + 32], 1
ba P3500
nop

TARGET3459:
ba RET3459
nop


P3500: !_DWLD [15] (FP)
ldd [%i3 + 192], %f18
! 1 addresses covered
fmovs %f18, %f7

P3501: !_CASX [13] (maybe <- 0x1800031) (Int)
add %i3, 64, %l7
ldx [%l7], %o2
! move %o2(upper) -> %o2(upper)
! move %o2(lower) -> %o2(lower)
mov  %o2, %l6
sllx %l4, 32, %o3
casx [%l7], %l6, %o3
! move %o3(upper) -> %o3(upper)
! move %o3(lower) -> %o3(lower)
add  %l4, 1, %l4

P3502: !_DWLD [13] (FP)
ldd [%i3 + 64], %f8
! 1 addresses covered

P3503: !_PREFETCH [4] (Int)
prefetch [%i0 + 64], 1

P3504: !_DWLD [14] (FP)
ldd [%i3 + 128], %f18
! 1 addresses covered
fmovs %f18, %f9

P3505: !_SWAP [8] (maybe <- 0x1800032) (Int)
mov %l4, %o4
swap  [%i1 + 256], %o4
! move %o4(lower) -> %o4(upper)
sllx %o4, 32, %o4
add   %l4, 1, %l4

P3506: !_MEMBAR (Int)
membar #StoreLoad

P3507: !_PREFETCH [8] (Int)
prefetch [%i1 + 256], 1

P3508: !_DWST [10] (maybe <- 0x4100008b) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
std %f20, [%i2 + 32]

P3509: !_REPLACEMENT [7] (Int)
sethi %hi(0x54), %o5
or %o5, %lo(0x54),  %o5
sethi %hi(0x10000), %l3
or %l3, %lo(0x10000),  %l3
add %i3, %o5, %o5
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]

P3510: !_REPLACEMENT [4] (Int)
sethi %hi(0x40), %l7
or %l7, %lo(0x40),  %l7
sethi %hi(0x10000), %o5
or %o5, %lo(0x10000),  %o5
add %i3, %l7, %l7
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]

P3511: !_ST [10] (maybe <- 0x4100008c) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i2 + 32 ]

P3512: !_LD [13] (FP)
ld [%i3 + 64], %f10
! 1 addresses covered

P3513: !_DWLD [13] (FP) (Branch target of P3730)
ldd [%i3 + 64], %f18
! 1 addresses covered
fmovs %f18, %f11
ba P3514
nop

TARGET3730:
ba RET3730
nop


P3514: !_LD [15] (FP)
ld [%i3 + 192], %f12
! 1 addresses covered

P3515: !_MEMBAR (Int)
membar #StoreLoad

P3516: !_ST [12] (maybe <- 0x4100008d) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i3 + 0 ]

P3517: !_CASX [11] (maybe <- 0x1800033) (Int)
add %i2, 64, %l3
ldx [%l3], %l7
! move %l7(upper) -> %o4(lower)
srlx %l7, 32, %o5
or %o5, %o4, %o4
!---- flushing int results buffer----
mov %o0, %l5
mov %o1, %l5
mov %o2, %l5
mov %o3, %l5
mov %o4, %l5
! move %l7(lower) -> %o0(upper)
sllx %l7, 32, %o0
mov  %l7, %o5
sllx %l4, 32, %l7
casx [%l3], %o5, %l7
! move %l7(upper) -> %o0(lower)
srlx %l7, 32, %l3
or %l3, %o0, %o0
! move %l7(lower) -> %o1(upper)
sllx %l7, 32, %o1
add  %l4, 1, %l4

P3518: !_LD [15] (FP)
ld [%i3 + 192], %f13
! 1 addresses covered

P3519: !_LD [11] (FP)
ld [%i2 + 64], %f14
! 1 addresses covered

P3520: !_REPLACEMENT [13] (Int)
sethi %hi(0x40), %o5
or %o5, %lo(0x40),  %o5
sethi %hi(0x10000), %l3
or %l3, %lo(0x10000),  %l3
add %i3, %o5, %o5
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]

P3521: !_LD [14] (FP)
ld [%i3 + 128], %f15
! 1 addresses covered
!---- flushing fp results buffer to %f30 ----
fmovd %f0, %f30
fmovd %f2, %f30
fmovd %f4, %f30
fmovd %f6, %f30
fmovd %f8, %f30
fmovd %f10, %f30
fmovd %f12, %f30
fmovd %f14, %f30

P3522: !_DWST [10] (maybe <- 0x4100008e) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
std %f20, [%i2 + 32]

P3523: !_DWST [6] (maybe <- 0x4100008f) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
! 1 th moved, current_fp_src=21 
fmovs  %f16, %f21
fadds  %f16, %f17, %f16
std %f20, [%i1 + 80]

P3524: !_LD [12] (FP)
ld [%i3 + 0], %f0
! 1 addresses covered

P3525: !_LD [3] (FP)
ld [%i0 + 32], %f1
! 1 addresses covered

P3526: !_PREFETCH [4] (Int)
prefetch [%i0 + 64], 1

P3527: !_MEMBAR (Int)
membar #StoreLoad

P3528: !_DWLD [7] (FP)
ldd [%i1 + 80], %f2
! 2 addresses covered

P3529: !_LD [6] (FP)
ld [%i1 + 80], %f4
! 1 addresses covered

P3530: !_CAS [7] (maybe <- 0x1800034) (Int)
add %i1, 84, %l6
lduw [%l6], %o5
mov %o5, %l3
! move %l3(lower) -> %o1(lower)
or %l3, %o1, %o1
mov %l4, %o2
cas [%l6], %l3, %o2
! move %o2(lower) -> %o2(upper)
sllx %o2, 32, %o2
add   %l4, 1, %l4

P3531: !_LD [4] (FP)
ld [%i0 + 64], %f5
! 1 addresses covered

P3532: !_LD [5] (FP)
ld [%i1 + 76], %f6
! 1 addresses covered

P3533: !_REPLACEMENT [10] (Int)
sethi %hi(0x20), %l3
or %l3, %lo(0x20),  %l3
sethi %hi(0x10000), %l6
or %l6, %lo(0x10000),  %l6
add %i3, %l3, %l3
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]

P3534: !_CAS [14] (maybe <- 0x1800035) (Int)
add %i3, 128, %l3
lduw [%l3], %l7
mov %l7, %o5
! move %o5(lower) -> %o2(lower)
or %o5, %o2, %o2
mov %l4, %o3
cas [%l3], %o5, %o3
! move %o3(lower) -> %o3(upper)
sllx %o3, 32, %o3
add   %l4, 1, %l4

P3535: !_DWLD [6] (FP)
ldd [%i1 + 80], %f18
! 2 addresses covered
fmovs %f18, %f7
fmovs %f19, %f8

P3536: !_CAS [5] (maybe <- 0x1800036) (Int)
add %i1, 76, %l3
lduw [%l3], %l7
mov %l7, %o5
! move %o5(lower) -> %o3(lower)
or %o5, %o3, %o3
mov %l4, %o4
cas [%l3], %o5, %o4
! move %o4(lower) -> %o4(upper)
sllx %o4, 32, %o4
add   %l4, 1, %l4

P3537: !_DWST [5] (maybe <- 0x41000091) (FP)
! 0 th moved, current_fp_src=21 
fmovs  %f16, %f21
fadds  %f16, %f17, %f16
std %f20, [%i1 + 72]

P3538: !_DWLD [1] (FP)
ldd [%i0 + 0], %f18
! 2 addresses covered
fmovs %f18, %f9
fmovs %f19, %f10

P3539: !_PREFETCH [3] (Int)
prefetch [%i0 + 32], 1

P3540: !_LD [12] (FP)
ld [%i3 + 0], %f11
! 1 addresses covered

P3541: !_ST [12] (maybe <- 0x41000092) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i3 + 0 ]

P3542: !_PREFETCH [1] (Int)
prefetch [%i0 + 4], 1

P3543: !_DWST [10] (maybe <- 0x41000093) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
std %f20, [%i2 + 32]

P3544: !_ST [6] (maybe <- 0x41000094) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i1 + 80 ]

P3545: !_ST [13] (maybe <- 0x41000095) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i3 + 64 ]

P3546: !_DWLD [1] (FP)
ldd [%i0 + 0], %f12
! 2 addresses covered

P3547: !_REPLACEMENT [1] (Int)
sethi %hi(0x4), %l7
or %l7, %lo(0x4),  %l7
sethi %hi(0x10000), %o5
or %o5, %lo(0x10000),  %o5
add %i3, %l7, %l7
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]

P3548: !_CAS [0] (maybe <- 0x1800037) (Int)
add %i0, 0, %l7
lduw [%l7], %l3
mov %l3, %l6
! move %l6(lower) -> %o4(lower)
or %l6, %o4, %o4
!---- flushing int results buffer----
mov %o0, %l5
mov %o1, %l5
mov %o2, %l5
mov %o3, %l5
mov %o4, %l5
mov %l4, %o0
cas [%l7], %l6, %o0
! move %o0(lower) -> %o0(upper)
sllx %o0, 32, %o0
add   %l4, 1, %l4

P3549: !_REPLACEMENT [13] (Int)
sethi %hi(0x40), %l6
or %l6, %lo(0x40),  %l6
sethi %hi(0x10000), %l7
or %l7, %lo(0x10000),  %l7
add %i3, %l6, %l6
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]

P3550: !_DWST [14] (maybe <- 0x41000096) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
std %f20, [%i3 + 128]

P3551: !_CAS [12] (maybe <- 0x1800038) (Int)
add %i3, 0, %l3
lduw [%l3], %l7
mov %l7, %o5
! move %o5(lower) -> %o0(lower)
or %o5, %o0, %o0
mov %l4, %o1
cas [%l3], %o5, %o1
! move %o1(lower) -> %o1(upper)
sllx %o1, 32, %o1
add   %l4, 1, %l4

P3552: !_PREFETCH [4] (Int)
prefetch [%i0 + 64], 1

P3553: !_ST [0] (maybe <- 0x41000097) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i0 + 0 ]

P3554: !_SWAP [6] (maybe <- 0x1800039) (Int)
mov %l4, %l3
swap  [%i1 + 80], %l3
! move %l3(lower) -> %o1(lower)
srl %l3, 0, %l7
or %l7, %o1, %o1
add   %l4, 1, %l4

P3555: !_DWST [10] (maybe <- 0x41000098) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
std %f20, [%i2 + 32]

P3556: !_LD [1] (FP)
ld [%i0 + 4], %f14
! 1 addresses covered

P3557: !_PREFETCH [1] (Int)
prefetch [%i0 + 4], 1

P3558: !_DWST [13] (maybe <- 0x41000099) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
std %f20, [%i3 + 64]

P3559: !_DWLD [1] (FP) (CBR)
ldd [%i0 + 0], %f18
! 2 addresses covered
fmovs %f18, %f15
!---- flushing fp results buffer to %f30 ----
fmovd %f0, %f30
fmovd %f2, %f30
fmovd %f4, %f30
fmovd %f6, %f30
fmovd %f8, %f30
fmovd %f10, %f30
fmovd %f12, %f30
fmovd %f14, %f30
fmovs %f19, %f0

! cbranch
andcc %l0, 1, %g0
be,pt  %xcc, TARGET3559
nop
RET3559:

! lfsr step begin
srlx %l0, 1, %o5
xnor %o5, %l0, %o5
sllx %o5, 63, %o5
or  %o5, %l0, %l0
srlx %l0, 1, %l0


P3560: !_DWST [9] (maybe <- 0x4100009a) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
std %f20, [%i1 + 512]

P3561: !_DWLD [5] (FP)
ldd [%i1 + 72], %f18
! 1 addresses covered
fmovs %f19, %f1

P3562: !_DWST [13] (maybe <- 0x4100009b) (FP) (CBR)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
std %f20, [%i3 + 64]

! cbranch
andcc %l0, 1, %g0
be,pt  %xcc, TARGET3562
nop
RET3562:

! lfsr step begin
srlx %l0, 1, %l7
xnor %l7, %l0, %l7
sllx %l7, 63, %l7
or  %l7, %l0, %l0
srlx %l0, 1, %l0


P3563: !_LD [15] (FP)
ld [%i3 + 192], %f2
! 1 addresses covered

P3564: !_CAS [8] (maybe <- 0x180003a) (Int) (CBR)
add %i1, 256, %l3
lduw [%l3], %o2
mov %o2, %o5
! move %o5(lower) -> %o2(upper)
sllx %o5, 32, %o2
mov %l4, %l7
cas [%l3], %o5, %l7
! move %l7(lower) -> %o2(lower)
srl %l7, 0, %l3
or %l3, %o2, %o2
add   %l4, 1, %l4

! cbranch
andcc %l0, 1, %g0
be,pn  %xcc, TARGET3564
nop
RET3564:

! lfsr step begin
srlx %l0, 1, %o5
xnor %o5, %l0, %o5
sllx %o5, 63, %o5
or  %o5, %l0, %l0
srlx %l0, 1, %l0


P3565: !_PREFETCH [0] (Int)
prefetch [%i0 + 0], 1

P3566: !_DWLD [3] (FP)
ldd [%i0 + 32], %f18
! 1 addresses covered
fmovs %f18, %f3

P3567: !_DWST [3] (maybe <- 0x4100009c) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
std %f20, [%i0 + 32]

P3568: !_PREFETCH [6] (Int)
prefetch [%i1 + 80], 1

P3569: !_ST [15] (maybe <- 0x4100009d) (FP) (CBR)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i3 + 192 ]

! cbranch
andcc %l0, 1, %g0
be,pn  %xcc, TARGET3569
nop
RET3569:

! lfsr step begin
srlx %l0, 1, %l7
xnor %l7, %l0, %l7
sllx %l7, 63, %l7
or  %l7, %l0, %l0
srlx %l0, 1, %l0


P3570: !_LD [8] (FP)
ld [%i1 + 256], %f4
! 1 addresses covered

P3571: !_REPLACEMENT [11] (Int) (Branch target of P4063)
sethi %hi(0x40), %o5
or %o5, %lo(0x40),  %o5
sethi %hi(0x10000), %l3
or %l3, %lo(0x10000),  %l3
add %i3, %o5, %o5
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
ba P3572
nop

TARGET4063:
ba RET4063
nop


P3572: !_LD [2] (FP)
ld [%i0 + 12], %f5
! 1 addresses covered

P3573: !_ST [12] (maybe <- 0x4100009e) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i3 + 0 ]

P3574: !_ST [5] (maybe <- 0x4100009f) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i1 + 76 ]

P3575: !_ST [9] (maybe <- 0x410000a0) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i1 + 512 ]

P3576: !_CAS [14] (maybe <- 0x180003b) (Int) (Branch target of P3975)
add %i3, 128, %l3
lduw [%l3], %o3
mov %o3, %o5
! move %o5(lower) -> %o3(upper)
sllx %o5, 32, %o3
mov %l4, %l7
cas [%l3], %o5, %l7
! move %l7(lower) -> %o3(lower)
srl %l7, 0, %l3
or %l3, %o3, %o3
add   %l4, 1, %l4
ba P3577
nop

TARGET3975:
ba RET3975
nop


P3577: !_SWAP [13] (maybe <- 0x180003c) (Int) (CBR)
mov %l4, %o4
swap  [%i3 + 64], %o4
! move %o4(lower) -> %o4(upper)
sllx %o4, 32, %o4
add   %l4, 1, %l4

! cbranch
andcc %l0, 1, %g0
be,pt  %xcc, TARGET3577
nop
RET3577:

! lfsr step begin
srlx %l0, 1, %l7
xnor %l7, %l0, %l7
sllx %l7, 63, %l7
or  %l7, %l0, %l0
srlx %l0, 1, %l0


P3578: !_LD [4] (Int)
lduw [%i0 + 64], %l3
! move %l3(lower) -> %o4(lower)
or %l3, %o4, %o4
!---- flushing int results buffer----
mov %o0, %l5
mov %o1, %l5
mov %o2, %l5
mov %o3, %l5
mov %o4, %l5

P3579: !_LD [12] (FP)
ld [%i3 + 0], %f6
! 1 addresses covered

P3580: !_LD [8] (FP)
ld [%i1 + 256], %f7
! 1 addresses covered

P3581: !_LD [0] (FP)
ld [%i0 + 0], %f8
! 1 addresses covered

P3582: !_LD [13] (FP)
ld [%i3 + 64], %f9
! 1 addresses covered

P3583: !_LD [7] (FP)
ld [%i1 + 84], %f10
! 1 addresses covered

P3584: !_LD [2] (FP) (CBR)
ld [%i0 + 12], %f11
! 1 addresses covered

! cbranch
andcc %l0, 1, %g0
be,pt  %xcc, TARGET3584
nop
RET3584:

! lfsr step begin
srlx %l0, 1, %l6
xnor %l6, %l0, %l6
sllx %l6, 63, %l6
or  %l6, %l0, %l0
srlx %l0, 1, %l0


P3585: !_LD [10] (FP)
ld [%i2 + 32], %f12
! 1 addresses covered

P3586: !_LD [13] (FP)
ld [%i3 + 64], %f13
! 1 addresses covered

P3587: !_LD [2] (FP)
ld [%i0 + 12], %f14
! 1 addresses covered

P3588: !_LD [15] (FP)
ld [%i3 + 192], %f15
! 1 addresses covered
!---- flushing fp results buffer to %f30 ----
fmovd %f0, %f30
fmovd %f2, %f30
fmovd %f4, %f30
fmovd %f6, %f30
fmovd %f8, %f30
fmovd %f10, %f30
fmovd %f12, %f30
fmovd %f14, %f30

P3589: !_DWST [13] (maybe <- 0x410000a1) (FP) (Loop exit)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
std %f20, [%i3 + 64]
loop_exit_3_0:
sub %l2, 1, %l2
cmp %l2, 0
bg loop_entry_3_0
nop

P3590: !_DWST [13] (maybe <- 0x410000a2) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
std %f20, [%i3 + 64]

P3591: !_LD [10] (FP)
ld [%i2 + 32], %f0
! 1 addresses covered

P3592: !_CAS [8] (maybe <- 0x180003d) (Int)
add %i1, 256, %l7
lduw [%l7], %o0
mov %o0, %l6
! move %l6(lower) -> %o0(upper)
sllx %l6, 32, %o0
mov %l4, %l3
cas [%l7], %l6, %l3
! move %l3(lower) -> %o0(lower)
srl %l3, 0, %l7
or %l7, %o0, %o0
add   %l4, 1, %l4

P3593: !_DWST [6] (maybe <- 0x410000a3) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
! 1 th moved, current_fp_src=21 
fmovs  %f16, %f21
fadds  %f16, %f17, %f16
std %f20, [%i1 + 80]

P3594: !_LD [1] (FP)
ld [%i0 + 4], %f1
! 1 addresses covered

P3595: !_LD [9] (FP)
ld [%i1 + 512], %f2
! 1 addresses covered

P3596: !_ST [3] (maybe <- 0x410000a5) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i0 + 32 ]

P3597: !_CASX [2] (maybe <- 0x180003e) (Int)
add %i0, 8, %l3
ldx [%l3], %o1
! move %o1(upper) -> %o1(upper)
! move %o1(lower) -> %o1(lower)
mov  %o1, %o5
mov %l4, %o2
casx [%l3], %o5, %o2
! move %o2(upper) -> %o2(upper)
! move %o2(lower) -> %o2(lower)
add  %l4, 1, %l4

P3598: !_PREFETCH [8] (Int)
prefetch [%i1 + 256], 1

P3599: !_DWST [5] (maybe <- 0x410000a6) (FP)
! 0 th moved, current_fp_src=21 
fmovs  %f16, %f21
fadds  %f16, %f17, %f16
std %f20, [%i1 + 72]

P3600: !_ST [12] (maybe <- 0x410000a7) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i3 + 0 ]

P3601: !_CAS [9] (maybe <- 0x180003f) (Int)
add %i1, 512, %l7
lduw [%l7], %o3
mov %o3, %l6
! move %l6(lower) -> %o3(upper)
sllx %l6, 32, %o3
mov %l4, %l3
cas [%l7], %l6, %l3
! move %l3(lower) -> %o3(lower)
srl %l3, 0, %l7
or %l7, %o3, %o3
add   %l4, 1, %l4

P3602: !_SWAP [11] (maybe <- 0x1800040) (Int)
mov %l4, %o4
swap  [%i2 + 64], %o4
! move %o4(lower) -> %o4(upper)
sllx %o4, 32, %o4
add   %l4, 1, %l4

P3603: !_LD [7] (FP) (Branch target of P3428)
ld [%i1 + 84], %f3
! 1 addresses covered
ba P3604
nop

TARGET3428:
ba RET3428
nop


P3604: !_ST [6] (maybe <- 0x410000a8) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i1 + 80 ]

P3605: !_SWAP [14] (maybe <- 0x1800041) (Int)
mov %l4, %l6
swap  [%i3 + 128], %l6
! move %l6(lower) -> %o4(lower)
srl %l6, 0, %o5
or %o5, %o4, %o4
!---- flushing int results buffer----
mov %o0, %l5
mov %o1, %l5
mov %o2, %l5
mov %o3, %l5
mov %o4, %l5
add   %l4, 1, %l4

P3606: !_MEMBAR (Int)
membar #StoreLoad

P3607: !_REPLACEMENT [8] (Int)
sethi %hi(0x100), %l7
or %l7, %lo(0x100),  %l7
sethi %hi(0x10000), %o5
or %o5, %lo(0x10000),  %o5
add %i3, %l7, %l7
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]

P3608: !_DWLD [5] (FP)
ldd [%i1 + 72], %f4
! 1 addresses covered
fmovs %f5, %f4

P3609: !_CAS [14] (maybe <- 0x1800042) (Int) (Branch target of P3767)
add %i3, 128, %l7
lduw [%l7], %o0
mov %o0, %l6
! move %l6(lower) -> %o0(upper)
sllx %l6, 32, %o0
mov %l4, %l3
cas [%l7], %l6, %l3
! move %l3(lower) -> %o0(lower)
srl %l3, 0, %l7
or %l7, %o0, %o0
add   %l4, 1, %l4
ba P3610
nop

TARGET3767:
ba RET3767
nop


P3610: !_LD [2] (FP)
ld [%i0 + 12], %f5
! 1 addresses covered

P3611: !_ST [12] (maybe <- 0x410000a9) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i3 + 0 ]

P3612: !_PREFETCH [8] (Int)
prefetch [%i1 + 256], 1

P3613: !_PREFETCH [12] (Int)
prefetch [%i3 + 0], 1

P3614: !_CASX [15] (maybe <- 0x1800043) (Int)
add %i3, 192, %l6
ldx [%l6], %o1
! move %o1(upper) -> %o1(upper)
! move %o1(lower) -> %o1(lower)
mov  %o1, %l3
sllx %l4, 32, %o2
casx [%l6], %l3, %o2
! move %o2(upper) -> %o2(upper)
! move %o2(lower) -> %o2(lower)
add  %l4, 1, %l4

P3615: !_ST [4] (maybe <- 0x410000aa) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i0 + 64 ]

P3616: !_DWLD [11] (FP)
ldd [%i2 + 64], %f6
! 1 addresses covered

P3617: !_SWAP [12] (maybe <- 0x1800044) (Int)
mov %l4, %o3
swap  [%i3 + 0], %o3
! move %o3(lower) -> %o3(upper)
sllx %o3, 32, %o3
add   %l4, 1, %l4

P3618: !_CASX [11] (maybe <- 0x1800045) (Int) (CBR)
add %i2, 64, %o5
ldx [%o5], %l6
! move %l6(upper) -> %o3(lower)
srlx %l6, 32, %l7
or %l7, %o3, %o3
! move %l6(lower) -> %o4(upper)
sllx %l6, 32, %o4
mov  %l6, %l7
sllx %l4, 32, %l6
casx [%o5], %l7, %l6
! move %l6(upper) -> %o4(lower)
srlx %l6, 32, %o5
or %o5, %o4, %o4
!---- flushing int results buffer----
mov %o0, %l5
mov %o1, %l5
mov %o2, %l5
mov %o3, %l5
mov %o4, %l5
! move %l6(lower) -> %o0(upper)
sllx %l6, 32, %o0
add  %l4, 1, %l4

! cbranch
andcc %l0, 1, %g0
be,pt  %xcc, TARGET3618
nop
RET3618:

! lfsr step begin
srlx %l0, 1, %l7
xnor %l7, %l0, %l7
sllx %l7, 63, %l7
or  %l7, %l0, %l0
srlx %l0, 1, %l0


P3619: !_CASX [13] (maybe <- 0x1800046) (Int)
add %i3, 64, %l3
ldx [%l3], %l7
! move %l7(upper) -> %o0(lower)
srlx %l7, 32, %o5
or %o5, %o0, %o0
! move %l7(lower) -> %o1(upper)
sllx %l7, 32, %o1
mov  %l7, %o5
sllx %l4, 32, %l7
casx [%l3], %o5, %l7
! move %l7(upper) -> %o1(lower)
srlx %l7, 32, %l3
or %l3, %o1, %o1
! move %l7(lower) -> %o2(upper)
sllx %l7, 32, %o2
add  %l4, 1, %l4

P3620: !_PREFETCH [14] (Int)
prefetch [%i3 + 128], 1

P3621: !_DWST [2] (maybe <- 0x410000ab) (FP) (Branch target of P3205)
! 0 th moved, current_fp_src=21 
fmovs  %f16, %f21
fadds  %f16, %f17, %f16
std %f20, [%i0 + 8]
ba P3622
nop

TARGET3205:
ba RET3205
nop


P3622: !_LD [0] (FP)
ld [%i0 + 0], %f7
! 1 addresses covered

P3623: !_NOP (Int)
nop

P3624: !_ST [10] (maybe <- 0x410000ac) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i2 + 32 ]

P3625: !_CASX [15] (maybe <- 0x1800047) (Int)
add %i3, 192, %l7
ldx [%l7], %l3
! move %l3(upper) -> %o2(lower)
srlx %l3, 32, %l6
or %l6, %o2, %o2
! move %l3(lower) -> %o3(upper)
sllx %l3, 32, %o3
mov  %l3, %l6
sllx %l4, 32, %l3
casx [%l7], %l6, %l3
! move %l3(upper) -> %o3(lower)
srlx %l3, 32, %l7
or %l7, %o3, %o3
! move %l3(lower) -> %o4(upper)
sllx %l3, 32, %o4
add  %l4, 1, %l4

P3626: !_NOP (Int)
nop

P3627: !_LD [13] (FP)
ld [%i3 + 64], %f8
! 1 addresses covered

P3628: !_LD [10] (FP)
ld [%i2 + 32], %f9
! 1 addresses covered

P3629: !_PREFETCH [8] (Int)
prefetch [%i1 + 256], 1

P3630: !_ST [14] (maybe <- 0x410000ad) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i3 + 128 ]

P3631: !_LD [7] (FP)
ld [%i1 + 84], %f10
! 1 addresses covered

P3632: !_SWAP [14] (maybe <- 0x1800048) (Int)
mov %l4, %l7
swap  [%i3 + 128], %l7
! move %l7(lower) -> %o4(lower)
srl %l7, 0, %l3
or %l3, %o4, %o4
!---- flushing int results buffer----
mov %o0, %l5
mov %o1, %l5
mov %o2, %l5
mov %o3, %l5
mov %o4, %l5
add   %l4, 1, %l4

P3633: !_REPLACEMENT [0] (Int)
sethi %hi(0x0), %o5
or %o5, %lo(0x0),  %o5
sethi %hi(0x10000), %l3
or %l3, %lo(0x10000),  %l3
add %i3, %o5, %o5
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]

P3634: !_REPLACEMENT [10] (Int)
sethi %hi(0x20), %l7
or %l7, %lo(0x20),  %l7
sethi %hi(0x10000), %o5
or %o5, %lo(0x10000),  %o5
add %i3, %l7, %l7
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]

P3635: !_REPLACEMENT [7] (Int)
sethi %hi(0x54), %l6
or %l6, %lo(0x54),  %l6
sethi %hi(0x10000), %l7
or %l7, %lo(0x10000),  %l7
add %i3, %l6, %l6
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]

P3636: !_CAS [3] (maybe <- 0x1800049) (Int)
add %i0, 32, %l6
lduw [%l6], %o0
mov %o0, %l3
! move %l3(lower) -> %o0(upper)
sllx %l3, 32, %o0
mov %l4, %o5
cas [%l6], %l3, %o5
! move %o5(lower) -> %o0(lower)
srl %o5, 0, %l6
or %l6, %o0, %o0
add   %l4, 1, %l4

P3637: !_REPLACEMENT [9] (Int)
sethi %hi(0x200), %l3
or %l3, %lo(0x200),  %l3
sethi %hi(0x10000), %l6
or %l6, %lo(0x10000),  %l6
add %i3, %l3, %l3
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]

P3638: !_ST [10] (maybe <- 0x410000ae) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i2 + 32 ]

P3639: !_DWLD [11] (FP)
ldd [%i2 + 64], %f18
! 1 addresses covered
fmovs %f18, %f11

P3640: !_DWLD [8] (FP) (CBR)
ldd [%i1 + 256], %f12
! 1 addresses covered

! cbranch
andcc %l0, 1, %g0
be,pn  %xcc, TARGET3640
nop
RET3640:

! lfsr step begin
srlx %l0, 1, %l7
xnor %l7, %l0, %l7
sllx %l7, 63, %l7
or  %l7, %l0, %l0
srlx %l0, 1, %l0


P3641: !_DWST [0] (maybe <- 0x410000af) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
! 1 th moved, current_fp_src=21 
fmovs  %f16, %f21
fadds  %f16, %f17, %f16
std %f20, [%i0 + 0]

P3642: !_PREFETCH [9] (Int) (CBR)
prefetch [%i1 + 512], 1

! cbranch
andcc %l0, 1, %g0
be,pn  %xcc, TARGET3642
nop
RET3642:

! lfsr step begin
srlx %l0, 1, %l7
xnor %l7, %l0, %l7
sllx %l7, 63, %l7
or  %l7, %l0, %l0
srlx %l0, 1, %l0


P3643: !_DWST [12] (maybe <- 0x410000b1) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
std %f20, [%i3 + 0]

P3644: !_DWLD [4] (FP)
ldd [%i0 + 64], %f18
! 1 addresses covered
fmovs %f18, %f13

P3645: !_DWLD [7] (FP)
ldd [%i1 + 80], %f14
! 2 addresses covered
!---- flushing fp results buffer to %f30 ----
fmovd %f0, %f30
fmovd %f2, %f30
fmovd %f4, %f30
fmovd %f6, %f30
fmovd %f8, %f30
fmovd %f10, %f30
fmovd %f12, %f30
fmovd %f14, %f30

P3646: !_DWLD [3] (FP)
ldd [%i0 + 32], %f0
! 1 addresses covered

P3647: !_LD [9] (FP)
ld [%i1 + 512], %f1
! 1 addresses covered

P3648: !_PREFETCH [10] (Int) (Branch target of P3195)
prefetch [%i2 + 32], 1
ba P3649
nop

TARGET3195:
ba RET3195
nop


P3649: !_ST [14] (maybe <- 0x410000b2) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i3 + 128 ]

P3650: !_LD [11] (FP) (CBR)
ld [%i2 + 64], %f2
! 1 addresses covered

! cbranch
andcc %l0, 1, %g0
be,pn  %xcc, TARGET3650
nop
RET3650:

! lfsr step begin
srlx %l0, 1, %l6
xnor %l6, %l0, %l6
sllx %l6, 63, %l6
or  %l6, %l0, %l0
srlx %l0, 1, %l0


P3651: !_DWST [2] (maybe <- 0x410000b3) (FP)
! 0 th moved, current_fp_src=21 
fmovs  %f16, %f21
fadds  %f16, %f17, %f16
std %f20, [%i0 + 8]

P3652: !_LD [9] (FP)
ld [%i1 + 512], %f3
! 1 addresses covered

P3653: !_SWAP [2] (maybe <- 0x180004a) (Int)
mov %l4, %o1
swap  [%i0 + 12], %o1
! move %o1(lower) -> %o1(upper)
sllx %o1, 32, %o1
add   %l4, 1, %l4

P3654: !_DWLD [0] (FP)
ldd [%i0 + 0], %f4
! 2 addresses covered

P3655: !_SWAP [10] (maybe <- 0x180004b) (Int) (LE)
wr %g0, 0x88, %asi
mov %l4, %l7
! Change single-word-level endianess (big endian <-> little endian) 
sethi %hi(0xff00ff00), %l3
or %l3, %lo(0xff00ff00), %l3
and %l7, %l3, %l6
srl %l6, 8, %l6
sll %l7, 8, %l7
and %l7, %l3, %l7
or %l7, %l6, %l7
srl %l7, 16, %l6
sll %l7, 16, %l7
srl %l7, 0, %l7
or %l7, %l6, %l7
swapa  [%i2 + 32] %asi, %l7
! move %l7(lower) -> %o1(lower)
srl %l7, 0, %l3
or %l3, %o1, %o1
add   %l4, 1, %l4

P3656: !_DWST [8] (maybe <- 0x410000b4) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
std %f20, [%i1 + 256]

P3657: !_DWST [13] (maybe <- 0x410000b5) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
std %f20, [%i3 + 64]

P3658: !_CAS [7] (maybe <- 0x180004c) (Int)
add %i1, 84, %l7
lduw [%l7], %o2
mov %o2, %l6
! move %l6(lower) -> %o2(upper)
sllx %l6, 32, %o2
mov %l4, %l3
cas [%l7], %l6, %l3
! move %l3(lower) -> %o2(lower)
srl %l3, 0, %l7
or %l7, %o2, %o2
add   %l4, 1, %l4

P3659: !_ST [3] (maybe <- 0x410000b6) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i0 + 32 ]

P3660: !_CASX [2] (maybe <- 0x180004d) (Int)
add %i0, 8, %l6
ldx [%l6], %o3
! move %o3(upper) -> %o3(upper)
! move %o3(lower) -> %o3(lower)
mov  %o3, %l3
mov %l4, %o4
casx [%l6], %l3, %o4
! move %o4(upper) -> %o4(upper)
! move %o4(lower) -> %o4(lower)
!---- flushing int results buffer----
mov %o0, %l5
mov %o1, %l5
mov %o2, %l5
mov %o3, %l5
mov %o4, %l5
add  %l4, 1, %l4

P3661: !_LD [3] (FP)
ld [%i0 + 32], %f6
! 1 addresses covered

P3662: !_DWLD [5] (FP)
ldd [%i1 + 72], %f18
! 1 addresses covered
fmovs %f19, %f7

P3663: !_ST [9] (maybe <- 0x410000b7) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i1 + 512 ]

P3664: !_REPLACEMENT [6] (Int)
sethi %hi(0x50), %o5
or %o5, %lo(0x50),  %o5
sethi %hi(0x10000), %l3
or %l3, %lo(0x10000),  %l3
add %i3, %o5, %o5
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]

P3665: !_ST [7] (maybe <- 0x410000b8) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i1 + 84 ]

P3666: !_DWST [11] (maybe <- 0x410000b9) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
std %f20, [%i2 + 64]

P3667: !_ST [0] (maybe <- 0x410000ba) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i0 + 0 ]

P3668: !_ST [3] (maybe <- 0x410000bb) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i0 + 32 ]

P3669: !_ST [5] (maybe <- 0x410000bc) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i1 + 76 ]

P3670: !_ST [5] (maybe <- 0x410000bd) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i1 + 76 ]

P3671: !_REPLACEMENT [5] (Int)
sethi %hi(0x4c), %l3
or %l3, %lo(0x4c),  %l3
sethi %hi(0x10000), %l6
or %l6, %lo(0x10000),  %l6
add %i3, %l3, %l3
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]

P3672: !_CASX [9] (maybe <- 0x180004e) (Int) (LE)
! Change single-word-level endianess (big endian <-> little endian) 
sethi %hi(0xff00ff00), %l3
or %l3, %lo(0xff00ff00), %l3
and %l4, %l3, %o5
srl %o5, 8, %o5
sll %l4, 8, %l6
and %l6, %l3, %l6
or %l6, %o5, %l6
srl %l6, 16, %o5
sll %l6, 16, %l6
srl %l6, 0, %l6
or %l6, %o5, %l6
wr %g0, 0x88, %asi
add %i1, 512, %l3
ldxa [%l3] %asi, %l7
! move %l7(lower) -> %o0(upper)
sllx %l7, 32, %o0
! move %l7(upper) -> %o0(lower)
srlx %l7, 32, %o5
or %o5, %o0, %o0
mov  %l7, %o5
mov  %l6, %l7
casxa [%l3] %asi, %o5, %l7
! move %l7(lower) -> %o1(upper)
sllx %l7, 32, %o1
! move %l7(upper) -> %o1(lower)
srlx %l7, 32, %l3
or %l3, %o1, %o1
add  %l4, 1, %l4

P3673: !_DWLD [3] (FP)
ldd [%i0 + 32], %f8
! 1 addresses covered

P3674: !_REPLACEMENT [1] (Int)
sethi %hi(0x4), %o5
or %o5, %lo(0x4),  %o5
sethi %hi(0x10000), %l3
or %l3, %lo(0x10000),  %l3
add %i3, %o5, %o5
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]

P3675: !_REPLACEMENT [3] (Int)
sethi %hi(0x20), %l7
or %l7, %lo(0x20),  %l7
sethi %hi(0x10000), %o5
or %o5, %lo(0x10000),  %o5
add %i3, %l7, %l7
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]

P3676: !_ST [11] (maybe <- 0x410000be) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i2 + 64 ]

P3677: !_REPLACEMENT [5] (Int)
sethi %hi(0x4c), %l3
or %l3, %lo(0x4c),  %l3
sethi %hi(0x10000), %l6
or %l6, %lo(0x10000),  %l6
add %i3, %l3, %l3
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]

P3678: !_CASX [15] (maybe <- 0x180004f) (Int)
add %i3, 192, %l3
ldx [%l3], %o2
! move %o2(upper) -> %o2(upper)
! move %o2(lower) -> %o2(lower)
mov  %o2, %o5
sllx %l4, 32, %o3
casx [%l3], %o5, %o3
! move %o3(upper) -> %o3(upper)
! move %o3(lower) -> %o3(lower)
add  %l4, 1, %l4

P3679: !_DWST [10] (maybe <- 0x410000bf) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
std %f20, [%i2 + 32]

P3680: !_LD [9] (FP) (Branch target of P3642)
ld [%i1 + 512], %f9
! 1 addresses covered
ba P3681
nop

TARGET3642:
ba RET3642
nop


P3681: !_REPLACEMENT [10] (Int)
sethi %hi(0x20), %l7
or %l7, %lo(0x20),  %l7
sethi %hi(0x10000), %o5
or %o5, %lo(0x10000),  %o5
add %i3, %l7, %l7
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]

P3682: !_DWLD [10] (FP) (CBR)
ldd [%i2 + 32], %f10
! 1 addresses covered

! cbranch
andcc %l0, 1, %g0
be,pt  %xcc, TARGET3682
nop
RET3682:

! lfsr step begin
srlx %l0, 1, %l6
xnor %l6, %l0, %l6
sllx %l6, 63, %l6
or  %l6, %l0, %l0
srlx %l0, 1, %l0


P3683: !_REPLACEMENT [14] (Int)
sethi %hi(0x80), %l7
or %l7, %lo(0x80),  %l7
sethi %hi(0x10000), %o5
or %o5, %lo(0x10000),  %o5
add %i3, %l7, %l7
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]

P3684: !_LD [10] (FP) (CBR)
ld [%i2 + 32], %f11
! 1 addresses covered

! cbranch
andcc %l0, 1, %g0
be,pn  %xcc, TARGET3684
nop
RET3684:

! lfsr step begin
srlx %l0, 1, %l6
xnor %l6, %l0, %l6
sllx %l6, 63, %l6
or  %l6, %l0, %l0
srlx %l0, 1, %l0


P3685: !_DWST [14] (maybe <- 0x410000c0) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
std %f20, [%i3 + 128]

P3686: !_PREFETCH [9] (Int)
prefetch [%i1 + 512], 1

P3687: !_LD [5] (FP)
ld [%i1 + 76], %f12
! 1 addresses covered

P3688: !_CAS [6] (maybe <- 0x1800050) (Int)
add %i1, 80, %l7
lduw [%l7], %o4
mov %o4, %l6
! move %l6(lower) -> %o4(upper)
sllx %l6, 32, %o4
mov %l4, %l3
cas [%l7], %l6, %l3
! move %l3(lower) -> %o4(lower)
srl %l3, 0, %l7
or %l7, %o4, %o4
!---- flushing int results buffer----
mov %o0, %l5
mov %o1, %l5
mov %o2, %l5
mov %o3, %l5
mov %o4, %l5
add   %l4, 1, %l4

P3689: !_DWST [9] (maybe <- 0x410000c1) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
std %f20, [%i1 + 512]

P3690: !_REPLACEMENT [9] (Int)
sethi %hi(0x200), %l3
or %l3, %lo(0x200),  %l3
sethi %hi(0x10000), %l6
or %l6, %lo(0x10000),  %l6
add %i3, %l3, %l3
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]

P3691: !_PREFETCH [0] (Int)
prefetch [%i0 + 0], 1

P3692: !_DWST [3] (maybe <- 0x410000c2) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
std %f20, [%i0 + 32]

P3693: !_ST [14] (maybe <- 0x410000c3) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i3 + 128 ]

P3694: !_CASX [13] (maybe <- 0x1800051) (Int) (Branch target of P3842)
add %i3, 64, %l7
ldx [%l7], %o0
! move %o0(upper) -> %o0(upper)
! move %o0(lower) -> %o0(lower)
mov  %o0, %l6
sllx %l4, 32, %o1
casx [%l7], %l6, %o1
! move %o1(upper) -> %o1(upper)
! move %o1(lower) -> %o1(lower)
add  %l4, 1, %l4
ba P3695
nop

TARGET3842:
ba RET3842
nop


P3695: !_REPLACEMENT [0] (Int)
sethi %hi(0x0), %l6
or %l6, %lo(0x0),  %l6
sethi %hi(0x10000), %l7
or %l7, %lo(0x10000),  %l7
add %i3, %l6, %l6
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]

P3696: !_DWST [4] (maybe <- 0x410000c4) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
std %f20, [%i0 + 64]

P3697: !_REPLACEMENT [10] (Int)
sethi %hi(0x20), %o5
or %o5, %lo(0x20),  %o5
sethi %hi(0x10000), %l3
or %l3, %lo(0x10000),  %l3
add %i3, %o5, %o5
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]

P3698: !_REPLACEMENT [11] (Int)
sethi %hi(0x40), %l7
or %l7, %lo(0x40),  %l7
sethi %hi(0x10000), %o5
or %o5, %lo(0x10000),  %o5
add %i3, %l7, %l7
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]

P3699: !_PREFETCH [11] (Int)
prefetch [%i2 + 64], 1

P3700: !_ST [3] (maybe <- 0x410000c5) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i0 + 32 ]

P3701: !_LD [15] (FP)
ld [%i3 + 192], %f13
! 1 addresses covered

P3702: !_REPLACEMENT [13] (Int)
sethi %hi(0x40), %l3
or %l3, %lo(0x40),  %l3
sethi %hi(0x10000), %l6
or %l6, %lo(0x10000),  %l6
add %i3, %l3, %l3
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]

P3703: !_CAS [14] (maybe <- 0x1800052) (Int)
add %i3, 128, %l3
lduw [%l3], %o2
mov %o2, %o5
! move %o5(lower) -> %o2(upper)
sllx %o5, 32, %o2
mov %l4, %l7
cas [%l3], %o5, %l7
! move %l7(lower) -> %o2(lower)
srl %l7, 0, %l3
or %l3, %o2, %o2
add   %l4, 1, %l4

P3704: !_PREFETCH [11] (Int)
prefetch [%i2 + 64], 1

P3705: !_ST [10] (maybe <- 0x410000c6) (FP) (Branch target of P3416)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i2 + 32 ]
ba P3706
nop

TARGET3416:
ba RET3416
nop


P3706: !_REPLACEMENT [3] (Int)
sethi %hi(0x20), %l7
or %l7, %lo(0x20),  %l7
sethi %hi(0x10000), %o5
or %o5, %lo(0x10000),  %o5
add %i3, %l7, %l7
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]

P3707: !_PREFETCH [8] (Int)
prefetch [%i1 + 256], 1

P3708: !_DWLD [12] (FP)
ldd [%i3 + 0], %f14
! 1 addresses covered

P3709: !_REPLACEMENT [10] (Int)
sethi %hi(0x20), %l6
or %l6, %lo(0x20),  %l6
sethi %hi(0x10000), %l7
or %l7, %lo(0x10000),  %l7
add %i3, %l6, %l6
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]

P3710: !_ST [13] (maybe <- 0x410000c7) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i3 + 64 ]

P3711: !_DWLD [15] (FP)
ldd [%i3 + 192], %f18
! 1 addresses covered
fmovs %f18, %f15
!---- flushing fp results buffer to %f30 ----
fmovd %f0, %f30
fmovd %f2, %f30
fmovd %f4, %f30
fmovd %f6, %f30
fmovd %f8, %f30
fmovd %f10, %f30
fmovd %f12, %f30
fmovd %f14, %f30

P3712: !_DWST [15] (maybe <- 0x410000c8) (FP) (CBR)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
std %f20, [%i3 + 192]

! cbranch
andcc %l0, 1, %g0
be,pt  %xcc, TARGET3712
nop
RET3712:

! lfsr step begin
srlx %l0, 1, %l7
xnor %l7, %l0, %l7
sllx %l7, 63, %l7
or  %l7, %l0, %l0
srlx %l0, 1, %l0


P3713: !_CASX [4] (maybe <- 0x1800053) (Int)
add %i0, 64, %l3
ldx [%l3], %o3
! move %o3(upper) -> %o3(upper)
! move %o3(lower) -> %o3(lower)
mov  %o3, %o5
sllx %l4, 32, %o4
casx [%l3], %o5, %o4
! move %o4(upper) -> %o4(upper)
! move %o4(lower) -> %o4(lower)
!---- flushing int results buffer----
mov %o0, %l5
mov %o1, %l5
mov %o2, %l5
mov %o3, %l5
mov %o4, %l5
add  %l4, 1, %l4

P3714: !_LD [5] (FP)
ld [%i1 + 76], %f0
! 1 addresses covered

P3715: !_REPLACEMENT [6] (Int)
sethi %hi(0x50), %o5
or %o5, %lo(0x50),  %o5
sethi %hi(0x10000), %l3
or %l3, %lo(0x10000),  %l3
add %i3, %o5, %o5
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]

P3716: !_ST [7] (maybe <- 0x410000c9) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i1 + 84 ]

P3717: !_DWST [10] (maybe <- 0x410000ca) (FP) (CBR)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
std %f20, [%i2 + 32]

! cbranch
andcc %l0, 1, %g0
be,pt  %xcc, TARGET3717
nop
RET3717:

! lfsr step begin
srlx %l0, 1, %l3
xnor %l3, %l0, %l3
sllx %l3, 63, %l3
or  %l3, %l0, %l0
srlx %l0, 1, %l0


P3718: !_PREFETCH [8] (Int)
prefetch [%i1 + 256], 1

P3719: !_DWLD [1] (FP)
ldd [%i0 + 0], %f18
! 2 addresses covered
fmovs %f18, %f1
fmovs %f19, %f2

P3720: !_LD [15] (FP)
ld [%i3 + 192], %f3
! 1 addresses covered

P3721: !_LD [10] (FP)
ld [%i2 + 32], %f4
! 1 addresses covered

P3722: !_LD [13] (FP) (CBR) (Branch target of P3559)
ld [%i3 + 64], %f5
! 1 addresses covered

! cbranch
andcc %l0, 1, %g0
be,pt  %xcc, TARGET3722
nop
RET3722:

! lfsr step begin
srlx %l0, 1, %l6
xnor %l6, %l0, %l6
sllx %l6, 63, %l6
or  %l6, %l0, %l0
srlx %l0, 1, %l0

ba P3723
nop

TARGET3559:
ba RET3559
nop


P3723: !_DWLD [12] (FP) (Branch target of P3870)
ldd [%i3 + 0], %f6
! 1 addresses covered
ba P3724
nop

TARGET3870:
ba RET3870
nop


P3724: !_PREFETCH [7] (Int) (LE)
wr %g0, 0x88, %asi
prefetcha [%i1 + 84] %asi, 1

P3725: !_DWST [0] (maybe <- 0x410000cb) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
! 1 th moved, current_fp_src=21 
fmovs  %f16, %f21
fadds  %f16, %f17, %f16
std %f20, [%i0 + 0]

P3726: !_PREFETCH [13] (Int)
prefetch [%i3 + 64], 1

P3727: !_SWAP [4] (maybe <- 0x1800054) (Int)
mov %l4, %o0
swap  [%i0 + 64], %o0
! move %o0(lower) -> %o0(upper)
sllx %o0, 32, %o0
add   %l4, 1, %l4

P3728: !_ST [2] (maybe <- 0x410000cd) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i0 + 12 ]

P3729: !_MEMBAR (Int)
membar #StoreLoad

P3730: !_CAS [9] (maybe <- 0x1800055) (Int) (CBR)
add %i1, 512, %l3
lduw [%l3], %l7
mov %l7, %o5
! move %o5(lower) -> %o0(lower)
or %o5, %o0, %o0
mov %l4, %o1
cas [%l3], %o5, %o1
! move %o1(lower) -> %o1(upper)
sllx %o1, 32, %o1
add   %l4, 1, %l4

! cbranch
andcc %l0, 1, %g0
be,pn  %xcc, TARGET3730
nop
RET3730:

! lfsr step begin
srlx %l0, 1, %o5
xnor %o5, %l0, %o5
sllx %o5, 63, %o5
or  %o5, %l0, %l0
srlx %l0, 1, %l0


P3731: !_ST [14] (maybe <- 0x410000ce) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i3 + 128 ]

P3732: !_REPLACEMENT [9] (Int)
sethi %hi(0x200), %o5
or %o5, %lo(0x200),  %o5
sethi %hi(0x10000), %l3
or %l3, %lo(0x10000),  %l3
add %i3, %o5, %o5
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]

P3733: !_REPLACEMENT [2] (Int)
sethi %hi(0xc), %l7
or %l7, %lo(0xc),  %l7
sethi %hi(0x10000), %o5
or %o5, %lo(0x10000),  %o5
add %i3, %l7, %l7
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]

P3734: !_LD [8] (FP)
ld [%i1 + 256], %f7
! 1 addresses covered

P3735: !_SWAP [2] (maybe <- 0x1800056) (Int)
mov %l4, %o5
swap  [%i0 + 12], %o5
! move %o5(lower) -> %o1(lower)
srl %o5, 0, %l6
or %l6, %o1, %o1
add   %l4, 1, %l4

P3736: !_CASX [13] (maybe <- 0x1800057) (Int)
add %i3, 64, %l6
ldx [%l6], %o2
! move %o2(upper) -> %o2(upper)
! move %o2(lower) -> %o2(lower)
mov  %o2, %l3
sllx %l4, 32, %o3
casx [%l6], %l3, %o3
! move %o3(upper) -> %o3(upper)
! move %o3(lower) -> %o3(lower)
add  %l4, 1, %l4

P3737: !_ST [5] (maybe <- 0x410000cf) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i1 + 76 ]

P3738: !_DWLD [10] (FP)
ldd [%i2 + 32], %f8
! 1 addresses covered

P3739: !_DWLD [0] (FP)
ldd [%i0 + 0], %f18
! 2 addresses covered
fmovs %f18, %f9
fmovs %f19, %f10

P3740: !_REPLACEMENT [6] (Int) (CBR)
sethi %hi(0x50), %o5
or %o5, %lo(0x50),  %o5
sethi %hi(0x10000), %l3
or %l3, %lo(0x10000),  %l3
add %i3, %o5, %o5
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]

! cbranch
andcc %l0, 1, %g0
be,pt  %xcc, TARGET3740
nop
RET3740:

! lfsr step begin
srlx %l0, 1, %l7
xnor %l7, %l0, %l7
sllx %l7, 63, %l7
or  %l7, %l0, %l0
srlx %l0, 1, %l0


P3741: !_ST [3] (maybe <- 0x410000d0) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i0 + 32 ]

P3742: !_MEMBAR (Int)
membar #StoreLoad

P3743: !_CAS [1] (maybe <- 0x1800058) (Int)
add %i0, 4, %o5
lduw [%o5], %o4
mov %o4, %l7
! move %l7(lower) -> %o4(upper)
sllx %l7, 32, %o4
mov %l4, %l6
cas [%o5], %l7, %l6
! move %l6(lower) -> %o4(lower)
srl %l6, 0, %o5
or %o5, %o4, %o4
!---- flushing int results buffer----
mov %o0, %l5
mov %o1, %l5
mov %o2, %l5
mov %o3, %l5
mov %o4, %l5
add   %l4, 1, %l4

P3744: !_DWLD [3] (FP)
ldd [%i0 + 32], %f18
! 1 addresses covered
fmovs %f18, %f11

P3745: !_DWLD [14] (FP)
ldd [%i3 + 128], %f12
! 1 addresses covered

P3746: !_DWLD [1] (FP)
ldd [%i0 + 0], %f18
! 2 addresses covered
fmovs %f18, %f13
fmovs %f19, %f14

P3747: !_DWST [12] (maybe <- 0x410000d1) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
std %f20, [%i3 + 0]

P3748: !_PREFETCH [6] (Int)
prefetch [%i1 + 80], 1

P3749: !_DWST [1] (maybe <- 0x410000d2) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
! 1 th moved, current_fp_src=21 
fmovs  %f16, %f21
fadds  %f16, %f17, %f16
std %f20, [%i0 + 0]

P3750: !_LD [12] (FP)
ld [%i3 + 0], %f15
! 1 addresses covered
!---- flushing fp results buffer to %f30 ----
fmovd %f0, %f30
fmovd %f2, %f30
fmovd %f4, %f30
fmovd %f6, %f30
fmovd %f8, %f30
fmovd %f10, %f30
fmovd %f12, %f30
fmovd %f14, %f30

P3751: !_ST [15] (maybe <- 0x410000d4) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i3 + 192 ]

P3752: !_LD [13] (FP)
ld [%i3 + 64], %f0
! 1 addresses covered

P3753: !_MEMBAR (Int)
membar #StoreLoad

P3754: !_ST [2] (maybe <- 0x410000d5) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i0 + 12 ]

P3755: !_PREFETCH [2] (Int) (Branch target of P3448)
prefetch [%i0 + 12], 1
ba P3756
nop

TARGET3448:
ba RET3448
nop


P3756: !_MEMBAR (Int)
membar #StoreLoad

P3757: !_ST [5] (maybe <- 0x410000d6) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i1 + 76 ]

P3758: !_REPLACEMENT [15] (Int)
sethi %hi(0xc0), %l6
or %l6, %lo(0xc0),  %l6
sethi %hi(0x10000), %l7
or %l7, %lo(0x10000),  %l7
add %i3, %l6, %l6
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]

P3759: !_DWST [11] (maybe <- 0x410000d7) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
std %f20, [%i2 + 64]

P3760: !_SWAP [13] (maybe <- 0x1800059) (Int)
mov %l4, %o0
swap  [%i3 + 64], %o0
! move %o0(lower) -> %o0(upper)
sllx %o0, 32, %o0
add   %l4, 1, %l4

P3761: !_DWLD [15] (FP)
ldd [%i3 + 192], %f18
! 1 addresses covered
fmovs %f18, %f1

P3762: !_CASX [12] (maybe <- 0x180005a) (Int) (CBR)
add %i3, 0, %o5
ldx [%o5], %l6
! move %l6(upper) -> %o0(lower)
srlx %l6, 32, %l7
or %l7, %o0, %o0
! move %l6(lower) -> %o1(upper)
sllx %l6, 32, %o1
mov  %l6, %l7
sllx %l4, 32, %l6
casx [%o5], %l7, %l6
! move %l6(upper) -> %o1(lower)
srlx %l6, 32, %o5
or %o5, %o1, %o1
! move %l6(lower) -> %o2(upper)
sllx %l6, 32, %o2
add  %l4, 1, %l4

! cbranch
andcc %l0, 1, %g0
be,pt  %xcc, TARGET3762
nop
RET3762:

! lfsr step begin
srlx %l0, 1, %l7
xnor %l7, %l0, %l7
sllx %l7, 63, %l7
or  %l7, %l0, %l0
srlx %l0, 1, %l0


P3763: !_LD [6] (FP)
ld [%i1 + 80], %f2
! 1 addresses covered

P3764: !_DWLD [3] (FP)
ldd [%i0 + 32], %f18
! 1 addresses covered
fmovs %f18, %f3

P3765: !_ST [6] (maybe <- 0x410000d8) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i1 + 80 ]

P3766: !_LD [10] (FP)
ld [%i2 + 32], %f4
! 1 addresses covered

P3767: !_DWLD [7] (FP) (CBR)
ldd [%i1 + 80], %f18
! 2 addresses covered
fmovs %f18, %f5
fmovs %f19, %f6

! cbranch
andcc %l0, 1, %g0
be,pt  %xcc, TARGET3767
nop
RET3767:

! lfsr step begin
srlx %l0, 1, %l7
xnor %l7, %l0, %l7
sllx %l7, 63, %l7
or  %l7, %l0, %l0
srlx %l0, 1, %l0


P3768: !_DWLD [12] (FP)
ldd [%i3 + 0], %f18
! 1 addresses covered
fmovs %f18, %f7

P3769: !_DWST [2] (maybe <- 0x410000d9) (FP)
! 0 th moved, current_fp_src=21 
fmovs  %f16, %f21
fadds  %f16, %f17, %f16
std %f20, [%i0 + 8]

P3770: !_MEMBAR (Int)
membar #StoreLoad

P3771: !_PREFETCH [2] (Int)
prefetch [%i0 + 12], 1

P3772: !_CASX [6] (maybe <- 0x180005b) (Int)
add %i1, 80, %o5
ldx [%o5], %l6
! move %l6(upper) -> %o2(lower)
srlx %l6, 32, %l7
or %l7, %o2, %o2
! move %l6(lower) -> %o3(upper)
sllx %l6, 32, %o3
mov %l6, %l7
sllx %l4, 32, %l6
add  %l4, 1, %l4
or   %l4, %l6, %l6
casx [%o5], %l7, %l6
! move %l6(upper) -> %o3(lower)
srlx %l6, 32, %o5
or %o5, %o3, %o3
! move %l6(lower) -> %o4(upper)
sllx %l6, 32, %o4
add  %l4, 1, %l4

P3773: !_DWST [4] (maybe <- 0x410000da) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
std %f20, [%i0 + 64]

P3774: !_LD [6] (FP)
ld [%i1 + 80], %f8
! 1 addresses covered

P3775: !_DWLD [3] (FP)
ldd [%i0 + 32], %f18
! 1 addresses covered
fmovs %f18, %f9

P3776: !_ST [3] (maybe <- 0x410000db) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i0 + 32 ]

P3777: !_ST [2] (maybe <- 0x410000dc) (FP) (CBR)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i0 + 12 ]

! cbranch
andcc %l0, 1, %g0
be,pt  %xcc, TARGET3777
nop
RET3777:

! lfsr step begin
srlx %l0, 1, %o5
xnor %o5, %l0, %o5
sllx %o5, 63, %o5
or  %o5, %l0, %l0
srlx %l0, 1, %l0


P3778: !_DWLD [11] (FP)
ldd [%i2 + 64], %f10
! 1 addresses covered

P3779: !_PREFETCH [1] (Int)
prefetch [%i0 + 4], 1

P3780: !_CASX [3] (maybe <- 0x180005d) (Int)
add %i0, 32, %l6
ldx [%l6], %o5
! move %o5(upper) -> %o4(lower)
srlx %o5, 32, %l3
or %l3, %o4, %o4
!---- flushing int results buffer----
mov %o0, %l5
mov %o1, %l5
mov %o2, %l5
mov %o3, %l5
mov %o4, %l5
! move %o5(lower) -> %o0(upper)
sllx %o5, 32, %o0
mov  %o5, %l3
sllx %l4, 32, %o5
casx [%l6], %l3, %o5
! move %o5(upper) -> %o0(lower)
srlx %o5, 32, %l6
or %l6, %o0, %o0
! move %o5(lower) -> %o1(upper)
sllx %o5, 32, %o1
add  %l4, 1, %l4

P3781: !_DWST [10] (maybe <- 0x410000dd) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
std %f20, [%i2 + 32]

P3782: !_REPLACEMENT [12] (Int)
sethi %hi(0x0), %o5
or %o5, %lo(0x0),  %o5
sethi %hi(0x10000), %l3
or %l3, %lo(0x10000),  %l3
add %i3, %o5, %o5
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]

P3783: !_PREFETCH [2] (Int)
prefetch [%i0 + 12], 1

P3784: !_LD [6] (FP)
ld [%i1 + 80], %f11
! 1 addresses covered

P3785: !_DWST [13] (maybe <- 0x410000de) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
std %f20, [%i3 + 64]

P3786: !_REPLACEMENT [12] (Int)
sethi %hi(0x0), %l6
or %l6, %lo(0x0),  %l6
sethi %hi(0x10000), %l7
or %l7, %lo(0x10000),  %l7
add %i3, %l6, %l6
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]

P3787: !_LD [2] (FP)
ld [%i0 + 12], %f12
! 1 addresses covered

P3788: !_PREFETCH [1] (Int)
prefetch [%i0 + 4], 1

P3789: !_ST [11] (maybe <- 0x410000df) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i2 + 64 ]

P3790: !_SWAP [7] (maybe <- 0x180005e) (Int)
mov %l4, %l6
swap  [%i1 + 84], %l6
! move %l6(lower) -> %o1(lower)
srl %l6, 0, %o5
or %o5, %o1, %o1
add   %l4, 1, %l4

P3791: !_REPLACEMENT [10] (Int)
sethi %hi(0x20), %l7
or %l7, %lo(0x20),  %l7
sethi %hi(0x10000), %o5
or %o5, %lo(0x10000),  %o5
add %i3, %l7, %l7
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]

P3792: !_LD [14] (FP)
ld [%i3 + 128], %f13
! 1 addresses covered

P3793: !_ST [0] (maybe <- 0x410000e0) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i0 + 0 ]

P3794: !_ST [7] (maybe <- 0x410000e1) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i1 + 84 ]

P3795: !_ST [7] (maybe <- 0x410000e2) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i1 + 84 ]

P3796: !_DWST [7] (maybe <- 0x410000e3) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
! 1 th moved, current_fp_src=21 
fmovs  %f16, %f21
fadds  %f16, %f17, %f16
std %f20, [%i1 + 80]

P3797: !_PREFETCH [5] (Int)
prefetch [%i1 + 76], 1

P3798: !_DWST [8] (maybe <- 0x410000e5) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
std %f20, [%i1 + 256]

P3799: !_PREFETCH [1] (Int)
prefetch [%i0 + 4], 1

P3800: !_PREFETCH [11] (Int)
prefetch [%i2 + 64], 1

P3801: !_DWST [2] (maybe <- 0x410000e6) (FP)
! 0 th moved, current_fp_src=21 
fmovs  %f16, %f21
fadds  %f16, %f17, %f16
std %f20, [%i0 + 8]

P3802: !_LD [1] (FP)
ld [%i0 + 4], %f14
! 1 addresses covered

P3803: !_MEMBAR (Int)
membar #StoreLoad

P3804: !_ST [7] (maybe <- 0x410000e7) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i1 + 84 ]

P3805: !_DWLD [0] (FP) (CBR)
ldd [%i0 + 0], %f18
! 2 addresses covered
fmovs %f18, %f15
!---- flushing fp results buffer to %f30 ----
fmovd %f0, %f30
fmovd %f2, %f30
fmovd %f4, %f30
fmovd %f6, %f30
fmovd %f8, %f30
fmovd %f10, %f30
fmovd %f12, %f30
fmovd %f14, %f30
fmovs %f19, %f0

! cbranch
andcc %l0, 1, %g0
be,pt  %xcc, TARGET3805
nop
RET3805:

! lfsr step begin
srlx %l0, 1, %l7
xnor %l7, %l0, %l7
sllx %l7, 63, %l7
or  %l7, %l0, %l0
srlx %l0, 1, %l0


P3806: !_MEMBAR (Int)
membar #StoreLoad

P3807: !_REPLACEMENT [5] (Int)
sethi %hi(0x4c), %o5
or %o5, %lo(0x4c),  %o5
sethi %hi(0x10000), %l3
or %l3, %lo(0x10000),  %l3
add %i3, %o5, %o5
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]

P3808: !_PREFETCH [1] (Int) (CBR)
prefetch [%i0 + 4], 1

! cbranch
andcc %l0, 1, %g0
be,pn  %xcc, TARGET3808
nop
RET3808:

! lfsr step begin
srlx %l0, 1, %l7
xnor %l7, %l0, %l7
sllx %l7, 63, %l7
or  %l7, %l0, %l0
srlx %l0, 1, %l0


P3809: !_CASX [9] (maybe <- 0x180005f) (Int)
add %i1, 512, %l3
ldx [%l3], %o2
! move %o2(upper) -> %o2(upper)
! move %o2(lower) -> %o2(lower)
mov  %o2, %o5
sllx %l4, 32, %o3
casx [%l3], %o5, %o3
! move %o3(upper) -> %o3(upper)
! move %o3(lower) -> %o3(lower)
add  %l4, 1, %l4

P3810: !_DWLD [15] (FP)
ldd [%i3 + 192], %f18
! 1 addresses covered
fmovs %f18, %f1

P3811: !_LD [5] (FP)
ld [%i1 + 76], %f2
! 1 addresses covered

P3812: !_CAS [10] (maybe <- 0x1800060) (Int)
add %i2, 32, %l3
lduw [%l3], %o4
mov %o4, %o5
! move %o5(lower) -> %o4(upper)
sllx %o5, 32, %o4
mov %l4, %l7
cas [%l3], %o5, %l7
! move %l7(lower) -> %o4(lower)
srl %l7, 0, %l3
or %l3, %o4, %o4
!---- flushing int results buffer----
mov %o0, %l5
mov %o1, %l5
mov %o2, %l5
mov %o3, %l5
mov %o4, %l5
add   %l4, 1, %l4

P3813: !_SWAP [10] (maybe <- 0x1800061) (Int) (LE)
wr %g0, 0x88, %asi
mov %l4, %o0
! Change single-word-level endianess (big endian <-> little endian) 
sethi %hi(0xff00ff00), %o5
or %o5, %lo(0xff00ff00), %o5
and %o0, %o5, %l3
srl %l3, 8, %l3
sll %o0, 8, %o0
and %o0, %o5, %o0
or %o0, %l3, %o0
srl %o0, 16, %l3
sll %o0, 16, %o0
srl %o0, 0, %o0
or %o0, %l3, %o0
swapa  [%i2 + 32] %asi, %o0
! move %o0(lower) -> %o0(upper)
sllx %o0, 32, %o0
add   %l4, 1, %l4

P3814: !_ST [15] (maybe <- 0x410000e8) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i3 + 192 ]

P3815: !_LD [12] (FP)
ld [%i3 + 0], %f3
! 1 addresses covered

P3816: !_DWLD [6] (FP)
ldd [%i1 + 80], %f4
! 2 addresses covered

P3817: !_DWLD [5] (FP)
ldd [%i1 + 72], %f6
! 1 addresses covered
fmovs %f7, %f6

P3818: !_ST [9] (maybe <- 0x410000e9) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i1 + 512 ]

P3819: !_PREFETCH [6] (Int)
prefetch [%i1 + 80], 1

P3820: !_REPLACEMENT [7] (Int)
sethi %hi(0x54), %l3
or %l3, %lo(0x54),  %l3
sethi %hi(0x10000), %l6
or %l6, %lo(0x10000),  %l6
add %i3, %l3, %l3
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]

P3821: !_REPLACEMENT [15] (Int)
sethi %hi(0xc0), %o5
or %o5, %lo(0xc0),  %o5
sethi %hi(0x10000), %l3
or %l3, %lo(0x10000),  %l3
add %i3, %o5, %o5
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]

P3822: !_LD [1] (FP)
ld [%i0 + 4], %f7
! 1 addresses covered

P3823: !_ST [9] (maybe <- 0x410000ea) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i1 + 512 ]

P3824: !_MEMBAR (Int)
membar #StoreLoad

P3825: !_PREFETCH [1] (Int) (Branch target of P3569)
prefetch [%i0 + 4], 1
ba P3826
nop

TARGET3569:
ba RET3569
nop


P3826: !_ST [4] (maybe <- 0x410000eb) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i0 + 64 ]

P3827: !_DWST [6] (maybe <- 0x410000ec) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
! 1 th moved, current_fp_src=21 
fmovs  %f16, %f21
fadds  %f16, %f17, %f16
std %f20, [%i1 + 80]

P3828: !_NOP (Int)
nop

P3829: !_CAS [14] (maybe <- 0x1800062) (Int)
add %i3, 128, %l3
lduw [%l3], %l7
mov %l7, %o5
! move %o5(lower) -> %o0(lower)
or %o5, %o0, %o0
mov %l4, %o1
cas [%l3], %o5, %o1
! move %o1(lower) -> %o1(upper)
sllx %o1, 32, %o1
add   %l4, 1, %l4

P3830: !_REPLACEMENT [10] (Int)
sethi %hi(0x20), %o5
or %o5, %lo(0x20),  %o5
sethi %hi(0x10000), %l3
or %l3, %lo(0x10000),  %l3
add %i3, %o5, %o5
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]

P3831: !_DWLD [10] (FP)
ldd [%i2 + 32], %f8
! 1 addresses covered

P3832: !_CASX [10] (maybe <- 0x1800063) (Int)
add %i2, 32, %o5
ldx [%o5], %l6
! move %l6(upper) -> %o1(lower)
srlx %l6, 32, %l7
or %l7, %o1, %o1
! move %l6(lower) -> %o2(upper)
sllx %l6, 32, %o2
mov  %l6, %l7
sllx %l4, 32, %l6
casx [%o5], %l7, %l6
! move %l6(upper) -> %o2(lower)
srlx %l6, 32, %o5
or %o5, %o2, %o2
! move %l6(lower) -> %o3(upper)
sllx %l6, 32, %o3
add  %l4, 1, %l4

P3833: !_DWST [0] (maybe <- 0x410000ee) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
! 1 th moved, current_fp_src=21 
fmovs  %f16, %f21
fadds  %f16, %f17, %f16
std %f20, [%i0 + 0]

P3834: !_DWST [14] (maybe <- 0x410000f0) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
std %f20, [%i3 + 128]

P3835: !_CASX [12] (maybe <- 0x1800064) (Int)
add %i3, 0, %l6
ldx [%l6], %o5
! move %o5(upper) -> %o3(lower)
srlx %o5, 32, %l3
or %l3, %o3, %o3
! move %o5(lower) -> %o4(upper)
sllx %o5, 32, %o4
mov  %o5, %l3
sllx %l4, 32, %o5
casx [%l6], %l3, %o5
! move %o5(upper) -> %o4(lower)
srlx %o5, 32, %l6
or %l6, %o4, %o4
!---- flushing int results buffer----
mov %o0, %l5
mov %o1, %l5
mov %o2, %l5
mov %o3, %l5
mov %o4, %l5
! move %o5(lower) -> %o0(upper)
sllx %o5, 32, %o0
add  %l4, 1, %l4

P3836: !_CASX [4] (maybe <- 0x1800065) (Int)
add %i0, 64, %l6
ldx [%l6], %o5
! move %o5(upper) -> %o0(lower)
srlx %o5, 32, %l3
or %l3, %o0, %o0
! move %o5(lower) -> %o1(upper)
sllx %o5, 32, %o1
mov  %o5, %l3
sllx %l4, 32, %o5
casx [%l6], %l3, %o5
! move %o5(upper) -> %o1(lower)
srlx %o5, 32, %l6
or %l6, %o1, %o1
! move %o5(lower) -> %o2(upper)
sllx %o5, 32, %o2
add  %l4, 1, %l4

P3837: !_DWLD [5] (FP)
ldd [%i1 + 72], %f18
! 1 addresses covered
fmovs %f19, %f9

P3838: !_DWLD [6] (FP) (Branch target of P3214)
ldd [%i1 + 80], %f10
! 2 addresses covered
ba P3839
nop

TARGET3214:
ba RET3214
nop


P3839: !_ST [13] (maybe <- 0x410000f1) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i3 + 64 ]

P3840: !_SWAP [2] (maybe <- 0x1800066) (Int)
mov %l4, %l6
swap  [%i0 + 12], %l6
! move %l6(lower) -> %o2(lower)
srl %l6, 0, %o5
or %o5, %o2, %o2
add   %l4, 1, %l4

P3841: !_DWLD [6] (FP)
ldd [%i1 + 80], %f12
! 2 addresses covered

P3842: !_DWLD [8] (FP) (CBR)
ldd [%i1 + 256], %f14
! 1 addresses covered

! cbranch
andcc %l0, 1, %g0
be,pt  %xcc, TARGET3842
nop
RET3842:

! lfsr step begin
srlx %l0, 1, %l7
xnor %l7, %l0, %l7
sllx %l7, 63, %l7
or  %l7, %l0, %l0
srlx %l0, 1, %l0


P3843: !_DWST [15] (maybe <- 0x410000f2) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
std %f20, [%i3 + 192]

P3844: !_DWST [0] (maybe <- 0x410000f3) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
! 1 th moved, current_fp_src=21 
fmovs  %f16, %f21
fadds  %f16, %f17, %f16
std %f20, [%i0 + 0]

P3845: !_DWST [10] (maybe <- 0x410000f5) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
std %f20, [%i2 + 32]

P3846: !_DWST [11] (maybe <- 0x410000f6) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
std %f20, [%i2 + 64]

P3847: !_LD [2] (FP)
ld [%i0 + 12], %f15
! 1 addresses covered
!---- flushing fp results buffer to %f30 ----
fmovd %f0, %f30
fmovd %f2, %f30
fmovd %f4, %f30
fmovd %f6, %f30
fmovd %f8, %f30
fmovd %f10, %f30
fmovd %f12, %f30
fmovd %f14, %f30

P3848: !_DWLD [8] (FP)
ldd [%i1 + 256], %f0
! 1 addresses covered

P3849: !_PREFETCH [2] (Int)
prefetch [%i0 + 12], 1

P3850: !_DWST [11] (maybe <- 0x410000f7) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
std %f20, [%i2 + 64]

P3851: !_DWLD [9] (FP) (Branch target of P3762)
ldd [%i1 + 512], %f18
! 1 addresses covered
fmovs %f18, %f1
ba P3852
nop

TARGET3762:
ba RET3762
nop


P3852: !_REPLACEMENT [4] (Int)
sethi %hi(0x40), %l7
or %l7, %lo(0x40),  %l7
sethi %hi(0x10000), %o5
or %o5, %lo(0x10000),  %o5
add %i3, %l7, %l7
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]

P3853: !_REPLACEMENT [14] (Int)
sethi %hi(0x80), %l6
or %l6, %lo(0x80),  %l6
sethi %hi(0x10000), %l7
or %l7, %lo(0x10000),  %l7
add %i3, %l6, %l6
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]

P3854: !_PREFETCH [0] (Int)
prefetch [%i0 + 0], 1

P3855: !_REPLACEMENT [7] (Int)
sethi %hi(0x54), %l3
or %l3, %lo(0x54),  %l3
sethi %hi(0x10000), %l6
or %l6, %lo(0x10000),  %l6
add %i3, %l3, %l3
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]

P3856: !_ST [10] (maybe <- 0x410000f8) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i2 + 32 ]

P3857: !_DWLD [3] (FP)
ldd [%i0 + 32], %f2
! 1 addresses covered

P3858: !_ST [13] (maybe <- 0x410000f9) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i3 + 64 ]

P3859: !_DWLD [9] (FP)
ldd [%i1 + 512], %f18
! 1 addresses covered
fmovs %f18, %f3

P3860: !_DWST [7] (maybe <- 0x410000fa) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
! 1 th moved, current_fp_src=21 
fmovs  %f16, %f21
fadds  %f16, %f17, %f16
std %f20, [%i1 + 80]

P3861: !_LD [14] (FP)
ld [%i3 + 128], %f4
! 1 addresses covered

P3862: !_REPLACEMENT [6] (Int)
sethi %hi(0x50), %l3
or %l3, %lo(0x50),  %l3
sethi %hi(0x10000), %l6
or %l6, %lo(0x10000),  %l6
add %i3, %l3, %l3
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]

P3863: !_PREFETCH [5] (Int) (LE)
wr %g0, 0x88, %asi
prefetcha [%i1 + 76] %asi, 1

P3864: !_DWLD [6] (FP)
ldd [%i1 + 80], %f18
! 2 addresses covered
fmovs %f18, %f5
fmovs %f19, %f6

P3865: !_PREFETCH [11] (Int)
prefetch [%i2 + 64], 1

P3866: !_LD [0] (FP)
ld [%i0 + 0], %f7
! 1 addresses covered

P3867: !_CASX [0] (maybe <- 0x1800067) (Int)
add %i0, 0, %l3
ldx [%l3], %o3
! move %o3(upper) -> %o3(upper)
! move %o3(lower) -> %o3(lower)
mov %o3, %o5
sllx %l4, 32, %o4
add  %l4, 1, %l4
or   %l4, %o4, %o4
casx [%l3], %o5, %o4
! move %o4(upper) -> %o4(upper)
! move %o4(lower) -> %o4(lower)
!---- flushing int results buffer----
mov %o0, %l5
mov %o1, %l5
mov %o2, %l5
mov %o3, %l5
mov %o4, %l5
add  %l4, 1, %l4

P3868: !_REPLACEMENT [0] (Int)
sethi %hi(0x0), %o5
or %o5, %lo(0x0),  %o5
sethi %hi(0x10000), %l3
or %l3, %lo(0x10000),  %l3
add %i3, %o5, %o5
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]

P3869: !_LD [15] (FP)
ld [%i3 + 192], %f8
! 1 addresses covered

P3870: !_SWAP [10] (maybe <- 0x1800069) (Int) (CBR)
mov %l4, %o0
swap  [%i2 + 32], %o0
! move %o0(lower) -> %o0(upper)
sllx %o0, 32, %o0
add   %l4, 1, %l4

! cbranch
andcc %l0, 1, %g0
be,pn  %xcc, TARGET3870
nop
RET3870:

! lfsr step begin
srlx %l0, 1, %l6
xnor %l6, %l0, %l6
sllx %l6, 63, %l6
or  %l6, %l0, %l0
srlx %l0, 1, %l0


P3871: !_DWST [3] (maybe <- 0x410000fc) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
std %f20, [%i0 + 32]

P3872: !_PREFETCH [12] (Int)
prefetch [%i3 + 0], 1

P3873: !_PREFETCH [15] (Int)
prefetch [%i3 + 192], 1

P3874: !_REPLACEMENT [4] (Int) (CBR)
sethi %hi(0x40), %l6
or %l6, %lo(0x40),  %l6
sethi %hi(0x10000), %l7
or %l7, %lo(0x10000),  %l7
add %i3, %l6, %l6
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]

! cbranch
andcc %l0, 1, %g0
be,pt  %xcc, TARGET3874
nop
RET3874:

! lfsr step begin
srlx %l0, 1, %l3
xnor %l3, %l0, %l3
sllx %l3, 63, %l3
or  %l3, %l0, %l0
srlx %l0, 1, %l0


P3875: !_DWST [13] (maybe <- 0x410000fd) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
std %f20, [%i3 + 64]

P3876: !_DWST [1] (maybe <- 0x410000fe) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
! 1 th moved, current_fp_src=21 
fmovs  %f16, %f21
fadds  %f16, %f17, %f16
std %f20, [%i0 + 0]

P3877: !_DWST [14] (maybe <- 0x41000100) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
std %f20, [%i3 + 128]

P3878: !_CAS [1] (maybe <- 0x180006a) (Int)
add %i0, 4, %o5
lduw [%o5], %l6
mov %l6, %l7
! move %l7(lower) -> %o0(lower)
or %l7, %o0, %o0
mov %l4, %o1
cas [%o5], %l7, %o1
! move %o1(lower) -> %o1(upper)
sllx %o1, 32, %o1
add   %l4, 1, %l4

P3879: !_SWAP [3] (maybe <- 0x180006b) (Int)
mov %l4, %l3
swap  [%i0 + 32], %l3
! move %l3(lower) -> %o1(lower)
srl %l3, 0, %l7
or %l7, %o1, %o1
add   %l4, 1, %l4

P3880: !_DWLD [3] (FP)
ldd [%i0 + 32], %f18
! 1 addresses covered
fmovs %f18, %f9

P3881: !_PREFETCH [8] (Int)
prefetch [%i1 + 256], 1

P3882: !_ST [11] (maybe <- 0x41000101) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i2 + 64 ]

P3883: !_LD [10] (FP) (Branch target of P3808)
ld [%i2 + 32], %f10
! 1 addresses covered
ba P3884
nop

TARGET3808:
ba RET3808
nop


P3884: !_PREFETCH [6] (Int)
prefetch [%i1 + 80], 1

P3885: !_ST [2] (maybe <- 0x41000102) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i0 + 12 ]

P3886: !_REPLACEMENT [2] (Int)
sethi %hi(0xc), %o5
or %o5, %lo(0xc),  %o5
sethi %hi(0x10000), %l3
or %l3, %lo(0x10000),  %l3
add %i3, %o5, %o5
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]

P3887: !_DWLD [2] (FP)
ldd [%i0 + 8], %f18
! 1 addresses covered
fmovs %f19, %f11

P3888: !_REPLACEMENT [13] (Int)
sethi %hi(0x40), %l7
or %l7, %lo(0x40),  %l7
sethi %hi(0x10000), %o5
or %o5, %lo(0x10000),  %o5
add %i3, %l7, %l7
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]

P3889: !_LD [11] (FP) (CBR)
ld [%i2 + 64], %f12
! 1 addresses covered

! cbranch
andcc %l0, 1, %g0
be,pn  %xcc, TARGET3889
nop
RET3889:

! lfsr step begin
srlx %l0, 1, %l6
xnor %l6, %l0, %l6
sllx %l6, 63, %l6
or  %l6, %l0, %l0
srlx %l0, 1, %l0


P3890: !_LD [6] (FP)
ld [%i1 + 80], %f13
! 1 addresses covered

P3891: !_LD [9] (FP)
ld [%i1 + 512], %f14
! 1 addresses covered

P3892: !_LD [13] (FP)
ld [%i3 + 64], %f15
! 1 addresses covered
!---- flushing fp results buffer to %f30 ----
fmovd %f0, %f30
fmovd %f2, %f30
fmovd %f4, %f30
fmovd %f6, %f30
fmovd %f8, %f30
fmovd %f10, %f30
fmovd %f12, %f30
fmovd %f14, %f30

P3893: !_CAS [9] (maybe <- 0x180006c) (Int)
add %i1, 512, %o5
lduw [%o5], %o2
mov %o2, %l7
! move %l7(lower) -> %o2(upper)
sllx %l7, 32, %o2
mov %l4, %l6
cas [%o5], %l7, %l6
! move %l6(lower) -> %o2(lower)
srl %l6, 0, %o5
or %o5, %o2, %o2
add   %l4, 1, %l4

P3894: !_DWST [0] (maybe <- 0x41000103) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
! 1 th moved, current_fp_src=21 
fmovs  %f16, %f21
fadds  %f16, %f17, %f16
std %f20, [%i0 + 0]

P3895: !_CASX [13] (maybe <- 0x180006d) (Int)
add %i3, 64, %l7
ldx [%l7], %o3
! move %o3(upper) -> %o3(upper)
! move %o3(lower) -> %o3(lower)
mov  %o3, %l6
sllx %l4, 32, %o4
casx [%l7], %l6, %o4
! move %o4(upper) -> %o4(upper)
! move %o4(lower) -> %o4(lower)
!---- flushing int results buffer----
mov %o0, %l5
mov %o1, %l5
mov %o2, %l5
mov %o3, %l5
mov %o4, %l5
add  %l4, 1, %l4

P3896: !_LD [10] (FP)
ld [%i2 + 32], %f0
! 1 addresses covered

P3897: !_CASX [9] (maybe <- 0x180006e) (Int)
add %i1, 512, %l7
ldx [%l7], %o0
! move %o0(upper) -> %o0(upper)
! move %o0(lower) -> %o0(lower)
mov  %o0, %l6
sllx %l4, 32, %o1
casx [%l7], %l6, %o1
! move %o1(upper) -> %o1(upper)
! move %o1(lower) -> %o1(lower)
add  %l4, 1, %l4

P3898: !_PREFETCH [10] (Int)
prefetch [%i2 + 32], 1

P3899: !_LD [0] (FP)
ld [%i0 + 0], %f1
! 1 addresses covered

P3900: !_DWST [14] (maybe <- 0x41000105) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
std %f20, [%i3 + 128]

P3901: !_PREFETCH [11] (Int)
prefetch [%i2 + 64], 1

P3902: !_SWAP [14] (maybe <- 0x180006f) (Int)
mov %l4, %o2
swap  [%i3 + 128], %o2
! move %o2(lower) -> %o2(upper)
sllx %o2, 32, %o2
add   %l4, 1, %l4

P3903: !_DWST [2] (maybe <- 0x41000106) (FP)
! 0 th moved, current_fp_src=21 
fmovs  %f16, %f21
fadds  %f16, %f17, %f16
std %f20, [%i0 + 8]

P3904: !_PREFETCH [1] (Int)
prefetch [%i0 + 4], 1

P3905: !_REPLACEMENT [12] (Int)
sethi %hi(0x0), %l7
or %l7, %lo(0x0),  %l7
sethi %hi(0x10000), %o5
or %o5, %lo(0x10000),  %o5
add %i3, %l7, %l7
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]

P3906: !_DWST [4] (maybe <- 0x41000107) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
std %f20, [%i0 + 64]

P3907: !_NOP (Int)
nop

P3908: !_CASX [3] (maybe <- 0x1800070) (Int) (CBR)
add %i0, 32, %l6
ldx [%l6], %o5
! move %o5(upper) -> %o2(lower)
srlx %o5, 32, %l3
or %l3, %o2, %o2
! move %o5(lower) -> %o3(upper)
sllx %o5, 32, %o3
mov  %o5, %l3
sllx %l4, 32, %o5
casx [%l6], %l3, %o5
! move %o5(upper) -> %o3(lower)
srlx %o5, 32, %l6
or %l6, %o3, %o3
! move %o5(lower) -> %o4(upper)
sllx %o5, 32, %o4
add  %l4, 1, %l4

! cbranch
andcc %l0, 1, %g0
be,pn  %xcc, TARGET3908
nop
RET3908:

! lfsr step begin
srlx %l0, 1, %l3
xnor %l3, %l0, %l3
sllx %l3, 63, %l3
or  %l3, %l0, %l0
srlx %l0, 1, %l0


P3909: !_DWLD [15] (FP)
ldd [%i3 + 192], %f2
! 1 addresses covered

P3910: !_DWLD [12] (FP)
ldd [%i3 + 0], %f18
! 1 addresses covered
fmovs %f18, %f3

P3911: !_ST [2] (maybe <- 0x41000108) (FP) (Branch target of P3777)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i0 + 12 ]
ba P3912
nop

TARGET3777:
ba RET3777
nop


P3912: !_DWST [15] (maybe <- 0x41000109) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
std %f20, [%i3 + 192]

P3913: !_CAS [5] (maybe <- 0x1800071) (Int)
add %i1, 76, %l3
lduw [%l3], %l7
mov %l7, %o5
! move %o5(lower) -> %o4(lower)
or %o5, %o4, %o4
!---- flushing int results buffer----
mov %o0, %l5
mov %o1, %l5
mov %o2, %l5
mov %o3, %l5
mov %o4, %l5
mov %l4, %o0
cas [%l3], %o5, %o0
! move %o0(lower) -> %o0(upper)
sllx %o0, 32, %o0
add   %l4, 1, %l4

P3914: !_DWST [6] (maybe <- 0x4100010a) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
! 1 th moved, current_fp_src=21 
fmovs  %f16, %f21
fadds  %f16, %f17, %f16
std %f20, [%i1 + 80]

P3915: !_ST [10] (maybe <- 0x4100010c) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i2 + 32 ]

P3916: !_REPLACEMENT [1] (Int)
sethi %hi(0x4), %l6
or %l6, %lo(0x4),  %l6
sethi %hi(0x10000), %l7
or %l7, %lo(0x10000),  %l7
add %i3, %l6, %l6
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]

P3917: !_ST [3] (maybe <- 0x4100010d) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i0 + 32 ]

P3918: !_CASX [13] (maybe <- 0x1800072) (Int)
add %i3, 64, %l3
ldx [%l3], %l7
! move %l7(upper) -> %o0(lower)
srlx %l7, 32, %o5
or %o5, %o0, %o0
! move %l7(lower) -> %o1(upper)
sllx %l7, 32, %o1
mov  %l7, %o5
sllx %l4, 32, %l7
casx [%l3], %o5, %l7
! move %l7(upper) -> %o1(lower)
srlx %l7, 32, %l3
or %l3, %o1, %o1
! move %l7(lower) -> %o2(upper)
sllx %l7, 32, %o2
add  %l4, 1, %l4

P3919: !_DWST [9] (maybe <- 0x4100010e) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
std %f20, [%i1 + 512]

P3920: !_PREFETCH [0] (Int) (LE)
wr %g0, 0x88, %asi
prefetcha [%i0 + 0] %asi, 1

P3921: !_DWLD [13] (FP)
ldd [%i3 + 64], %f4
! 1 addresses covered

P3922: !_ST [7] (maybe <- 0x4100010f) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i1 + 84 ]

P3923: !_DWST [10] (maybe <- 0x41000110) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
std %f20, [%i2 + 32]

P3924: !_REPLACEMENT [12] (Int)
sethi %hi(0x0), %l3
or %l3, %lo(0x0),  %l3
sethi %hi(0x10000), %l6
or %l6, %lo(0x10000),  %l6
add %i3, %l3, %l3
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]

P3925: !_ST [14] (maybe <- 0x41000111) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i3 + 128 ]

P3926: !_DWLD [5] (FP)
ldd [%i1 + 72], %f18
! 1 addresses covered
fmovs %f19, %f5

P3927: !_ST [10] (maybe <- 0x41000112) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i2 + 32 ]

P3928: !_NOP (Int)
nop

P3929: !_DWLD [12] (FP)
ldd [%i3 + 0], %f6
! 1 addresses covered

P3930: !_LD [15] (FP) (Branch target of P3211)
ld [%i3 + 192], %f7
! 1 addresses covered
ba P3931
nop

TARGET3211:
ba RET3211
nop


P3931: !_REPLACEMENT [5] (Int)
sethi %hi(0x4c), %l6
or %l6, %lo(0x4c),  %l6
sethi %hi(0x10000), %l7
or %l7, %lo(0x10000),  %l7
add %i3, %l6, %l6
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]

P3932: !_DWLD [6] (FP) (CBR)
ldd [%i1 + 80], %f8
! 2 addresses covered

! cbranch
andcc %l0, 1, %g0
be,pt  %xcc, TARGET3932
nop
RET3932:

! lfsr step begin
srlx %l0, 1, %l3
xnor %l3, %l0, %l3
sllx %l3, 63, %l3
or  %l3, %l0, %l0
srlx %l0, 1, %l0


P3933: !_ST [3] (maybe <- 0x41000113) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i0 + 32 ]

P3934: !_LD [14] (FP)
ld [%i3 + 128], %f10
! 1 addresses covered

P3935: !_REPLACEMENT [3] (Int)
sethi %hi(0x20), %l3
or %l3, %lo(0x20),  %l3
sethi %hi(0x10000), %l6
or %l6, %lo(0x10000),  %l6
add %i3, %l3, %l3
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]

P3936: !_PREFETCH [8] (Int)
prefetch [%i1 + 256], 1

P3937: !_CAS [12] (maybe <- 0x1800073) (Int)
add %i3, 0, %l3
lduw [%l3], %l7
mov %l7, %o5
! move %o5(lower) -> %o2(lower)
or %o5, %o2, %o2
mov %l4, %o3
cas [%l3], %o5, %o3
! move %o3(lower) -> %o3(upper)
sllx %o3, 32, %o3
add   %l4, 1, %l4

P3938: !_CASX [10] (maybe <- 0x1800074) (Int)
add %i2, 32, %l3
ldx [%l3], %l7
! move %l7(upper) -> %o3(lower)
srlx %l7, 32, %o5
or %o5, %o3, %o3
! move %l7(lower) -> %o4(upper)
sllx %l7, 32, %o4
mov  %l7, %o5
sllx %l4, 32, %l7
casx [%l3], %o5, %l7
! move %l7(upper) -> %o4(lower)
srlx %l7, 32, %l3
or %l3, %o4, %o4
!---- flushing int results buffer----
mov %o0, %l5
mov %o1, %l5
mov %o2, %l5
mov %o3, %l5
mov %o4, %l5
! move %l7(lower) -> %o0(upper)
sllx %l7, 32, %o0
add  %l4, 1, %l4

P3939: !_REPLACEMENT [6] (Int)
sethi %hi(0x50), %o5
or %o5, %lo(0x50),  %o5
sethi %hi(0x10000), %l3
or %l3, %lo(0x10000),  %l3
add %i3, %o5, %o5
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]

P3940: !_DWLD [0] (FP)
ldd [%i0 + 0], %f18
! 2 addresses covered
fmovs %f18, %f11
fmovs %f19, %f12

P3941: !_PREFETCH [14] (Int)
prefetch [%i3 + 128], 1

P3942: !_PREFETCH [13] (Int) (CBR)
prefetch [%i3 + 64], 1

! cbranch
andcc %l0, 1, %g0
be,pn  %xcc, TARGET3942
nop
RET3942:

! lfsr step begin
srlx %l0, 1, %l7
xnor %l7, %l0, %l7
sllx %l7, 63, %l7
or  %l7, %l0, %l0
srlx %l0, 1, %l0


P3943: !_DWST [5] (maybe <- 0x41000114) (FP)
! 0 th moved, current_fp_src=21 
fmovs  %f16, %f21
fadds  %f16, %f17, %f16
std %f20, [%i1 + 72]

P3944: !_LD [3] (FP)
ld [%i0 + 32], %f13
! 1 addresses covered

P3945: !_CASX [3] (maybe <- 0x1800075) (Int)
add %i0, 32, %o5
ldx [%o5], %l6
! move %l6(upper) -> %o0(lower)
srlx %l6, 32, %l7
or %l7, %o0, %o0
! move %l6(lower) -> %o1(upper)
sllx %l6, 32, %o1
mov  %l6, %l7
sllx %l4, 32, %l6
casx [%o5], %l7, %l6
! move %l6(upper) -> %o1(lower)
srlx %l6, 32, %o5
or %o5, %o1, %o1
! move %l6(lower) -> %o2(upper)
sllx %l6, 32, %o2
add  %l4, 1, %l4

P3946: !_DWST [0] (maybe <- 0x41000115) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
! 1 th moved, current_fp_src=21 
fmovs  %f16, %f21
fadds  %f16, %f17, %f16
std %f20, [%i0 + 0]

P3947: !_DWLD [6] (FP)
ldd [%i1 + 80], %f14
! 2 addresses covered
!---- flushing fp results buffer to %f30 ----
fmovd %f0, %f30
fmovd %f2, %f30
fmovd %f4, %f30
fmovd %f6, %f30
fmovd %f8, %f30
fmovd %f10, %f30
fmovd %f12, %f30
fmovd %f14, %f30

P3948: !_DWST [12] (maybe <- 0x41000117) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
std %f20, [%i3 + 0]

P3949: !_REPLACEMENT [6] (Int)
sethi %hi(0x50), %l3
or %l3, %lo(0x50),  %l3
sethi %hi(0x10000), %l6
or %l6, %lo(0x10000),  %l6
add %i3, %l3, %l3
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]

P3950: !_DWLD [8] (FP)
ldd [%i1 + 256], %f0
! 1 addresses covered

P3951: !_SWAP [11] (maybe <- 0x1800076) (Int)
mov %l4, %l6
swap  [%i2 + 64], %l6
! move %l6(lower) -> %o2(lower)
srl %l6, 0, %o5
or %o5, %o2, %o2
add   %l4, 1, %l4

P3952: !_PREFETCH [10] (Int)
prefetch [%i2 + 32], 1

P3953: !_CASX [11] (maybe <- 0x1800077) (Int)
add %i2, 64, %o5
ldx [%o5], %o3
! move %o3(upper) -> %o3(upper)
! move %o3(lower) -> %o3(lower)
mov  %o3, %l7
sllx %l4, 32, %o4
casx [%o5], %l7, %o4
! move %o4(upper) -> %o4(upper)
! move %o4(lower) -> %o4(lower)
!---- flushing int results buffer----
mov %o0, %l5
mov %o1, %l5
mov %o2, %l5
mov %o3, %l5
mov %o4, %l5
add  %l4, 1, %l4

P3954: !_DWLD [13] (FP)
ldd [%i3 + 64], %f18
! 1 addresses covered
fmovs %f18, %f1

P3955: !_DWLD [4] (FP)
ldd [%i0 + 64], %f2
! 1 addresses covered

P3956: !_REPLACEMENT [8] (Int)
sethi %hi(0x100), %l7
or %l7, %lo(0x100),  %l7
sethi %hi(0x10000), %o5
or %o5, %lo(0x10000),  %o5
add %i3, %l7, %l7
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]

P3957: !_PREFETCH [6] (Int)
prefetch [%i1 + 80], 1

P3958: !_CAS [15] (maybe <- 0x1800078) (Int)
add %i3, 192, %l7
lduw [%l7], %o0
mov %o0, %l6
! move %l6(lower) -> %o0(upper)
sllx %l6, 32, %o0
mov %l4, %l3
cas [%l7], %l6, %l3
! move %l3(lower) -> %o0(lower)
srl %l3, 0, %l7
or %l7, %o0, %o0
add   %l4, 1, %l4

P3959: !_DWLD [14] (FP)
ldd [%i3 + 128], %f18
! 1 addresses covered
fmovs %f18, %f3

P3960: !_REPLACEMENT [1] (Int)
sethi %hi(0x4), %l6
or %l6, %lo(0x4),  %l6
sethi %hi(0x10000), %l7
or %l7, %lo(0x10000),  %l7
add %i3, %l6, %l6
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]

P3961: !_PREFETCH [10] (Int)
prefetch [%i2 + 32], 1

P3962: !_LD [4] (FP)
ld [%i0 + 64], %f4
! 1 addresses covered

P3963: !_LD [14] (FP)
ld [%i3 + 128], %f5
! 1 addresses covered

P3964: !_ST [3] (maybe <- 0x41000118) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i0 + 32 ]

P3965: !_ST [4] (maybe <- 0x41000119) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i0 + 64 ]

P3966: !_LD [4] (FP)
ld [%i0 + 64], %f6
! 1 addresses covered

P3967: !_ST [9] (maybe <- 0x4100011a) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i1 + 512 ]

P3968: !_ST [10] (maybe <- 0x4100011b) (FP) (Branch target of P3717)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i2 + 32 ]
ba P3969
nop

TARGET3717:
ba RET3717
nop


P3969: !_DWLD [2] (FP)
ldd [%i0 + 8], %f18
! 1 addresses covered
fmovs %f19, %f7

P3970: !_LD [14] (FP)
ld [%i3 + 128], %f8
! 1 addresses covered

P3971: !_REPLACEMENT [7] (Int)
sethi %hi(0x54), %l3
or %l3, %lo(0x54),  %l3
sethi %hi(0x10000), %l6
or %l6, %lo(0x10000),  %l6
add %i3, %l3, %l3
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]

P3972: !_LD [1] (FP)
ld [%i0 + 4], %f9
! 1 addresses covered

P3973: !_LD [4] (FP)
ld [%i0 + 64], %f10
! 1 addresses covered

P3974: !_ST [8] (maybe <- 0x4100011c) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i1 + 256 ]

P3975: !_PREFETCH [14] (Int) (CBR)
prefetch [%i3 + 128], 1

! cbranch
andcc %l0, 1, %g0
be,pt  %xcc, TARGET3975
nop
RET3975:

! lfsr step begin
srlx %l0, 1, %l7
xnor %l7, %l0, %l7
sllx %l7, 63, %l7
or  %l7, %l0, %l0
srlx %l0, 1, %l0


P3976: !_DWST [5] (maybe <- 0x4100011d) (FP)
! 0 th moved, current_fp_src=21 
fmovs  %f16, %f21
fadds  %f16, %f17, %f16
std %f20, [%i1 + 72]

P3977: !_REPLACEMENT [2] (Int)
sethi %hi(0xc), %l7
or %l7, %lo(0xc),  %l7
sethi %hi(0x10000), %o5
or %o5, %lo(0x10000),  %o5
add %i3, %l7, %l7
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]

P3978: !_REPLACEMENT [0] (Int)
sethi %hi(0x0), %l6
or %l6, %lo(0x0),  %l6
sethi %hi(0x10000), %l7
or %l7, %lo(0x10000),  %l7
add %i3, %l6, %l6
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]

P3979: !_DWST [15] (maybe <- 0x4100011e) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
std %f20, [%i3 + 192]

P3980: !_DWLD [15] (FP)
ldd [%i3 + 192], %f18
! 1 addresses covered
fmovs %f18, %f11

P3981: !_LD [2] (FP)
ld [%i0 + 12], %f12
! 1 addresses covered

P3982: !_ST [9] (maybe <- 0x4100011f) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i1 + 512 ]

P3983: !_PREFETCH [11] (Int) (LE)
wr %g0, 0x88, %asi
prefetcha [%i2 + 64] %asi, 1

P3984: !_DWST [10] (maybe <- 0x41000120) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
std %f20, [%i2 + 32]

P3985: !_PREFETCH [8] (Int)
prefetch [%i1 + 256], 1

P3986: !_PREFETCH [12] (Int)
prefetch [%i3 + 0], 1

P3987: !_LD [8] (FP)
ld [%i1 + 256], %f13
! 1 addresses covered

P3988: !_ST [2] (maybe <- 0x41000121) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i0 + 12 ]

P3989: !_REPLACEMENT [9] (Int)
sethi %hi(0x200), %l3
or %l3, %lo(0x200),  %l3
sethi %hi(0x10000), %l6
or %l6, %lo(0x10000),  %l6
add %i3, %l3, %l3
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]

P3990: !_ST [14] (maybe <- 0x41000122) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i3 + 128 ]

P3991: !_DWST [15] (maybe <- 0x41000123) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
std %f20, [%i3 + 192]

P3992: !_REPLACEMENT [4] (Int) (Branch target of P3577)
sethi %hi(0x40), %l6
or %l6, %lo(0x40),  %l6
sethi %hi(0x10000), %l7
or %l7, %lo(0x10000),  %l7
add %i3, %l6, %l6
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
ba P3993
nop

TARGET3577:
ba RET3577
nop


P3993: !_DWST [9] (maybe <- 0x41000124) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
std %f20, [%i1 + 512]

P3994: !_ST [13] (maybe <- 0x41000125) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i3 + 64 ]

P3995: !_DWST [14] (maybe <- 0x41000126) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
std %f20, [%i3 + 128]

P3996: !_DWST [12] (maybe <- 0x41000127) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
std %f20, [%i3 + 0]

P3997: !_ST [9] (maybe <- 0x41000128) (FP) (CBR)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i1 + 512 ]

! cbranch
andcc %l0, 1, %g0
be,pt  %xcc, TARGET3997
nop
RET3997:

! lfsr step begin
srlx %l0, 1, %o5
xnor %o5, %l0, %o5
sllx %o5, 63, %o5
or  %o5, %l0, %l0
srlx %l0, 1, %l0


P3998: !_DWST [5] (maybe <- 0x41000129) (FP) (CBR)
! 0 th moved, current_fp_src=21 
fmovs  %f16, %f21
fadds  %f16, %f17, %f16
std %f20, [%i1 + 72]

! cbranch
andcc %l0, 1, %g0
be,pn  %xcc, TARGET3998
nop
RET3998:

! lfsr step begin
srlx %l0, 1, %o5
xnor %o5, %l0, %o5
sllx %o5, 63, %o5
or  %o5, %l0, %l0
srlx %l0, 1, %l0


P3999: !_REPLACEMENT [12] (Int)
sethi %hi(0x0), %l3
or %l3, %lo(0x0),  %l3
sethi %hi(0x10000), %l6
or %l6, %lo(0x10000),  %l6
add %i3, %l3, %l3
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]

P4000: !_ST [0] (maybe <- 0x4100012a) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i0 + 0 ]

P4001: !_DWLD [7] (FP)
ldd [%i1 + 80], %f14
! 2 addresses covered
!---- flushing fp results buffer to %f30 ----
fmovd %f0, %f30
fmovd %f2, %f30
fmovd %f4, %f30
fmovd %f6, %f30
fmovd %f8, %f30
fmovd %f10, %f30
fmovd %f12, %f30
fmovd %f14, %f30

P4002: !_MEMBAR (Int)
membar #StoreLoad

P4003: !_LD [0] (FP)
ld [%i0 + 0], %f0
! 1 addresses covered

P4004: !_LD [1] (FP) (CBR)
ld [%i0 + 4], %f1
! 1 addresses covered

! cbranch
andcc %l0, 1, %g0
be,pn  %xcc, TARGET4004
nop
RET4004:

! lfsr step begin
srlx %l0, 1, %l7
xnor %l7, %l0, %l7
sllx %l7, 63, %l7
or  %l7, %l0, %l0
srlx %l0, 1, %l0


P4005: !_REPLACEMENT [0] (Int) (Branch target of P3942)
sethi %hi(0x0), %o5
or %o5, %lo(0x0),  %o5
sethi %hi(0x10000), %l3
or %l3, %lo(0x10000),  %l3
add %i3, %o5, %o5
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
ba P4006
nop

TARGET3942:
ba RET3942
nop


P4006: !_REPLACEMENT [5] (Int)
sethi %hi(0x4c), %l7
or %l7, %lo(0x4c),  %l7
sethi %hi(0x10000), %o5
or %o5, %lo(0x10000),  %o5
add %i3, %l7, %l7
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]

P4007: !_DWST [15] (maybe <- 0x4100012b) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
std %f20, [%i3 + 192]

P4008: !_LD [6] (FP)
ld [%i1 + 80], %f2
! 1 addresses covered

P4009: !_PREFETCH [14] (Int)
prefetch [%i3 + 128], 1

P4010: !_PREFETCH [8] (Int)
prefetch [%i1 + 256], 1

P4011: !_SWAP [0] (maybe <- 0x1800079) (Int)
mov %l4, %o1
swap  [%i0 + 0], %o1
! move %o1(lower) -> %o1(upper)
sllx %o1, 32, %o1
add   %l4, 1, %l4

P4012: !_LD [11] (FP)
ld [%i2 + 64], %f3
! 1 addresses covered

P4013: !_SWAP [14] (maybe <- 0x180007a) (Int)
mov %l4, %l6
swap  [%i3 + 128], %l6
! move %l6(lower) -> %o1(lower)
srl %l6, 0, %o5
or %o5, %o1, %o1
add   %l4, 1, %l4

P4014: !_DWLD [9] (FP)
ldd [%i1 + 512], %f4
! 1 addresses covered

P4015: !_DWST [13] (maybe <- 0x4100012c) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
std %f20, [%i3 + 64]

P4016: !_DWLD [14] (FP)
ldd [%i3 + 128], %f18
! 1 addresses covered
fmovs %f18, %f5

P4017: !_DWLD [10] (FP)
ldd [%i2 + 32], %f6
! 1 addresses covered

P4018: !_LD [7] (FP)
ld [%i1 + 84], %f7
! 1 addresses covered

P4019: !_DWST [0] (maybe <- 0x4100012d) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
! 1 th moved, current_fp_src=21 
fmovs  %f16, %f21
fadds  %f16, %f17, %f16
std %f20, [%i0 + 0]

P4020: !_PREFETCH [9] (Int)
prefetch [%i1 + 512], 1

P4021: !_DWST [10] (maybe <- 0x4100012f) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
std %f20, [%i2 + 32]

P4022: !_DWST [14] (maybe <- 0x41000130) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
std %f20, [%i3 + 128]

P4023: !_DWST [14] (maybe <- 0x41000131) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
std %f20, [%i3 + 128]

P4024: !_MEMBAR (Int)
membar #StoreLoad

P4025: !_CASX [9] (maybe <- 0x180007b) (Int)
add %i1, 512, %l7
ldx [%l7], %o2
! move %o2(upper) -> %o2(upper)
! move %o2(lower) -> %o2(lower)
mov  %o2, %l6
sllx %l4, 32, %o3
casx [%l7], %l6, %o3
! move %o3(upper) -> %o3(upper)
! move %o3(lower) -> %o3(lower)
add  %l4, 1, %l4

P4026: !_ST [8] (maybe <- 0x41000132) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i1 + 256 ]

P4027: !_ST [0] (maybe <- 0x41000133) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i0 + 0 ]

P4028: !_DWST [12] (maybe <- 0x41000134) (FP) (CBR)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
std %f20, [%i3 + 0]

! cbranch
andcc %l0, 1, %g0
be,pt  %xcc, TARGET4028
nop
RET4028:

! lfsr step begin
srlx %l0, 1, %l7
xnor %l7, %l0, %l7
sllx %l7, 63, %l7
or  %l7, %l0, %l0
srlx %l0, 1, %l0


P4029: !_SWAP [4] (maybe <- 0x180007c) (Int) (Branch target of P3151)
mov %l4, %o4
swap  [%i0 + 64], %o4
! move %o4(lower) -> %o4(upper)
sllx %o4, 32, %o4
add   %l4, 1, %l4
ba P4030
nop

TARGET3151:
ba RET3151
nop


P4030: !_DWST [2] (maybe <- 0x41000135) (FP)
! 0 th moved, current_fp_src=21 
fmovs  %f16, %f21
fadds  %f16, %f17, %f16
std %f20, [%i0 + 8]

P4031: !_DWLD [8] (FP)
ldd [%i1 + 256], %f8
! 1 addresses covered

P4032: !_REPLACEMENT [15] (Int)
sethi %hi(0xc0), %l6
or %l6, %lo(0xc0),  %l6
sethi %hi(0x10000), %l7
or %l7, %lo(0x10000),  %l7
add %i3, %l6, %l6
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]

P4033: !_LD [5] (FP) (Branch target of P3712)
ld [%i1 + 76], %f9
! 1 addresses covered
ba P4034
nop

TARGET3712:
ba RET3712
nop


P4034: !_DWST [13] (maybe <- 0x41000136) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
std %f20, [%i3 + 64]

P4035: !_SWAP [3] (maybe <- 0x180007d) (Int)
mov %l4, %l6
swap  [%i0 + 32], %l6
! move %l6(lower) -> %o4(lower)
srl %l6, 0, %o5
or %o5, %o4, %o4
!---- flushing int results buffer----
mov %o0, %l5
mov %o1, %l5
mov %o2, %l5
mov %o3, %l5
mov %o4, %l5
add   %l4, 1, %l4

P4036: !_PREFETCH [2] (Int) (Branch target of P3086)
prefetch [%i0 + 12], 1
ba P4037
nop

TARGET3086:
ba RET3086
nop


P4037: !_REPLACEMENT [15] (Int)
sethi %hi(0xc0), %l7
or %l7, %lo(0xc0),  %l7
sethi %hi(0x10000), %o5
or %o5, %lo(0x10000),  %o5
add %i3, %l7, %l7
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]

P4038: !_CASX [15] (maybe <- 0x180007e) (Int)
add %i3, 192, %l7
ldx [%l7], %o0
! move %o0(upper) -> %o0(upper)
! move %o0(lower) -> %o0(lower)
mov  %o0, %l6
sllx %l4, 32, %o1
casx [%l7], %l6, %o1
! move %o1(upper) -> %o1(upper)
! move %o1(lower) -> %o1(lower)
add  %l4, 1, %l4

P4039: !_PREFETCH [13] (Int) (LE)
wr %g0, 0x88, %asi
prefetcha [%i3 + 64] %asi, 1

P4040: !_ST [3] (maybe <- 0x41000137) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i0 + 32 ]

P4041: !_REPLACEMENT [12] (Int)
sethi %hi(0x0), %l3
or %l3, %lo(0x0),  %l3
sethi %hi(0x10000), %l6
or %l6, %lo(0x10000),  %l6
add %i3, %l3, %l3
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]

P4042: !_REPLACEMENT [13] (Int)
sethi %hi(0x40), %o5
or %o5, %lo(0x40),  %o5
sethi %hi(0x10000), %l3
or %l3, %lo(0x10000),  %l3
add %i3, %o5, %o5
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]

P4043: !_REPLACEMENT [13] (Int)
sethi %hi(0x40), %l7
or %l7, %lo(0x40),  %l7
sethi %hi(0x10000), %o5
or %o5, %lo(0x10000),  %o5
add %i3, %l7, %l7
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]

P4044: !_DWLD [0] (FP)
ldd [%i0 + 0], %f10
! 2 addresses covered

P4045: !_CASX [12] (maybe <- 0x180007f) (Int)
add %i3, 0, %l7
ldx [%l7], %o2
! move %o2(upper) -> %o2(upper)
! move %o2(lower) -> %o2(lower)
mov  %o2, %l6
sllx %l4, 32, %o3
casx [%l7], %l6, %o3
! move %o3(upper) -> %o3(upper)
! move %o3(lower) -> %o3(lower)
add  %l4, 1, %l4

P4046: !_DWLD [8] (FP)
ldd [%i1 + 256], %f12
! 1 addresses covered

P4047: !_REPLACEMENT [13] (Int)
sethi %hi(0x40), %l6
or %l6, %lo(0x40),  %l6
sethi %hi(0x10000), %l7
or %l7, %lo(0x10000),  %l7
add %i3, %l6, %l6
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]

P4048: !_CAS [12] (maybe <- 0x1800080) (Int)
add %i3, 0, %l6
lduw [%l6], %o4
mov %o4, %l3
! move %l3(lower) -> %o4(upper)
sllx %l3, 32, %o4
mov %l4, %o5
cas [%l6], %l3, %o5
! move %o5(lower) -> %o4(lower)
srl %o5, 0, %l6
or %l6, %o4, %o4
!---- flushing int results buffer----
mov %o0, %l5
mov %o1, %l5
mov %o2, %l5
mov %o3, %l5
mov %o4, %l5
add   %l4, 1, %l4

P4049: !_DWLD [14] (FP)
ldd [%i3 + 128], %f18
! 1 addresses covered
fmovs %f18, %f13

P4050: !_ST [15] (maybe <- 0x41000138) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i3 + 192 ]

P4051: !_DWLD [3] (FP)
ldd [%i0 + 32], %f14
! 1 addresses covered

P4052: !_ST [3] (maybe <- 0x41000139) (FP) (Branch target of P3889)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i0 + 32 ]
ba P4053
nop

TARGET3889:
ba RET3889
nop


P4053: !_LD [7] (FP)
ld [%i1 + 84], %f15
! 1 addresses covered
!---- flushing fp results buffer to %f30 ----
fmovd %f0, %f30
fmovd %f2, %f30
fmovd %f4, %f30
fmovd %f6, %f30
fmovd %f8, %f30
fmovd %f10, %f30
fmovd %f12, %f30
fmovd %f14, %f30

P4054: !_PREFETCH [1] (Int)
prefetch [%i0 + 4], 1

P4055: !_CASX [5] (maybe <- 0x1800081) (Int)
add %i1, 72, %o5
ldx [%o5], %o0
! move %o0(upper) -> %o0(upper)
! move %o0(lower) -> %o0(lower)
mov  %o0, %l7
mov %l4, %o1
casx [%o5], %l7, %o1
! move %o1(upper) -> %o1(upper)
! move %o1(lower) -> %o1(lower)
add  %l4, 1, %l4

P4056: !_REPLACEMENT [10] (Int)
sethi %hi(0x20), %l7
or %l7, %lo(0x20),  %l7
sethi %hi(0x10000), %o5
or %o5, %lo(0x10000),  %o5
add %i3, %l7, %l7
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]

P4057: !_DWST [0] (maybe <- 0x4100013a) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
! 1 th moved, current_fp_src=21 
fmovs  %f16, %f21
fadds  %f16, %f17, %f16
std %f20, [%i0 + 0]

P4058: !_LD [7] (FP)
ld [%i1 + 84], %f0
! 1 addresses covered

P4059: !_PREFETCH [6] (Int)
prefetch [%i1 + 80], 1

P4060: !_DWLD [2] (FP)
ldd [%i0 + 8], %f18
! 1 addresses covered
fmovs %f19, %f1

P4061: !_REPLACEMENT [9] (Int)
sethi %hi(0x200), %l3
or %l3, %lo(0x200),  %l3
sethi %hi(0x10000), %l6
or %l6, %lo(0x10000),  %l6
add %i3, %l3, %l3
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]

P4062: !_CASX [3] (maybe <- 0x1800082) (Int) (Branch target of P3233)
add %i0, 32, %l3
ldx [%l3], %o2
! move %o2(upper) -> %o2(upper)
! move %o2(lower) -> %o2(lower)
mov  %o2, %o5
sllx %l4, 32, %o3
casx [%l3], %o5, %o3
! move %o3(upper) -> %o3(upper)
! move %o3(lower) -> %o3(lower)
add  %l4, 1, %l4
ba P4063
nop

TARGET3233:
ba RET3233
nop


P4063: !_LD [14] (FP) (CBR)
ld [%i3 + 128], %f2
! 1 addresses covered

! cbranch
andcc %l0, 1, %g0
be,pt  %xcc, TARGET4063
nop
RET4063:

! lfsr step begin
srlx %l0, 1, %o5
xnor %o5, %l0, %o5
sllx %o5, 63, %o5
or  %o5, %l0, %l0
srlx %l0, 1, %l0


P4064: !_DWLD [8] (FP)
ldd [%i1 + 256], %f18
! 1 addresses covered
fmovs %f18, %f3

P4065: !_PREFETCH [12] (Int)
prefetch [%i3 + 0], 1

P4066: !_REPLACEMENT [9] (Int)
sethi %hi(0x200), %l3
or %l3, %lo(0x200),  %l3
sethi %hi(0x10000), %l6
or %l6, %lo(0x10000),  %l6
add %i3, %l3, %l3
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]

P4067: !_REPLACEMENT [13] (Int)
sethi %hi(0x40), %o5
or %o5, %lo(0x40),  %o5
sethi %hi(0x10000), %l3
or %l3, %lo(0x10000),  %l3
add %i3, %o5, %o5
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]

P4068: !_DWST [10] (maybe <- 0x4100013c) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
std %f20, [%i2 + 32]

P4069: !_DWLD [10] (FP)
ldd [%i2 + 32], %f4
! 1 addresses covered

P4070: !_PREFETCH [2] (Int)
prefetch [%i0 + 12], 1

P4071: !_REPLACEMENT [8] (Int)
sethi %hi(0x100), %l6
or %l6, %lo(0x100),  %l6
sethi %hi(0x10000), %l7
or %l7, %lo(0x10000),  %l7
add %i3, %l6, %l6
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]

P4072: !_PREFETCH [10] (Int)
prefetch [%i2 + 32], 1

P4073: !_DWST [13] (maybe <- 0x4100013d) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
std %f20, [%i3 + 64]

P4074: !_ST [2] (maybe <- 0x4100013e) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i0 + 12 ]

P4075: !_SWAP [8] (maybe <- 0x1800083) (Int)
mov %l4, %o4
swap  [%i1 + 256], %o4
! move %o4(lower) -> %o4(upper)
sllx %o4, 32, %o4
add   %l4, 1, %l4

P4076: !_DWLD [7] (FP)
ldd [%i1 + 80], %f18
! 2 addresses covered
fmovs %f18, %f5
fmovs %f19, %f6

P4077: !_LD [13] (FP)
ld [%i3 + 64], %f7
! 1 addresses covered

P4078: !_MEMBAR (Int)
membar #StoreLoad

P4079: !_LD [0] (FP)
ld [%i0 + 0], %f8
! 1 addresses covered

P4080: !_LD [1] (FP)
ld [%i0 + 4], %f9
! 1 addresses covered

P4081: !_LD [2] (FP)
ld [%i0 + 12], %f10
! 1 addresses covered

P4082: !_LD [3] (FP)
ld [%i0 + 32], %f11
! 1 addresses covered

P4083: !_LD [4] (FP)
ld [%i0 + 64], %f12
! 1 addresses covered

P4084: !_LD [5] (FP)
ld [%i1 + 76], %f13
! 1 addresses covered

P4085: !_LD [6] (FP)
ld [%i1 + 80], %f14
! 1 addresses covered

P4086: !_LD [7] (FP)
ld [%i1 + 84], %f15
! 1 addresses covered
!---- flushing fp results buffer to %f30 ----
fmovd %f0, %f30
fmovd %f2, %f30
fmovd %f4, %f30
fmovd %f6, %f30
fmovd %f8, %f30
fmovd %f10, %f30
fmovd %f12, %f30
fmovd %f14, %f30

P4087: !_LD [8] (FP)
ld [%i1 + 256], %f0
! 1 addresses covered

P4088: !_LD [9] (FP)
ld [%i1 + 512], %f1
! 1 addresses covered

P4089: !_LD [10] (FP)
ld [%i2 + 32], %f2
! 1 addresses covered

P4090: !_LD [11] (FP)
ld [%i2 + 64], %f3
! 1 addresses covered

P4091: !_LD [12] (FP)
ld [%i3 + 0], %f4
! 1 addresses covered

P4092: !_LD [13] (FP)
ld [%i3 + 64], %f5
! 1 addresses covered

P4093: !_LD [14] (FP)
ld [%i3 + 128], %f6
! 1 addresses covered

P4094: !_LD [15] (FP)
ld [%i3 + 192], %f7
! 1 addresses covered

END_NODES3: ! Test istream for CPU 3 ends
sethi %hi(0xdead0e0f), %l6
or    %l6, %lo(0xdead0e0f), %l6
! move %l6(lower) -> %o4(lower)
or %l6, %o4, %o4
!---- flushing int results buffer----
mov %o0, %l5
mov %o1, %l5
mov %o2, %l5
mov %o3, %l5
mov %o4, %l5
stw %l6, [%i5] 
ld [%i5], %f8
!---- flushing fp results buffer to %f30 ----
fmovd %f0, %f30
fmovd %f2, %f30
fmovd %f4, %f30
fmovd %f6, %f30
fmovd %f8, %f30

restore
retl
nop
!-----------------

! register usage:
! %i0 %i1 %i2 %i3 : base registers for 4 regions
! %i4 fixed pointer to per-cpu results area
! %l1 moving pointer to per-cpu FP results area
! %o7 moving pointer to per-cpu integer results area
! %i5 pointer to per-cpu private area
! %l0 holds lfsr, used as source of random bits 
! %l2 loop count register
! %f16 running counter for unique fp store values
! %f17 holds increment value for fp counter
! %l4 running counter for unique integer store values (increment value is always 1)
! %l5 move-to register for load values (simulation only)
! %f30 move-to register for FP values (simulation only)
! %l3 %l6 %l7 %o5 : 4 temporary registers
! %o0 %o1 %o2 %o3 %o4 : 5 integer results buffer registers
! %f0-f15 FP results buffer registers
! %f32-f47 FP block load/store registers

func4:
! 1000 (dynamic) instruction sequence begins
save   %sp, -192, %sp

! Force %i0-%i3 to be 64-byte aligned
add %i0, 63, %i0
andn %i0, 63, %i0

add %i1, 63, %i1
andn %i1, 63, %i1

add %i2, 63, %i2
andn %i2, 63, %i2

add %i3, 63, %i3
andn %i3, 63, %i3

add %i4, 63, %i4
andn %i4, 63, %i4

add %i5, 63, %i5
andn %i5, 63, %i5


! Initialize pointer to FP load results area
mov   %i4, %l1

! Initialize pointer to integer load results area
sethi %hi(0x80000), %o7
or    %o7, %lo(0x80000), %o7
add  %o7, %l1, %o7 

! Initialize %f0-%f62 to 0xdeadbee0deadbee1
sethi %hi(0xdeadbee0), %l3
or    %l3, %lo(0xdeadbee0), %l3
stw   %l3, [%i5]
sethi %hi(0xdeadbee1), %l3
or    %l3, %lo(0xdeadbee1), %l3
stw   %l3, [%i5+4]
ldd [%i5], %f0
fmovd %f0, %f2
fmovd %f0, %f4
fmovd %f0, %f6
fmovd %f0, %f8
fmovd %f0, %f10
fmovd %f0, %f12
fmovd %f0, %f14
fmovd %f0, %f16
fmovd %f0, %f18
fmovd %f0, %f20
fmovd %f0, %f22
fmovd %f0, %f24
fmovd %f0, %f26
fmovd %f0, %f28
fmovd %f0, %f30
fmovd %f0, %f32
fmovd %f0, %f34
fmovd %f0, %f36
fmovd %f0, %f38
fmovd %f0, %f40
fmovd %f0, %f42
fmovd %f0, %f44
fmovd %f0, %f46
fmovd %f0, %f48
fmovd %f0, %f50
fmovd %f0, %f52
fmovd %f0, %f54
fmovd %f0, %f56
fmovd %f0, %f58
fmovd %f0, %f60
fmovd %f0, %f62

! Signature for extract_loads script to start extracting load values for this stream
sethi %hi(0x04deade1), %l3
or    %l3, %lo(0x04deade1), %l3
stw %l3, [%i5] 
ld [%i5], %f16

! Initialize running integer counter in register %l4
sethi %hi(0x2000001), %l4
or    %l4, %lo(0x2000001), %l4

! Initialize running FP counter in register %f16
sethi %hi(0x41800001), %l3
or    %l3, %lo(0x41800001), %l3
stw %l3, [%i5] 
ld [%i5], %f16

! Initialize FP counter increment value in register %f17 (constant)
sethi %hi(0x36000000), %l3
or    %l3, %lo(0x36000000), %l3
stw %l3, [%i5] 
ld [%i5], %f17 

! Initialize LFSR to 0xd5c^4
sethi %hi(0xd5c), %l0
or    %l0, %lo(0xd5c), %l0
mulx  %l0, %l0, %l0
mulx  %l0, %l0, %l0

!-- init shared addrs 8 to 9 ---
stx %g0, [%i1+256]
stx %g0, [%i1+512]

! use untouched cache-line (offset 4K) in replacement area for sync
sub %i1, %i0, %l6
add %i3, %l6, %l6
sub %l6, -4096, %l6

!-- begin of sync_init ---
or %g0, 1, %l7
or %g0, %l7, %o5
swap [%l6+4], %o5
membar #Sync
sync_init_1_4:
brnz,pt %l7, sync_init_1_4
lduw [%l6+4], %l7 ! delay slot
sync_init_2_4:
lduw [%l6], %l7
sub %l7, 1, %o5
cas [%l6], %l7, %o5
cmp %l7, %o5
bne,pt %xcc, sync_init_2_4
nop
membar #Sync
sync_init_3_4:
lduw [%l6], %l7 ! delay slot
brnz,pt %l7, sync_init_3_4
nop
!-- end of sync_init ---


BEGIN_NODES4: ! Test istream for CPU 4 begins

P4095: !_ST [8] (maybe <- 0x41800001) (FP) (Loop entry)
sethi %hi(0x1), %l2
or %l2, %lo(0x1),  %l2
loop_entry_4_0:
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i1 + 256 ]

P4096: !_DWST [8] (maybe <- 0x41800002) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
std %f20, [%i1 + 256]

P4097: !_REPLACEMENT [2] (Int)
sethi %hi(0xc), %l7
or %l7, %lo(0xc),  %l7
sethi %hi(0x10000), %o5
or %o5, %lo(0x10000),  %o5
add %i3, %l7, %l7
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]

P4098: !_MEMBAR (Int)
membar #StoreLoad

P4099: !_DWLD [15] (FP)
ldd [%i3 + 192], %f0
! 1 addresses covered

P4100: !_DWLD [13] (FP)
ldd [%i3 + 64], %f18
! 1 addresses covered
fmovs %f18, %f1

P4101: !_LD [5] (FP)
ld [%i1 + 76], %f2
! 1 addresses covered

P4102: !_PREFETCH [14] (Int)
prefetch [%i3 + 128], 1

P4103: !_CASX [12] (maybe <- 0x2000001) (Int)
add %i3, 0, %l7
ldx [%l7], %o0
! move %o0(upper) -> %o0(upper)
! move %o0(lower) -> %o0(lower)
mov  %o0, %l6
sllx %l4, 32, %o1
casx [%l7], %l6, %o1
! move %o1(upper) -> %o1(upper)
! move %o1(lower) -> %o1(lower)
add  %l4, 1, %l4

P4104: !_DWST [12] (maybe <- 0x41800003) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
std %f20, [%i3 + 0]

P4105: !_LD [9] (FP)
ld [%i1 + 512], %f3
! 1 addresses covered

P4106: !_LD [12] (FP)
ld [%i3 + 0], %f4
! 1 addresses covered

P4107: !_REPLACEMENT [9] (Int)
sethi %hi(0x200), %l3
or %l3, %lo(0x200),  %l3
sethi %hi(0x10000), %l6
or %l6, %lo(0x10000),  %l6
add %i3, %l3, %l3
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]

P4108: !_PREFETCH [13] (Int)
prefetch [%i3 + 64], 1

P4109: !_CASX [11] (maybe <- 0x2000002) (Int)
add %i2, 64, %l3
ldx [%l3], %o2
! move %o2(upper) -> %o2(upper)
! move %o2(lower) -> %o2(lower)
mov  %o2, %o5
sllx %l4, 32, %o3
casx [%l3], %o5, %o3
! move %o3(upper) -> %o3(upper)
! move %o3(lower) -> %o3(lower)
add  %l4, 1, %l4

P4110: !_DWST [1] (maybe <- 0x41800004) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
! 1 th moved, current_fp_src=21 
fmovs  %f16, %f21
fadds  %f16, %f17, %f16
std %f20, [%i0 + 0]

P4111: !_PREFETCH [0] (Int)
prefetch [%i0 + 0], 1

P4112: !_DWLD [9] (FP)
ldd [%i1 + 512], %f18
! 1 addresses covered
fmovs %f18, %f5

P4113: !_DWLD [9] (FP)
ldd [%i1 + 512], %f6
! 1 addresses covered

P4114: !_ST [4] (maybe <- 0x41800006) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i0 + 64 ]

P4115: !_DWLD [6] (FP)
ldd [%i1 + 80], %f18
! 2 addresses covered
fmovs %f18, %f7
fmovs %f19, %f8

P4116: !_ST [9] (maybe <- 0x41800007) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i1 + 512 ]

P4117: !_REPLACEMENT [3] (Int)
sethi %hi(0x20), %l3
or %l3, %lo(0x20),  %l3
sethi %hi(0x10000), %l6
or %l6, %lo(0x10000),  %l6
add %i3, %l3, %l3
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]

P4118: !_REPLACEMENT [5] (Int)
sethi %hi(0x4c), %o5
or %o5, %lo(0x4c),  %o5
sethi %hi(0x10000), %l3
or %l3, %lo(0x10000),  %l3
add %i3, %o5, %o5
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]

P4119: !_DWLD [14] (FP)
ldd [%i3 + 128], %f18
! 1 addresses covered
fmovs %f18, %f9

P4120: !_PREFETCH [1] (Int)
prefetch [%i0 + 4], 1

P4121: !_DWLD [2] (FP)
ldd [%i0 + 8], %f10
! 1 addresses covered
fmovs %f11, %f10

P4122: !_LD [3] (FP)
ld [%i0 + 32], %f11
! 1 addresses covered

P4123: !_DWST [7] (maybe <- 0x41800008) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
! 1 th moved, current_fp_src=21 
fmovs  %f16, %f21
fadds  %f16, %f17, %f16
std %f20, [%i1 + 80]

P4124: !_PREFETCH [0] (Int)
prefetch [%i0 + 0], 1

P4125: !_DWLD [10] (FP) (CBR)
ldd [%i2 + 32], %f12
! 1 addresses covered

! cbranch
andcc %l0, 1, %g0
be,pt  %xcc, TARGET4125
nop
RET4125:

! lfsr step begin
srlx %l0, 1, %l6
xnor %l6, %l0, %l6
sllx %l6, 63, %l6
or  %l6, %l0, %l0
srlx %l0, 1, %l0


P4126: !_ST [11] (maybe <- 0x4180000a) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i2 + 64 ]

P4127: !_ST [10] (maybe <- 0x4180000b) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i2 + 32 ]

P4128: !_REPLACEMENT [11] (Int)
sethi %hi(0x40), %l3
or %l3, %lo(0x40),  %l3
sethi %hi(0x10000), %l6
or %l6, %lo(0x10000),  %l6
add %i3, %l3, %l3
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]

P4129: !_SWAP [9] (maybe <- 0x2000003) (Int)
mov %l4, %o4
swap  [%i1 + 512], %o4
! move %o4(lower) -> %o4(upper)
sllx %o4, 32, %o4
add   %l4, 1, %l4

P4130: !_DWST [14] (maybe <- 0x4180000c) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
std %f20, [%i3 + 128]

P4131: !_ST [12] (maybe <- 0x4180000d) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i3 + 0 ]

P4132: !_ST [9] (maybe <- 0x4180000e) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i1 + 512 ]

P4133: !_REPLACEMENT [5] (Int)
sethi %hi(0x4c), %o5
or %o5, %lo(0x4c),  %o5
sethi %hi(0x10000), %l3
or %l3, %lo(0x10000),  %l3
add %i3, %o5, %o5
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]

P4134: !_REPLACEMENT [9] (Int)
sethi %hi(0x200), %l7
or %l7, %lo(0x200),  %l7
sethi %hi(0x10000), %o5
or %o5, %lo(0x10000),  %o5
add %i3, %l7, %l7
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]

P4135: !_DWLD [4] (FP)
ldd [%i0 + 64], %f18
! 1 addresses covered
fmovs %f18, %f13

P4136: !_LD [13] (FP)
ld [%i3 + 64], %f14
! 1 addresses covered

P4137: !_DWST [11] (maybe <- 0x4180000f) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
std %f20, [%i2 + 64]

P4138: !_REPLACEMENT [2] (Int)
sethi %hi(0xc), %l3
or %l3, %lo(0xc),  %l3
sethi %hi(0x10000), %l6
or %l6, %lo(0x10000),  %l6
add %i3, %l3, %l3
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]

P4139: !_MEMBAR (Int)
membar #StoreLoad

P4140: !_PREFETCH [7] (Int)
prefetch [%i1 + 84], 1

P4141: !_CASX [12] (maybe <- 0x2000004) (Int)
add %i3, 0, %l3
ldx [%l3], %l7
! move %l7(upper) -> %o4(lower)
srlx %l7, 32, %o5
or %o5, %o4, %o4
!---- flushing int results buffer----
mov %o0, %l5
mov %o1, %l5
mov %o2, %l5
mov %o3, %l5
mov %o4, %l5
! move %l7(lower) -> %o0(upper)
sllx %l7, 32, %o0
mov  %l7, %o5
sllx %l4, 32, %l7
casx [%l3], %o5, %l7
! move %l7(upper) -> %o0(lower)
srlx %l7, 32, %l3
or %l3, %o0, %o0
! move %l7(lower) -> %o1(upper)
sllx %l7, 32, %o1
add  %l4, 1, %l4

P4142: !_DWLD [6] (FP)
ldd [%i1 + 80], %f18
! 2 addresses covered
fmovs %f18, %f15
!---- flushing fp results buffer to %f30 ----
fmovd %f0, %f30
fmovd %f2, %f30
fmovd %f4, %f30
fmovd %f6, %f30
fmovd %f8, %f30
fmovd %f10, %f30
fmovd %f12, %f30
fmovd %f14, %f30
fmovs %f19, %f0

P4143: !_REPLACEMENT [0] (Int)
sethi %hi(0x0), %o5
or %o5, %lo(0x0),  %o5
sethi %hi(0x10000), %l3
or %l3, %lo(0x10000),  %l3
add %i3, %o5, %o5
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]

P4144: !_SWAP [0] (maybe <- 0x2000005) (Int)
mov %l4, %l3
swap  [%i0 + 0], %l3
! move %l3(lower) -> %o1(lower)
srl %l3, 0, %l7
or %l7, %o1, %o1
add   %l4, 1, %l4

P4145: !_DWLD [2] (FP) (CBR)
ldd [%i0 + 8], %f18
! 1 addresses covered
fmovs %f19, %f1

! cbranch
andcc %l0, 1, %g0
be,pn  %xcc, TARGET4145
nop
RET4145:

! lfsr step begin
srlx %l0, 1, %l6
xnor %l6, %l0, %l6
sllx %l6, 63, %l6
or  %l6, %l0, %l0
srlx %l0, 1, %l0


P4146: !_CAS [15] (maybe <- 0x2000006) (Int)
add %i3, 192, %o5
lduw [%o5], %o2
mov %o2, %l7
! move %l7(lower) -> %o2(upper)
sllx %l7, 32, %o2
mov %l4, %l6
cas [%o5], %l7, %l6
! move %l6(lower) -> %o2(lower)
srl %l6, 0, %o5
or %o5, %o2, %o2
add   %l4, 1, %l4

P4147: !_LD [10] (FP)
ld [%i2 + 32], %f2
! 1 addresses covered

P4148: !_DWST [6] (maybe <- 0x41800010) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
! 1 th moved, current_fp_src=21 
fmovs  %f16, %f21
fadds  %f16, %f17, %f16
std %f20, [%i1 + 80]

P4149: !_LD [1] (FP)
ld [%i0 + 4], %f3
! 1 addresses covered

P4150: !_SWAP [2] (maybe <- 0x2000007) (Int)
mov %l4, %o3
swap  [%i0 + 12], %o3
! move %o3(lower) -> %o3(upper)
sllx %o3, 32, %o3
add   %l4, 1, %l4

P4151: !_PREFETCH [8] (Int)
prefetch [%i1 + 256], 1

P4152: !_REPLACEMENT [12] (Int)
sethi %hi(0x0), %l3
or %l3, %lo(0x0),  %l3
sethi %hi(0x10000), %l6
or %l6, %lo(0x10000),  %l6
add %i3, %l3, %l3
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]

P4153: !_MEMBAR (Int)
membar #StoreLoad

P4154: !_ST [12] (maybe <- 0x41800012) (FP) (Branch target of P4347)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i3 + 0 ]
ba P4155
nop

TARGET4347:
ba RET4347
nop


P4155: !_LD [14] (FP)
ld [%i3 + 128], %f4
! 1 addresses covered

P4156: !_DWST [10] (maybe <- 0x41800013) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
std %f20, [%i2 + 32]

P4157: !_ST [15] (maybe <- 0x41800014) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i3 + 192 ]

P4158: !_DWLD [11] (FP)
ldd [%i2 + 64], %f18
! 1 addresses covered
fmovs %f18, %f5

P4159: !_LD [8] (FP)
ld [%i1 + 256], %f6
! 1 addresses covered

P4160: !_ST [2] (maybe <- 0x41800015) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i0 + 12 ]

P4161: !_ST [11] (maybe <- 0x41800016) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i2 + 64 ]

P4162: !_PREFETCH [6] (Int)
prefetch [%i1 + 80], 1

P4163: !_ST [13] (maybe <- 0x41800017) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i3 + 64 ]

P4164: !_REPLACEMENT [6] (Int)
sethi %hi(0x50), %l6
or %l6, %lo(0x50),  %l6
sethi %hi(0x10000), %l7
or %l7, %lo(0x10000),  %l7
add %i3, %l6, %l6
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]

P4165: !_PREFETCH [3] (Int)
prefetch [%i0 + 32], 1

P4166: !_SWAP [13] (maybe <- 0x2000008) (Int)
mov %l4, %l7
swap  [%i3 + 64], %l7
! move %l7(lower) -> %o3(lower)
srl %l7, 0, %l3
or %l3, %o3, %o3
add   %l4, 1, %l4

P4167: !_ST [5] (maybe <- 0x41800018) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i1 + 76 ]

P4168: !_DWST [11] (maybe <- 0x41800019) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
std %f20, [%i2 + 64]

P4169: !_REPLACEMENT [11] (Int)
sethi %hi(0x40), %l6
or %l6, %lo(0x40),  %l6
sethi %hi(0x10000), %l7
or %l7, %lo(0x10000),  %l7
add %i3, %l6, %l6
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]

P4170: !_DWST [10] (maybe <- 0x4180001a) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
std %f20, [%i2 + 32]

P4171: !_DWLD [9] (FP)
ldd [%i1 + 512], %f18
! 1 addresses covered
fmovs %f18, %f7

P4172: !_ST [3] (maybe <- 0x4180001b) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i0 + 32 ]

P4173: !_ST [11] (maybe <- 0x4180001c) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i2 + 64 ]

P4174: !_PREFETCH [11] (Int)
prefetch [%i2 + 64], 1

P4175: !_LD [11] (FP)
ld [%i2 + 64], %f8
! 1 addresses covered

P4176: !_ST [1] (maybe <- 0x4180001d) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i0 + 4 ]

P4177: !_DWST [5] (maybe <- 0x4180001e) (FP)
! 0 th moved, current_fp_src=21 
fmovs  %f16, %f21
fadds  %f16, %f17, %f16
std %f20, [%i1 + 72]

P4178: !_ST [5] (maybe <- 0x4180001f) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i1 + 76 ]

P4179: !_DWST [15] (maybe <- 0x41800020) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
std %f20, [%i3 + 192]

P4180: !_PREFETCH [7] (Int) (Branch target of P4954)
prefetch [%i1 + 84], 1
ba P4181
nop

TARGET4954:
ba RET4954
nop


P4181: !_SWAP [0] (maybe <- 0x2000009) (Int)
mov %l4, %o4
swap  [%i0 + 0], %o4
! move %o4(lower) -> %o4(upper)
sllx %o4, 32, %o4
add   %l4, 1, %l4

P4182: !_CASX [5] (maybe <- 0x200000a) (Int) (LE)
! Change single-word-level endianess (big endian <-> little endian) 
sethi %hi(0xff00ff00), %l6
or %l6, %lo(0xff00ff00), %l6
and %l4, %l6, %l3
srl %l3, 8, %l3
sll %l4, 8, %l7
and %l7, %l6, %l7
or %l7, %l3, %l7
srl %l7, 16, %l3
sll %l7, 16, %l7
srl %l7, 0, %l7
or %l7, %l3, %l7
sllx %l7, 32, %l7
wr %g0, 0x88, %asi
add %i1, 72, %l6
ldxa [%l6] %asi, %o5
! move %o5(lower) -> %o4(lower)
srl %o5, 0, %l3
or %l3, %o4, %o4
!---- flushing int results buffer----
mov %o0, %l5
mov %o1, %l5
mov %o2, %l5
mov %o3, %l5
mov %o4, %l5
! move %o5(upper) -> %o0(upper)
or %o5, %g0, %o0
mov  %o5, %l3
mov  %l7, %o5
casxa [%l6] %asi, %l3, %o5
! move %o5(lower) -> %o0(lower)
srlx %o0, 32, %o0
sllx %o0, 32, %o0
srl %o5, 0, %l6
or %l6, %o0, %o0
! move %o5(upper) -> %o1(upper)
or %o5, %g0, %o1
add  %l4, 1, %l4

P4183: !_SWAP [1] (maybe <- 0x200000b) (Int)
mov %l4, %l7
swap  [%i0 + 4], %l7
! move %l7(lower) -> %o1(lower)
srlx %o1, 32, %o1
sllx %o1, 32, %o1
srl %l7, 0, %l3
or %l3, %o1, %o1
add   %l4, 1, %l4

P4184: !_DWLD [9] (FP)
ldd [%i1 + 512], %f18
! 1 addresses covered
fmovs %f18, %f9

P4185: !_CAS [5] (maybe <- 0x200000c) (Int) (Branch target of P4259)
add %i1, 76, %l3
lduw [%l3], %o2
mov %o2, %o5
! move %o5(lower) -> %o2(upper)
sllx %o5, 32, %o2
mov %l4, %l7
cas [%l3], %o5, %l7
! move %l7(lower) -> %o2(lower)
srl %l7, 0, %l3
or %l3, %o2, %o2
add   %l4, 1, %l4
ba P4186
nop

TARGET4259:
ba RET4259
nop


P4186: !_ST [5] (maybe <- 0x41800021) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i1 + 76 ]

P4187: !_LD [4] (FP)
ld [%i0 + 64], %f10
! 1 addresses covered

P4188: !_DWST [14] (maybe <- 0x41800022) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
std %f20, [%i3 + 128]

P4189: !_DWST [14] (maybe <- 0x41800023) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
std %f20, [%i3 + 128]

P4190: !_LD [15] (FP)
ld [%i3 + 192], %f11
! 1 addresses covered

P4191: !_REPLACEMENT [3] (Int)
sethi %hi(0x20), %l3
or %l3, %lo(0x20),  %l3
sethi %hi(0x10000), %l6
or %l6, %lo(0x10000),  %l6
add %i3, %l3, %l3
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]

P4192: !_ST [15] (maybe <- 0x41800024) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i3 + 192 ]

P4193: !_ST [2] (maybe <- 0x41800025) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i0 + 12 ]

P4194: !_LD [13] (FP)
ld [%i3 + 64], %f12
! 1 addresses covered

P4195: !_PREFETCH [0] (Int)
prefetch [%i0 + 0], 1

P4196: !_REPLACEMENT [15] (Int)
sethi %hi(0xc0), %l6
or %l6, %lo(0xc0),  %l6
sethi %hi(0x10000), %l7
or %l7, %lo(0x10000),  %l7
add %i3, %l6, %l6
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]

P4197: !_REPLACEMENT [4] (Int)
sethi %hi(0x40), %l3
or %l3, %lo(0x40),  %l3
sethi %hi(0x10000), %l6
or %l6, %lo(0x10000),  %l6
add %i3, %l3, %l3
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]

P4198: !_REPLACEMENT [7] (Int)
sethi %hi(0x54), %o5
or %o5, %lo(0x54),  %o5
sethi %hi(0x10000), %l3
or %l3, %lo(0x10000),  %l3
add %i3, %o5, %o5
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]

P4199: !_PREFETCH [13] (Int)
prefetch [%i3 + 64], 1

P4200: !_PREFETCH [11] (Int)
prefetch [%i2 + 64], 1

P4201: !_PREFETCH [5] (Int)
prefetch [%i1 + 76], 1

P4202: !_DWST [12] (maybe <- 0x41800026) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
std %f20, [%i3 + 0]

P4203: !_REPLACEMENT [9] (Int)
sethi %hi(0x200), %l6
or %l6, %lo(0x200),  %l6
sethi %hi(0x10000), %l7
or %l7, %lo(0x10000),  %l7
add %i3, %l6, %l6
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]

P4204: !_PREFETCH [8] (Int)
prefetch [%i1 + 256], 1

P4205: !_SWAP [7] (maybe <- 0x200000d) (Int) (Branch target of P4125)
mov %l4, %o3
swap  [%i1 + 84], %o3
! move %o3(lower) -> %o3(upper)
sllx %o3, 32, %o3
add   %l4, 1, %l4
ba P4206
nop

TARGET4125:
ba RET4125
nop


P4206: !_REPLACEMENT [12] (Int)
sethi %hi(0x0), %o5
or %o5, %lo(0x0),  %o5
sethi %hi(0x10000), %l3
or %l3, %lo(0x10000),  %l3
add %i3, %o5, %o5
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]

P4207: !_CASX [6] (maybe <- 0x200000e) (Int)
add %i1, 80, %o5
ldx [%o5], %l6
! move %l6(upper) -> %o3(lower)
srlx %l6, 32, %l7
or %l7, %o3, %o3
! move %l6(lower) -> %o4(upper)
sllx %l6, 32, %o4
mov %l6, %l7
sllx %l4, 32, %l6
add  %l4, 1, %l4
or   %l4, %l6, %l6
casx [%o5], %l7, %l6
! move %l6(upper) -> %o4(lower)
srlx %l6, 32, %o5
or %o5, %o4, %o4
!---- flushing int results buffer----
mov %o0, %l5
mov %o1, %l5
mov %o2, %l5
mov %o3, %l5
mov %o4, %l5
! move %l6(lower) -> %o0(upper)
sllx %l6, 32, %o0
add  %l4, 1, %l4

P4208: !_ST [10] (maybe <- 0x41800027) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i2 + 32 ]

P4209: !_LD [1] (FP)
ld [%i0 + 4], %f13
! 1 addresses covered

P4210: !_LD [6] (FP)
ld [%i1 + 80], %f14
! 1 addresses covered

P4211: !_LD [7] (FP) (CBR)
ld [%i1 + 84], %f15
! 1 addresses covered
!---- flushing fp results buffer to %f30 ----
fmovd %f0, %f30
fmovd %f2, %f30
fmovd %f4, %f30
fmovd %f6, %f30
fmovd %f8, %f30
fmovd %f10, %f30
fmovd %f12, %f30
fmovd %f14, %f30

! cbranch
andcc %l0, 1, %g0
be,pt  %xcc, TARGET4211
nop
RET4211:

! lfsr step begin
srlx %l0, 1, %l6
xnor %l6, %l0, %l6
sllx %l6, 63, %l6
or  %l6, %l0, %l0
srlx %l0, 1, %l0


P4212: !_CASX [0] (maybe <- 0x2000010) (Int)
add %i0, 0, %o5
ldx [%o5], %l6
! move %l6(upper) -> %o0(lower)
srlx %l6, 32, %l7
or %l7, %o0, %o0
! move %l6(lower) -> %o1(upper)
sllx %l6, 32, %o1
mov %l6, %l7
sllx %l4, 32, %l6
add  %l4, 1, %l4
or   %l4, %l6, %l6
casx [%o5], %l7, %l6
! move %l6(upper) -> %o1(lower)
srlx %l6, 32, %o5
or %o5, %o1, %o1
! move %l6(lower) -> %o2(upper)
sllx %l6, 32, %o2
add  %l4, 1, %l4

P4213: !_ST [9] (maybe <- 0x41800028) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i1 + 512 ]

P4214: !_PREFETCH [14] (Int)
prefetch [%i3 + 128], 1

P4215: !_MEMBAR (Int)
membar #StoreLoad

P4216: !_PREFETCH [6] (Int) (CBR)
prefetch [%i1 + 80], 1

! cbranch
andcc %l0, 1, %g0
be,pn  %xcc, TARGET4216
nop
RET4216:

! lfsr step begin
srlx %l0, 1, %l6
xnor %l6, %l0, %l6
sllx %l6, 63, %l6
or  %l6, %l0, %l0
srlx %l0, 1, %l0


P4217: !_ST [2] (maybe <- 0x41800029) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i0 + 12 ]

P4218: !_DWLD [13] (FP)
ldd [%i3 + 64], %f0
! 1 addresses covered

P4219: !_LD [12] (FP)
ld [%i3 + 0], %f1
! 1 addresses covered

P4220: !_REPLACEMENT [2] (Int) (Branch target of P4287)
sethi %hi(0xc), %l6
or %l6, %lo(0xc),  %l6
sethi %hi(0x10000), %l7
or %l7, %lo(0x10000),  %l7
add %i3, %l6, %l6
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
ba P4221
nop

TARGET4287:
ba RET4287
nop


P4221: !_CAS [10] (maybe <- 0x2000012) (Int)
add %i2, 32, %l6
lduw [%l6], %o5
mov %o5, %l3
! move %l3(lower) -> %o2(lower)
or %l3, %o2, %o2
mov %l4, %o3
cas [%l6], %l3, %o3
! move %o3(lower) -> %o3(upper)
sllx %o3, 32, %o3
add   %l4, 1, %l4

P4222: !_LD [9] (FP)
ld [%i1 + 512], %f2
! 1 addresses covered

P4223: !_LD [12] (FP)
ld [%i3 + 0], %f3
! 1 addresses covered

P4224: !_REPLACEMENT [14] (Int)
sethi %hi(0x80), %l3
or %l3, %lo(0x80),  %l3
sethi %hi(0x10000), %l6
or %l6, %lo(0x10000),  %l6
add %i3, %l3, %l3
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]

P4225: !_REPLACEMENT [3] (Int)
sethi %hi(0x20), %o5
or %o5, %lo(0x20),  %o5
sethi %hi(0x10000), %l3
or %l3, %lo(0x10000),  %l3
add %i3, %o5, %o5
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]

P4226: !_PREFETCH [11] (Int)
prefetch [%i2 + 64], 1

P4227: !_LD [7] (FP)
ld [%i1 + 84], %f4
! 1 addresses covered

P4228: !_NOP (Int)
nop

P4229: !_DWST [2] (maybe <- 0x4180002a) (FP)
! 0 th moved, current_fp_src=21 
fmovs  %f16, %f21
fadds  %f16, %f17, %f16
std %f20, [%i0 + 8]

P4230: !_REPLACEMENT [3] (Int)
sethi %hi(0x20), %l6
or %l6, %lo(0x20),  %l6
sethi %hi(0x10000), %l7
or %l7, %lo(0x10000),  %l7
add %i3, %l6, %l6
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]

P4231: !_REPLACEMENT [12] (Int)
sethi %hi(0x0), %l3
or %l3, %lo(0x0),  %l3
sethi %hi(0x10000), %l6
or %l6, %lo(0x10000),  %l6
add %i3, %l3, %l3
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]

P4232: !_LD [4] (FP)
ld [%i0 + 64], %f5
! 1 addresses covered

P4233: !_REPLACEMENT [15] (Int)
sethi %hi(0xc0), %o5
or %o5, %lo(0xc0),  %o5
sethi %hi(0x10000), %l3
or %l3, %lo(0x10000),  %l3
add %i3, %o5, %o5
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]

P4234: !_ST [4] (maybe <- 0x4180002b) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i0 + 64 ]

P4235: !_PREFETCH [2] (Int)
prefetch [%i0 + 12], 1

P4236: !_PREFETCH [14] (Int)
prefetch [%i3 + 128], 1

P4237: !_REPLACEMENT [12] (Int)
sethi %hi(0x0), %l6
or %l6, %lo(0x0),  %l6
sethi %hi(0x10000), %l7
or %l7, %lo(0x10000),  %l7
add %i3, %l6, %l6
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]

P4238: !_LD [15] (FP)
ld [%i3 + 192], %f6
! 1 addresses covered

P4239: !_DWLD [7] (FP)
ldd [%i1 + 80], %f18
! 2 addresses covered
fmovs %f18, %f7
fmovs %f19, %f8

P4240: !_ST [12] (maybe <- 0x4180002c) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i3 + 0 ]

P4241: !_DWST [9] (maybe <- 0x4180002d) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
std %f20, [%i1 + 512]

P4242: !_PREFETCH [8] (Int)
prefetch [%i1 + 256], 1

P4243: !_DWST [1] (maybe <- 0x4180002e) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
! 1 th moved, current_fp_src=21 
fmovs  %f16, %f21
fadds  %f16, %f17, %f16
std %f20, [%i0 + 0]

P4244: !_REPLACEMENT [9] (Int)
sethi %hi(0x200), %l6
or %l6, %lo(0x200),  %l6
sethi %hi(0x10000), %l7
or %l7, %lo(0x10000),  %l7
add %i3, %l6, %l6
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]

P4245: !_SWAP [2] (maybe <- 0x2000013) (Int)
mov %l4, %l7
swap  [%i0 + 12], %l7
! move %l7(lower) -> %o3(lower)
srl %l7, 0, %l3
or %l3, %o3, %o3
add   %l4, 1, %l4

P4246: !_PREFETCH [10] (Int)
prefetch [%i2 + 32], 1

P4247: !_REPLACEMENT [8] (Int)
sethi %hi(0x100), %o5
or %o5, %lo(0x100),  %o5
sethi %hi(0x10000), %l3
or %l3, %lo(0x10000),  %l3
add %i3, %o5, %o5
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]

P4248: !_DWLD [0] (FP) (CBR)
ldd [%i0 + 0], %f18
! 2 addresses covered
fmovs %f18, %f9
fmovs %f19, %f10

! cbranch
andcc %l0, 1, %g0
be,pn  %xcc, TARGET4248
nop
RET4248:

! lfsr step begin
srlx %l0, 1, %l7
xnor %l7, %l0, %l7
sllx %l7, 63, %l7
or  %l7, %l0, %l0
srlx %l0, 1, %l0


P4249: !_ST [4] (maybe <- 0x41800030) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i0 + 64 ]

P4250: !_REPLACEMENT [3] (Int) (CBR) (Branch target of P4701)
sethi %hi(0x20), %l7
or %l7, %lo(0x20),  %l7
sethi %hi(0x10000), %o5
or %o5, %lo(0x10000),  %o5
add %i3, %l7, %l7
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]

! cbranch
andcc %l0, 1, %g0
be,pt  %xcc, TARGET4250
nop
RET4250:

! lfsr step begin
srlx %l0, 1, %l6
xnor %l6, %l0, %l6
sllx %l6, 63, %l6
or  %l6, %l0, %l0
srlx %l0, 1, %l0

ba P4251
nop

TARGET4701:
ba RET4701
nop


P4251: !_LD [0] (FP)
ld [%i0 + 0], %f11
! 1 addresses covered

P4252: !_ST [9] (maybe <- 0x41800031) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i1 + 512 ]

P4253: !_ST [10] (maybe <- 0x41800032) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i2 + 32 ]

P4254: !_PREFETCH [14] (Int)
prefetch [%i3 + 128], 1

P4255: !_PREFETCH [13] (Int) (CBR)
prefetch [%i3 + 64], 1

! cbranch
andcc %l0, 1, %g0
be,pn  %xcc, TARGET4255
nop
RET4255:

! lfsr step begin
srlx %l0, 1, %l3
xnor %l3, %l0, %l3
sllx %l3, 63, %l3
or  %l3, %l0, %l0
srlx %l0, 1, %l0


P4256: !_LD [10] (FP)
ld [%i2 + 32], %f12
! 1 addresses covered

P4257: !_PREFETCH [13] (Int)
prefetch [%i3 + 64], 1

P4258: !_ST [14] (maybe <- 0x41800033) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i3 + 128 ]

P4259: !_DWST [7] (maybe <- 0x41800034) (FP) (CBR)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
! 1 th moved, current_fp_src=21 
fmovs  %f16, %f21
fadds  %f16, %f17, %f16
std %f20, [%i1 + 80]

! cbranch
andcc %l0, 1, %g0
be,pn  %xcc, TARGET4259
nop
RET4259:

! lfsr step begin
srlx %l0, 1, %o5
xnor %o5, %l0, %o5
sllx %o5, 63, %o5
or  %o5, %l0, %l0
srlx %l0, 1, %l0


P4260: !_ST [6] (maybe <- 0x41800036) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i1 + 80 ]

P4261: !_PREFETCH [15] (Int)
prefetch [%i3 + 192], 1

P4262: !_CASX [14] (maybe <- 0x2000014) (Int)
add %i3, 128, %l3
ldx [%l3], %o4
! move %o4(upper) -> %o4(upper)
! move %o4(lower) -> %o4(lower)
!---- flushing int results buffer----
mov %o0, %l5
mov %o1, %l5
mov %o2, %l5
mov %o3, %l5
mov %o4, %l5
mov  %o4, %o5
sllx %l4, 32, %o0
casx [%l3], %o5, %o0
! move %o0(upper) -> %o0(upper)
! move %o0(lower) -> %o0(lower)
add  %l4, 1, %l4

P4263: !_DWLD [8] (FP)
ldd [%i1 + 256], %f18
! 1 addresses covered
fmovs %f18, %f13

P4264: !_LD [15] (FP)
ld [%i3 + 192], %f14
! 1 addresses covered

P4265: !_ST [8] (maybe <- 0x41800037) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i1 + 256 ]

P4266: !_REPLACEMENT [4] (Int)
sethi %hi(0x40), %l7
or %l7, %lo(0x40),  %l7
sethi %hi(0x10000), %o5
or %o5, %lo(0x10000),  %o5
add %i3, %l7, %l7
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]

P4267: !_REPLACEMENT [1] (Int)
sethi %hi(0x4), %l6
or %l6, %lo(0x4),  %l6
sethi %hi(0x10000), %l7
or %l7, %lo(0x10000),  %l7
add %i3, %l6, %l6
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]

P4268: !_LD [3] (FP)
ld [%i0 + 32], %f15
! 1 addresses covered
!---- flushing fp results buffer to %f30 ----
fmovd %f0, %f30
fmovd %f2, %f30
fmovd %f4, %f30
fmovd %f6, %f30
fmovd %f8, %f30
fmovd %f10, %f30
fmovd %f12, %f30
fmovd %f14, %f30

P4269: !_PREFETCH [12] (Int)
prefetch [%i3 + 0], 1

P4270: !_PREFETCH [4] (Int)
prefetch [%i0 + 64], 1

P4271: !_DWLD [1] (FP)
ldd [%i0 + 0], %f0
! 2 addresses covered

P4272: !_DWST [13] (maybe <- 0x41800038) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
std %f20, [%i3 + 64]

P4273: !_ST [11] (maybe <- 0x41800039) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i2 + 64 ]

P4274: !_REPLACEMENT [9] (Int)
sethi %hi(0x200), %l7
or %l7, %lo(0x200),  %l7
sethi %hi(0x10000), %o5
or %o5, %lo(0x10000),  %o5
add %i3, %l7, %l7
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]

P4275: !_ST [14] (maybe <- 0x4180003a) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i3 + 128 ]

P4276: !_ST [6] (maybe <- 0x4180003b) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i1 + 80 ]

P4277: !_PREFETCH [5] (Int)
prefetch [%i1 + 76], 1

P4278: !_PREFETCH [13] (Int)
prefetch [%i3 + 64], 1

P4279: !_DWLD [12] (FP)
ldd [%i3 + 0], %f2
! 1 addresses covered

P4280: !_DWLD [0] (FP)
ldd [%i0 + 0], %f18
! 2 addresses covered
fmovs %f18, %f3
fmovs %f19, %f4

P4281: !_LD [5] (FP)
ld [%i1 + 76], %f5
! 1 addresses covered

P4282: !_LD [11] (FP)
ld [%i2 + 64], %f6
! 1 addresses covered

P4283: !_DWLD [9] (FP)
ldd [%i1 + 512], %f18
! 1 addresses covered
fmovs %f18, %f7

P4284: !_ST [15] (maybe <- 0x4180003c) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i3 + 192 ]

P4285: !_CAS [0] (maybe <- 0x2000015) (Int)
add %i0, 0, %o5
lduw [%o5], %o1
mov %o1, %l7
! move %l7(lower) -> %o1(upper)
sllx %l7, 32, %o1
mov %l4, %l6
cas [%o5], %l7, %l6
! move %l6(lower) -> %o1(lower)
srl %l6, 0, %o5
or %o5, %o1, %o1
add   %l4, 1, %l4

P4286: !_LD [3] (FP)
ld [%i0 + 32], %f8
! 1 addresses covered

P4287: !_MEMBAR (Int) (CBR)
membar #StoreLoad

! cbranch
andcc %l0, 1, %g0
be,pn  %xcc, TARGET4287
nop
RET4287:

! lfsr step begin
srlx %l0, 1, %l7
xnor %l7, %l0, %l7
sllx %l7, 63, %l7
or  %l7, %l0, %l0
srlx %l0, 1, %l0


P4288: !_DWLD [0] (FP) (Branch target of P4453)
ldd [%i0 + 0], %f18
! 2 addresses covered
fmovs %f18, %f9
fmovs %f19, %f10
ba P4289
nop

TARGET4453:
ba RET4453
nop


P4289: !_DWST [15] (maybe <- 0x4180003d) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
std %f20, [%i3 + 192]

P4290: !_CASX [12] (maybe <- 0x2000016) (Int)
add %i3, 0, %o5
ldx [%o5], %o2
! move %o2(upper) -> %o2(upper)
! move %o2(lower) -> %o2(lower)
mov  %o2, %l7
sllx %l4, 32, %o3
casx [%o5], %l7, %o3
! move %o3(upper) -> %o3(upper)
! move %o3(lower) -> %o3(lower)
add  %l4, 1, %l4

P4291: !_LD [11] (FP)
ld [%i2 + 64], %f11
! 1 addresses covered

P4292: !_CASX [2] (maybe <- 0x2000017) (Int)
add %i0, 8, %o5
ldx [%o5], %o4
! move %o4(upper) -> %o4(upper)
! move %o4(lower) -> %o4(lower)
!---- flushing int results buffer----
mov %o0, %l5
mov %o1, %l5
mov %o2, %l5
mov %o3, %l5
mov %o4, %l5
mov  %o4, %l7
mov %l4, %o0
casx [%o5], %l7, %o0
! move %o0(upper) -> %o0(upper)
! move %o0(lower) -> %o0(lower)
add  %l4, 1, %l4

P4293: !_PREFETCH [11] (Int)
prefetch [%i2 + 64], 1

P4294: !_DWLD [3] (FP)
ldd [%i0 + 32], %f12
! 1 addresses covered

P4295: !_DWST [0] (maybe <- 0x4180003e) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
! 1 th moved, current_fp_src=21 
fmovs  %f16, %f21
fadds  %f16, %f17, %f16
std %f20, [%i0 + 0]

P4296: !_SWAP [10] (maybe <- 0x2000018) (Int)
mov %l4, %o1
swap  [%i2 + 32], %o1
! move %o1(lower) -> %o1(upper)
sllx %o1, 32, %o1
add   %l4, 1, %l4

P4297: !_MEMBAR (Int)
membar #StoreLoad

P4298: !_DWST [1] (maybe <- 0x41800040) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
! 1 th moved, current_fp_src=21 
fmovs  %f16, %f21
fadds  %f16, %f17, %f16
std %f20, [%i0 + 0]

P4299: !_LD [10] (FP)
ld [%i2 + 32], %f13
! 1 addresses covered

P4300: !_ST [15] (maybe <- 0x41800042) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i3 + 192 ]

P4301: !_ST [11] (maybe <- 0x41800043) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i2 + 64 ]

P4302: !_DWST [15] (maybe <- 0x41800044) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
std %f20, [%i3 + 192]

P4303: !_ST [2] (maybe <- 0x41800045) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i0 + 12 ]

P4304: !_PREFETCH [13] (Int)
prefetch [%i3 + 64], 1

P4305: !_DWLD [9] (FP)
ldd [%i1 + 512], %f14
! 1 addresses covered

P4306: !_DWST [1] (maybe <- 0x41800046) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
! 1 th moved, current_fp_src=21 
fmovs  %f16, %f21
fadds  %f16, %f17, %f16
std %f20, [%i0 + 0]

P4307: !_LD [5] (FP)
ld [%i1 + 76], %f15
! 1 addresses covered
!---- flushing fp results buffer to %f30 ----
fmovd %f0, %f30
fmovd %f2, %f30
fmovd %f4, %f30
fmovd %f6, %f30
fmovd %f8, %f30
fmovd %f10, %f30
fmovd %f12, %f30
fmovd %f14, %f30

P4308: !_LD [10] (FP)
ld [%i2 + 32], %f0
! 1 addresses covered

P4309: !_DWST [12] (maybe <- 0x41800048) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
std %f20, [%i3 + 0]

P4310: !_PREFETCH [12] (Int)
prefetch [%i3 + 0], 1

P4311: !_ST [7] (maybe <- 0x41800049) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i1 + 84 ]

P4312: !_DWST [15] (maybe <- 0x4180004a) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
std %f20, [%i3 + 192]

P4313: !_PREFETCH [4] (Int)
prefetch [%i0 + 64], 1

P4314: !_LD [7] (FP)
ld [%i1 + 84], %f1
! 1 addresses covered

P4315: !_DWST [15] (maybe <- 0x4180004b) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
std %f20, [%i3 + 192]

P4316: !_PREFETCH [15] (Int)
prefetch [%i3 + 192], 1

P4317: !_DWST [13] (maybe <- 0x4180004c) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
std %f20, [%i3 + 64]

P4318: !_DWLD [13] (FP)
ldd [%i3 + 64], %f2
! 1 addresses covered

P4319: !_DWLD [10] (FP)
ldd [%i2 + 32], %f18
! 1 addresses covered
fmovs %f18, %f3

P4320: !_DWLD [13] (FP)
ldd [%i3 + 64], %f4
! 1 addresses covered

P4321: !_LD [13] (FP)
ld [%i3 + 64], %f5
! 1 addresses covered

P4322: !_PREFETCH [12] (Int)
prefetch [%i3 + 0], 1

P4323: !_DWST [5] (maybe <- 0x4180004d) (FP)
! 0 th moved, current_fp_src=21 
fmovs  %f16, %f21
fadds  %f16, %f17, %f16
std %f20, [%i1 + 72]

P4324: !_DWST [0] (maybe <- 0x4180004e) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
! 1 th moved, current_fp_src=21 
fmovs  %f16, %f21
fadds  %f16, %f17, %f16
std %f20, [%i0 + 0]

P4325: !_LD [5] (FP) (CBR)
ld [%i1 + 76], %f6
! 1 addresses covered

! cbranch
andcc %l0, 1, %g0
be,pn  %xcc, TARGET4325
nop
RET4325:

! lfsr step begin
srlx %l0, 1, %o5
xnor %o5, %l0, %o5
sllx %o5, 63, %o5
or  %o5, %l0, %l0
srlx %l0, 1, %l0


P4326: !_LD [2] (FP)
ld [%i0 + 12], %f7
! 1 addresses covered

P4327: !_DWLD [10] (FP)
ldd [%i2 + 32], %f8
! 1 addresses covered

P4328: !_CAS [5] (maybe <- 0x2000019) (Int)
add %i1, 76, %l6
lduw [%l6], %o5
mov %o5, %l3
! move %l3(lower) -> %o1(lower)
or %l3, %o1, %o1
mov %l4, %o2
cas [%l6], %l3, %o2
! move %o2(lower) -> %o2(upper)
sllx %o2, 32, %o2
add   %l4, 1, %l4

P4329: !_PREFETCH [14] (Int)
prefetch [%i3 + 128], 1

P4330: !_DWLD [9] (FP)
ldd [%i1 + 512], %f18
! 1 addresses covered
fmovs %f18, %f9

P4331: !_REPLACEMENT [7] (Int)
sethi %hi(0x54), %l3
or %l3, %lo(0x54),  %l3
sethi %hi(0x10000), %l6
or %l6, %lo(0x10000),  %l6
add %i3, %l3, %l3
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]

P4332: !_CASX [6] (maybe <- 0x200001a) (Int)
add %i1, 80, %l3
ldx [%l3], %l7
! move %l7(upper) -> %o2(lower)
srlx %l7, 32, %o5
or %o5, %o2, %o2
! move %l7(lower) -> %o3(upper)
sllx %l7, 32, %o3
mov %l7, %o5
sllx %l4, 32, %l7
add  %l4, 1, %l4
or   %l4, %l7, %l7
casx [%l3], %o5, %l7
! move %l7(upper) -> %o3(lower)
srlx %l7, 32, %l3
or %l3, %o3, %o3
! move %l7(lower) -> %o4(upper)
sllx %l7, 32, %o4
add  %l4, 1, %l4

P4333: !_MEMBAR (Int)
membar #StoreLoad

P4334: !_PREFETCH [13] (Int)
prefetch [%i3 + 64], 1

P4335: !_LD [13] (FP)
ld [%i3 + 64], %f10
! 1 addresses covered

P4336: !_DWST [14] (maybe <- 0x41800050) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
std %f20, [%i3 + 128]

P4337: !_MEMBAR (Int)
membar #StoreLoad

P4338: !_DWLD [11] (FP) (CBR)
ldd [%i2 + 64], %f18
! 1 addresses covered
fmovs %f18, %f11

! cbranch
andcc %l0, 1, %g0
be,pn  %xcc, TARGET4338
nop
RET4338:

! lfsr step begin
srlx %l0, 1, %l7
xnor %l7, %l0, %l7
sllx %l7, 63, %l7
or  %l7, %l0, %l0
srlx %l0, 1, %l0


P4339: !_ST [3] (maybe <- 0x41800051) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i0 + 32 ]

P4340: !_ST [4] (maybe <- 0x41800052) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i0 + 64 ]

P4341: !_ST [6] (maybe <- 0x41800053) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i1 + 80 ]

P4342: !_SWAP [0] (maybe <- 0x200001c) (Int)
mov %l4, %l7
swap  [%i0 + 0], %l7
! move %l7(lower) -> %o4(lower)
srl %l7, 0, %l3
or %l3, %o4, %o4
!---- flushing int results buffer----
mov %o0, %l5
mov %o1, %l5
mov %o2, %l5
mov %o3, %l5
mov %o4, %l5
add   %l4, 1, %l4

P4343: !_PREFETCH [10] (Int) (Branch target of P4325)
prefetch [%i2 + 32], 1
ba P4344
nop

TARGET4325:
ba RET4325
nop


P4344: !_REPLACEMENT [3] (Int)
sethi %hi(0x20), %o5
or %o5, %lo(0x20),  %o5
sethi %hi(0x10000), %l3
or %l3, %lo(0x10000),  %l3
add %i3, %o5, %o5
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]

P4345: !_DWLD [15] (FP)
ldd [%i3 + 192], %f12
! 1 addresses covered

P4346: !_PREFETCH [9] (Int)
prefetch [%i1 + 512], 1

P4347: !_DWLD [0] (FP) (CBR)
ldd [%i0 + 0], %f18
! 2 addresses covered
fmovs %f18, %f13
fmovs %f19, %f14

! cbranch
andcc %l0, 1, %g0
be,pn  %xcc, TARGET4347
nop
RET4347:

! lfsr step begin
srlx %l0, 1, %l7
xnor %l7, %l0, %l7
sllx %l7, 63, %l7
or  %l7, %l0, %l0
srlx %l0, 1, %l0


P4348: !_ST [0] (maybe <- 0x41800054) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i0 + 0 ]

P4349: !_DWLD [9] (FP) (Branch target of P4574)
ldd [%i1 + 512], %f18
! 1 addresses covered
fmovs %f18, %f15
!---- flushing fp results buffer to %f30 ----
fmovd %f0, %f30
fmovd %f2, %f30
fmovd %f4, %f30
fmovd %f6, %f30
fmovd %f8, %f30
fmovd %f10, %f30
fmovd %f12, %f30
fmovd %f14, %f30
ba P4350
nop

TARGET4574:
ba RET4574
nop


P4350: !_LD [0] (FP)
ld [%i0 + 0], %f0
! 1 addresses covered

P4351: !_LD [8] (FP)
ld [%i1 + 256], %f1
! 1 addresses covered

P4352: !_DWLD [13] (FP)
ldd [%i3 + 64], %f2
! 1 addresses covered

P4353: !_DWST [0] (maybe <- 0x41800055) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
! 1 th moved, current_fp_src=21 
fmovs  %f16, %f21
fadds  %f16, %f17, %f16
std %f20, [%i0 + 0]

P4354: !_DWLD [12] (FP)
ldd [%i3 + 0], %f18
! 1 addresses covered
fmovs %f18, %f3

P4355: !_LD [8] (FP)
ld [%i1 + 256], %f4
! 1 addresses covered

P4356: !_DWST [10] (maybe <- 0x41800057) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
std %f20, [%i2 + 32]

P4357: !_CASX [8] (maybe <- 0x200001d) (Int)
add %i1, 256, %l6
ldx [%l6], %o0
! move %o0(upper) -> %o0(upper)
! move %o0(lower) -> %o0(lower)
mov  %o0, %l3
sllx %l4, 32, %o1
casx [%l6], %l3, %o1
! move %o1(upper) -> %o1(upper)
! move %o1(lower) -> %o1(lower)
add  %l4, 1, %l4

P4358: !_ST [12] (maybe <- 0x41800058) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i3 + 0 ]

P4359: !_DWST [0] (maybe <- 0x41800059) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
! 1 th moved, current_fp_src=21 
fmovs  %f16, %f21
fadds  %f16, %f17, %f16
std %f20, [%i0 + 0]

P4360: !_LD [5] (FP)
ld [%i1 + 76], %f5
! 1 addresses covered

P4361: !_ST [4] (maybe <- 0x4180005b) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i0 + 64 ]

P4362: !_ST [4] (maybe <- 0x4180005c) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i0 + 64 ]

P4363: !_PREFETCH [4] (Int)
prefetch [%i0 + 64], 1

P4364: !_PREFETCH [5] (Int)
prefetch [%i1 + 76], 1

P4365: !_ST [8] (maybe <- 0x4180005d) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i1 + 256 ]

P4366: !_LD [5] (FP)
ld [%i1 + 76], %f6
! 1 addresses covered

P4367: !_PREFETCH [7] (Int) (LE)
wr %g0, 0x88, %asi
prefetcha [%i1 + 84] %asi, 1

P4368: !_REPLACEMENT [0] (Int)
sethi %hi(0x0), %o5
or %o5, %lo(0x0),  %o5
sethi %hi(0x10000), %l3
or %l3, %lo(0x10000),  %l3
add %i3, %o5, %o5
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]

P4369: !_DWST [0] (maybe <- 0x4180005e) (FP) (Branch target of P4145)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
! 1 th moved, current_fp_src=21 
fmovs  %f16, %f21
fadds  %f16, %f17, %f16
std %f20, [%i0 + 0]
ba P4370
nop

TARGET4145:
ba RET4145
nop


P4370: !_DWST [4] (maybe <- 0x41800060) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
std %f20, [%i0 + 64]

P4371: !_DWST [13] (maybe <- 0x41800061) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
std %f20, [%i3 + 64]

P4372: !_MEMBAR (Int)
membar #StoreLoad

P4373: !_PREFETCH [6] (Int)
prefetch [%i1 + 80], 1

P4374: !_DWST [5] (maybe <- 0x41800062) (FP)
! 0 th moved, current_fp_src=21 
fmovs  %f16, %f21
fadds  %f16, %f17, %f16
std %f20, [%i1 + 72]

P4375: !_PREFETCH [12] (Int)
prefetch [%i3 + 0], 1

P4376: !_DWST [0] (maybe <- 0x41800063) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
! 1 th moved, current_fp_src=21 
fmovs  %f16, %f21
fadds  %f16, %f17, %f16
std %f20, [%i0 + 0]

P4377: !_ST [10] (maybe <- 0x41800065) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i2 + 32 ]

P4378: !_DWLD [6] (FP)
ldd [%i1 + 80], %f18
! 2 addresses covered
fmovs %f18, %f7
fmovs %f19, %f8

P4379: !_ST [15] (maybe <- 0x41800066) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i3 + 192 ]

P4380: !_CAS [14] (maybe <- 0x200001e) (Int)
add %i3, 128, %l3
lduw [%l3], %o2
mov %o2, %o5
! move %o5(lower) -> %o2(upper)
sllx %o5, 32, %o2
mov %l4, %l7
cas [%l3], %o5, %l7
! move %l7(lower) -> %o2(lower)
srl %l7, 0, %l3
or %l3, %o2, %o2
add   %l4, 1, %l4

P4381: !_LD [1] (FP)
ld [%i0 + 4], %f9
! 1 addresses covered

P4382: !_DWLD [10] (FP)
ldd [%i2 + 32], %f10
! 1 addresses covered

P4383: !_PREFETCH [15] (Int)
prefetch [%i3 + 192], 1

P4384: !_CAS [5] (maybe <- 0x200001f) (Int)
add %i1, 76, %l3
lduw [%l3], %o3
mov %o3, %o5
! move %o5(lower) -> %o3(upper)
sllx %o5, 32, %o3
mov %l4, %l7
cas [%l3], %o5, %l7
! move %l7(lower) -> %o3(lower)
srl %l7, 0, %l3
or %l3, %o3, %o3
add   %l4, 1, %l4

P4385: !_NOP (Int)
nop

P4386: !_CAS [6] (maybe <- 0x2000020) (Int)
add %i1, 80, %l3
lduw [%l3], %o4
mov %o4, %o5
! move %o5(lower) -> %o4(upper)
sllx %o5, 32, %o4
mov %l4, %l7
cas [%l3], %o5, %l7
! move %l7(lower) -> %o4(lower)
srl %l7, 0, %l3
or %l3, %o4, %o4
!---- flushing int results buffer----
mov %o0, %l5
mov %o1, %l5
mov %o2, %l5
mov %o3, %l5
mov %o4, %l5
add   %l4, 1, %l4

P4387: !_PREFETCH [3] (Int)
prefetch [%i0 + 32], 1

P4388: !_DWST [7] (maybe <- 0x41800067) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
! 1 th moved, current_fp_src=21 
fmovs  %f16, %f21
fadds  %f16, %f17, %f16
std %f20, [%i1 + 80]

P4389: !_SWAP [4] (maybe <- 0x2000021) (Int)
mov %l4, %o0
swap  [%i0 + 64], %o0
! move %o0(lower) -> %o0(upper)
sllx %o0, 32, %o0
add   %l4, 1, %l4

P4390: !_CASX [10] (maybe <- 0x2000022) (Int)
add %i2, 32, %l7
ldx [%l7], %l3
! move %l3(upper) -> %o0(lower)
srlx %l3, 32, %l6
or %l6, %o0, %o0
! move %l3(lower) -> %o1(upper)
sllx %l3, 32, %o1
mov  %l3, %l6
sllx %l4, 32, %l3
casx [%l7], %l6, %l3
! move %l3(upper) -> %o1(lower)
srlx %l3, 32, %l7
or %l7, %o1, %o1
! move %l3(lower) -> %o2(upper)
sllx %l3, 32, %o2
add  %l4, 1, %l4

P4391: !_MEMBAR (Int)
membar #StoreLoad

P4392: !_PREFETCH [9] (Int)
prefetch [%i1 + 512], 1

P4393: !_LD [9] (FP)
ld [%i1 + 512], %f11
! 1 addresses covered

P4394: !_PREFETCH [3] (Int)
prefetch [%i0 + 32], 1

P4395: !_LD [13] (FP)
ld [%i3 + 64], %f12
! 1 addresses covered

P4396: !_LD [0] (FP)
ld [%i0 + 0], %f13
! 1 addresses covered

P4397: !_ST [6] (maybe <- 0x41800069) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i1 + 80 ]

P4398: !_ST [4] (maybe <- 0x4180006a) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i0 + 64 ]

P4399: !_ST [11] (maybe <- 0x4180006b) (FP) (Branch target of P4569)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i2 + 64 ]
ba P4400
nop

TARGET4569:
ba RET4569
nop


P4400: !_CAS [11] (maybe <- 0x2000023) (Int)
add %i2, 64, %o5
lduw [%o5], %l6
mov %l6, %l7
! move %l7(lower) -> %o2(lower)
or %l7, %o2, %o2
mov %l4, %o3
cas [%o5], %l7, %o3
! move %o3(lower) -> %o3(upper)
sllx %o3, 32, %o3
add   %l4, 1, %l4

P4401: !_REPLACEMENT [10] (Int)
sethi %hi(0x20), %l7
or %l7, %lo(0x20),  %l7
sethi %hi(0x10000), %o5
or %o5, %lo(0x10000),  %o5
add %i3, %l7, %l7
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]

P4402: !_CASX [6] (maybe <- 0x2000024) (Int)
add %i1, 80, %l7
ldx [%l7], %l3
! move %l3(upper) -> %o3(lower)
srlx %l3, 32, %l6
or %l6, %o3, %o3
! move %l3(lower) -> %o4(upper)
sllx %l3, 32, %o4
mov %l3, %l6
sllx %l4, 32, %l3
add  %l4, 1, %l4
or   %l4, %l3, %l3
casx [%l7], %l6, %l3
! move %l3(upper) -> %o4(lower)
srlx %l3, 32, %l7
or %l7, %o4, %o4
!---- flushing int results buffer----
mov %o0, %l5
mov %o1, %l5
mov %o2, %l5
mov %o3, %l5
mov %o4, %l5
! move %l3(lower) -> %o0(upper)
sllx %l3, 32, %o0
add  %l4, 1, %l4

P4403: !_DWST [3] (maybe <- 0x4180006c) (FP) (CBR)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
std %f20, [%i0 + 32]

! cbranch
andcc %l0, 1, %g0
be,pt  %xcc, TARGET4403
nop
RET4403:

! lfsr step begin
srlx %l0, 1, %l3
xnor %l3, %l0, %l3
sllx %l3, 63, %l3
or  %l3, %l0, %l0
srlx %l0, 1, %l0


P4404: !_LD [11] (FP)
ld [%i2 + 64], %f14
! 1 addresses covered

P4405: !_CAS [0] (maybe <- 0x2000026) (Int)
add %i0, 0, %l7
lduw [%l7], %l3
mov %l3, %l6
! move %l6(lower) -> %o0(lower)
or %l6, %o0, %o0
mov %l4, %o1
cas [%l7], %l6, %o1
! move %o1(lower) -> %o1(upper)
sllx %o1, 32, %o1
add   %l4, 1, %l4

P4406: !_REPLACEMENT [15] (Int)
sethi %hi(0xc0), %l6
or %l6, %lo(0xc0),  %l6
sethi %hi(0x10000), %l7
or %l7, %lo(0x10000),  %l7
add %i3, %l6, %l6
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]

P4407: !_PREFETCH [9] (Int)
prefetch [%i1 + 512], 1

P4408: !_ST [1] (maybe <- 0x4180006d) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i0 + 4 ]

P4409: !_DWST [11] (maybe <- 0x4180006e) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
std %f20, [%i2 + 64]

P4410: !_LD [10] (FP)
ld [%i2 + 32], %f15
! 1 addresses covered
!---- flushing fp results buffer to %f30 ----
fmovd %f0, %f30
fmovd %f2, %f30
fmovd %f4, %f30
fmovd %f6, %f30
fmovd %f8, %f30
fmovd %f10, %f30
fmovd %f12, %f30
fmovd %f14, %f30

P4411: !_LD [12] (FP)
ld [%i3 + 0], %f0
! 1 addresses covered

P4412: !_REPLACEMENT [8] (Int)
sethi %hi(0x100), %l7
or %l7, %lo(0x100),  %l7
sethi %hi(0x10000), %o5
or %o5, %lo(0x10000),  %o5
add %i3, %l7, %l7
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]

P4413: !_SWAP [13] (maybe <- 0x2000027) (Int) (Branch target of P4473)
mov %l4, %o5
swap  [%i3 + 64], %o5
! move %o5(lower) -> %o1(lower)
srl %o5, 0, %l6
or %l6, %o1, %o1
add   %l4, 1, %l4
ba P4414
nop

TARGET4473:
ba RET4473
nop


P4414: !_SWAP [2] (maybe <- 0x2000028) (Int) (Branch target of P4211)
mov %l4, %o2
swap  [%i0 + 12], %o2
! move %o2(lower) -> %o2(upper)
sllx %o2, 32, %o2
add   %l4, 1, %l4
ba P4415
nop

TARGET4211:
ba RET4211
nop


P4415: !_REPLACEMENT [2] (Int)
sethi %hi(0xc), %o5
or %o5, %lo(0xc),  %o5
sethi %hi(0x10000), %l3
or %l3, %lo(0x10000),  %l3
add %i3, %o5, %o5
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]

P4416: !_ST [7] (maybe <- 0x4180006f) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i1 + 84 ]

P4417: !_REPLACEMENT [15] (Int)
sethi %hi(0xc0), %l6
or %l6, %lo(0xc0),  %l6
sethi %hi(0x10000), %l7
or %l7, %lo(0x10000),  %l7
add %i3, %l6, %l6
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]

P4418: !_ST [15] (maybe <- 0x41800070) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i3 + 192 ]

P4419: !_LD [8] (FP)
ld [%i1 + 256], %f1
! 1 addresses covered

P4420: !_DWLD [4] (FP)
ldd [%i0 + 64], %f2
! 1 addresses covered

P4421: !_DWLD [11] (FP)
ldd [%i2 + 64], %f18
! 1 addresses covered
fmovs %f18, %f3

P4422: !_LD [12] (FP)
ld [%i3 + 0], %f4
! 1 addresses covered

P4423: !_LD [6] (FP)
ld [%i1 + 80], %f5
! 1 addresses covered

P4424: !_REPLACEMENT [7] (Int)
sethi %hi(0x54), %o5
or %o5, %lo(0x54),  %o5
sethi %hi(0x10000), %l3
or %l3, %lo(0x10000),  %l3
add %i3, %o5, %o5
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]

P4425: !_LD [11] (FP)
ld [%i2 + 64], %f6
! 1 addresses covered

P4426: !_CASX [13] (maybe <- 0x2000029) (Int)
add %i3, 64, %o5
ldx [%o5], %l6
! move %l6(upper) -> %o2(lower)
srlx %l6, 32, %l7
or %l7, %o2, %o2
! move %l6(lower) -> %o3(upper)
sllx %l6, 32, %o3
mov  %l6, %l7
sllx %l4, 32, %l6
casx [%o5], %l7, %l6
! move %l6(upper) -> %o3(lower)
srlx %l6, 32, %o5
or %o5, %o3, %o3
! move %l6(lower) -> %o4(upper)
sllx %l6, 32, %o4
add  %l4, 1, %l4

P4427: !_MEMBAR (Int)
membar #StoreLoad

P4428: !_DWLD [2] (FP)
ldd [%i0 + 8], %f18
! 1 addresses covered
fmovs %f19, %f7

P4429: !_LD [5] (FP)
ld [%i1 + 76], %f8
! 1 addresses covered

P4430: !_SWAP [9] (maybe <- 0x200002a) (Int)
mov %l4, %l3
swap  [%i1 + 512], %l3
! move %l3(lower) -> %o4(lower)
srl %l3, 0, %l7
or %l7, %o4, %o4
!---- flushing int results buffer----
mov %o0, %l5
mov %o1, %l5
mov %o2, %l5
mov %o3, %l5
mov %o4, %l5
add   %l4, 1, %l4

P4431: !_CAS [10] (maybe <- 0x200002b) (Int)
add %i2, 32, %l7
lduw [%l7], %o0
mov %o0, %l6
! move %l6(lower) -> %o0(upper)
sllx %l6, 32, %o0
mov %l4, %l3
cas [%l7], %l6, %l3
! move %l3(lower) -> %o0(lower)
srl %l3, 0, %l7
or %l7, %o0, %o0
add   %l4, 1, %l4

P4432: !_ST [0] (maybe <- 0x41800071) (FP) (Branch target of P5032)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i0 + 0 ]
ba P4433
nop

TARGET5032:
ba RET5032
nop


P4433: !_ST [11] (maybe <- 0x41800072) (FP) (Branch target of P4995)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i2 + 64 ]
ba P4434
nop

TARGET4995:
ba RET4995
nop


P4434: !_DWST [1] (maybe <- 0x41800073) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
! 1 th moved, current_fp_src=21 
fmovs  %f16, %f21
fadds  %f16, %f17, %f16
std %f20, [%i0 + 0]

P4435: !_DWST [3] (maybe <- 0x41800075) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
std %f20, [%i0 + 32]

P4436: !_ST [14] (maybe <- 0x41800076) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i3 + 128 ]

P4437: !_DWLD [0] (FP)
ldd [%i0 + 0], %f18
! 2 addresses covered
fmovs %f18, %f9
fmovs %f19, %f10

P4438: !_DWST [4] (maybe <- 0x41800077) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
std %f20, [%i0 + 64]

P4439: !_REPLACEMENT [9] (Int)
sethi %hi(0x200), %o5
or %o5, %lo(0x200),  %o5
sethi %hi(0x10000), %l3
or %l3, %lo(0x10000),  %l3
add %i3, %o5, %o5
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]

P4440: !_NOP (Int)
nop

P4441: !_REPLACEMENT [0] (Int)
sethi %hi(0x0), %l7
or %l7, %lo(0x0),  %l7
sethi %hi(0x10000), %o5
or %o5, %lo(0x10000),  %o5
add %i3, %l7, %l7
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]

P4442: !_ST [5] (maybe <- 0x41800078) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i1 + 76 ]

P4443: !_DWST [9] (maybe <- 0x41800079) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
std %f20, [%i1 + 512]

P4444: !_DWLD [11] (FP) (Branch target of P4666)
ldd [%i2 + 64], %f18
! 1 addresses covered
fmovs %f18, %f11
ba P4445
nop

TARGET4666:
ba RET4666
nop


P4445: !_ST [5] (maybe <- 0x4180007a) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i1 + 76 ]

P4446: !_DWLD [9] (FP)
ldd [%i1 + 512], %f12
! 1 addresses covered

P4447: !_DWST [7] (maybe <- 0x4180007b) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
! 1 th moved, current_fp_src=21 
fmovs  %f16, %f21
fadds  %f16, %f17, %f16
std %f20, [%i1 + 80]

P4448: !_MEMBAR (Int)
membar #StoreLoad

P4449: !_DWLD [13] (FP)
ldd [%i3 + 64], %f18
! 1 addresses covered
fmovs %f18, %f13

P4450: !_PREFETCH [0] (Int)
prefetch [%i0 + 0], 1

P4451: !_LD [6] (FP)
ld [%i1 + 80], %f14
! 1 addresses covered

P4452: !_SWAP [10] (maybe <- 0x200002c) (Int)
mov %l4, %o1
swap  [%i2 + 32], %o1
! move %o1(lower) -> %o1(upper)
sllx %o1, 32, %o1
add   %l4, 1, %l4

P4453: !_ST [3] (maybe <- 0x4180007d) (FP) (CBR)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i0 + 32 ]

! cbranch
andcc %l0, 1, %g0
be,pt  %xcc, TARGET4453
nop
RET4453:

! lfsr step begin
srlx %l0, 1, %o5
xnor %o5, %l0, %o5
sllx %o5, 63, %o5
or  %o5, %l0, %l0
srlx %l0, 1, %l0


P4454: !_LD [1] (FP)
ld [%i0 + 4], %f15
! 1 addresses covered
!---- flushing fp results buffer to %f30 ----
fmovd %f0, %f30
fmovd %f2, %f30
fmovd %f4, %f30
fmovd %f6, %f30
fmovd %f8, %f30
fmovd %f10, %f30
fmovd %f12, %f30
fmovd %f14, %f30

P4455: !_PREFETCH [4] (Int)
prefetch [%i0 + 64], 1

P4456: !_PREFETCH [12] (Int)
prefetch [%i3 + 0], 1

P4457: !_LD [3] (FP)
ld [%i0 + 32], %f0
! 1 addresses covered

P4458: !_DWST [4] (maybe <- 0x4180007e) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
std %f20, [%i0 + 64]

P4459: !_PREFETCH [14] (Int)
prefetch [%i3 + 128], 1

P4460: !_PREFETCH [5] (Int)
prefetch [%i1 + 76], 1

P4461: !_REPLACEMENT [4] (Int)
sethi %hi(0x40), %o5
or %o5, %lo(0x40),  %o5
sethi %hi(0x10000), %l3
or %l3, %lo(0x10000),  %l3
add %i3, %o5, %o5
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]

P4462: !_DWST [3] (maybe <- 0x4180007f) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
std %f20, [%i0 + 32]

P4463: !_DWST [9] (maybe <- 0x41800080) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
std %f20, [%i1 + 512]

P4464: !_NOP (Int)
nop

P4465: !_ST [3] (maybe <- 0x41800081) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i0 + 32 ]

P4466: !_LD [1] (FP)
ld [%i0 + 4], %f1
! 1 addresses covered

P4467: !_DWLD [10] (FP)
ldd [%i2 + 32], %f2
! 1 addresses covered

P4468: !_DWST [0] (maybe <- 0x41800082) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
! 1 th moved, current_fp_src=21 
fmovs  %f16, %f21
fadds  %f16, %f17, %f16
std %f20, [%i0 + 0]

P4469: !_ST [4] (maybe <- 0x41800084) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i0 + 64 ]

P4470: !_REPLACEMENT [7] (Int)
sethi %hi(0x54), %l6
or %l6, %lo(0x54),  %l6
sethi %hi(0x10000), %l7
or %l7, %lo(0x10000),  %l7
add %i3, %l6, %l6
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]

P4471: !_DWST [5] (maybe <- 0x41800085) (FP)
! 0 th moved, current_fp_src=21 
fmovs  %f16, %f21
fadds  %f16, %f17, %f16
std %f20, [%i1 + 72]

P4472: !_REPLACEMENT [12] (Int)
sethi %hi(0x0), %o5
or %o5, %lo(0x0),  %o5
sethi %hi(0x10000), %l3
or %l3, %lo(0x10000),  %l3
add %i3, %o5, %o5
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]

P4473: !_DWST [7] (maybe <- 0x41800086) (FP) (CBR)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
! 1 th moved, current_fp_src=21 
fmovs  %f16, %f21
fadds  %f16, %f17, %f16
std %f20, [%i1 + 80]

! cbranch
andcc %l0, 1, %g0
be,pn  %xcc, TARGET4473
nop
RET4473:

! lfsr step begin
srlx %l0, 1, %l6
xnor %l6, %l0, %l6
sllx %l6, 63, %l6
or  %l6, %l0, %l0
srlx %l0, 1, %l0


P4474: !_ST [3] (maybe <- 0x41800088) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i0 + 32 ]

P4475: !_CAS [6] (maybe <- 0x200002d) (Int)
add %i1, 80, %l7
lduw [%l7], %l3
mov %l3, %l6
! move %l6(lower) -> %o1(lower)
or %l6, %o1, %o1
mov %l4, %o2
cas [%l7], %l6, %o2
! move %o2(lower) -> %o2(upper)
sllx %o2, 32, %o2
add   %l4, 1, %l4

P4476: !_ST [9] (maybe <- 0x41800089) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i1 + 512 ]

P4477: !_ST [12] (maybe <- 0x4180008a) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i3 + 0 ]

P4478: !_DWST [12] (maybe <- 0x4180008b) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
std %f20, [%i3 + 0]

P4479: !_DWLD [10] (FP)
ldd [%i2 + 32], %f18
! 1 addresses covered
fmovs %f18, %f3

P4480: !_LD [0] (FP)
ld [%i0 + 0], %f4
! 1 addresses covered

P4481: !_DWLD [11] (FP)
ldd [%i2 + 64], %f18
! 1 addresses covered
fmovs %f18, %f5

P4482: !_LD [13] (FP)
ld [%i3 + 64], %f6
! 1 addresses covered

P4483: !_MEMBAR (Int)
membar #StoreLoad

P4484: !_PREFETCH [13] (Int)
prefetch [%i3 + 64], 1

P4485: !_REPLACEMENT [14] (Int) (CBR)
sethi %hi(0x80), %l7
or %l7, %lo(0x80),  %l7
sethi %hi(0x10000), %o5
or %o5, %lo(0x10000),  %o5
add %i3, %l7, %l7
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]

! cbranch
andcc %l0, 1, %g0
be,pt  %xcc, TARGET4485
nop
RET4485:

! lfsr step begin
srlx %l0, 1, %l6
xnor %l6, %l0, %l6
sllx %l6, 63, %l6
or  %l6, %l0, %l0
srlx %l0, 1, %l0


P4486: !_DWST [0] (maybe <- 0x4180008c) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
! 1 th moved, current_fp_src=21 
fmovs  %f16, %f21
fadds  %f16, %f17, %f16
std %f20, [%i0 + 0]

P4487: !_PREFETCH [10] (Int)
prefetch [%i2 + 32], 1

P4488: !_SWAP [6] (maybe <- 0x200002e) (Int)
mov %l4, %o5
swap  [%i1 + 80], %o5
! move %o5(lower) -> %o2(lower)
srl %o5, 0, %l6
or %l6, %o2, %o2
add   %l4, 1, %l4

P4489: !_ST [1] (maybe <- 0x4180008e) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i0 + 4 ]

P4490: !_DWST [12] (maybe <- 0x4180008f) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
std %f20, [%i3 + 0]

P4491: !_ST [12] (maybe <- 0x41800090) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i3 + 0 ]

P4492: !_DWST [6] (maybe <- 0x41800091) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
! 1 th moved, current_fp_src=21 
fmovs  %f16, %f21
fadds  %f16, %f17, %f16
std %f20, [%i1 + 80]

P4493: !_ST [3] (maybe <- 0x41800093) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i0 + 32 ]

P4494: !_ST [10] (maybe <- 0x41800094) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i2 + 32 ]

P4495: !_REPLACEMENT [3] (Int)
sethi %hi(0x20), %l7
or %l7, %lo(0x20),  %l7
sethi %hi(0x10000), %o5
or %o5, %lo(0x10000),  %o5
add %i3, %l7, %l7
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]

P4496: !_PREFETCH [5] (Int)
prefetch [%i1 + 76], 1

P4497: !_PREFETCH [3] (Int)
prefetch [%i0 + 32], 1

P4498: !_CAS [7] (maybe <- 0x200002f) (Int) (LE)
! Change single-word-level endianess (big endian <-> little endian) 
sethi %hi(0xff00ff00), %l7
or %l7, %lo(0xff00ff00), %l7
and %l4, %l7, %l6
srl %l6, 8, %l6
sll %l4, 8, %o5
and %o5, %l7, %o5
or %o5, %l6, %o5
srl %o5, 16, %l6
sll %o5, 16, %o5
srl %o5, 0, %o5
or %o5, %l6, %o5
wr %g0, 0x88, %asi
add %i1, 84, %l7
lduwa [%l7] %asi, %o3
mov %o3, %l6
! move %l6(lower) -> %o3(upper)
sllx %l6, 32, %o3
mov %o5, %l3
casa [%l7] %asi, %l6, %l3
! move %l3(lower) -> %o3(lower)
srl %l3, 0, %l7
or %l7, %o3, %o3
add   %l4, 1, %l4

P4499: !_CASX [2] (maybe <- 0x2000030) (Int)
add %i0, 8, %l7
ldx [%l7], %o4
! move %o4(upper) -> %o4(upper)
! move %o4(lower) -> %o4(lower)
!---- flushing int results buffer----
mov %o0, %l5
mov %o1, %l5
mov %o2, %l5
mov %o3, %l5
mov %o4, %l5
mov  %o4, %l6
mov %l4, %o0
casx [%l7], %l6, %o0
! move %o0(upper) -> %o0(upper)
! move %o0(lower) -> %o0(lower)
add  %l4, 1, %l4

P4500: !_REPLACEMENT [2] (Int)
sethi %hi(0xc), %l6
or %l6, %lo(0xc),  %l6
sethi %hi(0x10000), %l7
or %l7, %lo(0x10000),  %l7
add %i3, %l6, %l6
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]

P4501: !_REPLACEMENT [12] (Int)
sethi %hi(0x0), %l3
or %l3, %lo(0x0),  %l3
sethi %hi(0x10000), %l6
or %l6, %lo(0x10000),  %l6
add %i3, %l3, %l3
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]

P4502: !_PREFETCH [3] (Int)
prefetch [%i0 + 32], 1

P4503: !_DWST [2] (maybe <- 0x41800095) (FP)
! 0 th moved, current_fp_src=21 
fmovs  %f16, %f21
fadds  %f16, %f17, %f16
std %f20, [%i0 + 8]

P4504: !_DWST [4] (maybe <- 0x41800096) (FP) (Branch target of P4518)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
std %f20, [%i0 + 64]
ba P4505
nop

TARGET4518:
ba RET4518
nop


P4505: !_LD [3] (FP) (CBR)
ld [%i0 + 32], %f7
! 1 addresses covered

! cbranch
andcc %l0, 1, %g0
be,pn  %xcc, TARGET4505
nop
RET4505:

! lfsr step begin
srlx %l0, 1, %l6
xnor %l6, %l0, %l6
sllx %l6, 63, %l6
or  %l6, %l0, %l0
srlx %l0, 1, %l0


P4506: !_SWAP [12] (maybe <- 0x2000031) (Int)
mov %l4, %o1
swap  [%i3 + 0], %o1
! move %o1(lower) -> %o1(upper)
sllx %o1, 32, %o1
add   %l4, 1, %l4

P4507: !_ST [3] (maybe <- 0x41800097) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i0 + 32 ]

P4508: !_PREFETCH [4] (Int)
prefetch [%i0 + 64], 1

P4509: !_DWLD [1] (FP)
ldd [%i0 + 0], %f8
! 2 addresses covered

P4510: !_PREFETCH [6] (Int)
prefetch [%i1 + 80], 1

P4511: !_LD [5] (FP) (Branch target of P4827)
ld [%i1 + 76], %f10
! 1 addresses covered
ba P4512
nop

TARGET4827:
ba RET4827
nop


P4512: !_LD [9] (FP)
ld [%i1 + 512], %f11
! 1 addresses covered

P4513: !_DWST [14] (maybe <- 0x41800098) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
std %f20, [%i3 + 128]

P4514: !_DWLD [2] (FP)
ldd [%i0 + 8], %f12
! 1 addresses covered
fmovs %f13, %f12

P4515: !_DWST [11] (maybe <- 0x41800099) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
std %f20, [%i2 + 64]

P4516: !_SWAP [11] (maybe <- 0x2000032) (Int) (CBR)
mov %l4, %l3
swap  [%i2 + 64], %l3
! move %l3(lower) -> %o1(lower)
srl %l3, 0, %l7
or %l7, %o1, %o1
add   %l4, 1, %l4

! cbranch
andcc %l0, 1, %g0
be,pt  %xcc, TARGET4516
nop
RET4516:

! lfsr step begin
srlx %l0, 1, %l6
xnor %l6, %l0, %l6
sllx %l6, 63, %l6
or  %l6, %l0, %l0
srlx %l0, 1, %l0


P4517: !_REPLACEMENT [3] (Int)
sethi %hi(0x20), %l7
or %l7, %lo(0x20),  %l7
sethi %hi(0x10000), %o5
or %o5, %lo(0x10000),  %o5
add %i3, %l7, %l7
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]

P4518: !_REPLACEMENT [0] (Int) (CBR)
sethi %hi(0x0), %l6
or %l6, %lo(0x0),  %l6
sethi %hi(0x10000), %l7
or %l7, %lo(0x10000),  %l7
add %i3, %l6, %l6
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]

! cbranch
andcc %l0, 1, %g0
be,pt  %xcc, TARGET4518
nop
RET4518:

! lfsr step begin
srlx %l0, 1, %l3
xnor %l3, %l0, %l3
sllx %l3, 63, %l3
or  %l3, %l0, %l0
srlx %l0, 1, %l0


P4519: !_PREFETCH [3] (Int)
prefetch [%i0 + 32], 1

P4520: !_NOP (Int)
nop

P4521: !_DWLD [9] (FP)
ldd [%i1 + 512], %f18
! 1 addresses covered
fmovs %f18, %f13

P4522: !_PREFETCH [8] (Int)
prefetch [%i1 + 256], 1

P4523: !_DWST [10] (maybe <- 0x4180009a) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
std %f20, [%i2 + 32]

P4524: !_REPLACEMENT [3] (Int)
sethi %hi(0x20), %l3
or %l3, %lo(0x20),  %l3
sethi %hi(0x10000), %l6
or %l6, %lo(0x10000),  %l6
add %i3, %l3, %l3
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]

P4525: !_ST [8] (maybe <- 0x4180009b) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i1 + 256 ]

P4526: !_ST [0] (maybe <- 0x4180009c) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i0 + 0 ]

P4527: !_LD [12] (FP)
ld [%i3 + 0], %f14
! 1 addresses covered

P4528: !_PREFETCH [0] (Int)
prefetch [%i0 + 0], 1

P4529: !_ST [4] (maybe <- 0x4180009d) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i0 + 64 ]

P4530: !_PREFETCH [10] (Int)
prefetch [%i2 + 32], 1

P4531: !_PREFETCH [4] (Int) (CBR)
prefetch [%i0 + 64], 1

! cbranch
andcc %l0, 1, %g0
be,pn  %xcc, TARGET4531
nop
RET4531:

! lfsr step begin
srlx %l0, 1, %l3
xnor %l3, %l0, %l3
sllx %l3, 63, %l3
or  %l3, %l0, %l0
srlx %l0, 1, %l0


P4532: !_CAS [12] (maybe <- 0x2000033) (Int)
add %i3, 0, %l7
lduw [%l7], %o2
mov %o2, %l6
! move %l6(lower) -> %o2(upper)
sllx %l6, 32, %o2
mov %l4, %l3
cas [%l7], %l6, %l3
! move %l3(lower) -> %o2(lower)
srl %l3, 0, %l7
or %l7, %o2, %o2
add   %l4, 1, %l4

P4533: !_MEMBAR (Int)
membar #StoreLoad

P4534: !_PREFETCH [3] (Int)
prefetch [%i0 + 32], 1

P4535: !_ST [7] (maybe <- 0x4180009e) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i1 + 84 ]

P4536: !_DWLD [13] (FP)
ldd [%i3 + 64], %f18
! 1 addresses covered
fmovs %f18, %f15
!---- flushing fp results buffer to %f30 ----
fmovd %f0, %f30
fmovd %f2, %f30
fmovd %f4, %f30
fmovd %f6, %f30
fmovd %f8, %f30
fmovd %f10, %f30
fmovd %f12, %f30
fmovd %f14, %f30

P4537: !_DWST [15] (maybe <- 0x4180009f) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
std %f20, [%i3 + 192]

P4538: !_ST [14] (maybe <- 0x418000a0) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i3 + 128 ]

P4539: !_PREFETCH [1] (Int)
prefetch [%i0 + 4], 1

P4540: !_PREFETCH [12] (Int) (CBR) (Branch target of P4485)
prefetch [%i3 + 0], 1

! cbranch
andcc %l0, 1, %g0
be,pn  %xcc, TARGET4540
nop
RET4540:

! lfsr step begin
srlx %l0, 1, %l7
xnor %l7, %l0, %l7
sllx %l7, 63, %l7
or  %l7, %l0, %l0
srlx %l0, 1, %l0

ba P4541
nop

TARGET4485:
ba RET4485
nop


P4541: !_DWST [6] (maybe <- 0x418000a1) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
! 1 th moved, current_fp_src=21 
fmovs  %f16, %f21
fadds  %f16, %f17, %f16
std %f20, [%i1 + 80]

P4542: !_PREFETCH [5] (Int)
prefetch [%i1 + 76], 1

P4543: !_PREFETCH [7] (Int)
prefetch [%i1 + 84], 1

P4544: !_REPLACEMENT [10] (Int)
sethi %hi(0x20), %l7
or %l7, %lo(0x20),  %l7
sethi %hi(0x10000), %o5
or %o5, %lo(0x10000),  %o5
add %i3, %l7, %l7
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]

P4545: !_SWAP [10] (maybe <- 0x2000034) (Int)
mov %l4, %o3
swap  [%i2 + 32], %o3
! move %o3(lower) -> %o3(upper)
sllx %o3, 32, %o3
add   %l4, 1, %l4

P4546: !_PREFETCH [5] (Int)
prefetch [%i1 + 76], 1

P4547: !_LD [14] (FP)
ld [%i3 + 128], %f0
! 1 addresses covered

P4548: !_CASX [9] (maybe <- 0x2000035) (Int)
add %i1, 512, %l6
ldx [%l6], %o5
! move %o5(upper) -> %o3(lower)
srlx %o5, 32, %l3
or %l3, %o3, %o3
! move %o5(lower) -> %o4(upper)
sllx %o5, 32, %o4
mov  %o5, %l3
sllx %l4, 32, %o5
casx [%l6], %l3, %o5
! move %o5(upper) -> %o4(lower)
srlx %o5, 32, %l6
or %l6, %o4, %o4
!---- flushing int results buffer----
mov %o0, %l5
mov %o1, %l5
mov %o2, %l5
mov %o3, %l5
mov %o4, %l5
! move %o5(lower) -> %o0(upper)
sllx %o5, 32, %o0
add  %l4, 1, %l4

P4549: !_ST [12] (maybe <- 0x418000a3) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i3 + 0 ]

P4550: !_ST [6] (maybe <- 0x418000a4) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i1 + 80 ]

P4551: !_DWLD [12] (FP)
ldd [%i3 + 0], %f18
! 1 addresses covered
fmovs %f18, %f1

P4552: !_PREFETCH [8] (Int)
prefetch [%i1 + 256], 1

P4553: !_MEMBAR (Int)
membar #StoreLoad

P4554: !_DWST [15] (maybe <- 0x418000a5) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
std %f20, [%i3 + 192]

P4555: !_LD [12] (FP)
ld [%i3 + 0], %f2
! 1 addresses covered

P4556: !_CAS [2] (maybe <- 0x2000036) (Int)
add %i0, 12, %l7
lduw [%l7], %l3
mov %l3, %l6
! move %l6(lower) -> %o0(lower)
or %l6, %o0, %o0
mov %l4, %o1
cas [%l7], %l6, %o1
! move %o1(lower) -> %o1(upper)
sllx %o1, 32, %o1
add   %l4, 1, %l4

P4557: !_REPLACEMENT [11] (Int)
sethi %hi(0x40), %l6
or %l6, %lo(0x40),  %l6
sethi %hi(0x10000), %l7
or %l7, %lo(0x10000),  %l7
add %i3, %l6, %l6
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]

P4558: !_DWST [0] (maybe <- 0x418000a6) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
! 1 th moved, current_fp_src=21 
fmovs  %f16, %f21
fadds  %f16, %f17, %f16
std %f20, [%i0 + 0]

P4559: !_DWLD [1] (FP)
ldd [%i0 + 0], %f18
! 2 addresses covered
fmovs %f18, %f3
fmovs %f19, %f4

P4560: !_DWST [10] (maybe <- 0x418000a8) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
std %f20, [%i2 + 32]

P4561: !_ST [0] (maybe <- 0x418000a9) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i0 + 0 ]

P4562: !_DWLD [10] (FP)
ldd [%i2 + 32], %f18
! 1 addresses covered
fmovs %f18, %f5

P4563: !_ST [11] (maybe <- 0x418000aa) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i2 + 64 ]

P4564: !_DWLD [5] (FP)
ldd [%i1 + 72], %f6
! 1 addresses covered
fmovs %f7, %f6

P4565: !_REPLACEMENT [15] (Int)
sethi %hi(0xc0), %l3
or %l3, %lo(0xc0),  %l3
sethi %hi(0x10000), %l6
or %l6, %lo(0x10000),  %l6
add %i3, %l3, %l3
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]

P4566: !_REPLACEMENT [9] (Int)
sethi %hi(0x200), %o5
or %o5, %lo(0x200),  %o5
sethi %hi(0x10000), %l3
or %l3, %lo(0x10000),  %l3
add %i3, %o5, %o5
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]

P4567: !_PREFETCH [3] (Int)
prefetch [%i0 + 32], 1

P4568: !_PREFETCH [15] (Int) (Branch target of P4846)
prefetch [%i3 + 192], 1
ba P4569
nop

TARGET4846:
ba RET4846
nop


P4569: !_PREFETCH [1] (Int) (CBR)
prefetch [%i0 + 4], 1

! cbranch
andcc %l0, 1, %g0
be,pt  %xcc, TARGET4569
nop
RET4569:

! lfsr step begin
srlx %l0, 1, %l7
xnor %l7, %l0, %l7
sllx %l7, 63, %l7
or  %l7, %l0, %l0
srlx %l0, 1, %l0


P4570: !_ST [3] (maybe <- 0x418000ab) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i0 + 32 ]

P4571: !_LD [15] (FP)
ld [%i3 + 192], %f7
! 1 addresses covered

P4572: !_CASX [9] (maybe <- 0x2000037) (Int)
add %i1, 512, %o5
ldx [%o5], %l6
! move %l6(upper) -> %o1(lower)
srlx %l6, 32, %l7
or %l7, %o1, %o1
! move %l6(lower) -> %o2(upper)
sllx %l6, 32, %o2
mov  %l6, %l7
sllx %l4, 32, %l6
casx [%o5], %l7, %l6
! move %l6(upper) -> %o2(lower)
srlx %l6, 32, %o5
or %o5, %o2, %o2
! move %l6(lower) -> %o3(upper)
sllx %l6, 32, %o3
add  %l4, 1, %l4

P4573: !_SWAP [7] (maybe <- 0x2000038) (Int)
mov %l4, %l3
swap  [%i1 + 84], %l3
! move %l3(lower) -> %o3(lower)
srl %l3, 0, %l7
or %l7, %o3, %o3
add   %l4, 1, %l4

P4574: !_REPLACEMENT [10] (Int) (CBR)
sethi %hi(0x20), %l6
or %l6, %lo(0x20),  %l6
sethi %hi(0x10000), %l7
or %l7, %lo(0x10000),  %l7
add %i3, %l6, %l6
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]

! cbranch
andcc %l0, 1, %g0
be,pn  %xcc, TARGET4574
nop
RET4574:

! lfsr step begin
srlx %l0, 1, %l3
xnor %l3, %l0, %l3
sllx %l3, 63, %l3
or  %l3, %l0, %l0
srlx %l0, 1, %l0


P4575: !_DWST [12] (maybe <- 0x418000ac) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
std %f20, [%i3 + 0]

P4576: !_REPLACEMENT [9] (Int)
sethi %hi(0x200), %l3
or %l3, %lo(0x200),  %l3
sethi %hi(0x10000), %l6
or %l6, %lo(0x10000),  %l6
add %i3, %l3, %l3
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]

P4577: !_LD [7] (FP)
ld [%i1 + 84], %f8
! 1 addresses covered

P4578: !_ST [14] (maybe <- 0x418000ad) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i3 + 128 ]

P4579: !_NOP (Int)
nop

P4580: !_PREFETCH [0] (Int)
prefetch [%i0 + 0], 1

P4581: !_SWAP [2] (maybe <- 0x2000039) (Int)
mov %l4, %o4
swap  [%i0 + 12], %o4
! move %o4(lower) -> %o4(upper)
sllx %o4, 32, %o4
add   %l4, 1, %l4

P4582: !_CASX [7] (maybe <- 0x200003a) (Int)
add %i1, 80, %l7
ldx [%l7], %l3
! move %l3(upper) -> %o4(lower)
srlx %l3, 32, %l6
or %l6, %o4, %o4
!---- flushing int results buffer----
mov %o0, %l5
mov %o1, %l5
mov %o2, %l5
mov %o3, %l5
mov %o4, %l5
! move %l3(lower) -> %o0(upper)
sllx %l3, 32, %o0
mov %l3, %l6
sllx %l4, 32, %l3
add  %l4, 1, %l4
or   %l4, %l3, %l3
casx [%l7], %l6, %l3
! move %l3(upper) -> %o0(lower)
srlx %l3, 32, %l7
or %l7, %o0, %o0
! move %l3(lower) -> %o1(upper)
sllx %l3, 32, %o1
add  %l4, 1, %l4

P4583: !_ST [2] (maybe <- 0x418000ae) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i0 + 12 ]

P4584: !_REPLACEMENT [12] (Int)
sethi %hi(0x0), %l3
or %l3, %lo(0x0),  %l3
sethi %hi(0x10000), %l6
or %l6, %lo(0x10000),  %l6
add %i3, %l3, %l3
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]

P4585: !_DWLD [12] (FP)
ldd [%i3 + 0], %f18
! 1 addresses covered
fmovs %f18, %f9

P4586: !_ST [11] (maybe <- 0x418000af) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i2 + 64 ]

P4587: !_PREFETCH [10] (Int)
prefetch [%i2 + 32], 1

P4588: !_NOP (Int)
nop

P4589: !_DWLD [9] (FP)
ldd [%i1 + 512], %f10
! 1 addresses covered

P4590: !_LD [13] (FP)
ld [%i3 + 64], %f11
! 1 addresses covered

P4591: !_REPLACEMENT [2] (Int)
sethi %hi(0xc), %l7
or %l7, %lo(0xc),  %l7
sethi %hi(0x10000), %o5
or %o5, %lo(0x10000),  %o5
add %i3, %l7, %l7
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]

P4592: !_LD [8] (FP)
ld [%i1 + 256], %f12
! 1 addresses covered

P4593: !_PREFETCH [2] (Int)
prefetch [%i0 + 12], 1

P4594: !_REPLACEMENT [4] (Int)
sethi %hi(0x40), %l6
or %l6, %lo(0x40),  %l6
sethi %hi(0x10000), %l7
or %l7, %lo(0x10000),  %l7
add %i3, %l6, %l6
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]

P4595: !_PREFETCH [2] (Int)
prefetch [%i0 + 12], 1

P4596: !_PREFETCH [7] (Int)
prefetch [%i1 + 84], 1

P4597: !_SWAP [3] (maybe <- 0x200003c) (Int)
mov %l4, %l7
swap  [%i0 + 32], %l7
! move %l7(lower) -> %o1(lower)
srl %l7, 0, %l3
or %l3, %o1, %o1
add   %l4, 1, %l4

P4598: !_REPLACEMENT [9] (Int)
sethi %hi(0x200), %o5
or %o5, %lo(0x200),  %o5
sethi %hi(0x10000), %l3
or %l3, %lo(0x10000),  %l3
add %i3, %o5, %o5
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]

P4599: !_ST [15] (maybe <- 0x418000b0) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i3 + 192 ]

P4600: !_CASX [6] (maybe <- 0x200003d) (Int)
add %i1, 80, %l7
ldx [%l7], %o2
! move %o2(upper) -> %o2(upper)
! move %o2(lower) -> %o2(lower)
mov %o2, %l6
sllx %l4, 32, %o3
add  %l4, 1, %l4
or   %l4, %o3, %o3
casx [%l7], %l6, %o3
! move %o3(upper) -> %o3(upper)
! move %o3(lower) -> %o3(lower)
add  %l4, 1, %l4

P4601: !_SWAP [12] (maybe <- 0x200003f) (Int)
mov %l4, %o4
swap  [%i3 + 0], %o4
! move %o4(lower) -> %o4(upper)
sllx %o4, 32, %o4
add   %l4, 1, %l4

P4602: !_REPLACEMENT [11] (Int)
sethi %hi(0x40), %l3
or %l3, %lo(0x40),  %l3
sethi %hi(0x10000), %l6
or %l6, %lo(0x10000),  %l6
add %i3, %l3, %l3
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]

P4603: !_LD [4] (FP)
ld [%i0 + 64], %f13
! 1 addresses covered

P4604: !_ST [5] (maybe <- 0x418000b1) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i1 + 76 ]

P4605: !_DWLD [2] (FP)
ldd [%i0 + 8], %f14
! 1 addresses covered
fmovs %f15, %f14

P4606: !_LD [0] (Int)
lduw [%i0 + 0], %o5
! move %o5(lower) -> %o4(lower)
or %o5, %o4, %o4
!---- flushing int results buffer----
mov %o0, %l5
mov %o1, %l5
mov %o2, %l5
mov %o3, %l5
mov %o4, %l5

P4607: !_DWLD [8] (FP) (Loop exit)
ldd [%i1 + 256], %f18
! 1 addresses covered
fmovs %f18, %f15
!---- flushing fp results buffer to %f30 ----
fmovd %f0, %f30
fmovd %f2, %f30
fmovd %f4, %f30
fmovd %f6, %f30
fmovd %f8, %f30
fmovd %f10, %f30
fmovd %f12, %f30
fmovd %f14, %f30
loop_exit_4_0:
sub %l2, 1, %l2
cmp %l2, 0
bg loop_entry_4_0
nop

P4608: !_DWLD [8] (FP)
ldd [%i1 + 256], %f0
! 1 addresses covered

P4609: !_LD [5] (FP)
ld [%i1 + 76], %f1
! 1 addresses covered

P4610: !_SWAP [3] (maybe <- 0x2000040) (Int)
mov %l4, %o0
swap  [%i0 + 32], %o0
! move %o0(lower) -> %o0(upper)
sllx %o0, 32, %o0
add   %l4, 1, %l4

P4611: !_CAS [0] (maybe <- 0x2000041) (Int)
add %i0, 0, %l6
lduw [%l6], %o5
mov %o5, %l3
! move %l3(lower) -> %o0(lower)
or %l3, %o0, %o0
mov %l4, %o1
cas [%l6], %l3, %o1
! move %o1(lower) -> %o1(upper)
sllx %o1, 32, %o1
add   %l4, 1, %l4

P4612: !_PREFETCH [14] (Int)
prefetch [%i3 + 128], 1

P4613: !_REPLACEMENT [2] (Int)
sethi %hi(0xc), %l3
or %l3, %lo(0xc),  %l3
sethi %hi(0x10000), %l6
or %l6, %lo(0x10000),  %l6
add %i3, %l3, %l3
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]

P4614: !_SWAP [9] (maybe <- 0x2000042) (Int)
mov %l4, %l6
swap  [%i1 + 512], %l6
! move %l6(lower) -> %o1(lower)
srl %l6, 0, %o5
or %o5, %o1, %o1
add   %l4, 1, %l4

P4615: !_SWAP [3] (maybe <- 0x2000043) (Int)
mov %l4, %o2
swap  [%i0 + 32], %o2
! move %o2(lower) -> %o2(upper)
sllx %o2, 32, %o2
add   %l4, 1, %l4

P4616: !_DWST [0] (maybe <- 0x418000b2) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
! 1 th moved, current_fp_src=21 
fmovs  %f16, %f21
fadds  %f16, %f17, %f16
std %f20, [%i0 + 0]

P4617: !_PREFETCH [8] (Int)
prefetch [%i1 + 256], 1

P4618: !_LD [7] (FP)
ld [%i1 + 84], %f2
! 1 addresses covered

P4619: !_CASX [0] (maybe <- 0x2000044) (Int) (CBR)
add %i0, 0, %l6
ldx [%l6], %o5
! move %o5(upper) -> %o2(lower)
srlx %o5, 32, %l3
or %l3, %o2, %o2
! move %o5(lower) -> %o3(upper)
sllx %o5, 32, %o3
mov %o5, %l3
sllx %l4, 32, %o5
add  %l4, 1, %l4
or   %l4, %o5, %o5
casx [%l6], %l3, %o5
! move %o5(upper) -> %o3(lower)
srlx %o5, 32, %l6
or %l6, %o3, %o3
! move %o5(lower) -> %o4(upper)
sllx %o5, 32, %o4
add  %l4, 1, %l4

! cbranch
andcc %l0, 1, %g0
be,pn  %xcc, TARGET4619
nop
RET4619:

! lfsr step begin
srlx %l0, 1, %l3
xnor %l3, %l0, %l3
sllx %l3, 63, %l3
or  %l3, %l0, %l0
srlx %l0, 1, %l0


P4620: !_LD [13] (FP)
ld [%i3 + 64], %f3
! 1 addresses covered

P4621: !_SWAP [13] (maybe <- 0x2000046) (Int)
mov %l4, %o5
swap  [%i3 + 64], %o5
! move %o5(lower) -> %o4(lower)
srl %o5, 0, %l6
or %l6, %o4, %o4
!---- flushing int results buffer----
mov %o0, %l5
mov %o1, %l5
mov %o2, %l5
mov %o3, %l5
mov %o4, %l5
add   %l4, 1, %l4

P4622: !_PREFETCH [2] (Int)
prefetch [%i0 + 12], 1

P4623: !_REPLACEMENT [3] (Int)
sethi %hi(0x20), %l3
or %l3, %lo(0x20),  %l3
sethi %hi(0x10000), %l6
or %l6, %lo(0x10000),  %l6
add %i3, %l3, %l3
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]

P4624: !_LD [15] (FP)
ld [%i3 + 192], %f4
! 1 addresses covered

P4625: !_ST [9] (maybe <- 0x418000b4) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i1 + 512 ]

P4626: !_ST [1] (maybe <- 0x418000b5) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i0 + 4 ]

P4627: !_ST [0] (maybe <- 0x418000b6) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i0 + 0 ]

P4628: !_ST [11] (maybe <- 0x418000b7) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i2 + 64 ]

P4629: !_CAS [10] (maybe <- 0x2000047) (Int)
add %i2, 32, %l3
lduw [%l3], %o0
mov %o0, %o5
! move %o5(lower) -> %o0(upper)
sllx %o5, 32, %o0
mov %l4, %l7
cas [%l3], %o5, %l7
! move %l7(lower) -> %o0(lower)
srl %l7, 0, %l3
or %l3, %o0, %o0
add   %l4, 1, %l4

P4630: !_ST [4] (maybe <- 0x418000b8) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i0 + 64 ]

P4631: !_LD [13] (FP)
ld [%i3 + 64], %f5
! 1 addresses covered

P4632: !_DWST [3] (maybe <- 0x418000b9) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
std %f20, [%i0 + 32]

P4633: !_NOP (Int)
nop

P4634: !_DWST [8] (maybe <- 0x418000ba) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
std %f20, [%i1 + 256]

P4635: !_ST [1] (maybe <- 0x418000bb) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i0 + 4 ]

P4636: !_REPLACEMENT [14] (Int) (CBR)
sethi %hi(0x80), %o5
or %o5, %lo(0x80),  %o5
sethi %hi(0x10000), %l3
or %l3, %lo(0x10000),  %l3
add %i3, %o5, %o5
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]

! cbranch
andcc %l0, 1, %g0
be,pn  %xcc, TARGET4636
nop
RET4636:

! lfsr step begin
srlx %l0, 1, %l7
xnor %l7, %l0, %l7
sllx %l7, 63, %l7
or  %l7, %l0, %l0
srlx %l0, 1, %l0


P4637: !_DWLD [8] (FP)
ldd [%i1 + 256], %f6
! 1 addresses covered

P4638: !_PREFETCH [10] (Int)
prefetch [%i2 + 32], 1

P4639: !_DWLD [7] (FP) (CBR)
ldd [%i1 + 80], %f18
! 2 addresses covered
fmovs %f18, %f7
fmovs %f19, %f8

! cbranch
andcc %l0, 1, %g0
be,pn  %xcc, TARGET4639
nop
RET4639:

! lfsr step begin
srlx %l0, 1, %o5
xnor %o5, %l0, %o5
sllx %o5, 63, %o5
or  %o5, %l0, %l0
srlx %l0, 1, %l0


P4640: !_REPLACEMENT [13] (Int) (Branch target of P4940)
sethi %hi(0x40), %l3
or %l3, %lo(0x40),  %l3
sethi %hi(0x10000), %l6
or %l6, %lo(0x10000),  %l6
add %i3, %l3, %l3
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
ba P4641
nop

TARGET4940:
ba RET4940
nop


P4641: !_ST [0] (maybe <- 0x418000bc) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i0 + 0 ]

P4642: !_PREFETCH [0] (Int)
prefetch [%i0 + 0], 1

P4643: !_MEMBAR (Int)
membar #StoreLoad

P4644: !_CASX [6] (maybe <- 0x2000048) (Int)
add %i1, 80, %o5
ldx [%o5], %o1
! move %o1(upper) -> %o1(upper)
! move %o1(lower) -> %o1(lower)
mov %o1, %l7
sllx %l4, 32, %o2
add  %l4, 1, %l4
or   %l4, %o2, %o2
casx [%o5], %l7, %o2
! move %o2(upper) -> %o2(upper)
! move %o2(lower) -> %o2(lower)
add  %l4, 1, %l4

P4645: !_ST [8] (maybe <- 0x418000bd) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i1 + 256 ]

P4646: !_LD [10] (FP)
ld [%i2 + 32], %f9
! 1 addresses covered

P4647: !_DWLD [13] (FP)
ldd [%i3 + 64], %f10
! 1 addresses covered

P4648: !_REPLACEMENT [15] (Int)
sethi %hi(0xc0), %l6
or %l6, %lo(0xc0),  %l6
sethi %hi(0x10000), %l7
or %l7, %lo(0x10000),  %l7
add %i3, %l6, %l6
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]

P4649: !_LD [5] (FP)
ld [%i1 + 76], %f11
! 1 addresses covered

P4650: !_NOP (Int)
nop

P4651: !_PREFETCH [10] (Int)
prefetch [%i2 + 32], 1

P4652: !_PREFETCH [2] (Int)
prefetch [%i0 + 12], 1

P4653: !_PREFETCH [14] (Int)
prefetch [%i3 + 128], 1

P4654: !_ST [5] (maybe <- 0x418000be) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i1 + 76 ]

P4655: !_DWST [9] (maybe <- 0x418000bf) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
std %f20, [%i1 + 512]

P4656: !_PREFETCH [8] (Int) (LE)
wr %g0, 0x88, %asi
prefetcha [%i1 + 256] %asi, 1

P4657: !_LD [14] (FP)
ld [%i3 + 128], %f12
! 1 addresses covered

P4658: !_LD [13] (FP) (Branch target of P5031)
ld [%i3 + 64], %f13
! 1 addresses covered
ba P4659
nop

TARGET5031:
ba RET5031
nop


P4659: !_ST [7] (maybe <- 0x418000c0) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i1 + 84 ]

P4660: !_DWLD [13] (FP)
ldd [%i3 + 64], %f14
! 1 addresses covered

P4661: !_REPLACEMENT [11] (Int)
sethi %hi(0x40), %l6
or %l6, %lo(0x40),  %l6
sethi %hi(0x10000), %l7
or %l7, %lo(0x10000),  %l7
add %i3, %l6, %l6
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]

P4662: !_REPLACEMENT [0] (Int) (CBR)
sethi %hi(0x0), %l3
or %l3, %lo(0x0),  %l3
sethi %hi(0x10000), %l6
or %l6, %lo(0x10000),  %l6
add %i3, %l3, %l3
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]

! cbranch
andcc %l0, 1, %g0
be,pn  %xcc, TARGET4662
nop
RET4662:

! lfsr step begin
srlx %l0, 1, %o5
xnor %o5, %l0, %o5
sllx %o5, 63, %o5
or  %o5, %l0, %l0
srlx %l0, 1, %l0


P4663: !_LD [8] (FP)
ld [%i1 + 256], %f15
! 1 addresses covered
!---- flushing fp results buffer to %f30 ----
fmovd %f0, %f30
fmovd %f2, %f30
fmovd %f4, %f30
fmovd %f6, %f30
fmovd %f8, %f30
fmovd %f10, %f30
fmovd %f12, %f30
fmovd %f14, %f30

P4664: !_REPLACEMENT [4] (Int)
sethi %hi(0x40), %l3
or %l3, %lo(0x40),  %l3
sethi %hi(0x10000), %l6
or %l6, %lo(0x10000),  %l6
add %i3, %l3, %l3
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]

P4665: !_ST [15] (maybe <- 0x418000c1) (FP) (CBR)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i3 + 192 ]

! cbranch
andcc %l0, 1, %g0
be,pn  %xcc, TARGET4665
nop
RET4665:

! lfsr step begin
srlx %l0, 1, %l7
xnor %l7, %l0, %l7
sllx %l7, 63, %l7
or  %l7, %l0, %l0
srlx %l0, 1, %l0


P4666: !_LD [5] (FP) (CBR)
ld [%i1 + 76], %f0
! 1 addresses covered

! cbranch
andcc %l0, 1, %g0
be,pn  %xcc, TARGET4666
nop
RET4666:

! lfsr step begin
srlx %l0, 1, %o5
xnor %o5, %l0, %o5
sllx %o5, 63, %o5
or  %o5, %l0, %l0
srlx %l0, 1, %l0


P4667: !_PREFETCH [13] (Int) (CBR)
prefetch [%i3 + 64], 1

! cbranch
andcc %l0, 1, %g0
be,pt  %xcc, TARGET4667
nop
RET4667:

! lfsr step begin
srlx %l0, 1, %l3
xnor %l3, %l0, %l3
sllx %l3, 63, %l3
or  %l3, %l0, %l0
srlx %l0, 1, %l0


P4668: !_DWST [12] (maybe <- 0x418000c2) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
std %f20, [%i3 + 0]

P4669: !_ST [6] (maybe <- 0x418000c3) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i1 + 80 ]

P4670: !_ST [14] (maybe <- 0x418000c4) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i3 + 128 ]

P4671: !_PREFETCH [12] (Int)
prefetch [%i3 + 0], 1

P4672: !_MEMBAR (Int)
membar #StoreLoad

P4673: !_LD [12] (FP)
ld [%i3 + 0], %f1
! 1 addresses covered

P4674: !_DWLD [7] (FP)
ldd [%i1 + 80], %f2
! 2 addresses covered

P4675: !_PREFETCH [9] (Int)
prefetch [%i1 + 512], 1

P4676: !_LD [2] (FP)
ld [%i0 + 12], %f4
! 1 addresses covered

P4677: !_DWST [6] (maybe <- 0x418000c5) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
! 1 th moved, current_fp_src=21 
fmovs  %f16, %f21
fadds  %f16, %f17, %f16
std %f20, [%i1 + 80]

P4678: !_SWAP [15] (maybe <- 0x200004a) (Int)
mov %l4, %o3
swap  [%i3 + 192], %o3
! move %o3(lower) -> %o3(upper)
sllx %o3, 32, %o3
add   %l4, 1, %l4

P4679: !_ST [14] (maybe <- 0x418000c7) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i3 + 128 ]

P4680: !_DWST [12] (maybe <- 0x418000c8) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
std %f20, [%i3 + 0]

P4681: !_PREFETCH [15] (Int)
prefetch [%i3 + 192], 1

P4682: !_LD [8] (FP) (Branch target of P4255)
ld [%i1 + 256], %f5
! 1 addresses covered
ba P4683
nop

TARGET4255:
ba RET4255
nop


P4683: !_DWST [10] (maybe <- 0x418000c9) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
std %f20, [%i2 + 32]

P4684: !_DWLD [10] (FP)
ldd [%i2 + 32], %f6
! 1 addresses covered

P4685: !_REPLACEMENT [1] (Int)
sethi %hi(0x4), %l6
or %l6, %lo(0x4),  %l6
sethi %hi(0x10000), %l7
or %l7, %lo(0x10000),  %l7
add %i3, %l6, %l6
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]

P4686: !_MEMBAR (Int)
membar #StoreLoad

P4687: !_DWST [15] (maybe <- 0x418000ca) (FP) (CBR)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
std %f20, [%i3 + 192]

! cbranch
andcc %l0, 1, %g0
be,pt  %xcc, TARGET4687
nop
RET4687:

! lfsr step begin
srlx %l0, 1, %o5
xnor %o5, %l0, %o5
sllx %o5, 63, %o5
or  %o5, %l0, %l0
srlx %l0, 1, %l0


P4688: !_MEMBAR (Int)
membar #StoreLoad

P4689: !_DWST [8] (maybe <- 0x418000cb) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
std %f20, [%i1 + 256]

P4690: !_DWST [10] (maybe <- 0x418000cc) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
std %f20, [%i2 + 32]

P4691: !_REPLACEMENT [11] (Int)
sethi %hi(0x40), %l7
or %l7, %lo(0x40),  %l7
sethi %hi(0x10000), %o5
or %o5, %lo(0x10000),  %o5
add %i3, %l7, %l7
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]

P4692: !_ST [5] (maybe <- 0x418000cd) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i1 + 76 ]

P4693: !_PREFETCH [12] (Int)
prefetch [%i3 + 0], 1

P4694: !_DWST [9] (maybe <- 0x418000ce) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
std %f20, [%i1 + 512]

P4695: !_LD [15] (FP)
ld [%i3 + 192], %f7
! 1 addresses covered

P4696: !_DWLD [7] (FP)
ldd [%i1 + 80], %f8
! 2 addresses covered

P4697: !_REPLACEMENT [2] (Int)
sethi %hi(0xc), %o5
or %o5, %lo(0xc),  %o5
sethi %hi(0x10000), %l3
or %l3, %lo(0x10000),  %l3
add %i3, %o5, %o5
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]

P4698: !_CAS [2] (maybe <- 0x200004b) (Int)
add %i0, 12, %o5
lduw [%o5], %l6
mov %l6, %l7
! move %l7(lower) -> %o3(lower)
or %l7, %o3, %o3
mov %l4, %o4
cas [%o5], %l7, %o4
! move %o4(lower) -> %o4(upper)
sllx %o4, 32, %o4
add   %l4, 1, %l4

P4699: !_MEMBAR (Int)
membar #StoreLoad

P4700: !_REPLACEMENT [13] (Int)
sethi %hi(0x40), %l7
or %l7, %lo(0x40),  %l7
sethi %hi(0x10000), %o5
or %o5, %lo(0x10000),  %o5
add %i3, %l7, %l7
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]

P4701: !_LD [13] (FP) (CBR)
ld [%i3 + 64], %f10
! 1 addresses covered

! cbranch
andcc %l0, 1, %g0
be,pt  %xcc, TARGET4701
nop
RET4701:

! lfsr step begin
srlx %l0, 1, %l6
xnor %l6, %l0, %l6
sllx %l6, 63, %l6
or  %l6, %l0, %l0
srlx %l0, 1, %l0


P4702: !_DWST [7] (maybe <- 0x418000cf) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
! 1 th moved, current_fp_src=21 
fmovs  %f16, %f21
fadds  %f16, %f17, %f16
std %f20, [%i1 + 80]

P4703: !_REPLACEMENT [3] (Int)
sethi %hi(0x20), %l6
or %l6, %lo(0x20),  %l6
sethi %hi(0x10000), %l7
or %l7, %lo(0x10000),  %l7
add %i3, %l6, %l6
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]

P4704: !_CAS [5] (maybe <- 0x200004c) (Int)
add %i1, 76, %l6
lduw [%l6], %o5
mov %o5, %l3
! move %l3(lower) -> %o4(lower)
or %l3, %o4, %o4
!---- flushing int results buffer----
mov %o0, %l5
mov %o1, %l5
mov %o2, %l5
mov %o3, %l5
mov %o4, %l5
mov %l4, %o0
cas [%l6], %l3, %o0
! move %o0(lower) -> %o0(upper)
sllx %o0, 32, %o0
add   %l4, 1, %l4

P4705: !_REPLACEMENT [7] (Int)
sethi %hi(0x54), %l3
or %l3, %lo(0x54),  %l3
sethi %hi(0x10000), %l6
or %l6, %lo(0x10000),  %l6
add %i3, %l3, %l3
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]

P4706: !_DWST [13] (maybe <- 0x418000d1) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
std %f20, [%i3 + 64]

P4707: !_REPLACEMENT [11] (Int)
sethi %hi(0x40), %l7
or %l7, %lo(0x40),  %l7
sethi %hi(0x10000), %o5
or %o5, %lo(0x10000),  %o5
add %i3, %l7, %l7
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]

P4708: !_CASX [9] (maybe <- 0x200004d) (Int) (LE)
! Change single-word-level endianess (big endian <-> little endian) 
sethi %hi(0xff00ff00), %l7
or %l7, %lo(0xff00ff00), %l7
and %l4, %l7, %l6
srl %l6, 8, %l6
sll %l4, 8, %o5
and %o5, %l7, %o5
or %o5, %l6, %o5
srl %o5, 16, %l6
sll %o5, 16, %o5
srl %o5, 0, %o5
or %o5, %l6, %o5
wr %g0, 0x88, %asi
add %i1, 512, %l7
ldxa [%l7] %asi, %l3
! move %l3(lower) -> %o0(lower)
srl %l3, 0, %l6
or %l6, %o0, %o0
! move %l3(upper) -> %o1(upper)
or %l3, %g0, %o1
mov  %l3, %l6
mov  %o5, %l3
casxa [%l7] %asi, %l6, %l3
! move %l3(lower) -> %o1(lower)
srlx %o1, 32, %o1
sllx %o1, 32, %o1
srl %l3, 0, %l7
or %l7, %o1, %o1
! move %l3(upper) -> %o2(upper)
or %l3, %g0, %o2
add  %l4, 1, %l4

P4709: !_DWST [6] (maybe <- 0x418000d2) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
! 1 th moved, current_fp_src=21 
fmovs  %f16, %f21
fadds  %f16, %f17, %f16
std %f20, [%i1 + 80]

P4710: !_DWLD [12] (FP)
ldd [%i3 + 0], %f18
! 1 addresses covered
fmovs %f18, %f11

P4711: !_CASX [6] (maybe <- 0x200004e) (Int)
add %i1, 80, %l6
ldx [%l6], %o5
! move %o5(upper) -> %o2(lower)
srlx %o2, 32, %o2
sllx %o2, 32, %o2
srlx %o5, 32, %l3
or %l3, %o2, %o2
! move %o5(lower) -> %o3(upper)
sllx %o5, 32, %o3
mov %o5, %l3
sllx %l4, 32, %o5
add  %l4, 1, %l4
or   %l4, %o5, %o5
casx [%l6], %l3, %o5
! move %o5(upper) -> %o3(lower)
srlx %o5, 32, %l6
or %l6, %o3, %o3
! move %o5(lower) -> %o4(upper)
sllx %o5, 32, %o4
add  %l4, 1, %l4

P4712: !_DWLD [6] (FP)
ldd [%i1 + 80], %f12
! 2 addresses covered

P4713: !_DWST [10] (maybe <- 0x418000d4) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
std %f20, [%i2 + 32]

P4714: !_CASX [4] (maybe <- 0x2000050) (Int)
add %i0, 64, %l3
ldx [%l3], %l7
! move %l7(upper) -> %o4(lower)
srlx %l7, 32, %o5
or %o5, %o4, %o4
!---- flushing int results buffer----
mov %o0, %l5
mov %o1, %l5
mov %o2, %l5
mov %o3, %l5
mov %o4, %l5
! move %l7(lower) -> %o0(upper)
sllx %l7, 32, %o0
mov  %l7, %o5
sllx %l4, 32, %l7
casx [%l3], %o5, %l7
! move %l7(upper) -> %o0(lower)
srlx %l7, 32, %l3
or %l3, %o0, %o0
! move %l7(lower) -> %o1(upper)
sllx %l7, 32, %o1
add  %l4, 1, %l4

P4715: !_LD [11] (FP)
ld [%i2 + 64], %f14
! 1 addresses covered

P4716: !_DWST [0] (maybe <- 0x418000d5) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
! 1 th moved, current_fp_src=21 
fmovs  %f16, %f21
fadds  %f16, %f17, %f16
std %f20, [%i0 + 0]

P4717: !_CASX [13] (maybe <- 0x2000051) (Int)
add %i3, 64, %o5
ldx [%o5], %l6
! move %l6(upper) -> %o1(lower)
srlx %l6, 32, %l7
or %l7, %o1, %o1
! move %l6(lower) -> %o2(upper)
sllx %l6, 32, %o2
mov  %l6, %l7
sllx %l4, 32, %l6
casx [%o5], %l7, %l6
! move %l6(upper) -> %o2(lower)
srlx %l6, 32, %o5
or %o5, %o2, %o2
! move %l6(lower) -> %o3(upper)
sllx %l6, 32, %o3
add  %l4, 1, %l4

P4718: !_PREFETCH [12] (Int)
prefetch [%i3 + 0], 1

P4719: !_DWLD [5] (FP)
ldd [%i1 + 72], %f18
! 1 addresses covered
fmovs %f19, %f15
!---- flushing fp results buffer to %f30 ----
fmovd %f0, %f30
fmovd %f2, %f30
fmovd %f4, %f30
fmovd %f6, %f30
fmovd %f8, %f30
fmovd %f10, %f30
fmovd %f12, %f30
fmovd %f14, %f30

P4720: !_DWLD [1] (FP)
ldd [%i0 + 0], %f0
! 2 addresses covered

P4721: !_ST [8] (maybe <- 0x418000d7) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i1 + 256 ]

P4722: !_DWST [1] (maybe <- 0x418000d8) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
! 1 th moved, current_fp_src=21 
fmovs  %f16, %f21
fadds  %f16, %f17, %f16
std %f20, [%i0 + 0]

P4723: !_CAS [2] (maybe <- 0x2000052) (Int)
add %i0, 12, %l6
lduw [%l6], %o5
mov %o5, %l3
! move %l3(lower) -> %o3(lower)
or %l3, %o3, %o3
mov %l4, %o4
cas [%l6], %l3, %o4
! move %o4(lower) -> %o4(upper)
sllx %o4, 32, %o4
add   %l4, 1, %l4

P4724: !_CAS [12] (maybe <- 0x2000053) (Int)
add %i3, 0, %l6
lduw [%l6], %o5
mov %o5, %l3
! move %l3(lower) -> %o4(lower)
or %l3, %o4, %o4
!---- flushing int results buffer----
mov %o0, %l5
mov %o1, %l5
mov %o2, %l5
mov %o3, %l5
mov %o4, %l5
mov %l4, %o0
cas [%l6], %l3, %o0
! move %o0(lower) -> %o0(upper)
sllx %o0, 32, %o0
add   %l4, 1, %l4

P4725: !_REPLACEMENT [11] (Int)
sethi %hi(0x40), %l3
or %l3, %lo(0x40),  %l3
sethi %hi(0x10000), %l6
or %l6, %lo(0x10000),  %l6
add %i3, %l3, %l3
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]

P4726: !_PREFETCH [12] (Int)
prefetch [%i3 + 0], 1

P4727: !_ST [3] (maybe <- 0x418000da) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i0 + 32 ]

P4728: !_DWLD [4] (FP)
ldd [%i0 + 64], %f2
! 1 addresses covered

P4729: !_REPLACEMENT [7] (Int)
sethi %hi(0x54), %l7
or %l7, %lo(0x54),  %l7
sethi %hi(0x10000), %o5
or %o5, %lo(0x10000),  %o5
add %i3, %l7, %l7
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]

P4730: !_ST [0] (maybe <- 0x418000db) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i0 + 0 ]

P4731: !_REPLACEMENT [14] (Int)
sethi %hi(0x80), %l3
or %l3, %lo(0x80),  %l3
sethi %hi(0x10000), %l6
or %l6, %lo(0x10000),  %l6
add %i3, %l3, %l3
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]

P4732: !_MEMBAR (Int)
membar #StoreLoad

P4733: !_PREFETCH [13] (Int)
prefetch [%i3 + 64], 1

P4734: !_LD [4] (FP)
ld [%i0 + 64], %f3
! 1 addresses covered

P4735: !_REPLACEMENT [15] (Int)
sethi %hi(0xc0), %o5
or %o5, %lo(0xc0),  %o5
sethi %hi(0x10000), %l3
or %l3, %lo(0x10000),  %l3
add %i3, %o5, %o5
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]

P4736: !_DWST [13] (maybe <- 0x418000dc) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
std %f20, [%i3 + 64]

P4737: !_DWST [1] (maybe <- 0x418000dd) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
! 1 th moved, current_fp_src=21 
fmovs  %f16, %f21
fadds  %f16, %f17, %f16
std %f20, [%i0 + 0]

P4738: !_DWST [9] (maybe <- 0x418000df) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
std %f20, [%i1 + 512]

P4739: !_DWLD [3] (FP)
ldd [%i0 + 32], %f4
! 1 addresses covered

P4740: !_CASX [4] (maybe <- 0x2000054) (Int)
add %i0, 64, %l3
ldx [%l3], %l7
! move %l7(upper) -> %o0(lower)
srlx %l7, 32, %o5
or %o5, %o0, %o0
! move %l7(lower) -> %o1(upper)
sllx %l7, 32, %o1
mov  %l7, %o5
sllx %l4, 32, %l7
casx [%l3], %o5, %l7
! move %l7(upper) -> %o1(lower)
srlx %l7, 32, %l3
or %l3, %o1, %o1
! move %l7(lower) -> %o2(upper)
sllx %l7, 32, %o2
add  %l4, 1, %l4

P4741: !_DWLD [4] (FP)
ldd [%i0 + 64], %f18
! 1 addresses covered
fmovs %f18, %f5

P4742: !_LD [0] (FP)
ld [%i0 + 0], %f6
! 1 addresses covered

P4743: !_PREFETCH [6] (Int)
prefetch [%i1 + 80], 1

P4744: !_REPLACEMENT [2] (Int)
sethi %hi(0xc), %o5
or %o5, %lo(0xc),  %o5
sethi %hi(0x10000), %l3
or %l3, %lo(0x10000),  %l3
add %i3, %o5, %o5
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]

P4745: !_LD [2] (FP) (Branch target of P4918)
ld [%i0 + 12], %f7
! 1 addresses covered
ba P4746
nop

TARGET4918:
ba RET4918
nop


P4746: !_REPLACEMENT [4] (Int)
sethi %hi(0x40), %l7
or %l7, %lo(0x40),  %l7
sethi %hi(0x10000), %o5
or %o5, %lo(0x10000),  %o5
add %i3, %l7, %l7
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]

P4747: !_DWLD [4] (FP)
ldd [%i0 + 64], %f8
! 1 addresses covered

P4748: !_DWLD [1] (FP)
ldd [%i0 + 0], %f18
! 2 addresses covered
fmovs %f18, %f9
fmovs %f19, %f10

P4749: !_CASX [7] (maybe <- 0x2000055) (Int) (CBR)
add %i1, 80, %l7
ldx [%l7], %l3
! move %l3(upper) -> %o2(lower)
srlx %l3, 32, %l6
or %l6, %o2, %o2
! move %l3(lower) -> %o3(upper)
sllx %l3, 32, %o3
mov %l3, %l6
sllx %l4, 32, %l3
add  %l4, 1, %l4
or   %l4, %l3, %l3
casx [%l7], %l6, %l3
! move %l3(upper) -> %o3(lower)
srlx %l3, 32, %l7
or %l7, %o3, %o3
! move %l3(lower) -> %o4(upper)
sllx %l3, 32, %o4
add  %l4, 1, %l4

! cbranch
andcc %l0, 1, %g0
be,pn  %xcc, TARGET4749
nop
RET4749:

! lfsr step begin
srlx %l0, 1, %l6
xnor %l6, %l0, %l6
sllx %l6, 63, %l6
or  %l6, %l0, %l0
srlx %l0, 1, %l0


P4750: !_PREFETCH [10] (Int)
prefetch [%i2 + 32], 1

P4751: !_REPLACEMENT [2] (Int)
sethi %hi(0xc), %l7
or %l7, %lo(0xc),  %l7
sethi %hi(0x10000), %o5
or %o5, %lo(0x10000),  %o5
add %i3, %l7, %l7
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]

P4752: !_REPLACEMENT [2] (Int) (CBR)
sethi %hi(0xc), %l6
or %l6, %lo(0xc),  %l6
sethi %hi(0x10000), %l7
or %l7, %lo(0x10000),  %l7
add %i3, %l6, %l6
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]

! cbranch
andcc %l0, 1, %g0
be,pt  %xcc, TARGET4752
nop
RET4752:

! lfsr step begin
srlx %l0, 1, %l3
xnor %l3, %l0, %l3
sllx %l3, 63, %l3
or  %l3, %l0, %l0
srlx %l0, 1, %l0


P4753: !_DWST [5] (maybe <- 0x418000e0) (FP)
! 0 th moved, current_fp_src=21 
fmovs  %f16, %f21
fadds  %f16, %f17, %f16
std %f20, [%i1 + 72]

P4754: !_DWST [7] (maybe <- 0x418000e1) (FP) (Branch target of P4749)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
! 1 th moved, current_fp_src=21 
fmovs  %f16, %f21
fadds  %f16, %f17, %f16
std %f20, [%i1 + 80]
ba P4755
nop

TARGET4749:
ba RET4749
nop


P4755: !_LD [15] (FP)
ld [%i3 + 192], %f11
! 1 addresses covered

P4756: !_DWLD [14] (FP)
ldd [%i3 + 128], %f12
! 1 addresses covered

P4757: !_MEMBAR (Int)
membar #StoreLoad

P4758: !_PREFETCH [1] (Int)
prefetch [%i0 + 4], 1

P4759: !_PREFETCH [14] (Int)
prefetch [%i3 + 128], 1

P4760: !_DWST [12] (maybe <- 0x418000e3) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
std %f20, [%i3 + 0]

P4761: !_DWLD [8] (FP)
ldd [%i1 + 256], %f18
! 1 addresses covered
fmovs %f18, %f13

P4762: !_PREFETCH [15] (Int)
prefetch [%i3 + 192], 1

P4763: !_DWST [1] (maybe <- 0x418000e4) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
! 1 th moved, current_fp_src=21 
fmovs  %f16, %f21
fadds  %f16, %f17, %f16
std %f20, [%i0 + 0]

P4764: !_PREFETCH [11] (Int)
prefetch [%i2 + 64], 1

P4765: !_LD [15] (FP) (Branch target of P4639)
ld [%i3 + 192], %f14
! 1 addresses covered
ba P4766
nop

TARGET4639:
ba RET4639
nop


P4766: !_LD [10] (FP)
ld [%i2 + 32], %f15
! 1 addresses covered
!---- flushing fp results buffer to %f30 ----
fmovd %f0, %f30
fmovd %f2, %f30
fmovd %f4, %f30
fmovd %f6, %f30
fmovd %f8, %f30
fmovd %f10, %f30
fmovd %f12, %f30
fmovd %f14, %f30

P4767: !_REPLACEMENT [0] (Int)
sethi %hi(0x0), %l6
or %l6, %lo(0x0),  %l6
sethi %hi(0x10000), %l7
or %l7, %lo(0x10000),  %l7
add %i3, %l6, %l6
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]

P4768: !_CAS [5] (maybe <- 0x2000057) (Int)
add %i1, 76, %l6
lduw [%l6], %o5
mov %o5, %l3
! move %l3(lower) -> %o4(lower)
or %l3, %o4, %o4
!---- flushing int results buffer----
mov %o0, %l5
mov %o1, %l5
mov %o2, %l5
mov %o3, %l5
mov %o4, %l5
mov %l4, %o0
cas [%l6], %l3, %o0
! move %o0(lower) -> %o0(upper)
sllx %o0, 32, %o0
add   %l4, 1, %l4

P4769: !_PREFETCH [1] (Int)
prefetch [%i0 + 4], 1

P4770: !_DWST [11] (maybe <- 0x418000e6) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
std %f20, [%i2 + 64]

P4771: !_DWST [1] (maybe <- 0x418000e7) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
! 1 th moved, current_fp_src=21 
fmovs  %f16, %f21
fadds  %f16, %f17, %f16
std %f20, [%i0 + 0]

P4772: !_PREFETCH [7] (Int)
prefetch [%i1 + 84], 1

P4773: !_PREFETCH [11] (Int)
prefetch [%i2 + 64], 1

P4774: !_DWLD [1] (FP)
ldd [%i0 + 0], %f0
! 2 addresses covered

P4775: !_REPLACEMENT [2] (Int) (CBR)
sethi %hi(0xc), %l7
or %l7, %lo(0xc),  %l7
sethi %hi(0x10000), %o5
or %o5, %lo(0x10000),  %o5
add %i3, %l7, %l7
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]

! cbranch
andcc %l0, 1, %g0
be,pt  %xcc, TARGET4775
nop
RET4775:

! lfsr step begin
srlx %l0, 1, %l6
xnor %l6, %l0, %l6
sllx %l6, 63, %l6
or  %l6, %l0, %l0
srlx %l0, 1, %l0


P4776: !_ST [9] (maybe <- 0x418000e9) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i1 + 512 ]

P4777: !_CASX [9] (maybe <- 0x2000058) (Int)
add %i1, 512, %l7
ldx [%l7], %l3
! move %l3(upper) -> %o0(lower)
srlx %l3, 32, %l6
or %l6, %o0, %o0
! move %l3(lower) -> %o1(upper)
sllx %l3, 32, %o1
mov  %l3, %l6
sllx %l4, 32, %l3
casx [%l7], %l6, %l3
! move %l3(upper) -> %o1(lower)
srlx %l3, 32, %l7
or %l7, %o1, %o1
! move %l3(lower) -> %o2(upper)
sllx %l3, 32, %o2
add  %l4, 1, %l4

P4778: !_CAS [8] (maybe <- 0x2000059) (Int)
add %i1, 256, %l7
lduw [%l7], %l3
mov %l3, %l6
! move %l6(lower) -> %o2(lower)
or %l6, %o2, %o2
mov %l4, %o3
cas [%l7], %l6, %o3
! move %o3(lower) -> %o3(upper)
sllx %o3, 32, %o3
add   %l4, 1, %l4

P4779: !_ST [7] (maybe <- 0x418000ea) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i1 + 84 ]

P4780: !_DWLD [12] (FP) (Branch target of P4403)
ldd [%i3 + 0], %f2
! 1 addresses covered
ba P4781
nop

TARGET4403:
ba RET4403
nop


P4781: !_SWAP [1] (maybe <- 0x200005a) (Int)
mov %l4, %l7
swap  [%i0 + 4], %l7
! move %l7(lower) -> %o3(lower)
srl %l7, 0, %l3
or %l3, %o3, %o3
add   %l4, 1, %l4

P4782: !_DWST [14] (maybe <- 0x418000eb) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
std %f20, [%i3 + 128]

P4783: !_DWST [2] (maybe <- 0x418000ec) (FP)
! 0 th moved, current_fp_src=21 
fmovs  %f16, %f21
fadds  %f16, %f17, %f16
std %f20, [%i0 + 8]

P4784: !_LD [3] (FP)
ld [%i0 + 32], %f3
! 1 addresses covered

P4785: !_DWST [9] (maybe <- 0x418000ed) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
std %f20, [%i1 + 512]

P4786: !_PREFETCH [13] (Int)
prefetch [%i3 + 64], 1

P4787: !_ST [3] (maybe <- 0x418000ee) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i0 + 32 ]

P4788: !_NOP (Int) (Branch target of P4947)
nop
ba P4789
nop

TARGET4947:
ba RET4947
nop


P4789: !_REPLACEMENT [0] (Int)
sethi %hi(0x0), %o5
or %o5, %lo(0x0),  %o5
sethi %hi(0x10000), %l3
or %l3, %lo(0x10000),  %l3
add %i3, %o5, %o5
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]

P4790: !_LD [14] (FP)
ld [%i3 + 128], %f4
! 1 addresses covered

P4791: !_REPLACEMENT [7] (Int)
sethi %hi(0x54), %l7
or %l7, %lo(0x54),  %l7
sethi %hi(0x10000), %o5
or %o5, %lo(0x10000),  %o5
add %i3, %l7, %l7
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]

P4792: !_ST [3] (maybe <- 0x418000ef) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i0 + 32 ]

P4793: !_PREFETCH [15] (Int)
prefetch [%i3 + 192], 1

P4794: !_DWLD [12] (FP)
ldd [%i3 + 0], %f18
! 1 addresses covered
fmovs %f18, %f5

P4795: !_LD [3] (FP)
ld [%i0 + 32], %f6
! 1 addresses covered

P4796: !_DWST [6] (maybe <- 0x418000f0) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
! 1 th moved, current_fp_src=21 
fmovs  %f16, %f21
fadds  %f16, %f17, %f16
std %f20, [%i1 + 80]

P4797: !_REPLACEMENT [15] (Int)
sethi %hi(0xc0), %o5
or %o5, %lo(0xc0),  %o5
sethi %hi(0x10000), %l3
or %l3, %lo(0x10000),  %l3
add %i3, %o5, %o5
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]

P4798: !_LD [13] (FP)
ld [%i3 + 64], %f7
! 1 addresses covered

P4799: !_CAS [2] (maybe <- 0x200005b) (Int)
add %i0, 12, %o5
lduw [%o5], %o4
mov %o4, %l7
! move %l7(lower) -> %o4(upper)
sllx %l7, 32, %o4
mov %l4, %l6
cas [%o5], %l7, %l6
! move %l6(lower) -> %o4(lower)
srl %l6, 0, %o5
or %o5, %o4, %o4
!---- flushing int results buffer----
mov %o0, %l5
mov %o1, %l5
mov %o2, %l5
mov %o3, %l5
mov %o4, %l5
add   %l4, 1, %l4

P4800: !_REPLACEMENT [4] (Int)
sethi %hi(0x40), %l7
or %l7, %lo(0x40),  %l7
sethi %hi(0x10000), %o5
or %o5, %lo(0x10000),  %o5
add %i3, %l7, %l7
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]

P4801: !_DWLD [9] (FP) (Branch target of P4636)
ldd [%i1 + 512], %f8
! 1 addresses covered
ba P4802
nop

TARGET4636:
ba RET4636
nop


P4802: !_ST [9] (maybe <- 0x418000f2) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i1 + 512 ]

P4803: !_LD [9] (FP)
ld [%i1 + 512], %f9
! 1 addresses covered

P4804: !_LD [10] (FP)
ld [%i2 + 32], %f10
! 1 addresses covered

P4805: !_CASX [11] (maybe <- 0x200005c) (Int)
add %i2, 64, %l6
ldx [%l6], %o0
! move %o0(upper) -> %o0(upper)
! move %o0(lower) -> %o0(lower)
mov  %o0, %l3
sllx %l4, 32, %o1
casx [%l6], %l3, %o1
! move %o1(upper) -> %o1(upper)
! move %o1(lower) -> %o1(lower)
add  %l4, 1, %l4

P4806: !_DWST [12] (maybe <- 0x418000f3) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
std %f20, [%i3 + 0]

P4807: !_DWLD [3] (FP)
ldd [%i0 + 32], %f18
! 1 addresses covered
fmovs %f18, %f11

P4808: !_CAS [12] (maybe <- 0x200005d) (Int)
add %i3, 0, %l3
lduw [%l3], %o2
mov %o2, %o5
! move %o5(lower) -> %o2(upper)
sllx %o5, 32, %o2
mov %l4, %l7
cas [%l3], %o5, %l7
! move %l7(lower) -> %o2(lower)
srl %l7, 0, %l3
or %l3, %o2, %o2
add   %l4, 1, %l4

P4809: !_LD [11] (FP)
ld [%i2 + 64], %f12
! 1 addresses covered

P4810: !_REPLACEMENT [10] (Int)
sethi %hi(0x20), %o5
or %o5, %lo(0x20),  %o5
sethi %hi(0x10000), %l3
or %l3, %lo(0x10000),  %l3
add %i3, %o5, %o5
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]

P4811: !_LD [8] (FP)
ld [%i1 + 256], %f13
! 1 addresses covered

P4812: !_DWST [1] (maybe <- 0x418000f4) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
! 1 th moved, current_fp_src=21 
fmovs  %f16, %f21
fadds  %f16, %f17, %f16
std %f20, [%i0 + 0]

P4813: !_ST [11] (maybe <- 0x418000f6) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i2 + 64 ]

P4814: !_LD [8] (FP)
ld [%i1 + 256], %f14
! 1 addresses covered

P4815: !_ST [15] (maybe <- 0x418000f7) (FP) (Branch target of P4870)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i3 + 192 ]
ba P4816
nop

TARGET4870:
ba RET4870
nop


P4816: !_PREFETCH [2] (Int)
prefetch [%i0 + 12], 1

P4817: !_REPLACEMENT [0] (Int)
sethi %hi(0x0), %o5
or %o5, %lo(0x0),  %o5
sethi %hi(0x10000), %l3
or %l3, %lo(0x10000),  %l3
add %i3, %o5, %o5
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]

P4818: !_LD [15] (FP)
ld [%i3 + 192], %f15
! 1 addresses covered
!---- flushing fp results buffer to %f30 ----
fmovd %f0, %f30
fmovd %f2, %f30
fmovd %f4, %f30
fmovd %f6, %f30
fmovd %f8, %f30
fmovd %f10, %f30
fmovd %f12, %f30
fmovd %f14, %f30

P4819: !_DWLD [1] (FP)
ldd [%i0 + 0], %f0
! 2 addresses covered

P4820: !_SWAP [1] (maybe <- 0x200005e) (Int)
mov %l4, %o3
swap  [%i0 + 4], %o3
! move %o3(lower) -> %o3(upper)
sllx %o3, 32, %o3
add   %l4, 1, %l4

P4821: !_PREFETCH [12] (Int)
prefetch [%i3 + 0], 1

P4822: !_REPLACEMENT [8] (Int)
sethi %hi(0x100), %l6
or %l6, %lo(0x100),  %l6
sethi %hi(0x10000), %l7
or %l7, %lo(0x10000),  %l7
add %i3, %l6, %l6
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]

P4823: !_ST [4] (maybe <- 0x418000f8) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i0 + 64 ]

P4824: !_REPLACEMENT [5] (Int)
sethi %hi(0x4c), %o5
or %o5, %lo(0x4c),  %o5
sethi %hi(0x10000), %l3
or %l3, %lo(0x10000),  %l3
add %i3, %o5, %o5
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]

P4825: !_DWST [8] (maybe <- 0x418000f9) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
std %f20, [%i1 + 256]

P4826: !_LD [5] (FP)
ld [%i1 + 76], %f2
! 1 addresses covered

P4827: !_LD [12] (FP) (CBR)
ld [%i3 + 0], %f3
! 1 addresses covered

! cbranch
andcc %l0, 1, %g0
be,pn  %xcc, TARGET4827
nop
RET4827:

! lfsr step begin
srlx %l0, 1, %l6
xnor %l6, %l0, %l6
sllx %l6, 63, %l6
or  %l6, %l0, %l0
srlx %l0, 1, %l0


P4828: !_ST [10] (maybe <- 0x418000fa) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i2 + 32 ]

P4829: !_DWLD [9] (FP)
ldd [%i1 + 512], %f4
! 1 addresses covered

P4830: !_ST [5] (maybe <- 0x418000fb) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i1 + 76 ]

P4831: !_LD [7] (FP)
ld [%i1 + 84], %f5
! 1 addresses covered

P4832: !_LD [5] (FP)
ld [%i1 + 76], %f6
! 1 addresses covered

P4833: !_ST [0] (maybe <- 0x418000fc) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i0 + 0 ]

P4834: !_DWLD [13] (FP)
ldd [%i3 + 64], %f18
! 1 addresses covered
fmovs %f18, %f7

P4835: !_PREFETCH [3] (Int)
prefetch [%i0 + 32], 1

P4836: !_DWST [4] (maybe <- 0x418000fd) (FP) (CBR)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
std %f20, [%i0 + 64]

! cbranch
andcc %l0, 1, %g0
be,pt  %xcc, TARGET4836
nop
RET4836:

! lfsr step begin
srlx %l0, 1, %l7
xnor %l7, %l0, %l7
sllx %l7, 63, %l7
or  %l7, %l0, %l0
srlx %l0, 1, %l0


P4837: !_CAS [3] (maybe <- 0x200005f) (Int)
add %i0, 32, %l3
lduw [%l3], %l7
mov %l7, %o5
! move %o5(lower) -> %o3(lower)
or %o5, %o3, %o3
mov %l4, %o4
cas [%l3], %o5, %o4
! move %o4(lower) -> %o4(upper)
sllx %o4, 32, %o4
add   %l4, 1, %l4

P4838: !_DWLD [11] (FP)
ldd [%i2 + 64], %f8
! 1 addresses covered

P4839: !_DWST [13] (maybe <- 0x418000fe) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
std %f20, [%i3 + 64]

P4840: !_DWLD [9] (FP)
ldd [%i1 + 512], %f18
! 1 addresses covered
fmovs %f18, %f9

P4841: !_LD [6] (FP)
ld [%i1 + 80], %f10
! 1 addresses covered

P4842: !_ST [2] (maybe <- 0x418000ff) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i0 + 12 ]

P4843: !_LD [12] (FP)
ld [%i3 + 0], %f11
! 1 addresses covered

P4844: !_DWLD [1] (FP)
ldd [%i0 + 0], %f12
! 2 addresses covered

P4845: !_DWLD [15] (FP)
ldd [%i3 + 192], %f14
! 1 addresses covered

P4846: !_PREFETCH [5] (Int) (CBR)
prefetch [%i1 + 76], 1

! cbranch
andcc %l0, 1, %g0
be,pn  %xcc, TARGET4846
nop
RET4846:

! lfsr step begin
srlx %l0, 1, %l6
xnor %l6, %l0, %l6
sllx %l6, 63, %l6
or  %l6, %l0, %l0
srlx %l0, 1, %l0


P4847: !_PREFETCH [15] (Int) (Branch target of P4216)
prefetch [%i3 + 192], 1
ba P4848
nop

TARGET4216:
ba RET4216
nop


P4848: !_DWLD [10] (FP)
ldd [%i2 + 32], %f18
! 1 addresses covered
fmovs %f18, %f15
!---- flushing fp results buffer to %f30 ----
fmovd %f0, %f30
fmovd %f2, %f30
fmovd %f4, %f30
fmovd %f6, %f30
fmovd %f8, %f30
fmovd %f10, %f30
fmovd %f12, %f30
fmovd %f14, %f30

P4849: !_ST [5] (maybe <- 0x41800100) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i1 + 76 ]

P4850: !_DWLD [4] (FP)
ldd [%i0 + 64], %f0
! 1 addresses covered

P4851: !_REPLACEMENT [12] (Int)
sethi %hi(0x0), %l6
or %l6, %lo(0x0),  %l6
sethi %hi(0x10000), %l7
or %l7, %lo(0x10000),  %l7
add %i3, %l6, %l6
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]

P4852: !_REPLACEMENT [5] (Int)
sethi %hi(0x4c), %l3
or %l3, %lo(0x4c),  %l3
sethi %hi(0x10000), %l6
or %l6, %lo(0x10000),  %l6
add %i3, %l3, %l3
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]

P4853: !_REPLACEMENT [8] (Int)
sethi %hi(0x100), %o5
or %o5, %lo(0x100),  %o5
sethi %hi(0x10000), %l3
or %l3, %lo(0x10000),  %l3
add %i3, %o5, %o5
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]

P4854: !_REPLACEMENT [10] (Int)
sethi %hi(0x20), %l7
or %l7, %lo(0x20),  %l7
sethi %hi(0x10000), %o5
or %o5, %lo(0x10000),  %o5
add %i3, %l7, %l7
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]

P4855: !_LD [15] (FP)
ld [%i3 + 192], %f1
! 1 addresses covered

P4856: !_LD [8] (FP)
ld [%i1 + 256], %f2
! 1 addresses covered

P4857: !_CASX [0] (maybe <- 0x2000060) (Int)
add %i0, 0, %l7
ldx [%l7], %l3
! move %l3(upper) -> %o4(lower)
srlx %l3, 32, %l6
or %l6, %o4, %o4
!---- flushing int results buffer----
mov %o0, %l5
mov %o1, %l5
mov %o2, %l5
mov %o3, %l5
mov %o4, %l5
! move %l3(lower) -> %o0(upper)
sllx %l3, 32, %o0
mov %l3, %l6
sllx %l4, 32, %l3
add  %l4, 1, %l4
or   %l4, %l3, %l3
casx [%l7], %l6, %l3
! move %l3(upper) -> %o0(lower)
srlx %l3, 32, %l7
or %l7, %o0, %o0
! move %l3(lower) -> %o1(upper)
sllx %l3, 32, %o1
add  %l4, 1, %l4

P4858: !_DWLD [11] (FP)
ldd [%i2 + 64], %f18
! 1 addresses covered
fmovs %f18, %f3

P4859: !_PREFETCH [11] (Int)
prefetch [%i2 + 64], 1

P4860: !_ST [13] (maybe <- 0x41800101) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i3 + 64 ]

P4861: !_CASX [2] (maybe <- 0x2000062) (Int)
add %i0, 8, %l6
ldx [%l6], %o5
! move %o5(upper) -> %o1(lower)
srlx %o5, 32, %l3
or %l3, %o1, %o1
! move %o5(lower) -> %o2(upper)
sllx %o5, 32, %o2
mov  %o5, %l3
mov %l4, %o5
casx [%l6], %l3, %o5
! move %o5(upper) -> %o2(lower)
srlx %o5, 32, %l6
or %l6, %o2, %o2
! move %o5(lower) -> %o3(upper)
sllx %o5, 32, %o3
add  %l4, 1, %l4

P4862: !_DWST [0] (maybe <- 0x41800102) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
! 1 th moved, current_fp_src=21 
fmovs  %f16, %f21
fadds  %f16, %f17, %f16
std %f20, [%i0 + 0]

P4863: !_ST [1] (maybe <- 0x41800104) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i0 + 4 ]

P4864: !_LD [2] (FP)
ld [%i0 + 12], %f4
! 1 addresses covered

P4865: !_DWLD [15] (FP)
ldd [%i3 + 192], %f18
! 1 addresses covered
fmovs %f18, %f5

P4866: !_DWST [13] (maybe <- 0x41800105) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
std %f20, [%i3 + 64]

P4867: !_SWAP [7] (maybe <- 0x2000063) (Int)
mov %l4, %o5
swap  [%i1 + 84], %o5
! move %o5(lower) -> %o3(lower)
srl %o5, 0, %l6
or %l6, %o3, %o3
add   %l4, 1, %l4

P4868: !_DWLD [13] (FP)
ldd [%i3 + 64], %f6
! 1 addresses covered

P4869: !_SWAP [12] (maybe <- 0x2000064) (Int)
mov %l4, %o4
swap  [%i3 + 0], %o4
! move %o4(lower) -> %o4(upper)
sllx %o4, 32, %o4
add   %l4, 1, %l4

P4870: !_REPLACEMENT [15] (Int) (CBR)
sethi %hi(0xc0), %o5
or %o5, %lo(0xc0),  %o5
sethi %hi(0x10000), %l3
or %l3, %lo(0x10000),  %l3
add %i3, %o5, %o5
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]

! cbranch
andcc %l0, 1, %g0
be,pt  %xcc, TARGET4870
nop
RET4870:

! lfsr step begin
srlx %l0, 1, %l7
xnor %l7, %l0, %l7
sllx %l7, 63, %l7
or  %l7, %l0, %l0
srlx %l0, 1, %l0


P4871: !_DWLD [14] (FP) (Branch target of P4687)
ldd [%i3 + 128], %f18
! 1 addresses covered
fmovs %f18, %f7
ba P4872
nop

TARGET4687:
ba RET4687
nop


P4872: !_LD [1] (FP)
ld [%i0 + 4], %f8
! 1 addresses covered

P4873: !_ST [13] (maybe <- 0x41800106) (FP) (Branch target of P4836)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i3 + 64 ]
ba P4874
nop

TARGET4836:
ba RET4836
nop


P4874: !_LD [6] (FP)
ld [%i1 + 80], %f9
! 1 addresses covered

P4875: !_SWAP [13] (maybe <- 0x2000065) (Int)
mov %l4, %l3
swap  [%i3 + 64], %l3
! move %l3(lower) -> %o4(lower)
srl %l3, 0, %l7
or %l7, %o4, %o4
!---- flushing int results buffer----
mov %o0, %l5
mov %o1, %l5
mov %o2, %l5
mov %o3, %l5
mov %o4, %l5
add   %l4, 1, %l4

P4876: !_DWLD [15] (FP)
ldd [%i3 + 192], %f10
! 1 addresses covered

P4877: !_ST [7] (maybe <- 0x41800107) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i1 + 84 ]

P4878: !_DWST [0] (maybe <- 0x41800108) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
! 1 th moved, current_fp_src=21 
fmovs  %f16, %f21
fadds  %f16, %f17, %f16
std %f20, [%i0 + 0]

P4879: !_DWLD [4] (FP)
ldd [%i0 + 64], %f18
! 1 addresses covered
fmovs %f18, %f11

P4880: !_ST [0] (maybe <- 0x4180010a) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i0 + 0 ]

P4881: !_REPLACEMENT [11] (Int)
sethi %hi(0x40), %l7
or %l7, %lo(0x40),  %l7
sethi %hi(0x10000), %o5
or %o5, %lo(0x10000),  %o5
add %i3, %l7, %l7
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]

P4882: !_CASX [8] (maybe <- 0x2000066) (Int)
add %i1, 256, %l7
ldx [%l7], %o0
! move %o0(upper) -> %o0(upper)
! move %o0(lower) -> %o0(lower)
mov  %o0, %l6
sllx %l4, 32, %o1
casx [%l7], %l6, %o1
! move %o1(upper) -> %o1(upper)
! move %o1(lower) -> %o1(lower)
add  %l4, 1, %l4

P4883: !_PREFETCH [9] (Int)
prefetch [%i1 + 512], 1

P4884: !_PREFETCH [14] (Int)
prefetch [%i3 + 128], 1

P4885: !_CAS [12] (maybe <- 0x2000067) (Int)
add %i3, 0, %l7
lduw [%l7], %o2
mov %o2, %l6
! move %l6(lower) -> %o2(upper)
sllx %l6, 32, %o2
mov %l4, %l3
cas [%l7], %l6, %l3
! move %l3(lower) -> %o2(lower)
srl %l3, 0, %l7
or %l7, %o2, %o2
add   %l4, 1, %l4

P4886: !_CAS [14] (maybe <- 0x2000068) (Int) (LE)
! Change single-word-level endianess (big endian <-> little endian) 
sethi %hi(0xff00ff00), %l7
or %l7, %lo(0xff00ff00), %l7
and %l4, %l7, %l6
srl %l6, 8, %l6
sll %l4, 8, %o5
and %o5, %l7, %o5
or %o5, %l6, %o5
srl %o5, 16, %l6
sll %o5, 16, %o5
srl %o5, 0, %o5
or %o5, %l6, %o5
wr %g0, 0x88, %asi
add %i3, 128, %l7
lduwa [%l7] %asi, %o3
mov %o3, %l6
! move %l6(lower) -> %o3(upper)
sllx %l6, 32, %o3
mov %o5, %l3
casa [%l7] %asi, %l6, %l3
! move %l3(lower) -> %o3(lower)
srl %l3, 0, %l7
or %l7, %o3, %o3
add   %l4, 1, %l4

P4887: !_REPLACEMENT [8] (Int)
sethi %hi(0x100), %l6
or %l6, %lo(0x100),  %l6
sethi %hi(0x10000), %l7
or %l7, %lo(0x10000),  %l7
add %i3, %l6, %l6
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]

P4888: !_SWAP [7] (maybe <- 0x2000069) (Int)
mov %l4, %o4
swap  [%i1 + 84], %o4
! move %o4(lower) -> %o4(upper)
sllx %o4, 32, %o4
add   %l4, 1, %l4

P4889: !_CAS [7] (maybe <- 0x200006a) (Int)
add %i1, 84, %l3
lduw [%l3], %l7
mov %l7, %o5
! move %o5(lower) -> %o4(lower)
or %o5, %o4, %o4
!---- flushing int results buffer----
mov %o0, %l5
mov %o1, %l5
mov %o2, %l5
mov %o3, %l5
mov %o4, %l5
mov %l4, %o0
cas [%l3], %o5, %o0
! move %o0(lower) -> %o0(upper)
sllx %o0, 32, %o0
add   %l4, 1, %l4

P4890: !_CAS [1] (maybe <- 0x200006b) (Int)
add %i0, 4, %l3
lduw [%l3], %l7
mov %l7, %o5
! move %o5(lower) -> %o0(lower)
or %o5, %o0, %o0
mov %l4, %o1
cas [%l3], %o5, %o1
! move %o1(lower) -> %o1(upper)
sllx %o1, 32, %o1
add   %l4, 1, %l4

P4891: !_SWAP [0] (maybe <- 0x200006c) (Int)
mov %l4, %l6
swap  [%i0 + 0], %l6
! move %l6(lower) -> %o1(lower)
srl %l6, 0, %o5
or %o5, %o1, %o1
add   %l4, 1, %l4

P4892: !_ST [1] (maybe <- 0x4180010b) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i0 + 4 ]

P4893: !_PREFETCH [3] (Int)
prefetch [%i0 + 32], 1

P4894: !_DWST [14] (maybe <- 0x4180010c) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
std %f20, [%i3 + 128]

P4895: !_DWLD [7] (FP)
ldd [%i1 + 80], %f12
! 2 addresses covered

P4896: !_REPLACEMENT [0] (Int)
sethi %hi(0x0), %l3
or %l3, %lo(0x0),  %l3
sethi %hi(0x10000), %l6
or %l6, %lo(0x10000),  %l6
add %i3, %l3, %l3
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]

P4897: !_PREFETCH [0] (Int)
prefetch [%i0 + 0], 1

P4898: !_DWST [5] (maybe <- 0x4180010d) (FP)
! 0 th moved, current_fp_src=21 
fmovs  %f16, %f21
fadds  %f16, %f17, %f16
std %f20, [%i1 + 72]

P4899: !_LD [15] (FP)
ld [%i3 + 192], %f14
! 1 addresses covered

P4900: !_LD [12] (FP)
ld [%i3 + 0], %f15
! 1 addresses covered
!---- flushing fp results buffer to %f30 ----
fmovd %f0, %f30
fmovd %f2, %f30
fmovd %f4, %f30
fmovd %f6, %f30
fmovd %f8, %f30
fmovd %f10, %f30
fmovd %f12, %f30
fmovd %f14, %f30

P4901: !_DWLD [1] (FP)
ldd [%i0 + 0], %f0
! 2 addresses covered

P4902: !_DWST [4] (maybe <- 0x4180010e) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
std %f20, [%i0 + 64]

P4903: !_DWLD [2] (FP)
ldd [%i0 + 8], %f2
! 1 addresses covered
fmovs %f3, %f2

P4904: !_LD [8] (FP)
ld [%i1 + 256], %f3
! 1 addresses covered

P4905: !_REPLACEMENT [0] (Int)
sethi %hi(0x0), %l6
or %l6, %lo(0x0),  %l6
sethi %hi(0x10000), %l7
or %l7, %lo(0x10000),  %l7
add %i3, %l6, %l6
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]

P4906: !_MEMBAR (Int)
membar #StoreLoad

P4907: !_REPLACEMENT [2] (Int)
sethi %hi(0xc), %l3
or %l3, %lo(0xc),  %l3
sethi %hi(0x10000), %l6
or %l6, %lo(0x10000),  %l6
add %i3, %l3, %l3
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]

P4908: !_MEMBAR (Int)
membar #StoreLoad

P4909: !_SWAP [15] (maybe <- 0x200006d) (Int)
mov %l4, %o2
swap  [%i3 + 192], %o2
! move %o2(lower) -> %o2(upper)
sllx %o2, 32, %o2
add   %l4, 1, %l4

P4910: !_DWLD [2] (FP)
ldd [%i0 + 8], %f4
! 1 addresses covered
fmovs %f5, %f4

P4911: !_REPLACEMENT [7] (Int)
sethi %hi(0x54), %l7
or %l7, %lo(0x54),  %l7
sethi %hi(0x10000), %o5
or %o5, %lo(0x10000),  %o5
add %i3, %l7, %l7
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]

P4912: !_DWST [8] (maybe <- 0x4180010f) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
std %f20, [%i1 + 256]

P4913: !_PREFETCH [4] (Int) (LE)
wr %g0, 0x88, %asi
prefetcha [%i0 + 64] %asi, 1

P4914: !_PREFETCH [4] (Int)
prefetch [%i0 + 64], 1

P4915: !_LD [15] (FP)
ld [%i3 + 192], %f5
! 1 addresses covered

P4916: !_DWLD [11] (FP)
ldd [%i2 + 64], %f6
! 1 addresses covered

P4917: !_DWST [2] (maybe <- 0x41800110) (FP)
! 0 th moved, current_fp_src=21 
fmovs  %f16, %f21
fadds  %f16, %f17, %f16
std %f20, [%i0 + 8]

P4918: !_ST [14] (maybe <- 0x41800111) (FP) (CBR)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i3 + 128 ]

! cbranch
andcc %l0, 1, %g0
be,pn  %xcc, TARGET4918
nop
RET4918:

! lfsr step begin
srlx %l0, 1, %l7
xnor %l7, %l0, %l7
sllx %l7, 63, %l7
or  %l7, %l0, %l0
srlx %l0, 1, %l0


P4919: !_PREFETCH [13] (Int)
prefetch [%i3 + 64], 1

P4920: !_REPLACEMENT [14] (Int)
sethi %hi(0x80), %o5
or %o5, %lo(0x80),  %o5
sethi %hi(0x10000), %l3
or %l3, %lo(0x10000),  %l3
add %i3, %o5, %o5
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]

P4921: !_SWAP [9] (maybe <- 0x200006e) (Int)
mov %l4, %l3
swap  [%i1 + 512], %l3
! move %l3(lower) -> %o2(lower)
srl %l3, 0, %l7
or %l7, %o2, %o2
add   %l4, 1, %l4

P4922: !_PREFETCH [14] (Int)
prefetch [%i3 + 128], 1

P4923: !_DWST [12] (maybe <- 0x41800112) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
std %f20, [%i3 + 0]

P4924: !_ST [5] (maybe <- 0x41800113) (FP) (Branch target of P4250)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i1 + 76 ]
ba P4925
nop

TARGET4250:
ba RET4250
nop


P4925: !_SWAP [9] (maybe <- 0x200006f) (Int)
mov %l4, %o3
swap  [%i1 + 512], %o3
! move %o3(lower) -> %o3(upper)
sllx %o3, 32, %o3
add   %l4, 1, %l4

P4926: !_PREFETCH [4] (Int)
prefetch [%i0 + 64], 1

P4927: !_ST [3] (maybe <- 0x41800114) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i0 + 32 ]

P4928: !_REPLACEMENT [15] (Int)
sethi %hi(0xc0), %l6
or %l6, %lo(0xc0),  %l6
sethi %hi(0x10000), %l7
or %l7, %lo(0x10000),  %l7
add %i3, %l6, %l6
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]

P4929: !_DWST [5] (maybe <- 0x41800115) (FP)
! 0 th moved, current_fp_src=21 
fmovs  %f16, %f21
fadds  %f16, %f17, %f16
std %f20, [%i1 + 72]

P4930: !_DWST [7] (maybe <- 0x41800116) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
! 1 th moved, current_fp_src=21 
fmovs  %f16, %f21
fadds  %f16, %f17, %f16
std %f20, [%i1 + 80]

P4931: !_DWLD [14] (FP)
ldd [%i3 + 128], %f18
! 1 addresses covered
fmovs %f18, %f7

P4932: !_CASX [2] (maybe <- 0x2000070) (Int)
add %i0, 8, %o5
ldx [%o5], %l6
! move %l6(upper) -> %o3(lower)
srlx %l6, 32, %l7
or %l7, %o3, %o3
! move %l6(lower) -> %o4(upper)
sllx %l6, 32, %o4
mov  %l6, %l7
mov %l4, %l6
casx [%o5], %l7, %l6
! move %l6(upper) -> %o4(lower)
srlx %l6, 32, %o5
or %o5, %o4, %o4
!---- flushing int results buffer----
mov %o0, %l5
mov %o1, %l5
mov %o2, %l5
mov %o3, %l5
mov %o4, %l5
! move %l6(lower) -> %o0(upper)
sllx %l6, 32, %o0
add  %l4, 1, %l4

P4933: !_DWST [3] (maybe <- 0x41800118) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
std %f20, [%i0 + 32]

P4934: !_DWST [0] (maybe <- 0x41800119) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
! 1 th moved, current_fp_src=21 
fmovs  %f16, %f21
fadds  %f16, %f17, %f16
std %f20, [%i0 + 0]

P4935: !_DWLD [3] (FP)
ldd [%i0 + 32], %f8
! 1 addresses covered

P4936: !_ST [2] (maybe <- 0x4180011b) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i0 + 12 ]

P4937: !_CASX [11] (maybe <- 0x2000071) (Int)
add %i2, 64, %l3
ldx [%l3], %l7
! move %l7(upper) -> %o0(lower)
srlx %l7, 32, %o5
or %o5, %o0, %o0
! move %l7(lower) -> %o1(upper)
sllx %l7, 32, %o1
mov  %l7, %o5
sllx %l4, 32, %l7
casx [%l3], %o5, %l7
! move %l7(upper) -> %o1(lower)
srlx %l7, 32, %l3
or %l3, %o1, %o1
! move %l7(lower) -> %o2(upper)
sllx %l7, 32, %o2
add  %l4, 1, %l4

P4938: !_DWST [9] (maybe <- 0x4180011c) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
std %f20, [%i1 + 512]

P4939: !_DWLD [11] (FP)
ldd [%i2 + 64], %f18
! 1 addresses covered
fmovs %f18, %f9

P4940: !_REPLACEMENT [0] (Int) (CBR)
sethi %hi(0x0), %l7
or %l7, %lo(0x0),  %l7
sethi %hi(0x10000), %o5
or %o5, %lo(0x10000),  %o5
add %i3, %l7, %l7
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]

! cbranch
andcc %l0, 1, %g0
be,pt  %xcc, TARGET4940
nop
RET4940:

! lfsr step begin
srlx %l0, 1, %l6
xnor %l6, %l0, %l6
sllx %l6, 63, %l6
or  %l6, %l0, %l0
srlx %l0, 1, %l0


P4941: !_DWLD [15] (FP)
ldd [%i3 + 192], %f10
! 1 addresses covered

P4942: !_DWLD [10] (FP) (CBR)
ldd [%i2 + 32], %f18
! 1 addresses covered
fmovs %f18, %f11

! cbranch
andcc %l0, 1, %g0
be,pt  %xcc, TARGET4942
nop
RET4942:

! lfsr step begin
srlx %l0, 1, %l7
xnor %l7, %l0, %l7
sllx %l7, 63, %l7
or  %l7, %l0, %l0
srlx %l0, 1, %l0


P4943: !_LD [14] (FP)
ld [%i3 + 128], %f12
! 1 addresses covered

P4944: !_PREFETCH [12] (Int)
prefetch [%i3 + 0], 1

P4945: !_PREFETCH [3] (Int)
prefetch [%i0 + 32], 1

P4946: !_PREFETCH [6] (Int)
prefetch [%i1 + 80], 1

P4947: !_DWLD [14] (FP) (CBR)
ldd [%i3 + 128], %f18
! 1 addresses covered
fmovs %f18, %f13

! cbranch
andcc %l0, 1, %g0
be,pn  %xcc, TARGET4947
nop
RET4947:

! lfsr step begin
srlx %l0, 1, %o5
xnor %o5, %l0, %o5
sllx %o5, 63, %o5
or  %o5, %l0, %l0
srlx %l0, 1, %l0


P4948: !_DWST [10] (maybe <- 0x4180011d) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
std %f20, [%i2 + 32]

P4949: !_LD [2] (FP)
ld [%i0 + 12], %f14
! 1 addresses covered

P4950: !_PREFETCH [9] (Int)
prefetch [%i1 + 512], 1

P4951: !_REPLACEMENT [3] (Int)
sethi %hi(0x20), %o5
or %o5, %lo(0x20),  %o5
sethi %hi(0x10000), %l3
or %l3, %lo(0x10000),  %l3
add %i3, %o5, %o5
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]

P4952: !_PREFETCH [13] (Int) (LE)
wr %g0, 0x88, %asi
prefetcha [%i3 + 64] %asi, 1

P4953: !_REPLACEMENT [3] (Int)
sethi %hi(0x20), %l7
or %l7, %lo(0x20),  %l7
sethi %hi(0x10000), %o5
or %o5, %lo(0x10000),  %o5
add %i3, %l7, %l7
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]

P4954: !_ST [15] (maybe <- 0x4180011e) (FP) (CBR)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i3 + 192 ]

! cbranch
andcc %l0, 1, %g0
be,pt  %xcc, TARGET4954
nop
RET4954:

! lfsr step begin
srlx %l0, 1, %l3
xnor %l3, %l0, %l3
sllx %l3, 63, %l3
or  %l3, %l0, %l0
srlx %l0, 1, %l0


P4955: !_ST [3] (maybe <- 0x4180011f) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i0 + 32 ]

P4956: !_PREFETCH [15] (Int)
prefetch [%i3 + 192], 1

P4957: !_DWST [8] (maybe <- 0x41800120) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
std %f20, [%i1 + 256]

P4958: !_LD [14] (FP)
ld [%i3 + 128], %f15
! 1 addresses covered
!---- flushing fp results buffer to %f30 ----
fmovd %f0, %f30
fmovd %f2, %f30
fmovd %f4, %f30
fmovd %f6, %f30
fmovd %f8, %f30
fmovd %f10, %f30
fmovd %f12, %f30
fmovd %f14, %f30

P4959: !_LD [9] (FP)
ld [%i1 + 512], %f0
! 1 addresses covered

P4960: !_LD [1] (FP)
ld [%i0 + 4], %f1
! 1 addresses covered

P4961: !_PREFETCH [2] (Int) (Branch target of P4619)
prefetch [%i0 + 12], 1
ba P4962
nop

TARGET4619:
ba RET4619
nop


P4962: !_DWST [2] (maybe <- 0x41800121) (FP)
! 0 th moved, current_fp_src=21 
fmovs  %f16, %f21
fadds  %f16, %f17, %f16
std %f20, [%i0 + 8]

P4963: !_SWAP [8] (maybe <- 0x2000072) (Int) (Branch target of P4248)
mov %l4, %l3
swap  [%i1 + 256], %l3
! move %l3(lower) -> %o2(lower)
srl %l3, 0, %l7
or %l7, %o2, %o2
add   %l4, 1, %l4
ba P4964
nop

TARGET4248:
ba RET4248
nop


P4964: !_LD [13] (FP)
ld [%i3 + 64], %f2
! 1 addresses covered

P4965: !_DWLD [9] (FP)
ldd [%i1 + 512], %f18
! 1 addresses covered
fmovs %f18, %f3

P4966: !_LD [6] (FP)
ld [%i1 + 80], %f4
! 1 addresses covered

P4967: !_DWLD [0] (FP)
ldd [%i0 + 0], %f18
! 2 addresses covered
fmovs %f18, %f5
fmovs %f19, %f6

P4968: !_MEMBAR (Int)
membar #StoreLoad

P4969: !_DWLD [1] (FP)
ldd [%i0 + 0], %f18
! 2 addresses covered
fmovs %f18, %f7
fmovs %f19, %f8

P4970: !_ST [1] (maybe <- 0x41800122) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i0 + 4 ]

P4971: !_ST [6] (maybe <- 0x41800123) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i1 + 80 ]

P4972: !_PREFETCH [3] (Int)
prefetch [%i0 + 32], 1

P4973: !_PREFETCH [3] (Int)
prefetch [%i0 + 32], 1

P4974: !_REPLACEMENT [5] (Int)
sethi %hi(0x4c), %o5
or %o5, %lo(0x4c),  %o5
sethi %hi(0x10000), %l3
or %l3, %lo(0x10000),  %l3
add %i3, %o5, %o5
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]

P4975: !_SWAP [9] (maybe <- 0x2000073) (Int)
mov %l4, %o3
swap  [%i1 + 512], %o3
! move %o3(lower) -> %o3(upper)
sllx %o3, 32, %o3
add   %l4, 1, %l4

P4976: !_MEMBAR (Int)
membar #StoreLoad

P4977: !_DWLD [8] (FP)
ldd [%i1 + 256], %f18
! 1 addresses covered
fmovs %f18, %f9

P4978: !_ST [2] (maybe <- 0x41800124) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i0 + 12 ]

P4979: !_DWST [8] (maybe <- 0x41800125) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
std %f20, [%i1 + 256]

P4980: !_ST [14] (maybe <- 0x41800126) (FP) (Branch target of P4516)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i3 + 128 ]
ba P4981
nop

TARGET4516:
ba RET4516
nop


P4981: !_REPLACEMENT [3] (Int)
sethi %hi(0x20), %l7
or %l7, %lo(0x20),  %l7
sethi %hi(0x10000), %o5
or %o5, %lo(0x10000),  %o5
add %i3, %l7, %l7
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]

P4982: !_DWLD [11] (FP)
ldd [%i2 + 64], %f10
! 1 addresses covered

P4983: !_PREFETCH [12] (Int)
prefetch [%i3 + 0], 1

P4984: !_ST [6] (maybe <- 0x41800127) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i1 + 80 ]

P4985: !_ST [2] (maybe <- 0x41800128) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i0 + 12 ]

P4986: !_SWAP [12] (maybe <- 0x2000074) (Int)
mov %l4, %l6
swap  [%i3 + 0], %l6
! move %l6(lower) -> %o3(lower)
srl %l6, 0, %o5
or %o5, %o3, %o3
add   %l4, 1, %l4

P4987: !_LD [6] (FP)
ld [%i1 + 80], %f11
! 1 addresses covered

P4988: !_CAS [8] (maybe <- 0x2000075) (Int) (LE) (Branch target of P4338)
! Change single-word-level endianess (big endian <-> little endian) 
sethi %hi(0xff00ff00), %o5
or %o5, %lo(0xff00ff00), %o5
and %l4, %o5, %l7
srl %l7, 8, %l7
sll %l4, 8, %l3
and %l3, %o5, %l3
or %l3, %l7, %l3
srl %l3, 16, %l7
sll %l3, 16, %l3
srl %l3, 0, %l3
or %l3, %l7, %l3
wr %g0, 0x88, %asi
add %i1, 256, %o5
lduwa [%o5] %asi, %o4
mov %o4, %l7
! move %l7(lower) -> %o4(upper)
sllx %l7, 32, %o4
mov %l3, %l6
casa [%o5] %asi, %l7, %l6
! move %l6(lower) -> %o4(lower)
srl %l6, 0, %o5
or %o5, %o4, %o4
!---- flushing int results buffer----
mov %o0, %l5
mov %o1, %l5
mov %o2, %l5
mov %o3, %l5
mov %o4, %l5
add   %l4, 1, %l4
ba P4989
nop

TARGET4338:
ba RET4338
nop


P4989: !_REPLACEMENT [9] (Int) (Branch target of P4775)
sethi %hi(0x200), %l7
or %l7, %lo(0x200),  %l7
sethi %hi(0x10000), %o5
or %o5, %lo(0x10000),  %o5
add %i3, %l7, %l7
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]
ba P4990
nop

TARGET4775:
ba RET4775
nop


P4990: !_REPLACEMENT [14] (Int) (Branch target of P4540)
sethi %hi(0x80), %l6
or %l6, %lo(0x80),  %l6
sethi %hi(0x10000), %l7
or %l7, %lo(0x10000),  %l7
add %i3, %l6, %l6
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
ba P4991
nop

TARGET4540:
ba RET4540
nop


P4991: !_NOP (Int)
nop

P4992: !_CASX [9] (maybe <- 0x2000076) (Int)
add %i1, 512, %l6
ldx [%l6], %o0
! move %o0(upper) -> %o0(upper)
! move %o0(lower) -> %o0(lower)
mov  %o0, %l3
sllx %l4, 32, %o1
casx [%l6], %l3, %o1
! move %o1(upper) -> %o1(upper)
! move %o1(lower) -> %o1(lower)
add  %l4, 1, %l4

P4993: !_PREFETCH [14] (Int)
prefetch [%i3 + 128], 1

P4994: !_REPLACEMENT [13] (Int)
sethi %hi(0x40), %l3
or %l3, %lo(0x40),  %l3
sethi %hi(0x10000), %l6
or %l6, %lo(0x10000),  %l6
add %i3, %l3, %l3
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]

P4995: !_DWLD [6] (FP) (CBR)
ldd [%i1 + 80], %f12
! 2 addresses covered

! cbranch
andcc %l0, 1, %g0
be,pn  %xcc, TARGET4995
nop
RET4995:

! lfsr step begin
srlx %l0, 1, %o5
xnor %o5, %l0, %o5
sllx %o5, 63, %o5
or  %o5, %l0, %l0
srlx %l0, 1, %l0


P4996: !_DWLD [15] (FP)
ldd [%i3 + 192], %f14
! 1 addresses covered

P4997: !_REPLACEMENT [3] (Int)
sethi %hi(0x20), %l3
or %l3, %lo(0x20),  %l3
sethi %hi(0x10000), %l6
or %l6, %lo(0x10000),  %l6
add %i3, %l3, %l3
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]

P4998: !_SWAP [9] (maybe <- 0x2000077) (Int)
mov %l4, %o2
swap  [%i1 + 512], %o2
! move %o2(lower) -> %o2(upper)
sllx %o2, 32, %o2
add   %l4, 1, %l4

P4999: !_ST [12] (maybe <- 0x41800129) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i3 + 0 ]

P5000: !_SWAP [5] (maybe <- 0x2000078) (Int)
mov %l4, %o5
swap  [%i1 + 76], %o5
! move %o5(lower) -> %o2(lower)
srl %o5, 0, %l6
or %l6, %o2, %o2
add   %l4, 1, %l4

P5001: !_REPLACEMENT [15] (Int)
sethi %hi(0xc0), %l3
or %l3, %lo(0xc0),  %l3
sethi %hi(0x10000), %l6
or %l6, %lo(0x10000),  %l6
add %i3, %l3, %l3
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]

P5002: !_CAS [6] (maybe <- 0x2000079) (Int)
add %i1, 80, %l3
lduw [%l3], %o3
mov %o3, %o5
! move %o5(lower) -> %o3(upper)
sllx %o5, 32, %o3
mov %l4, %l7
cas [%l3], %o5, %l7
! move %l7(lower) -> %o3(lower)
srl %l7, 0, %l3
or %l3, %o3, %o3
add   %l4, 1, %l4

P5003: !_DWST [4] (maybe <- 0x4180012a) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
std %f20, [%i0 + 64]

P5004: !_PREFETCH [7] (Int)
prefetch [%i1 + 84], 1

P5005: !_ST [8] (maybe <- 0x4180012b) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i1 + 256 ]

P5006: !_PREFETCH [7] (Int) (Branch target of P4667)
prefetch [%i1 + 84], 1
ba P5007
nop

TARGET4667:
ba RET4667
nop


P5007: !_PREFETCH [14] (Int)
prefetch [%i3 + 128], 1

P5008: !_DWLD [11] (FP)
ldd [%i2 + 64], %f18
! 1 addresses covered
fmovs %f18, %f15
!---- flushing fp results buffer to %f30 ----
fmovd %f0, %f30
fmovd %f2, %f30
fmovd %f4, %f30
fmovd %f6, %f30
fmovd %f8, %f30
fmovd %f10, %f30
fmovd %f12, %f30
fmovd %f14, %f30

P5009: !_REPLACEMENT [4] (Int)
sethi %hi(0x40), %l6
or %l6, %lo(0x40),  %l6
sethi %hi(0x10000), %l7
or %l7, %lo(0x10000),  %l7
add %i3, %l6, %l6
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]

P5010: !_PREFETCH [9] (Int)
prefetch [%i1 + 512], 1

P5011: !_LD [4] (FP)
ld [%i0 + 64], %f0
! 1 addresses covered

P5012: !_DWLD [6] (FP)
ldd [%i1 + 80], %f18
! 2 addresses covered
fmovs %f18, %f1
fmovs %f19, %f2

P5013: !_DWST [6] (maybe <- 0x4180012c) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
! 1 th moved, current_fp_src=21 
fmovs  %f16, %f21
fadds  %f16, %f17, %f16
std %f20, [%i1 + 80]

P5014: !_LD [6] (FP) (Branch target of P4662)
ld [%i1 + 80], %f3
! 1 addresses covered
ba P5015
nop

TARGET4662:
ba RET4662
nop


P5015: !_REPLACEMENT [10] (Int)
sethi %hi(0x20), %o5
or %o5, %lo(0x20),  %o5
sethi %hi(0x10000), %l3
or %l3, %lo(0x10000),  %l3
add %i3, %o5, %o5
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]

P5016: !_PREFETCH [12] (Int)
prefetch [%i3 + 0], 1

P5017: !_DWST [9] (maybe <- 0x4180012e) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
std %f20, [%i1 + 512]

P5018: !_DWST [6] (maybe <- 0x4180012f) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
! 1 th moved, current_fp_src=21 
fmovs  %f16, %f21
fadds  %f16, %f17, %f16
std %f20, [%i1 + 80]

P5019: !_LD [10] (FP)
ld [%i2 + 32], %f4
! 1 addresses covered

P5020: !_REPLACEMENT [4] (Int)
sethi %hi(0x40), %l3
or %l3, %lo(0x40),  %l3
sethi %hi(0x10000), %l6
or %l6, %lo(0x10000),  %l6
add %i3, %l3, %l3
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]

P5021: !_REPLACEMENT [9] (Int)
sethi %hi(0x200), %o5
or %o5, %lo(0x200),  %o5
sethi %hi(0x10000), %l3
or %l3, %lo(0x10000),  %l3
add %i3, %o5, %o5
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]

P5022: !_REPLACEMENT [14] (Int)
sethi %hi(0x80), %l7
or %l7, %lo(0x80),  %l7
sethi %hi(0x10000), %o5
or %o5, %lo(0x10000),  %o5
add %i3, %l7, %l7
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]

P5023: !_DWLD [10] (FP)
ldd [%i2 + 32], %f18
! 1 addresses covered
fmovs %f18, %f5

P5024: !_DWLD [15] (FP)
ldd [%i3 + 192], %f6
! 1 addresses covered

P5025: !_DWLD [4] (FP)
ldd [%i0 + 64], %f18
! 1 addresses covered
fmovs %f18, %f7

P5026: !_LD [12] (FP)
ld [%i3 + 0], %f8
! 1 addresses covered

P5027: !_DWST [6] (maybe <- 0x41800131) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
! 1 th moved, current_fp_src=21 
fmovs  %f16, %f21
fadds  %f16, %f17, %f16
std %f20, [%i1 + 80]

P5028: !_DWLD [14] (FP)
ldd [%i3 + 128], %f18
! 1 addresses covered
fmovs %f18, %f9

P5029: !_ST [10] (maybe <- 0x41800133) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i2 + 32 ]

P5030: !_PREFETCH [13] (Int)
prefetch [%i3 + 64], 1

P5031: !_NOP (Int) (CBR)
nop

! cbranch
andcc %l0, 1, %g0
be,pt  %xcc, TARGET5031
nop
RET5031:

! lfsr step begin
srlx %l0, 1, %o5
xnor %o5, %l0, %o5
sllx %o5, 63, %o5
or  %o5, %l0, %l0
srlx %l0, 1, %l0


P5032: !_ST [5] (maybe <- 0x41800134) (FP) (CBR)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i1 + 76 ]

! cbranch
andcc %l0, 1, %g0
be,pn  %xcc, TARGET5032
nop
RET5032:

! lfsr step begin
srlx %l0, 1, %o5
xnor %o5, %l0, %o5
sllx %o5, 63, %o5
or  %o5, %l0, %l0
srlx %l0, 1, %l0


P5033: !_REPLACEMENT [10] (Int)
sethi %hi(0x20), %l3
or %l3, %lo(0x20),  %l3
sethi %hi(0x10000), %l6
or %l6, %lo(0x10000),  %l6
add %i3, %l3, %l3
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]

P5034: !_CAS [0] (maybe <- 0x200007a) (Int)
add %i0, 0, %l3
lduw [%l3], %o4
mov %o4, %o5
! move %o5(lower) -> %o4(upper)
sllx %o5, 32, %o4
mov %l4, %l7
cas [%l3], %o5, %l7
! move %l7(lower) -> %o4(lower)
srl %l7, 0, %l3
or %l3, %o4, %o4
!---- flushing int results buffer----
mov %o0, %l5
mov %o1, %l5
mov %o2, %l5
mov %o3, %l5
mov %o4, %l5
add   %l4, 1, %l4

P5035: !_LD [10] (FP)
ld [%i2 + 32], %f10
! 1 addresses covered

P5036: !_REPLACEMENT [14] (Int)
sethi %hi(0x80), %o5
or %o5, %lo(0x80),  %o5
sethi %hi(0x10000), %l3
or %l3, %lo(0x10000),  %l3
add %i3, %o5, %o5
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]

P5037: !_SWAP [12] (maybe <- 0x200007b) (Int) (Branch target of P4942)
mov %l4, %o0
swap  [%i3 + 0], %o0
! move %o0(lower) -> %o0(upper)
sllx %o0, 32, %o0
add   %l4, 1, %l4
ba P5038
nop

TARGET4942:
ba RET4942
nop


P5038: !_DWST [5] (maybe <- 0x41800135) (FP) (Branch target of P4531)
! 0 th moved, current_fp_src=21 
fmovs  %f16, %f21
fadds  %f16, %f17, %f16
std %f20, [%i1 + 72]
ba P5039
nop

TARGET4531:
ba RET4531
nop


P5039: !_SWAP [10] (maybe <- 0x200007c) (Int)
mov %l4, %l7
swap  [%i2 + 32], %l7
! move %l7(lower) -> %o0(lower)
srl %l7, 0, %l3
or %l3, %o0, %o0
add   %l4, 1, %l4

P5040: !_LD [4] (FP)
ld [%i0 + 64], %f11
! 1 addresses covered

P5041: !_PREFETCH [3] (Int)
prefetch [%i0 + 32], 1

P5042: !_DWLD [10] (FP)
ldd [%i2 + 32], %f12
! 1 addresses covered

P5043: !_ST [10] (maybe <- 0x41800136) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i2 + 32 ]

P5044: !_CASX [8] (maybe <- 0x200007d) (Int)
add %i1, 256, %o5
ldx [%o5], %o1
! move %o1(upper) -> %o1(upper)
! move %o1(lower) -> %o1(lower)
mov  %o1, %l7
sllx %l4, 32, %o2
casx [%o5], %l7, %o2
! move %o2(upper) -> %o2(upper)
! move %o2(lower) -> %o2(lower)
add  %l4, 1, %l4

P5045: !_MEMBAR (Int)
membar #StoreLoad

P5046: !_PREFETCH [9] (Int)
prefetch [%i1 + 512], 1

P5047: !_ST [15] (maybe <- 0x41800137) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i3 + 192 ]

P5048: !_DWLD [4] (FP)
ldd [%i0 + 64], %f18
! 1 addresses covered
fmovs %f18, %f13

P5049: !_DWLD [8] (FP)
ldd [%i1 + 256], %f14
! 1 addresses covered

P5050: !_DWST [9] (maybe <- 0x41800138) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
std %f20, [%i1 + 512]

P5051: !_DWLD [6] (FP)
ldd [%i1 + 80], %f18
! 2 addresses covered
fmovs %f18, %f15
!---- flushing fp results buffer to %f30 ----
fmovd %f0, %f30
fmovd %f2, %f30
fmovd %f4, %f30
fmovd %f6, %f30
fmovd %f8, %f30
fmovd %f10, %f30
fmovd %f12, %f30
fmovd %f14, %f30
fmovs %f19, %f0

P5052: !_LD [3] (FP)
ld [%i0 + 32], %f1
! 1 addresses covered

P5053: !_DWLD [11] (FP)
ldd [%i2 + 64], %f2
! 1 addresses covered

P5054: !_LD [5] (FP)
ld [%i1 + 76], %f3
! 1 addresses covered

P5055: !_CASX [3] (maybe <- 0x200007e) (Int)
add %i0, 32, %l6
ldx [%l6], %o3
! move %o3(upper) -> %o3(upper)
! move %o3(lower) -> %o3(lower)
mov  %o3, %l3
sllx %l4, 32, %o4
casx [%l6], %l3, %o4
! move %o4(upper) -> %o4(upper)
! move %o4(lower) -> %o4(lower)
!---- flushing int results buffer----
mov %o0, %l5
mov %o1, %l5
mov %o2, %l5
mov %o3, %l5
mov %o4, %l5
add  %l4, 1, %l4

P5056: !_PREFETCH [9] (Int)
prefetch [%i1 + 512], 1

P5057: !_REPLACEMENT [2] (Int)
sethi %hi(0xc), %l3
or %l3, %lo(0xc),  %l3
sethi %hi(0x10000), %l6
or %l6, %lo(0x10000),  %l6
add %i3, %l3, %l3
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]

P5058: !_MEMBAR (Int)
membar #StoreLoad

P5059: !_DWST [0] (maybe <- 0x41800139) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
! 1 th moved, current_fp_src=21 
fmovs  %f16, %f21
fadds  %f16, %f17, %f16
std %f20, [%i0 + 0]

P5060: !_PREFETCH [5] (Int)
prefetch [%i1 + 76], 1

P5061: !_ST [5] (maybe <- 0x4180013b) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i1 + 76 ]

P5062: !_LD [13] (FP)
ld [%i3 + 64], %f4
! 1 addresses covered

P5063: !_CAS [3] (maybe <- 0x200007f) (Int)
add %i0, 32, %l7
lduw [%l7], %o0
mov %o0, %l6
! move %l6(lower) -> %o0(upper)
sllx %l6, 32, %o0
mov %l4, %l3
cas [%l7], %l6, %l3
! move %l3(lower) -> %o0(lower)
srl %l3, 0, %l7
or %l7, %o0, %o0
add   %l4, 1, %l4

P5064: !_PREFETCH [2] (Int)
prefetch [%i0 + 12], 1

P5065: !_DWLD [1] (FP)
ldd [%i0 + 0], %f18
! 2 addresses covered
fmovs %f18, %f5
fmovs %f19, %f6

P5066: !_REPLACEMENT [7] (Int)
sethi %hi(0x54), %l6
or %l6, %lo(0x54),  %l6
sethi %hi(0x10000), %l7
or %l7, %lo(0x10000),  %l7
add %i3, %l6, %l6
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]

P5067: !_LD [2] (FP)
ld [%i0 + 12], %f7
! 1 addresses covered

P5068: !_REPLACEMENT [4] (Int)
sethi %hi(0x40), %l3
or %l3, %lo(0x40),  %l3
sethi %hi(0x10000), %l6
or %l6, %lo(0x10000),  %l6
add %i3, %l3, %l3
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]

P5069: !_ST [3] (maybe <- 0x4180013c) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i0 + 32 ]

P5070: !_ST [4] (maybe <- 0x4180013d) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i0 + 64 ]

P5071: !_DWLD [13] (FP)
ldd [%i3 + 64], %f8
! 1 addresses covered

P5072: !_DWST [10] (maybe <- 0x4180013e) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
std %f20, [%i2 + 32]

P5073: !_PREFETCH [4] (Int)
prefetch [%i0 + 64], 1

P5074: !_DWLD [5] (FP)
ldd [%i1 + 72], %f18
! 1 addresses covered
fmovs %f19, %f9

P5075: !_LD [5] (FP)
ld [%i1 + 76], %f10
! 1 addresses covered

P5076: !_REPLACEMENT [14] (Int)
sethi %hi(0x80), %l3
or %l3, %lo(0x80),  %l3
sethi %hi(0x10000), %l6
or %l6, %lo(0x10000),  %l6
add %i3, %l3, %l3
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]

P5077: !_MEMBAR (Int)
membar #StoreLoad

P5078: !_DWST [10] (maybe <- 0x4180013f) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
std %f20, [%i2 + 32]

P5079: !_DWLD [4] (FP)
ldd [%i0 + 64], %f18
! 1 addresses covered
fmovs %f18, %f11

P5080: !_LD [11] (FP)
ld [%i2 + 64], %f12
! 1 addresses covered

P5081: !_CAS [3] (maybe <- 0x2000080) (Int)
add %i0, 32, %o5
lduw [%o5], %o1
mov %o1, %l7
! move %l7(lower) -> %o1(upper)
sllx %l7, 32, %o1
mov %l4, %l6
cas [%o5], %l7, %l6
! move %l6(lower) -> %o1(lower)
srl %l6, 0, %o5
or %o5, %o1, %o1
add   %l4, 1, %l4

P5082: !_CASX [10] (maybe <- 0x2000081) (Int) (Branch target of P4752)
add %i2, 32, %o5
ldx [%o5], %o2
! move %o2(upper) -> %o2(upper)
! move %o2(lower) -> %o2(lower)
mov  %o2, %l7
sllx %l4, 32, %o3
casx [%o5], %l7, %o3
! move %o3(upper) -> %o3(upper)
! move %o3(lower) -> %o3(lower)
add  %l4, 1, %l4
ba P5083
nop

TARGET4752:
ba RET4752
nop


P5083: !_DWLD [13] (FP)
ldd [%i3 + 64], %f18
! 1 addresses covered
fmovs %f18, %f13

P5084: !_PREFETCH [13] (Int)
prefetch [%i3 + 64], 1

P5085: !_PREFETCH [12] (Int)
prefetch [%i3 + 0], 1

P5086: !_CASX [3] (maybe <- 0x2000082) (Int) (Branch target of P4665)
add %i0, 32, %o5
ldx [%o5], %o4
! move %o4(upper) -> %o4(upper)
! move %o4(lower) -> %o4(lower)
!---- flushing int results buffer----
mov %o0, %l5
mov %o1, %l5
mov %o2, %l5
mov %o3, %l5
mov %o4, %l5
mov  %o4, %l7
sllx %l4, 32, %o0
casx [%o5], %l7, %o0
! move %o0(upper) -> %o0(upper)
! move %o0(lower) -> %o0(lower)
add  %l4, 1, %l4
ba P5087
nop

TARGET4665:
ba RET4665
nop


P5087: !_DWST [1] (maybe <- 0x41800140) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
! 1 th moved, current_fp_src=21 
fmovs  %f16, %f21
fadds  %f16, %f17, %f16
std %f20, [%i0 + 0]

P5088: !_DWLD [3] (FP)
ldd [%i0 + 32], %f14
! 1 addresses covered

P5089: !_REPLACEMENT [7] (Int)
sethi %hi(0x54), %l6
or %l6, %lo(0x54),  %l6
sethi %hi(0x10000), %l7
or %l7, %lo(0x10000),  %l7
add %i3, %l6, %l6
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]

P5090: !_LD [2] (FP)
ld [%i0 + 12], %f15
! 1 addresses covered
!---- flushing fp results buffer to %f30 ----
fmovd %f0, %f30
fmovd %f2, %f30
fmovd %f4, %f30
fmovd %f6, %f30
fmovd %f8, %f30
fmovd %f10, %f30
fmovd %f12, %f30
fmovd %f14, %f30

P5091: !_LD [3] (FP)
ld [%i0 + 32], %f0
! 1 addresses covered

P5092: !_CASX [1] (maybe <- 0x2000083) (Int)
add %i0, 0, %l6
ldx [%l6], %o1
! move %o1(upper) -> %o1(upper)
! move %o1(lower) -> %o1(lower)
mov %o1, %l3
sllx %l4, 32, %o2
add  %l4, 1, %l4
or   %l4, %o2, %o2
casx [%l6], %l3, %o2
! move %o2(upper) -> %o2(upper)
! move %o2(lower) -> %o2(lower)
add  %l4, 1, %l4

P5093: !_LD [9] (FP)
ld [%i1 + 512], %f1
! 1 addresses covered

P5094: !_DWLD [1] (FP)
ldd [%i0 + 0], %f2
! 2 addresses covered

P5095: !_LD [1] (FP)
ld [%i0 + 4], %f4
! 1 addresses covered

P5096: !_MEMBAR (Int)
membar #StoreLoad

P5097: !_LD [0] (FP)
ld [%i0 + 0], %f5
! 1 addresses covered

P5098: !_LD [1] (FP)
ld [%i0 + 4], %f6
! 1 addresses covered

P5099: !_LD [2] (FP)
ld [%i0 + 12], %f7
! 1 addresses covered

P5100: !_LD [3] (FP)
ld [%i0 + 32], %f8
! 1 addresses covered

P5101: !_LD [4] (FP)
ld [%i0 + 64], %f9
! 1 addresses covered

P5102: !_LD [5] (FP)
ld [%i1 + 76], %f10
! 1 addresses covered

P5103: !_LD [6] (FP)
ld [%i1 + 80], %f11
! 1 addresses covered

P5104: !_LD [7] (FP)
ld [%i1 + 84], %f12
! 1 addresses covered

P5105: !_LD [8] (FP)
ld [%i1 + 256], %f13
! 1 addresses covered

P5106: !_LD [9] (FP)
ld [%i1 + 512], %f14
! 1 addresses covered

P5107: !_LD [10] (FP)
ld [%i2 + 32], %f15
! 1 addresses covered
!---- flushing fp results buffer to %f30 ----
fmovd %f0, %f30
fmovd %f2, %f30
fmovd %f4, %f30
fmovd %f6, %f30
fmovd %f8, %f30
fmovd %f10, %f30
fmovd %f12, %f30
fmovd %f14, %f30

P5108: !_LD [11] (FP)
ld [%i2 + 64], %f0
! 1 addresses covered

P5109: !_LD [12] (FP) (Branch target of P4505)
ld [%i3 + 0], %f1
! 1 addresses covered
ba P5110
nop

TARGET4505:
ba RET4505
nop


P5110: !_LD [13] (FP)
ld [%i3 + 64], %f2
! 1 addresses covered

P5111: !_LD [14] (FP)
ld [%i3 + 128], %f3
! 1 addresses covered

P5112: !_LD [15] (FP)
ld [%i3 + 192], %f4
! 1 addresses covered

END_NODES4: ! Test istream for CPU 4 ends
sethi %hi(0xdead0e0f), %l3
or    %l3, %lo(0xdead0e0f), %l3
! move %l3(lower) -> %o3(upper)
sllx %l3, 32, %o3
stw %l3, [%i5] 
ld [%i5], %f5
!---- flushing int results buffer----
mov %o0, %l5
mov %o1, %l5
mov %o2, %l5
mov %o3, %l5
!---- flushing fp results buffer to %f30 ----
fmovd %f0, %f30
fmovd %f2, %f30
fmovd %f4, %f30

restore
retl
nop
!-----------------

! register usage:
! %i0 %i1 %i2 %i3 : base registers for 4 regions
! %i4 fixed pointer to per-cpu results area
! %l1 moving pointer to per-cpu FP results area
! %o7 moving pointer to per-cpu integer results area
! %i5 pointer to per-cpu private area
! %l0 holds lfsr, used as source of random bits 
! %l2 loop count register
! %f16 running counter for unique fp store values
! %f17 holds increment value for fp counter
! %l4 running counter for unique integer store values (increment value is always 1)
! %l5 move-to register for load values (simulation only)
! %f30 move-to register for FP values (simulation only)
! %l3 %l6 %l7 %o5 : 4 temporary registers
! %o0 %o1 %o2 %o3 %o4 : 5 integer results buffer registers
! %f0-f15 FP results buffer registers
! %f32-f47 FP block load/store registers

func5:
! 1000 (dynamic) instruction sequence begins
save   %sp, -192, %sp

! Force %i0-%i3 to be 64-byte aligned
add %i0, 63, %i0
andn %i0, 63, %i0

add %i1, 63, %i1
andn %i1, 63, %i1

add %i2, 63, %i2
andn %i2, 63, %i2

add %i3, 63, %i3
andn %i3, 63, %i3

add %i4, 63, %i4
andn %i4, 63, %i4

add %i5, 63, %i5
andn %i5, 63, %i5


! Initialize pointer to FP load results area
mov   %i4, %l1

! Initialize pointer to integer load results area
sethi %hi(0x80000), %o7
or    %o7, %lo(0x80000), %o7
add  %o7, %l1, %o7 

! Initialize %f0-%f62 to 0xdeadbee0deadbee1
sethi %hi(0xdeadbee0), %o5
or    %o5, %lo(0xdeadbee0), %o5
stw   %o5, [%i5]
sethi %hi(0xdeadbee1), %o5
or    %o5, %lo(0xdeadbee1), %o5
stw   %o5, [%i5+4]
ldd [%i5], %f0
fmovd %f0, %f2
fmovd %f0, %f4
fmovd %f0, %f6
fmovd %f0, %f8
fmovd %f0, %f10
fmovd %f0, %f12
fmovd %f0, %f14
fmovd %f0, %f16
fmovd %f0, %f18
fmovd %f0, %f20
fmovd %f0, %f22
fmovd %f0, %f24
fmovd %f0, %f26
fmovd %f0, %f28
fmovd %f0, %f30
fmovd %f0, %f32
fmovd %f0, %f34
fmovd %f0, %f36
fmovd %f0, %f38
fmovd %f0, %f40
fmovd %f0, %f42
fmovd %f0, %f44
fmovd %f0, %f46
fmovd %f0, %f48
fmovd %f0, %f50
fmovd %f0, %f52
fmovd %f0, %f54
fmovd %f0, %f56
fmovd %f0, %f58
fmovd %f0, %f60
fmovd %f0, %f62

! Signature for extract_loads script to start extracting load values for this stream
sethi %hi(0x05deade1), %o5
or    %o5, %lo(0x05deade1), %o5
stw %o5, [%i5] 
ld [%i5], %f16

! Initialize running integer counter in register %l4
sethi %hi(0x2800001), %l4
or    %l4, %lo(0x2800001), %l4

! Initialize running FP counter in register %f16
sethi %hi(0x42000001), %o5
or    %o5, %lo(0x42000001), %o5
stw %o5, [%i5] 
ld [%i5], %f16

! Initialize FP counter increment value in register %f17 (constant)
sethi %hi(0x36800000), %o5
or    %o5, %lo(0x36800000), %o5
stw %o5, [%i5] 
ld [%i5], %f17 

! Initialize LFSR to 0x321a^4
sethi %hi(0x321a), %l0
or    %l0, %lo(0x321a), %l0
mulx  %l0, %l0, %l0
mulx  %l0, %l0, %l0

!-- init shared addrs 10 to 11 ---
stx %g0, [%i2+32]
stx %g0, [%i2+64]

! use untouched cache-line (offset 4K) in replacement area for sync
sub %i1, %i0, %l3
add %i3, %l3, %l3
sub %l3, -4096, %l3

!-- begin of sync_init ---
or %g0, 1, %l6
or %g0, %l6, %l7
swap [%l3+4], %l7
membar #Sync
sync_init_1_5:
brnz,pt %l6, sync_init_1_5
lduw [%l3+4], %l6 ! delay slot
sync_init_2_5:
lduw [%l3], %l6
sub %l6, 1, %l7
cas [%l3], %l6, %l7
cmp %l6, %l7
bne,pt %xcc, sync_init_2_5
nop
membar #Sync
sync_init_3_5:
lduw [%l3], %l6 ! delay slot
brnz,pt %l6, sync_init_3_5
nop
!-- end of sync_init ---


BEGIN_NODES5: ! Test istream for CPU 5 begins

P5113: !_DWLD [8] (FP)
ldd [%i1 + 256], %f0
! 1 addresses covered

P5114: !_PREFETCH [9] (Int)
prefetch [%i1 + 512], 1

P5115: !_CASX [14] (maybe <- 0x2800001) (Int)
add %i3, 128, %l3
ldx [%l3], %o0
! move %o0(upper) -> %o0(upper)
! move %o0(lower) -> %o0(lower)
mov  %o0, %o5
sllx %l4, 32, %o1
casx [%l3], %o5, %o1
! move %o1(upper) -> %o1(upper)
! move %o1(lower) -> %o1(lower)
add  %l4, 1, %l4

P5116: !_DWLD [9] (FP)
ldd [%i1 + 512], %f18
! 1 addresses covered
fmovs %f18, %f1

P5117: !_MEMBAR (Int)
membar #StoreLoad

P5118: !_CAS [13] (maybe <- 0x2800002) (Int) (CBR)
add %i3, 64, %l3
lduw [%l3], %o2
mov %o2, %o5
! move %o5(lower) -> %o2(upper)
sllx %o5, 32, %o2
mov %l4, %l7
cas [%l3], %o5, %l7
! move %l7(lower) -> %o2(lower)
srl %l7, 0, %l3
or %l3, %o2, %o2
add   %l4, 1, %l4

! cbranch
andcc %l0, 1, %g0
be,pn  %xcc, TARGET5118
nop
RET5118:

! lfsr step begin
srlx %l0, 1, %o5
xnor %o5, %l0, %o5
sllx %o5, 63, %o5
or  %o5, %l0, %l0
srlx %l0, 1, %l0


P5119: !_CASX [11] (maybe <- 0x2800003) (Int)
add %i2, 64, %l6
ldx [%l6], %o3
! move %o3(upper) -> %o3(upper)
! move %o3(lower) -> %o3(lower)
mov  %o3, %l3
sllx %l4, 32, %o4
casx [%l6], %l3, %o4
! move %o4(upper) -> %o4(upper)
! move %o4(lower) -> %o4(lower)
!---- flushing int results buffer----
mov %o0, %l5
mov %o1, %l5
mov %o2, %l5
mov %o3, %l5
mov %o4, %l5
add  %l4, 1, %l4

P5120: !_PREFETCH [10] (Int)
prefetch [%i2 + 32], 1

P5121: !_LD [14] (FP)
ld [%i3 + 128], %f2
! 1 addresses covered

P5122: !_CASX [5] (maybe <- 0x2800004) (Int)
add %i1, 72, %l6
ldx [%l6], %o0
! move %o0(upper) -> %o0(upper)
! move %o0(lower) -> %o0(lower)
mov  %o0, %l3
mov %l4, %o1
casx [%l6], %l3, %o1
! move %o1(upper) -> %o1(upper)
! move %o1(lower) -> %o1(lower)
add  %l4, 1, %l4

P5123: !_DWST [3] (maybe <- 0x42000001) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
std %f20, [%i0 + 32]

P5124: !_REPLACEMENT [0] (Int)
sethi %hi(0x0), %o5
or %o5, %lo(0x0),  %o5
sethi %hi(0x10000), %l3
or %l3, %lo(0x10000),  %l3
add %i3, %o5, %o5
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]

P5125: !_REPLACEMENT [5] (Int)
sethi %hi(0x4c), %l7
or %l7, %lo(0x4c),  %l7
sethi %hi(0x10000), %o5
or %o5, %lo(0x10000),  %o5
add %i3, %l7, %l7
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]

P5126: !_DWLD [8] (FP)
ldd [%i1 + 256], %f18
! 1 addresses covered
fmovs %f18, %f3

P5127: !_ST [2] (maybe <- 0x42000002) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i0 + 12 ]

P5128: !_PREFETCH [8] (Int)
prefetch [%i1 + 256], 1

P5129: !_DWLD [2] (FP) (CBR)
ldd [%i0 + 8], %f4
! 1 addresses covered
fmovs %f5, %f4

! cbranch
andcc %l0, 1, %g0
be,pt  %xcc, TARGET5129
nop
RET5129:

! lfsr step begin
srlx %l0, 1, %l3
xnor %l3, %l0, %l3
sllx %l3, 63, %l3
or  %l3, %l0, %l0
srlx %l0, 1, %l0


P5130: !_REPLACEMENT [4] (Int)
sethi %hi(0x40), %l6
or %l6, %lo(0x40),  %l6
sethi %hi(0x10000), %l7
or %l7, %lo(0x10000),  %l7
add %i3, %l6, %l6
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]

P5131: !_LD [0] (FP)
ld [%i0 + 0], %f5
! 1 addresses covered

P5132: !_SWAP [4] (maybe <- 0x2800005) (Int)
mov %l4, %o2
swap  [%i0 + 64], %o2
! move %o2(lower) -> %o2(upper)
sllx %o2, 32, %o2
add   %l4, 1, %l4

P5133: !_ST [12] (maybe <- 0x42000003) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i3 + 0 ]

P5134: !_SWAP [12] (maybe <- 0x2800006) (Int)
mov %l4, %l3
swap  [%i3 + 0], %l3
! move %l3(lower) -> %o2(lower)
srl %l3, 0, %l7
or %l7, %o2, %o2
add   %l4, 1, %l4

P5135: !_NOP (Int)
nop

P5136: !_MEMBAR (Int)
membar #StoreLoad

P5137: !_LD [3] (FP)
ld [%i0 + 32], %f6
! 1 addresses covered

P5138: !_NOP (Int)
nop

P5139: !_PREFETCH [2] (Int) (Branch target of P5842)
prefetch [%i0 + 12], 1
ba P5140
nop

TARGET5842:
ba RET5842
nop


P5140: !_ST [5] (maybe <- 0x42000004) (FP) (CBR)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i1 + 76 ]

! cbranch
andcc %l0, 1, %g0
be,pt  %xcc, TARGET5140
nop
RET5140:

! lfsr step begin
srlx %l0, 1, %l3
xnor %l3, %l0, %l3
sllx %l3, 63, %l3
or  %l3, %l0, %l0
srlx %l0, 1, %l0


P5141: !_DWLD [7] (FP)
ldd [%i1 + 80], %f18
! 2 addresses covered
fmovs %f18, %f7
fmovs %f19, %f8

P5142: !_DWST [8] (maybe <- 0x42000005) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
std %f20, [%i1 + 256]

P5143: !_DWLD [15] (FP)
ldd [%i3 + 192], %f18
! 1 addresses covered
fmovs %f18, %f9

P5144: !_REPLACEMENT [0] (Int) (Branch target of P5790)
sethi %hi(0x0), %l3
or %l3, %lo(0x0),  %l3
sethi %hi(0x10000), %l6
or %l6, %lo(0x10000),  %l6
add %i3, %l3, %l3
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
ba P5145
nop

TARGET5790:
ba RET5790
nop


P5145: !_ST [3] (maybe <- 0x42000006) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i0 + 32 ]

P5146: !_REPLACEMENT [5] (Int)
sethi %hi(0x4c), %l7
or %l7, %lo(0x4c),  %l7
sethi %hi(0x10000), %o5
or %o5, %lo(0x10000),  %o5
add %i3, %l7, %l7
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]

P5147: !_CASX [0] (maybe <- 0x2800007) (Int)
add %i0, 0, %l7
ldx [%l7], %o3
! move %o3(upper) -> %o3(upper)
! move %o3(lower) -> %o3(lower)
mov %o3, %l6
sllx %l4, 32, %o4
add  %l4, 1, %l4
or   %l4, %o4, %o4
casx [%l7], %l6, %o4
! move %o4(upper) -> %o4(upper)
! move %o4(lower) -> %o4(lower)
!---- flushing int results buffer----
mov %o0, %l5
mov %o1, %l5
mov %o2, %l5
mov %o3, %l5
mov %o4, %l5
add  %l4, 1, %l4

P5148: !_PREFETCH [9] (Int)
prefetch [%i1 + 512], 1

P5149: !_DWLD [10] (FP)
ldd [%i2 + 32], %f10
! 1 addresses covered

P5150: !_ST [4] (maybe <- 0x42000007) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i0 + 64 ]

P5151: !_DWLD [9] (FP)
ldd [%i1 + 512], %f18
! 1 addresses covered
fmovs %f18, %f11

P5152: !_PREFETCH [9] (Int)
prefetch [%i1 + 512], 1

P5153: !_DWLD [11] (FP)
ldd [%i2 + 64], %f12
! 1 addresses covered

P5154: !_REPLACEMENT [5] (Int)
sethi %hi(0x4c), %l3
or %l3, %lo(0x4c),  %l3
sethi %hi(0x10000), %l6
or %l6, %lo(0x10000),  %l6
add %i3, %l3, %l3
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]

P5155: !_LD [2] (FP)
ld [%i0 + 12], %f13
! 1 addresses covered

P5156: !_SWAP [4] (maybe <- 0x2800009) (Int)
mov %l4, %o0
swap  [%i0 + 64], %o0
! move %o0(lower) -> %o0(upper)
sllx %o0, 32, %o0
add   %l4, 1, %l4

P5157: !_ST [1] (maybe <- 0x42000008) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i0 + 4 ]

P5158: !_DWST [11] (maybe <- 0x42000009) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
std %f20, [%i2 + 64]

P5159: !_DWLD [1] (FP)
ldd [%i0 + 0], %f14
! 2 addresses covered
!---- flushing fp results buffer to %f30 ----
fmovd %f0, %f30
fmovd %f2, %f30
fmovd %f4, %f30
fmovd %f6, %f30
fmovd %f8, %f30
fmovd %f10, %f30
fmovd %f12, %f30
fmovd %f14, %f30

P5160: !_DWST [15] (maybe <- 0x4200000a) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
std %f20, [%i3 + 192]

P5161: !_ST [10] (maybe <- 0x4200000b) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i2 + 32 ]

P5162: !_DWST [2] (maybe <- 0x4200000c) (FP)
! 0 th moved, current_fp_src=21 
fmovs  %f16, %f21
fadds  %f16, %f17, %f16
std %f20, [%i0 + 8]

P5163: !_ST [13] (maybe <- 0x4200000d) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i3 + 64 ]

P5164: !_DWST [8] (maybe <- 0x4200000e) (FP) (Branch target of P5306)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
std %f20, [%i1 + 256]
ba P5165
nop

TARGET5306:
ba RET5306
nop


P5165: !_DWLD [15] (FP)
ldd [%i3 + 192], %f0
! 1 addresses covered

P5166: !_CASX [11] (maybe <- 0x280000a) (Int)
add %i2, 64, %l3
ldx [%l3], %l7
! move %l7(upper) -> %o0(lower)
srlx %l7, 32, %o5
or %o5, %o0, %o0
! move %l7(lower) -> %o1(upper)
sllx %l7, 32, %o1
mov  %l7, %o5
sllx %l4, 32, %l7
casx [%l3], %o5, %l7
! move %l7(upper) -> %o1(lower)
srlx %l7, 32, %l3
or %l3, %o1, %o1
! move %l7(lower) -> %o2(upper)
sllx %l7, 32, %o2
add  %l4, 1, %l4

P5167: !_CASX [0] (maybe <- 0x280000b) (Int)
add %i0, 0, %l3
ldx [%l3], %l7
! move %l7(upper) -> %o2(lower)
srlx %l7, 32, %o5
or %o5, %o2, %o2
! move %l7(lower) -> %o3(upper)
sllx %l7, 32, %o3
mov %l7, %o5
sllx %l4, 32, %l7
add  %l4, 1, %l4
or   %l4, %l7, %l7
casx [%l3], %o5, %l7
! move %l7(upper) -> %o3(lower)
srlx %l7, 32, %l3
or %l3, %o3, %o3
! move %l7(lower) -> %o4(upper)
sllx %l7, 32, %o4
add  %l4, 1, %l4

P5168: !_ST [14] (maybe <- 0x4200000f) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i3 + 128 ]

P5169: !_LD [13] (FP) (CBR)
ld [%i3 + 64], %f1
! 1 addresses covered

! cbranch
andcc %l0, 1, %g0
be,pt  %xcc, TARGET5169
nop
RET5169:

! lfsr step begin
srlx %l0, 1, %l7
xnor %l7, %l0, %l7
sllx %l7, 63, %l7
or  %l7, %l0, %l0
srlx %l0, 1, %l0


P5170: !_REPLACEMENT [4] (Int)
sethi %hi(0x40), %o5
or %o5, %lo(0x40),  %o5
sethi %hi(0x10000), %l3
or %l3, %lo(0x10000),  %l3
add %i3, %o5, %o5
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]

P5171: !_SWAP [4] (maybe <- 0x280000d) (Int) (Branch target of P5837)
mov %l4, %l3
swap  [%i0 + 64], %l3
! move %l3(lower) -> %o4(lower)
srl %l3, 0, %l7
or %l7, %o4, %o4
!---- flushing int results buffer----
mov %o0, %l5
mov %o1, %l5
mov %o2, %l5
mov %o3, %l5
mov %o4, %l5
add   %l4, 1, %l4
ba P5172
nop

TARGET5837:
ba RET5837
nop


P5172: !_PREFETCH [4] (Int)
prefetch [%i0 + 64], 1

P5173: !_DWST [8] (maybe <- 0x42000010) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
std %f20, [%i1 + 256]

P5174: !_MEMBAR (Int)
membar #StoreLoad

P5175: !_REPLACEMENT [9] (Int)
sethi %hi(0x200), %l3
or %l3, %lo(0x200),  %l3
sethi %hi(0x10000), %l6
or %l6, %lo(0x10000),  %l6
add %i3, %l3, %l3
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]

P5176: !_REPLACEMENT [8] (Int)
sethi %hi(0x100), %o5
or %o5, %lo(0x100),  %o5
sethi %hi(0x10000), %l3
or %l3, %lo(0x10000),  %l3
add %i3, %o5, %o5
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]

P5177: !_DWLD [9] (FP)
ldd [%i1 + 512], %f2
! 1 addresses covered

P5178: !_PREFETCH [2] (Int)
prefetch [%i0 + 12], 1

P5179: !_SWAP [14] (maybe <- 0x280000e) (Int)
mov %l4, %o0
swap  [%i3 + 128], %o0
! move %o0(lower) -> %o0(upper)
sllx %o0, 32, %o0
add   %l4, 1, %l4

P5180: !_DWLD [5] (FP)
ldd [%i1 + 72], %f18
! 1 addresses covered
fmovs %f19, %f3

P5181: !_ST [7] (maybe <- 0x42000011) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i1 + 84 ]

P5182: !_DWLD [15] (FP)
ldd [%i3 + 192], %f4
! 1 addresses covered

P5183: !_LD [6] (FP)
ld [%i1 + 80], %f5
! 1 addresses covered

P5184: !_DWLD [9] (FP)
ldd [%i1 + 512], %f6
! 1 addresses covered

P5185: !_ST [4] (maybe <- 0x42000012) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i0 + 64 ]

P5186: !_ST [2] (maybe <- 0x42000013) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i0 + 12 ]

P5187: !_DWST [5] (maybe <- 0x42000014) (FP)
! 0 th moved, current_fp_src=21 
fmovs  %f16, %f21
fadds  %f16, %f17, %f16
std %f20, [%i1 + 72]

P5188: !_PREFETCH [14] (Int)
prefetch [%i3 + 128], 1

P5189: !_CAS [11] (maybe <- 0x280000f) (Int)
add %i2, 64, %l7
lduw [%l7], %l3
mov %l3, %l6
! move %l6(lower) -> %o0(lower)
or %l6, %o0, %o0
mov %l4, %o1
cas [%l7], %l6, %o1
! move %o1(lower) -> %o1(upper)
sllx %o1, 32, %o1
add   %l4, 1, %l4

P5190: !_DWLD [6] (FP)
ldd [%i1 + 80], %f18
! 2 addresses covered
fmovs %f18, %f7
fmovs %f19, %f8

P5191: !_REPLACEMENT [14] (Int)
sethi %hi(0x80), %l6
or %l6, %lo(0x80),  %l6
sethi %hi(0x10000), %l7
or %l7, %lo(0x10000),  %l7
add %i3, %l6, %l6
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]

P5192: !_CAS [15] (maybe <- 0x2800010) (Int)
add %i3, 192, %l6
lduw [%l6], %o5
mov %o5, %l3
! move %l3(lower) -> %o1(lower)
or %l3, %o1, %o1
mov %l4, %o2
cas [%l6], %l3, %o2
! move %o2(lower) -> %o2(upper)
sllx %o2, 32, %o2
add   %l4, 1, %l4

P5193: !_ST [4] (maybe <- 0x42000015) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i0 + 64 ]

P5194: !_DWLD [11] (FP)
ldd [%i2 + 64], %f18
! 1 addresses covered
fmovs %f18, %f9

P5195: !_DWST [1] (maybe <- 0x42000016) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
! 1 th moved, current_fp_src=21 
fmovs  %f16, %f21
fadds  %f16, %f17, %f16
std %f20, [%i0 + 0]

P5196: !_ST [12] (maybe <- 0x42000018) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i3 + 0 ]

P5197: !_DWLD [6] (FP)
ldd [%i1 + 80], %f10
! 2 addresses covered

P5198: !_REPLACEMENT [4] (Int)
sethi %hi(0x40), %l6
or %l6, %lo(0x40),  %l6
sethi %hi(0x10000), %l7
or %l7, %lo(0x10000),  %l7
add %i3, %l6, %l6
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]

P5199: !_NOP (Int)
nop

P5200: !_DWST [2] (maybe <- 0x42000019) (FP)
! 0 th moved, current_fp_src=21 
fmovs  %f16, %f21
fadds  %f16, %f17, %f16
std %f20, [%i0 + 8]

P5201: !_CAS [13] (maybe <- 0x2800011) (Int)
add %i3, 64, %l3
lduw [%l3], %l7
mov %l7, %o5
! move %o5(lower) -> %o2(lower)
or %o5, %o2, %o2
mov %l4, %o3
cas [%l3], %o5, %o3
! move %o3(lower) -> %o3(upper)
sllx %o3, 32, %o3
add   %l4, 1, %l4

P5202: !_ST [8] (maybe <- 0x4200001a) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i1 + 256 ]

P5203: !_NOP (Int)
nop

P5204: !_LD [15] (FP)
ld [%i3 + 192], %f12
! 1 addresses covered

P5205: !_ST [9] (maybe <- 0x4200001b) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i1 + 512 ]

P5206: !_DWST [14] (maybe <- 0x4200001c) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
std %f20, [%i3 + 128]

P5207: !_SWAP [4] (maybe <- 0x2800012) (Int)
mov %l4, %l7
swap  [%i0 + 64], %l7
! move %l7(lower) -> %o3(lower)
srl %l7, 0, %l3
or %l3, %o3, %o3
add   %l4, 1, %l4

P5208: !_ST [14] (maybe <- 0x4200001d) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i3 + 128 ]

P5209: !_SWAP [1] (maybe <- 0x2800013) (Int)
mov %l4, %o4
swap  [%i0 + 4], %o4
! move %o4(lower) -> %o4(upper)
sllx %o4, 32, %o4
add   %l4, 1, %l4

P5210: !_PREFETCH [15] (Int)
prefetch [%i3 + 192], 1

P5211: !_REPLACEMENT [10] (Int)
sethi %hi(0x20), %l6
or %l6, %lo(0x20),  %l6
sethi %hi(0x10000), %l7
or %l7, %lo(0x10000),  %l7
add %i3, %l6, %l6
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]

P5212: !_SWAP [7] (maybe <- 0x2800014) (Int)
mov %l4, %l7
swap  [%i1 + 84], %l7
! move %l7(lower) -> %o4(lower)
srl %l7, 0, %l3
or %l3, %o4, %o4
!---- flushing int results buffer----
mov %o0, %l5
mov %o1, %l5
mov %o2, %l5
mov %o3, %l5
mov %o4, %l5
add   %l4, 1, %l4

P5213: !_DWST [15] (maybe <- 0x4200001e) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
std %f20, [%i3 + 192]

P5214: !_DWST [2] (maybe <- 0x4200001f) (FP)
! 0 th moved, current_fp_src=21 
fmovs  %f16, %f21
fadds  %f16, %f17, %f16
std %f20, [%i0 + 8]

P5215: !_DWST [15] (maybe <- 0x42000020) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
std %f20, [%i3 + 192]

P5216: !_DWLD [2] (FP)
ldd [%i0 + 8], %f18
! 1 addresses covered
fmovs %f19, %f13

P5217: !_DWST [0] (maybe <- 0x42000021) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
! 1 th moved, current_fp_src=21 
fmovs  %f16, %f21
fadds  %f16, %f17, %f16
std %f20, [%i0 + 0]

P5218: !_CAS [0] (maybe <- 0x2800015) (Int)
add %i0, 0, %l3
lduw [%l3], %o0
mov %o0, %o5
! move %o5(lower) -> %o0(upper)
sllx %o5, 32, %o0
mov %l4, %l7
cas [%l3], %o5, %l7
! move %l7(lower) -> %o0(lower)
srl %l7, 0, %l3
or %l3, %o0, %o0
add   %l4, 1, %l4

P5219: !_SWAP [7] (maybe <- 0x2800016) (Int) (Branch target of P5661)
mov %l4, %o1
swap  [%i1 + 84], %o1
! move %o1(lower) -> %o1(upper)
sllx %o1, 32, %o1
add   %l4, 1, %l4
ba P5220
nop

TARGET5661:
ba RET5661
nop


P5220: !_DWLD [4] (FP)
ldd [%i0 + 64], %f14
! 1 addresses covered

P5221: !_LD [4] (FP)
ld [%i0 + 64], %f15
! 1 addresses covered
!---- flushing fp results buffer to %f30 ----
fmovd %f0, %f30
fmovd %f2, %f30
fmovd %f4, %f30
fmovd %f6, %f30
fmovd %f8, %f30
fmovd %f10, %f30
fmovd %f12, %f30
fmovd %f14, %f30

P5222: !_PREFETCH [8] (Int)
prefetch [%i1 + 256], 1

P5223: !_LD [12] (FP)
ld [%i3 + 0], %f0
! 1 addresses covered

P5224: !_ST [1] (maybe <- 0x42000023) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i0 + 4 ]

P5225: !_ST [10] (maybe <- 0x42000024) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i2 + 32 ]

P5226: !_ST [8] (maybe <- 0x42000025) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i1 + 256 ]

P5227: !_DWLD [2] (FP)
ldd [%i0 + 8], %f18
! 1 addresses covered
fmovs %f19, %f1

P5228: !_REPLACEMENT [13] (Int)
sethi %hi(0x40), %o5
or %o5, %lo(0x40),  %o5
sethi %hi(0x10000), %l3
or %l3, %lo(0x10000),  %l3
add %i3, %o5, %o5
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]

P5229: !_DWST [1] (maybe <- 0x42000026) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
! 1 th moved, current_fp_src=21 
fmovs  %f16, %f21
fadds  %f16, %f17, %f16
std %f20, [%i0 + 0]

P5230: !_ST [12] (maybe <- 0x42000028) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i3 + 0 ]

P5231: !_DWLD [15] (FP)
ldd [%i3 + 192], %f2
! 1 addresses covered

P5232: !_ST [7] (maybe <- 0x42000029) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i1 + 84 ]

P5233: !_DWLD [4] (FP) (CBR)
ldd [%i0 + 64], %f18
! 1 addresses covered
fmovs %f18, %f3

! cbranch
andcc %l0, 1, %g0
be,pn  %xcc, TARGET5233
nop
RET5233:

! lfsr step begin
srlx %l0, 1, %o5
xnor %o5, %l0, %o5
sllx %o5, 63, %o5
or  %o5, %l0, %l0
srlx %l0, 1, %l0


P5234: !_DWLD [9] (FP)
ldd [%i1 + 512], %f4
! 1 addresses covered

P5235: !_REPLACEMENT [7] (Int) (Branch target of P5140)
sethi %hi(0x54), %l3
or %l3, %lo(0x54),  %l3
sethi %hi(0x10000), %l6
or %l6, %lo(0x10000),  %l6
add %i3, %l3, %l3
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
ba P5236
nop

TARGET5140:
ba RET5140
nop


P5236: !_REPLACEMENT [11] (Int)
sethi %hi(0x40), %o5
or %o5, %lo(0x40),  %o5
sethi %hi(0x10000), %l3
or %l3, %lo(0x10000),  %l3
add %i3, %o5, %o5
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]

P5237: !_ST [4] (maybe <- 0x4200002a) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i0 + 64 ]

P5238: !_PREFETCH [8] (Int) (LE)
wr %g0, 0x88, %asi
prefetcha [%i1 + 256] %asi, 1

P5239: !_DWST [9] (maybe <- 0x4200002b) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
std %f20, [%i1 + 512]

P5240: !_ST [1] (maybe <- 0x4200002c) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i0 + 4 ]

P5241: !_PREFETCH [5] (Int)
prefetch [%i1 + 76], 1

P5242: !_CASX [3] (maybe <- 0x2800017) (Int)
add %i0, 32, %l3
ldx [%l3], %l7
! move %l7(upper) -> %o1(lower)
srlx %l7, 32, %o5
or %o5, %o1, %o1
! move %l7(lower) -> %o2(upper)
sllx %l7, 32, %o2
mov  %l7, %o5
sllx %l4, 32, %l7
casx [%l3], %o5, %l7
! move %l7(upper) -> %o2(lower)
srlx %l7, 32, %l3
or %l3, %o2, %o2
! move %l7(lower) -> %o3(upper)
sllx %l7, 32, %o3
add  %l4, 1, %l4

P5243: !_CASX [3] (maybe <- 0x2800018) (Int)
add %i0, 32, %l3
ldx [%l3], %l7
! move %l7(upper) -> %o3(lower)
srlx %l7, 32, %o5
or %o5, %o3, %o3
! move %l7(lower) -> %o4(upper)
sllx %l7, 32, %o4
mov  %l7, %o5
sllx %l4, 32, %l7
casx [%l3], %o5, %l7
! move %l7(upper) -> %o4(lower)
srlx %l7, 32, %l3
or %l3, %o4, %o4
!---- flushing int results buffer----
mov %o0, %l5
mov %o1, %l5
mov %o2, %l5
mov %o3, %l5
mov %o4, %l5
! move %l7(lower) -> %o0(upper)
sllx %l7, 32, %o0
add  %l4, 1, %l4

P5244: !_ST [5] (maybe <- 0x4200002d) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i1 + 76 ]

P5245: !_ST [3] (maybe <- 0x4200002e) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i0 + 32 ]

P5246: !_DWST [12] (maybe <- 0x4200002f) (FP) (Branch target of P5979)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
std %f20, [%i3 + 0]
ba P5247
nop

TARGET5979:
ba RET5979
nop


P5247: !_CASX [4] (maybe <- 0x2800019) (Int)
add %i0, 64, %l6
ldx [%l6], %o5
! move %o5(upper) -> %o0(lower)
srlx %o5, 32, %l3
or %l3, %o0, %o0
! move %o5(lower) -> %o1(upper)
sllx %o5, 32, %o1
mov  %o5, %l3
sllx %l4, 32, %o5
casx [%l6], %l3, %o5
! move %o5(upper) -> %o1(lower)
srlx %o5, 32, %l6
or %l6, %o1, %o1
! move %o5(lower) -> %o2(upper)
sllx %o5, 32, %o2
add  %l4, 1, %l4

P5248: !_REPLACEMENT [4] (Int)
sethi %hi(0x40), %l3
or %l3, %lo(0x40),  %l3
sethi %hi(0x10000), %l6
or %l6, %lo(0x10000),  %l6
add %i3, %l3, %l3
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]

P5249: !_ST [10] (maybe <- 0x42000030) (FP) (Branch target of P5907)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i2 + 32 ]
ba P5250
nop

TARGET5907:
ba RET5907
nop


P5250: !_NOP (Int)
nop

P5251: !_DWLD [14] (FP)
ldd [%i3 + 128], %f18
! 1 addresses covered
fmovs %f18, %f5

P5252: !_DWLD [3] (FP)
ldd [%i0 + 32], %f6
! 1 addresses covered

P5253: !_LD [11] (FP)
ld [%i2 + 64], %f7
! 1 addresses covered

P5254: !_LD [13] (FP)
ld [%i3 + 64], %f8
! 1 addresses covered

P5255: !_DWST [5] (maybe <- 0x42000031) (FP)
! 0 th moved, current_fp_src=21 
fmovs  %f16, %f21
fadds  %f16, %f17, %f16
std %f20, [%i1 + 72]

P5256: !_CASX [5] (maybe <- 0x280001a) (Int)
add %i1, 72, %l7
ldx [%l7], %l3
! move %l3(upper) -> %o2(lower)
srlx %l3, 32, %l6
or %l6, %o2, %o2
! move %l3(lower) -> %o3(upper)
sllx %l3, 32, %o3
mov  %l3, %l6
mov %l4, %l3
casx [%l7], %l6, %l3
! move %l3(upper) -> %o3(lower)
srlx %l3, 32, %l7
or %l7, %o3, %o3
! move %l3(lower) -> %o4(upper)
sllx %l3, 32, %o4
add  %l4, 1, %l4

P5257: !_LD [2] (FP)
ld [%i0 + 12], %f9
! 1 addresses covered

P5258: !_CASX [12] (maybe <- 0x280001b) (Int)
add %i3, 0, %l7
ldx [%l7], %l3
! move %l3(upper) -> %o4(lower)
srlx %l3, 32, %l6
or %l6, %o4, %o4
!---- flushing int results buffer----
mov %o0, %l5
mov %o1, %l5
mov %o2, %l5
mov %o3, %l5
mov %o4, %l5
! move %l3(lower) -> %o0(upper)
sllx %l3, 32, %o0
mov  %l3, %l6
sllx %l4, 32, %l3
casx [%l7], %l6, %l3
! move %l3(upper) -> %o0(lower)
srlx %l3, 32, %l7
or %l7, %o0, %o0
! move %l3(lower) -> %o1(upper)
sllx %l3, 32, %o1
add  %l4, 1, %l4

P5259: !_REPLACEMENT [15] (Int)
sethi %hi(0xc0), %l6
or %l6, %lo(0xc0),  %l6
sethi %hi(0x10000), %l7
or %l7, %lo(0x10000),  %l7
add %i3, %l6, %l6
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]

P5260: !_PREFETCH [8] (Int) (CBR)
prefetch [%i1 + 256], 1

! cbranch
andcc %l0, 1, %g0
be,pt  %xcc, TARGET5260
nop
RET5260:

! lfsr step begin
srlx %l0, 1, %l3
xnor %l3, %l0, %l3
sllx %l3, 63, %l3
or  %l3, %l0, %l0
srlx %l0, 1, %l0


P5261: !_ST [12] (maybe <- 0x42000032) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i3 + 0 ]

P5262: !_PREFETCH [12] (Int) (Branch target of P5129)
prefetch [%i3 + 0], 1
ba P5263
nop

TARGET5129:
ba RET5129
nop


P5263: !_DWST [13] (maybe <- 0x42000033) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
std %f20, [%i3 + 64]

P5264: !_DWST [5] (maybe <- 0x42000034) (FP)
! 0 th moved, current_fp_src=21 
fmovs  %f16, %f21
fadds  %f16, %f17, %f16
std %f20, [%i1 + 72]

P5265: !_REPLACEMENT [7] (Int)
sethi %hi(0x54), %l7
or %l7, %lo(0x54),  %l7
sethi %hi(0x10000), %o5
or %o5, %lo(0x10000),  %o5
add %i3, %l7, %l7
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]

P5266: !_LD [13] (FP)
ld [%i3 + 64], %f10
! 1 addresses covered

P5267: !_LD [15] (FP)
ld [%i3 + 192], %f11
! 1 addresses covered

P5268: !_LD [13] (FP) (CBR)
ld [%i3 + 64], %f12
! 1 addresses covered

! cbranch
andcc %l0, 1, %g0
be,pn  %xcc, TARGET5268
nop
RET5268:

! lfsr step begin
srlx %l0, 1, %l6
xnor %l6, %l0, %l6
sllx %l6, 63, %l6
or  %l6, %l0, %l0
srlx %l0, 1, %l0


P5269: !_DWLD [0] (FP)
ldd [%i0 + 0], %f18
! 2 addresses covered
fmovs %f18, %f13
fmovs %f19, %f14

P5270: !_NOP (Int)
nop

P5271: !_ST [14] (maybe <- 0x42000035) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i3 + 128 ]

P5272: !_DWLD [11] (FP)
ldd [%i2 + 64], %f18
! 1 addresses covered
fmovs %f18, %f15
!---- flushing fp results buffer to %f30 ----
fmovd %f0, %f30
fmovd %f2, %f30
fmovd %f4, %f30
fmovd %f6, %f30
fmovd %f8, %f30
fmovd %f10, %f30
fmovd %f12, %f30
fmovd %f14, %f30

P5273: !_MEMBAR (Int)
membar #StoreLoad

P5274: !_DWST [8] (maybe <- 0x42000036) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
std %f20, [%i1 + 256]

P5275: !_PREFETCH [12] (Int) (LE)
wr %g0, 0x88, %asi
prefetcha [%i3 + 0] %asi, 1

P5276: !_PREFETCH [9] (Int)
prefetch [%i1 + 512], 1

P5277: !_LD [9] (FP) (CBR)
ld [%i1 + 512], %f0
! 1 addresses covered

! cbranch
andcc %l0, 1, %g0
be,pn  %xcc, TARGET5277
nop
RET5277:

! lfsr step begin
srlx %l0, 1, %l3
xnor %l3, %l0, %l3
sllx %l3, 63, %l3
or  %l3, %l0, %l0
srlx %l0, 1, %l0


P5278: !_DWST [14] (maybe <- 0x42000037) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
std %f20, [%i3 + 128]

P5279: !_MEMBAR (Int)
membar #StoreLoad

P5280: !_DWLD [5] (FP)
ldd [%i1 + 72], %f18
! 1 addresses covered
fmovs %f19, %f1

P5281: !_MEMBAR (Int)
membar #StoreLoad

P5282: !_DWST [6] (maybe <- 0x42000038) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
! 1 th moved, current_fp_src=21 
fmovs  %f16, %f21
fadds  %f16, %f17, %f16
std %f20, [%i1 + 80]

P5283: !_REPLACEMENT [6] (Int)
sethi %hi(0x50), %o5
or %o5, %lo(0x50),  %o5
sethi %hi(0x10000), %l3
or %l3, %lo(0x10000),  %l3
add %i3, %o5, %o5
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]

P5284: !_PREFETCH [12] (Int)
prefetch [%i3 + 0], 1

P5285: !_DWLD [12] (FP)
ldd [%i3 + 0], %f2
! 1 addresses covered

P5286: !_DWLD [11] (FP)
ldd [%i2 + 64], %f18
! 1 addresses covered
fmovs %f18, %f3

P5287: !_PREFETCH [11] (Int)
prefetch [%i2 + 64], 1

P5288: !_LD [8] (FP)
ld [%i1 + 256], %f4
! 1 addresses covered

P5289: !_REPLACEMENT [14] (Int)
sethi %hi(0x80), %l7
or %l7, %lo(0x80),  %l7
sethi %hi(0x10000), %o5
or %o5, %lo(0x10000),  %o5
add %i3, %l7, %l7
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]

P5290: !_DWLD [13] (FP)
ldd [%i3 + 64], %f18
! 1 addresses covered
fmovs %f18, %f5

P5291: !_LD [3] (FP) (Branch target of P5299)
ld [%i0 + 32], %f6
! 1 addresses covered
ba P5292
nop

TARGET5299:
ba RET5299
nop


P5292: !_DWST [10] (maybe <- 0x4200003a) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
std %f20, [%i2 + 32]

P5293: !_DWST [15] (maybe <- 0x4200003b) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
std %f20, [%i3 + 192]

P5294: !_REPLACEMENT [2] (Int)
sethi %hi(0xc), %o5
or %o5, %lo(0xc),  %o5
sethi %hi(0x10000), %l3
or %l3, %lo(0x10000),  %l3
add %i3, %o5, %o5
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]

P5295: !_REPLACEMENT [14] (Int) (CBR)
sethi %hi(0x80), %l7
or %l7, %lo(0x80),  %l7
sethi %hi(0x10000), %o5
or %o5, %lo(0x10000),  %o5
add %i3, %l7, %l7
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]

! cbranch
andcc %l0, 1, %g0
be,pn  %xcc, TARGET5295
nop
RET5295:

! lfsr step begin
srlx %l0, 1, %l6
xnor %l6, %l0, %l6
sllx %l6, 63, %l6
or  %l6, %l0, %l0
srlx %l0, 1, %l0


P5296: !_ST [7] (maybe <- 0x4200003c) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i1 + 84 ]

P5297: !_DWLD [14] (FP) (Branch target of P5815)
ldd [%i3 + 128], %f18
! 1 addresses covered
fmovs %f18, %f7
ba P5298
nop

TARGET5815:
ba RET5815
nop


P5298: !_PREFETCH [15] (Int) (CBR)
prefetch [%i3 + 192], 1

! cbranch
andcc %l0, 1, %g0
be,pt  %xcc, TARGET5298
nop
RET5298:

! lfsr step begin
srlx %l0, 1, %l6
xnor %l6, %l0, %l6
sllx %l6, 63, %l6
or  %l6, %l0, %l0
srlx %l0, 1, %l0


P5299: !_DWLD [10] (FP) (CBR)
ldd [%i2 + 32], %f8
! 1 addresses covered

! cbranch
andcc %l0, 1, %g0
be,pt  %xcc, TARGET5299
nop
RET5299:

! lfsr step begin
srlx %l0, 1, %l7
xnor %l7, %l0, %l7
sllx %l7, 63, %l7
or  %l7, %l0, %l0
srlx %l0, 1, %l0


P5300: !_ST [1] (maybe <- 0x4200003d) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i0 + 4 ]

P5301: !_LD [6] (FP)
ld [%i1 + 80], %f9
! 1 addresses covered

P5302: !_CASX [3] (maybe <- 0x280001c) (Int)
add %i0, 32, %o5
ldx [%o5], %l6
! move %l6(upper) -> %o1(lower)
srlx %l6, 32, %l7
or %l7, %o1, %o1
! move %l6(lower) -> %o2(upper)
sllx %l6, 32, %o2
mov  %l6, %l7
sllx %l4, 32, %l6
casx [%o5], %l7, %l6
! move %l6(upper) -> %o2(lower)
srlx %l6, 32, %o5
or %o5, %o2, %o2
! move %l6(lower) -> %o3(upper)
sllx %l6, 32, %o3
add  %l4, 1, %l4

P5303: !_PREFETCH [10] (Int)
prefetch [%i2 + 32], 1

P5304: !_ST [4] (maybe <- 0x4200003e) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i0 + 64 ]

P5305: !_DWLD [7] (FP)
ldd [%i1 + 80], %f10
! 2 addresses covered

P5306: !_DWLD [2] (FP) (CBR)
ldd [%i0 + 8], %f12
! 1 addresses covered
fmovs %f13, %f12

! cbranch
andcc %l0, 1, %g0
be,pn  %xcc, TARGET5306
nop
RET5306:

! lfsr step begin
srlx %l0, 1, %l6
xnor %l6, %l0, %l6
sllx %l6, 63, %l6
or  %l6, %l0, %l0
srlx %l0, 1, %l0


P5307: !_LD [11] (FP) (Branch target of P5646)
ld [%i2 + 64], %f13
! 1 addresses covered
ba P5308
nop

TARGET5646:
ba RET5646
nop


P5308: !_MEMBAR (Int)
membar #StoreLoad

P5309: !_LD [4] (FP)
ld [%i0 + 64], %f14
! 1 addresses covered

P5310: !_REPLACEMENT [6] (Int)
sethi %hi(0x50), %l7
or %l7, %lo(0x50),  %l7
sethi %hi(0x10000), %o5
or %o5, %lo(0x10000),  %o5
add %i3, %l7, %l7
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]

P5311: !_DWST [14] (maybe <- 0x4200003f) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
std %f20, [%i3 + 128]

P5312: !_DWLD [0] (FP)
ldd [%i0 + 0], %f18
! 2 addresses covered
fmovs %f18, %f15
!---- flushing fp results buffer to %f30 ----
fmovd %f0, %f30
fmovd %f2, %f30
fmovd %f4, %f30
fmovd %f6, %f30
fmovd %f8, %f30
fmovd %f10, %f30
fmovd %f12, %f30
fmovd %f14, %f30
fmovs %f19, %f0

P5313: !_DWLD [15] (FP)
ldd [%i3 + 192], %f18
! 1 addresses covered
fmovs %f18, %f1

P5314: !_ST [5] (maybe <- 0x42000040) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i1 + 76 ]

P5315: !_SWAP [14] (maybe <- 0x280001d) (Int)
mov %l4, %l6
swap  [%i3 + 128], %l6
! move %l6(lower) -> %o3(lower)
srl %l6, 0, %o5
or %o5, %o3, %o3
add   %l4, 1, %l4

P5316: !_DWST [13] (maybe <- 0x42000041) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
std %f20, [%i3 + 64]

P5317: !_REPLACEMENT [3] (Int)
sethi %hi(0x20), %l6
or %l6, %lo(0x20),  %l6
sethi %hi(0x10000), %l7
or %l7, %lo(0x10000),  %l7
add %i3, %l6, %l6
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]

P5318: !_REPLACEMENT [9] (Int)
sethi %hi(0x200), %l3
or %l3, %lo(0x200),  %l3
sethi %hi(0x10000), %l6
or %l6, %lo(0x10000),  %l6
add %i3, %l3, %l3
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]

P5319: !_PREFETCH [7] (Int)
prefetch [%i1 + 84], 1

P5320: !_ST [11] (maybe <- 0x42000042) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i2 + 64 ]

P5321: !_REPLACEMENT [14] (Int)
sethi %hi(0x80), %l7
or %l7, %lo(0x80),  %l7
sethi %hi(0x10000), %o5
or %o5, %lo(0x10000),  %o5
add %i3, %l7, %l7
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]

P5322: !_DWLD [1] (FP)
ldd [%i0 + 0], %f2
! 2 addresses covered

P5323: !_LD [2] (FP)
ld [%i0 + 12], %f4
! 1 addresses covered

P5324: !_ST [4] (maybe <- 0x42000043) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i0 + 64 ]

P5325: !_DWST [11] (maybe <- 0x42000044) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
std %f20, [%i2 + 64]

P5326: !_REPLACEMENT [11] (Int)
sethi %hi(0x40), %o5
or %o5, %lo(0x40),  %o5
sethi %hi(0x10000), %l3
or %l3, %lo(0x10000),  %l3
add %i3, %o5, %o5
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]

P5327: !_LD [9] (FP) (Branch target of P5436)
ld [%i1 + 512], %f5
! 1 addresses covered
ba P5328
nop

TARGET5436:
ba RET5436
nop


P5328: !_ST [7] (maybe <- 0x42000045) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i1 + 84 ]

P5329: !_DWLD [6] (FP)
ldd [%i1 + 80], %f6
! 2 addresses covered

P5330: !_CAS [11] (maybe <- 0x280001e) (Int)
add %i2, 64, %l7
lduw [%l7], %o4
mov %o4, %l6
! move %l6(lower) -> %o4(upper)
sllx %l6, 32, %o4
mov %l4, %l3
cas [%l7], %l6, %l3
! move %l3(lower) -> %o4(lower)
srl %l3, 0, %l7
or %l7, %o4, %o4
!---- flushing int results buffer----
mov %o0, %l5
mov %o1, %l5
mov %o2, %l5
mov %o3, %l5
mov %o4, %l5
add   %l4, 1, %l4

P5331: !_SWAP [2] (maybe <- 0x280001f) (Int)
mov %l4, %o0
swap  [%i0 + 12], %o0
! move %o0(lower) -> %o0(upper)
sllx %o0, 32, %o0
add   %l4, 1, %l4

P5332: !_PREFETCH [5] (Int)
prefetch [%i1 + 76], 1

P5333: !_REPLACEMENT [8] (Int)
sethi %hi(0x100), %l3
or %l3, %lo(0x100),  %l3
sethi %hi(0x10000), %l6
or %l6, %lo(0x10000),  %l6
add %i3, %l3, %l3
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]

P5334: !_LD [15] (FP)
ld [%i3 + 192], %f8
! 1 addresses covered

P5335: !_DWST [12] (maybe <- 0x42000046) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
std %f20, [%i3 + 0]

P5336: !_DWST [3] (maybe <- 0x42000047) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
std %f20, [%i0 + 32]

P5337: !_DWST [5] (maybe <- 0x42000048) (FP)
! 0 th moved, current_fp_src=21 
fmovs  %f16, %f21
fadds  %f16, %f17, %f16
std %f20, [%i1 + 72]

P5338: !_DWST [1] (maybe <- 0x42000049) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
! 1 th moved, current_fp_src=21 
fmovs  %f16, %f21
fadds  %f16, %f17, %f16
std %f20, [%i0 + 0]

P5339: !_LD [1] (FP) (CBR)
ld [%i0 + 4], %f9
! 1 addresses covered

! cbranch
andcc %l0, 1, %g0
be,pn  %xcc, TARGET5339
nop
RET5339:

! lfsr step begin
srlx %l0, 1, %o5
xnor %o5, %l0, %o5
sllx %o5, 63, %o5
or  %o5, %l0, %l0
srlx %l0, 1, %l0


P5340: !_PREFETCH [5] (Int)
prefetch [%i1 + 76], 1

P5341: !_REPLACEMENT [10] (Int)
sethi %hi(0x20), %l3
or %l3, %lo(0x20),  %l3
sethi %hi(0x10000), %l6
or %l6, %lo(0x10000),  %l6
add %i3, %l3, %l3
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]

P5342: !_DWLD [13] (FP)
ldd [%i3 + 64], %f10
! 1 addresses covered

P5343: !_PREFETCH [12] (Int)
prefetch [%i3 + 0], 1

P5344: !_CAS [10] (maybe <- 0x2800020) (Int)
add %i2, 32, %l3
lduw [%l3], %l7
mov %l7, %o5
! move %o5(lower) -> %o0(lower)
or %o5, %o0, %o0
mov %l4, %o1
cas [%l3], %o5, %o1
! move %o1(lower) -> %o1(upper)
sllx %o1, 32, %o1
add   %l4, 1, %l4

P5345: !_ST [14] (maybe <- 0x4200004b) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i3 + 128 ]

P5346: !_ST [15] (maybe <- 0x4200004c) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i3 + 192 ]

P5347: !_PREFETCH [11] (Int) (LE)
wr %g0, 0x88, %asi
prefetcha [%i2 + 64] %asi, 1

P5348: !_DWST [14] (maybe <- 0x4200004d) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
std %f20, [%i3 + 128]

P5349: !_CAS [9] (maybe <- 0x2800021) (Int)
add %i1, 512, %l6
lduw [%l6], %o5
mov %o5, %l3
! move %l3(lower) -> %o1(lower)
or %l3, %o1, %o1
mov %l4, %o2
cas [%l6], %l3, %o2
! move %o2(lower) -> %o2(upper)
sllx %o2, 32, %o2
add   %l4, 1, %l4

P5350: !_DWST [6] (maybe <- 0x4200004e) (FP) (CBR)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
! 1 th moved, current_fp_src=21 
fmovs  %f16, %f21
fadds  %f16, %f17, %f16
std %f20, [%i1 + 80]

! cbranch
andcc %l0, 1, %g0
be,pn  %xcc, TARGET5350
nop
RET5350:

! lfsr step begin
srlx %l0, 1, %o5
xnor %o5, %l0, %o5
sllx %o5, 63, %o5
or  %o5, %l0, %l0
srlx %l0, 1, %l0


P5351: !_ST [15] (maybe <- 0x42000050) (FP) (Branch target of P5594)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i3 + 192 ]
ba P5352
nop

TARGET5594:
ba RET5594
nop


P5352: !_DWST [12] (maybe <- 0x42000051) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
std %f20, [%i3 + 0]

P5353: !_DWLD [9] (FP) (CBR)
ldd [%i1 + 512], %f18
! 1 addresses covered
fmovs %f18, %f11

! cbranch
andcc %l0, 1, %g0
be,pt  %xcc, TARGET5353
nop
RET5353:

! lfsr step begin
srlx %l0, 1, %l7
xnor %l7, %l0, %l7
sllx %l7, 63, %l7
or  %l7, %l0, %l0
srlx %l0, 1, %l0


P5354: !_PREFETCH [14] (Int)
prefetch [%i3 + 128], 1

P5355: !_DWST [3] (maybe <- 0x42000052) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
std %f20, [%i0 + 32]

P5356: !_REPLACEMENT [1] (Int)
sethi %hi(0x4), %l7
or %l7, %lo(0x4),  %l7
sethi %hi(0x10000), %o5
or %o5, %lo(0x10000),  %o5
add %i3, %l7, %l7
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]

P5357: !_PREFETCH [12] (Int)
prefetch [%i3 + 0], 1

P5358: !_ST [12] (maybe <- 0x42000053) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i3 + 0 ]

P5359: !_ST [10] (maybe <- 0x42000054) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i2 + 32 ]

P5360: !_REPLACEMENT [6] (Int)
sethi %hi(0x50), %o5
or %o5, %lo(0x50),  %o5
sethi %hi(0x10000), %l3
or %l3, %lo(0x10000),  %l3
add %i3, %o5, %o5
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]

P5361: !_REPLACEMENT [11] (Int)
sethi %hi(0x40), %l7
or %l7, %lo(0x40),  %l7
sethi %hi(0x10000), %o5
or %o5, %lo(0x10000),  %o5
add %i3, %l7, %l7
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]

P5362: !_REPLACEMENT [2] (Int)
sethi %hi(0xc), %l6
or %l6, %lo(0xc),  %l6
sethi %hi(0x10000), %l7
or %l7, %lo(0x10000),  %l7
add %i3, %l6, %l6
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]

P5363: !_ST [8] (maybe <- 0x42000055) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i1 + 256 ]

P5364: !_DWST [9] (maybe <- 0x42000056) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
std %f20, [%i1 + 512]

P5365: !_DWLD [2] (FP)
ldd [%i0 + 8], %f12
! 1 addresses covered
fmovs %f13, %f12

P5366: !_SWAP [3] (maybe <- 0x2800022) (Int)
mov %l4, %l3
swap  [%i0 + 32], %l3
! move %l3(lower) -> %o2(lower)
srl %l3, 0, %l7
or %l7, %o2, %o2
add   %l4, 1, %l4

P5367: !_PREFETCH [8] (Int)
prefetch [%i1 + 256], 1

P5368: !_ST [4] (maybe <- 0x42000057) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i0 + 64 ]

P5369: !_ST [13] (maybe <- 0x42000058) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i3 + 64 ]

P5370: !_CAS [0] (maybe <- 0x2800023) (Int)
add %i0, 0, %l3
lduw [%l3], %o3
mov %o3, %o5
! move %o5(lower) -> %o3(upper)
sllx %o5, 32, %o3
mov %l4, %l7
cas [%l3], %o5, %l7
! move %l7(lower) -> %o3(lower)
srl %l7, 0, %l3
or %l3, %o3, %o3
add   %l4, 1, %l4

P5371: !_CAS [5] (maybe <- 0x2800024) (Int)
add %i1, 76, %l3
lduw [%l3], %o4
mov %o4, %o5
! move %o5(lower) -> %o4(upper)
sllx %o5, 32, %o4
mov %l4, %l7
cas [%l3], %o5, %l7
! move %l7(lower) -> %o4(lower)
srl %l7, 0, %l3
or %l3, %o4, %o4
!---- flushing int results buffer----
mov %o0, %l5
mov %o1, %l5
mov %o2, %l5
mov %o3, %l5
mov %o4, %l5
add   %l4, 1, %l4

P5372: !_DWST [5] (maybe <- 0x42000059) (FP)
! 0 th moved, current_fp_src=21 
fmovs  %f16, %f21
fadds  %f16, %f17, %f16
std %f20, [%i1 + 72]

P5373: !_DWLD [15] (FP)
ldd [%i3 + 192], %f18
! 1 addresses covered
fmovs %f18, %f13

P5374: !_ST [14] (maybe <- 0x4200005a) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i3 + 128 ]

P5375: !_LD [4] (FP)
ld [%i0 + 64], %f14
! 1 addresses covered

P5376: !_LD [13] (FP)
ld [%i3 + 64], %f15
! 1 addresses covered
!---- flushing fp results buffer to %f30 ----
fmovd %f0, %f30
fmovd %f2, %f30
fmovd %f4, %f30
fmovd %f6, %f30
fmovd %f8, %f30
fmovd %f10, %f30
fmovd %f12, %f30
fmovd %f14, %f30

P5377: !_SWAP [2] (maybe <- 0x2800025) (Int) (Branch target of P5522)
mov %l4, %o0
swap  [%i0 + 12], %o0
! move %o0(lower) -> %o0(upper)
sllx %o0, 32, %o0
add   %l4, 1, %l4
ba P5378
nop

TARGET5522:
ba RET5522
nop


P5378: !_ST [13] (maybe <- 0x4200005b) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i3 + 64 ]

P5379: !_PREFETCH [13] (Int)
prefetch [%i3 + 64], 1

P5380: !_CAS [5] (maybe <- 0x2800026) (Int)
add %i1, 76, %l3
lduw [%l3], %l7
mov %l7, %o5
! move %o5(lower) -> %o0(lower)
or %o5, %o0, %o0
mov %l4, %o1
cas [%l3], %o5, %o1
! move %o1(lower) -> %o1(upper)
sllx %o1, 32, %o1
add   %l4, 1, %l4

P5381: !_REPLACEMENT [13] (Int)
sethi %hi(0x40), %o5
or %o5, %lo(0x40),  %o5
sethi %hi(0x10000), %l3
or %l3, %lo(0x10000),  %l3
add %i3, %o5, %o5
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]

P5382: !_LD [9] (FP)
ld [%i1 + 512], %f0
! 1 addresses covered

P5383: !_DWLD [12] (FP)
ldd [%i3 + 0], %f18
! 1 addresses covered
fmovs %f18, %f1

P5384: !_REPLACEMENT [8] (Int)
sethi %hi(0x100), %l7
or %l7, %lo(0x100),  %l7
sethi %hi(0x10000), %o5
or %o5, %lo(0x10000),  %o5
add %i3, %l7, %l7
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]

P5385: !_LD [8] (FP)
ld [%i1 + 256], %f2
! 1 addresses covered

P5386: !_DWST [2] (maybe <- 0x4200005c) (FP)
! 0 th moved, current_fp_src=21 
fmovs  %f16, %f21
fadds  %f16, %f17, %f16
std %f20, [%i0 + 8]

P5387: !_NOP (Int)
nop

P5388: !_NOP (Int)
nop

P5389: !_ST [12] (maybe <- 0x4200005d) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i3 + 0 ]

P5390: !_PREFETCH [1] (Int)
prefetch [%i0 + 4], 1

P5391: !_PREFETCH [1] (Int)
prefetch [%i0 + 4], 1

P5392: !_PREFETCH [0] (Int) (CBR)
prefetch [%i0 + 0], 1

! cbranch
andcc %l0, 1, %g0
be,pn  %xcc, TARGET5392
nop
RET5392:

! lfsr step begin
srlx %l0, 1, %o5
xnor %o5, %l0, %o5
sllx %o5, 63, %o5
or  %o5, %l0, %l0
srlx %l0, 1, %l0


P5393: !_DWLD [9] (FP)
ldd [%i1 + 512], %f18
! 1 addresses covered
fmovs %f18, %f3

P5394: !_REPLACEMENT [5] (Int)
sethi %hi(0x4c), %l3
or %l3, %lo(0x4c),  %l3
sethi %hi(0x10000), %l6
or %l6, %lo(0x10000),  %l6
add %i3, %l3, %l3
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]

P5395: !_CAS [12] (maybe <- 0x2800027) (Int)
add %i3, 0, %l3
lduw [%l3], %l7
mov %l7, %o5
! move %o5(lower) -> %o1(lower)
or %o5, %o1, %o1
mov %l4, %o2
cas [%l3], %o5, %o2
! move %o2(lower) -> %o2(upper)
sllx %o2, 32, %o2
add   %l4, 1, %l4

P5396: !_LD [11] (FP)
ld [%i2 + 64], %f4
! 1 addresses covered

P5397: !_LD [0] (FP)
ld [%i0 + 0], %f5
! 1 addresses covered

P5398: !_ST [2] (maybe <- 0x4200005e) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i0 + 12 ]

P5399: !_PREFETCH [1] (Int)
prefetch [%i0 + 4], 1

P5400: !_PREFETCH [15] (Int)
prefetch [%i3 + 192], 1

P5401: !_DWLD [10] (FP)
ldd [%i2 + 32], %f6
! 1 addresses covered

P5402: !_ST [12] (maybe <- 0x4200005f) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i3 + 0 ]

P5403: !_MEMBAR (Int)
membar #StoreLoad

P5404: !_DWST [10] (maybe <- 0x42000060) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
std %f20, [%i2 + 32]

P5405: !_ST [6] (maybe <- 0x42000061) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i1 + 80 ]

P5406: !_DWLD [15] (FP)
ldd [%i3 + 192], %f18
! 1 addresses covered
fmovs %f18, %f7

P5407: !_ST [3] (maybe <- 0x42000062) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i0 + 32 ]

P5408: !_ST [14] (maybe <- 0x42000063) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i3 + 128 ]

P5409: !_LD [9] (FP)
ld [%i1 + 512], %f8
! 1 addresses covered

P5410: !_ST [4] (maybe <- 0x42000064) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i0 + 64 ]

P5411: !_DWST [9] (maybe <- 0x42000065) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
std %f20, [%i1 + 512]

P5412: !_SWAP [15] (maybe <- 0x2800028) (Int)
mov %l4, %l6
swap  [%i3 + 192], %l6
! move %l6(lower) -> %o2(lower)
srl %l6, 0, %o5
or %o5, %o2, %o2
add   %l4, 1, %l4

P5413: !_DWST [0] (maybe <- 0x42000066) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
! 1 th moved, current_fp_src=21 
fmovs  %f16, %f21
fadds  %f16, %f17, %f16
std %f20, [%i0 + 0]

P5414: !_DWST [0] (maybe <- 0x42000068) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
! 1 th moved, current_fp_src=21 
fmovs  %f16, %f21
fadds  %f16, %f17, %f16
std %f20, [%i0 + 0]

P5415: !_ST [1] (maybe <- 0x4200006a) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i0 + 4 ]

P5416: !_LD [3] (FP)
ld [%i0 + 32], %f9
! 1 addresses covered

P5417: !_PREFETCH [9] (Int)
prefetch [%i1 + 512], 1

P5418: !_DWLD [5] (FP)
ldd [%i1 + 72], %f10
! 1 addresses covered
fmovs %f11, %f10

P5419: !_REPLACEMENT [8] (Int)
sethi %hi(0x100), %o5
or %o5, %lo(0x100),  %o5
sethi %hi(0x10000), %l3
or %l3, %lo(0x10000),  %l3
add %i3, %o5, %o5
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]

P5420: !_DWLD [6] (FP)
ldd [%i1 + 80], %f18
! 2 addresses covered
fmovs %f18, %f11
fmovs %f19, %f12

P5421: !_MEMBAR (Int)
membar #StoreLoad

P5422: !_REPLACEMENT [15] (Int)
sethi %hi(0xc0), %l7
or %l7, %lo(0xc0),  %l7
sethi %hi(0x10000), %o5
or %o5, %lo(0x10000),  %o5
add %i3, %l7, %l7
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]

P5423: !_CAS [7] (maybe <- 0x2800029) (Int)
add %i1, 84, %l7
lduw [%l7], %o3
mov %o3, %l6
! move %l6(lower) -> %o3(upper)
sllx %l6, 32, %o3
mov %l4, %l3
cas [%l7], %l6, %l3
! move %l3(lower) -> %o3(lower)
srl %l3, 0, %l7
or %l7, %o3, %o3
add   %l4, 1, %l4

P5424: !_CAS [15] (maybe <- 0x280002a) (Int)
add %i3, 192, %l7
lduw [%l7], %o4
mov %o4, %l6
! move %l6(lower) -> %o4(upper)
sllx %l6, 32, %o4
mov %l4, %l3
cas [%l7], %l6, %l3
! move %l3(lower) -> %o4(lower)
srl %l3, 0, %l7
or %l7, %o4, %o4
!---- flushing int results buffer----
mov %o0, %l5
mov %o1, %l5
mov %o2, %l5
mov %o3, %l5
mov %o4, %l5
add   %l4, 1, %l4

P5425: !_DWST [6] (maybe <- 0x4200006b) (FP) (CBR)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
! 1 th moved, current_fp_src=21 
fmovs  %f16, %f21
fadds  %f16, %f17, %f16
std %f20, [%i1 + 80]

! cbranch
andcc %l0, 1, %g0
be,pn  %xcc, TARGET5425
nop
RET5425:

! lfsr step begin
srlx %l0, 1, %l3
xnor %l3, %l0, %l3
sllx %l3, 63, %l3
or  %l3, %l0, %l0
srlx %l0, 1, %l0


P5426: !_DWST [7] (maybe <- 0x4200006d) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
! 1 th moved, current_fp_src=21 
fmovs  %f16, %f21
fadds  %f16, %f17, %f16
std %f20, [%i1 + 80]

P5427: !_DWLD [7] (FP)
ldd [%i1 + 80], %f18
! 2 addresses covered
fmovs %f18, %f13
fmovs %f19, %f14

P5428: !_ST [0] (maybe <- 0x4200006f) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i0 + 0 ]

P5429: !_LD [4] (FP)
ld [%i0 + 64], %f15
! 1 addresses covered
!---- flushing fp results buffer to %f30 ----
fmovd %f0, %f30
fmovd %f2, %f30
fmovd %f4, %f30
fmovd %f6, %f30
fmovd %f8, %f30
fmovd %f10, %f30
fmovd %f12, %f30
fmovd %f14, %f30

P5430: !_REPLACEMENT [3] (Int)
sethi %hi(0x20), %o5
or %o5, %lo(0x20),  %o5
sethi %hi(0x10000), %l3
or %l3, %lo(0x10000),  %l3
add %i3, %o5, %o5
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]

P5431: !_DWST [8] (maybe <- 0x42000070) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
std %f20, [%i1 + 256]

P5432: !_LD [4] (FP)
ld [%i0 + 64], %f0
! 1 addresses covered

P5433: !_DWLD [7] (FP)
ldd [%i1 + 80], %f18
! 2 addresses covered
fmovs %f18, %f1
fmovs %f19, %f2

P5434: !_REPLACEMENT [10] (Int)
sethi %hi(0x20), %l6
or %l6, %lo(0x20),  %l6
sethi %hi(0x10000), %l7
or %l7, %lo(0x10000),  %l7
add %i3, %l6, %l6
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]

P5435: !_DWLD [11] (FP) (Branch target of P5169)
ldd [%i2 + 64], %f18
! 1 addresses covered
fmovs %f18, %f3
ba P5436
nop

TARGET5169:
ba RET5169
nop


P5436: !_REPLACEMENT [9] (Int) (CBR)
sethi %hi(0x200), %l3
or %l3, %lo(0x200),  %l3
sethi %hi(0x10000), %l6
or %l6, %lo(0x10000),  %l6
add %i3, %l3, %l3
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]

! cbranch
andcc %l0, 1, %g0
be,pn  %xcc, TARGET5436
nop
RET5436:

! lfsr step begin
srlx %l0, 1, %o5
xnor %o5, %l0, %o5
sllx %o5, 63, %o5
or  %o5, %l0, %l0
srlx %l0, 1, %l0


P5437: !_DWST [1] (maybe <- 0x42000071) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
! 1 th moved, current_fp_src=21 
fmovs  %f16, %f21
fadds  %f16, %f17, %f16
std %f20, [%i0 + 0]

P5438: !_DWLD [14] (FP)
ldd [%i3 + 128], %f4
! 1 addresses covered

P5439: !_DWLD [12] (FP)
ldd [%i3 + 0], %f18
! 1 addresses covered
fmovs %f18, %f5

P5440: !_DWST [3] (maybe <- 0x42000073) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
std %f20, [%i0 + 32]

P5441: !_LD [4] (FP)
ld [%i0 + 64], %f6
! 1 addresses covered

P5442: !_DWST [2] (maybe <- 0x42000074) (FP)
! 0 th moved, current_fp_src=21 
fmovs  %f16, %f21
fadds  %f16, %f17, %f16
std %f20, [%i0 + 8]

P5443: !_DWST [9] (maybe <- 0x42000075) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
std %f20, [%i1 + 512]

P5444: !_LD [1] (FP)
ld [%i0 + 4], %f7
! 1 addresses covered

P5445: !_ST [10] (maybe <- 0x42000076) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i2 + 32 ]

P5446: !_ST [11] (maybe <- 0x42000077) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i2 + 64 ]

P5447: !_PREFETCH [13] (Int)
prefetch [%i3 + 64], 1

P5448: !_SWAP [5] (maybe <- 0x280002b) (Int) (LE)
wr %g0, 0x88, %asi
mov %l4, %o0
! Change single-word-level endianess (big endian <-> little endian) 
sethi %hi(0xff00ff00), %l7
or %l7, %lo(0xff00ff00), %l7
and %o0, %l7, %o5
srl %o5, 8, %o5
sll %o0, 8, %o0
and %o0, %l7, %o0
or %o0, %o5, %o0
srl %o0, 16, %o5
sll %o0, 16, %o0
srl %o0, 0, %o0
or %o0, %o5, %o0
swapa  [%i1 + 76] %asi, %o0
! move %o0(lower) -> %o0(upper)
sllx %o0, 32, %o0
add   %l4, 1, %l4

P5449: !_SWAP [10] (maybe <- 0x280002c) (Int)
mov %l4, %o5
swap  [%i2 + 32], %o5
! move %o5(lower) -> %o0(lower)
srl %o5, 0, %l6
or %l6, %o0, %o0
add   %l4, 1, %l4

P5450: !_LD [9] (FP)
ld [%i1 + 512], %f8
! 1 addresses covered

P5451: !_SWAP [5] (maybe <- 0x280002d) (Int)
mov %l4, %o1
swap  [%i1 + 76], %o1
! move %o1(lower) -> %o1(upper)
sllx %o1, 32, %o1
add   %l4, 1, %l4

P5452: !_DWST [6] (maybe <- 0x42000078) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
! 1 th moved, current_fp_src=21 
fmovs  %f16, %f21
fadds  %f16, %f17, %f16
std %f20, [%i1 + 80]

P5453: !_REPLACEMENT [4] (Int)
sethi %hi(0x40), %l7
or %l7, %lo(0x40),  %l7
sethi %hi(0x10000), %o5
or %o5, %lo(0x10000),  %o5
add %i3, %l7, %l7
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]

P5454: !_DWST [9] (maybe <- 0x4200007a) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
std %f20, [%i1 + 512]

P5455: !_ST [9] (maybe <- 0x4200007b) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i1 + 512 ]

P5456: !_DWLD [5] (FP)
ldd [%i1 + 72], %f18
! 1 addresses covered
fmovs %f19, %f9

P5457: !_ST [7] (maybe <- 0x4200007c) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i1 + 84 ]

P5458: !_DWST [1] (maybe <- 0x4200007d) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
! 1 th moved, current_fp_src=21 
fmovs  %f16, %f21
fadds  %f16, %f17, %f16
std %f20, [%i0 + 0]

P5459: !_DWLD [15] (FP)
ldd [%i3 + 192], %f10
! 1 addresses covered

P5460: !_ST [14] (maybe <- 0x4200007f) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i3 + 128 ]

P5461: !_DWLD [5] (FP)
ldd [%i1 + 72], %f18
! 1 addresses covered
fmovs %f19, %f11

P5462: !_DWST [14] (maybe <- 0x42000080) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
std %f20, [%i3 + 128]

P5463: !_LD [8] (FP)
ld [%i1 + 256], %f12
! 1 addresses covered

P5464: !_CASX [11] (maybe <- 0x280002e) (Int)
add %i2, 64, %l3
ldx [%l3], %l7
! move %l7(upper) -> %o1(lower)
srlx %l7, 32, %o5
or %o5, %o1, %o1
! move %l7(lower) -> %o2(upper)
sllx %l7, 32, %o2
mov  %l7, %o5
sllx %l4, 32, %l7
casx [%l3], %o5, %l7
! move %l7(upper) -> %o2(lower)
srlx %l7, 32, %l3
or %l3, %o2, %o2
! move %l7(lower) -> %o3(upper)
sllx %l7, 32, %o3
add  %l4, 1, %l4

P5465: !_DWST [0] (maybe <- 0x42000081) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
! 1 th moved, current_fp_src=21 
fmovs  %f16, %f21
fadds  %f16, %f17, %f16
std %f20, [%i0 + 0]

P5466: !_DWLD [0] (FP) (Branch target of P5536)
ldd [%i0 + 0], %f18
! 2 addresses covered
fmovs %f18, %f13
fmovs %f19, %f14
ba P5467
nop

TARGET5536:
ba RET5536
nop


P5467: !_DWLD [15] (FP)
ldd [%i3 + 192], %f18
! 1 addresses covered
fmovs %f18, %f15
!---- flushing fp results buffer to %f30 ----
fmovd %f0, %f30
fmovd %f2, %f30
fmovd %f4, %f30
fmovd %f6, %f30
fmovd %f8, %f30
fmovd %f10, %f30
fmovd %f12, %f30
fmovd %f14, %f30

P5468: !_PREFETCH [13] (Int)
prefetch [%i3 + 64], 1

P5469: !_REPLACEMENT [4] (Int)
sethi %hi(0x40), %l7
or %l7, %lo(0x40),  %l7
sethi %hi(0x10000), %o5
or %o5, %lo(0x10000),  %o5
add %i3, %l7, %l7
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]

P5470: !_REPLACEMENT [12] (Int)
sethi %hi(0x0), %l6
or %l6, %lo(0x0),  %l6
sethi %hi(0x10000), %l7
or %l7, %lo(0x10000),  %l7
add %i3, %l6, %l6
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]

P5471: !_DWST [7] (maybe <- 0x42000083) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
! 1 th moved, current_fp_src=21 
fmovs  %f16, %f21
fadds  %f16, %f17, %f16
std %f20, [%i1 + 80]

P5472: !_MEMBAR (Int)
membar #StoreLoad

P5473: !_DWLD [9] (FP)
ldd [%i1 + 512], %f0
! 1 addresses covered

P5474: !_ST [14] (maybe <- 0x42000085) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i3 + 128 ]

P5475: !_LD [5] (FP)
ld [%i1 + 76], %f1
! 1 addresses covered

P5476: !_NOP (Int)
nop

P5477: !_LD [6] (FP)
ld [%i1 + 80], %f2
! 1 addresses covered

P5478: !_LD [13] (FP)
ld [%i3 + 64], %f3
! 1 addresses covered

P5479: !_DWST [6] (maybe <- 0x42000086) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
! 1 th moved, current_fp_src=21 
fmovs  %f16, %f21
fadds  %f16, %f17, %f16
std %f20, [%i1 + 80]

P5480: !_NOP (Int)
nop

P5481: !_DWST [4] (maybe <- 0x42000088) (FP) (Branch target of P5233)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
std %f20, [%i0 + 64]
ba P5482
nop

TARGET5233:
ba RET5233
nop


P5482: !_LD [3] (FP)
ld [%i0 + 32], %f4
! 1 addresses covered

P5483: !_ST [6] (maybe <- 0x42000089) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i1 + 80 ]

P5484: !_CAS [9] (maybe <- 0x280002f) (Int)
add %i1, 512, %l3
lduw [%l3], %l7
mov %l7, %o5
! move %o5(lower) -> %o3(lower)
or %o5, %o3, %o3
mov %l4, %o4
cas [%l3], %o5, %o4
! move %o4(lower) -> %o4(upper)
sllx %o4, 32, %o4
add   %l4, 1, %l4

P5485: !_REPLACEMENT [0] (Int)
sethi %hi(0x0), %o5
or %o5, %lo(0x0),  %o5
sethi %hi(0x10000), %l3
or %l3, %lo(0x10000),  %l3
add %i3, %o5, %o5
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]

P5486: !_REPLACEMENT [5] (Int)
sethi %hi(0x4c), %l7
or %l7, %lo(0x4c),  %l7
sethi %hi(0x10000), %o5
or %o5, %lo(0x10000),  %o5
add %i3, %l7, %l7
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]

P5487: !_SWAP [5] (maybe <- 0x2800030) (Int)
mov %l4, %o5
swap  [%i1 + 76], %o5
! move %o5(lower) -> %o4(lower)
srl %o5, 0, %l6
or %l6, %o4, %o4
!---- flushing int results buffer----
mov %o0, %l5
mov %o1, %l5
mov %o2, %l5
mov %o3, %l5
mov %o4, %l5
add   %l4, 1, %l4

P5488: !_MEMBAR (Int)
membar #StoreLoad

P5489: !_MEMBAR (Int)
membar #StoreLoad

P5490: !_REPLACEMENT [13] (Int)
sethi %hi(0x40), %l3
or %l3, %lo(0x40),  %l3
sethi %hi(0x10000), %l6
or %l6, %lo(0x10000),  %l6
add %i3, %l3, %l3
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]

P5491: !_MEMBAR (Int)
membar #StoreLoad

P5492: !_SWAP [0] (maybe <- 0x2800031) (Int)
mov %l4, %o0
swap  [%i0 + 0], %o0
! move %o0(lower) -> %o0(upper)
sllx %o0, 32, %o0
add   %l4, 1, %l4

P5493: !_CASX [11] (maybe <- 0x2800032) (Int) (LE)
! Change single-word-level endianess (big endian <-> little endian) 
sethi %hi(0xff00ff00), %o5
or %o5, %lo(0xff00ff00), %o5
and %l4, %o5, %l7
srl %l7, 8, %l7
sll %l4, 8, %l3
and %l3, %o5, %l3
or %l3, %l7, %l3
srl %l3, 16, %l7
sll %l3, 16, %l3
srl %l3, 0, %l3
or %l3, %l7, %l3
wr %g0, 0x88, %asi
add %i2, 64, %o5
ldxa [%o5] %asi, %l6
! move %l6(lower) -> %o0(lower)
srl %l6, 0, %l7
or %l7, %o0, %o0
! move %l6(upper) -> %o1(upper)
or %l6, %g0, %o1
mov  %l6, %l7
mov  %l3, %l6
casxa [%o5] %asi, %l7, %l6
! move %l6(lower) -> %o1(lower)
srlx %o1, 32, %o1
sllx %o1, 32, %o1
srl %l6, 0, %o5
or %o5, %o1, %o1
! move %l6(upper) -> %o2(upper)
or %l6, %g0, %o2
add  %l4, 1, %l4

P5494: !_REPLACEMENT [7] (Int)
sethi %hi(0x54), %l7
or %l7, %lo(0x54),  %l7
sethi %hi(0x10000), %o5
or %o5, %lo(0x10000),  %o5
add %i3, %l7, %l7
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]

P5495: !_LD [15] (FP)
ld [%i3 + 192], %f5
! 1 addresses covered

P5496: !_DWST [12] (maybe <- 0x4200008a) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
std %f20, [%i3 + 0]

P5497: !_PREFETCH [8] (Int)
prefetch [%i1 + 256], 1

P5498: !_CAS [4] (maybe <- 0x2800033) (Int)
add %i0, 64, %l6
lduw [%l6], %o5
mov %o5, %l3
! move %l3(lower) -> %o2(lower)
srlx %o2, 32, %o2
sllx %o2, 32, %o2
or %l3, %o2, %o2
mov %l4, %o3
cas [%l6], %l3, %o3
! move %o3(lower) -> %o3(upper)
sllx %o3, 32, %o3
add   %l4, 1, %l4

P5499: !_PREFETCH [0] (Int)
prefetch [%i0 + 0], 1

P5500: !_LD [14] (FP)
ld [%i3 + 128], %f6
! 1 addresses covered

P5501: !_DWLD [1] (FP)
ldd [%i0 + 0], %f18
! 2 addresses covered
fmovs %f18, %f7
fmovs %f19, %f8

P5502: !_CAS [8] (maybe <- 0x2800034) (Int)
add %i1, 256, %l6
lduw [%l6], %o5
mov %o5, %l3
! move %l3(lower) -> %o3(lower)
or %l3, %o3, %o3
mov %l4, %o4
cas [%l6], %l3, %o4
! move %o4(lower) -> %o4(upper)
sllx %o4, 32, %o4
add   %l4, 1, %l4

P5503: !_ST [8] (maybe <- 0x4200008b) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i1 + 256 ]

P5504: !_DWST [3] (maybe <- 0x4200008c) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
std %f20, [%i0 + 32]

P5505: !_REPLACEMENT [2] (Int)
sethi %hi(0xc), %l7
or %l7, %lo(0xc),  %l7
sethi %hi(0x10000), %o5
or %o5, %lo(0x10000),  %o5
add %i3, %l7, %l7
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]

P5506: !_ST [0] (maybe <- 0x4200008d) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i0 + 0 ]

P5507: !_LD [15] (FP)
ld [%i3 + 192], %f9
! 1 addresses covered

P5508: !_DWST [15] (maybe <- 0x4200008e) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
std %f20, [%i3 + 192]

P5509: !_DWLD [7] (FP)
ldd [%i1 + 80], %f10
! 2 addresses covered

P5510: !_LD [13] (FP)
ld [%i3 + 64], %f12
! 1 addresses covered

P5511: !_REPLACEMENT [9] (Int)
sethi %hi(0x200), %o5
or %o5, %lo(0x200),  %o5
sethi %hi(0x10000), %l3
or %l3, %lo(0x10000),  %l3
add %i3, %o5, %o5
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]

P5512: !_ST [0] (maybe <- 0x4200008f) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i0 + 0 ]

P5513: !_REPLACEMENT [13] (Int)
sethi %hi(0x40), %l6
or %l6, %lo(0x40),  %l6
sethi %hi(0x10000), %l7
or %l7, %lo(0x10000),  %l7
add %i3, %l6, %l6
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]

P5514: !_CAS [3] (maybe <- 0x2800035) (Int)
add %i0, 32, %l6
lduw [%l6], %o5
mov %o5, %l3
! move %l3(lower) -> %o4(lower)
or %l3, %o4, %o4
!---- flushing int results buffer----
mov %o0, %l5
mov %o1, %l5
mov %o2, %l5
mov %o3, %l5
mov %o4, %l5
mov %l4, %o0
cas [%l6], %l3, %o0
! move %o0(lower) -> %o0(upper)
sllx %o0, 32, %o0
add   %l4, 1, %l4

P5515: !_DWLD [5] (FP) (Branch target of P5350)
ldd [%i1 + 72], %f18
! 1 addresses covered
fmovs %f19, %f13
ba P5516
nop

TARGET5350:
ba RET5350
nop


P5516: !_ST [13] (maybe <- 0x42000090) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i3 + 64 ]

P5517: !_ST [9] (maybe <- 0x42000091) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i1 + 512 ]

P5518: !_ST [9] (maybe <- 0x42000092) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i1 + 512 ]

P5519: !_ST [14] (maybe <- 0x42000093) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i3 + 128 ]

P5520: !_LD [12] (FP)
ld [%i3 + 0], %f14
! 1 addresses covered

P5521: !_CAS [8] (maybe <- 0x2800036) (Int)
add %i1, 256, %l6
lduw [%l6], %o5
mov %o5, %l3
! move %l3(lower) -> %o0(lower)
or %l3, %o0, %o0
mov %l4, %o1
cas [%l6], %l3, %o1
! move %o1(lower) -> %o1(upper)
sllx %o1, 32, %o1
add   %l4, 1, %l4

P5522: !_PREFETCH [8] (Int) (CBR)
prefetch [%i1 + 256], 1

! cbranch
andcc %l0, 1, %g0
be,pn  %xcc, TARGET5522
nop
RET5522:

! lfsr step begin
srlx %l0, 1, %l3
xnor %l3, %l0, %l3
sllx %l3, 63, %l3
or  %l3, %l0, %l0
srlx %l0, 1, %l0


P5523: !_PREFETCH [9] (Int) (Branch target of P5277)
prefetch [%i1 + 512], 1
ba P5524
nop

TARGET5277:
ba RET5277
nop


P5524: !_SWAP [4] (maybe <- 0x2800037) (Int)
mov %l4, %o5
swap  [%i0 + 64], %o5
! move %o5(lower) -> %o1(lower)
srl %o5, 0, %l6
or %l6, %o1, %o1
add   %l4, 1, %l4

P5525: !_REPLACEMENT [4] (Int)
sethi %hi(0x40), %l3
or %l3, %lo(0x40),  %l3
sethi %hi(0x10000), %l6
or %l6, %lo(0x10000),  %l6
add %i3, %l3, %l3
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]

P5526: !_ST [0] (maybe <- 0x42000094) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i0 + 0 ]

P5527: !_ST [8] (maybe <- 0x42000095) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i1 + 256 ]

P5528: !_CASX [9] (maybe <- 0x2800038) (Int)
add %i1, 512, %l7
ldx [%l7], %o2
! move %o2(upper) -> %o2(upper)
! move %o2(lower) -> %o2(lower)
mov  %o2, %l6
sllx %l4, 32, %o3
casx [%l7], %l6, %o3
! move %o3(upper) -> %o3(upper)
! move %o3(lower) -> %o3(lower)
add  %l4, 1, %l4

P5529: !_PREFETCH [7] (Int)
prefetch [%i1 + 84], 1

P5530: !_CAS [4] (maybe <- 0x2800039) (Int)
add %i0, 64, %l7
lduw [%l7], %o4
mov %o4, %l6
! move %l6(lower) -> %o4(upper)
sllx %l6, 32, %o4
mov %l4, %l3
cas [%l7], %l6, %l3
! move %l3(lower) -> %o4(lower)
srl %l3, 0, %l7
or %l7, %o4, %o4
!---- flushing int results buffer----
mov %o0, %l5
mov %o1, %l5
mov %o2, %l5
mov %o3, %l5
mov %o4, %l5
add   %l4, 1, %l4

P5531: !_CAS [1] (maybe <- 0x280003a) (Int)
add %i0, 4, %l7
lduw [%l7], %o0
mov %o0, %l6
! move %l6(lower) -> %o0(upper)
sllx %l6, 32, %o0
mov %l4, %l3
cas [%l7], %l6, %l3
! move %l3(lower) -> %o0(lower)
srl %l3, 0, %l7
or %l7, %o0, %o0
add   %l4, 1, %l4

P5532: !_LD [2] (FP) (Branch target of P5700)
ld [%i0 + 12], %f15
! 1 addresses covered
!---- flushing fp results buffer to %f30 ----
fmovd %f0, %f30
fmovd %f2, %f30
fmovd %f4, %f30
fmovd %f6, %f30
fmovd %f8, %f30
fmovd %f10, %f30
fmovd %f12, %f30
fmovd %f14, %f30
ba P5533
nop

TARGET5700:
ba RET5700
nop


P5533: !_SWAP [11] (maybe <- 0x280003b) (Int)
mov %l4, %o1
swap  [%i2 + 64], %o1
! move %o1(lower) -> %o1(upper)
sllx %o1, 32, %o1
add   %l4, 1, %l4

P5534: !_LD [6] (FP)
ld [%i1 + 80], %f0
! 1 addresses covered

P5535: !_ST [0] (maybe <- 0x42000096) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i0 + 0 ]

P5536: !_DWST [11] (maybe <- 0x42000097) (FP) (CBR)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
std %f20, [%i2 + 64]

! cbranch
andcc %l0, 1, %g0
be,pt  %xcc, TARGET5536
nop
RET5536:

! lfsr step begin
srlx %l0, 1, %l7
xnor %l7, %l0, %l7
sllx %l7, 63, %l7
or  %l7, %l0, %l0
srlx %l0, 1, %l0


P5537: !_DWLD [10] (FP)
ldd [%i2 + 32], %f18
! 1 addresses covered
fmovs %f18, %f1

P5538: !_DWLD [9] (FP)
ldd [%i1 + 512], %f2
! 1 addresses covered

P5539: !_DWLD [8] (FP)
ldd [%i1 + 256], %f18
! 1 addresses covered
fmovs %f18, %f3

P5540: !_REPLACEMENT [4] (Int)
sethi %hi(0x40), %o5
or %o5, %lo(0x40),  %o5
sethi %hi(0x10000), %l3
or %l3, %lo(0x10000),  %l3
add %i3, %o5, %o5
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]

P5541: !_DWLD [10] (FP)
ldd [%i2 + 32], %f4
! 1 addresses covered

P5542: !_ST [12] (maybe <- 0x42000098) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i3 + 0 ]

P5543: !_LD [3] (FP)
ld [%i0 + 32], %f5
! 1 addresses covered

P5544: !_REPLACEMENT [14] (Int)
sethi %hi(0x80), %l6
or %l6, %lo(0x80),  %l6
sethi %hi(0x10000), %l7
or %l7, %lo(0x10000),  %l7
add %i3, %l6, %l6
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]

P5545: !_DWST [7] (maybe <- 0x42000099) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
! 1 th moved, current_fp_src=21 
fmovs  %f16, %f21
fadds  %f16, %f17, %f16
std %f20, [%i1 + 80]

P5546: !_LD [7] (FP)
ld [%i1 + 84], %f6
! 1 addresses covered

P5547: !_REPLACEMENT [2] (Int)
sethi %hi(0xc), %o5
or %o5, %lo(0xc),  %o5
sethi %hi(0x10000), %l3
or %l3, %lo(0x10000),  %l3
add %i3, %o5, %o5
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]

P5548: !_LD [7] (FP)
ld [%i1 + 84], %f7
! 1 addresses covered

P5549: !_ST [6] (maybe <- 0x4200009b) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i1 + 80 ]

P5550: !_PREFETCH [11] (Int)
prefetch [%i2 + 64], 1

P5551: !_LD [4] (FP)
ld [%i0 + 64], %f8
! 1 addresses covered

P5552: !_REPLACEMENT [13] (Int) (Branch target of P5298)
sethi %hi(0x40), %l6
or %l6, %lo(0x40),  %l6
sethi %hi(0x10000), %l7
or %l7, %lo(0x10000),  %l7
add %i3, %l6, %l6
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
ba P5553
nop

TARGET5298:
ba RET5298
nop


P5553: !_DWLD [5] (FP)
ldd [%i1 + 72], %f18
! 1 addresses covered
fmovs %f19, %f9

P5554: !_MEMBAR (Int)
membar #StoreLoad

P5555: !_DWLD [11] (FP)
ldd [%i2 + 64], %f10
! 1 addresses covered

P5556: !_ST [1] (maybe <- 0x4200009c) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i0 + 4 ]

P5557: !_DWST [5] (maybe <- 0x4200009d) (FP)
! 0 th moved, current_fp_src=21 
fmovs  %f16, %f21
fadds  %f16, %f17, %f16
std %f20, [%i1 + 72]

P5558: !_DWLD [13] (FP)
ldd [%i3 + 64], %f18
! 1 addresses covered
fmovs %f18, %f11

P5559: !_DWST [1] (maybe <- 0x4200009e) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
! 1 th moved, current_fp_src=21 
fmovs  %f16, %f21
fadds  %f16, %f17, %f16
std %f20, [%i0 + 0]

P5560: !_REPLACEMENT [5] (Int)
sethi %hi(0x4c), %l6
or %l6, %lo(0x4c),  %l6
sethi %hi(0x10000), %l7
or %l7, %lo(0x10000),  %l7
add %i3, %l6, %l6
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]

P5561: !_LD [2] (FP)
ld [%i0 + 12], %f12
! 1 addresses covered

P5562: !_ST [6] (maybe <- 0x420000a0) (FP) (CBR)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i1 + 80 ]

! cbranch
andcc %l0, 1, %g0
be,pt  %xcc, TARGET5562
nop
RET5562:

! lfsr step begin
srlx %l0, 1, %o5
xnor %o5, %l0, %o5
sllx %o5, 63, %o5
or  %o5, %l0, %l0
srlx %l0, 1, %l0


P5563: !_PREFETCH [9] (Int)
prefetch [%i1 + 512], 1

P5564: !_ST [1] (maybe <- 0x420000a1) (FP) (CBR)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i0 + 4 ]

! cbranch
andcc %l0, 1, %g0
be,pn  %xcc, TARGET5564
nop
RET5564:

! lfsr step begin
srlx %l0, 1, %o5
xnor %o5, %l0, %o5
sllx %o5, 63, %o5
or  %o5, %l0, %l0
srlx %l0, 1, %l0


P5565: !_ST [3] (maybe <- 0x420000a2) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i0 + 32 ]

P5566: !_LD [14] (FP)
ld [%i3 + 128], %f13
! 1 addresses covered

P5567: !_REPLACEMENT [7] (Int)
sethi %hi(0x54), %o5
or %o5, %lo(0x54),  %o5
sethi %hi(0x10000), %l3
or %l3, %lo(0x10000),  %l3
add %i3, %o5, %o5
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]

P5568: !_REPLACEMENT [1] (Int)
sethi %hi(0x4), %l7
or %l7, %lo(0x4),  %l7
sethi %hi(0x10000), %o5
or %o5, %lo(0x10000),  %o5
add %i3, %l7, %l7
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]

P5569: !_CAS [0] (maybe <- 0x280003c) (Int) (CBR)
add %i0, 0, %l7
lduw [%l7], %l3
mov %l3, %l6
! move %l6(lower) -> %o1(lower)
or %l6, %o1, %o1
mov %l4, %o2
cas [%l7], %l6, %o2
! move %o2(lower) -> %o2(upper)
sllx %o2, 32, %o2
add   %l4, 1, %l4

! cbranch
andcc %l0, 1, %g0
be,pt  %xcc, TARGET5569
nop
RET5569:

! lfsr step begin
srlx %l0, 1, %l6
xnor %l6, %l0, %l6
sllx %l6, 63, %l6
or  %l6, %l0, %l0
srlx %l0, 1, %l0


P5570: !_NOP (Int)
nop

P5571: !_LD [12] (FP)
ld [%i3 + 0], %f14
! 1 addresses covered

P5572: !_REPLACEMENT [8] (Int)
sethi %hi(0x100), %l7
or %l7, %lo(0x100),  %l7
sethi %hi(0x10000), %o5
or %o5, %lo(0x10000),  %o5
add %i3, %l7, %l7
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]

P5573: !_DWLD [2] (FP)
ldd [%i0 + 8], %f18
! 1 addresses covered
fmovs %f19, %f15
!---- flushing fp results buffer to %f30 ----
fmovd %f0, %f30
fmovd %f2, %f30
fmovd %f4, %f30
fmovd %f6, %f30
fmovd %f8, %f30
fmovd %f10, %f30
fmovd %f12, %f30
fmovd %f14, %f30

P5574: !_LD [6] (FP) (Branch target of P5975)
ld [%i1 + 80], %f0
! 1 addresses covered
ba P5575
nop

TARGET5975:
ba RET5975
nop


P5575: !_PREFETCH [7] (Int)
prefetch [%i1 + 84], 1

P5576: !_DWST [4] (maybe <- 0x420000a3) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
std %f20, [%i0 + 64]

P5577: !_REPLACEMENT [12] (Int)
sethi %hi(0x0), %l3
or %l3, %lo(0x0),  %l3
sethi %hi(0x10000), %l6
or %l6, %lo(0x10000),  %l6
add %i3, %l3, %l3
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]

P5578: !_LD [13] (FP)
ld [%i3 + 64], %f1
! 1 addresses covered

P5579: !_CAS [1] (maybe <- 0x280003d) (Int)
add %i0, 4, %l3
lduw [%l3], %l7
mov %l7, %o5
! move %o5(lower) -> %o2(lower)
or %o5, %o2, %o2
mov %l4, %o3
cas [%l3], %o5, %o3
! move %o3(lower) -> %o3(upper)
sllx %o3, 32, %o3
add   %l4, 1, %l4

P5580: !_ST [2] (maybe <- 0x420000a4) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i0 + 12 ]

P5581: !_PREFETCH [0] (Int)
prefetch [%i0 + 0], 1

P5582: !_DWST [0] (maybe <- 0x420000a5) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
! 1 th moved, current_fp_src=21 
fmovs  %f16, %f21
fadds  %f16, %f17, %f16
std %f20, [%i0 + 0]

P5583: !_CAS [2] (maybe <- 0x280003e) (Int)
add %i0, 12, %l7
lduw [%l7], %l3
mov %l3, %l6
! move %l6(lower) -> %o3(lower)
or %l6, %o3, %o3
mov %l4, %o4
cas [%l7], %l6, %o4
! move %o4(lower) -> %o4(upper)
sllx %o4, 32, %o4
add   %l4, 1, %l4

P5584: !_DWLD [3] (FP)
ldd [%i0 + 32], %f2
! 1 addresses covered

P5585: !_LD [5] (FP)
ld [%i1 + 76], %f3
! 1 addresses covered

P5586: !_DWST [0] (maybe <- 0x420000a7) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
! 1 th moved, current_fp_src=21 
fmovs  %f16, %f21
fadds  %f16, %f17, %f16
std %f20, [%i0 + 0]

P5587: !_REPLACEMENT [2] (Int)
sethi %hi(0xc), %l3
or %l3, %lo(0xc),  %l3
sethi %hi(0x10000), %l6
or %l6, %lo(0x10000),  %l6
add %i3, %l3, %l3
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]

P5588: !_CASX [14] (maybe <- 0x280003f) (Int)
add %i3, 128, %l3
ldx [%l3], %l7
! move %l7(upper) -> %o4(lower)
srlx %l7, 32, %o5
or %o5, %o4, %o4
!---- flushing int results buffer----
mov %o0, %l5
mov %o1, %l5
mov %o2, %l5
mov %o3, %l5
mov %o4, %l5
! move %l7(lower) -> %o0(upper)
sllx %l7, 32, %o0
mov  %l7, %o5
sllx %l4, 32, %l7
casx [%l3], %o5, %l7
! move %l7(upper) -> %o0(lower)
srlx %l7, 32, %l3
or %l3, %o0, %o0
! move %l7(lower) -> %o1(upper)
sllx %l7, 32, %o1
add  %l4, 1, %l4

P5589: !_DWLD [5] (FP)
ldd [%i1 + 72], %f4
! 1 addresses covered
fmovs %f5, %f4

P5590: !_PREFETCH [11] (Int)
prefetch [%i2 + 64], 1

P5591: !_REPLACEMENT [3] (Int)
sethi %hi(0x20), %o5
or %o5, %lo(0x20),  %o5
sethi %hi(0x10000), %l3
or %l3, %lo(0x10000),  %l3
add %i3, %o5, %o5
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]

P5592: !_LD [15] (FP)
ld [%i3 + 192], %f5
! 1 addresses covered

P5593: !_CASX [1] (maybe <- 0x2800040) (Int)
add %i0, 0, %o5
ldx [%o5], %l6
! move %l6(upper) -> %o1(lower)
srlx %l6, 32, %l7
or %l7, %o1, %o1
! move %l6(lower) -> %o2(upper)
sllx %l6, 32, %o2
mov %l6, %l7
sllx %l4, 32, %l6
add  %l4, 1, %l4
or   %l4, %l6, %l6
casx [%o5], %l7, %l6
! move %l6(upper) -> %o2(lower)
srlx %l6, 32, %o5
or %o5, %o2, %o2
! move %l6(lower) -> %o3(upper)
sllx %l6, 32, %o3
add  %l4, 1, %l4

P5594: !_CAS [6] (maybe <- 0x2800042) (Int) (CBR)
add %i1, 80, %o5
lduw [%o5], %l6
mov %l6, %l7
! move %l7(lower) -> %o3(lower)
or %l7, %o3, %o3
mov %l4, %o4
cas [%o5], %l7, %o4
! move %o4(lower) -> %o4(upper)
sllx %o4, 32, %o4
add   %l4, 1, %l4

! cbranch
andcc %l0, 1, %g0
be,pn  %xcc, TARGET5594
nop
RET5594:

! lfsr step begin
srlx %l0, 1, %l7
xnor %l7, %l0, %l7
sllx %l7, 63, %l7
or  %l7, %l0, %l0
srlx %l0, 1, %l0


P5595: !_ST [13] (maybe <- 0x420000a9) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i3 + 64 ]

P5596: !_LD [1] (FP)
ld [%i0 + 4], %f6
! 1 addresses covered

P5597: !_DWLD [10] (FP)
ldd [%i2 + 32], %f18
! 1 addresses covered
fmovs %f18, %f7

P5598: !_DWST [8] (maybe <- 0x420000aa) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
std %f20, [%i1 + 256]

P5599: !_DWLD [13] (FP) (Branch target of P5295)
ldd [%i3 + 64], %f8
! 1 addresses covered
ba P5600
nop

TARGET5295:
ba RET5295
nop


P5600: !_REPLACEMENT [1] (Int)
sethi %hi(0x4), %l6
or %l6, %lo(0x4),  %l6
sethi %hi(0x10000), %l7
or %l7, %lo(0x10000),  %l7
add %i3, %l6, %l6
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]

P5601: !_DWLD [10] (FP) (Branch target of P5963)
ldd [%i2 + 32], %f18
! 1 addresses covered
fmovs %f18, %f9
ba P5602
nop

TARGET5963:
ba RET5963
nop


P5602: !_PREFETCH [0] (Int)
prefetch [%i0 + 0], 1

P5603: !_DWLD [12] (FP)
ldd [%i3 + 0], %f10
! 1 addresses covered

P5604: !_REPLACEMENT [1] (Int) (Branch target of P5339)
sethi %hi(0x4), %l3
or %l3, %lo(0x4),  %l3
sethi %hi(0x10000), %l6
or %l6, %lo(0x10000),  %l6
add %i3, %l3, %l3
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
ba P5605
nop

TARGET5339:
ba RET5339
nop


P5605: !_MEMBAR (Int)
membar #StoreLoad

P5606: !_LD [6] (FP)
ld [%i1 + 80], %f11
! 1 addresses covered

P5607: !_DWST [10] (maybe <- 0x420000ab) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
std %f20, [%i2 + 32]

P5608: !_DWST [2] (maybe <- 0x420000ac) (FP)
! 0 th moved, current_fp_src=21 
fmovs  %f16, %f21
fadds  %f16, %f17, %f16
std %f20, [%i0 + 8]

P5609: !_NOP (Int)
nop

P5610: !_PREFETCH [13] (Int)
prefetch [%i3 + 64], 1

P5611: !_DWST [12] (maybe <- 0x420000ad) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
std %f20, [%i3 + 0]

P5612: !_REPLACEMENT [4] (Int)
sethi %hi(0x40), %l3
or %l3, %lo(0x40),  %l3
sethi %hi(0x10000), %l6
or %l6, %lo(0x10000),  %l6
add %i3, %l3, %l3
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]

P5613: !_SWAP [1] (maybe <- 0x2800043) (Int)
mov %l4, %l6
swap  [%i0 + 4], %l6
! move %l6(lower) -> %o4(lower)
srl %l6, 0, %o5
or %o5, %o4, %o4
!---- flushing int results buffer----
mov %o0, %l5
mov %o1, %l5
mov %o2, %l5
mov %o3, %l5
mov %o4, %l5
add   %l4, 1, %l4

P5614: !_ST [6] (maybe <- 0x420000ae) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i1 + 80 ]

P5615: !_LD [10] (FP)
ld [%i2 + 32], %f12
! 1 addresses covered

P5616: !_REPLACEMENT [5] (Int)
sethi %hi(0x4c), %l6
or %l6, %lo(0x4c),  %l6
sethi %hi(0x10000), %l7
or %l7, %lo(0x10000),  %l7
add %i3, %l6, %l6
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]

P5617: !_DWST [8] (maybe <- 0x420000af) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
std %f20, [%i1 + 256]

P5618: !_CAS [10] (maybe <- 0x2800044) (Int)
add %i2, 32, %l3
lduw [%l3], %o0
mov %o0, %o5
! move %o5(lower) -> %o0(upper)
sllx %o5, 32, %o0
mov %l4, %l7
cas [%l3], %o5, %l7
! move %l7(lower) -> %o0(lower)
srl %l7, 0, %l3
or %l3, %o0, %o0
add   %l4, 1, %l4

P5619: !_LD [9] (FP)
ld [%i1 + 512], %f13
! 1 addresses covered

P5620: !_CAS [12] (maybe <- 0x2800045) (Int)
add %i3, 0, %l3
lduw [%l3], %o1
mov %o1, %o5
! move %o5(lower) -> %o1(upper)
sllx %o5, 32, %o1
mov %l4, %l7
cas [%l3], %o5, %l7
! move %l7(lower) -> %o1(lower)
srl %l7, 0, %l3
or %l3, %o1, %o1
add   %l4, 1, %l4

P5621: !_REPLACEMENT [11] (Int)
sethi %hi(0x40), %o5
or %o5, %lo(0x40),  %o5
sethi %hi(0x10000), %l3
or %l3, %lo(0x10000),  %l3
add %i3, %o5, %o5
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]

P5622: !_PREFETCH [12] (Int)
prefetch [%i3 + 0], 1

P5623: !_REPLACEMENT [6] (Int)
sethi %hi(0x50), %l7
or %l7, %lo(0x50),  %l7
sethi %hi(0x10000), %o5
or %o5, %lo(0x10000),  %o5
add %i3, %l7, %l7
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]

P5624: !_DWLD [5] (FP)
ldd [%i1 + 72], %f14
! 1 addresses covered
fmovs %f15, %f14

P5625: !_DWST [0] (maybe <- 0x420000b0) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
! 1 th moved, current_fp_src=21 
fmovs  %f16, %f21
fadds  %f16, %f17, %f16
std %f20, [%i0 + 0]

P5626: !_LD [3] (FP)
ld [%i0 + 32], %f15
! 1 addresses covered
!---- flushing fp results buffer to %f30 ----
fmovd %f0, %f30
fmovd %f2, %f30
fmovd %f4, %f30
fmovd %f6, %f30
fmovd %f8, %f30
fmovd %f10, %f30
fmovd %f12, %f30
fmovd %f14, %f30

P5627: !_DWLD [15] (FP)
ldd [%i3 + 192], %f0
! 1 addresses covered

P5628: !_MEMBAR (Int)
membar #StoreLoad

P5629: !_ST [12] (maybe <- 0x420000b2) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i3 + 0 ]

P5630: !_DWLD [11] (FP)
ldd [%i2 + 64], %f18
! 1 addresses covered
fmovs %f18, %f1

P5631: !_CAS [3] (maybe <- 0x2800046) (Int)
add %i0, 32, %l3
lduw [%l3], %o2
mov %o2, %o5
! move %o5(lower) -> %o2(upper)
sllx %o5, 32, %o2
mov %l4, %l7
cas [%l3], %o5, %l7
! move %l7(lower) -> %o2(lower)
srl %l7, 0, %l3
or %l3, %o2, %o2
add   %l4, 1, %l4

P5632: !_REPLACEMENT [10] (Int)
sethi %hi(0x20), %o5
or %o5, %lo(0x20),  %o5
sethi %hi(0x10000), %l3
or %l3, %lo(0x10000),  %l3
add %i3, %o5, %o5
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]

P5633: !_LD [4] (FP)
ld [%i0 + 64], %f2
! 1 addresses covered

P5634: !_LD [3] (FP)
ld [%i0 + 32], %f3
! 1 addresses covered

P5635: !_NOP (Int)
nop

P5636: !_ST [10] (maybe <- 0x420000b3) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i2 + 32 ]

P5637: !_ST [13] (maybe <- 0x420000b4) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i3 + 64 ]

P5638: !_LD [3] (FP)
ld [%i0 + 32], %f4
! 1 addresses covered

P5639: !_LD [6] (FP)
ld [%i1 + 80], %f5
! 1 addresses covered

P5640: !_CASX [1] (maybe <- 0x2800047) (Int)
add %i0, 0, %l6
ldx [%l6], %o3
! move %o3(upper) -> %o3(upper)
! move %o3(lower) -> %o3(lower)
mov %o3, %l3
sllx %l4, 32, %o4
add  %l4, 1, %l4
or   %l4, %o4, %o4
casx [%l6], %l3, %o4
! move %o4(upper) -> %o4(upper)
! move %o4(lower) -> %o4(lower)
!---- flushing int results buffer----
mov %o0, %l5
mov %o1, %l5
mov %o2, %l5
mov %o3, %l5
mov %o4, %l5
add  %l4, 1, %l4

P5641: !_LD [11] (FP)
ld [%i2 + 64], %f6
! 1 addresses covered

P5642: !_PREFETCH [4] (Int)
prefetch [%i0 + 64], 1

P5643: !_DWLD [14] (FP)
ldd [%i3 + 128], %f18
! 1 addresses covered
fmovs %f18, %f7

P5644: !_DWLD [1] (FP)
ldd [%i0 + 0], %f8
! 2 addresses covered

P5645: !_REPLACEMENT [8] (Int)
sethi %hi(0x100), %l3
or %l3, %lo(0x100),  %l3
sethi %hi(0x10000), %l6
or %l6, %lo(0x10000),  %l6
add %i3, %l3, %l3
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]

P5646: !_DWST [12] (maybe <- 0x420000b5) (FP) (CBR)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
std %f20, [%i3 + 0]

! cbranch
andcc %l0, 1, %g0
be,pt  %xcc, TARGET5646
nop
RET5646:

! lfsr step begin
srlx %l0, 1, %l7
xnor %l7, %l0, %l7
sllx %l7, 63, %l7
or  %l7, %l0, %l0
srlx %l0, 1, %l0


P5647: !_LD [12] (FP)
ld [%i3 + 0], %f10
! 1 addresses covered

P5648: !_DWLD [10] (FP)
ldd [%i2 + 32], %f18
! 1 addresses covered
fmovs %f18, %f11

P5649: !_DWLD [15] (FP)
ldd [%i3 + 192], %f12
! 1 addresses covered

P5650: !_DWLD [11] (FP) (CBR)
ldd [%i2 + 64], %f18
! 1 addresses covered
fmovs %f18, %f13

! cbranch
andcc %l0, 1, %g0
be,pt  %xcc, TARGET5650
nop
RET5650:

! lfsr step begin
srlx %l0, 1, %o5
xnor %o5, %l0, %o5
sllx %o5, 63, %o5
or  %o5, %l0, %l0
srlx %l0, 1, %l0


P5651: !_LD [10] (FP)
ld [%i2 + 32], %f14
! 1 addresses covered

P5652: !_MEMBAR (Int)
membar #StoreLoad

P5653: !_SWAP [15] (maybe <- 0x2800049) (Int)
mov %l4, %o0
swap  [%i3 + 192], %o0
! move %o0(lower) -> %o0(upper)
sllx %o0, 32, %o0
add   %l4, 1, %l4

P5654: !_REPLACEMENT [5] (Int)
sethi %hi(0x4c), %o5
or %o5, %lo(0x4c),  %o5
sethi %hi(0x10000), %l3
or %l3, %lo(0x10000),  %l3
add %i3, %o5, %o5
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]

P5655: !_DWST [11] (maybe <- 0x420000b6) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
std %f20, [%i2 + 64]

P5656: !_DWST [3] (maybe <- 0x420000b7) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
std %f20, [%i0 + 32]

P5657: !_CAS [3] (maybe <- 0x280004a) (Int) (Branch target of P5392)
add %i0, 32, %l6
lduw [%l6], %o5
mov %o5, %l3
! move %l3(lower) -> %o0(lower)
or %l3, %o0, %o0
mov %l4, %o1
cas [%l6], %l3, %o1
! move %o1(lower) -> %o1(upper)
sllx %o1, 32, %o1
add   %l4, 1, %l4
ba P5658
nop

TARGET5392:
ba RET5392
nop


P5658: !_LD [0] (FP)
ld [%i0 + 0], %f15
! 1 addresses covered
!---- flushing fp results buffer to %f30 ----
fmovd %f0, %f30
fmovd %f2, %f30
fmovd %f4, %f30
fmovd %f6, %f30
fmovd %f8, %f30
fmovd %f10, %f30
fmovd %f12, %f30
fmovd %f14, %f30

P5659: !_DWLD [5] (FP)
ldd [%i1 + 72], %f0
! 1 addresses covered
fmovs %f1, %f0

P5660: !_ST [9] (maybe <- 0x420000b8) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i1 + 512 ]

P5661: !_ST [12] (maybe <- 0x420000b9) (FP) (CBR)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i3 + 0 ]

! cbranch
andcc %l0, 1, %g0
be,pt  %xcc, TARGET5661
nop
RET5661:

! lfsr step begin
srlx %l0, 1, %l7
xnor %l7, %l0, %l7
sllx %l7, 63, %l7
or  %l7, %l0, %l0
srlx %l0, 1, %l0


P5662: !_PREFETCH [1] (Int)
prefetch [%i0 + 4], 1

P5663: !_DWST [14] (maybe <- 0x420000ba) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
std %f20, [%i3 + 128]

P5664: !_LD [4] (FP)
ld [%i0 + 64], %f1
! 1 addresses covered

P5665: !_REPLACEMENT [7] (Int)
sethi %hi(0x54), %l7
or %l7, %lo(0x54),  %l7
sethi %hi(0x10000), %o5
or %o5, %lo(0x10000),  %o5
add %i3, %l7, %l7
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]

P5666: !_DWLD [11] (FP)
ldd [%i2 + 64], %f2
! 1 addresses covered

P5667: !_LD [14] (FP)
ld [%i3 + 128], %f3
! 1 addresses covered

P5668: !_PREFETCH [4] (Int)
prefetch [%i0 + 64], 1

P5669: !_DWLD [3] (FP)
ldd [%i0 + 32], %f4
! 1 addresses covered

P5670: !_LD [9] (FP)
ld [%i1 + 512], %f5
! 1 addresses covered

P5671: !_LD [6] (FP)
ld [%i1 + 80], %f6
! 1 addresses covered

P5672: !_PREFETCH [12] (Int)
prefetch [%i3 + 0], 1

P5673: !_ST [9] (maybe <- 0x420000bb) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i1 + 512 ]

P5674: !_DWST [3] (maybe <- 0x420000bc) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
std %f20, [%i0 + 32]

P5675: !_LD [8] (FP)
ld [%i1 + 256], %f7
! 1 addresses covered

P5676: !_LD [2] (FP)
ld [%i0 + 12], %f8
! 1 addresses covered

P5677: !_DWLD [7] (FP)
ldd [%i1 + 80], %f18
! 2 addresses covered
fmovs %f18, %f9
fmovs %f19, %f10

P5678: !_DWLD [0] (FP)
ldd [%i0 + 0], %f18
! 2 addresses covered
fmovs %f18, %f11
fmovs %f19, %f12

P5679: !_DWLD [5] (FP)
ldd [%i1 + 72], %f18
! 1 addresses covered
fmovs %f19, %f13

P5680: !_SWAP [13] (maybe <- 0x280004b) (Int)
mov %l4, %l6
swap  [%i3 + 64], %l6
! move %l6(lower) -> %o1(lower)
srl %l6, 0, %o5
or %o5, %o1, %o1
add   %l4, 1, %l4

P5681: !_DWLD [12] (FP)
ldd [%i3 + 0], %f14
! 1 addresses covered

P5682: !_CAS [0] (maybe <- 0x280004c) (Int)
add %i0, 0, %o5
lduw [%o5], %o2
mov %o2, %l7
! move %l7(lower) -> %o2(upper)
sllx %l7, 32, %o2
mov %l4, %l6
cas [%o5], %l7, %l6
! move %l6(lower) -> %o2(lower)
srl %l6, 0, %o5
or %o5, %o2, %o2
add   %l4, 1, %l4

P5683: !_PREFETCH [1] (Int)
prefetch [%i0 + 4], 1

P5684: !_CASX [12] (maybe <- 0x280004d) (Int) (LE)
! Change single-word-level endianess (big endian <-> little endian) 
sethi %hi(0xff00ff00), %o5
or %o5, %lo(0xff00ff00), %o5
and %l4, %o5, %l7
srl %l7, 8, %l7
sll %l4, 8, %l3
and %l3, %o5, %l3
or %l3, %l7, %l3
srl %l3, 16, %l7
sll %l3, 16, %l3
srl %l3, 0, %l3
or %l3, %l7, %l3
wr %g0, 0x88, %asi
add %i3, 0, %o5
ldxa [%o5] %asi, %l6
! move %l6(lower) -> %o3(upper)
sllx %l6, 32, %o3
! move %l6(upper) -> %o3(lower)
srlx %l6, 32, %l7
or %l7, %o3, %o3
mov  %l6, %l7
mov  %l3, %l6
casxa [%o5] %asi, %l7, %l6
! move %l6(lower) -> %o4(upper)
sllx %l6, 32, %o4
! move %l6(upper) -> %o4(lower)
srlx %l6, 32, %o5
or %o5, %o4, %o4
!---- flushing int results buffer----
mov %o0, %l5
mov %o1, %l5
mov %o2, %l5
mov %o3, %l5
mov %o4, %l5
add  %l4, 1, %l4

P5685: !_REPLACEMENT [1] (Int)
sethi %hi(0x4), %l7
or %l7, %lo(0x4),  %l7
sethi %hi(0x10000), %o5
or %o5, %lo(0x10000),  %o5
add %i3, %l7, %l7
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]

P5686: !_DWLD [7] (FP)
ldd [%i1 + 80], %f18
! 2 addresses covered
fmovs %f18, %f15
!---- flushing fp results buffer to %f30 ----
fmovd %f0, %f30
fmovd %f2, %f30
fmovd %f4, %f30
fmovd %f6, %f30
fmovd %f8, %f30
fmovd %f10, %f30
fmovd %f12, %f30
fmovd %f14, %f30
fmovs %f19, %f0

P5687: !_PREFETCH [9] (Int)
prefetch [%i1 + 512], 1

P5688: !_REPLACEMENT [8] (Int)
sethi %hi(0x100), %l6
or %l6, %lo(0x100),  %l6
sethi %hi(0x10000), %l7
or %l7, %lo(0x10000),  %l7
add %i3, %l6, %l6
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]

P5689: !_LD [6] (FP)
ld [%i1 + 80], %f1
! 1 addresses covered

P5690: !_LD [5] (FP)
ld [%i1 + 76], %f2
! 1 addresses covered

P5691: !_MEMBAR (Int)
membar #StoreLoad

P5692: !_DWLD [11] (FP)
ldd [%i2 + 64], %f18
! 1 addresses covered
fmovs %f18, %f3

P5693: !_DWST [5] (maybe <- 0x420000bd) (FP) (CBR)
! 0 th moved, current_fp_src=21 
fmovs  %f16, %f21
fadds  %f16, %f17, %f16
std %f20, [%i1 + 72]

! cbranch
andcc %l0, 1, %g0
be,pn  %xcc, TARGET5693
nop
RET5693:

! lfsr step begin
srlx %l0, 1, %o5
xnor %o5, %l0, %o5
sllx %o5, 63, %o5
or  %o5, %l0, %l0
srlx %l0, 1, %l0


P5694: !_DWLD [11] (FP)
ldd [%i2 + 64], %f4
! 1 addresses covered

P5695: !_CASX [10] (maybe <- 0x280004e) (Int)
add %i2, 32, %l6
ldx [%l6], %o0
! move %o0(upper) -> %o0(upper)
! move %o0(lower) -> %o0(lower)
mov  %o0, %l3
sllx %l4, 32, %o1
casx [%l6], %l3, %o1
! move %o1(upper) -> %o1(upper)
! move %o1(lower) -> %o1(lower)
add  %l4, 1, %l4

P5696: !_PREFETCH [5] (Int)
prefetch [%i1 + 76], 1

P5697: !_PREFETCH [9] (Int)
prefetch [%i1 + 512], 1

P5698: !_LD [12] (FP)
ld [%i3 + 0], %f5
! 1 addresses covered

P5699: !_ST [13] (maybe <- 0x420000be) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i3 + 64 ]

P5700: !_LD [1] (FP) (CBR)
ld [%i0 + 4], %f6
! 1 addresses covered

! cbranch
andcc %l0, 1, %g0
be,pt  %xcc, TARGET5700
nop
RET5700:

! lfsr step begin
srlx %l0, 1, %o5
xnor %o5, %l0, %o5
sllx %o5, 63, %o5
or  %o5, %l0, %l0
srlx %l0, 1, %l0


P5701: !_DWLD [7] (FP)
ldd [%i1 + 80], %f18
! 2 addresses covered
fmovs %f18, %f7
fmovs %f19, %f8

P5702: !_DWLD [4] (FP)
ldd [%i0 + 64], %f18
! 1 addresses covered
fmovs %f18, %f9

P5703: !_DWST [0] (maybe <- 0x420000bf) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
! 1 th moved, current_fp_src=21 
fmovs  %f16, %f21
fadds  %f16, %f17, %f16
std %f20, [%i0 + 0]

P5704: !_DWST [13] (maybe <- 0x420000c1) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
std %f20, [%i3 + 64]

P5705: !_LD [5] (FP)
ld [%i1 + 76], %f10
! 1 addresses covered

P5706: !_REPLACEMENT [0] (Int)
sethi %hi(0x0), %l7
or %l7, %lo(0x0),  %l7
sethi %hi(0x10000), %o5
or %o5, %lo(0x10000),  %o5
add %i3, %l7, %l7
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]

P5707: !_REPLACEMENT [3] (Int)
sethi %hi(0x20), %l6
or %l6, %lo(0x20),  %l6
sethi %hi(0x10000), %l7
or %l7, %lo(0x10000),  %l7
add %i3, %l6, %l6
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]

P5708: !_PREFETCH [13] (Int)
prefetch [%i3 + 64], 1

P5709: !_ST [2] (maybe <- 0x420000c2) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i0 + 12 ]

P5710: !_DWST [7] (maybe <- 0x420000c3) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
! 1 th moved, current_fp_src=21 
fmovs  %f16, %f21
fadds  %f16, %f17, %f16
std %f20, [%i1 + 80]

P5711: !_CASX [8] (maybe <- 0x280004f) (Int)
add %i1, 256, %o5
ldx [%o5], %o2
! move %o2(upper) -> %o2(upper)
! move %o2(lower) -> %o2(lower)
mov  %o2, %l7
sllx %l4, 32, %o3
casx [%o5], %l7, %o3
! move %o3(upper) -> %o3(upper)
! move %o3(lower) -> %o3(lower)
add  %l4, 1, %l4

P5712: !_DWLD [4] (FP)
ldd [%i0 + 64], %f18
! 1 addresses covered
fmovs %f18, %f11

P5713: !_ST [2] (maybe <- 0x420000c5) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i0 + 12 ]

P5714: !_PREFETCH [3] (Int) (Branch target of P5743)
prefetch [%i0 + 32], 1
ba P5715
nop

TARGET5743:
ba RET5743
nop


P5715: !_CASX [1] (maybe <- 0x2800050) (Int)
add %i0, 0, %l7
ldx [%l7], %o4
! move %o4(upper) -> %o4(upper)
! move %o4(lower) -> %o4(lower)
!---- flushing int results buffer----
mov %o0, %l5
mov %o1, %l5
mov %o2, %l5
mov %o3, %l5
mov %o4, %l5
mov %o4, %l6
sllx %l4, 32, %o0
add  %l4, 1, %l4
or   %l4, %o0, %o0
casx [%l7], %l6, %o0
! move %o0(upper) -> %o0(upper)
! move %o0(lower) -> %o0(lower)
add  %l4, 1, %l4

P5716: !_PREFETCH [4] (Int)
prefetch [%i0 + 64], 1

P5717: !_DWLD [10] (FP)
ldd [%i2 + 32], %f12
! 1 addresses covered

P5718: !_SWAP [4] (maybe <- 0x2800052) (Int)
mov %l4, %o1
swap  [%i0 + 64], %o1
! move %o1(lower) -> %o1(upper)
sllx %o1, 32, %o1
add   %l4, 1, %l4

P5719: !_LD [10] (FP)
ld [%i2 + 32], %f13
! 1 addresses covered

P5720: !_PREFETCH [5] (Int)
prefetch [%i1 + 76], 1

P5721: !_REPLACEMENT [11] (Int)
sethi %hi(0x40), %l3
or %l3, %lo(0x40),  %l3
sethi %hi(0x10000), %l6
or %l6, %lo(0x10000),  %l6
add %i3, %l3, %l3
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]

P5722: !_SWAP [13] (maybe <- 0x2800053) (Int)
mov %l4, %l6
swap  [%i3 + 64], %l6
! move %l6(lower) -> %o1(lower)
srl %l6, 0, %o5
or %o5, %o1, %o1
add   %l4, 1, %l4

P5723: !_MEMBAR (Int)
membar #StoreLoad

P5724: !_SWAP [14] (maybe <- 0x2800054) (Int)
mov %l4, %o2
swap  [%i3 + 128], %o2
! move %o2(lower) -> %o2(upper)
sllx %o2, 32, %o2
add   %l4, 1, %l4

P5725: !_DWLD [10] (FP)
ldd [%i2 + 32], %f14
! 1 addresses covered

P5726: !_PREFETCH [9] (Int)
prefetch [%i1 + 512], 1

P5727: !_DWLD [2] (FP)
ldd [%i0 + 8], %f18
! 1 addresses covered
fmovs %f19, %f15
!---- flushing fp results buffer to %f30 ----
fmovd %f0, %f30
fmovd %f2, %f30
fmovd %f4, %f30
fmovd %f6, %f30
fmovd %f8, %f30
fmovd %f10, %f30
fmovd %f12, %f30
fmovd %f14, %f30

P5728: !_PREFETCH [10] (Int) (Branch target of P5996)
prefetch [%i2 + 32], 1
ba P5729
nop

TARGET5996:
ba RET5996
nop


P5729: !_PREFETCH [14] (Int)
prefetch [%i3 + 128], 1

P5730: !_DWST [6] (maybe <- 0x420000c6) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
! 1 th moved, current_fp_src=21 
fmovs  %f16, %f21
fadds  %f16, %f17, %f16
std %f20, [%i1 + 80]

P5731: !_DWLD [13] (FP)
ldd [%i3 + 64], %f0
! 1 addresses covered

P5732: !_LD [10] (FP)
ld [%i2 + 32], %f1
! 1 addresses covered

P5733: !_DWLD [3] (FP)
ldd [%i0 + 32], %f2
! 1 addresses covered

P5734: !_REPLACEMENT [0] (Int)
sethi %hi(0x0), %l3
or %l3, %lo(0x0),  %l3
sethi %hi(0x10000), %l6
or %l6, %lo(0x10000),  %l6
add %i3, %l3, %l3
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]

P5735: !_REPLACEMENT [7] (Int)
sethi %hi(0x54), %o5
or %o5, %lo(0x54),  %o5
sethi %hi(0x10000), %l3
or %l3, %lo(0x10000),  %l3
add %i3, %o5, %o5
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]

P5736: !_DWLD [12] (FP) (Branch target of P5260)
ldd [%i3 + 0], %f18
! 1 addresses covered
fmovs %f18, %f3
ba P5737
nop

TARGET5260:
ba RET5260
nop


P5737: !_CASX [15] (maybe <- 0x2800055) (Int)
add %i3, 192, %o5
ldx [%o5], %l6
! move %l6(upper) -> %o2(lower)
srlx %l6, 32, %l7
or %l7, %o2, %o2
! move %l6(lower) -> %o3(upper)
sllx %l6, 32, %o3
mov  %l6, %l7
sllx %l4, 32, %l6
casx [%o5], %l7, %l6
! move %l6(upper) -> %o3(lower)
srlx %l6, 32, %o5
or %o5, %o3, %o3
! move %l6(lower) -> %o4(upper)
sllx %l6, 32, %o4
add  %l4, 1, %l4

P5738: !_ST [5] (maybe <- 0x420000c8) (FP) (Branch target of P6063)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i1 + 76 ]
ba P5739
nop

TARGET6063:
ba RET6063
nop


P5739: !_REPLACEMENT [5] (Int)
sethi %hi(0x4c), %l6
or %l6, %lo(0x4c),  %l6
sethi %hi(0x10000), %l7
or %l7, %lo(0x10000),  %l7
add %i3, %l6, %l6
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]

P5740: !_DWLD [11] (FP)
ldd [%i2 + 64], %f4
! 1 addresses covered

P5741: !_REPLACEMENT [15] (Int)
sethi %hi(0xc0), %l3
or %l3, %lo(0xc0),  %l3
sethi %hi(0x10000), %l6
or %l6, %lo(0x10000),  %l6
add %i3, %l3, %l3
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]

P5742: !_DWLD [14] (FP)
ldd [%i3 + 128], %f18
! 1 addresses covered
fmovs %f18, %f5

P5743: !_ST [12] (maybe <- 0x420000c9) (FP) (CBR)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i3 + 0 ]

! cbranch
andcc %l0, 1, %g0
be,pn  %xcc, TARGET5743
nop
RET5743:

! lfsr step begin
srlx %l0, 1, %l7
xnor %l7, %l0, %l7
sllx %l7, 63, %l7
or  %l7, %l0, %l0
srlx %l0, 1, %l0


P5744: !_ST [4] (maybe <- 0x420000ca) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i0 + 64 ]

P5745: !_ST [5] (maybe <- 0x420000cb) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i1 + 76 ]

P5746: !_ST [10] (maybe <- 0x420000cc) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i2 + 32 ]

P5747: !_ST [2] (maybe <- 0x420000cd) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i0 + 12 ]

P5748: !_DWST [10] (maybe <- 0x420000ce) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
std %f20, [%i2 + 32]

P5749: !_LD [9] (FP)
ld [%i1 + 512], %f6
! 1 addresses covered

P5750: !_REPLACEMENT [4] (Int)
sethi %hi(0x40), %l7
or %l7, %lo(0x40),  %l7
sethi %hi(0x10000), %o5
or %o5, %lo(0x10000),  %o5
add %i3, %l7, %l7
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]

P5751: !_SWAP [3] (maybe <- 0x2800056) (Int)
mov %l4, %o5
swap  [%i0 + 32], %o5
! move %o5(lower) -> %o4(lower)
srl %o5, 0, %l6
or %l6, %o4, %o4
!---- flushing int results buffer----
mov %o0, %l5
mov %o1, %l5
mov %o2, %l5
mov %o3, %l5
mov %o4, %l5
add   %l4, 1, %l4

P5752: !_REPLACEMENT [4] (Int)
sethi %hi(0x40), %l3
or %l3, %lo(0x40),  %l3
sethi %hi(0x10000), %l6
or %l6, %lo(0x10000),  %l6
add %i3, %l3, %l3
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]

P5753: !_DWLD [4] (FP)
ldd [%i0 + 64], %f18
! 1 addresses covered
fmovs %f18, %f7

P5754: !_NOP (Int)
nop

P5755: !_DWLD [11] (FP)
ldd [%i2 + 64], %f8
! 1 addresses covered

P5756: !_DWST [10] (maybe <- 0x420000cf) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
std %f20, [%i2 + 32]

P5757: !_REPLACEMENT [12] (Int)
sethi %hi(0x0), %l7
or %l7, %lo(0x0),  %l7
sethi %hi(0x10000), %o5
or %o5, %lo(0x10000),  %o5
add %i3, %l7, %l7
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]
add %l7, %o5, %l7
ld [%l7], %l3
st %l3, [%l7]

P5758: !_PREFETCH [0] (Int)
prefetch [%i0 + 0], 1

P5759: !_LD [4] (FP)
ld [%i0 + 64], %f9
! 1 addresses covered

P5760: !_REPLACEMENT [4] (Int)
sethi %hi(0x40), %l6
or %l6, %lo(0x40),  %l6
sethi %hi(0x10000), %l7
or %l7, %lo(0x10000),  %l7
add %i3, %l6, %l6
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]

P5761: !_DWLD [2] (FP)
ldd [%i0 + 8], %f10
! 1 addresses covered
fmovs %f11, %f10

P5762: !_MEMBAR (Int)
membar #StoreLoad

P5763: !_DWST [9] (maybe <- 0x420000d0) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
std %f20, [%i1 + 512]

P5764: !_PREFETCH [11] (Int)
prefetch [%i2 + 64], 1

P5765: !_DWST [1] (maybe <- 0x420000d1) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
! 1 th moved, current_fp_src=21 
fmovs  %f16, %f21
fadds  %f16, %f17, %f16
std %f20, [%i0 + 0]

P5766: !_ST [7] (maybe <- 0x420000d3) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i1 + 84 ]

P5767: !_LD [11] (FP)
ld [%i2 + 64], %f11
! 1 addresses covered

P5768: !_REPLACEMENT [12] (Int)
sethi %hi(0x0), %l6
or %l6, %lo(0x0),  %l6
sethi %hi(0x10000), %l7
or %l7, %lo(0x10000),  %l7
add %i3, %l6, %l6
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]

P5769: !_DWST [2] (maybe <- 0x420000d4) (FP)
! 0 th moved, current_fp_src=21 
fmovs  %f16, %f21
fadds  %f16, %f17, %f16
std %f20, [%i0 + 8]

P5770: !_DWLD [11] (FP)
ldd [%i2 + 64], %f12
! 1 addresses covered

P5771: !_REPLACEMENT [13] (Int)
sethi %hi(0x40), %o5
or %o5, %lo(0x40),  %o5
sethi %hi(0x10000), %l3
or %l3, %lo(0x10000),  %l3
add %i3, %o5, %o5
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]

P5772: !_ST [7] (maybe <- 0x420000d5) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i1 + 84 ]

P5773: !_REPLACEMENT [0] (Int) (Branch target of P5569)
sethi %hi(0x0), %l6
or %l6, %lo(0x0),  %l6
sethi %hi(0x10000), %l7
or %l7, %lo(0x10000),  %l7
add %i3, %l6, %l6
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
add %l6, %l7, %l6
ld [%l6], %o5
st %o5, [%l6]
ba P5774
nop

TARGET5569:
ba RET5569
nop


P5774: !_PREFETCH [9] (Int)
prefetch [%i1 + 512], 1

P5775: !_REPLACEMENT [12] (Int)
sethi %hi(0x0), %l3
or %l3, %lo(0x0),  %l3
sethi %hi(0x10000), %l6
or %l6, %lo(0x10000),  %l6
add %i3, %l3, %l3
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]
add %l3, %l6, %l3
ld [%l3], %l7
st %l7, [%l3]

P5776: !_REPLACEMENT [12] (Int)
sethi %hi(0x0), %o5
or %o5, %lo(0x0),  %o5
sethi %hi(0x10000), %l3
or %l3, %lo(0x10000),  %l3
add %i3, %o5, %o5
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]
add %o5, %l3, %o5
ld [%o5], %l6
st %l6, [%o5]

P5777: !_SWAP [8] (maybe <- 0x2800057) (Int) (LE)
wr %g0, 0x88, %asi
mov %l4, %o0
! Change single-word-level endianess (big endian <-> little endian) 
sethi %hi(0xff00ff00), %l7
or %l7, %lo(0xff00ff00), %l7
and %o0, %l7, %o5
srl %o5, 8, %o5
sll %o0, 8, %o0
and %o0, %l7, %o0
or %o0, %o5, %o0
srl %o0, 16, %o5
sll %o0, 16, %o0
srl %o0, 0, %o0
or %o0, %o5, %o0
swapa  [%i1 + 256] %asi, %o0
! move %o0(lower) -> %o0(upper)
sllx %o0, 32, %o0
add   %l4, 1, %l4

P5778: !_DWLD [12] (FP)
ldd [%i3 + 0], %f18
! 1 addresses covered
fmovs %f18, %f13

P5779: !_DWST [7] (maybe <- 0x420000d6) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
! 1 th moved, current_fp_src=21 
fmovs  %f16, %f21
fadds  %f16, %f17, %f16
std %f20, [%i1 + 80]

P5780: !_PREFETCH [15] (Int)
prefetch [%i3 + 192], 1

P5781: !_DWST [15] (maybe <- 0x420000d8) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
std %f20, [%i3 + 192]

P5782: !_PREFETCH [5] (Int)
prefetch [%i1 + 76], 1

P5783: !_ST [2] (maybe <- 0x420000d9) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
st   %f20, [%i0 + 12 ]

P5784: !_DWST [1] (maybe <- 0x420000da) (FP)
! 0 th moved, current_fp_src=20 
fmovs  %f16, %f20
fadds  %f16, %f17, %f16
! 1 th moved, current_fp_src=21 
fmovs  %f16, %f21
fadds  %f16, %f17, %f16
std %f20, [%i0 + 0]

prefetch [%i0 + 4], 1