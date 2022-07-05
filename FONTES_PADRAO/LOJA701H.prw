#INCLUDE "PROTHEUS.CH"
#INCLUDE "PARMTYPE.CH"
#INCLUDE "LOJA701H.CH"

/*/{Protheus.doc} LjDelIss()
Rotina para verificar se deve limpar a variavel cCodIss
ou se deve restaurar.
@author  Bruno Almeida
@version P12.1.17
@since   22/11/2018
@return                                                                     
/*/
//--------------------------------------------------------
Function Lj7lCodIss()

Local aAreaSb1 := SB1->(GetArea()) //Guarda a area da SB1
Local nPosProd := aScan(aHeader, { |x| AllTrim(x[02]) == "LR_PRODUTO" }) //Posicao do codigo do produto
Local nPosDtItem := Ascan(aHeader,{|x| AllTrim(Upper(x[02])) == "LR_ITEM"}) // Posicao do numero do item
Local nX := 0 //Variavel de loop
Local lLimpa := .T. //Verifica se deve limpar ou nao a variavel cCodIss
Local lRet := .T. //Variavel de retorno

SB1->(dbSetOrder(1)) //B1_FILIAL+B1_COD 

//Se o item que o usuario esta deletando ou restaurando nao eh servico,
//nem deixo entrar no FOR
If SB1->(dbSeek(xFilial('SB1') + aCols[n][nPosProd])) .AND. !Empty(SB1->B1_CODISS)
	
	//Se o item que o usuario esta deletando ou restaurando eh um servico,
	//preciso verificar se tem mais itens de servicos na venda, caso exista mais itens de servico e nao esta deletado, 
	//verifico se pode restaurar o item ou se pode limpar a variavel cCodIss
	For nX := 1 To Len(aCols)
		
		//Se a posicao que esta o curso e a posicao do nX nao for o mesmo LR_ITEM e se o item nao esta deletado
		If !(aCols[n][nPosDtItem] == aCols[nX][nPosDtItem]) .AND. !aCols[nX][Len(aCols[nX])]
			
			//Se estiver deletando o item entra no IF, senao signifca 
			//que o usuario esta restaurando o item e entao entra no else
			If !aCols[n][Len(aCols[n])]
			
				If SB1->(dbSeek(xFilial('SB1') + aCols[nX][nPosProd])) .AND. !Empty(SB1->B1_CODISS)
					lLimpa := .F.
					Exit
				Else
					lLimpa := .T.
				EndIf
			
			Else
				
			   	If Empty(Lj7GetIss())
			   		lRet := .T.
			   		Exit
			   	ElseIf Empty(SB1->B1_CODISS) .OR. (AllTrim(SB1->B1_CODISS) == AllTrim(Lj7GetIss()))
			   		lRet := .T.
			   	Else 
			   		lRet := .F.
			   		Exit
			   	EndIf									
			
			EndIf
			
		EndIf		
	Next nX
	
	//Se estiver deletando o item entra no IF, senao signifca 
	//que o usuario esta restaurando o item e entao entra no else
	If !aCols[n][Len(aCols[n])]
		//Como o usuario esta deletando o item de servico e nao existe
		//no orcamento outros itens de servico, entao limpo a variavel cCodIss permitindo
		//que o usuario possa lancar outros itens de servico de codigo de iss diferente
		If lLimpa .AND. ExistFunc("Lj7SetIss")
			Lj7SetIss()
		EndIf
	Else
		//Se a variavel lRet for false, significa que existem no orcamento itens de servico ativo
		//que o codigo do iss eh diferente do item que esta tentando restaurar. Neste caso, nao eh permitido restaurar o item
		If !lRet
			Aviso( STR0001  ,STR0002 + Chr(10) + Chr(10) + "B1_CODISS: " + Lj7GetIss() + STR0003 +;
				Chr(10) + "B1_CODISS: " + SB1->B1_CODISS + STR0004, {STR0005} ) //#"Aviso" #"Impossível registrar no mesmo orçamento itens de serviços com código de ISS diferentes!" #" - Código de ISS já registrado no orçamento" #" - Código de ISS que esta tentando registrar" #"Ok"
		Else
			//Se entrou no else, nao existe outros itens de
			//servico ativo com codigo de iss diferente, neste caso alimento a variavel cCodIss
			Lj7SetIss(SB1->B1_CODISS)			
		EndIf						
	EndIf
EndIf

RestArea(aAreaSb1)

Return lRet

//---------------------------------------------------------------------------
/*/{Protheus.doc} Lj7FatRes
Fator para cálculo do valor total da venda.

@type 		function
@author 	Varejo
@since  	21/10/2010
@version 	P12.1.17

@param nVlrTotRe, numérico, Valor total da resreva
@param nVlrTotal, numérico, Valor total
@param nFrete	, numérico, Valor do frete

@return array, Array com fator da venda e fator da reserva
/*/
//---------------------------------------------------------------------------
Function Lj7FatRes(nVlrTotRe, nVlrTotal,nFrete)

Local nFatorRes	:=	0 		//Fator reserva
Local nFatorVen	:=	0		//Fator venda
Local aRet 		:= {}		//Retorno da funcao

Default nVlrTotRe := 1
Default nVlrTotal := 1
Default nFrete	 := 0

//Nas vendas vindas do SIGAFRT, o FRETE precia ser somado ao total da venda
nVlrTotRe += nFrete
nVlrTotal += nFrete

nFatorRes := (nVlrTotRe/nVlrTotal)
nFatorVen := (1-nFatorRes)

If nFatorVen == 0
	aRet := {1, nFatorRes}
Else
	aRet := {nFatorVen, nFatorRes}
Endif

Return aRet

//---------------------------------------------------------------------------
/*/{Protheus.doc} LJTntTefD
Funcao que permite passar um TEF discado novamente ou cancelar todas as 
transações já confirmadas.

@type 		function
@author 	michael.gabriel
@since  	22/08/2017
@version 	P11.8

@param aReb, array, informações do pagamento
@param lSemRede, lógico, indica se tem conexão

@return lógico, Indica se a transação TEF está OK
/*/
//---------------------------------------------------------------------------
Function LJTntTefD(aReb, lSemRede)

Local lTentar	:= .F.
Local lTEFOk	:= .F.
Local aTEFPend	:= {}

Default aReb	:= {}
Default lSemRede:= .F.

//Faz a leitura do arquivo TEFPEND.TEMP localizado na pasta do smartclient
aTEFPend := LJLoadDTEF()
If aScan(aTEFPend, {|x| x[8]=="CONFIRMADA"}) > 0
	lTentar := .T.
EndIf

While lTentar

	lTentar := MsgYesNo("Tentar passar o cartão novamente?" + CRLF + "Se Não, as transações já aprovadas serão canceladas.")

	If lTentar
		lTEFOk := Loja010T(  "V"	, Nil  	, aReb	, Nil  		,;
							Nil		, Nil	, Nil	, Nil		,;
							Nil		, Nil	, Nil	, @lSemRede	,;
							Nil		, Nil	, Nil 	, Nil		,;
							Nil		, Nil	, Nil	, Nil		,;
							lTentar	)
		If !lTEFOk
			//desfaz a ultima operacao PENDENTE
			LOJA010T("F","N")
		EndIf
		//se a transacao TEF foi bem sucedida (lTEFOk = TRUE), sai do loop
		lTentar := !lTEFOk
	Else
		Loja010T("X",,,,,,,,,,,,,,,,,,,,.T./*existe Trn confirmada*/)
	EndIf
