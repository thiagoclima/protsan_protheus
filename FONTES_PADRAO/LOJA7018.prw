#INCLUDE "PROTHEUS.CH"
#INCLUDE "MSGRAPHI.CH"
#INCLUDE "DBTREE.CH"
#INCLUDE "LOJA7018.CH"
#INCLUDE "PRCONST.CH"

Static nTamEEUU	 := If(IIf( FindFunction("FWCodFil"), FWSizeFilial() > 2, .F. ),LEN(FWCompany()+FWUnitBusiness()),0)
Static cCodCateg := ""													// Codigo Categoria para retorno
Static cCodGrFil := ""													// Codigo Grupo de Filial para retorno
Static cEspCodPr := SPACE(TamSx3("ACV_CODPRO")[1])	  					// Espaços para o campo ACV_CODPRO
Static cEspGrupo := SPACE(TamSx3("ACV_GRUPO")[1])		 				// Espaços para o campo ACV_GRUPO
/* 
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³ LOJA7018        	  ³ Autor ³ TOTVS                 ³ Data ³ 11/10/13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Consulta gerencial baseada em movimentacoes do Varejo                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Indicadores Gerenciais                                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function LOJA7018()
Local aArea     	:= GetArea()		// Salva a area atual
Local aResource 	:= {}				// Contem todos os botoes que farao parte do tool bar
Local bValid 		:= {|| .T.}			// Funcao de validacao no ACTIVATE do MsExplorer - nesse caso sempre .T.
Local cContato  	:= ""				// Dados do contato mostrados na TOOL BAR
Local cEmpresa  	:= ""				// Dados da entidade mostrados na TOOL BAR
Local aFuncPanels 	:= {}				// Array com as funcoes para a criacao de cada painel on demand

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Variaveis referentes a dialog de selecao da entidade e o periodo de pesquisa da base de dados   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local oDlg          := Nil             	// Tela inicial - configuracoes			
Local nI,nY 		:= 0 				// Contador auxiliar	
Local oEmpCont		:= Nil   			// Painel principal
Local nLenAux		:= 0				// Contador auxiliar para o FOR
Local nOpca         := 0				// Consistencia de opcao da tela
Local cPerg			:= "LJ7018"			// Pergunte (chamado ao clicar em parametros)
Local aFiliais      := {}              	// Recebera o retorna dos nomes das Filiais	
Local oMeter							// Objeto com a barra de progressao

Static oExplorer   	:= Nil				// Arvores de visoes 
Static oPanels	   	:= {}				// Receberá os paines da arvore(oExplorer)
Static nPanel	   	:= 0 			    // Numero do painel atual
Static lGPFilial   	:= .F.             	// Identificara se existe Grupo de empresa para trabalhar
Static aGPFilial   	:= {}              	// Contem a amarracao de grupos de filiais x filiais
Static lCatProd    	:= .F.   	       	// Identifica se o sistema ira exibir os indicadores Categoria e Grupo de produto
Static aRelatorio  	:= {}              	// Contem a estrutura de chamadas e parametros de relatório referente aos indicadores que o sistema pode executar
Static aSerieAux   	:= {}              	// Contem os dados da série ao grafico    
Static aSerie   	:= {}				// Valores dos itens que farao parte da serie
Static aParam := {	{STR0047,"","*"},;	//"Data de"			// Array com os Parâmetros utilizados
					{STR0048,"","*"},;	//"Data até"
					{STR0004,"","*"},;	//"Grupo de Filial de"
					{STR0005,"","*"},;	//"Grupo de Filial até"
					{STR0006,"","*"},;	//"Filial de"
					{STR0007,"","*"},;	//"Filial até"
					{STR0008,"","*"},;	//"Vendedor de"
					{STR0009,"","*"},;	//"Vendedor até"
					{STR0016,"","*"},;	//"Forma de Pagto de"
					{STR0017,"","*"},;	//"Forma de Pagto até"
					{STR0014,"","*"},;	//"Categoria de"
					{STR0015,"","*"},;	//"Categoria até"
					{STR0059,"","*"},;	//"Prioriza Filtro"
					{STR0061,"","*"} }	//"Considerar Devol."
// Mensagem para indicadores de Formas de Pagamentos e Categorias de Produtos
Static aMsgPnl := 	{STR0054,STR0055,STR0056,STR0057}//"Para a Visão de "#"não serão observados os filtros"#"referentes á Categoria de Produto."#"referentes á Formas de Pagamento."

If !L7018VlRotina(cPerg)
	Return Nil
EndIf
				
If Pergunte( cPerg,.T. )

	If !L7018ValPerg()
		Return Nil
	EndIf
	
	oExplorer := MSExplorer():New( STR0001 ) 	//"Consulta"
	oExplorer:DefaultBar()						//	Define a barra de botoes padrao
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Monta o conjunto de botoes da tool bar do objeto Explorer e as respectivas chamadas das funcoes³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Aadd( aResource, {"IMPRESSAO",	STR0002, {|| LJAR7018(oExplorer,aRelatorio)}})	// "Impressão"
	Aadd( aResource, {"CANCEL"	 ,	STR0003, {|| oExplorer:Deactivate()}})			// "Cancela"
	
	For nI := 1 To Len(aResource)
		oExplorer:AddDefButton( aResource[nI,1], aResource[nI,2], aResource[nI,3] ) 
	Next nI
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Monta o painel statico com dados do contato e da empresa como uma tool bar³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oEmpCont := TPanel():New( 35,125,"",,,,,CLR_BLACK,CLR_WHITE,397,16,.T.,.T.)
	
	@ 34,113 TO 52,510 LABEL "" OF oEmpCont PIXEL
	
	@ 03,02 BitMap oBmp1 ResName "BMPSEP1" OF oEmpCont Size 10,10 NoBorder When .F. Pixel
	
	@ 01,08 BitMap oBmp1 ResName "BMPUSER" OF oEmpCont Size 10,10 NoBorder When .F. Pixel
	TSay():New(02,18,{|| cContato },oEmpCont,,,,,,.T.,CLR_HBLUE,CLR_WHITE)
	
	@ 08,08 BitMap oBmp2 ResName "BMPCPO" OF oEmpCont Size 10,10 NoBorder When .F. Pixel
	TSay():New(09,18,{|| cEmpresa },oEmpCont,,,,,,.T.,CLR_HRED,CLR_WHITE)
	
	aGPFilial := LJ7018QryFil(.T.)[1]
	lGPFilial := !EMPTY(aGPFilial)
	
	//Consulta se trabalha com Categoria de Produtos
	lCatProd := Lj7018CatPr()
	
	TMeter(oExplorer ,aFuncPanels, aParam)
	
	oExplorer:Activate(.T.,bValid)      
			
	RestArea(aArea)
	
EndIf

Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ LJ7018MontaPn ºAutor ³TOTVS            ºData ³  11/10/02       º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Comandos para criacao do Tree com o respectivo painel para     º±±
±±º          ³ cada item da arvore, com funcao para instancia dos objetos     º±±
±±º          ³ que cada painel ira conter.                                    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Indicadores Gerenciais                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function LJ7018MontaPn(oExplorer ,aFuncPanels, aParam)

Local aArea   	:= GetArea() 	// Salva a area atual
Local nRanking  := 1   	   		// Contem o numero de registros por ranking
Local cInforme1 := ""  	  		// contem a primeira descricao de informacao do grafico em uso
Local cInforme2 := ""  	  		// contem a segunda  descricao de informacao do grafico em uso
Local cInforme3 := ""  	 		// contem a terceira descricao de informacao do grafico em uso

Default oExplorer 	:= NIL		// Objeto gráfico
Default aFuncPanels	:= {}      	// Arrays com as funções dos panels
Default aParam 		:= {} 		// Parametros

ProcRegua(50)

If !Empty(mv_par15)
	nRanking := mv_par15
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Criacao da Arvore          - Nivel 0 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ                          
oExplorer:AddTree(Padr(STR0010,150),"SDUPROP",,Padr(StrZero(++nPanel,7),20))//"Indicadores Gerenciais"
Aadd( oPanels, oExplorer:GetPanel(nPanel) ) 

IncProc()

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Criacao do 3. Grupo        - Nivel 1 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oExplorer:AddTree(Padr(STR0011,150),"BMPUSER",,Padr(StrZero(++nPanel,7),20)) //"Faturamento"
	Aadd( oPanels, 	oExplorer:GetPanel(nPanel) )
	
	IncProc()
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Criacao do 3. Sub-Grupo    - Nivel 2 ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		
		oExplorer:AddTree(Padr(STR0012,150),"FOLDER13",,Padr(StrZero(++nPanel,7),20))//"Faturamento Bruto"
		Aadd( oPanels, oExplorer:GetPanel(nPanel) ) 
		
		IncProc()
			If lGPFilial //Somente se existir Grupo de empresa
				oExplorer:AddItem(Padr(STR0030,150),"PMSDOC", Padr(StrZero(++nPanel,7),20))//"Grupo de Filial"
				Aadd( oPanels, oExplorer:GetPanel(nPanel) ) 
				
				Aadd(aFuncPanels,"LJPn7018(1,oExplorer,"+Str(nPanel)+","+Str(nRanking)+" , mv_par03, mv_par04, '"+ ;
					STR0004+" x "+STR0005+"', '11', '"+ cInforme1 +"','"+ cInforme2+"','"+ cInforme3+"','"+STR0012+" - "+STR0030+"',aParam)")//Grupo de Filial de x Grupo de filial ate//Faturamento Bruto - Grupo de Filial
				Aadd(aRelatorio,{STR0010+"\"+STR0011+"\"+STR0012+"\"+STR0030,"LR70181('"+STR0012+"','"+STR0030+ ;
					"',lGPFilial,lCatProd,1)"})//"Indicadores Gerenciais"\"Faturamento"\"Faturamento Bruto"\"Grupo de Filial"
				IncProc()
			Endif
			
			oExplorer:AddItem(Padr(STR0031,150),"PMSDOC", Padr(StrZero(++nPanel,7),20))//"Filial"
			Aadd( oPanels, oExplorer:GetPanel(nPanel) ) 
			
			Aadd(aFuncPanels,"LJPn7018(1,oExplorer,"+Str(nPanel)+","+Str(nRanking)+" , mv_par05, mv_par06 ,'"+ ;
				STR0006+" x "+STR0007+"', '12', '"+ cInforme1 +"','"+ cInforme2+"','"+ cInforme3+"','"+STR0012+" - "+STR0031+"',aParam)")//Filial de x Filial ate//Faturamento Bruto - Filial
			Aadd(aRelatorio,{STR0010+"\"+STR0011+"\"+STR0012+"\"+STR0031,"LR70181('"+STR0012+"','"+STR0031+ ;
				"',lGPFilial,lCatProd,2)"})//"Indicadores Gerenciais"\"Faturamento"\"Faturamento Bruto"\"Filial"
			IncProc()
            
			oExplorer:AddItem(Padr(STR0018,150),"PMSDOC", Padr(StrZero(++nPanel,7),20))//"Vendedores"
			Aadd( oPanels, oExplorer:GetPanel(nPanel) )
			
			Aadd(aFuncPanels,"LJPn7018(1,oExplorer,"+Str(nPanel)+","+Str(nRanking)+" , mv_par07, mv_par08, '"+ ;
				STR0008+" x "+STR0009+"', '13', '"+ cInforme1 +"','"+ cInforme2+"','"+ cInforme3+"','"+STR0012+" - "+STR0018+"',aParam)")//Vendedor de x Vendedor ate//Faturamento Bruto - Vendedores
			Aadd(aRelatorio,{STR0010+"\"+STR0011+"\"+STR0012+"\"+STR0018,"LR70181('"+STR0012+"','"+STR0018+ ;
				"',lGPFilial,lCatProd,3)"})//"Indicadores Gerenciais"\"Faturamento"\"Faturamento Bruto"\"Vendedores"
			IncProc()
			
			oExplorer:AddItem(Padr(STR0019,150),"PMSDOC", Padr(StrZero(++nPanel,7),20))//"Formas de Pagamento"
			Aadd( oPanels, oExplorer:GetPanel(nPanel) )
			
			Aadd(aFuncPanels,"LJPn7018(1,oExplorer,"+Str(nPanel)+","+Str(nRanking)+" , mv_par09, mv_par10, '"+ ;
				STR0016+" x "+STR0017+"', '14', '"+ cInforme1 +"','"+ cInforme2+"','"+ cInforme3+"','"+STR0012+" - "+STR0019+"',aParam)")//Forma de Pagto de x Forma de Pagto ate//Faturamento Bruto - Formas de Pagamento
			Aadd(aRelatorio,{STR0010+"\"+STR0011+"\"+STR0012+"\"+STR0019,"LR70181('"+STR0012+"','"+STR0019+ ;
				"',lGPFilial,lCatProd,4)"})//"Indicadores Gerenciais"\"Faturamento"\"Faturamento Bruto"\"Formas de Pagamento"
			IncProc()
			
			If lCatProd //Somente se existir Categorias de Produto
				oExplorer:AddItem(Padr(STR0020,150),"PMSDOC", Padr(StrZero(++nPanel,7),20))//"Categoria"
				Aadd( oPanels, oExplorer:GetPanel(nPanel) )
				
				Aadd(aFuncPanels,"LJPn7018(1,oExplorer,"+Str(nPanel)+","+Str(nRanking)+" , mv_par11, mv_par12, '"+ ;
					STR0014+" x "+STR0015+"', '15', '"+ cInforme1 +"','"+ cInforme2+"','"+ cInforme3+"','"+STR0012+" - "+STR0020+"',aParam)")//Categoria de x Categoria ate//Faturamento Bruto - Categoria
				Aadd(aRelatorio,{STR0010+"\"+STR0011+"\"+STR0012+"\"+STR0020,"LR70181('"+STR0012+"','"+STR0020+ ;
					"',lGPFilial,lCatProd,5)"})//"Indicadores Gerenciais"\"Faturamento"\"Faturamento Bruto"\"Categoria"
				IncProc()
   			EndIf
   			
		oExplorer:EndTree()
        
       	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Criacao do 3. Sub-Grupo    - Nivel 2 ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
        
	   	oExplorer:AddTree(Padr(STR0013,150),"FOLDER13",,Padr(StrZero(++nPanel,7),20))//"Faturamento p/ Ticket Médio"
		Aadd( oPanels, oExplorer:GetPanel(nPanel) ) 
		
		IncProc()
		If lGPFilial //Somente se existir Grupo de empresa
			oExplorer:AddItem(Padr(STR0030,150),"PMSDOC", Padr(StrZero(++nPanel,7),20))//"Grupo de Filial"
			Aadd( oPanels, oExplorer:GetPanel(nPanel) ) 
			
			Aadd(aFuncPanels,"LJPn7018(2,oExplorer,"+Str(nPanel)+","+Str(nRanking)+" , mv_par03, mv_par04,'"+ ;
				STR0004+" x "+STR0005+" ', '21', '"+ cInforme1 +"','"+ cInforme2+"','"+ cInforme3+"','"+STR0013+" - "+STR0030+"',aParam)")//Grupo de Filial de x Grupo de filial ate//Faturamento p/ Ticket Médio - Grupo de Filial
			Aadd(aRelatorio,{STR0010+"\"+STR0011+"\"+STR0013+"\"+STR0030,"LR70182('"+STR0013+"','"+STR0030+ ;
				"',lGPFilial,lCatProd,1)"})//"Indicadores Gerenciais"\"Faturamento"\"Faturamento p/ Ticket Médio"\"Grupo de Filial"
			IncProc()
		Endif 
		
		oExplorer:AddItem(Padr(STR0031,150),"PMSDOC", Padr(StrZero(++nPanel,7),20))//"Filial"
		Aadd( oPanels, oExplorer:GetPanel(nPanel) ) 
		
		Aadd(aFuncPanels,"LJPn7018(2,oExplorer,"+Str(nPanel)+","+Str(nRanking)+" , mv_par05, mv_par06,'"+ ;
			STR0006+" x "+STR0007+"', '22', '"+ cInforme1 +"','"+ cInforme2+"','"+ cInforme3+"','"+STR0013+" - "+STR0031+"',aParam)")//Filial de x Filial ate //Faturamento p/ Ticket Médio - Filial
		Aadd(aRelatorio,{STR0010+"\"+STR0011+"\"+STR0013+"\"+STR0031,"LR70182('"+STR0013+"','"+STR0031+ ;
			"',lGPFilial,lCatProd,2)"})//"Indicadores Gerenciais"\"Faturamento"\"Faturamento p/ Ticket Médio"\"Filial"
		IncProc()
        
		oExplorer:EndTree()
		
	oExplorer:EndTree()

RestArea(aArea)

Return Nil

//#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~
//                                               Processa as chamadas das rotinas graficas                                        
//#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ LJPn7018   ºAutor  ³ Totvs                 º Data ³ 11/10/2013 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Monta a chamada aos painels                                    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Indicadores Gerenciais                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/                  
Static Function LJPn7018(	nIndicador,		oExplorer, 		nPanel,			nRanking, 	;
							cParam01,		cParam02,		cMSG,			cOPC, 		;
							cInforme1,		cInforme2,		cInforme3,		cTitulo, 	;
							aParam)
							
Local aArea     	:= GetArea()                                           	// Salva a area atual
Local oGraphic		:= NIL													// Objeto do definicao do grafico
Local nBottom  		:= Int((oExplorer:aPanel[nPanel]:nHeight * .95) / 2)	// Posicao inicial ABAIXO
Local nRight		:= Int((oExplorer:aPanel[nPanel]:nWidth * .98) / 2)	// Posicao inicial DIREITA	
Local nTopPar		:= 0													// Posicao topo dos parametros
Local nFor      	:= 0													// Contador Auxiliar
Local aMSG      	:= {}                                                  	// Contem as mensagens auxiliares referente ao grafico em uso
Local cReferencia   := ""                                             	 	// Contem o nome da funcao que o sistema usa para gerar os graficos 
Local oLblInfo1		:= NIL													// Objeto de Informação 01
Local oLblInfo2		:= NIL													// Objeto de Informação 02
Local oLblInfo3		:= NIL													// Objeto de Informação 03
Local cIndicador	:= ""													// Define o indicador posicionado

Default nIndicador 	:= 0 	// Tipo de Indicador
Default oExplorer	:= NIL	// Objeto gráfico
Default nPanel		:= 0	// Numero do Painel
Default nRanking	:= 0	// Qtd de gráficos
Default cParam01	:= "" 	// Parametro 01
Default cParam02	:= "" 	// Parametro 02
Default cMSG		:= ""	// Mensagem
Default cOPC		:= "" 	// Opção para busca da função
Default cInforme1	:= ""  	// Informativo 01
Default cInforme2	:= ""  	// Informativo 02
Default cInforme3	:= ""  	// Informativo 03
Default cTitulo		:= "" 	// Titulo do Painel
Default aParam		:= {}  	// Array de parametros

aSerie   	:= {}
For nFor := 1 TO nRanking
  Aadd(aSerie, {"0", 0, "Coluna-"+alltrim(str(nFor)),0} )
Next nFor

//Carrega a lógica das visoes
If  Empty(cParam02) .AND. !(cOpc $ "11/12/21/22")
	Aadd(aMSG,cMSG) 
	LJ7018Vazio(oExplorer, nPanel, aMSG )
Else
    cReferencia := "ProcInd"+alltrim(cOPC)+"()"

  	If FindFunction(cReferencia) 
	  	aSerie := Eval({|| &cReferencia })
		aAdd(aSerieAux,{nPanel,cTitulo,aSerie})
		
		nLenAux := LEN(aSerie)
	    
    	If !Empty(aSerie[1][2]) .And. (aSerie[1][2] <> 0)

			fAjustaMsg(@cInforme1,@cInforme2,@cInforme3,aSerie,2)
    		//Tela de Observacoes
			@ (nBottom * .88),02 TO nBottom+15,nRight+3 LABEL STR0026 OF oExplorer:GetPanel(nPanel) PIXEL //"RESUMO: "
			If !Empty(cInforme1)
				//Par de Bottom + Say
				@ (nBottom * .910),08 BitMap oBmp1 ResName "checked" OF oExplorer:GetPanel(nPanel) Size 10,10 NoBorder When .F. Pixel
			Endif
			oLblInfo1 := TSay():New((nBottom * .910),21,{|| cInforme1 },oExplorer:GetPanel(nPanel),,,,,,.T.,CLR_BLACK,CLR_WHITE) 
			If !Empty(cInforme2)
				//Par de Bottom + Say
				@ (nBottom * .955),08 BitMap oBmp1 ResName "checked" OF oExplorer:GetPanel(nPanel) Size 10,10 NoBorder When .F. Pixel
			Endif
			oLblInfo2 := TSay():New((nBottom * .955),21,{|| cInforme2 },oExplorer:GetPanel(nPanel),,,,,,.T.,CLR_BLACK,CLR_WHITE) 
			If !Empty(cInforme3)
				//Par de Bottom + Say
				@ (nBottom * .100),08 BitMap oBmp1 ResName "checked" OF oExplorer:GetPanel(nPanel) Size 10,10 NoBorder When .F. Pixel
			Endif
			oLblInfo3 := TSay():New((nBottom * .100),21,{|| cInforme3 },oExplorer:GetPanel(nPanel),,,,,,.T.,CLR_BLACK,CLR_WHITE)
			
		    //Carrega os objetos do grafico
			LJ7018GRAP(	@oGraphic,			02,							02,			nRight,		;
						(nBottom * .80), 	oExplorer:GetPanel(nPanel),	aSerie,		cTitulo, 	;
						nIndicador,			@cInforme1,					@cInforme2,	@cInforme3,	;
						@oLblInfo1,			@oLblInfo2,					@oLblInfo3) 		
	        
	        //Tela de Parametros
	  		fAjustaPar(@aParam,nIndicador)
	        nTopPar := 18
			@ nTopPar,nRight*0.81 TO (nBottom * .69),nRight+3 LABEL STR0049 OF oExplorer:GetPanel(nPanel) PIXEL //" PARAMETROS: "
			TSay():New(nTopPar := nTopPar+10,nRight*0.82,{|| aParam[01][1] },oExplorer:GetPanel(nPanel),,,,,,.T.,CLR_BLACK,CLR_WHITE)
			TSay():New(nTopPar := nTopPar+00,nRight*0.93,{|| aParam[01][2] },oExplorer:GetPanel(nPanel),,,,,,.T.,CLR_BLACK,CLR_WHITE)			
			TSay():New(nTopPar := nTopPar+10,nRight*0.82,{|| aParam[02][1] },oExplorer:GetPanel(nPanel),,,,,,.T.,CLR_BLACK,CLR_WHITE)
			TSay():New(nTopPar := nTopPar+00,nRight*0.93,{|| aParam[02][2] },oExplorer:GetPanel(nPanel),,,,,,.T.,CLR_BLACK,CLR_WHITE)			
			TSay():New(nTopPar := nTopPar+10,nRight*0.82,{|| aParam[03][1] },oExplorer:GetPanel(nPanel),,,,,,.T.,CLR_BLACK,CLR_WHITE)
			TSay():New(nTopPar := nTopPar+00,nRight*0.93,{|| aParam[03][2] },oExplorer:GetPanel(nPanel),,,,,,.T.,CLR_BLACK,CLR_WHITE)			
			TSay():New(nTopPar := nTopPar+10,nRight*0.82,{|| aParam[04][1] },oExplorer:GetPanel(nPanel),,,,,,.T.,CLR_BLACK,CLR_WHITE)
			TSay():New(nTopPar := nTopPar+00,nRight*0.93,{|| aParam[04][2] },oExplorer:GetPanel(nPanel),,,,,,.T.,CLR_BLACK,CLR_WHITE)			
			TSay():New(nTopPar := nTopPar+10,nRight*0.82,{|| aParam[05][1] },oExplorer:GetPanel(nPanel),,,,,,.T.,CLR_BLACK,CLR_WHITE)
			TSay():New(nTopPar := nTopPar+00,nRight*0.93,{|| aParam[05][2] },oExplorer:GetPanel(nPanel),,,,,,.T.,CLR_BLACK,CLR_WHITE)			
			TSay():New(nTopPar := nTopPar+10,nRight*0.82,{|| aParam[06][1] },oExplorer:GetPanel(nPanel),,,,,,.T.,CLR_BLACK,CLR_WHITE)
			TSay():New(nTopPar := nTopPar+00,nRight*0.93,{|| aParam[06][2] },oExplorer:GetPanel(nPanel),,,,,,.T.,CLR_BLACK,CLR_WHITE)			
			TSay():New(nTopPar := nTopPar+10,nRight*0.82,{|| aParam[07][1] },oExplorer:GetPanel(nPanel),,,,,,.T.,CLR_BLACK,CLR_WHITE)
			TSay():New(nTopPar := nTopPar+00,nRight*0.93,{|| aParam[07][2] },oExplorer:GetPanel(nPanel),,,,,,.T.,CLR_BLACK,CLR_WHITE)			
			TSay():New(nTopPar := nTopPar+10,nRight*0.82,{|| aParam[08][1] },oExplorer:GetPanel(nPanel),,,,,,.T.,CLR_BLACK,CLR_WHITE)
			TSay():New(nTopPar := nTopPar+00,nRight*0.93,{|| aParam[08][2] },oExplorer:GetPanel(nPanel),,,,,,.T.,CLR_BLACK,CLR_WHITE)			
			TSay():New(nTopPar := nTopPar+10,nRight*0.82,{|| aParam[09][1] },oExplorer:GetPanel(nPanel),,,,,,.T.,CLR_BLACK,CLR_WHITE)
			TSay():New(nTopPar := nTopPar+00,nRight*0.93,{|| aParam[09][2] },oExplorer:GetPanel(nPanel),,,,,,.T.,CLR_BLACK,CLR_WHITE)			
			TSay():New(nTopPar := nTopPar+10,nRight*0.82,{|| aParam[10][1] },oExplorer:GetPanel(nPanel),,,,,,.T.,CLR_BLACK,CLR_WHITE)
			TSay():New(nTopPar := nTopPar+00,nRight*0.93,{|| aParam[10][2] },oExplorer:GetPanel(nPanel),,,,,,.T.,CLR_BLACK,CLR_WHITE)			
			TSay():New(nTopPar := nTopPar+10,nRight*0.82,{|| aParam[11][1] },oExplorer:GetPanel(nPanel),,,,,,.T.,CLR_BLACK,CLR_WHITE)
			TSay():New(nTopPar := nTopPar+00,nRight*0.93,{|| aParam[11][2] },oExplorer:GetPanel(nPanel),,,,,,.T.,CLR_BLACK,CLR_WHITE)			
			TSay():New(nTopPar := nTopPar+10,nRight*0.82,{|| aParam[12][1] },oExplorer:GetPanel(nPanel),,,,,,.T.,CLR_BLACK,CLR_WHITE)
			TSay():New(nTopPar := nTopPar+00,nRight*0.93,{|| aParam[12][2] },oExplorer:GetPanel(nPanel),,,,,,.T.,CLR_BLACK,CLR_WHITE)
			TSay():New(nTopPar := nTopPar+10,nRight*0.82,{|| aParam[13][1] },oExplorer:GetPanel(nPanel),,,,,,.T.,CLR_BLACK,CLR_WHITE)
			TSay():New(nTopPar := nTopPar+00,nRight*0.93,{|| aParam[13][2] },oExplorer:GetPanel(nPanel),,,,,,.T.,CLR_BLACK,CLR_WHITE)
			TSay():New(nTopPar := nTopPar+10,nRight*0.82,{|| aParam[14][1] },oExplorer:GetPanel(nPanel),,,,,,.T.,CLR_BLACK,CLR_WHITE)
			TSay():New(nTopPar := nTopPar+00,nRight*0.93,{|| aParam[14][2] },oExplorer:GetPanel(nPanel),,,,,,.T.,CLR_BLACK,CLR_WHITE)
			
			// Mensagem para indicadores de Formas de Pagamentos e Categorias de Produtos
		
			nTopPar := nBottom * .70
			@ nTopPar,nRight*0.81 TO (nBottom * .88),nRight+3 LABEL "" OF oExplorer:GetPanel(nPanel) PIXEL
			If cOPC $ "11/21"
				cIndicador := STR0030 //"Grupo de filial"
			ElseIf cOPC $ "12/22"
				cIndicador := STR0031 //"Filial"
			ElseIf cOPC == "13"
				cIndicador := STR0018 //"Vendedores"
			ElseIf cOPC == "14"
				cIndicador := STR0019 //"Formas de Pagamento"
			ElseIf cOPC == "15"
				cIndicador := STR0058 //"Categoria de Produto"	
			EndIf
			
			TSay():New(nTopPar := nTopPar+10,nRight*0.82,{|| aMsgPnl[01]+cIndicador },oExplorer:GetPanel(nPanel),,,,,,.T.,CLR_BLACK,CLR_WHITE)
			TSay():New(nTopPar := nTopPar+10,nRight*0.82,{|| aMsgPnl[02] },oExplorer:GetPanel(nPanel),,,,,,.T.,CLR_BLACK,CLR_WHITE)
			If (mv_par13 == 1 .AND. cOPC <> "15") .OR. (mv_par13 == 2 .AND. cOPC == "14") .OR. (cOPC $ "21/22") // Prioriza Forma de pagamento
				TSay():New(nTopPar := nTopPar+10,nRight*0.82,{|| aMsgPnl[03] },oExplorer:GetPanel(nPanel),,,,,,.T.,CLR_BLACK,CLR_WHITE)
			Else
				TSay():New(nTopPar := nTopPar+10,nRight*0.82,{|| aMsgPnl[04] },oExplorer:GetPanel(nPanel),,,,,,.T.,CLR_BLACK,CLR_WHITE)
			EndIf

	    Else
		    Aadd(aMSG,cMSG) 
			LJ7018Vazio(oExplorer, nPanel, aMSG )
	    Endif
  	Endif
Endif	
	
RestArea(aArea)

Return Nil


//#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~
//                                                              FIM                                         
//#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³LJ7018GRAPºAutor  ³Microsiga           º Data ³ 11/10/2013  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Configuracoes                                              º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Indicadores Gerenciais                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function LJ7018GRAP(	oGraphic,		nTop,			nLeft,			nRight, 	;
							nBottom,		oPai,			aSerie,			cTitle, 	;
							nIndicador,		cInforme1,		cInforme2,		cInforme3, 	;
							oLblInfo1,		oLblInfo2,		oLblInfo3,		nAlign, 	;
							cPict,			cMask)
							
Local nI			:= 0    // Contador For
Local cCbxResA		:= ""   // Contem a opcao de formato padrão para exibir os graficos
Local aCbxResA		:= {}   // Contem as opçoes de formato de exibicao dos graficos
Local cCbxQtVr		:= ""   // Contem a opcao de informacao padrão para exibir os graficos
Local aCbxQtVr		:= {}   // Contem as opçoes de informacoes de exibicao dos graficos
Local aGraficos		:= {{STR0045,BARCHART},{STR0046,PIECHART}} 	//"Barra"#"Pizza"
Local aInfos		:= {{STR0041,1},{STR0040,2}} 					//"Valores"#"Quantidades"
Local nTpChart		:= 0    // Contem o formato de exibicao de grafico selecionado pelo usuario
Local nTpInfo		:= 1    // Contem qual tipo de informacao que sera apresentado no grafico selecionado pelo usuario
Local oPanGra		:= NIL  // Agrupador dos componentes visuais utilizados para construir o grafico
Local oPanelCombo	:= NIL  // Agrupador dos componentes visuais utilizados para exbir as opções de exibicao dos graficos
Local oPanelQtdVr	:= NIL  // Agrupador dos componentes visuais utilizados para exbir as opções de exibicao dos graficos

Static oFwChart		:= NIL  				// Exibe o Grafico

Default oGraphic	:= NIL	// Objeto gráfico
Default nTop		:= 0	// Objeto gráfico
Default nLeft		:= 0  	// Posicao da esquerda
Default nRight		:= 0	// Posicao da direita
Default nBottom		:= 0	// Posicao do rodape
Default oPai		:= NIL	// Objeto gráfico
Default aSerie		:= {}  	// Array com as séries
Default cTitle		:= ""	// Titulo do grafico	
Default nIndicador	:= 0   	// Tipo de Indicador
Default cInforme1	:= ""	// Informativo 01
Default cInforme2	:= ""	// Informativo 02
Default cInforme3	:= ""	// Informativo 03
Default oLblInfo1	:= NIL 	// Objeto Label 01
Default oLblInfo2	:= NIL 	// Objeto Label 02
Default oLblInfo3	:= NIL 	// Objeto Label 03

Default nAlign		:= CONTROL_ALIGN_BOTTOM	//Alinhamento da Legenda
Default cPict		:= "@E 999,999,999.99" 	//Formatacao do titulo 
Default cMask		:= " *@* "	   			//Mascara do titulo

oPanelCombo	:= tPanel():New(nTop+00,nLeft+000,"",oPai,,,,CLR_WHITE,CLR_WHITE,nRight-000,15)
oPanelQtdVr	:= tPanel():New(nTop+00,nLeft+135,"",oPai,,,,CLR_WHITE,CLR_WHITE,nRight-135,15)
oPanGra		:= tPanel():New(nTop+12,nLeft+000,"",oPai,,,,CLR_WHITE,CLR_WHITE,nRight*0.80,nBottom-05)

aCbxResA := {STR0045,STR0046} //"Barra"#"Pizza"
aCbxQtVr := {STR0041,STR0040} //"Valores"#"Quantidades"
cCbxResA := aCbxResA[1]
cCbxQtVr := aCbxQtVr[1]

If ValType(oFwChart) <> "O"
	oFwChart := FwChartFactory():New()
EndIf 

@ 04, 05 Say STR0044+":" Size 050, 008 Pixel Of oPanelCombo //"Tipo de Gráfico"
@ 02, 55 ComboBox cCbxResA Items aCbxResA Size 050, 008 Pixel Of oPanelCombo;	
	On Change (	nTpChart := aScan( aGraficos, {|xVar| xVar[1] == cCbxResA}),;
				LJ7018Chrt(	@oFwChart,	@oGraphic,	oPanGra,	aGraficos[nTpChart][2],	;
							aSerie,		nAlign,		cTitle,		cPict, 					;
							cMask,		nTpInfo,	@cInforme1,	@cInforme2, 			;
							@cInforme3),oLblInfo1:Refresh(),oLblInfo2:Refresh(),oLblInfo3:Refresh();
				)
If nIndicador == 1 .OR. nIndicador == 2
	@ 04, 05 Say STR0039+":" Size 050, 008 Pixel Of oPanelQtdVr //"Apresenta Por"
	@ 02, 56 ComboBox cCbxQtVr Items aCbxQtVr Size 055, 010 Pixel Of oPanelQtdVr;	
	On Change (	nTpInfo := aScan( aInfos, {|xVar| xVar[1] == cCbxQtVr}),;
				LJ7018Chrt(	@oFwChart,	@oGraphic,	oPanGra,	aGraficos[aScan(aGraficos,{|xVar| xVar[1] == cCbxResA})][2], 	;
							aSerie,		nAlign,		cTitle,		cPict, 															;
							cMask,		nTpInfo,	@cInforme1,	@cInforme2, 													;
							@cInforme3),oLblInfo1:Refresh(),oLblInfo2:Refresh(),oLblInfo3:Refresh();
				)
EndIf

LJ7018Chrt(	@oFwChart,	@oGraphic,	oPanGra,	aGraficos[aScan(aGraficos,{|xVar| xVar[1] == cCbxResA})][2], 	;
			aSerie,		nAlign,		cTitle,		cPict, 															;
			cMask,		nTpInfo,	@cInforme1,	@cInforme2, 													;
			@cInforme3)

Return Nil


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³LJ7018ChrtºAutor  ³Microsiga           º Data ³ 11/10/2013  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Adiciona os dados da série ao grafico                      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Indicadores Gerenciais                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function LJ7018Chrt(	oFwChart,	oGraphic,	oPanGra,	nTpChart, 	;
							aSerie,		nAlign,		cTitle,		cPict, 		;
							cMask,		nTpInfo,	cInforme1,	cInforme2, 	;
							cInforme3)
									
Local nLenAux 	:= 0  // Contem o tamanho do array aSerie
Local nI		:= 0  // Contador For
Local nPos 		:= 0  // Contem o panel atual

Default oFwChart 	:= NIL	// Objeto gráfico
Default oGraphic	:= NIL 	// Objeto gráfico
Default oPanGra		:= NIL 	// Objeto gráfico
Default nTpChart	:= 0	// Tipo de gráfico
Default aSerie		:= {}  	// Array com as séries
Default nAlign		:= 0   	// Tipo de alinhamento
Default cTitle		:= ""  	// Titulo do Painel
Default cPict		:= ""  	// Formato da Picture
Default cMask		:= ""  	// Mascara da informação
Default nTpInfo		:= 0   	// Tipo da Informação
Default cInforme1	:= ""	// Informativo 01
Default cInforme2	:= ""	// Informativo 02
Default cInforme3	:= ""	// Informativo 03

// Pelo fato de o sistema desposicionar, eh carregado o array aSerie com as informacoes do primeiro registro.
nPos := aScan(aSerieAux,{|xVar| xVar[1] == oExplorer:NPANEL})
If nPos > 0 // Verifica pelo Panel
	If ValType(cTitle) == "O"
		cTitle := aSerieAux[nPos][02]
	EndIf
	aSerie := aSerieAux[nPos][03]
Else		// Verifica pelo Titulo
	If ValType(cTitle) == "O"
		cTitle := IIF(ValType(cTitle:cTitle) == "C",cTitle:cTitle,"")
	EndIf
	nPos := aScan(aSerieAux,{|xVar| xVar[2] == cTitle})
	aSerie := aSerieAux[nPos][03]
EndIf

If Valtype(oGraphic) == "O"
	FreeObj(oGraphic) 
EndIf
										
oGraphic := oFwChart:getInstance( nTpChart )

If cTitle <> ""
	oGraphic:setTitle( cTitle, CONTROL_ALIGN_CENTER )
EndIf

oGraphic:setLegend( nAlign )

If cMask <> ""
	oGraphic:setMask( cMask )
EndIf
If cPict <> ""
	oGraphic:setPicture( cPict )
EndIf

oGraphic:init(oPanGra, .T., .T. )

nLenAux := 0
For nI := 1 To LEN(aSerie)
	nLenAux += IIf (aSerie[nI][2] <> 0,1,0)
Next nI	

If nTpChart == BARCHART  				// Barra
	oGraphic:lShadow := !(nLenAux==1) 	// Se tiver apenas 1 serie não apresentará sombra no gráfico
EndIf

For nI := 1 To nLenAux
	If aSerie[nI][2] <> 0 				// Se existir alguma informacao jah no primeiro item
		If aSerie[nI][4] == 0  		// Se não houver um segundo valor na casa 4, geramos barras separadas 
			oGraphic:addSerie( aSerie[nI][3],Round(aSerie[nI][2],2) )
		Else                 		// Caso contrário iremos agrupar as barras do mesmo contexto
			If nTpInfo == 1
				oGraphic:addSerie(aSerie[nI][3]+STR0042, Round(aSerie[nI][2],2) ) //(Valor)
				fAjustaMsg(@cInforme1,@cInforme2,@cInforme3,aSerie,2)
			Else
				oGraphic:addSerie(aSerie[nI][3]+STR0043, Round(aSerie[nI][4],2) ) //(Quant.)
				fAjustaMsg(@cInforme1,@cInforme2,@cInforme3,aSerie,4)
			EndIf
		EndIf
	Endif	
Next nI

oGraphic:setColor("Random")  

oGraphic:Build()

Return Nil


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³LJ7018Vazio ºAutor  ³Armando M. Tessaroli  º Data ³ 11/10/2013  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Monta o panel com informacoes para o caso de nao haver dados   º±±
±±º          ³ para serem pesquisados na base.                                º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Indicadores Gerenciais                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function LJ7018Vazio(oExplorer, nPanel, aTexto)

Local nTop       := 0		// Posicao no TOPO
Local nLeft      := 0		// Posicao na ESQUERDA
Local nBottom    := 0		// Posicao ABAIXO
Local nRight     := 0		// Posicao na DIREITA
Local oBmp1		 := Nil		// Bitmap
Local nI         := 0		// Contador
Local cTextSay	 := ""		// Texto

Default oExplorer	:= NIL 	// Objeto gráfico
Default nPanel 		:= NIL 	// Numero do Painel
Default aTexto 		:= NIL 	// Array com mensagens

nRight := oExplorer:GetPanel(nPanel):nRight
nBottom := oExplorer:GetPanel(nPanel):nBottom

TSay():New(nTop+10,nLeft+10,{|| STR0021 },oExplorer:GetPanel(nPanel),,,,,,.T.,CLR_HRED,CLR_WHITE) //"Atencao, verifique os parametros dos filtros abaixo, pois não existe movimento para esta visão:"

@ nTop+20, nLeft+10 TO nBottom, nRight Label "" Of oExplorer:GetPanel(nPanel) Pixel

If Len(aTexto) > 0
	
	For nI := 1 TO Len(aTexto)
		If aTexto[nI] <> Nil
			cTextSay := "{||'"+aTexto[nI]+"'}"
			TSay():New(nTop+20+(nI*10),nLeft+20,MontaBlock(cTextSay),oExplorer:GetPanel(nPanel),,,,,,.T.,CLR_HBLUE,CLR_WHITE)
		EndIf
	Next nI
	
Else
	TSay():New(nTop+30,nLeft+20,{|| STR0029 },oExplorer:GetPanel(nPanel),,,,,,.T.,CLR_HBLUE,CLR_WHITE) //"Nao existe informaçoes adicionais."
Endif

@ nTop, nLeft BitMap oBmp1 ResName STR0010 Of oExplorer:GetPanel(nPanel) /*Size nRight/6, nBottom+10 NoBorder*/ When .F. Pixel Adjust //"Indicadores Gerenciais"
oBmp1:lAutoSize := .T.

