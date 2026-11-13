	.file	"baseline.c"
	.text
	.p2align 4
	.globl	qoi_encode_ref
	.type	qoi_encode_ref, @function
qoi_encode_ref:
.LFB33:
	.cfi_startproc
	endbr64
	pushq	%r15
	.cfi_def_cfa_offset 16
	.cfi_offset 15, -16
	movq	%rsi, %rax
	movq	%rdx, %rsi
	pushq	%r14
	.cfi_def_cfa_offset 24
	.cfi_offset 14, -24
	pushq	%r13
	.cfi_def_cfa_offset 32
	.cfi_offset 13, -32
	pushq	%r12
	.cfi_def_cfa_offset 40
	.cfi_offset 12, -40
	pushq	%rbp
	.cfi_def_cfa_offset 48
	.cfi_offset 6, -48
	pushq	%rbx
	.cfi_def_cfa_offset 56
	.cfi_offset 3, -56
	subq	$328, %rsp
	.cfi_def_cfa_offset 384
	movq	%fs:40, %r12
	movq	%r12, 312(%rsp)
	xorl	%r12d, %r12d
	testq	%rdx, %rdx
	sete	%dl
	testq	%rax, %rax
	sete	%cl
	orb	%cl, %dl
	jne	.L5
	movq	%rdi, %r15
	testq	%rdi, %rdi
	je	.L5
	movl	(%rax), %ecx
	movl	%ecx, %ebx
	bswap	%ebx
	movl	%ebx, %r14d
	testl	%ecx, %ecx
	je	.L5
	movl	4(%rax), %edi
	movl	%edi, %ebx
	bswap	%ebx
	movl	%ebx, %r8d
	testl	%edi, %edi
	je	.L5
	movzbl	8(%rax), %r13d
	leal	-3(%r13), %edx
	cmpb	$1, %dl
	ja	.L5
	movzbl	9(%rax), %r9d
	cmpb	$1, %r9b
	ja	.L5
	movl	$400000000, %eax
	xorl	%edx, %edx
	divl	%ecx
	cmpl	%eax, %edi
	jnb	.L5
	imull	%edi, %ecx
	movzbl	%r13b, %edx
	movb	%r9b, 40(%rsp)
	leal	1(%rdx), %edi
	movl	%edx, 4(%rsp)
	movl	%r8d, 8(%rsp)
	imull	%ecx, %edi
	movq	%rsi, 16(%rsp)
	movl	%ecx, %ebx
	addl	$22, %edi
	movslq	%edi, %rdi
	call	malloc@PLT
	movq	%rax, %rbp
	testq	%rax, %rax
	je	.L5
	movl	4(%rsp), %edx
	movzbl	40(%rsp), %r9d
	movl	%r14d, 4(%rax)
	movl	$32, %ecx
	movl	8(%rsp), %r8d
	movb	%r13b, 12(%rax)
	leaq	48(%rsp), %rdi
	movl	$-16777216, %r13d
	imull	%edx, %ebx
	movl	$1718185841, (%rax)
	movq	16(%rsp), %rsi
	movl	$-16777216, %r14d
	movl	%r8d, 8(%rax)
	movb	%r9b, 13(%rax)
	movq	%r12, %rax
	rep stosq
	testl	%ebx, %ebx
	movl	%ebx, 40(%rsp)
	jle	.L35
	subl	%edx, %ebx
	movl	%ebx, 16(%rsp)
	cmpl	$4, %edx
	je	.L36
	movq	%rsi, 32(%rsp)
	xorl	%ebx, %ebx
	movl	$-16777216, %r8d
	xorl	%r9d, %r9d
	movl	$14, %r12d
	movl	$14, %eax
	jmp	.L22
	.p2align 4,,10
	.p2align 3
.L61:
	movzbl	%ch, %edi
	movl	%edi, %r8d
	testl	%r9d, %r9d
	je	.L19
	subl	$1, %r9d
	movl	4(%rsp), %r12d
	orl	$-64, %r9d
	movb	%r9b, (%r11)
	leal	1(%r12), %eax
	movl	%eax, 4(%rsp)
	movslq	%r12d, %rax
.L19:
	movzbl	%r8b, %r9d
	movzbl	%cl, %r11d
	addq	%rbp, %rax
	leal	(%r11,%r11,2), %r11d
	leal	(%r9,%r9,4), %r9d
	movq	%rax, 8(%rsp)
	addl	%r11d, %r9d
	leal	(%r9,%r10,8), %r9d
	subl	%r10d, %r9d
	leal	2805(%r9), %r10d
	leal	2805(%r9), %r11d
	andl	$63, %r10d
	andl	$63, %r11d
	cmpl	%edx, 48(%rsp,%r10,4)
	je	.L18
	movl	%edx, 48(%rsp,%r10,4)
	movslq	4(%rsp), %r9
	movl	%r13d, %r10d
	leal	2(%r12), %r11d
	shrl	$24, %r10d
	addq	%rbp, %r9
	cmpb	$-1, %r10b
	je	.L11
	movb	$-1, (%rax)
	movslq	%r11d, %rax
	movb	%cl, (%r9)
	leal	3(%r12), %ecx
	xorl	%r9d, %r9d
	movb	%r8b, 0(%rbp,%rax)
	leal	4(%r12), %eax
	movslq	%ecx, %rcx
	addl	$5, %r12d
	cltq
	movb	%sil, 0(%rbp,%rcx)
	movb	$-1, 0(%rbp,%rax)
	movslq	%r12d, %rax
