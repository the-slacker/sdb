%include 'common.inc'

[BITS 32]
[ORG LOADER_MEM_ADDR]

_start:
	jmp $


;ClusterSize := 1
times 512 - ( $ - $$ ) db 0
