#include "rwmake.ch"
#include "topconn.ch"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³GRVGCPB9  ºAutor  ³Mauricio da Silva   º Data ³  30/11/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Gera registro na tabela SB9 dos produtos GCP.              º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Especifico NEOPLASTIC                                      º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function ATUSL2()

Local nGera

nGera := Aviso("Atencao","Atualiza Comissao dos vendedores  ?",{" Sim "," Nao "})
If nGera = 1
	Processa( { || ATUL2()},"Executando a rotina..." )
Else
	Return(.T.)
EndIf

Return(.T.)

Static function ATUL2()

Local nTeto := GETMV("MV_XDESCLJ")

Local cDoc  := ""



DbSelectArea("SL2")
Dbgotop()
ProcRegua(Reccount())



While SL2->(!EOF())

    IF EMPTY(SL2->L2_DOC)
        dbSkip() 
        incproc("Venda SL2 : " + SL2->L2_NUM )
        Loop
    ENDIF 


    IF EMPTY(SL2->L2_VEND)
        dbSelectArea("SL1")
        DbSetOrder(1)
        IF DbSeek(xfilial("SL1") + SL2->L2_NUM)
            SL2->(Reclock("SL2",.F.))
                SL2->L2_VEND  := SL1->L1_VEND 
            MSUNLOCK()
        ENDIF        
    ENDIF 

	
    dbSelectArea("SA3")
    DbSetOrder(1)

IF DbSeek(xfilial("SA3") + SL2->L2_VEND)

    dbSelectArea("SL2")
    DbSetOrder(1)
    
    Reclock("SL2",.F.)
    
        //iF SL2->L2_DESC <> 0 
        //    If SL2->L2_DESC <= NTeto 
    
        //        SL2->L2_COMIS1 := SA3->A3_COMIS 
            
        //    Else 
            
        //        SL2->L2_COMIS1 := 0.5 

        //    Endif 
        //Else 
            If SL2->L2_XDESC <= NTeto 
    
                SL2->L2_COMIS1 := SA3->A3_COMIS 
            
            Else 
            
                SL2->L2_COMIS1 := 1.5 

            Endif 
        //ENDIF


        MsUnlock() 

    dbSelectArea("SL1")
    DbSetOrder(1)
    
    cDoc := SPACE(09)  

    IF DbSeek(xfilial("SL1") + SL2->L2_NUM)
    
        cDoc := SL1->L1_DOC
    
    ENDIF

    
    dbSelectArea("SD2")
    DbSetOrder(3)
    //D2_FILIAL+D2_DOC+D2_SERIE+D2_CLIENTE+D2_LOJA+D2_COD+D2_ITEM                                                                                                     


    IF DbSeek(xfilial("SD2") + SL2->L2_DOC + SL2->L2_SERIE+ SL1->L1_CLIENTE + SL1->L1_LOJA + SL2->L2_PRODUTO+SL2->L2_ITEM)
    
        //cDoc := SD2->D2_DOC
        
        //While SD2->(!EOF()) .AND. cDoc == SD2->D2_DOC 

        //dbSelectArea("SD2")
        //DbSetOrder(3)

        Reclock("SD2",.F.)
    
        //If SD2->D2_DESC <= NTeto 
    
            SD2->D2_COMIS1 := SL2->L2_COMIS1 
            
        //Else 
            
        //    SD2->D2_COMIS1 := 0.5 

        //Endif 
        
        MsUnlock() 

        //dbSkip() 
        
     //   cDoc := SD2->D2_DOC 

        //Enddo 

    Endif
   
ENDIF

dbSelectArea("SL2")
DbSetOrder(1)


DbSkip()
incproc("Venda SL2 : " + SL2->L2_NUM )
		
ENDDO


Return()                                     
