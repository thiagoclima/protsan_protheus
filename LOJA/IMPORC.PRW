#include 'protheus.ch'
#include 'parmtype.ch'
#INCLUDE "COLORS.CH"
#INCLUDE "RPTDEF.CH"
#INCLUDE "FWPrintSetup.ch"

#DEFINE PAD_LEFT	0
#DEFINE PAD_RIGHT	1
#DEFINE PAD_CENTER	2

#DEFINE PAD_HCENTER	0
#DEFINE PAD_HTOP	1
#DEFINE PAD_BOTTOM	2

user function IMPORC(nOrigem)
	Local cHist     := ""
	Local cTimeStmp := ""
	Private cFileImg1 	:= GetMV('ZZ_ORCIMG1', .F., '\01.png')
	Private cFileImg2 	:= GetMV('ZZ_ORCIMG2', .F., '\02.png')
	Private cFileImg3 	:= GetMV('ZZ_ORCIMG3', .F., '\03.png')
	Private cFileImg4 	:= GetMV('ZZ_ORCIMG4', .F., '\04.png')
	Private cFileImg5 	:= GetMV('ZZ_ORCIMG5', .F., '\05.png')
	Private cFileImg6 	:= GetMV('ZZ_ORCIMG6', .F., '\06.png')
	Private cFileImg7 	:= GetMV('ZZ_ORCIMG7', .F., '\07.png')
	Private cFileImg8 	:= GetMV('ZZ_ORCIMG8', .F., '\08.png')
	Private cFileImg9 	:= GetMV('ZZ_ORCIMG9', .F., '\09.png')
	Private cFileImg0 	:= GetMV('ZZ_ORCIMG0', .F., '\10.png')
	Private nI  			:= 0
	Private lHasImage 	:= .F.

	Private cFileLogo 	:= GetMV('ZZ_ORCIMGL', .F., '\lgmid01.png')

	Private aDescricao	:= ""
	Private cFunName	:= 'IMPORC'
	Private cPerg		:= cFunName
	Private aMsg		:= {}
	Private cTipo		:= ''
	Private cTitulo		:= ''
	Private oPrint		:= Nil
	Private cAliasTMP	:= GetNextAlias()
	Private cQuery		:= ''
	Private nTotReg		:= 0
	Private cPathPDF	:= 'C:\TEMP\'

	Private oFont07a	:= TFont():New('Arial'      ,,07,,.F.,,,,.F.,.F.)	//Negrito/Italico/Sublinhado
	Private oFont07b	:= TFont():New('Arial'      ,,07,,.T.,,,,.F.,.F.)	//Negrito/Italico/Sublinhado
	Private oFont08a	:= TFont():New('Arial'      ,,08,,.F.,,,,.F.,.F.)	//Negrito/Italico/Sublinhado
	Private oFont08b	:= TFont():New('Arial'      ,,08,,.T.,,,,.F.,.F.)	//Negrito/Italico/Sublinhado
	Private oFont09a	:= TFont():New('Arial'      ,,09,,.F.,,,,.F.,.F.)	//Negrito/Italico/Sublinhado
	Private oFont09b	:= TFont():New('Arial'      ,,09,,.T.,,,,.F.,.F.)	//Negrito/Italico/Sublinhado
	Private oFont10a	:= TFont():New('Arial'      ,,10,,.F.,,,,.F.,.F.)	//Negrito/Italico/Sublinhado
	Private oFont10b	:= TFont():New('Arial'      ,,10,,.T.,,,,.F.,.F.)	//Negrito/Italico/Sublinhado
	Private oFont11a	:= TFont():New('Arial'      ,,11,,.F.,,,,.F.,.F.)	//Negrito/Italico/Sublinhado
	Private oFont11b	:= TFont():New('Arial'      ,,11,,.T.,,,,.F.,.F.)	//Negrito/Italico/Sublinhado
	Private oFont12a	:= TFont():New('Arial'		,,12,,.F.,,,,.F.,.F.)	//Negrito/Italico/Sublinhado
	Private oFont12b	:= TFont():New('Arial'		,,12,,.T.,,,,.F.,.F.)	//Negrito/Italico/Sublinhado
	Private oFont13a	:= TFont():New('Arial'		,,13,,.F.,,,,.F.,.F.)	//Negrito/Italico/Sublinhado
	Private oFont13b	:= TFont():New('Arial'		,,13,,.T.,,,,.F.,.F.)	//Negrito/Italico/Sublinhado
	Private oFont14a	:= TFont():New('Arial'		,,14,,.F.,,,,.F.,.F.)	//Negrito/Italico/Sublinhado
	Private oFont14b	:= TFont():New('Arial'		,,14,,.T.,,,,.F.,.F.)	//Negrito/Italico/Sublinhado
	Private oFont16a	:= TFont():New('Arial'		,,16,,.F.,,,,.F.,.F.)	//Negrito/Italico/Sublinhado
	Private oFont16b	:= TFont():New('Arial'		,,16,,.T.,,,,.F.,.F.)	//Negrito/Italico/Sublinhado
	Private oFont18a	:= TFont():New('Arial'		,,18,,.F.,,,,.F.,.F.)	//Negrito/Italico/Sublinhado
	Private oFont18b	:= TFont():New('Arial'		,,18,,.T.,,,,.F.,.F.)	//Negrito/Italico/Sublinhado
	Private oFont20a	:= TFont():New('Arial'		,,20,,.F.,,,,.F.,.F.)	//Negrito/Italico/Sublinhado
	Private oFont20b	:= TFont():New('Arial'		,,20,,.T.,,,,.F.,.F.)	//Negrito/Italico/Sublinhado
	Private oFont22a	:= TFont():New('Arial'		,,22,,.F.,,,,.F.,.F.)	//Negrito/Italico/Sublinhado
	Private oFont22b	:= TFont():New('Arial'		,,22,,.T.,,,,.F.,.F.)	//Negrito/Italico/Sublinhado
	Private oFont24a	:= TFont():New('Arial'		,,24,,.F.,,,,.F.,.F.)	//Negrito/Italico/Sublinhado
	Private oFont24b	:= TFont():New('Arial'		,,24,,.T.,,,,.F.,.F.)	//Negrito/Italico/Sublinhado
	Private cPathTMP	:= '\temp-files\'
	Private cImgProd    := ''

	Private cPDFLocal	:= ""
	Private nLin		:= 0
	Private aPos		:= {}
	Private aParamBox	:= {}
	Private nLinRP		:= 765
	Private aArray		:= {}
	Private nLinLimite 	:= 585	//Limite da folha A4
	Private nColIni		:= 10
	Private nColAtu		:= nColIni + 0010
	Private nColFim		:= 585
	Private cNumOrc  	:= SL1->L1_NUM
	Private aFormaPGTO  := {}
	Private oBrush1     := Nil
	Private lEnvEmail   := .F.
	Private nPagina     := 0
	Private lViewPDF	:= .T.
	Private cEmailCli   := ''

	Default nOrigem    := 1

	If nOrigem == 2 //Chamou pelo PE
		cNumOrc  := SL1->L1_NUM
	Else
		aAdd( aParamBox, {1, "Orçamento", cNumOrc  , "@!", "", "SB1"  , "", 80, .F. } )

		if ParamBox(aParamBox, "Parâmetros da Consulta")
			cNumOrc   := MV_PAR01

			If !MsgYesNo("Confirma a Impressão do Orçamento " + cNumOrc + " ?", "Confirma?")
				Return
			Endif

		Endif
	Endif

	lEnvEmail := MsgYesNo("Deseja enviar o orçamento " + cNumOrc + " via email?", "Confirma?")
	lViewPDF  := !lEnvEmail
	FWMsgRun(, {|| Imprimir() }, "Imprimindo", "Imprimindo Orçamento...")
	
	cHist := Alltrim(SL1->L1_XHISBLQ)
	cHist += "==========================="+CRLF
	cTimeStmp := DtoC(Date())+"-"+Time()
	cHist += cTimeStmp+"-IMPRESSÃO DE ORÇAMENTO"+CRLF
	cHist +="IMPRESSO POR "+__cUserId + " " +  cUserName+CRLF
