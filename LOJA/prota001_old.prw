#Include 'Protheus.ch'

Static cProdSelected := ""

User Function prota001(cTp)
    Local aArea :=  GetArea()
    Local ni    := 0
    Local xRet  
    Default cTp := '1'

    Private oFontBrw := TFont():New("Arial",,-10,.T.)

    aDelArqs      := {}
    
    If cTp == '1'
        FwMsgRun(NIL, {|oSay| xRet := ConsProd(oSay) }, "Processing", "Starting process...")
        For ni := 1 to Len(aDelArqs)
            oTempX := aDelArqs[ni]
            oTempX:Delete()
        Next
    EndIf

    If cTp == '2'
        xRet := cProdSelected
    EndIf

    RestArea(aArea)
Return(xRet)

Static Function ConsProd(oSay)
    Local aCoors    := FWGetDialogSize( oMainWnd )
    Local cCadastro := "Pesquisa Produtos - Protsan"
    Local oDlgPrinc 
    Local oFWLayer
    Local oPanelPara,oPanelObs,oPanelFoto,oPanelGrid,oPanelButton
    Local oBrowseCons
    Local cFabric   := Space( 40 )
    Local cProdut   := Space( 15 )
    Local cDescPr   := Space( 40 ) 
    Local cAliasTB1 := "SB1TMP"
    Local lRet      := .f.
    Local nOpcDlg   := 0
    
    Lj7SetKeys(.F.)

    cProdSelected := ""

    oSay:SetText("Criando Área de Trabalho") 
    ProcessMessage() 

    CriaTRB(cAliasTB1)

    aRotina := {}
    Define MsDialog oDlgPrinc Title cCadastro From aCoors[1], aCoors[2] To aCoors[3]/1.2, aCoors[4] Pixel
        oFWLayer := FWLayer():New()
        oFWLayer:Init( oDlgPrinc, .F., .T. )

        oFWLayer:AddLine( 'PAR', 40, .F. )
            oFWLayer:AddCollumn( 'COL1', 30, .T., 'PAR' )
                oFWLayer:AddWindow('COL1','WIN1','Parâmetros',100,.T.,.T.,,'PAR')
                oPanelPara := oFWLayer:GetWinPanel( 'COL1', 'WIN1', 'PAR' )
            oFWLayer:AddCollumn( 'COL2', 50, .T., 'PAR' )
                oFWLayer:AddWindow('COL2','WIN1','Observações Produto',100,.T.,.T.,,'PAR')
                oPanelObs := oFWLayer:GetWinPanel( 'COL2', 'WIN1', 'PAR' )
            oFWLayer:AddCollumn( 'COL3', 20, .T., 'PAR' )
                oFWLayer:AddWindow('COL3','WIN2','Foto Produto',100,.T.,.T.,,'PAR')
                oPanelFoto := oFWLayer:GetWinPanel( 'COL3', 'WIN2', 'PAR' )        
        
        oFWLayer:AddLine( 'GRI', 55, .F. )
            oFWLayer:AddCollumn( 'COL1', 100, .T., 'GRI' )
                oFWLayer:AddWindow('COL1','WIN1','Resultado Pesquisa',100,.T.,.T.,,'GRI')
                oPanelGrid := oFWLayer:GetWinPanel( 'COL1', 'WIN1', 'GRI' )

        oFWLayer:AddLine( 'BOT', 05, .F. )
            oFWLayer:AddCollumn( 'COL1', 100, .T., 'BOT' )
            oPanelButton:=oFWLayer:GetColPanel( 'COL1', 'BOT' )
        
        oGet := TMultiGet():New(0,0,{|u| (cAliasTB1)->OBSERVACAO},oPanelObs,399,049,,.F.,,,,.T.,,,,,,.t./*lLeitura*/,,,,.F.)
        oGet:align := CONTROL_ALIGN_ALLCLIENT
        
        oBmp := TBmpRep():New(1,01,200,200,"",.T.,oPanelFoto,{|u| Showbitmap(oBmp,(cAliasTB1)->BITMAP,"") },{|u| Showbitmap(oBmp,(cAliasTB1)->BITMAP,"") },.F.,.F.,,,,)	
        oBmp:align := CONTROL_ALIGN_ALLCLIENT

        oBrowseCons:= FWBrowse():New()
            oBrowseCons:SetOwner( oPanelGrid )                                      
            oBrowseCons:SetDescription( "Produtos" )
            oBrowseCons:DisableFilter()
            oBrowseCons:DisableReports()
            oBrowseCons:SetDataTable()
            oBrowseCons:SetAlias( cAliasTB1 )
            oBrowseCons:SetColumns( getColumns((cAliasTB1)->(dbStruct()),{}) )
            oBrowseCons:SetProfileID( '1' )
            oBrowseCons:setChange({|| Showbitmap(oBmp,(cAliasTB1)->BITMAP,"") })
            oBrowseCons:SetLineHeight(10) 
            oBrowseCons:SetFontBrowse(oFontBrw)
        oBrowseCons:Activate()

        DEFINE FONT oBold NAME "Arial" SIZE 0, -13 BOLD
                                                    
        @ 12, 00 SAY "Descrição" of oPanelPara SIZE 40, 00   PIXEL  // 
        @ 10, 30 MSGET oGetPesq2 VAR cDescPr of oPanelPara SIZE 150, 10 VALID .T.  PIXEL  PICTURE "@!"

        @ 26, 00 SAY "Fabricante" of oPanelPara SIZE 40, 00  PIXEL  // 
        @ 24, 30 MSGET oGetPesq3 VAR cFabric of oPanelPara SIZE 150, 10 VALID .T. PIXEL

        @ 40, 00 SAY "Codigo" of oPanelPara SIZE 40, 00    PIXEL  // 
        @ 38, 30 MSGET oGetPesq3 VAR cProdut of oPanelPara SIZE 150, 00 VALID .T. PIXEL F3 "SB1" HasButton PICTURE "@!"
                                                            
        @ 60, 00 Button "&Filtrar" of oPanelPara Size 30,12 Pixel Action FwMsgRun(NIL, {|o| FiltraDados(o,cDescPr,cFabric,cProdut,cAliasTB1,oBrowseCons,oBmp) }, cCadastro, "Buscando Produtos...") 
        @ 60, 45 Button "&Limpar"  of oPanelPara Size 30,12 Pixel Action LimpaCampos( @cDescPr,@cFabric,@cProdut,cAliasTB1,oBrowseCons )

        oBtn1 := TButton():New( 002, 002, "Confirmar",oPanelButton,{||nOpcDlg:= 1 , oDlgPrinc:End()}, 40,10,,,.F.,.T.,.F.,,.F.,,,.F. )   
        oBtn1:Align := CONTROL_ALIGN_RIGHT
        oBtn2 := TButton():New( 002, 002, "Sair",oPanelButton,{||nOpcDlg:= 0, oDlgPrinc:End()}, 40,10,,,.F.,.T.,.F.,,.F.,,,.F. ) 
        oBtn2:Align := CONTROL_ALIGN_RIGHT
        
    Activate MsDialog oDlgPrinc Center

    If !(cAliasTB1)->(Eof())
        If nOpcDlg == 1
            cProdSelected := (cAliasTB1)->PRODUTO
            lRet := .t.
        Else
            lRet := .f.
        Endif
    Else
        lRet := .f.
    EndIf

    Lj7SetKeys(.T.)