Return Nil

//#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~
//                                Procesamento dos valores que serao impressos pelo painel                                        
//#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ ProcInd11       ³Autor  ³TOTVS               ³ Data ³ 11/10/13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Retorna os valores que serao impressos pelo painel             ³±±
±±³          ³ Faturamento Bruto - Grupo de Filial                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Indicadores Gerenciais                                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function ProcInd11()
Local aArea  	:= GetArea()	//Area Atual
Local nCont		:= 0 			//Contador de serie
Local cQuery    := ""			//Texto SQL que é enviado para o comando TCGenQry
Local aTotal    := {} 			//Array com os totais de incrementados
Local nI		:= 0  			//Contador
Local nTotal    := 0  			//Limitador do numero de registros por ranking
Local lAchou    := .F.			//Indica se já existe o agrupador em aTotal[]
Local lGestao   := IIf( FindFunction("FWCodFil"), FWSizeFilial() > 2, .F. )	// Indica se usa Gestao Corporativa
Local lACVComp  := FWModeAccess("ACV",3)== "C" 									// Verifica se ACV é compartilhada
Local lSE1Comp  := FWModeAccess("SE1",3)== "C" 									// Verifica se SE1 é compartilhada
Local cFiliais	:= LJ7018QryFil(.F.,"SF2")[2]									// Filiais permitidas
Local aChvDocs	:= {}															// Guarda os documentos para não haver repeticoes.

