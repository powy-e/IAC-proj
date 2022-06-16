; *********************************************************************************
; * Ficheiro:  grupo_12.asm
; * Descrição: Ficheiro de código Assembly para o PEPE-16 relativo
; * 		   à versão intermédia do projeto de IAC do grupo 12.
; *
; *	Beatriz Gavilan - 102463 - beatrizgavilan@tecnico.ulisboa.pt
; *	Eduardo Nazário - 102415 - eduardo.nazario@tecnico.ulisboa.pt
; *	Miguel Coelho   - 102430 - miguel.pinheiro.coelho@tecnico.ulisboa.pt
; *********************************************************************************


;  Tecla andar para a esquerda:	0
;  Tecla andar para a direita:	2
;  Tecla descer o meteoro:		7
;  Tecla para diminuir display: C
;  Tecla para aumentar display: D

; +------------+
; | CONSTANTES |
; +------------+
TEC_LIN					EQU 0C000H		; Endereço das linhas do teclado (periférico POUT-2)
TEC_COL					EQU 0E000H		; Endereço das colunas do teclado (periférico PIN)
NUMERO_LINHAS			EQU 4			; Número de linhas no teclado
MASCARA					EQU 0FH			; Para isolar os 4 bits de menor peso, ao ler as colunas do teclado

TECLA_ESQUERDA			EQU 0H			; Tecla 0
TECLA_DIREITA			EQU 2H			; Tecla 2
TECLA_METEORO_BAIXAR	EQU 7H			; Tecla 7
TECLA_AUMENTA_DISPLAY 	EQU 0DH			; Tecla D
TECLA_DIMINUI_DISPLAY	EQU 0CH			; Tecla C

DEFINE_LINHA    		EQU 600AH      	; Endereço do comando para definir a linha
DEFINE_COLUNA   		EQU 600CH      	; Endereço do comando para definir a coluna
DEFINE_PIXEL    		EQU 6012H      	; Endereço do comando para escrever um pixel
APAGA_AVISO     		EQU 6040H      	; Endereço do comando para apagar o aviso de nenhum cenário selecionado
APAGA_ECRÃ	 			EQU 6002H      	; Endereço do comando para apagar todos os pixels já desenhados
SELECIONA_CENARIO_FUNDO EQU 6042H      	; Endereço do comando para selecionar uma imagem de fundo
TOCA_SOM				EQU 605AH      	; Endereço do comando para tocar um som


ATRASO					EQU	0FFFH		; Atraso para limitar a velocidade de movimento

ENDEREÇO_DISPLAY		EQU 0A000H		; Endereço do display (POUT-2)
ENERGIA_INICIAL			EQU	100			; Energia inicial da nave
VALOR_ENERGIA_AUMENTO 	EQU 5			; Valor de energia a aumentar por comando
VALOR_ENERGIA_DIMINUI 	EQU 5			; Valor de energia a diminuir por comando


LINHA_NAVE        		EQU 28        	; Linha base da nave (a meio do ecrã)
COLUNA_INICIAL_NAVE		EQU 30        	; Coluna base da nave (a meio do ecrã)
LINHA_APOS_NAVE         EQU 32         	; Linha após linha final da nave
ALTURA_NAVE             EQU 4			; Altura da nave
LARGURA_NAVE			EQU	5			; Largura da nave


LINHA_INICIAL_METEORO   EQU 0			; Linha base do meteoro
COLUNA_METEORO          EQU 44			; Coluna base do meteoro
ALTURA_METEORO_MAU      EQU 5			; Altura do meteoro mau
LARGURA_METEORO_MAU 	EQU 5 			; Largura do meteoro mau

MAX_LINHA       		EQU 31
MIN_COLUNA				EQU  0			; Número da última coluna à esquerda no ecrã
MAX_COLUNA				EQU  63     	; Número da última coluna à direita no ecrã


COR_PIXEL_METEORO       EQU 0FF05H   	

; Cores dos pixeis da nave
PIXEL_VERMELHO 			EQU	0FF00H
PIXEL_LARANJA 			EQU	0FF50H
PIXEL_LARANJA2 			EQU 0FFA5H
PIXEL_AMARELO 			EQU	0FFF0H
PIXEL_AMARELO2 			EQU 0FFFAH
PIXEL_VERDE 			EQU	0FAF5H
PIXEL_AZUL 				EQU	0F0AFH


