	.file	"optimized.c"
	.text
	.p2align 4
	.globl	qoi_encode_opt
	.type	qoi_encode_opt, @function
qoi_encode_opt:
.LFB33:
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
	movq	%rdx, %rbp
	pushq	%rbx
	.cfi_def_cfa_offset 56
	.cfi_offset 3, -56
	subq	$312, %rsp
	.cfi_def_cfa_offset 368
	movq	%fs:40, %r12
	movq	%r12, 296(%rsp)
	xorl	%r12d, %r12d
	testq	%rdx, %rdx
	sete	%al
	testq	%rsi, %rsi
	sete	%dl
	orb	%dl, %al
	jne	.L5
	movq	%rdi, %r15
	testq	%rdi, %rdi
	je	.L5
	movl	(%rsi), %ecx
	movl	%ecx, %eax
	bswap	%eax
	movl	%eax, %r14d
	testl	%ecx, %ecx
	je	.L5
	movl	4(%rsi), %edi
	movl	%edi, %eax
	bswap	%eax
	movl	%eax, %r8d
	testl	%edi, %edi
	je	.L5
	movzbl	8(%rsi), %r13d
	leal	-3(%r13), %eax
	cmpb	$1, %al
	ja	.L5
	movzbl	9(%rsi), %r9d
	cmpb	$1, %r9b
	ja	.L5
	movl	$400000000, %eax
	xorl	%edx, %edx
	divl	%ecx
	cmpl	%eax, %edi
	jnb	.L5
	movl	%ecx, %ebx
	movzbl	%r13b, %r11d
	movb	%r9b, 12(%rsp)
	imull	%edi, %ebx
	leal	1(%r11), %edi
	movl	%r11d, (%rsp)
	movl	%r8d, 16(%rsp)
	imull	%ebx, %edi
	addl	$22, %edi
	movslq	%edi, %rdi
	call	malloc@PLT
	movq	%rax, %rsi
	testq	%rax, %rax
	je	.L5
	movl	(%rsp), %r11d
	movzbl	12(%rsp), %r9d
	movl	$1718185841, (%rax)
	movl	$32, %ecx
	movl	16(%rsp), %r8d
	movl	%r14d, 4(%rax)
	leaq	32(%rsp), %rdi
	imull	%r11d, %ebx
	movb	%r13b, 12(%rax)
	movl	%r8d, 8(%rax)
	movb	%r9b, 13(%rax)
	movq	%r12, %rax
	movl	$-16777216, %r12d
	rep stosq
	movl	%ebx, %eax
	movl	%ebx, 12(%rsp)
	subl	%r11d, %eax
	movl	%eax, 20(%rsp)
	cmpb	$4, %r13b
	je	.L6
	testl	%ebx, %ebx
	jle	.L35
	movq	%rsi, (%rsp)
	xorl	%r8d, %r8d
	movl	$-16777216, %r13d
	xorl	%eax, %eax
	movq	%rbp, 24(%rsp)
	movl	$14, %edi
	movl	$14, %ecx
	movl	$-16777216, %ebx
	.p2align 4
	.p2align 3
.L7:
	movzwl	(%r15,%r8), %edx
	andl	$-16777216, %r12d
	movzbl	2(%r15,%r8), %r10d
	movq	(%rsp), %r14
	movzwl	%dx, %r11d
	movl	%r10d, %esi
	movl	%r10d, %r9d
	orl	%r11d, %r12d
	sall	$16, %esi
	leaq	(%r14,%rcx), %r11
	orl	%r12d, %esi
	movl	%esi, %r12d
	cmpl	%r13d, %esi
	je	.L64
	movzbl	%dh, %ebp
	testl	%eax, %eax
	je	.L24
	subl	$1, %eax
	addl	$1, %edi
	orl	$-64, %eax
	movslq	%edi, %rcx
	movb	%al, (%r11)
