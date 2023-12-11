SECTION code_user









; HL-����, DE-�������� ������ ��� ��������, BC-����� / HL-������� ���������, A-��� ������
PUBLIC _FS_Find
 extern _path
 extern _max_files
 extern _adr
 extern _bytes_loaded
 extern _err_code
_FS_Find:
     ; ��� �������
     MVI	A, 3
     CALL	StartCommand

     ; ����
     CALL	SendString

     ; �������� ������
     XCHG
     CALL	SendWord

     ; ������������� � ����� ������
     CALL	SwitchRecv

     ; �������
     LXI	H, 0

CmdFindLoop:
     ; ���� ���� �� ���������
     CALL	WaitForReady
     CPI	43h; ERR_OK
     JZ		Ret0
     CPI	45h; ERR_OK_ENTRY
     JNZ	EndCommand

     ; ����� ����� ������
     LXI	D, 20	; ����� �����
     CALL	RecvBlock

     ; ����������� ������� ������
     INX	H

     ; ����
     JMP	CmdFindLoop

;----------------------------------------------------------------------------
; D-�����, HL-��� ����� / A-��� ������
PUBLIC _FS_Open
 extern _fs_answer 
 extern _mode
 extern _filename
 extern _err_code
_FS_Open:
     ; ��� �������
     MVI	A, 4
     CALL	StartCommand
     LDA _mode;
     ; �����
     ;MOV	A, D
     CALL	Send

     LHLD _filename;        ��� �����
     CALL	SendString

     ; ���� ���� �� ���������
     CALL	SwitchRecvAndWait
     CPI	43h; ERR_OK
     JZ		Ret0
     JMP	EndCommand
     
;----------------------------------------------------------------------------
; B-�����, DE:HL-������� / A-��� ������, DE:HL-�������
PUBLIC _FS_Seek
 extern _mode
 extern _lpointer
 extern _hpointer
 extern _err_code
_FS_Seek:

     ; ��� �������
     MVI 	A, 5
     CALL	StartCommand
     
     LDA _mode
     ; �����     
     ;MOV	A, B
     CALL	Send
     lhld _lpointer
     ; �������     
     CALL	SendWord
     lhld _hpointer
     CALL	SendWord

     ; ���� ���� �� ���������. �� ������ �������� ����� ERR_OK
     CALL	SwitchRecvAndWait
     CPI	43h; ERR_OK
     JNZ	EndCommand

     ; ����� �����
     CALL	RecvWord
     XCHG
     CALL	RecvWord

     ; ���������
     JMP	Ret0
     
;----------------------------------------------------------------------------
; HL-������, DE-����� / HL-������� ���������, A-��� ������
PUBLIC _FS_Read
 extern _size
 extern _adr
 extern _bytes_loaded
 extern _err_code
_FS_Read:
     ; ��� �������
     MVI	A, 6
     CALL	StartCommand
     LHLD _adr ; �������� � HL �����, ���� ���������� ������
     ; ����� � BC
     MOV	B, H
     MOV	C, L
     LHLD _size
     ; ������ �����
     CALL	SendWord        ; HL-������

     ; ������������� � ����� ������
     CALL	SwitchRecv

     ; ����� �����. �� ����� ����� BC, �������� ����� � HL
     JMP	RecvBuf

;----------------------------------------------------------------------------
; HL-������, DE-����� / A-��� ������
PUBLIC _FS_Write
 extern _size
 extern _adr
 extern _err_code
_FS_Write:
     ; ��� �������
     MVI	A, 7
     CALL	StartCommand
     LHLD _size
     ; ������ �����
     CALL	SendWord        ; HL-������
     LHLD _adr ;
     ; ������ ����� � HL
     XCHG

CmdWriteFile2:
     ; ��������� ���������� �������
     CALL	SwitchRecvAndWait
     CPI  	43h; ERR_OK
     JZ  	Ret0
     CPI  	46h; ERR_OK_WRITE
     JNZ	EndCommand

     ; ������ �����, ������� ����� ������� �� � DE
     CALL	RecvWord

     ; ������������� � ����� ��������    
     CALL	SwitchSend

     ; �������� �����. ����� BC ����� DE. (����� �������������� ����)
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
; HL-��, DE-� / A-��� ������
PUBLIC _FS_Move
 extern _from
 extern _to
 extern _err_code
_FS_Move:     
     ; ��� �������
     MVI	A, 8
     CALL	StartCommand

     ; ��� �����
     CALL	SendString

     ; ���� ���� �� ���������
     CALL	SwitchRecvAndWait
     CPI	46h; ERR_OK_WRITE
     JNZ	EndCommand

     ; ������������� � ����� ��������
     CALL	SwitchSend

     ; ��� �����
     XCHG
     CALL	SendString

WaitEnd:
     ; ���� ���� �� ���������
     CALL	SwitchRecvAndWait
     CPI	43h; ERR_OK
     JZ		Ret0
     JMP	EndCommand



;----------------------------------------------------------------------------
; ��� ���� ��������� �������. 
;----------------------------------------------------------------------------