; +-------+
; | DADOS | 
; +-------+
	PLACE       2000H

	STACK 100H							; espaço reservado para a pilha do processo "main" (programa prinicipal)
SP_inicial_main:						; este é o endereço (2200H) com que o SP deste processo deve ser inicializado

	STACK 100H							; espaço reservado para a pilha do processo "teclado" (linha 1)
SP_inicial_teclado_1:					; este é o endereço (2400H) com que o SP deste processo deve ser inicializado

	STACK 100H							; espaço reservado para a pilha do processo "teclado" (linha 1)
SP_inicial_teclado_2:					; este é o endereço (2600H) com que o SP deste processo deve ser inicializado

	STACK 100H							; espaço reservado para a pilha do processo "teclado" (linha 1)
SP_inicial_teclado_3:					; este é o endereço (2800H) com que o SP deste processo deve ser inicializado

	STACK 100H							; espaço reservado para a pilha do processo "teclado" (linha 1)
SP_inicial_teclado_4:					; este é o endereço (3000H) com que o SP deste processo deve ser inicializado

	STACK 100H							; espaço reservado para a pilha do processo "nave"
SP_inicial_nave:						; este é o endereço (3200H) com que o SP deste processo deve ser inicializado

	STACK 100H							; espaço reservado para a pilha do processo "display"
SP_inicial_display:						; este é o endereço (3400H) com que o SP deste processo deve ser inicializado

	STACK 100H							; espaço reservado para a pilha do processo "meteoro"
SP_inicial_meteoro:						; este é o endereço (3600H) com que o SP deste processo deve ser inicializado

ENERGIA:
	WORD ENERGIA_INICIAL 				; guarda a energia inicial da nave

TECLA_CARREGADA:
	LOCK 0 								; LOCK usado para o teclado comunicar aos restantes processos que tecla detetou
										; uma vez por cada tecla carregada

TECLA_CONTINUA:
	LOCK 0								; LOCK usado para o teclado comunicar aos restantes processos que tecla detetou,
										; enquanto a tecla estiver carregada

SP_TECLADO:
	WORD SP_inicial_teclado_1
	WORD SP_inicial_teclado_2
	WORD SP_inicial_teclado_3
	WORD SP_inicial_teclado_4

DEF_NAVE:								; tabela que define a nave 
	WORD		ALTURA_NAVE, LARGURA_NAVE
    WORD		0, 				0, 				PIXEL_AMARELO2, 0, 				0
	WORD		PIXEL_VERMELHO, 0, 				PIXEL_AMARELO, 	0, 				PIXEL_AZUL
    WORD		PIXEL_VERMELHO, PIXEL_LARANJA, 	PIXEL_AMARELO, 	PIXEL_VERDE, 	PIXEL_AZUL
    WORD		0, 				PIXEL_LARANJA2, 0, 				PIXEL_VERDE, 	0

POSIÇAO_NAVE:
	WORD COLUNA_INICIAL_NAVE

DEF_METEORO_MAU:						; tabela que define o meteoro mau 
	WORD		ALTURA_METEORO_MAU, LARGURA_METEORO_MAU
    WORD		COR_PIXEL_METEORO, 	0, 					0, 					0, 					COR_PIXEL_METEORO
	WORD		COR_PIXEL_METEORO, 	0, 					COR_PIXEL_METEORO, 	0, 					COR_PIXEL_METEORO
    WORD		0, 					COR_PIXEL_METEORO, 	COR_PIXEL_METEORO, 	COR_PIXEL_METEORO, 	0
   	WORD		COR_PIXEL_METEORO, 	0, 					COR_PIXEL_METEORO, 	0, 					COR_PIXEL_METEORO
    WORD		COR_PIXEL_METEORO, 	0, 					0, 					0, 					COR_PIXEL_METEORO

POSIÇAO_METEORO:
	WORD LINHA_INICIAL_METEORO

