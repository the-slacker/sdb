;File Allocation Table 12
	struc _FAT12 {	;sizeof := 0x3e (including the nop and jmp)
		.start:
		.BS_OEMName:		rb 8
		.BPB_BytesPerSec:	rw 1
		.BPB_SecPerClus:	rb 1
		.BPB_RsvdSecCnt:	rw 1
		.BPB_NumFATs:		rb 1
		.BPB_RootEntCnt:	rw 1
		.BPB_TotSec16:		rw 1
		.BPB_Media:		rb 1
		.BPB_FATSz16:		rw 1
		.BPB_SecPerTrk:		rw 1
		.BPB_NumHeads:		rw 1
		.BPB_HiddSec:		rd 1
		.BPB_TotSec32:		rd 1
		.BS_DrvNum:		rb 1
		.BS_Reserved1:		rb 1
		.BS_BootSig:		rb 1
		.BS_VolID:		rd 1
		.BS_VolLab:		rb 11
		.BS_FilSysType:		rb 8
		.eof:
	}

;Extended FAT Area (EFA), to take place after the FAT12 struct in mem ( 0x0500 + 0x3e )
	struc _EFA {
		.start:
		.ClusterOffset:		rw 1	;Just need to add any LogicalCluster(n) to this to get the data area
		.RsvdSecSize:		rw 1	;Contains sizeof RsvdSec
		.FatChainAddr:		rw 1	;Contains addrs of the FAT tables in memory
		.FatChainSize:		rw 1 	;Contains sizeof FatChain (without RsdvdSec)
		.RootDirAddr:		rw 1	;Contains addrs of RootDir in memory
		.RootDirSize:		rw 1	;Contains sizeof RootDir (without RsvdSec)
		.ModeInfoBlock:		rw 1	;VBE3 ModeInfoBlock
		.VbeInfoBlock:		rw 1	;VBE3 VbeInfoBlock
		.MemSizeLo:		rd 1	;Lower 32 (of 64) bits of RAM amount
		.MemBlockSizeLo:	rd 1	;Chunk size for MemSizeLo
		.MemSizeHi:		rd 1 	;Higher 32 (of 64) bits of RAM amount
		.MemBlockSizeHi:	rd 1	;Chunk size for MemSizeHi
		.eof:
	;Reserved DWORDs for aligning to 16 bytes
	}

;For HDD info
	struc _HDD_INFO {
		.start:
		.drive_szbuf: 	rw 1   ;Size of DriveInfo Buffer (set to 0x1a for v1.x)
		.drive_flags: 	rw 1   ;Drive information flags
		.drive_cyls:  	rd 1   ;Number of physical cylinders
		.drive_heads: 	rd 1   ;Number of physical heads
		.drive_spt:   	rd 1   ;Number of Sectors Per Track (usually 63)
		.drive_secs:  	rq 1   ;Number of Sectors
		.drive_bpsec:	rw 1   ;Bytes per Sector (almost always 512)
		.eof:
	;see ctyme.com/intr/rb-0715.htm
	}

;Global Descriptor Table (PMODE)
	;GDTR contains info for using LGDT instruction to load GDT reg (GDTR)
	struc _GDTR {
		.start:
		.size:		rw 1	;Size of GDT for LGDT instruction
		.offset:	rd 1	;Offset to GDT for LGDT instruction
			alignb 4	;Pad out RESW above to DWORD (2nd word unused in GDTR entry)
		.eof:
	}

	;GDT_ENTRY structure 
	struc _GDT_ENTRY {
		.start:
		.Lim_7_0:		rb 1	;Limit 7:0
		.Lim_15_8:		rb 1	;Limit 15:8
		.Base_7_0:		rb 1	;Base 7:0
		.Base_15_8:		rb 1	;Base 15:8
		.Base_23_16:		rb 1	;Base 23:16
		.Access:		rb 1	;Access Byte 			(Constants GDT_ACCESS_x)
		.Flags_Lim_19_16:	rb 1	;Flags & Limit 19:16	(Constants GDT_FLAGS_x)
			;See CONSTANTS for accessing Access and Flags_Lim_19_16
		.Base_31_24:		rb 1	;Base 31:24
		.eof:
	}