EndDo

Return lTEFOk

//---------------------------------------------------------------------------
/*/{Protheus.doc} Lj7RecupPed
Função responsável por remontar o array aPedidos para recuperação.

@type 		function
@author 	rafael.pessoa
@since  	09/06/2017
@version 	P12.1.17

@param cNumPai, caracter, número do orçamento Pai
@param nAuxNcc, numérico, valor da NCC usada
@param aAuxNcc, array, Array com os item de NCC
@param nNccAux, caracter, valor da NCC gerada

@return array, Retorna array de pedidos formatado no Padrao
/*/
//---------------------------------------------------------------------------
Function Lj7RecupPed( cNumPai , nAuxNcc , aAuxNcc , nNccAux)
Local nX		:= 0
Local nY		:= 0
Local aAreaL1	:= SL1->(GetArea())	// Pega a Area posicionada no Orcamento do SL1
Local aAreaL2	:= SL2->(GetArea())	// Pega a Area posicionada no Orcamento do SL2
Local aAreaL4	:= SL4->(GetArea())	// Pega a Area posicionada no Orcamento do SL4
Local aOrcPed   := {}	
Local aSL1		:= {}									
Local aSL2		:= {}
Local aRet		:= {}		
Local cFiltro 	:= ""																 

Default cNumPai	:= ""
Default nAuxNcc	:= 0
Default aAuxNcc	:= {}
Default nNccAux	:= 0

LjGrvLog("Lj7RecupPed","Recupera Pedidos")

//Busca orcamentos filhos através da SL1 pois os registros ja foram excluidos.
cFiltro :=  "L1_FILRES = '" + SL1->L1_FILIAL + "' .AND. " + ;
			"L1_ORCRES = '" + cNumPai   	 + "'  "

DbSelectArea("SL1")
SL1->(dbSetFilter({|| &cFiltro},cFiltro)) 
SL1->(dbGoTop()) 
While SL1->(!Eof()) 
	DbSelectArea("SL2")
	SL2->( DbSetOrder(1) )	//L2_FILIAL+L2_NUM+L2_ITEM+L2_PRODUTO
	SL2->( DbGoTop())
	If SL2->( DbSeek(SL1->L1_FILIAL+SL1->L1_NUM) )
		While SL2->(!EOF()) .AND. (SL2->L2_FILIAL+SL2->L2_NUM == SL1->L1_FILIAL+SL1->L1_NUM)
			If !Empty(SL2->L2_ENTREGA) .And. SL2->L2_ENTREGA <> "2"
				If aScan(aOrcPed ,{ |x| x[1] == SL2->L2_FILRES + SL2->L2_NUM } ) == 0
					Aadd(aOrcPed, {SL2->L2_FILRES + SL2->L2_NUM ,SL2->L2_FILRES , SL2->L2_NUM} )
				EndIf
			EndIf
			SL2->(DbSkip())
		Enddo
	Endif
	SL1->(DbSkip())
Enddo

SL1->(dbClearFilter()) 

For nX := 1 To Len(aOrcPed)

	DbSelectArea("SL1")
	SL1->( DbSetOrder(1) )	//L1_FILIAL+L1_NUM
	If SL1->( DbSeek(aOrcPed[nX][1]) )
	
		For nY := 1 to FCount()
			aAdd( aSL1, { Trim(FieldName(nY)), FieldGet(nY) } )
		Next nY
		
		DbSelectArea("SL2")
		SL2->( DbSetOrder(1) )	//L2_FILIAL+L2_NUM+L2_ITEM+L2_PRODUTO
		If SL2->( DbSeek(aOrcPed[nX][1]) )
			While !EOF() .AND. (SL2->L2_FILIAL+SL2->L2_NUM == aOrcPed[nX][1])
					
				aAdd( aSL2, {} )
				For nY := 1 to FCount()
					aAdd( aSL2[Len(aSL2)], { FieldName(nY), FieldGet(nY) } )
				Next nY
				SL2->( DbSkip() )
			End	
		EndIf
		
		aAdd(aRet			,{	aClone(aSL1) 		, aClone(aSL2)			, aOrcPed[nX][2]		, aOrcPed[nX][3]	,;
			 					.T.					, .F.					, aOrcPed[nX][2]    	, aOrcPed[nX][2]	,;
								 ""	 				, ""					, .F.					, cNumPai			,;
			 					.T.					, .F.					, aOrcPed[nX][2]							})
		
	EndIf	

	// -- Limpeza dos arrays auxiliares 
	aSL1 := {}	
	aSL2 := {}

Next nX

//Recupera NCCs 
DbSelectArea("MDJ")
MDJ->(DbSetOrder(3))//MDJ->MDJ_FILIAL + MDJ->MDJ_NUMORC
If MDJ->(DbSeek(xFIlial("MDJ") + cNumPai ))
	nAuxNcc	:= MDJ->MDJ_NCCUSA	
	nNccAux	:= MDJ->MDJ_NCCGER
	
	DbSelectArea("MDK")
	MDK->( DbSetOrder(2) )	//MDK_FILIAL + MDK_NUMORC
	If MDK->(DbSeek(MDJ->MDJ_FILIAL + MDJ->MDJ_NUMORC))
		While MDK->MDK_FILIAL + MDK->MDK_NUMORC == MDJ->MDJ_FILIAL + MDJ->MDJ_NUMORC
			AAdd( aAuxNcc ,	{ 	.T.					, MDK->MDK_SALDO 	, MDK->MDK_TITULO	, MDK->MDK_DTNCC		,;
	  			  				MDK->MDK_NUMREC		, MDK->MDK_SALDO 	, MDK->MDK_MVMOED	, MDK->MDK_MOEDA  		,;
	  			  				MDK->MDK_PREFIX		, MDK->MDK_PARCEL	, MDK->MDK_TIPO   } )
	  		MDK->(DbSkip())	  				
		End
	EndIf	
	
EndIf

RestArea(aAreaL1)
RestArea(aAreaL2)
RestArea(aAreaL4)

Return aRet

//---------------------------------------------------------------------------
/*/{Protheus.doc} LJ7OrcPen
Função responsável por verificar os orcamentos pendentes de processamento

@type 		function
@author 	alessandrosantos
@since  	19/06/2017
@version 	P12.1.16

@return array, Orcamentos pendentes de processamento da filial
/*/
//---------------------------------------------------------------------------
Function LJ7OrcPen()
Local aRet	 	:= {}
Local cWhere 	:= "" //Condicao da query
Local cAliasTmp	:= GetNextAlias() //Alias Temporario

//Condicional query	
cWhere := "% "
cWhere += " L1_FILIAL = " + "'" + xFilial("SL1") + "'"
cWhere += " AND L1_SITUA = 'RX'"
cWhere += " AND SL1.D_E_L_E_T_ = ''"			
cWhere += " %"
			
//Executa a query
BeginSql alias cAliasTmp
	SELECT 
		L1_NUM 		
	FROM %table:SL1% SL1							
		WHERE %exp:cWhere%		   			
EndSql	

(cAliasTmp)->(dbGoTop())

//Busca Orcamentos em aberto
While (cAliasTmp)->(!EOF())	 
	aAdd(aRet, (cAliasTmp)->L1_NUM)	
	(cAliasTmp)->(dbSkip())	
EndDo

//Fecha arquivo temporario			
If (Select(cAliasTmp) > 0)
	(cAliasTmp)->(dbCloseArea())