; +--------+
; | CÓDIGO |
; +--------+
PLACE   0                     			; o código tem de começar em 0000H
inicio:
	MOV SP, SP_inicial_main				; Inicializa o SP (stack pointer) do programa principal

load_start:
	MOV  [APAGA_AVISO], R1				; Apaga o aviso de nenhum cenário selecionado 
	MOV  [APAGA_ECRÃ], R1	    		; Apaga todos os pixels já desenhados 
	MOV	 R1, 1			        		; Cenário de fundo número 0
    MOV  [SELECIONA_CENARIO_FUNDO], R1	; Seleciona o cenário de fundo

	MOV  R11, NUMERO_LINHAS				; Inicializa R11 com o valor da primeira linha a ser lida
loop_teclados:
	CMP R11, 0
	JZ start_game
	SUB R11, 1
	CALL teclado
	JMP loop_teclados
start_game:
	MOV R3, [TECLA_CARREGADA]
	MOV R4, TECLA_DIMINUI_DISPLAY
	CMP R3, R4
	JNZ start_game

load_game:
	MOV  [APAGA_AVISO], R1	    		; Apaga o aviso de nenhum cenário selecionado 
    MOV  [APAGA_ECRÃ], R1	    		; Apaga todos os pixels já desenhados 
	MOV	 R1, 0			        		; Cenário de fundo número 0
    MOV  [SELECIONA_CENARIO_FUNDO], R1	; Seleciona o cenário de fundo

	; Cria processos. O CALL não invoca a rotina, apenas cria um processo executável
	CALL meteoro
	CALL display

nave:
	MOV R2, [POSIÇAO_NAVE]				; Argumento posição da Nave (coluna)
	MOV R4, 0							; Argumento offset da Nave
	CALL desenha_col_offset				; Desenha a nave na sua posição inicial
espera_movimento:
	MOV R3, [TECLA_CONTINUA]
mover_esquerda:
	CMP R3, TECLA_ESQUERDA
	JNZ mover_direita					; Passa ao próximo teste
	CALL mover_nave_esquerda
	JMP espera_movimento
mover_direita:
	CMP R3, TECLA_DIREITA
	JNZ espera_movimento
	CALL mover_nave_direita
	JMP espera_movimento


; *
; * ATRASO - Executa um ciclo para implementar um atraso.
; * Argumentos:	R11 - valor que define o atraso
; *
; *
inicio_ciclo_atraso:
	PUSH R11
	MOV R11, ATRASO							
ciclo_atraso:							; Ciclo usado para "fazer tempo" entre movimentos sucessivos de naves e meteoros
	SUB	R11, 1								
	JNZ	ciclo_atraso					; Espera até que, por subtrações sucessivas, R11 fique a 0
	POP R11
	RET 

; * [Processo]
; *
; * NAVE - Processo que trata do movimento da nave, controlado pelo input do teclado
; *


; * [Processo]
; *
; * DISPLAY - Processo que trata da inicialização e alteração do valor do display, controlado pelo input do teclado
; *
PROCESS SP_inicial_display
display:
	CALL inicia_energia_display 		; Inicializa o display da energia ao seu valor inicial predefinido (100)
ciclo_display:
	MOV R3, [TECLA_CARREGADA]			; 
aumenta_display:
	MOV R4, TECLA_AUMENTA_DISPLAY		; NOTA: aqui usamos um registo intermédia (R4) uma vez que o valor de TECLA_DIMINUI_DISPLAY excede a gama admitida em constantes
	CMP R3, R4							; Verifica se a tecla lida corresponde à tecla responsável por aumentar o display
	JNZ diminui_display					; Caso não for, passa ao próximo teste
	CALL aumenta_energia_display		; Caso for, chama a rotina própria 
	JMP ciclo_display					; Torna a ler o input do teclado
diminui_display:
	MOV R4, TECLA_DIMINUI_DISPLAY		; NOTA: aqui usamos um registo intermédia (R4) uma vez que o valor de TECLA_DIMINUI_DISPLAY excede a gama admitida em constantes
	CMP R3, R4							; Verifica se a tecla lida corresponde à tecla responsável por diminuir o display
	JNZ ciclo_display					; Caso não for, torna a ler o input do teclado
	CALL diminui_energia_display		; Caso for, chama a rotina própria
	JMP ciclo_display					; Torna a ler o input do teclado
	
