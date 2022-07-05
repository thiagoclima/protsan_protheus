#Include 'Protheus.ch'

//-------------------------------------------------------------------
/*/{Protheus.doc} ZDPCOM04
Rotina de Importação de dados para atualização da tabela ZZ3

@author  paulo.apolinario
@since   04/11/2020
@version 1.0
/*/
//-------------------------------------------------------------------
User Function geraSL1()
Local aButtons		:=	{}
Local nOpc			:=	0
Local aSays			:=	{}
Local bFileCSV      := {|| cFileCSV := cGetFile("Arquivo .csv|*.csv|","Selecione o arquivo a ser processado...",0,"",.T.,GETF_LOCALFLOPPY + GETF_LOCALHARD + GETF_NETWORKDRIVE) }

Private oProcess	:= Nil 
Private cFileCSV	:= ''

//    If !u_PodeEditar("TI_ZDA", .T.)
 //       u_ZDHelp("Atenção - ZDA", "Acesso Restrito ao TI")
  //      Return
  //  Endif

    aAdd( aSays, "Essa rotina tem como objetivo importar csv " )
    aAdd( aSays, "para alimentar a tabela SL1" )
    aAdd( aSays, "" )

    aAdd( aButtons, { 14, .T., bFileCSV } )
    //aAdd( aButtons, { 5, .T., {|| Pergunte( cPerg, .T. ) } } )
    aAdd( aButtons, { 1, .T., {|| nOpc := 1, FechaBatch() }} )
    aAdd( aButtons, { 2, .T., {|| nOpc := 0, FechaBatch() }} )

    FormBatch( "Importar CSV", aSays, aButtons )

    If nOpc == 0
        Return( Nil )
    ElseIf nOpc == 1
        Processa( { || ImportaCSV() }, "Aguarde...", "Importando CSV...", .F. )
    Endif

Return ( Nil )


//-------------------------------------------------------------------
/*/{Protheus.doc} ImportaCSV
Importa os dados da planilha com as informações de separação.
@author  paulo.apolinario
@since   04/11/2020
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ImportaCSV()

Local aAreaSL1      := SL1->( GetArea() )


    dbSelectArea('SL1')
    SL1->( dbSetOrder( 1 ) ) //ZZ3_FILIAL+ZZ3_CC+ZZ3_USER
    dbgotop()

//UPDATE SL1010 
//SET L1_XNOME = A1_NOME 
//INNER JOIN SA1010 on A1_COD = L1_CLIENTE


	While .not. eof() 

		IncProc()

        dbSelectArea('SA1')
        SA1->( dbSetOrder( 1 ) ) //ZZ3_FILIAL+ZZ3_CC+ZZ3_USER
        if dbseek(xfilial("SA1")+SL1->L1_CLIENTE + SL1->L1_LOJA) 
            SL1->(Reclock("SL1",.F.))
                SL1->L1_XNOME := SA1->A1_NOME 

             
            SL1->(MSUNLOCK()) 
        ENDIF  
            dbSelectArea('SL1')
            SL1->( dbSetOrder( 1 ) ) //ZZ3_FILIAL+ZZ3_CC+ZZ3_USER
            DBSKIP() 
    ENDDO 



    RestArea( aAreaSL1 )
Return