Return

Static Function Imprimir()
	Local sTime := Time()

	FWMakeDir( cPathPDF, .F.)
	FWMakeDir( cPathTMP, .F.)

	lAdjustToLegacy := .F.
	cTitulo := 'ORCAMENTO ' + cNumOrc + ' - ' +  DToS(date()) + ' - ' + StrTran( sTime, ':', '') + '.rel'
	cPDFLocal  := cPathPDF + 'ORCAMENTO ' + cNumOrc + ' - ' +  DToS(date()) + ' - ' + StrTran( sTime, ':', '') + '.pdf'
	cPDFServer := cPathTMP + 'ORCAMENTO ' + cNumOrc + ' - ' +  DToS(date()) + ' - ' + StrTran( sTime, ':', '') + '.pdf'

	oPrint	:= FWMSPrinter():New( 	cTitulo /*cFilePrintert*/, IMP_PDF /*nDevice*/, lAdjustToLegacy /*lAdjustToLegacy*/, /*cPathInServer*/,.T. /*lDisabeSetup*/,;
									/*lTReport*/,/*oPrintSetup*/,/*cPrinter*/,/*lServer*/,/*lPDFAsPNG*/,/*lRaw*/,lViewPDF,/*nQtdCopy*/)
	oBrush1 := TBrush():New( , RGB(63, 165, 217))
	oPrint:SetPortrait()	//Retrato
	oPrint:SetpaperSize(9)	//PAPEL A4
	oPrint:cPathPDF := cPathPDF
	//oPrint:lViewPDF	:= .F.

	// Posiciona no arquivo cabe‡alho								 
	dbSelectArea( "SL1" )
	dbSetOrder( 1 )
	dbSeek( xFilial("SL1")+cNumOrc )

	// Posiciona no arquivo de Clientes							 
	dbSelectArea( "SA1" )
	dbSetOrder( 1 )
	dbSeek( xFilial("SA1")+SL1->L1_CLIENTE+SL1->L1_LOJA )

	cEmailCli := Alltrim( SA1->A1_EMAIL )

	// Posiciona no arquivo de Vendedores 							 
	dbSelectArea( "SA3" )
	dbSetOrder( 1 )

	dbSeek( xFilial("SA3")+SL1->L1_VEND )

	// Monta Array da Condi‡„o de Pagamento						 
	aCondicoes := lj010Cond( )

	//³Monta Array com tipo de Forma de Pagamento					 
	dbSelectArea( "SX5" )
	dbSetOrder( 1 )
	dbSeek( xFilial("SX5")+"06" )

	While !Eof( ) .and. SX5->X5_FILIAL == xFilial("SX5") .and. SX5->X5_TABELA = "06"

		If Trim(SX5->X5_CHAVE) == "CC"
			SAE->(DbSeek(xFilial("SX5")+Chr(0),.T.))
		EndIf

		If SX5->X5_CHAVE != "CC" .or. !SAE->(Eof())
			Aadd( aFormaPgto, SubStr( SX5->X5_DESCRI, 1, 13 ) + SubStr(SX5->X5_CHAVE , 1, 3 ) )
		EndIf

		dbSkip( )

	EndDo

	// Posiciona no arquivo de Itens								 
	dbSelectArea( "SL2" )
	dbSetOrder( 1 )
	dbSeek( xFilial("SL2")+cNumOrc )	

	Cabec()
	DadosCli()
	Negociacao()
	CabecItem()

	While !SL2->( Eof( ) ) .AND. SL2->L2_FILIAL == SL1->L1_FILIAL .AND. SL2->L2_NUM == SL1->L1_NUM

		If SL2->L2_VENDIDO == "S"
			dbSkip()
			Loop
		EndIf

		cDescProd 	:= Alltrim( SL2->L2_DESCRI )
		aDescricao 	:= GetLinTxt( cDescProd, oFont07a, 140, 155 )
		nTamDescr   := Len( aDescricao )
		lHasImage 	:= .F.

		dbSelectArea('SB1')
		SB1->( dbSetOrder( 1 ) )
		cImgProd := ''
		If SB1->( dbSeek( FwxFilial('SB1') + SL2->L2_PRODUTO) ) .AND. !Empty( SB1->B1_BITMAP )
			cImgProd := cPathTMP + AllTrim(SL2->L2_PRODUTO) + '-' +  Alltrim(SB1->B1_BITMAP) + ".jpg"
			If File( cImgProd )
				FErase( cImgProd )
			Endif
			RepExtract(AllTrim(SB1->B1_BITMAP), cImgProd , .T.)
			If File( cImgProd )
				//lHasImage := .T. mudei para nao imprimir a imagem 
 				lHasImage := .F.
			Endif
		Endif
		
		If nLin + 40 >= nLinRP
			xRodape()
			Cabec()
			CabecItem()
		Endif

		If nTamDescr < 2 .AND. lHasImage
			aPos := { nLin + 0010, 0020, 1 } // Linha inicial -- Largura em px -- Alinhamento Vertical
		Else
			aPos := { nLin + 0000, 0010, 1 } // Linha inicial -- Largura em px -- Alinhamento Vertical
		EndIf

		Item()

		SL2->( dbSkip() )
	EndDo

	xRodape()

	If lEnvEmail

		oPrint:Print()

		cCorpo   := "Segue anexo o orçamento solicitado."
		cAssunto := 'Orçamento'

		CpyT2S( cPDFLocal, cPathTMP, .F. )

		oSendMail := SendMail():newSendMail()
		// cEmailCli := "heverson.cga.epp@gmail.com;prapolinario@gmail.com"
		If oSendMail:send( cEmailCli, cAssunto, cCorpo, cPDFServer )
			MsgInfo("Email enviado com sucesso", "Email")
		Endif

		FreeObj( oSendMail )
		FreeObj( oPrint )

		FErase( cPDFServer )

	Else
		oPrint:Preview()

	Endif