Return(lRet)

Static Function CriaTRB(cAliasTB1)
    Local oTempT01  := nil

    If Select(cAliasTB1) > 0
        DbSelectArea(cAliasTB1)
        (cAliasTB1)->(DbCloseArea())
    EndIf

    aCpos:= {}

    aCpos:= {   {"PRODUTO"            ,"C",015,0 },;
                {"DESCRICAO"          ,"C",100,0 },;
                {"FABRICANTE"         ,"C",012,0 },;
                {"COD_FABRIC"         ,"C",015,0 },;
                {"NCM"                ,"C",015,0 },;
                {"DT_ULTCOM"          ,"D",008,0 },;
                {"ULT_PRCVEN"         ,"N",015,2 },;
                {"PRECO_ATU"          ,"N",015,2 },;
                {"SANTOS"             ,"N",015,2 },;
                {"CUBATAO"            ,"N",015,2 },;
                {"ULT_PEDIDO"         ,"C",006,0 },;
                {"ULT_VENDA"          ,"C",020,0 },;
                {"VENDEDOR"           ,"C",030,0 },;
                {"BITMAP"             ,"C",020,0 },;
                {"OBSERVACAO"         ,"M",010,0 }}

    oTempT01 := FwTemporaryTable():New(cAliasTB1,aCpos)

    oTempT01:AddIndex("T01",{"PRODUTO"})
    oTempT01:Create()

    aAdd(aDelArqs,oTempT01)