cQuery := "SELECT SAU.AU_CODGRUP,SAU.AU_DESCRI,SF2.F2_FILIAL,SF2.F2_DOC,SF2.F2_SERIE,SF2.F2_VALBRUT "
If mv_par16 == 1 .And. (lCatProd .OR. mv_par13 == 2)
	cQuery += ",SD2.D2_ITEM,SD2.D2_VALBRUT VALORIND,ACV.ACV_CATEGO "
Else
	cQuery += ",SE1.E1_TIPO,SE1.E1_VALOR VALORIND "
EndIf
cQuery += " FROM " + RetSqlName("SF2") + " SF2 "
cQuery += " INNER JOIN " + RetSqlName("SD2") + " SD2 "
cQuery += " ON SD2.D_E_L_E_T_  = ' ' AND SF2.F2_FILIAL = SD2.D2_FILIAL AND SF2.F2_DOC = SD2.D2_DOC AND SF2.F2_SERIE = SD2.D2_SERIE "
cQuery += " INNER JOIN " + RetSqlName("SAU") + " SAU "
cQuery += " ON SAU.D_E_L_E_T_ = ' ' AND SAU.AU_CODFIL = SF2.F2_FILIAL "
If mv_par16 == 1 .And. (lCatProd .OR. mv_par13 == 2)
	cQuery += " INNER JOIN " + RetSqlName("ACV") + " ACV ON ACV.D_E_L_E_T_ =  ' ' AND ACV.ACV_SUVEND <> '1' "
	cQuery += " AND ACV.ACV_CODPRO = CASE WHEN ACV.ACV_CODPRO <> '"+cEspCodPr+"' THEN SD2.D2_COD ELSE '"+cEspCodPr+"' END	"
	cQuery += " AND ACV.ACV_GRUPO  = CASE WHEN ACV.ACV_GRUPO  <> '"+cEspGrupo+"' THEN SD2.D2_GRUPO ELSE '"+cEspGrupo+"' END "
	If lGestao .AND. lACVComp	// Se a tabela ACV for compartilhada aceito a filial corrente
		cQuery += " AND ACV.ACV_FILIAL = '" + xFilial("ACV") + "' "
	Else 						// Se a tabela ACV for exclusiva comparo as Filiais
		cQuery += " AND ACV.ACV_FILIAL = SF2.F2_FILIAL "
	EndIf 
Else
	cQuery += " INNER JOIN (SELECT SL1.L1_FILIAL L1_FILIAL, SL1.L1_DOC L1_DOC, SL1.L1_SERIE L1_SERIE, SL1.L1_DOC NUMTIT, SL1.L1_SERIE PFXTIT "
	cQuery += " 			  FROM " + RetSqlName("SL1") + " SL1 "
	cQuery += " 		     WHERE SL1.L1_TIPO = 'V' " //V=Venda Normal
	cQuery += " 		       AND SL1.D_E_L_E_T_ = ' ' "
	cQuery += " 		    UNION "
	cQuery += " 		    SELECT SL1A.L1_FILIAL L1_FILIAL, SL1A.L1_DOC L1_DOC, SL1A.L1_SERIE L1_SERIE, SL1B.L1_DOCPED NUMTIT, SL1B.L1_SERPED PFXTIT "
	cQuery += " 		      FROM " + RetSqlName("SL1") + " SL1A, " + RetSqlName("SL1") + " SL1B "
	cQuery += " 		     WHERE SL1A.L1_TIPO = 'P' " //P=Venda com Pedido (Entrega/Reserva)
	cQuery += " 		       AND SL1A.D_E_L_E_T_ = ' '"
	cQuery += " 		       AND SL1B.L1_FILIAL = SL1A.L1_FILRES "
	cQuery += " 		       AND SL1B.L1_NUM = SL1A.L1_ORCRES "
	cQuery += " 		       AND SL1B.D_E_L_E_T_ = ' ') QRYSL1 " 
	cQuery += " ON QRYSL1.L1_FILIAL = SF2.F2_FILIAL AND QRYSL1.L1_DOC = SF2.F2_DOC AND QRYSL1.L1_SERIE = SF2.F2_SERIE "
	
	cQuery += " INNER JOIN " + RetSqlName("SE1") + " SE1 "
	cQuery += " ON SE1.D_E_L_E_T_  = ' ' AND SE1.E1_NUM = QRYSL1.NUMTIT AND SE1.E1_PREFIXO = QRYSL1.PFXTIT "
	If lSE1Comp	// Se a tabela SE1 for compartilhada aceito a filial corrente
		cQuery += " AND SE1.E1_FILIAL IN (" + L7018FilC(lGestao,cFiliais) + ") "
	Else							// Se a tabela SE1 for exclusiva comparo as Filiais
		cQuery += " AND SE1.E1_FILIAL = SF2.F2_FILIAL "
	EndIf
EndIf
cQuery += " WHERE SF2.D_E_L_E_T_  = ' ' "
cQuery += " AND " + cFiliais
cQuery += " AND SF2.F2_FILIAL BETWEEN '"+ mv_par05 			+"' AND '"+ mv_par06 		+"' "
cQuery += " AND SF2.F2_EMISSAO >= '" 	+ DToS(mv_par01) 	+ "'"
cQuery += " AND SF2.F2_EMISSAO <= '" 	+ DToS(mv_par02) 	+ "'"
cQuery += " AND SF2.F2_VEND1 >= '" 		+ mv_par07 			+ "'"
cQuery += " AND SF2.F2_VEND1 <= '" 		+ mv_par08 			+ "'"
cQuery += " AND SAU.AU_CODGRUP BETWEEN '"+mv_par03+"' AND '"+mv_par04+"'"
If mv_par16 == 1 .And. (lCatProd .OR. mv_par13 == 2)
	cQuery += " AND ACV.ACV_CATEGO >= '" + mv_par11 		+ "'"
	cQuery += " AND ACV.ACV_CATEGO <= '" + mv_par12 		+ "'"
Else
	cQuery += " AND SE1.E1_TIPO >= '" 		+ mv_par09 		+ "'"
	cQuery += " AND SE1.E1_TIPO <= '" 		+ mv_par10 		+ "'"
EndIf
If mv_par14 == 1
	cQuery += " AND NOT EXISTS ("
	cQuery += " 	SELECT SD1.D1_FILIAL+SD1.D1_DOC+SD1.D1_SERIE FROM " + RetSqlName("SD1") + " SD1 "
	cQuery += " 	WHERE SD1.D_E_L_E_T_  = ' ' AND SD2.D2_FILIAL = SD1.D1_FILIAL AND SD2.D2_DOC = SD1.D1_NFORI "
	cQuery += " 	AND SD2.D2_SERIE = SD1.D1_SERIORI AND SD2.D2_ITEM = SD1.D1_ITEMORI AND SD2.D2_QTDEDEV <> 0 "
	cQuery += ")"
EndIf
cQuery += " GROUP BY SAU.AU_CODGRUP,SAU.AU_DESCRI,SF2.F2_FILIAL,SF2.F2_DOC,SF2.F2_SERIE,SF2.F2_VALBRUT "
If mv_par16 == 1 .And. (lCatProd .OR. mv_par13 == 2)
	cQuery += ",SD2.D2_ITEM,SD2.D2_VALBRUT,ACV.ACV_CATEGO "
Else
	cQuery += ",SE1.E1_TIPO,SE1.E1_VALOR "
EndIf
cQuery += " ORDER BY SAU.AU_CODGRUP,SAU.AU_DESCRI,SF2.F2_FILIAL,SF2.F2_DOC,SF2.F2_SERIE,SF2.F2_VALBRUT"

cQuery := ChangeQuery(cQuery)
DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), 'SAUTRB', .F., .T.)
	
While SAUTRB->(!Eof()) 			
	
    If nCont == 0 
  		Aadd(aTotal,{SAUTRB->AU_CODGRUP,SAUTRB->VALORIND,AllTrim(SAUTRB->AU_DESCRI),nCont+1})
		Aadd(aChvDocs,SAUTRB->(F2_FILIAL+F2_DOC+F2_SERIE))
  		lAchou := .T.
    Else             
	    For nI:= 1 to Len(aTotal)
	    	If SAUTRB->AU_CODGRUP == aTotal[nI][1] 
	    		aTotal[nI][2] := aTotal[nI][2] + SAUTRB->VALORIND		//Incrementa o totalizador do Total
	    		If aScan( aChvDocs, {|x| x == SAUTRB->(F2_FILIAL+F2_DOC+F2_SERIE)} ) == 0
	    			aTotal[nI][4] := aTotal[nI][4] + 1  				//Incrementa o totalizador da Quantidade
	    			Aadd(aChvDocs,SAUTRB->(F2_FILIAL+F2_DOC+F2_SERIE))	//Se não houver documento, incremento.
	    		EndIf
	    		lAchou := .T.
	        EndIf
	    Next nI
	EndIf    
    If !lAchou
    	nCont := 0      
  		Aadd(aTotal,{SAUTRB->AU_CODGRUP,SAUTRB->VALORIND,AllTrim(SAUTRB->AU_DESCRI),nCont+1})
  		aChvDocs := {}
  		Aadd(aChvDocs,SAUTRB->(F2_FILIAL+F2_DOC+F2_SERIE))
    EndIf
	
	nCont ++	
	lAchou := .F.
	
	SAUTRB->(dbSkip())
