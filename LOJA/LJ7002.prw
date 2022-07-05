#include "Protheus.ch"

*--------------------*
User Function LJ7002()
*--------------------*
     Local aSv_Area := GetArea() 

    //  MsgAlert("lj7002" , "lj7002" )
     SL1->(RecLock("SL1",.F.))
      //  SL1->L1_COMIS   := 1
     SL1->(MsUnLock())

     SD2->(DbSetOrder(3))
     SD2->(DbSeek(xFilial("SD2")+SF2->(F2_DOC+F2_SERIE+F2_CLIENTE+F2_LOJA)))
     While !SD2->(Eof())                           .And.;
           SD2->D2_FILIAL     == xFilial("SD2")    .And.;
           SD2->D2_DOC        == SF2->F2_DOC       .And.;
           SD2->D2_SERIE      == SF2->F2_SERIE     .And.;
           SD2->D2_CLIENTE    == SF2->F2_CLIENTE   .And.;
           SD2->D2_LOJA       == SF2->F2_LOJA
           
         SD2->(RecLock("SD2",.F.))
         //  SD2->D2_COMIS1  := 1
         SD2->(MsUnLock())
         
         SD2->(Dbskip())
     End
     
     RestArea(aSv_Area)

     Return(.T.)