Return

static function getColumns(aFields, aCpoFil)
    local aColumns as array
    local nLoop as numeric
    Default aCpoFil := {}
    aColumns := {}
    for nLoop := 1 to Len(aFields)
        If Len(aCpoFil)==0 .or. ascan(aCpoFil, {|x| Alltrim(x) = Alltrim(aFields[nLoop][1]) } ) > 0            
            aAdd(aColumns, FWBrwColumn():New() )
            cTit := FWSX3Util():GetDescription( aFields[nLoop][1])
            nColumns := Len(aColumns)
            aColumns[nColumns]:SetData( &("{ || " + aFields[nLoop][1] + " }") )
            If !Empty(cTit)
                aColumns[nColumns]:SetTitle( Capital(cTit) ) 
            Else
                aColumns[nColumns]:SetTitle( Capital(aFields[nLoop][1]) )
            EndIf
            aColumns[nColumns]:SetType( aFields[nLoop][2] )
            aColumns[nColumns]:SetSize( 5 )
            aColumns[nColumns]:SetDecimal( aFields[nLoop][4] )  
        Endif
    next

return aColumns

Static Function LimpaCampos(cDescPr,cFabric,cProdut,cAliasTB1, oBrw)

	cFabric := Space( 40 ) 
 	cProdut := Space( 15 )
	cDescPr := Space( 40 )

    (cAliasTB1)->(__DbZap())
	oBrw:Refresh(.T.)
Return .T.