.L24:
	movzbl	%bpl, %r11d
	movzbl	%dl, %r13d
	addq	(%rsp), %rcx
	leal	(%r11,%r11,4), %r14d
	leal	0(%r13,%r13,2), %eax
	movl	%r11d, 16(%rsp)
	addl	%r14d, %eax
	leal	(%rax,%r10,8), %eax
	subl	%r10d, %eax
	addl	$2805, %eax
	movl	%eax, %r14d
	andl	$63, %eax
	andl	$63, %r14d
	cmpl	32(%rsp,%rax,4), %esi
	je	.L65
	movl	%ebp, %r14d
	movl	%esi, 32(%rsp,%rax,4)
	movzbl	%bh, %eax
	subl	%ebx, %edx
	subl	%eax, %r14d
	shrl	$16, %ebx
	subl	%ebp, %eax
	subl	%ebx, %r9d
	leal	(%rdx,%rax), %ebx
	addl	$2, %edx
	leal	(%r9,%rax), %ebp
	leal	8(%rbx), %eax
	cmpb	$2, %dl
	ja	.L26
	leal	2(%r14), %r11d
	cmpb	$2, %r11b
	ja	.L26
	addl	$2, %r9d
	cmpb	$2, %r9b
	jbe	.L27
	cmpb	$15, %al
	jbe	.L28
	.p2align 4
	.p2align 3
.L29:
	movl	16(%rsp), %r11d
	movl	%r13d, %edx
	sall	$24, %r10d
	movl	$4, %eax
	sall	$8, %edx
	sall	$16, %r11d
	orl	%r11d, %edx
	orl	%r10d, %edx
	orb	$-2, %dl
.L31:
	addl	%eax, %edi
	movl	%edx, (%rcx)
	xorl	%eax, %eax
	movslq	%edi, %rcx
.L22:
	movl	%esi, %ebx
	addq	$3, %r8
	cmpl	%r8d, 12(%rsp)
	jle	.L60
.L67:
	movl	%esi, %r13d
	jmp	.L7
	.p2align 4,,10
	.p2align 3
.L5:
	xorl	%esi, %esi
.L1:
	movq	296(%rsp), %rax
	subq	%fs:40, %rax
	jne	.L66
	addq	$312, %rsp
	.cfi_remember_state
	.cfi_def_cfa_offset 56
	movq	%rsi, %rax
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
.L26:
	.cfi_restore_state
	cmpb	$15, %al
	ja	.L29
	leal	32(%r14), %eax
	cmpb	$63, %al
	ja	.L29
.L28:
	leal	8(%rbp), %eax
	movsbl	%r14b, %r14d
	cmpb	$15, %al
	setbe	%al
	movzbl	%al, %eax
	testl	%eax, %eax
	je	.L29
	leal	8(%rbx), %edx
	movsbl	%bpl, %eax
	addl	$32, %r14d
	movsbl	%dl, %edx
	addl	$8, %eax
	sall	$4, %edx
	orl	%eax, %edx
	movl	$2, %eax
	sall	$8, %edx
	orl	%r14d, %edx
	orb	$-128, %dl
	jmp	.L31
	.p2align 4,,10
	.p2align 3
.L64:
	addl	$1, %eax
	cmpl	$62, %eax
	je	.L37
	cmpl	%r8d, 20(%rsp)
	jne	.L22
.L37:
	subl	$1, %eax
	addl	$1, %edi
	movl	%esi, %ebx
	addq	$3, %r8
	orl	$-64, %eax
	movslq	%edi, %rcx
	movb	%al, (%r11)
	xorl	%eax, %eax
	cmpl	%r8d, 12(%rsp)
	jg	.L67
	.p2align 4
	.p2align 3
.L60:
	movq	(%rsp), %rsi
	movq	24(%rsp), %rbp
.L8:
	movabsq	$72057594037927936, %rax
	addl	$8, %edi
	movq	%rax, (%rsi,%rcx)
	movl	%edi, 0(%rbp)
	jmp	.L1
	.p2align 4,,10
	.p2align 3
.L65:
	addl	$1, %edi
	movb	%r14b, (%rcx)
	xorl	%eax, %eax
	movslq	%edi, %rcx
	jmp	.L22
	.p2align 4,,10
	.p2align 3
