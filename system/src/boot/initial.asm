;Initiation module
%include 'common.inc'

;-----------------------------------------------
;					CODE					   |
;-----------------------------------------------
[BITS 16]
[ORG 0x0]


_start:
	;Setup the new segment descriptors
	call Setup
	
	;Clear screen
	;call ResetVideoMode
	
	;Enable the A20 gate
	call EnableA20
	jc .hang
	
	;Determine amount of RAM
	call GetAmountRAM
	jc .hang
	
	;Check if support Mode of 640x480 16 bpp
	mov WORD [ CheckVideoMode.xres ],640
	mov WORD [ CheckVideoMode.yres ],480
	mov BYTE [ CheckVideoMode.bpp ],16
	call CheckVideoMode
	jc .hang
	
	;Since we have the video mode now, set it.
	mov bx, WORD [ CheckVideoMode.mode ]
	call SetVideoMode
	jc .hang
	
	;Load LOADER.COM and DEMO.COM
	call LoadSteps
	
	;PMODE time
	jmp SetPMODE


.hang:
	jmp $
;-----------------------------------------------
;+++++++++++++++++++++++++++++++++
;++SETUP SEGREGS FOR INITIALIZER++
;+++++++++++++++++++++++++++++++++

Setup:
	pop bx
	
	cli
	push cs			;Push our CS to put in DS
	pop ds
	xor ax,ax
	mov es,ax
	mov fs,ax
	mov gs,ax
	mov ss,ax
	mov sp,0x7e00	;Use bootsec area for stack
	sti
	
	;Set up the rest of our EFA's VBE memaddrs
	mov ax,WORD [ es:EFA + _EFA.ModeInfoBlock ]
	mov WORD [ es:EFA + _EFA.VbeInfoBlock ],ax
	mov ax, WORD [ es:EFA + _EFA.RootDirSize ]
	add ax, WORD [ es:EFA + _EFA.FatChainSize ]
	add WORD [ es:EFA + _EFA.ModeInfoBlock ],ax
	add ax,( _ModeInfoBlock.eof - _ModeInfoBlock.start )	;should be 256 bytes
	add [ es:EFA + _EFA.VbeInfoBlock ],ax
	
	;Clear our VBE structs to 0
	mov cx,( _ModeInfoBlock.eof - _ModeInfoBlock.start ) + ( _VbeInfoBlock.eof - _VbeInfoBlock.start ) / 2
	mov di,WORD [ es:EFA + _ModeInfoBlock ]
	xor ax,ax
	rep stosw
	
	;Set up our constants in the VBE structures
	mov di,WORD [ es:EFA + _EFA.ModeInfoBlock ]
	mov al,BYTE 1
	stosb
	
	mov di,WORD [ es:EFA + _EFA.VbeInfoBlock ]
	mov si,.VbeSig
	mov cx,4
	rep movsb
	mov ax,0x0300
	stosw
	
	;Push back RETADDR and return
	push bx
	ret

.VbeSig:	db 'VBE2'
;-----------------------------------------------
;++++++++++++++++++++++++++++++++++
;+       RESET  VIDEO  MODE       +
;++++++++++++++++++++++++++++++++++

ResetVideoMode:
	pusha
	
	;Reset Video Mode Redundantly
	mov ax,0x0f00
	int 0x10
	
	xor ah,ah
	int 0x10
	
	popa
	ret
;-----------------------------------------------
;++++++++++++++++++++++++++++++++++
;+       CHECK  VIDEO  MODE       +
;++++++++++++++++++++++++++++++++++

CheckVideoMode:
	pusha
	
	clc
	;push es
	push fs
	;VBE Controller Info structure in data seg
	;push ds
	;pop es
	
	;Get the VBE Controller Info
	mov ax,0x4f00
	mov di,WORD [ es:EFA + _EFA.VbeInfoBlock ]
	int 0x10
	cmp al,0x4f
	jnz .no_vbe_support
	test ah,ah
	jnz .error
	
	;Find the Resolution and Colour mode desired.
	mov bp,WORD [ es:EFA + _EFA.VbeInfoBlock ]
	mov bx,WORD [ es:bp + _VbeInfoBlock.VideoModePtr ]
	mov ax,WORD [ es:bp + _VbeInfoBlock.VideoModePtr + 2 ]
	mov fs,ax
