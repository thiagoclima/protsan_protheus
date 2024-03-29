#INCLUDE "PROTHEUS.CH"
#INCLUDE "LOJA701.CH"
#INCLUDE "AUTODEF.CH"
#INCLUDE "TBICONN.CH"

Static lTEFSave	:= SuperGetMV("MV_TEFSAVE",,2) == 1 .AND. nModulo == 12 //Funcionalidade dispon�vel somente no SIGALOJA: Sistema deve guardar e recuperar os dados da transa��o TEF realizada na venda caso ocorra algum problema antes de concluir a venda? (1=Sim;2=N�o)  

/*
��������������������������������������������������������������������������������
��������������������������������������������������������������������������������
����������������������������������������������������������������������������Ŀ��
���Fun��o    �LOJA701F    	  � Autor �Vendas CRM            � Data �18.12.2011�  ��
����������������������������������������������������������������������������Ĵ��
���Descri��o �Fonte para inclus�o de fun��es especificas do Venda Direta       ���
����������������������������������������������������������������������������Ĵ��
��������������������������������������������������������������������������������
*/

/*
��������������������������������������������������������������������������������
��������������������������������������������������������������������������������
����������������������������������������������������������������������������Ŀ��
���Fun��o    �FTVDAltPrc    � Autor �Vendas CRM            � Data �18.12.2011�  ��
����������������������������������������������������������������������������Ĵ��
���Descri��o �Venda Programada(Venda Direta)                                   ���
����������������������������������������������������������������������������Ĵ��
���Parametros�cL1Num - Num Orcamento                                         ���
���          �aPrc   - aSL4 - Parcelas                                       ���
����������������������������������������������������������������������������Ĵ��
���Retorno   �lRet - .T. - sucesso                                           ���
�����������������������������������������������������������������������������ٱ�
��������������������������������������������������������������������������������
*/
Function LjVDAltPrc(cL1Num,aPrc)
Local _aCab			:=	{}												//Array do Cabe�alho do Or�amento
Local _aItem			:=	{}												//Array dos Itens do Or�amento
Local aDadosItem    	:=  {}                                             	//Dados do Item montado no loop
Local aCamposSL1    	:=  {}                                            	//Campos de SL1 para montar array pro execauto
Local aCamposSL2    	:=  {}	                                            //Campos de SL1 para montar array pro execauto
Local nI
Local lRet				:= .F.

Default cL1Num			:= ""
Default aPrc			:= {}

Private lMsHelpAuto 	:= .T.												// Variavel de controle interno do ExecAuto
Private lMsErroAuto 	:= .F.												// Variavel que informa a ocorr�ncia de erros no ExecAuto
Private INCLUI 		:= .T.												// Variavel necess�ria para o ExecAuto identificar que se trata de uma inclus�o
Private ALTERA 		:= .F.												// Variavel necess�ria para o ExecAuto identificar que se trata de uma inclus�o

DbSelectArea("SX3")
DbSetOrder(1)
DbSeek("SL1")
While !Eof() .AND. SX3->X3_ARQUIVO == "SL1"
	If X3Uso(SX3->X3_USADO) .AND. cNivel >= SX3->X3_NIVEL 
		If SX3->X3_CONTEXT != "V"
			Aadd(aCamposSL1,Alltrim(SX3->X3_CAMPO))
		EndIf
	EndIf
	SX3->(DbSkip())
End

aCamposSL2 :=   {"L2_NUM"	 ,"L2_PRODUTO",	"L2_QUANT"	,"L2_UM",;
				 "L2_DESC"	 ,"L2_VALDESC",	"L2_DOC"	,"L2_SERIE",;
				 "L2_PDV"	 ,"L2_TABELA",	"L2_DESCPRO","L2_FILIAL",; 
				 "L2_VRUNIT" , "L2_VEND"}

//Monta cabe�alho do or�amento (SLQ)
DbSelectArea("SL1")
DbSetOrder(1)                                                                                                                                                       
If !MsSeek(XFilial("SL1")+cL1Num)                                                                                                                                    
	Aviso( STR0019, STR0248+cL1Num, {STR0028} ) // "Aten��o" ### "Numero de Orcamento nao encontrado" ### "Ok"				
