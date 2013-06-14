%ifndef STRUCS_INC
	%define STRUCS_INC

;File Allocation Table 12
	struc _FAT12	;sizeof := 0x3e (including the nop and jmp)
		.start:
		.BS_OEMName:		resb 8
		.BPB_BytesPerSec:	resw 1
		.BPB_SecPerClus:	resb 1
		.BPB_RsvdSecCnt:	resw 1
		.BPB_NumFATs:		resb 1
		.BPB_RootEntCnt:	resw 1
		.BPB_TotSec16:		resw 1
		.BPB_Media:			resb 1
		.BPB_FATSz16:		resw 1
		.BPB_SecPerTrk:		resw 1
		.BPB_NumHeads:		resw 1
		.BPB_HiddSec:		resd 1
		.BPB_TotSec32:		resd 1
		.BS_DrvNum:			resb 1
		.BS_Reserved1:		resb 1
		.BS_BootSig:		resb 1
		.BS_VolID:			resd 1
		.BS_VolLab:			resb 11
		.BS_FilSysType:		resb 8
		.eof:
	endstruc

;Extended FAT Area (EFA), to take place after the FAT12 struct in mem ( 0x0500 + 0x3e )
	struc _EFA
		.start:
		.ClusterOffset:		resw 1	;Just need to add any LogicalCluster(n) to this to get the data area
		.RsvdSecSize:		resw 1	;Contains sizeof RsvdSec
		.FatChainAddr:		resw 1	;Contains address of the FAT tables in memory
		.FatChainSize:		resw 1 	;Contains sizeof FatChain (without RsdvdSec)
		.RootDirAddr:		resw 1	;Contains address of RootDir in memory
		.RootDirSize:		resw 1	;Contains sizeof RootDir (without RsvdSec)
		.ModeInfoBlock:		resw 1	;VBE3 ModeInfoBlock
		.VbeInfoBlock:		resw 1	;VBE3 VbeInfoBlock
		.MemSizeLo:			resd 1	;Lower 32 (of 64) bits of RAM amount
		.MemBlockSizeLo:	resd 1	;Chunk size for MemSizeLo
		.MemSizeHi:			resd 1 	;Higher 32 (of 64) bits of RAM amount
		.MemBlockSizeHi:	resd 1	;Chunk size for MemSizeHi
		.eof:
	;Reserved DWORDs for aligning to 16 bytes
	endstruc

;For HDD info
	struc _HDD_INFO
		.start:
		.drive_szbuf: 	resw 1   ;Size of DriveInfo Buffer (set to 0x1a for v1.x)
		.drive_flags: 	resw 1   ;Drive information flags
		.drive_cyls:  	resd 1   ;Number of physical cylinders
		.drive_heads: 	resd 1   ;Number of physical heads
		.drive_spt:   	resd 1   ;Number of Sectors Per Track (usually 63)
		.drive_secs:  	resq 1   ;Number of Sectors
		.drive_bpsec:	resw 1   ;Bytes per Sector (almost always 512)
		.eof:
	;see ctyme.com/intr/rb-0715.htm
	endstruc

;Global Descriptor Table (PMODE)
	;GDTR contains info for using LGDT instruction to load GDT reg (GDTR)
	struc _GDTR
		.start:
		.size:		resw 1	;Size of GDT for LGDT instruction
		.offset:	resd 1	;Offset to GDT for LGDT instruction
			alignb 4	;Pad out RESW above to DWORD (2nd word unused in GDTR entry)
		.eof:
	endstruc

	;GDT_ENTRY structure 
	struc _GDT_ENTRY
		.start:
		.Lim_7_0:			resb 1	;Limit 7:0
		.Lim_15_8:			resb 1	;Limit 15:8
		.Base_7_0:			resb 1	;Base 7:0
		.Base_15_8:			resb 1	;Base 15:8
		.Base_23_16:		resb 1	;Base 23:16
		.Access:			resb 1	;Access Byte 			(Constants GDT_ACCESS_x)
		.Flags_Lim_19_16:	resb 1	;Flags & Limit 19:16	(Constants GDT_FLAGS_x)
			;See CONSTANTS for accessing Access and Flags_Lim_19_16
		.Base_31_24:		resb 1	;Base 31:24
		.eof:
	endstruc