.L12:
	movl	%edx, %r13d
	addq	$3, %rbx
	cmpl	%ebx, 40(%rsp)
	jle	.L57
.L62:
	movl	%edx, %r8d
.L22:
	movzbl	2(%r15,%rbx), %r10d
	movzwl	(%r15,%rbx), %ecx
	leaq	0(%rbp,%rax), %r11
	andl	$-16777216, %r14d
	movzwl	%cx, %edi
	movl	%r10d, %edx
	movl	%r10d, %esi
	orl	%edi, %r14d
	sall	$16, %edx
	leal	1(%r12), %edi
	orl	%r14d, %edx
	movl	%edi, 4(%rsp)
	movl	%edx, %r14d
	cmpl	%r8d, %edx
	jne	.L61
	addl	$1, %r9d
	cmpl	%ebx, 16(%rsp)
	je	.L37
	cmpl	$62, %r9d
	jne	.L12
.L37:
	movslq	4(%rsp), %rax
	subl	$1, %r9d
	movl	%edx, %r13d
	addq	$3, %rbx
	orl	$-64, %r9d
	movb	%r9b, (%r11)
	movq	%rax, %r12
	xorl	%r9d, %r9d
	cmpl	%ebx, 40(%rsp)
	jg	.L62
	.p2align 4
	.p2align 3
.L57:
	movq	32(%rsp), %rsi
.L6:
	movabsq	$72057594037927936, %rcx
	addl	$8, %r12d
	movq	%rcx, 0(%rbp,%rax)
	movl	%r12d, (%rsi)
	jmp	.L1
	.p2align 4,,10
	.p2align 3
.L5:
	xorl	%ebp, %ebp
.L1:
	movq	312(%rsp), %rax
	subq	%fs:40, %rax
	jne	.L63
	addq	$328, %rsp
	.cfi_remember_state
	.cfi_def_cfa_offset 56
	movq	%rbp, %rax
	popq	%rbx
	.cfi_def_cfa_offset 48
	popq	%rbp
	.cfi_def_cfa_offset 40
	popq	%r12
	.cfi_def_cfa_offset 32
	popq	%r13
	.cfi_def_cfa_offset 24
	popq	%r14
	.cfi_def_cfa_offset 16
	popq	%r15
	.cfi_def_cfa_offset 8
	ret
	.p2align 4,,10
	.p2align 3
.L16:
	.cfi_restore_state
	leal	0(,%rax,4), %r11d
	sall	$4, %r10d
	orl	%r10d, %r11d
	orl	$64, %r11d
	orl	%edi, %r11d
	.p2align 4
	.p2align 3
.L18:
	movq	8(%rsp), %rax
	xorl	%r9d, %r9d
	movb	%r11b, (%rax)
	movslq	4(%rsp), %rax
	movq	%rax, %r12
	jmp	.L12
	.p2align 4,,10
	.p2align 3
.L11:
	movl	%r13d, %eax
	movl	%r8d, %edi
	movl	%ecx, %r10d
	movzbl	%ah, %eax
	subl	%r13d, %r10d
	shrl	$16, %r13d
	subl	%eax, %edi
	subl	%r8d, %eax
	movb	%dil, 46(%rsp)
	movl	%esi, %edi
	subl	%r13d, %edi
	movl	%eax, %r13d
	leal	0(%r13,%r10), %eax
	addl	$2, %r10d
	movb	%dil, 47(%rsp)
	movb	%al, 24(%rsp)
	cmpb	$3, %r10b
	ja	.L14
	movzbl	46(%rsp), %eax
	addl	$2, %eax
	cmpb	$3, %al
	ja	.L14
	addl	$2, %edi
	cmpb	$3, %dil
	jbe	.L16
	movzbl	24(%rsp), %edi
	addl	$8, %edi
	cmpb	$15, %dil
	ja	.L15
	movzbl	46(%rsp), %r10d
	addl	$32, %r10d
.L17:
	movzbl	47(%rsp), %eax
	leal	8(%r13,%rax), %r13d
	cmpb	$15, %r13b
	ja	.L15
	movq	8(%rsp), %rax
	orl	$-128, %r10d
	sall	$4, %edi
	orl	%r13d, %edi
	movb	%r10b, (%rax)
	movslq	%r11d, %rax
	movb	%dil, (%r9)
	movq	%rax, %r12
	xorl	%r9d, %r9d
	jmp	.L12
	.p2align 4,,10
	.p2align 3
