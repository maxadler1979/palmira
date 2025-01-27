                ; i8080 assembler code
                .project ramfont.rk
                .tape rk-bin

                ROM             equ $F800               ; Начало ПЗУ

                KR580VG75       equ $C000
                KR580VT57       equ $E008
                KR580VV55_KBD   equ $C200
                KR580VI53       equ $CC00
                FONT_RAM        equ $D800
                FONT_SET        equ $CE00

                COLS		equ 78
                ROWS		equ 64
                DMA_SIZE        equ COLS * ROWS - 1

                ; Видеорежимы
                DISPLAY_78X64   equ (ROWS - 1) << 8 | (COLS - 1)
                GRAPH_78X64     equ $5877
                DMA_SIZE_78X64  equ DMA_SIZE

                org $0000

                JMP START
                
                ; Конфигурация платформы
                
                RECORD_00:      dw KR580VG75
                RECORD_01:      dw KR580VT57
                RECORD_02:      dw KR580VV55_KBD
                RECORD_03:      dw $0000
                RECORD_04:      dw $0000
                RECORD_05:      dw $0000
                RECORD_06:      dw $0000
                
                CLOCK:          dw $00
                
                FONT_CNT:       dw $0000
                FONT_ROW:       dw $0000
                FONT_COL:       dw $0000
                
                SINE_1          dw $00
                SINE_2          dw $00
                
                SCROLL_INDEX:   db $00
                TEXT_INDEX:     db $00
                LETTER:         db $00, $00, $00, $00, $00, $00, $00, $00
                
                INVERTER:       dw $0000
                
                TRACK_POINTER   db $00
                TRACK_VOLUME    db $00

                TMP             dw $00


        SET_DISPLAY: ; Настройка ВГ75
        
                ; DE - строки и столбцы
                ; BC - размер знакоместа и курсор

		; Останов КР580ВГ75
		LXI H, KR580VG75 + 1


		; Скрываем курсор

        	MVI M, $80
		DCR L
		MVI M, $FF
		MVI M, $FF

		; Останов КР580ВГ75

		INR L
		MVI M, 0
		DCR L

        	MOV M, E	; Столбцы
        	MOV M, D	; Строки
        	MOV M, C	; Позиция курсора и кол-во линий в знакоместе
        	MOV M, B	; 0101.0011
        	
 		; Старт КР580ВГ75

		INR L
        	MVI M, $23

		CALL VG75_READY
		
		RET

		
        SET_DMA: ; Настройка ПДП

                ; DE - адрес экрана
                ; BC - размер экрана
                
                LXI H, KR580VT57
		MVI L, $08
		MVI M, $80
		MVI L, $04
		MOV M, E
		MOV M, D

		INR L
		MOV M, C
		MOV M, B
		MVI L, $08
		MVI M, $A4

                RET


        VG75_READY: ; Ждем обратный ход

                LXI H, KR580VG75 + 1
		MOV A, M
		MOV A, M \\ ANI $20 \\ JZ . - 3
                RET      
                
                
        VI53_RST: ; Сброс ВИ53
        
                LXI H, KR580VI53 + 3
                MVI M, $36 \\ MVI M, $76 \\ MVI M, $B6
                RET
                
                
        SINES:
        
                LDA CLOCK
                LXI D, $0000
                LXI H, SINE
                MOV E, A
                DAD D
                MOV A, M
                ;SBI $80
                
                STA SINE_1
                
                LDA CLOCK
                ADI $40
                LXI H, SINE
                MOV E, A
                DAD D
                MOV A, M
                
                STA SINE_2

                RET


        FONT_ENABLE:

                LXI H, FONT_SET
                ;MOV A, M
                ;ORI 01000000b
                ;MOV M, A
                
                MVI A, 11000000b
                MOV M, A
                
                RET            


        FONT_DISABLE:

                LXI H, FONT_SET
                ;MOV A, M
                ;ANI 10111111b
                ;MOV M, A
                
                MVI A, 10001000b
                MOV M, A
                
                RET

                
        UPLOAD_FONT: 
        
                LXI H, FONT_RAM
                LXI D, FONT
                LXI B, $0000
                
                FONT_CYCLE:
                
                LDAX D
                MOV M, A
                INX H
                INX D

                INR C
                MVI A, $08
                CMP C
                JNZ FONT_CYCLE
                
                MVI C, $08
                DAD B
                MVI C, $00
                
                MVI A, $E0
                CMP H
                JNZ FONT_CYCLE
                
                CALL FONT_ENABLE

                RET


        FONT_WRITE:
        
                ; HL - адрес
                ; E - значение
                ; D - фаза

                MOV A, D \\ RAR \\ MOV D, A \\ MOV A, E \\ JNC . + 4 \\ CMA \\ MOV M, A \\ INX H
                MOV A, D \\ RAR \\ MOV D, A \\ MOV A, E \\ JNC . + 4 \\ CMA \\ MOV M, A \\ INX H
                MOV A, D \\ RAR \\ MOV D, A \\ MOV A, E \\ JNC . + 4 \\ CMA \\ MOV M, A \\ INX H
                MOV A, D \\ RAR \\ MOV D, A \\ MOV A, E \\ JNC . + 4 \\ CMA \\ MOV M, A \\ INX H
                MOV A, D \\ RAR \\ MOV D, A \\ MOV A, E \\ JNC . + 4 \\ CMA \\ MOV M, A \\ INX H
                MOV A, D \\ RAR \\ MOV D, A \\ MOV A, E \\ JNC . + 4 \\ CMA \\ MOV M, A \\ INX H
                MOV A, D \\ RAR \\ MOV D, A \\ MOV A, E \\ JNC . + 4 \\ CMA \\ MOV M, A \\ INX H
                MOV A, D \\ RAR \\ MOV D, A \\ MOV A, E \\ JNC . + 4 \\ CMA \\ MOV M, A
                
                RET
                
                
        COPY_CMA:

                LDAX D \\ CMA \\ MOV M, A \\ INX H \\ INX D
                LDAX D \\ CMA \\ MOV M, A \\ INX H \\ INX D
                LDAX D \\ CMA \\ MOV M, A \\ INX H \\ INX D
                LDAX D \\ CMA \\ MOV M, A \\ INX H \\ INX D
                LDAX D \\ CMA \\ MOV M, A \\ INX H \\ INX D
                LDAX D \\ CMA \\ MOV M, A \\ INX H \\ INX D
                LDAX D \\ CMA \\ MOV M, A \\ INX H \\ INX D
                LDAX D \\ CMA \\ MOV M, A 
                
                RET
                
                
        COPY_XOR:
        
                LDAX D \\ XRA M \\ STAX B \\ INX H \\ INX D \\ INX B
                LDAX D \\ XRA M \\ STAX B \\ INX H \\ INX D \\ INX B
                LDAX D \\ XRA M \\ STAX B \\ INX H \\ INX D \\ INX B
                LDAX D \\ XRA M \\ STAX B \\ INX H \\ INX D \\ INX B
                LDAX D \\ XRA M \\ STAX B \\ INX H \\ INX D \\ INX B
                LDAX D \\ XRA M \\ STAX B \\ INX H \\ INX D \\ INX B
                LDAX D \\ XRA M \\ STAX B \\ INX H \\ INX D \\ INX B
                LDAX D \\ XRA M \\ STAX B

                RET
                
                
        FONT_BUFFER_FLUSH:
        
                CALL FONT_DISABLE
                
                LXI H, $0000
                DAD SP
                SHLD TMP

                LXI SP, FONT_BUFFER
                LXI H, FONT_RAM + $70 * 16
                LXI B, $0008
                
                MVI A, $0C
                
                FLUSH:
                
                POP D \\ MOV M, E \\ INX H \\ MOV M, D \\ INX H
                POP D \\ MOV M, E \\ INX H \\ MOV M, D \\ INX H
                POP D \\ MOV M, E \\ INX H \\ MOV M, D \\ INX H
                POP D \\ MOV M, E \\ INX H \\ MOV M, D \\ INX H
                
                DAD B
                
                DCR A
                JNZ FLUSH

 		LHLD TMP
                SPHL

                CALL FONT_ENABLE

                RET


        SHIFT_RECT:
                
                LDA SINE_1
                ANI 00011111b
                MOV C, A
                MOV E, A
                
                LDA SINE_2
                ANI 00011111b
                MOV B, A
                MOV D, A
                
                LDA FONT_CNT
                CPI $00 \\ JNZ . + 5 \\ MVI B, $00
                CPI $01 \\ JNZ . + 4 \\ MOV B, E
                ;CPI $02 \\ JNZ . + 5 \\ MVI C, $00
                CPI $04 \\ JNZ . + 5 \\ MVI C, $00
                CPI $06 \\ JNZ . + 4 \\ MOV B, E


                LXI H, CELL
                LXI D, $0000
                PUSH D
                PUSH H

                MOV A, C
                ADD A
                MOV E, A
                DAD D
                
                MOV E, M
                INX H
                MOV D, M
                
                XCHG
                SHLD FONT_ROW

                
                POP H
                POP D

                MOV A, B
                ADD A
                MOV E, A
                DAD D
                
                MOV E, M
                INX H
                MOV D, M
                
                XCHG
                SHLD FONT_COL
                
                
                LHLD FONT_COL \\ MOV D, L
                LHLD FONT_ROW \\ MOV E, L
                LXI H, FONT_BUFFER + $00 * 8
                CALL FONT_WRITE
                
                LXI H, FONT_BUFFER + $04 * 8
                LXI D, FONT_BUFFER + $00 * 8
                CALL COPY_CMA
                

                LHLD FONT_COL \\ MOV D, L
                LHLD FONT_ROW \\ MOV E, H
                LXI H, FONT_BUFFER + $01 * 8
                CALL FONT_WRITE

                LXI H, FONT_BUFFER + $05 * 8
                LXI D, FONT_BUFFER + $01 * 8
                CALL COPY_CMA


                LHLD FONT_COL \\ MOV D, H
                LHLD FONT_ROW \\ MOV E, L
                LXI H, FONT_BUFFER + $02 * 8
                CALL FONT_WRITE

                LXI H, FONT_BUFFER + $06 * 8
                LXI D, FONT_BUFFER + $02 * 8
                CALL COPY_CMA


                LHLD FONT_COL \\ MOV D, H
                LHLD FONT_ROW \\ MOV E, H
                LXI H, FONT_BUFFER + $03 * 8
                CALL FONT_WRITE

                LXI H, FONT_BUFFER + $07 * 8
                LXI D, FONT_BUFFER + $03 * 8
                CALL COPY_CMA
                
                ; Инверторы

                LHLD INVERTER \\ XCHG
                LXI H, FONT_BUFFER + $02 * 8
                LXI B, FONT_BUFFER + $08 * 8
                CALL COPY_XOR

                LXI D, 8 * 1
                LHLD INVERTER \\ DAD D \\ XCHG
                LXI H, FONT_BUFFER + $07 * 8
                LXI B, FONT_BUFFER + $09 * 8
                CALL COPY_XOR

                LXI D, 8 * 2
                LHLD INVERTER \\ DAD D \\ XCHG
                LXI H, FONT_BUFFER + $04 * 8
                LXI B, FONT_BUFFER + $0A * 8
                CALL COPY_XOR

                LXI D, 8 * 3
                LHLD INVERTER \\ DAD D \\ XCHG
                LXI H, FONT_BUFFER + $01 * 8
                LXI B, FONT_BUFFER + $0B * 8
                CALL COPY_XOR

                RET
 

        SCROLL_BUFFER_FLUSH:

                LXI H, $0000
                DAD SP
                SHLD TMP

                LXI SP, SCROLL_BUFFER
                LXI H, SCREEN + 8
                LXI B, COLS - 48
                
                MVI A, $03
                
                FLUSH_:
                
                POP D \\ MOV M, E \\ INX H \\ MOV M, D \\ INX H
                POP D \\ MOV M, E \\ INX H \\ MOV M, D \\ INX H
                POP D \\ MOV M, E \\ INX H \\ MOV M, D \\ INX H
                POP D \\ MOV M, E \\ INX H \\ MOV M, D \\ INX H
                POP D \\ MOV M, E \\ INX H \\ MOV M, D \\ INX H
                POP D \\ MOV M, E \\ INX H \\ MOV M, D \\ INX H
                POP D \\ MOV M, E \\ INX H \\ MOV M, D \\ INX H
                POP D \\ MOV M, E \\ INX H \\ MOV M, D \\ INX H
                POP D \\ MOV M, E \\ INX H \\ MOV M, D \\ INX H
                POP D \\ MOV M, E \\ INX H \\ MOV M, D \\ INX H
                POP D \\ MOV M, E \\ INX H \\ MOV M, D \\ INX H
                POP D \\ MOV M, E \\ INX H \\ MOV M, D \\ INX H
                POP D \\ MOV M, E \\ INX H \\ MOV M, D \\ INX H
                POP D \\ MOV M, E \\ INX H \\ MOV M, D \\ INX H
                POP D \\ MOV M, E \\ INX H \\ MOV M, D \\ INX H
                POP D \\ MOV M, E \\ INX H \\ MOV M, D \\ INX H
                POP D \\ MOV M, E \\ INX H \\ MOV M, D \\ INX H
                POP D \\ MOV M, E \\ INX H \\ MOV M, D \\ INX H
                POP D \\ MOV M, E \\ INX H \\ MOV M, D \\ INX H
                POP D \\ MOV M, E \\ INX H \\ MOV M, D \\ INX H
                POP D \\ MOV M, E \\ INX H \\ MOV M, D \\ INX H
                POP D \\ MOV M, E \\ INX H \\ MOV M, D \\ INX H
                POP D \\ MOV M, E \\ INX H \\ MOV M, D \\ INX H
                POP D \\ MOV M, E \\ INX H \\ MOV M, D \\ INX H

                DAD B
                
                DCR A
                JNZ FLUSH_

 		LHLD TMP
                SPHL

                RET


        SCROLL:

                LXI H,  SCROLL_BUFFER
                LXI D,  SCROLL_BUFFER + 1
                
                
                MVI C, $90
                
                SCROLL_LOOP:
                
                MOV A, M
                RAR
                ANI 00000101b
                MOV B, A
                
                LDAX D
                RAL
                ANI 00001010b
                ORA B
                MOV M, A
                
                INX H \\ INX D

                DCR C
                JNZ SCROLL_LOOP

                ; Скроллим символ

                LXI H, LETTER
                MOV A, M \\ RLC \\ MOV M, A \\ INX H
                MOV A, M \\ RLC \\ MOV M, A \\ INX H
                MOV A, M \\ RLC \\ MOV M, A \\ INX H
                MOV A, M \\ RLC \\ MOV M, A \\ INX H
                MOV A, M \\ RLC \\ MOV M, A \\ INX H
                MOV A, M \\ RLC \\ MOV M, A \\ INX H

                ; Выводим символ
                
                LXI H, SCROLL_BUFFER + 47
                LXI D, LETTER
                LXI B, 48
                
                MVI A, $03
                
                PRINT_LOOP:
                
                PUSH PSW

                LDAX D
                ANI 00100000b
                CPI $00 \\ JZ . + 5 \\ MVI A, $01
                MOV M, A
                INX D

                LDAX D                
                ANI 00100000b
                CPI $00 \\ JZ . + 5 \\ MVI A, $04
                ORA M
                MOV M, A
                INX D

                DAD B
                
                POP PSW
                DCR A
                JNZ PRINT_LOOP
                
                LDA SCROLL_INDEX
                INR A
                CPI $06 \\ JNZ . + 4 \\ XRA A
                STA SCROLL_INDEX
                
                CPI $00 \\ RNZ
                
                LXI H, GREETINGS
                LXI B, $0000
                LDA TEXT_INDEX
                MOV C, A
                DAD B
                
                INR A
                STA TEXT_INDEX
                
                MOV A, M
                LXI B, $0000
                MOV C, A

                LXI H, FONT
                DAD B \\ DAD B \\ DAD B \\ DAD B \\ DAD B \\ DAD B \\ DAD B \\ DAD B 
                XCHG

                LXI H, LETTER
                CALL COPY_CMA


                RET


        TRACKER:

                ; Нота
		LDA TRACK_POINTER
                LXI H, TRACK
                MVI B, 0 \\ MOV C, A \\ DAD B \\ MOV A, M

                CPI $00 \\ JZ TRACKER_COUNTER ; Нота не изменилась
                
                ; Новая нота, сброс настроек канала
                LXI H, KR580VI53 + 3
                MVI M, $36 \\ MVI M, $76 \\ MVI M, $B6
                
                CPI $FF \\ JZ TRACKER_COUNTER ; Нота останов

                TRACKER_SOUND: ; Загружаем ноту

                LXI H, SCALES
                
                ADD A \\ MVI B, 0 \\ MOV C, A \\ DAD B
                MOV B, M \\ INX H \\ MOV C, M
                
                LXI H, KR580VI53
                MOV M, B \\ MOV M, C \\ INR L
                MOV M, B \\ MOV M, C \\ INR L
                MOV M, B \\ MOV M, C
                
                MVI A, $07 \\ STA TRACK_VOLUME

                TRACKER_COUNTER:
                
		LXI H, TRACK_POINTER
                INR M

		RET