.L27:
	movsbl	%dl, %edx
	movsbl	%r14b, %r14d
	movsbl	%r9b, %r9d
	leal	8(,%r14,4), %eax
	sall	$4, %edx
	orl	%eax, %edx
	movl	$1, %eax
	orl	%r9d, %edx
	orl	$64, %edx
	jmp	.L31
	.p2align 4,,10
	.p2align 3
.L6:
	movl	%ebx, %r13d
	testl	%ebx, %ebx
	jle	.L35
	movq	%rbp, (%rsp)
	xorl	%r8d, %r8d
	movl	$-16777216, %r11d
	xorl	%edx, %edx
	movl	$14, %edi
	movl	$14, %ecx
	movl	$-16777216, %ebx
	jmp	.L20
	.p2align 4,,10
	.p2align 3
.L9:
	testl	%edx, %edx
	je	.L12
	subl	$1, %edx
	addl	$1, %edi
	orl	$-64, %edx
	movslq	%edi, %rcx
	movb	%dl, (%r9)
.L12:
	movzbl	%ah, %edx
	movl	%eax, %r9d
	movl	%eax, %r10d
	shrl	$16, %r9d
	movl	%edx, %r12d
	movzbl	%al, %edx
	shrl	$24, %r10d
	leal	(%rdx,%rdx,2), %edx
	leal	(%r12,%r12,4), %r11d
	movl	%r12d, %ebp
	addl	%edx, %r11d
	movzbl	%r9b, %edx
	leal	(%r10,%r10,4), %r14d
	leal	(%r11,%rdx,8), %r11d
	subl	%edx, %r11d
	leal	(%r10,%r14,2), %edx
	addl	%r11d, %edx
	leaq	(%rsi,%rcx), %r11
	movl	%edx, %r14d
	andl	$63, %edx
	andl	$63, %r14d
	cmpl	%eax, 32(%rsp,%rdx,4)
	je	.L68
	movl	%eax, 32(%rsp,%rdx,4)
	movl	%ebx, %edx
	shrl	$24, %edx
	cmpb	%dl, %r10b
	je	.L69
	addl	$5, %edi
	movb	$-1, (%r11)
	xorl	%edx, %edx
	movb	%al, 1(%rsi,%rcx)
	movb	%r12b, 2(%rsi,%rcx)
	movb	%r9b, 3(%rsi,%rcx)
	movb	%r10b, 4(%rsi,%rcx)
	movslq	%edi, %rcx
.L10:
	addq	$4, %r8
	movl	%eax, %ebx
	cmpl	%r8d, %r13d
	jle	.L59
	movl	%eax, %r11d
.L20:
	movl	(%r15,%r8), %eax
	leaq	(%rsi,%rcx), %r9
	cmpl	%r11d, %eax
	jne	.L9
	addl	$1, %edx
	cmpl	$62, %edx
	je	.L36
	cmpl	%r8d, 20(%rsp)
	jne	.L10
.L36:
	subl	$1, %edx
	addl	$1, %edi
	orl	$-64, %edx
	movslq	%edi, %rcx
	movb	%dl, (%r9)
	xorl	%edx, %edx
	jmp	.L10
	.p2align 4,,10
	.p2align 3
.L68:
	addl	$1, %edi
	movb	%r14b, (%r11)
	xorl	%edx, %edx
	movslq	%edi, %rcx
	jmp	.L10
	.p2align 4,,10
	.p2align 3
.L69:
	movzbl	%bh, %ecx
	movl	%eax, %edx
	movl	%r12d, %r10d
	subl	%ebx, %edx
	subl	%ecx, %r10d
	shrl	$16, %ebx
	subl	%r12d, %ecx
	subl	%ebx, %r9d
	leal	(%rdx,%rcx), %ebx
	addl	$2, %edx
	leal	(%r9,%rcx), %r14d
	leal	8(%rbx), %ecx
	cmpb	$2, %dl
	ja	.L15
	leal	2(%r10), %r12d
	cmpb	$2, %r12b
	ja	.L15
	addl	$2, %r9d
	cmpb	$2, %r9b
	jbe	.L16
	cmpb	$15, %cl
	ja	.L17