EndIf

Return aRet

//---------------------------------------------------------------------------
/*/{Protheus.doc} Lj7DelOrc
Função responsável por excluir orcamentos para estorno de transação da LJ7Pedido em casos de erro 

@type 		function
@author 	rafael.pessoa
@since  	12/05/2017
@version 	P12.1.16

@param aOrcs, array, Array com a relação de orçamentos a serem excluídos

@return Nil, Retorno nulo
/*/
//---------------------------------------------------------------------------
Function Lj7DelOrc( aOrcs )
Local nX		:= 0
Local aAreaL1	:= SL1->(GetArea())	// Pega a Area posicionada no Orcamento do SL1
Local aAreaL2	:= SL2->(GetArea())	// Pega a Area posicionada no Orcamento do SL2
Local aAreaL4	:= SL4->(GetArea())	// Pega a Area posicionada no Orcamento do SL4
Local nRecL1 	:= SL1->(Recno())	// Guarda recno da SL1

Default aOrcs	:= {}

LjGrvLog("Lj7DelOrc","Orcamentos para exclusão ",aOrcs)

If Len(aOrcs) > 0
	For nX := 1 to Len( aOrcs )
		DbSelectArea("SL1")
		SL1->(DbSetOrder(1)) //"L1_FILIAL+L1_NUM"
		If SL1->(DbSeek( aOrcs[nX][1] + aOrcs[nX][2] ))
				
			//Verifica se houve geracao de nota em casos de queda do sistema para realizar exclusão			
			DbSelectArea("SF2")
			SF2->(DbSetOrder(1))//F2_FILIAL+F2_DOC+F2_SERIE+F2_CLIENTE+F2_LOJA+F2_FORMUL+F2_TIPO
			If SF2->(DbSeek(aOrcs[nX][1]+ SL1->L1_DOC + SL1->L1_SERIE))
				MafisSave()
				MafisEnd()
				LJ140Exc( "SL1", nRecL1, 2 ,,,,,,,,.T.)
				MafisRestore()
			Endif
			
			While !SL1->(Eof()) .AND. (SL1->L1_FILIAL + SL1->L1_NUM ) == ( aOrcs[nX][1] + aOrcs[nX][2] )
				RecLock("SL1",.F.)
				SL1->(DbDelete())
				SL1->(MSUNLOCK())
			   	SL1->(DbSkip())
			End
		EndIf
	
		DbSelectArea("SL2")
		SL2->(DbSetOrder(1)) //"L2_FILIAL+L2_NUM"
		If SL2->(DbSeek( aOrcs[nX][1] + aOrcs[nX][2] ))
			While !SL2->(Eof()) .AND. (SL2->L2_FILIAL + SL2->L2_NUM ) == ( aOrcs[nX][1] + aOrcs[nX][2] )
				RecLock("SL2",.F.)
				SL2->(DbDelete())
				SL2->(MSUNLOCK())
			   	SL2->(DbSkip())
			End
		EndIf
	
		DbSelectArea("SL4")
		SL4->(DbSetOrder(1)) //"L4_FILIAL+L4_NUM+L4_ORIGEM"
		If SL4->(DbSeek( aOrcs[nX][1] + aOrcs[nX][2] ))
			While !SL4->(Eof()) .AND. (SL4->L4_FILIAL + SL4->L4_NUM ) == ( aOrcs[nX][1] + aOrcs[nX][2] )
				RecLock("SL4",.F.)
				SL4->(DbDelete())
				SL4->(MSUNLOCK())
			   	SL4->(DbSkip())
			End
		EndIf
	Next nX
EndIf	

RestArea(aAreaL1)
RestArea(aAreaL2)
RestArea(aAreaL4)

Return Nil

//---------------------------------------------------------------------------
/*/{Protheus.doc} Lj7EstPed
Função responsável por estornar gravacoes realizadas pela funcao LJ7Pedido em casos de erro 

@type 		function
@author 	rafael.pessoa
@since  	02/03/2017
@version 	P12.1.16

@param cNumOrcPai, caracter, Número do orçamento Pai
@param lJob, lógico, Indica se é execução via JOB
@param aOrcRetira, array, Array com a relação de orçamentos do tipo RETIRA
@param aPedidos, array, Array com a relação de orçamentos com ENTREGA
@param lTefOk, lógico, Flag que indica se foi venda com TEF

@return Nil, Retorno nulo
/*/
//---------------------------------------------------------------------------
Function Lj7EstPed(	cNumOrcPai, lJob, aOrcRetira, aPedidos, lTefOk )
Local nX		 	:= 0
Local aAreaL1	 	:= SL1->(GetArea()) // Pega a Area posicionada no Orcamento do SL1
Local aAreaL2	 	:= SL2->(GetArea())	// Pega a Area posicionada no Orcamento do SL2
Local aAreaL4	 	:= SL4->(GetArea())	// Pega a Area posicionada no Orcamento do SL4
Local aOrcDel    	:= {}

Default cNumOrcPai	:= ""
Default lJob		:= .F.
Default aOrcRetira	:= {}
Default aPedidos	:= {}
Default lTefOk		:= .F.

LjGrvLog(cNumOrcPai,"Busca o orcamento pai para estorno",xFilial("SL1"))
DbSelectArea("SL1")
SL1->(DbSetOrder(1)) //"L1_FILIAL+L1_NUM"
If SL1->(DbSeek( xFilial("SL1") + cNumOrcPai ))

	If RecLock("SL1",.F.)

		SL1->L1_EMISNF 		:= StoD("  /  /  ")
		SL1->L1_NUMMOV 		:= ""	
		SL1->L1_TIPO 		:= ""	
		SL1->L1_OPERADO 	:= ""
		SL1->L1_DOCPED 		:= ""	
		SL1->L1_SERPED 		:= ""
		
		If lTefOk
			SL1->L1_VENDTEF 		:= ""	
			SL1->L1_DATATEF 		:= ""	
			SL1->L1_HORATEF 		:= ""
			SL1->L1_DOCTEF 			:= ""
			SL1->L1_AUTORIZ 		:= ""
			SL1->L1_INSTITU 		:= ""
			SL1->L1_DOCCANC 		:= ""
			SL1->L1_DATCANC 		:= ""
			SL1->L1_HORCANC 		:= ""
			SL1->L1_NSUTEF 			:= ""
			SL1->L1_TIPCART 		:= ""
		EndIf
	
		SL1->(MSUNLOCK())
	
	EndIf	
	
EndIf	

DbSelectArea("SL4")
SL4->(DbSetOrder(1)) //"L4_FILIAL+L4_NUM+L4_ORIGEM"
If SL4->(DbSeek( xFilial("SL4") + cNumOrcPai ))
	While !SL4->(Eof()) .AND. (SL4->L4_FILIAL + SL4->L4_NUM ) == (xFilial("SL4") + cNumOrcPai )

		RecLock("SL4",.F.)

		SL4->L4_ADMINIS 		:= ""
		SL4->L4_NUMCART 		:= ""
		SL4->L4_AGENCIA 		:= ""
		SL4->L4_CONTA 			:= ""	
		SL4->L4_RG		 		:= ""
		SL4->L4_TELEFON 		:= ""
		SL4->L4_COMP    		:= ""
		SL4->L4_TERCEIR 		:= .F.
		SL4->L4_NOMECLI 		:= ""
		SL4->L4_VENDTEF 		:= ""
		SL4->L4_DATATEF 		:= ""
		SL4->L4_HORATEF 		:= ""
		SL4->L4_DOCTEF  		:= ""
		SL4->L4_AUTORIZ 		:= ""
		SL4->L4_INSTITU 		:= ""
		SL4->L4_DOCCANC 		:= ""
		SL4->L4_DATCANC 		:= ""
		SL4->L4_HORCANC 		:= ""
		SL4->L4_NSUTEF  		:= ""
		SL4->L4_TIPCART 		:= ""
		SL4->L4_FORMPG 			:= ""
				
		SL4->(MSUNLOCK())
	   	SL4->(DbSkip())

	End