START:

                ; Настройка знакогенератора
                LXI D, DISPLAY_78X64
                LXI B, GRAPH_78X64
                CALL SET_DISPLAY
                
                ; Настройка ПДП                
                LXI D, SCREEN
		MVI C, DMA_SIZE_78X64 & $00FF
		MVI B, ($4000 + DMA_SIZE_78X64) >> 8
                CALL SET_DMA
                
                CALL UPLOAD_FONT
                
                LXI H, CIRCLE
                SHLD INVERTER
                
                ; Расставляем инверторы
                
                LXI H, $0000
                DAD SP

                LXI D, $7978
                
                LXI SP, SCREEN + 7 * COLS + 23 \\ PUSH D
                LXI SP, SCREEN + 7 * COLS + 27 \\ PUSH D
                LXI SP, SCREEN + 7 * COLS + 31 \\ PUSH D
                LXI SP, SCREEN + 7 * COLS + 35 \\ PUSH D
                LXI SP, SCREEN + 7 * COLS + 43 \\ PUSH D
                
                LXI SP, SCREEN + 11 * COLS + 23 \\ PUSH D
                LXI SP, SCREEN + 11 * COLS + 31 \\ PUSH D
                LXI SP, SCREEN + 11 * COLS + 35 \\ PUSH D
                LXI SP, SCREEN + 11 * COLS + 43 \\ PUSH D
                
                LXI SP, SCREEN + 15 * COLS + 23 \\ PUSH D
                LXI SP, SCREEN + 15 * COLS + 27 \\ PUSH D
                LXI SP, SCREEN + 15 * COLS + 31 \\ PUSH D
                LXI SP, SCREEN + 15 * COLS + 35 \\ PUSH D
                LXI SP, SCREEN + 15 * COLS + 39 \\ PUSH D
                
                LXI SP, SCREEN + 19 * COLS + 23 \\ PUSH D
                LXI SP, SCREEN + 19 * COLS + 35 \\ PUSH D
                LXI SP, SCREEN + 19 * COLS + 43 \\ PUSH D
                
                LXI SP, SCREEN + 23 * COLS + 23 \\ PUSH D
                LXI SP, SCREEN + 23 * COLS + 35 \\ PUSH D
                LXI SP, SCREEN + 23 * COLS + 43 \\ PUSH D
                
                LXI D, $7B7A

                LXI SP, SCREEN + 8 * COLS + 23 \\ PUSH D
                LXI SP, SCREEN + 8 * COLS + 27 \\ PUSH D
                LXI SP, SCREEN + 8 * COLS + 31 \\ PUSH D
                LXI SP, SCREEN + 8 * COLS + 35 \\ PUSH D
                LXI SP, SCREEN + 8 * COLS + 43 \\ PUSH D
                
                LXI SP, SCREEN + 12 * COLS + 23 \\ PUSH D
                LXI SP, SCREEN + 12 * COLS + 31 \\ PUSH D
                LXI SP, SCREEN + 12 * COLS + 35 \\ PUSH D
                LXI SP, SCREEN + 12 * COLS + 43 \\ PUSH D
                
                LXI SP, SCREEN + 16 * COLS + 23 \\ PUSH D
                LXI SP, SCREEN + 16 * COLS + 27 \\ PUSH D
                LXI SP, SCREEN + 16 * COLS + 31 \\ PUSH D
                LXI SP, SCREEN + 16 * COLS + 35 \\ PUSH D
                LXI SP, SCREEN + 16 * COLS + 39 \\ PUSH D
                
                LXI SP, SCREEN + 20 * COLS + 23 \\ PUSH D
                LXI SP, SCREEN + 20 * COLS + 35 \\ PUSH D
                LXI SP, SCREEN + 20 * COLS + 43 \\ PUSH D
                
                LXI SP, SCREEN + 24 * COLS + 23 \\ PUSH D
                LXI SP, SCREEN + 24 * COLS + 35 \\ PUSH D
                LXI SP, SCREEN + 24 * COLS + 43 \\ PUSH D

                SPHL
                

        MAIN:

		; Ждём обратный ход луча для синхронизации
		
		CALL VG75_READY

		; Счетчик-делитель

		LXI H, CLOCK
		INR M

		; X1
		CALL X1

                ; X2 FLIP
		LDA CLOCK
		ANI 1
		CZ X2
		
                ; X2 FLOP
		LDA CLOCK
		ANI 1
		CNZ X2_

                ; X4
		LDA CLOCK
 		ANI 3
		CZ X4
   
                JMP MAIN


        X2:
        
                CALL FONT_BUFFER_FLUSH
                CALL SHIFT_RECT
                CALL SINES
                CALL TRACKER

		RET


        X2_:

                CALL SCROLL_BUFFER_FLUSH
                CALL SCROLL
                
                RET


        X4:

		; Опрос клавиавтуры
                LXI H, KR580VV55_KBD
                MVI M, 11111110b

		; Выход
                LDA KR580VV55_KBD + 1
                CPI 11111011b
                JZ ROM
		RET
		

        X1:
        
                ; Амплитуда меандра

                LDA TRACK_VOLUME
                DCR A
                ANI 00000111b
                STA TRACK_VOLUME
                
                LXI H, KR580VI53 + 3
                CPI $05 \\ JNZ . + 5 \\ MVI M, $B6
                CPI $03 \\ JNZ . + 5 \\ MVI M, $76
                CPI $00 \\ JNZ . + 5 \\ MVI M, $36

                ; Смена спрайтов

                LDA CLOCK
                CPI $00
                JNZ SPRITES
                LDA FONT_CNT
                INR A
                CPI $06 \\ JNZ . + 4 \\ XRA A
                STA FONT_CNT
                
                
                SPRITES:
                
                LDA CLOCK
                RRC \\ RRC \\ RRC
                ANI 00000011b

                CPI $00
                JNZ INVERTER_01
                
                LXI H, CIRCLE
                SHLD INVERTER
                RET
                
                INVERTER_01:
                
                CPI $01
                JNZ INVERTER_02
                
                LXI H, DIAMOND
                SHLD INVERTER
                RET
                
                INVERTER_02:
                
                CPI $02
                JNZ INVERTER_03
                
                LXI H, STAR
                SHLD INVERTER
                RET
                
                INVERTER_03:
                
                LXI H, DIAMOND
                SHLD INVERTER
        
                RET

                