return

Static Function GetLinTxt( cSplitText, oFont, nMin, nMax )
	Local aRet       := {}
	Local cTextPrint := ''
	Local nTamText   := 0
	Local nLargura   := 0
	Local lFimText   := .F.
	Local nX 		 := 0
	Local cText		 := cSplitText
	Local cTextTmp

	While Len( cText ) > 0
		cTextPrint := ''
		nTamText   := Len( cText )
		nLargura   := 0
		lFimText   := .F.
		For nX := 1 To nTamText

			If nX == nTamText
				lFimText := .T.
			Endif

			If Substr( cText, nX, 1) == ' ' .OR. lFimText
				cTextPrint := ''
				cTextTmp   := Substr( cText, 1, nX - Iif( lFimText, 0, 1 ) )
				nLargura   := oPrint:GetTextWidth( cTextTmp, oFont, 2)
				If nLargura >= nMin .OR. lFimText
					cTextPrint := cTextTmp
				Endif
			Endif

			If nLargura >= nMin .OR. lFimText
				Aadd( aRet, cTextPrint )
				If lFimText
					cText := ''
				Else
					cText := Substr( cText, nX + 1 )
					Exit
				Endif
			Endif
		Next nX
	End While
Return aRet



Static Function Cabec()

	nPagina++

	oPrint:StartPage()
	nLin := 20
	//---------------------------------------------------------------------------------------
	//								    CABEÇALHO
	//---------------------------------------------------------------------------------------	

	oPrint:SayBitmap( nLin - 0040 , nColIni + 0010, cFileLogo, 0150, 0120)
	oPrint:Say( nLin + 0010 , nColIni + 0450, "Orçamento Venda"			         	, oFont18b)
	oPrint:Say( nLin + 0030 , nColIni + 0535, "Página: " + CValToChar( nPagina )	, oFont10a)
	oPrint:Say( nLin + 0050 , nColIni + 0025, "Solda | Ferramentas | EPI | Limpeza" , oFont10a)
	oPrint:Say( nLin + 0050 , nColIni + 0420, "Data: " + DtoC(SL1->L1_EMISSAO)		, oFont12a)
	oPrint:Say( nLin + 0050 , nColIni + 0500, "Número: " + SL1->L1_NUM				, oFont12a)
	nLin += 70

