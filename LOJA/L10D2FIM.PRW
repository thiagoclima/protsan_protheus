#include "Protheus.ch"

*--------------------*
User Function L10D2FIM()
*--------------------*
     Local aSv_Area := GetArea()

               
         SD2->(RecLock("SD2",.F.))
            SD2->D2_COMIS1  := SL2->L2_COMIS1
            SD2->D2_DESC    := 0.00 
            SD2->D2_DESCON  := 0.00 
          //  MSGSTOP("DESCONTO L10D2FIM ", STRZERO(SD2->D2_DESCON))
         SD2->(MsUnLock())
         
    nValDesc    := 0
    nDescF2     := 0     

//    DbSelectArea('SF2')
//    DbSetOrder(01)

//    If DbSeeK(xFilial('SF2')+SD2->D2_DOC+SD2->D2_SERIE+SD2->D2_CLIENTE+SD2->D2_LOJA)

  //      SF2->(RecLock("SF2",.F.))
  //           SF2->F2_VALMERC := SF2->F2_VALMERC - SF2->F2_DESCONT 
  //           SF2->F2_DESCON := 0
  //      SF2->(MsUnLock())
  //  Endif 



/*

         F2_VALMERC := F2_VALMERC - F2_DESCONT 
         F2_DESCON := 0

         F3_VALOBSE := 0 
         
         FT_DESCONT := 0 
         FT_TOTAL := FT_TOTAL - FT_DESCONT 
         


*/
     
     RestArea(aSv_Area)
     Return(.T.)
