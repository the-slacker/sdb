%ifndef MACROS_MAC
	%define MACROS_MAC

;------------------------------------------------
;decrypt MACRO
;------------------------------------------------
;Usage: decrypt OUTPUT_CONSTANT,STRING (with each letter seperated by comma)
;------------------------------------------------
;%macro decrypt 2+
;	%assign i 0
;	%define str_%2 %2
;	%deftok tok_%1 %2
;	%strlen size_%1 str_%2
;	%rep size_%2
;	%assign i i+1
;	%substr char_tok_%1 %2 %i
;		%assign j char_%i+3
;		
;	%endrep
;	%1 equ cat_%2
;%endmacro
;------------------------------------------------
;magic_bp MACRO
;------------------------------------------------
;Usage: magic_bp
;------------------------------------------------
%macro magic_bp 0
	xchg bx,bx
%endmacro
;------------------------------------------------
;gdt_entry MACRO
;------------------------------------------------
;Usage: gdt_entry BASE_ADDR,LIMIT,ACCESS FLAGS, LIM_FLAGS
;------------------------------------------------
%macro gdt_entry 4
	;Lo DWORD of GDT
	;dd (((%2 << 16) & 0xffff0000) | (%2 & 0x0000ffff))
	;Hi DWORD of GDT
	;dd ((%2 & 0x000f0000) | ((((%3 >> 8) | %4) << 8) & 0x00f0ff00) | (%1 & 0xff000000) | ((%1 >> 16) & 0x000000ff))
	
	;Lo DWORD of GDT
	db ( %2 & 0x000000ff )
	db ( ( %2 & 0x0000ff00 ) >> 8 )
	db ( %1 & 0x000000ff )
	db ( ( %1 & 0x0000ff00 ) >> 8 )
	;Hi DWORD of GDT
	db ( ( %1 & 0x00ff0000 ) >> 16 )
	db %3
	db ( ( %4 & GDT_FLAGS_NIBBLE ) | ( ( %2 & 0x0f0000 ) >> 16 ) )
	db ( ( %1 & 0xff000000 ) >> 28 )
%endmacro
;------------------------------------------------

%endif