Else
	For nI := 1 To Len(aCamposSL1)
		Aadd(_aCab,{"LQ_"+Substr(aCamposSL1[nI],4) , &("SL1->"+aCamposSL1[nI]) , NIL} )
	Next nI	
	//Monta item do or�amento (SLR)
	DbSelectArea("SL2")
	DbSetOrder(1)                                                                                                                                                       
	If !MsSeek(XFilial("SL2")+cL1Num)                                                                                                                                    
		Aviso( STR0019, STR0248+" SL2 "+cL1Num, {STR0028} ) // "Aten��o" ### "Numero de Orcamento nao Encontrado" ### "Ok"		
	Else	
		While !Eof() .AND. SL2->L2_NUM == cL1Num
			aDadosItem    :=  {}
			For nI := 1 To Len(aCamposSL2)
				Aadd(aDadosItem,{"LR_"+Substr(aCamposSL2[nI],4) , &("SL2->"+aCamposSL2[nI]) , NIL} )		
			Next nI 
			Aadd(aDadosItem,{"LR_ENTREGA" , "2" , NIL} )	// Seta para nao validar reserva pois apenas sera gravada a parcela.
			Aadd(_aItem,aDadosItem)
			DbSkip()
		End	                
		
		SetFunName("LOJA701")
		MSExecAuto({|a,b,c,d,e,f,g,h| LOJA701(a,b,c,d,e,f,g,h)},.F.,6,"","",{},_aCab,_aItem	,aPrc)
		
		If lMsErroAuto
			lRet := .F.
			MostraErro()        
			DisarmTransaction()
			// Libera sequencial
			RollBackSx8()	
		Else
			lRet := .T.
		EndIf                                    
	EndIf
EndIf
	
Return lRet

/*
��������������������������������������������������������������������������������
��������������������������������������������������������������������������������
����������������������������������������������������������������������������Ŀ��
���Fun��o    �FTVDVProg     � Autor �Vendas CRM            � Data �18.12.2011���
����������������������������������������������������������������������������Ĵ��
���Descri��o �Venda Programada                                               ���
����������������������������������������������������������������������������Ĵ��
���Parametros�cL2Num - Num Orcamento                                         ���
���          �cL2Item - Item de SL2                                          ���
���          �cL2Prod - Codigo Produto Padrao SL2                            ���
���          �cB2Prod - Codigo Produto Final SB2                             ���
���          �cB2Local - Local de SB2 do produto final                       ���
����������������������������������������������������������������������������Ĵ��
���Retorno   �Nenhum                                                         ���
�����������������������������������������������������������������������������ٱ�
��������������������������������������������������������������������������������
*/
Function LjVDVProg(cL2Num,cL2Item,cL2Prod,cB2Prod,cB2Local)  

Local aArea     	:= GetArea()                                                     
Local aAreaSL1              //Area SL1 do registro cL2Num
Local aAreaSL2              //Area SL2 do registro cL2Num
Local cLocalGen             //Armazem do Produto Gen�rico                        
Local cL1NumRes    
Local cPedRes
Local lRet 		:= .T.  


Default cL2Num	 	:= ""
Default cL2Item	:= ""
Default cL2Prod  	:= "" 
Default cB2Prod  	:= "" 
Default cB2Local 	:= ""

DbSelectArea("SL1")
DbSetOrder(1)    
                                                                                                                                                   
If !MsSeek(XFilial("SL1")+cL2Num)                                                                                                                                    
	Aviso( STR0019, STR0248+cL2Num, {STR0028} ) // "Aten��o" ### "Numero de Or�amento n�o encontrado " ### "Ok"
	Conout( STR0019, STR0248+cL2Num, {STR0028} )
	lRet := .F.
EndIf

If lRet .AND. (Empty(SL1->L1_ORCRES) .OR. Empty(SL1->L1_PEDRES))
	Aviso( STR0019, STR0249, {STR0028} ) // "Aten��o" ### "O Or�amento informado dever� ser o or�amento criado na finaliza��o da venda. O Or�amento que possui pedido de venda." ### "Ok"
	Conout( STR0019, STR0249, {STR0028} )
	lRet := .F.
EndIf                      

cL1NumRes := SL1->L1_ORCRES        
cPedRes   := SL1->L1_PEDRES     
aAreaSL1 := GetArea()

DbSelectArea("SL1")
DbSetOrder(1)                                                                                                                                                       
If lRet .AND. !MsSeek(XFilial("SL1")+cL1NumRes)                                                                                                                                    
	Aviso( STR0019, STR0248+cL1NumRes, {STR0028} ) // "Aten��o" ### "" ### "Ok"
	Conout( STR0019, STR0248+cL1NumRes, {STR0028} )
	lRet := .F.
EndIf

If lRet .AND. (SuperGetMV("MV_VEICULO",,"N") <> "S" .OR. SL1->(FieldPos("L1_ORIGEM")) == 0 .OR. SL1->L1_ORIGEM <> "V")
	Aviso( STR0019, STR0250, {STR0028} ) // "Aten��o" ### "Integra��o de Gest�o de Concession�rias Desativada. O Registro SL1 a ser alterado dever� ter sido criado por MsExecAuto do FATA701 atrav�s do m�dulo de gest�o de concession�rias." ### "Ok"
	Conout( STR0019, STR0250, {STR0028} )
	lRet := .F.		
EndIf                                                                  

DbSelectArea("SL2")
DbSetOrder(1)                                                                                                                                                       
If lRet .AND. !MsSeek(XFilial("SL2")+cL2Num+cL2Item+cL2Prod)                                                                                                                                    
	Aviso( STR0019, STR0251, {STR0028} ) // "Aten��o" ### ""Numero de Or�amento n�o encontrado em SL2"" ### "Ok"
	Conout( STR0019, STR0251, {STR0028} )
	lRet := .F.