EndDo

SAUTRB->(DbCloseArea())

//Ordernar do maior para o menor valor 
ASORT(aTotal,,,{ | x,y | x[2] > y[2] } )

//Limitar o numero de registros pelo numero de ranking informado
If Len(aTotal) < Len(aSerie)
   nTotal := Len(aTotal)
Else
   nTotal := Len(aSerie)   
Endif

For nI:= 1 To nTotal
	aSerie[nI][1] := "Cod:" + AllTrim(aTotal[nI][1])
	aSerie[nI][2] := aTotal[nI][2] 										//Totalizador do Total
	aSerie[nI][3] := AllTrim(aTotal[nI][1])+"-"+AllTrim(+aTotal[nI][3])	//Codigo e Descrição
	aSerie[nI][4] := aTotal[nI][4] 										//Totalizador da Quantidade
Next nI  

RestArea(aArea)

Return aSerie

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ ProcInd12       ³Autor  ³TOTVS               ³ Data ³ 11/10/13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Retorna os valores que serao impressos pelo painel             ³±±
±±³          ³ Faturamento Bruto - Filial                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Indicadores Gerenciais                                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function ProcInd12()
Local aArea  	:= GetArea()	//Area Atual
Local nCont		:= 0 			//Contador de serie
Local cQuery    := ""			//Texto SQL que é enviado para o comando TCGenQry
Local aTotal    := {} 			//Array com os totais de incrementados
Local nI		:= 0  			//Contador
Local nTotal    := 0  			//Limitador do numero de registros por ranking
Local lAchou    := .F.			//Indica se já existe o agrupador em aTotal[]
Local aFiliais 	:= Lj7017Fil()	//Recebe o retorno dos nomes das Filiais
Local nPos		:= 0			//Recebe a posição da filial de aFiliais
Local lGestao   := IIf( FindFunction("FWCodFil"), FWSizeFilial() > 2, .F. )	// Indica se usa Gestao Corporativa
Local lACVComp  := FWModeAccess("ACV",3)== "C" 									// Verifica se ACV é compartilhada
Local lSE1Comp  := FWModeAccess("SE1",3)== "C" 									// Verifica se SE1 é compartilhada
Local cFiliais	:= LJ7018QryFil(.F.,"SF2")[2]									// Filiais permitidas
Local aChvDocs	:= {}															// Guarda os documentos para não haver repeticoes.

cQuery := "SELECT SF2.F2_FILIAL,SF2.F2_DOC,SF2.F2_SERIE,SF2.F2_VALBRUT "
If mv_par16 == 1 .And. (lCatProd .OR. mv_par13 == 2)
	cQuery += ",SD2.D2_ITEM,SD2.D2_VALBRUT VALORIND,ACV.ACV_CATEGO "
Else
	cQuery += ",SE1.E1_TIPO,SE1.E1_VALOR VALORIND "
EndIf
cQuery += " FROM " + RetSqlName("SF2") + " SF2 "
cQuery += " INNER JOIN " + RetSqlName("SD2") + " SD2 "
cQuery += " ON SD2.D_E_L_E_T_  = ' ' AND SF2.F2_FILIAL = SD2.D2_FILIAL AND SF2.F2_DOC = SD2.D2_DOC AND SF2.F2_SERIE = SD2.D2_SERIE "
If mv_par16 == 1 .And. (lCatProd .OR. mv_par13 == 2)
	cQuery += " INNER JOIN " + RetSqlName("ACV") + " ACV ON ACV.D_E_L_E_T_ =  ' ' AND ACV.ACV_SUVEND <> '1' "
	cQuery += " AND ACV.ACV_CODPRO = CASE WHEN ACV.ACV_CODPRO <> '"+cEspCodPr+"' THEN SD2.D2_COD ELSE '"+cEspCodPr+"' END	"
	cQuery += " AND ACV.ACV_GRUPO  = CASE WHEN ACV.ACV_GRUPO  <> '"+cEspGrupo+"' THEN SD2.D2_GRUPO ELSE '"+cEspGrupo+"' END "
	If lGestao .AND. lACVComp	// Se a tabela ACV for compartilhada aceito a filial corrente
		cQuery += " AND ACV.ACV_FILIAL = '" + xFilial("ACV") + "' "
	Else 						// Se a tabela ACV for exclusiva comparo as Filiais
		cQuery += " AND ACV.ACV_FILIAL = SF2.F2_FILIAL "
	EndIf
Else
	cQuery += " INNER JOIN (SELECT SL1.L1_FILIAL L1_FILIAL, SL1.L1_DOC L1_DOC, SL1.L1_SERIE L1_SERIE, SL1.L1_DOC NUMTIT, SL1.L1_SERIE PFXTIT "
	cQuery += " 			  FROM " + RetSqlName("SL1") + " SL1 "
	cQuery += " 		     WHERE SL1.L1_TIPO = 'V' " //V=Venda Normal
	cQuery += " 		       AND SL1.D_E_L_E_T_ = ' ' "
	cQuery += " 		    UNION "
	cQuery += " 		    SELECT SL1A.L1_FILIAL L1_FILIAL, SL1A.L1_DOC L1_DOC, SL1A.L1_SERIE L1_SERIE, SL1B.L1_DOCPED NUMTIT, SL1B.L1_SERPED PFXTIT "
	cQuery += " 		      FROM " + RetSqlName("SL1") + " SL1A, " + RetSqlName("SL1") + " SL1B "
	cQuery += " 		     WHERE SL1A.L1_TIPO = 'P' " //P=Venda com Pedido (Entrega/Reserva)
	cQuery += " 		       AND SL1A.D_E_L_E_T_ = ' '"
	cQuery += " 		       AND SL1B.L1_FILIAL = SL1A.L1_FILRES "
	cQuery += " 		       AND SL1B.L1_NUM = SL1A.L1_ORCRES "
	cQuery += " 		       AND SL1B.D_E_L_E_T_ = ' ') QRYSL1 " 
	cQuery += " ON QRYSL1.L1_FILIAL = SF2.F2_FILIAL AND QRYSL1.L1_DOC = SF2.F2_DOC AND QRYSL1.L1_SERIE = SF2.F2_SERIE "
	
	cQuery += " INNER JOIN " + RetSqlName("SE1") + " SE1 "
	cQuery += " ON SE1.D_E_L_E_T_  = ' ' AND SE1.E1_NUM = QRYSL1.NUMTIT AND SE1.E1_PREFIXO = QRYSL1.PFXTIT "
	If lGestao .AND. lSE1Comp	// Se a tabela SE1 for compartilhada aceito a filial corrente
		cQuery += " AND SE1.E1_FILIAL IN (" + L7018FilC(lGestao,cFiliais) + ") "
	Else							// Se a tabela SE1 for exclusiva comparo as Filiais
		cQuery += " AND SE1.E1_FILIAL = SF2.F2_FILIAL "
	EndIf
EndIf
cQuery += " WHERE SF2.D_E_L_E_T_  = ' ' "
cQuery += " AND " + cFiliais
cQuery += " AND SF2.F2_FILIAL BETWEEN '"+ mv_par05 			+"' AND '"+ mv_par06 		+"' "
cQuery += " AND SF2.F2_EMISSAO >= '" 	+ DToS(mv_par01) 	+ "'"
cQuery += " AND SF2.F2_EMISSAO <= '" 	+ DToS(mv_par02) 	+ "'"
cQuery += " AND SF2.F2_VEND1 >= '" 		+ mv_par07 			+ "'"
cQuery += " AND SF2.F2_VEND1 <= '" 		+ mv_par08 			+ "'"
If mv_par16 == 1 .And. (lCatProd .OR. mv_par13 == 2)
	cQuery += " AND ACV.ACV_CATEGO >= '" + mv_par11 		+ "'"
	cQuery += " AND ACV.ACV_CATEGO <= '" + mv_par12 		+ "'"
Else
	cQuery += " AND SE1.E1_TIPO >= '" 	+ mv_par09 			+ "'"
	cQuery += " AND SE1.E1_TIPO <= '" 	+ mv_par10 			+ "'"
EndIf
If mv_par14 == 1
	cQuery += " AND NOT EXISTS ("
	cQuery += " 	SELECT SD1.D1_FILIAL+SD1.D1_DOC+SD1.D1_SERIE FROM " + RetSqlName("SD1") + " SD1 "
	cQuery += " 	WHERE SD1.D_E_L_E_T_  = ' ' AND SD2.D2_FILIAL = SD1.D1_FILIAL AND SD2.D2_DOC = SD1.D1_NFORI "
	cQuery += " 	AND SD2.D2_SERIE = SD1.D1_SERIORI AND SD2.D2_ITEM = SD1.D1_ITEMORI AND SD2.D2_QTDEDEV <> 0 "
	cQuery += ")"
EndIf
cQuery += " GROUP BY SF2.F2_FILIAL,SF2.F2_DOC,SF2.F2_SERIE,SF2.F2_VALBRUT "
If mv_par16 == 1 .And. (lCatProd .OR. mv_par13 == 2)
	cQuery += ",SD2.D2_ITEM,SD2.D2_VALBRUT,ACV.ACV_CATEGO "
Else
	cQuery += ",SE1.E1_TIPO,SE1.E1_PARCELA,SE1.E1_VALOR "
EndIf
cQuery += " ORDER BY SF2.F2_FILIAL,SF2.F2_DOC,SF2.F2_SERIE,SF2.F2_VALBRUT"

cQuery := ChangeQuery(cQuery)
DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), 'FILTRB', .F., .T.)

While FILTRB->(!Eof())

	If nCont == 0
		nPos := aScan( aFiliais, {|xVar| AllTrim(xVar[1]) == AllTrim(FILTRB->F2_FILIAL)})
		Aadd(aTotal,{FILTRB->F2_FILIAL,FILTRB->VALORIND,IIF(nPos>0,aFiliais[nPos][2],""),nCont+1})
		Aadd(aChvDocs,FILTRB->(F2_FILIAL+F2_DOC+F2_SERIE))
		lAchou := .T.
	Else
		For nI:= 1 to Len(aTotal)
			If FILTRB->F2_FILIAL == aTotal[nI][1]
				aTotal[nI][2] := aTotal[nI][2] + FILTRB->VALORIND		//Incrementa o totalizador do Total
				If aScan( aChvDocs, {|x| x == FILTRB->(F2_FILIAL+F2_DOC+F2_SERIE)} ) == 0
					aTotal[nI][4] := aTotal[nI][4] + 1  				//Incrementa o totalizador da Quantidade
					Aadd(aChvDocs,FILTRB->(F2_FILIAL+F2_DOC+F2_SERIE))	//Se não houver documento, incremento.
				EndIf
				lAchou := .T.
			EndIf
		Next nI
	EndIf
	If !lAchou
		nCont := 0
		nPos := aScan( aFiliais, {|xVar| AllTrim(xVar[1]) == AllTrim(FILTRB->F2_FILIAL)})
		Aadd(aTotal,{FILTRB->F2_FILIAL,FILTRB->VALORIND,IIF(nPos>0,aFiliais[nPos][2],""),nCont+1})
		aChvDocs := {}
		Aadd(aChvDocs,FILTRB->(F2_FILIAL+F2_DOC+F2_SERIE))
	EndIf

	nCont ++
	lAchou := .F.

	FILTRB->(dbSkip())
EndDo

FILTRB->(DbCloseArea())

//Ordernar do maior para o menor valor 
ASORT(aTotal,,,{ | x,y | x[2] > y[2] } )

//Limitar o numero de registros pelo numero de ranking informado
If Len(aTotal) < Len(aSerie)
	nTotal := Len(aTotal)
Else
	nTotal := Len(aSerie)
Endif

For nI:= 1 To nTotal
	aSerie[nI][1] := "Cod:" + AllTrim(aTotal[nI][1])
	aSerie[nI][2] := aTotal[nI][2] 										//Totalizador do Total
	aSerie[nI][3] := AllTrim(aTotal[nI][1])+"-"+AllTrim(+aTotal[nI][3])	//Codigo e Descrição
	aSerie[nI][4] := aTotal[nI][4] 										//Totalizador da Quantidade
Next nI

RestArea(aArea)

Return aSerie

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ ProcInd13       ³Autor  ³TOTVS               ³ Data ³ 11/10/13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Retorna os valores que serao impressos pelo painel             ³±±
±±³          ³ Faturamento Bruto - Vendedores                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Indicadores Gerenciais                                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function ProcInd13()
Local aArea  	:= GetArea()	//Area Atual
Local nCont		:= 0 			//Contador de serie
Local cQuery    := ""			//Texto SQL que é enviado para o comando TCGenQry
Local aTotal    := {} 			//Array com os totais de incrementados
Local nI		:= 0  			//Contador
Local nTotal    := 0  			//Limitador do numero de registros por ranking
Local lAchou    := .F.			//Indica se já existe o agrupador em aTotal[]
Local lACVComp  := FWModeAccess("ACV",3)== "C" 									// Verifica se ACV é compartilhada
Local lSA3Comp  := FWModeAccess("SA3",3)== "C" 									// Verifica se SA3 é compartilhada
Local lSE1Comp  := FWModeAccess("SE1",3)== "C" 									// Verifica se SE1 é compartilhada
Local cFiliais	:= LJ7018QryFil(.F.,"SF2")[2]									// Filiais permitidas
Local aChvDocs	:= {}															// Guarda os documentos para não haver repeticoes.
Local cMvLjTpCom := SuperGetMV("MV_LJTPCOM",,"1")								// Verifica tipo de comissão/vendedor por cabeçalho ou item

cQuery := "SELECT SA3.A3_FILIAL,SA3.A3_COD,SA3.A3_NREDUZ,SF2.F2_FILIAL,SF2.F2_DOC,SF2.F2_SERIE,SF2.F2_VALBRUT "
cQuery += ",SD2.D2_ITEM,SD2.D2_VALBRUT VALORIND "
If mv_par16 == 1 .And. (lCatProd .OR. mv_par13 == 2)
	cQuery += ",ACV.ACV_CATEGO "
EndIf
cQuery += " FROM " + RetSqlName("SF2") + " SF2 "
cQuery += " INNER JOIN " + RetSqlName("SD2") + " SD2 "
cQuery += " ON SD2.D_E_L_E_T_  = ' ' AND SF2.F2_FILIAL = SD2.D2_FILIAL AND SF2.F2_DOC = SD2.D2_DOC AND SF2.F2_SERIE = SD2.D2_SERIE "
If cMVLjTpCom $ "2.3" //2 e 3 é Vendedor por Item
	cQuery += " INNER JOIN " + RetSqlName("SL2") + " SL2 ON SL2.D_E_L_E_T_ =  ' ' AND SD2.D2_DOC = SL2.L2_DOC AND SD2.D2_SERIE = SL2.L2_SERIE AND SD2.D2_COD = SL2.L2_PRODUTO AND SD2.D2_ITEMPV = SL2.L2_ITEM "
EndIf
cQuery += " INNER JOIN " + RetSqlName("SA3") + " SA3 "
If cMVLjTpCom $ "2.3" //2 e 3 é Vendedor por Item
	cQuery += " ON SA3.D_E_L_E_T_  = ' ' AND SL2.L2_VEND = SA3.A3_COD "
Else
	cQuery += " ON SA3.D_E_L_E_T_  = ' ' AND SF2.F2_VEND1 = SA3.A3_COD "
EndIf
If lSA3Comp  		// Se a tabela SA3 for compartilhada aceito a filial corrente
	cQuery += " AND SUBSTRING(SA3.A3_FILIAL, 1, " +STRZERO(nTamEEUU,2)+ ") =  SUBSTRING(SF2.F2_FILIAL, 1, " +STRZERO(nTamEEUU,2)+ ") "
Else 				// Se a tabela SA3 for exclusiva comparo as Filiais
	cQuery += " AND SA3.A3_FILIAL = SF2.F2_FILIAL "
EndIf
If mv_par16 == 1 .And. (lCatProd .OR. mv_par13 == 2)
	cQuery += " INNER JOIN " + RetSqlName("ACV") + " ACV ON ACV.D_E_L_E_T_ =  ' ' AND ACV.ACV_SUVEND <> '1' "
	cQuery += " AND ACV.ACV_CODPRO = CASE WHEN ACV.ACV_CODPRO <> '"+cEspCodPr+"' THEN SD2.D2_COD ELSE '"+cEspCodPr+"' END	"
	cQuery += " AND ACV.ACV_GRUPO  = CASE WHEN ACV.ACV_GRUPO  <> '"+cEspGrupo+"' THEN SD2.D2_GRUPO ELSE '"+cEspGrupo+"' END "
	If lACVComp	// Se a tabela ACV for compartilhada aceito a filial corrente
		cQuery += " AND ACV.ACV_FILIAL = '" + xFilial("ACV") + "' "
	Else 			// Se a tabela ACV for exclusiva comparo as Filiais
		cQuery += " AND ACV.ACV_FILIAL = SF2.F2_FILIAL "
	EndIf
EndIf
cQuery += " WHERE SF2.D_E_L_E_T_  = ' ' "
cQuery += " AND " + cFiliais
cQuery += " AND SF2.F2_FILIAL BETWEEN '"+ mv_par05 			+"' AND '"+ mv_par06 		+"' "
cQuery += " AND SF2.F2_EMISSAO >= '" 	+ DToS(mv_par01) 	+ "'"
cQuery += " AND SF2.F2_EMISSAO <= '" 	+ DToS(mv_par02) 	+ "'"
If cMVLjTpCom $ "2.3" //2 e 3 é Vendedor por Item
	cQuery += " AND SL2.L2_VEND >= '" 		+ mv_par07 			+ "'"
	cQuery += " AND SL2.L2_VEND <= '" 		+ mv_par08 			+ "'"