;VBE Mode Info Block
	struc _ModeInfoBlock
		.start:
		.ModeAttributes:		resw 1 ; mode attributes
		.WinAAttributes: 		resb 1 ; window A attributes
		.WinBAttributes:		resb 1 ; window B attributes
		.WinGranularity: 		resw 1 ; window granularity
		.WinSize:				resw 1 ; window size
		.WinASegment: 			resw 1 ; window A start segment
		.WinBSegment: 			resw 1 ; window B start segment
		.WinFuncPtr: 			resd 1 ; real mode pointer to window function
		.BytesPerScanLine: 		resw 1 ; bytes per scan line
		; Mandatory information for VBE 1.2 and above
		.XResolution: 			resw 1 ; horizontal resolution in pixels or characters3
		.YResolution: 			resw 1 ; vertical resolution in pixels or characters
		.XCharSize:				resb 1 ; character cell width in pixels
		.YCharSize: 			resb 1 ; character cell height in pixels
		.NumberOfPlanes: 		resb 1 ; number of memory planes
		.BitsPerPixel: 			resb 1 ; bits per pixel
		.NumberOfBanks: 		resb 1 ; number of banks
		.MemoryModel: 			resb 1 ; memory model type
		.BankSize: 				resb 1 ; bank size in KB
		.NumberOfImagePages: 	resb 1 ; number of images
		.Reserved: 				resb 1 ; reserved for page function 		[[SHOULD BE 1]]
		; Direct Color fields (required for direct/6 and YUV/7 memory models)
		.RedMaskSize: 			resb 1 ; size of direct color red mask in bits
		.RedFieldPosition: 		resb 1 ; bit position of lsb of red mask
		.GreenMaskSize: 		resb 1 ; size of direct color green mask in bits
		.GreenFieldPosition: 	resb 1 ; bit position of lsb of green mask
		.BlueMaskSize: 			resb 1 ; size of direct color blue mask in bits
		.BlueFieldPosition: 	resb 1 ; bit position of lsb of blue mask
		.RsvdMaskSize: 			resb 1 ; size of direct color reserved mask in bits
		.RsvdFieldPosition: 	resb 1 ; bit position of lsb of reserved mask
		.DirectColorModeInfo: 	resb 1 ; direct color mode attributes
		; Mandatory information for VBE 2.0 and above
		.PhysBasePtr: 			resd 1 ; physical address for flat memory frame buffer
		.Reserved1:				resd 1 ; Reserved - always set to 0
		.Reserved2:				resw 1 ; Reserved - always set to 0
		; Mandatory information for VBE 3.0 and above
		.LinBytesPerScanLine: 	resw 1 ; bytes per scan line for linear modes
		.BnkNumberOfImagePages: resb 1 ; number of images for banked modes
		.LinNumberOfImagePages:	resb 1 ; number of images for linear modes
		.LinRedMaskSize: 		resb 1 ; size of direct color red mask (linear modes)
		.LinRedFieldPosition: 	resb 1 ; bit position of lsb of red mask (linear modes)
		.LinGreenMaskSize: 		resb 1 ; size of direct color green mask (linear modes)
		.LinGreenFieldPosition: resb 1 ; bit position of lsb of green mask (linear modes)
		.LinBlueMaskSize: 		resb 1 ; size of direct color blue mask (linear modes)
		.LinBlueFieldPosition: 	resb 1 ; bit position of lsb of blue mask (linear modes)
		.LinRsvdMaskSize: 		resb 1 ; size of direct color reserved mask (linear modes)
		.LinRsvdFieldPosition: 	resb 1 ; bit position of lsb of reserved mask (linear modes)
		.MaxPixelClock:			resd 1 ; maximum pixel clock (in Hz) for graphics mode
		.Reserved3:				resb 189 ; remainder of ModeInfoBlock
		.eof:
	endstruc
	
;VBE Information Block
	struc _VbeInfoBlock
		.start:
		.VbeSignature:			resb 4 ;'VBE2'
		.VbeVersion:			resw 1 ;0x300
		.OemStringPtr:			resd 1
		.Capabilities:			resb 4
		.VideoModePtr:			resd 1
		.TotalMemory:			resw 1
		.OemSoftwareRev:		resw 1
		.OemVendorNamePtr:		resd 1
		.OemProductNamePtr:		resd 1
		.OemProductRevPtr:		resd 1
		.Reserved:				resb 222
		.OemData:				resb 256
		.eof:
	endstruc
	
%endif