EndIf                     

aAreaSL2 := GetArea()            

DbSelectArea("SL2")
DbSetOrder(1)                                                                                                                                                       
If lRet .AND. !MsSeek(XFilial("SL2")+cL1NumRes+cL2Item+cL2Prod)                                                                                                                                    
	Aviso( STR0019, STR0251, {STR0028} ) // "Aten��o" ### ""Numero de Or�amento n�o encontrado em SL2"" ### "Ok"
	Conout( STR0019, STR0251, {STR0028} )
	lRet := .F.
EndIf                                                    

cLocalGen := SL2->L2_LOCAL //Armazem do Produto Generico

DbSelectArea("SB1")
DbSetOrder(1)
If lRet .AND. !MsSeek(XFilial("SB1")+cB2Prod)
	Aviso( STR0019, STR0252, {STR0028} ) // "Aten��o" ### "O Produto Final e o Local Informado n�o foram encontrados em SB1." ### "Ok"
	Conout( STR0019, STR0252, {STR0028} )
	lRet := .F.
EndIf                                                       

DbSelectArea("SB2")
DbSetOrder(1)
If lRet .AND. !MsSeek(XFilial("SB2")+cB2Prod+cB2Local)
	Aviso( STR0019, STR0253, {STR0028} ) // "Aten��o" ### "O Produto Final e o Local Informado n�o foram encontrados em SB2." ### "Ok"
	Conout( STR0019, STR0253, {STR0028} )
	lRet := .F.
EndIf                                                       
		                                                    
If lRet .AND. SaldoSb2() <= 0 
	Aviso( STR0019, STR0254, {STR0028} ) // "Aten��o" ### "O Produto Final e o Local Informado n�o possuem saldo em estoque." ### "Ok"
	Conout( STR0019, STR0254, {STR0028} )
	lRet := .F.
EndIf		

DbSelectArea("SC5")
DbSetOrder(1)
If lRet .AND. !MsSeek(XFilial("SC5")+cPedRes)
	Aviso( STR0019, STR0255, {STR0028} ) // "Aten��o" ### "O Pedido de Venda do Or�amento n�o foi encontrado." ### "Ok"
	Conout( STR0019, STR0255, {STR0028} )
	lRet := .F.
EndIf

DbSelectArea("SC6")
DbSetOrder(1)
If lRet .AND. (!MsSeek(XFilial("SC6")+cPedRes+cL2Item+cL2Prod) .OR. SC6->C6_LOCAL <> SL2->L2_LOCAL)
	Aviso( STR0019, STR0256, {STR0028} ) // "Aten��o" ### "Item do Or�amento Informado para Venda Progresso n�o encontrado." ### "Ok"
	Conout( STR0019, STR0256, {STR0028} )
	lRet := .F.
EndIf                                                                     

DbSelectArea("SC9")
DbSetOrder(2)
If lRet .AND. (!MsSeek(XFilial("SC9")+SL1->L1_CLIENTE+SL1->L1_LOJA+cPedRes+cL2Item) .OR. SC9->C9_PRODUTO <> cL2Prod .OR. SC9->C9_LOCAL <> SL2->L2_LOCAL)
	Aviso( STR0019, STR0256, {STR0028} ) // "Aten��o" ### "Item do Or�amento Informado para Venda Progresso n�o encontrado." ### "Ok"
	Conout( STR0019, STR0256, {STR0028} )
	lRet := .F.
EndIf                                                                     

If lRet                              
	BeginTran()                                                             
		RecLock("SL2",.F.)
		REPLACE SL2->L2_PRODUTO WITH cB2Prod
		REPLACE SL2->L2_DESCRI  WITH SB1->B1_DESC	
		REPLACE SL2->L2_LOCAL   WITH cB2Local
		MsUnlock("SL2")       
		RestArea(aAreaSL2)
		RecLock("SL2",.F.)
		REPLACE SL2->L2_PRODUTO WITH cB2Prod
		REPLACE SL2->L2_DESCRI  WITH SB1->B1_DESC	
		REPLACE SL2->L2_LOCAL   WITH cB2Local
		MsUnlock("SL2")	                                     
		RecLock("SC6",.F.)
		REPLACE SC6->C6_PRODUTO WITH cB2Prod
		REPLACE SC6->C6_DESCRI  WITH SB1->B1_DESC	
		REPLACE SC6->C6_LOCAL   WITH cB2Local
		MsUnlock("SC6")
		RecLock("SC9",.F.)
		REPLACE SC9->C9_PRODUTO WITH cB2Prod
		REPLACE SC9->C9_LOCAL   WITH cB2Local
		MsUnlock("SC9")	
		RecLock("SB2",.F.)
		REPLACE SB2->B2_QPEDVEN WITH SB2->B2_QPEDVEN+SL2->L2_QUANT
		MsUnlock("SB2")
		DbSelectArea("SB2")  
		DbSetOrder(1)	
		If !MsSeek(XFilial("SB2")+cL2Prod+cLocalGen)
			Aviso( STR0019, STR0257, {STR0028} ) // "Aten��o" ### "Armazem original do Produto generico nao encontrado." ### "Ok" 
			DisarmTransaction()
			EndTran()
			lRet := .F.	
		EndIf
		RecLock("SB2",.F.)
		REPLACE SB2->B2_QPEDVEN WITH SB2->B2_QPEDVEN-SL2->L2_QUANT
		MsUnlock("SB2")	
	EndTran()
	MsUnlockAll()
