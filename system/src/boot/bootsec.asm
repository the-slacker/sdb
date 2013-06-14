format binary
;BootSector (first 512 on primary partition)
include '../include/common.inc'

;-----------------------------------------------+
;			CODE			|
;-----------------------------------------------+
use16
org 0x7c00

start:
	nop
	jmp short main

;Include FAT12 Table	
;%include 'fat12.inc'
virtual at $
	fat FAT12 <'88888888'>,512,8,1,2,512,0x4ec0,0xf8,8,63,\
		  16,0,0,0x80,0,0x29,0x436618de,<'bbbbbbbbbbb'>,\
		  <'FAT12   '>

end virtual
;SizeOf FAT12 table := 0x3e (62) bytes
main:	
	;Store drive number
	;mov byte [fat.BS_DrvNum],dl
	
	;Setup basic info, check for supported functions
	call Setup
	
	;Copy FAT to mem
	call CopyFAT
	
	;Copy INITIAL_COM to mem
	call CopyINITIAL
	
	;Jump to INITIAL.COM
	jmp ( INITIAL_MEM_ADDR shr 4 ):0x0
	
;-----------------------------------------------
;++++++++++++++++++++++++++++++++++++++
;+SETUP SEGREGS AND CHECK BIOS SUPPORT+
;++++++++++++++++++++++++++++++++++++++
Setup:
	;Store retaddr
	pop bp
	
	;Store Drive Number in FAT table
	;mov byte [fat.BS_DrvNum],dl

	;Setup segregs
	cli
	xor ax,ax
	mov ds,ax
	mov es,ax
	mov gs,ax
	mov ss,ax
	mov sp,0x7c00
	sti
	
	;Put the retaddr back on the stack
	push bp
	
	;Calculate the ClusterOffset
	;( ( RootEntCnt * FAT12_ENTRY_SIZE ) + ( RsvdSecCnt * BytesPerSec ) )
	mov ax,FAT12_ENTRY_SIZE
	mul WORD [ FAT12 + _FAT12.BPB_RootEntCnt ]
	mov WORD [ EFA + _EFA.RootDirSize ],ax
	mov bx,ax
	xor dx,dx
	
	mov ax,WORD [ FAT12 + _FAT12.BPB_RsvdSecCnt ]
	mul WORD [ FAT12 + _FAT12.BPB_BytesPerSec ]
	mov WORD [ EFA + _EFA.RsvdSecSize ],ax
	add ax,bx
	mov WORD [ EFA + _EFA.ClusterOffset ],ax
	
	;Check for EXTENDED READ/WRITE BIOS functions
	mov ax,0x4100
	mov bx,0x55aa
	mov dl,BYTE [ FAT12 + _FAT12.BS_DrvNum ]
	int 0x13
	
	;Check if error or invalid function
	jc .no_ext_support
	cmp ah,1
	jz .no_ext_support
	;Check the bits in cx for supported functions
	mov ax,cx
	and ax,00000001b	;bit for extended functions
	rcr ax,1
	jc .done
	;Bit 0 wasn't set, so no support for the functions needed
	
.no_ext_support:
	;NO support for Ext. BIOS Disk Functions, show message then die
	push errNoExtSupport
	call print
		jmp $
	
.done:
	;Supports Ext. BIOS Disk Functions
	ret
;-----------------------------------------------
;++++++++++++++++++++++++++++++++++++
;+COPY FAT TABLE AND ROOT DIR TO MEM+
;++++++++++++++++++++++++++++++++++++

CopyFAT:			;CopyFAT();
	;Move our FAT Table into a safe spot in memory
	mov di,INFO_MEM_ADDR
	mov si,_start
	mov cx,( commence - _start ) / 2
	rep movsw
	
	;increment di to align on 0x10 boundary
	inc di
	
	;Get size of Root Dir in Sectors
	xor dx,dx
	mov ax,WORD [ FAT12 + _FAT12.BPB_BytesPerSec ]
	mul WORD [ FAT12 + _FAT12.BPB_FATSz16 ]
	xor dx,dx
	mul WORD [ FAT12 + _FAT12.BPB_NumFATs ]
	mov WORD [ EFA + _EFA.RootDirAddr ],ax
	mov WORD [ EFA + _EFA.FatChainSize ],ax
	add ax,WORD [ EFA + _EFA.RootDirSize ]
	xor dx,dx
	div WORD [ FAT12 + _FAT12.BPB_BytesPerSec ]
	test dx,dx
	setnz dl
	movzx dx,dl
	add dx,ax

	;Round di up to next 0x100 bytes via remainder
	mov ax,di
	mov bx,0x0100
	movzx ax,al
	sub bx,ax
	add di,bx
	
	;Calculate and store FatChain/RootDir/VBE memptrs
	mov WORD [ EFA + _EFA.FatChainAddr ],di
	add WORD [ EFA + _EFA.RootDirAddr ],di
	mov WORD [ EFA + _EFA.ModeInfoBlock ],di
	
	;startBlock := 1, nBlocks := dx
	mov ax,1
	mov cx,dx
	
	;Read FAT into memory
	call ReadSectors
	
	ret
;-----------------------------------------------
;+++++++++++++++++++++++++
;+COPY INITIAL.COM TO MEM+
;+++++++++++++++++++++++++

