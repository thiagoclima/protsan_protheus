//Bibliotecas
#Include 'Protheus.ch'
#Include 'RwMake.ch'
 
/*------------------------------------------------------------------------------------------------------*
 | P.E.:  M410PVNF                                                                                      |
 | Desc:  Validação na chamada do Prep Doc Saída no Ações Relacionadas do Pedido de Venda               |
 | Links: http://tdn.totvs.com/pages/releaseview.actionçpageId=6784152                                  |
 *------------------------------------------------------------------------------------------------------*/
 
User Function M410PVNF()
    Local lRet := .T.
    Local aArea := GetArea()
    Local aAreaC5 := SC5->(GetArea())
    Local aAreaC6 := SC6->(GetArea())
     
    //Se tiver em branco o campo, não permite prosseguir
    If Emtpy(SC5->C5_XSEPARA){
        lRet := .F.
    }
    
    else if (SC5->C5_XSEPARA = 'L'){
        lRet := .F.
    }

    else{
        lRet := .T. 
    }
        
    EndIf
     
    RestArea(aAreaC6)
    RestArea(aAreaC5)
    RestArea(aArea)
Return lRet
