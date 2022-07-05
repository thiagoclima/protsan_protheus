#Include 'Protheus.ch'

User Function prota003(cTp)
    Local aArea:= GetArea()
    Local xRet := nil
    
    If cTp == "G"
        xRet := ProtTrig()
    EndIf

    If cTp == "V"
        xRet := ProtVld()
    EndIf

    RestArea(aArea)
Return(xRet)

Static Function ProtTrig()
    Local xRet      := nil
    Local nPosVunit := aPosCpo[Ascan(aPosCpo,{|x| Alltrim(Upper(x[1])) == "LR_VRUNIT"})][2]
    Local nPosVUnitA:= ascan(oGetva:aAlter,{|x| Alltrim(x) == "LR_VRUNIT" }) 
    Local nLinGetD  := oGetva:oBrowse:nAt

    If nPosVUnitA == 0
        aadd(oGetva:aAlter,'LR_VRUNIT')
    Endif

    xRet := aCols[nLinGetD,nPosVunit]
Return(xRet)

Static Function ProtVld()
    Local lRet      := .t.
    Local nPercDes  := SLF->LF_DESCPER
    Local nPosQuant := aPosCpo[Ascan(aPosCpo,{|x| Alltrim(Upper(x[1])) == "LR_QUANT"})][2]
    Local nPosVitem := aPosCpo[Ascan(aPosCpo,{|x| Alltrim(Upper(x[1])) == "LR_VLRITEM"})][2]
    Local nPosPDesc := aPosCpo[Ascan(aPosCpo,{|x| Alltrim(Upper(x[1])) == "LR_DESC"})][2]
    Local nPosVDesc := aPosCpo[Ascan(aPosCpo,{|x| Alltrim(Upper(x[1])) == "LR_VALDESC"})][2]
    Local nLinGetD  := oGetva:oBrowse:nAt
    Local aRet      := {}
    Local aParamBox := {}
    Local cPassDes  := GetNewPar("XX_PASSDES", "LibProtsan" )
    Local nValOrig  := SB1->B1_PRV1 
          
    If M->LR_VRUNIT == nValOrig 
        lRet := .t.
    ElseIf M->LR_VRUNIT > (nValOrig-(nValOrig*(nPercDes/100)))
        lRet := .t.
    else
        aAdd(aParamBox,{9,"Valor de Desconto acima do Máximo permitido",150,7,.T.})
        aAdd(aParamBox,{8,"Senha de Liberação",Space(10),"","","","",80,.T.})
        If ParamBox(aParamBox,"Liberação Desconto...",@aRet) 
            If Alltrim(aRet[2]) == cPassDes
                lRet := .t.
            else
                lRet := .f.
            Endif 
        Else
            lRet := .f.
        Endif
    EndIf

    If lRet
        aCols[nLinGetD,nPosVitem] := M->LR_VRUNIT * aCols[nLinGetD,nPosQuant]
        If M->LR_VRUNIT < nValOrig
            aCols[nLinGetD,nPosPDesc] := Round(((nValOrig-M->LR_VRUNIT)/nValOrig)*100,2)
            aCols[nLinGetD,nPosVDesc] := nValOrig-M->LR_VRUNIT
        Endif
    Endif

Return(lRet)