SINE: 

		db $00, $00, $00, $00, $01, $01, $01, $02
		db $02, $03, $04, $05, $05, $06, $07, $09
		db $0A, $0B, $0C, $0E, $0F, $11, $12, $14
		db $15, $17, $19, $1B, $1D, $1F, $21, $23
		db $25, $28, $2A, $2C, $2F, $31, $34, $36
		db $39, $3B, $3E, $41, $43, $46, $49, $4C
		db $4F, $52, $55, $58, $5A, $5D, $61, $64
		db $67, $6A, $6D, $70, $73, $76, $79, $7C
		db $80, $83, $86, $89, $8C, $8F, $92, $95
		db $98, $9B, $9E, $A2, $A5, $A7, $AA, $AD
		db $B0, $B3, $B6, $B9, $BC, $BE, $C1, $C4
		db $C6, $C9, $CB, $CE, $D0, $D3, $D5, $D7
		db $DA, $DC, $DE, $E0, $E2, $E4, $E6, $E8
		db $EA, $EB, $ED, $EE, $F0, $F1, $F3, $F4
		db $F5, $F6, $F8, $F9, $FA, $FA, $FB, $FC
		db $FD, $FD, $FE, $FE, $FE, $FF, $FF, $FF
		db $FF, $FF, $FF, $FF, $FE, $FE, $FE, $FD
		db $FD, $FC, $FB, $FA, $FA, $F9, $F8, $F6
		db $F5, $F4, $F3, $F1, $F0, $EE, $ED, $EB
		db $EA, $E8, $E6, $E4, $E2, $E0, $DE, $DC
		db $DA, $D7, $D5, $D3, $D0, $CE, $CB, $C9
		db $C6, $C4, $C1, $BE, $BC, $B9, $B6, $B3
		db $B0, $AD, $AA, $A7, $A5, $A2, $9E, $9B
		db $98, $95, $92, $8F, $8C, $89, $86, $83
		db $80, $7C, $79, $76, $73, $70, $6D, $6A
		db $67, $64, $61, $5D, $5A, $58, $55, $52
		db $4F, $4C, $49, $46, $43, $41, $3E, $3B
		db $39, $36, $34, $31, $2F, $2C, $2A, $28
		db $25, $23, $21, $1F, $1D, $1B, $19, $17
		db $15, $14, $12, $11, $0F, $0E, $0C, $0B
		db $0A, $09, $07, $06, $05, $05, $04, $03
		db $02, $02, $01, $01, $01, $00, $00, $00

		
CELL:           
                dw $0000, $0001, $0003, $0007, $000F, $001F, $003F, $007F
                dw $00FF, $01FF, $03FF, $07FF, $0FFF, $1FFF, $3FFF, $7FFF
                dw $FFFF, $FFFE, $FFFC, $FFF8, $FFF0, $FFE0, $FFC0, $FF80
                dw $FF00, $FE00, $FC00, $F800, $F000, $E000, $C000, $8000
               
                
FONT_BUFFER:
		db $00, $00, $00, $00, $00, $00, $00, $00,      $00, $00, $00, $00, $00, $00, $00, $00,      $00, $00, $00, $00, $00, $00, $00, $00,      $00, $00, $00, $00, $00, $00, $00, $00
		db $00, $00, $00, $00, $00, $00, $00, $00,      $00, $00, $00, $00, $00, $00, $00, $00,      $00, $00, $00, $00, $00, $00, $00, $0F,      $00, $00, $00, $00, $00, $00, $00, $00
		db $00, $00, $00, $00, $00, $00, $00, $00,      $00, $00, $00, $00, $00, $00, $00, $00,      $00, $00, $00, $00, $00, $00, $00, $00,      $00, $00, $00, $00, $00, $00, $00, $00
		db $00, $00, $00, $00, $00, $00, $00, $00,      $00, $00, $00, $00, $00, $00, $00, $00,      $00, $00, $00, $00, $00, $00, $00, $0F,      $00, $00, $00, $00, $00, $00, $00, $00
               
                
SCROLL_BUFFER:
		db $00, $00, $00, $00, $00, $00, $00, $00,      $00, $00, $00, $00, $00, $00, $00, $00,      $00, $00, $00, $00, $00, $00, $00, $00,      $00, $00, $00, $00, $00, $00, $00, $00
		db $00, $00, $00, $00, $00, $00, $00, $00,      $00, $00, $00, $00, $00, $00, $00, $00,      $00, $00, $00, $00, $00, $00, $00, $00,      $00, $00, $00, $00, $00, $00, $00, $00
		db $00, $00, $00, $00, $00, $00, $00, $00,      $00, $00, $00, $00, $00, $00, $00, $00,      $00, $00, $00, $00, $00, $00, $00, $00,      $00, $00, $00, $00, $00, $00, $00, $00
		db $00, $00, $00, $00, $00, $00, $00, $00,      $00, $00, $00, $00, $00, $00, $00, $00,      $00, $00, $00, $00, $00, $00, $00, $00,      $00, $00, $00, $00, $00, $00, $00, $00
		db $00, $00, $00, $00, $00, $00, $00, $00,      $00, $00, $00, $00, $00, $00, $00, $00,      $00, $00, $00, $00, $00, $00, $00, $00,      $00, $00, $00, $00, $00, $00, $00, $00

                