.check_vbe_modes:
	mov cx,WORD [ fs:bx ]
	cmp cx,0xffff
	jz .end_of_list
	mov di,WORD [ es:EFA + _EFA.ModeInfoBlock ]
	mov ax,0x4f01
	int 0x10
	cmp al,0x4f
	jnz .no_vbe_support
	test ah,ah
	jnz .error
	
	mov dx,cx
	xor cx,cx
	mov bp,WORD [ es:EFA + _EFA.ModeInfoBlock ]
	;Check the mode to see if it fits attributes
	mov ax,WORD [ es:bp + _ModeInfoBlock.XResolution ]
	cmp WORD [ .xres ],ax
	setnz cl
	add ch,cl
	
	mov ax,WORD [ es:bp + _ModeInfoBlock.YResolution ]
	cmp WORD [ .yres ],ax
	setnz cl
	add ch,cl
	
	mov al,BYTE [ es:bp + _ModeInfoBlock.BitsPerPixel ]
	cmp BYTE [ .bpp ],al
	setnz cl
	add ch,cl
	
	;Check ModeAttributes
	mov ax,WORD [ es:bp + _ModeInfoBlock.ModeAttributes ]
	
	;Supported by Hardware
	bt ax,0
	setnc cl
	add ch,cl
	
	;Colour Mode
	bt ax,3
	setnc cl
	add ch,cl
	
	;Graphics Mode
	bt ax,4
	setnc cl
	add ch,cl
	
	;Linear Frame Buffer Mode
	bt ax,7
	setnc cl
	add ch,cl	
	
	;Found what we needed if CX := 0
	movzx cx,ch
	jcxz .found_mode
	
	;Not what we want, keep going
	add bx,2
	jmp .check_vbe_modes

.end_of_list:
	;Unable to find the mode we desire, fail

.no_vbe_support:

.error:
	stc
	jmp .done

.found_mode:
	mov WORD [ .mode ],dx

.done:
	pop fs
	;pop es
	popa
	ret

;Desired Attributes
.xres:		dw 0
.yres:		dw 0
.bpp:		db 0
.pad:		db 0
.mode		dw 0
;-----------------------------------------------
;++++++++++++++++++++++++++++++++++
;+       SET   VIDEO   MODE       +
;++++++++++++++++++++++++++++++++++

SetVideoMode:		;SetVideoMode( bx := VideoMode )
	pusha
	
	;CF := 0, ES := DS
	clc
	;push es
	;push ds
	;pop es
	
	;Set the options we need in our mode
	and bx,0x1ff
	or bx,0100000000000000b	
	mov ax,0x4f02
	int 0x10
	cmp al,0x4f
	jnz .error
	test ah,ah
	jnz .error
	
	jmp .done
	
.error:
	stc

.done:
	;pop es
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
	mul BYTE [ es:FAT + _FAT12.BPB_SecPerClus ]
	xor dx,dx
	mul WORD [ es:FAT + _FAT12.BPB_BytesPerSec ]
	;Add in RootDir & RsvdSec sizes
	add ax,WORD [ es:EFA + _EFA.RootDirSize ]
	add ax,WORD [ es:EFA + _EFA.RsvdSecSize ]
	xor dx,dx
	;Now, just divide it by SectorSize to get LBA
	div WORD [ es:FAT + _FAT12.BPB_BytesPerSec ]
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
	
	;Clear carry flag, set only for error
	clc
	mov WORD [ RetVal ],0
	;Setup di,bx,cx for file search
	mov di,WORD [ es:EFA + _EFA.RootDirAddr ]
	mov bx,WORD [ es:FAT + _FAT12.BPB_RootEntCnt ]
	mov cx,FAT12_NAME_SIZE
	
		;NOTE:: Don't forget to splice file name for dir hunt
		;NOTE:: Don't forget to add subdir branching in search
	
.find_file:
	pusha
	repz cmpsb
	test cx,cx
	;Not it, keep looking
	popa
	jz .found_file
	add di,FAT12_ENTRY_SIZE
	dec bx
	jnz .find_file
	
		stc
		jmp .done
	
.found_file:
	;Found the file, di := FAT12_ENTRY of file
	mov WORD [ RetVal ],di
.done:
	popa
	mov di,WORD [ RetVal ]
	ret
;-----------------------------------------------
;++++++++++++++++++++++++++++++++++
;+++++READ IN SPECIFIED SECTORS++++
;++++++++++++++++++++++++++++++++++

ReadSectors:		;ReadSectors( cx := nBlocks, ax := startBlock, di := ptrBuffer );
	pusha

	mov si,.DiskPacket
.read:
	;Move regs into disk packet
	mov WORD [ .nBlocks ],cx
	mov DWORD [ .Buffer ],edi
	mov WORD [ .lba ],ax
	
	;Save registers, do our interrupt
	pusha
	mov ax,0x4200
	mov dl,BYTE [ es:FAT + _FAT12.BS_DrvNum ]
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
	mov dl,BYTE [ es:FAT + _FAT12.BS_DrvNum ]
	int 0x13
	jmp .read
	