; * [Processo]
; *
; * METEORO - Processo que trata do movimento da meteoro, controlado pelo input do teclado
; *
PROCESS SP_inicial_meteoro
meteoro:
	CALL linha_seguinte					; Desenha o meteoro mau na sua posição inicial
ciclo_meteoro:
	MOV R3, [TECLA_CARREGADA]
baixa_meteoro:
	CMP R3, TECLA_METEORO_BAIXAR
	JNZ ciclo_meteoro		
	MOV R9, 0
	MOV [TOCA_SOM], R9
	CALL mover_meteoro_mau
	JMP ciclo_meteoro


; * [Processo]
; *
; * TECLADO - Faz uma leitura às teclas de uma linha do teclado e retorna o valor da tecla lida
; * Argumentos:	R11 - linha a testar (em formato 1, 2, 4 ou 8)
; *
PROCESS SP_inicial_teclado_1

teclado:
	MOV  R2, TEC_LIN   					; Endereço do periférico das linhas
	MOV  R3, TEC_COL   					; Endereço do periférico das colunas
	MOV  R5, MASCARA   					; Para isolar os 4 bits de menor peso, ao ler as colunas do teclado

	MOV  R1, R11						; Número da linha a testar (R11 vem em formato (0, 1, 2, 3))
	SHL  R1, 1
	MOV  R10, SP_TECLADO
	MOV  SP, [R10 + R1]

	MOV  R6, 1 
loop_fix_linha:
	CMP  R11, 0
	JZ end_fix_linha
	SHL  R6, 1
	SUB  R11, 1
	JMP loop_fix_linha
end_fix_linha:
	MOV  R1, R6

espera_tecla:							; Neste ciclo, espera-se até uma tecla ser premida

	WAIT 								; Este ciclo é potencialmente bloqueante, pelo que tem de
										; ter um ponto de fuga (aqui pode comutar para outro processo)

	MOVB [R2], R1 						; Escrever no periférico de saída (linhas)
	MOVB R0, [R3]      					; Ler do periférico de entrada (colunas)
	AND  R0, R5        					; Elimina bits para além dos bits 0-3
	CMP R0, 0							; Verifica se foi detetada alguma tecla carregada
	JZ espera_tecla						; Se nenhuma tecla for premida, repete

	CALL formata_tecla					; Converte o valor da linha e o da coluna no valor da tecla lida
										; (retorna um valor entre 0H e FH, consoante o valor da tecla lida)
	MOV [TECLA_CARREGADA], R0			; Informa quem estiver bloqueado neste LOCK que uma tecla foi carregada

espera_nao_tecla:						; Neste ciclo, espera-se até NENHUMA tecla estar premida

	YIELD								; Este ciclo é potencialmente bloqueante, pelo que tem de
										; ter um ponto de fuga (aqui pode comutar para outro processo)

	CALL formata_tecla					; Converte o valor da linha e o da coluna no valor da tecla lida
										; (retorna um valor entre 0H e FH, consoante o valor da tecla lida)
	MOV [TECLA_CONTINUA], R0			; Informa quem estiver bloqueado neste LOCK que uma tecla está a ser carregada

	MOVB [R2], R1 						; Escrever no periférico de saída (linhas)
	MOVB R0, [R3]      					; Ler do periférico de entrada (colunas)
	AND  R0, R5        					; Elimina bits para além dos bits 0-3
	CMP R0, 0							; Verfica se há uma tecla premida
	JNZ espera_nao_tecla				; Se ainda houver uma tecla premida, repete

	JMP espera_tecla					; Inicia-se um ciclo infinito, uma vez que o programa
										; nunca deve parar de verificar inputs do teclado
										; (enquanto o jogo não estiver pausado ou parado)

