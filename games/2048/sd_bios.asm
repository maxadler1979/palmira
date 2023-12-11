SECTION code_user









; HL-путь, DE-максимум файлов для загрузки, BC-адрес / HL-сколько загрузили, A-код ошибки
PUBLIC _FS_Find
 extern _path
 extern _max_files
 extern _adr
 extern _bytes_loaded
 extern _err_code
_FS_Find:
     ; Код команды
     MVI	A, 3
     CALL	StartCommand

     ; Путь
     CALL	SendString

     ; Максимум файлов
     XCHG
     CALL	SendWord

     ; Переключаемся в режим приема
     CALL	SwitchRecv

     ; Счетчик
     LXI	H, 0

CmdFindLoop:
     ; Ждем пока МК прочитает
     CALL	WaitForReady
     CPI	43h; ERR_OK
     JZ		Ret0
     CPI	45h; ERR_OK_ENTRY
     JNZ	EndCommand

     ; Прием блока данных
     LXI	D, 20	; Длина блока
     CALL	RecvBlock

     ; Увеличиваем счетчик файлов
     INX	H

     ; Цикл
     JMP	CmdFindLoop

;----------------------------------------------------------------------------
; D-режим, HL-имя файла / A-код ошибки
PUBLIC _FS_Open
 extern _fs_answer 
 extern _mode
 extern _filename
 extern _err_code
_FS_Open:
     ; Код команды
     MVI	A, 4
     CALL	StartCommand
     LDA _mode;
     ; Режим
     ;MOV	A, D
     CALL	Send

     LHLD _filename;        Имя файла
     CALL	SendString

     ; Ждем пока МК сообразит
     CALL	SwitchRecvAndWait
     CPI	43h; ERR_OK
     JZ		Ret0
     JMP	EndCommand
     
;----------------------------------------------------------------------------
; B-режим, DE:HL-позиция / A-код ошибки, DE:HL-позиция
PUBLIC _FS_Seek
 extern _mode
 extern _lpointer
 extern _hpointer
 extern _err_code
_FS_Seek:

     ; Код команды
     MVI 	A, 5
     CALL	StartCommand
     
     LDA _mode
     ; Режим     
     ;MOV	A, B
     CALL	Send
     lhld _lpointer
     ; Позиция     
     CALL	SendWord
     lhld _hpointer
     CALL	SendWord

     ; Ждем пока МК сообразит. МК должен ответить кодом ERR_OK
     CALL	SwitchRecvAndWait
     CPI	43h; ERR_OK
     JNZ	EndCommand

     ; Длина файла
     CALL	RecvWord
     XCHG
     CALL	RecvWord

     ; Результат
     JMP	Ret0
     
;----------------------------------------------------------------------------
; HL-размер, DE-адрес / HL-сколько загрузили, A-код ошибки
PUBLIC _FS_Read
 extern _size
 extern _adr
 extern _bytes_loaded
 extern _err_code
_FS_Read:
     ; Код команды
     MVI	A, 6
     CALL	StartCommand
     LHLD _adr ; поместим в HL адрес, куда складывать данные
     ; Адрес в BC
     MOV	B, H
     MOV	C, L
     LHLD _size
     ; Размер блока
     CALL	SendWord        ; HL-размер

     ; Переключаемся в режим приема
     CALL	SwitchRecv

     ; Прием блока. На входе адрес BC, принятая длина в HL
     JMP	RecvBuf

;----------------------------------------------------------------------------
; HL-размер, DE-адрес / A-код ошибки
PUBLIC _FS_Write
 extern _size
 extern _adr
 extern _err_code
_FS_Write:
     ; Код команды
     MVI	A, 7
     CALL	StartCommand
     LHLD _size
     ; Размер блока
     CALL	SendWord        ; HL-размер
     LHLD _adr ;
     ; Теперь адрес в HL
     XCHG

CmdWriteFile2:
     ; Результат выполнения команды
     CALL	SwitchRecvAndWait
     CPI  	43h; ERR_OK
     JZ  	Ret0
     CPI  	46h; ERR_OK_WRITE
     JNZ	EndCommand

     ; Размер блока, который может принять МК в DE
     CALL	RecvWord

     ; Переключаемся в режим передачи    
     CALL	SwitchSend

     ; Передача блока. Адрес BC длина DE. (Можно оптимизировать цикл)
CmdWriteFile1:
     MOV	A, M
     INX	H
     CALL	Send
     DCX	D
     MOV	A, D
     ORA	E
     JNZ 	CmdWriteFile1

     JMP	CmdWriteFile2

;----------------------------------------------------------------------------
; HL-из, DE-в / A-код ошибки
PUBLIC _FS_Move
 extern _from
 extern _to
 extern _err_code
_FS_Move:     
     ; Код команды
     MVI	A, 8
     CALL	StartCommand

     ; Имя файла
     CALL	SendString

     ; Ждем пока МК сообразит
     CALL	SwitchRecvAndWait
     CPI	46h; ERR_OK_WRITE
     JNZ	EndCommand

     ; Переключаемся в режим передачи
     CALL	SwitchSend

     ; Имя файла
     XCHG
     CALL	SendString

WaitEnd:
     ; Ждем пока МК сообразит
     CALL	SwitchRecvAndWait
     CPI	43h; ERR_OK
     JZ		Ret0
     JMP	EndCommand



;----------------------------------------------------------------------------
; Это была последняя команда. 
;----------------------------------------------------------------------------

;----------------------------------------------------------------------------
; Начало любой команды. 
; A - код команды