Static Function FiltraDados(oSay,cDescPr,cFabric,cProdut,cAliasTB1,oBrw,oBmp) 
    Local cSql      := ""
    Local cTb1Tmp   := ""
    Local cTb2Tmp   := ""
    Local nUprec    := 0
    Local cUorc     := ""
    Local cUvend    := ""
    Local cCodFabric:= ""
    Local cUVenda   := ""
    Local dDtUCompra:= StoD("")

    (cAliasTB1)->(__DbZap())
    
    cSql := ""
    cSql += " SELECT "  
    cSql += "   SB1.R_E_C_N_O_ RECB1 "
    cSql += " FROM "+RetSqlName("SB1")+" SB1 "
    cSql += " WHERE "  
    cSql += "   B1_FILIAL = '"+xFilial("SB1")+"' AND "
    If !Empty(cProdut)
        cSql += "   B1_COD LIKE '%"+Alltrim(cProdut)+"%' AND "
    EndIf
    If !Empty(cDescPr)
        cSql += "   B1_DESC LIKE '%"+StrTran(Alltrim(cDescPr)," ","%")+"%' AND "
    EndIf
    If !Empty(cFabric)
        cSql += "   B1_FABRIC LIKE '%"+StrTran(Alltrim(cFabric)," ","%")+"%' AND "
    EndIf
    cSql += "   B1_MSBLQL <> '1' AND "
    cSql += "   SB1.D_E_L_E_T_ =  ' ' "
    
    oSay:SetText("Selecionando Produtos") 
    ProcessMessage() 

    cTb1Tmp := MpSysOpenQuery(cSql)
    
    oSay:SetText("Obtendo Informações dos Produtos") 
    ProcessMessage() 
    
    While !(cTb1Tmp)->(EoF())
        SB1->(DbGoto((cTb1Tmp)->RECB1))
        
        cSql := ""
        cSql += " SELECT TOP 1 "
        cSql += " 	L1_NUM ORC, "
        cSql += " 	A3_NREDUZ VEND, "
        cSql += " 	L2_VRUNIT U_PRECO "
        cSql += " FROM "
        cSql += " 	"+RetSqlName("SL1")+" SL1 "
        cSql += " 	INNER JOIN "+RetSqlName("SL2")+" SL2 ON "
        cSql += " 		L1_FILIAL = L2_FILIAL AND "
        cSql += " 		L1_NUM = L2_NUM AND "
        cSql += " 		SL1.D_E_L_E_T_ = ' ' AND "
        cSql += " 		SL2.D_E_L_E_T_ = ' ' "
        cSql += " 	INNER JOIN "+RetSqlName("SA3")+" SA3 ON "
        cSql += " 		A3_FILIAL = '"+xFilial("SA3")+"' AND "
        cSql += " 		L1_VEND = A3_COD AND "
        cSql += " 		SA3.D_E_L_E_T_ = ' ' "
        cSql += " WHERE "
        cSql += " 	L1_CLIENTE = '"+M->LQ_CLIENTE+"' AND "
        cSql += " 	L1_LOJA = '"+M->LQ_LOJA+"' AND "
        cSql += " 	L2_PRODUTO = '"+Alltrim(SB1->B1_COD)+"' "
        cSql += " ORDER BY "
        cSql += " 	L1_EMISSAO DESC "

        nUprec  := 0
        cUorc   := ""
        cUvend  := ""
        cTb2Tmp := MpSysOpenQuery(cSql)

        If !(cTb2Tmp)->(EoF())
            nUprec  := (cTb2Tmp)->U_PRECO
            cUorc   := (cTb2Tmp)->ORC
            cUvend  := (cTb2Tmp)->VEND
        Endif
        
        (cTb2Tmp)->(DbCloseArea())

        cSql := ""
        cSql += "SELECT " 
        cSql += "	A5_CODPRF " 
        cSql += "FROM "
        cSql += "	"+RetSqlName("SA5")+" SA5 "
        cSql += "WHERE "
        cSql += "	A5_FILIAL = '"+xFilial("SA5")+"' AND "
        cSql += "	A5_PRODUTO  = '"+Alltrim(SB1->B1_COD)+"' AND "
        cSql += "	A5_CODPRF <> ' ' AND "
        cSql += "	D_E_L_E_T_ = ' ' "

        cCodFabric  := ""
        cTb2Tmp     := MpSysOpenQuery(cSql)

        If !(cTb2Tmp)->(EoF())
            (cTb2Tmp)->(DbEval({|| cCodFabric+= Alltrim((cTb2Tmp)->A5_CODPRF)+"/" }))
        EndIf
        (cTb2Tmp)->(DbCloseArea())

        cSql := ""
        cSql += "SELECT TOP 1 "
        cSql += "	C7_DATPRF "
        cSql += "FROM "
        cSql += "	"+RetSqlName("SC7")+" SC7 "
        cSql += "WHERE "
        cSql += "	C7_FILIAL = '"+xFilial("SC7")+"' AND "
        cSql += "	C7_PRODUTO  = '"+Alltrim(SB1->B1_COD)+"' AND "
        cSql += "	D_E_L_E_T_ = ' ' "
        cSql += "ORDER BY "
        cSql += "	C7_DATPRF DESC "

        dDtUCompra  := Stod("")
        cTb2Tmp     := MpSysOpenQuery(cSql)
        If !(cTb2Tmp)->(EoF())
            dDtUCompra := (cTb2Tmp)->C7_DATPRF
        EndIf
        (cTb2Tmp)->(DbCloseArea())

        cSql := ""
        cSql += "SELECT TOP 1 "
        cSql += "	L1_NUM, D2_DOC, D2_SERIE "
        cSql += "FROM "
        cSql += "	SD2010 SD2 "
        cSql += "	INNER JOIN SL1010 SL1 ON "
        cSql += "	D2_FILIAL = '"+xFilial("SD2")+"' AND "
        cSql += "	L1_FILIAL = '"+xFilial("SL1")+"' AND "
        cSql += "	D2_DOC = L1_DOC AND "
        cSql += "	D2_SERIE = L1_SERIE AND "
        cSql += "	D2_CLIENTE = L1_CLIENTE AND "
        cSql += "	D2_LOJA = L1_LOJA AND "
        cSql += "	SL1.D_E_L_E_T_ = ' ' AND "
        cSql += "	SD2.D_E_L_E_T_ = ' ' "
        cSql += "WHERE "
        cSql += "	D2_COD = '"+Alltrim(SB1->B1_COD)+"' AND "
        cSql += "	D2_CLIENTE = '"+M->LQ_CLIENTE+"' AND "
        cSql += "	D2_LOJA = '"+M->LQ_LOJA+"' " 
        cSql += "ORDER BY "
        cSql += "	D2_EMISSAO DESC "

        dDtUCompra  := Stod("")
        cTb2Tmp     := MpSysOpenQuery(cSql)
        If !(cTb2Tmp)->(EoF())
            cUVenda := (cTb2Tmp)->L1_NUM+"/"+(cTb2Tmp)->D2_SERIE+"-"+(cTb2Tmp)->D2_DOC
        EndIf
        (cTb2Tmp)->(DbCloseArea())

        RecLock(cAliasTB1,.T.)
            (cAliasTB1)->PRODUTO    := SB1->B1_COD  
            (cAliasTB1)->DESCRICAO  := SB1->B1_DESC
            (cAliasTB1)->FABRICANTE := SB1->B1_FABRIC
            (cAliasTB1)->COD_FABRIC := cCodFabric
            (cAliasTB1)->NCM        := SB1->B1_POSIPI
            (cAliasTB1)->DT_ULTCOM  := dDtUCompra
            (cAliasTB1)->ULT_PRCVEN := nUprec
            (cAliasTB1)->PRECO_ATU  := SB1->B1_PRV1
            (cAliasTB1)->SANTOS     := GetAdvFval("SB2", "B2_QATU", '0101' + SB1->B1_COD + "01"  , 1, 0 )   
            (cAliasTB1)->CUBATAO    := GetAdvFval("SB2", "B2_QATU", '0102' + SB1->B1_COD + "01"  , 1, 0 )    
            (cAliasTB1)->ULT_PEDIDO := cUorc
            (cAliasTB1)->VENDEDOR   := cUvend
            (cAliasTB1)->ULT_VENDA  := cUVenda
            (cAliasTB1)->BITMAP     := SB1->B1_BITMAP   
            (cAliasTB1)->OBSERVACAO := SB1->B1_XOBS
        (cAliasTB1)->(MsUnlock())  
        MsUnlock()

        (cTb1Tmp)->(DbSkip())
    End
    (cTb1Tmp)->(DbCloseArea())
    oBrw:SetLineHeight(10)
    oBrw:SetFontBrowse(oFontBrw)
    oBrw:Refresh(.T.)
    Showbitmap(oBmp,(cAliasTB1)->BITMAP,"")
Return