.L14:
	movzbl	24(%rsp), %edi
	addl	$8, %edi
	cmpb	$15, %dil
	ja	.L15
	movzbl	46(%rsp), %r10d
	addl	$32, %r10d
	cmpb	$63, %r10b
	jbe	.L17
.L15:
	movq	8(%rsp), %rax
	movb	$-2, (%rax)
	leal	3(%r12), %eax
	addl	$4, %r12d
	movb	%cl, (%r9)
	cltq
	movslq	%r11d, %rcx
	xorl	%r9d, %r9d
	movb	%r8b, 0(%rbp,%rcx)
	movb	%sil, 0(%rbp,%rax)
	movslq	%r12d, %rax
	jmp	.L12
	.p2align 4,,10
	.p2align 3
.L36:
	movq	%rsi, 24(%rsp)
	xorl	%r14d, %r14d
	movl	$-16777216, %edi
	xorl	%r9d, %r9d
	movl	$14, %r12d
	movl	$14, %eax
	jmp	.L7
	.p2align 4,,10
	.p2align 3
.L23:
	movl	%edx, %ebx
	movl	%edx, %edi
	movzbl	%dh, %esi
	movl	%edx, %r8d
	shrl	$24, %ebx
	shrl	$16, %edi
	testl	%r9d, %r9d
	je	.L26
	subl	$1, %r9d
	movslq	%ecx, %rax
	orl	$-64, %r9d
	movq	%rax, %r12
	leal	1(%rax), %ecx
	movb	%r9b, (%r10)
.L26:
	movzbl	%r8b, %r9d
	movzbl	%sil, %r10d
	leal	(%r9,%r9,2), %r9d
	leal	(%r10,%r10,4), %r10d
	addl	%r9d, %r10d
	movzbl	%dil, %r9d
	leal	(%r10,%r9,8), %r10d
	subl	%r9d, %r10d
	leal	(%rbx,%rbx,4), %r9d
	leal	(%rbx,%r9,2), %r9d
	addl	%r9d, %r10d
	leaq	0(%rbp,%rax), %r9
	movl	%r10d, %r11d
	andl	$63, %r10d
	andl	$63, %r11d
	cmpl	%edx, 48(%rsp,%r10,4)
	je	.L64
	leal	2(%r12), %eax
	movl	%edx, 48(%rsp,%r10,4)
	movl	%r13d, %r10d
	movl	%eax, 4(%rsp)
	shrl	$24, %r10d
	movslq	%ecx, %rax
	movq	%rax, 8(%rsp)
	leaq	0(%rbp,%rax), %r11
	cmpb	%r10b, %bl
	je	.L65
	movslq	4(%rsp), %rax
	movb	$-1, (%r9)
	leal	3(%r12), %ecx
	xorl	%r9d, %r9d
	movb	%r8b, (%r11)
	movslq	%ecx, %rcx
	movb	%sil, 0(%rbp,%rax)
	leal	4(%r12), %eax
	addl	$5, %r12d
	cltq
	movb	%dil, 0(%rbp,%rcx)
	movb	%bl, 0(%rbp,%rax)
	movslq	%r12d, %rax
.L24:
	movl	%edx, %r13d
	addq	$4, %r14
	cmpl	%r14d, 40(%rsp)
	jle	.L58
	movl	%edx, %edi
.L7:
	movl	(%r15,%r14), %edx
	leal	1(%r12), %ecx
	leaq	0(%rbp,%rax), %r10
	cmpl	%edx, %edi
	jne	.L23
	addl	$1, %r9d
	cmpl	$62, %r9d
	je	.L38
	cmpl	%r14d, 16(%rsp)
	jne	.L24
.L38:
	subl	$1, %r9d
	movslq	%ecx, %rax
	orl	$-64, %r9d
	movq	%rax, %r12
	movb	%r9b, (%r10)
	xorl	%r9d, %r9d
	jmp	.L24
	.p2align 4,,10
	.p2align 3
.L64:
	movslq	%ecx, %rax
	movb	%r11b, (%r9)
	xorl	%r9d, %r9d
	movq	%rax, %r12
	jmp	.L24
	.p2align 4,,10
	.p2align 3