EndIf
	          
RestArea(aArea)

Return lRet  

/*���������������������������������������������������������������������������
���Funcao    �FTVDT_SUFR � Autor � Vendas Clientes      � Data � 04/07/02���
�������������������������������������������������������������������������ĳ��
���Descricao � Pertencente ao grupo das funcoes de Totais, tem como		  ���
���          � objetivo manipular o valor total da venda	 			  ���
�������������������������������������������������������������������������ĳ��
���Sintaxe   � FTVDT_SUFR(nExp1, uExp2)				                 	  ���
�������������������������������������������������������������������������ı�
���Parametros� nExp1 - O que se deseja manipular o valor 		 		  	���
���          � uExp1 - Qual valor deve conter (em caso de alteracao)	  	���
���          � 															    ���
���          � Para nExp1, tem-se:										  	���
���          � 1 - Titulo												  	���
���          � 2 - Valor												  	���
���          � 3 - Objeto												  	���
���          � 4 - Picture												  	���
���          � 															  	���
���          � Exemplos:												  	���
���          � Para alterar o titulo do valor total						  	���
���          � FTVDT_Total(1, "Valor total da venda")					  	���
���          � 															  	���
���          � Para receber o titulo do valor total						  	���
���          � FTVDT_SUFR(1)								  			  	���
�������������������������������������������������������������������������ĳ��
���Uso		 � FATA701 													  	���
����������������������������������������������������������������������������*/
Function LjVDT_SUFR( nTipo, uParam )

If !Lj7T_VlTp(nTipo, "Lj7Total", uParam)
	Return .F.
EndIf

Return Lj7T_Array( 7, nTipo, uParam )

/*���������������������������������������������������������������������������
���Programa  �FATA701A  �Autor  �Vendas CRM           � Data �  08/16/11  ���
�������������������������������������������������������������������������͹��
���Desc.     � Inicializa as variaveis fiscais para o correto calculo     ���
���          � do Suframa                                                 ���
�������������������������������������������������������������������������͹��
���Retorno   � Valor de Suframa											  ���
�������������������������������������������������������������������������ͺ��
���Uso       � Fata701                                                    ���
���������������������������������������������������������������������������*/
Function LjVDSuframa()
Local aArea			:= GetArea()
Local aAreaSA1      := SA1->(GetArea())
Local aAreaSF4      := SF4->(GetArea())
Local nPosProd		:= aPosCpo[Ascan(aPosCpo,{|x| AllTrim(Upper(x[1])) == "LR_PRODUTO"})][2]			// Posicao da codigo do produto
Local nPosQuant		:= aPosCpo[Ascan(aPosCpo,{|x| AllTrim(Upper(x[1])) == "LR_QUANT"})][2]				// Posicao da Quantidade
Local nPosVlUnit	:= aPosCpo[Ascan(aPosCpo,{|x| AllTrim(Upper(x[1])) == "LR_VRUNIT"})][2]				// Posicao do Valor unitario do item
Local nPosVlItem	:= aPosCpo[Ascan(aPosCpo,{|x| AllTrim(Upper(x[1])) == "LR_VLRITEM"})][2]			// Posicao do Valor do item
Local nPosValDesc	:= aPosCpo[Ascan(aPosCpo,{|x| AllTrim(Upper(x[1])) == "LR_VALDESC"})][2]			// Posicao do valor de desconto
Local nPosDtTes		:= Ascan(aPosCpoDet,{|x| AllTrim(Upper(x[1])) == "LR_TES"})							// Posicao do Codigo do TES  
Local nX        	:= 0                                                                                // Variavel a ser utilizada no FOR
Local nPrcLista 	:= 0                                                                                // Variavel para armazenar o pre�o de lista
Local nValMerc  	:= 0                                                                                // Variavel para armazenar o valor de mercado do item
Local nDesconto 	:= 0                                                                                // Variavel para armazenar o valor de desconto
Local cProduto  	:= ""                                                                               // Variavel para armazenar o codigo do produto
Local nSuframa  	:= 0                                                                                // Variavel para armazenar e retornar o valor de suframa
Local cTpFrete		:= "" //Tipo do Frete