Else
	cQuery += " AND SF2.F2_VEND1 >= '" 		+ mv_par07 			+ "'"
	cQuery += " AND SF2.F2_VEND1 <= '" 		+ mv_par08 			+ "'"
EndIf
If mv_par16 == 1 .And. (lCatProd .OR. mv_par13 == 2)
	cQuery += " AND ACV.ACV_CATEGO >= '" + mv_par11 		+ "'"
	cQuery += " AND ACV.ACV_CATEGO <= '" + mv_par12 		+ "'"
EndIf
If mv_par14 == 1
	cQuery += " AND NOT EXISTS ("
	cQuery += " 	SELECT SD1.D1_FILIAL+SD1.D1_DOC+SD1.D1_SERIE FROM " + RetSqlName("SD1") + " SD1 "
	cQuery += " 	WHERE SD1.D_E_L_E_T_  = ' ' AND SD2.D2_FILIAL = SD1.D1_FILIAL AND SD2.D2_DOC = SD1.D1_NFORI "
	cQuery += " 	AND SD2.D2_SERIE = SD1.D1_SERIORI AND SD2.D2_ITEM = SD1.D1_ITEMORI AND SD2.D2_QTDEDEV <> 0 "
	cQuery += ")"
EndIf
cQuery += " GROUP BY SA3.A3_FILIAL,SA3.A3_COD,SA3.A3_NREDUZ,SF2.F2_FILIAL,SF2.F2_DOC,SF2.F2_SERIE,SF2.F2_VALBRUT "
cQuery += ",SD2.D2_ITEM,SD2.D2_VALBRUT "
If mv_par16 == 1 .And. (lCatProd .OR. mv_par13 == 2)
	cQuery += ",ACV.ACV_CATEGO "
EndIf
cQuery += " ORDER BY SA3.A3_FILIAL,SA3.A3_COD,SA3.A3_NREDUZ, SF2.F2_FILIAL,SF2.F2_DOC,SF2.F2_SERIE,SF2.F2_VALBRUT"

cQuery := ChangeQuery(cQuery)
DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), 'SA3TRB', .F., .T.)
SA3TRB->(DBGoTop())

While SA3TRB->(!Eof()) 			
	
    If nCont == 0
   		Aadd(aTotal,{L7018FilVe(lSA3Comp,SA3TRB->A3_FILIAL,SA3TRB->F2_FILIAL,SA3TRB->A3_COD),SA3TRB->VALORIND,AllTrim(SA3TRB->A3_NREDUZ),nCont+1})
  		lAchou := .T.
  		Aadd(aChvDocs,SA3TRB->(F2_FILIAL+F2_DOC+F2_SERIE))
    Else             
	    For nI:= 1 to Len(aTotal)
	    	If L7018FilVe(lSA3Comp,SA3TRB->A3_FILIAL,SA3TRB->F2_FILIAL,SA3TRB->A3_COD) == aTotal[nI][1] 
	    		aTotal[nI][2] := aTotal[nI][2] + SA3TRB->VALORIND		//Incrementa o totalizador do Total
	    		If aScan( aChvDocs, {|x| x == SA3TRB->(F2_FILIAL+F2_DOC+F2_SERIE)} ) == 0
	    			aTotal[nI][4] := aTotal[nI][4] + 1  				//Incrementa o totalizador da Quantidade
	    			Aadd(aChvDocs,SA3TRB->(F2_FILIAL+F2_DOC+F2_SERIE))	//Se não houver documento, incremento.
	    		EndIf
	    		lAchou := .T.
	        EndIf
	    Next nI
	EndIf    
    If !lAchou
    	nCont := 0      
  		Aadd(aTotal,{L7018FilVe(lSA3Comp,SA3TRB->A3_FILIAL,SA3TRB->F2_FILIAL,SA3TRB->A3_COD),SA3TRB->VALORIND,AllTrim(SA3TRB->A3_NREDUZ),nCont+1})
  		aChvDocs := {}
  		Aadd(aChvDocs,SA3TRB->(F2_FILIAL+F2_DOC+F2_SERIE))
    EndIf
	
	nCont ++	
	lAchou := .F.
	
	SA3TRB->(dbSkip())
EndDo

SA3TRB->(DbCloseArea())

//Ordernar do maior para o menor valor 
ASORT(aTotal,,,{ | x,y | x[2] > y[2] } )

//Limitar o numero de registros pelo numero de ranking informado
If Len(aTotal) < Len(aSerie)
   nTotal := Len(aTotal)
Else
   nTotal := Len(aSerie)   
Endif

For nI:= 1 To nTotal
	aSerie[nI][1] := "Cod:" + AllTrim(aTotal[nI][1])
	aSerie[nI][2] := aTotal[nI][2] 										//Totalizador do Total
	aSerie[nI][3] := AllTrim(aTotal[nI][1])+"-"+AllTrim(+aTotal[nI][3])	//Codigo e Descrição
	aSerie[nI][4] := aTotal[nI][4] 										//Totalizador da Quantidade
Next nI  

RestArea(aArea)

Return aSerie

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ ProcInd14       ³Autor  ³TOTVS               ³ Data ³ 11/10/13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Retorna os valores que serao impressos pelo painel             ³±±
±±³          ³ Faturamento Bruto - Formas de Pagamento                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Indicadores Gerenciais                                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function ProcInd14()
Local aArea  	:= GetArea()	//Area Atual
Local nCont		:= 0 			//Contador de serie
Local cQuery    := ""			//Texto SQL que é enviado para o comando TCGenQry
Local aTotal    := {} 			//Array com os totais de incrementados
Local nI		:= 0  			//Contador
Local nTotal    := 0  			//Limitador do numero de registros por ranking
Local lAchou    := .F.			//Indica se já existe o agrupador em aTotal[]
Local lGestao   := IIf( FindFunction("FWCodFil"), FWSizeFilial() > 2, .F. )	// Indica se usa Gestao Corporativa
Local cFormaPag	:= ""															// Recebe a descrição da forma de pagamento
Local lSE1Comp  := FWModeAccess("SE1",3)== "C" 									// Verifica se SE1 é compartilhada
Local cFiliais	:= LJ7018QryFil(.F.,"SF2")[2]									// Filiais permitidas
Local cChvAnt	:= ""

cQuery := "SELECT SE1.E1_TIPO,SF2.F2_DOC,SF2.F2_SERIE,SF2.F2_VALBRUT,SUM(SE1.E1_VALOR) VALORIND "
cQuery += " FROM " + RetSqlName("SF2") + " SF2 "
cQuery += " INNER JOIN (SELECT SL1.L1_FILIAL L1_FILIAL, SL1.L1_DOC L1_DOC, SL1.L1_SERIE L1_SERIE, SL1.L1_DOC NUMTIT, SL1.L1_SERIE PFXTIT "
cQuery += " 			  FROM " + RetSqlName("SL1") + " SL1 "
cQuery += " 		     WHERE SL1.L1_TIPO = 'V' " //V=Venda Normal
cQuery += " 		       AND SL1.D_E_L_E_T_ = ' ' "
cQuery += " 		    UNION "
cQuery += " 		    SELECT SL1A.L1_FILIAL L1_FILIAL, SL1A.L1_DOC L1_DOC, SL1A.L1_SERIE L1_SERIE, SL1B.L1_DOCPED NUMTIT, SL1B.L1_SERPED PFXTIT "
cQuery += " 		      FROM " + RetSqlName("SL1") + " SL1A, " + RetSqlName("SL1") + " SL1B "
cQuery += " 		     WHERE SL1A.L1_TIPO = 'P' " //P=Venda com Pedido (Entrega/Reserva)
cQuery += " 		       AND SL1A.D_E_L_E_T_ = ' '"
cQuery += " 		       AND SL1B.L1_FILIAL = SL1A.L1_FILRES "
cQuery += " 		       AND SL1B.L1_NUM = SL1A.L1_ORCRES "
cQuery += " 		       AND SL1B.D_E_L_E_T_ = ' ') QRYSL1 " 
cQuery += " ON QRYSL1.L1_FILIAL = SF2.F2_FILIAL AND QRYSL1.L1_DOC = SF2.F2_DOC AND QRYSL1.L1_SERIE = SF2.F2_SERIE "
cQuery += " INNER JOIN " + RetSqlName("SE1") + " SE1 "
cQuery += " ON SE1.D_E_L_E_T_  = ' ' AND SE1.E1_NUM = QRYSL1.NUMTIT AND SE1.E1_PREFIXO = QRYSL1.PFXTIT "
If lGestao .AND. lSE1Comp	// Se a tabela SE1 for compartilhada aceito a filial corrente
	cQuery += " AND SE1.E1_FILIAL IN (" + L7018FilC(lGestao,cFiliais) + ") "	
Else							// Se a tabela SE1 for exclusiva comparo as Filiais
	cQuery += " AND SE1.E1_FILIAL = SF2.F2_FILIAL "
EndIf
cQuery += " WHERE SF2.D_E_L_E_T_  = ' ' "
cQuery += " AND " + cFiliais
cQuery += " AND SF2.F2_FILIAL BETWEEN '"+ mv_par05 			+"' AND '"+ mv_par06 		+"' "
cQuery += " AND SF2.F2_EMISSAO >= '" 	+ DToS(mv_par01) 	+ "'"
cQuery += " AND SF2.F2_EMISSAO <= '" 	+ DToS(mv_par02) 	+ "'"
cQuery += " AND SF2.F2_VEND1 >= '" 		+ mv_par07 			+ "'"
cQuery += " AND SF2.F2_VEND1 <= '" 		+ mv_par08 			+ "'"
cQuery += " AND SE1.E1_TIPO >= '" 		+ mv_par09 			+ "'"
cQuery += " AND SE1.E1_TIPO <= '" 		+ mv_par10 			+ "'"
If mv_par14 == 1
	cQuery += " AND NOT EXISTS ("
	cQuery += " Select SD1.D1_FILIAL+SD1.D1_DOC+SD1.D1_SERIE "
	cQuery += "	From " +RetSqlName("SD1")+ " SD1 " 
	cQuery += "	Inner Join " +RetSqlName("SD2")+ " SD2 On SD2.D2_FILIAL = SD1.D1_FILIAL " 
	cQuery += "		And SD2.D2_DOC = SD1.D1_NFORI "
	cQuery += "		And SD2.D2_SERIE = SD1.D1_SERIORI " 
	cQuery += "		And SD2.D2_ITEM = SD1.D1_ITEMORI "
	cQuery += "	Where SD1.D_E_L_E_T_ = '' "
	cQuery += "		And SD2.D_E_L_E_T_ = '' "
	cQuery += "		And SD2.D2_FILIAL = SF2.F2_FILIAL " 
	cQuery += "		And SD2.D2_DOC = SF2.F2_DOC "
	cQuery += "		And SD2.D2_SERIE = SF2.F2_SERIE "
	cQuery += "		And SD2.D2_QTDEDEV <> 0 ) "
EndIf
cQuery += " GROUP BY SE1.E1_TIPO,SF2.F2_DOC,SF2.F2_SERIE,SF2.F2_VALBRUT "
cQuery += " ORDER BY SE1.E1_TIPO,SF2.F2_DOC,SF2.F2_SERIE,SF2.F2_VALBRUT "

cQuery := ChangeQuery(cQuery)
DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), 'SE1TRB', .F., .T.)
SE1TRB->(DBGoTop())

While SE1TRB->(!Eof()) 			
	cFormaPag := ""
    If nCont == 0
    	cFormaPag := Lj010AdmPer(AllTrim(SE1TRB->E1_TIPO))
  		Aadd(aTotal,{AllTrim(SE1TRB->E1_TIPO),SE1TRB->VALORIND,cFormaPag,nCont+1})
  		lAchou := .T.
    Else             
	    For nI:= 1 to Len(aTotal)
	    	If AllTrim(SE1TRB->E1_TIPO) == aTotal[nI][1]
	    		If cChvAnt <> AllTrim(SE1TRB->F2_SERIE+SE1TRB->F2_DOC)
		    		aTotal[nI][2] := aTotal[nI][2] + SE1TRB->VALORIND		//Incrementa o totalizador do Total
		    		aTotal[nI][4] := aTotal[nI][4] + 1  					//Incrementa o totalizador da Quantidade
		    	EndIf
		    	lAchou := .T.
	        EndIf
	    Next nI
	EndIf    
    If !lAchou
    	nCont := 0
    	cFormaPag := Lj010AdmPer(AllTrim(SE1TRB->E1_TIPO))      
  		Aadd(aTotal,{AllTrim(SE1TRB->E1_TIPO),SE1TRB->VALORIND,cFormaPag,nCont+1})
    EndIf
	
	nCont ++	
	lAchou 	:= .F.
	cChvAnt := AllTrim(SE1TRB->F2_SERIE+SE1TRB->F2_DOC)
	SE1TRB->(dbSkip())
EndDo

SE1TRB->(DbCloseArea())

//Ordernar do maior para o menor valor 
ASORT(aTotal,,,{ | x,y | x[2] > y[2] } )

//Limitar o numero de registros pelo numero de ranking informado
If Len(aTotal) < Len(aSerie)
   nTotal := Len(aTotal)
Else
   nTotal := Len(aSerie)   
Endif

For nI:= 1 To nTotal
	aSerie[nI][1] := "Cod:" + AllTrim(aTotal[nI][1])
	aSerie[nI][2] := aTotal[nI][2] 										//Totalizador do Total
	aSerie[nI][3] := AllTrim(aTotal[nI][1])+"-"+AllTrim(+aTotal[nI][3])	//Codigo e Descrição
	aSerie[nI][4] := aTotal[nI][4] 										//Totalizador da Quantidade
Next nI  

RestArea(aArea)

Return aSerie

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ ProcInd15       ³Autor  ³TOTVS               ³ Data ³ 11/10/13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Retorna os valores que serao impressos pelo painel             ³±±
±±³          ³ Faturamento Bruto - Categoria de Produtos                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Indicadores Gerenciais                                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function ProcInd15()
Local aArea  	:= GetArea()	//Area Atual
Local nCont		:= 0 			//Contador de serie
Local cQuery    := ""			//Texto SQL que é enviado para o comando TCGenQry
Local aTotal    := {} 			//Array com os totais de incrementados
Local nI		:= 0  			//Contador
Local nTotal    := 0  			//Limitador do numero de registros por ranking
Local lAchou    := .F.			//Indica se já existe o agrupador em aTotal[]
Local lGestao   := IIf( FindFunction("FWCodFil"), FWSizeFilial() > 2, .F. )	// Indica se usa Gestao Corporativa
Local lACVComp  := FWModeAccess("ACV",3)== "C" 									// Verifica se ACV é compartilhada
Local cFiliais	:= LJ7018QryFil(.F.,"SF2")[2]									// Filiais permitidas
Local aChvDocs	:= {}															// Guarda os documentos para não haver repeticoes.

cQuery := "SELECT ACU.ACU_FILIAL,ACU.ACU_COD,ACU.ACU_DESC,SF2.F2_FILIAL,SF2.F2_DOC,SF2.F2_SERIE,SF2.F2_VALBRUT,SD2.D2_QUANT,SD2.D2_ITEM,SD2.D2_VALBRUT VALORIND " 
cQuery += " FROM " + RetSqlName("SF2") + " SF2 "
cQuery += " INNER JOIN " + RetSqlName("SD2") + " SD2 "
cQuery += " ON SD2.D_E_L_E_T_  = ' ' AND SF2.F2_FILIAL = SD2.D2_FILIAL AND SF2.F2_DOC = SD2.D2_DOC AND SF2.F2_SERIE = SD2.D2_SERIE "
cQuery += " INNER JOIN " + RetSqlName("ACV") + " ACV "
cQuery += " ON ACV.D_E_L_E_T_ =  ' ' AND ACV.ACV_SUVEND <> '1' "
cQuery += " AND ACV.ACV_CODPRO = CASE WHEN ACV.ACV_CODPRO <> '"+cEspCodPr+"' THEN SD2.D2_COD ELSE '"+cEspCodPr+"' END	"
cQuery += " AND ACV.ACV_GRUPO  = CASE WHEN ACV.ACV_GRUPO  <> '"+cEspGrupo+"' THEN SD2.D2_GRUPO ELSE '"+cEspGrupo+"' END "
If lGestao .AND. lACVComp	// Se a tabela ACV for compartilhada aceito a filial corrente
	cQuery += " AND ACV.ACV_FILIAL = '" + xFilial("ACV") + "' "
Else 						// Se a tabela ACV for exclusiva comparo as Filiais
	cQuery += " AND ACV.ACV_FILIAL = SF2.F2_FILIAL "