FONT:           

                db $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
                db $9F, $4F, $0F, $9F, $FF, $FF, $FF, $FF
                db $F9, $F4, $F0, $F9, $FF, $FF, $FF, $FF
                db $99, $44, $00, $99, $FF, $FF, $FF, $FF
                db $FF, $FF, $FF, $FF, $9F, $4F, $0F, $9F
                db $9F, $4F, $0F, $9F, $9F, $4F, $0F, $9F
                db $F9, $F4, $F0, $F9, $9F, $4F, $0F, $9F
                db $99, $44, $00, $99, $9F, $4F, $0F, $9F
                db $FF, $FF, $FF, $FF, $F9, $F4, $F0, $F9
                db $9F, $4F, $0F, $9F, $F9, $F4, $F0, $F9
                db $F9, $F4, $F0, $F9, $F9, $F4, $F0, $F9
                db $99, $44, $00, $99, $F9, $F4, $F0, $F9
                db $FF, $FF, $FF, $FF, $99, $44, $00, $99
                db $9F, $4F, $0F, $9F, $99, $44, $00, $99
                db $F9, $F4, $F0, $F9, $99, $44, $00, $99
                db $99, $44, $00, $99, $99, $44, $00, $99
                db $DF, $CF, $C7, $C3, $C1, $CF, $DF, $FF
                db $7E, $BD, $FF, $FF, $FF, $FF, $BD, $7E
                db $FF, $C9, $B0, $B8, $D9, $EB, $F7, $FF
                db $E7, $E7, $FF, $A5, $A5, $E7, $FF, $DB
                db $FF, $DF, $AD, $DA, $FD, $EF, $AB, $AA
                db $FF, $10, $10, $14, $FF, $81, $01, $01
                db $1C, $0E, $07, $83, $C1, $E0, $70, $38
                db $55, $AA, $55, $AA, $55, $AA, $55, $AA
                db $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
                db $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
                db $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
                db $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
                db $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
                db $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
                db $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
                db $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
                db $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
                db $FB, $FB, $FB, $FF, $FB, $FF, $FF, $FF
                db $F5, $F5, $FF, $FF, $FF, $FF, $FF, $FF
                db $F5, $E0, $F5, $E0, $F5, $FF, $FF, $FF
                db $EE, $F1, $F5, $F1, $EE, $FF, $FF, $FF
                db $FE, $ED, $FB, $F6, $EF, $FF, $FF, $FF
                db $F3, $EF, $F2, $ED, $F2, $FF, $FF, $FF
                db $F9, $FD, $FF, $FF, $FF, $FF, $FF, $FF
                db $FB, $F7, $F7, $F7, $FB, $FF, $FF, $FF
                db $FB, $FD, $FD, $FD, $FB, $FF, $FF, $FF
                db $FB, $EA, $F1, $EA, $FB, $FF, $FF, $FF
                db $FB, $FB, $E0, $FB, $FB, $FF, $FF, $FF
                db $FF, $FF, $FF, $EF, $EF, $FF, $FF, $FF
                db $FF, $FF, $E0, $FF, $FF, $FF, $FF, $FF
                db $FF, $FF, $FF, $FF, $EF, $FF, $FF, $FF
                db $FE, $FD, $FB, $F7, $EF, $FF, $FF, $FF
                db $E0, $EC, $EA, $E6, $E0, $FF, $FF, $FF
                db $FB, $F3, $FB, $FB, $F1, $FF, $FF, $FF
                db $E1, $FE, $F1, $EF, $E0, $FF, $FF, $FF
                db $E0, $FE, $E0, $FE, $E0, $FF, $FF, $FF
                db $FB, $F7, $ED, $E0, $FD, $FF, $FF, $FF
                db $E0, $EF, $E0, $FE, $E1, $FF, $FF, $FF
                db $E0, $EF, $E0, $EE, $E0, $FF, $FF, $FF
                db $E0, $FE, $FD, $FB, $FB, $FF, $FF, $FF
                db $E0, $EE, $E0, $EE, $E0, $FF, $FF, $FF
                db $E0, $EE, $E0, $FE, $E0, $FF, $FF, $FF
                db $FF, $EF, $FF, $EF, $FF, $FF, $FF, $FF
                db $FF, $EF, $FF, $EF, $EF, $FF, $FF, $FF
                db $FE, $FD, $FB, $FD, $FE, $FF, $FF, $FF
                db $FF, $E0, $FF, $E0, $FF, $FF, $FF, $FF
                db $EF, $F7, $FB, $F7, $EF, $FF, $FF, $FF
                db $F3, $ED, $FB, $FF, $FB, $FF, $FF, $FF
                db $E0, $EE, $E8, $EF, $E0, $FF, $FF, $FF
                db $E0, $EE, $EE, $E0, $EE, $FF, $FF, $FF
                db $E1, $ED, $E0, $EE, $E0, $FF, $FF, $FF
                db $E0, $EF, $EF, $EF, $E0, $FF, $FF, $FF
                db $E1, $EE, $EE, $EE, $E1, $FF, $FF, $FF
                db $E0, $EF, $E1, $EF, $E0, $FF, $FF, $FF
                db $E0, $EF, $E1, $EF, $EF, $FF, $FF, $FF
                db $E0, $EF, $EC, $EE, $E0, $FF, $FF, $FF
                db $EE, $EE, $E0, $EE, $EE, $FF, $FF, $FF
                db $E0, $FB, $FB, $FB, $E0, $FF, $FF, $FF
                db $F0, $FD, $FD, $ED, $E1, $FF, $FF, $FF
                db $EE, $ED, $E3, $ED, $EE, $FF, $FF, $FF
                db $EF, $EF, $EF, $EF, $E1, $FF, $FF, $FF
                db $EE, $E4, $EA, $EE, $EE, $FF, $FF, $FF
                db $EE, $E6, $EA, $EC, $EE, $FF, $FF, $FF
                db $F1, $EE, $EE, $EE, $F1, $FF, $FF, $FF
                db $E1, $EE, $EE, $E1, $EF, $FF, $FF, $FF
                db $E0, $EE, $EE, $EC, $E0, $FF, $FF, $FF
                db $E1, $EE, $EE, $E1, $EE, $FF, $FF, $FF
                db $E0, $EF, $E0, $FE, $E0, $FF, $FF, $FF
                db $E0, $FB, $FB, $FB, $FB, $FF, $FF, $FF
                db $EE, $EE, $EE, $EE, $F1, $FF, $FF, $FF
                db $EE, $EE, $EE, $F5, $FB, $FF, $FF, $FF
                db $EE, $EE, $EE, $EA, $F5, $FF, $FF, $FF
                db $EE, $F5, $FB, $F5, $EE, $FF, $FF, $FF
                db $EE, $EE, $F5, $FB, $FB, $FF, $FF, $FF
                db $E0, $FD, $FB, $F7, $E0, $FF, $FF, $FF
                db $F3, $F7, $F7, $F7, $F3, $FF, $FF, $FF
                db $EF, $F7, $FB, $FD, $FE, $FF, $FF, $FF
                db $F9, $FD, $FD, $FD, $F9, $FF, $FF, $FF
                db $F1, $EE, $FF, $FF, $FF, $FF, $FF, $FF
                db $FF, $FF, $FF, $FF, $E0, $FF, $FF, $FF
                db $E8, $EA, $E2, $EA, $E8, $FF, $FF, $FF
                db $E0, $EE, $EE, $E0, $EE, $FF, $FF, $FF
                db $E0, $EF, $E0, $EE, $E0, $FF, $FF, $FF
                db $ED, $ED, $ED, $ED, $E0, $FE, $FF, $FF
                db $F1, $F5, $F5, $F5, $E0, $FF, $FF, $FF
                db $E0, $EF, $E1, $EF, $E0, $FF, $FF, $FF
                db $E0, $EA, $EA, $E0, $FB, $FF, $FF, $FF
                db $E0, $EE, $EF, $EF, $EF, $FF, $FF, $FF
                db $EE, $F5, $FB, $F5, $EE, $FF, $FF, $FF
                db $EE, $EC, $EA, $E6, $EE, $FF, $FF, $FF
                db $EA, $EC, $EA, $E6, $EE, $FF, $FF, $FF
                db $EE, $ED, $E3, $ED, $EE, $FF, $FF, $FF
                db $F8, $F6, $F6, $F6, $E6, $FF, $FF, $FF
                db $EE, $E4, $EA, $EE, $EE, $FF, $FF, $FF
                db $EE, $EE, $E0, $EE, $EE, $FF, $FF, $FF
                db $F1, $EE, $EE, $EE, $F1, $FF, $FF, $FF
                db $E0, $EE, $EE, $EE, $EE, $FF, $FF, $FF
                db $F0, $EE, $EE, $F0, $EE, $FF, $FF, $FF
                db $E1, $EE, $EE, $E1, $EF, $FF, $FF, $FF
                db $F0, $EF, $EF, $EF, $F0, $FF, $FF, $FF
                db $E0, $FB, $FB, $FB, $FB, $FF, $FF, $FF
                db $EE, $EE, $F5, $FB, $F7, $FF, $FF, $FF
                db $EE, $EA, $E0, $EA, $EE, $FF, $FF, $FF
                db $E1, $ED, $E0, $EE, $E0, $FF, $FF, $FF
                db $EF, $E1, $EE, $EE, $E1, $FF, $FF, $FF
                db $EE, $E2, $EC, $EC, $E2, $FF, $FF, $FF
                db $F1, $EE, $F9, $EE, $F1, $FF, $FF, $FF
                db $EE, $EA, $EA, $EA, $E0, $FF, $FF, $FF
                db $F1, $EE, $F8, $EE, $F1, $FF, $FF, $FF
                db $EE, $EA, $EA, $EA, $E0, $FE, $FF, $FF
                db $EE, $EE, $EE, $E0, $FE, $FF, $FF, $FF
                db $E7, $F1, $F6, $F6, $F1, $FF, $FF, $FF
                
                
CIRCLE:                
                db $07, $1F, $3F, $7F, $7F, $FF, $FF, $FF
                db $E0, $F8, $FC, $FE, $FE, $FF, $FF, $FF
                db $FF, $FF, $FF, $7F, $7F, $3F, $1F, $07
                db $FF, $FF, $FF, $FE, $FE, $FC, $F8, $E0
                
                
DIAMOND:                
                db $01, $03, $07, $0F, $1F, $3F, $7F, $FF
                db $80, $C0, $E0, $F0, $F8, $FC, $FE, $FF
                db $FF, $7F, $3F, $1F, $0F, $07, $03, $01
                db $FF, $FE, $FC, $F8, $F0, $E0, $C0, $80
                
                
STAR:                
                db $01, $01, $03, $03, $07, $0F, $3F, $FF
                db $80, $80, $C0, $C0, $E0, $F0, $FC, $FF
                db $FF, $3F, $0F, $07, $03, $03, $01, $01
                db $FF, $FC, $F0, $E0, $C0, $C0, $80, $80
                
                
SCALES:         ;  C      C#     D      D#     E      F      F#     G      G#     A      A#     B
                dw $8000, $78DF, $7223, $6BC7, $65C6, $601A, $5AC0, $55B2, $50EB, $4C69, $4827, $4422
                dw $4057, $3CC1, $395F, $362C, $3328, $304E, $2D9D, $2B13, $28AC, $2668, $2445, $223F
                dw $2057, $1E8A, $1CD6, $1B3B, $19B7, $1848, $16EE, $15A7, $1472, $134E, $123B, $1137
                dw $1041, $0F5A, $0E7F, $0DB0, $0CED, $0C35, $0B86, $0AE2, $0A47, $09B4, $092A, $08A7
                dw $082C, $07B7, $0749, $06E1, $067F, $0623, $05CB, $0579, $052B, $04E1, $049B, $045A
                