SA1->(DbSetOrder(1))
If SA1->(MsSeek(xFilial("SA1")+M->LQ_CLIENTE+M->LQ_LOJA))

	MaFisSave()
	MaFisEnd() 
	cTpFrete := Lj7TpFrete(M->LQ_CLIENTE,M->LQ_LOJA)
	cTpFrete	:= IIf( Empty(cTpFrete) .And. (M->LQ_TPFRET == "S" .OR. M->LQ_TPFRET == "0"), "S", cTpFrete)

	MaFisIni(M->LQ_CLIENTE,;	// 1-Codigo Cliente/Fornecedor
		M->LQ_LOJA,;			// 2-Loja do Cliente/Fornecedor
		"C",;					// 3-C:Cliente , F:Fornecedor
		"S",;					// 4-Tipo da NF
		SA1->A1_TIPO,;			// 5-Tipo do Cliente/Fornecedor
		Nil,;					// 06-Relacao de Impostos que suportados no arquivo
		Nil,;					// 07-Tipo de complemento
		Nil,;					// 08-Permite Incluir Impostos no Rodape .T./.F.
		Nil,;					// 09-Alias do Cadastro de Produtos - ("SBI" P/ Front Loja)
		"MATA461",;				// 10-Nome da rotina que esta utilizando a funcao
		Nil,;					// 11-Tipo de documento
		Nil,;					// 12-Especie do documento
		Nil,;					// 13-Codigo e Loja do Prospect 
		Nil,;					// 14-Grupo Cliente
		Nil,;					// 15-Recolhe ISS
		Nil,;					// 16-Codigo do cliente de entrega na nota fiscal de saida
		Nil,;					// 17-Loja do cliente de entrega na nota fiscal de saida
		Nil,;					// 18-Informacoes do transportador [01]-UF,[02]-TPTRANS
		NIL,;					//19
		NIL,;					//20
		NIL,;					//21
		NIL,;					//22	
		NIL,;					//23
		NIL,;					//24
		NIL,;					//25
		cTpFrete)				//26
		
	//���������������������������������������������Ŀ
	//�Agrega os itens para a funcao fiscal         �
	//�����������������������������������������������
    If Type("aCols") == "A" .And. nPosProd > 0 .And. nPosValDesc > 0 .And. nPosVlUnit > 0 .And. nPosQuant > 0 .And. nPosDtTes > 0

		For nX := 1 To Len(aCols)
	
			If !aTail(aColsDet[nX]) .AND. !Empty(aCols[nX][nPosProd])		
				
				cProduto := aCols[nX][nPosProd]
				MatGrdPrRf(@cProduto)
	
	            SF4->(dbSetOrder(1))
	            SF4->(MsSeek(xFilial("SF4")+aColsDet[nX][nPosDtTes]))
				//���������������������������������������������������Ŀ
				//�Armazena os valores para inicializar a MATXFIS     �
				//�����������������������������������������������������
				nValMerc  := aCols[nX][nPosVlItem]
				nPrcLista := aCols[nX][nPosVlUnit]
				nDesconto := aCols[nX][nPosValDesc]
				
				//Para os outros paises, este tratamento e feito no programas que calculam os impostos.
				If cPaisLoc=="BRA" .or. GetNewPar('MV_DESCSAI','1') == "2"
					nValMerc  += nDesconto
				Endif
									
				//���������������������������������������������Ŀ
				//�Agrega os itens para a funcao fiscal         �
				//�����������������������������������������������
				MaFisAdd(cProduto,;   				// 1-Codigo do Produto ( Obrigatorio )
					aColsDet[nX][nPosDtTes],;	   	// 2-Codigo do TES ( Opcional )
					aCols[nX][nPosQuant],;  		// 3-Quantidade ( Obrigatorio )
					nPrcLista,;		  				// 4-Preco Unitario ( Obrigatorio )
					nDesconto,; 					// 5-Valor do Desconto ( Opcional )
					"",;	   						// 6-Numero da NF Original ( Devolucao/Benef )
					"",;							// 7-Serie da NF Original ( Devolucao/Benef )
					0,;								// 8-RecNo da NF Original no arq SD1/SD2
					0,;								// 9-Valor do Frete do Item ( Opcional )
					0,;								// 10-Valor da Despesa do item ( Opcional )
					0,;								// 11-Valor do Seguro do item ( Opcional )
					0,;								// 12-Valor do Frete Autonomo ( Opcional )
					nValMerc,;						// 13-Valor da Mercadoria ( Obrigatorio )
					0)
			EndIf
	   	Next nX
	   	
	EndIf
		
	nSuframa:= MaFisRet(, "NF_DESCZF")
	
EndIf

RestArea(aAreaSA1)
RestArea(aAreaSF4)
RestArea(aArea)

Return nSuframa	

/*�����������������������������������������������������������������������������
���Fun��o    �FTVDItDedIcm� Autor � Vendas Clientes       � Data � 13/07/12 ���
���������������������������������������������������������������������������Ĵ��
���Descri��o � Retorna o valor total da dedu��o de ICMS dos itens.		    ���
���			 �															   	���
���������������������������������������������������������������������������Ĵ��
��� Uso      �FTVD701C                                                      ���
�����������������������������������������������������������������������������*/
Function LjVDItDedIcm(lConsidTES)

Local nX := 0
Local nVlrDedIcm := 0