; * (Função auxiliar)
; * FORMATA_TECLA - Converte o valor da linha lida e da coluna lida no valor da tecla lida (0H até FH)
; * Argumentos: R1 - valor da linha lida em (1, 2, 4, 8)
; *				R0 - valor da coluna lida em (1, 2, 4, 8)
; *
; * Retorna:    R0 - valor da tecla lida em (0, 1, 2, 3)   
; *
formata_tecla:
	PUSH R1
	CALL formata_linha					; caso haja uma tecla premida, converte o valor da linha lida
										; de (1, 2, 3, 4) para (0, 1, 2, 3)
	CALL formata_coluna					; e faz a mesma operação para o valor da coluna lida
	MOV TEMP, 4
	MUL R1, TEMP
	ADD R0, R1							; O valor da tecla é definido como sendo:
										; 	tecla = 4 * linha + coluna
	POP R1
	RET

; * (Função auxiliar)
; * FORMATA_LINHA - Converte o valor da linha lida de (1, 2, 4, 8) em (0, 1, 2, 3)
; * Argumentos: R1 - valor da linha lida em (1, 2, 4, 8)
; *
; * Retorna:    R1 - valor da linha lida em (0, 1, 2, 3)   
; *
formata_linha:
   MOV TEMP, -1
formata_linha_ciclo:                    ; Para converter o valor da linha lida
   ADD TEMP, 1                         	; de (1, 2, 3, 4) para (0, 1, 2, 3)
   SHR R1, 1                           	; contamos o número de vezes que é preciso fazer SHR ao valor da linha
   CMP R1, 0                           	; para obter 0
   JNZ formata_linha_ciclo
   MOV R1, TEMP
   RET
 
; * (Função auxiliar)
; * FORMATA_COLUNA - Converte o valor da coluna lida de (1, 2, 4, 8) em (0, 1, 2, 3)
; * Argumentos: R0 - valor da coluna lida em (1, 2, 4, 8)
; *
; * Retorna:    R0 - valor da coluna lida em (0, 1, 2, 3)  
; *
formata_coluna:
   MOV TEMP, -1
formata_coluna_ciclo:                   ; Para converter o valor da coluna lida
   ADD TEMP, 1                         	; de (1, 2, 3, 4) para (0, 1, 2, 3)
   SHR R0, 1                           	; contamos o número de vezes que é preciso fazer SHR ao valor da linha
   CMP R0, 0                          	; para obter 0
   JNZ formata_coluna_ciclo
   MOV R0, TEMP
   RET
	

; **************************************	
; *				  Display	 		   *
; **************************************	


; *
; * INICIA_ENERGIA_DISPLAY - Inicializa o display de energia
; *  Inicia o Display com o valor da energia que está na memória 
; *

inicia_energia_display:
	PUSH R0								; Guarda o valor de R0
	MOV R0, [ENERGIA]					; Coloca em R0 o valor inicial da energia
	MOV [ENDEREÇO_DISPLAY], R0			; Coloca o valor inicial no display
	POP R0					
	RET

; *
; * DIMINUI_ENERGIA_DISPLAY - Aumenta o valor de energia da nave
; *  Usa a memória para calcular e guardar o valor da energia
; *   e dá output para o Display 
; *
aumenta_energia_display:
	PUSH R0								; Guarda o valor de R0
	PUSH R1								; Guarda o valor de R1
	MOV R0, [ENERGIA]					; Coloca em R0 o valor inicial da energia
	MOV R1, ENERGIA_INICIAL			
	SUB R1,R0
	CMP R1, VALOR_ENERGIA_AUMENTO		;Se a energia for maior que 5, não altera
	JLT exit_aumenta_energia_display  
	ADD R0, 5
	MOV [ENERGIA], R0					;Guarda energia na memória
	MOV [ENDEREÇO_DISPLAY], R0			;Coloca o valor inicial no display
exit_aumenta_energia_display:
	POP R1 								; restaura o valor de R1
	POP R0								; restaura o valor de R0
	RET

; *
; * DIMINUI_ENERGIA_DISPLAY - Aumenta o valor de energia da nave
; *  Usa a memória para calcular e guardar o valor da energia
; *   e dá output para o Display 
; *
diminui_energia_display:
	PUSH R0								; Guarda o valor de R0
	MOV R0, [ENERGIA]					; Coloca em R0 o valor inicial da energia
	CMP R0, VALOR_ENERGIA_DIMINUI		; Se a energia for maior que 5, não altera
	JLT exit_diminui_energia_display   
	SUB R0, 5 
	MOV [ENERGIA], R0					; Guarda energia na memória
	MOV [ENDEREÇO_DISPLAY], R0			; Coloca o valor inicial no display