.L65:
	movl	%r13d, %ebx
	movl	%esi, %eax
	movl	%r8d, %r10d
	movzbl	%bh, %ebx
	subl	%r13d, %r10d
	shrl	$16, %r13d
	subl	%ebx, %eax
	subl	%esi, %ebx
	movb	%al, 46(%rsp)
	movl	%edi, %eax
	subl	%r13d, %eax
	movl	%ebx, %r13d
	leal	(%r10,%r13), %ebx
	addl	$2, %r10d
	movb	%al, 32(%rsp)
	cmpb	$3, %r10b
	ja	.L29
	movzbl	46(%rsp), %eax
	addl	$2, %eax
	movb	%al, 47(%rsp)
	cmpb	$3, %al
	ja	.L29
	movzbl	32(%rsp), %eax
	addl	$2, %eax
	cmpb	$3, %al
	ja	.L30
	movzbl	47(%rsp), %ebx
	movl	%r10d, %esi
	movl	%ecx, %r12d
	sall	$4, %esi
	sall	$2, %ebx
	orl	%ebx, %esi
	orl	$64, %esi
	orl	%eax, %esi
	movq	8(%rsp), %rax
	movb	%sil, (%r9)
	xorl	%r9d, %r9d
	jmp	.L24
	.p2align 4,,10
	.p2align 3
.L29:
	leal	8(%rbx), %eax
	cmpb	$15, %al
	ja	.L31
	movzbl	46(%rsp), %ecx
	addl	$32, %ecx
	cmpb	$63, %cl
	ja	.L31
.L32:
	movzbl	32(%rsp), %ebx
	leal	8(%rbx,%r13), %r10d
	cmpb	$15, %r10b
	ja	.L31
	sall	$4, %eax
	orl	$-128, %ecx
	orl	%r10d, %eax
	movb	%cl, (%r9)
	xorl	%r9d, %r9d
	movb	%al, (%r11)
	movslq	4(%rsp), %rax
	movq	%rax, %r12
	jmp	.L24
	.p2align 4,,10
	.p2align 3
.L31:
	leal	3(%r12), %eax
	movslq	4(%rsp), %rcx
	addl	$4, %r12d
	movb	$-2, (%r9)
	cltq
	movb	%r8b, (%r11)
	xorl	%r9d, %r9d
	movb	%sil, 0(%rbp,%rcx)
	movb	%dil, 0(%rbp,%rax)
	movslq	%r12d, %rax
	jmp	.L24
	.p2align 4,,10
	.p2align 3
.L58:
	movq	24(%rsp), %rsi
	jmp	.L6
	.p2align 4,,10
	.p2align 3
.L35:
	movl	$14, %r12d
	movl	$14, %eax
	jmp	.L6
.L30:
	leal	8(%rbx), %eax
	cmpb	$15, %al
	ja	.L31
	movzbl	46(%rsp), %ecx
	addl	$32, %ecx
	jmp	.L32
.L63:
	call	__stack_chk_fail@PLT
	.cfi_endproc
.LFE33:
	.size	qoi_encode_ref, .-qoi_encode_ref
	.p2align 4
	.globl	qoi_decode_ref
	.type	qoi_decode_ref, @function
qoi_decode_ref:
.LFB34:
	.cfi_startproc
	endbr64
	pushq	%r15
	.cfi_def_cfa_offset 16
	.cfi_offset 15, -16
	pushq	%r14
	.cfi_def_cfa_offset 24
	.cfi_offset 14, -24
	pushq	%r13
	.cfi_def_cfa_offset 32
	.cfi_offset 13, -32
	pushq	%r12
	.cfi_def_cfa_offset 40
	.cfi_offset 12, -40
	pushq	%rbp
	.cfi_def_cfa_offset 48
	.cfi_offset 6, -48
	pushq	%rbx
	.cfi_def_cfa_offset 56
	.cfi_offset 3, -56
	subq	$312, %rsp
	.cfi_def_cfa_offset 368
	movq	%fs:40, %rax
	movq	%rax, 296(%rsp)
	xorl	%eax, %eax
	testq	%rdi, %rdi
	je	.L70
	testq	%rdx, %rdx
	je	.L70
	leal	-3(%rcx), %eax
	movq	%rdi, %r8
	movl	%esi, %r9d
	cmpl	$1, %eax
	jbe	.L101
	testl	%ecx, %ecx
	jne	.L70
.L101:
	cmpl	$21, %r9d
	jle	.L70
	movl	4(%r8), %r10d
	movl	(%r8), %r14d
	movl	%r10d, %r11d
	bswap	%r11d
	movl	%r11d, (%rdx)
	movl	8(%r8), %ebx
	movl	%ebx, %esi
	bswap	%esi
	movl	%esi, 4(%rdx)
	movzbl	12(%r8), %edi
	movb	%dil, 8(%rdx)
	leal	-3(%rdi), %eax
	movzbl	13(%r8), %ebp
	cmpb	$1, %al
	seta	%al
	cmpb	$1, %bpl
	movb	%bpl, 9(%rdx)
	seta	%dl
	orl	%edx, %eax
	testl	%ebx, %ebx
	sete	%dl
	orl	%edx, %eax
	testl	%r10d, %r10d
	sete	%dl
	orb	%dl, %al
	jne	.L70
	cmpl	$1718185841, %r14d
	je	.L118
.L70:
	xorl	%edx, %edx