;----------------------------------------------------------------------------
; ������ ����� �������. 
; A - ��� �������

StartCommand:
     ; ������ ������ ���������� ������������� � ������������
     ; ����������� 256 �������, � ������ �� ������� ������������ 256+ ����
     ; �� ���� ��� ������������ ���-�� ������, ������� ����� �������� ����������
     PUSH	B
     PUSH	H
     PUSH	PSW
     MVI	C, 0

StartCommand1:
     ; ����� �������� (����������� ����) � �������������� HL
     CALL       SwitchRecv

     ; ������ ����� ������� (��� ���� ������)
     LXI	H, 0ee00H+1
     MVI        M, 0
     MVI        M, 44h
     MVI        M, 40h
     MVI        M, 0h

     ; ���� ���� �������������, �� ���������� ������� ERR_START
     CALL	Recv
     CPI	40h; ERR_START
     JZ		StartCommand2

     ; �����. � �� ���� ���������� 256 ���� (� ����� ����� 
     ; ��������� 64 �� ������, ������������ ������ ������)
     PUSH	B
     MVI	C, 0
StartCommand3:
     CALL	Recv
     DCR	C
     JNZ	StartCommand3
     POP	B
        
     ; �������
     DCR	C
     JNZ	StartCommand1    

     ; ��� ������
     MVI	A, 40h; ERR_START
StartCommandErr2:
     POP	B ; ������� �������� PSW
     POP	H ; ������� �������� H
     POP	B ; ������� �������� B     
     POP	B ; ������� ����� �������.
     RET

;----------------------------------------------------------------------------
; ������������� � ������������ ����. ���������� ������ �������� ERR_OK_NEXT

StartCommand2:
     ; �����         	
     CALL	WaitForReady
     CPI	42h; ERR_OK_NEXT
     JNZ	StartCommandErr2

     ; ������������� � ����� ��������
     CALL       SwitchSend

     POP        PSW
     POP        H
     POP        B

     ; �������� ��� �������
     JMP        Send

;----------------------------------------------------------------------------
; ������������� � ����� ��������

SwitchSend:
     CALL	Recv
SwitchSend0:
     MVI	A, 80h; SEND_MODE
     STA	0ee00H+3
     RET

;----------------------------------------------------------------------------
; �������� ��������� ������� 
; � �������������� ����, ��� �� �� �������� ����

Ret0:
     XRA	A

;----------------------------------------------------------------------------
; ��������� ������� � ������� � A 
; � �������������� ����, ��� �� �� �������� ����

EndCommand:
     PUSH	PSW
     CALL	Recv
     POP	PSW
     STA _fs_answer
     RET

;----------------------------------------------------------------------------
; ������� ����� � DE 
; ������ A.

RecvWord:
    CALL Recv
    MOV  E, A
    CALL Recv
    MOV  D, A
    RET
    
;----------------------------------------------------------------------------
; ��������� ����� �� HL 
; ������ A.

SendWord:
    MOV		A, L
    CALL	Send
    MOV		A, H
    JMP		Send
    
;----------------------------------------------------------------------------
; �������� ������
; HL - ������
; ������ A.

SendString:
     XRA	A
     ORA	M
     JZ		Send
     CALL	Send
     INX	H
     JMP	SendString
     
;----------------------------------------------------------------------------
; ������������� � ����� ������

SwitchRecv:
     MVI	A, 90h; RECV_MODE
     STA	0ee00H+3
     RET

;----------------------------------------------------------------------------
; ������������� � ����� �������� � �������� ���������� ��.

SwitchRecvAndWait:
     CALL SwitchRecv

;----------------------------------------------------------------------------
; �������� ���������� ��.

WaitForReady:
     CALL	Recv
     CPI	41h; ERR_WAIT
     JZ		WaitForReady
     RET

;----------------------------------------------------------------------------
; ������� DE ���� �� ������ BC
; ������ A

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
; �������� ������ �� ������ BC. 
; �� ������ HL ������� ���������
; ������ A
; ���� ��������� ��� ������, �� ������ Z=1

RecvBuf:
     LXI	H, 0
RecvBuf0:   
     ; ���������
     CALL	WaitForReady
     CPI	44h; ERR_OK_READ
     JZ		Ret0		; �� ������ Z (��� ������)
     SUI        4Fh; ERR_OK_BLOCK
     JNZ	EndCommand	; �� ������ NZ (������)

     ; ������ ����������� ������ � DE
     CALL	RecvWord

     ; � HL ����� ������
     DAD D

     ; ������� DE ���� �� ������ BC
     CALL	RecvBlock

     JMP	RecvBuf0

;----------------------------------------------------------------------------
; ����������� ������ � ������������ 256 �������� (������� ����������)

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
     MVI  M, 0 ; ����������
     RET

;----------------------------------------------------------------------------
; ��������� ���� �� A.

Send:
     STA	0ee00H

;----------------------------------------------------------------------------
; ������� ���� � �

Recv:
     MVI	A, 20h
     STA	0ee00H+1
     XRA	A
     STA	0ee00H+1
     LDA	0ee00H
     RET

;----------------------------------------------------------------------------

