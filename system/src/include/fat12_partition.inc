%ifndef FAT12_INC
	%define FAT12_INC

;+-------------------+
;+--+ FAT12 TABLE +--+
;+-------------------+

;OEM Name String
	string 				BS_OEMName,8,"MSWIN4.1"	;Do not forget to change!

;Bytes Per Sector
	BPB_BytesPerSec		dw 512

;Sectors Per Cluster
	BPB_SecPerClus		db 8

;Reserved Sector Count (always 1)
	BPB_RsvdSecCnt		dw 1

;Number of FATs (always 2)
	BPB_NumFATs			db 2

;Root Entry Count (Use 512 for now)
	BPB_RootEntCnt		dw 512

;Total Sectors 12/16 (Reverse Engineering FRDOS4.1 gave me 0x4e81)
	BPB_TotSec16		dw 0x4e81

;Media Code (0xf8 == fixed media, 0xf0 == removable media)
	BPB_Media			db 0xf8

;Size of FAT 12/16
	BPB_FATSz16			dw 8

;Sectors Per Track (use bochs value of 63 for now)
	BPB_SecPerTrk		dw 63

;Number of Heads (use bochs value of 16 for now)
	BPB_NumHeads		dw 16

;Hidden Sectors (math shows 63 hidden sectors before boot sector of 1st partition)
	BPB_HiddSec			dd 63

;Total Sectors 32
	BPB_TotSec32		dd 0

;Drive Number (0 == floppy, 0x80 == hdd)
	BS_DrvNum			db 0x80

;Reserved, always 0
	BS_Reserved1		db 0

;Boot Signature (see if 0 disables, should be 0x29)
	BS_BootSig			db 0x29

;Volume ID (Reverse Engineering FRDOS4.1 gave this value)
	BS_VolID			dd 0x436618de

;Volume Label
	string 				BS_VolLab,11,"VOLIM"

;FAT type (12,16,32)
	string				BS_FilSysType,8,"FAT12"

%endif
