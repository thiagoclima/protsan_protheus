#Include 'Protheus.ch'
#Include 'TbiConn.ch'

/*/{Protheus.doc} EnvEmlCT
Envia a cotação por e-mail aos fornecedores.
Executado via PE MT150ROT.
@type function
@version 12.1.25
@author Heverson Gomes 
@since 02/08/2021
@param cxFilial, character, Filial da Cotação
@param cxCotacao, character, Número da Cotação
/*/
User Function EnvEmlCT( cxFilial, cxCotacao )
	Local cAliasTMP := GetNextAlias()
	Local cQuery    := ''
	Local nTotReg   := 0

	Local oSendMail := Nil
	Local cDestino  := ''
	Local cAssunto  := ''
	Local cCorpo    := ''
	Local aRetCota  := {}

	Default cxFilial   := FwxFilial('SC8')
	Default cxCotacao := PadR( '', TamSX3('C8_NUM')[1] )

	If !MsgYesNo('Confirma o envio da cotação aos fornecedores por e-mail?')
		Return
	Endif

	cQuery := "SELECT DISTINCT C8_NUM, C8_FORNECE, C8_LOJA "
	cQuery += "FROM " + RetSqlName('SC8') + "  "
	cQuery += "WHERE D_E_L_E_T_ = '' "
	cQuery += "  AND C8_FILIAL = '" + cxFilial + "' "
	cQuery += "  AND C8_NUM = '" + cxCotacao + "' "
	cQuery += "ORDER BY C8_FORNECE, C8_LOJA "

	dbUseArea(.T., 'TOPCONN', TCGenQry(,,cQuery),cAliasTMP,.F.,.T.)
	(cAliasTMP)->( dbEval( { || nTotReg++ },,{ || !Eof() } ) )
	(cAliasTMP)->( dbGoTop() )

	If nTotReg > 0

		While !(cAliasTMP)->( Eof() )

			aRetCota := GetCorpo( cxFilial, cxCotacao, (cAliasTMP)->C8_FORNECE, (cAliasTMP)->C8_LOJA )
			cDestino := aRetCota[1]
			cCorpo   := aRetCota[2]
			
			cAssunto := 'Solicitação de Compra'

			oSendMail := SendMail():newSendMail()
			oSendMail:send( cDestino, cAssunto, cCorpo )

			FreeObj( oSendMail )
			
			(cAliasTMP)->( dbSkip() )
		End While

	Endif

	(cAliasTMP)->( dbCloseArea() )

Return

