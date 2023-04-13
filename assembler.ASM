DATA      SEGMENT
BUF       DB       1000 DUP(?)
STR1      DB       13,10,"Lucky Number: "  ,"$",13,10
STR2      DB       13,10,"Student Number: ","$",13,10
FNAME     DB       'mystu.txt',0
FCODE     DW       ?
SUM       DW       0
LEN       DB       9
ERR_OP    DB       'OPEN ERROR'   ,13,10,'$'
ERR_CL    DB       'CLOSE ERROR'  ,13,10,'$'
ERR_RD    DB       'READ ERROR'   ,13,10,'$'
ERR_WR    DB       'WRITE ERROR'  ,13,10,'$'
ERR_PO    DB       'POINTER ERROR',13,10,'$'
DATA      ENDS

CODE      SEGMENT
          ASSUME   CS:CODE,DS:DATA
START:    MOV      AX, DATA
          MOV      DS, AX
          CALL     COUNT_NUM
          CALL     GENER_NUM
          PUSH     AX
          LEA      DX, STR1
          MOV      AH, 9
          INT      21H
          POP      AX
          CALL     TRANS_NUM
          PUSH     AX
          LEA      DX, STR2
          MOV      AH,9
          INT      21H
          POP      AX
          CALL     PRINT_NUM
          MOV      AH, 4CH
          INT      21H

COUNT_NUM PROC     
          LEA      DX, FNAME                   ;设置ASCIZ串指针
          MOV      AH, 3DH                     ;打开文件
          MOV      AL, 0
          INT      21H
          JC       ERROP                       ;文件打开失败则跳转到ERROP显示出错信息
          MOV      FCODE, AX
RDLOOP:   MOV      AH, 3FH
          LEA      DX, BUF
          MOV      BX, FCODE
          MOV      CX, 9
          INT      21H
          JC       ERRRD                       ;文件读取失败则跳转到ERRRD显示出错信息
          CMP      AX, 0                       ;判断文件是否结束
          JZ       CLOSE                       ;若文件结束则跳转到CLOSE关闭文件
          INC      SUM
          JMP      RDLOOP
ERROP:    LEA      DX, ERR_OP                  
          MOV      AH, 9
          INT      21H
          MOV      AH, 4CH
          INT      21H
ERRRD:    LEA      DX, ERR_RD
          MOV      AH, 9
          INT      21H
          MOV      AH, 4CH
          INT      21H
CLOSE:    MOV      AH, 3EH
          MOV      BX, FCODE
          INT      21H
          JNC      QUIT                         ;关闭文件成功则跳转到QUIT
          LEA      DX, ERR_CL                   ;关闭文件失败则显示出错信息
          MOV      AH, 9
          INT      21H
          MOV      AH, 4CH
          INT      21H
QUIT:     MOV      AX, SUM
          AND      AX, 00FFH
          MOV      BL, AL                       ;将总人数存入BL中
          RET
          COUNT_NUM ENDP

GENER_NUM PROC
          MOV      AH, 0
          INT      1AH
          MOV      AX, DX
          AND      AX, 00FFH
          DIV      BL
          MOV      AL, AH
          INC      AL
          AND      AX, 00FFH                    ;产生规定范围内的随机数并存入AL中
          RET
          GENER_NUM ENDP

TRANS_NUM PROC
          PUSH     AX
          PUSH     BX
          MOV	   CX, 0
	  MOV	   BX, 10
REP1:	  MOV	   DX, 0
	  DIV	   BX
	  ADD	   DX, '0'
	  PUSH	   DX
	  INC	   CX
          OR	   AX, AX
	  JNZ	   REP1
REP2:	  POP	   DX
	  MOV	   AH, 2
	  INT	   21H
	  LOOP	   REP2
          POP      BX
          POP      AX
          RET
          TRANS_NUM ENDP

PRINT_NUM PROC
          PUSH     AX
          LEA      DX, FNAME                   ;设置ASCIZ串指针
          MOV      AH, 3DH                     ;打开文件
          MOV      AL, 0
          INT      21H
          JC       ERROPS                      ;文件打开失败则跳转到ERROPS显示出错信息
          
          MOV      FCODE, AX
          XOR      CX, CX                      ;清空CX中的数据
          XOR      DX, DX                      ;清空DX中的数据
          POP      AX
          DEC      AX
          MUL      LEN                         ;计算指针偏移值
          MOV      CX, DX
          MOV      DX, AX                      ;将指针偏移值存入CX:DX中
          MOV      AH, 42H
          MOV      AL, 0
          MOV      BX, FCODE
          INT      21H
          JC       ERRPOS                      ;指针转移失败则跳转到ERRPOS显示出错信息
          
          MOV      AH, 3FH                     ;接下来读取跳转行的文件信息
          LEA      DX, BUF
          MOV      BX, FCODE 
          MOV      CX, 9
          INT      21H
          JC       ERRRDS                      ;文件读取失败则跳转到ERRRDS显示出错信息
          MOV      AH, 40H                     ;文件读取成功则写文件（将读取的信息显示在屏幕上）
          MOV      BX, 1
          LEA      DX, BUF
          INT      21H
          JC       ERRWRS                      ;写文件失败则跳转到ERRWRS显示出错信息
          JMP      CLOSES

ERROPS:   LEA      DX, ERR_OP                  
          MOV      AH, 9
          INT      21H
          MOV      AH, 4CH
          INT      21H

ERRPOS:   LEA      DX, ERR_PO
          MOV      AH, 9
          INT      21H
          MOV      AH, 4CH
          INT      21H

ERRRDS:   LEA      DX, ERR_RD
          MOV      AH, 9
          INT      21H
          MOV      AH, 4CH
          INT      21H

ERRWRS:   LEA      DX, ERR_WR
          MOV      AH, 9
          INT      21H
          MOV      AH, 4CH
          INT      21H

CLOSES:   MOV      AH, 3EH
          MOV      BX, FCODE
          INT      21H
          JNC      QUITS                        ;关闭文件成功则跳转到QUITS
          LEA      DX, ERR_CL                   ;关闭文件失败则显示出错信息
          MOV      AH, 9
          INT      21H
          MOV      AH, 4CH
          INT      21H
QUITS:    RET
          PRINT_NUM ENDP
                           
CODE      ENDS
          END      START

      

          
              
 