DEFAULT lConsidTES := .F. //Indica se considerar� a TES no calculo do valor total de ICMS desonerado

If Type("aCols") == "A" .And. MaFisFound("NF")
	For nX := 1 To Len(aCols)
		If !aCols[nX][Len(aCols[nX])]
			If lConsidTES 
			 	If MaFisRet(nX, "IT_TS")[26] == "D" //Verifico o campo F4_AGREG da TES
					nVlrDedIcm += MaFisRet(nX,"IT_DEDICM")
				EndIf 
			Else
				nVlrDedIcm += MaFisRet(nX,"IT_DEDICM")	
			EndIf 
		EndIf		
	Next nX
EndIf

Return nVlrDedIcm
          
/*
�������������������������������������������������������������������������������
���Programa  �LjGuardaTef  	  �Autor  �Leandro Lima  � Data �  09/11/2015   ���
���������������������������������������������������������������������������͹��
���Desc.     � Funcao responsavel por armazenar os dados da venda TEF   	���
���          � Todos os principais campos do objeto oTEF sao armazendados   ���	
���          � justamente para que possa ser recuperado posteriormente      ���
�������������������������������������������������������������������������������
*/	
Function LjGuardaTef(cNumeOrc,aTefBKP)
Local lRet 			:= .F.
Local cFile			:= ""
Local cTefDIR		:= "\AUTOCOM\TEF"+cEmpAnt+StrTran(Alltrim(cFilAnt)," ","")
Local nHandle		:= 0
Local cTexto		:= ""
Local nX			:= 0
Local lLoopTef		:= .F.
Local nBkpnX		:= 0
Local nPend			:= 0

DEFAULT cNumeOrc := ""
DEFAULT aTefBKP	 := {}


If lTEFSave

	cFile  := cTefDIR+"\" + cNumeOrc +".CSV"

	// Verifica a exist�ncia do arquivo de recupera��o de transa��es TEF ".CSV"
	// Se existir, renomeia e cria novamente atualizado com os dados de oTef:aRetCartao
	If File( cFile )
		LjEraseTef(cNumeOrc)
	EndIf

	If Type("oTef") <> "U" .AND. Len(oTEF:aRETCARTAO) > 0 .AND.;
		 (oTef:lTefOk .OR. (!oTef:lTefOk .AND. Len(aTefBKP) > 0 ))
		 
		 LjGrvLog(cNumeOrc,"Efetuou a guarda do TEF")
		 	 
		cTexto := "oTef:nCodFuncao"+";"+AllTrim(STR(oTef:nCodFuncao)) +";" 
		cTexto += "oTef:cCupom"+";"+oTef:cCupom +";"
		cTexto += "oTef:cData"+";"+oTef:cData +";"
		cTexto += "oTef:cHora"+";"+oTef:cHora +";"
		cTexto += "oTef:cOperador"+";"+oTef:cOperador+";"
	
		// Caso a transacao total nao esteja OK porem 1 cart�o passou
		lLoopTef := (!oTef:lTefOk .AND. Len(aTefBKP) > 0 )
		
		For nX := 1 to Len(oTef:aRetCartao)
			If lLoopTef
				For nPend := 1 to Len(aTefBKP)
					If oTef:aRetCartao[nx]:DENTRADA		== aTefBKP[nPend]:DENTRADA	  	.AND.;
						oTef:aRetCartao[nX]:NVLRTRANS 	== aTefBKP[nPend]:NVLRTRANS	  	.AND.;
						oTef:aRetCartao[nX]:CFORMA 		== aTefBKP[nPend]:CFORMA	  	.AND.;
						oTef:aRetCartao[nX]:CIDCART 	== aTefBKP[nPend]:CIDCART	  	.AND.;
						oTef:aRetCartao[nX]:NVLRENTRADA	== aTefBKP[nPend]:NVLRENTRADA 	 
						Exit
					EndIf	
				Next nPend
				nBkpnX 	:= nX
				nX		:= nPend 
			EndIf	
			cTexto += "oTef:aRetCartao["+AllTrim(Str(nX))+"]:nParcelas"+";"+AllTrim(STR(oTef:aRetCartao[nX]:nParcelas))+";"
			cTexto += "oTef:aRetCartao["+AllTrim(Str(nX))+"]:cIdCart" +";"+oTef:aRetCartao[nX]:cIdCart+";"
			cTexto += "oTef:aRetCartao["+AllTrim(Str(nX))+"]:cTipCart"+";"+oTef:aRetCartao[nX]:cTipCart+";"
			cTexto += "oTef:aRetCartao["+AllTrim(Str(nX))+"]:cDescAdm"+";"+oTef:aRetCartao[nX]:cDescAdm+";"
			cTexto += "oTef:aRetCartao["+AllTrim(Str(nX))+"]:dEntrada"+";"+DTOS(oTef:aRetCartao[nX]:dEntrada)+";"
			cTexto += "oTef:aRetCartao["+AllTrim(Str(nX))+"]:nVlrTrans"+";"+AllTrim(STR(oTef:aRetCartao[nX]:nVlrTrans))+";"
			cTexto += "oTef:aRetCartao["+AllTrim(Str(nX))+"]:nVlrEntrada"+";"+AllTrim(STR(oTef:aRetCartao[nX]:nVlrEntrada))+";"
			cTexto += "oTef:aRetCartao["+AllTrim(Str(nX))+"]:cAutoriza"+";"+oTef:aRetCartao[nX]:cAutoriza+";"
			cTexto += "oTef:aRetCartao["+AllTrim(Str(nX))+"]:cNsuAutor"+";"+oTef:aRetCartao[nX]:cNsuAutor+";"
			cTexto += "oTef:aRetCartao["+AllTrim(Str(nX))+"]:cPosCart"+";"+oTef:aRetCartao[nX]:cPosCart+";"
			cTexto += "oTef:aRetCartao["+AllTrim(Str(nX))+"]:cForma"+";"+oTef:aRetCartao[nX]:cForma+";"
			cTexto += "oTef:aRetCartao["+AllTrim(Str(nX))+"]:cNsuSitef"+";"+oTef:aRetCartao[nX]:cNsuSitef+";"
			cTexto += "oTef:aRetCartao["+AllTrim(Str(nX))+"]:cCupom01"+";"+oTef:aRetCartao[nX]:cCupom01+";"
			cTexto += "oTef:aRetCartao["+AllTrim(Str(nX))+"]:cCupom02"+";"+oTef:aRetCartao[nX]:cCupom02+";"
			cTexto += "oTef:aRetCartao["+AllTrim(Str(nX))+"]:cCodRede"+";"+oTef:aRetCartao[nX]:cCodRede+";"
			cTexto += "oTef:aRetCartao["+AllTrim(Str(nX))+"]:cDescRede"+";"+oTef:aRetCartao[nX]:cDescRede+";"

			
			
			If lLoopTef
				nX	:= nBkpnX 
			EndIf
		Next nX
		
		cTexto := Left(cTexto, Len(cTexto)-1)
			
		If !File( cFile ) // Caso nao exista cria o arquivo
			MakeDir( "\AUTOCOM" )
			MakeDir( cTefDIR )
			nHandle := FCreate( cFile )
			FClose( nHandle )
		EndIf
		If File( cFile )
			nHandle := FOpen( cFile, 2 )
			FSeek ( nHandle, 0, 2 )			// Posiciona no final do arquivo.
			FWrite( nHandle, cTexto )
			FClose( nHandle )
		EndIf
	EndIf
			
