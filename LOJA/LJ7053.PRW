#Include 'Protheus.ch'

User Function LJ7053()
    Local aArray := {}

    Aadd( aArray, {"Impr. Or�amento"          , "U_IMPORC(2)" , 0, 1, NIL, .F.} )
    Aadd( aArray, {"Impr. Lista de Separa��o" , "U_IMPORC2(2)", 0, 1, NIL, .F.} )
    If ExistBlock("PROTA002")
        Aadd( aArray, {"Lib. Impress�o Or�amento" , "U_PROTA002('L')", 0, 1, NIL, .F.} )
    Endif

Return (aArray)


