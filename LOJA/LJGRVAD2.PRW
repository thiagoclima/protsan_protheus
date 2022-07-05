#Include 'Protheus.ch'

//-------------------------------------------------------------------
/*/{Protheus.doc} ZDPCOM04
Ponto de entrada para ajustar campos de desconto na venda assistida.  


@author  Heverson Gomes
@since   07/01/2021
@version 1.0
/*/
//http://tss-homologacao.totvscloud.com.br:8261/ 
// url do tss da base de testes. 

//-----------------------------------------------
User Function LJGRVAD2()

Local aSv_Area := {}
Local _nRecnoD2 := 0 

aSv_Area       := GetArea()

_nRecnoD2 := SD2->(RECNO()) 



//MSGSTOP("D2_DOC "   , SD2->D2_FILIAL+" " + SD2->D2_DOC+" "+ SD2->D2_SERIE+" " + SD2->D2_CLIENTE+" " + SD2->D2_LOJA+" " + SD2->D2_COD+" " + SD2->D2_ITEM  )
//MSGSTOP("L2_DOC "   , SL2->L2_FILIAL+" " + SL2->L2_DOC+" "+ SL2->L2_SERIE+" "  + SD2->D2_COD+" " + SD2->D2_ITEM  )
//MSGSTOP("L1_CLIENTE ",  SL1->L1_CLIENTE+" " + SL1->L1_LOJA)
//MSGSTOP( "L1_DOC "   , SL1->L1_DOC)

SL1->(RecLock("SL1",.F.))

//    MsgAlert(Transform( SL1->L1_DESCONT,"@E 99,999.99"), "DESCONTO")
//    MsgAlert(Transform( SL1->L1_VALMERC,"@E 99,999.99"), "VAL MERC  ")
//    MsgAlert(Transform( SL1->L1_VLRTOT,"@E 99,999.99"), "VAL TOTAL  ")
    SL1->L1_XVLMERC     := SL1->L1_VALMERC // TRANFERE PARA MANTER HISTORICO.
    SL1->L1_XDESCON     := SL1->L1_DESCONT  
    
    SL1->L1_VALMERC     := SL1->L1_VLRTOT
    SL1->L1_DESCONT     := 0   
MSUNLOCK()

SL2->(RecLock("SL2",.F.))
    SL2->L2_XDESC       := SL2->L2_DESC 
    SL2->L2_XVALDESC    := SL2->L2_VALDESC 
    SL2->L2_XTABELA     := SL2->L2_TABELA 
    SL2->L2_XPRTAB      := SL2->L2_PRCTAB 

    SL2->L2_DESC    := 0
    SL2->L2_VALDESC := 0
    SL2->L2_DESCPRO := 0 
    SL2->L2_PRCTAB  := SL2->L2_VRUNIT  
    SL2->L2_TABELA  := SPACE(03)
    nTotDesc:= 0 

MSUNLOCK() 

    nValDesc        := 0
    nDescF2         := 0     
    nVlrDescItem	:= 0 // zera a variavel para nao ser apresentado na nota. 

        SF2->(RecLock("SF2",.F.))
  
            //MsgAlert(SF2->F2_DOC , "F2_DOC")
            
            //MsgAlert(Transform( SF2->F2_VALMERC,"@E 99,999.99"), "VALMERC")

            

             SF2->F2_DESCONT := 0


        SF2->(MsUnLock())

     RestArea(aSv_Area)

Return() 