Return

Static Function DadosCli()
	

	oPrint:Fillrect({nLin - 0004,nColIni , nLin + 10, nColFim}, oBrush1, "-2")
	oPrint:SayAlign( nLin - 0005, 0060, "DADOS DO CLIENTE" 			         		, oFont16b, 0475, 0030, CLR_WHITE , 2, 0 )
	nLin += 20
	oPrint:Say( nLin + 0010, nColIni + 0010, "Cliente.......:"			            	, oFont10b)
	oPrint:Say( nLin + 0020, nColIni + 0010, "Endereço......:"			            	, oFont10b)
	oPrint:Say( nLin + 0030, nColIni + 0010, "Cidade/UF.....:"			            	, oFont10b)
	oPrint:Say( nLin + 0040, nColIni + 0010, "Classe Fiscal.:"			            , oFont10b)
	oPrint:Say( nLin + 0050, nColIni + 0010, "CNPJ..........:"			            , oFont10b)
	oPrint:Say( nLin + 0010, nColIni + 0067, AllTrim(SA1->A1_NOME)						 	, oFont10a)
	oPrint:Say( nLin + 0020, nColIni + 0067, AllTrim(SA1->A1_END)			 	 			, oFont10a)
	oPrint:Say( nLin + 0030, nColIni + 0067, AllTrim(SA1->A1_MUN) + " / " + AllTrim(SA1->A1_EST)		, oFont10a)
	oPrint:Say( nLin + 0040, nColIni + 0067, "Consumidor Não Contribuinte"		 			, oFont10a)
	oPrint:Say( nLin + 0050, nColIni + 0067, AllTrim(SA1->A1_CGC)			 	 			, oFont10a)

	nLin += 60