EndIf 
cQuery += " INNER JOIN " + RetSqlName("ACU") + " ACU "
cQuery += " ON ACU.D_E_L_E_T_ =  ' ' AND ACU.ACU_FILIAL = ACV.ACV_FILIAL AND ACU.ACU_COD = ACV.ACV_CATEGO "
cQuery += " WHERE SF2.D_E_L_E_T_  = ' ' "
cQuery += " AND " + cFiliais
cQuery += " AND SF2.F2_FILIAL BETWEEN '"+ mv_par05 			+"' AND '"+ mv_par06 		+"' "
cQuery += " AND SF2.F2_EMISSAO >= '" 	+ DToS(mv_par01) 	+ "'"
cQuery += " AND SF2.F2_EMISSAO <= '" 	+ DToS(mv_par02) 	+ "'"
cQuery += " AND SF2.F2_VEND1 >= '" 		+ mv_par07 			+ "'"
cQuery += " AND SF2.F2_VEND1 <= '" 		+ mv_par08 			+ "'"
cQuery += " AND ACV.ACV_CATEGO >= '" 	+ mv_par11 			+ "'"
cQuery += " AND ACV.ACV_CATEGO <= '" 	+ mv_par12 			+ "'"
cQuery += " AND ACU.ACU_MSBLQL <> '1' "
If mv_par14 == 1
	cQuery += " AND NOT EXISTS ("
	cQuery += " 	SELECT SD1.D1_FILIAL+SD1.D1_DOC+SD1.D1_SERIE FROM " + RetSqlName("SD1") + " SD1 "
	cQuery += " 	WHERE SD1.D_E_L_E_T_  = ' ' AND SD2.D2_FILIAL = SD1.D1_FILIAL AND SD2.D2_DOC = SD1.D1_NFORI "
	cQuery += " 	AND SD2.D2_SERIE = SD1.D1_SERIORI AND SD2.D2_ITEM = SD1.D1_ITEMORI AND SD2.D2_QTDEDEV <> 0 "
	cQuery += ")"
EndIf
cQuery += " GROUP BY ACU.ACU_FILIAL,ACU.ACU_COD,ACU.ACU_DESC,SF2.F2_FILIAL,SF2.F2_DOC,SF2.F2_SERIE,SF2.F2_VALBRUT,SD2.D2_QUANT,SD2.D2_ITEM,SD2.D2_VALBRUT "
cQuery += " ORDER BY ACU.ACU_FILIAL,ACU.ACU_COD,ACU.ACU_DESC,SF2.F2_FILIAL,SF2.F2_DOC,SF2.F2_SERIE,SF2.F2_VALBRUT"

cQuery := ChangeQuery(cQuery)
DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), 'ACVTRB', .F., .T.)
ACVTRB->(DBGoTop())

While ACVTRB->(!Eof()) 			
	
    If nCont == 0 
  		Aadd(aTotal,{AllTrim(ACVTRB->ACU_FILIAL)+"/"+AllTrim(ACVTRB->ACU_COD),ACVTRB->VALORIND,AllTrim(ACVTRB->ACU_DESC),nCont+1})
  		lAchou := .T.
  		Aadd(aChvDocs,ACVTRB->(F2_FILIAL+F2_DOC+F2_SERIE))
    Else             
	    For nI:= 1 to Len(aTotal)
	    	If AllTrim(ACVTRB->ACU_FILIAL)+"/"+AllTrim(ACVTRB->ACU_COD) == aTotal[nI][1] 
	    		aTotal[nI][2] := aTotal[nI][2] + ACVTRB->VALORIND		//Incrementa o totalizador do Total
	    		If aScan( aChvDocs, {|x| x == ACVTRB->(F2_FILIAL+F2_DOC+F2_SERIE)} ) == 0
	    			aTotal[nI][4] := aTotal[nI][4] + 1					//Incrementa o totalizador da Quantidade
	    			Aadd(aChvDocs,ACVTRB->(F2_FILIAL+F2_DOC+F2_SERIE))	//Se não houver documento, incremento.
	    		EndIf
	    		
	    		lAchou := .T.
	        EndIf
	    Next nI
	EndIf    
    If !lAchou
    	nCont := 0      
  		Aadd(aTotal,{AllTrim(ACVTRB->ACU_FILIAL)+"/"+AllTrim(ACVTRB->ACU_COD),ACVTRB->VALORIND,AllTrim(ACVTRB->ACU_DESC),nCont+1})
  		aChvDocs := {}
  		Aadd(aChvDocs,ACVTRB->(F2_FILIAL+F2_DOC+F2_SERIE))
    EndIf
	
	nCont ++	
	lAchou := .F.
	
	ACVTRB->(dbSkip())
EndDo

ACVTRB->(DbCloseArea())

//Ordernar do maior para o menor valor 
ASORT(aTotal,,,{ | x,y | x[2] > y[2] } )

//Limitar o numero de registros pelo numero de ranking informado
If Len(aTotal) < Len(aSerie)
   nTotal := Len(aTotal)
Else
   nTotal := Len(aSerie)   
Endif

For nI:= 1 To nTotal
	aSerie[nI][1] := "Cod:" + AllTrim(aTotal[nI][1])
	aSerie[nI][2] := aTotal[nI][2] 										//Totalizador do Total
	aSerie[nI][3] := AllTrim(aTotal[nI][1])+"-"+AllTrim(+aTotal[nI][3])	//Codigo e Descrição
	aSerie[nI][4] := aTotal[nI][4] 										//Totalizador da Quantidade
Next nI  

RestArea(aArea)

Return aSerie

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ ProcInd21       ³Autor  ³TOTVS               ³ Data ³ 11/10/13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Retorna os valores que serao impressos pelo painel             ³±±
±±³          ³ Faturamento p/ Ticket Médio - Grupo de Filial                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Indicadores Gerenciais                                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function ProcInd21()
Local aArea  	:= GetArea()	//Area Atual
Local cQuery    := ""			//Texto SQL que é enviado para o comando TCGenQry
Local aTotal    := {} 			//Array com os totais de incrementados
Local nI		:= 0  			//Contador
Local nTotal    := 0  			//Limitador do numero de registros por ranking
Local lGestao   := IIf( FindFunction("FWCodFil"), FWSizeFilial() > 2, .F. )	// Indica se usa Gestao Corporativa
Local lSE1Comp  := FWModeAccess("SE1",3)== "C" 									// Verifica se SE1 é compartilhada
Local cFiliais	:= LJ7018QryFil(.F.,"SF2")[2]									// Filiais permitidas
Local nCont		:= 0 			//Contador de serie
Local lAchou    := .F.			//Indica se já existe o agrupador em aTotal[]
Local aChvDocs	:= {}			// Guarda os documentos para não haver repeticoes.

cQuery := " SELECT SAU.AU_CODGRUP,SAU.AU_DESCRI, "
cQuery += " 										( Select Sum(D2_QUANT) " 
cQuery += " 											From " +RetSqlName("SD2")+ " SD2_1 " 
cQuery += "		 									Where SD2_1.D_E_L_E_T_ = '' "
cQuery += "		 										And SD2_1.D2_FILIAL = SF2.F2_FILIAL "
cQuery += " 												And SD2_1.D2_DOC = SF2.F2_DOC " 
cQuery += " 												And SD2_1.D2_SERIE = SF2.F2_SERIE ) TOTALITEM, "
cQuery += " 	SF2.F2_FILIAL,SF2.F2_DOC,SF2.F2_SERIE,SF2.F2_CLIENTE,SF2.F2_LOJA,SUM(SE1.E1_VALOR) VALORIND,SE1.E1_TIPO "
cQuery += " FROM " + RetSqlName("SF2") + " SF2 "
cQuery += " INNER JOIN " + RetSqlName("SAU") + " SAU "
cQuery += " 	ON SAU.D_E_L_E_T_ = ' ' AND SAU.AU_CODFIL = SF2.F2_FILIAL "
cQuery += " INNER JOIN (SELECT SL1.L1_FILIAL L1_FILIAL, SL1.L1_DOC L1_DOC, SL1.L1_SERIE L1_SERIE, SL1.L1_DOC NUMTIT, SL1.L1_SERIE PFXTIT "
cQuery += " 			  FROM " + RetSqlName("SL1") + " SL1 "
cQuery += " 		     WHERE SL1.L1_TIPO = 'V' " //V=Venda Normal
cQuery += " 		       AND SL1.D_E_L_E_T_ = ' ' "
cQuery += " 		    UNION "
cQuery += " 		    SELECT SL1A.L1_FILIAL L1_FILIAL, SL1A.L1_DOC L1_DOC, SL1A.L1_SERIE L1_SERIE, SL1B.L1_DOCPED NUMTIT, SL1B.L1_SERPED PFXTIT "
cQuery += " 		      FROM " + RetSqlName("SL1") + " SL1A, " + RetSqlName("SL1") + " SL1B "
cQuery += " 		     WHERE SL1A.L1_TIPO = 'P' " //P=Venda com Pedido (Entrega/Reserva)
cQuery += " 		       AND SL1A.D_E_L_E_T_ = ' '"
cQuery += " 		       AND SL1B.L1_FILIAL = SL1A.L1_FILRES "
cQuery += " 		       AND SL1B.L1_NUM = SL1A.L1_ORCRES "
cQuery += " 		       AND SL1B.D_E_L_E_T_ = ' ') QRYSL1 " 
cQuery += " ON QRYSL1.L1_FILIAL = SF2.F2_FILIAL AND QRYSL1.L1_DOC = SF2.F2_DOC AND QRYSL1.L1_SERIE = SF2.F2_SERIE "
cQuery += " INNER JOIN " + RetSqlName("SE1") + " SE1 "
cQuery += " ON SE1.D_E_L_E_T_  = ' ' AND SE1.E1_NUM = QRYSL1.NUMTIT AND SE1.E1_PREFIXO = QRYSL1.PFXTIT "
If lGestao .AND. lSE1Comp	// Se a tabela SE1 for compartilhada aceito a filial corrente
	cQuery += " AND SE1.E1_FILIAL IN (" + L7018FilC(lGestao,cFiliais) + ") "
Else							// Se a tabela SE1 for exclusiva comparo as Filiais
	cQuery += " AND SE1.E1_FILIAL = SF2.F2_FILIAL "
EndIf
cQuery += " WHERE SF2.D_E_L_E_T_  = ' ' "
cQuery += " 	AND " + cFiliais
cQuery += " 	AND SF2.F2_FILIAL BETWEEN '"+ mv_par05 			+"' AND '"+ mv_par06 		+"' "
cQuery += " 	AND SF2.F2_EMISSAO >= '" 	+ DToS(mv_par01) 	+ "'"
cQuery += " 	AND SF2.F2_EMISSAO <= '" 	+ DToS(mv_par02) 	+ "'"
cQuery += " 	AND SF2.F2_VEND1 >= '" 		+ mv_par07 			+ "'"
cQuery += " 	AND SF2.F2_VEND1 <= '" 		+ mv_par08 			+ "'"
cQuery += " 	AND SE1.E1_TIPO >= '" 		+ mv_par09 			+ "'"
cQuery += " 	AND SE1.E1_TIPO <= '" 		+ mv_par10 			+ "'"
cQuery += " 	AND SAU.AU_CODGRUP >= '" 	+ mv_par03 			+ "'"
cQuery += " 	AND SAU.AU_CODGRUP <= '" 	+ mv_par04 			+ "'"
cQuery += " GROUP BY SAU.AU_CODGRUP,SAU.AU_DESCRI, "
cQuery += " SF2.F2_FILIAL,SF2.F2_DOC,SF2.F2_SERIE,SF2.F2_CLIENTE,SF2.F2_LOJA,SE1.E1_TIPO "
cQuery += " ORDER BY SAU.AU_CODGRUP,SAU.AU_DESCRI"

cQuery := ChangeQuery(cQuery)
DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), 'SAUTRB', .F., .T.)
	
While SAUTRB->(!Eof())
	If nCont == 0 
  		Aadd(aTotal,{SAUTRB->AU_CODGRUP,SAUTRB->VALORIND,AllTrim(SAUTRB->AU_DESCRI),nCont+1,SAUTRB->TOTALITEM})
  		Aadd(aChvDocs,SAUTRB->(F2_FILIAL+F2_DOC+F2_SERIE))
  		lAchou := .T.
    Else             
	    For nI:= 1 to Len(aTotal)
	    	If SAUTRB->AU_CODGRUP == aTotal[nI][1] 
	    		aTotal[nI][2] := aTotal[nI][2] + SAUTRB->VALORIND		//Incrementa o totalizador do Total
	    		If aScan( aChvDocs, {|x| x == SAUTRB->(F2_FILIAL+F2_DOC+F2_SERIE)} ) == 0
	    			aTotal[nI][4] := aTotal[nI][4] + 1  			 	//Incrementa o totalizador da Quantidade
	    			aTotal[nI][5] := aTotal[nI][5] + SAUTRB->TOTALITEM	//Incrementa o totalizador de Itens
	    			Aadd(aChvDocs,SAUTRB->(F2_FILIAL+F2_DOC+F2_SERIE))	//Se não houver documento, incremento.
	    		EndIf
	    		lAchou := .T.
	        EndIf
	    Next nI
	EndIf    
    If !lAchou
    	nCont := 0      
  		Aadd(aTotal,{SAUTRB->AU_CODGRUP,SAUTRB->VALORIND,AllTrim(SAUTRB->AU_DESCRI),nCont+1,SAUTRB->TOTALITEM})
  		aChvDocs := {}
  		Aadd(aChvDocs,SAUTRB->(F2_FILIAL+F2_DOC+F2_SERIE))
    EndIf
	
	nCont ++	
	lAchou := .F.
	
	SAUTRB->(dbSkip())

EndDo

SAUTRB->(DbCloseArea())

//Ordernar do maior para o menor valor 
ASORT(aTotal,,,{ | x,y | x[2] > y[2] } )

//Limitar o numero de registros pelo numero de ranking informado
If Len(aTotal) < Len(aSerie)
   nTotal := Len(aTotal)
Else
   nTotal := Len(aSerie)   
Endif

For nI:= 1 To nTotal
	aSerie[nI][1] := "Cod:" + AllTrim(aTotal[nI][1])
	aSerie[nI][2] := Round(aTotal[nI][2]/aTotal[nI][4],2)					//Totalizador do Total
	aSerie[nI][3] := AllTrim(aTotal[nI][1])+"-"+AllTrim(+aTotal[nI][3])	//Codigo e Descrição
	aSerie[nI][4] := Round(aTotal[nI][5]/aTotal[nI][4],2) 				//Totalizador da Quantidade
Next nI  
ASORT(aSerie,,,{ | x,y | x[2] > y[2] } )
RestArea(aArea)

Return aSerie

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ ProcInd22       ³Autor  ³TOTVS               ³ Data ³ 11/10/13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Retorna os valores que serao impressos pelo painel             ³±±
±±³          ³ Faturamento p/ Ticket Médio - Filial                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Indicadores Gerenciais                                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function ProcInd22()
Local aArea  	:= GetArea()	//Area Atual
Local cQuery    := ""			//Texto SQL que é enviado para o comando TCGenQry
Local aTotal    := {} 			//Array com os totais de incrementados
Local nI		:= 0  			//Contador
Local nTotal    := 0  			//Limitador do numero de registros por ranking
Local aFiliais 	:= Lj7017Fil()	//Recebe o retorno dos nomes das Filiais
Local nPos		:= 0			//Recebe a posição da filial de aFiliais
Local lGestao   := IIf( FindFunction("FWCodFil"), FWSizeFilial() > 2, .F. )	// Indica se usa Gestao Corporativa
Local lSE1Comp  := FWModeAccess("SE1",3)== "C" 									// Verifica se SE1 é compartilhada
Local cFiliais	:= LJ7018QryFil(.F.,"SF2")[2]									// Filiais permitidas
Local nCont		:= 0 			//Contador de serie
Local lAchou    := .F.			//Indica se já existe o agrupador em aTotal[]
Local aChvDocs	:= {}			// Guarda os documentos para não haver repeticoes.

cQuery := " SELECT SF2.F2_FILIAL, "
cQuery += " 						( Select Sum(D2_QUANT) " 
cQuery += " 							From " +RetSqlName("SD2")+ " SSD2 " 
cQuery += "		 					Where SSD2.D_E_L_E_T_ = '' "
cQuery += "		 						And SSD2.D2_FILIAL = SF2.F2_FILIAL "
cQuery += " 								And SSD2.D2_DOC = SF2.F2_DOC " 
cQuery += " 								And SSD2.D2_SERIE = SF2.F2_SERIE ) TOTALITEM, "
cQuery += " SF2.F2_DOC,SF2.F2_SERIE,SF2.F2_CLIENTE,SF2.F2_LOJA,SUM(SE1.E1_VALOR) VALORIND,SE1.E1_TIPO "
cQuery += " FROM " + RetSqlName("SF2") + " SF2 "
cQuery += " INNER JOIN (SELECT SL1.L1_FILIAL L1_FILIAL, SL1.L1_DOC L1_DOC, SL1.L1_SERIE L1_SERIE, SL1.L1_DOC NUMTIT, SL1.L1_SERIE PFXTIT "
cQuery += " 			  FROM " + RetSqlName("SL1") + " SL1 "
cQuery += " 		     WHERE SL1.L1_TIPO = 'V' " //V=Venda Normal
cQuery += " 		       AND SL1.D_E_L_E_T_ = ' ' "
cQuery += " 		    UNION "
cQuery += " 		    SELECT SL1A.L1_FILIAL L1_FILIAL, SL1A.L1_DOC L1_DOC, SL1A.L1_SERIE L1_SERIE, SL1B.L1_DOCPED NUMTIT, SL1B.L1_SERPED PFXTIT "
cQuery += " 		      FROM " + RetSqlName("SL1") + " SL1A, " + RetSqlName("SL1") + " SL1B "
cQuery += " 		     WHERE SL1A.L1_TIPO = 'P' " //P=Venda com Pedido (Entrega/Reserva)
cQuery += " 		       AND SL1A.D_E_L_E_T_ = ' '"
cQuery += " 		       AND SL1B.L1_FILIAL = SL1A.L1_FILRES "
cQuery += " 		       AND SL1B.L1_NUM = SL1A.L1_ORCRES "
cQuery += " 		       AND SL1B.D_E_L_E_T_ = ' ') QRYSL1 " 
cQuery += " ON QRYSL1.L1_FILIAL = SF2.F2_FILIAL AND QRYSL1.L1_DOC = SF2.F2_DOC AND QRYSL1.L1_SERIE = SF2.F2_SERIE "
cQuery += " INNER JOIN " + RetSqlName("SE1") + " SE1 "
cQuery += " ON SE1.D_E_L_E_T_  = ' ' AND SE1.E1_NUM = QRYSL1.NUMTIT AND SE1.E1_PREFIXO = QRYSL1.PFXTIT "
If lGestao .AND. lSE1Comp	// Se a tabela SE1 for compartilhada aceito a filial corrente
	cQuery += " AND SE1.E1_FILIAL IN (" + L7018FilC(lGestao,cFiliais) + ") "