.L66:
	movq	296(%rsp), %rax
	subq	%fs:40, %rax
	jne	.L119
	addq	$312, %rsp
	.cfi_remember_state
	.cfi_def_cfa_offset 56
	movq	%rdx, %rax
	popq	%rbx
	.cfi_def_cfa_offset 48
	popq	%rbp
	.cfi_def_cfa_offset 40
	popq	%r12
	.cfi_def_cfa_offset 32
	popq	%r13
	.cfi_def_cfa_offset 24
	popq	%r14
	.cfi_def_cfa_offset 16
	popq	%r15
	.cfi_def_cfa_offset 8
	ret
	.p2align 4,,10
	.p2align 3
.L118:
	.cfi_restore_state
	movl	$400000000, %eax
	xorl	%edx, %edx
	divl	%r11d
	cmpl	%eax, %esi
	jnb	.L70
	testl	%ecx, %ecx
	movl	%ecx, %ebx
	movq	%r8, 16(%rsp)
	cmove	%edi, %ebx
	imull	%r11d, %esi
	movl	%r9d, 24(%rsp)
	imull	%ebx, %esi
	movslq	%esi, %rdi
	movl	%esi, (%rsp)
	call	malloc@PLT
	movq	%rax, %rdx
	testq	%rax, %rax
	je	.L70
	movl	(%rsp), %esi
	leaq	32(%rsp), %rdi
	movl	$32, %ecx
	xorl	%eax, %eax
	movq	%rdi, 8(%rsp)
	rep stosq
	testl	%esi, %esi
	jle	.L66
	movl	24(%rsp), %r9d
	cmpl	$4, %ebx
	movq	16(%rsp), %r8
	leal	-8(%r9), %r13d
	je	.L98
	movb	$-1, 16(%rsp)
	xorl	%eax, %eax
	movl	$14, %ebx
	xorl	%r9d, %r9d
	movq	%r8, (%rsp)
	xorl	%ebp, %ebp
	xorl	%r11d, %r11d
	xorl	%edi, %edi
	jmp	.L87
	.p2align 5
	.p2align 4,,10
	.p2align 3
.L75:
	subl	$1, %r9d
.L81:
	movb	%r11b, (%rdx,%rax)
	movb	%bpl, 1(%rdx,%rax)
	movb	%dil, 2(%rdx,%rax)
	addq	$3, %rax
	cmpl	%eax, %esi
	jle	.L66
.L87:
	testl	%r9d, %r9d
	jg	.L75
	cmpl	%ebx, %r13d
	jg	.L76
.L120:
	movb	%r11b, (%rdx,%rax)
	movb	%bpl, 1(%rdx,%rax)
	movb	%dil, 2(%rdx,%rax)
	addq	$3, %rax
	cmpl	%eax, %esi
	jle	.L66
	cmpl	%ebx, %r13d
	jle	.L120
.L76:
	movq	(%rsp), %r15
	movslq	%ebx, %rcx
	leal	1(%rbx), %r10d
	movzbl	(%r15,%rcx), %r8d
	movl	%r8d, %ecx
	cmpb	$-2, %r8b
	je	.L121
	cmpl	$255, %r8d
	je	.L82
	cmpb	$63, %r8b
	jbe	.L83
	movl	%r8d, %r15d
	andl	$-64, %r15d
	cmpb	$64, %r15b
	je	.L84
	cmpb	$-128, %r15b
	je	.L85
	andl	$63, %ecx
	cmpb	$-64, %r15b
	movl	%r10d, %ebx
	cmove	%ecx, %r9d
	.p2align 4
	.p2align 3
.L86:
	movzbl	%bpl, %r15d
	movzbl	%r11b, %r8d
	movzbl	%dil, %r14d
	leal	(%r8,%r8,2), %r10d
	leal	(%r15,%r15,4), %ecx
	addl	%r10d, %ecx
	leal	(%rcx,%r14,8), %r10d
	movzbl	16(%rsp), %ecx
	subl	%r14d, %r10d
	leal	(%rcx,%rcx,4), %r12d
	leal	(%rcx,%r12,2), %r12d
	sall	$8, %ecx
	orl	%r14d, %ecx
	addl	%r12d, %r10d
	sall	$8, %ecx
	andl	$63, %r10d
	orl	%r15d, %ecx
	movq	8(%rsp), %r15
	sall	$8, %ecx
	orl	%r8d, %ecx
	movl	%ecx, (%r15,%r10,4)
	jmp	.L81
	.p2align 4,,10
	.p2align 3
.L82:
	leal	2(%rbx), %ecx
	leal	3(%rbx), %edi
	movslq	%r10d, %r10
	movslq	%ecx, %rcx
	movslq	%edi, %rdi
	movzbl	(%r15,%r10), %r11d
	movzbl	(%r15,%rcx), %ebp
	leal	4(%rbx), %ecx
	movzbl	(%r15,%rdi), %edi
	addl	$5, %ebx
	movslq	%ecx, %rcx
	movzbl	(%r15,%rcx), %ecx
	movb	%cl, 16(%rsp)
	jmp	.L86
	.p2align 4,,10
	.p2align 3
