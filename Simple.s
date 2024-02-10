	.text
	.file	"Simple.ll"
	.globl	"java/lang/Object_<init>"       # -- Begin function java/lang/Object_<init>
	.p2align	4, 0x90
	.type	"java/lang/Object_<init>",@function
"java/lang/Object_<init>":              # @"java/lang/Object_<init>"
	.cfi_startproc
# %bb.0:
	retq
.Lfunc_end0:
	.size	"java/lang/Object_<init>", .Lfunc_end0-"java/lang/Object_<init>"
	.cfi_endproc
                                        # -- End function
	.globl	"Simple_<init>"                 # -- Begin function Simple_<init>
	.p2align	4, 0x90
	.type	"Simple_<init>",@function
"Simple_<init>":                        # @"Simple_<init>"
	.cfi_startproc
# %bb.0:
	pushq	%rbx
	.cfi_def_cfa_offset 16
	.cfi_offset %rbx, -16
	movq	%rdi, %rbx
	callq	"java/lang/Object_<init>"@PLT
	movl	$0, (%rbx)
	callq	print@PLT
	popq	%rbx
	.cfi_def_cfa_offset 8
	retq
.Lfunc_end1:
	.size	"Simple_<init>", .Lfunc_end1-"Simple_<init>"
	.cfi_endproc
                                        # -- End function
	.globl	Simple_doSomething              # -- Begin function Simple_doSomething
	.p2align	4, 0x90
	.type	Simple_doSomething,@function
Simple_doSomething:                     # @Simple_doSomething
	.cfi_startproc
# %bb.0:
	pushq	%rax
	.cfi_def_cfa_offset 16
	movl	$0, (%rdi)
	callq	print@PLT
	popq	%rax
	.cfi_def_cfa_offset 8
	retq
.Lfunc_end2:
	.size	Simple_doSomething, .Lfunc_end2-Simple_doSomething
	.cfi_endproc
                                        # -- End function
	.globl	main                            # -- Begin function main
	.p2align	4, 0x90
	.type	main,@function
main:                                   # @main
	.cfi_startproc
# %bb.0:
	pushq	%rax
	.cfi_def_cfa_offset 16
	movq	%rsp, %rdi
	callq	"Simple_<init>"@PLT
	movl	(%rsp), %edi
	callq	Simple_doSomething@PLT
	callq	call2@PLT
	xorl	%eax, %eax
	popq	%rcx
	.cfi_def_cfa_offset 8
	retq
.Lfunc_end3:
	.size	main, .Lfunc_end3-main
	.cfi_endproc
                                        # -- End function
	.globl	print                           # -- Begin function print
	.p2align	4, 0x90
	.type	print,@function
print:                                  # @print
	.cfi_startproc
# %bb.0:
	pushq	%rax
	.cfi_def_cfa_offset 16
	movl	$1819043144, 1(%rsp)            # imm = 0x6C6C6548
	movw	$8559, 5(%rsp)                  # imm = 0x216F
	movb	$0, 7(%rsp)
	leaq	1(%rsp), %rdi
	callq	puts@PLT
	movl	$1, %eax
	popq	%rcx
	.cfi_def_cfa_offset 8
	retq
.Lfunc_end4:
	.size	print, .Lfunc_end4-print
	.cfi_endproc
                                        # -- End function
	.globl	call2                           # -- Begin function call2
	.p2align	4, 0x90
	.type	call2,@function
call2:                                  # @call2
	.cfi_startproc
# %bb.0:
	pushq	%rax
	.cfi_def_cfa_offset 16
	callq	print@PLT
	popq	%rax
	.cfi_def_cfa_offset 8
	retq
.Lfunc_end5:
	.size	call2, .Lfunc_end5-call2
	.cfi_endproc
                                        # -- End function
	.section	".note.GNU-stack","",@progbits