StartCommand:
     ; Первым этапом происходит синхронизация с контроллером
     ; Принимается 256 попыток, в каждой из которых пропускается 256+ байт
     ; То есть это максимальное кол-во данных, которое может передать контроллер
     PUSH	B
     PUSH	H
     PUSH	PSW
     MVI	C, 0

StartCommand1:
     ; Режим передачи (освобождаем шину) и инициализируем HL
     CALL       SwitchRecv

     ; Начало любой команды (это шина адреса)
     LXI	H, 0ee00H+1
     MVI        M, 0
     MVI        M, 44h
     MVI        M, 40h
     MVI        M, 0h

     ; Если есть синхронизация, то контроллер ответит ERR_START
     CALL	Recv
     CPI	40h; ERR_START
     JZ		StartCommand2

     ; Пауза. И за одно пропускаем 256 байт (в сумме будет 
     ; пропущено 64 Кб данных, максимальный размер пакета)
     PUSH	B
     MVI	C, 0
StartCommand3:
     CALL	Recv
     DCR	C
     JNZ	StartCommand3
     POP	B
        
     ; Попытки
     DCR	C
     JNZ	StartCommand1    

     ; Код ошибки
     MVI	A, 40h; ERR_START
StartCommandErr2:
     POP	B ; Прошлое значение PSW
     POP	H ; Прошлое значение H
     POP	B ; Прошлое значение B     
     POP	B ; Выходим через функцию.
     RET

;----------------------------------------------------------------------------
; Синхронизация с контроллером есть. Контроллер должен ответить ERR_OK_NEXT

StartCommand2:
     ; Ответ         	
     CALL	WaitForReady
     CPI	42h; ERR_OK_NEXT
     JNZ	StartCommandErr2

     ; Переключаемся в режим передачи
     CALL       SwitchSend

     POP        PSW
     POP        H
     POP        B

     ; Передаем код команды
     JMP        Send

;----------------------------------------------------------------------------
; Переключиться в режим передачи

SwitchSend:
     CALL	Recv
SwitchSend0:
     MVI	A, 80h; SEND_MODE
     STA	0ee00H+3
     RET

;----------------------------------------------------------------------------
; Успешное окончание команды 
; и дополнительный такт, что бы МК отпустил шину

Ret0:
     XRA	A

;----------------------------------------------------------------------------
; Окончание команды с ошибкой в A 
; и дополнительный такт, что бы МК отпустил шину

EndCommand:
     PUSH	PSW
     CALL	Recv
     POP	PSW
     STA _fs_answer
     RET

;----------------------------------------------------------------------------
; Принять слово в DE 
; Портим A.

RecvWord:
    CALL Recv
    MOV  E, A
    CALL Recv
    MOV  D, A
    RET
    
;----------------------------------------------------------------------------
; Отправить слово из HL 
; Портим A.

SendWord:
    MOV		A, L
    CALL	Send
    MOV		A, H
    JMP		Send
    
;----------------------------------------------------------------------------
; Отправка строки
; HL - строка
; Портим A.

SendString:
     XRA	A
     ORA	M
     JZ		Send
     CALL	Send
     INX	H
     JMP	SendString
     
;----------------------------------------------------------------------------
; Переключиться в режим приема

SwitchRecv:
     MVI	A, 90h; RECV_MODE
     STA	0ee00H+3
     RET

;----------------------------------------------------------------------------
; Переключиться в режим передами и ожидание готовности МК.

SwitchRecvAndWait:
     CALL SwitchRecv

;----------------------------------------------------------------------------
; Ожидание готовности МК.

WaitForReady:
     CALL	Recv
     CPI	41h; ERR_WAIT
     JZ		WaitForReady
     RET

;----------------------------------------------------------------------------
; Принять DE байт по адресу BC
; Портим A

RecvBlock:
     PUSH	H
     LXI 	H, 0ee00H+1
     INR 	D
     XRA 	A
     ORA 	E
     JZ 	RecvBlock2
RecvBlock1:
     MVI        M, 20h			; 7
     MVI        M, 0			; 7
     LDA	0ee00H		; 13
     STAX	B		        ; 7
     INX	B		        ; 5
     DCR	E		        ; 5
     JNZ	RecvBlock1		; 10 = 54
RecvBlock2:
     DCR	D
     JNZ	RecvBlock1
     POP	H
     RET

;----------------------------------------------------------------------------
; Загрузка данных по адресу BC. 
; На выходе HL сколько загрузили
; Портим A
; Если загружено без ошибок, на выходе Z=1

RecvBuf:
     LXI	H, 0
RecvBuf0:   
     ; Подождать
     CALL	WaitForReady
     CPI	44h; ERR_OK_READ
     JZ		Ret0		; на выходе Z (нет ошибки)
     SUI        4Fh; ERR_OK_BLOCK
     JNZ	EndCommand	; на выходе NZ (ошибка)

     ; Размер загруженных данных в DE
     CALL	RecvWord

     ; В HL общий размер
     DAD D

     ; Принять DE байт по адресу BC
     CALL	RecvBlock

     JMP	RecvBuf0

;----------------------------------------------------------------------------
; Скопироваьт строку с ограничением 256 символов (включая терминатор)

strcpy255:
     MVI  B, 255
strcpy255_1:
     LDAX D
     INX  D
     MOV  M, A
     INX  H
     ORA  A
     RZ
     DCR  B
     JNZ  strcpy255_1
     MVI  M, 0 ; Терминатор
     RET

;----------------------------------------------------------------------------
; Отправить байт из A.

Send:
     STA	0ee00H

;----------------------------------------------------------------------------
; Принять байт в А

Recv:
     MVI	A, 20h
     STA	0ee00H+1
     XRA	A
     STA	0ee00H+1
     LDA	0ee00H
     RET

;----------------------------------------------------------------------------