Else							// Se a tabela SE1 for exclusiva comparo as Filiais
	cQuery += " AND SE1.E1_FILIAL = SF2.F2_FILIAL "
EndIf
cQuery += " WHERE SF2.D_E_L_E_T_  = ' ' "
cQuery += " 	AND " + cFiliais
cQuery += " 	AND SF2.F2_FILIAL BETWEEN '"+ mv_par05 			+"' AND '"+ mv_par06 		+"' "
cQuery += " 	AND SF2.F2_EMISSAO >= '" 	+ DToS(mv_par01) 	+ "'"
cQuery += " 	AND SF2.F2_EMISSAO <= '" 	+ DToS(mv_par02) 	+ "'"
cQuery += " 	AND SF2.F2_VEND1 >= '" 		+ mv_par07 			+ "'"
cQuery += " 	AND SF2.F2_VEND1 <= '" 		+ mv_par08 			+ "'"
cQuery += " 	AND SE1.E1_TIPO >= '" 		+ mv_par09 			+ "'"
cQuery += " 	AND SE1.E1_TIPO <= '" 		+ mv_par10 			+ "'"
cQuery += " GROUP BY SF2.F2_FILIAL, "
cQuery += " SF2.F2_DOC,SF2.F2_SERIE,SF2.F2_CLIENTE,SF2.F2_LOJA,SE1.E1_TIPO "
cQuery += " ORDER BY SF2.F2_FILIAL"

cQuery := ChangeQuery(cQuery)
DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), 'FILTRB', .F., .T.)

While FILTRB->(!Eof())
	If nCont == 0 
		nPos := aScan( aFiliais, {|xVar| AllTrim(xVar[1]) == AllTrim(FILTRB->F2_FILIAL)})
		Aadd(aTotal,{FILTRB->F2_FILIAL,FILTRB->VALORIND,IIF(nPos>0,aFiliais[nPos][2],""),nCont+1,FILTRB->TOTALITEM})
		Aadd(aChvDocs,FILTRB->(F2_FILIAL+F2_DOC+F2_SERIE))
  		lAchou := .T.
    Else             
	    For nI:= 1 to Len(aTotal)
	    	If FILTRB->F2_FILIAL == aTotal[nI][1] 
	    		aTotal[nI][2] := aTotal[nI][2] + FILTRB->VALORIND		//Incrementa o totalizador do Total
	    		If aScan( aChvDocs, {|x| x == FILTRB->(F2_FILIAL+F2_DOC+F2_SERIE)} ) == 0
	    			aTotal[nI][4] := aTotal[nI][4] + 1  				//Incrementa o totalizador da Quantidade
	    			aTotal[nI][5] := aTotal[nI][5] + FILTRB->TOTALITEM	//Incrementa o totalizador de Itens
	    			Aadd(aChvDocs,FILTRB->(F2_FILIAL+F2_DOC+F2_SERIE))	//Se não houver documento, incremento.
	    		EndIf
	    		lAchou := .T.
	        EndIf
	    Next nI
	EndIf    
    If !lAchou
    	nCont := 0
    	nPos := aScan( aFiliais, {|xVar| AllTrim(xVar[1]) == AllTrim(FILTRB->F2_FILIAL)})
		Aadd(aTotal,{FILTRB->F2_FILIAL,FILTRB->VALORIND,IIF(nPos>0,aFiliais[nPos][2],""),nCont+1,FILTRB->TOTALITEM})
		aChvDocs := {}
		Aadd(aChvDocs,FILTRB->(F2_FILIAL+F2_DOC+F2_SERIE))
    EndIf
        
	nCont ++	
	lAchou := .F.
	
	FILTRB->(dbSkip())
	
EndDo

FILTRB->(DbCloseArea())

//Ordernar do maior para o menor valor 
ASORT(aTotal,,,{ | x,y | x[2] > y[2] } )

//Limitar o numero de registros pelo numero de ranking informado
If Len(aTotal) < Len(aSerie)
   nTotal := Len(aTotal)
Else
   nTotal := Len(aSerie)   
Endif

For nI:= 1 To nTotal
	aSerie[nI][1] := "Cod:" + AllTrim(aTotal[nI][1])
	aSerie[nI][2] := Round(aTotal[nI][2]/aTotal[nI][4],2) 				//Totalizador do Total
	aSerie[nI][3] := AllTrim(aTotal[nI][1])+"-"+AllTrim(+aTotal[nI][3])	//Codigo e Descrição
	aSerie[nI][4] := Round(aTotal[nI][5]/aTotal[nI][4],2) 				//Totalizador da Quantidade
Next nI  
ASORT(aSerie,,,{ | x,y | x[2] > y[2] } )
RestArea(aArea)

Return aSerie

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ LJ7018QryFil    ³Autor  ³TOTVS               ³ Data ³ 11/10/13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Retorna dados cadastrados no Grupo de Filiais (SAU)            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Indicadores Gerenciais                                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function LJ7018QryFil(lVerifGrp, cAlias)
Local cQuery    := ""  		// Texto SQL que é enviado para o comando TCGenQry
Local nX 		:= 0 		// Contador auxiliar
Local cQueryFil := ""  		// Retorno do complemento de query para filiais
Local aGrpFil	:= {}		// Retorno dos grupos de filiais
Local lAchou	:= .F.		// Indica se já existe o agrupador em aTotal[]
Local aFilUsu   := {}		// Recebe as filiais que o usuario possui acesso
Local cFilUsu   := ""		// Complemento da query com as filiais de acesso do usuário
Local cCompFil	:= ""		// Complemento das filiais do Grupo de Filial
Local nPos 		:= 0		// Recebe posição do array

Default lVerifGrp 	:= .F.	// Verificador de grupos de filiais
Default cAlias		:= ""	// Alias para composicao da query de retorno

//Consulta se a empresa trabalha com Grupo de Filial
If lVerifGrp .AND. AliasInDic("SAU") .AND. !EMPTY(mv_par03+mv_par04)
	
	//1 selecionar as filiais pertencentes ao filtro dos grupos
	cQuery := "SELECT AU_CODFIL, AU_CODGRUP "
	cQuery += " FROM " + RetSqlName("SAU")
	cQuery += " WHERE AU_CODGRUP >= '" 	+ mv_par03 + "' "
	cQuery += " AND AU_CODGRUP <= '" 	+ mv_par04 + "' "
	cQuery += " AND D_E_L_E_T_ = ' ' "
	cQuery += " GROUP BY AU_CODGRUP,AU_CODFIL "
	
	cQuery := ChangeQuery(cQuery)		
	DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), 'SAUTRB', .F., .T.)
	SAUTRB->(DBGoTop())
	
	//Gera array de GF
	If SAUTRB->(!Eof())
	   	While SAUTRB->(!Eof())
			If !Empty(aGrpFil)
				For nX := 1 To Len(aGrpFil)
					If AllTrim(aGrpFil[nX][1]) == alltrim(SAUTRB->AU_CODGRUP) //Grupo de filial
						If !Empty(aGrpFil[nX][2])
							aGrpFil[nX][2] += ",'"+alltrim(SAUTRB->AU_CODFIL)+"'"
						Else
							aGrpFil[nX][2] := "'"+alltrim(SAUTRB->AU_CODFIL)+"'"
						Endif	
						lAchou := .T.
					    Exit
					Endif
				Next nX
				If !lAchou
				   Aadd(aGrpFil,{SAUTRB->AU_CODGRUP,"'"+alltrim(SAUTRB->AU_CODFIL)+"'"})
				   lAchou := .F.
				Endif
			Else
			   Aadd(aGrpFil,{SAUTRB->AU_CODGRUP,"'"+alltrim(SAUTRB->AU_CODFIL)+"'"})
			Endif
			SAUTRB->(dbSkip())
			lAchou := .F.
	   	EndDo
	Endif
	
	SAUTRB->(DbCloseArea())
EndIf

If !EMPTY(cAlias)
	aFilUsu := LJValFilial() //Valida as filiais que o usuario possui acesso
	
	// Inicio
	cQueryFil := cAlias +"."+ IIF(Substr(cAlias,1,1) == 'S',Substr(cAlias,2,LEN(cAlias)),cAlias) + "_FILIAL " // Retira o 'S'
	lAchou := .F.
	
	// Conteudo Sem Grupo de Filial
	If EMPTY(aGPFilial) .AND. !lGPFilial
		If EMPTY(aFilUsu)
			cQueryFil += "IN ( '' ) "
		ElseIf !("@" $ aFilUsu[1])
			For nX := 1 To Len(aFilUsu)
			  	If nX = 1
			     	cFilUsu := alltrim(aFilUsu[nX])
			  	Else
				 	cFilUsu += ","+ alltrim(aFilUsu[nX])
			  	Endif 
			Next
			cFilUsu := IIF(EMPTY(cFilUsu), "''", cFilUsu)
			cQueryFil += "IN ( " + cFilUsu +") "
		Else
			cQueryFil += "BETWEEN '" + mv_par05 + "' AND '" + mv_par06 + "' "
		EndIf
	Else //Com Grupo de Filial
		cQueryFil += "IN ( "
		For nX := 1 To Len(aGPFilial)
			cCompFil := AllTrim(aGPFilial[nX][2])
			If "@" $ aFilUsu[1]
				cQueryFil += aGPFilial[nX][2] + ","
				lAchou := .T.
			ElseIf ( nPos := aScan( aFilUsu, {|xVar| AllTrim(xVar) $ cCompFil }) ) > 0
				cQueryFil += aFilUsu[nPos] + ","
				lAchou := .T.
			EndIf
		Next nX
		// Retiro a ultima virgula.
		If lAchou 
			cQueryFil := IIF( SUBSTR(cQueryFil,LEN(cQueryFil),1) == ',',SUBSTR(cQueryFil,1,LEN(cQueryFil)-1),cQueryFil )
		Else
			cQueryFil += "''"
		EndIF
		cQueryFil += " ) "
	EndIf
	
EndIf

Return {aGrpFil,cQueryFil}

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ Lj7018CatPr     ³Autor  ³TOTVS               ³ Data ³ 11/10/13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Retorna se há consulta com Categoria de Produtos               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Indicadores Gerenciais                                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function Lj7018CatPr()
Local lRet	:= .F.																// Retorno da função
Local lGestao   := IIf( FindFunction("FWCodFil"), FWSizeFilial() > 2, .F. )	// Indica se usa Gestao Corporativa
Local lACVComp  := FWModeAccess("ACV",3)== "C" 									// Verifica se ACV é compartilhada

If AliasInDic("ACU") .AND. !EMPTY(mv_par11+mv_par12)  // Se existir tabela ACU - Categoria de Produtos
	cQuery := "SELECT ACU.ACU_COD "
	cQuery += " FROM " + RetSqlName("ACU") + " ACU "
	cQuery += " INNER JOIN " + RetSqlName("ACV") + " ACV "
	cQuery += " ON ACV.D_E_L_E_T_ =  ' ' "
	cQuery += " AND ACU.ACU_FILIAL = ACV.ACV_FILIAL "
	cQuery += " AND ACU.ACU_COD = ACV.ACV_CATEGO "
	cQuery += " AND ACV.ACV_SUVEND <> '1' "
	If lGestao .AND. lACVComp
		cQuery += " WHERE ACV.ACV_FILIAL = '" + xFilial("ACV") + "' "
	Else
		cQuery += " WHERE " + LJ7018QryFil(.F.,"ACV")[2]
	EndIf
	cQuery += " AND ACU.ACU_COD BETWEEN '"+mv_par11+"' AND '"+mv_par12+"' "
	cQuery += " AND ACU.D_E_L_E_T_ =  ' ' "
	
	cQuery := ChangeQuery(cQuery)
	
	DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), 'ACUTRB', .F., .T.)	
	
	If ACUTRB->(!Eof())
		lRet := .T.
	Else
		lRet := .F.
	Endif
				
	ACUTRB->(DbCloseArea())	
EndIF
	
Return lRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ LJValFilial     ³Autor  ³TOTVS               ³ Data ³ 11/10/13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Valida as filiais que o usuario possui acessos                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Indicadores Gerenciais                                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function LJValFilial()
Local aUsrFil	:= {}	// Retorna vetor com informações do usuário
Local aGrupo    := ""	// Grupos que o usuario pertence
Local nX        := 0	// Variável de laço For
Local nxFil     := 0	// Variável de laço For
Local nInc      := 0	// Variável de laço For
Local aFilUsr   := {}	// Array de retorno com as filiáis de acesso do usuário

PswOrder(1)
If PswSeek( __cUserID, .T. )
	aUsrFil := PswRet()[2,6] 					// Retorna vetor com informações do usuário   
  	
  	If Empty(aUsrFil) .And. PswRet()[2,11]  	// Verifica se prioriza os acessos do grupo do usuario
    	aGrupo := PswRet()[1,10]   				// Grupos que o usuario pertence
       	For nX := 1 To  Len(aGrupo)  			// Busca as filiais dos grupos q o usuario tem acesso 
    	  	PswSeek( aGrupo[nX], .F. ) 
	  	  	For nxFil := 1 To Len(PswRet()[1,11]) 
	    		AADD(aUsrFil, PswRet()[1,11][nXFil])
		    Next
	   	Next
  	Endif   
	
	// Adiciona as filiais que o usuario tem permissão            
	If Len( aUsrFil ) >= 0
		If (!EMPTY(mv_par05) .Or. !EMPTY(mv_par06)) .AND. !lGPFilial // Se nao for grupo de filial
	   		If "@" $ aUsrFil[1] .Or. (Empty(mv_par05) .And. (mv_par06 $ "Z" .Or. mv_par06 $ "z")) // Usuario possui todos os acessos
				For nInc := 1 To Len( aUsrFil )
			   		AADD(aFilUsr, "'"+ Right( aUsrFil[nInc],LEN(aUsrFil[nInc])-2 ) +"'")
		    	Next	
			Else
	   			For nInc := 1 To Len( aUsrFil )    
	 	   		 	If (Right(aUsrFil[nInc],4) >= AllTrim(mv_par05)) .AND. (Right(aUsrFil[nInc],4) <= AllTrim(mv_par06))
						AADD(aFilUsr, "'"+ Right( aUsrFil[nInc],LEN(aUsrFil[nInc])-2 ) +"'")
		    		Endif	
				Next
			Endif
		Else
			For nInc := 1 To Len( aUsrFil )
				AADD(aFilUsr, "'"+Right( aUsrFil[nInc],LEN(aUsrFil[nInc])-2 ) +"'")
			Next	
		Endif	
	Endif
Endif 

Return aFilUsr

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ TMeter   ºAutor  ³Microsiga           º Data ³  11/10/13   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Cria a barra de progresso                                  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Indicadores Gerenciais                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function TMeter(oExplorer, aFuncPanels, aParam )
Local oMeter	// Objeto com a barra de progressao

Default oExplorer 	:= NIL 	// Objeto grafico
Default aFuncPanels := {} 	// Arrays com as funções dos panels
Default aParam	 	:= {} 	// Array de parametros


DEFINE FONT oFont NAME "Arial" BOLD SIZE 9,14

DEFINE DIALOG oDlg TITLE STR0010+" - "+STR0022 FROM 180,180 TO 250,700 PIXEL//"Indicadores Gerenciais" - "Consulta indicadores"

oPnlCentro := TPanel():New(01,01,,oDlg,,,,,,5,15,.F.,.F.)

oPnlCentro:Align := CONTROL_ALIGN_ALLCLIENT

@ 05,20 SAY STR0023	OF oPnlCentro PIXEL SIZE 150,9 FONT oFont COLOR CLR_BLUE  //"Processando.... Aguarde!"
oMeter := TMeter():New(15,10,,30,oPnlCentro,240,16,,.T.,,,.F.,,,,,)

oDlg:bStart := {|| CursorWait(),LJ7018Proc(oMeter, oExplorer ,aFuncPanels, aParam),CursorArrow(),oDlg:End()}

ACTIVATE DIALOG oDlg CENTERED

Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³LJ7018ProcºAutor  ³Microsiga           º Data ³  11/10/13   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Processa as visões dos indicadores                         º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Indicadores Gerenciais                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function LJ7018Proc(oMeter, oExplorer ,aFuncPanels, aParam)
Local nI     := 0	//Contador
Local nTotal := 0 	//Limitador do numero de registros por ranking

Default oMeter	 	:= NIL 	// Objeto de processo
Default oExplorer 	:= NIL 	// Objeto grafico
Default aFuncPanels := {} 	// Arrays com as funções dos panels
Default aParam	 	:= {} 	// Array de parametros

oMeter:SET(0)  
aFuncPanels := {}
aRelatorio	:= {}
nPanel		:= 0

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Função que monta todos os paineis³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
MsgRun(STR0024,STR0025,{||LJ7018MontaPn(oExplorer ,aFuncPanels, aParam)}) //"Selecionando dados...."##"Aguarde!"
nTotal := Len(aFuncPanels)
oMeter:SetTotal(nTotal)