EndIf

Return lRet

/*
�������������������������������������������������������������������������������
���Programa  �LjRecupTef  	  �Autor  �Leandro Lima  � Data �  09/11/2015   ���
���������������������������������������������������������������������������͹��
���Desc.     � Funcao responsavel por armazenar os dados da venda TEF   	���
���          � Todos os principais campos do objeto oTEF sao armazendados   ���	
���          � justamente para que possa ser recuperado posteriormente      ���
�������������������������������������������������������������������������������
*/	
Function LjRecupTef(cNumeOrc,lTemTefPend,aTefBKP)

Local cTefDIR		:= "\AUTOCOM\TEF"+cEmpAnt+StrTran(Alltrim(cFilAnt)," ","")
Local cLinha		:= ""		//variavel de leitura da linha
Local nHdlFile		:= 0	
Local aLinha		:= {}		//Array contendo todos os Registros ja desmembrados
Local lRet			:= .F.
Local cTipVar		:= ""
Local nAt			:= 0
Local nX			:= 0
Local cTef			:= ""
Local cStrTokArr2	:= "StrTokArr2"
Local lFuncOk		:= .F.

DEFAULT cNumeOrc	:= ""
DEFAULT lTemTefPend := .F.
DEFAULT aTefBKP		:= {}

/*	Protegemos a execu��o da fun��o StrTokArr2, pois como o robopatch utiliza a primeira vers�o da build para gerar os pacotes,
	esses pacotes podem n�o possuir essa fun��o, causando o erro "Invalid Type Function" em tempo de execu��o.
*/

lFuncOk := ExistFunc(cStrTokArr2)