.L121:
	leal	3(%rbx), %ecx
	leal	2(%rbx), %edi
	movslq	%r10d, %r10
	addl	$4, %ebx
	movslq	%edi, %rdi
	movslq	%ecx, %rcx
	movzbl	(%r15,%r10), %r11d
	movzbl	(%r15,%rdi), %ebp
	movzbl	(%r15,%rcx), %edi
	jmp	.L86
	.p2align 4,,10
	.p2align 3
.L98:
	movb	$-1, (%rsp)
	xorl	%ecx, %ecx
	movl	$14, %ebp
	xorl	%r9d, %r9d
	movl	%esi, 16(%rsp)
	xorl	%r14d, %r14d
	xorl	%r12d, %r12d
	movq	%r8, 24(%rsp)
	movq	%rdx, %r8
	xorl	%edx, %edx
	.p2align 6
	.p2align 4
	.p2align 3
.L74:
	testl	%r9d, %r9d
	jle	.L122
	movzbl	(%rsp), %eax
	subl	$1, %r9d
	movzbl	%dl, %ebx
	movzbl	%r14b, %r11d
	movzbl	%r12b, %r10d
.L89:
	sall	$8, %eax
	orl	%ebx, %eax
	sall	$8, %eax
	orl	%r11d, %eax
	sall	$8, %eax
	orl	%r10d, %eax
	movl	%eax, (%r8,%rcx)
	addq	$4, %rcx
	cmpl	%ecx, 16(%rsp)
	jg	.L74
.L115:
	movq	%r8, %rdx
	jmp	.L66
	.p2align 4,,10
	.p2align 3
.L83:
	movslq	%r8d, %r8
	movzbl	35(%rsp,%r8,4), %ebx
	movzbl	32(%rsp,%r8,4), %r11d
	movzbl	33(%rsp,%r8,4), %ebp
	movzbl	34(%rsp,%r8,4), %edi
	movb	%bl, 16(%rsp)
	movl	%r10d, %ebx
	jmp	.L86
	.p2align 4,,10
	.p2align 3
.L122:
	movzbl	(%rsp), %eax
	movzbl	%dl, %esi
	movl	16(%rsp), %r11d
	sall	$8, %eax
	orl	%esi, %eax
	movzbl	%r14b, %esi
	sall	$8, %eax
	orl	%esi, %eax
	movzbl	%r12b, %esi
	sall	$8, %eax
	orl	%esi, %eax
.L88:
	cmpl	%ebp, %r13d
	jg	.L90
	leaq	4(%rcx), %r10
	movl	%eax, (%r8,%rcx)
	cmpl	%r10d, %r11d
	jle	.L115
	movl	%eax, 4(%r8,%rcx)
	addq	$8, %rcx
	cmpl	%ecx, %r11d
	jg	.L88
	jmp	.L115
	.p2align 4,,10
	.p2align 3
.L90:
	movq	24(%rsp), %rbx
	movslq	%ebp, %rax
	leal	1(%rbp), %edi
	movzbl	(%rbx,%rax), %esi
	movl	%esi, %eax
	cmpb	$-2, %sil
	je	.L123
	cmpl	$255, %esi
	je	.L124
	cmpb	$63, %sil
	ja	.L94
	movslq	%esi, %rsi
	movl	%edi, %ebp
	movzbl	35(%rsp,%rsi,4), %eax
	movzbl	32(%rsp,%rsi,4), %r12d
	movzbl	33(%rsp,%rsi,4), %r14d
	movzbl	34(%rsp,%rsi,4), %edx
	movb	%al, (%rsp)
.L92:
	movzbl	%r12b, %r10d
	movzbl	%r14b, %r11d
	movzbl	%dl, %ebx
	movq	8(%rsp), %r15
	leal	(%r10,%r10,2), %esi
	leal	(%r11,%r11,4), %eax
	addl	%esi, %eax
	leal	(%rax,%rbx,8), %esi
	movzbl	(%rsp), %eax
	subl	%ebx, %esi
	leal	(%rax,%rax,4), %edi
	leal	(%rax,%rdi,2), %edi
	addl	%edi, %esi
	movl	%eax, %edi
	sall	$8, %edi
	andl	$63, %esi
	orl	%ebx, %edi
	sall	$8, %edi
	orl	%r11d, %edi
	sall	$8, %edi
	orl	%r10d, %edi
	movl	%edi, (%r15,%rsi,4)
	jmp	.L89
	.p2align 4,,10
	.p2align 3
.L123:
	leal	3(%rbp), %eax
	leal	2(%rbp), %edx
	movslq	%edi, %rdi
	addl	$4, %ebp
	movslq	%edx, %rdx
	cltq
	movzbl	(%rbx,%rdi), %r12d
	movzbl	(%rbx,%rdx), %r14d
	movzbl	(%rbx,%rax), %edx
	jmp	.L92
	.p2align 4,,10
	.p2align 3