EndIf

//Exclui Orcamentos Retira
LjGrvLog(cNumOrcPai,"Orcamentos filhos RETIRA ",aOrcRetira)
If Len(aOrcRetira) > 0
	For nX := 1 to Len( aOrcRetira )
		AADD(aOrcDel,{ xFilial("SL1") , aOrcRetira[nX] })
	Next nX
	Lj7DelOrc(aOrcDel)
EndIf	

//Exclui orcamentos Pedidos
LjGrvLog(cNumOrcPai,"Orcamentos filhos FILHOS ",aPedidos)
If Len(aPedidos) > 0
	For nX := 1 to Len( aPedidos )
		AADD(aOrcDel,{ aPedidos[nX][3] , aPedidos[nX][4] })
	Next nX
	Lj7DelOrc(aOrcDel)
EndIf	

RestArea(aAreaL1)
RestArea(aAreaL2)
RestArea(aAreaL4)

Return Nil

//---------------------------------------------------------------------------
/*/{Protheus.doc} LJ7GPedVen
Função responsável por gerar o pedido de venda

@type 		function
@author 	felipe.martinez
@since  	08/03/2017
@version 	P12.1.14

@param aPedidos, array, Array com os pedidos a serem gerados

@return Lógico, .T.-> Gerado com suesso / .F.-> Não gerados
/*/
//---------------------------------------------------------------------------
Function LJ7GPedVen(aPedidos)
Local lRet 			:= .T.
Local lCen1VFE		:= .F.
Local lJob			:= .F.
Local lExistVfe		:= .F.							// Verifica se cenario contempla VFE
Local lAlterOrc		:= .F.
Local lAvCred		:= .F.
Local aRetEnt		:= {}
Local aAreaCDL		:= {}
Local aSl1			:= {}
Local aSl2			:= {}
Local cCliente		:= ""
Local cLojaCli		:= ""
Local cNumPai		:= ""
Local cFilResC0		:= ""
Local cFilLoc		:= ""
Local cFilFilho		:= ""
Local cNumFilho		:= ""
Local cFilReserv	:= ""
Local nI			:= 1
Local lCentroDL		:= SuperGetMv("MV_LJCDL",, .F.)	// Parametro de controle VFE
Local cBkpFilAnt    := cFilAnt

Default aPedidos	:= {}

For nI := 1 To Len(aPedidos)

	lExistVfe	:= .F.
	lCen1VFE	:= .F.
	aSl1		:= aClone(aPedidos[nI][1])
	aSl2		:= aClone(aPedidos[nI][2])
	cFilFilho	:= aPedidos[nI][3]
	cNumFilho	:= aPedidos[nI][4]
	lJob		:= aPedidos[nI][5]
	lAlterOrc	:= aPedidos[nI][6]
	cFilLoc		:= aPedidos[nI][7]
	cFilReserv	:= aPedidos[nI][8]
	cCliente	:= aPedidos[nI][9]
	cLojaCli	:= aPedidos[nI][10]
	cNumPai		:= aPedidos[nI][12]
	lAvCred		:= aPedidos[nI][13]
	cFilResC0	:= aPedidos[nI][15]

    //Atualiza a filial com a filial do pedido filho para gerar tudo relacionado ao pedido para na filial correta  
    cFilAnt     := cFilFilho

	If lCentroDL //Tratamento VFE - Verifica se funcionalidade esta habilitada
		lExistVfe	:= aPedidos[nI][11]
		lCen1VFE	:= aPedidos[nI][14]
	EndIf

	LjGrvLog(cNumPai,"Realizando a geracao dos pedidos para o orcamento:'" + cFilFilho + "/" + cNumFilho + "'")

	aRetEnt := Lj7GeraEnt(	aSl1	, aSl2		, cFilFilho	, cNumFilho	,;
							lJob 	, lAlterOrc	, cFilLoc	, cFilReserv,;
							cCliente, cLojaCli	, lExistVfe	, cNumPai	,;
							lAvCred	)
	lRet := aRetEnt[1]
	If lRet
		//Gera Pedidos de Vendas VFE
		If lCentroDL .And. lExistVfe
			aAreaCDL:= GetArea() //Guarda a area atual
			If lCen1VFE //Especifico para Minas Gerais = Cenario 1
		  		//Simples Faturamento
		 		LJ7GerPedVFE("1",aSl1,aSl2,cFilReserv, cFilResC0, cFilLoc)
				//Remessa Entrega Futura
				LJ7GerPedVFE("2",aSl1,aSl2,cFilReserv, cFilResC0, cFilLoc)
				//Remessa por Conta e Ordem de Estabelecimento Showroom
				LJ7GerPedVFE("3",aSl1,aSl2,cFilReserv, cFilResC0, cFilLoc)
				//Transferencia Simbolica
				LJ7GerPedVFE("4",aSl1,aSl2,cFilReserv, cFilResC0, cFilLoc)
			Else
				//Demais estados = Cenario 2
		 	  	LJ7GerPedVFE("5",aSl1,aSl2,cFilReserv, cFilResC0, cFilLoc)
		 	Endif
			RestArea(aAreaCDL)
		EndIf
		LjGrvLog(cNumPai,"Pedido de venda gerado com sucesso para o orcamento: " + aRetEnt[2])
        
        If lRet .And. FWHasEAI("MATA410B", .T., , .T.)
	        LjGrvLog("LJ7PEDIDO" , "Chamada IntegDef - MATA410B.")
            FwIntegDef("MATA410B",,,, "MATA410B")
        Endif

	Else
		LjGrvLog(cNumPai,"Problemas ao gerar o pedido de venda")
		Exit
	EndIf

    //Restaura para a filial que chamou a rotina
    cFilAnt := cBkpFilAnt

Next nI

Return lRet

//---------------------------------------------------------------------------
/*/{Protheus.doc} LjVldUlVnd
Valida se a ultima venda está de acordo com o ECF caso o ECF esteja OK e a 
venda não OK ( queda de energia) cancelo o ultimo cupom.

@type 		function
@author 	Varejo
@since  	13/06/2016
@version 	P11.8

@return Lógico, Retorna se cancelou ou não o cupom

@obs	 Nao precisa validar o CCD pois se este for impresso as tabelas
		 do sistema já estão finalizadas ( ou seja venda finalizada )
/*/
//---------------------------------------------------------------------------
Function LjVldUlVnd()
Local aAreaSL1		:= {}
Local nRet    		:= 0
Local nTamDoc		:= TamSX3("L1_DOC")[1]
Local nIndice		:= 0
Local cNumCup		:= Space(nTamDoc)
Local lRet     		:= .T.   							// .T. - Cancelamento com sucesso; .F. - Erro no cancelamento do cupom
Local lFindReg		:= .F.
Local cCodEst		:= ""
Local cIndex		:= ""
Local cIndFName		:= ""
Local cChave		:= ""
Local cCond			:= ""
Local cQuery		:= ""
Local cAlSL1		:= "SL1TMP"