If lTEFSave
	
	cFile  := cTefDIR+"\" + cNumeOrc +".CSV"
	If File(cFile) .AND. !lFuncOk
		MsgStop(STR0426 + CRLF + STR0427, STR0428)	//"N�o foi poss�vel recuperar o arquivo de Transa��es TEF." #"Fun��o StrTokArr2 n�o compilada no RPO. Por favor, atualize a build 7.00.131227A com data de gera��o superior a 08/09/2014."#"Erro"	
	EndIf
	nHdlFile := FT_FUse(cFile)
	
	fClose(nHdlFile)
	nHdlFile := FT_FUse(cFile)
	If nHdlFile <> -1 .AND. lFuncOk
		FT_FGoTop()					// Posiciona na primeria linha
		
		While !FT_FEOF()   			// Percorre todo o arquivo
			cLinha := FT_FReadLn() 	// Retorna a linha corrent
			If AT(";",cLinha) == 0
				cLinha := cLinha+ Chr(10)
			EndIf
			cTef += cLinha
			FT_FSKIP()	// Pula para proxima linha  
		End
		FT_FUSE() // Fecha o Arquivo
		fClose(nHdlFile)

		//Se estiver processando um arquivo antes da altera��o, pode dar problemas
		If Right(cTef,1) == ";"
			cTef := Left(cTef, Len(cTef)-1)
		EndIf
	
		aLinha	:=  &cStrTokArr2.(cTef, ";",.T.)
	
		If Type("oTef") <> "U"
			For nX := 1 to Len(aLinha) step 2
				nAt :=  AT("]",aLinha[nX]) + 2
				// Se no arquivo tiver varios cartoes, tem que adicionar no aRetCartao
				If nAt > 2 .AND. Len(oTef:aRetCartao) < Val(SubStr(aLinha[nX],nAt-3,1))
					Aadd(oTef:aRetCartao,{})
					oTef:aRetCartao[Len(oTef:aRetCartao)] := MSRetCartao():New()
				ElseIf nAt == 2  // Caso nao seja aRetCartao 
					nAt :=  AT(":",aLinha[nX]) +1
				EndIf
				cTipVar := SubStr(aLinha[nX],nAt,1)
				
				If UPPER(cTipVar) == "N"
					&(aLinha[nX]) := Val(aLinha[nX+1])
				ElseIf UPPER(cTipVar) == "D"
					&(aLinha[nX]) := STOD(aLinha[nX+1])
				Else 
					&(aLinha[nX]) := aLinha[nX+1]
				EndIf
			Next nX
			If Len(aLinha)  > 0
				LjGrvLog(cNumeOrc,"Efetuou a recuperacao do TEF")
				oTef:lTefOk := .T. 
				aTefBKP := aClone(oTef:aRetCartao)
				lTemTEFPend := .T.
			EndIf	
		EndIf
	ElseIf nHdlFile <> -1
		fClose(nHdlFile)
	EndIf	

EndIf

Return lRet


/*
�������������������������������������������������������������������������������
���Programa  � LjEraseTef  	  �Autor  �                � Data �  25/02/2016 ���
���������������������������������������������������������������������������͹��
���Desc.     � Funcao responsavel por apagar o arquivo .csv que contem os   ���
���          � dados da venda TEF. O Arquivo eh apagado na situacao onde a  ���	
���          � transacao TEF eh cancelada.                                  ���
�������������������������������������������������������������������������������
*/
Function LjEraseTef(cNumeOrc)
Local lRet 		:= .F.
Local cFile		:= ""
Local cTefDIR	:= "\AUTOCOM\TEF"+cEmpAnt+StrTran(Alltrim(cFilAnt)," ","")
Local nRet		:= -1
Local cArqRename:= ""

If lTEFSave
	
	cFile  := cTefDIR + "\" + cNumeOrc + ".CSV"
	cArqRename:= cTefDIR  + "\" + cNumeOrc + "_ARQUIVO_DELETADO_" + DtoS(dDataBase) + "_" + StrTran(Time(),":","") + ".CSV"
	
	If File( cFile )
		//nRet := FERASE(cFile) //Dabas  (Comentei este trecho temporariamente para o Projeto Todimo. Ao inves de apagar o arquivo, apenas o Renomeia para identificar que passou por esta funcao. Assim, mantemos o arquivo para eventuais consultas para identificar problemas. Futuramente sera sempre excluido o arquivo.)
		nRet := FRename(cFile , cArqRename)
		If nRet == -1
			LjGrvLog(cNumeOrc,"Ocorreu uma FALHA ao tentar apagar o arquivo ["+cFile+"] de recuperacao do TEF. [FError: "+ Str(FError(),4)+ "]")
			lRet := .F.
		Else
			LjGrvLog(cNumeOrc,"Apagou o arquivo ["+cFile+"] de recuperacao do TEF")
			lRet := .T.
		Endif
	Else
		LjGrvLog(cNumeOrc,"Arquivo [" + cFile + "] de recuperacao do TEF nao encontrado para realizar sua exclusao")
		lRet := .F.
	EndIf		

EndIf

Return lRet


//------------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} LjExiTEF
Funcao para verificar se existe o arquivo de recupera��o TEF
@author	fabiana.silva
@param     cNumeOrc - Numero do Or�amento
return    lRet Existe o arquivo de recupera��o TEF
@version	P11.80
@since	01/06/2017
/*/
//------------------------------------------------------------------------------------------------------------------------
Function LjExiTEF(cNumeOrc)
Local lRet 		:= .F.
Local cFile		:= ""
Local cTefDIR	:= "\AUTOCOM\TEF"+cEmpAnt+StrTran(Alltrim(cFilAnt)," ","")

If lTEFSave .AND. !Empty(cNumeOrc)
	
	cFile  := cTefDIR + "\" + cNumeOrc + ".CSV"
	lRet := File(cFile)
	
EndIf

Return lRet

