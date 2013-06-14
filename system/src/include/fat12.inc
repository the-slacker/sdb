;+-------------------+
;+--+ FAT12 TABLE +--+
;+-------------------+

struc FAT12 a,b,c,d,e,f,g,h,i,j,k,l,m,n,o,p,q,r,s {
	.BS_OEMName,		db a	;db '88888888'		;8 chars
	.BPB_BytesPerSec,	dw b	;dw 512
	.BPB_SecPerClus,	db c	;db 8
	.BPB_RsvdSecCnt,	dw d	;dw 1
	.BPB_NumFATs,		db e	;db 2
	.BPB_RootEntCnt,	dw f	;dw 512
	.BPB_TotSec16,		dw g	;dw 0x4ec0
	.BPB_Media,		db h	;db 0xf8
	.BPB_FATSz16,		dw i	;dw 8
	.BPB_SecPerTrk,		dw j	;dw 63
	.BPB_NumHeads,		dw k	;dw 16
	.BPB_HiddSec,		dd l	;dd 0
	.BPB_TotSec32,		dd m	;dd 0
	.BS_DrvNum,		db n	;db 0x80
	.BS_Reserved1,		db o	;db 0
	.BS_BootSig,		db p	;db 0x29
	.BS_VolID,		dd q	;dd 0x436618de
	.BS_VolLab,		db r	;db '55555      '	;11 chars
	.BS_FilSysType,		db s	;db 'FAT12   '		;8 chars
}