DbSelectArea("SL1")
aAreaSL1 := SL1->(GetArea())

nRet	:= IFPegCupom( nHdlECF,@cNumCup )
cNumCup	:= PADR(cNumCup,nTamDoc) // Restaura o tamanho da variavel cNumcup para a comparação com L1_DOC
If nRet <> 0
	HELP(' ',1,'FRT011')	      // "Erro com a Impressora Fiscal. Operação não efetuada.", "Atenção"
	lRet := .F.
Endif

If lRet
	cCodEst := LjGetStation("CODIGO")
	
	#IFDEF TOP
		If Select(cAlSL1) > 0
			(cAlSL1)->(DbCloseArea())
		EndIf
		
		cQuery := " SELECT "
		cQuery += " L1_NUM "
		cQuery += " FROM " + RetSQLName("SL1") + " SL1 "
		cQuery += " WHERE "
		cQuery += " SL1.D_E_L_E_T_ = '' AND SL1.L1_FILIAL = '"+xFilial("SL1")+"'"
		cQuery += " AND SL1.L1_NUMCFIS = '" + cNumCup + "' AND SL1.L1_ESTACAO = '" + cCodEst + "'"
		cQuery += " AND SL1.L1_DOC = '' "
		
		cQuery := ChangeQuery(cQuery)
		DBUseArea(.T., "TOPCONN", TCGenQry(,,cQuery),cAlSL1, .F., .T.)
		(cAlSL1)->(DbGoTop())
		
		If !Empty(AllTrim((cAlSL1)->L1_NUM))
			SL1->(DbSetOrder(1))
			lFindReg := SL1->(DbSeek(xFilial("SL1")+(cAlSL1)->L1_NUM))
		EndIf
		
		(cAlSL1)->(DbCloseArea())
	#ELSE
		cIndex	:= CriaTrab(Nil,.F.)
		cChave	:= "L1_FILIAL+L1_NUMCFIS+L1_ESTACAO"
		cCond	:= "L1_FILIAL = '"+xFilial("SL1")+"' .AND. L1_NUMCFIS = '" + cNumCup + "' .AND. L1_ESTACAO = '" + cCodEst + "' .AND. Empty(Trim(L1_DOC)) "
		IndRegua("SL1",cIndex,cChave,,cCond)
		DbSelectArea("SL1")
		nIndice := RetIndex("SL1")
		cIndFName := cIndex+OrdBagExt()
		SL1->(DbSetIndex(cIndFName))
		SL1->(DbSetOrder(nIndice+1))
		lFindReg := SL1->(DbSeek(xFilial("SL1")+cNumCup+cCodEst))				
	#ENDIF
	
	If lFindReg
		RecLock("SL1",.F.)
		REPLACE SL1->L1_NUMCFIS WITH ""	//Retorno o campo ao normal para evitar algum dado impreciso posteriormente
		SL1->(MsUnlock())

		nRet := IFCancCup( nHdlECF )
	EndIf
	
	If !Empty(cIndex)
		FErase(cIndFName)
		SL1->(DbCloseArea())
		
		DbSelectArea("SL1")
		RetIndex("SL1")
		SL1->(DbClearFilter())
	EndIf
EndIf

RestArea(aAreaSL1)

lRet := (nRet == 0)

Return lRet

//---------------------------------------------------------------------------
/*/{Protheus.doc} LjCodSiTEF
Retorna informacoes da tabela MDE referente ao codigo de retorno do SiTEF.

@type 		function
@author 	Varejo
@since  	08/03/2016
@version 	P11.8

@param cOpc, caracter, Opcao de busca a ser realizada (MDE_TIPO). Ex.: CC=Cartao de Credito; CD=Cartao de Debito; RD=Rede

@return array, Retorna informacoes da tabela MDE referente ao codigo de retorno do SiTEF.
/*/
//---------------------------------------------------------------------------
Function LjCodSiTEF(cOpc)
Local aRet 		:= {}

DbSelectArea("MDE")

MDE->(DbSetOrder(3)) // MDE_FILIAL+MDE_TIPO+MDE_CODSIT
If MDE->(DbSeek(xFilial("MDE")+cOpc))
	While !MDE->(EoF()) .And. xFilial("MDE")+cOpc == MDE->MDE_FILIAL+MDE->MDE_TIPO
		Aadd( aRet, { AllTrim(MDE->MDE_CODSIT), AllTrim(MDE->MDE_DESC) } )
		MDE->(DbSkip())
	End
EndIf

Return aRet

//---------------------------------------------------------------------------
/*/{Protheus.doc} LjxPropRes
Retorna valor proporcional do para o item atual

@type 		function
@author 	Varejo
@since  	20/08/2015
@version 	P11.8

@param nReserva, numérico, Valor total dos itens
@param nValor, numérico, Valor do frete, seguro ou despesa
@param lScreen, lógico, indica se é execução com interface ou em JOB
@param nDescProp, numérico, Valor do desconto proporcional
@param nAcresProp, numérico, Valor do acréscimo proporcional

@return numérico, Valor proporcional calculado
/*/
//---------------------------------------------------------------------------
Function LjxPropRes(nReserva, nValor, lScreen, nDescProp, nAcresProp)
Local nValItem 		:= 0    // Valor do item
Local nVlProp 		:= 0	// Valor proporcional do item

Default nReserva	:= 0
Default nValor		:= 0
Default lScreen		:= .T.  // Verifica se foi chamada pela LJGRVBATCH
Default nDescProp	:= 0	// Desconto proporcional do item
Default nAcresProp  := 0	// Acrescimo proporcional do item

//Quando e chamada pela LjGrvBatch a soma dos itens (nReserva) ja esta considerando o desconto proporcional.
If !lScreen
	//Pega o Valor do Item ja calculado do PDV
	nValItem := SL2->L2_VLRITEM
Else
	nValItem := (SL2->L2_VRUNIT * SL2->L2_QUANT) - nDescProp + nAcresProp
EndIf

nVlProp  := (nValItem / nReserva) * nValor

Return nVlProp

//---------------------------------------------------------------------------
/*/{Protheus.doc} LjxTotRes
Retorna o total dos itens de reserva.

@type 		function
@author 	Varejo
@since  	20/08/2015
@version 	P11.8

@return numérico, Valor Total dos Itens de reserva
/*/
//---------------------------------------------------------------------------
Function LjxTotRes()
Local aArea 	:= GetArea()
Local nReserva	:= 0
Local cL2Entrega:= ""

DbSelectArea( "SL2" )
SL2->(DbSetOrder( 1 ))
SL2->(DbSeek( xFilial( "SL2" ) + SL1->L1_NUM ))

While !SL2->(Eof()) .AND. ( xFilial( "SL2" ) + SL1->L1_NUM == SL2->L2_FILIAL + SL2->L2_NUM )
	
	cL2Entrega := AllTrim(SL2->L2_ENTREGA)
	
	If !Empty(cL2Entrega) .And. (cL2Entrega <> "2") 
		nReserva += SL2->L2_VLRITEM
	EndIf
	
	SL2->(DbSkip())
End
RestArea(aArea)

Return nReserva

/*/{Protheus.doc} LjEspecieNF
Função que verifica qual o tipo de Especie de Nota Fiscal.

@type 		function
@author 	Varejo
@since  	23/06/2015
@version 	P11.8

@return caracter, Espécie do Documento Fiscal
/*/
//---------------------------------------------------------------------------
Function LjEspecieNF()
Local lNFServ	:= .F.
Local cEspecie	:= ""
 
