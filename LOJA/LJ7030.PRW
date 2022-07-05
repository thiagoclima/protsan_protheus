#INCLUDE "TOTVS.CH"

User Function LJ7030()

Local _aArea        :=GetArea()
Local _nPosDesc     := 0
Local _nPosComis    := 0
//Local _nPosVDesc    := 0 
//Local _nPosDescx    := 0 
//Local _nPosVDescx   := 0 
//Local _nPosVlritem  := 0
//Local _nPosVrUnit   := 0
//Local _nPosTabela   := 0
//Local _nPosPrcTab   := 0 
//Local _nVrUnit      := 0 
//Local _nPrcTab      := 0  

Local _lOK          := .T. 
Local _nDesclj      := GETMV("MV_XDESCLJ")
Local _nDesc        := 0
//Local _nVlrDesc     := 0 
Local _nPComis      := 0
//Local _cTabela      := ""  
Local nOpcao        := PARAMIXB[1]
//Local _n            := 0 

If(nOpcao ==1) // linha ok

  If !aCols[n][Len(aHeader)+1]
    _nPosDesc     := aScan( aHeader, {|x| AllTrim(x[2]) == "LR_DESC"})
    _nPosComis    := aScan( aHeader, {|x| AllTrim(x[2]) == "LR_COMIS1"})

    _nDesc        := aCols[n][_nPosDesc]
    _nPComis      := IIF(_nDesc <= _nDesclj,1.5,0.5)  

    // Atualiza o percentual da comissão       
    aCols[n][_nPoSComis] := _nPComis  

  Endif
Endif 

/*

If(nOpcao ==2) // tudo ok 

  for _n := 1 to len(aCols)      

      _nPosVrUnit   := aScan( aHeader, {|x| AllTrim(x[2]) == "LR_VRUNIT"})
      _nPosVlritem  := aScan( aHeader, {|x| AllTrim(x[2]) == "LR_VLRITEM"})
      _nPosDesc     := aScan( aHeader, {|x| AllTrim(x[2]) == "LR_DESC"})

      _nPosVDesc    := aScan( aHeader, {|x| AllTrim(x[2]) == "LR_VALDESC"})
      _nPosxDesc    := aScan( aHeader, {|x| AllTrim(x[2]) == "LR_XDESC"})
      _nPosxVDesc   := aScan( aHeader, {|x| AllTrim(x[2]) == "LR_XVALDES"})
      _nPosxVrItem  := aScan( aHeader, {|x| AllTrim(x[2]) == "LR_XVRITEM"})
      _nPosxVrUnit  := aScan( aHeader, {|x| AllTrim(x[2]) == "LR_XVRUNIT"}) 
    
      _nPosTabela   := aScan( aHeader, {|x| AllTrim(x[2]) == "LR_TABELA"})
      _nPosxTabela  := aScan( aHeader, {|x| AllTrim(x[2]) == "LR_XTABELA"}) 
      _nPosPrcTab   := aScan( aHeader, {|x| AllTrim(x[2]) == "LR_PRCTAB"})
      _nPosxPrTab   := aScan( aHeader, {|x| AllTrim(x[2]) == "LR_XPRTAB"}) 
    
    // mover valores atuais para campos de historicos 
    //Preco Unit 
    //Vlr Item 
    //Desconto 
    //Valor Desc
    //Tabela     
    
    // mover valores atuais para campos de historicos 
    // Preco Unit 
      _nVrUnit                := aCols[_n][_nPosVrUnit]    // LR_VRUNIT 
      aCols[_n][_nPosxVrUnit] := _nVrUnit                // LR_XVRUNIT   


   
    // Vlr item
      _nVlrItem               := aCols[_n][_nPosVlritem]   // LR_VLRITEM 
      aCols[_n][_nPosxVrItem] := _nVlrItem                // LR_XVRITEM   

    //Desconto 
      _nDesc                  := aCols[_n][_nPosDesc]      // LR_DESC 
      aCols[_n][_nPosxDesc]   := _nDesc                   // LR_XDESC   

    //Valor Desc
      _nVlrDesc                  := aCols[_n][_nPosVDesc]      // LR_VALDESC 
      aCols[_n][_nPosxVDesc]     := _nVlrDesc                 // LR_XVALDES   

//    //Preco Tabela 
//      _nPrcTab                    := aCols[_n][_nPosPrcTab]      // LR_PRCTAB 
//      aCols[_n][_nPosxPrTab]     := _cPrcTab                     //  LR_XPRTAB   



  //     If !aCols[i,Len(aHeader)+1]
    //     _nTotQtd     +=     (aCols[i,aScan(aHeader,{|x| Alltrim(upper(x[2]))== "LR_QUANT"})] * aCols[i,aScan(aHeader,{|x| Alltrim(upper(x[2]))== "LR_VLRITE"})])
    //     EndIf
      
      
     // _nAux1   := aScan(aHeader,{ |X| alltrim(upper(X[2])) == "LR_NUM" })
     // _nAux2   := aScan(aHeader,{ |X| alltrim(upper(X[2])) == "LR_ITEM" })
     // _nAux3   := aScan(aHeader,{ |X| alltrim(upper(X[2])) == "LR_PRODUTO" })
     // _nAux4   := aScan(aHeader,{ |X| alltrim(upper(X[2])) == "LR_VLRITEM" })
     // _nQtdCol := Len(aHeader)+1
      
      //_cNum := aCols[1][_nAux1]
     // _cItem := aCols[1][_nAux2]
     // _cProd := aCols[1][_nAux3]
    //  _nVrIt := aCols[1][_nAux4]
      
    //  _nTotal := _nVrUni + _nVrIt
      
    //  IF _nTotal > _nLimit
    //        ALERT("Ultrapassou o limite de "+ Transform(_nLimit, "@r ###,###.##"))
    //        _lRet := .F.
    //  ENDIF

  next _n      

Endif




//    _nPosVDesc    := aScan( aHeader, {|x| AllTrim(x[2]) == "LR_VALDESC"})
//    _nPosDescx    := aScan( aHeader, {|x| AllTrim(x[2]) == "LR_XDESC"})
//    _nPosVDescx   := aScan( aHeader, {|x| AllTrim(x[2]) == "LR_XVALDES"})
//    _nPosVlritem  := aScan( aHeader, {|x| AllTrim(x[2]) == "LR_VLRITEM"})
//    _nPosVrUnit   := aScan( aHeader, {|x| AllTrim(x[2]) == "LR_VRUNIT"})
//    _nPosTabela   := aScan( aHeader, {|x| AllTrim(x[2]) == "LR_TABELA"})
//    _nPosPrcTab   := aScan( aHeader, {|x| AllTrim(x[2]) == "LR_PRCTAB"})

 
//Endif 

*/

RestArea(_aArea)

Return(_lOK)