TRACK:
                db $0C, $00, $00, $00, $18, $00, $18, $00,      $0A, $00, $00, $00, $0C, $00, $00, $00,      $00, $00, $00, $00, $00, $00, $00, $00,      $0A, $00, $00, $00, $00, $00, $00, $00
                db $0C, $00, $00, $00, $18, $00, $18, $00,      $0A, $00, $00, $24, $0C, $00, $00, $00,      $00, $00, $00, $00, $00, $00, $00, $00,      $00, $27, $24, $27, $24, $00, $00, $00
                db $0C, $00, $00, $00, $18, $00, $18, $00,      $0A, $00, $00, $00, $0C, $00, $00, $00,      $00, $00, $00, $00, $00, $00, $00, $00,      $0A, $00, $00, $00, $00, $00, $00, $00
                db $0C, $00, $00, $00, $18, $00, $18, $00,      $0A, $00, $00, $24, $0C, $00, $00, $00,      $00, $00, $00, $00, $00, $00, $00, $00,      $00, $27, $24, $27, $24, $00, $00, $00
                db $0C, $00, $00, $00, $18, $00, $18, $00,      $0A, $00, $00, $00, $0C, $00, $00, $00,      $00, $00, $00, $00, $00, $00, $00, $00,      $0A, $00, $00, $00, $00, $00, $00, $00
                db $0C, $00, $00, $00, $18, $00, $18, $00,      $0A, $00, $00, $24, $0C, $00, $00, $00,      $00, $00, $00, $00, $00, $00, $00, $00,      $00, $27, $24, $27, $24, $00, $00, $00
                db $0C, $00, $00, $00, $18, $00, $18, $00,      $0A, $00, $00, $00, $0C, $00, $00, $00,      $00, $00, $00, $00, $18, $00, $18, $00,      $0A, $00, $00, $00, $18, $00, $18, $00
                db $0C, $00, $00, $00, $0C, $00, $00, $00,      $0B, $00, $00, $00, $0B, $00, $00, $00,      $0A, $00, $00, $00, $00, $00, $00, $00,      $00, $00, $00, $00, $00, $00, $00, $00
                
