#include "PROTHEUS.CH"

User Function LJ7051(nOpc,aArray)
    Local aArea         := GetArea()
    Local aArrayCustom  := {}
    Local nI           := 0

    If nOpc == 1
		aAdd( aArrayCustom, { "CADEADO_MDI.PNG"		, "Impressão Orc. Bloqueado"	})
        aAdd( aArrayCustom, { "BRW_PRINT.PNG"		, "Orçamento Impresso"	})
	Else
		aAdd( aArrayCustom, { 'L1_XIMPBLQ == "B" ' 	, "CADEADO_MDI" })
        aAdd( aArrayCustom, { 'L1_XIMPBLQ == "I" .and. !(!Empty(L1_DOC) .AND. !Empty(L1_SERIE) .AND. L1_STORC <> "A" .AND. !(L1_SITUA $ "X0|X1|X2|X3") .AND. !(L1_STATUS $ "D|F") .AND. (FieldPos("L1_STATUES") = 0 .OR. Empty(L1_STATUES)))' 	, "BRW_PRINT.PNG" })
	EndIf
	
    //Adiciona ao array customizado as demais opcoes padrao, matendo as customizacoes no inicio.
	For nI := 1 to Len(aArray)
		aAdd(aArrayCustom,aClone(aArray[nI]))
	Next
	//Substitui o array padrao pelo, lembrando que o array padrao e passado por referencia.
	aArray := aClone(aArrayCustom)

    RestArea(aArea)
Return