Return

Static Function Negociacao()
	Local aObserv 	:= {}
	Local nI 		:= 0
	//---------------------------------------------------------------------------------------
	//								 DADOS DE NEGOCIAÇÃO	
	//---------------------------------------------------------------------------------------
	oPrint:Fillrect({nLin - 0004,nColIni , nLin + 10, nColFim}, oBrush1, "-2")
	oPrint:SayAlign( nLin - 0005, 0060, "DADOS DE NEGOCIAÇÃO"          , oFont16b, 0475, 0030, 	CLR_WHITE , 2, 0 )
	nLin += 20

	oPrint:SayAlign( nLin + 0010, nColIni + 0010, "Tipo de Frete: "		   	 										, oFont10b, 0100, 0010,, 0, 1 )
	//oPrint:SayAlign( nLin + 0010, nColIni + 0120, SL1->L1_TPFRETE			 										, oFont10a, 0100, 0010,, 0, 1 )
	
	nLinFrt	:= nLin

	oPrint:SayAlign( nLin + 0020, nColIni + 0010, "Transportadora: "		 										, oFont10b, 0100, 0010,, 0, 1 )
	oPrint:SayAlign( nLin + 0020, nColIni + 0120, SL1->L1_TRANSP			 										, oFont10a, 0100, 0010,, 0, 1 )
	oPrint:SayAlign( nLin + 0030, nColIni + 0010, "Negociação: "			 										, oFont10b, 0100, 0010,, 0, 1 )
	oPrint:SayAlign( nLin + 0030, nColIni + 0120, SL1->L1_CONDPG + SL1->L1_FORMPG  									, oFont10a, 0100, 0010,, 0, 1 )
	//oPrint:SayAlign( nLin + 0040, nColIni + 0010, "Prev. de Entrega: "	   	 										, oFont10b, 0100, 0010,, 0, 1 )
	//oPrint:SayAlign( nLin + 0040, nColIni + 0120, DtoC(SL2->L2_FDTENTR)		 										, oFont10a, 0100, 0010,, 0, 1 )
	oPrint:SayAlign( nLin + 0040, nColIni + 0010, "Validade Orçamento: "   	 										, oFont10b, 0100, 0010,, 0, 1 )
	oPrint:SayAlign( nLin + 0040, nColIni + 0120, dtoC(SL1->L1_DTLIM)				 										, oFont10a, 0100, 0010,, 0, 1 )
	oPrint:SayAlign( nLin + 0050, nColIni + 0010, "Pedido do Cliente: "	   	 										, oFont10b, 0100, 0010,, 0, 1 )
	oPrint:SayAlign( nLin + 0050, nColIni + 0120, SL2->L2_PEDRES		 											, oFont10a, 0100, 0010,, 0, 1 )
	oPrint:SayAlign( nLin + 0010, nColIni + 0400, "Vendedor: "  	 												, oFont12b, 0100, 0010,, 0, 1 )
	oPrint:SayAlign( nLin + 0010, nColIni + 0450, SA3->A3_NOME	 												, oFont12a, 0100, 0010,, 0, 1 )
	oPrint:SayAlign( nLin + 0070, nColIni + 0420, "Valor do frete: "  												, oFont13b, 0100, 0010,, 0, 1 )
	oPrint:SayAlign( nLin + 0070, nColIni + 0500, Transform(SL1->L1_FRETE, "@E 999,999,999.99")						, oFont13a, 0075, 0010,, 1, 1 )
	oPrint:SayAlign( nLin + 0090, nColIni + 0420, "Total: "  	 													, oFont13b, 0100, 0010,, 0, 1 )
	oPrint:SayAlign( nLin + 0090, nColIni + 0500, Transform(SL1->L1_VLRTOT + SL1->L1_FRETE, "@E 999,999,999.99")	, oFont13a, 0075, 0010,, 1, 1 )

	oPrint:SayAlign( nLin + 0060, nColIni + 0010, "Observações: "		   	 										, oFont10b, 0100, 0010,, 0, 1 )

	nLinObs := nLin + 0060
	cObserv 	:= Alltrim( SL1->L1_XOBS )
	aObserv 	:= GetLinTxt( cObserv, oFont07a, 245, 255 )
	If Len( aObserv ) > 0
		For nI := 1 To Len( aObserv )
			oPrint:SayAlign( nLinObs, 0110, aObserv[ nI ], oFont09a, 250, 20, , 0, 1 )
			nLinObs	+= 10
		Next nI
	Endif

	nLin += 110

Return 

Static Function CabecItem()
	//---------------------------------------------------------------------------------------
	//								 PRODUTOS	
	//---------------------------------------------------------------------------------------	
	oPrint:Fillrect({nLin - 0004,nColIni , nLin + 10, nColFim}, oBrush1, "-2")
	oPrint:SayAlign( nLin - 0005, 0060, "PRODUTOS"           ,oFont16b, 0475, 0030, CLR_WHITE , 2, 0 )
	nLin += 12

	oPrint:Fillrect({nLin + 0000, nColIni + 0000, nLin + 0015, nColFim}, oBrush1, "-2")
	oPrint:SayAlign( nLin + 0000, nColIni + 0000, "Cod."			 , oFont07b, 0040, 0030, CLR_WHITE , 0, 1 )
	oPrint:SayAlign( nLin + 0000, nColIni + 0070, "Descrição"		 , oFont07b, 0150, 0030, CLR_WHITE , 0, 1 )
	oPrint:SayAlign( nLin + 0000, nColIni + 0220, "Imagem"			 , oFont07b, 0040, 0030, CLR_WHITE , 0, 1 )
	oPrint:SayAlign( nLin + 0000, nColIni + 0265, "NCM"				 , oFont07b, 0030, 0030, CLR_WHITE , 0, 1 )
	oPrint:SayAlign( nLin + 0000, nColIni + 0300, "C.A."			 , oFont07b, 0025, 0030, CLR_WHITE , 0, 1 )
	oPrint:SayAlign( nLin + 0000, nColIni + 0330, "Un."				 , oFont07b, 0015, 0030, CLR_WHITE , 0, 1 )
	oPrint:SayAlign( nLin + 0000, nColIni + 0350, "Qtd."			 , oFont07b, 0025, 0030, CLR_WHITE , 1, 1 )
	oPrint:SayAlign( nLin + 0000, nColIni + 0380, "Vlr Unit"		 , oFont07b, 0030, 0030, CLR_WHITE , 1, 1 )
	oPrint:SayAlign( nLin + 0000, nColIni + 0415, "S.T"				 , oFont07b, 0015, 0030, CLR_WHITE , 1, 1 )
	oPrint:SayAlign( nLin + 0000, nColIni + 0435, "IPI"				 , oFont07b, 0015, 0030, CLR_WHITE , 1, 1 )
	oPrint:SayAlign( nLin + 0000, nColIni + 0455, "Icms"			 , oFont07b, 0015, 0030, CLR_WHITE , 1, 1 )
	oPrint:SayAlign( nLin + 0000, nColIni + 0475, "Desc"			 , oFont07b, 0020, 0030, CLR_WHITE , 1, 1 )
	oPrint:SayAlign( nLin + 0000, nColIni + 0495, "Vlr Total"		 , oFont07b, 0045, 0030, CLR_WHITE , 1, 1 )
	//oPrint:SayAlign( nLin + 0000, nColIni + 0545, "Entrega"			 , oFont07b, 0040, 0030, CLR_WHITE , 0, 1 )
	nLin 	+= 20

Return


Static Function Item()
	Local nI := 0

	Local cEstCli 	:= ""

	cEstCli := SA1->A1_EST

	oPrint:SayAlign( aPos[1], nColIni + 0000, AllTrim(SL2->L2_PRODUTO)    											, oFont07a, 0050, aPos[2],, 0, aPos[3] )
	If lHasImage
		oPrint:SayBitmap( nLin - 0004 , nColIni + 0210, cImgProd, 0040, 0040)
	Endif
//	cVlrUnit   := Transform( SL2->L2_VRUNIT  + SL2->L2_DESCPRO + (SL2->L2_VALDESC / SL2->L2_QUANT), "@E 9,999,999.99")
	cVlrUnit   := Transform( SL2->L2_VRUNIT  , "@E 999,999.99")
	cVdesc	   := 0 
	cVdesc   := Transform( cVdesc  , "@E 99.99")
	
	oPrint:SayAlign( aPos[1], nColIni + 0265, Alltrim( SL2->L2_POSIPI )												, oFont07a, 0030, aPos[2],, 0, aPos[3] )
//	oPrint:SayAlign( aPos[1], nColIni + 0300, "B1_CA"/*AllTrim(SB1->B1_CA)*/         								, oFont07a, 0025, aPos[2],, 0, aPos[3] )
	oPrint:SayAlign( aPos[1], nColIni + 0300, AllTrim(SB1->B1_CA)         											, oFont07a, 0025, aPos[2],, 0, aPos[3] )
	oPrint:SayAlign( aPos[1], nColIni + 0330, SL2->L2_UM        													, oFont07a, 0015, aPos[2],, 0, aPos[3] )
	oPrint:SayAlign( aPos[1], nColIni + 0350, Alltrim( Transform(SL2->L2_QUANT, PesqPict("SL2","L2_QUANT") ) )		, oFont07a, 0030, aPos[2],, 1, aPos[3] )
	oPrint:SayAlign( aPos[1], nColIni + 0380, cVlrUnit 																, oFont07a, 0030, aPos[2],, 1, aPos[3] )
	oPrint:SayAlign( aPos[1], nColIni + 0415, CValToChar(SL2->L2_ALIQSOL)											, oFont07a, 0015, aPos[2],, 1, aPos[3] )
	oPrint:SayAlign( aPos[1], nColIni + 0435, CValToChar(SL2->L2_IPI)+"%"											, oFont07a, 0015, aPos[2],, 1, aPos[3] )
//	oPrint:SayAlign( aPos[1], nColIni + 0455, CValToChar(SL2->L2_PICM)       										, oFont07a, 0015, aPos[2],, 1, aPos[3] )
	//oPrint:SayAlign( aPos[1], nColIni + 0455, "18%"						      										, oFont07a, 0015, aPos[2],, 1, aPos[3] )
	oPrint:SayAlign( aPos[1], nColIni + 0455, fcnAliqEst(cEstCli)		      										, oFont07a, 0015, aPos[2],, 1, aPos[3] )
//	oPrint:SayAlign( aPos[1], nColIni + 0475, CValToChar(SL2->L2_DESC)+"%"           								, oFont07a, 0015, aPos[2],, 1, aPos[3] )
	oPrint:SayAlign( aPos[1], nColIni + 0475, CValToChar(cVdesc)+"%"           										, oFont07a, 0015, aPos[2],, 1, aPos[3] )
	oPrint:SayAlign( aPos[1], nColIni + 0495, Alltrim(Transform( SL2->L2_VLRITEM, "@E 9,999,999.99"))  				, oFont07a, 0045, aPos[2],, 1, aPos[3] )
	//oPrint:SayAlign( aPos[1], nColIni + 0545, CValToChar(SL2->L2_ENTREGA)+ " Dias"									, oFont07a, 0040, aPos[2],, 0, aPos[3] )

	If nTamDescr > 0
		For nI := 1 To nTamDescr
			oPrint:SayAlign( aPos[1], 0070, aDescricao[ nI ], oFont07a, 150, 20, , 0, 1 )
			aPos[1] += 10
		Next nI
	Endif

	If !Empty(cImgProd)
		nLin 	+= 40
	Else
	//	nLin 	+= aPos[1] // RETIRADO PARA NAO PULAR LINHAS AJUSTES EM 04/01/2021
		nLin    += 40
	EndIf

	If lHasImage .AND. File( cImgProd )
		FErase( cImgProd )
	Endif

Return

Static Function fcnAliqEst(cEstCli)

	Local cAliq 		:= ""
	Local aAliq 		:= {}
	Local cAliqEst 		:= "AC17;AL17;AM18;AP18;BA18;CE17;DF18;ES17;GO17;MA18;MG18;MS17;MT17;PA17;PB18;PE18;PI17;PR18;RJ18;RN18;RO17.50;RR17;RS18;SC17;SE18;SP18;TO18"
	Local nPos 			:= 0

	aAliq := StrTokArr(cAliqEst,";")

	nPos := aScan(aAliq,{|x| SubStr(x,1,2) == cEstCli })

	If nPos > 0
		cAliq := SubStr(aAliq[nPos],3,(Len(aAliq[nPos])-2))
	EndIf

Return(cAliq)

Static Function xRodape()
	nLin := nLinRP

	oPrint:SayAlign( nLin + 0000, nColIni + 0000, "Matriz: Av. Conselheiro Nébias, 69 - Paquetá, Santos - SP, 11015-001 | CNPJ 15.301.412/0001-39"			, oFont10b, 575, 20,, 2, 0 )
	oPrint:SayAlign( nLin + 0010, nColIni + 0000, "Filial: Av. Pedro José Cardoso, 451 - Vila Paulista, Cubatão - SP, 11510-100 | CNPJ 15.301.412/0002-10 "	, oFont10b, 575, 20,, 2, 0 )
	nLin += 30
	
	oPrint:Line( nLin - 0003 , nColIni + 000, nLin - 0003 , nColFim, 0,"-1")

	oPrint:SayBitmap( nLin , nColIni + 0050, cFileImg1, 0045, 0030)
	oPrint:SayBitmap( nLin , nColIni + 0150, cFileImg2, 0045, 0030)
	oPrint:SayBitmap( nLin , nColIni + 0250, cFileImg3, 0045, 0030)
	oPrint:SayBitmap( nLin , nColIni + 0350, cFileImg4, 0045, 0030)
	oPrint:SayBitmap( nLin , nColIni + 0450, cFileImg5, 0045, 0030)


	nLin +=20

	oPrint:SayBitmap( nLin , nColIni + 0050, cFileImg6, 0045, 0030)
	oPrint:SayBitmap( nLin , nColIni + 0150, cFileImg7, 0045, 0030)
	oPrint:SayBitmap( nLin , nColIni + 0250, cFileImg8, 0045, 0030)
	oPrint:SayBitmap( nLin , nColIni + 0350, cFileImg9, 0045, 0030)
	oPrint:SayBitmap( nLin , nColIni + 0450, cFileImg0, 0045, 0030)

	oPrint:EndPage()
Return