.L124:
	leal	2(%rbp), %eax
	leal	3(%rbp), %edx
	movslq	%edi, %rdi
	cltq
	movslq	%edx, %rdx
	movzbl	(%rbx,%rdi), %r12d
	movzbl	(%rbx,%rax), %r14d
	leal	4(%rbp), %eax
	movzbl	(%rbx,%rdx), %edx
	addl	$5, %ebp
	cltq
	movzbl	(%rbx,%rax), %eax
	movb	%al, (%rsp)
	jmp	.L92
	.p2align 4,,10
	.p2align 3
.L94:
	movl	%esi, %r10d
	andl	$-64, %r10d
	cmpb	$64, %r10b
	je	.L125
	cmpb	$-128, %r10b
	je	.L126
	andl	$63, %eax
	cmpb	$-64, %r10b
	movl	%edi, %ebp
	cmove	%eax, %r9d
	jmp	.L92
.L84:
	movl	%r8d, %ebx
	sarl	$2, %r8d
	andl	$3, %ecx
	sarl	$4, %ebx
	andl	$3, %r8d
	leal	-2(%rdi,%rcx), %edi
	andl	$3, %ebx
	leal	-2(%rbp,%r8), %ebp
	leal	-2(%r11,%rbx), %r11d
	movl	%r10d, %ebx
	jmp	.L86
.L85:
	movq	(%rsp), %r15
	movslq	%r10d, %r10
	andl	$63, %ecx
	addl	$2, %ebx
	leal	-40(%r11,%rcx), %r11d
	leal	-32(%rbp,%rcx), %ebp
	movzbl	(%r15,%r10), %r8d
	leal	-40(%rdi,%rcx), %ecx
	movl	%r8d, %r10d
	andl	$15, %r8d
	shrb	$4, %r10b
	leal	(%rcx,%r8), %edi
	addl	%r10d, %r11d
	jmp	.L86
.L125:
	movl	%esi, %r10d
	sarl	$2, %esi
	andl	$3, %eax
	movl	%edi, %ebp
	sarl	$4, %r10d
	andl	$3, %esi
	leal	-2(%rdx,%rax), %edx
	andl	$3, %r10d
	leal	-2(%rsi,%r14), %r14d
	leal	-2(%r10,%r12), %r12d
	jmp	.L92
.L126:
	movslq	%edi, %rdi
	andl	$63, %eax
	addl	$2, %ebp
	movzbl	(%rbx,%rdi), %esi
	leal	-40(%rax,%r12), %r10d
	leal	-32(%rax,%r14), %r14d
	leal	-40(%rdx,%rax), %eax
	movl	%esi, %edi
	andl	$15, %esi
	shrb	$4, %dil
	leal	(%rax,%rsi), %edx
	leal	(%rdi,%r10), %r12d
	jmp	.L92
.L119:
	call	__stack_chk_fail@PLT
	.cfi_endproc
.LFE34:
	.size	qoi_decode_ref, .-qoi_decode_ref
	.section	.rodata.str1.1,"aMS",@progbits,1
.LC1:
	.string	"wb"
	.text
	.p2align 4
	.globl	qoi_write_ref
	.type	qoi_write_ref, @function
qoi_write_ref:
.LFB59:
	.cfi_startproc
	endbr64
	pushq	%r13
	.cfi_def_cfa_offset 16
	.cfi_offset 13, -16
	pushq	%r12
	.cfi_def_cfa_offset 24
	.cfi_offset 12, -24
	pushq	%rbp
	.cfi_def_cfa_offset 32
	.cfi_offset 6, -32
	movq	%rsi, %rbp
	leaq	.LC1(%rip), %rsi
	pushq	%rbx
	.cfi_def_cfa_offset 40
	.cfi_offset 3, -40
	subq	$24, %rsp
	.cfi_def_cfa_offset 64
	movq	%fs:40, %r12
	movq	%r12, 8(%rsp)
	movq	%rdx, %r12
	call	fopen@PLT
	testq	%rax, %rax
	je	.L129
	movq	%rbp, %rdi
	leaq	4(%rsp), %rdx
	movq	%r12, %rsi
	movq	%rax, %rbx
	call	qoi_encode_ref
	movq	%rax, %rbp
	testq	%rax, %rax
	je	.L135
	movslq	4(%rsp), %rdx
	movq	%rbx, %rcx
	movl	$1, %esi
	movq	%rax, %rdi
	movq	%rdx, %r12
	call	fwrite@PLT
	movq	%rbx, %rdi
	call	fflush@PLT
	movq	%rbx, %rdi
	call	ferror@PLT
	movq	%rbx, %rdi
	movl	%eax, %r13d
	call	fclose@PLT
	movq	%rbp, %rdi
	call	free@PLT
	testl	%r13d, %r13d
	jne	.L129