/*/{Protheus.doc} GetCorpo
Monta o HTML para enviar ao fornecedor
@type function
@version 12.1.25
@author Paulo Apolinário
@since 02/08/2021
@param cxFilial, character, Filial da cotação
@param cxCotacao, character, Número da cotação
@param cxFornece, character, Fornecedor
@param cxLoja, character, Loja
@return array, E-mail do fornecedor e corpo do HTML
/*/
Static Function GetCorpo( cxFilial, cxCotacao, cxFornece, cxLoja )
	Local cRet      := ''
	Local cMailForn := ''
	Local aAreaSC8  := {}

	If Select('SC8') <> 0
		aAreaSC8 := SC8->( GetArea() )
	Endif

	dbSelectArea('SC8')
	SC8->( dbSetOrder( 1 ) ) //C8_FILIAL+C8_NUM+C8_FORNECE+C8_LOJA+C8_ITEM+C8_NUMPRO+C8_ITEMGRD
	SC8->( dbSeek( cxFilial + cxCotacao + cxFornece + cxLoja ) )

	dbSelectArea('SA2')
	SA2->( dbSetOrder( 1 ) )
	SA2->( dbSeek( FwxFilial('SA2') + cxFornece + cxLoja ) )

	cMailForn := Alltrim( SA2->A2_EMAIL )

	cRet += ' <html>'
	cRet += ' '
	cRet += ' <head>'
	cRet += ' <meta http-equiv="Content-Language" content="en-us">'
	cRet += ' <meta http-equiv="Content-Type"'
	cRet += ' content="text/html; charset=iso-8859-1">'
	cRet += ' <meta name="ProgId" content="FrontPage.Editor.Document">'
	cRet += ' <meta name="GENERATOR" content="Microsoft FrontPage Express 2.0">'
	cRet += ' <title>Solicitação de Compras </title>'
	cRet += ' </head>'
	cRet += ' '
	cRet += ' <body background="file:///e:/ap6/workflow/evento/fundo609.jpg"'
	cRet += ' bgcolor="#FFFFFF" bgproperties="fixed">'
	cRet += ' '
	cRet += ' <img src="https://protsan.com.br/wp-content/uploads/2021/02/cropped-protsan-187x63.png"><br>
	cRet += '     <p align="right"><font color="#FFFFFF" size="3" face="Arial"><strong><span style="text-transform: uppercase"></strong></font><font'
	cRet += '     color="#FF0000" size="3" face="Arial"><strong>Cotação</strong></font><font'
	cRet += '     color="#FFFFFF" size="3" face="Arial"></font></p>'
	cRet += '     <p align="right">&nbsp;</p>'
	cRet += '     <table border="3" width="100%" bordercolor="#DFEFFF"'
	cRet += '     bordercolordark="#DFEFFF" bordercolorlight="#DFEFFF">'
	cRet += '         <tr>'
	cRet += '             <td rowspan="2" width="552" bgcolor="#DFEFFF"'
	cRet += '             height="1"><font size="2" face="Arial">PREZADOS'
	cRet += '             SENHORES.<br>'
	cRet += '             ' + SA2->A2_NOME + '&nbsp;&nbsp;&nbsp; (' + SC8->C8_FORNECE + '-'
	cRet += '             ' + SC8->C8_LOJA + ')<br>'
	cRet += '             ' + SA2->A2_END + ',&nbsp; ' + SA2->A2_NR_END + '<br>'
	cRet += '             ' + SA2->A2_BAIRRO + '&nbsp; -&nbsp; ' + SA2->A2_MUN + '<br>'
	cRet += '             Fone: ' + SA2->A2_TEL + '<br>'
	cRet += '             Fax : ' + SA2->A2_FAX + '</font><font size="3" face="Arial"><br>'
	cRet += '             <br>'
	cRet += '             </font><font size="2" face="Arial">Solicitamos de V.'
	cRet += '             Sas, cotação de preços para os produtos'
	cRet += '             discriminados conforme os padrões abaixo'
	cRet += '             estabelecidos:</font></td>'
	cRet += '             <td width="126" bgcolor="#DFEFFF" height="1"><p'
	cRet += '             align="right"><font size="3" face="Arial"><b>Cotação'
	cRet += '             nº </b>:' + SC8->C8_NUM + '</font> </p>'
	cRet += '             </td>'
	cRet += '         </tr>'
	cRet += '         <tr>'
	cRet += '             <td width="126" bgcolor="#DFEFFF" height="12"><p'
	cRet += '             align="right"><font size="3" face="Arial"><b>Vencimento'
	cRet += '             </b>: ' + DTOC( SC8->C8_VALIDA ) + '</font> </p>'
	cRet += '             </td>'
	cRet += '         </tr>'
	cRet += '     </table>'
	cRet += '     <table border="3" width="100%" bgcolor="#FFFFFF"'
	cRet += '     bordercolor="#DFEFFF" bordercolordark="#DFEFFF"'
	cRet += '     bordercolorlight="#DFEFFF">'
	cRet += '         <tr>'
	cRet += '             <td align="center" width="48" bgcolor="#DFEFFF"'
	cRet += '             height="23"><font size="1" face="Arial">Item </font></td>'
	cRet += '             <td align="center" width="66" bgcolor="#DFEFFF"'
	cRet += '             height="23"><font size="1" face="Arial">N/Vosso'
	cRet += '             Codigo </font></td>'
	cRet += '             <td align="center" width="60" bgcolor="#DFEFFF"'
	cRet += '             height="23"><font size="1" face="Arial">Descrição'
	cRet += '             da Mercadoria</font></td>'
	cRet += '             <td align="center" width="55" bgcolor="#DFEFFF"'
	cRet += '             height="23"><font size="1" face="Arial">Qtde </font></td>'
	cRet += '             <td align="center" width="42" bgcolor="#DFEFFF"'
	cRet += '             height="23"><font size="1" face="Arial">UN </font></td>'
	cRet += '             <td align="center" width="90" bgcolor="#DFEFFF"'
	cRet += '             height="23"><font size="1" face="Arial">Valor Unitário'
	cRet += '             </font></td>'
	cRet += '             <td align="center" width="90" bgcolor="#DFEFFF"'
	cRet += '             height="23"><font size="1" face="Arial">Valor Total </font></td>'
	cRet += '             <td align="center" width="40" bgcolor="#DFEFFF"'
	cRet += '             height="23"><font size="1" face="Arial">IPI</font></td>'
	cRet += '             <td align="center" width="40" bgcolor="#DFEFFF"'
	cRet += '             height="23"><font size="1" face="Arial">ICMS</font></td>'
	cRet += '             <td align="center" width="40" bgcolor="#DFEFFF"'
	cRet += '             height="23"><font size="1" face="Arial">ICMS ST</font></td>'
	cRet += '             <td align="center" width="40" bgcolor="#DFEFFF"'
	cRet += '             height="23"><font size="1" face="Arial">Prazo</font></td>'
	cRet += '         </tr>'

	While !SC8->( Eof() ) .AND. SC8->C8_FILIAL == cxFilial .AND. SC8->C8_NUM == cxCotacao .AND. SC8->C8_FORNECE == cxFornece .AND. SC8->C8_LOJA == cxLoja

		dbSelectArea('SB1')
		SB1->( dbSetOrder( 1 ) )
		SB1->( dbSeek( FwxFilial('SB1') + SC8->C8_PRODUTO ) )

		cRet += '         <tr>'
		cRet += '             <td align="center" width="48" height="21"><font size="1" face="Arial">' + SC8->C8_ITEM + '</font></td>'
		cRet += '             <td width="66" height="21"><font size="1" face="Arial">' + SC8->C8_PRODUTO + '</font></td>'
		cRet += '             <td align="center" width="60" height="21"><font size="1" face="Arial">' + Alltrim( SB1->B1_DESC ) + '</font></td>'
		cRet += '             <td align="center" width="55" height="21"><font size="1" face="Arial">' + Transform( SC8->C8_QUANT, PesqPict('SC8','C8_QUANT') ) +'</font></td>'
		cRet += '             <td align="center" width="42" height="21"><font size="1" face="Arial">' + SC8->C8_UM + ' </font></td>'
		cRet += '             <td align="center" width="90" bgcolor="#FFFFFF" bordercolor="#FFFFFF" bordercolordark="#FFFFFF" bordercolorlight="#FFFFFF" height="21"><font size="1"'
		cRet += '             face="Arial"><!--webbot bot="Validation"'
		cRet += '             s-display-name="Valor Unitário" s-data-type="Number"'
		cRet += '             s-number-separators=".," b-value-required="TRUE"'
		cRet += '             i-maximum-length="12"'
		cRet += '             s-validation-constraint="Greater than or equal to"'
		// cRet += '             s-validation-value="0" -->' + Transform( SC8->C8_PRECO, PesqPict('SC8','C8_PRECO') ) + '</font></td>'
		cRet += '             s-validation-value="0" --> ............ </font></td>'
		cRet += '             <td align="center" width="90" height="21"><font'
		cRet += '             size="1" face="Arial"><!--webbot bot="Validation"'
		cRet += '             s-display-name="Valor Total" s-data-type="Number"'
		cRet += '             s-number-separators=".," b-value-required="TRUE"'
		cRet += '             i-maximum-length="12"'
		cRet += '             s-validation-constraint="Greater than or equal to"'
		//cRet += '             s-validation-value="0" -->' + Transform( SC8->C8_TOTAL, PesqPict('SC8','C8_TOTAL') ) + '</font></td>'
		cRet += '             s-validation-value="0" --> .............. </font></td>'
		cRet += '             <td align="center" width="40" height="21"><font'
		cRet += '             size="1" face="Arial"><!--webbot bot="Validation"'
		cRet += '             s-display-name="IPI" s-data-type="Number"'
		cRet += '             s-number-separators=".," b-value-required="TRUE"'
		// cRet += '             i-maximum-length="5" -->' + Transform( SC8->C8_ALIIPI, PesqPict('SC8','C8_ALIIPI') ) + '</font></td>'
		cRet += '             i-maximum-length="5" --> .............. </font></td>'
		cRet += '             <td align="center" width="40" bgcolor="#DFEFFF"'
		cRet += '             height="23"><font size="1" face="Arial"><!--webbot bot="Validation"'
		cRet += '             s-display-name="ICMS" s-data-type="Number"'
		cRet += '             s-number-separators=".," b-value-required="TRUE"'
		// cRet += '             i-maximum-length="5" -->' + Transform( SC8->C8_ICMS, PesqPict('SC8','C8_ICMS') ) + '</font></td>'
		cRet += '             i-maximum-length="5" --> .............. </font></td>'
		cRet += '             <td align="center" width="40" bgcolor="#DFEFFF"'
		cRet += '             height="23"><font size="1" face="Arial"><!--webbot bot="Validation"'
		cRet += '             s-display-name="ICMS" s-data-type="Number"'
		cRet += '             s-number-separators=".," b-value-required="TRUE"'
		// cRet += '             i-maximum-length="5" -->' + Transform( SC8->C8_ICMSST, PesqPict('SC8','C8_ICMSST') ) + '</font></td>'
		cRet += '             i-maximum-length="5" --> .............. </font></td>'
		cRet += '             <td align="center" width="40" height="21"><font'
		// cRet += '             size="1" face="Arial">' + Transform( SC8->C8_PRAZO, PesqPict('SC8','C8_PRAZO') ) + '</font></td>'
		cRet += '             size="1" face="Arial"> .............. </font></td>'
		cRet += '         </tr>'

		SC8->( dbSkip() )
	End While

	cRet += '     </table>'
	cRet += '     <table border="3" width="100%" bordercolor="#DFEFFF"'
	cRet += '     bordercolordark="#DFEFFF" bordercolorlight="#DFEFFF">'
	cRet += '         <tr>'
	cRet += '             <td><table border="0" cellpadding="0" cellspacing="0"'
	cRet += '             width="100%">'
	cRet += '                 <tr>'
	cRet += '                     <td width="35%"><font size="2" face="Arial">Local de Entrega&nbsp;</font> </td>'
	cRet += '                     <td width="17%"><font size="2" face="Arial">Sub Total</font></td>'
	cRet += '                     <td width="13%"><font size="1" face="Arial"> .............. </font></td>' //%subtot% 
	cRet += '                     <td width="25%"><font size="2" face="Arial">Condição de Pagamento</font></td>'
	cRet += '                 </tr>'
	cRet += '                 <tr>'
	cRet += '                     <td width="35%"><font size="2" face="Arial">' + SC8->C8_FILENT + '</font></td>'
	cRet += '                     <td width="17%"><font size="2" face="Arial">Descontos</font></td>'
	// cRet += '                     <td width="13%"><font size="1" face="Arial">' + Transform( SC8->C8_VLDESC, PesqPict('SC8','C8_VLDESC') ) + '</font></td>'
	cRet += '                     <td width="13%"><font size="1" face="Arial"> .............. </font></td>'
	// cRet += '                     <td width="25%"><font size="1" face="Arial">' + SC8->C8_COND + '</font></td>'
	cRet += '                     <td width="25%"><font size="1" face="Arial"> .............. </font></td>'
	cRet += '                 </tr>'
	cRet += '                 <tr>'
	cRet += '                     <td width="35%"><font size="2" face="Arial">Local de Pagamento</font></td>'
	cRet += '                     <td width="17%"><font size="2" face="Arial">Total do IPI</font></td>'
	// cRet += '                     <td width="13%"><font size="1" face="Arial">' + Transform( SC8->C8_ALIIPI, PesqPict('SC8','C8_ALIIPI') ) + '</font></td>'
	cRet += '                     <td width="13%"><font size="1" face="Arial"> .............. </font></td>'
	cRet += '                     <td width="25%">&nbsp;</td>'
	cRet += '                 </tr>'
	cRet += '                 <tr>'
	cRet += '                     <td width="35%"><font size="2" face="Arial">' + '' + '</font>' //%rever%
	cRet += '                     </td>'
	cRet += '                     <td width="17%"><font size="2" face="Arial">Frete&nbsp;&nbsp;'
	cRet += '                     </font><font size="1" face="Arial">' + SC8->C8_TPFRETE + '</font></td>'
	// cRet += '                     <td width="13%"><font size="1" face="Arial">' + Transform( SC8->C8_VALFRE, PesqPict('SC8','C8_VALFRE') ) + '</font></td>'
	cRet += '                     <td width="13%"><font size="1" face="Arial"> .............. </font></td>'
	cRet += '                     <td width="25%"><font size="2" face="Arial">Condição de Reajuste</font></td>'
	cRet += '                 </tr>'
	cRet += '                 <tr>'
	cRet += '                     <td width="35%"><font size="2" face="Arial">Contato no Fornecedor</font> </td>'
	cRet += '                     <td width="17%"><font size="2" face="Arial">TOTAL DO PEDIDO</font> </td>'
	cRet += '                     <td width="13%"><font size="1" face="Arial"> .............. </font></td>'
	cRet += '                     <td width="25%">&nbsp;</td>'
	cRet += '                 </tr>'
	cRet += '                 <tr>'
	cRet += '                     <td width="35%"><font size="2" face="Arial">' + SC8->C8_CONTATO + '</font>'
	cRet += '                     </td>'
	cRet += '                     <td width="17%">&nbsp;</td>'
	cRet += '                     <td width="13%">&nbsp;</td>'
	cRet += '                     <td width="25%">&nbsp;</td>'
	cRet += '                 </tr>'
	cRet += '             </table>'
	cRet += '             </td>'
	cRet += '         </tr>'
	cRet += '     </table>'
	cRet += ' '
	cRet += ' </body>'
	cRet += ' </html>'

Return { cMailForn, cRet }
