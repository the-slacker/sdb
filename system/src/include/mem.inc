%ifndef MEM_INC
	%define MEM_INC

;+------------------+
;|    MEM  AREAS    |
;+------------------+
INFO_MEM_ADDR		equ ( 0x0500 + 1 )	;Where we start storing FAT/EFA/RootDir data in mem (offset = 1 for alignment)
INITIAL_MEM_ADDR	equ 0x7e00			;The place where we store INITIAL.COM
LOADER_MEM_ADDR		equ INITIAL_MEM_ADDR + 4096 ;&Initial.com + ClusterSize
DEMO_MEM_ADDR		equ 0x00100000
;+------------------+
;|    FAT12 TABLE   |
;+------------------+
FAT					equ ( INFO_MEM_ADDR + 3 )		;3 is the size of our nop-jmp portion
;+------------------+
;|    EFA   TABLE   |
;+------------------+
EFA					equ ( FAT + ( _FAT12.eof - _FAT12.start ) )
;+------------------+
;|  SYS INFO TABLE  |
;+------------------+
;SYS_TABLE_ADDR		equ	( EFA_TABLE_ADDR + ( _EFA.ClusterOffset - _EFA.eof ) )
SYS					equ 0 ;NEEDS TO equal SOMETHING
;+------------------+
;|  ___ ____ _____  |
;+------------------+

;+------------------+
;|  HDD INFO TABLE  |
;+------------------+
;DRIVE_PARAM_ADDR  	equ 0x04500
	
	
%endif