exit_diminui_energia_display: 
	POP R0								; Restaura o valor de R0
	RET


; **************************************	
; *				  Nave    	 		   *
; **************************************	

; *
; * MOVER_NAVE_ESQUERDA - Trata o movimento da nave para a esquerda
; *
mover_nave_esquerda:
    PUSH R4								; Guarda todos os registos utilizados
    PUSH R2
	MOV	R4, MIN_COLUNA          		; Guarda a Coluna do Limite Esquerdo em R5
	MOV R2, [POSIÇAO_NAVE]      		; Vai buscar a Coluna onde a Nave se encontra
	CMP	R2, R4                  		; Verifica se a nave se encontra na coluna limite
	JLE	fim_movimento_esquerda  		; Se sim, não se pode mover    
	MOV R4, -1                  		; Indica o sentido do movimento
    CALL inicio_apaga_nave      		; Chama a rotina que apaga a Nave
    CALL desenha_col_offset   			; Chama a rotina que desenha da Nave
	CALL inicio_ciclo_atraso			; Atrasa a execução do próximo comando, tornando o movimento mais fluido
	
fim_movimento_esquerda:
    POP R2								; Repõe todos os registos utilizados
    POP R4
    RET

; *
; * MOVER_NAVE_DIREITA - Trata o movimento da nava para a direita
; *
mover_nave_direita:	
    PUSH R6
    PUSH R5								; Guarda todos os registos utilizados
	PUSH R4	
    PUSH R2
	MOV	R6, [DEF_NAVE+2]				; Obtém a largura da nave (2º elemento da tabela DEF_NAVE)
	MOV R2, [POSIÇAO_NAVE]   			; Vai buscar a Linha onde a Nave se encontra
	ADD R6, R2                 			; Obtém a posiçao da última coluna da nave
	MOV	R5, MAX_COLUNA					; Obtem ultima coluna à direita do ecrãua i
	CMP	R6, R5							; Verifica se a ultima coluna da nave ja se encontra na Coluna Limite Direito
	JGT	fim_movimento_direita   		; Caso a nave já ocupe a ultima coluna, não se move 
    MOV R4, 1                  			; Indica o sentido do movimento
    CALL inicio_apaga_nave      		; Chama a rotina que apaga a nave
	CALL desenha_col_offset   			; Chama a rotina que desenha a nave
	CALL inicio_ciclo_atraso			; Atrasa a execução do próximo comando, tornando o movimento mais fluido

fim_movimento_direita:
    POP R2
	POP R4								; Repõe todos os registos utilizados
    POP R5
    POP R6
    RET


; *
; * INICIO_APAGA_NAVE - Apaga a nave, começando por obter a posição 
; *  da nave e apagando-a linha a linha, num ciclo.
; *
inicio_apaga_nave:
	PUSH R9	
	PUSH R8	
	PUSH R6								; Guarda todos os registos utilizados
	PUSH R5
	PUSH R3
    MOV R9, LINHA_NAVE					; obtém a linha onde começa a nave
    MOV R8, [DEF_NAVE]					; obtém a altura da nave que serve como contador de linhas
	MOV	R3, 0			        		; para apagar, a cor do pixel é 0
	JMP apaga_linha_nave
apaga_linha_nave:		
	MOV	R6, [POSIÇAO_NAVE]				; cópia da coluna da nave
	MOV	R5, [DEF_NAVE+2]				; obtém a largura da nave
apaga_pixels_nave:       				
	MOV  [DEFINE_LINHA], R9	    		; seleciona a linha
	MOV  [DEFINE_COLUNA], R6			; seleciona a coluna
	MOV  [DEFINE_PIXEL], R3	    		; altera a cor do pixel na linha e coluna selecionadas
    ADD  R6, 1                  		; Passa à próxima coluna
    SUB  R5, 1			        		; Reduz o contador de colunas por apagar
    JNZ  apaga_pixels_nave				; Continua até percorrer toda a largura do objeto
	ADD R9, 1                   		; Passa à linha seguinte
    SUB R8, 1                   		; Reduz o contador das linhas por apagar
	JNZ apaga_linha_nave        		; Vai apagar a próxima linha da nave
	POP R3
	POP R5
	POP R6								; Repõe todos os registos utilizados
	POP R8
	POP R9
    RET