.L62:
	leal	8(%r14), %edx
	movsbl	%r10b, %r10d
	cmpb	$15, %dl
	ja	.L17
	addl	$8, %ebx
	leal	8(%r14), %ecx
	addl	$32, %r10d
	movsbl	%bl, %edx
	movsbl	%cl, %ecx
	sall	$4, %edx
	orl	%ecx, %edx
	movl	$2, %ecx
	sall	$8, %edx
	orl	%r10d, %edx
	orb	$-128, %dl
.L19:
	addl	%ecx, %edi
	movl	%edx, (%r11)
	xorl	%edx, %edx
	movslq	%edi, %rcx
	jmp	.L10
	.p2align 4,,10
	.p2align 3
.L15:
	cmpb	$15, %cl
	ja	.L17
	leal	32(%r10), %edx
	cmpb	$63, %dl
	jbe	.L62
.L17:
	movl	%eax, %edx
	sall	$16, %ebp
	movl	$4, %ecx
	bswap	%edx
	andl	$-16711936, %edx
	roll	$16, %edx
	orl	%ebp, %edx
	orb	$-2, %dl
	jmp	.L19
	.p2align 4,,10
	.p2align 3
.L59:
	movq	(%rsp), %rbp
	jmp	.L8
.L16:
	movsbl	%dl, %edx
	movsbl	%r10b, %r10d
	movsbl	%r9b, %r9d
	leal	8(,%r10,4), %ecx
	sall	$4, %edx
	orl	%ecx, %edx
	movl	$1, %ecx
	orl	%r9d, %edx
	orl	$64, %edx
	jmp	.L19
	.p2align 4,,10
	.p2align 3
.L35:
	movl	$14, %edi
	movl	$14, %ecx
	jmp	.L8
.L66:
	call	__stack_chk_fail@PLT
	.cfi_endproc
.LFE33:
	.size	qoi_encode_opt, .-qoi_encode_opt
	.p2align 4
	.globl	qoi_decode_opt
	.type	qoi_decode_opt, @function
qoi_decode_opt:
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
	je	.L74
	testq	%rdx, %rdx
	je	.L74
	leal	-3(%rcx), %eax
	movq	%rdi, %r8
	movl	%esi, %r9d
	cmpl	$1, %eax
	jbe	.L105
	testl	%ecx, %ecx
	jne	.L74
.L105:
	cmpl	$21, %r9d
	jle	.L74
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
	jne	.L74
	cmpl	$1718185841, %r14d
	je	.L122
.L74:
	xorl	%edx, %edx
.L70:
	movq	296(%rsp), %rax
	subq	%fs:40, %rax
	jne	.L123
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
.L122:
	.cfi_restore_state
	movl	$400000000, %eax
	xorl	%edx, %edx
	divl	%r11d
	cmpl	%eax, %esi
	jnb	.L74
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
	je	.L74
	movl	(%rsp), %esi
	leaq	32(%rsp), %rdi
	movl	$32, %ecx
	xorl	%eax, %eax
	movq	%rdi, 8(%rsp)
	rep stosq
	testl	%esi, %esi
	jle	.L70
	movl	24(%rsp), %r9d
	cmpl	$4, %ebx
	movq	16(%rsp), %r8
	leal	-8(%r9), %r13d
	je	.L102
	movb	$-1, 16(%rsp)
	xorl	%eax, %eax
	movl	$14, %ebx
	xorl	%r9d, %r9d
	movq	%r8, (%rsp)
	xorl	%ebp, %ebp
	xorl	%r11d, %r11d
	xorl	%edi, %edi
	jmp	.L91
	.p2align 5
	.p2align 4,,10
	.p2align 3
.L79:
	subl	$1, %r9d
.L85:
	movb	%r11b, (%rdx,%rax)
	movb	%bpl, 1(%rdx,%rax)
	movb	%dil, 2(%rdx,%rax)
	addq	$3, %rax
	cmpl	%eax, %esi
	jle	.L70
