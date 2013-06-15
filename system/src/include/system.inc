;+----------------------+
;+--+SYSTEM CONSTANTS+--+
;+----------------------+

;+----------------------+
;		VIDEO
;+----------------------+
VIDEO_TELETYPE_OUTPUT	= 0x0e

;+----------------------+
;		KEYBOARD
;+----------------------+
KB_PORT_COMMAND		= 0x64
KB_PORT_STATUS		= 0x60

KB_READ_STATUS 		= 0xd0
KB_WRITE_STATUS		= 0xd1

KB_COMMAND_READY_BIT	= 1
KB_STATUS_READY_BIT	= 0

;+----------------------+
;		TIMER
;+----------------------+
RTC_INDEX		= 0x70
RTC_DATA		= 0x71
