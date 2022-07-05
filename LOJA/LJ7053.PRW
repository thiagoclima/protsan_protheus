#Include 'Protheus.ch'

User Function LJ7053()
    Local aArray := {}

    Aadd( aArray, {"Impr. Orçamento"          , "U_IMPORC(2)" , 0, 1, NIL, .F.} )
    Aadd( aArray, {"Impr. Lista de Separação" , "U_IMPORC2(2)", 0, 1, NIL, .F.} )
    If ExistBlock("PROTA002")
        Aadd( aArray, {"Lib. Impressão Orçamento" , "U_PROTA002('L')", 0, 1, NIL, .F.} )
    Endif

Return (aArray)


