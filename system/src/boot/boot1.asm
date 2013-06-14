format binary
use16
org 0x7c00

start:
jmp boot
times 8-($-$$) db 0
     
;	Boot Information Table
bi_PrimaryVolumeDescriptor  rd  1    ; LBA of the Primary Volume Descriptor
bi_BootFileLocation         rd  1    ; LBA of the Boot File
bi_BootFileLength           rd  1    ; Length of the boot file in bytes
bi_Checksum                 rd  1    ; 32 bit checksum
bi_Reserved                 rb  40   ; Reserved 'for future standardization'

boot:
jmp $