.read_okay:
	popa
	ret

.DiskPacket:
	.size:		db 0x10
	.resv:		db 00
	.nBlocks:	dw 00
	.Buffer:	dd 00
	.lba:		dq 00
	.resv2:		dq 00
;-----------------------------------------------
;++++++++++++++++++++++++++++++++++
;+ LOAD THE FILE  FROM HDD TO MEM +
;++++++++++++++++++++++++++++++++++

LoadFile:		;CF := LoadFile( si := FileName, di := buffer );
	pusha
	
	;mov 
	
.done:
	popa
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
;+++++USE CMOS TIMER AND SLEEP+++++
;++++++++++++++++++++++++++++++++++

Sleep:				;Sleep( int seconds )
	push bp
	mov bp,sp
	pusha
	
	;Load seconds into CX
	mov cx,WORD [ ss:bp + 4 ]
	
	cli

.wait1:
	mov al,0x0a
	out 0x70,al
	mov ax,0xffff
	mov ax,0xaaaa
	mov ax,0xafaf
	in al,0x71
	test al,0x80
	jnz .wait1
	
	xor al,al
	out 0x70,al
	in al,0x71
	
	mov bl,al

.wait2:
	mov al,0x0a
	out 0x70,al
	mov ax,0xffff
	mov ax,0xaaaa
	mov ax,0xafaf
	in al,0x71
	test al,0x80
	jnz .wait2
	
	xor al,al
	out 0x70,al
	in al,0x71
	
	sub al,bl
	movzx ax,al
	cmp cx,ax
	jz .done
	jg .wait2
	
.done:
	sti
	popa
	pop bp
	ret
;-----------------------------------------------
;++++++++++++++++++++++++++++++++++
;+ENABLE A20 LINE FOR HIMEM ACCESS+
;++++++++++++++++++++++++++++++++++

EnableA20:
	pusha
	
	;FASTA20 port
	in al,0x92
	or al,2
	out 0x92,al
	
	call .CheckA20
	;jnc .done
		jmp .done	;BOCHS doesn't support BIOS method, but supports fastA20port
	
	
	;DUMMYA20 port
	in al,0xee
	call .CheckA20
	jnc .done
	
	;BIOS Method
	mov ax,0x2401
	int 0x15
	call .CheckA20
	jnc .done
	
	;PC/AT method

.error:
	;Unable to set the A20 line, so leave with error message and fail
	push errBadA20
	call print
	
.done:
	popa
	ret
