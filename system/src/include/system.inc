%ifndef SYSTEM_INC
	%define SYSTEM_INC

;									+----------------------+
;									+--+SYSTEM CONSTANTS+--+
;									+----------------------+

;+----------------------+
;		VIDEO
;+----------------------+
VIDEO_TELETYPE_OUTPUT	EQU 0x0e

;+----------------------+
;		KEYBOARD
;+----------------------+
KB_PORT_COMMAND			EQU 0x64
KB_PORT_STATUS			EQU 0x60

KB_READ_STATUS 			EQU 0xd0
KB_WRITE_STATUS			EQU 0xd1

KB_COMMAND_READY_BIT	EQU 1
KB_STATUS_READY_BIT		EQU 0

;+----------------------+
;		TIMER
;+----------------------+
RTC_INDEX				EQU 0x70
RTC_DATA				EQU 0x71

%endif
