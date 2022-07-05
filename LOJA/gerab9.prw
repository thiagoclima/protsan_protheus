#Include 'Protheus.ch'

//-------------------------------------------------------------------
/*/{Protheus.doc} ZDPCOM04
Rotina de Importação de dados para atualização da tabela ZZ3

@author  paulo.apolinario
@since   04/11/2020
@version 1.0
/*/
//-------------------------------------------------------------------
User Function gerasb9()
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
    aAdd( aSays, "para alimentar a tabela sb1" )
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

Local aAreaSB1      := SB1->( GetArea() )


    dbSelectArea('SB1')
    SB1->( dbSetOrder( 1 ) ) //ZZ3_FILIAL+ZZ3_CC+ZZ3_USER

	While .not. eof() 

		IncProc()

        dbSelectArea('SB9')
        SB9->( dbSetOrder( 1 ) ) //ZZ3_FILIAL+ZZ3_CC+ZZ3_USER
        if !dbseek(xfilial("SB9")+SB1->B1_COD) 
            Reclock("SB9",.T.)
                SB9->B9_FILIAL  := "0101"
                SB9->B9_COD     := SB1->B1_COD 
                SB9->B9_LOCAL   := SB1->B1_LOCPAD 
                SB9->B9_QINI    := 2000 
                SB9->B9_VINI1   := 1000
            SB9->(MSUNLOCK()) 
        ENDIF  
            dbSelectArea('SB1')
            SB1->( dbSetOrder( 1 ) ) //ZZ3_FILIAL+ZZ3_CC+ZZ3_USER
            DBSKIP() 
    ENDDO 



    RestArea( aAreaSB1 )
Return