;-----------------
.CheckA20:
	pusha

	;Set carry,only reset if A20 on.
	stc
		;Bypass interrupt, do no_bios (bochs doesn't support well?)
		jmp .no_bios

	;Check via BIOS if supported
	mov ax,0x2402
	int 0x15
	cmp ah,0x86
	jz .no_bios
	test al,al
	jnz .A20_on
	jmp .done2

.no_bios:
	;Check via memop to see if shadowed
	;0xFFFF:0x8000 will wrap to 0x0000 if no A20
	;so check the next four words to make sure
	;they aren't the same values
	push es
	push gs
   
	xor ax,ax
	mov es,ax
	dec ax
	mov gs,ax
   
	xor cx,cx
	mov ax,WORD [ es:0 ]
	mov bx,WORD [ gs:0x8000 ]
	cmp ax,bx
	setz ch
	add cl,ch
	mov ax,WORD [ es:2 ]
	mov bx,WORD [ gs:0x8002 ]
	cmp ax,bx
	setz ch
	add cl,ch
	mov ax,WORD [ es:4 ]
	mov bx,WORD [ gs:0x8004 ]
	cmp ax,bx
	setz ch
	add cl,ch
	mov ax,WORD [ es:6 ]
	mov bx,WORD [ gs:0x8006 ]
	cmp ax,bx
	setz ch
	add cl,ch

	pop gs
	pop es
   
	;If cl == 0, then A20 is on.
	jcxz .A20_on
	;A20 is off
	jmp .done2

.A20_on:
	clc

.done2:                                          
	popa
	ret

;A20 related data 
out_bytes	db KB_READ_STATUS,KB_WRITE_STATUS
;-----------------------------------------------
;+++++++++++++++++++++++++++++++++++
;+DETERMINE AMOUNT OF RAM FOR PMODE+
;+++++++++++++++++++++++++++++++++++

GetAmountRAM:
	pusha
	clc
	;BIOS function ( ax := 0xe820 int 0x15 )-- Unlinked List Memory Map
	
	;BIOS function ( ax := 0xe881 int 0x15 )-- Contig. Mem Map w/ 32b regs
	xor ecx,ecx
	xor edx,edx
	mov ax,0xe801
	int 0x15
	jc .error
	cmp ax,0x86
	jz .error
	cmp ax,0x80
	jz .error
	
	jcxz .ax_bx_pair
	mov eax,ecx
	mov ebx,edx
	
.ax_bx_pair:
	;Store the info and NOTE this is in 64KiB chunks
	mov DWORD [ es:EFA + _EFA.MemSizeLo ],eax
	mov DWORD [ es:EFA + _EFA.MemBlockSizeLo ],1024		;1024 = 1KiB
	mov DWORD [ es:EFA + _EFA.MemSizeHi ],ebx
	mov DWORD [ es:EFA + _EFA.MemBlockSizeHi ],(64*1024)	;64 * 1024 = 64KiB
	jmp .done
	
.error:
	push errAmountRAM
	call print
	stc
	
.done:
	popa
	ret
;-----------------------------------------------
;++++++++++++++++++++++++++++++++++
;+ LOADER.COM  &  DEMO.COM LOADER +
;++++++++++++++++++++++++++++++++++

LoadSteps:
	pusha
	clc
	;Begin by loading the LOADER.COM, the middle step
	mov si,.Loader
	call FindFile
	jc .error
	mov ax,[ es:di + FAT12_ENTRY_FIRSTCLUSTER ]
	call CalculateLBA
	;File size should be 512, disregard
	mov cx,1
	;Buffer addr := LOADER_MEM_ADDR
	mov edi,LOADER_MEM_ADDR
	call ReadSectors
	jc .error
	
	;Now load our DEMO.COM
	mov si,.Demo
	call FindFile
	jc .error
	mov ax,[ es:di + FAT12_ENTRY_FIRSTCLUSTER ]
	call CalculateLBA
	;File Size
	mov cx,[ es:di + FAT12_ENTRY_FILESIZE ]
	;Buffer := DEMO_MEM_ADDR
	mov edi,DEMO_MEM_ADDR
	call ReadSectors
	jc .error
			;THIS JUST FUCKING ASSUMES SHIT IS 4096 OR LESS, NEED TO USE FAT CHAIN TABLE!!!!!!!!!!!!!!!!

	jmp .done

.error:
	stc

.done:
	popa
	ret
	
.Loader:	db 'LOADER  COM'
.Demo:		db 'DEMO    COM'	
;-----------------------------------------------
;++++++++++++++++++++++++++++++++++
;+ENABLE A20 LINE FOR HIMEM ACCESS+
;++++++++++++++++++++++++++++++++++

SetPMODE:		;SetPMODE( void ); //DOES NOT RESERVE REGISTERS OR SEGMENTS
	;Calculate offset for GDT entries offset
	xor eax,eax
	mov ax,ds
	shl eax,4
	add eax,GDTR
	mov DWORD [ GDTR + _GDTR.offset ],eax
	;Get ready for bumpy ride
	cli
	
	;Now load the GDTR via LGDT
	lgdt [ GDTR ]
	
	;Enable the PE, disable PG, of CR0
	mov eax,cr0
	and eax,0x7fffffff
	or eax,1
	mov cr0,eax
	
	;Set up the segregs
	mov eax,DATA_SEG_SELECTOR
	mov ds,eax
	mov eax,STACK_SEG_SELECTOR
	mov ss,eax
	mov esp,STACK_SEG_OFFSET
	
	;Clear our CS reg to our new descriptor
	jmp CODE_SEG_SELECTOR:LOADER_MEM_ADDR
		;instead of loading TWO more COMs, just INCBIN LOADER.COM in a spot after this
		;BUT STILL have it load DEMO.COM


;Labels defined inside file for use
align 8,db 0
%include 'gdt.inc'
;-----------------------------------------------
;++++++++++++++++++++++++++++++++++
;+ENABLE A20 LINE FOR HIMEM ACCESS+
;++++++++++++++++++++++++++++++++++
;-----------------------------------------------
;					DATA					   |
;-----------------------------------------------

;Return Value
RetVal		dw 0

;Error Strings
errBadRead			db 'Unable to read sectors into memory.',0
errBadA20			db 'Unable to set the A20 line.',0
errAmountRAM		db 'Unable to determine the amount of RAM in system.',0

;Pad out to ClusterSize just for ease
times 4096 - ( $ - $$ ) db 0