If LjEmitNFCe()
	//Especie da NFC-e
	cEspecie	:= "NFCE"
ElseIf lNFServ
	//Para NF de "Servico" grava a especie como RPS (Recibo Provisorio de Servico)
	cEspecie	:= "RPS"
ElseIf LjAnalisaLeg(18)[1]
	//Se for o Estado de Piauí, grava ECF
	cEspecie	:= "ECF"
Else 
	// Especie do tipo Cupom Fiscal
	cEspecie	:= "CF"
EndIf

Return cEspecie

//---------------------------------------------------------------------------
/*/{Protheus.doc} Lj701CIPI
Retorna o preço de venda do Item (abatido o valor do IPI)

@type 		function
@author 	Varejo
@since  	10/03/2014
@version 	P11.8

@param cProduto, caracter, Código do Produto
@param nPrecoIPI, numérico, Preço do IPI
@param lMVRNDIPI, lógico, Arredonda/Trunca IPI
@param cTES, caracter, TES e-commerce
@param nCasasIPI, numérico, Casas do IPI

@return numérico, Preço de venda do Item (abatido o valor do IPI)
/*/
//---------------------------------------------------------------------------
Function Lj701CIPI(cProduto, nPrecoIPI, lMVRNDIPI, cTES, nCasasIPI)
Local aArea 		:= GetArea()
Local nValIPIEn 	:= 0 //Valor IPI Embutido
Local aAreaSB1 		:= SB1->(GetArea())
Local aAreaSF4 		:= {}

Default nPrecoIPI 	:= 0
Default cProduto 	:= ""
Default lMVRNDIPI 	:= SuperGetMV("MV_RNDIPI", NIL, .F.)
Default cTES 		:= SuperGetMV("MV_LJTESPE", NIL, "501")
Default nCasasIPI 	:= 0

DbSelectArea("SB1")
SB1->( DbSetOrder(1) )	//B1_FILIAL + B1_COD
If SB1->( DbSeek(xFilial("SB1") + cProduto) )  .AND. Substr(cTES,1, 1) <> "&"
	aAreaSF4 := SF4->(GetArea())
	
	//Busca na TES de pedido se está sinalizado para calcular IPI
	SF4->(DbSetOrder(1)	)
	If SF4->(DbSeek(xFilial("SF4") + cTES ))  .And. SF4->(!Empty(F4_IPI) .And. F4_IPI <> "N")

		nValIPIEn	:=  nPrecoIPI   * ( SB1->B1_IPI/100)	//Apura a Base do IPI

		If lMVRNDIPI
			nValIPIEn := Round(nValIPIEn,nCasasIPI)     //Trabalha com arredondamento
		Else
			nValIPIEn := NoRound(nValIPIEn,nCasasIPI)   //Trabalha com truncamento
		EndIf

	EndIf
	RestArea(aAreaSF4)
EndIf

RestArea(aAreaSB1)

RestArea(aArea)

Return nValIPIEn

//---------------------------------------------------------------------------
/*/{Protheus.doc} LjItGE
Função responsável em verificar se o item é do tipo Garantia Estendida

@type 		function
@author 	Varejo
@since  	17/01/2014
@version 	P11.5

@param cProduto, caracter, Codigo do Produto que sera validado

@return lógico, Retorna se o item é do tipo Garantia Estendida
/*/
//---------------------------------------------------------------------------
Function LjItGE(cProduto)
Local lRet		:= .F.								//Define se o item eh do tipo Garantia Estendida
Local cTipoGE	:= SuperGetMV("MV_LJTPGAR",,"GE")	//Tipo do produto Garantia Estendida
Local nTmB1Tipo	:= 0								//Tamanho do campo B1_TIPO
Local aB1Area	:= SB1->( GetArea() )

Default cProduto:= ""

//Armazenamos em cache o tamanho do campo B1_TIPO
nTmB1Tipo := GetSx3Cache("B1_TIPO","X3_TAMANHO")

cTipoGE := PadR(cTipoGE, nTmB1Tipo)

If nModulo == 23
	DbSelectArea("SBI")
	SBI->( DbSetOrder(2) )	//BI_FILIAL + BI_TIPO + BI_COD
	lRet := SBI->( MsSeek(xFilial("SBI") + cTipoGE + cProduto) )
Else
	DbSelectArea("SB1")
	SB1->( DbSetOrder(2) )	//B1_FILIAL + B1_TIPO + B1_COD
	If SB1->( MsSeek(xFilial("SB1") + cTipoGE + cProduto) )
		lRet := .T.
	EndIf
EndIf

RestArea(aB1Area)

Return lRet

//---------------------------------------------------------------------------
/*/{Protheus.doc} LjChkNFS
Verifica se o parametro MV_LJVFNFS existe e qual seu conteúdo. Se o parâmetro existir e 
for verdadeiro ou se o parâmetro não foi criado e a filial pertencer ao estado de MG 
ativa o processo de geração de NFS na venda futura (legislação estadual)  

@type 		function
@author 	Varejo
@since  	04/12/2013
@version 	P11

@param cProduto, caracter, Codigo do Produto que sera validado

@return lógico, Retorna se ativa o processo de geração de Nota de Simples Faturamento na venda futura
/*/
//---------------------------------------------------------------------------
Function LjChkNFS(aSL2)
Local lRet			:= .F.
Local lLjVfNFS		:= SuperGetMV("MV_LJVFNFS",,.F.) //Habilita ou desabilita a utilização da emissao de nota na venda futura.
Local nX			:= 0
Local nPos			:= 0
Local lLjSimpFat    := ExistBlock("LjSimpFat")		// VerIfica se existe o PE LjSimpFat
  
DEFAULT aSL2		:= {}

LjGrvLog( NIL, " Verifica geração de Nota de Simples Faturamento - Parâmetro MV_LJVFNFS", lLjVfNFS)

If lLjVfNFS
	lRet := .T.
	If Len(aSL2) > 0
		If (nPos := ascan(aSL2[1], {|x| Alltrim(Upper(x[1])) == "L2_ENTREGA"})) > 0
			For nX := 1 To Len(aSL2)
				If aSL2[nX][nPos][2] <> '3'
					lRet := .F.
				Endif
			Next nX
			If lRet .And. lLjSimpFat
				lRet	:= ExecBlock( "LjSimpFat", .F., .F., aSL2)
			EndIf
		EndIf
	EndIf
EndIf

Return lRet 

//---------------------------------------------------------------------------
/*/{Protheus.doc} Lj7PesqAltMot
Pesquisa se existe um motivo de desconto e se existir altera

@type 		function
@author 	Varejo
@since  	02/12/2011
@version 	P11

@param cSerie, caracter, Série do documento
@param cDoc, caracter, Número do documento
@param cNumOrc, caracter, Número do Orçamento

@return lógico, Retorna se existe um motivo de desconto
/*/
//---------------------------------------------------------------------------
Function Lj7PesqAltMot( cSerie , cDoc , cNumOrc )
Local lRet	   	 := .F.
Local lMotDesc   := Lj7Mv_Desc()      		// Testa se na retaguarda tbem existe o motivo de desconto
Local cDocPesq	 := ""
Local nTamNumOrc := TamSx3("MDU_NUMORC")[1]