SCREEN:

                ; Видимая область
                
                ; 01
		db $00, $00, $00, $00, $00, $00, $00, $8C,      $00, $00, $00, $00, $00, $00, $00, $00,      $00, $00, $00, $00, $00, $00, $00, $00,      $00, $00, $00, $00, $00, $00, $00, $00
		db $00, $00, $00, $00, $00, $00, $00, $00,      $00, $00, $00, $00, $00, $00, $00, $00,      $00, $00, $00, $00, $00, $00, $00, $00,      $00, $00, $00, $00, $00, $00, $00, $00
		db $00, $00, $00, $00, $00, $00, $00, $F1,      $00, $00, $00, $00, $00, $00
		
                ; 02
		db $00, $00, $00, $00, $00, $00, $00, $00,      $00, $00, $00, $00, $00, $00, $00, $00,      $00, $00, $00, $00, $00, $00, $00, $00,      $00, $00, $00, $00, $00, $00, $00, $00
		db $00, $00, $00, $00, $00, $00, $00, $00,      $00, $00, $00, $00, $00, $00, $00, $00,      $00, $00, $00, $00, $00, $00, $00, $00,      $00, $00, $00, $00, $00, $00, $00, $00
		db $00, $00, $00, $00, $00, $00, $00, $F1,      $00, $00, $00, $00, $00, $00

                ; 03
		db $00, $00, $00, $00, $00, $00, $00, $00,      $00, $00, $00, $00, $00, $00, $00, $00,      $00, $00, $00, $00, $00, $00, $00, $00,      $00, $00, $00, $00, $00, $00, $00, $00
		db $00, $00, $00, $00, $00, $00, $00, $00,      $00, $00, $00, $00, $00, $00, $00, $00,      $00, $00, $00, $00, $00, $00, $00, $00,      $00, $00, $00, $00, $00, $00, $00, $80
		db $00, $00, $00, $00, $00, $00, $00, $F1,      $00, $00, $00, $00, $00, $00
		
                ; 04
		db $00, $00, $00, $00, $00, $00, $00, $00,      $00, $00, $00, $00, $00, $00, $00, $00,      $00, $00, $00, $00, $00, $00, $00, $00,      $00, $00, $00, $00, $00, $00, $00, $00
		db $00, $00, $00, $00, $00, $00, $00, $00,      $00, $00, $00, $00, $00, $00, $00, $00,      $00, $00, $00, $00, $00, $00, $00, $00,      $80, $00, $00, $00, $00, $00, $00, $00
		db $00, $00, $00, $00, $00, $00, $00, $F1,      $00, $00, $00, $00, $00, $00

                ; 05
		db $00, $00, $00, $00, $00, $00, $00, $81,      $75, $74, $71, $70, $75, $74, $71, $70,      $75, $74, $71, $70, $75, $74, $71, $70,      $75, $74, $71, $70, $75, $74, $71, $70
		db $75, $74, $71, $70, $75, $74, $71, $70,      $75, $74, $71, $70, $75, $74, $71, $70,      $75, $74, $71, $70, $75, $74, $71, $70,      $00, $80, $00, $00, $00, $00, $00, $00
		db $00, $00, $00, $00, $00, $00, $00, $F1,      $00, $00, $00, $00, $00, $00
		
                ; 06
		db $00, $00, $00, $00, $00, $00, $00, $81,      $77, $76, $73, $72, $77, $76, $73, $72,      $77, $76, $73, $72, $77, $76, $73, $72,      $77, $76, $73, $72, $77, $76, $73, $72
		db $77, $76, $73, $72, $77, $76, $73, $72,      $77, $76, $73, $72, $77, $76, $73, $72,      $77, $76, $73, $72, $77, $76, $73, $72,      $00, $80, $00, $00, $00, $00, $00, $00
		db $00, $00, $00, $00, $00, $00, $00, $F1,      $00, $00, $00, $00, $00, $00
		
                ; 07
		db $00, $00, $00, $00, $00, $00, $00, $81,      $71, $70, $75, $74, $71, $70, $75, $74,      $71, $70, $75, $74, $71, $70, $75, $74,      $71, $70, $75, $74, $71, $70, $75, $74
		db $71, $70, $75, $74, $71, $70, $75, $74,      $71, $70, $75, $74, $71, $70, $75, $74,      $71, $70, $75, $74, $71, $70, $75, $74,      $00, $80, $00, $00, $00, $00, $00, $00
		db $00, $00, $00, $00, $00, $00, $00, $F1,      $00, $00, $00, $00, $00, $00
		
                ; 08
		db $00, $00, $00, $00, $00, $00, $00, $81,      $73, $72, $77, $76, $73, $72, $77, $76,      $73, $72, $77, $76, $73, $72, $77, $76,      $73, $72, $77, $76, $73, $72, $77, $76
		db $73, $72, $77, $76, $73, $72, $77, $76,      $73, $72, $77, $76, $73, $72, $77, $76,      $73, $72, $77, $76, $73, $72, $77, $76,      $00, $80, $00, $00, $00, $00, $00, $00
		db $00, $00, $00, $00, $00, $00, $00, $F1,      $00, $00, $00, $00, $00, $00

                ; 09
		db $00, $00, $00, $00, $00, $00, $00, $81,      $75, $74, $71, $70, $75, $74, $71, $70,      $75, $74, $71, $70, $75, $74, $71, $70,      $75, $74, $71, $70, $75, $74, $71, $70
		db $75, $74, $71, $70, $75, $74, $71, $70,      $75, $74, $71, $70, $75, $74, $71, $70,      $75, $74, $71, $70, $75, $74, $71, $70,      $00, $80, $00, $00, $00, $00, $00, $00
		db $00, $00, $00, $00, $00, $00, $00, $F1,      $00, $00, $00, $00, $00, $00
		
                ; 10
		db $00, $00, $00, $00, $00, $00, $00, $81,      $77, $76, $73, $72, $77, $76, $73, $72,      $77, $76, $73, $72, $77, $76, $73, $72,      $77, $76, $73, $72, $77, $76, $73, $72
		db $77, $76, $73, $72, $77, $76, $73, $72,      $77, $76, $73, $72, $77, $76, $73, $72,      $77, $76, $73, $72, $77, $76, $73, $72,      $00, $80, $00, $00, $00, $00, $00, $00
		db $00, $00, $00, $00, $00, $00, $00, $F1,      $00, $00, $00, $00, $00, $00
		
                ; 11
		db $00, $00, $00, $00, $00, $00, $00, $81,      $71, $70, $75, $74, $71, $70, $75, $74,      $71, $70, $75, $74, $71, $70, $75, $74,      $71, $70, $75, $74, $71, $70, $75, $74
		db $71, $70, $75, $74, $71, $70, $75, $74,      $71, $70, $75, $74, $71, $70, $75, $74,      $71, $70, $75, $74, $71, $70, $75, $74,      $00, $80, $00, $00, $00, $00, $00, $00
		db $00, $00, $00, $00, $00, $00, $00, $F1,      $00, $00, $00, $00, $00, $00
		
                ; 12
		db $00, $00, $00, $00, $00, $00, $00, $81,      $73, $72, $77, $76, $73, $72, $77, $76,      $73, $72, $77, $76, $73, $72, $77, $76,      $73, $72, $77, $76, $73, $72, $77, $76
		db $73, $72, $77, $76, $73, $72, $77, $76,      $73, $72, $77, $76, $73, $72, $77, $76,      $73, $72, $77, $76, $73, $72, $77, $76,      $00, $80, $00, $00, $00, $00, $00, $00
		db $00, $00, $00, $00, $00, $00, $00, $F1,      $00, $00, $00, $00, $00, $00

                ; 13
		db $00, $00, $00, $00, $00, $00, $00, $81,      $75, $74, $71, $70, $75, $74, $71, $70,      $75, $74, $71, $70, $75, $74, $71, $70,      $75, $74, $71, $70, $75, $74, $71, $70
		db $75, $74, $71, $70, $75, $74, $71, $70,      $75, $74, $71, $70, $75, $74, $71, $70,      $75, $74, $71, $70, $75, $74, $71, $70,      $00, $80, $00, $00, $00, $00, $00, $00
		db $00, $00, $00, $00, $00, $00, $00, $F1,      $00, $00, $00, $00, $00, $00
		
                ; 14
		db $00, $00, $00, $00, $00, $00, $00, $81,      $77, $76, $73, $72, $77, $76, $73, $72,      $77, $76, $73, $72, $77, $76, $73, $72,      $77, $76, $73, $72, $77, $76, $73, $72
		db $77, $76, $73, $72, $77, $76, $73, $72,      $77, $76, $73, $72, $77, $76, $73, $72,      $77, $76, $73, $72, $77, $76, $73, $72,      $00, $80, $00, $00, $00, $00, $00, $00
		db $00, $00, $00, $00, $00, $00, $00, $F1,      $00, $00, $00, $00, $00, $00
		
                ; 15
		db $00, $00, $00, $00, $00, $00, $00, $81,      $71, $70, $75, $74, $71, $70, $75, $74,      $71, $70, $75, $74, $71, $70, $75, $74,      $71, $70, $75, $74, $71, $70, $75, $74
		db $71, $70, $75, $74, $71, $70, $75, $74,      $71, $70, $75, $74, $71, $70, $75, $74,      $71, $70, $75, $74, $71, $70, $75, $74,      $00, $80, $00, $00, $00, $00, $00, $00
		db $00, $00, $00, $00, $00, $00, $00, $F1,      $00, $00, $00, $00, $00, $00
		
                ; 16
		db $00, $00, $00, $00, $00, $00, $00, $81,      $73, $72, $77, $76, $73, $72, $77, $76,      $73, $72, $77, $76, $73, $72, $77, $76,      $73, $72, $77, $76, $73, $72, $77, $76
		db $73, $72, $77, $76, $73, $72, $77, $76,      $73, $72, $77, $76, $73, $72, $77, $76,      $73, $72, $77, $76, $73, $72, $77, $76,      $00, $80, $00, $00, $00, $00, $00, $00
		db $00, $00, $00, $00, $00, $00, $00, $F1,      $00, $00, $00, $00, $00, $00

                ; 17
		db $00, $00, $00, $00, $00, $00, $00, $81,      $75, $74, $71, $70, $75, $74, $71, $70,      $75, $74, $71, $70, $75, $74, $71, $70,      $75, $74, $71, $70, $75, $74, $71, $70
		db $75, $74, $71, $70, $75, $74, $71, $70,      $75, $74, $71, $70, $75, $74, $71, $70,      $75, $74, $71, $70, $75, $74, $71, $70,      $00, $80, $00, $00, $00, $00, $00, $00
		db $00, $00, $00, $00, $00, $00, $00, $F1,      $00, $00, $00, $00, $00, $00
		
                ; 18
		db $00, $00, $00, $00, $00, $00, $00, $81,      $77, $76, $73, $72, $77, $76, $73, $72,      $77, $76, $73, $72, $77, $76, $73, $72,      $77, $76, $73, $72, $77, $76, $73, $72
		db $77, $76, $73, $72, $77, $76, $73, $72,      $77, $76, $73, $72, $77, $76, $73, $72,      $77, $76, $73, $72, $77, $76, $73, $72,      $00, $80, $00, $00, $00, $00, $00, $00
		db $00, $00, $00, $00, $00, $00, $00, $F1,      $00, $00, $00, $00, $00, $00
		
                ; 19
		db $00, $00, $00, $00, $00, $00, $00, $81,      $71, $70, $75, $74, $71, $70, $75, $74,      $71, $70, $75, $74, $71, $70, $75, $74,      $71, $70, $75, $74, $71, $70, $75, $74
		db $71, $70, $75, $74, $71, $70, $75, $74,      $71, $70, $75, $74, $71, $70, $75, $74,      $71, $70, $75, $74, $71, $70, $75, $74,      $00, $80, $00, $00, $00, $00, $00, $00
		db $00, $00, $00, $00, $00, $00, $00, $F1,      $00, $00, $00, $00, $00, $00
		
                ; 20
		db $00, $00, $00, $00, $00, $00, $00, $81,      $73, $72, $77, $76, $73, $72, $77, $76,      $73, $72, $77, $76, $73, $72, $77, $76,      $73, $72, $77, $76, $73, $72, $77, $76
		db $73, $72, $77, $76, $73, $72, $77, $76,      $73, $72, $77, $76, $73, $72, $77, $76,      $73, $72, $77, $76, $73, $72, $77, $76,      $00, $80, $00, $00, $00, $00, $00, $00
		db $00, $00, $00, $00, $00, $00, $00, $F1,      $00, $00, $00, $00, $00, $00

                ; 21
		db $00, $00, $00, $00, $00, $00, $00, $81,      $75, $74, $71, $70, $75, $74, $71, $70,      $75, $74, $71, $70, $75, $74, $71, $70,      $75, $74, $71, $70, $75, $74, $71, $70
		db $75, $74, $71, $70, $75, $74, $71, $70,      $75, $74, $71, $70, $75, $74, $71, $70,      $75, $74, $71, $70, $75, $74, $71, $70,      $00, $80, $00, $00, $00, $00, $00, $00
		db $00, $00, $00, $00, $00, $00, $00, $F1,      $00, $00, $00, $00, $00, $00
		
                ; 22
		db $00, $00, $00, $00, $00, $00, $00, $81,      $77, $76, $73, $72, $77, $76, $73, $72,      $77, $76, $73, $72, $77, $76, $73, $72,      $77, $76, $73, $72, $77, $76, $73, $72
		db $77, $76, $73, $72, $77, $76, $73, $72,      $77, $76, $73, $72, $77, $76, $73, $72,      $77, $76, $73, $72, $77, $76, $73, $72,      $00, $80, $00, $00, $00, $00, $00, $00
		db $00, $00, $00, $00, $00, $00, $00, $F1,      $00, $00, $00, $00, $00, $00
		
                ; 23
		db $00, $00, $00, $00, $00, $00, $00, $81,      $71, $70, $75, $74, $71, $70, $75, $74,      $71, $70, $75, $74, $71, $70, $75, $74,      $71, $70, $75, $74, $71, $70, $75, $74
		db $71, $70, $75, $74, $71, $70, $75, $74,      $71, $70, $75, $74, $71, $70, $75, $74,      $71, $70, $75, $74, $71, $70, $75, $74,      $00, $80, $00, $00, $00, $00, $00, $00
		db $00, $00, $00, $00, $00, $00, $00, $F1,      $00, $00, $00, $00, $00, $00
		
                ; 24
		db $00, $00, $00, $00, $00, $00, $00, $81,      $73, $72, $77, $76, $73, $72, $77, $76,      $73, $72, $77, $76, $73, $72, $77, $76,      $73, $72, $77, $76, $73, $72, $77, $76
		db $73, $72, $77, $76, $73, $72, $77, $76,      $73, $72, $77, $76, $73, $72, $77, $76,      $73, $72, $77, $76, $73, $72, $77, $76,      $00, $80, $00, $00, $00, $00, $00, $00
		db $00, $00, $00, $00, $00, $00, $00, $F1,      $00, $00, $00, $00, $00, $00

                ; 25
		db $00, $00, $00, $00, $00, $00, $00, $81,      $75, $74, $71, $70, $75, $74, $71, $70,      $75, $74, $71, $70, $75, $74, $71, $70,      $75, $74, $71, $70, $75, $74, $71, $70
		db $75, $74, $71, $70, $75, $74, $71, $70,      $75, $74, $71, $70, $75, $74, $71, $70,      $75, $74, $71, $70, $75, $74, $71, $70,      $00, $80, $00, $00, $00, $00, $00, $00
		db $00, $00, $00, $00, $00, $00, $00, $F1,      $00, $00, $00, $00, $00, $00
		
                ; 26
		db $00, $00, $00, $00, $00, $00, $00, $81,      $77, $76, $73, $72, $77, $76, $73, $72,      $77, $76, $73, $72, $77, $76, $73, $72,      $77, $76, $73, $72, $77, $76, $73, $72
		db $77, $76, $73, $72, $77, $76, $73, $72,      $77, $76, $73, $72, $77, $76, $73, $72,      $77, $76, $73, $72, $77, $76, $73, $72,      $00, $80, $00, $00, $00, $00, $00, $00
		db $00, $00, $00, $00, $00, $00, $00, $F1,      $00, $00, $00, $00, $00, $00
		
                ; 27
		db $00, $00, $00, $00, $00, $00, $00, $81,      $71, $70, $75, $74, $71, $70, $75, $74,      $71, $70, $75, $74, $71, $70, $75, $74,      $71, $70, $75, $74, $71, $70, $75, $74
		db $71, $70, $75, $74, $71, $70, $75, $74,      $71, $70, $75, $74, $71, $70, $75, $74,      $71, $70, $75, $74, $71, $70, $75, $74,      $00, $80, $00, $00, $00, $00, $00, $00
		db $00, $00, $00, $00, $00, $00, $00, $F1,      $00, $00, $00, $00, $00, $00
		
                ; 28
		db $00, $00, $00, $00, $00, $00, $00, $81,      $73, $72, $77, $76, $73, $72, $77, $76,      $73, $72, $77, $76, $73, $72, $77, $76,      $73, $72, $77, $76, $73, $72, $77, $76
		db $73, $72, $77, $76, $73, $72, $77, $76,      $73, $72, $77, $76, $73, $72, $77, $76,      $73, $72, $77, $76, $73, $72, $77, $76,      $00, $80, $00, $00, $00, $00, $00, $00
		db $00, $00, $00, $00, $00, $00, $00, $F1,      $00, $00, $00, $00, $00, $00

                ; 29
		db $00, $00, $00, $00, $00, $00, $00, $00,      $00, $00, $00, $00, $00, $00, $00, $00,      $00, $00, $00, $00, $00, $00, $00, $00,      $00, $00, $00, $00, $00, $00, $00, $00
		db $00, $00, $00, $00, $00, $00, $00, $00,      $00, $00, $00, $00, $00, $00, $00, $00,      $00, $00, $00, $00, $00, $00, $00, $00,      $00, $00, $00, $00, $00, $00, $00, $00
		db $00, $00, $00, $00, $00, $00, $00, $F1,      $00, $00, $00, $00, $00, $00

                ; 30
		db $00, $00, $00, $00, $00, $00, $00, $00,      $00, $00, $00, $00, $00, $00, $00, $00,      $00, $00, $00, $00, $00, $00, $00, $00,      $00, $00, $00, $00, $00, $00, $00, $00
		db $00, $00, $00, $00, $00, $00, $00, $00,      $00, $00, $00, $00, $00, $00, $00, $00,      $00, $00, $00, $00, $00, $00, $00, $00,      $00, $00, $00, $00, $00, $00, $00, $00
		db $00, $00, $00, $00, $00, $00, $00, $F1,      $00, $00, $00, $00, $00, $00

                ; 31
		db $00, $00, $00, $00, $00, $00, $00, $89,      $00, $00, $00, $00, $00, $00, $00, $00,      $00, $00, $00, 'D', 'E', 'M', 'O', $00,      'B', 'Y', $00, 'D', 'M', 'I', 'T', 'R'
		db 'Y', $00, 'I', 'V', 'A', 'N', 'O', 'V',      $00, '2', '0', '2', '5', $00, $00, $00,      $00, $00, $00, $00, $00, $00, $00, $00,      $80, $00, $00, $00, $00, $00, $00, $00
		db $00, $00, $00, $00, $00, $00, $00, $F1,      $00, $00, $00, $00, $00, $00

                ; 32
		db $00, $00, $00, $00, $00, $00, $00, $00,      $00, $00, $00, $00, $00, $00, $00, $00,      $00, $00, $00, $00, $00, $00, $00, $00,      $00, $00, $00, $00, $00, $00, $00, $00
		db $00, $00, $00, $00, $00, $00, $00, $00,      $00, $00, $00, $00, $00, $00, $00, $00,      $00, $00, $00, $00, $00, $00, $00, $00,      $00, $00, $00, $00, $00, $00, $00, $00
		db $00, $00, $00, $00, $00, $00, $00, $F1,      $00, $00, $00, $00, $00, $00


                ; Подвал
		db $00, $00, $00, $00, $00, $00, $00, $00,      $00, $00, $00, $00, $00, $00, $00, $00,      $00, $00, $00, $00, $00, $00, $00, $00,      $00, $00, $00, $00, $00, $00, $00, $00
		db $00, $00, $00, $00, $00, $00, $00, $00,      $00, $00, $00, $00, $00, $00, $00, $00,      $00, $00, $00, $00, $00, $00, $00, $00,      $00, $00, $00, $00, $00, $00, $00, $00
		db $00, $00, $00, $00, $00, $00, $00, $F1,      $00, $00, $00, $00, $00, $00
		
		db $00, $00, $00, $00, $00, $00, $00, $00,      $00, $00, $00, $00, $00, $00, $00, $00,      $00, $00, $00, $00, $00, $00, $00, $00,      $00, $00, $00, $00, $00, $00, $00, $00
		db $00, $00, $00, $00, $00, $00, $00, $00,      $00, $00, $00, $00, $00, $00, $00, $00,      $00, $00, $00, $00, $00, $00, $00, $00,      $00, $00, $00, $00, $00, $00, $00, $00
		db $00, $00, $00, $00, $00, $00, $00, $F1,      $00, $00, $00, $00, $00, $00
		
		db $00, $00, $00, $00, $00, $00, $00, $00,      $00, $00, $00, $00, $00, $00, $00, $00,      $00, $00, $00, $00, $00, $00, $00, $00,      $00, $00, $00, $00, $00, $00, $00, $00
		db $00, $00, $00, $00, $00, $00, $00, $00,      $00, $00, $00, $00, $00, $00, $00, $00,      $00, $00, $00, $00, $00, $00, $00, $00,      $00, $00, $00, $00, $00, $00, $00, $00
		db $00, $00, $00, $00, $00, $00, $00, $F1,      $00, $00, $00, $00, $00, $00

		db $00, $00, $00, $00, $00, $00, $00, $00,      $00, $00, $00, $00, $00, $00, $00, $00,      $00, $00, $00, $00, $00, $00, $00, $00,      $00, $00, $00, $00, $00, $00, $00, $00
		db $00, $00, $00, $00, $00, $00, $00, $00,      $00, $00, $00, $00, $00, $00, $00, $00,      $00, $00, $00, $00, $00, $00, $00, $00,      $00, $00, $00, $00, $00, $00, $00, $00
		db $00, $00, $00, $00, $00, $00, $00, $F1,      $00, $00, $00, $00, $00, $00
		
		db $00, $00, $00, $00, $00, $00, $00, $00,      $00, $00, $00, $00, $00, $00, $00, $00,      $00, $00, $00, $00, $00, $00, $00, $00,      $00, $00, $00, $00, $00, $00, $00, $00
		db $00, $00, $00, $00, $00, $00, $00, $00,      $00, $00, $00, $00, $00, $00, $00, $00,      $00, $00, $00, $00, $00, $00, $00, $00,      $00, $00, $00, $00, $00, $00, $00, $00
		db $00, $00, $00, $00, $00, $00, $00, $F1,      $00, $00, $00, $00, $00, $00
		
		db $00, $00, $00, $00, $00, $00, $00, $00,      $00, $00, $00, $00, $00, $00, $00, $00,      $00, $00, $00, $00, $00, $00, $00, $00,      $00, $00, $00, $00, $00, $00, $00, $00
		db $00, $00, $00, $00, $00, $00, $00, $00,      $00, $00, $00, $00, $00, $00, $00, $00,      $00, $00, $00, $00, $00, $00, $00, $00,      $00, $00, $00, $00, $00, $00, $00, $00
		db $00, $00, $00, $00, $00, $00, $00, $F1,      $00, $00, $00, $00, $00, $00
		
		db $00, $00, $00, $00, $00, $00, $00, $00,      $00, $00, $00, $00, $00, $00, $00, $00,      $00, $00, $00, $00, $00, $00, $00, $00,      $00, $00, $00, $00, $00, $00, $00, $00
		db $00, $00, $00, $00, $00, $00, $00, $00,      $00, $00, $00, $00, $00, $00, $00, $00,      $00, $00, $00, $00, $00, $00, $00, $00,      $00, $00, $00, $00, $00, $00, $00, $00
		db $00, $00, $00, $00, $00, $00, $00, $F1,      $00, $00, $00, $00, $00, $00

		db $00, $00, $00, $00, $00, $00, $00, $00,      $00, $00, $00, $00, $00, $00, $00, $00,      $00, $00, $00, $00, $00, $00, $00, $00,      $00, $00, $00, $00, $00, $00, $00, $00
		db $00, $00, $00, $00, $00, $00, $00, $00,      $00, $00, $00, $00, $00, $00, $00, $00,      $00, $00, $00, $00, $00, $00, $00, $00,      $00, $00, $00, $00, $00, $00, $00, $00
		db $00, $00, $00, $00, $00, $00, $00, $F1,      $00, $00, $00, $00, $00, $00

		db $00, $00, $00, $00, $00, $00, $00, $00,      $00, $00, $00, $00, $00, $00, $00, $00,      $00, $00, $00, $00, $00, $00, $00, $00,      $00, $00, $00, $00, $00, $00, $00, $00
		db $00, $00, $00, $00, $00, $00, $00, $00,      $00, $00, $00, $00, $00, $00, $00, $00,      $00, $00, $00, $00, $00, $00, $00, $00,      $00, $00, $00, $00, $00, $00, $00, $00
		db $00, $00, $00, $00, $00, $00, $00, $F1,      $00, $00, $00, $00, $00, $00
		
		db $00, $00, $00, $00, $00, $00, $00, $00,      $00, $00, $00, $00, $00, $00, $00, $00,      $00, $00, $00, $00, $00, $00, $00, $00,      $00, $00, $00, $00, $00, $00, $00, $00
		db $00, $00, $00, $00, $00, $00, $00, $00,      $00, $00, $00, $00, $00, $00, $00, $00,      $00, $00, $00, $00, $00, $00, $00, $00,      $00, $00, $00, $00, $00, $00, $00, $00
		db $00, $00, $00, $00, $00, $00, $00, $F1,      $00, $00, $00, $00, $00, $00
		
		db $00, $00, $00, $00, $00, $00, $00, $00,      $00, $00, $00, $00, $00, $00, $00, $00,      $00, $00, $00, $00, $00, $00, $00, $00,      $00, $00, $00, $00, $00, $00, $00, $00
		db $00, $00, $00, $00, $00, $00, $00, $00,      $00, $00, $00, $00, $00, $00, $00, $00,      $00, $00, $00, $00, $00, $00, $00, $00,      $00, $00, $00, $00, $00, $00, $00, $00
		db $00, $00, $00, $00, $00, $00, $00, $F1,      $00, $00, $00, $00, $00, $00

		db $00, $00, $00, $00, $00, $00, $00, $00,      $00, $00, $00, $00, $00, $00, $00, $00,      $00, $00, $00, $00, $00, $00, $00, $00,      $00, $00, $00, $00, $00, $00, $00, $00
		db $00, $00, $00, $00, $00, $00, $00, $00,      $00, $00, $00, $00, $00, $00, $00, $00,      $00, $00, $00, $00, $00, $00, $00, $00,      $00, $00, $00, $00, $00, $00, $00, $00
		db $00, $00, $00, $00, $00, $00, $00, $F1,      $00, $00, $00, $00, $00, $00
		
		db $00, $00, $00, $00, $00, $00, $00, $00,      $00, $00, $00, $00, $00, $00, $00, $00,      $00, $00, $00, $00, $00, $00, $00, $00,      $00, $00, $00, $00, $00, $00, $00, $00
		db $00, $00, $00, $00, $00, $00, $00, $00,      $00, $00, $00, $00, $00, $00, $00, $00,      $00, $00, $00, $00, $00, $00, $00, $00,      $00, $00, $00, $00, $00, $00, $00, $00
		db $00, $00, $00, $00, $00, $00, $00, $F1,      $00, $00, $00, $00, $00, $00
		
		db $00, $00, $00, $00, $00, $00, $00, $00,      $00, $00, $00, $00, $00, $00, $00, $00,      $00, $00, $00, $00, $00, $00, $00, $00,      $00, $00, $00, $00, $00, $00, $00, $00
		db $00, $00, $00, $00, $00, $00, $00, $00,      $00, $00, $00, $00, $00, $00, $00, $00,      $00, $00, $00, $00, $00, $00, $00, $00,      $00, $00, $00, $00, $00, $00, $00, $00
		db $00, $00, $00, $00, $00, $00, $00, $F1,      $00, $00, $00, $00, $00, $00
		
		db $00, $00, $00, $00, $00, $00, $00, $00,      $00, $00, $00, $00, $00, $00, $00, $00,      $00, $00, $00, $00, $00, $00, $00, $00,      $00, $00, $00, $00, $00, $00, $00, $00
		db $00, $00, $00, $00, $00, $00, $00, $00,      $00, $00, $00, $00, $00, $00, $00, $00,      $00, $00, $00, $00, $00, $00, $00, $00,      $00, $00, $00, $00, $00, $00, $00, $00
		db $00, $00, $00, $00, $00, $00, $00, $F1,      $00, $00, $00, $00, $00, $00

		db $00, $00, $00, $00, $00, $00, $00, $00,      $00, $00, $00, $00, $00, $00, $00, $00,      $00, $00, $00, $00, $00, $00, $00, $00,      $00, $00, $00, $00, $00, $00, $00, $00
		db $00, $00, $00, $00, $00, $00, $00, $00,      $00, $00, $00, $00, $00, $00, $00, $00,      $00, $00, $00, $00, $00, $00, $00, $00,      $00, $00, $00, $00, $00, $00, $00, $00
		db $00, $00, $00, $00, $00, $00, $00, $F3,      $00, $00, $00, $00, $00, $00

		db $00, $00, $00, $00, $00, $00, $00, $00,      $00, $00, $00, $00, $00, $00, $00, $00,      $00, $00, $00, $00, $00, $00, $00, $00,      $00, $00, $00, $00, $00, $00, $00, $00
		db $00, $00, $00, $00, $00, $00, $00, $00,      $00, $00, $00, $00, $00, $00, $00, $00,      $00, $00, $00, $00, $00, $00, $00, $00,      $00, $00, $00, $00, $00, $00, $00, $00
		db $00, $00, $00, $00, $00, $00, $00, $F1,      $00, $00, $00, $00, $00, $00
		
		db $00, $00, $00, $00, $00, $00, $00, $00,      $00, $00, $00, $00, $00, $00, $00, $00,      $00, $00, $00, $00, $00, $00, $00, $00,      $00, $00, $00, $00, $00, $00, $00, $00
		db $00, $00, $00, $00, $00, $00, $00, $00,      $00, $00, $00, $00, $00, $00, $00, $00,      $00, $00, $00, $00, $00, $00, $00, $00,      $00, $00, $00, $00, $00, $00, $00, $00
		db $00, $00, $00, $00, $00, $00, $00, $F1,      $00, $00, $00, $00, $00, $00
		
		db $00, $00, $00, $00, $00, $00, $00, $00,      $00, $00, $00, $00, $00, $00, $00, $00,      $00, $00, $00, $00, $00, $00, $00, $00,      $00, $00, $00, $00, $00, $00, $00, $00
		db $00, $00, $00, $00, $00, $00, $00, $00,      $00, $00, $00, $00, $00, $00, $00, $00,      $00, $00, $00, $00, $00, $00, $00, $00,      $00, $00, $00, $00, $00, $00, $00, $00
		db $00, $00, $00, $00, $00, $00, $00, $F1,      $00, $00, $00, $00, $00, $00

		db $00, $00, $00, $00, $00, $00, $00, $00,      $00, $00, $00, $00, $00, $00, $00, $00,      $00, $00, $00, $00, $00, $00, $00, $00,      $00, $00, $00, $00, $00, $00, $00, $00
		db $00, $00, $00, $00, $00, $00, $00, $00,      $00, $00, $00, $00, $00, $00, $00, $00,      $00, $00, $00, $00, $00, $00, $00, $00,      $00, $00, $00, $00, $00, $00, $00, $00
		db $00, $00, $00, $00, $00, $00, $00, $F1,      $00, $00, $00, $00, $00, $00
		
		db $00, $00, $00, $00, $00, $00, $00, $00,      $00, $00, $00, $00, $00, $00, $00, $00,      $00, $00, $00, $00, $00, $00, $00, $00,      $00, $00, $00, $00, $00, $00, $00, $00
		db $00, $00, $00, $00, $00, $00, $00, $00,      $00, $00, $00, $00, $00, $00, $00, $00,      $00, $00, $00, $00, $00, $00, $00, $00,      $00, $00, $00, $00, $00, $00, $00, $00
		db $00, $00, $00, $00, $00, $00, $00, $F1,      $00, $00, $00, $00, $00, $00
		
		db $00, $00, $00, $00, $00, $00, $00, $00,      $00, $00, $00, $00, $00, $00, $00, $00,      $00, $00, $00, $00, $00, $00, $00, $00,      $00, $00, $00, $00, $00, $00, $00, $00
		db $00, $00, $00, $00, $00, $00, $00, $00,      $00, $00, $00, $00, $00, $00, $00, $00,      $00, $00, $00, $00, $00, $00, $00, $00,      $00, $00, $00, $00, $00, $00, $00, $00
		db $00, $00, $00, $00, $00, $00, $00, $F1,      $00, $00, $00, $00, $00, $00
		
		db $00, $00, $00, $00, $00, $00, $00, $00,      $00, $00, $00, $00, $00, $00, $00, $00,      $00, $00, $00, $00, $00, $00, $00, $00,      $00, $00, $00, $00, $00, $00, $00, $00
		db $00, $00, $00, $00, $00, $00, $00, $00,      $00, $00, $00, $00, $00, $00, $00, $00,      $00, $00, $00, $00, $00, $00, $00, $00,      $00, $00, $00, $00, $00, $00, $00, $00
		db $00, $00, $00, $00, $00, $00, $00, $F1,      $00, $00, $00, $00, $00, $00

		db $00, $00, $00, $00, $00, $00, $00, $00,      $00, $00, $00, $00, $00, $00, $00, $00,      $00, $00, $00, $00, $00, $00, $00, $00,      $00, $00, $00, $00, $00, $00, $00, $00
		db $00, $00, $00, $00, $00, $00, $00, $00,      $00, $00, $00, $00, $00, $00, $00, $00,      $00, $00, $00, $00, $00, $00, $00, $00,      $00, $00, $00, $00, $00, $00, $00, $00
		db $00, $00, $00, $00, $00, $00, $00, $F1,      $00, $00, $00, $00, $00, $00

		db $00, $00, $00, $00, $00, $00, $00, $00,      $00, $00, $00, $00, $00, $00, $00, $00,      $00, $00, $00, $00, $00, $00, $00, $00,      $00, $00, $00, $00, $00, $00, $00, $00
		db $00, $00, $00, $00, $00, $00, $00, $00,      $00, $00, $00, $00, $00, $00, $00, $00,      $00, $00, $00, $00, $00, $00, $00, $00,      $00, $00, $00, $00, $00, $00, $00, $00
		db $00, $00, $00, $00, $00, $00, $00, $F1,      $00, $00, $00, $00, $00, $00
		
		db $00, $00, $00, $00, $00, $00, $00, $00,      $00, $00, $00, $00, $00, $00, $00, $00,      $00, $00, $00, $00, $00, $00, $00, $00,      $00, $00, $00, $00, $00, $00, $00, $00
		db $00, $00, $00, $00, $00, $00, $00, $00,      $00, $00, $00, $00, $00, $00, $00, $00,      $00, $00, $00, $00, $00, $00, $00, $00,      $00, $00, $00, $00, $00, $00, $00, $00
		db $00, $00, $00, $00, $00, $00, $00, $F1,      $00, $00, $00, $00, $00, $00
		
		db $00, $00, $00, $00, $00, $00, $00, $00,      $00, $00, $00, $00, $00, $00, $00, $00,      $00, $00, $00, $00, $00, $00, $00, $00,      $00, $00, $00, $00, $00, $00, $00, $00
		db $00, $00, $00, $00, $00, $00, $00, $00,      $00, $00, $00, $00, $00, $00, $00, $00,      $00, $00, $00, $00, $00, $00, $00, $00,      $00, $00, $00, $00, $00, $00, $00, $00
		db $00, $00, $00, $00, $00, $00, $00, $F1,      $00, $00, $00, $00, $00, $00

		db $00, $00, $00, $00, $00, $00, $00, $00,      $00, $00, $00, $00, $00, $00, $00, $00,      $00, $00, $00, $00, $00, $00, $00, $00,      $00, $00, $00, $00, $00, $00, $00, $00
		db $00, $00, $00, $00, $00, $00, $00, $00,      $00, $00, $00, $00, $00, $00, $00, $00,      $00, $00, $00, $00, $00, $00, $00, $00,      $00, $00, $00, $00, $00, $00, $00, $00
		db $00, $00, $00, $00, $00, $00, $00, $F1,      $00, $00, $00, $00, $00, $00
		
		db $00, $00, $00, $00, $00, $00, $00, $00,      $00, $00, $00, $00, $00, $00, $00, $00,      $00, $00, $00, $00, $00, $00, $00, $00,      $00, $00, $00, $00, $00, $00, $00, $00
		db $00, $00, $00, $00, $00, $00, $00, $00,      $00, $00, $00, $00, $00, $00, $00, $00,      $00, $00, $00, $00, $00, $00, $00, $00,      $00, $00, $00, $00, $00, $00, $00, $00
		db $00, $00, $00, $00, $00, $00, $00, $F1,      $00, $00, $00, $00, $00, $00
		
		db $00, $00, $00, $00, $00, $00, $00, $00,      $00, $00, $00, $00, $00, $00, $00, $00,      $00, $00, $00, $00, $00, $00, $00, $00,      $00, $00, $00, $00, $00, $00, $00, $00
		db $00, $00, $00, $00, $00, $00, $00, $00,      $00, $00, $00, $00, $00, $00, $00, $00,      $00, $00, $00, $00, $00, $00, $00, $00,      $00, $00, $00, $00, $00, $00, $00, $00
		db $00, $00, $00, $00, $00, $00, $00, $F1,      $00, $00, $00, $00, $00, $00
		
		db $00, $00, $00, $00, $00, $00, $00, $00,      $00, $00, $00, $00, $00, $00, $00, $00,      $00, $00, $00, $00, $00, $00, $00, $00,      $00, $00, $00, $00, $00, $00, $00, $00
		db $00, $00, $00, $00, $00, $00, $00, $00,      $00, $00, $00, $00, $00, $00, $00, $00,      $00, $00, $00, $00, $00, $00, $00, $00,      $00, $00, $00, $00, $00, $00, $00, $00
		db $00, $00, $00, $00, $00, $00, $00, $F1,      $00, $00, $00, $00, $00, $00

		db $00, $00, $00, $00, $00, $00, $00, $00,      $00, $00, $00, $00, $00, $00, $00, $00,      $00, $00, $00, $00, $00, $00, $00, $00,      $00, $00, $00, $00, $00, $00, $00, $00
		db $00, $00, $00, $00, $00, $00, $00, $00,      $00, $00, $00, $00, $00, $00, $00, $00,      $00, $00, $00, $00, $00, $00, $00, $00,      $00, $00, $00, $00, $00, $00, $00, $00
		db $00, $00, $00, $00, $00, $00, $00, $F1,      $00, $00, $00, $00, $00, $00


GREETINGS:      db "~elowek u klawiatury? OLD'y tut? prosto ho~u pokazatx wozmovnosti tajlowoj grafiki, oni wpe~atlq`t! priwetiki: wedu}ij specialist, wiktor pyhonin, ruslan alikberow, `rij lesnyh, wladimir, barsik... i wsem retrofrikam! ne slu{aj, ~to {ep~et belyj {um!"
                db $00, $17, $17, $17, $17, $00