.L127:
	movq	8(%rsp), %rax
	subq	%fs:40, %rax
	jne	.L136
	addq	$24, %rsp
	.cfi_remember_state
	.cfi_def_cfa_offset 40
	movl	%r12d, %eax
	popq	%rbx
	.cfi_def_cfa_offset 32
	popq	%rbp
	.cfi_def_cfa_offset 24
	popq	%r12
	.cfi_def_cfa_offset 16
	popq	%r13
	.cfi_def_cfa_offset 8
	ret
	.p2align 4,,10
	.p2align 3
.L135:
	.cfi_restore_state
	movq	%rbx, %rdi
	call	fclose@PLT
.L129:
	xorl	%r12d, %r12d
	jmp	.L127
.L136:
	call	__stack_chk_fail@PLT
	.cfi_endproc
.LFE59:
	.size	qoi_write_ref, .-qoi_write_ref
	.section	.rodata.str1.1
.LC2:
	.string	"rb"
	.text
	.p2align 4
	.globl	qoi_read_ref
	.type	qoi_read_ref, @function
qoi_read_ref:
.LFB60:
	.cfi_startproc
	endbr64
	pushq	%r15
	.cfi_def_cfa_offset 16
	.cfi_offset 15, -16
	movq	%rsi, %r15
	leaq	.LC2(%rip), %rsi
	pushq	%r14
	.cfi_def_cfa_offset 24
	.cfi_offset 14, -24
	pushq	%r13
	.cfi_def_cfa_offset 32
	.cfi_offset 13, -32
	movl	%edx, %r13d
	pushq	%r12
	.cfi_def_cfa_offset 40
	.cfi_offset 12, -40
	pushq	%rbp
	.cfi_def_cfa_offset 48
	.cfi_offset 6, -48
	pushq	%rbx
	.cfi_def_cfa_offset 56
	.cfi_offset 3, -56
	subq	$24, %rsp
	.cfi_def_cfa_offset 80
	call	fopen@PLT
	testq	%rax, %rax
	je	.L138
	movq	%rax, %rbx
	movl	$2, %edx
	xorl	%esi, %esi
	movq	%rax, %rdi
	call	fseek@PLT
	movq	%rbx, %rdi
	call	ftell@PLT
	movl	%eax, 12(%rsp)
	movq	%rax, %rbp
	testl	%eax, %eax
	jle	.L141
	xorl	%edx, %edx
	xorl	%esi, %esi
	movq	%rbx, %rdi
	call	fseek@PLT
	testl	%eax, %eax
	jne	.L141
	movslq	%ebp, %rdx
	movq	%rdx, %rdi
	movq	%rdx, (%rsp)
	call	malloc@PLT
	movq	(%rsp), %rdx
	testq	%rax, %rax
	movq	%rax, %r12
	je	.L141
	movq	%rbx, %rcx
	movl	$1, %esi
	movq	%rax, %rdi
	call	fread@PLT
	movq	%rbx, %rdi
	xorl	%ebx, %ebx
	movq	%rax, %r14
	call	fclose@PLT
	cmpl	%r14d, %ebp
	je	.L149
.L143:
	movq	%r12, %rdi
	call	free@PLT
.L137:
	addq	$24, %rsp
	.cfi_remember_state
	.cfi_def_cfa_offset 56
	movq	%rbx, %rax
	popq	%rbx
	.cfi_def_cfa_offset 48
	popq	%rbp
	.cfi_def_cfa_offset 40
	popq	%r12
	.cfi_def_cfa_offset 32
	popq	%r13
	.cfi_def_cfa_offset 24
	popq	%r14
	.cfi_def_cfa_offset 16
	popq	%r15
	.cfi_def_cfa_offset 8
	ret
	.p2align 4,,10
	.p2align 3
.L141:
	.cfi_restore_state
	movq	%rbx, %rdi
	call	fclose@PLT
.L138:
	xorl	%ebx, %ebx
	jmp	.L137
	.p2align 4,,10
	.p2align 3
.L149:
	movl	12(%rsp), %esi
	movl	%r13d, %ecx
	movq	%r15, %rdx
	movq	%r12, %rdi
	call	qoi_decode_ref
	movq	%rax, %rbx
	jmp	.L143
	.cfi_endproc
.LFE60:
	.size	qoi_read_ref, .-qoi_read_ref
	.ident	"GCC: (Ubuntu 15.2.0-16ubuntu1) 15.2.0"
	.section	.note.GNU-stack,"",@progbits
	.section	.note.gnu.property,"a"
	.align 8
	.long	1f - 0f
	.long	4f - 1f
	.long	5
0:
	.string	"GNU"
1:
	.align 8
	.long	0xc0000002
	.long	3f - 2f
2:
	.long	0x3
3:
	.align 8
4:
