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



user function IMPORC2(nOrigem)
	Private aDescricao	:= ""
	Private cFunName	:= 'IMPORC2'
	Private cPerg		:= cFunName
	Private aMsg		:= {}
	Private cTipo		:= ''
	Private cTitulo		:= ''
	Private cFileLogo 	:= GetMV('ZZ_ORCIMGL', .F., '\lgmid01.png')
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

	Private nLin		:= 0
	Private aParamBox	:= {}
	Private nLinRP		:= 680
	Private nValDesc	:= 0
	Private aArray		:= {}
	Private nLinLimite 	:= 585	//Limite da folha A4
	Private nColIni		:= 10
	Private nColAtu		:= nColIni + 0010
	Private nColFim		:= 585
	Private cNumOrc  	:= SL1->L1_NUM
	Private aFormaPGTO  := {}
	Private oBrush1     := Nil
	Private nPagina     := 0

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

	If !ExistBlock("PROTA002") .or. U_PROTA002('V')
		FWMsgRun(, {|| Imprimir() }, "Imprimindo", "imprimindo lista de separação...")
	Endif

Return

Static Function Imprimir()

	FWMakeDir( cPathPDF, .F.)


	lAdjustToLegacy := .F.
	cTitulo := 'lista-separacao-' + DToS(date()) + '-' + StrTran(Time(),':','')

	oPrint	:= FWMSPrinter():New( cTitulo, IMP_PDF, lAdjustToLegacy, ,.T.)
	oBrush1 := TBrush():New( , CLR_HBLUE)
	oPrint:SetPortrait()	//Retrato
	oPrint:SetpaperSize(9)	//PAPEL A4
	oPrint:cPathPDF := cPathPDF
	//oPrint:lViewPDF	:= .F.


	dbSelectArea( "SL1" )
	dbSetOrder( 1 )
	dbSeek( xFilial("SL1")+cNumOrc )

	dbSelectArea( "SA1" )
	dbSetOrder( 1 )
	dbSeek( xFilial("SA1")+SL1->L1_CLIENTE+SL1->L1_LOJA )

	dbSelectArea( "SA3" )
	dbSetOrder( 1 )

	dbSeek( xFilial("SA3")+SL1->L1_VEND )

	dbSelectArea( "SX5" )
	dbSetOrder( 1 )
	dbSeek( xFilial("SX5")+"06" )

	aCondicoes := lj010Cond( )

	While !Eof( ) .and. SX5->X5_FILIAL == xFilial("SX5") .and. SX5->X5_TABELA = "06"

		If Trim(SX5->X5_CHAVE) == "CC"
			SAE->(DbSeek(xFilial("SX5")+Chr(0),.T.))
		EndIf

		If SX5->X5_CHAVE != "CC" .or. !SAE->(Eof())
			Aadd( aFormaPgto, SubStr( SX5->X5_DESCRI, 1, 13 ) + SubStr(SX5->X5_CHAVE , 1, 3 ) )
		EndIf

		dbSkip( )

	EndDo

	dbSelectArea( "SL2" )
	dbSetOrder( 1 )
	dbSeek( xFilial("SL2")+cNumOrc )

	Cabec()
	CabecItem()

	While !Eof( ) .and. SL2->L2_NUM == SL1->L1_NUM
	//	If SL2->L2_VENDIDO == "S"
	//		SL2->( dbSkip() )
	//		Loop
	//	EndIf
		If nLin + 30 >= (nLinRP + 100)
			// xRodape()
			oPrint:SayAlign( nLin + 0015, 0060, "continua..."           ,oFont16b, 0475, 0017, , 2, 1 )
			Cabec()
			CabecItem()
		Endif

		Item()

		SL2->( dbSkip() )
	EndDo
	xRodape()

	oPrint:Preview()
	FreeObj( oPrint )

return

Static Function GetLinTxt( cSplitText, oFont, nMin, nMax )
	Local aRet       := {}
	Local cTextPrint := ''
	Local nTamText   := 0
	Local nLargura   := 0
	Local lFimText   := .F.
	Local nJ 		 := 0
	Local cText		 := cSplitText
	Local cTextTmp

	While Len( cText ) > 0
		cTextPrint := ''
		nTamText   := Len( cText )
		nLargura   := 0
		lFimText   := .F.
		For nJ := 1 To nTamText

			If nJ == nTamText
				lFimText := .T.
			Endif

			If Substr( cText, nJ, 1) == ' ' .OR. lFimText
				cTextPrint := ''
				cTextTmp   := Substr( cText, 1, nJ - Iif( lFimText, 0, 1 ) )
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
					cText := Substr( cText, nJ + 1 )
					Exit
				Endif
			Endif
		Next nJ
	End While
Return aRet

Static Function Cabec()
	nPagina++

	oPrint:StartPage()
	nLin := 00
	//CABEÇALHO
	oPrint:SayAlign( nLin + 0005, 0060, "Lista de Separação"           ,oFont16b, 0475, 0030, , 2, 1 )
	oPrint:Say( nLin + 0015, nColIni + 0500, "Página: " + CValToChar( nPagina )		, oFont10a)
	nLin += 20
	oPrint:Line(nLin + 0000, nColIni + 000, nLin + 0000, nColFim, 0,"-4")
	oPrint:Say( nLin + 0010, nColIni + 0400, "Emissão: "  				, oFont10a)
	oPrint:Say( nLin + 0010, nColIni + 0500, DtoC(SL1->L1_EMISSAO)		, oFont10a)
	oPrint:Say( nLin + 0025, nColIni + 0400, "Número do Oçamento: " 	, oFont10a)
	oPrint:Say( nLin + 0025, nColIni + 0500, SL1->L1_NUM				, oFont10a)
	oPrint:Say( nLin + 0040, nColIni + 0400, "Validade : " 				, oFont10a)
	oPrint:Say( nLin + 0040, nColIni + 0500, DToC(SL1->L1_DTLIM)		, oFont10a)


	oPrint:Say( nLin + 0010, nColIni + 0010, "Cliente :"			    , oFont10b)
	oPrint:Say( nLin + 0010, nColIni + 0065, AllTrim(SL1->L1_CLIENTE)	, oFont10a)
	oPrint:Say( nLin + 0020, nColIni + 0010, "Nome :"			        , oFont10b)
	oPrint:Say( nLin + 0020, nColIni + 0065, AllTrim(SA1->A1_NOME)		, oFont10a)
	oPrint:Say( nLin + 0030, nColIni + 0010, "Vendedor :"			    , oFont10b)
	oPrint:Say( nLin + 0030, nColIni + 0065, AllTrim(SL1->L1_VEND)		, oFont10a)
	oPrint:Say( nLin + 0040, nColIni + 0010, "Nome :"			        , oFont10b)
	oPrint:Say( nLin + 0040, nColIni + 0065, AllTrim(SA3->A3_NOME)		, oFont10a)
	oPrint:Say( nLin + 0050, nColIni + 0010, "Endereço :"			        , oFont10b)
	oPrint:Say( nLin + 0050, nColIni + 0065, AllTrim(SA1->A1_END)+" "+ Alltrim(SA1->A1_BAIRRO);
															     +" "+ Alltrim(SA1->A1_MUN)		, oFont09a)

	nLin += 40

Return


Static Function CabecItem()
//	oPrint:Line( nLin + 0000, nColIni + 0000, nLin + 0000, nColFim, 0,"-4")
//	oPrint:SayAlign( nLin + 0000, 0060, "Produtos"           ,oFont16b, 0475, 0017, , 2, 1 )
	oPrint:Line( nLin + 0020, nColIni + 0000, nLin + 0020, nColFim, 0,"-4")
	nLin += 0025

	oPrint:SayAlign( nLin + 0000, nColIni + 0000, "Item"		   	, oFont10a, 0030, 0030,, 0, 1 )
	oPrint:SayAlign( nLin + 0000, nColIni + 0020, "Código"		   	, oFont10a, 0060, 0030,, 0, 1 )
	oPrint:SayAlign( nLin + 0000, nColIni + 0090, "Descrição"		, oFont10a, 0250, 0030,, 0, 1 )
	oPrint:SayAlign( nLin + 0000, nColIni + 0320, "UM"				, oFont10a, 0030, 0030,, 0, 1 )
	oPrint:SayAlign( nLin + 0000, nColIni + 0360, "Qtde"	   		, oFont10a, 0030, 0030,, 1, 1 )
	oPrint:SayAlign( nLin + 0000, nColIni + 0410, "Vlr.Unitário"	, oFont10a, 0043, 0030,, 1, 1 )
	oPrint:SayAlign( nLin + 0000, nColIni + 0465, "Vlr.Desconto"	, oFont10a, 0050, 0030,, 1, 1 )
	oPrint:SayAlign( nLin + 0000, nColIni + 0520, "Vlr.Total"		, oFont10a, 0055, 0030,, 1, 1 )
	
	oPrint:Line( nLin + 0013, nColIni + 0000, nLin + 0013, nColFim, 0,"-4")

	nLin 	+= 15

Return

Static Function Item()
	Local nX			:= 0
	Local cQtde         := space(10)  

	cQtde      := Transform( SL2->L2_QUANT,"@E 99,999.99")
	cVlrUnit   := Transform( SL2->L2_VRUNIT  + SL2->L2_DESCPRO + (SL2->L2_VALDESC / SL2->L2_QUANT), "@E 999,999.99")
	cDesconto  := Transform( SL2->L2_VALDESC + SL2->L2_DESCPRO, "@E 99,999.99")
	cTotalItem := Transform( SL2->L2_VLRITEM, "@E 9,999,999.99")

	cDesc1 := ''
	oPrint:SayAlign( nLin + 0000, nColIni + 0000, AllTrim(SL2->L2_ITEM)	   				, oFont10a, 0030, 0030,, 0, 1 )
	oPrint:SayAlign( nLin + 0000, nColIni + 0020, AllTrim(SL2->L2_PRODUTO)	   			, oFont10a, 0060, 0030,, 0, 1 )
	oPrint:SayAlign( nLin + 0000, nColIni + 0320, AllTrim(SL2->L2_UM)					, oFont10a, 0030, 0030,, 0, 1 )
	oPrint:SayAlign( nLin + 0000, nColIni + 0350, AllTrim(cQtde)	   					, oFont10a, 0040, 0030,, 1, 1 )
	oPrint:SayAlign( nLin + 0000, nColIni + 0410, AllTrim(cVlrUnit)						, oFont10a, 0043, 0030,, 1, 1 )
	oPrint:SayAlign( nLin + 0000, nColIni + 0465, AllTrim(cDesconto)					, oFont10a, 0050, 0030,, 1, 1 )
	oPrint:SayAlign( nLin + 0000, nColIni + 0520, AllTrim(cTotalItem)					, oFont10a, 0055, 0030,, 1, 1 )

	nValDesc += SL2->L2_VALDESC

	cDescProd 	:= Alltrim( SL2->L2_DESCRI )
	aDescricao 	:= GetLinTxt( cDescProd, oFont09a, 245, 255 )

	If Len( aDescricao ) > 0
		For nX := 1 To Len( aDescricao )
			oPrint:SayAlign( nLin + 0000, nColIni + 0090, aDescricao[ nX ]				, oFont09a, 0250, 0030,, 0, 1 )
			nLin += 10
		Next nX
	Endif

//	oPrint:SayAlign( nLin + 0000, nColIni + 0360, cQtde	   						, oFont10a, 0030, 0030,, 1, 1 )
//	oPrint:SayAlign( nLin + 0000, nColIni + 0410, cVlrUnit						, oFont10a, 0043, 0030,, 1, 1 )
//	oPrint:SayAlign( nLin + 0000, nColIni + 0465, cDesconto						, oFont10a, 0050, 0030,, 1, 1 )
//	oPrint:SayAlign( nLin + 0000, nColIni + 0520, cTotalItem					, oFont10a, 0055, 0030,, 1, 1 )

	nLin += 10
//	oPrint:Line( nLin + 0003, nColIni + 000, nLin + 0003, nColFim, 0,"-4")
	
//	nLin += 3

Return

Static Function xRodape()
	Local cCondPag 		:= Posicione('SE4', 1, xFilial('SE4') + SL1->L1_CONDPG, 'E4_DESCRI')
	Local aObserv 		:= 0
	Local cObserv 		:= 0
	Local nX
	
	nLin := nLinRP

	oPrint:Line( nLin + 0005, nColIni + 000, nLin + 0005, nColFim, 0,"-4")

	oPrint:Say( nLin + 0020, nColIni + 0010, "T O T A L"		, oFont10a)
	oPrint:SayAlign( nLin + 0013,  nColIni + 0140, Transform(SL1->L1_VLRTOT + SL1->L1_DESCONT + nValDesc	, "@E 999,999,999.99") ,oFont10b, 0050, 0010, , 1, 1 )

	nLin +=0020

	oPrint:Line( nLin + 0005, nColIni + 000, nLin + 0005, nColFim, 0,"-4")

	oPrint:Say( nLin + 0020, nColIni + 0010, "D E S C O N T O"	, oFont10a)
	oPrint:SayAlign( nLin + 0013,  nColIni + 0140,  Transform(SL1->L1_DESCONT + nValDesc					, "@E 999,999,999.99") ,oFont10b, 0050, 0010, , 1, 1 )

	nLin +=0020

	oPrint:Line( nLin + 0005, nColIni + 000, nLin + 0005, nColFim, 0,"-4")

	oPrint:Say( nLin + 0020, nColIni + 0010, "L Í Q U I D O"	, oFont10a)
	oPrint:SayAlign( nLin + 0013,  nColIni + 0140, Transform(SL1->L1_VLRLIQ								, "@E 999,999,999.99"),oFont10b,0050, 0010, , 1, 1 )

	nLin +=0020
	oPrint:Line( nLin + 0005, nColIni + 000, nLin + 0005, nColFim, 0,"-4")

	oPrint:Say( nLin + 0020, nColIni + 0010, "O B S E R V A Ç Õ E S"	, oFont10a)
	nLinObs := nLin + 0013
	cObserv 	:= Alltrim( SL1->L1_XOBS )
	aObserv 	:= GetLinTxt( cObserv, oFont09a, 495, 505 )
	If Len( aObserv ) > 0
		For nX := 1 To Len( aObserv )
			oPrint:SayAlign( nLinObs, nColIni + 0120, aObserv[ nX ], oFont09a, 500, 20, , 0, 1 )
			nLinObs	+= 10
			nLin += 10
		Next nX
	Endif

	nLin +=0020
	oPrint:Line( nLin + 0005, nColIni + 000, nLin + 0005, nColFim, 0,"-4")

	oPrint:Say( nLin + 0020, nColIni + 0010, "C O N D I Ç Ã O  D E  P A G A M E N T O"	, oFont10a)
	oPrint:Say( nLin + 0020,  nColIni + 0160, cCondPag, oFont10b)


	oPrint:Say( nLin + 0020, nColIni + 0330, "A  P A G A R"	, oFont10a)
	oPrint:Say( nLin + 0020, nColIni + 0380, TRANSFORM(SL1->L1_VLRLIQ								, "@E 999,999,999.99"), oFont10b)

	nLin +=0020
	oPrint:Line( nLin + 0005, nColIni + 000, nLin + 0005, nColFim, 0,"-4")

	oPrint:SayAlign( nLin + 0010, 0000, "*** EXIJA O CUPOM FISCAL - NÂO É VÁLIDO COMO GARANTIA DE MERCADORIA ***"           ,oFont07b, nColFim, 0030, , 2, 1 )
	oPrint:SayAlign( nLin + 0020, 0000, AllTrim(SM0->M0_NOME) + " || " +AllTrim(SM0->M0_ENDENT)  +" " + AllTrim(SM0->M0_BAIRENT) +" | " + AllTrim(SM0->M0_CIDENT) +" - " + AllTrim(SM0->M0_ESTENT) +" || " + AllTrim(SM0->M0_TEL),oFont07b, nColFim, 0030, , 2, 1 )

	oPrint:EndPage()
Return