;VBE Mode Info Block
	struc _ModeInfoBlock {
		.start:
		.ModeAttributes:		rw 1 ; mode attributes
		.WinAAttributes: 		rb 1 ; window A attributes
		.WinBAttributes:		rb 1 ; window B attributes
		.WinGranularity: 		rw 1 ; window granularity
		.WinSize:			rw 1 ; window size
		.WinASegment: 			rw 1 ; window A start segment
		.WinBSegment: 			rw 1 ; window B start segment
		.WinFuncPtr: 			rd 1 ; real mode pointer to window function
		.BytesPerScanLine: 		rw 1 ; bytes per scan line
		; Mandatory information for VBE 1.2 and above
		.XResolution: 			rw 1 ; horizontal rolution in pixels or characters3
		.YResolution: 			rw 1 ; vertical rolution in pixels or characters
		.XCharSize:			rb 1 ; character cell width in pixels
		.YCharSize: 			rb 1 ; character cell height in pixels
		.NumberOfPlanes: 		rb 1 ; number of memory planes
		.BitsPerPixel: 			rb 1 ; bits per pixel
		.NumberOfBanks: 		rb 1 ; number of banks
		.MemoryModel: 			rb 1 ; memory model type
		.BankSize: 			rb 1 ; bank size in KB
		.NumberOfImagePages: 		rb 1 ; number of images
		.Reserved: 			rb 1 ; rerved for page function 		[[SHOULD BE 1]]
		; Direct Color fields (required for direct/6 and YUV/7 memory models)
		.RedMaskSize: 			rb 1 ; size of direct color red mask in bits
		.RedFieldPosition: 		rb 1 ; bit position of lsb of red mask
		.GreenMaskSize: 		rb 1 ; size of direct color green mask in bits
		.GreenFieldPosition: 		rb 1 ; bit position of lsb of green mask
		.BlueMaskSize: 			rb 1 ; size of direct color blue mask in bits
		.BlueFieldPosition: 		rb 1 ; bit position of lsb of blue mask
		.RsvdMaskSize: 			rb 1 ; size of direct color rerved mask in bits
		.RsvdFieldPosition: 		rb 1 ; bit position of lsb of rerved mask
		.DirectColorModeInfo: 		rb 1 ; direct color mode attributes
		; Mandatory information for VBE 2.0 and above
		.PhysBasePtr: 			rd 1 ; physical addrs for flat memory frame buffer
		.Reserved1:			rd 1 ; Reserved - always set to 0
		.Reserved2:			rw 1 ; Reserved - always set to 0
		; Mandatory information for VBE 3.0 and above
		.LinBytesPerScanLine: 		rw 1 ; bytes per scan line for linear modes
		.BnkNumberOfImagePages: 	rb 1 ; number of images for banked modes
		.LinNumberOfImagePages:		rb 1 ; number of images for linear modes
		.LinRedMaskSize: 		rb 1 ; size of direct color red mask (linear modes)
		.LinRedFieldPosition: 		rb 1 ; bit position of lsb of red mask (linear modes)
		.LinGreenMaskSize: 		rb 1 ; size of direct color green mask (linear modes)
		.LinGreenFieldPosition: 	rb 1 ; bit position of lsb of green mask (linear modes)
		.LinBlueMaskSize: 		rb 1 ; size of direct color blue mask (linear modes)
		.LinBlueFieldPosition: 		rb 1 ; bit position of lsb of blue mask (linear modes)
		.LinRsvdMaskSize: 		rb 1 ; size of direct color rerved mask (linear modes)
		.LinRsvdFieldPosition: 		rb 1 ; bit position of lsb of rerved mask (linear modes)
		.MaxPixelClock:			rd 1 ; maximum pixel clock (in Hz) for graphics mode
		.Reserved3:			rb 189 ; remainder of ModeInfoBlock
		.eof:
	}
	
;VBE Information Block
	struc _VbeInfoBlock {
		.start:
		.VbeSignature:			rb 4 ;'VBE2'
		.VbeVersion:			rw 1 ;0x300
		.OemStringPtr:			rd 1
		.Capabilities:			rb 4
		.VideoModePtr:			rd 1
		.TotalMemory:			rw 1
		.OemSoftwareRev:		rw 1
		.OemVendorNamePtr:		rd 1
		.OemProductNamePtr:		rd 1
		.OemProductRevPtr:		rd 1
		.Reserved:			rb 222
		.OemData:			rb 256
		.eof:
	}