.L91:
	testl	%r9d, %r9d
	jg	.L79
	cmpl	%ebx, %r13d
	jg	.L80
.L124:
	movb	%r11b, (%rdx,%rax)
	movb	%bpl, 1(%rdx,%rax)
	movb	%dil, 2(%rdx,%rax)
	addq	$3, %rax
	cmpl	%eax, %esi
	jle	.L70
	cmpl	%ebx, %r13d
	jle	.L124
.L80:
	movq	(%rsp), %r15
	movslq	%ebx, %rcx
	leal	1(%rbx), %r10d
	movzbl	(%r15,%rcx), %r8d
	movl	%r8d, %ecx
	cmpb	$-2, %r8b
	je	.L125
	cmpl	$255, %r8d
	je	.L86
	cmpb	$63, %r8b
	jbe	.L87
	movl	%r8d, %r15d
	andl	$-64, %r15d
	cmpb	$64, %r15b
	je	.L88
	cmpb	$-128, %r15b
	je	.L89
	andl	$63, %ecx
	cmpb	$-64, %r15b
	movl	%r10d, %ebx
	cmove	%ecx, %r9d
	.p2align 4
	.p2align 3
.L90:
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
	jmp	.L85
	.p2align 4,,10
	.p2align 3
.L86:
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
	jmp	.L90
	.p2align 4,,10
	.p2align 3
.L125:
	leal	3(%rbx), %ecx
	leal	2(%rbx), %edi
	movslq	%r10d, %r10
	addl	$4, %ebx
	movslq	%edi, %rdi
	movslq	%ecx, %rcx
	movzbl	(%r15,%r10), %r11d
	movzbl	(%r15,%rdi), %ebp
	movzbl	(%r15,%rcx), %edi
	jmp	.L90
	.p2align 4,,10
	.p2align 3
.L102:
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
.L78:
	testl	%r9d, %r9d
	jle	.L126
	movzbl	(%rsp), %eax
	subl	$1, %r9d
	movzbl	%dl, %ebx
	movzbl	%r14b, %r11d
	movzbl	%r12b, %r10d
.L93:
	sall	$8, %eax
	orl	%ebx, %eax
	sall	$8, %eax
	orl	%r11d, %eax
	sall	$8, %eax
	orl	%r10d, %eax
	movl	%eax, (%r8,%rcx)
	addq	$4, %rcx
	cmpl	%ecx, 16(%rsp)
	jg	.L78
.L119:
	movq	%r8, %rdx
	jmp	.L70
	.p2align 4,,10
	.p2align 3
.L87:
	movslq	%r8d, %r8
	movzbl	35(%rsp,%r8,4), %ebx
	movzbl	32(%rsp,%r8,4), %r11d
	movzbl	33(%rsp,%r8,4), %ebp
	movzbl	34(%rsp,%r8,4), %edi
	movb	%bl, 16(%rsp)
	movl	%r10d, %ebx
	jmp	.L90
	.p2align 4,,10
	.p2align 3
.L126:
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
.L92:
	cmpl	%ebp, %r13d
	jg	.L94
	leaq	4(%rcx), %r10
	movl	%eax, (%r8,%rcx)
	cmpl	%r10d, %r11d
	jle	.L119
	movl	%eax, 4(%r8,%rcx)
	addq	$8, %rcx
	cmpl	%ecx, %r11d
	jg	.L92
	jmp	.L119
	.p2align 4,,10
	.p2align 3
.L94:
	movq	24(%rsp), %rbx
	movslq	%ebp, %rax
	leal	1(%rbp), %edi
	movzbl	(%rbx,%rax), %esi
	movl	%esi, %eax
	cmpb	$-2, %sil
	je	.L127
	cmpl	$255, %esi
	je	.L128
	cmpb	$63, %sil
	ja	.L98
	movslq	%esi, %rsi
	movl	%edi, %ebp
	movzbl	35(%rsp,%rsi,4), %eax
	movzbl	32(%rsp,%rsi,4), %r12d
	movzbl	33(%rsp,%rsi,4), %r14d
	movzbl	34(%rsp,%rsi,4), %edx
	movb	%al, (%rsp)