If lMotDesc
	cDocPesq	:= PadR(cNumOrc,nTamNumOrc)
	lRet		:= .T.

	DbSelectArea("MDU")
	MDU->(DbSetOrder(2)) //MDU_FILIAL+MDU_DOC+MDU_SERIE+MDU_PRODUT
	If MDU->(DbSeek(xFilial("MDU") + cDoc + cSerie)) //Verifica se existe já na retaguarda um motivo de desconto já importado pelo PDV para a mesma venda
		lRet := .F.
	EndIf

	If lRet

		MDU->(DbSetOrder(3)) //MDU_FILIAL+MDU_NUMORC
		If MDU->(DbSeek(xFilial("MDU") + cDocPesq))

			While !MDU->(Eof()) .AND. MDU->MDU_NUMORC == cDocPesq

				RecLock("MDU",.F.)
				REPLACE MDU->MDU_STATUS WITH ""
		    	REPLACE MDU->MDU_NUMORC WITH cNumOrc
				REPLACE MDU->MDU_DOC   	WITH cDoc       // Atualiza o campo doc que está em branco e quando a venda é finaliza este é preenchido
				SerieNfId("MDU",1,"MDU_SERIE",dDataBase,LjEspecieNF(),cSerie)	// Atualiza o campo serie que está em branco e quando a venda é finalizada este é preenchido
				MDU->(MsUnlock())

				MDU->(DbSkip())
			EndDo

		Else
			lRet := .F.
		EndIf
	EndIf

EndIf

Return lRet

//---------------------------------------------------------------------------
/*/{Protheus.doc} LC701QtdSC
Retorna quantidade da solicitacao de compras do item

@type 		function
@author 	Varejo
@since  	17/02/2011
@version 	P11

@param cNSolCom, caracter, Número da solicitação de compras
@param cProduto, caracter, Código do produto

@return numérico, Retorna quantidade da solicitacao de compras do item
/*/
//---------------------------------------------------------------------------
Function LC701QtdSC(cNSolCom, cProduto)
Local nQtdeSC       := 0				// Quantidade da solicitacao de compras
Local lContinua		:= .T.            	// Controla continuacao do processo

Default	cNSolCom	:= ""  				// Numero da solicitacao de compras
Default	cProduto	:= ""             	// Codigo do produto

// Posiciona na solicitacao de compras gerada para o item da venda
DbSelectArea("SC1")
DbSetOrder(1) //C1_FILIAL+C1_NUM+C1_ITEM
If DbSeek(xFilial("SC1") + cNSolCom)
	While !Eof() .AND. (SC1->C1_NUM == cNSolCom) .AND. lContinua
    	If SC1->C1_PRODUTO == cProduto
       		nQtdeSC := 	SC1->C1_QUANT
			lContinua := .F.
		Endif
		DbSkip()
	End
Endif

// Validacao de seguranca, pois nao  pode retornar menor que zero
If nQtdeSC < 0
	nQtdeSC := 0
EndIf

Return nQtdeSC

//---------------------------------------------------------------------------
/*/{Protheus.doc} Lj7PegCupArg
Pega o numero do cupom ou fatura da impressora (Localizaçoes Argentina)  

@type 		function
@author 	Varejo
@since  	13/01/2009
@version 	P11

@param nHdlECF, numérico, Número do handle do ECF
@param cRetorno, caracter, Space com tamanho que o numero do cupom tem que ter

@return numérico, Retorno da comunicação com o periférico
/*/
//---------------------------------------------------------------------------
Function Lj7PegCupArg(nHdlECF, cRetorno)
Local cSerie   := ""   //serie dependendo do cliente
Local nRet     := 1    //retorno da funcao IFPegCupom

cSerie := Lj7SerArg()

nRet := IFPegCupom( nHdlECF, @cRetorno, "D|"+AllTrim(cSerie))

Return nRet

//---------------------------------------------------------------------------
/*/{Protheus.doc} Lj7ImpNf
Valida se pode emitir nota fiscal (Localizaçoes Argentina)  

@type 		function
@author 	Varejo
@since  	23/07/2009
@version 	P11

@param lImpNfArg, lógico, Indica se pode ser imprimir NF

@return numérico, Retorno da comunicação com o periférico
/*/
//---------------------------------------------------------------------------
Function Lj7ImpNf(lImpNfArg)
Local lRet			:= .F.
Local lLibEmiteNF	:= .F.
Local lPvAutNf		:= .F.
Local lEmisNF		:= .F.

If SLG->(FieldPos("LG_PVAUTNF")) > 0
	lPvAutNf := LjGetStation("LG_PVAUTNF")
EndIf

If lPvAutNf
	lEmisNF	:= LjEmiteNF(SM0->M0_CGC,@lLibEmiteNF)
EndIf

If cPaisLoc == "ARG" .AND. !lFiscal .AND. lEmisNF .AND. lPvAutNf
	lRet := .T.
EndIf

lImpNfArg  := lRet

Return lRet

//---------------------------------------------------------------------------
/*/{Protheus.doc} Lj7LimpTef
Funcao que apaga os registros referente a TEF das tabelas SL1 e SL4 caso tenha erro na transacao.

@type 		function
@author 	Varejo
@since  	30/09/2008
@version 	P11

@return nil, Nulo
/*/
//---------------------------------------------------------------------------
Function Lj7LimpTef()

Local aSl1 := {}	//Array com campos "" para gravacao no arquivo SL1
Local aSl4 := {}	//Array com campos "" para gravacao no arquivo SL4

AADD(aSl1, {"L1_VENDTEF", ""})
AADD(aSl1, {"L1_DATATEF", ""})
AADD(aSl1, {"L1_HORATEF", ""})
AADD(aSl1, {"L1_DOCTEF", ""})
AADD(aSl1, {"L1_AUTORIZ", ""})
AADD(aSl1, {"L1_NSUTEF", ""})
Lj7GeraSL( "SL1", aSL1, .F., .F. )	//Grava Arquivo SL1

AADD(aSl4, {"L4_VENDTEF", ""})
AADD(aSl4, {"L4_DATATEF", ""})
AADD(aSl4, {"L4_HORATEF", ""})
AADD(aSl4, {"L4_DOCTEF", ""})
AADD(aSl4, {"L4_AUTORIZ", ""})
AADD(aSl4, {"L4_NSUTEF", ""})
AADD(aSl4, {"L4_PARCTEF", ""})

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Grava Arquivo SL4.³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

DbSelectArea( "SL4" )
DbSetOrder( 1 )
SL4->(DbSeek( xFilial( "SL4" ) + SL1->L1_NUM ))
While SL4->( !EOF() ) .AND. SL4->L4_FILIAL + SL4->L4_NUM == xFilial( "SL4" ) + SL1->L1_NUM
	Lj7GeraSL( "SL4", aSL4, .F. )
	SL4->(DbSkip())
End

Return Nil

//-----------------------------------------------------------
/*/{Protheus.doc} Lj7HAvlCrd()
Executa a MaAvalCred via RPC e retorna conforme o PDV-PAF
espera o retorno

@type function
@param cCodCli, string, código do cliente
@param cLoja, string, loja do cliente
@param nValor, numerico, valor do credito 
@param nMoeda, numerico, moeda corrente 
@param lPedido, logico, É pedido ?
@param cCodigo, string, passado somente por compatibilidade
						pois é usado a variavel cRet
@return aRet, array, contendo o retorno da MaAvalCred
@version 	P12
@since   	17/12/2019
@autor		julio.nery
/*/
//-----------------------------------------------------------
Function Lj7HAvlCrd(cCodCli, cLoja, nValor, nMoeda, lPedido,;
 					cCodigo)