; *
; * DESENHA_COL_OFFSET - Desenha a nave na posição (coluna) desejada, começando por 
; *  obter a sua posição e desenhando-a, linha a linha, num ciclo.
; * Argumentos: R2 - Coluna onde a nave se encontra
; *				R4 - offset (descreve o sentido do movimento ou a não existência do mesmo)
; *
desenha_col_offset:
    PUSH R9
    PUSH R8
	PUSH R6
	PUSH R5								; Guarda todos os registos utilizados
    PUSH R4
	PUSH R2
	ADD	R2, R4			        		; Altera a coluna consoante o sentido do movimento 
	MOV [POSIÇAO_NAVE], R2				; Atualiza a coluna onde começa o desenho da nave
    MOV R9, LINHA_NAVE          		; Obtém a linha onde começa a nave
    MOV R8, [DEF_NAVE]					; Cópia da altura (contador de linhas)
    MOV	R4, DEF_NAVE		    		; Endereço da tabela que define a nave
    ADD R4, 4			        		; Endereço da cor do 1º pixel 
desenha_linha_nave:       				
	MOV	R6, [POSIÇAO_NAVE]				; Cópia da coluna da nave
	MOV	R5, [DEF_NAVE+2]				; Obtém a largura da nave (contador de colunas)
desenha_pixels_nave:       				
	MOV	R2, [R4]			    		; Obtém a cor do próximo pixel 
	MOV  [DEFINE_LINHA], R9	    		; Seleciona a linha
	MOV  [DEFINE_COLUNA], R6			; Seleciona a coluna
	MOV  [DEFINE_PIXEL], R2	    		; Altera a cor do pixel na linha e coluna selecionadas
	ADD	 R4, 2			        		; Endereço da cor do próximo pixel 
    ADD  R6, 1                  		; Passa à próxima coluna
    SUB  R5, 1			        		; Reduz o contador de colunas por tratar
    JNZ  desenha_pixels_nave    		; Continua até percorrer toda a largura do objeto
	ADD R9, 1                   		; Aumenta a linha
	SUB R8, 1							; Reduz contador das linhas por desenhar
    JNZ desenha_linha_nave				; Vai desenhar a próxima linha da nave		
	POP R2
	POP R4
    POP R5								; Repõe todos os registos utilizados
	POP R6
	POP R8
    POP R9
	RET



; **************************************	
; *				 Meteoros  	 		   *
; **************************************	


; *
; * MOVER_METEORO_MAU - Move o meteoro mau 1 linha para baixo, começando por obter a posição 
; *  da nave e apagando-a linha a linha, num ciclo.
; *
mover_meteoro_mau:	
    PUSH R8
    PUSH R9								; Guarda todos os registos utilizados
	PUSH R4						
	MOV R9, [POSIÇAO_METEORO]			; Cópia da linha onde se encontra o meteoro
	MOV R8, [DEF_METEORO_MAU]			; Cópia da altura (contador das linhas)
    MOV R4, 1							; Sentido do movimento (para baixo)
	CALL apaga_meteoro_mau
	CALL linha_seguinte
fim_movimento_meteoro:
    POP R4
	POP R9								; Repõe todos os registos utilizados
    POP R8
    RET


; *
; * APAGA_METEORO_MAU - Apaga o meteoro mau, começando por obter a sua posição 
; *  da nave e apagando-o linha a linha, num ciclo.
; * Argumentos: R8 - Altura do meteoro (contador das linhas)
; *				R9 - 1ª Linha onde se encontra o meteoro
; *
apaga_meteoro_mau:
	PUSH R9
	PUSH R8
	PUSH R6								; Guarda todos os registos utilizados
	PUSH R5
	PUSH R3
apaga_linha_meteoro_mau:
	MOV R6, COLUNA_METEORO				; Obtém a coluna onde começa o meteoro
	MOV	R5, [DEF_METEORO_MAU + 2]		; Obtém a largura do meteoro (contador de colunas)
	MOV	R3, 0							; Para apagar, a cor do pixel é sempre 0
