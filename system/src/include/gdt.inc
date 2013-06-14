%ifndef GDT_INC
	%define GDT_INC

;GDT for INITIAL.COM
GDT:
GDTR:
	;GDTR section
	istruc _GDTR
		at _GDTR.size,		dw ( ( .end_GDT - GDTR ) - 1 )
		at _GDTR.offset,	dd 0 	;Calculate before using LGDT
	iend

;GDT_ENTRY
.entries:
	;.null_seg:		;Null segment descriptor (required)
			;gdt_entry 0,0,0,0
	.code_seg:		;start := 0x0000, size := 4GiB
		CODE_SEG_LIMIT		equ GDT_FLAGS_GRANULARITY_PAGE | GDT_FLAGS_SIZE_32
		CODE_SEG_ACCESS		equ GDT_CODE_SEGMENT | GDT_ACCESS_READABLE
			gdt_entry 0x00000000,0x0fffff,CODE_SEG_ACCESS,CODE_SEG_LIMIT
	.data_seg:		;start := 0x0000, size := 4GiB
		DATA_SEG_LIMIT		equ GDT_FLAGS_GRANULARITY_PAGE | GDT_FLAGS_SIZE_32
		DATA_SEG_ACCESS		equ GDT_DATA_SEGMENT | GDT_ACCESS_WRITABLE
			gdt_entry 0x00000000,0x0fffff,DATA_SEG_ACCESS,DATA_SEG_LIMIT
	.stack_seg:		;start := 0xffffff (16 MiB mark, size := 1MiB)
		STACK_SEG_LIMIT		equ GDT_FLAGS_GRANULARITY_BYTE | GDT_FLAGS_SIZE_32
		STACK_SEG_ACCESS 	equ GDT_STACK_SEGMENT
			gdt_entry 0x00ffffff,0x0fffff,STACK_SEG_ACCESS,STACK_SEG_LIMIT
.end_GDT:

%endif
