#Include 'Protheus.ch'

//-------------------------------------------------------------------
/*/{Protheus.doc} ZDPCOM04
Ponto de entrada para filtrar orçamento do vendedor 


@author  Heverson Gomes
@since   07/01/2021
@version 1.0
/*/
//-------------------------------------------------------------------
User Function LJ010SF3()

Local aSv_Area := {}

aSv_Area       := GetArea()


        SF2->(RecLock("SF2",.F.))
  
         //   MsgAlert(SF2->F2_DOC , "F2_DOC")
            
            //MsgAlert(Transform( SF2->F2_VALMERC,"@E 99,999.99"), "VALMERC")
         //   MsgAlert(Transform( SF2->F2_DESCONT,"@E 99,999.99"), "DESCONTO lj010SF3")
            
//             SF2->F2_VALMERC := SF2->F2_VALMERC - SF2->F2_DESCONT 

          SF2->F2_DESCONT := 0



        SF2->(MsUnLock())
//    Endif 



/*

         F2_VALMERC := F2_VALMERC - F2_DESCONT 
         F2_DESCON := 0

         F3_VALOBSE := 0 
         
         FT_DESCONT := 0 
         FT_TOTAL := FT_TOTAL - FT_DESCONT 
         
          


    */
     
//    DBGOTO(_nRecnod2)

     RestArea(aSv_Area)
    
    // Return(.T.)


Return() 