Local aRet	:= {}
Local lRet	:= .F.
Local cRet	:= ""

Default cCodigo := ""

LjGrvLog( NIL, "Antes de MaAvalCred", {cCodCli, cLoja, nValor, nMoeda, lPedido, @cCodigo})
lRet := MaAvalCred(cCodCli, cLoja, nValor, nMoeda, lPedido, @cCodigo )
LjGrvLog( NIL, "Depois de MaAvalCred", {lRet,@cCodigo})

cRet := cCodigo

aRet := {lRet,cRet,""}

Return aRet

/*/{Protheus.doc} LjBaixaNCC
Efetua a baixa da(s) NCC(s) utilizada(s) na venda e gera nova NCC se necessário.

@type 	 Function
@author  Alberto Deviciente
@since 	 28/04/2020
@version 12.1.17

@return lRet, Lógico, Indica se o processo da baixa da NCC foi executado com sucesso.
/*/
Function LjBaixaNCC()
Local lRet		:= .T.
Local cDocCred	:= ""				//PREFIXO+NUM+PARCELA+TIPO+LOJA do titulo CR que sera usado para compensacao da NCC
Local nRecnoSE1	:= 0				//R_E_C_N_O_ do titulo do tipo CR que foi gerado
Local nMsDecimal:= MsDecimais(1)

LjGrvLog(SL1->L1_NUM,"Vai realizar a baixa das NCCs",aNCCItens)

//--------------------------------
// Inclui nova NCC para o cliente
//--------------------------------
lRet := StaticCall( WSFRTNCC		, FrtIncluiNCC		,;
					aNCCItens		, 	nNccUsada		, nNccGerada		, SL1->L1_DOC		,;
					SL1->L1_SERIE	,	SL1->L1_OPERADO	, SL1->L1_EMISSAO	, SL1->L1_CLIENTE	,;
					SL1->L1_LOJA	)

LjGrvLog(SL1->L1_NUM,"Retorno se incluiu a nova NCC",lRet)
LjGrvLog(SL1->L1_NUM,"Valor da nova NCC:",nNccGerada)

If lRet
	//------------------------------------------------------------------
	// Inclui tipo CR para fazer a compensação das NCCs usadas na venda
	//------------------------------------------------------------------
	lRet := StaticCall( WSFRTNCC		, FrtIncluiCR		,;
						SL1->L1_SERIE	, @cDocCred			, @nRecnoSE1	, SL1->L1_DOC		,;
						SL1->L1_SERIE	, SL1->L1_CLIENTE	, SL1->L1_LOJA	, SL1->L1_CREDITO	,;
						SL1->L1_OPERADO	, nNccUsada			, nNccGerada   	, aNccItens			)

	LjGrvLog(SL1->L1_NUM,"Retorno se incluiu o CR para compensacao da NCC",lRet)

	//----------------------
	// Efetua a compensacao
	//----------------------
	If lRet
		
		LjGrvLog(SL1->L1_NUM,"Executa a baixa da NCC utilizada na venda")

		StaticCall(	LOJXFUNC , LjInMovNCC	,;
					aNccItens, nMsDecimal	, cDocCred 		, nRecnoSE1	,;
					nNccUsada, nNccGerada	, SL1->L1_NUM )
	Else
		MsgStop(STR0006) //"Não foi possível realizar a inclusão do título do tipo CR referente a NCC"
		LjGrvLog(SL1->L1_NUM,STR0006) //"Não foi possível realizar a inclusão do título do tipo CR referente a NCC"
	EndIf
Else
	MsgStop(STR0007) //"Não foi possível realizar a inclusão da Nota de Crédito"
	LjGrvLog(SL1->L1_NUM,STR0007) //"Não foi possível realizar a inclusão da Nota de Crédito"
EndIf

Return lRet

/*/{Protheus.doc} LjDadosFCI
Retorno os dodos de FCI, campos D1_FCICOD e D1_CLASFIS

@type  	 Function
@author  joao.marcos
@since 	 05/07/2021
@version V12

@param	 cNumLote, caracter, numero do lote
@param	 cLoteCtl, caracter, numero do loteCtl
@param	 cProduto, caracter, codigo do produto

@return  aDadosFCI, array, retorna o conteudo dos campo D1_FCICOD e D1_CLASFIS da NF de entrada
*/
Function LjDadosFCI(cNumLote, cLoteCtl, cProduto)
Local cSeekSD1	:= ""
Local cSeekSB8	:= ""
Local nBaseIcm	:= 0
Local cItem		:= ""
Local aDadosFCI	:= {"","",0}
Local aArea		:= GetArea()
Local aAreaSD1	:= SD1->( GetArea() )
Local aAreaSFT 	:= SFT->( GetArea() )
Local aAreaSB8	:= SB8->( GetArea() )

DEFAULT cNumLote := ""
DEFAULT cLoteCtl := ""
DEFAULT cProduto := ""

LjGrvLog("Dados FCI", "Busca dados FCI - Inicio")

cSeekSB8 := cNumLote + cLoteCtl + cProduto

dbSelectArea("SB8")
dbSetOrder(2) // B8_FILIAL+B8_NUMLOTE+B8_LOTECTL+B8_PRODUTO+B8_LOCAL+DTOS(B8_DTVALID)
If !Empty(cSeekSB8) .AND. SB8->( dbSeek(xFilial("SB8") + cSeekSB8) )

	cSeekSD1 := SB8->B8_DOC + SB8->B8_SERIE + SB8->B8_CLIFOR + SB8->B8_LOJA + cProduto + cLoteCtl + cNumLote

	dbSelectArea("SD1")
	dbSetOrder(11)
	If !Empty(cSeekSD1) .AND. MsSeek(xFilial("SD1") + cSeekSD1)

		// Busca Doc de entrada
		cItem:= SD1->D1_SERIE+SD1->D1_DOC+SD1->D1_FORNECE+SD1->D1_LOJA+SD1->D1_ITEM+cProduto
		If SD1->(FieldPos("D1_FCICOD")) <> 0

			// Busca SFT da NF de Entrada
			dbSelectArea("SFT")
			dbSetOrder(1) // FT_FILIAL+FT_TIPOMOV+FT_SERIE+FT_NFISCAL+FT_CLIEFOR+FT_LOJA+FT_ITEM+FT_PRODUTO

			If MsSeek(xFilial("SFT")+"E" + cItem )
			
				If SFT->FT_BASERET > 0 .AND. SFT->FT_VALANTI > 0					
					nBaseIcm   := (SFT->FT_BASERET / SB8->B8_QTDORI)
				ElseIf SFT->FT_BASEICM > 0 .And. SFT->FT_ICMSRET > 0
					nBaseIcm   := (SFT->FT_BASEICM / SB8->B8_QTDORI)
				EndIf

			EndIf	

			aDadosFCI[01] := SD1->D1_FCICOD
			aDadosFCI[02] := Substr(SD1->D1_CLASFIS,1,1)
			aDadosFCI[03] := nBaseIcm
			
		EndIf
	EndIf

EndIf

RestArea( aAreaSD1 )
RestArea( aAreaSFT )
RestArea( aAreaSB8 )
RestArea( aArea )

LjGrvLog("Dados FCI", "Busca dados FCI - Fim")

Return aDadosFCI