.L96:
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
	jmp	.L93
	.p2align 4,,10
	.p2align 3
.L127:
	leal	3(%rbp), %eax
	leal	2(%rbp), %edx
	movslq	%edi, %rdi
	addl	$4, %ebp
	movslq	%edx, %rdx
	cltq
	movzbl	(%rbx,%rdi), %r12d
	movzbl	(%rbx,%rdx), %r14d
	movzbl	(%rbx,%rax), %edx
	jmp	.L96
	.p2align 4,,10
	.p2align 3
.L128:
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
	jmp	.L96
	.p2align 4,,10
	.p2align 3
.L98:
	movl	%esi, %r10d
	andl	$-64, %r10d
	cmpb	$64, %r10b
	je	.L129
	cmpb	$-128, %r10b
	je	.L130
	andl	$63, %eax
	cmpb	$-64, %r10b
	movl	%edi, %ebp
	cmove	%eax, %r9d
	jmp	.L96
.L88:
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
	jmp	.L90
.L89:
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
	jmp	.L90
.L129:
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
	jmp	.L96
.L130:
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
	jmp	.L96
.L123:
	call	__stack_chk_fail@PLT
	.cfi_endproc
.LFE34:
	.size	qoi_decode_opt, .-qoi_decode_opt
	.section	.rodata.str1.1,"aMS",@progbits,1
.LC1:
	.string	"wb"
	.text
	.p2align 4
	.globl	qoi_write_opt
	.type	qoi_write_opt, @function
qoi_write_opt:
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
	je	.L133
	movq	%rbp, %rdi
	leaq	4(%rsp), %rdx
	movq	%r12, %rsi
	movq	%rax, %rbx
	call	qoi_encode_opt
	movq	%rax, %rbp
	testq	%rax, %rax
	je	.L139
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
	jne	.L133
.L131:
	movq	8(%rsp), %rax
	subq	%fs:40, %rax
	jne	.L140
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
.L139:
	.cfi_restore_state
	movq	%rbx, %rdi
	call	fclose@PLT
.L133:
	xorl	%r12d, %r12d
	jmp	.L131
.L140:
	call	__stack_chk_fail@PLT
	.cfi_endproc
.LFE59:
	.size	qoi_write_opt, .-qoi_write_opt
	.section	.rodata.str1.1
.LC2:
	.string	"rb"
	.text
	.p2align 4
	.globl	qoi_read_opt
	.type	qoi_read_opt, @function
qoi_read_opt:
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
	je	.L142
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
	jle	.L145
	xorl	%edx, %edx
	xorl	%esi, %esi
	movq	%rbx, %rdi
	call	fseek@PLT
	testl	%eax, %eax
	jne	.L145
	movslq	%ebp, %rdx
	movq	%rdx, %rdi
	movq	%rdx, (%rsp)
	call	malloc@PLT
	movq	(%rsp), %rdx
	testq	%rax, %rax
	movq	%rax, %r12
	je	.L145
	movq	%rbx, %rcx
	movl	$1, %esi
	movq	%rax, %rdi
	call	fread@PLT
	movq	%rbx, %rdi
	xorl	%ebx, %ebx
	movq	%rax, %r14
	call	fclose@PLT
	cmpl	%r14d, %ebp
	je	.L153
.L147:
	movq	%r12, %rdi
	call	free@PLT
.L141:
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
.L145:
	.cfi_restore_state
	movq	%rbx, %rdi
	call	fclose@PLT
.L142:
	xorl	%ebx, %ebx
	jmp	.L141
	.p2align 4,,10
	.p2align 3
.L153:
	movl	12(%rsp), %esi
	movl	%r13d, %ecx
	movq	%r15, %rdx
	movq	%r12, %rdi
	call	qoi_decode_opt
	movq	%rax, %rbx
	jmp	.L147
	.cfi_endproc
.LFE60:
	.size	qoi_read_opt, .-qoi_read_opt
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