CopyINITIAL:		;CopyINITIAL();
	mov di,WORD [ EFA + _EFA.RootDirAddr ]

	;Find INITIAL_COM and get FAT12_ENTRY pointer
	mov si,INITIAL_COM
	call FindFile
	
	xor dx,dx
	mov ax,WORD [ di + FAT12_ENTRY_FILESIZE ]
	div WORD [ FAT12 + _FAT12.BPB_BytesPerSec ]
	
	;Get INITIAL_COM size
	xor dx,dx
	mov ax,WORD [ di + FAT12_ENTRY_FILESIZE ]
	mov bx,WORD [ FAT12 + _FAT12.BPB_BytesPerSec ]
	div bx
	;Test and add for remainder
	test dx,dx
	setnz cl
	movzx cx,cl
	add cx,ax
		
	;Get INITIAL_COM LBA
	mov ax,WORD [ di + FAT12_ENTRY_FIRSTCLUSTER ]
	call CalculateLBA
	
	mov di,INITIAL_MEM_ADDR
	call ReadSectors
	
	ret
;-----------------------------------------------
;++++++++++++++++++++++++++++++++++
;+PRINT STRING TO VIDEO FROM STACK+
;++++++++++++++++++++++++++++++++++

print:				;print( const char * string );
	push bp
	mov bp,sp
	pusha
	
	;Load string
	mov si,WORD [ ss:bp + 4 ]
	
.print_loop:
	lodsb
	test al,al
	jz .done
	mov ah,0x0e
	
	int 0x10
	jmp .print_loop

.done:
	popa
	pop bp
	ret 2
;-----------------------------------------------
;++++++++++++++++++++++++++++++++++
;+++++READ IN SPECIFIED SECTORS++++
;++++++++++++++++++++++++++++++++++

ReadSectors:		;ReadSectors( cx := nBlocks, ax := startBlock, di := ptrBuffer );
	pusha
	
	mov bx,8
	;Setup stack DiskPacket
.setup_stack:
	push 0
	dec bx
	jnz .setup_stack

	mov si,sp
	;Now load default values into the DiskPacket
	mov BYTE [ ds:si ],0x10

.read:
	;Move regs into disk packet
	mov WORD [ ds:si + 2 ],cx
	mov WORD [ ds:si + 4 ],di
	mov WORD [ ds:si + 8 ],ax
	
	;Save registers, do our interrupt
	pusha
	mov ax,0x4200
	mov dl,BYTE [ FAT12 + _FAT12.BS_DrvNum ]
	int 0x13
	popa
	
	jnc .read_okay
	;Decrement counter if not good read
	dec bx
	;If 0, exhausted all tries, so lock up
	jnz .retry
		;Exhausted retries, die
		push errBadRead
		call print
		jmp $
		
.retry:
	xor ax,ax
	mov dl,BYTE [ FAT12 + _FAT12.BS_DrvNum ]
	int 0x13
	jmp .read
	
.read_okay:
	add sp,16
	popa
	ret
;-----------------------------------------------
;++++++++++++++++++++++++++++
;+CALCULATE LBA FROM CLUSTER+
;++++++++++++++++++++++++++++

CalculateLBA:		;ax := CalculateLBA( ax := LogicalCluster );
	pusha
	;Take the cluster number and turn into physical address first
	;Cluster number in FAT already takes into account (nFATs*szFATs)
	;( Cluster * SecPerClus * BytesPerSec )
	xor dx,dx
	mul BYTE [ FAT12 + _FAT12.BPB_SecPerClus ]
	xor dx,dx
	mul WORD [ FAT12 + _FAT12.BPB_BytesPerSec ]
	;Add in RootDir & RsvdSec sizes
	add ax,WORD [ EFA + _EFA.RootDirSize ]
	add ax,WORD [ EFA + _EFA.RsvdSecSize ]
	xor dx,dx
	;Now, just divide it by SectorSize to get LBA
	div WORD [ FAT12 + _FAT12.BPB_BytesPerSec ]
	;Test and add for remainder
	test dx,dx
	setnz dl
	movzx dx,dl
	add dx,ax
	;Finished, just store in RetVal then retrieve and exit
	mov WORD [ RetVal ],ax
	popa
	mov ax,WORD [ RetVal ]
	ret
;-----------------------------------------------
;+++++++++++++++++++++++++++
;+++FIND FILE IN FILE SYS+++
;+++++++++++++++++++++++++++

FindFile:			;CF := !FindFile( si := FileName ); di := FAT12_ENTRY of found file
	pusha
	mov bp,sp
	
	;Clear carry flag, set only for error
	clc
	;Setup di,bx,cx for file search
	mov di,WORD [ EFA + _EFA.RootDirAddr ]
	mov bx,WORD [ FAT12 + _FAT12.BPB_RootEntCnt ]
	mov cx,FAT12_NAME_SIZE
	
		;NOTE:: Don't forget to splice file name for dir hunt
		;NOTE:: Don't forget to add subdir branching in search
	
.find_file:
	pusha
	repz cmpsb
	test cx,cx
	jz .found_file
	;Not it, keep looking
	popa
	add di,FAT12_ENTRY_SIZE
	dec bx
	jnz .find_file
	
		stc
	
.found_file:
	;Found the file, di := FAT12_ENTRY of file
	mov sp,bp
	popa
	ret
;-----------------------------------------------
;-----------------------------------------------
;					DATA					   |
;-----------------------------------------------

;Return Value placeholder
RetVal			dw 0
	
;File Names
INITIAL_COM		db 'INITIAL COM'

;Error Strings
errBadRead			db 'ReadError',0
errNoExtSupport		db 'No xBIOS',0


;Boot Sec Sig With Padding
times 510 - ( $ - $$ ) db 0
dw 0xaa55