apaga_pixels_meteoro:       			
	MOV  [DEFINE_LINHA], R9				; Seleciona a linha 
	MOV  [DEFINE_COLUNA], R6			; Seleciona a coluna
	MOV  [DEFINE_PIXEL], R3				; Altera (para 0) a cor do pixel na linha e coluna selecionadas
    ADD  R6, 1             				; Passa à próxima coluna
    SUB  R5, 1							; Reduz o contador de colunas por apagar
    JNZ  apaga_pixels_meteoro			; Continua até percorrer toda a largura do objeto
	ADD R9, 1							; Avança para a linha seguinte
    SUB R8, 1							; Reduz contador das linhas por apagar
	JNZ apaga_linha_meteoro_mau			; Vai apagar a próxima linha do meteoro
	POP R3
	POP R5								
	POP R6								; Repõe todos os registos
	POP R8
	POP R9
    RET

; *
; * APAGA_METEORO_MAU - Desenha o meteoro mau na posição desejada (1 linha abaixo), começando por 
; *  obter a sua posição e desenhando-o, linha a linha, num ciclo.
; * Argumentos: R4 - offset (descreve o sentido do movimento ou a não existência do mesmo)
; *				R8 - Altura do meteoro (contador das linhas)
; *				R9 - 1ª Linha onde se encontra o meteoro
; *
linha_seguinte:
	PUSH R9
	PUSH R8
	PUSH R6
	PUSH R5								; Guarda todos os registos utilizados
	PUSH R4
	PUSH R3 
	PUSH R2
	PUSH R1
	MOV R2, [POSIÇAO_METEORO]			; Vai buscar a linha do meteoro à memória
	ADD R2, R4							; Obtém a linha seguinte onde desenhar o meteoro	
	MOV [POSIÇAO_METEORO], R2			; Atualiza a linha inicial do meteoro
inicio_desenha_meteoro_mau:
	MOV R9, [POSIÇAO_METEORO]			; Volta a obter da memória a linha do meteoro
    MOV R8, [DEF_METEORO_MAU]   		; Obtém a altura do meteoro mau
    MOV	R4, DEF_METEORO_MAU				; Obtém o endereço da tabela que define o meteoro mau
    ADD R4, 4           				; Obtém o endereço da cor do 1º pixel 
desenha_meteoro_mau:       						
    MOV R1, MAX_LINHA					; Obtém o endereço da última linha do ecrã
	CMP R9, R1							; Verifica se a próxima linha do meteoro está fora do ecrã 
	JGT acaba_desenho_meteoro_mau		; Nesse caso, interrompe o desenho, pois o resto do meteoro já ultrapassou o ecrã 
	MOV R6, COLUNA_METEORO				; Cópia da primeira coluna do meteoro
	MOV	R5, [DEF_METEORO_MAU+2]			; Obtém a largura do meteoro
desenha_pixels_meteoro:       		
	MOV	R3, [R4]						; Obtém a cor do próximo pixel 
	MOV [DEFINE_LINHA], R9				; Seleciona a linha
	MOV [DEFINE_COLUNA], R6				; Seleciona a coluna
	MOV [DEFINE_PIXEL], R3				; Altera a cor do pixel na linha e coluna selecionadas
	ADD	R4, 2							; Obtém endereço da cor do próximo pixel 
    ADD R6, 1               			; Passa à próxima coluna
    SUB R5, 1							; Reduz o contador de colunas por desenhar
    JNZ desenha_pixels_meteoro 			; Continua até percorrer toda a largura do objeto
	ADD R9, 1               			; Avança para a linha seguinte
	SUB R8, 1							; Reduz o contador das linhas por desenhar
    JNZ desenha_meteoro_mau				; Vai desenhar a próxima linha do meteoro
	CALL inicio_ciclo_atraso			; Atrasa a execução do próximo comando, tornando o movimento mais fluido	
acaba_desenho_meteoro_mau:
	POP R1
	POP R2
	POP R3
	POP R4
	POP R5								; Repõe todos os registos
	POP R6
	POP R8
	POP R9
	RET
   
