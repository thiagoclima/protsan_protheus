#Include 'Protheus.ch'

User Function prota002(cTp)
    Local aArea := GetArea()
    Local lRet  := .t.
    Local cHist     := ""

    If cTp == "V" .AND. !SL1->L1_XIMPBLQ $ 'L,I'
        cHist := Alltrim(SL1->L1_XHISBLQ)
        cHist += "==========================="+CRLF
        FwMsgRun(NIL, {|oSay| lRet := AnaOrc(oSay,@cHist) }, "Processing", "Starting process...")
        RecLock("SL1",.F.)
            If !lRet
                SL1->L1_XIMPBLQ := 'B'
            Endif
            SL1->L1_XHISBLQ := cHist 
        SL1->(MsUnlock())
        If !lRet
            MsgStop("Foram encontrados ALERTAS, orçamento não será impresso")
        EndIf
    EndIf
    If cTp == "L"
        cHist := Alltrim(SL1->L1_XHISBLQ)
        cHist += "==========================="+CRLF
        FwMsgRun(NIL, {|oSay| lRet := LibOrc(oSay,@cHist) }, "Processing", "Starting process...")
        RecLock("SL1",.F.)
            If lRet
                SL1->L1_XIMPBLQ := 'L'
            Endif
            SL1->L1_XHISBLQ := cHist 
        SL1->(MsUnlock())
    EndIf
    RestArea(aArea)
Return(lRet)

Static Function AnaOrc(oSay,cHist)
    Local lRet      := .t.
    Local lCredito  := .f.
    Local lEstoque  := .f.
    Local cBlqCred  := ""
    Local cTimeStmp := ""
    Local nSaldoDisp:= 0
    
    oSay:SetText("Verificando Crédito") 
    ProcessMessage() 

    cTimeStmp := DtoC(Date())+"-"+Time()
    lCredito := MaAvalCred(SL1->L1_CLIENTE,SL1->L1_LOJA,SL1->L1_VLRTOT,SL1->L1_MOEDA,.T.,@cBlqCred)

    If lCredito
        cHist += cTimeStmp+"-CRÉDITO [OK]"+CRLF
    else
        cHist += cTimeStmp+"-ANALISE DE CRÉDITO [ALERTA]"+CRLF 
        cHist += "BLOQUEIO DE CREDITO ["+cBlqCred+"]"+CRLF      
        lRet := .F.
    Endif

    oSay:SetText("Verificando Estoque Produtos") 
    ProcessMessage() 

    SL2->(DbSetOrder(1))
    If SL2->(DbSeek(SL1->(L1_FILIAL+L1_NUM)))
        cHist += cTimeStmp+"-ANALISE DE ESTOQUE"+CRLF
        cTimeStmp := DtoC(Date())+"-"+Time()
        while !SL2->(eOf()) .AND. SL2->(L2_FILIAL+L2_NUM) == SL1->(L1_FILIAL+L1_NUM)
            SB2->(dbSetOrder(1))
            If SB2->(dbSeek(xFilial('SB2')+SL2->(L2_PRODUTO+L2_LOCAL)))
                nSaldoDisp := SaldoSB2()
            else
                nSaldoDisp := 0
            EndIf
            lEstoque := SL2->L2_QUANT <= nSaldoDisp
            If lEstoque
                cHist +="PRODUTO "+Alltrim(SL2->L2_PRODUTO)+" LOCAL "+SL2->L2_LOCAL+" QTD "+Alltrim(Str(SL2->L2_QUANT))+" SALDO "+Alltrim(Str(nSaldoDisp))+" [OK]"+CRLF
            else
                cHist +="PRODUTO "+Alltrim(SL2->L2_PRODUTO)+" LOCAL "+SL2->L2_LOCAL+" QTD "+Alltrim(Str(SL2->L2_QUANT))+" SALDO "+Alltrim(Str(nSaldoDisp))+" [ALERTA]"+CRLF
                lRet := .F.
            Endif
            SL2->(DbSkip())            
        end
    EndIf
Return(lRet)

Static Function LibOrc(oSay,cHist)
    Local lRet      := .t.
    Local oDlg      := NIL
    Local oFont     := NIL
    Local oMemo     := NIL
    Local cTexto    := SL1->L1_XHISBLQ
    Local cUserLib  := GetNewPar("X_ULIBIMP","000000")
    Local nOpcA     := 0
    Local cTimeStmp := ""
    Local   cMask     := "Arquivos Texto" + "(*.TXT)|*.txt|"

	Define Font oFont Name "Mono AS" Size 5, 12

    Define MsDialog oDlg Title "Histórico Análise para Impressão" From 3, 0 to 340, 417 Pixel

    @ 5, 5 Get oMemo Var cTexto Memo Size 200, 145 Of oDlg Pixel
    oMemo:bRClicked := { || AllwaysTrue() }
    oMemo:oFont     := oFont

    If SL1->L1_XIMPBLQ == 'B' .AND. __cUserID $ cUserLib
        Define SButton From 153, 175 Type  1 Action (nOpcA:= 1, oDlg:End()) Enable Of oDlg Pixel // Apaga
    EndIf
    Define SButton From 153, 145 Type 13 Action ( nOpcA:= 0, cFile := cGetFile( cMask, "" ), If( cFile == "", .T., ;
    MemoWrite( cFile, cTexto ) ) ) Enable Of oDlg Pixel

    Activate MsDialog oDlg Center

    If nOpcA = 1 .and. MsgYesNo("Confirma a liberação de impressão do Orçamento?", "Confirma?")
        cTimeStmp := DtoC(Date())+"-"+Time()
        cHist += cTimeStmp+"-LIBERAÇÃO IMPRESSÃO DE ORÇAMENTO"+CRLF
        cHist +="LIBERADO POR "+__cUserId + " " +  cUserName+CRLF
        lRet := .t.
    else
        lRet := .f.   
    EndIf

Return(lRet)