aSerieAux := {}

For nI:= 1 to Len(aFuncPanels) 
	&(aFuncPanels[nI])
	oMeter:Set(nI)  
	oMeter:Refresh()
    ProcessMessages()
Next nI

oMeter:Free()

Return Nil       

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ fAjustaMsg      ³Autor  ³TOTVS               ³ Data ³ 11/10/13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Retorna mensagem com resumo dos indicadores                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Indicadores Gerenciais                                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function fAjustaMsg(	cMensagem1,	cMensagem2,	cMensagem3,	aSerie, ;
							nPosInfo)
Local nFor			:= 0 					//Contador de Laco
Local cMsg			:= "1"					//Define qual variavel de mensagem
Local cMsgMaster 	:= "cMensagem"+cMsg		//Define qual variavel de mensagem está em foco
Local nTotal		:= 0					//Totalizador
Local nContador		:= 0					//Contador
Local cPict	   		:= "@E 999,999,999.99" 	//Formatacao do titulo 

Default cMensagem1	 := NIL 	// String da Mensagem 01
Default cMensagem2	 := NIL 	// String da Mensagem 02
Default cMensagem3	 := NIL 	// String da Mensagem 03
Default aSerie		 := {} 		// Array com as séries
Default nPosInfo	 := 0	 	// String da Mensagem 01

If !Empty(aSerie[1][nPosInfo]) .And. (aSerie[1][nPosInfo] <> 0) //Se o primeiro item jah existe valor, continuo...
	
	For nFor := 1 To Len(aSerie)
		If ValType(aSerie[nFor][nPosInfo]) == "N" .AND. aSerie[nFor][nPosInfo] <> 0
	    	nTotal += aSerie[nFor][nPosInfo];nContador++
		EndIf
	Next nFor
	
	&(cMsgMaster) := ""

	For nFor := 1 To Len(aSerie)
		If aSerie[nFor][nPosInfo] <> 0
			
			&(cMsgMaster) += AllTrim(SUBSTR( aSerie[nFor][3],AT("-", aSerie[nFor][3])+1, LEN(aSerie[nFor][3]) )) + ;
			"->" + " (" + Transform( Round( (aSerie[nFor][nPosInfo]/nTotal)*100, 2 ),"@R 999.99%" ) + ")   -   " 
			
			If Len(&(cMsgMaster)) >= 120 .AND. nFor+1 <= LEN(aSerie) .AND. aSerie[nFor+1][nPosInfo] > 0
				&(cMsgMaster) := SUBSTR(&(cMsgMaster),1, LEN(&(cMsgMaster))-7) // Tira o ultimo Traco
				cMsg := ALLTRIM(STR(VAL(cMsg)+1))
				cMsgMaster := "cMensagem"+cMsg
				&(cMsgMaster) := ""
			EndIf
			
		EndIf
    Next nFor
	&(cMsgMaster) := SUBSTR(&(cMsgMaster),1, LEN(&(cMsgMaster))-7) // Tira o ultimo Traco
	
	cMensagem1 := IIf( VAL(cMsg) >= 1 .AND. !EMPTY(&("cMensagem1")), &("cMensagem1") ,"" )
	cMensagem2 := IIf( VAL(cMsg) >= 2 .AND. !EMPTY(&("cMensagem2")), &("cMensagem2") ,"" )
	cMensagem3 := IIf( VAL(cMsg) >= 3 .AND. !EMPTY(&("cMensagem3")), &("cMensagem3") ,"" )
	
EndIf

Return Nil

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ fAjustaPar      ³Autor  ³TOTVS               ³ Data ³ 11/10/13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Retorna os parâmetros utilizados nos indicadores               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Indicadores Gerenciais                                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function fAjustaPar(aParam, nIndicador)
Local nFor		:= 0 						//Contador de Laco
Local cIndicad	:= AllTrim(STR(nIndicador))	//Indicador Utilizado

Default aParam	 	:= {}		// Array de parametros
Default nIndicador	:= 0	 	// Tipo de Indicador

For nFor := 1 To LEN(aParam)
	If aParam[nFor][03] == "*" .OR. cIndicad $ aParam[nFor][03]
		aParam[nFor][01] := 	IIF (nFor==01,STR0047, IIF (nFor==02,STR0048, IIF (nFor==03,STR0004, IIF (nFor==04,STR0005, ;
								IIF (nFor==05,STR0006, IIF (nFor==06,STR0007, IIF (nFor==07,STR0008, IIF (nFor==08,STR0009, ;
								IIF (nFor==09,STR0016, IIF (nFor==10,STR0017, IIF (nFor==11,STR0014, IIF (nFor==12,STR0015, ;
								IIF (nFor==13,STR0059, IIF (nFor==14,STR0061,""))))))))))))))
		aParam[nFor][02] := 	IIF (nFor==01,DToC(mv_par01), 	IIF (nFor==02,DToC(mv_par02), 	IIF (nFor==03,mv_par03, IIF (nFor==04,mv_par04, ;
								IIF (nFor==05,mv_par05, 		IIF (nFor==06,mv_par06, 		IIF (nFor==07,mv_par07, IIF (nFor==08,mv_par08, ;
								IIF (nFor==09,mv_par09, 		IIF (nFor==10,mv_par10, 		IIF (nFor==11,mv_par11, IIF (nFor==12,mv_par12, ;
								IIF (nFor==13,IIF(mv_par13==1,STR0060,STR0020),IIF (nFor==14,IIF(mv_par14==1,STR0063,STR0062),""))))))))))))))
	Else
		aParam[nFor][01] := ""
		aParam[nFor][02] := ""	
	EndIF
Next nFor

Return Nil

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ L7018VlRotina   ³Autor  ³TOTVS               ³ Data ³ 11/10/13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Valida rotina compatibilizada                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Indicadores Gerenciais                                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function L7018VlRotina(cPerg)
Local lRet := .T.	// Variável de retorno da função

Default cPerg	 	:= ""		// Pergunta da rotina

dbSelectArea("SX1")
dbSetOrder(1)
If !dbSeek(PADR(cPerg,Len(SX1->X1_GRUPO)))
	lRet := .F.
	MsgInfo(STR0050+cPerg+STR0051+STR0052,STR0032) //"Grupo de perguntas["#"]não encontrado. "#"Necessário executar o update U_UPDLO126 para esta empresa."#"Aviso"
EndIf

If lRet 
	#IFDEF TOP
		lRet := .T.	
	#ELSE
		lRet := .F.
		MsgStop(STR0053,STR0032)//"Funcionalidade disponivel somente para TopConnect."#"Aviso"
	#ENDIF 
Endif

Return lRet
	
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ L7018ValPerg    ³Autor  ³TOTVS               ³ Data ³ 11/10/13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Valida as perguntas da rotina                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Indicadores Gerenciais                                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function L7018ValPerg()
Local lRet := .T.	// Variável de retorno da função

// Valida as Datas
If lRet .AND. EMPTY(mv_par01) .AND. EMPTY(mv_par02)
	MsgInfo(STR0038,STR0032) //"Preencha os parametros das Datas para visualizar os indicadores !"#"Aviso"
	lRet := .F.
Else
	If lRet .AND. DToS(mv_par01) > DToS(mv_par02)
		MsgInfo(STR0037,STR0032) //"A Data Inicial não deve ser maior que a Data Final !"#"Aviso"
		lRet := .F.
	EndIf
EndIf
// Valida as Filiais
If lRet .AND. EMPTY(mv_par03) .AND. EMPTY(mv_par04) .AND. EMPTY(mv_par05) .AND. EMPTY(mv_par06)
	MsgInfo(STR0033,STR0032) //"Preencha os parametros das Filiais para visualizar os indicadores !"#"Aviso"
	lRet := .F.
EndIf
// Valida os Vendedores
If lRet .AND. EMPTY(mv_par07) .AND. EMPTY(mv_par08)
	MsgInfo(STR0034,STR0032) //"Preencha os parametros dos Vendedores para visualizar os indicadores !"#"Aviso"
	lRet := .F.
EndIf
// Valida as Formas de Pagamento
If lRet .AND. EMPTY(mv_par09) .AND. EMPTY(mv_par10)
	MsgInfo(STR0036,STR0032) //"Preencha os parametros das Formas de Pagamentos para visualizar os indicadores !"#"Aviso"
	lRet := .F.
EndIf
// Valida o Ranking 
If lRet .AND. EMPTY(mv_par15) 
	MsgInfo(STR0027,STR0032) //"Preencha o parametro Ranking para estabelecer a quantidade de itens no gráfico."#"Aviso"
	lRet := .F.
Else
	// Valida a quantidade do Ranking 
	If lRet .AND. mv_par15 > 99 
		MsgInfo("Preencha o parametro Ranking com um valor menor ou igual a 99.",STR0032)//"Preencha o parametro Ranking com um valor menor ou igual a 10."#"Aviso"
		lRet := .F.
	Endif	
EndIf

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ LJAR7018 ºAutor  ³TOTVS               º Data ³ 11/10/2013  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Relatorio de impressao dos Indicadores Gerenciais          º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Indicadores Gerenciais                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function LJAR7018(oExplorer, aRelatorio)
Local nI := 0 			//Contador

Default oExplorer 	:= NIL 	// Objeto Grafico
Default aRelatorio 	:= {} 	// Array com as funções de relatório

For nI := 1 To Len(aRelatorio)
	If alltrim(aRelatorio[nI][1]) == alltrim(oExplorer:cGetTree)
		&(aRelatorio[nI][2]) //executa o relatório passado como referencia 
		Exit
	Endif
Next nI

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³L7018FilC ºAutor  ³TOTVS               º Data ³ 11/10/2013  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Retorna Empresas+Unidades para filiais compartilhadas      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Indicadores Gerenciais                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function L7018FilC(lGestao, cFiliais)
Local cRet 		:= ""	// Variável de retorno da função
Local cStrFil 	:= ""	// String auxiliar com as filiais para manipulaçao

Default lGestao 	:= .F. 	// Identifica se eh gestao de empresas
Default cFiliais 	:= "" 	// String com as filiais do usuário

If lGestao
	cStrFil := SUBSTR( cFiliais,AT("'", cFiliais)+1,LEN(cFiliais) )
	While !EMPTY(cStrFil)
		cRet += "'"
		cRet += Padr( SUBSTR(cStrFil,1,nTamEEUU),FWSizeFilial() )
		cRet += "',"
		cStrFil := SUBSTR( cStrFil,AT("'", cStrFil)+1,LEN(cStrFil) )
		cStrFil := SUBSTR( cStrFil,AT("'", cStrFil)+1,LEN(cStrFil) )
		If AT("'", cStrFil) == 0
			cStrFil := ""
		EndIf
	EndDo
	If !EMPTY(cRet) // Retiro a ultima virgula
		cRet := SUBSTR( cRet,1,LEN(cRet)-1 )
	EndIf
EndIf

If EMPTY(cRet)
	cRet := "'" + xFilial("SE1") + "'"
EndIf

Return cRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³L7018FilVeºAutor  ³TOTVS               º Data ³ 11/10/2013  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Retorna Empresas+Unidades comparadas com vendedores        º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Indicadores Gerenciais                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function L7018FilVe(lCompara,cA3FILIAL,cF2FILIAL,cA3COD,cSeparador)
Local cRet 		:= ""	// Variável de retorno da função
Default cSeparador := "/"

If lCompara
	cRet := AllTrim(SUBSTR(cF2FILIAL,1,nTamEEUU))+cSeparador+AllTrim(cA3COD)
Else
	cRet := AllTrim(cA3FILIAL)+"/"+AllTrim(cA3COD)
EndIf

Return cRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³L7018PeCatºAutor  ³TOTVS               º Data ³ 11/10/2013  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Monta uma consulta do tipo F3 especifica para a consulta   º±±
±±º          ³ categorias de produtos para todas as filiais               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Indicadores Gerenciais                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function L7018PeCat()
Local aAreaACU    := ACU->(GetArea())				// Area do ACU
Local oDlgCons	  := Nil  							// Objeto Tela
Local oListBox    := Nil                           	// Objeto Listbox com as opcoes
Local nPosLbx     := 0								// Posicao do Listbox
Local nPos        := 0								// Contador          
Local aItens      := {}								// Array dos itens
Local lRet        := .F.							// Retorno da funcao

CursorWait()

dbSelectArea("ACU")
DbSetOrder(1) //ACU_FILIAL+ACU_COD
ACU->(DBGoTop())
While ACU->(!Eof())
	If ACU->ACU_MSBLQL <> "1"
		aAdd(aItens,{ACU->ACU_COD,ACU->ACU_FILIAL,ACU->ACU_DESC})
	EndIf
	ACU->(dbSkip())
EndDo

//Ordernar do menor para o maior
ASORT(aItens,,,{ | x,y | x[1]+x[2] < y[1]+y[2] } )

CursorArrow()

DEFINE MSDIALOG oDlgCons FROM 0,0 TO 230,440 TITLE STR0064 PIXEL	// "Consulta Categorias de Produto"

	@ 05,05 LISTBOX oListBox VAR nPosLbx FIELDS HEADER STR0065, STR0031, STR0066 SIZE 180,100 OF oDlgCons PIXEL NOSCROLL	// "Codigo", "Filial", "Descrição"
	oListBox:SetArray(aItens)
    oListBox:bLine:={|| {	aItens[oListBox:nAt,1],;
						    aItens[oListBox:nAt,2],;
						   	aItens[oListBox:nAt,3]}}

    oListBox:BlDblClick := {||(lRet:= .T.,nPos:= oListBox:nAt, oDlgCons:End())}
	oListBox:Refresh()
                                       
    DEFINE SBUTTON FROM 05,190 TYPE 1  ENABLE OF oDlgCons ACTION (lRet:= .T.,nPos:= oListBox:nAt,oDlgCons:End()) // Ok

    DEFINE SBUTTON FROM 20,190 TYPE 2  ENABLE OF oDlgCons ACTION (lRet:= .F.,oDlgCons:End()) // Cancelar
    
ACTIVATE MSDIALOG oDlgCons CENTERED

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Posiciona no item selecionado na tela³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lRet   
	cCodCateg := aItens[nPos][1]
Endif

RestArea(aAreaACU)

Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³L7018ReCatºAutor  ³TOTVS               º Data ³ 11/10/2013  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Retorna categoria de produto selecionado                   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Indicadores Gerenciais                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function L7018ReCat()

Return(cCodCateg)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³L7018PeGFiºAutor  ³TOTVS               º Data ³ 11/10/2013  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Monta uma consulta do tipo F3 especifica para a consulta   º±±
±±º          ³ Grupo de Filiais                                           º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Indicadores Gerenciais                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function L7018PeGFi()
Local aAreaSAU    := SAU->(GetArea())				// Area do SAU
Local oDlgCons	  := Nil  							// Objeto Tela
Local oListBox    := Nil                           	// Objeto Listbox com as opcoes
Local nPosLbx     := 0								// Posicao do Listbox
Local nPos        := 0								// Contador          
Local aItens      := {}								// Array dos itens
Local lRet        := .F.							// Retorno da funcao
Local cGrupAnt    := ""								// Grupo anterior
CursorWait()

dbSelectArea("SAU")
DbSetOrder(1) //AU_FILIAL+AU_CODGRUP+AU_CODFIL
SAU->(DBGoTop())
If SAU->(!Eof())
	While SAU->(!Eof())
		If cGrupAnt <> SAU->AU_FILIAL+SAU->AU_CODGRUP
			aAdd(aItens,{SAU->AU_FILIAL,SAU->AU_CODGRUP,SAU->AU_DESCRI})
		EndIf
		cGrupAnt := SAU->AU_FILIAL+SAU->AU_CODGRUP
		SAU->(dbSkip())
	EndDo
Else
	Alert(STR0068)//"Não há grupo de filiais cadastrado!"
	Return(.T.)
EndIf
//Ordernar do menor para o maior
ASORT(aItens,,,{ | x,y | x[1]+x[2] < y[1]+y[2] } )

CursorArrow()

DEFINE MSDIALOG oDlgCons FROM 0,0 TO 230,440 TITLE STR0067 PIXEL	// "Consulta Grupos de Filiais"

	@ 05,05 LISTBOX oListBox VAR nPosLbx FIELDS HEADER STR0031, STR0065, STR0066 SIZE 180,100 OF oDlgCons PIXEL NOSCROLL	// "Filial", "Codigo", "Descrição"
	oListBox:SetArray(aItens)
    oListBox:bLine:={|| {	aItens[oListBox:nAt,1],;
						    aItens[oListBox:nAt,2],;
						   	aItens[oListBox:nAt,3]}}

    oListBox:BlDblClick := {||(lRet:= .T.,nPos:= oListBox:nAt, oDlgCons:End())}
	oListBox:Refresh()
                                       
    DEFINE SBUTTON FROM 05,190 TYPE 1  ENABLE OF oDlgCons ACTION (lRet:= .T.,nPos:= oListBox:nAt,oDlgCons:End()) // Ok

    DEFINE SBUTTON FROM 20,190 TYPE 2  ENABLE OF oDlgCons ACTION (lRet:= .F.,oDlgCons:End()) // Cancelar
    
ACTIVATE MSDIALOG oDlgCons CENTERED

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Posiciona no item selecionado na tela³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lRet   
	cCodGrFil := aItens[nPos][2]
Endif

RestArea(aAreaSAU)

Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³L7018ReGFiºAutor  ³TOTVS               º Data ³ 11/10/2013  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Retorna o Grupo de Fialis selecionado                      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Indicadores Gerenciais                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function L7018ReGFi()

Return(cCodGrFil) 
