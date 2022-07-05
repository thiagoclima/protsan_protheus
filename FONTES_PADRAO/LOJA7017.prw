#INCLUDE "PROTHEUS.CH"
#INCLUDE "MSGRAPHI.CH"
#INCLUDE "DBTREE.CH"
#INCLUDE "LOJA7017.CH"
#INCLUDE "PRCONST.CH"

/* 
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³ LOJA7017        	  ³ Autor ³ TOTVS                 ³ Data ³ 02/07/13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Consulta gerencial baseada em movimentacoes criadas pelo SigaLoja e  ³±±
±±³          ³ FrontLoja                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Prevencao de perdas									  		     	³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function LOJA7017()
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
Local cPerg			:= "LJ7017"			// Pergunte (chamado ao clicar em parametros)
Local cQuery        := ""               // Texto SQL que é enviado para o comando TCGenQry
Local aFiliais      := {}              	// Recebera o retorna dos nomes das Filiais	
Local oMeter		:= Nil				// Objeto com a barra de progressao

Static oExplorer   	:= Nil				// Arvores de visoes 
Static oPanels	   	:= {}				// Receberá os paines da arvore(oExplorer)
Static nPanel	   	:= 0 			    // Numero do painel atual
Static lGPFilial   	:= .F.             	// Identificara se existe Grupo de empresa para trabalhar
Static aGPFilial   	:= {}              	// Contem a amarracao de grupos de filiais x filiais
Static lCatProd    	:= .F.   	       	// Identifica se o sistema ira exibir os indicadores Categoria e Grupo de produto
Static aRelatorio  	:= {}              	// Contem a estrutura de chamadas e parametros de relatório referente aos indicadores que o sistema pode executar
Static aSerieAux   	:= {}              	// Contem os dados da série ao grafico    
Static aSerie   	:= {}				// Valores dos itens que farao parte da serie
Static lGestao   	:= IIf( FindFunction("FWCodFil"), FWSizeFilial() > 2, .F. )	// Indica se usa Gestao Corporativa
Static lACVComp  	:= FWModeAccess("ACV",3)== "C" 									// Verifica se ACV é compartilhada
Static lCenVenda 	:= SuperGetMv("MV_LJCNVDA",,.F.)

If !L7017VlRotina()
	Return Nil
EndIf

If Pergunte( cPerg,.T. )

	If !L7017ValPerg()
		Return Nil
	EndIf

	oExplorer := MSExplorer():New( STR0001 ) 	//"Consulta"
	oExplorer:DefaultBar()						//	Define a barra de botoes padrao
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Monta o conjunto de botoes da tool bar do objeto Explorer e as respectivas chamadas das funcoes³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Aadd( aResource, {"IMPRESSAO", STR0039, {|| LJAR7017(oExplorer,aRelatorio)}})		// "Impressao" //"Impressão"
	Aadd( aResource, {"CANCEL"	 , STR0040, {|| oExplorer:Deactivate()}})			// "Cancela"
	
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
	
	aGPFilial := LJ7017QryFil(.T.)[1]
	lGPFilial := !EMPTY(aGPFilial)
	lCatProd := .F.
	//Categoria de produtos                   
	If !Empty(aGPFilial) .AND. "1" $ AllTrim(mv_par26) .AND. !(lGestao .AND. lACVComp) .AND. !EMPTY(mv_par11+mv_par12)
		
		For nY:= 1 to Len(aGPFilial)
		  	cQuery :=	" SELECT ACV.ACV_CATEGO " +;
					" FROM 	" + RetSqlName("ACV")  +" ACV  " +;
					" WHERE ACV.ACV_CATEGO IN (SELECT ACU_COD  FROM 	" + RetSqlName("ACU") +;
					"                      WHERE  ACU_CODPAI >= '" + mv_par11 + "'" +;//CATEGORIA
					"                         AND ACU_CODPAI <= '" + mv_par12 + "'" +;//CATEGORIA
					"                         AND D_E_L_E_T_ = ' ') " +;
		            " AND ACV.ACV_FILIAL IN ( "+ aGPFilial[nY][2]  +")"  +;
		   			" AND ACV.ACV_GRUPO >= '" + mv_par13 + "'" +;
					" AND ACV.ACV_GRUPO <= '" + mv_par14 + "'" +;
		 	 	    " AND ACV.D_E_L_E_T_ =  ' '  "                                                                                 
		
			cQuery := ChangeQuery(cQuery)
			
			DbSelectArea("ACV")
			If Select("ACUTRB") > 0
				ACUTRB->(DbCloseArea())
			Endif
			DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), 'ACUTRB', .F., .T.)
			
			If ACUTRB->(!Eof()) 			
				lCatProd := .T. 
				Exit  	 
			Endif
					
			ACUTRB->(DbCloseArea())	
		Next nY
	ElseIf "1" $ AllTrim(mv_par26) .AND. !EMPTY(mv_par11+mv_par12)
	  	cQuery :=	" SELECT ACV.ACV_CATEGO " +;
					" FROM 	" + RetSqlName("ACV")  +" ACV  " +;
					" WHERE ACV.ACV_CATEGO IN (SELECT ACU_COD  FROM 	" + RetSqlName("ACU") +;
					"                      WHERE  ACU_CODPAI >= '" + mv_par11 + "'" +;//CATEGORIA
					"                         AND ACU_CODPAI <= '" + mv_par12 + "'" +;//CATEGORIA
					"                         AND D_E_L_E_T_ = ' ') " +;
		            " AND ACV.ACV_GRUPO >= '" + mv_par13 + "'" +;
			        " AND ACV.ACV_GRUPO <= '" + mv_par14 + "'" +;
		 	 	    " AND ACV.D_E_L_E_T_ =  ' '  "                                                                                 
		
		cQuery := ChangeQuery(cQuery)
		
		DbSelectArea("ACV")
		If Select("ACUTRB") > 0
			ACUTRB->(DbCloseArea())
		Endif
		DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), 'ACUTRB', .F., .T.)
		
		If ACUTRB->(!Eof()) 			
			lCatProd := .T.
		Endif
	
		ACUTRB->(DbCloseArea())
	Endif
	
	TMeter(oExplorer ,aFuncPanels)
	
	oExplorer:Activate(.T.,bValid)      
			
	RestArea(aArea)
	
EndIf

If Select("ACUTRB") > 0
	ACUTRB->(DbCloseArea())
Endif

Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³LJ7017MontaPanelºAutor ³TOTVS           ºData ³  02/07/02       º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Comandos para criacao do Tree com o respectivo painel para      º±±
±±º          ³cada item da arvore, com funcao para instancia dos objetos      º±±
±±º          ³que cada painel ira conter.                                     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³Prevencao de perdas                                             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function LJ7017MontaPanel(oExplorer  ,aFuncPanels)

Local aArea   	:= GetArea() // Salva a area atual
Local nRanking  := 1   // Contem o numero de registros por ranking
Local cInforme1 := ""  // contem a primeira descricao de informacao do grafico em uso
Local cInforme2 := ""  // contem a segunda  descricao de informacao do grafico em uso
Local cInforme3 := ""  // contem a terceira descricao de informacao do grafico em uso

ProcRegua(50)

If !Empty(mv_par25)
	nRanking := mv_par25
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Criacao da Arvore          - Nivel 0 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ                          
oExplorer:AddTree(Padr(STR0041,150),"SDUPROP",,Padr(StrZero(++nPanel,7),20))//"Prevencao de perdas"
Aadd( oPanels, oExplorer:GetPanel(nPanel) ) 

IncProc()

If "1" $ AllTrim(mv_par26)
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Criacao do 1. Grupo        - Nivel 1 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oExplorer:AddTree(Padr(STR0025,150),"BMPUSER",,Padr(StrZero(++nPanel,7),20))//Estoque
	Aadd( oPanels, 	oExplorer:GetPanel(nPanel) ) 

	IncProc()
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Criacao do 1. Sub-Grupo    - Nivel 2 ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		oExplorer:AddTree(Padr(STR0029,150),"FOLDER13",,Padr(StrZero(++nPanel,7),20)) //Produtos c/ Maior Devolução
		Aadd( oPanels,oExplorer:GetPanel(nPanel) ) 
		
 		IncProc()

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Criacao dos 	Itens         - Nivel 3 ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ   
			If lGPFilial //Somente se existir Grupo de empresa
				oExplorer:AddItem(Padr(STR0030,150),"PMSDOC", Padr(StrZero(++nPanel,7),20))//"Grupo de Filial"
				Aadd( oPanels, oExplorer:GetPanel(nPanel) ) 
				cInforme1 := ""
				cInforme2 := ""
				cInforme3 := ""
				Aadd(aFuncPanels,"LJPnGeral(1,oExplorer,"+Str(nPanel)+","+Str(nRanking)+" , mv_par01, mv_par02, '"+STR0004+" x "+STR0005+"', '01','"+ cInforme1 +"','"+ cInforme2+"','"+ cInforme3+"','"+STR0029+" - "+STR0030+" ' )")
			    Aadd(aRelatorio,{1,STR0041+"\"+STR0025+"\"+STR0029+"\"+STR0030,"LJR70171(lCatProd,'"+STR0041+" - "+STR0025+" - "+STR0029+" - "+STR0030+"',0,aGPFilial)"})//"Prevencao de Perdas\Estoque\Produtos c/ Maior Devolução\Grupo de Filial
				IncProc()
			Endif
			
			oExplorer:AddItem(Padr(STR0031,150),"PMSDOC", Padr(StrZero(++nPanel,7),20))//"Filial"
			Aadd( oPanels, oExplorer:GetPanel(nPanel) ) 
			cInforme1 := ""
			cInforme2 := ""
			cInforme3 := ""
			Aadd(aFuncPanels,"LJPnGeral(1,oExplorer,"+Str(nPanel)+","+Str(nRanking)+" , mv_par03, mv_par04, '"+STR0006+" x "+STR0007+"', '02', '"+ cInforme1 +"','"+ cInforme2+"','"+ cInforme3+"','"+ STR0029+" - "+STR0031+" ' )")
			Aadd(aRelatorio,{1,STR0041+"\"+STR0025+"\"+STR0029+"\"+STR0031,"LJR70171(lCatProd,'"+STR0041+" - "+STR0025+" - "+STR0029+" - "+STR0031+"',2)"})//"Prevencao de Perdas\Produtos c/ Maior Devolução\Filial 
			IncProc()

			If lCatProd //Somente se existir categoria sera exibidos os indicadores Categoria e Grupo
				oExplorer:AddItem(Padr(STR0032,150),"PMSDOC", Padr(StrZero(++nPanel,7),20))//"Categoria de Produtos"
				Aadd( oPanels, oExplorer:GetPanel(nPanel) )
				cInforme1 := ""
				cInforme2 := ""
				cInforme3 := ""
				Aadd(aFuncPanels,"LJPnGeral(1,oExplorer,"+Str(nPanel)+","+Str(nRanking)+" , mv_par04, mv_par12, '"+STR0007+" x "+STR0015+"', '03','"+ cInforme1 +"','"+ cInforme2+"','"+ cInforme3+"','"+STR0029+" - "+STR0032+" ')")
				Aadd(aRelatorio,{"1",STR0041+"\"+STR0025+"\"+STR0029+"\"+STR0032,"LJR70171(lCatProd,'"+STR0041+" - "+STR0025+" - "+STR0029+" - "+STR0032+"',3)"})//"Prevencao de Perdas\Estoque\Produtos c/ Maior Devolução\Categoria de Produtos 
				IncProc()
				
				oExplorer:AddItem(Padr(STR0033,150),"PMSDOC", Padr(StrZero(++nPanel,7),20))//"Grupo de Produtos"
				Aadd( oPanels, oExplorer:GetPanel(nPanel) )
				cInforme1 := ""
				cInforme2 := ""
				cInforme3 := ""
			  	Aadd(aFuncPanels,"LJPnGeral(1,oExplorer,"+Str(nPanel)+","+Str(nRanking)+" , mv_par04, mv_par14, '"+STR0007+" x "+STR0017+"', '04','"+ cInforme1 +"','"+ cInforme2+"','"+ cInforme3+"','"+STR0029+" - "+STR0033+" ')")
   				Aadd(aRelatorio,{"1",STR0041+"\"+STR0025+"\"+STR0029+"\"+STR0033,"LJR70171(lCatProd,'"+STR0041+" - "+STR0025+" - "+STR0029+" - "+STR0033+"',4)"})//"Prevencao de Perdas\Estoque\Produtos c/ Maior Devolução\Grupo de Produtos
			    IncProc()                          
			Endif
	
			oExplorer:AddItem(Padr(STR0034,150),"PMSDOC", Padr(StrZero(++nPanel,7),20))//"Produtos"
			Aadd( oPanels, oExplorer:GetPanel(nPanel) )
			cInforme1 := ""
			cInforme2 := ""
			cInforme3 := ""
			Aadd(aFuncPanels,"LJPnGeral(1,oExplorer,"+Str(nPanel)+","+Str(nRanking)+" , mv_par04, mv_par16, '"+STR0007+" x "+STR0019+"', '05','"+ cInforme1 +"','"+ cInforme2+"','"+ cInforme3+"','"+STR0029+" - "+STR0034+" ')")
			Aadd(aRelatorio,{"1",STR0041+"\"+STR0025+"\"+STR0029+"\"+STR0034,"LJR70171(lCatProd,'"+STR0041+" - "+STR0025+" - "+STR0029+" - "+STR0034+"',5)"})//"Prevencao de Perdas\Estoque\Produtos c/ Maior Devolução\Produtos
			IncProc() 
			
		oExplorer:EndTree()
        
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Criacao do 3. Sub-Grupo    - Nivel 2 ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

		oExplorer:AddTree(Padr(STR0035,150),"FOLDER13",,Padr(StrZero(++nPanel,7),20))//Produtos Cancelados
		Aadd( oPanels, oExplorer:GetPanel(nPanel) ) 
		
		IncProc()
			If lGPFilial //Somente se existir Grupo de filial
				oExplorer:AddItem(Padr(STR0030,150),"PMSDOC", Padr(StrZero(++nPanel,7),20))//"Grupo de Filial"
				Aadd( oPanels, oExplorer:GetPanel(nPanel) ) 
				cInforme1 := ""
				cInforme2 := ""
				cInforme3 := ""
				Aadd(aFuncPanels,"LJPnGeral(1,oExplorer,"+Str(nPanel)+","+Str(nRanking)+" , mv_par01, mv_par02, '"+STR0004+" x "+STR0005+"', '06','"+ cInforme1 +"','"+ cInforme2+"','"+ cInforme3+"', '"+STR0035+" - "+STR0030+" ')")
			    Aadd(aRelatorio,{2,STR0041+"\"+STR0025+"\"+STR0035+"\"+STR0030,"LJR70172(lCatProd,'"+STR0041+" - "+STR0025+" - "+STR0035+" - "+STR0030+"',0,aGPFilial)"})//"Prevencao de Perdas\Estoque\Produtos Cancelados\Grupo de Filial 
				IncProc()
			Endif 
						
			oExplorer:AddItem(Padr(STR0031,150),"PMSDOC", Padr(StrZero(++nPanel,7),20))//"Filial"
			Aadd( oPanels, oExplorer:GetPanel(nPanel) ) 
			cInforme1 := ""
			cInforme2 := ""
			cInforme3 := ""
			Aadd(aFuncPanels,"LJPnGeral(1,oExplorer,"+Str(nPanel)+","+Str(nRanking)+" , mv_par03, mv_par04 ,'"+STR0006+" x "+STR0007+"', '07', '"+ cInforme1 +"','"+ cInforme2+"','"+ cInforme3+"', '"+STR0035+" - "+STR0031+" ')")
		    Aadd(aRelatorio,{2,STR0041+"\"+STR0025+"\"+STR0035+"\"+STR0031,"LJR70172(lCatProd,'"+STR0041+" - "+STR0025+" - "+STR0035+" - "+STR0031+"',2)"})//"Prevencao de Perdas\Estoque\Produtos Cancelados\Filial 
			IncProc()
            
			If lCatProd //Somente se existir categoria sera exibidos os indicadores Categoria e Grupo
				oExplorer:AddItem(Padr(STR0032,150),"PMSDOC", Padr(StrZero(++nPanel,7),20))//"Categoria de Produtos"
				Aadd( oPanels, oExplorer:GetPanel(nPanel) )
				cInforme1 := ""
				cInforme2 := ""
				cInforme3 := ""
				Aadd(aFuncPanels,"LJPnGeral(1,oExplorer,"+Str(nPanel)+","+Str(nRanking)+" , mv_par04, mv_par12, '"+STR0007+" x "+STR0015+"', '08','"+ cInforme1 +"','"+ cInforme2+"','"+ cInforme3+"', '"+STR0035+" - "+STR0032+" ')")
			    Aadd(aRelatorio,{2,STR0041+"\"+STR0025+"\"+STR0035+"\"+STR0032,"LJR70172(lCatProd,'"+STR0041+" - "+STR0025+" - "+STR0035+" - "+STR0032+"',3)"})//"Prevencao de Perdas\Estoque\Produtos Cancelados\Categoria de Produtos
				IncProc()
				
				oExplorer:AddItem(Padr(STR0033,150),"PMSDOC", Padr(StrZero(++nPanel,7),20))//"Grupo de Produtos"
				Aadd( oPanels, oExplorer:GetPanel(nPanel) )
				cInforme1 := ""
				cInforme2 := ""
				cInforme3 := ""
				Aadd(aFuncPanels,"LJPnGeral(1,oExplorer,"+Str(nPanel)+","+Str(nRanking)+" , mv_par04, mv_par14, '"+STR0007+" x "+STR0017+"', '09', '"+ cInforme1 +"','"+ cInforme2+"','"+ cInforme3+"', '"+STR0035+" - "+STR0033+" ')")
			    Aadd(aRelatorio,{2,STR0041+"\"+STR0025+"\"+STR0035+"\"+STR0033,"LJR70172(lCatProd,'"+STR0041+" - "+STR0025+" - "+STR0035+" - "+STR0033+"',4)"})//"Prevencao de Perdas\Estoque\Produtos Cancelados\Grupo de Produtos
				IncProc()                          
	        Endif
	        
			oExplorer:AddItem(Padr(STR0034,150),"PMSDOC", Padr(StrZero(++nPanel,7),20))//"Produtos"
			Aadd( oPanels, oExplorer:GetPanel(nPanel) )
			cInforme1 := ""
			cInforme2 := ""
			cInforme3 := ""
			Aadd(aFuncPanels,"LJPnGeral(1,oExplorer,"+Str(nPanel)+","+Str(nRanking)+" , mv_par04, mv_par16,'"+STR0007+" x "+STR0019+"', '10', '"+ cInforme1 +"','"+ cInforme2+"','"+ cInforme3+"', '"+STR0035+" - "+STR0034+" ')")
		    Aadd(aRelatorio,{2,STR0041+"\"+STR0025+"\"+STR0035+"\"+STR0034,"LJR70172(lCatProd,'"+STR0041+" - "+STR0025+" - "+STR0035+" - "+STR0034+"',5)"})//"Prevencao de Perdas\Estoque\Produtos Cancelados\Produtos 
			IncProc()                          

		oExplorer:EndTree()
                                                                     
		oExplorer:AddTree(Padr(STR0047,150),"FOLDER13",,Padr(StrZero(++nPanel,7),20))//Venda Perdida
		Aadd( oPanels, oExplorer:GetPanel(nPanel) ) 
		
		IncProc()
			If lGPFilial //Somente se existir Grupo de empresa
				oExplorer:AddItem(Padr(STR0030,150),"PMSDOC", Padr(StrZero(++nPanel,7),20))//"Grupo de Filial"
				Aadd( oPanels, oExplorer:GetPanel(nPanel) ) 
				cInforme1 := ""
				cInforme2 := ""
				cInforme3 := ""
				Aadd(aFuncPanels,"LJPnGeral(1,oExplorer,"+Str(nPanel)+","+Str(nRanking)+" , mv_par01, mv_par02,'"+STR0004+" x "+STR0005+" ', '11', '"+ cInforme1 +"','"+ cInforme2+"','"+ cInforme3+"', '"+STR0047+" - "+STR0030+" ')")
			    Aadd(aRelatorio,{3,STR0041+"\"+STR0025+"\"+STR0047+"\"+STR0030,"LJR70173(lCatProd,'"+STR0041+" - "+STR0025+" - "+STR0047+" - "+STR0030+"',0,aGPFilial)"})//"Prevencao de Perdas\Estoque\Venda Perdida\Grupo de Filial 
				IncProc()
			Endif 
						
			oExplorer:AddItem(Padr(STR0031,150),"PMSDOC", Padr(StrZero(++nPanel,7),20))//"Filial"
			Aadd( oPanels, oExplorer:GetPanel(nPanel) ) 
			cInforme1 := ""
			cInforme2 := ""
			cInforme3 := ""
			Aadd(aFuncPanels,"LJPnGeral(1,oExplorer,"+Str(nPanel)+","+Str(nRanking)+" , mv_par03, mv_par04,'"+STR0007+" x "+STR0019+"', '12','"+ cInforme1 +"','"+ cInforme2+"','"+ cInforme3+"','"+STR0047+" - "+STR0031+" ')")
		    Aadd(aRelatorio,{3,STR0041+"\"+STR0025+"\"+STR0047+"\"+STR0031,"LJR70173(lCatProd,'"+STR0041+" - "+STR0025+" - "+STR0047+" - "+STR0031+"',2)"})//"Prevencao de Perdas\Estoque\Venda Perdida\Filial 
			IncProc()
            
			oExplorer:AddItem(Padr(STR0048,150),"PMSDOC", Padr(StrZero(++nPanel,7),20))//"Motivo"
			Aadd( oPanels, oExplorer:GetPanel(nPanel) )
			cInforme1 := ""
			cInforme2 := ""
			cInforme3 := ""
			Aadd(aFuncPanels,"LJPnGeral(1,oExplorer,"+Str(nPanel)+","+Str(nRanking)+" , mv_par19, mv_par20,'"+STR0050+" x "+STR0013+" x "+STR0002+" x "+STR0075+"', '13','"+ cInforme1 +"','"+ cInforme2+"','"+ cInforme3+"','"+STR0047+" - "+STR0048+" ')")
		    Aadd(aRelatorio,{3,STR0041+"\"+STR0025+"\"+STR0047+"\"+STR0048,"LJR70173(lCatProd,'"+STR0041+" - "+STR0025+" - "+STR0047+" - "+STR0048+"',3)"})//"Prevencao de Perdas\Estoque\Venda Perdida\Motivo 
			IncProc()
			
			If lCatProd //Somente se existir categoria sera exibidos os indicadores Categoria e Grupo
				oExplorer:AddItem(Padr(STR0032,150),"PMSDOC", Padr(StrZero(++nPanel,7),20))//"Categoria de Produtos"
				Aadd( oPanels, oExplorer:GetPanel(nPanel) )
				cInforme1 := ""
				cInforme2 := ""
				cInforme3 := ""
				Aadd(aFuncPanels,"LJPnGeral(1,oExplorer,"+Str(nPanel)+","+Str(nRanking)+" , mv_par11, mv_par12,'"+STR0072+" x "+STR0013+" x "+STR0002+" x "+STR0075+"', '14','"+ cInforme1 +"','"+ cInforme2+"','"+ cInforme3+"','"+STR0047+" - "+STR0032+" ')") //'Categoria x Data ate x Estação x PDV'
			    Aadd(aRelatorio,{3,STR0041+"\"+STR0025+"\"+STR0047+"\"+STR0032,"LJR70173(lCatProd,'"+STR0041+" - "+STR0025+" - "+STR0047+" - "+STR0032+"',4)"})//"Prevencao de Perdas\Estoque\Venda Perdida\Categoriga de Produtos 
				IncProc()                          
	
				oExplorer:AddItem(Padr(STR0033,150),"PMSDOC", Padr(StrZero(++nPanel,7),20))//"Grupo de Produtos"
				Aadd( oPanels, oExplorer:GetPanel(nPanel) )
				cInforme1 := ""
				cInforme2 := ""
				cInforme3 := ""
				Aadd(aFuncPanels,"LJPnGeral(1,oExplorer,"+Str(nPanel)+","+Str(nRanking)+" , mv_par13, mv_par14,'"+STR0016+" x "+STR0017+"', '15','"+ cInforme1 +"','"+ cInforme2+"','"+ cInforme3+"','"+STR0047+" - "+STR0033+" ')")//"Grupo de Produto de"## "Grupo de produto ate?"
			    Aadd(aRelatorio,{3,STR0041+"\"+STR0025+"\"+STR0047+"\"+STR0033,"LJR70173(lCatProd,'"+STR0041+" - "+STR0025+" - "+STR0047+" - "+STR0033+"',5)"})//"Prevencao de Perdas\Estoque\Venda Perdida\Grupo de Produtos 
				IncProc()                          
            Endif
            
			oExplorer:AddItem(Padr(STR0034,150),"PMSDOC", Padr(StrZero(++nPanel,7),20))//"Produtos"
			Aadd( oPanels, oExplorer:GetPanel(nPanel) )
			cInforme1 := ""
			cInforme2 := ""
			cInforme3 := ""
			Aadd(aFuncPanels,"LJPnGeral(1,oExplorer,"+Str(nPanel)+","+Str(nRanking)+" , mv_par04, mv_par16,'"+STR0007+" x "+STR0019+"', '16','"+ cInforme1 +"','"+ cInforme2+"','"+ cInforme3+"','"+STR0047+" - "+STR0034+" ')") //"Filial ate?" ##"Produto ate?"
		    Aadd(aRelatorio,{3,STR0041+"\"+STR0025+"\"+STR0047+"\"+STR0034,"LJR70173(lCatProd,'"+STR0041+" - "+STR0025+" - "+STR0047+" - "+STR0034+"',6)"})//"Prevencao de Perdas\Estoque\Venda Perdida\Produtos 
			IncProc()                          
            
		oExplorer:EndTree()
        
		oExplorer:AddTree(Padr(STR0051,150),"FOLDER13",,Padr(StrZero(++nPanel,7),20))//Prod. c/ Diverg. de Inventário
		Aadd( oPanels, oExplorer:GetPanel(nPanel) ) 
		
		IncProc()
			If lGPFilial //Somente se existir Grupo de empresa
				oExplorer:AddItem(Padr(STR0030,150),"PMSDOC", Padr(StrZero(++nPanel,7),20))//"Grupo de Filial"
				Aadd( oPanels, oExplorer:GetPanel(nPanel) ) 
				cInforme1 := ""
				cInforme2 := ""
				cInforme3 := ""
				Aadd(aFuncPanels,"LJPnGeral(1,oExplorer,"+Str(nPanel)+","+Str(nRanking)+" , mv_par01, mv_par02,'"+STR0004+" x "+STR0005+"', '17','"+ cInforme1 +"','"+ cInforme2+"','"+ cInforme3+"','"+STR0051+" - "+STR0030+" ')")//"Grupo de Filial de?"##"Grupo de Filial ate?"##'Prod. c/ Diverg. de Inventário'###'Grupo de Filial '
			    Aadd(aRelatorio,{4,STR0041+"\"+STR0025+"\"+STR0051+"\"+STR0030,"LJR70174(lCatProd,'"+STR0041+" - "+STR0025+" - "+STR0051+" - "+STR0030+"',0,aGPFilial)"})//"Prevencao de Perdas\Estoque\Prod. c/ Diverg. de Inventário\Grupo de Filial 
				IncProc()
			Endif 
						
			oExplorer:AddItem(Padr(STR0031,150),"PMSDOC", Padr(StrZero(++nPanel,7),20))//"Filial"
			Aadd( oPanels, oExplorer:GetPanel(nPanel) ) 
			cInforme1 := ""
			cInforme2 := ""
			cInforme3 := ""
			Aadd(aFuncPanels,"LJPnGeral(1,oExplorer,"+Str(nPanel)+","+Str(nRanking)+" , mv_par03, mv_par04,'"+STR0007+" x "+STR0019+"', '18','"+ cInforme1 +"','"+ cInforme2+"','"+ cInforme3+"','"+STR0051+" - "+STR0031+" ')")//"Filial ate?" ##"Produto ate?"##'Prod. c/ Diverg. de Inventário' ### 'Filial'
	        Aadd(aRelatorio,{4,STR0041+"\"+STR0025+"\"+STR0051+"\"+STR0031,"LJR70174(lCatProd,'"+STR0041+" - "+STR0025+" - "+STR0051+" - "+STR0031+"',2)"})//"Prevencao de Perdas\Estoque\Prod. c/ Diverg. de Inventário\Filial 
			IncProc()                                                                                 
            		
			If lCatProd //Somente se existir categoria sera exibidos os indicadores Categoria e Grupo
				oExplorer:AddItem(Padr(STR0032,150),"PMSDOC", Padr(StrZero(++nPanel,7),20))//"Categoria de Produtos"
				Aadd( oPanels, oExplorer:GetPanel(nPanel) )
				cInforme1 := ""
				cInforme2 := ""
				cInforme3 := ""
				Aadd(aFuncPanels,"LJPnGeral(1,oExplorer,"+Str(nPanel)+","+Str(nRanking)+" , mv_par11, mv_par12,'"+STR0031+" x "+STR0072+"', '19', '"+ cInforme1 +"','"+ cInforme2+"','"+ cInforme3+"','"+STR0051+" - "+STR0032+"')")//"Filial"##"Categoria"\'Produtos com divergência de inventário'\'Categoria de Produtos'
		        Aadd(aRelatorio,{4,STR0041+"\"+STR0025+"\"+STR0051+"\"+STR0032,"LJR70174(lCatProd,'"+STR0041+" - "+STR0025+" - "+STR0051+" - "+STR0032+"',3)"})//"Prevencao de Perdas\Estoque\Prod. c/ Diverg. de Inventário\Categoria de Produtos
				IncProc()                          
	
				oExplorer:AddItem(Padr(STR0033,150),"PMSDOC", Padr(StrZero(++nPanel,7),20))//"Grupo de Produtos"
				Aadd( oPanels, oExplorer:GetPanel(nPanel) )
				cInforme1 := ""
				cInforme2 := ""
				cInforme3 := ""
				Aadd(aFuncPanels,"LJPnGeral(1,oExplorer,"+Str(nPanel)+","+Str(nRanking)+" , mv_par13, mv_par14,'"+STR0016+" x "+STR0017+"', '20', '"+ cInforme1 +"','"+ cInforme2+"','"+ cInforme3+"','"+STR0051+" - "+STR0033+" ')") // 'Grupo de Produto de'\'Grupo de Produto ate' \'Prod. c/ Diverg. de Inventário'\' Grupo de Produtos '
		        Aadd(aRelatorio,{4,STR0041+"\"+STR0025+"\"+STR0051+"\"+STR0033,"LJR70174(lCatProd,'"+STR0041+" - "+STR0025+" - "+STR0051+" - "+STR0033+"',4)"})//"Prevencao de Perdas\Estoque\Prod. c/ Diverg. de Inventário\Grupo de Produtos
				IncProc()                          
	        Endif
	        
			oExplorer:AddItem(Padr(STR0034,150),"PMSDOC", Padr(StrZero(++nPanel,7),20))//"Produtos"
			Aadd( oPanels, oExplorer:GetPanel(nPanel) )
			cInforme1 := ""
			cInforme2 := ""
			cInforme3 := ""
			Aadd(aFuncPanels,"LJPnGeral(1,oExplorer,"+Str(nPanel)+","+Str(nRanking)+" , mv_par04, mv_par16,'"+STR0007+" x "+STR0019+"', '21','"+ cInforme1 +"','"+ cInforme2+"','"+ cInforme3+"','"+STR0051+" - "+STR0034+"')")//'Filial ate'\' Produto ate'\'Prod. c/ Diverg. de Inventário' / 'Produtos'
	        Aadd(aRelatorio,{4,STR0041+"\"+STR0025+"\"+STR0051+"\"+STR0034,"LJR70174(lCatProd,'"+STR0041+" - "+STR0025+" - "+STR0051+" - "+STR0034+"',5)"})//"Prevencao de Perdas\Estoque\Prod. c/ Diverg. de Inventário\Produtos
			IncProc()                          

			oExplorer:AddItem(Padr(STR0052,150),"PMSDOC", Padr(StrZero(++nPanel,7),20))//Armazem
			Aadd( oPanels, oExplorer:GetPanel(nPanel) )
			cInforme1 := ""
			cInforme2 := ""
			cInforme3 := ""
			Aadd(aFuncPanels,"LJPnGeral(1,oExplorer,"+Str(nPanel)+","+Str(nRanking)+" , mv_par19, mv_par20,'"+STR0019+" x "+STR0021+"', '22','"+ cInforme1 +"','"+ cInforme2+"','"+ cInforme3+"','"+STR0051+" - "+STR0052+"')")//'Produto ate '\'Armazem ate'/'Prod. c/ Diverg. de Inventário'\ 'Armazem'
	        Aadd(aRelatorio,{4,STR0041+"\"+STR0025+"\"+STR0051+"\"+STR0052,"LJR70174(lCatProd,'"+STR0041+" - "+STR0025+" - "+STR0051+" - "+STR0052+"',6)"})//"Prevencao de Perdas\Estoque\Prod. c/ Diverg. de Inventário\Armazem
			IncProc()
            
   		oExplorer:EndTree()

		oExplorer:AddTree(Padr(STR0053,150),"FOLDER13",,Padr(StrZero(++nPanel,7),20))//Quebra Operacional 
		Aadd( oPanels, oExplorer:GetPanel(nPanel) ) 
		
		IncProc()
			If lGPFilial //Somente se existir Grupo de empresa
				oExplorer:AddItem(Padr(STR0030,150),"PMSDOC", Padr(StrZero(++nPanel,7),20))//"Grupo de Filial"
				Aadd( oPanels, oExplorer:GetPanel(nPanel) ) 
				cInforme1 := ""
				cInforme2 := ""
				cInforme3 := ""
				Aadd(aFuncPanels,"LJPnGeral(1,oExplorer,"+Str(nPanel)+","+Str(nRanking)+" , mv_par01, mv_par02,'"+STR0004+" x "+STR0005+"', '23','"+ cInforme1 +"','"+ cInforme2+"','"+ cInforme3+"','"+STR0053+" - "+STR0030+"')")//'Grupo de Filial de'/'Grupo de filial ate' //'Quebra Operacional - Grupo de Filial'
			    Aadd(aRelatorio,{5,STR0041+"\"+STR0025+"\"+STR0053+"\"+STR0030,"LJR70175(lCatProd,'"+STR0041+" - "+STR0025+" - "+STR0053+" - "+STR0030+"',0,aGPFilial)"})//"Prevencao de Perdas\Estoque\Quebra Operacional\Grupo de Filial
				IncProc()
			Endif 
						
			oExplorer:AddItem(Padr(STR0031,150),"PMSDOC", Padr(StrZero(++nPanel,7),20))//"Filial"
			Aadd( oPanels, oExplorer:GetPanel(nPanel) ) 
			cInforme1 := ""
			cInforme2 := ""
			cInforme3 := ""
			Aadd(aFuncPanels,"LJPnGeral(1,oExplorer,"+Str(nPanel)+","+Str(nRanking)+" , mv_par03, mv_par04,'"+STR0007+" x "+STR0019+"', '24', '"+ cInforme1 +"','"+ cInforme2+"','"+ cInforme3+"','"+STR0053+" - "+STR0031+"')")//Filial ate x Produto ate//'Quebra Operacional - Filial'
		    Aadd(aRelatorio,{5,STR0041+"\"+STR0025+"\"+STR0053+"\"+STR0031,"LJR70175(lCatProd,'"+STR0041+" - "+STR0025+" - "+STR0053+" - "+STR0031+"',2)"})//"Prevencao de Perdas\Estoque\Quebra Operacional\Filial
			IncProc()
            		
			If lCatProd //Somente se existir categoria sera exibidos os indicadores Categoria e Grupo
				oExplorer:AddItem(Padr(STR0032,150),"PMSDOC", Padr(StrZero(++nPanel,7),20))//"Categoria de Produtos"
				Aadd( oPanels, oExplorer:GetPanel(nPanel) )
				cInforme1 := ""
				cInforme2 := ""
				cInforme3 := ""
				Aadd(aFuncPanels,"LJPnGeral(1,oExplorer,"+Str(nPanel)+","+Str(nRanking)+" , mv_par11, mv_par12,'"+STR0031+" x "+STR0072+"', '25', '"+ cInforme1 +"','"+ cInforme2+"','"+ cInforme3+"','"+STR0053+" - "+STR0032+"')")//Filial x Categoria//'Quebra Operacional - Categoria de Produtos'
			    Aadd(aRelatorio,{5,STR0041+"\"+STR0025+"\"+STR0053+"\"+STR0032,"LJR70175(lCatProd,'"+STR0041+" - "+STR0025+" - "+STR0053+" - "+STR0032+"',3)"})//"Prevencao de Perdas\Estoque\Quebra Operacional\Categoria de Produtos
				IncProc()                          
	
				oExplorer:AddItem(Padr(STR0033,150),"PMSDOC", Padr(StrZero(++nPanel,7),20))//"Grupo de Produtos"
				Aadd( oPanels, oExplorer:GetPanel(nPanel) )
				cInforme1 := ""
				cInforme2 := ""
				cInforme3 := ""
				Aadd(aFuncPanels,"LJPnGeral(1,oExplorer,"+Str(nPanel)+","+Str(nRanking)+" , mv_par13, mv_par14,'"+STR0016+" x "+STR0017+"', '26','"+ cInforme1 +"','"+ cInforme2+"','"+ cInforme3+"','"+STR0053+" - "+STR0033+"')")//Grupo de Produto de x Grupo de Produto ate//'Quebra Operacional - Grupo de Produtos'
			    Aadd(aRelatorio,{5,STR0041+"\"+STR0025+"\"+STR0053+"\"+STR0033,"LJR70175(lCatProd,'"+STR0041+" - "+STR0025+" - "+STR0053+" - "+STR0033+"',4)"})//"Prevencao de Perdas\Estoque\Quebra Operacional\Grupo de Produtos
				IncProc()                          
	        Endif
	        
			oExplorer:AddItem(Padr(STR0034,150),"PMSDOC", Padr(StrZero(++nPanel,7),20))//Produtos
			Aadd( oPanels, oExplorer:GetPanel(nPanel) )
			cInforme1 := ""
			cInforme2 := ""
			cInforme3 := ""
			Aadd(aFuncPanels,"LJPnGeral(1,oExplorer,"+Str(nPanel)+","+Str(nRanking)+" , mv_par04, mv_par16,'"+STR0007+" x "+STR0019+"', '27', '"+ cInforme1 +"','"+ cInforme2+"','"+ cInforme3+"','"+STR0053+" - "+STR0034+"')")//Filial ate x Produto ate///'Quebra Operacional - Produtos'
		    Aadd(aRelatorio,{5,STR0041+"\"+STR0025+"\"+STR0053+"\"+STR0034,"LJR70175(lCatProd,'"+STR0041+" - "+STR0025+" - "+STR0053+" - "+STR0034+"',5)"})//"Prevencao de Perdas\Estoque\Quebra Operacional\Produtos
			IncProc()                          

			oExplorer:AddItem(Padr(STR0061,150),"PMSDOC", Padr(StrZero(++nPanel,7),20))//Motivo
			Aadd( oPanels, oExplorer:GetPanel(nPanel) )
			cInforme1 := ""
			cInforme2 := ""
			cInforme3 := ""
			Aadd(aFuncPanels,"LJPnGeral(1,oExplorer,"+Str(nPanel)+","+Str(nRanking)+" , mv_par19, mv_par20,'"+STR0019+" x "+STR0050+"', '28', '"+ cInforme1 +"','"+ cInforme2+"','"+ cInforme3+"','"+STR0053+" - "+STR0048+"')")//Produto ate x Motivo ate//'Quebra Operacional - Motivo'
		    Aadd(aRelatorio,{5,STR0041+"\"+STR0025+"\"+STR0053+"\"+STR0061,"LJR70175(lCatProd,'"+STR0041+" - "+STR0025+" - "+STR0053+" - "+STR0061+"',6)"})//"Prevencao de Perdas\Estoque\Quebra Operacional\Motivo
			IncProc()
      
      		oExplorer:AddItem(Padr(STR0062,150),"PMSDOC", Padr(StrZero(++nPanel,7),20))//Origem
			Aadd( oPanels, oExplorer:GetPanel(nPanel) )
			cInforme1 := ""
			cInforme2 := ""
			cInforme3 := ""
			Aadd(aFuncPanels,"LJPnGeral(1,oExplorer,"+Str(nPanel)+","+Str(nRanking)+" , mv_par19, mv_par20,'"+STR0019+" x "+STR0059+"', '29','"+ cInforme1 +"','"+ cInforme2+"','"+ cInforme3+"','"+STR0053+" - "+STR0062+"')")//Produto ate x Origem ate//'Quebra Operacional - Origem'
		    Aadd(aRelatorio,{5,STR0041+"\"+STR0025+"\"+STR0053+"\"+STR0062,"LJR70175(lCatProd,'"+STR0041+" - "+STR0025+" - "+STR0053+" - "+STR0062+"',7)"})//"Prevencao de Perdas\Estoque\Quebra Operacional\Origem
			IncProc()
      
      		oExplorer:AddItem(Padr(STR0063,150),"PMSDOC", Padr(StrZero(++nPanel,7),20))//Ocorrencia
			Aadd( oPanels, oExplorer:GetPanel(nPanel) )
			cInforme1 := ""
			cInforme2 := ""
			cInforme3 := ""
			Aadd(aFuncPanels,"LJPnGeral(1,oExplorer,"+Str(nPanel)+","+Str(nRanking)+" , mv_par19, mv_par20,'"+STR0019+" x "+STR0060+"', '30', '"+ cInforme1 +"','"+ cInforme2+"','"+ cInforme3+"','"+STR0053+" - "+STR0063+"')")//Produto ate x Ocorrencia ate//'Quebra Operacional - Ocorrência'
		    Aadd(aRelatorio,{5,STR0041+"\"+STR0025+"\"+STR0053+"\"+STR0063,"LJR70175(lCatProd,'"+STR0041+" - "+STR0025+" - "+STR0053+" - "+STR0063+"',8)"})//"Prevencao de Perdas\Estoque\Quebra Operacional\Ocorrencia
			IncProc()
                        
   		oExplorer:EndTree()
           
	oExplorer:EndTree()
EndIf

If "2" $ AllTrim(mv_par26)
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Criacao do 1. Grupo        - Nivel 1 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oExplorer:AddTree(Padr(STR0066,150),"BMPUSER",,Padr(StrZero(++nPanel,7),20))//Financeira
	Aadd( oPanels, 	oExplorer:GetPanel(nPanel) ) 

	IncProc()
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Criacao do 1. Sub-Grupo    - Nivel 2 ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		oExplorer:AddTree(Padr(STR0067,150),"FOLDER13",,Padr(StrZero(++nPanel,7),20)) //Quebra Conf.Caixa
		Aadd( oPanels,oExplorer:GetPanel(nPanel) ) 
		
 		IncProc()

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Criacao dos 	Itens         - Nivel 3 ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ   
			If lGPFilial //Somente se existir Grupo de empresa
				oExplorer:AddItem(Padr(STR0030,150),"PMSDOC", Padr(StrZero(++nPanel,7),20))//"Grupo de Filial"
				Aadd( oPanels, oExplorer:GetPanel(nPanel) ) 
				cInforme1 := ""
				cInforme2 := ""
				cInforme3 := ""
				Aadd(aFuncPanels,"LJPnGeral(2,oExplorer,"+Str(nPanel)+","+Str(nRanking)+" , mv_par01, mv_par02, '"+STR0004+" x "+STR0005+"', '31','"+ cInforme1 +"','"+ cInforme2+"','"+ cInforme3+"','"+STR0067+" - "+STR0030+"' )") //Grupo de Filial de x Grupo de filial ate//'Quebra Conf.Caixa - Grupo de Filial'
			    Aadd(aRelatorio,{6,STR0041+"\"+STR0066+"\"+STR0067+"\"+STR0030,"LJR70176('"+STR0041+" - "+STR0066+" - "+STR0067+" - "+STR0030+"',0,aGPFilial)"})//"Prevencao de Perdas\Financeira\Quebra Conf.Caixa\Grupo de Filial
				IncProc()
			Endif
			
			oExplorer:AddItem(Padr(STR0031,150),"PMSDOC", Padr(StrZero(++nPanel,7),20))//"Filial"
			Aadd( oPanels, oExplorer:GetPanel(nPanel) ) 
			cInforme1 := ""
			cInforme2 := ""
			cInforme3 := ""
			Aadd(aFuncPanels,"LJPnGeral(2,oExplorer,"+Str(nPanel)+","+Str(nRanking)+" , mv_par03, mv_par04, '"+STR0006+" x "+STR0007+"', '32', '"+ cInforme1 +"','"+ cInforme2+"','"+ cInforme3+"','"+STR0067+" - "+STR0031+"')")//Filial de x Filial ate  //'Quebra Conf.Caixa - Filial'
			Aadd(aRelatorio,{6,STR0041+"\"+STR0066+"\"+STR0067+"\"+STR0031,"LJR70176('"+STR0041+" - "+STR0066+" - "+STR0067+" - "+STR0031+"',2)"})//"Prevencao de Perdas\Financeira\Quebra Operacional\Filial
			IncProc()

			
			oExplorer:AddItem(Padr(STR0068,150),"PMSDOC", Padr(StrZero(++nPanel,7),20))//"Caixa"
			Aadd( oPanels, oExplorer:GetPanel(nPanel) )
			cInforme1 := ""
			cInforme2 := ""
			cInforme3 := ""
			Aadd(aFuncPanels,"LJPnGeral(2,oExplorer,"+Str(nPanel)+","+Str(nRanking)+" , mv_par05, mv_par06, '"+STR0007+" x "+STR0009+"', '33','"+ cInforme1 +"','"+ cInforme2+"','"+ cInforme3+"','"+STR0067+" - "+STR0068+"')")//Filial ate x Caixa ate//'Quebra Conf.Caixa - Caixa'
			Aadd(aRelatorio,{6,STR0041+"\"+STR0066+"\"+STR0067+"\"+STR0068,"LJR70176('"+STR0041+" - "+STR0066+" - "+STR0067+" - "+STR0068+"',3)"})//"Prevencao de Perdas\Financeira\Quebra Operacional\Caixa
			IncProc()                          
			
		oExplorer:EndTree()
		
		oExplorer:AddTree(Padr(STR0069,150),"FOLDER13",,Padr(StrZero(++nPanel,7),20)) //Cheques devolvidos
		Aadd( oPanels,oExplorer:GetPanel(nPanel) ) 
		
 		IncProc()
	
			If lGPFilial 
				oExplorer:AddItem(Padr(STR0030,150),"PMSDOC", Padr(StrZero(++nPanel,7),20))//"Grupo de Filial"
				Aadd( oPanels, oExplorer:GetPanel(nPanel) ) 
				cInforme1 := ""
				cInforme2 := ""
				cInforme3 := ""
				Aadd(aFuncPanels,"LJPnGeral(2,oExplorer,"+Str(nPanel)+","+Str(nRanking)+" , mv_par01, MV_PAR10, '"+STR0004+" x "+STR0005+"', '34','"+ cInforme1 +"','"+ cInforme2+"','"+ cInforme3+"','"+STR0069+" - "+STR0030+"' )")//Grupo de Filial de x Grupo de filial ate//'Cheques devolvidos - Grupo de Filial'
				Aadd(aRelatorio,{7,STR0041+"\"+STR0066+"\"+STR0069+"\"+STR0030,"LJR70177('"+STR0041+" - "+STR0066+" - "+STR0069+" - "+STR0030+"',0,aGPFilial)"})//"Prevencao de Perdas\Financeira\Cheques devolvidos\grupo de filial
				IncProc()
			Endif
			
			oExplorer:AddItem(Padr(STR0031,150),"PMSDOC", Padr(StrZero(++nPanel,7),20))//"Filial"
			Aadd( oPanels, oExplorer:GetPanel(nPanel) ) 
			cInforme1 := ""
			cInforme2 := ""
			cInforme3 := ""
			Aadd(aFuncPanels,"LJPnGeral(2,oExplorer,"+Str(nPanel)+","+Str(nRanking)+" , mv_par03, MV_PAR10, '"+STR0006+" x "+STR0007+"', '35', '"+ cInforme1 +"','"+ cInforme2+"','"+ cInforme3+"','"+STR0069+" - "+STR0031+"')")//Filial de x Filial ate//'Cheques devolvidos - Filial'
			Aadd(aRelatorio,{7,STR0041+"\"+STR0066+"\"+STR0069+"\"+STR0031,"LJR70177('"+STR0041+" - "+STR0066+" - "+STR0069+" - "+STR0031+"',2)"})//"Prevencao de Perdas\Financeira\Cheques devolvidos\Filial
			IncProc()

		oExplorer:EndTree()
    

		oExplorer:AddTree(Padr(STR0070,150),"FOLDER13",,Padr(StrZero(++nPanel,7),20)) //Titulos em atraso
		Aadd( oPanels,oExplorer:GetPanel(nPanel) ) 
		
 		IncProc()

    		If lGPFilial 
				oExplorer:AddItem(Padr(STR0030,150),"PMSDOC", Padr(StrZero(++nPanel,7),20))//"Grupo de Filial"
				Aadd( oPanels, oExplorer:GetPanel(nPanel) ) 
				cInforme1 := ""
				cInforme2 := ""
				cInforme3 := ""
				Aadd(aFuncPanels,"LJPnGeral(2,oExplorer,"+Str(nPanel)+","+Str(nRanking)+" , mv_par01, MV_PAR06, '"+STR0004+" x "+STR0005+"', '36','"+ cInforme1 +"','"+ cInforme2+"','"+ cInforme3+"','"+STR0070+" - "+STR0030+"' )") //Grupo de Filial de x Grupo de filial ate//'Titulos em atraso - Grupo de Filial'
			    Aadd(aRelatorio,{8,STR0041+"\"+STR0066+"\"+STR0070+"\"+STR0030,"LJR70178('"+STR0041+" - "+STR0066+" - "+STR0070+" - "+STR0030+"',0,aGPFilial)"})//"Prevencao de Perdas\Financeira\Titulos em atraso\Grupo de Filial
				IncProc()
			Endif
			
			oExplorer:AddItem(Padr(STR0031,150),"PMSDOC", Padr(StrZero(++nPanel,7),20))//"Filial"
			Aadd( oPanels, oExplorer:GetPanel(nPanel) ) 
			cInforme1 := ""
			cInforme2 := ""
			cInforme3 := ""
			Aadd(aFuncPanels,"LJPnGeral(2,oExplorer,"+Str(nPanel)+","+Str(nRanking)+" , mv_par03, mv_par06, '"+STR0006+" x "+STR0007+"', '37', '"+ cInforme1 +"','"+ cInforme2+"','"+ cInforme3+"','"+STR0070+" - "+STR0031+"')")//Filial de x Filial ate //'Titulos em atraso - Filial'
		    Aadd(aRelatorio,{8,STR0041+"\"+STR0066+"\"+STR0070+"\"+STR0031,"LJR70178('"+STR0041+" - "+STR0066+" - "+STR0070+" - "+STR0031+"',2)"})//"Prevencao de Perdas\Financeira\Titulos em atraso\Filial
			IncProc()

			oExplorer:AddItem(Padr(STR0065,150),"PMSDOC", Padr(StrZero(++nPanel,7),20))//"Cliente"                                                                                                                                  
			Aadd( oPanels, oExplorer:GetPanel(nPanel) ) 
			cInforme1 := ""
			cInforme2 := ""
			cInforme3 := ""
			Aadd(aFuncPanels,"LJPnGeral(2,oExplorer,"+Str(nPanel)+","+Str(nRanking)+" , mv_par03, mv_par06, '"+STR0006+" x "+STR0007+"', '38', '"+ cInforme1 +"','"+ cInforme2+"','"+ cInforme3+"','"+STR0070+" - "+STR0065+"')")//Filial de x Filial ate//'Titulos em atraso - Cliente'
		    Aadd(aRelatorio,{8,STR0041+"\"+STR0066+"\"+STR0070+"\"+STR0065,"LJR70178('"+STR0041+" - "+STR0066+" - "+STR0070+" - "+STR0065+"',3)"})//"Prevencao de Perdas\Financeira\Titulos em atraso\Cliente
			IncProc()

		oExplorer:EndTree()

	oExplorer:EndTree()
EndIf
If "3" $ AllTrim(mv_par26)
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Criacao do 3. Grupo        - Nivel 1 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oExplorer:AddTree(Padr(STR0027,150),"BMPUSER",,Padr(StrZero(++nPanel,7),20)) //"Comercial"
	Aadd( oPanels, 	oExplorer:GetPanel(nPanel) )
	
	IncProc()
		
		If AliasInDic("MFL")  // Se existir tabela MFL - Consulta de Preco pelo PDV
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Criacao do 3. Sub-Grupo    - Nivel 2 ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			oExplorer:AddTree(Padr(STR0073,150),"FOLDER13",,Padr(StrZero(++nPanel,7),20)) //"Qtde. Consulta Preços"
			Aadd( oPanels,oExplorer:GetPanel(nPanel) )
			
	 		IncProc()
				
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Criacao dos Itens          - Nivel 3 ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ   
				If lGPFilial //Somente se existir Grupo de Filial
					oExplorer:AddItem(Padr(STR0030,150),"PMSDOC", Padr(StrZero(++nPanel,7),20))//"Grupo de Filial"
					Aadd( oPanels, oExplorer:GetPanel(nPanel) ) 
					cInforme1 := ""
					cInforme2 := ""
					cInforme3 := ""
					Aadd(aFuncPanels,"LJPnGeral(3,oExplorer,"+Str(nPanel)+","+Str(nRanking)+" , mv_par01, mv_par02, '"+STR0004+" x "+STR0005+"', '301', '"+ cInforme1 +"','"+ cInforme2+"','"+ cInforme3+"','"+STR0074+" - "+STR0030+"')")//Grupo de Filial de x Grupo de filial ate//'Quantidade de Consulta de Preços - Grupo de Filial'
					Aadd(aRelatorio,{1,STR0041+"\"+STR0027+"\"+STR0073+"\"+STR0030,"LR7017311('"+STR0030+"',lGPFilial,1)"})//"Prevencao de Perdas\Comercial\Qtde. Consulta Preços\Grupo de Filial"
					IncProc()
				Endif
				
				oExplorer:AddItem(Padr(STR0031,150),"PMSDOC", Padr(StrZero(++nPanel,7),20))//"Filial"
				Aadd( oPanels, oExplorer:GetPanel(nPanel) )
				cInforme1 := ""
				cInforme2 := ""
				cInforme3 := ""
				Aadd(aFuncPanels,"LJPnGeral(3,oExplorer,"+Str(nPanel)+","+Str(nRanking)+" , mv_par03, mv_par04, '"+STR0006+" x "+STR0007+"', '302', '"+ cInforme1 +"','"+ cInforme2+"','"+ cInforme3+"','"+STR0074+" - "+STR0031+"')")//Filial de x Filial ate//'Quantidade de Consulta de Preços - Filial'
				Aadd(aRelatorio,{2,STR0041+"\"+STR0027+"\"+STR0073+"\"+STR0031,"LR7017311('"+STR0031+"',lGPFilial,2)"})//"Prevencao de Perdas\Comercial\Qtde. Consulta Preços\Filial"
				IncProc()
				
				oExplorer:AddItem(Padr(STR0068,150),"PMSDOC", Padr(StrZero(++nPanel,7),20))//"Caixa"
				Aadd( oPanels, oExplorer:GetPanel(nPanel) )
				cInforme1 := ""
				cInforme2 := ""
				cInforme3 := ""
				Aadd(aFuncPanels,"LJPnGeral(3,oExplorer,"+Str(nPanel)+","+Str(nRanking)+" , mv_par05, mv_par06, '"+STR0008+" x "+STR0009+"', '303', '"+ cInforme1 +"','"+ cInforme2+"','"+ cInforme3+"','"+STR0074+" - "+STR0068+"')")//Caixa de x Caixa ate//'Quantidade de Consulta de Preços - Caixa'
				Aadd(aRelatorio,{3,STR0041+"\"+STR0027+"\"+STR0073+"\"+STR0068,"LR7017311('"+STR0068+"',lGPFilial,3)"})//"Prevencao de Perdas\Comercial\Qtde. Consulta Preços\Caixa"
				IncProc()
				
				oExplorer:AddItem(Padr(STR0075,150),"PMSDOC", Padr(StrZero(++nPanel,7),20))//"PDV"
				Aadd( oPanels, oExplorer:GetPanel(nPanel) )
				cInforme1 := ""
				cInforme2 := ""
				cInforme3 := ""
				Aadd(aFuncPanels,"LJPnGeral(3,oExplorer,"+Str(nPanel)+","+Str(nRanking)+" , mv_par07, mv_par08, '"+STR0010+" x "+STR0011+"', '304', '"+ cInforme1 +"','"+ cInforme2+"','"+ cInforme3+"','"+STR0074+" - "+STR0075+"')")//PDV de x PDV ate //'Quantidade de Consulta de Preços - PDV'
				Aadd(aRelatorio,{4,STR0041+"\"+STR0027+"\"+STR0073+"\"+STR0075,"LR7017311('"+STR0075+"',lGPFilial,4)"})//"Prevencao de Perdas\Comercial\Qtde. Consulta Preços\PDV"
				IncProc()
				
			oExplorer:EndTree()
		EndIf
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Criacao do 3. Sub-Grupo    - Nivel 2 ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		
		oExplorer:AddTree(Padr(STR0076,150),"FOLDER13",,Padr(StrZero(++nPanel,7),20))//"Cancelamento Cupom"
		Aadd( oPanels, oExplorer:GetPanel(nPanel) ) 
		
		IncProc()
			If lGPFilial //Somente se existir Grupo de empresa
				oExplorer:AddItem(Padr(STR0030,150),"PMSDOC", Padr(StrZero(++nPanel,7),20))//"Grupo de Filial"
				Aadd( oPanels, oExplorer:GetPanel(nPanel) ) 
				cInforme1 := ""
				cInforme2 := ""
				cInforme3 := ""
				Aadd(aFuncPanels,"LJPnGeral(3,oExplorer,"+Str(nPanel)+","+Str(nRanking)+" , mv_par01, mv_par02, '"+STR0004+" x "+STR0005+"', '305', '"+ cInforme1 +"','"+ cInforme2+"','"+ cInforme3+"','"+STR0076+" - "+STR0030+"')")//Grupo de Filial de x Grupo de filial ate//Cancelamento Cupom - Grupo de Filial
				Aadd(aRelatorio,{1,STR0041+"\"+STR0027+"\"+STR0076+"\"+STR0030,"LR7017321('"+STR0030+"',lGPFilial,1)"})//"Prevencao de Perdas\Comercial\Cancelamento Cupom\Grupo de Filial"
				IncProc()
			Endif 
			
			oExplorer:AddItem(Padr(STR0031,150),"PMSDOC", Padr(StrZero(++nPanel,7),20))//"Filial"
			Aadd( oPanels, oExplorer:GetPanel(nPanel) ) 
			cInforme1 := ""
			cInforme2 := ""
			cInforme3 := ""
			Aadd(aFuncPanels,"LJPnGeral(3,oExplorer,"+Str(nPanel)+","+Str(nRanking)+" , mv_par03, mv_par04 ,'"+STR0006+" x "+STR0007+"', '306', '"+ cInforme1 +"','"+ cInforme2+"','"+ cInforme3+"','"+STR0076+" - "+STR0031+"')")//Filial de x Filial ate// Cancelamento Cupom - Filial
			Aadd(aRelatorio,{2,STR0041+"\"+STR0027+"\"+STR0076+"\"+STR0031,"LR7017321('"+STR0031+"',lGPFilial,2)"})//"Prevencao de Perdas\Comercial\Cancelamento Cupom\Filial"
			IncProc()
            
			oExplorer:AddItem(Padr(STR0068,150),"PMSDOC", Padr(StrZero(++nPanel,7),20))//"Caixa"
			Aadd( oPanels, oExplorer:GetPanel(nPanel) )
			cInforme1 := ""
			cInforme2 := ""
			cInforme3 := ""
			Aadd(aFuncPanels,"LJPnGeral(3,oExplorer,"+Str(nPanel)+","+Str(nRanking)+" , mv_par05, mv_par06, '"+STR0008+" x "+STR0009+"', '307', '"+ cInforme1 +"','"+ cInforme2+"','"+ cInforme3+"','"+STR0076+" - "+STR0068+"')")//Caixa de x Caixa ate//Cancelamento Cupom - Caixa
			Aadd(aRelatorio,{3,STR0041+"\"+STR0027+"\"+STR0076+"\"+STR0068,"LR7017321('"+STR0068+"',lGPFilial,3)"})//"Prevencao de Perdas\Comercial\Cancelamento Cupom\Caixa"
			IncProc()
			
			oExplorer:AddItem(Padr(STR0075,150),"PMSDOC", Padr(StrZero(++nPanel,7),20))//"PDV"
			Aadd( oPanels, oExplorer:GetPanel(nPanel) )
			cInforme1 := ""
			cInforme2 := ""
			cInforme3 := ""
			Aadd(aFuncPanels,"LJPnGeral(3,oExplorer,"+Str(nPanel)+","+Str(nRanking)+" , mv_par07, mv_par08, '"+STR0010+" x "+STR0011+"', '308', '"+ cInforme1 +"','"+ cInforme2+"','"+ cInforme3+"','"+STR0076+" - "+STR0075+"')")//PDV de x PDV ate//Cancelamento Cupom - PDV
			Aadd(aRelatorio,{4,STR0041+"\"+STR0027+"\"+STR0076+"\"+STR0075,"LR7017321('"+STR0075+"',lGPFilial,4)"})//"Prevencao de Perdas\Comercial\Cancelamento Cupom\PDV"
			IncProc()
   			
		oExplorer:EndTree()
        
       	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Criacao do 3. Sub-Grupo    - Nivel 2 ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
        
	   	oExplorer:AddTree(Padr(STR0078,150),"FOLDER13",,Padr(StrZero(++nPanel,7),20))//"Entrada de Troco"
		Aadd( oPanels, oExplorer:GetPanel(nPanel) ) 
		
		IncProc()
			If lGPFilial //Somente se existir Grupo de empresa
				oExplorer:AddItem(Padr(STR0030,150),"PMSDOC", Padr(StrZero(++nPanel,7),20))//"Grupo de Filial"
				Aadd( oPanels, oExplorer:GetPanel(nPanel) ) 
				cInforme1 := ""
				cInforme2 := ""
				cInforme3 := ""
				Aadd(aFuncPanels,"LJPnGeral(3,oExplorer,"+Str(nPanel)+","+Str(nRanking)+" , mv_par01, mv_par02,'"+STR0004+" x "+STR0005+" ', '309', '"+ cInforme1 +"','"+ cInforme2+"','"+ cInforme3+"','"+STR0078+" - "+STR0030+"')")//Grupo de Filial de x Grupo de filial ate//'Entrada de Troco - Grupo de Filial'
				Aadd(aRelatorio,{1,STR0041+"\"+STR0027+"\"+STR0078+"\"+STR0030,"LR7017331('"+STR0030+"',lGPFilial,1)"})//"Prevencao de Perdas\Comercial\Entrada de Troco\Grupo de Filial"
				IncProc()
			Endif 
			
			oExplorer:AddItem(Padr(STR0031,150),"PMSDOC", Padr(StrZero(++nPanel,7),20))//"Filial"
			Aadd( oPanels, oExplorer:GetPanel(nPanel) ) 
			cInforme1 := ""
			cInforme2 := ""
			cInforme3 := ""
			Aadd(aFuncPanels,"LJPnGeral(3,oExplorer,"+Str(nPanel)+","+Str(nRanking)+" , mv_par04, mv_par16,'"+STR0007+" x "+STR0019+"', '310', '"+ cInforme1 +"','"+ cInforme2+"','"+ cInforme3+"','"+STR0078+" - "+STR0031+"')")//Filial ate x Produto ate //'Entrada de Troco - Filial'
			Aadd(aRelatorio,{2,STR0041+"\"+STR0027+"\"+STR0078+"\"+STR0031,"LR7017331('"+STR0031+"',lGPFilial,2)"})//"Prevencao de Perdas\Comercial\Entrada de Troco\Filial"
			IncProc()
            
			oExplorer:AddItem(Padr(STR0068,150),"PMSDOC", Padr(StrZero(++nPanel,7),20))//"Caixa"
			Aadd( oPanels, oExplorer:GetPanel(nPanel) )
			cInforme1 := ""
			cInforme2 := ""
			cInforme3 := ""
			Aadd(aFuncPanels,"LJPnGeral(3,oExplorer,"+Str(nPanel)+","+Str(nRanking)+" , mv_par05, mv_par06, '"+STR0008+" x "+STR0009+"', '311', '"+ cInforme1 +"','"+ cInforme2+"','"+ cInforme3+"','"+STR0078+" - "+STR0068+"')")//Caixa de x Caixa ate//'Entrada de Troco - Caixa'
			Aadd(aRelatorio,{3,STR0041+"\"+STR0027+"\"+STR0078+"\"+STR0068,"LR7017331('"+STR0068+"',lGPFilial,3)"})//"Prevencao de Perdas\Comercial\Entrada de Troco\Caixa"
			IncProc()
			
			oExplorer:AddItem(Padr(STR0075,150),"PMSDOC", Padr(StrZero(++nPanel,7),20))//"PDV"
			Aadd( oPanels, oExplorer:GetPanel(nPanel) )
			cInforme1 := ""
			cInforme2 := ""
			cInforme3 := ""
			Aadd(aFuncPanels,"LJPnGeral(3,oExplorer,"+Str(nPanel)+","+Str(nRanking)+" , mv_par07, mv_par08, '"+STR0010+" x "+STR0011+"', '312', '"+ cInforme1 +"','"+ cInforme2+"','"+ cInforme3+"','"+STR0078+" - "+STR0075+"')")//PDV de x PDV ate//'Entrada de Troco - PDV'
			Aadd(aRelatorio,{4,STR0041+"\"+STR0027+"\"+STR0078+"\"+STR0075,"LR7017331('"+STR0075+"',lGPFilial,4)"})//"Prevencao de Perdas\Comercial\Entrada de Troco\PDV"
			IncProc()
			
		oExplorer:EndTree()
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Criacao do 3. Sub-Grupo    - Nivel 2 ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
        
		oExplorer:AddTree(Padr(STR0079,150),"FOLDER13",,Padr(StrZero(++nPanel,7),20))//"Sangria"
		Aadd( oPanels, oExplorer:GetPanel(nPanel) ) 
		
		IncProc()
			If lGPFilial //Somente se existir Grupo de empresa
				oExplorer:AddItem(Padr(STR0030,150),"PMSDOC", Padr(StrZero(++nPanel,7),20))//"Grupo de Filial"
				Aadd( oPanels, oExplorer:GetPanel(nPanel) ) 
				cInforme1 := ""
				cInforme2 := ""
				cInforme3 := ""
				Aadd(aFuncPanels,"LJPnGeral(3,oExplorer,"+Str(nPanel)+","+Str(nRanking)+" , mv_par01, mv_par02,'"+STR0004+" x "+STR0005+" ', '313', '"+ cInforme1 +"','"+ cInforme2+"','"+ cInforme3+"','"+STR0079+" - "+STR0030+"')")//Grupo de Filial de x Grupo de filial ate//'Sangria - Grupo de Filial'
				Aadd(aRelatorio,{1,STR0041+"\"+STR0027+"\"+STR0079+"\"+STR0030,"LR7017341('"+STR0030+"',lGPFilial,1)"})//"Prevencao de Perdas\Comercial\Sangria\Grupo de Filial"
				IncProc()
			Endif 
			
			oExplorer:AddItem(Padr(STR0031,150),"PMSDOC", Padr(StrZero(++nPanel,7),20))//"Filial"
			Aadd( oPanels, oExplorer:GetPanel(nPanel) ) 
			cInforme1 := ""
			cInforme2 := ""
			cInforme3 := ""
			Aadd(aFuncPanels,"LJPnGeral(3,oExplorer,"+Str(nPanel)+","+Str(nRanking)+" , mv_par04, mv_par16,'"+STR0007+" x "+STR0019+"', '314', '"+ cInforme1 +"','"+ cInforme2+"','"+ cInforme3+"','"+STR0079+" - "+STR0031+"')")//Filial ate x Produto ate//'Sangria - Filial'
			Aadd(aRelatorio,{2,STR0041+"\"+STR0027+"\"+STR0079+"\"+STR0031,"LR7017341('"+STR0031+"',lGPFilial,2)"})//"Prevencao de Perdas\Comercial\Sangria\Filial"
			IncProc()
            
			oExplorer:AddItem(Padr(STR0068,150),"PMSDOC", Padr(StrZero(++nPanel,7),20))//"Caixa"
			Aadd( oPanels, oExplorer:GetPanel(nPanel) )
			cInforme1 := ""
			cInforme2 := ""
			cInforme3 := ""
			Aadd(aFuncPanels,"LJPnGeral(3,oExplorer,"+Str(nPanel)+","+Str(nRanking)+" , mv_par05, mv_par06, '"+STR0008+" x "+STR0009+"', '315', '"+ cInforme1 +"','"+ cInforme2+"','"+ cInforme3+"','"+STR0079+" - "+STR0068+"')")//Caixa de x Caixa ate//'Sangria - Caixa'
			Aadd(aRelatorio,{3,STR0041+"\"+STR0027+"\"+STR0079+"\"+STR0068,"LR7017341('"+STR0068+"',lGPFilial,3)"})//"Prevencao de Perdas\Comercial\Sangria\Caixa"
			IncProc()
			
			oExplorer:AddItem(Padr(STR0075,150),"PMSDOC", Padr(StrZero(++nPanel,7),20))//"PDV"
			Aadd( oPanels, oExplorer:GetPanel(nPanel) )
			cInforme1 := ""
			cInforme2 := ""
			cInforme3 := ""
			Aadd(aFuncPanels,"LJPnGeral(3,oExplorer,"+Str(nPanel)+","+Str(nRanking)+" , mv_par07, mv_par08, '"+STR0010+" x "+STR0011+"', '316', '"+ cInforme1 +"','"+ cInforme2+"','"+ cInforme3+"','"+STR0079+" - "+STR0075+"')")//PDV de x PDV ate //'Sangria - PDV'
			Aadd(aRelatorio,{4,STR0041+"\"+STR0027+"\"+STR0079+"\"+STR0075,"LR7017341('"+STR0075+"',lGPFilial,4)"})//"Prevencao de Perdas\Comercial\Sangria\PDV"
			IncProc()
			
		oExplorer:EndTree()
		
	oExplorer:EndTree()
EndIf

If "4" $ AllTrim(mv_par26)
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Criacao do 3. Grupo        - Nivel 1 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oExplorer:AddTree(Padr(STR0028,150),"BMPUSER",,Padr(StrZero(++nPanel,7),20)) //"Produtividade"
	Aadd( oPanels, 	oExplorer:GetPanel(nPanel) )
	
	IncProc()
		
		If SL1->(FieldPos("L1_TIMEATE") ) > 0  // Se existir o campo L1_TIMEATE
		
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Criacao do 3. Sub-Grupo    - Nivel 2 ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			oExplorer:AddTree(Padr(STR0080,150),"FOLDER13",,Padr(StrZero(++nPanel,7),20)) //"Média Atend. Vendas"
			Aadd( oPanels,oExplorer:GetPanel(nPanel) )
			
	 		IncProc()
				
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Criacao dos Itens          - Nivel 3 ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If lGPFilial //Somente se existir Grupo de Filial
					oExplorer:AddItem(Padr(STR0030,150),"PMSDOC", Padr(StrZero(++nPanel,7),20))//"Grupo de Filial"
					Aadd( oPanels, oExplorer:GetPanel(nPanel) ) 
					cInforme1 := ""
					cInforme2 := ""
					cInforme3 := ""
					Aadd(aFuncPanels,"LJPnGeral(4,oExplorer,"+Str(nPanel)+","+Str(nRanking)+" , mv_par01, mv_par02, '"+STR0004+" x "+STR0005+"', '401', '"+ cInforme1 +"','"+ cInforme2+"','"+ cInforme3+"','"+"Média Atendimento de Vendas (Segundos)"+" - "+STR0030+"')")//Grupo de Filial de x Grupo de filial ate//Média Atendimento de Vendas (Segundos) - Grupo de Filial')
					Aadd(aRelatorio,{1,STR0041+"\"+STR0028+"\"+STR0080+"\"+STR0030,"LR7017411('"+STR0030+"',lGPFilial,1)"})//"Prevencao de Perdas\Produtividade\Média Atend. Vendas\Grupo de Filial"
					IncProc()
				Endif
				
				oExplorer:AddItem(Padr(STR0031,150),"PMSDOC", Padr(StrZero(++nPanel,7),20))//"Filial"
				Aadd( oPanels, oExplorer:GetPanel(nPanel) )
				cInforme1 := ""
				cInforme2 := ""
				cInforme3 := ""
				Aadd(aFuncPanels,"LJPnGeral(4,oExplorer,"+Str(nPanel)+","+Str(nRanking)+" , mv_par03, mv_par04, '"+STR0006+" x "+STR0007+"', '402', '"+ cInforme1 +"','"+ cInforme2+"','"+ cInforme3+"','"+"Média Atendimento de Vendas (Segundos)"+" - "+STR0031+"')")//Filial de x Filial ate//Média Atendimento de Vendas (Segundos) - Filial')
				Aadd(aRelatorio,{2,STR0041+"\"+STR0028+"\"+STR0080+"\"+STR0031,"LR7017411('"+STR0031+"',lGPFilial,2)"})//"Prevencao de Perdas\Produtividade\Média Atend. Vendas\Filial"
				IncProc()
				
				oExplorer:AddItem(Padr(STR0068,150),"PMSDOC", Padr(StrZero(++nPanel,7),20))//"Caixa"
				Aadd( oPanels, oExplorer:GetPanel(nPanel) )
				cInforme1 := ""
				cInforme2 := ""
				cInforme3 := ""
				Aadd(aFuncPanels,"LJPnGeral(4,oExplorer,"+Str(nPanel)+","+Str(nRanking)+" , mv_par05, mv_par06, '"+STR0008+" x "+STR0009+"', '403', '"+ cInforme1 +"','"+ cInforme2+"','"+ cInforme3+"','"+"Média Atendimento de Vendas (Segundos)"+" - "+STR0068+"')")//Caixa de x Caixa ate//Média Atendimento de Vendas (Segundos) - Caixa')
				Aadd(aRelatorio,{3,STR0041+"\"+STR0028+"\"+STR0080+"\"+STR0068,"LR7017411('"+STR0068+"',lGPFilial,3)"})//"Prevencao de Perdas\Produtividade\Média Atend. Vendas\Caixa"
				IncProc()
				
				oExplorer:AddItem(Padr(STR0075,150),"PMSDOC", Padr(StrZero(++nPanel,7),20))//"PDV"
				Aadd( oPanels, oExplorer:GetPanel(nPanel) )
				cInforme1 := ""
				cInforme2 := ""
				cInforme3 := ""
				Aadd(aFuncPanels,"LJPnGeral(4,oExplorer,"+Str(nPanel)+","+Str(nRanking)+" , mv_par07, mv_par08, '"+STR0010+" x "+STR0011+"', '404', '"+ cInforme1 +"','"+ cInforme2+"','"+ cInforme3+"','"+"Média Atendimento de Vendas (Segundos)"+" - "+STR0075+"')")//PDV de x PDV ate//Média Atendimento de Vendas (Segundos) - PDV')
				Aadd(aRelatorio,{4,STR0041+"\"+STR0028+"\"+STR0080+"\"+STR0075,"LR7017411('"+STR0075+"',lGPFilial,4)"})//"Prevencao de Perdas\Produtividade\Média Atend. Vendas\PDV"
				IncProc()
				
			oExplorer:EndTree()
		EndIf
		
		If SL1->(FieldPos("L1_TIMEITE") ) > 0  // Se existir o campo L1_TIMEITE
		
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Criacao do 3. Sub-Grupo    - Nivel 2 ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			
			oExplorer:AddTree(Padr(STR0077,150),"FOLDER13",,Padr(StrZero(++nPanel,7),20))//"Média Registro Item"
			Aadd( oPanels, oExplorer:GetPanel(nPanel) ) 
			
			IncProc()
			
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Criacao dos Itens          - Nivel 3 ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ 
				If lGPFilial //Somente se existir Grupo de empresa
					oExplorer:AddItem(Padr(STR0030,150),"PMSDOC", Padr(StrZero(++nPanel,7),20))//"Grupo de Filial"
					Aadd( oPanels, oExplorer:GetPanel(nPanel) ) 
					cInforme1 := ""
					cInforme2 := ""
					cInforme3 := ""
					Aadd(aFuncPanels,"LJPnGeral(4,oExplorer,"+Str(nPanel)+","+Str(nRanking)+" , mv_par01, mv_par02, '"+STR0004+" x "+STR0005+"', '405', '"+ cInforme1 +"','"+ cInforme2+"','"+ cInforme3+"','"+STR0105+" - "+STR0030+"')")//Grupo de Filial de x Grupo de filial ate//Média Registro Item (Segundos) - Grupo de Filial
					Aadd(aRelatorio,{1,STR0041+"\"+STR0028+"\"+STR0077+"\"+STR0030,"LR7017421('"+STR0030+"',lGPFilial,1)"})//"Prevencao de Perdas\Produtividade\Média Registro Item\Grupo de Filial"
					IncProc()
				Endif 
				
				oExplorer:AddItem(Padr(STR0031,150),"PMSDOC", Padr(StrZero(++nPanel,7),20))//"Filial"
				Aadd( oPanels, oExplorer:GetPanel(nPanel) ) 
				cInforme1 := ""
				cInforme2 := ""
				cInforme3 := ""
				Aadd(aFuncPanels,"LJPnGeral(4,oExplorer,"+Str(nPanel)+","+Str(nRanking)+" , mv_par03, mv_par04 ,'"+STR0006+" x "+STR0007+"', '406', '"+ cInforme1 +"','"+ cInforme2+"','"+ cInforme3+"','"+STR0105+" - "+STR0031+"')")//Filial de x Filial ate//Média Registro Item (Segundos) - Filial
				Aadd(aRelatorio,{2,STR0041+"\"+STR0028+"\"+STR0077+"\"+STR0031,"LR7017421('"+STR0031+"',lGPFilial,2)"})//"Prevencao de Perdas\Produtividade\Média Registro Item\Filial"
				IncProc()
	            
				oExplorer:AddItem(Padr(STR0068,150),"PMSDOC", Padr(StrZero(++nPanel,7),20))//"Caixa"
				Aadd( oPanels, oExplorer:GetPanel(nPanel) )
				cInforme1 := ""
				cInforme2 := ""
				cInforme3 := ""
				Aadd(aFuncPanels,"LJPnGeral(4,oExplorer,"+Str(nPanel)+","+Str(nRanking)+" , mv_par05, mv_par06, '"+STR0008+" x "+STR0009+"', '407', '"+ cInforme1 +"','"+ cInforme2+"','"+ cInforme3+"','"+STR0105+" - "+STR0068+"')")//Caixa de x Caixa ate//Média Registro Item (Segundos) - Caixa
				Aadd(aRelatorio,{3,STR0041+"\"+STR0028+"\"+STR0077+"\"+STR0068,"LR7017421('"+STR0068+"',lGPFilial,3)"})//"Prevencao de Perdas\Produtividade\Média Registro Item\Caixa"
				IncProc()
				
				oExplorer:AddItem(Padr(STR0075,150),"PMSDOC", Padr(StrZero(++nPanel,7),20))//"PDV"
				Aadd( oPanels, oExplorer:GetPanel(nPanel) )
				cInforme1 := ""
				cInforme2 := ""
				cInforme3 := ""
				Aadd(aFuncPanels,"LJPnGeral(4,oExplorer,"+Str(nPanel)+","+Str(nRanking)+" , mv_par07, mv_par08, '"+STR0010+" x "+STR0011+"', '408', '"+ cInforme1 +"','"+ cInforme2+"','"+ cInforme3+"','"+STR0105+" - "+STR0075+"')")//PDV de x PDV ate//Média Registro Item (Segundos) - PDV
				Aadd(aRelatorio,{4,STR0041+"\"+STR0028+"\"+STR0077+"\"+STR0075,"LR7017421('"+STR0075+"',lGPFilial,4)"})//"Prevencao de Perdas\Produtividade\Média Registro Item\PDV"
				IncProc()
	   			
			oExplorer:EndTree()
		EndIf
		
	oExplorer:EndTree()
EndIf

RestArea(aArea)

Return Nil

//#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~
//                                               Processa as chamadas das rotinas graficas                                        
//#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³LJPnGeral  ºAutor  ³ Totvs                   º Data ³  04/07/13 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Monta a chamada aos painels                                     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³Prevencao de Perdas                                             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/                  
Function LJPnGeral(nIndicador,oExplorer, nPanel, nRanking, cParam01, cParam02, cMSG, cOPC, cInforme1, cInforme2, cInforme3, cTitulo)
Local aArea     := GetArea()                                           	// Salva a area atual
Local oGraphic	:= NIL													// Objeto do definicao do grafico
Local nBottom  	:= Int((oExplorer:aPanel[nPanel]:nHeight * .95) / 2)	// Posicao inicial ABAIXO
Local nRight	:= Int((oExplorer:aPanel[nPanel]:nWidth * .98) / 2)	// Posicao inicial DIREITA	
Local nI 		:= 0 													// Contador Auxiliar
Local nCol      := 0													// Contador Auxiliar
Local nAuxLen	:= 0													// Contador Auxiliar para o FOR	
Local aMSG      := {}                                                  	// Contem as mensagens auxiliares referente ao grafico em uso
Local cReferencia   := ""                                              	// Contem o nome da funcao que o sistema usa para gerar os graficos 

aSerie   	:= {}
For nCol := 1 TO nRanking
  Aadd(aSerie, {"0", 0, "Coluna-"+alltrim(str(nCol)),0} )
Next nCol

//Carrega a lógica das visoes
If  Empty(cParam02)
	Aadd(aMSG,cMSG) 
	LJ7017Vazio(oExplorer, nPanel, aMSG )
Else
    cReferencia := "ProcInd"+alltrim(cOPC)+"()"

  	If FindFunction(cReferencia) 
	  	aSerie := Eval({|| &cReferencia })
		aAdd(aSerieAux,{nPanel,cTitulo,aSerie})
		
		nLenAux := LEN(aSerie)
	    
    If !Empty(aSerie[1][2]) .And. (aSerie[1][2] <> 0)
		    //Carrega os objetos do grafico
			LJ7017GRAP(@oGraphic,02,02,nRight,(nBottom * .80),oExplorer:GetPanel(nPanel),aSerie,cTitulo,nIndicador) 		
	                            
			//Observacoes de tela
			@ (nBottom * .88),02 TO nBottom+15,nRight+3 LABEL "" OF oExplorer:GetPanel(nPanel) PIXEL

			fAjustaMsg(@cInforme1,@cInforme2,@cInforme3,cOPC,aSerie)
			
			If !Empty(cInforme1)
				//Par de Bottom + Say
				@ (nBottom * .90),08 BitMap oBmp1 ResName "checked" OF oExplorer:GetPanel(nPanel) Size 10,10 NoBorder When .F. Pixel
				TSay():New((nBottom * .90),21,{|| cInforme1 },oExplorer:GetPanel(nPanel),,,,,,.T.,CLR_BLACK,CLR_WHITE) 
			Endif

			If !Empty(cInforme2)
				//Par de Bottom + Say
				@ (nBottom * .95),08 BitMap oBmp1 ResName "checked" OF oExplorer:GetPanel(nPanel) Size 10,10 NoBorder When .F. Pixel
				TSay():New((nBottom * .95),21,{|| cInforme2 },oExplorer:GetPanel(nPanel),,,,,,.T.,CLR_BLACK,CLR_WHITE) 
			Endif
				
			If !Empty(cInforme3)
				//Par de Bottom + Say
				@ (nBottom * .100),08 BitMap oBmp1 ResName "checked" OF oExplorer:GetPanel(nPanel) Size 10,10 NoBorder When .F. Pixel
				TSay():New((nBottom * .100),21,{|| cInforme3 },oExplorer:GetPanel(nPanel),,,,,,.T.,CLR_BLACK,CLR_WHITE)
			Endif	
	    Else
		    Aadd(aMSG,cMSG) 
			LJ7017Vazio(oExplorer, nPanel, aMSG )
	    Endif
  	Endif
Endif	
	
RestArea(aArea)

Return Nil


//#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~
//                                                              FIM                                         
//#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³LJINDI7017³ Autor ³ TOTVS                 ³ Data ³ 02/07/13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Retorna os tipos de Indicadores disponíveis na rotina PP    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³Prevencao de perdas                                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function LJINDI7017(cRetValue)
Local lRet      := .F.    // Retorna se o usuario selecionou algum tipo de indicador para que o sistema possa trabalhar. 
Local nOpcA     := 0      // Controla a opção de OK ou Cancela 
Local nInd      := 0      // Contador para o FOR	
Local aLista    := {}     // Contem as opcoes de visoes disponiveis
Local oSelPP    := Nil    // Tela para selecionar os indicadores
Local bOK       := { || nOpca := 1, oDlg:End() } // Acao executada ao clicar no botao ok      
Local bCancel   := { || oDlg:End() }             // Acao executada no botao Cancel
Local aIndicSel := aBIToken(cRetValue,";")       // Opcoes de visões


	aAdd(aLista, {"1", STR0025	,Ascan(aIndicSel,"1") > 0}) // "Estoque"
	aAdd(aLista, {"2", STR0026	,Ascan(aIndicSel,"2") > 0}) // "Financeiro"
	aAdd(aLista, {"3", STR0027	,Ascan(aIndicSel,"3") > 0}) // "Comercial"
	aAdd(aLista, {"4", STR0028	,Ascan(aIndicSel,"4") > 0}) // "Produtividade"

	
	Define MsDialog oDlg Title STR0042 From 050, 150 To 400,600 Of oMainWnd Pixel  //"Seleção de Indicadores"
	
		oSelPP := TcBrowse():New(015,005,220,140,,,, oDlg,,,,,,,,,,,, .F.,, .T.,, .F., )
		
		oSelPP:AddColumn(TcColumn():New(" ",{ || IF(aLista[oSelPP:nAt,3],LoadBitmap( GetResources(), "LBOK" ),LoadBitmap( GetResources(), "LBNO" )) },;
			"@c",nil,nil,nil,015,.T.,.T.,nil,nil,nil,.T.,nil))
		
		oSelPP:AddColumn(TcColumn():New(STR0043,{ || OemToAnsi(aLista[oSelPP:nAt,1]) },; //"Código"
			"@!",nil,nil,nil,020,.F.,.F.,nil,nil,nil,.F.,nil))
		
		oSelPP:AddColumn(TcColumn():New(STR0044,{ || OemToAnsi(aLista[oSelPP:nAt,2]) },; //"Indicador"
			"@C",nil,nil,nil,200,.F.,.F.,nil,nil,nil,.F.,nil))
		
		oSelPP:SetArray(aLista)
		oSelPP:bLDblClick   := { ||aLista[oSelPP:nAt,3] := ! aLista[oSelPP:nAt,3] }
		oSelPP:bHeaderClick := { |a,b| iif(b == 1, MarkAll(aLista),), oSelPP:Refresh()}
	
	Activate MSDialog oDlg Centered On Init EnChoiceBar(oDlg,bOK,bCancel,.F.,{})
	
	If nOpcA == 1
		cRetValue := ""
		For nInd := 1 to Len(aLista)
			If aLista[nInd,3] .And. aLista[nInd,1] <> "T"
				If Len(cRetValue) > 0
					cRetValue += ";"
				EndIf
				cRetValue += aLista[nInd,1]
			EndIf
		Next nInd
		lRet := .T.
	EndIf
	
Return lRet


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ MarkAll  ³ Autor ³ TOTVS                 ³ Data ³ 02/07/13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Faz a marcacao dos indicadores.                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³Prevencao de perdas                                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function MarkAll(aLista)
Local lMark := .f. // Indica se ocorreu a selecao de todas as visoes
    
aEval(aLista, {|x| IIf (!x[3], lMark := .t.,)  }) 
aEval(aLista, {|x,i| aLista[i,3] := lMark }) 

Return .T.


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³LOJA7017  ºAutor  ³Microsiga           º Data ³  07/03/13   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³  Configuracoes                                             º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function LJ7017GRAP(oGraphic,nTop,nLeft,nRight,nBottom,oPai,aSerie,cTitle,nIndicador,nAlign,cPict,cMask)
Local nI			:= 0    // Contador For
Local cCbxResA		:= ""   // Contem a opcao de formato padrão para exibir os graficos
Local aCbxResA		:= {}   // Contem as opçoes de formato de exibicao dos graficos
Local cCbxQtVr		:= ""   // Contem a opcao de informacao padrão para exibir os graficos
Local aCbxQtVr		:= {}   // Contem as opçoes de informacoes de exibicao dos graficos
Local aGraficos		:= {{STR0045,BARCHART},{STR0046,PIECHART}} 	//"Barra"#"Pizza"
Local aInfos		:= {{STR0110,1},{STR0109,2}} 					//"Valores"#"Quantidades"
Local nTpChart		:= 0    // Contem o formato de exibicao de grafico selecionado pelo usuario
Local nTpInfo		:= 1    // Contem qual tipo de informacao que sera apresentado no grafico selecionado pelo usuario
Local oPanGra		:= NIL  // Agrupador dos componentes visuais utilizados para construir o grafico
Local oPanelCombo	:= NIL  // Agrupador dos componentes visuais utilizados para exbir as opções de exibicao dos graficos
Local oPanelQtdVr	:= NIL  // Agrupador dos componentes visuais utilizados para exbir as opções de exibicao dos graficos

Static oFwChart		:= NIL  // Exibe o Grafico

Default nAlign		:= CONTROL_ALIGN_BOTTOM  //Alinhamento da Legenda
Default cTitle		:= "" 			//Titulo do grafico	
Default cPict		:= "@E 999,999,999.99" 	//Formatacao do titulo 
Default cMask		:= " *@* "		//Mascara do titulo

oPanelCombo	:= tPanel():New(nTop+00,nLeft+000,"",oPai,,,,CLR_WHITE,CLR_WHITE,nRight-000,15)
oPanelQtdVr	:= tPanel():New(nTop+00,nLeft+135,"",oPai,,,,CLR_WHITE,CLR_WHITE,nRight-135,15)
oPanGra		:= tPanel():New(nTop+12,nLeft+000,"",oPai,,,,CLR_WHITE,CLR_WHITE,nRight-000,nBottom-05)

aCbxResA := {STR0045,STR0046} //"Barra"#"Pizza"
aCbxQtVr := {STR0110,STR0109} //"Valores"#"Quantidades"
cCbxResA := aCbxResA[1]
cCbxQtVr := aCbxQtVr[1]

If ValType(oFwChart) <> "O"
	oFwChart := FwChartFactory():New()
EndIf 

@ 04, 05 Say STR0042+":" Size 050, 008 Pixel Of oPanelCombo //"Tipo de Gráfico"
@ 02, 55 ComboBox cCbxResA Items aCbxResA Size 050, 008 Pixel Of oPanelCombo;	
	On Change (	nTpChart := aScan( aGraficos, {|xVar| xVar[1] == cCbxResA}),;
				LJ7017Chart(@oFwChart,oGraphic,oPanGra,aGraficos[nTpChart][2],;
					aSerie,nAlign,cTitle,cPict,cMask,nTpInfo);
				)
If nIndicador == 1 .OR. nIndicador == 2
	@ 04, 05 Say STR0108+":" Size 050, 008 Pixel Of oPanelQtdVr //"Apresenta Por"
	@ 02, 56 ComboBox cCbxQtVr Items aCbxQtVr Size 055, 010 Pixel Of oPanelQtdVr;	
		On Change (	nTpInfo := aScan( aInfos, {|xVar| xVar[1] == cCbxQtVr}),;
					LJ7017Chart(@oFwChart,oGraphic,oPanGra,aGraficos[aScan(aGraficos,{|xVar| xVar[1] == cCbxResA})][2],;
						aSerie,nAlign,cTitle,cPict,cMask,nTpInfo);
					)
EndIf

LJ7017Chart(@oFwChart,@oGraphic,oPanGra,aGraficos[aScan(aGraficos,{|xVar| xVar[1] == cCbxResA})][2],aSerie,nAlign,cTitle,cPict,cMask,nTpInfo)

Return Nil


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³LOJA7017  ºAutor  ³Microsiga           º Data ³  07/03/13   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Adiciona os dados da série ao grafico                      º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function LJ7017Chart(oFwChart,oGraphic,oPanGra,nTpChart,aSerie,nAlign,cTitle,cPict,cMask,nTpInfo)
									
Local nLenAux 	:= 0  // Contem o tamanho do array aSerie
Local nI		:= 0  // Contador For
Local nPos 		:= 0  // Contem o panel atual

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

If nTpChart == BARCHART  	// Barra
	oGraphic:lShadow := !(nLenAux==1) // Se tiver apenas 1 serie não apresentará sombra no gráfico
EndIf

For nI := 1 To nLenAux
	If aSerie[nI][2] <> 0 			// Se existir alguma informacao jah no primeiro item
		If nTpChart == BARCHART  	// Barra
			If aSerie[nI][4] == 0 	// Se não houver um segundo valor na casa 4, geramos barras separadas 
				oGraphic:addSerie( aSerie[nI][3],Round(aSerie[nI][2],2) )
			Else                 	// Caso contrário iremos agrupar as barras do mesmo contexto
				If nTpInfo == 1
					oGraphic:addSerie(aSerie[nI][3]+STR0103, Round(aSerie[nI][2],2) ) //(Valor)
				Else
					oGraphic:addSerie(aSerie[nI][3]+STR0104, Round(aSerie[nI][4],2) ) //(Quant.)
				EndIf
			EndIf
		Else			   			// Pizza
			If aSerie[nI][4] == 0 	// Se não houver um segundo valor na casa 4, geramos barras separadas 
				oGraphic:addSerie( aSerie[nI][3],Round(aSerie[nI][2],2) )
			Else                 	// Caso contrário iremos agrupar as barras do mesmo contexto
				If nTpInfo == 1
					oGraphic:addSerie(aSerie[nI][3]+STR0103, Round(aSerie[nI][2],2) ) //(Valor)
				Else
					oGraphic:addSerie(aSerie[nI][3]+STR0104, Round(aSerie[nI][4],2) ) //(Quant.)
				EndIf
			EndIf
		EndIF
	Endif	
Next nI

oGraphic:setColor("Random")  

oGraphic:Build()

Return Nil


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³TKC010SD    ºAutor  ³Armando M. Tessaroli  º Data ³  04/07/13   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Monta o panel com informacoes para o caso de nao haver dados    º±±
±±º          ³para serem pesquisados na base.                                 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³Pefil do Contato                                                º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º          ³        ³      ³                                                º±±
±±º          ³        ³      ³                                                º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function LJ7017Vazio(oExplorer, nPanel, aTexto)

Local nTop       := 0		// Posicao no TOPO
Local nLeft      := 0		// Posicao na ESQUERDA
Local nBottom    := 0		// Posicao ABAIXO
Local nRight     := 0		// Posicao na DIREITA
Local oBmp1		 := Nil		// Bitmap
Local nI         := 0		// Contador
Local cTextSay	 := ""		// Texto

nRight := oExplorer:GetPanel(nPanel):nRight
nBottom := oExplorer:GetPanel(nPanel):nBottom

TSay():New(nTop+10,nLeft+10,{|| STR0082 },oExplorer:GetPanel(nPanel),,,,,,.T.,CLR_HRED,CLR_WHITE) //"Atencao, verifique os parametros dos filtros abaixo, pois não existe movimento para esta visão:"

@ nTop+20, nLeft+10 TO nBottom, nRight Label "" Of oExplorer:GetPanel(nPanel) Pixel

If Len(aTexto) > 0
	
	For nI := 1 TO Len(aTexto)
		If aTexto[nI] <> Nil
			cTextSay := "{||'"+aTexto[nI]+"'}"
			TSay():New(nTop+20+(nI*10),nLeft+20,MontaBlock(cTextSay),oExplorer:GetPanel(nPanel),,,,,,.T.,CLR_HBLUE,CLR_WHITE)
		EndIf
	Next nI
	
Else
	TSay():New(nTop+30,nLeft+20,{|| STR0083 },oExplorer:GetPanel(nPanel),,,,,,.T.,CLR_HBLUE,CLR_WHITE) //"Nao existe informaçoes adicionais."
Endif

@ nTop, nLeft BitMap oBmp1 ResName STR0084 Of oExplorer:GetPanel(nPanel) /*Size nRight/6, nBottom+10 NoBorder*/ When .F. Pixel Adjust //"Prevenção de Perdas"
oBmp1:lAutoSize := .T.

Return Nil

//#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~
//                                Procesamento dos valores que serao impressos pelo painel                                        
//#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~#~

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ProcInd01        ³Autor  ³TOTVS               ³ Data ³ 02/07/13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Retorna os valores que serao impressos pelo painel             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Produtos c/ Maior Devolução >> Grupo de Filial                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function ProcInd01()

Local aArea  	:= GetArea()// Salva a area atual
Local cCont		:= 0   // contador de serie
Local cQuery    := ""  // Texto SQL que é enviado para o comando TCGenQry
Local aTotal    := {}  // Contem os valores que serao exibidos no grafico
Local nI        := 0   // Contador For
Local nY        := 0   // Contador For
Local nTotal    := 0   // limitador do numero de registros por ranking
Local lAchou    := .F. // Indica a quebra de grupo de registros  			

If lCatProd
	cQuery :=	" SELECT SAU.AU_CODGRUP,SAU.AU_DESCRI,SD1.D1_FILIAL,SD1.D1_DOC,SD1.D1_SERIE,SD1.D1_COD,SD1.D1_QUANT,SD1.D1_VUNIT,ACV.ACV_CATEGO,ACV.ACV_GRUPO " +;
				" FROM 	" + RetSqlName("SD1")  +" SD1 LEFT JOIN 	" + RetSqlName("ACV")  +" ACV on ACV.ACV_CODPRO  = SD1.D1_COD " +;
				" INNER JOIN " + RetSqlName("SAU") + " SAU " +;
				" ON SAU.D_E_L_E_T_ = ' ' AND SAU.AU_CODFIL = SD1.D1_FILIAL " +;
				" INNER JOIN " + RetSqlName("SD2") + " SD2 " +;
				" ON SD2.D_E_L_E_T_ = ' ' AND SD2.D2_FILIAL = SD1.D1_FILIAL AND SD2.D2_DOC = SD1.D1_NFORI " +;
				" AND SD2.D2_SERIE = SD1.D1_SERIORI AND SD2.D2_QTDEDEV <> 0 AND SD2.D2_ITEM = SD1.D1_ITEMORI " +;
				" WHERE ACV.ACV_CATEGO IN (SELECT ACU_COD  FROM 	" + RetSqlName("ACU") +;
				"                      WHERE  ACU_CODPAI >= '" + mv_par11 + "'" +;//CATEGORIA
				"                         AND ACU_CODPAI <= '" + mv_par12 + "'" +;//CATEGORIA
				"                         AND D_E_L_E_T_ = ' ') " +;
		        " AND " + LJ7017QryFil(.F.,"SD1")[2]
    If lGestao .AND. lACVComp	// Se a tabela ACV for compartilhada aceito a filial corrente
		cQuery += " AND ACV.ACV_FILIAL = '" + xFilial("ACV") + "' "
	Else 						// Se a tabela ACV for exclusiva comparo as Filiais
		cQuery += " AND ACV.ACV_FILIAL = SD1.D1_FILIAL "
	EndIf
    cQuery += 	" AND ACV.ACV_GRUPO >= '" + mv_par13 + "'" +;
				" AND ACV.ACV_GRUPO <= '" + mv_par14 + "'" +;
				" AND D1_COD >= '" + mv_par15 + "'" +;
		        " AND D1_COD <= '" + mv_par16 + "'" +;
		    	" AND D1_QUANT <> 0 " +;
			    " AND D1_EMISSAO >= '" + DToS(mv_par09) + "'"  +;
			   	" AND D1_EMISSAO <= '" + DToS(mv_par10) + "'"  +;
		     	" AND ACV.D_E_L_E_T_ = ' ' " +;
		     	" AND SD1.D_E_L_E_T_ = ' ' " +;
				" GROUP BY SAU.AU_CODGRUP,SAU.AU_DESCRI,SD1.D1_FILIAL,SD1.D1_DOC,SD1.D1_SERIE,SD1.D1_COD,SD1.D1_QUANT,SD1.D1_VUNIT,ACV.ACV_CATEGO,ACV.ACV_GRUPO "

Else  	
	cQuery :=	" SELECT SAU.AU_CODGRUP,SAU.AU_DESCRI,SD1.D1_FILIAL,SD1.D1_DOC,SD1.D1_SERIE,SD1.D1_COD,SD1.D1_QUANT,SD1.D1_VUNIT " +;
			" FROM 	" + RetSqlName("SD1")  + " SD1 " +;
			" INNER JOIN " + RetSqlName("SAU") + " SAU " +;
			" ON SAU.D_E_L_E_T_ = ' ' AND SAU.AU_CODFIL = SD1.D1_FILIAL " +;
			" INNER JOIN " + RetSqlName("SD2") + " SD2 " +;
			" ON SD2.D_E_L_E_T_ = ' ' AND SD2.D2_FILIAL = SD1.D1_FILIAL AND SD2.D2_DOC = SD1.D1_NFORI " +;
			" AND SD2.D2_SERIE = SD1.D1_SERIORI AND SD2.D2_QTDEDEV <> 0 AND SD2.D2_ITEM = SD1.D1_ITEMORI " +;
			" WHERE " +LJ7017QryFil(.F.,"SD1")[2] +;
			" AND D1_COD >= '" + mv_par15 + "'" +;
            " AND D1_COD <= '" + mv_par16 + "'" +;
     		" AND D1_QUANT <> 0 " +;
		    " AND D1_EMISSAO >= '" + DToS(mv_par09) + "'"  +;
		    " AND D1_EMISSAO <= '" + DToS(mv_par10) + "'"  +; 
		    " AND SD1.D1_FILIAL = SAU.AU_CODFIL "+;
     		" AND SD1.D_E_L_E_T_ = ' ' " +;
			" GROUP BY SAU.AU_CODGRUP,SAU.AU_DESCRI,SD1.D1_FILIAL,SD1.D1_DOC,SD1.D1_SERIE,SD1.D1_COD,SD1.D1_QUANT,SD1.D1_VUNIT "
Endif

cQuery := ChangeQuery(cQuery)

DbSelectArea("SD1")
DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), 'SD1TRB', .F., .T.)

While SD1TRB->(!Eof()) 			

    If cCont == 0 
  		Aadd(aTotal,{SD1TRB->AU_CODGRUP, (SD1TRB->D1_QUANT * SD1TRB->D1_VUNIT),AllTrim(SD1TRB->AU_DESCRI),SD1TRB->D1_QUANT})
  		lAchou := .T.
    Else             
	    For nI:= 1 to len(aTotal)
	    	If SD1TRB->AU_CODGRUP == aTotal[nI][1]
	    		aTotal[nI][2] := aTotal[nI][2] + (SD1TRB->D1_QUANT * SD1TRB->D1_VUNIT)
	    		aTotal[nI][4] := aTotal[nI][4] + SD1TRB->D1_QUANT
	    		lAchou := .T.
            Endif
	    Next nI
	Endif

	If !lAchou
  		Aadd(aTotal,{SD1TRB->AU_CODGRUP, (SD1TRB->D1_QUANT * SD1TRB->D1_VUNIT),AllTrim(SD1TRB->AU_DESCRI),SD1TRB->D1_QUANT})
	Endif

	cCont ++
	lAchou := .F.
	
	SD1TRB->(dbSkip())
EndDo	              

SD1TRB->(DbCloseArea())	
 
//Ordernar do maior para o menor valor 
ASORT(aTotal,,,{ | x,y | x[2] > y[2] } )

//Limitar o numero de registros pelo numero de ranking informado
If len(aTotal) < len(aSerie)
   nTotal := len(aTotal)
Else
   nTotal := len(aSerie)   
Endif

For nI:= 1 to nTotal
	aSerie[nI][1] := "Cod:" + AllTrim(aTotal[nI][1])
	aSerie[nI][2] := aTotal[nI][2]//Total de produtos devolvidos x $unitario do produto
	aSerie[nI][3] := AllTrim(aTotal[nI][1])+"-"+AllTrim(aTotal[nI][3])//Filial
	aSerie[nI][4] := aTotal[nI][4]//Total
Next nI  

RestArea(aArea)

Return aSerie


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ProcInd02        ³Autor  ³TOTVS               ³ Data ³ 02/07/13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Retorna os valores que serao impressos pelo painel             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Produtos c/ Maior Devolução >>Filial                           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function ProcInd02()

Local aArea  	:= GetArea()// Salva a area atual
Local cCont		:= 0   // contador de serie
Local cQuery    := ""  // Texto SQL que é enviado para o comando TCGenQry
Local aTotal    := {}  // Contem os valores que serao exibidos no grafico
Local nI        := 0   // Contador For
Local nY        := 0   // Contador For
Local nTotal    := 0   //limitador do numero de registros por ranking
Local lAchou    := .F. // Indica a quebra de grupo de registros  
Local nPos		:= 1   // Contador Auxiliar For
Local aFiliais 	:= Lj7017Fil() // Recebera o retorna dos nomes das Filiais	

DbSelectArea("SD1")       
DbSetOrder(1)//D1_FILIAL+D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA+D1_COD+D1_ITEM 

If lCatProd
	cQuery :=	" SELECT SD1.D1_FILIAL,SD1.D1_COD,ACV.ACV_CATEGO,SD1.D1_QUANT,SD1.D1_VUNIT,ACV.ACV_GRUPO,SD1.D1_DOC,SD1.D1_SERIE " +; 
				" FROM 	" + RetSqlName("SD1")  +" SD1 LEFT JOIN 	" + RetSqlName("ACV")  +" ACV on ACV.ACV_CODPRO  = SD1.D1_COD " +;
				" INNER JOIN " + RetSqlName("SD2") + " SD2 " +;
				" ON SD2.D_E_L_E_T_ = ' ' AND SD2.D2_FILIAL = SD1.D1_FILIAL AND SD2.D2_DOC = SD1.D1_NFORI " +;
				" AND SD2.D2_SERIE = SD1.D1_SERIORI AND SD2.D2_QTDEDEV <> 0 AND SD2.D2_ITEM = SD1.D1_ITEMORI " +;
				" WHERE ACV.ACV_CATEGO IN (SELECT ACU_COD  FROM 	" + RetSqlName("ACU") +;
				"                      WHERE  ACU_CODPAI >= '" + mv_par11 + "'" +;//CATEGORIA
				"                         AND ACU_CODPAI <= '" + mv_par12 + "'" +;//CATEGORIA
				"                         AND D_E_L_E_T_ = ' ') " +;
	            " AND " + LJ7017QryFil(.F.,"SD1")[2]
 	If lGestao .AND. lACVComp	// Se a tabela ACV for compartilhada aceito a filial corrente
		cQuery += " AND ACV.ACV_FILIAL = '" + xFilial("ACV") + "' "
	Else 						// Se a tabela ACV for exclusiva comparo as Filiais
		cQuery += " AND ACV.ACV_FILIAL = SD1.D1_FILIAL "
	EndIf
    cQuery += 	" AND ACV.ACV_GRUPO >= '" + mv_par13 + "'" +;
				" AND ACV.ACV_GRUPO <= '" + mv_par14 + "'" +;
				" AND D1_COD >= '" + mv_par15 + "'" +;
	            " AND D1_COD <= '" + mv_par16 + "'" +; 
	     		" AND D1_QUANT <> 0 " +;
	  		    " AND D1_EMISSAO >= '" + DToS(mv_par09) + "'"  +;
			    " AND D1_EMISSAO <= '" + DToS(mv_par10) + "'"  +;
	 	        " AND ACV.D_E_L_E_T_ = ' ' " +;
	  		    " AND SD1.D_E_L_E_T_ = ' ' " +;
			    " GROUP BY SD1.D1_FILIAL,SD1.D1_COD,ACV.ACV_CATEGO,SD1.D1_QUANT,SD1.D1_VUNIT,ACV.ACV_GRUPO,SD1.D1_DOC,SD1.D1_SERIE "
Else
	cQuery :=	" SELECT SD1.D1_FILIAL,SD1.D1_COD,SD1.D1_QUANT,SD1.D1_VUNIT,SD1.D1_DOC,SD1.D1_SERIE " +;
			" FROM 	" + RetSqlName("SD1")  +" SD1 " +;
			" INNER JOIN " + RetSqlName("SD2") + " SD2 " +;
			" ON SD2.D_E_L_E_T_ = ' ' AND SD2.D2_FILIAL = SD1.D1_FILIAL AND SD2.D2_DOC = SD1.D1_NFORI " +;
			" AND SD2.D2_SERIE = SD1.D1_SERIORI AND SD2.D2_QTDEDEV <> 0 AND SD2.D2_ITEM = SD1.D1_ITEMORI " +;
			" WHERE "+ LJ7017QryFil(.F.,"SD1")[2]+;
			" AND D1_COD >= '" + mv_par15 + "'" +;
            " AND D1_COD <= '" + mv_par16 + "'" +;
     		" AND D1_QUANT <> 0 " +;
  		    " AND D1_EMISSAO >= '" + DToS(mv_par09) + "'"  +;
		    " AND D1_EMISSAO <= '" + DToS(mv_par10) + "'"  +;
 	        " AND SD1.D_E_L_E_T_ = ' ' "+;
		    " GROUP BY SD1.D1_FILIAL,SD1.D1_COD,SD1.D1_QUANT,SD1.D1_VUNIT,SD1.D1_DOC,SD1.D1_SERIE "
Endif
			
cQuery := ChangeQuery(cQuery)

DbSelectArea("SD1")
DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), 'SD1TRB', .F., .T.)
	
While SD1TRB->(!Eof()) 			
	
    If cCont == 0 
  		Aadd(aTotal,{SD1TRB->D1_FILIAL, (SD1TRB->D1_QUANT * SD1TRB->D1_VUNIT),"",SD1TRB->D1_QUANT})  
  		lAchou := .T.
    Else             
	    For nI:= 1 to len(aTotal)
	    	If SD1TRB->D1_FILIAL == aTotal[nI][1] 
	    		aTotal[nI][2] := aTotal[nI][2] + (SD1TRB->D1_QUANT * SD1TRB->D1_VUNIT)
		    	aTotal[nI][4] := aTotal[nI][4] + SD1TRB->D1_QUANT
	    		lAchou := .T.
	        Endif
	    Next nI
	Endif
    
    If !lAchou
  		Aadd(aTotal,{SD1TRB->D1_FILIAL, (SD1TRB->D1_QUANT * SD1TRB->D1_VUNIT),"",SD1TRB->D1_QUANT})
    Endif
	
	cCont ++
	
	lAchou := .F.
	
	SD1TRB->(dbSkip())

EndDo
 
 
//Ordernar do maior para o menor valor 
ASORT(aTotal,,,{ | x,y | x[2] > y[2] } )

If len(aTotal) < len(aSerie)
   nTotal := len(aTotal)
Else
   nTotal := len(aSerie)   
Endif

For nI:= 1 to nTotal	
	For nY:= 1 to len(aFiliais)
		If alltrim(aTotal[nI][1]) == alltrim(aFiliais[nY][1]) 
			nPos := nY
		Endif	
	Next nY	
    
	aSerie[nI][1] := "Cod:" + AllTrim(aTotal[nI][1])
	aSerie[nI][2] := aTotal[nI][2] //Total de produtos devolvidos x $unitario do produto
	aSerie[nI][3] := AllTrim(aTotal[nI][1])+"-"+AllTrim(aFiliais[nPos][2])  //grupo de filial
	aSerie[nI][4] := aTotal[nI][4]//Total
Next nI  

RestArea(aArea)
SD1TRB->(DbCloseArea())

Return aSerie


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ProcInd03        ³Autor  ³TOTVS               ³ Data ³ 02/07/13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Retorna os valores que serao impressos pelo painel             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Produtos c/ Maior Devolução >> Categoria                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function ProcInd03()

Local aArea  	:= GetArea()// Salva a area atual
Local cCont		:= 0   // contador de serie
Local cQuery    := ""  // Texto SQL que é enviado para o comando TCGenQry
Local aTotal    := {}  // Contem os valores que serao exibidos no grafico
Local nI        := 0   // Contador For
Local nTotal    := 0   // limitador do numero de registros por ranking
Local lAchou    := .F. // Indica a quebra de grupo de registros  

cQuery :=	" SELECT SD1.D1_FILIAL,SD1.D1_COD,ACV.ACV_CATEGO,SD1.D1_QUANT,SD1.D1_DOC,SD1.D1_SERIE,SD1.D1_VUNIT,ACV.ACV_GRUPO " +;
			" FROM 	" + RetSqlName("SD1")  +" SD1 LEFT JOIN 	" + RetSqlName("ACV")  +" ACV on ACV.ACV_CODPRO  = SD1.D1_COD " +;
			" INNER JOIN " + RetSqlName("SD2") + " SD2 " +;
			" ON SD2.D_E_L_E_T_ = ' ' AND SD2.D2_FILIAL = SD1.D1_FILIAL AND SD2.D2_DOC = SD1.D1_NFORI " +;
			" AND SD2.D2_SERIE = SD1.D1_SERIORI AND SD2.D2_QTDEDEV <> 0 AND SD2.D2_ITEM = SD1.D1_ITEMORI " +;
			" WHERE ACV.ACV_CATEGO IN (SELECT ACU_COD  FROM 	" + RetSqlName("ACU") +;
			"                      WHERE  ACU_CODPAI >= '" + mv_par11 + "'" +;//CATEGORIA
			"                         AND ACU_CODPAI <= '" + mv_par12 + "'" +;//CATEGORIA
			"                         AND D_E_L_E_T_ = ' ') " +;
            " AND " + LJ7017QryFil(.F.,"SD1")[2]
If lGestao .AND. lACVComp	// Se a tabela ACV for compartilhada aceito a filial corrente
	cQuery += " AND ACV.ACV_FILIAL = '" + xFilial("ACV") + "' "
Else 						// Se a tabela ACV for exclusiva comparo as Filiais
	cQuery += " AND ACV.ACV_FILIAL = SD1.D1_FILIAL "
EndIf
cQuery += 	" AND ACV.ACV_GRUPO >= '" + mv_par13 + "'" +;
			" AND ACV.ACV_GRUPO <= '" + mv_par14 + "'" +;
			" AND D1_COD >= '" + mv_par15 + "'" +;
            " AND D1_COD <= '" + mv_par16 + "'" +;
     		" AND D1_QUANT <> 0 " +;
   		    " AND D1_EMISSAO >= '" + DToS(mv_par09) + "'" +;
		    " AND D1_EMISSAO <= '" + DToS(mv_par10) + "'" +;
 	        " AND ACV.D_E_L_E_T_ = ' ' " +;
     		" AND SD1.D_E_L_E_T_ = ' ' " +;
		    " GROUP BY SD1.D1_FILIAL,SD1.D1_COD,ACV.ACV_CATEGO,SD1.D1_QUANT,SD1.D1_DOC,SD1.D1_SERIE,SD1.D1_VUNIT,ACV.ACV_GRUPO "

cQuery := ChangeQuery(cQuery)

DbSelectArea("SD1")
DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), 'SD1TRB', .F., .T.)

While SD1TRB->(!Eof()) 			
	 
    If cCont == 0 
  		Aadd(aTotal,{SD1TRB->ACV_CATEGO, (SD1TRB->D1_QUANT * SD1TRB->D1_VUNIT),"",SD1TRB->D1_QUANT})
  		lAchou := .T.
    Else             
	    For nI:= 1 to len(aTotal)
	    	If SD1TRB->ACV_CATEGO == aTotal[nI][1] 
	    		aTotal[nI][2] := aTotal[nI][2] + (SD1TRB->D1_QUANT * SD1TRB->D1_VUNIT)
		    	aTotal[nI][4] := aTotal[nI][4] + SD1TRB->D1_QUANT
	    		lAchou := .T.
            Endif
	    Next nI
	Endif

	If !lAchou
  		Aadd(aTotal,{SD1TRB->ACV_CATEGO, (SD1TRB->D1_QUANT * SD1TRB->D1_VUNIT),"",SD1TRB->D1_QUANT})
    Endif
    
	cCont ++
	
	lAchou := .F.
	
	SD1TRB->(dbSkip())

EndDo
 
//Ordernar do maior para o menor valor 
ASORT(aTotal,,,{ | x,y | x[2] > y[2] } )

If len(aTotal) < len(aSerie)
   nTotal := len(aTotal)
Else
   nTotal := len(aSerie)   
Endif

For nI:= 1 to nTotal
	aSerie[nI][1] := "Cod:" + AllTrim(aTotal[nI][1])
	aSerie[nI][2] := aTotal[nI][2]//Total de produtos devolvidos 
	aSerie[nI][3] := AllTrim(aTotal[nI][1])+"-"+AllTrim(Posicione( "ACU", 1, xFilial("ACU")+aTotal[nI][1], "ACU_DESC" ))//Categoria de produtos
	aSerie[nI][4] := aTotal[nI][4]//Total
Next nI  

RestArea(aArea)
SD1TRB->(DbCloseArea())

Return aSerie

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ProcInd04        ³Autor  ³TOTVS               ³ Data ³ 02/07/13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Retorna os valores que serao impressos pelo painel             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Produtos c/ Maior Devolução >> Grupo de produtos               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function ProcInd04()

Local aArea  	:= GetArea()// Salva a area atual
Local cCont		:= 0  // contador de serie cQuery  
Local aTotal    := {} // Contem os valores que serao exibidos no grafico
Local nI        := 0  // Contador For
Local nTotal    := 0  // limitador do numero de registros por ranking
Local lAchou    := .F.// Indica a quebra de grupo de registros  

cQuery :=	" SELECT SD1.D1_FILIAL,SD1.D1_COD,ACV.ACV_GRUPO,ACV.ACV_CATEGO,SD1.D1_QUANT,SD1.D1_DOC,SD1.D1_SERIE,SD1.D1_VUNIT " +;
			" FROM 	" + RetSqlName("SD1")  +" SD1 LEFT JOIN 	" + RetSqlName("ACV")  +" ACV on ACV.ACV_CODPRO  = SD1.D1_COD " +;
			" INNER JOIN " + RetSqlName("SD2") + " SD2 " +;
			" ON SD2.D_E_L_E_T_ = ' ' AND SD2.D2_FILIAL = SD1.D1_FILIAL AND SD2.D2_DOC = SD1.D1_NFORI " +;
			" AND SD2.D2_SERIE = SD1.D1_SERIORI AND SD2.D2_QTDEDEV <> 0 AND SD2.D2_ITEM = SD1.D1_ITEMORI " +;
			" WHERE ACV.ACV_CATEGO IN (SELECT ACU_COD  FROM 	" + RetSqlName("ACU") +;
			"                      WHERE  ACU_CODPAI >= '" + mv_par11 + "'" +;//CATEGORIA
			"                         AND ACU_CODPAI <= '" + mv_par12 + "'" +;//CATEGORIA
			"                         AND D_E_L_E_T_ = ' ') " +;
            " AND " + LJ7017QryFil(.F.,"SD1")[2]
If lGestao .AND. lACVComp	// Se a tabela ACV for compartilhada aceito a filial corrente
	cQuery += " AND ACV.ACV_FILIAL = '" + xFilial("ACV") + "' "
Else 						// Se a tabela ACV for exclusiva comparo as Filiais
	cQuery += " AND ACV.ACV_FILIAL = SD1.D1_FILIAL "
EndIf
cQuery += 	" AND ACV.ACV_GRUPO >= '" + mv_par13 + "'" +;
			" AND ACV.ACV_GRUPO <= '" + mv_par14 + "'" +;
			" AND D1_COD >= '" + mv_par15 + "'" +;
			" AND D1_COD <= '" + mv_par16 + "'" +;
   			" AND D1_QUANT <> 0 " +;
   		    " AND D1_EMISSAO >= '" + DToS(mv_par09) + "'"  +;
		    " AND D1_EMISSAO <= '" + DToS(mv_par10) + "'"  +;
 	        " AND ACV.D_E_L_E_T_ = ' ' " +;
     		" AND SD1.D_E_L_E_T_ = ' ' " +;
		    " GROUP BY SD1.D1_FILIAL,SD1.D1_COD,ACV.ACV_GRUPO,ACV.ACV_CATEGO,SD1.D1_QUANT,SD1.D1_DOC,SD1.D1_SERIE,SD1.D1_VUNIT "		
	
cQuery := ChangeQuery(cQuery)

DbSelectArea("SD1")
DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), 'SD1TRB', .F., .T.)

While SD1TRB->(!Eof()) 			
	 
    If cCont == 0 
  		Aadd(aTotal,{SD1TRB->ACV_GRUPO, (SD1TRB->D1_QUANT * SD1TRB->D1_VUNIT),"",SD1TRB->D1_QUANT})
		lAchou := .T.
    Else             
	    For nI:= 1 to len(aTotal)
	    	If SD1TRB->ACV_GRUPO == aTotal[nI][1]
	    		aTotal[nI][2] := aTotal[nI][2] + (SD1TRB->D1_QUANT * SD1TRB->D1_VUNIT)
		    	aTotal[nI][4] := aTotal[nI][4] + SD1TRB->D1_QUANT
    			lAchou := .T.
            Endif
	    Next nI
	Endif

	If !lAchou
  		Aadd(aTotal,{SD1TRB->ACV_GRUPO, (SD1TRB->D1_QUANT * SD1TRB->D1_VUNIT),"",SD1TRB->D1_QUANT})
	Endif
	
	cCont ++  
	
	lAchou := .F.
	
	SD1TRB->(dbSkip())

EndDo
 
//Ordernar do maior para o menor valor 
ASORT(aTotal,,,{ | x,y | x[2] > y[2] } )

If len(aTotal) < len(aSerie)
   nTotal := len(aTotal)
Else
   nTotal := len(aSerie)   
Endif

For nI:= 1 to nTotal
	aSerie[nI][1] := "Cod:" + AllTrim(aTotal[nI][1])
	aSerie[nI][2] := aTotal[nI][2]//Total de produtos devolvidos 
	aSerie[nI][3] := AllTrim(aTotal[nI][1])+"-"+AllTrim(Posicione("SBM",1,xFilial("SBM")+aTotal[nI][1],"BM_DESC"))//Grupo de produtos
	aSerie[nI][4] := aTotal[nI][4]//Total
Next nI  

RestArea(aArea)
SD1TRB->(DbCloseArea())

Return aSerie

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ProcInd05        ³Autor  ³TOTVS               ³ Data ³ 02/07/13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Retorna os valores que serao impressos pelo painel             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Produtos c/ Maior Devolução >> Produtos                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function ProcInd05()

Local aArea  	:= GetArea()
Local cCont		:= 0   // contador de serie
Local cQuery    := "" // Texto SQL que é enviado para o comando TCGenQry
Local aTotal    := {}
Local nI        := 0
Local nTotal    := 0 //limitador do numero de registros por ranking
Local lAchou    := .F.
  
If lCatProd 
	cQuery :=	" SELECT SD1.D1_FILIAL,SD1.D1_COD,SD1.D1_QUANT,SD1.D1_DOC,SD1.D1_SERIE,ACV.ACV_GRUPO,ACV.ACV_CATEGO,SD1.D1_VUNIT " +;
				" FROM 	" + RetSqlName("SD1")  +" SD1 LEFT JOIN 	" + RetSqlName("ACV")  +" ACV on ACV.ACV_CODPRO  = SD1.D1_COD " +;
				" INNER JOIN " + RetSqlName("SD2") + " SD2 " +;
				" ON SD2.D_E_L_E_T_ = ' ' AND SD2.D2_FILIAL = SD1.D1_FILIAL AND SD2.D2_DOC = SD1.D1_NFORI " +;
				" AND SD2.D2_SERIE = SD1.D1_SERIORI AND SD2.D2_QTDEDEV <> 0 AND SD2.D2_ITEM = SD1.D1_ITEMORI " +;
				" WHERE ACV.ACV_CATEGO IN (SELECT ACU_COD  FROM 	" + RetSqlName("ACU") +;
				"                      WHERE  ACU_CODPAI >= '" + mv_par11 + "'" +;//CATEGORIA
				"                         AND ACU_CODPAI <= '" + mv_par12 + "'" +;//CATEGORIA
				"                         AND D_E_L_E_T_ = ' ') " +;
	            " AND " + LJ7017QryFil(.F.,"SD1")[2]
	If lGestao .AND. lACVComp	// Se a tabela ACV for compartilhada aceito a filial corrente
		cQuery += " AND ACV.ACV_FILIAL = '" + xFilial("ACV") + "' "
	Else 						// Se a tabela ACV for exclusiva comparo as Filiais
		cQuery += " AND ACV.ACV_FILIAL = SD1.D1_FILIAL "
	EndIf
    cQuery += 	" AND ACV.ACV_GRUPO >= '" + mv_par13 + "'" +;
				" AND ACV.ACV_GRUPO <= '" + mv_par14 + "'" +;
				" AND D1_COD >= '" + mv_par15 + "'" +;
	            " AND D1_COD <= '" + mv_par16 + "'" +;
	     		" AND D1_QUANT <> 0 " +;
	   		    " AND D1_EMISSAO >= '" + DToS(mv_par09) + "'"  +;
			    " AND D1_EMISSAO <= '" + DToS(mv_par10) + "'"  +;
	 	        " AND ACV.D_E_L_E_T_ = ' ' " +;
	     		" AND SD1.D_E_L_E_T_ = ' ' " +;
			    " GROUP BY SD1.D1_FILIAL,SD1.D1_COD,SD1.D1_QUANT,SD1.D1_DOC,SD1.D1_SERIE,ACV.ACV_GRUPO,ACV.ACV_CATEGO,SD1.D1_DOC,SD1.D1_SERIE,SD1.D1_VUNIT "
    Else
    	cQuery :=	" SELECT SD1.D1_FILIAL,SD1.D1_COD,SD1.D1_QUANT,SD1.D1_DOC,SD1.D1_SERIE,SD1.D1_VUNIT " +;
			" FROM 	" + RetSqlName("SD1")  +" SD1 " +;
			" INNER JOIN " + RetSqlName("SD2") + " SD2 " +;
			" ON SD2.D_E_L_E_T_ = ' ' AND SD2.D2_FILIAL = SD1.D1_FILIAL AND SD2.D2_DOC = SD1.D1_NFORI " +;
			" AND SD2.D2_SERIE = SD1.D1_SERIORI AND SD2.D2_QTDEDEV <> 0 AND SD2.D2_ITEM = SD1.D1_ITEMORI " +;
			" WHERE " + LJ7017QryFil(.F.,"SD1")[2]+;
			" AND D1_COD >= '" + mv_par15 + "'" +;
            " AND D1_COD <= '" + mv_par16 + "'" +;
     		" AND D1_QUANT <> 0 " +;
     		" AND SD1.D_E_L_E_T_ = ' ' "+;
    		" AND D1_EMISSAO >= '" + DToS(mv_par09) + "'"  +;
		    " AND D1_EMISSAO <= '" + DToS(mv_par10) + "'"  +;
		    " GROUP BY SD1.D1_FILIAL,SD1.D1_COD,SD1.D1_QUANT,SD1.D1_DOC,SD1.D1_SERIE,SD1.D1_VUNIT "
Endif		

cQuery := ChangeQuery(cQuery)

DbSelectArea("SD1")
DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), 'D1TRB', .F., .T.)

While D1TRB->(!Eof()) 			
	
    If cCont == 0 
  		Aadd(aTotal,{D1TRB->D1_COD, (D1TRB->D1_QUANT * D1TRB->D1_VUNIT),"",D1TRB->D1_QUANT})
  		lAchou := .T.	  
    Else             
	    For nI:= 1 to len(aTotal)
	    	If alltrim(D1TRB->D1_COD) == alltrim(aTotal[nI][1])
	    		aTotal[nI][2] := aTotal[nI][2] + (D1TRB->D1_QUANT * D1TRB->D1_VUNIT)
		    	aTotal[nI][4] := aTotal[nI][4] + D1TRB->D1_QUANT
	    		lAchou := .T.
            Endif
	    Next nI
	Endif
    
	If !lAchou
		Aadd(aTotal,{D1TRB->D1_COD, (D1TRB->D1_QUANT * D1TRB->D1_VUNIT),"",D1TRB->D1_QUANT})
	Endif
		
	cCont ++
	
	lAchou := .F.
		
	D1TRB->(dbSkip())

EndDo
 
//Ordernar do maior para o menor valor 
ASORT(aTotal,,,{ | x,y | x[2] > y[2] } )

If len(aTotal) < len(aSerie)
   nTotal := len(aTotal)
Else
   nTotal := len(aSerie)   
Endif

For nI:= 1 to nTotal
	aSerie[nI][1] := "Cod:" + AllTrim(aTotal[nI][1])
	aSerie[nI][2] := aTotal[nI][2] //Total de produtos devolvidos 
	aSerie[nI][3] := AllTrim(aTotal[nI][1])+"-"+AllTrim(Posicione( "SB1", 1, xFilial("SB1")+alltrim(aTotal[nI][1]), "B1_DESC" )) //Produto - Descricao 
	aSerie[nI][4] := aTotal[nI][4]//Total
Next nI  

RestArea(aArea)
D1TRB->(DbCloseArea())


Return aSerie

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ProcInd06        ³Autor  ³TOTVS               ³ Data ³ 10/07/13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Retorna os valores que serao impressos pelo painel             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Produtos Cancelados >> Grupo de Filial                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function ProcInd06()

Local aArea  	:= GetArea()
Local cCont		:= 0   // contador de serie
Local cQuery    := ""  // Texto SQL que é enviado para o comando TCGenQry
Local aTotal    := {}
Local nI,nY     := 0
Local nTotal    := 0 //limitador do numero de registros por ranking
Local lAchou    := .F.  
Local cFiliais  := ""

If lCatProd 
  	cQuery :=	" SELECT SAU.AU_CODGRUP, SAU.AU_DESCRI,SLX.LX_FILIAL, SLX.LX_PRODUTO, ACV.ACV_CATEGO,ACV.ACV_GRUPO, LX_PDV,SLX.LX_QTDE,SLX.LX_VALOR,SLX.LX_CUPOM,SLX.LX_SERIE,SLX.LX_ITEM " +;
				" FROM 	" + RetSqlName("SLX")  +" SLX LEFT JOIN 	" + RetSqlName("ACV")  +" ACV on ACV.ACV_CODPRO  = SLX.LX_PRODUTO " +;
	 			" INNER JOIN " + RetSqlName("SAU") + " SAU " +;
				" ON SAU.D_E_L_E_T_ = ' ' AND SAU.AU_CODFIL = SLX.LX_FILIAL " +;
				" WHERE ACV.ACV_CATEGO IN (SELECT ACU_COD  FROM 	" + RetSqlName("ACU") +;
				"                      WHERE  ACU_CODPAI >= '" + mv_par11 + "'" +;//CATEGORIA
				"                         AND ACU_CODPAI <= '" + mv_par12 + "'" +;//CATEGORIA
				"                         AND D_E_L_E_T_ = ' ') " +;			   
	 			" AND " + LJ7017QryFil(.F.,"SLX")[2]
	If lGestao .AND. lACVComp	// Se a tabela ACV for compartilhada aceito a filial corrente
		cQuery += " AND ACV.ACV_FILIAL = '" + xFilial("ACV") + "' "
	Else 						// Se a tabela ACV for exclusiva comparo as Filiais
		cQuery += " AND ACV.ACV_FILIAL = SLX.LX_FILIAL "
	EndIf
    cQuery += 	" AND ACV.ACV_GRUPO >= '" + mv_par13 + "'" +;
				" AND ACV.ACV_GRUPO <= '" + mv_par14 + "'" +;
				" AND LX_PRODUTO >= '" + mv_par15 + "'" +;
	            " AND LX_PRODUTO <= '" + mv_par16 + "'" +;
	     		" AND LX_PDV >= '" + mv_par07 + "'" +;
	            " AND LX_PDV <= '" + mv_par08 + "'" +;
	     		" AND LX_QTDE <> 0 " +;
	     		" AND LX_TPCANC <> 'D' " +;
	    		" AND LX_DTMOVTO >= '" + DToS(mv_par09) + "'"  +;
			    " AND LX_DTMOVTO <= '" + DToS(mv_par10) + "'"  +;
	 	        " AND ACV.D_E_L_E_T_ = ' ' " +;
	     		" AND SLX.D_E_L_E_T_ = ' ' " +;
			    " GROUP BY SAU.AU_CODGRUP, SAU.AU_DESCRI,LX_FILIAL, LX_PRODUTO, ACV_CATEGO, ACV.ACV_GRUPO, LX_PDV, LX_QTDE, LX_VALOR,LX_CUPOM, LX_SERIE, LX_ITEM "
Else
  	cQuery :=	" SELECT SAU.AU_CODGRUP, SAU.AU_DESCRI,SAU.AU_CODGRUP, SAU.AU_DESCRI,SLX.LX_FILIAL, SLX.LX_PRODUTO, LX_PDV,SLX.LX_QTDE,SLX.LX_VALOR, LX_CUPOM, LX_SERIE " +;
			" FROM 	" + RetSqlName("SLX")  +" SLX ," + RetSqlName("SAU") + " SAU " +;
			" WHERE " +LJ7017QryFil(.F.,"SLX")[2]	 +;
			" AND LX_PRODUTO >= '" + mv_par15 + "'" +;
            " AND LX_PRODUTO <= '" + mv_par16 + "'" +;
     		" AND LX_PDV >= '" + mv_par07 + "'" +;
            " AND LX_PDV <= '" + mv_par08 + "'" +;
     		" AND LX_QTDE <> 0 " +;
     		" AND LX_TPCANC <> 'D' " +;
    		" AND LX_DTMOVTO >= '" + DToS(mv_par09) + "'"  +;
		    " AND LX_DTMOVTO <= '" + DToS(mv_par10) + "'"  +;
     		" AND SLX.LX_FILIAL = SAU.AU_CODFIL "+;
     		" AND SLX.D_E_L_E_T_ = ' ' " +;
		    " GROUP BY SAU.AU_CODGRUP, SAU.AU_DESCRI,LX_FILIAL, LX_PRODUTO, LX_PDV, LX_QTDE, LX_VALOR, LX_CUPOM, LX_SERIE, LX_ITEM "
Endif
   
cQuery := ChangeQuery(cQuery)

DbSelectArea("SLX")
DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), 'SLXTRB', .F., .T.)

	
While SLXTRB->(!Eof()) 			
	
    If cCont == 0 
  		Aadd(aTotal,{SLXTRB->AU_CODGRUP,SLXTRB->LX_VALOR,AllTrim(SLXTRB->AU_DESCRI),SLXTRB->LX_QTDE})
  		lAchou := .T.
    Else             
	    For nI:= 1 to len(aTotal)
	    	If SLXTRB->AU_CODGRUP == aTotal[nI][1]
	    		aTotal[nI][2] := aTotal[nI][2] + SLXTRB->LX_VALOR //incrementa o totalizador da mesma filial
	    		aTotal[nI][4] := aTotal[nI][4] + SLXTRB->LX_QTDE  //incrementa o totalizador da mesma filial
	    		lAchou := .T.
            Endif
	    Next nI
	Endif

	If !lAchou
  		Aadd(aTotal,{SLXTRB->AU_CODGRUP,SLXTRB->LX_VALOR,AllTrim(SLXTRB->AU_DESCRI),SLXTRB->LX_QTDE})//adiciona uma nova filial
	Endif
	cCont ++
	lAchou := .F.
	
	SLXTRB->(dbSkip())

EndDo

SLXTRB->(DbCloseArea())

//Ordernar do maior para o menor valor 
ASORT(aTotal,,,{ | x,y | x[2] > y[2] } )

If len(aTotal) < len(aSerie)
   nTotal := len(aTotal)
Else
   nTotal := len(aSerie)   
Endif

For nI:= 1 to nTotal
	aSerie[nI][1] := "Cod:" + AllTrim(aTotal[nI][1])
	aSerie[nI][2] := aTotal[nI][2]//Total de produtos devolvidos x $unitario do produto
	aSerie[nI][3] := AllTrim(aTotal[nI][1])+"-"+AllTrim(aTotal[nI][3])//Grupo de filial
	aSerie[nI][4] := aTotal[nI][4]//Total
Next nI  

RestArea(aArea)

Return aSerie


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ProcInd07        ³Autor  ³TOTVS               ³ Data ³ 10/07/13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Retorna os valores que serao impressos pelo painel             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Produtos Cancelados >> Filial                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function ProcInd07()

Local aArea  	:= GetArea()
Local cCont		:= 0  // contador de serie
Local cQuery    := "" // Texto SQL que é enviado para o comando TCGenQry
Local aTotal    := {}
Local nI        := 0
Local ny        := 0
Local nTotal    := 0 //limitador do numero de registros por ranking
Local lAchou    := .F.
Local nPos		:= 1
Local aFiliais 	:= Lj7017Fil() // Recebera o retorna dos nomes das Filiais	
	
If lCatProd 
	cQuery :=	" SELECT SLX.LX_FILIAL, SLX.LX_PRODUTO, ACV.ACV_CATEGO,SLX.LX_QTDE, SLX.LX_VALOR, SLX.LX_PDV, SLX.LX_CUPOM, SLX.LX_SERIE, SLX.LX_ITEM " +;
				" FROM 	" + RetSqlName("SLX")  +" SLX LEFT JOIN 	" + RetSqlName("ACV")  +" ACV on ACV.ACV_CODPRO  = SLX.LX_PRODUTO " +;
				" WHERE ACV.ACV_CATEGO IN (SELECT ACU_COD  FROM 	" + RetSqlName("ACU") +;
				"                      WHERE  ACU_CODPAI >= '" + mv_par11 + "'" +;//CATEGORIA
				"                         AND ACU_CODPAI <= '" + mv_par12 + "'" +;//CATEGORIA
				"                         AND D_E_L_E_T_ = ' ') "+;
	       	 	" AND " + LJ7017QryFil(.F.,"SLX")[2]
	If lGestao .AND. lACVComp	// Se a tabela ACV for compartilhada aceito a filial corrente
		cQuery += " AND ACV.ACV_FILIAL = '" + xFilial("ACV") + "' "
	Else 						// Se a tabela ACV for exclusiva comparo as Filiais
		cQuery += " AND ACV.ACV_FILIAL = SLX.LX_FILIAL "
	EndIf
    cQuery += 	" AND ACV.ACV_GRUPO >= '" + mv_par13 + "'" +;
				" AND ACV.ACV_GRUPO <= '" + mv_par14 + "'" +;
				" AND LX_PRODUTO >= '" + mv_par15 + "'" +;
	            " AND LX_PRODUTO <= '" + mv_par16 + "'" +;
	            " AND LX_PDV >= '" + mv_par07 + "'" +;
	            " AND LX_PDV <= '" + mv_par08 + "'" +;
	     		" AND LX_QTDE <> 0 " +;
	     		" AND LX_TPCANC <> 'D' " +; 
	    		" AND LX_DTMOVTO >= '" + DToS(mv_par09) + "'"  +;
			    " AND LX_DTMOVTO <= '" + DToS(mv_par10) + "'"  +;
	            " AND ACV.D_E_L_E_T_ = ' ' " +;
	     		" AND SLX.D_E_L_E_T_ = ' ' " +;
			    " GROUP BY LX_FILIAL, LX_PRODUTO, ACV_CATEGO, LX_QTDE, LX_VALOR, LX_PDV, LX_CUPOM, LX_SERIE, LX_ITEM "
Else
	cQuery :=	" SELECT SLX.LX_FILIAL, SLX.LX_PRODUTO, SLX.LX_QTDE, SLX.LX_VALOR, SLX.LX_PDV, SLX.LX_CUPOM, SLX.LX_SERIE, SLX.LX_ITEM " +;
			" FROM 	" + RetSqlName("SLX")  +" SLX " +;
			" WHERE " +LJ7017QryFil(.F.,"SLX")[2]	 +;
			" AND LX_PRODUTO >= '" + mv_par15 + "'" +;
            " AND LX_PRODUTO <= '" + mv_par16 + "'" +;
            " AND LX_PDV >= '" + mv_par07 + "'" +;
            " AND LX_PDV <= '" + mv_par08 + "'" +;
     		" AND LX_QTDE <> 0 " +;
     		" AND LX_TPCANC <> 'D' " +;
    		" AND LX_DTMOVTO >= '" + DToS(mv_par09) + "'"  +;
		    " AND LX_DTMOVTO <= '" + DToS(mv_par10) + "'"  +;
     		" AND SLX.D_E_L_E_T_ = ' ' "+;
		    " GROUP BY LX_FILIAL, LX_PRODUTO, LX_QTDE, LX_VALOR, LX_PDV, LX_CUPOM, LX_SERIE, LX_ITEM  "
Endif
	
cQuery := ChangeQuery(cQuery)

DbSelectArea("SLX")
DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), 'SLXTRB', .F., .T.)

While SLXTRB->(!Eof()) 			
	
    If cCont == 0 
  		Aadd(aTotal,{SLXTRB->LX_FILIAL,SLXTRB->LX_VALOR,"",SLXTRB->LX_QTDE})
  		lAchou := .T.
    Else             
	    For nI:= 1 to len(aTotal)
	    	If SLXTRB->LX_FILIAL == aTotal[nI][1] 
	    		aTotal[nI][2] := aTotal[nI][2] + SLXTRB->LX_VALOR //incrementa o totalizador da mesma filial
	    		aTotal[nI][4] := aTotal[nI][4] + SLXTRB->LX_QTDE  //incrementa o totalizador da mesma filial
	    		lAchou := .T.
	        Endif
	    Next nI
	Endif
    
    If !lAchou
  		Aadd(aTotal,{SLXTRB->LX_FILIAL,SLXTRB->LX_VALOR,"",SLXTRB->LX_QTDE})//adiciona uma nova filial
    Endif
	
	cCont ++
	
	lAchou := .F.
	
	SLXTRB->(dbSkip())
EndDo
	 
//Ordernar do maior para o menor valor 
ASORT(aTotal,,,{ | x,y | x[2] > y[2] } )

If len(aTotal) < len(aSerie)
   nTotal := len(aTotal)
Else
   nTotal := len(aSerie)   
Endif

For nI:= 1 to nTotal	
	For nY:= 1 to len(aFiliais)
		If alltrim(aTotal[nI][1]) == alltrim(aFiliais[nY][1]) 
			nPos := nY
		Endif	
	Next nY
	aSerie[nI][1] := "Cod:" + AllTrim(aTotal[nI][1])
	aSerie[nI][2] := aTotal[nI][2] //Total de produtos devolvidos x $unitario do produto
	aSerie[nI][3] := AllTrim(aTotal[nI][1])+"-"+AllTrim(aFiliais[nPos][2])  // filial
	aSerie[nI][4] := aTotal[nI][4]//Total
Next nI  

RestArea(aArea)
SLXTRB->(DbCloseArea())

Return aSerie


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ProcInd08        ³Autor  ³TOTVS               ³ Data ³ 02/07/13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Retorna os valores que serao impressos pelo painel             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Produtos Cancelados >> Categoria                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function ProcInd08()

Local aArea  	:= GetArea()
Local cCont		:= 0  // contador de serie
Local cQuery    := "" // Texto SQL que é enviado para o comando TCGenQry
Local aTotal    := {}
Local nI        := 0
Local nTotal    := 0 //limitador do numero de registros por ranking
Local lAchou    := .F.
  
DbSelectArea("ACV")       
DbSetOrder(1) //ACV_FILIAL+ACV_CATEGO+ACV_GRUPO+ACV_CODPRO      

cQuery :=	" SELECT SLX.LX_FILIAL,SLX.LX_PRODUTO,ACV.ACV_CATEGO,SLX.LX_QTDE,SLX.LX_VALOR,ACV.ACV_GRUPO,SLX.LX_PDV,SLX.LX_CUPOM,SLX.LX_SERIE,SLX.LX_ITEM " +;
			" FROM 	" + RetSqlName("SLX")  +" SLX LEFT JOIN 	" + RetSqlName("ACV")  +" ACV on ACV.ACV_CODPRO  = SLX.LX_PRODUTO " +;
			" WHERE ACV.ACV_CATEGO IN (SELECT ACU_COD  FROM 	" + RetSqlName("ACU") +;
			"                      WHERE  ACU_CODPAI >= '" + mv_par11 + "'" +;
			"                         AND ACU_CODPAI <= '" + mv_par12 + "'" +;
			"                         AND D_E_L_E_T_ = ' ') " +;
       	 	" AND " + LJ7017QryFil(.F.,"SLX")[2]
If lGestao .AND. lACVComp	// Se a tabela ACV for compartilhada aceito a filial corrente
	cQuery += " AND ACV.ACV_FILIAL = '" + xFilial("ACV") + "' "
Else 						// Se a tabela ACV for exclusiva comparo as Filiais
	cQuery += " AND ACV.ACV_FILIAL = SLX.LX_FILIAL "
EndIf
cQuery += 	" AND ACV.ACV_GRUPO >= '" + mv_par13 + "'" +;
			" AND ACV.ACV_GRUPO <= '" + mv_par14 + "'" +;
			" AND LX_PRODUTO >= '" + mv_par15 + "'" +;
            " AND LX_PRODUTO <= '" + mv_par16 + "'" +;
     		" AND LX_QTDE <> 0 " +;
     		" AND LX_TPCANC <> 'D' " +;
            " AND LX_PDV >= '" + mv_par07 + "'" +;
            " AND LX_PDV <= '" + mv_par08 + "'" +;
    		" AND LX_DTMOVTO >= '" + DToS(mv_par09) + "'"  +;
		    " AND LX_DTMOVTO <= '" + DToS(mv_par10) + "'"  +;
 	 	    " AND ACV.D_E_L_E_T_ = ' ' " +;
     		" AND SLX.D_E_L_E_T_ = ' ' " +;
		    " GROUP BY SLX.LX_FILIAL,SLX.LX_PRODUTO,ACV.ACV_CATEGO,SLX.LX_QTDE,SLX.LX_VALOR,ACV.ACV_GRUPO,SLX.LX_PDV,SLX.LX_CUPOM,SLX.LX_SERIE,SLX.LX_ITEM "		

cQuery := ChangeQuery(cQuery)

DbSelectArea("SLX")
DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), 'ACVTRB', .F., .T.)

While ACVTRB->(!Eof()) 			
	 
    If cCont == 0 
  		Aadd(aTotal,{ACVTRB->ACV_CATEGO,ACVTRB->LX_VALOR,"",ACVTRB->LX_QTDE})
  		lAchou := .T.
    Else             
	    For nI:= 1 to len(aTotal)
	    	If ACVTRB->ACV_CATEGO == aTotal[nI][1] 
	    		aTotal[nI][2] := aTotal[nI][2] + ACVTRB->LX_VALOR //incrementa o totalizador da mesma categoria
	    		aTotal[nI][4] := aTotal[nI][4] + ACVTRB->LX_QTDE  //incrementa o totalizador da mesma categoria
	    		lAchou := .T.
            Endif
	    Next nI
	Endif

	If !lAchou
  		Aadd(aTotal,{ACVTRB->ACV_CATEGO,ACVTRB->LX_VALOR,"",ACVTRB->LX_QTDE})//adiciona uma nova categoria
    Endif
    
	cCont ++
	
	lAchou := .F.
	
	ACVTRB->(dbSkip())

EndDo
 
//Ordernar do maior para o menor valor 
ASORT(aTotal,,,{ | x,y | x[2] > y[2] } )

If len(aTotal) < len(aSerie)
   nTotal := len(aTotal)
Else
   nTotal := len(aSerie)   
Endif

For nI:= 1 to nTotal
	aSerie[nI][1] := "Cod:" + AllTrim(aTotal[nI][1])
	aSerie[nI][2] := aTotal[nI][2]//Total de produtos devolvidos 
	aSerie[nI][3] := AllTrim(aTotal[nI][1])+"-"+AllTrim(Posicione( "ACU", 1, xFilial("ACU")+aTotal[nI][1], "ACU_DESC" ))//Categoria de produtos
	aSerie[nI][4] := aTotal[nI][4]//Total
Next nI  

RestArea(aArea)
ACVTRB->(DbCloseArea())

Return aSerie


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ProcInd09        ³Autor  ³TOTVS               ³ Data ³ 10/07/13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Retorna os valores que serao impressos pelo painel             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Produtos Cancelados >> Grupo de Produtos                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function ProcInd09()

Local aArea  	:= GetArea()
Local cCont		:= 0// contador de serie cQuery    := ""
Local aTotal    := {}
Local nI        := 0
Local nTotal    := 0 //limitador do numero de registros por ranking
Local lAchou    := .F.  

cQuery :=	" SELECT SLX.LX_FILIAL,SLX.LX_PRODUTO,ACV.ACV_GRUPO,SLX.LX_QTDE,SLX.LX_VALOR,ACV.ACV_CATEGO,SLX.LX_PDV,SLX.LX_CUPOM, SLX.LX_SERIE,SLX.LX_ITEM " +;
			" FROM 	" + RetSqlName("SLX")  +" SLX LEFT JOIN 	" + RetSqlName("ACV")  +" ACV on ACV.ACV_CODPRO  = SLX.LX_PRODUTO " +;
			" WHERE ACV.ACV_CATEGO IN (SELECT ACU_COD  FROM 	" + RetSqlName("ACU") +;
			"                      WHERE  ACU_CODPAI >= '" + mv_par11 + "'" +;
			"                         AND ACU_CODPAI <= '" + mv_par12 + "'" +;
			"                         AND D_E_L_E_T_ = ' ') " +;
       	 	" AND " + LJ7017QryFil(.F.,"SLX")[2]
If lGestao .AND. lACVComp	// Se a tabela ACV for compartilhada aceito a filial corrente
	cQuery += " AND ACV.ACV_FILIAL = '" + xFilial("ACV") + "' "
Else 						// Se a tabela ACV for exclusiva comparo as Filiais
	cQuery += " AND ACV.ACV_FILIAL = SLX.LX_FILIAL "
EndIf
cQuery += 	" AND ACV.ACV_GRUPO >= '" + mv_par13 + "'" +;
			" AND ACV.ACV_GRUPO <= '" + mv_par14 + "'" +;
			" AND LX_PRODUTO >= '" + mv_par15 + "'" +;
			" AND LX_PRODUTO <= '" + mv_par16 + "'" +;
			" AND LX_QTDE <> 0 " +;
			" AND LX_TPCANC <> 'D' " +;
			" AND LX_PDV >= '" + mv_par07 + "'" +;
            " AND LX_PDV <= '" + mv_par08 + "'" +;
			" AND LX_DTMOVTO >= '" + DToS(mv_par09) + "'"  +;
		    " AND LX_DTMOVTO <= '" + DToS(mv_par10) + "'"  +;
			" AND ACV.D_E_L_E_T_ = ' ' " +;
			" AND SLX.D_E_L_E_T_ = ' ' " +;
		    " GROUP BY SLX.LX_FILIAL,SLX.LX_PRODUTO,ACV.ACV_GRUPO,SLX.LX_QTDE,SLX.LX_VALOR,ACV.ACV_CATEGO,SLX.LX_PDV,SLX.LX_CUPOM,SLX.LX_SERIE,SLX.LX_ITEM"		
	
cQuery := ChangeQuery(cQuery)

DbSelectArea("SLX")
DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), 'SLXTRB', .F., .T.)

While SLXTRB->(!Eof()) 			
	 
    If cCont == 0 
  		Aadd(aTotal,{SLXTRB->ACV_GRUPO,SLXTRB->LX_VALOR,"",SLXTRB->LX_QTDE})
		lAchou := .T.
    Else             
	    For nI:= 1 to len(aTotal)
	    	If SLXTRB->ACV_GRUPO == aTotal[nI][1] 
	    		aTotal[nI][2] := aTotal[nI][2] + SLXTRB->LX_VALOR //incrementa o totalizador do mesmo grupo
	    		aTotal[nI][4] := aTotal[nI][4] + SLXTRB->LX_QTDE  //incrementa o totalizador do mesmo grupo
    			lAchou := .T.
            Endif
	    Next nI
	Endif

	If !lAchou
  		Aadd(aTotal,{SLXTRB->ACV_GRUPO,SLXTRB->LX_VALOR,"",SLXTRB->LX_QTDE})//adiciona um novo grupo
	Endif
	
	cCont ++  
	
	lAchou := .F.
	
	SLXTRB->(dbSkip())

EndDo
 
//Ordernar do maior para o menor valor 
ASORT(aTotal,,,{ | x,y | x[2] > y[2] } )

If len(aTotal) < len(aSerie)
   nTotal := len(aTotal)
Else
   nTotal := len(aSerie)   
Endif

For nI:= 1 to nTotal
	aSerie[nI][1] := "Cod:" + AllTrim(aTotal[nI][1])
	aSerie[nI][2] := aTotal[nI][2]//Total de produtos devolvidos 
	aSerie[nI][3] := AllTrim(aTotal[nI][1])+"-"+AllTrim(Posicione("SBM",1,xFilial("SBM")+aTotal[nI][1],"BM_DESC"))//Grupo de produtos 
	aSerie[nI][4] := aTotal[nI][4]//Total
Next nI  

RestArea(aArea)
SLXTRB->(DbCloseArea())

Return aSerie


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ProcInd10        ³Autor  ³TOTVS               ³ Data ³ 02/07/13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Retorna os valores que serao impressos pelo painel             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Produtos Cancelados >> Produto                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function ProcInd10()

Local aArea  	:= GetArea()
Local cCont		:= 0  // contador de serie
Local cQuery    := "" // Texto SQL que é enviado para o comando TCGenQry
Local aTotal    := {}
Local nI        := 0
Local nTotal    := 0 //limitador do numero de registros por ranking
Local lAchou    := .F.
  
If lCatProd 
	cQuery :=	" SELECT SLX.LX_FILIAL,SLX.LX_PRODUTO,SLX.LX_QTDE,SLX.LX_VALOR,ACV.ACV_CATEGO,ACV.ACV_GRUPO,SLX.LX_PDV,SLX.LX_CUPOM, SLX.LX_SERIE, SLX.LX_ITEM " +;
				" FROM 	" + RetSqlName("SLX")  +" SLX LEFT JOIN 	" + RetSqlName("ACV")  +" ACV on ACV.ACV_CODPRO  = SLX.LX_PRODUTO " +;
				" WHERE ACV.ACV_CATEGO IN (SELECT ACU_COD  FROM 	" + RetSqlName("ACU") +;
				"                      WHERE  ACU_CODPAI >= '" + mv_par11 + "'" +;
				"                         AND ACU_CODPAI <= '" + mv_par12 + "'" +;
				"                         AND D_E_L_E_T_ = ' ') " +;
	       	 	" AND " +LJ7017QryFil(.F.,"SLX")[2]
	If lGestao .AND. lACVComp	// Se a tabela ACV for compartilhada aceito a filial corrente
		cQuery += " AND ACV.ACV_FILIAL = '" + xFilial("ACV") + "' "
	Else 						// Se a tabela ACV for exclusiva comparo as Filiais
		cQuery += " AND ACV.ACV_FILIAL = SLX.LX_FILIAL "
	EndIf
	cQuery += 	" AND ACV.ACV_GRUPO >= '" + mv_par13 + "'" +;
				" AND ACV.ACV_GRUPO <= '" + mv_par14 + "'" +;				
				" AND LX_PRODUTO >= '" + mv_par15 + "'" +;
                " AND LX_PRODUTO <= '" + mv_par16 + "'" +;
     			" AND LX_QTDE <> 0 " +;
     			" AND LX_TPCANC <> 'D' " +;
                " AND LX_PDV >= '" + mv_par07 + "'" +;
	            " AND LX_PDV <= '" + mv_par08 + "'" +;  			
    		    " AND LX_DTMOVTO >= '" + DToS(mv_par09) + "'"  +;
			    " AND LX_DTMOVTO <= '" + DToS(mv_par10) + "'"  +;
 	 	        " AND ACV.D_E_L_E_T_ = ' ' " +;                                                                                     
     		    " AND SLX.D_E_L_E_T_ = ' ' " +;
			    " GROUP BY SLX.LX_FILIAL,SLX.LX_PRODUTO,SLX.LX_QTDE,SLX.LX_VALOR,ACV.ACV_CATEGO,ACV.ACV_GRUPO,SLX.LX_PDV,SLX.LX_CUPOM, SLX.LX_SERIE, SLX.LX_ITEM "		
Else
	cQuery :=	" SELECT SLX.LX_FILIAL,SLX.LX_PRODUTO,SLX.LX_QTDE,SLX.LX_VALOR,SLX.LX_CUPOM, SLX.LX_SERIE, SLX.LX_ITEM" +;
				" FROM 	" + RetSqlName("SLX")  +" SLX " +;
				" WHERE "+;
                " LX_FILIAL BETWEEN '" + mv_par03 + "' and '" + mv_par04+"'"+;	  
				" AND LX_PRODUTO >= '" + mv_par15 + "'" +;
                " AND LX_PRODUTO <= '" + mv_par16 + "'" +;
     			" AND LX_QTDE <> 0 " +;
     			" AND LX_TPCANC <> 'D' " +;
                " AND LX_PDV >= '" + mv_par07 + "'" +;
	            " AND LX_PDV <= '" + mv_par08 + "'" +;  			
    		    " AND LX_DTMOVTO >= '" + DToS(mv_par09) + "'"  +;
			    " AND LX_DTMOVTO <= '" + DToS(mv_par10) + "'"  +;
     		    " AND SLX.D_E_L_E_T_ = ' ' "+;
			    " GROUP BY SLX.LX_FILIAL,SLX.LX_PRODUTO,SLX.LX_QTDE,SLX.LX_VALOR,SLX.LX_CUPOM, SLX.LX_SERIE, SLX.LX_ITEM"		    
Endif

cQuery := ChangeQuery(cQuery)
	
DbSelectArea("SLX")
DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), 'SLXTRB', .F., .T.)

While SLXTRB->(!Eof()) 			
	
    If cCont == 0 
  		Aadd(aTotal,{SLXTRB->LX_PRODUTO,SLXTRB->LX_VALOR,"",SLXTRB->LX_QTDE})
  		lAchou := .T.	  
    Else             
	    For nI:= 1 to len(aTotal)
	    	If alltrim(SLXTRB->LX_PRODUTO) == alltrim(aTotal[nI][1])
	    		aTotal[nI][2] := aTotal[nI][2] + SLXTRB->LX_VALOR //incrementa o totalizador da mesma filial e produto
	    		aTotal[nI][4] := aTotal[nI][4] + SLXTRB->LX_QTDE  //incrementa o totalizador da mesma filial e produto
	    		lAchou := .T.
            Endif
	    Next nI
	Endif
    
	If !lAchou
		Aadd(aTotal,{SLXTRB->LX_PRODUTO,SLXTRB->LX_VALOR,"",SLXTRB->LX_QTDE})//adiciona uma nova filial
	Endif
		
	cCont ++
	
	lAchou := .F.
		
	SLXTRB->(dbSkip())

EndDo
 
//Ordernar do maior para o menor valor 
ASORT(aTotal,,,{ | x,y | x[2] > y[2] } )

If len(aTotal) < len(aSerie)
   nTotal := len(aTotal)
Else
   nTotal := len(aSerie)   
Endif

For nI:= 1 to nTotal
	aSerie[nI][1] := "Cod:" + AllTrim(aTotal[nI][1])
	aSerie[nI][2] := aTotal[nI][2] //Total de produtos devolvidos 
	aSerie[nI][3] := AllTrim(aTotal[nI][1])+"-"+AllTrim(Posicione( "SB1", 1, xFilial("SB1")+alltrim(aTotal[nI][1]), "B1_DESC" )) //Produto - Descricao
	aSerie[nI][4] := aTotal[nI][4]//Total
Next nI  

RestArea(aArea)
SLXTRB->(DbCloseArea())


Return aSerie

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ProcInd11    ³Autor  ³TOTVS               ³ Data ³ 02/07/13     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Retorna os valores que serao impressos pelo painel             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Venda Perdida >> Grupo filial                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function ProcInd11()

Local aArea  	:= GetArea()
Local cCont		:= 0  // contador de serie
Local cQuery    := "" // Texto SQL que é enviado para o comando TCGenQry
Local aTotal    := {}
Local nI,nY     := 0
Local nTotal    := 0 //limitador do numero de registros por ranking
Local lAchou    := .F.  
Local cFiliais  := ""
Local nPrecoTab := 0

If lCatProd 
  	cQuery := " SELECT DISTINCT SAU.AU_CODGRUP,SAU.AU_DESCRI,MBR.MBR_FILIAL,MBR.MBR_CODIGO,MBR.MBR_PROD,MBR.MBR_QUANT,MBR.MBR_DOC,MBR.MBR_SERIE,MBR.MBR_NUMORC,ACV.ACV_CATEGO,ACV_GRUPO " +;
				" FROM " + RetSqlName("MBR")  +" MBR " +;
				" LEFT JOIN " + RetSqlName("ACV")  +" ACV on ACV.ACV_CODPRO  = MBR.MBR_PROD " +; 
				" INNER JOIN " + RetSqlName("SAU") + " SAU " +;
				" ON SAU.D_E_L_E_T_ = ' ' AND SAU.AU_CODFIL = MBR.MBR_FILIAL " +;
				" WHERE ACV.ACV_CATEGO IN (SELECT ACU_COD  FROM 	" + RetSqlName("ACU") +;
				"                      WHERE  ACU_CODPAI >= '" + mv_par11 + "'" +;//CATEGORIA
				"                         AND ACU_CODPAI <= '" + mv_par12 + "'" +;//CATEGORIA
				"                         AND D_E_L_E_T_ = ' ') " +;
	       	 	" AND " + LJ7017QryFil(.F.,"MBR")[2]
	If lGestao .AND. lACVComp	// Se a tabela ACV for compartilhada aceito a filial corrente
		cQuery += " AND ACV.ACV_FILIAL = '" + xFilial("ACV") + "' "
	Else 						// Se a tabela ACV for exclusiva comparo as Filiais
		cQuery += " AND ACV.ACV_FILIAL = MBR.MBR_FILIAL "
	EndIf
	cQuery += 	" AND ACV.ACV_GRUPO >= '" + mv_par13 + "'" +;
				" AND ACV.ACV_GRUPO <= '" + mv_par14 + "'" +;
				" AND MBR_PROD >= '" + mv_par15 + "'" +;
	            " AND MBR_PROD <= '" + mv_par16 + "'" +;
				" AND MBR_PDV >= '" + mv_par07 + "'" +;
				" AND MBR_PDV <= '" + mv_par08 + "'" +;
	 			" AND MBR_MOTIVO >= '" + mv_par19 + "'" +;
				" AND MBR_MOTIVO <= '" + mv_par20 + "'" +;  
				" AND MBR_ESTACA >= '" + mv_par05 + "'" +;
			    " AND MBR_ESTACA <= '" + mv_par06 + "'" +;
			    " AND MBR_EMISSA >= '" + DToS(mv_par09) + "'" +;
			    " AND MBR_EMISSA <= '" + DToS(mv_par10) + "'" +;
			    " AND ACV.D_E_L_E_T_ = ' ' " +;
	   		    " AND MBR.D_E_L_E_T_ = ' ' " +;
				" GROUP BY SAU.AU_CODGRUP,SAU.AU_DESCRI,MBR.MBR_FILIAL,MBR.MBR_CODIGO,MBR.MBR_PROD,MBR.MBR_QUANT,MBR.MBR_DOC,MBR.MBR_SERIE,MBR.MBR_NUMORC,ACV.ACV_CATEGO,ACV_GRUPO" 	 
Else
    cQuery := " SELECT DISTINCT SAU.AU_CODGRUP,SAU.AU_DESCRI,MBR.MBR_FILIAL,MBR.MBR_CODIGO,MBR.MBR_PROD,MBR.MBR_QUANT,MBR.MBR_DOC,MBR.MBR_SERIE,MBR.MBR_NUMORC " +;
			" FROM 	" + RetSqlName("MBR")  +" MBR " +;
			" INNER JOIN " + RetSqlName("SAU") + " SAU " +;
			" ON SAU.D_E_L_E_T_ = ' ' AND SAU.AU_CODFIL = MBR.MBR_FILIAL " +;
			" WHERE " + LJ7017QryFil(.F.,"MBR")[2]	+;
			" AND MBR_PROD >= '" + mv_par15 + "'" +;
            " AND MBR_PROD <= '" + mv_par16 + "'" +;
			" AND MBR_PDV >= '" + mv_par07 + "'" +;
			" AND MBR_PDV <= '" + mv_par08 + "'" +;
 			" AND MBR_MOTIVO >= '" + mv_par19 + "'" +;
			" AND MBR_MOTIVO <= '" + mv_par20 + "'" +;  
			" AND MBR_ESTACA >= '" + mv_par05 + "'" +;
		    " AND MBR_ESTACA <= '" + mv_par06 + "'" +;
		    " AND MBR_EMISSA >= '" + DToS(mv_par09) + "'"  +;
		    " AND MBR_EMISSA <= '" + DToS(mv_par10) + "'"  +;
		    " AND MBR.MBR_FILIAL = SAU.AU_CODFIL " +;
  		    " AND MBR.D_E_L_E_T_ = ' ' " +;
			" GROUP BY SAU.AU_CODGRUP,SAU.AU_DESCRI,MBR.MBR_FILIAL,MBR.MBR_CODIGO,MBR.MBR_PROD,MBR.MBR_QUANT,MBR.MBR_DOC,MBR.MBR_SERIE,MBR.MBR_NUMORC " 	 	
Endif

cQuery := ChangeQuery(cQuery)                             	

DbSelectArea("MBR")
DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), 'MBRTRB', .F., .T.)
cTabPad 	:= SuperGetMV("MV_TABPAD")
While MBRTRB->(!Eof()) 			
	nPrecoTab := LJ7017Prec(MBRTRB->MBR_PROD)
    If cCont == 0
  		Aadd(aTotal,{MBRTRB->AU_CODGRUP, (MBRTRB->MBR_QUANT * nPrecoTab),AllTrim(MBRTRB->AU_DESCRI),MBRTRB->MBR_QUANT})
  		lAchou := .T.
    Else             
	    For nI:= 1 to len(aTotal)
	    	If MBRTRB->AU_CODGRUP == aTotal[nI][1] 
	    		aTotal[nI][2] := aTotal[nI][2] + (MBRTRB->MBR_QUANT * nPrecoTab) //incrementa o totalizador da mesma filial
	    		aTotal[nI][4] := aTotal[nI][4] + MBRTRB->MBR_QUANT  //incrementa o totalizador da mesma filial
	    		lAchou := .T.
            Endif
	    Next nI
	Endif

	If !lAchou
  		Aadd(aTotal,{MBRTRB->AU_CODGRUP,(MBRTRB->MBR_QUANT * nPrecoTab),AllTrim(MBRTRB->AU_DESCRI),MBRTRB->MBR_QUANT})//adiciona uma nova filial
	Endif
	cCont ++
	lAchou := .F.
	
	MBRTRB->(dbSkip())	
EndDo
                                                                    
MBRTRB->(DbCloseArea())
 
//Ordernar do maior para o menor valor 
ASORT(aTotal,,,{ | x,y | x[2] > y[2] } )

If len(aTotal) < len(aSerie)
   nTotal := len(aTotal)
Else
   nTotal := len(aSerie)   
Endif

For nI:= 1 to nTotal
	aSerie[nI][1] := "Cod:" + AllTrim(aTotal[nI][1])
	aSerie[nI][2] := aTotal[nI][2]//Total de produtos devolvidos x $unitario do produto
	aSerie[nI][3] := AllTrim(aTotal[nI][1])+"-"+AllTrim(aTotal[nI][3])//Grupo filial
	aSerie[nI][4] := aTotal[nI][4]//Total
Next nI  

RestArea(aArea)

Return aSerie


/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ProcInd12    ³Autor  ³TOTVS               ³ Data ³ 11/07/13     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Retorna os valores que serao impressos pelo painel             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Venda Perdida >> Filial        	                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function ProcInd12()

Local aArea  	:= GetArea()
Local cCont		:= 0  // contador de serie
Local cQuery    := "" // Texto SQL que é enviado para o comando TCGenQry
Local aTotal    := {}
Local nI        := 0
Local nTotal    := 0 //limitador do numero de registros por ranking
Local lAchou    := .F.  
Local nPos		:= 1
Local aFiliais 	:= Lj7017Fil()// Recebera o retorna dos nomes das Filiais	
Local nY        := 0
Local nPrecoTab := 0

If lCatProd 
  	cQuery := 	" SELECT DISTINCT MBR.MBR_FILIAL,MBR.MBR_CODIGO,MBR.MBR_PROD,MBR.MBR_QUANT,MBR.MBR_DOC,MBR.MBR_SERIE,MBR.MBR_NUMORC,ACV.ACV_CATEGO,ACV_GRUPO " +;
				" FROM 	" + RetSqlName("MBR")  +" MBR LEFT JOIN 	" + RetSqlName("ACV")  +" ACV on ACV.ACV_CODPRO  = MBR.MBR_PROD " +;
				" WHERE ACV.ACV_CATEGO IN (SELECT ACU_COD  FROM 	" + RetSqlName("ACU") +;
				"                      WHERE  ACU_CODPAI >= '" + mv_par11 + "'" +;//CATEGORIA
				"                         AND ACU_CODPAI <= '" + mv_par12 + "'" +;//CATEGORIA
				"                         AND D_E_L_E_T_ = ' ') "+;
	       	 	" AND " + LJ7017QryFil(.F.,"MBR")[2]
	If lGestao .AND. lACVComp	// Se a tabela ACV for compartilhada aceito a filial corrente
		cQuery += " AND ACV.ACV_FILIAL = '" + xFilial("ACV") + "' "
	Else 						// Se a tabela ACV for exclusiva comparo as Filiais
		cQuery += " AND ACV.ACV_FILIAL = MBR.MBR_FILIAL "
	EndIf
	cQuery += 	" AND ACV.ACV_GRUPO >= '" + mv_par13 + "'" +;
				" AND ACV.ACV_GRUPO <= '" + mv_par14 + "'" +;
	 	 		" AND MBR_PROD >= '" + mv_par15 + "'" +;
	            " AND MBR_PROD <= '" + mv_par16 + "'" +;
				" AND MBR_PDV >= '" + mv_par07 + "'" +;
				" AND MBR_PDV <= '" + mv_par08 + "'" +;
	 			" AND MBR_MOTIVO >= '" + mv_par19 + "'" +;
				" AND MBR_MOTIVO <= '" + mv_par20 + "'" +;  
				" AND MBR_ESTACA >= '" + mv_par05 + "'" +;
			    " AND MBR_ESTACA <= '" + mv_par06 + "'" +;
			    " AND MBR_EMISSA >= '" + DToS(mv_par09) + "'"  +;
			    " AND MBR_EMISSA <= '" + DToS(mv_par10) + "'"  +;
			    " AND ACV.D_E_L_E_T_ = ' ' " +;
	     		" AND MBR.D_E_L_E_T_ = ' ' " +;
				" GROUP BY MBR.MBR_FILIAL,MBR.MBR_CODIGO,MBR.MBR_PROD,MBR.MBR_QUANT,MBR.MBR_DOC,MBR.MBR_SERIE,MBR.MBR_NUMORC,ACV.ACV_CATEGO,ACV_GRUPO" 	 
Else
  	cQuery :=	" SELECT DISTINCT MBR.MBR_FILIAL,MBR.MBR_CODIGO,MBR.MBR_PROD,MBR.MBR_QUANT,MBR.MBR_DOC,MBR.MBR_SERIE,MBR.MBR_NUMORC " +;
				" FROM 	" + RetSqlName("MBR") +" MBR "+;
			    " WHERE " + LJ7017QryFil(.F.,"MBR")[2]	+;
 	 			" AND MBR_PROD >= '" + mv_par15 + "'" +;
                " AND MBR_PROD <= '" + mv_par16 + "'" +;
				" AND MBR_PDV >= '" + mv_par07 + "'" +;
				" AND MBR_PDV <= '" + mv_par08 + "'" +;
	 			" AND MBR_MOTIVO >= '" + mv_par19 + "'" +;
				" AND MBR_MOTIVO <= '" + mv_par20 + "'" +;  
				" AND MBR_ESTACA >= '" + mv_par05 + "'" +;
			    " AND MBR_ESTACA <= '" + mv_par06 + "'"   +;
			    " AND MBR_EMISSA >= '" + DToS(mv_par09) + "'"  +;
			    " AND MBR_EMISSA <= '" + DToS(mv_par10) + "'"  +;
     		    " AND MBR.D_E_L_E_T_ = ' ' "+;
				" GROUP BY MBR.MBR_FILIAL,MBR.MBR_CODIGO,MBR.MBR_PROD,MBR.MBR_QUANT,MBR.MBR_DOC,MBR.MBR_SERIE,MBR.MBR_NUMORC " 	 
Endif

cQuery := ChangeQuery(cQuery)

DbSelectArea("MBR")
DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), 'MBRTRB', .F., .T.)

While MBRTRB->(!Eof()) 			
	nPrecoTab := LJ7017Prec(MBRTRB->MBR_PROD)
    If cCont == 0
  		Aadd(aTotal,{MBRTRB->MBR_FILIAL, (MBRTRB->MBR_QUANT * nPrecoTab),"",MBRTRB->MBR_QUANT})
  		lAchou := .T.
    Else             
	    For nI:= 1 to len(aTotal)
	    	If MBRTRB->MBR_FILIAL == aTotal[nI][1] 
	    		aTotal[nI][2] := aTotal[nI][2] + (MBRTRB->MBR_QUANT * nPrecoTab) //incrementa o totalizador da mesma filial
	    		aTotal[nI][4] := aTotal[nI][4] + MBRTRB->MBR_QUANT
	    		lAchou := .T.
            Endif
	    Next nI
	Endif

	If !lAchou
  		Aadd(aTotal,{MBRTRB->MBR_FILIAL, (MBRTRB->MBR_QUANT * nPrecoTab),"",MBRTRB->MBR_QUANT})//adiciona uma nova filial
	Endif
	cCont ++
	lAchou := .F.
	
	MBRTRB->(dbSkip())

EndDo
 
//Ordernar do maior para o menor valor 
ASORT(aTotal,,,{ | x,y | x[2] > y[2] } )

If len(aTotal) < len(aSerie)
   nTotal := len(aTotal)
Else
   nTotal := len(aSerie)   
Endif

For nI:= 1 to nTotal	

	For nY:= 1 to len(aFiliais)
		If alltrim(aTotal[nI][1]) == alltrim(aFiliais[nY][1]) 
			nPos := nY
		Endif	
	Next nY	
	
	aSerie[nI][1] := "Cod:" + AllTrim(aTotal[nI][1])
	aSerie[nI][2] := aTotal[nI][2]//Total de produtos devolvidos x $unitario do produto
	aSerie[nI][3] := AllTrim(aTotal[nI][1])+"-"+AllTrim(aFiliais[nPos][2])//Filial 
	aSerie[nI][4] := aTotal[nI][4]//Total
Next nI  

RestArea(aArea)
MBRTRB->(DbCloseArea())

Return aSerie


/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ProcInd13    ³Autor  ³TOTVS               ³ Data ³ 11/07/13     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Retorna os valores que serao impressos pelo painel             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Venda Perdida >> Motivo       	                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function ProcInd13()

Local aArea  	:= GetArea()
Local cCont		:= 0  // contador de serie
Local cQuery    := "" // Texto SQL que é enviado para o comando TCGenQry
Local aTotal    := {}
Local nI        := 0
Local nTotal    := 0 //limitador do numero de registros por ranking
Local lAchou    := .F.  
Local nPrecoTab := 0

If lCatProd 
  	cQuery :=	" SELECT DISTINCT MBR.MBR_FILIAL,MBR.MBR_CODIGO,MBR.MBR_MOTIVO,MBR.MBR_PROD,MBR.MBR_QUANT,MBR.MBR_DOC,MBR.MBR_SERIE,MBR.MBR_NUMORC,ACV.ACV_CATEGO,ACV_GRUPO " +;
				" FROM 	" + RetSqlName("MBR")  +" MBR LEFT JOIN 	" + RetSqlName("ACV")  +"  ACV on ACV.ACV_CODPRO  = MBR.MBR_PROD " +;
				" WHERE ACV.ACV_CATEGO IN (SELECT ACU_COD  FROM 	" + RetSqlName("ACU") +;
				"                      WHERE  ACU_CODPAI >= '" + mv_par11 + "'" +;//CATEGORIA
				"                         AND ACU_CODPAI <= '" + mv_par12 + "'" +;//CATEGORIA
				"                         AND D_E_L_E_T_ = ' ') " +;
	       	 	" AND " + LJ7017QryFil(.F.,"MBR")[2]
	If lGestao .AND. lACVComp	// Se a tabela ACV for compartilhada aceito a filial corrente
		cQuery += " AND ACV.ACV_FILIAL = '" + xFilial("ACV") + "' "
	Else 						// Se a tabela ACV for exclusiva comparo as Filiais
		cQuery += " AND ACV.ACV_FILIAL = MBR.MBR_FILIAL "
	EndIf
	cQuery += 	" AND ACV.ACV_GRUPO >= '" + mv_par13 + "'" +;
				" AND ACV.ACV_GRUPO <= '" + mv_par14 + "'" +;
 	 			" AND MBR_PROD >= '" + mv_par15 + "'" +;
                " AND MBR_PROD <= '" + mv_par16 + "'" +;
				" AND MBR_PDV >= '" + mv_par07 + "'" +;
				" AND MBR_PDV <= '" + mv_par08 + "'" +;
	 			" AND MBR_MOTIVO >= '" + mv_par19 + "'" +;
				" AND MBR_MOTIVO <= '" + mv_par20 + "'" +;
				" AND MBR_ESTACA >= '" + mv_par05 + "'" +;
			    " AND MBR_ESTACA <= '" + mv_par06 + "'" +;
			    " AND MBR_EMISSA >= '" + DToS(mv_par09) + "'" +;
			    " AND MBR_EMISSA <= '" + DToS(mv_par10) + "'" +;
			    " AND ACV.D_E_L_E_T_ = ' ' " +;
     		    " AND MBR.D_E_L_E_T_ = ' ' " +;
				" GROUP BY MBR.MBR_FILIAL,MBR.MBR_CODIGO,MBR.MBR_MOTIVO,MBR.MBR_PROD,MBR.MBR_QUANT,MBR.MBR_DOC,MBR.MBR_SERIE,MBR.MBR_NUMORC,ACV.ACV_CATEGO,ACV_GRUPO" 	 
Else
  	cQuery :=	" SELECT DISTINCT MBR.MBR_FILIAL,MBR.MBR_CODIGO,MBR.MBR_MOTIVO,MBR.MBR_PROD,MBR.MBR_QUANT,MBR.MBR_DOC,MBR.MBR_SERIE,MBR.MBR_NUMORC " +;
				" FROM 	" + RetSqlName("SD2")+" SD2, "+ RetSqlName("MBR") + " MBR "+;
				" WHERE " + LJ7017QryFil(.F.,"MBR")[2]	+;
	 	 		" AND MBR_PROD >= '" + mv_par15 + "'" +;
	            " AND MBR_PROD <= '" + mv_par16 + "'" +;
				" AND MBR_PDV >= '" + mv_par07 + "'" +;
				" AND MBR_PDV <= '" + mv_par08 + "'" +;
	 			" AND MBR_MOTIVO >= '" + mv_par19 + "'" +;
				" AND MBR_MOTIVO <= '" + mv_par20 + "'" +;  
				" AND MBR_ESTACA >= '" + mv_par05 + "'" +;
			    " AND MBR_ESTACA <= '" + mv_par06 + "'" +;
			    " AND MBR_EMISSA >= '" + DToS(mv_par09) + "'" +;
			    " AND MBR_EMISSA <= '" + DToS(mv_par10) + "'" +;
	     		" AND MBR.D_E_L_E_T_ = ' ' " +;
				" GROUP BY MBR.MBR_FILIAL,MBR.MBR_CODIGO,MBR.MBR_MOTIVO,MBR.MBR_PROD,MBR.MBR_QUANT,MBR.MBR_DOC,MBR.MBR_SERIE,MBR.MBR_NUMORC" 	 

Endif	

cQuery := ChangeQuery(cQuery)
	
DbSelectArea("MBR")
DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), 'MBRTRB', .F., .T.)

While MBRTRB->(!Eof()) 			
	nPrecoTab := LJ7017Prec(MBRTRB->MBR_PROD)
    If cCont == 0 
  		Aadd(aTotal,{MBRTRB->MBR_MOTIVO, (MBRTRB->MBR_QUANT * nPrecoTab),"",MBRTRB->MBR_QUANT})
  		lAchou := .T.
    Else             
	    For nI:= 1 to len(aTotal)
	    	If MBRTRB->MBR_MOTIVO == aTotal[nI][1]
	    		aTotal[nI][2] := aTotal[nI][2] + (MBRTRB->MBR_QUANT * nPrecoTab) //incrementa o totalizador da mesma filial
	    		aTotal[nI][4] := aTotal[nI][4] + MBRTRB->MBR_QUANT
	    		lAchou := .T.
            Endif
	    Next nI
	Endif

	If !lAchou
  		Aadd(aTotal,{MBRTRB->MBR_MOTIVO, (MBRTRB->MBR_QUANT * nPrecoTab),"",MBRTRB->MBR_QUANT})
	Endif
	cCont ++
	lAchou := .F.
	
	MBRTRB->(dbSkip())

EndDo
 
//Ordernar do maior para o menor valor 
ASORT(aTotal,,,{ | x,y | x[2] > y[2] } )

If len(aTotal) < len(aSerie)
   nTotal := len(aTotal)
Else
   nTotal := len(aSerie)   
Endif

For nI:= 1 to nTotal
	aSerie[nI][1] := "Cod:" + AllTrim(aTotal[nI][1])
	aSerie[nI][2] := aTotal[nI][2]//Total de motivos
	aSerie[nI][3] := AllTrim(aTotal[nI][1])+"-"+AllTrim(Posicione( "MBQ", 1, xFilial("MBQ")+aTotal[nI][1], "MBQ_DSCVEP" ))//motivo 
	aSerie[nI][4] := aTotal[nI][4]//Total
Next nI  

RestArea(aArea)
MBRTRB->(DbCloseArea())

Return aSerie


/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ProcInd15    ³Autor  ³TOTVS               ³ Data ³ 11/07/13     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Retorna os valores que serao impressos pelo painel             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Venda Perdida >> Categoria de produtos                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function ProcInd14()

Local aArea  	:= GetArea()
Local cCont		:= 0  // contador de serie
Local cQuery    := "" // Texto SQL que é enviado para o comando TCGenQry
Local aTotal    := {}
Local nI        := 0
Local nTotal    := 0 //limitador do numero de registros por ranking
Local lAchou    := .F.  
Local nPrecoTab := 0

DbSelectArea("MBR")       
DbSetOrder(1)//MBR_FILIAL+MBR_CODIGO+MBR_NUMORC+MBR_DOC+MBR_SERIE+MBR_PROD+MBR_ITEM                                                                                            

cQuery :=	" SELECT DISTINCT MBR.MBR_FILIAL,ACV.ACV_CATEGO,MBR.MBR_CODIGO,MBR.MBR_PROD,MBR.MBR_QUANT,MBR.MBR_DOC,MBR.MBR_SERIE,MBR.MBR_NUMORC,ACV.ACV_CATEGO,ACV_GRUPO " +;
			" FROM 	" + RetSqlName("MBR")  +" MBR LEFT JOIN 	" + RetSqlName("ACV")  +" ACV on ACV.ACV_CODPRO  = MBR.MBR_PROD " +;
			" WHERE ACV.ACV_CATEGO IN (SELECT ACU_COD  FROM 	" + RetSqlName("ACU") +;
			"                      WHERE  ACU_CODPAI >= '" + mv_par11 + "'" +;//CATEGORIA
			"                         AND ACU_CODPAI <= '" + mv_par12 + "'" +;//CATEGORIA
			"                         AND D_E_L_E_T_ = ' ') " +;
	  		" AND " + LJ7017QryFil(.F.,"MBR")[2]
If lGestao .AND. lACVComp	// Se a tabela ACV for compartilhada aceito a filial corrente
	cQuery += " AND ACV.ACV_FILIAL = '" + xFilial("ACV") + "' "
Else 						// Se a tabela ACV for exclusiva comparo as Filiais
	cQuery += " AND ACV.ACV_FILIAL = MBR.MBR_FILIAL "
EndIf
cQuery += 	" AND ACV.ACV_GRUPO >= '" + mv_par13 + "'" +;
			" AND ACV.ACV_GRUPO <= '" + mv_par14 + "'" +;
 			" AND MBR_PROD >= '" + mv_par15 + "'" +;
            " AND MBR_PROD <= '" + mv_par16 + "'" +;
			" AND MBR_PDV >= '" + mv_par07 + "'" +;
			" AND MBR_PDV <= '" + mv_par08 + "'" +;
 			" AND MBR_MOTIVO >= '" + mv_par19 + "'" +;
			" AND MBR_MOTIVO <= '" + mv_par20 + "'" +;  
			" AND MBR_ESTACA >= '" + mv_par05 + "'" +;
		    " AND MBR_ESTACA <= '" + mv_par06 + "'" +;
		    " AND MBR_EMISSA >= '" + DToS(mv_par09) + "'"  +;
		    " AND MBR_EMISSA <= '" + DToS(mv_par10) + "'"  +;
		    " AND ACV.D_E_L_E_T_ = ' ' " +;
  		    " AND MBR.D_E_L_E_T_ = ' ' " +;
			" GROUP BY MBR.MBR_FILIAL,ACV.ACV_CATEGO,MBR.MBR_CODIGO,MBR.MBR_PROD,MBR.MBR_QUANT,MBR.MBR_DOC,MBR.MBR_SERIE,MBR.MBR_NUMORC,ACV.ACV_CATEGO,ACV_GRUPO" 	 
					
cQuery := ChangeQuery(cQuery)

DbSelectArea("MBR")
DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), 'MBRTRB', .F., .T.)

While MBRTRB->(!Eof())
	nPrecoTab := LJ7017Prec(MBRTRB->MBR_PROD)
    If cCont == 0 
  		Aadd(aTotal,{MBRTRB->ACV_CATEGO, (MBRTRB->MBR_QUANT * nPrecoTab),"",MBRTRB->MBR_QUANT})
  		lAchou := .T.
    Else             
	    For nI:= 1 to len(aTotal)
	    	If MBRTRB->ACV_CATEGO == aTotal[nI][1] 
	    		aTotal[nI][2] := aTotal[nI][2] + (MBRTRB->MBR_QUANT * nPrecoTab) //incrementa o totalizador da mesma categoria
	    		aTotal[nI][4] := aTotal[nI][4] + MBRTRB->MBR_QUANT
	    		lAchou := .T.
            Endif
	    Next nI
	Endif

	If !lAchou
  		Aadd(aTotal,{MBRTRB->ACV_CATEGO, (MBRTRB->MBR_QUANT * nPrecoTab),"",MBRTRB->MBR_QUANT})
	Endif
	cCont ++
	lAchou := .F.
	
	MBRTRB->(dbSkip())

EndDo
 
//Ordernar do maior para o menor valor 
ASORT(aTotal,,,{ | x,y | x[2] > y[2] } )

If len(aTotal) < len(aSerie)
   nTotal := len(aTotal)
Else
   nTotal := len(aSerie)   
Endif

For nI:= 1 to nTotal
	aSerie[nI][1] := "Cod:" + AllTrim(aTotal[nI][1])
	aSerie[nI][2] := aTotal[nI][2]//Total de categorias
	aSerie[nI][3] := AllTrim(aTotal[nI][1])+"-"+AllTrim(Posicione( "ACU", 1, xFilial("ACU")+aTotal[nI][1], "ACU_DESC" ))//Categoria de produtos
	aSerie[nI][4] := aTotal[nI][4]//Total
Next nI  

RestArea(aArea)
MBRTRB->(DbCloseArea())

Return aSerie

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ProcInd16    ³Autor  ³TOTVS               ³ Data ³ 11/07/13     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Retorna os valores que serao impressos pelo painel             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Venda Perdida >> Grupo de produtos                             ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function ProcInd15()

Local aArea  	:= GetArea()
Local cCont		:= 0  // contador de serie
Local cQuery    := "" // Texto SQL que é enviado para o comando TCGenQry
Local aTotal    := {}
Local nI        := 0
Local nTotal    := 0 //limitador do numero de registros por ranking
Local lAchou    := .F.  
Local nPrecoTab := 0

DbSelectArea("MBR")       
DbSetOrder(1)//MBR_FILIAL+MBR_CODIGO+MBR_NUMORC+MBR_DOC+MBR_SERIE+MBR_PROD+MBR_ITEM                                                                                            

cQuery :=	" SELECT DISTINCT MBR.MBR_FILIAL,MBR.MBR_CODIGO,ACV.ACV_GRUPO,MBR.MBR_PROD,MBR.MBR_QUANT,MBR.MBR_DOC,MBR.MBR_SERIE,MBR.MBR_NUMORC,ACV.ACV_CATEGO,ACV_GRUPO " +;
			" FROM 	" + RetSqlName("MBR")  +" MBR LEFT JOIN 	" + RetSqlName("ACV")  +" ACV on ACV.ACV_CODPRO  = MBR.MBR_PROD " +;
			" WHERE ACV.ACV_CATEGO IN (SELECT ACU_COD  FROM 	" + RetSqlName("ACU") +;
			"                      WHERE  ACU_CODPAI >= '" + mv_par11 + "'" +;//CATEGORIA
			"                         AND ACU_CODPAI <= '" + mv_par12 + "'" +;//CATEGORIA
			"                         AND D_E_L_E_T_ = ' ') " +;
	  		" AND " + LJ7017QryFil(.F.,"MBR")[2]
If lGestao .AND. lACVComp	// Se a tabela ACV for compartilhada aceito a filial corrente
	cQuery += " AND ACV.ACV_FILIAL = '" + xFilial("ACV") + "' "
Else 						// Se a tabela ACV for exclusiva comparo as Filiais
	cQuery += " AND ACV.ACV_FILIAL = MBR.MBR_FILIAL "
EndIf
cQuery += 	" AND ACV.ACV_GRUPO >= '" + mv_par13 + "'" +;
			" AND ACV.ACV_GRUPO <= '" + mv_par14 + "'" +;
 	 		" AND MBR_PROD >= '" + mv_par15 + "'" +;
            " AND MBR_PROD <= '" + mv_par16 + "'" +;
			" AND MBR_PDV >= '" + mv_par07 + "'" +;
			" AND MBR_PDV <= '" + mv_par08 + "'" +;
 			" AND MBR_MOTIVO >= '" + mv_par19 + "'" +;
			" AND MBR_MOTIVO <= '" + mv_par20 + "'" +;
			" AND MBR_ESTACA >= '" + mv_par05 + "'" +;
		    " AND MBR_ESTACA <= '" + mv_par06 + "'" +;
		    " AND MBR_EMISSA >= '" + DToS(mv_par09) + "'" +;
		    " AND MBR_EMISSA <= '" + DToS(mv_par10) + "'" +;
		    " AND ACV.D_E_L_E_T_ = ' ' " +;
     		" AND MBR.D_E_L_E_T_ = ' ' " +;
			" GROUP BY MBR.MBR_FILIAL,MBR.MBR_CODIGO,ACV.ACV_GRUPO,MBR.MBR_PROD,MBR.MBR_QUANT,MBR.MBR_DOC,MBR.MBR_SERIE,MBR.MBR_NUMORC,ACV.ACV_CATEGO,ACV_GRUPO"
			
cQuery := ChangeQuery(cQuery)

DbSelectArea("MBR")
DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), 'MBRTRB', .F., .T.)

While MBRTRB->(!Eof())
	nPrecoTab := LJ7017Prec(MBRTRB->MBR_PROD)
    If cCont == 0 
  		Aadd(aTotal,{MBRTRB->ACV_GRUPO, (MBRTRB->MBR_QUANT * nPrecoTab),"",MBRTRB->MBR_QUANT})
  		lAchou := .T.
    Else             
	    For nI:= 1 to len(aTotal)
	    	If MBRTRB->ACV_GRUPO == aTotal[nI][1] 
	    		aTotal[nI][2] := aTotal[nI][2] + (MBRTRB->MBR_QUANT * nPrecoTab) //incrementa o totalizador do mesmo Grupo Produto
	    		aTotal[nI][4] := aTotal[nI][4] + MBRTRB->MBR_QUANT  //incrementa o totalizador do mesmo Grupo Produto
	    		lAchou := .T.
            Endif
	    Next nI
	Endif

	If !lAchou
  		Aadd(aTotal,{MBRTRB->ACV_GRUPO, (MBRTRB->MBR_QUANT * nPrecoTab),"",MBRTRB->MBR_QUANT})//adiciona um novo Grupo Produto
	Endif
	cCont ++
	lAchou := .F.
	
	MBRTRB->(dbSkip())

EndDo
 
//Ordernar do maior para o menor valor 
ASORT(aTotal,,,{ | x,y | x[2] > y[2] } )

If len(aTotal) < len(aSerie)
   nTotal := len(aTotal)
Else
   nTotal := len(aSerie)   
Endif

For nI:= 1 to nTotal
	aSerie[nI][1] := "Cod:" + AllTrim(aTotal[nI][1])
	aSerie[nI][2] := aTotal[nI][2]//Total de categorias
	aSerie[nI][3] := AllTrim(aTotal[nI][1])+"-"+AllTrim(Posicione("SBM",1,xFilial("SBM")+aTotal[nI][1],"BM_DESC"))//Grupo de produtos 
	aSerie[nI][4] := aTotal[nI][4]//Total
Next nI  

RestArea(aArea)
MBRTRB->(DbCloseArea())

Return aSerie

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ProcInd17    ³Autor  ³TOTVS               ³ Data ³ 11/07/13     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Retorna os valores que serao impressos pelo painel             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Venda Perdida >> Produtos 	                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function ProcInd16()

Local aArea  	:= GetArea()
Local cCont		:= 0 // contador de serie
Local cQuery    := ""// Texto SQL que é enviado para o comando TCGenQry
Local aTotal    := {}
Local nI        := 0
Local nTotal    := 0 //limitador do numero de registros por ranking
Local lAchou    := .F.  
Local nPrecoTab := 0

DbSelectArea("MBR")       
DbSetOrder(1)//MBR_FILIAL+MBR_CODIGO+MBR_NUMORC+MBR_DOC+MBR_SERIE+MBR_PROD+MBR_ITEM                                                                                            

If lCatProd 
  	cQuery :=	" SELECT DISTINCT MBR.MBR_FILIAL,MBR.MBR_CODIGO,MBR.MBR_PROD,MBR.MBR_QUANT,MBR.MBR_DOC,MBR.MBR_SERIE,MBR.MBR_NUMORC,ACV.ACV_CATEGO,ACV_GRUPO " +;
				" FROM 	" + RetSqlName("MBR")  +" MBR LEFT JOIN 	" + RetSqlName("ACV")  +" ACV on ACV.ACV_CODPRO  = MBR.MBR_PROD " +;
				" WHERE ACV.ACV_CATEGO IN (SELECT ACU_COD  FROM 	" + RetSqlName("ACU") +;
				"                      WHERE  ACU_CODPAI >= '" + mv_par11 + "'" +;//CATEGORIA
				"                         AND ACU_CODPAI <= '" + mv_par12 + "'" +;//CATEGORIA
				"                         AND D_E_L_E_T_ = ' ') " +;
	  			" AND " + LJ7017QryFil(.F.,"MBR")[2]
	If lGestao .AND. lACVComp	// Se a tabela ACV for compartilhada aceito a filial corrente
		cQuery += " AND ACV.ACV_FILIAL = '" + xFilial("ACV") + "' "
	Else 						// Se a tabela ACV for exclusiva comparo as Filiais
		cQuery += " AND ACV.ACV_FILIAL = MBR.MBR_FILIAL "
	EndIf
	cQuery += 	" AND ACV.ACV_GRUPO >= '" + mv_par13 + "'" +;
				" AND ACV.ACV_GRUPO <= '" + mv_par14 + "'" +;
	 			" AND MBR_PROD >= '" + mv_par15 + "'" +;
	            " AND MBR_PROD <= '" + mv_par16 + "'" +;
	   	       	" AND MBR_PDV >= '" + mv_par07 + "'" +;
				" AND MBR_PDV <= '" + mv_par08 + "'" +;
	 			" AND MBR_MOTIVO >= '" + mv_par19 + "'" +;
				" AND MBR_MOTIVO <= '" + mv_par20 + "'" +;  
				" AND MBR_ESTACA >= '" + mv_par05 + "'" +;
			    " AND MBR_ESTACA <= '" + mv_par06 + "'" +;
			    " AND MBR_EMISSA >= '" + DToS(mv_par09) + "'" +;
			    " AND MBR_EMISSA <= '" + DToS(mv_par10) + "'" +;
			    " AND ACV.D_E_L_E_T_ = ' ' " +;
	     	    " AND MBR.D_E_L_E_T_ = ' ' " +;
				" GROUP BY MBR.MBR_FILIAL,MBR.MBR_CODIGO,MBR.MBR_PROD,MBR.MBR_QUANT,MBR.MBR_DOC,MBR.MBR_SERIE,MBR.MBR_NUMORC,ACV.ACV_CATEGO,ACV_GRUPO" 	 
Else
  	cQuery :=	" SELECT DISTINCT MBR.MBR_FILIAL,MBR.MBR_CODIGO,MBR.MBR_PROD,MBR.MBR_QUANT,MBR.MBR_DOC,MBR.MBR_SERIE,MBR.MBR_NUMORC " +;
				" FROM 	" + RetSqlName("SD2")+" SD2, "+ RetSqlName("MBR")  +" MBR " +;
				" WHERE " + LJ7017QryFil(.F.,"MBR")[2]	+;
	 	 		" AND MBR_PROD >= '" + mv_par15 + "'" +;
	            " AND MBR_PROD <= '" + mv_par16 + "'" +;
				" AND MBR_PDV >= '" + mv_par07 + "'" +;
				" AND MBR_PDV <= '" + mv_par08 + "'" +;
	 			" AND MBR_MOTIVO >= '" + mv_par19 + "'" +;
				" AND MBR_MOTIVO <= '" + mv_par20 + "'" +;  
				" AND MBR_ESTACA >= '" + mv_par05 + "'" +;
			    " AND MBR_ESTACA <= '" + mv_par06 + "'" +;
			    " AND MBR_EMISSA >= '" + DToS(mv_par09) + "'" +;
			    " AND MBR_EMISSA <= '" + DToS(mv_par10) + "'" +;
	     		" AND MBR.D_E_L_E_T_ = ' ' " +;
				" GROUP BY MBR.MBR_FILIAL,MBR.MBR_CODIGO,MBR.MBR_PROD,MBR.MBR_QUANT,MBR.MBR_DOC,MBR.MBR_SERIE,MBR.MBR_NUMORC" 	 
Endif					
					
cQuery := ChangeQuery(cQuery)

DbSelectArea("MBR")
DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), 'MBRTRB', .F., .T.)
	
While MBRTRB->(!Eof()) 			
	nPrecoTab := LJ7017Prec(MBRTRB->MBR_PROD)
    If cCont == 0 
  		Aadd(aTotal,{MBRTRB->MBR_PROD, (MBRTRB->MBR_QUANT * nPrecoTab),"",MBRTRB->MBR_QUANT})
  		lAchou := .T.
    Else             
	    For nI:= 1 to len(aTotal)
	    	If MBRTRB->MBR_PROD == aTotal[nI][1] 
	    		aTotal[nI][2] := aTotal[nI][2] + (MBRTRB->MBR_QUANT * nPrecoTab) //incrementa o totalizador do mesmo Produtos
	    		aTotal[nI][4] := aTotal[nI][4] + MBRTRB->MBR_QUANT  //incrementa o totalizador do mesmo Produtos
	    		lAchou := .T.
            Endif
	    Next nI
	Endif

	If !lAchou
  		Aadd(aTotal,{MBRTRB->MBR_PROD, (MBRTRB->MBR_QUANT * nPrecoTab),"",MBRTRB->MBR_QUANT})//adiciona um novo Produtos
	Endif
	cCont ++
	lAchou := .F.
	
	MBRTRB->(dbSkip())

EndDo
 
//Ordernar do maior para o menor valor 
ASORT(aTotal,,,{ | x,y | x[2] > y[2] } )

If len(aTotal) < len(aSerie)
   nTotal := len(aTotal)
Else
   nTotal := len(aSerie)   
Endif

For nI:= 1 to nTotal
	aSerie[nI][1] := "Cod:" + AllTrim(aTotal[nI][1])
	aSerie[nI][2] := aTotal[nI][2]//Total de produtos
	aSerie[nI][3] := AllTrim(aTotal[nI][1])+"-"+AllTrim(Posicione("SB1",1,xFilial("SB1")+aTotal[nI][1],"B1_DESC"))//Produtos 
	aSerie[nI][4] := aTotal[nI][4]//Total
Next nI  

RestArea(aArea)
MBRTRB->(DbCloseArea())

Return aSerie

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ProcInd17        ³Autor  ³TOTVS               ³ Data ³ 12/07/13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Retorna os valores que serao impressos pelo painel             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ ¢ Produtos com divergência de inventário >> Grupo de Filial    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function ProcInd17()

Local aArea  	:= GetArea()
Local cCont		:= 0 // contador de serie
Local cQuery    := ""// Texto SQL que é enviado para o comando TCGenQry
Local aTotal    := {}
Local nI,nY     := 0
Local nTotal    := 0 //limitador do numero de registros por ranking
Local lAchou    := .F.
Local cFiliais  := ""
Local aSaldo	:= {}
Local nDifInv	:= 0

If lCatProd 
  	cQuery :=	" SELECT DISTINCT SAU.AU_CODGRUP,SAU.AU_DESCRI,SB7.B7_FILIAL,SB7.B7_DATA,SB7.B7_COD,SB7.B7_LOCAL,SB7.B7_QUANT,SB7.B7_DOC,SB1.B1_CUSTD,ACV.ACV_CATEGO,ACV_GRUPO " +;
				" FROM " + RetSqlName("SB1") + " SB1, " + RetSqlName("SB7") + " SB7 " +;
				" LEFT JOIN " + RetSqlName("ACV")  +" ACV on ACV.ACV_CODPRO  = SB7.B7_COD " +;
	 			" INNER JOIN " + RetSqlName("SAU") + " SAU " +;
				" ON SAU.D_E_L_E_T_ = ' ' AND SAU.AU_CODFIL = SB7.B7_FILIAL " +;
				" WHERE ACV.ACV_CATEGO IN (SELECT ACU_COD  FROM 	" + RetSqlName("ACU") +;
				"                      WHERE  ACU_CODPAI >= '" + mv_par11 + "'" +;//CATEGORIA
				"                         AND ACU_CODPAI <= '" + mv_par12 + "'" +;//CATEGORIA
				"                         AND D_E_L_E_T_ = ' ') " +;
	       	 	" AND " + LJ7017QryFil(.F.,"SB7")[2]
	If lGestao .AND. lACVComp	// Se a tabela ACV for compartilhada aceito a filial corrente
		cQuery += " AND ACV.ACV_FILIAL = '" + xFilial("ACV") + "' "
	Else 						// Se a tabela ACV for exclusiva comparo as Filiais
		cQuery += " AND ACV.ACV_FILIAL = SB7.B7_FILIAL "
	EndIf
	cQuery += 	" AND ACV.ACV_GRUPO >= '" + mv_par13 + "'" +;
				" AND ACV.ACV_GRUPO <= '" + mv_par14 + "'" +;
	   	      	" AND B7_FILIAL = B1_FILIAL "+;
				" AND B7_COD = B1_COD " +;
				" AND B7_LOCAL = B1_LOCPAD " +;
				" AND B7_STATUS = '1' " +;
				" AND B7_DATA >= '" + DToS(mv_par09) + "'" +;
			    " AND B7_DATA <= '" + DToS(mv_par10) + "'" +;
				" AND B7_COD >= '" + mv_par15 + "'" +;
	            " AND B7_COD <= '" + mv_par16 + "'" +;
				" AND B7_LOCAL >= '" + mv_par17 + "'" +;
		        " AND B7_LOCAL <= '" + mv_par18 + "'" +;
			    " AND ACV.D_E_L_E_T_ = ' ' " +;
				" AND SB1.D_E_L_E_T_ = ' ' " +;
	    	    " AND SB7.D_E_L_E_T_ = ' ' " +;
				" GROUP BY SAU.AU_CODGRUP,SAU.AU_DESCRI,SB7.B7_FILIAL,SB7.B7_DATA,SB7.B7_COD,SB7.B7_LOCAL,SB7.B7_QUANT,SB7.B7_DOC,SB1.B1_CUSTD,ACV.ACV_CATEGO,ACV_GRUPO  " 	 
Else
  	cQuery :=	" SELECT DISTINCT SAU.AU_CODGRUP,SAU.AU_DESCRI,SB7.B7_FILIAL,SB7.B7_DATA,SB7.B7_COD,SB7.B7_LOCAL,SB7.B7_QUANT,SB7.B7_DOC,SB1.B1_CUSTD " +;
				" FROM " + RetSqlName("SB1") + " SB1, " + RetSqlName("SB7") + " SB7 " +;
				" INNER JOIN " + RetSqlName("SAU") + " SAU " +;
				" ON SAU.D_E_L_E_T_ = ' ' AND SAU.AU_CODFIL = SB7.B7_FILIAL " +;
				" WHERE " +LJ7017QryFil(.F.,"SB7")[2] +;
		      	" AND B7_FILIAL = B1_FILIAL " +;
				" AND B7_COD = B1_COD " +;
				" AND B7_LOCAL = B1_LOCPAD " +;
				" AND B7_STATUS = '1' " +;
			    " AND B7_DATA >= '" + DToS(mv_par09) + "'" +;
			    " AND B7_DATA <= '" + DToS(mv_par10) + "'" +;
			    " AND B7_COD >= '" + mv_par15 + "'" +;
		        " AND B7_COD <= '" + mv_par16 + "'" +;
				" AND B7_LOCAL >= '" + mv_par17 + "'" +;
		        " AND B7_LOCAL <= '" + mv_par18 + "'" +;
		        " AND B7_FILIAL = SAU.AU_CODFIL " +;
				" AND SB1.D_E_L_E_T_ = ' ' " +;
		   	    " AND SB7.D_E_L_E_T_ = ' ' " +;
				" GROUP BY SAU.AU_CODGRUP,SAU.AU_DESCRI,SB7.B7_FILIAL,SB7.B7_DATA,SB7.B7_COD,SB7.B7_LOCAL,SB7.B7_QUANT,SB7.B7_DOC,SB1.B1_CUSTD" 	 
Endif 

cQuery := ChangeQuery(cQuery)

DbSelectArea("SB7")
DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), 'SB7TRB', .F., .T.)

While SB7TRB->(!Eof()) 			
	aSaldo  := CalcEst(SB7TRB->B7_COD,SB7TRB->B7_LOCAL,SToD(SB7TRB->B7_DATA))
	nDifInv := Round(NoRound(aSaldo[1],3),2) - SB7TRB->B7_QUANT
	
	If nDifInv <> 0
	    If cCont == 0 
	  		Aadd(aTotal,{SB7TRB->AU_CODGRUP, (nDifInv * SB7TRB->B1_CUSTD),AllTrim(SB7TRB->AU_DESCRI),nDifInv})
	  		lAchou := .T.
	    Else             
		    For nI:= 1 to len(aTotal)
		    	If SB7TRB->AU_CODGRUP == aTotal[nI][1]
		    		aTotal[nI][2] := aTotal[nI][2] + (nDifInv * SB7TRB->B1_CUSTD)
		    		aTotal[nI][4] := aTotal[nI][4] + nDifInv
		    		lAchou := .T.
		        Endif
		    Next nI
		Endif
	    
	    If !lAchou
	  		Aadd(aTotal,{SB7TRB->AU_CODGRUP, (nDifInv * SB7TRB->B1_CUSTD),AllTrim(SB7TRB->AU_DESCRI),nDifInv})
	    Endif
		
		cCont ++
	EndIf
	
	lAchou := .F.
	
	SB7TRB->(dbSkip())
EndDo

SB7TRB->(DbCloseArea())
 
//Ordernar do maior para o menor valor 
ASORT(aTotal,,,{ | x,y | x[2] > y[2] } )

If len(aTotal) < len(aSerie)
   nTotal := len(aTotal)
Else
   nTotal := len(aSerie)   
Endif

For nI:= 1 to nTotal
	aSerie[nI][1] := "Cod:" + AllTrim(aTotal[nI][1])
	aSerie[nI][2] := aTotal[nI][2] //Total de produtos devolvidos x $unitario do produto
	aSerie[nI][3] := AllTrim(aTotal[nI][1])+"-"+AllTrim(aTotal[nI][3])
	aSerie[nI][4] := aTotal[nI][4]//Total
Next nI  

RestArea(aArea)


Return aSerie


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ProcInd18        ³Autor  ³TOTVS               ³ Data ³ 12/07/13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Retorna os valores que serao impressos pelo painel             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ ¢ Produtos com divergência de inventário >> Filial             ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function ProcInd18()

Local aArea  	:= GetArea()
Local cCont		:= 0  // contador de serie
Local cQuery    := "" // Texto SQL que é enviado para o comando TCGenQry
Local aTotal    := {}
Local nI        := 0
Local nTotal    := 0 //limitador do numero de registros por ranking
Local lAchou    := .F.
Local nPos		:= 1
Local aFiliais 	:= Lj7017Fil()// Recebera o retorna dos nomes das Filiais	
Local nY        := 0
Local aSaldo	:= {}
Local nDifInv	:= 0

If lCatProd
	cQuery :=	" SELECT DISTINCT SB7.B7_FILIAL,SB7.B7_DATA,SB7.B7_COD,SB7.B7_LOCAL,SB7.B7_QUANT,SB7.B7_DOC,SB1.B1_CUSTD,ACV.ACV_CATEGO,ACV.ACV_GRUPO " +;
				" FROM " + RetSqlName("SB1") + " SB1, " + RetSqlName("SB7") + " SB7 " +;
				" LEFT JOIN 	" + RetSqlName("ACV")  +" ACV on ACV.ACV_CODPRO  = SB7.B7_COD " +;
				" WHERE ACV.ACV_CATEGO IN (SELECT ACU_COD  FROM 	" + RetSqlName("ACU") +;
				"                      WHERE  ACU_CODPAI >= '" + mv_par11 + "'" +;//CATEGORIA
				"                         AND ACU_CODPAI <= '" + mv_par12 + "'" +;//CATEGORIA
				"                         AND D_E_L_E_T_ = ' ') " +;
	 		 	" AND " + LJ7017QryFil(.F.,"SB7")[2]
	If lGestao .AND. lACVComp	// Se a tabela ACV for compartilhada aceito a filial corrente
		cQuery += " AND ACV.ACV_FILIAL = '" + xFilial("ACV") + "' "
	Else 						// Se a tabela ACV for exclusiva comparo as Filiais
		cQuery += " AND ACV.ACV_FILIAL = SB7.B7_FILIAL "
	EndIf
	cQuery += 	" AND ACV.ACV_GRUPO >= '" + mv_par13 + "'" +;
				" AND ACV.ACV_GRUPO <= '" + mv_par14 + "'" +;
	   	       	" AND B7_FILIAL = B1_FILIAL " +;
				" AND B7_COD = B1_COD " +;
				" AND B7_LOCAL = B1_LOCPAD " +;
				" AND B7_STATUS = '1' " +;
			    " AND B7_DATA >= '" + DToS(mv_par09) + "'" +;
			    " AND B7_DATA <= '" + DToS(mv_par10) + "'" +;
			    " AND B7_COD >= '" + mv_par15 + "'" +;
	            " AND B7_COD <= '" + mv_par16 + "'" +;
				" AND B7_LOCAL >= '" + mv_par17 + "'" +;
		        " AND B7_LOCAL <= '" + mv_par18 + "'" +;
			    " AND ACV.D_E_L_E_T_ = ' ' " +;
				" AND SB1.D_E_L_E_T_ = ' ' " +;
	     		" AND SB7.D_E_L_E_T_ = ' ' " +;
				" GROUP BY SB7.B7_FILIAL,SB7.B7_DATA,SB7.B7_COD,SB7.B7_LOCAL,SB7.B7_QUANT,SB7.B7_DOC,SB1.B1_CUSTD,ACV.ACV_CATEGO,ACV.ACV_GRUPO  " 	 
Else
	cQuery :=	" SELECT DISTINCT SB7.B7_FILIAL,SB7.B7_DATA,SB7.B7_COD,SB7.B7_LOCAL,SB7.B7_QUANT,SB7.B7_DOC,SB1.B1_CUSTD " +;
				" FROM " + RetSqlName("SB1") + " SB1, " + RetSqlName("SB7") + " SB7 " +;
				" WHERE " + LJ7017QryFil(.F.,"SB7")[2] +;
		       	" AND B7_FILIAL = B1_FILIAL "+;
				" AND B7_COD = B1_COD " +;
				" AND B7_LOCAL = B1_LOCPAD " +;
				" AND B7_STATUS = '1' " +;
			    " AND B7_DATA >= '" + DToS(mv_par09) + "'" +;
			    " AND B7_DATA <= '" + DToS(mv_par10) + "'" +;
			    " AND B7_COD >= '" + mv_par15 + "'" +;
		        " AND B7_COD <= '" + mv_par16 + "'" +;
				" AND B7_LOCAL >= '" + mv_par17 + "'" +;
		        " AND B7_LOCAL <= '" + mv_par18 + "'" +;
				" AND SB1.D_E_L_E_T_ = ' ' " +;
		  		" AND SB7.D_E_L_E_T_ = ' ' " +;
				" GROUP BY SB7.B7_FILIAL,SB7.B7_DATA,SB7.B7_COD,SB7.B7_LOCAL,SB7.B7_QUANT,SB7.B7_DOC,SB1.B1_CUSTD  " 	 
Endif

cQuery := ChangeQuery(cQuery)

DbSelectArea("SB7")
DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), 'SB7TRB', .F., .T.)

While SB7TRB->(!Eof()) 			
	aSaldo  := CalcEst(SB7TRB->B7_COD,SB7TRB->B7_LOCAL,SToD(SB7TRB->B7_DATA))
	nDifInv := Round(NoRound(aSaldo[1],3),2) - SB7TRB->B7_QUANT
	
	If nDifInv <> 0	
	    If cCont == 0 
	  		Aadd(aTotal,{SB7TRB->B7_FILIAL, (nDifInv * SB7TRB->B1_CUSTD),"",nDifInv})  
	  		lAchou := .T.
	    Else             
		    For nI:= 1 to len(aTotal)
		    	If SB7TRB->B7_FILIAL == aTotal[nI][1]
		    		aTotal[nI][2] := aTotal[nI][2] + (nDifInv * SB7TRB->B1_CUSTD)
		    		aTotal[nI][4] := aTotal[nI][4] + nDifInv
		    		lAchou := .T.
		        Endif
		    Next nI
		Endif
	    
	    If !lAchou      
	  		Aadd(aTotal,{SB7TRB->B7_FILIAL, (nDifInv * SB7TRB->B1_CUSTD),"",nDifInv})
	    Endif
		
		cCont ++
	EndIf
	
	lAchou := .F.
	
	SB7TRB->(dbSkip())
EndDo

	 
//Ordernar do maior para o menor valor 
ASORT(aTotal,,,{ | x,y | x[2] > y[2] } )

If len(aTotal) < len(aSerie)
   nTotal := len(aTotal)
Else
   nTotal := len(aSerie)   
Endif

For nI:= 1 to nTotal	

	For nY:= 1 to len(aFiliais)
		If alltrim(aTotal[nI][1]) == alltrim(aFiliais[nY][1]) 
			nPos := nY
		Endif	
	Next nY	
    
	aSerie[nI][1] := "Cod:" + AllTrim(aTotal[nI][1])
	aSerie[nI][2] := aTotal[nI][2] //Total de produtos devolvidos x $unitario do produto
	aSerie[nI][3] := AllTrim(aTotal[nI][1])+"-"+AllTrim(aFiliais[nPos][2])  //Filial
	aSerie[nI][4] := aTotal[nI][4]//Total
Next nI  

RestArea(aArea)
SB7TRB->(DbCloseArea())

Return aSerie


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ProcInd19        ³Autor  ³TOTVS               ³ Data ³ 12/07/13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Retorna os valores que serao impressos pelo painel             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Produtos com divergencia de estoque >> Categoria de Produtos   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function ProcInd19()

Local aArea  	:= GetArea()
Local cCont		:= 0  // contador de serie
Local cQuery    := "" // Texto SQL que é enviado para o comando TCGenQry
Local aTotal    := {}
Local nI        := 0
Local nTotal    := 0 //limitador do numero de registros por ranking
Local lAchou    := .F.
Local aSaldo	:= {}
Local nDifInv	:= 0
  
cQuery :=	" SELECT DISTINCT SB7.B7_FILIAL,SB7.B7_DATA,ACV.ACV_CATEGO,SB7.B7_COD,SB7.B7_LOCAL,SB7.B7_QUANT,SB7.B7_DOC,SB1.B1_CUSTD " +;
			" FROM " + RetSqlName("SB1") + " SB1, " + RetSqlName("SB7") + " SB7 " +;
			" LEFT JOIN " + RetSqlName("ACV")  +" ACV on ACV.ACV_CODPRO  = SB7.B7_COD " +;
			" WHERE ACV.ACV_CATEGO IN (SELECT ACU_COD  FROM 	" + RetSqlName("ACU") +;
			"							WHERE  ACU_CODPAI >= '" + mv_par11 + "'" +;//CATEGORIA
			"							AND ACU_CODPAI <= '" + mv_par12 + "'" +;//CATEGORIA
			"							AND D_E_L_E_T_ = ' ') " +;
   	   	 	" AND " + LJ7017QryFil(.F.,"SB7")[2]
If lGestao .AND. lACVComp	// Se a tabela ACV for compartilhada aceito a filial corrente
	cQuery += " AND ACV.ACV_FILIAL = '" + xFilial("ACV") + "' "
Else 						// Se a tabela ACV for exclusiva comparo as Filiais
	cQuery += " AND ACV.ACV_FILIAL = SB7.B7_FILIAL "
EndIf
cQuery += 	" AND ACV.ACV_GRUPO >= '" + mv_par13 + "'" +;
			" AND ACV.ACV_GRUPO <= '" + mv_par14 + "'" +;
   	       	" AND B7_FILIAL = B1_FILIAL " +;
			" AND B7_COD = B1_COD " +;
			" AND B7_LOCAL = B1_LOCPAD " +;
			" AND B7_STATUS = '1' " +;
		    " AND B7_DATA >= '" + DToS(mv_par09) + "'" +;
		    " AND B7_DATA <= '" + DToS(mv_par10) + "'" +;
		    " AND B7_COD >= '" + mv_par15 + "'" +;
            " AND B7_COD <= '" + mv_par16 + "'" +;
			" AND B7_LOCAL >= '" + mv_par17 + "'" +;
	        " AND B7_LOCAL <= '" + mv_par18 + "'" +;
		    " AND ACV.D_E_L_E_T_ = ' ' " +;
			" AND SB1.D_E_L_E_T_ = ' ' " +;
    	    " AND SB7.D_E_L_E_T_ = ' ' " +;
			" GROUP BY SB7.B7_FILIAL,SB7.B7_DATA,ACV.ACV_CATEGO,SB7.B7_COD,SB7.B7_LOCAL,SB7.B7_QUANT,SB7.B7_DOC,SB1.B1_CUSTD " 	 
			
cQuery := ChangeQuery(cQuery)

DbSelectArea("SB7")
DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), 'SB7TRB', .F., .T.)
	
While SB7TRB->(!Eof()) 			
	aSaldo  := CalcEst(SB7TRB->B7_COD,SB7TRB->B7_LOCAL,SToD(SB7TRB->B7_DATA))
	nDifInv := Round(NoRound(aSaldo[1],3),2) - SB7TRB->B7_QUANT
	
	If nDifInv <> 0
	    If cCont == 0
	  		Aadd(aTotal,{SB7TRB->ACV_CATEGO, (nDifInv * SB7TRB->B1_CUSTD),"",nDifInv})
	  		lAchou := .T.
	    Else             
		    For nI:= 1 to len(aTotal)
		    	If SB7TRB->ACV_CATEGO == aTotal[nI][1]
		    		aTotal[nI][2] := aTotal[nI][2] + (nDifInv * SB7TRB->B1_CUSTD)
		    		aTotal[nI][4] := aTotal[nI][4] + nDifInv
		    		lAchou := .T.
	            Endif
		    Next nI
		Endif
		
		If !lAchou
	  		Aadd(aTotal,{SB7TRB->ACV_CATEGO, (nDifInv * SB7TRB->B1_CUSTD),"",nDifInv})
	    Endif
	    
		cCont ++
	EndIf
	
	lAchou := .F.
	
	SB7TRB->(dbSkip())

EndDo
 
//Ordernar do maior para o menor valor 
ASORT(aTotal,,,{ | x,y | x[2] > y[2] } )

If len(aTotal) < len(aSerie)
   nTotal := len(aTotal)
Else
   nTotal := len(aSerie)   
Endif

For nI:= 1 to nTotal
	aSerie[nI][1] := "Cod:" + AllTrim(aTotal[nI][1])
	aSerie[nI][2] := aTotal[nI][2]//Total de produtos devolvidos 
	aSerie[nI][3] := AllTrim(aTotal[nI][1])+"-"+AllTrim(Posicione( "ACU", 1, xFilial("ACU")+aTotal[nI][1], "ACU_DESC" ))//Categoria de produtos
	aSerie[nI][4] := aTotal[nI][4]//Total
Next nI  

RestArea(aArea)
SB7TRB->(DbCloseArea())

Return aSerie


/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ProcInd20    ³Autor  ³TOTVS               ³ Data ³ 12/07/13     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Retorna os valores que serao impressos pelo painel             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Produtos com divergência de inventário>> Grupo de produtos     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function ProcInd20()

Local aArea  	:= GetArea()
Local cCont		:= 0  // contador de serie
Local cQuery    := "" // Texto SQL que é enviado para o comando TCGenQry
Local aTotal    := {}
Local nI        := 0
Local nTotal    := 0 //limitador do numero de registros por ranking
Local lAchou    := .F.  
Local aSaldo	:= {}
Local nDifInv	:= 0

cQuery :=	" SELECT DISTINCT SB7.B7_FILIAL,SB7.B7_DATA,ACV.ACV_GRUPO,ACV.ACV_CATEGO,SB7.B7_COD,SB7.B7_LOCAL,SB7.B7_QUANT,SB7.B7_DOC,SB1.B1_CUSTD " +;
			" FROM " + RetSqlName("SB1") + " SB1, " + RetSqlName("SB7") + " SB7 " +;
			" LEFT JOIN " + RetSqlName("ACV")  +" ACV on ACV.ACV_CODPRO  = SB7.B7_COD " +;
			" WHERE ACV.ACV_CATEGO IN (SELECT ACU_COD  FROM 	" + RetSqlName("ACU") +;
			"                         WHERE  ACU_CODPAI >= '" + mv_par11 + "'" +;//CATEGORIA
			"                         AND ACU_CODPAI <= '" + mv_par12 + "'" +;//CATEGORIA
			"                         AND D_E_L_E_T_ = ' ') " +;
   	   	 	" AND " + LJ7017QryFil(.F.,"SB7")[2]
If lGestao .AND. lACVComp	// Se a tabela ACV for compartilhada aceito a filial corrente
	cQuery += " AND ACV.ACV_FILIAL = '" + xFilial("ACV") + "' "
Else 						// Se a tabela ACV for exclusiva comparo as Filiais
	cQuery += " AND ACV.ACV_FILIAL = SB7.B7_FILIAL "
EndIf
cQuery += 	" AND ACV.ACV_GRUPO >= '" + mv_par13 + "'" +;
			" AND ACV.ACV_GRUPO <= '" + mv_par14 + "'" +;
   	       	" AND B7_FILIAL = B1_FILIAL " +;
			" AND B7_COD = B1_COD " +;
			" AND B7_LOCAL = B1_LOCPAD " +;
			" AND B7_STATUS = '1' " +;
		    " AND B7_DATA >= '" + DToS(mv_par09) + "'" +;
		    " AND B7_DATA <= '" + DToS(mv_par10) + "'" +;
		    " AND B7_COD >= '" + mv_par15 + "'" +;
            " AND B7_COD <= '" + mv_par16 + "'" +;
			" AND B7_LOCAL >= '" + mv_par17 + "'" +;
	        " AND B7_LOCAL <= '" + mv_par18 + "'" +;
		    " AND ACV.D_E_L_E_T_ = ' ' " +;
			" AND SB1.D_E_L_E_T_ = ' ' " +;
  		    " AND SB7.D_E_L_E_T_ = ' ' " +;
			" GROUP BY SB7.B7_FILIAL,SB7.B7_DATA,ACV.ACV_GRUPO,ACV.ACV_CATEGO,SB7.B7_COD,SB7.B7_LOCAL,SB7.B7_QUANT,SB7.B7_DOC,SB1.B1_CUSTD "
					
cQuery := ChangeQuery(cQuery)

DbSelectArea("SB7")
DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), 'SB7TRB', .F., .T.)

While SB7TRB->(!Eof()) 			
	aSaldo  := CalcEst(SB7TRB->B7_COD,SB7TRB->B7_LOCAL,SToD(SB7TRB->B7_DATA))
	nDifInv := Round(NoRound(aSaldo[1],3),2) - SB7TRB->B7_QUANT
	
	If nDifInv <> 0
	    If cCont == 0 
	  		Aadd(aTotal,{SB7TRB->ACV_GRUPO, (nDifInv * SB7TRB->B1_CUSTD),"",nDifInv})
	  		lAchou := .T.
	    Else             
		    For nI:= 1 to len(aTotal)
		    	If SB7TRB->ACV_GRUPO == aTotal[nI][1]
		    		aTotal[nI][2] := aTotal[nI][2] + (nDifInv * SB7TRB->B1_CUSTD)
		    		aTotal[nI][4] := aTotal[nI][4] + nDifInv
		    		lAchou := .T.
	            Endif
		    Next nI
		Endif
	
		If !lAchou
	  		Aadd(aTotal,{SB7TRB->ACV_GRUPO, (nDifInv * SB7TRB->B1_CUSTD),"",nDifInv})
		Endif
		
		cCont ++
	EndIf
		
	lAchou := .F.
	
	SB7TRB->(dbSkip())

EndDo
 
//Ordernar do maior para o menor valor 
ASORT(aTotal,,,{ | x,y | x[2] > y[2] } )

If len(aTotal) < len(aSerie)
   nTotal := len(aTotal)
Else
   nTotal := len(aSerie)   
Endif

For nI:= 1 to nTotal
	aSerie[nI][1] := "Cod:" + AllTrim(aTotal[nI][1])
	aSerie[nI][2] := aTotal[nI][2]//Total de categorias
	aSerie[nI][3] := AllTrim(aTotal[nI][1])+"-"+AllTrim(Posicione("SBM",1,xFilial("SBM")+aTotal[nI][1],"BM_DESC"))//Grupo de produtos 
	aSerie[nI][4] := aTotal[nI][4]//Total
Next nI  

RestArea(aArea)
SB7TRB->(DbCloseArea())

Return aSerie

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ProcInd21    ³Autor  ³TOTVS               ³ Data ³ 12/07/13     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Retorna os valores que serao impressos pelo painel             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Produtos com divergência de inventário>> Produtos              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function ProcInd21()

Local aArea  	:= GetArea()
Local cCont		:= 0 // contador de serie
Local cQuery    := ""// Texto SQL que é enviado para o comando TCGenQry
Local aTotal    := {}
Local nI        := 0
Local nTotal    := 0 //limitador do numero de registros por ranking
Local lAchou    := .F.  
Local aSaldo	:= {}
Local nDifInv	:= 0

If lCatProd 
	cQuery :=	" SELECT DISTINCT SB7.B7_FILIAL,SB7.B7_COD,SB7.B7_LOCAL,SB7.B7_DATA,SB7.B7_QUANT,SB7.B7_DOC,SB1.B1_CUSTD,ACV.ACV_CATEGO,ACV.ACV_GRUPO " +;
				" FROM " + RetSqlName("SB1") + " SB1, " + RetSqlName("SB7") + " SB7 " +;
				" LEFT JOIN " + RetSqlName("ACV") + " ACV on ACV.ACV_CODPRO  = SB7.B7_COD " +;
				" WHERE ACV.ACV_CATEGO IN (SELECT ACU_COD  FROM " + RetSqlName("ACU") +;
				"                         WHERE  ACU_CODPAI >= '" + mv_par11 + "'" +;//CATEGORIA
				"                         AND ACU_CODPAI <= '" + mv_par12 + "'" +;//CATEGORIA
				"                         AND D_E_L_E_T_ = ' ') " +;
	   	   	 	" AND " + LJ7017QryFil(.F.,"SB7")[2]
	If lGestao .AND. lACVComp	// Se a tabela ACV for compartilhada aceito a filial corrente
		cQuery += " AND ACV.ACV_FILIAL = '" + xFilial("ACV") + "' "
	Else 						// Se a tabela ACV for exclusiva comparo as Filiais
		cQuery += " AND ACV.ACV_FILIAL = SB7.B7_FILIAL "
	EndIf
	cQuery += 	" AND ACV.ACV_GRUPO >= '" + mv_par13 + "'" +;
				" AND ACV.ACV_GRUPO <= '" + mv_par14 + "'" +;			
	   	       	" AND B7_FILIAL = B1_FILIAL " +;
				" AND B7_COD = B1_COD " +;
				" AND B7_LOCAL = B1_LOCPAD " +;
				" AND B7_STATUS = '1' " +;
			    " AND B7_DATA >= '" + DToS(mv_par09) + "'" +;
			    " AND B7_DATA <= '" + DToS(mv_par10) + "'" +;
			    " AND B7_COD >= '" + mv_par15 + "'" +;
	            " AND B7_COD <= '" + mv_par16 + "'" +;
				" AND B7_LOCAL >= '" + mv_par17 + "'" +;
		        " AND B7_LOCAL <= '" + mv_par18 + "'" +;
			    " AND ACV.D_E_L_E_T_ = ' ' " +;
				" AND SB1.D_E_L_E_T_ = ' ' " +;
	   		    " AND SB7.D_E_L_E_T_ = ' ' " +;
				" GROUP BY SB7.B7_FILIAL,SB7.B7_COD,SB7.B7_LOCAL,SB7.B7_DATA,SB7.B7_QUANT,SB7.B7_DOC,SB1.B1_CUSTD,ACV.ACV_CATEGO,ACV.ACV_GRUPO" 	 
Else
	cQuery :=	" SELECT DISTINCT SB7.B7_FILIAL,SB7.B7_COD,SB7.B7_LOCAL,SB7.B7_DATA,SB7.B7_QUANT,SB7.B7_DOC,SB1.B1_CUSTD " +;
				" FROM " + RetSqlName("SB1") + " SB1, " + RetSqlName("SB7") + " SB7 " +;
				" WHERE " + LJ7017QryFil(.F.,"SB7")[2] +;
	   	       	" AND B7_FILIAL = B1_FILIAL " +;
				" AND B7_COD = B1_COD " +;
				" AND B7_LOCAL = B1_LOCPAD " +;
				" AND B7_STATUS = '1' " +;
			    " AND B7_DATA >= '" + DToS(mv_par09) + "'" +;
			    " AND B7_DATA <= '" + DToS(mv_par10) + "'" +;
			    " AND B7_COD >= '" + mv_par15 + "'" +;
	            " AND B7_COD <= '" + mv_par16 + "'" +;
				" AND B7_LOCAL >= '" + mv_par17 + "'" +;
		        " AND B7_LOCAL <= '" + mv_par18 + "'" +;
				" AND SB1.D_E_L_E_T_ = ' ' " +;
	     	    " AND SB7.D_E_L_E_T_ = ' ' " +;
				" GROUP BY SB7.B7_FILIAL,SB7.B7_COD,SB7.B7_LOCAL,SB7.B7_DATA,SB7.B7_QUANT,SB7.B7_DOC,SB1.B1_CUSTD" 	 
Endif					

cQuery := ChangeQuery(cQuery)

DbSelectArea("SB7")
DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), 'SB7TRB', .F., .T.)

While SB7TRB->(!Eof()) 			
	aSaldo  := CalcEst(SB7TRB->B7_COD,SB7TRB->B7_LOCAL,SToD(SB7TRB->B7_DATA))
	nDifInv := Round(NoRound(aSaldo[1],3),2) - SB7TRB->B7_QUANT
	
	If nDifInv <> 0
	    If cCont == 0 
	  		Aadd(aTotal,{SB7TRB->B7_COD, (nDifInv * SB7TRB->B1_CUSTD),"",nDifInv})
	  		lAchou := .T.
	    Else             
		    For nI:= 1 to len(aTotal)
		    	If SB7TRB->B7_COD == aTotal[nI][1]
		    		aTotal[nI][2] := aTotal[nI][2] + (nDifInv * SB7TRB->B1_CUSTD)
		    		aTotal[nI][4] := aTotal[nI][4] + nDifInv
		    		lAchou := .T.
	            Endif
		    Next nI
		Endif
	
		If !lAchou
	  		Aadd(aTotal,{SB7TRB->B7_COD, (nDifInv * SB7TRB->B1_CUSTD),"",nDifInv}) 
		Endif
		
		cCont ++
	EndIf
	
	lAchou := .F.
	
	SB7TRB->(dbSkip())

EndDo
 
//Ordernar do maior para o menor valor 
ASORT(aTotal,,,{ | x,y | x[2] > y[2] } )

If len(aTotal) < len(aSerie)
   nTotal := len(aTotal)
Else
   nTotal := len(aSerie)   
Endif

For nI:= 1 to nTotal
	aSerie[nI][1] := "Cod:" + AllTrim(aTotal[nI][1])
	aSerie[nI][2] := aTotal[nI][2]//Total de categorias
	aSerie[nI][3] := AllTrim(aTotal[nI][1])+"-"+AllTrim(Posicione( "SB1", 1, xFilial("SB1")+alltrim(aTotal[nI][1]), "B1_DESC" ))
	aSerie[nI][4] := aTotal[nI][4]//Total
Next nI  

RestArea(aArea)
SB7TRB->(DbCloseArea())

Return aSerie


/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ProcInd22    ³Autor  ³TOTVS               ³ Data ³ 12/07/13     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Retorna os valores que serao impressos pelo painel             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Produtos com divergência de inventário>> Armazem               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function ProcInd22()

Local aArea  	:= GetArea()
Local cCont		:= 0 // contador de serie
Local cQuery    := ""// Texto SQL que é enviado para o comando TCGenQry
Local aTotal    := {}
Local nI        := 0
Local nTotal    := 0 //limitador do numero de registros por ranking
Local lAchou    := .F.  
Local aSaldo	:= {}
Local nDifInv	:= 0

If lCatProd 
	cQuery :=	" SELECT DISTINCT SB7.B7_FILIAL,SB7.B7_DATA,SB7.B7_COD,SB7.B7_LOCAL,SB7.B7_QUANT,SB7.B7_DOC,SB1.B1_CUSTD,ACV.ACV_CATEGO,ACV.ACV_GRUPO " +;
				" FROM " + RetSqlName("SB1") + " SB1, " + RetSqlName("SB7") + " SB7 " +;
				" LEFT JOIN " + RetSqlName("ACV") + " ACV on ACV.ACV_CODPRO  = SB7.B7_COD " +;
				" WHERE ACV.ACV_CATEGO IN (SELECT ACU_COD  FROM 	" + RetSqlName("ACU") +;
				"                         WHERE  ACU_CODPAI >= '" + mv_par11 + "'" +;//CATEGORIA
				"                         AND ACU_CODPAI <= '" + mv_par12 + "'" +;//CATEGORIA
				"                         AND D_E_L_E_T_ = ' ') " +;
	            " AND " + LJ7017QryFil(.F.,"SB7")[2]
	If lGestao .AND. lACVComp	// Se a tabela ACV for compartilhada aceito a filial corrente
		cQuery += " AND ACV.ACV_FILIAL = '" + xFilial("ACV") + "' "
	Else 						// Se a tabela ACV for exclusiva comparo as Filiais
		cQuery += " AND ACV.ACV_FILIAL = SB7.B7_FILIAL "
	EndIf
	cQuery += 	" AND ACV.ACV_GRUPO >= '" + mv_par13 + "'" +;
				" AND ACV.ACV_GRUPO <= '" + mv_par14 + "'" +;
	   	       	" AND B7_FILIAL = B1_FILIAL " +;
				" AND B7_COD = B1_COD " +;
				" AND B7_LOCAL = B1_LOCPAD " +;
				" AND B7_STATUS = '1' " +;
			    " AND B7_DATA >= '" + DToS(mv_par09) + "'" +;
			    " AND B7_DATA <= '" + DToS(mv_par10) + "'" +;
			    " AND B7_COD >= '" + mv_par15 + "'" +;
	            " AND B7_COD <= '" + mv_par16 + "'" +;
				" AND B7_LOCAL >= '" + mv_par17 + "'" +;
		        " AND B7_LOCAL <= '" + mv_par18 + "'" +;
			    " AND ACV.D_E_L_E_T_ = ' ' " +;
				" AND SB1.D_E_L_E_T_ = ' ' " +;
	   		    " AND SB7.D_E_L_E_T_ = ' ' " +;
				" GROUP BY SB7.B7_FILIAL,SB7.B7_DATA,SB7.B7_COD,SB7.B7_LOCAL,SB7.B7_QUANT,SB7.B7_DOC,SB1.B1_CUSTD,ACV.ACV_CATEGO,ACV.ACV_GRUPO "
Else
	cQuery :=	" SELECT DISTINCT SB7.B7_FILIAL,SB7.B7_DATA,SB7.B7_COD,SB7.B7_LOCAL,SB7.B7_QUANT,SB7.B7_DOC,SB1.B1_CUSTD " +;
				" FROM " + RetSqlName("SB1") + " SB1, " + RetSqlName("SB7") + " SB7 " +;
				" WHERE " + LJ7017QryFil(.F.,"SB7")[2] +;
	   	       	" AND B7_FILIAL = B1_FILIAL " +;
				" AND B7_COD = B1_COD " +;
				" AND B7_LOCAL = B1_LOCPAD " +;
				" AND B7_STATUS = '1' " +;
			    " AND B7_DATA >= '" + DToS(mv_par09) + "'" +;
			    " AND B7_DATA <= '" + DToS(mv_par10) + "'" +;
			    " AND B7_COD >= '" + mv_par15 + "'" +;
	            " AND B7_COD <= '" + mv_par16 + "'" +;
				" AND B7_LOCAL >= '" + mv_par17 + "'" +;
		        " AND B7_LOCAL <= '" + mv_par18 + "'" +;
				" AND SB1.D_E_L_E_T_ = ' ' " +;
	     	    " AND SB7.D_E_L_E_T_ = ' ' " +;
				" GROUP BY SB7.B7_FILIAL,SB7.B7_DATA,SB7.B7_COD,SB7.B7_LOCAL,SB7.B7_QUANT,SB7.B7_DOC,SB1.B1_CUSTD" 	 
Endif				

cQuery := ChangeQuery(cQuery)

DbSelectArea("SB7")
DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), 'SB7TRB', .F., .T.)

While SB7TRB->(!Eof()) 			
	aSaldo  := CalcEst(SB7TRB->B7_COD,SB7TRB->B7_LOCAL,SToD(SB7TRB->B7_DATA))
	nDifInv := Round(NoRound(aSaldo[1],3),2) - SB7TRB->B7_QUANT
	
	If nDifInv <> 0
	    If cCont == 0 
	  		Aadd(aTotal,{SB7TRB->B7_LOCAL, (nDifInv * SB7TRB->B1_CUSTD),"",nDifInv})
	  		lAchou := .T.
	    Else             
		    For nI:= 1 to len(aTotal)
		    	If SB7TRB->B7_LOCAL == aTotal[nI][1] 
		    		aTotal[nI][2] := aTotal[nI][2] + (nDifInv * SB7TRB->B1_CUSTD) //incrementa o totalizador da mesma filial
		    		aTotal[nI][4] := aTotal[nI][4] + nDifInv
		    		lAchou := .T.
	            Endif
		    Next nI
		Endif
		
		If !lAchou 
	  		Aadd(aTotal,{SB7TRB->B7_LOCAL, (nDifInv * SB7TRB->B1_CUSTD),"",nDifInv})
		Endif
		
		cCont ++
	EndIf
	
	lAchou := .F.
	
	SB7TRB->(dbSkip())

EndDo
 
//Ordernar do maior para o menor valor 
ASORT(aTotal,,,{ | x,y | x[2] > y[2] } )

If len(aTotal) < len(aSerie)
   nTotal := len(aTotal)
Else
   nTotal := len(aSerie)   
Endif

For nI:= 1 to nTotal
	aSerie[nI][1] := "Cod:" + AllTrim(aTotal[nI][1])
	aSerie[nI][2] := aTotal[nI][2]//Total de armazens
	aSerie[nI][3] := AllTrim(aTotal[nI][1])+"-"+AllTrim(Posicione("SBE",1,xFilial("SBE")+aTotal[nI][1],"BE_DESCRIC"))//Armazem
	aSerie[nI][4] := aTotal[nI][4]//Total
Next nI  

RestArea(aArea)
SB7TRB->(DbCloseArea())

Return aSerie

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ProcInd23        ³Autor  ³TOTVS               ³ Data ³ 15/07/13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Retorna os valores que serao impressos pelo painel             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Quebra Operacional >> Grupo de Filial                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function ProcInd23()

Local aArea  	:= GetArea()
Local cCont		:= 0 // contador de serie
Local cQuery    := ""// Texto SQL que é enviado para o comando TCGenQry
Local aTotal    := {}
Local nI,nY        := 0
Local nTotal    := 0 //limitador do numero de registros por ranking
Local lAchou    := .F.			
Local cFiliais  := ""

If lCatProd
  	cQuery :=	" SELECT DISTINCT SAU.AU_CODGRUP,SAU.AU_DESCRI,MFJ.MFJ_FILIAL,MFJ.MFJ_CODIGO,MFJ.MFJ_PRODUT,ACV.ACV_CATEGO,MFJ.MFJ_QUANT,MFJ.MFJ_VUNIT " +;
				" FROM 	" + RetSqlName("MFJ")  +" MFJ LEFT JOIN 	" + RetSqlName("ACV")  +" ACV on ACV.ACV_CODPRO  = MFJ.MFJ_PRODUT " +;
	 			" INNER JOIN " + RetSqlName("SAU") + " SAU " +;
				" ON SAU.D_E_L_E_T_ = ' ' AND SAU.AU_CODFIL = MFJ.MFJ_FILIAL " +;
				" WHERE ACV.ACV_CATEGO IN (SELECT ACU_COD  FROM 	" + RetSqlName("ACU") +;
				"                      WHERE  ACU_CODPAI >= '" + mv_par11 + "'" +;//CATEGORIA
				"                         AND ACU_CODPAI <= '" + mv_par12 + "'" +;//CATEGORIA
				"                         AND D_E_L_E_T_ = ' ') " +;   
		        " AND " +LJ7017QryFil(.F.,"MFJ")[2]
	If lGestao .AND. lACVComp	// Se a tabela ACV for compartilhada aceito a filial corrente
		cQuery += " AND ACV.ACV_FILIAL = '" + xFilial("ACV") + "' "
	Else 						// Se a tabela ACV for exclusiva comparo as Filiais
		cQuery += " AND ACV.ACV_FILIAL = MFJ.MFJ_FILIAL "
	EndIf
	cQuery += 	" AND ACV.ACV_GRUPO >= '" + mv_par13 + "'" +;
				" AND ACV.ACV_GRUPO <= '" + mv_par14 + "'" +;
				" AND MFJ_PRODUT >= '" + mv_par15 + "'" +;
	            " AND MFJ_PRODUT <= '" + mv_par16 + "'" +;
	     		" AND MFJ_QUANT <> '0' " +;
	     		" AND MFJ_DATA >= '" + DToS(mv_par09) + "'"  +;
       			" AND MFJ_DATA <= '" + DToS(mv_par10) + "'"  +;
	 	 	    " AND ACV.D_E_L_E_T_ = ' ' " +;
	     		" AND MFJ.D_E_L_E_T_ = ' ' " +;
				" GROUP BY SAU.AU_CODGRUP,SAU.AU_DESCRI,MFJ_FILIAL,MFJ_CODIGO,MFJ_PRODUT,ACV_CATEGO,MFJ_QUANT,MFJ_VUNIT "
Else
  	cQuery :=	" SELECT SAU.AU_CODGRUP, SAU.AU_DESCRI,MFJ.MFJ_FILIAL, MFJ.MFJ_PRODUT, MFJ.MFJ_QUANT,MFJ.MFJ_VUNIT " +;
			" FROM 	" + RetSqlName("MFJ")  +" MFJ, " + RetSqlName("SAU") + " SAU " +;
			" WHERE " +LJ7017QryFil(.F.,"MFJ")[2] +; 	
			" AND MFJ_PRODUT >= '" + mv_par15 + "'" +;
            " AND MFJ_PRODUT <= '" + mv_par16 + "'" +;
     		" AND MFJ_QUANT <> '0' " +;
            " AND MFJ_DATA >= '" + DToS(mv_par09) + "'"  +;
            " AND MFJ_DATA <= '" + DToS(mv_par10) + "'"  +;
            " AND MFJ.MFJ_FILIAL = SAU.AU_CODFIL "+;
     		" AND MFJ.D_E_L_E_T_ = ' ' " +;
			" GROUP BY SAU.AU_CODGRUP, SAU.AU_DESCRI,MFJ_FILIAL, MFJ_CODIGO, MFJ_PRODUT, MFJ_QUANT, MFJ_VUNIT "
Endif

cQuery := ChangeQuery(cQuery)
	
DbSelectArea("MFJ")
DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), 'MFJTRB', .F., .T.)
	
While MFJTRB->(!Eof()) 			
	
    If cCont == 0 
  		Aadd(aTotal,{MFJTRB->AU_CODGRUP,(val(MFJTRB->MFJ_QUANT) * MFJTRB->MFJ_VUNIT ), AllTrim(MFJTRB->AU_DESCRI), val(MFJTRB->MFJ_QUANT)})
  		lAchou := .T.
    Else             
	    For nI:= 1 to len(aTotal)
	    	If MFJTRB->AU_CODGRUP == aTotal[nI][1] 
	    		aTotal[nI][2] := aTotal[nI][2] + (val(MFJTRB->MFJ_QUANT) * MFJTRB->MFJ_VUNIT ) //incrementa o totalizador da mesma filial
	    		aTotal[nI][4] := aTotal[nI][4] + val(MFJTRB->MFJ_QUANT)  //incrementa o totalizador da mesma filial
	    		lAchou := .T.
	        Endif
	    Next nI
	Endif
    
    If !lAchou      
  		Aadd(aTotal,{MFJTRB->AU_CODGRUP,(val(MFJTRB->MFJ_QUANT) * MFJTRB->MFJ_VUNIT ),AllTrim(MFJTRB->AU_DESCRI),val(MFJTRB->MFJ_QUANT)})//adiciona uma nova filial
    Endif
	
	cCont ++
	
	lAchou := .F.
	
	MFJTRB->(dbSkip())
EndDo

MFJTRB->(DbCloseArea())

//Ordernar do maior para o menor valor 
ASORT(aTotal,,,{ | x,y | x[2] > y[2] } )

If len(aTotal) < len(aSerie)
   nTotal := len(aTotal)
Else
   nTotal := len(aSerie)   
Endif

For nI:= 1 to nTotal
	aSerie[nI][1] := "Cod:" + AllTrim(aTotal[nI][1])
	aSerie[nI][2] := aTotal[nI][2] //Total de produtos devolvidos x $unitario do produto
	aSerie[nI][3] := AllTrim(aTotal[nI][1])+"-"+AllTrim(+aTotal[nI][3])
	aSerie[nI][4] := aTotal[nI][4]//Total
Next nI  

RestArea(aArea)

Return aSerie


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ProcInd24        ³Autor  ³TOTVS               ³ Data ³ 17/07/13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Retorna os valores que serao impressos pelo painel             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Quebra Operacional >>Filial                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function ProcInd24()

Local aArea  	:= GetArea()
Local cCont		:= 0 // contador de serie
Local cQuery    := ""// Texto SQL que é enviado para o comando TCGenQry
Local aTotal    := {}
Local nI,nX     := 0
Local nTotal    := 0 //limitador do numero de registros por ranking
Local lAchou    := .F.
Local aFiliais  := {}// Recebera o retorna dos nomes das Filiais	
Local nPos		:= 1
Local aFiliais 	:= Lj7017Fil()// Recebera o retorna dos nomes das Filiais	
Local nY        := 0

If lCatProd			
  	cQuery :=	" SELECT MFJ.MFJ_FILIAL,MFJ.MFJ_CODIGO,MFJ.MFJ_PRODUT,ACV.ACV_CATEGO,MFJ.MFJ_QUANT,MFJ.MFJ_VUNIT " +;
				" FROM 	" + RetSqlName("MFJ")  +" MFJ LEFT JOIN 	" + RetSqlName("ACV")  +" ACV on ACV.ACV_CODPRO  = MFJ.MFJ_PRODUT " +;
				" WHERE ACV.ACV_CATEGO IN (SELECT ACU_COD  FROM 	" + RetSqlName("ACU") +;
				"                      WHERE  ACU_CODPAI >= '" + mv_par11 + "'" +;//CATEGORIA
				"                         AND ACU_CODPAI <= '" + mv_par12 + "'" +;//CATEGORIA
				"                         AND D_E_L_E_T_ = ' ') " +;   
		        " AND " +LJ7017QryFil(.F.,"MFJ")[2]
	If lGestao .AND. lACVComp	// Se a tabela ACV for compartilhada aceito a filial corrente
		cQuery += " AND ACV.ACV_FILIAL = '" + xFilial("ACV") + "' "
	Else 						// Se a tabela ACV for exclusiva comparo as Filiais
		cQuery += " AND ACV.ACV_FILIAL = MFJ.MFJ_FILIAL "
	EndIf
	cQuery += 	" AND ACV.ACV_GRUPO >= '" + mv_par13 + "'" +;
				" AND ACV.ACV_GRUPO <= '" + mv_par14 + "'" +;
				" AND MFJ_PRODUT >= '" + mv_par15 + "'" +;
	            " AND MFJ_PRODUT <= '" + mv_par16 + "'" +;
	     		" AND MFJ_QUANT <> '0' " +;
	 	 	    " AND ACV.D_E_L_E_T_ = ' ' " +;
	     		" AND MFJ.D_E_L_E_T_ = ' ' " +;
	            " AND MFJ_DATA >= '" + DToS(mv_par09) + "'"  +;
	            " AND MFJ_DATA <= '" + DToS(mv_par10) + "'"  +;
				" GROUP BY MFJ_FILIAL,MFJ_CODIGO,MFJ_PRODUT,ACV_CATEGO,MFJ_QUANT,MFJ_VUNIT "
Else
   	cQuery :=	" SELECT MFJ.MFJ_FILIAL, MFJ.MFJ_PRODUT, MFJ.MFJ_QUANT,MFJ.MFJ_VUNIT " +;
				" FROM 	" + RetSqlName("MFJ")  +" MFJ " +;
				" WHERE " +LJ7017QryFil(.F.,"MFJ")[2] +;
				" AND MFJ_PRODUT >= '" + mv_par15 + "'" +;
		        " AND MFJ_PRODUT <= '" + mv_par16 + "'" +;
		  		" AND MFJ_QUANT <> '0' " +;
		        " AND MFJ_DATA >= '" + DToS(mv_par09) + "'"  +;
		        " AND MFJ_DATA <= '" + DToS(mv_par10) + "'"  +;
		  		" AND MFJ.D_E_L_E_T_ = ' ' " +;
				" GROUP BY MFJ_FILIAL, MFJ_CODIGO, MFJ_PRODUT, MFJ_QUANT, MFJ_VUNIT "
Endif

cQuery := ChangeQuery(cQuery)

DbSelectArea("MFJ")
DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), 'MFJTRB', .F., .T.)

While MFJTRB->(!Eof()) 			
	
    If cCont == 0 
  		Aadd(aTotal,{MFJTRB->MFJ_FILIAL,(val(MFJTRB->MFJ_QUANT) * MFJTRB->MFJ_VUNIT ),"", val(MFJTRB->MFJ_QUANT)})  
  		lAchou := .T.
    Else             
	    For nI:= 1 to len(aTotal)
	    	If MFJTRB->MFJ_FILIAL == aTotal[nI][1] 
	    		aTotal[nI][2] := aTotal[nI][2] + (val(MFJTRB->MFJ_QUANT) * MFJTRB->MFJ_VUNIT) //incrementa o totalizador da mesma filial
	    		aTotal[nI][4] := aTotal[nI][4] + val(MFJTRB->MFJ_QUANT)  //incrementa o totalizador da mesma filial
	    		lAchou := .T.
	        Endif
	    Next nI
	Endif
    
    If !lAchou
  		Aadd(aTotal,{MFJTRB->MFJ_FILIAL,(val(MFJTRB->MFJ_QUANT) * MFJTRB->MFJ_VUNIT ),"", val(MFJTRB->MFJ_QUANT)}) //adiciona uma nova filial       
    Endif
	
	cCont ++
	
	lAchou := .F.
	
	MFJTRB->(dbSkip())

EndDo
 
//Ordernar do maior para o menor valor 
ASORT(aTotal,,,{ | x,y | x[2] > y[2] } )

If len(aTotal) < len(aSerie)
   nTotal := len(aTotal)
Else
   nTotal := len(aSerie)   
Endif

For nI:= 1 to nTotal	
	For nY:= 1 to len(aFiliais)
		If alltrim(aTotal[nI][1]) == alltrim(aFiliais[nY][1]) 
			nPos := nY
		Endif	
	Next nY	
	aSerie[nI][1] := "Cod:" + AllTrim(aTotal[nI][1])
	aSerie[nI][2] := aTotal[nI][2] //Total de produtos devolvidos x $unitario do produto
	aSerie[nI][3] := AllTrim(aTotal[nI][1])+"-"+AllTrim(aFiliais[nPos][2]) //Filial
	aSerie[nI][4] := aTotal[nI][4]//Total
Next nI  

RestArea(aArea)
MFJTRB->(DbCloseArea())

Return aSerie

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ProcInd25        ³Autor  ³TOTVS               ³ Data ³ 17/07/13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Retorna os valores que serao impressos pelo painel             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Quebra Operacional >> Categoria de produtos                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function ProcInd25()

Local aArea  	:= GetArea()
Local cCont		:= 0 // contador de serie
Local cQuery    := ""// Texto SQL que é enviado para o comando TCGenQry
Local aTotal    := {}
Local nI        := 0
Local nTotal    := 0 //limitador do numero de registros por ranking
Local lAchou    := .F.
  
cQuery :=	" SELECT MFJ.MFJ_FILIAL,MFJ.MFJ_PRODUT,ACV.ACV_CATEGO,MFJ.MFJ_QUANT,MFJ.MFJ_CODIGO,MFJ.MFJ_VUNIT " +;
			" FROM 	" + RetSqlName("MFJ")  +" MFJ LEFT JOIN 	" + RetSqlName("ACV")  +" ACV on ACV.ACV_CODPRO  = MFJ.MFJ_PRODUT " +;
			" WHERE ACV.ACV_CATEGO IN (SELECT ACU_COD  FROM 	" + RetSqlName("ACU") +;
			"                      WHERE  ACU_CODPAI >= '" + mv_par11 + "'" +;//CATEGORIA
			"                         AND ACU_CODPAI <= '" + mv_par12 + "'" +;//CATEGORIA
			"                         AND D_E_L_E_T_ = ' ') " +;
	        " AND " +LJ7017QryFil(.F.,"MFJ")[2]
If lGestao .AND. lACVComp	// Se a tabela ACV for compartilhada aceito a filial corrente
	cQuery += " AND ACV.ACV_FILIAL = '" + xFilial("ACV") + "' "
Else 						// Se a tabela ACV for exclusiva comparo as Filiais
	cQuery += " AND ACV.ACV_FILIAL = MFJ.MFJ_FILIAL "
EndIf
cQuery += 	" AND ACV.ACV_GRUPO >= '" + mv_par13 + "'" +;
			" AND ACV.ACV_GRUPO <= '" + mv_par14 + "'" +;
			" AND MFJ_PRODUT >= '" + mv_par15 + "'" +;
	        " AND MFJ_PRODUT <= '" + mv_par16 + "'" +;
	  		" AND MFJ_QUANT <> '0' " +;
	        " AND MFJ_DATA >= '" + DToS(mv_par09) + "'"  +;
	        " AND MFJ_DATA <= '" + DToS(mv_par10) + "'"  +;
	 	    " AND ACV.D_E_L_E_T_ = ' ' " +;
	   		" AND MFJ.D_E_L_E_T_ = ' ' " +;
			" GROUP BY MFJ_FILIAL,MFJ_CODIGO,MFJ_PRODUT,ACV_CATEGO,MFJ_QUANT,MFJ_VUNIT "+;
			" ORDER BY MFJ_FILIAL,ACV_CATEGO "

cQuery := ChangeQuery(cQuery)

DbSelectArea("MFJ")
DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), 'MFJTRB', .F., .T.)

While MFJTRB->(!Eof()) 			
	 
    If cCont == 0 
  		Aadd(aTotal,{MFJTRB->ACV_CATEGO,(val(MFJTRB->MFJ_QUANT) * MFJTRB->MFJ_VUNIT ),"", val(MFJTRB->MFJ_QUANT)})
  		lAchou := .T.
    Else             
	    For nI:= 1 to len(aTotal)
	    	If MFJTRB->ACV_CATEGO == aTotal[nI][1]
	    		aTotal[nI][2] := aTotal[nI][2] + (val(MFJTRB->MFJ_QUANT) * MFJTRB->MFJ_VUNIT ) //incrementa o totalizador da mesma categoria
	    		aTotal[nI][4] := aTotal[nI][4] + val(MFJTRB->MFJ_QUANT)  //incrementa o totalizador da mesma categoria
	    		lAchou := .T.
            Endif
	    Next nI
	Endif

	If !lAchou
		Aadd(aTotal,{MFJTRB->ACV_CATEGO,(val(MFJTRB->MFJ_QUANT) * MFJTRB->MFJ_VUNIT ),"", val(MFJTRB->MFJ_QUANT)})//adiciona uma nova categoria 
    Endif
    
	cCont ++
	
	lAchou := .F.
	
	MFJTRB->(dbSkip())

EndDo
 
//Ordernar do maior para o menor valor 
ASORT(aTotal,,,{ | x,y | x[2] > y[2] } )

If len(aTotal) < len(aSerie)
   nTotal := len(aTotal)
Else
   nTotal := len(aSerie)   
Endif

For nI:= 1 to nTotal
	aSerie[nI][1] := "Cod:" + AllTrim(aTotal[nI][1])
	aSerie[nI][2] := aTotal[nI][2]//Total 
	aSerie[nI][3] := AllTrim(aTotal[nI][1])+"-"+AllTrim(Posicione( "ACU", 1, xFilial("ACU")+aTotal[nI][1], "ACU_DESC" ))//Categoria de produtos
	aSerie[nI][4] := aTotal[nI][4]//Total
Next nI  

RestArea(aArea)
MFJTRB->(DbCloseArea())

Return aSerie


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ProcInd26        ³Autor  ³TOTVS               ³ Data ³ 17/07/13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Retorna os valores que serao impressos pelo painel             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Quebra Operacional >> Grupo de produtos                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function ProcInd26()

Local aArea  	:= GetArea()
Local cCont		:= 0 // contador de serie
Local cQuery    := ""// Texto SQL que é enviado para o comando TCGenQry
Local aTotal    := {}
Local nI        := 0
Local nTotal    := 0 //limitador do numero de registros por ranking
Local lAchou    := .F.
  
cQuery :=	" SELECT MFJ.MFJ_FILIAL,MFJ.MFJ_PRODUT,ACV.ACV_CATEGO,ACV.ACV_GRUPO,MFJ.MFJ_QUANT,MFJ.MFJ_CODIGO,MFJ.MFJ_VUNIT " +;
			" FROM 	" + RetSqlName("MFJ")  +" MFJ LEFT JOIN 	" + RetSqlName("ACV")  +" ACV on ACV.ACV_CODPRO  = MFJ.MFJ_PRODUT " +;
			" WHERE ACV.ACV_CATEGO IN (SELECT ACU_COD  FROM 	" + RetSqlName("ACU") +;
			"                      WHERE  ACU_CODPAI >= '" + mv_par11 + "'" +;//CATEGORIA
			"                         AND ACU_CODPAI <= '" + mv_par12 + "'" +;//CATEGORIA
			"                         AND D_E_L_E_T_ = ' ') " +;   
	        " AND " +LJ7017QryFil(.F.,"MFJ")[2]
If lGestao .AND. lACVComp	// Se a tabela ACV for compartilhada aceito a filial corrente
	cQuery += " AND ACV.ACV_FILIAL = '" + xFilial("ACV") + "' "
Else 						// Se a tabela ACV for exclusiva comparo as Filiais
	cQuery += " AND ACV.ACV_FILIAL = MFJ.MFJ_FILIAL "
EndIf
cQuery += 	" AND ACV.ACV_GRUPO >= '" + mv_par13 + "'" +;
			" AND ACV.ACV_GRUPO <= '" + mv_par14 + "'" +;
			" AND MFJ_PRODUT >= '" + mv_par15 + "'" +;
            " AND MFJ_PRODUT <= '" + mv_par16 + "'" +;
     		" AND MFJ_QUANT <> '0' " +;
 	 	    " AND ACV.D_E_L_E_T_ = ' ' " +;
     		" AND MFJ.D_E_L_E_T_ = ' ' " +;
            " AND MFJ_DATA >= '" + DToS(mv_par09) + "'"  +;
            " AND MFJ_DATA <= '" + DToS(mv_par10) + "'"  +;
			" GROUP BY MFJ_FILIAL,MFJ_CODIGO,MFJ_PRODUT,ACV.ACV_CATEGO,ACV_GRUPO,MFJ_QUANT,MFJ_VUNIT "

cQuery := ChangeQuery(cQuery)

DbSelectArea("MFJ")
DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), 'MFJTRB', .F., .T.)

While MFJTRB->(!Eof()) 			
	 
    If cCont == 0 
  		Aadd(aTotal,{MFJTRB->ACV_GRUPO,(val(MFJTRB->MFJ_QUANT) * MFJTRB->MFJ_VUNIT ),"", Val(MFJTRB->MFJ_QUANT)})
  		lAchou := .T.
    Else             
	    For nI:= 1 to len(aTotal)
	    	If MFJTRB->ACV_GRUPO == aTotal[nI][1] 
	    		aTotal[nI][2] := aTotal[nI][2] + (val(MFJTRB->MFJ_QUANT) * MFJTRB->MFJ_VUNIT ) //incrementa o totalizador do mesmo Grupo de produtos
	    		aTotal[nI][4] := aTotal[nI][4] + val(MFJTRB->MFJ_QUANT)  //incrementa o totalizador do mesmo Grupo de produtos
	    		lAchou := .T.
            Endif
	    Next nI
	Endif

	If !lAchou
  		Aadd(aTotal,{MFJTRB->ACV_GRUPO,(val(MFJTRB->MFJ_QUANT) * MFJTRB->MFJ_VUNIT ),"", Val(MFJTRB->MFJ_QUANT)})//adiciona um novo Grupo de produtos 
    Endif
    
	cCont ++
	
	lAchou := .F.
	
	MFJTRB->(dbSkip())

EndDo
 
//Ordernar do maior para o menor valor 
ASORT(aTotal,,,{ | x,y | x[2] > y[2] } )

If len(aTotal) < len(aSerie)
   nTotal := len(aTotal)
Else
   nTotal := len(aSerie)   
Endif

For nI:= 1 to nTotal
	aSerie[nI][1] := "Cod:" + AllTrim(aTotal[nI][1])
	aSerie[nI][2] := aTotal[nI][2]//Total 
	aSerie[nI][3] := AllTrim(aTotal[nI][1])+"-"+AllTrim(Posicione("SBM",1,xFilial("SBM")+aTotal[nI][1],"BM_DESC"))//Grupo de produtos 
	aSerie[nI][4] := aTotal[nI][4]//Total
Next nI  

RestArea(aArea)
MFJTRB->(DbCloseArea())

Return aSerie


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ProcInd26        ³Autor  ³TOTVS               ³ Data ³ 17/07/13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Retorna os valores que serao impressos pelo painel             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Quebra Operacional >> Produtos                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function ProcInd27()

Local aArea  	:= GetArea()
Local cCont		:= 0  // contador de serie
Local cQuery    := "" // Texto SQL que é enviado para o comando TCGenQry
Local aTotal    := {}
Local nI        := 0
Local nTotal    := 0 //limitador do numero de registros por ranking
Local lAchou    := .F.
  
If lCatProd
 	cQuery :=	" SELECT MFJ.MFJ_FILIAL,MFJ.MFJ_CODIGO,MFJ.MFJ_PRODUT,MFJ.MFJ_QUANT,MFJ.MFJ_VUNIT,ACV.ACV_CATEGO " +;
				" FROM 	" + RetSqlName("MFJ")  +" MFJ LEFT JOIN 	" + RetSqlName("ACV")  +" ACV on ACV.ACV_CODPRO  = MFJ.MFJ_PRODUT " +;
				" WHERE ACV.ACV_CATEGO IN (SELECT ACU_COD  FROM 	" + RetSqlName("ACU") +;
				"                      WHERE  ACU_CODPAI >= '" + mv_par11 + "'" +;//CATEGORIA
				"                         AND ACU_CODPAI <= '" + mv_par12 + "'" +;//CATEGORIA
				"                         AND D_E_L_E_T_ = ' ') " +;   
		        " AND " + LJ7017QryFil(.F.,"MFJ")[2]
	If lGestao .AND. lACVComp	// Se a tabela ACV for compartilhada aceito a filial corrente
		cQuery += " AND ACV.ACV_FILIAL = '" + xFilial("ACV") + "' "
	Else 						// Se a tabela ACV for exclusiva comparo as Filiais
		cQuery += " AND ACV.ACV_FILIAL = MFJ.MFJ_FILIAL "
	EndIf
	cQuery += 	" AND ACV.ACV_GRUPO >= '" + mv_par13 + "'" +;
				" AND ACV.ACV_GRUPO <= '" + mv_par14 + "'" +;
				" AND MFJ_PRODUT >= '" + mv_par15 + "'" +;
		        " AND MFJ_PRODUT <= '" + mv_par16 + "'" +;
		  		" AND MFJ_QUANT <> '0' " +;
		 	    " AND ACV.D_E_L_E_T_ = ' ' " +;
		  		" AND MFJ.D_E_L_E_T_ = ' ' " +;
		        " AND MFJ_DATA >= '" + DToS(mv_par09) + "'"  +;
		        " AND MFJ_DATA <= '" + DToS(mv_par10) + "'"  +;
				" GROUP BY MFJ_FILIAL,MFJ_CODIGO,MFJ_PRODUT,MFJ_QUANT,MFJ_VUNIT,ACV.ACV_CATEGO "
Else
   	cQuery :=	" SELECT MFJ.MFJ_FILIAL, MFJ.MFJ_PRODUT,MFJ.MFJ_QUANT,MFJ.MFJ_VUNIT" +;
		" FROM 	" + RetSqlName("MFJ")  +" MFJ " +;
		" WHERE " +LJ7017QryFil(.F.,"MFJ")[2] +;
		" AND MFJ_PRODUT >= '" + mv_par15 + "'" +;
        " AND MFJ_PRODUT <= '" + mv_par16 + "'" +;
  		" AND MFJ_QUANT <> '0' " +;
  		" AND MFJ.D_E_L_E_T_ = ' ' " +;
        " AND MFJ_DATA >= '" + DToS(mv_par09) + "'"  +;
        " AND MFJ_DATA <= '" + DToS(mv_par10) + "'"  +;
		" GROUP BY MFJ_FILIAL, MFJ_CODIGO, MFJ_PRODUT, MFJ_QUANT, MFJ_VUNIT "
Endif

cQuery := ChangeQuery(cQuery)

DbSelectArea("MFJ")
DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), 'MFJTRB', .F., .T.)

While MFJTRB->(!Eof()) 			
	 
    If cCont == 0 
		Aadd(aTotal,{MFJTRB->MFJ_PRODUT,(val(MFJTRB->MFJ_QUANT) * MFJTRB->MFJ_VUNIT ),"", val(MFJTRB->MFJ_QUANT)})
  		lAchou := .T.
    Else             
	    For nI:= 1 to len(aTotal)
	    	If MFJTRB->MFJ_PRODUT == aTotal[nI][1] 
	    		aTotal[nI][2] := aTotal[nI][2] + (val(MFJTRB->MFJ_QUANT) * MFJTRB->MFJ_VUNIT ) //incrementa o totalizador do mesmo produto
	    		aTotal[nI][4] := aTotal[nI][4] + val(MFJTRB->MFJ_QUANT)  //incrementa o totalizador do mesmo produto
	    		lAchou := .T.
            Endif
	    Next nI
	Endif

	If !lAchou
  		Aadd(aTotal,{MFJTRB->MFJ_PRODUT,(val(MFJTRB->MFJ_QUANT) * MFJTRB->MFJ_VUNIT ),"", val(MFJTRB->MFJ_QUANT)})//adiciona um novo produto
    Endif
    
	cCont ++
	
	lAchou := .F.
	
	MFJTRB->(dbSkip())

EndDo
 
//Ordernar do maior para o menor valor 
ASORT(aTotal,,,{ | x,y | x[2] > y[2] } )

If len(aTotal) < len(aSerie)
   nTotal := len(aTotal)
Else
   nTotal := len(aSerie)   
Endif

For nI:= 1 to nTotal	
	aSerie[nI][1] := "Cod:" + AllTrim(aTotal[nI][1])
	aSerie[nI][2] := aTotal[nI][2]//Total 
	aSerie[nI][3] := AllTrim(aTotal[nI][1])+"-"+AllTrim(Posicione( "SB1", 1, xFilial("SB1")+alltrim(aTotal[nI][1]), "B1_DESC" )) //Produto - Descricao
	aSerie[nI][4] := aTotal[nI][4]//Total 
Next nI  

RestArea(aArea)
MFJTRB->(DbCloseArea())

Return aSerie

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ProcInd28        ³Autor  ³TOTVS               ³ Data ³ 17/07/13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Retorna os valores que serao impressos pelo painel             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Quebra Operacional >> Motivo                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function ProcInd28()

Local aArea  	:= GetArea()
Local cCont		:= 0 // contador de serie
Local cQuery    := ""// Texto SQL que é enviado para o comando TCGenQry
Local aTotal    := {}         
Local nI        := 0
Local nTotal    := 0 //limitador do numero de registros por ranking
Local lAchou    := .F.
  
If lCatProd 
 	cQuery :=	" SELECT MFJ.MFJ_FILIAL,MFJ.MFJ_CODMOT,MFJ_QUANT,MFJ_CODIGO,MFJ_VUNIT,ACV.ACV_CATEGO " +;
				" FROM 	" + RetSqlName("MFJ")  +" MFJ LEFT JOIN 	" + RetSqlName("ACV")  +" ACV on ACV.ACV_CODPRO  = MFJ.MFJ_PRODUT " +;
				" WHERE ACV.ACV_CATEGO IN (SELECT ACU_COD  FROM 	" + RetSqlName("ACU") +;
				"                      WHERE  ACU_CODPAI >= '" + mv_par11 + "'" +;//CATEGORIA
				"                         AND ACU_CODPAI <= '" + mv_par12 + "'" +;//CATEGORIA
				"                         AND D_E_L_E_T_ = ' ') " +;
		        " AND " +LJ7017QryFil(.F.,"MFJ")[2]
	If lGestao .AND. lACVComp	// Se a tabela ACV for compartilhada aceito a filial corrente
		cQuery += " AND ACV.ACV_FILIAL = '" + xFilial("ACV") + "' "
	Else 						// Se a tabela ACV for exclusiva comparo as Filiais
		cQuery += " AND ACV.ACV_FILIAL = MFJ.MFJ_FILIAL "
	EndIf
	cQuery += 	" AND ACV.ACV_GRUPO >= '" + mv_par13 + "'" +;
				" AND ACV.ACV_GRUPO <= '" + mv_par14 + "'" +;
				" AND MFJ_PRODUT >= '" + mv_par15 + "'" +;
	            " AND MFJ_PRODUT <= '" + mv_par16 + "'" +;
	     		" AND MFJ_QUANT <> '0' " +;
	            " AND MFJ_CODMOT BETWEEN '" + mv_par19 + "' and '" + mv_par20+"'"	+; 
	            " AND MFJ_DATA >= '" + DToS(mv_par09) + "'"  +;
	            " AND MFJ_DATA <= '" + DToS(mv_par10) + "'"  +;
	 	 	    " AND ACV.D_E_L_E_T_ = ' ' " +;
	     		" AND MFJ.D_E_L_E_T_ = ' ' " +;
				" GROUP BY MFJ_FILIAL,MFJ_CODIGO,MFJ_CODMOT,MFJ_QUANT,MFJ_VUNIT,ACV.ACV_CATEGO  "
Else
 	cQuery :=	" SELECT MFJ.MFJ_FILIAL, MFJ.MFJ_CODMOT , MFJ_QUANT, MFJ_VUNIT, MFJ_CODIGO" +;
			" FROM 	" + RetSqlName("MFJ")  +" MFJ " +;
			" WHERE " +LJ7017QryFil(.F.,"MFJ")[2]	 +; 			    		
			" AND MFJ_PRODUT >= '" + mv_par15 + "'" +;
            " AND MFJ_PRODUT <= '" + mv_par16 + "'" +;
     		" AND MFJ_QUANT <> '0' " +;
            " AND MFJ_CODMOT BETWEEN '" + mv_par19 + "' and '" + mv_par20+"'"	+;	 	 	   
            " AND MFJ_DATA >= '" + DToS(mv_par09) + "'"  +;
            " AND MFJ_DATA <= '" + DToS(mv_par10) + "'"  +;
     		" AND MFJ.D_E_L_E_T_ = ' ' " +;   
			" GROUP BY MFJ_FILIAL, MFJ_CODIGO, MFJ_CODMOT, MFJ_QUANT, MFJ_VUNIT " 
Endif

cQuery := ChangeQuery(cQuery)

DbSelectArea("MFJ")
DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), 'MFJTRB', .F., .T.)

While MFJTRB->(!Eof()) 			
	 
    If cCont == 0 
  		Aadd(aTotal,{MFJTRB->MFJ_CODMOT,(val(MFJTRB->MFJ_QUANT) * MFJTRB->MFJ_VUNIT ),"", val(MFJTRB->MFJ_QUANT)})
  		lAchou := .T.
    Else             
	    For nI:= 1 to len(aTotal)
	    	If MFJTRB->MFJ_CODMOT == aTotal[nI][1] 
	    		aTotal[nI][2] := aTotal[nI][2] + (val(MFJTRB->MFJ_QUANT) * MFJTRB->MFJ_VUNIT ) //incrementa o totalizador da mesma categoria
	    		aTotal[nI][4] := aTotal[nI][4] + val(MFJTRB->MFJ_QUANT)  //incrementa o totalizador da mesma categoria
	    		lAchou := .T.
            Endif
	    Next nI
	Endif

	If !lAchou
  		Aadd(aTotal,{MFJTRB->MFJ_CODMOT,(val(MFJTRB->MFJ_QUANT) * MFJTRB->MFJ_VUNIT ),"", val(MFJTRB->MFJ_QUANT)})//adiciona uma nova categoria
    Endif
    
	cCont ++
	
	lAchou := .F.
	
	MFJTRB->(dbSkip())

EndDo
 
//Ordernar do maior para o menor valor 
ASORT(aTotal,,,{ | x,y | x[2] > y[2] } )

If len(aTotal) < len(aSerie)
   nTotal := len(aTotal)
Else
   nTotal := len(aSerie)   
Endif

For nI:= 1 to nTotal
	aSerie[nI][1] := "Cod:" + AllTrim(aTotal[nI][1])
	aSerie[nI][2] := aTotal[nI][2]//Total 
	aSerie[nI][3] := AllTrim(aTotal[nI][1])+"-"+AllTrim(Posicione( "MFM", 1, xFilial("MFM")+alltrim(aTotal[nI][1]), "MFM_DESCR" ))
	aSerie[nI][4] := aTotal[nI][4]//Total
Next nI  

RestArea(aArea)
MFJTRB->(DbCloseArea())

Return aSerie
 
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ProcInd29        ³Autor  ³TOTVS               ³ Data ³ 17/07/13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Retorna os valores que serao impressos pelo painel             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Quebra Operacional >> Origem                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function ProcInd29()

Local aArea  	:= GetArea()
Local cCont		:= 0  // contador de serie
Local cQuery    := "" // Texto SQL que é enviado para o comando TCGenQry
Local aTotal    := {}         
Local nI        := 0
Local nTotal    := 0 //limitador do numero de registros por ranking
Local lAchou    := .F.
  
If lCatProd 
 	cQuery :=	" SELECT MFJ.MFJ_FILIAL,MFJ.MFJ_CODIGO,MFJ.MFJ_CODORI,MFJ.MFJ_QUANT,MFJ.MFJ_VUNIT,ACV.ACV_CATEGO " +;
				" FROM 	" + RetSqlName("MFJ")  +" MFJ LEFT JOIN 	" + RetSqlName("ACV")  +" ACV on ACV.ACV_CODPRO  = MFJ.MFJ_PRODUT " +;
				" WHERE ACV.ACV_CATEGO IN (SELECT ACU_COD  FROM 	" + RetSqlName("ACU") +;
				"                      WHERE  ACU_CODPAI >= '" + mv_par11 + "'" +;//CATEGORIA
				"                         AND ACU_CODPAI <= '" + mv_par12 + "'" +;//CATEGORIA
				"                         AND D_E_L_E_T_ = ' ') " +;   
		        " AND " +LJ7017QryFil(.F.,"MFJ")[2]
	If lGestao .AND. lACVComp	// Se a tabela ACV for compartilhada aceito a filial corrente
		cQuery += " AND ACV.ACV_FILIAL = '" + xFilial("ACV") + "' "
	Else 						// Se a tabela ACV for exclusiva comparo as Filiais
		cQuery += " AND ACV.ACV_FILIAL = MFJ.MFJ_FILIAL "
	EndIf
	cQuery += 	" AND ACV.ACV_GRUPO >= '" + mv_par13 + "'" +;
				" AND ACV.ACV_GRUPO <= '" + mv_par14 + "'" +;
				" AND MFJ_PRODUT >= '" + mv_par15 + "'" +;
	            " AND MFJ_PRODUT <= '" + mv_par16 + "'" +;
	     		" AND MFJ_QUANT <> '0' " +;
	            " AND MFJ_CODORI BETWEEN '" + mv_par21 + "' and '" + mv_par22+"'"	+;
	 	 	    " AND ACV.D_E_L_E_T_ = ' ' " +;
	     		" AND MFJ.D_E_L_E_T_ = ' ' " +;
	            " AND MFJ_DATA >= '" + DToS(mv_par09) + "'"  +;
	            " AND MFJ_DATA <= '" + DToS(mv_par10) + "'"  +;
				" GROUP BY MFJ_FILIAL,MFJ_CODIGO, MFJ_CODORI,MFJ_QUANT,MFJ_VUNIT,ACV.ACV_CATEGO "
Else
  	cQuery :=	" SELECT MFJ.MFJ_FILIAL,MFJ.MFJ_CODORI,MFJ.MFJ_QUANT,MFJ.MFJ_VUNIT" +;
			" FROM 	" + RetSqlName("MFJ")  +" MFJ " +;
			" WHERE " +LJ7017QryFil(.F.,"MFJ")[2]	 +;
			" AND MFJ_PRODUT >= '" + mv_par15 + "'" +;
            " AND MFJ_PRODUT <= '" + mv_par16 + "'" +;
     		" AND MFJ_QUANT <> '0' " +;
            " AND MFJ_CODORI BETWEEN '" + mv_par21 + "' and '" + mv_par22+"'"	+;
     		" AND MFJ.D_E_L_E_T_ = ' ' " +;
            " AND MFJ_DATA >= '" + DToS(mv_par09) + "'"  +;
            " AND MFJ_DATA <= '" + DToS(mv_par10) + "'"  +;
			" GROUP BY MFJ_FILIAL, MFJ_CODIGO, MFJ_CODORI, MFJ_QUANT, MFJ_VUNIT" "
Endif
 
cQuery := ChangeQuery(cQuery)

DbSelectArea("MFJ")
DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), 'MFJTRB', .F., .T.)

While MFJTRB->(!Eof()) 			
	 
    If cCont == 0 
  		Aadd(aTotal,{MFJTRB->MFJ_CODORI,(val(MFJTRB->MFJ_QUANT) * MFJTRB->MFJ_VUNIT ),"", val(MFJTRB->MFJ_QUANT)})
  		lAchou := .T.
    Else             
	    For nI:= 1 to len(aTotal)
	    	If MFJTRB->MFJ_CODORI == aTotal[nI][1] 
	    		aTotal[nI][2] := aTotal[nI][2] + (val(MFJTRB->MFJ_QUANT) * MFJTRB->MFJ_VUNIT ) //incrementa o totalizador da mesma categoria
	    		aTotal[nI][4] := aTotal[nI][4] + val(MFJTRB->MFJ_QUANT)  //incrementa o totalizador da mesma categoria
	    		lAchou := .T.
            Endif
	    Next nI
	Endif

	If !lAchou
  		Aadd(aTotal,{MFJTRB->MFJ_CODORI,(val(MFJTRB->MFJ_QUANT) * MFJTRB->MFJ_VUNIT ),"", val(MFJTRB->MFJ_QUANT)})//adiciona uma nova categoria 
    Endif
    
	cCont ++
	
	lAchou := .F.
	
	MFJTRB->(dbSkip())

EndDo
 
//Ordernar do maior para o menor valor 
ASORT(aTotal,,,{ | x,y | x[2] > y[2] } )

If len(aTotal) < len(aSerie)
   nTotal := len(aTotal)
Else
   nTotal := len(aSerie)   
Endif

For nI:= 1 to nTotal
	aSerie[nI][1] := "Cod:" + AllTrim(aTotal[nI][1])
	aSerie[nI][2] := aTotal[nI][2]//Total 
	aSerie[nI][3] := AllTrim(aTotal[nI][1])+"-"+AllTrim(Posicione( "MFK", 1, xFilial("MFK")+alltrim(aTotal[nI][1]), "MFK_DESCR" ))
	aSerie[nI][4] := aTotal[nI][4]//Total
Next nI  

RestArea(aArea)
MFJTRB->(DbCloseArea())

Return aSerie


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ProcInd30        ³Autor  ³TOTVS               ³ Data ³ 17/07/13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Retorna os valores que serao impressos pelo painel             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Quebra Operacional >> Ocorrencia                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function ProcInd30()

Local aArea  	:= GetArea()
Local cCont		:= 0 // contador de serie
Local cQuery    := ""// Texto SQL que é enviado para o comando TCGenQry
Local aTotal    := {}         
Local nI        := 0
Local nTotal    := 0 //limitador do numero de registros por ranking
Local lAchou    := .F.
 
If lCatProd 
 	cQuery :=	" SELECT MFJ.MFJ_FILIAL,MFJ.MFJ_CODIGO,MFJ.MFJ_CODOCO,MFJ.MFJ_QUANT,MFJ.MFJ_VUNIT,ACV.ACV_CATEGO " +;
				" FROM 	" + RetSqlName("MFJ")  +" MFJ LEFT JOIN 	" + RetSqlName("ACV")  +" ACV on ACV.ACV_CODPRO  = MFJ.MFJ_PRODUT " +;
				" WHERE ACV.ACV_CATEGO IN (SELECT ACU_COD  FROM 	" + RetSqlName("ACU") +;
				"                      WHERE  ACU_CODPAI >= '" + mv_par11 + "'" +;//CATEGORIA
				"                         AND ACU_CODPAI <= '" + mv_par12 + "'" +;//CATEGORIA
				"                         AND D_E_L_E_T_ = ' ') " +;
		        " AND " +LJ7017QryFil(.F.,"MFJ")[2]
	If lGestao .AND. lACVComp	// Se a tabela ACV for compartilhada aceito a filial corrente
		cQuery += " AND ACV.ACV_FILIAL = '" + xFilial("ACV") + "' "
	Else 						// Se a tabela ACV for exclusiva comparo as Filiais
		cQuery += " AND ACV.ACV_FILIAL = MFJ.MFJ_FILIAL "
	EndIf
	cQuery += 	" AND ACV.ACV_GRUPO >= '" + mv_par13 + "'" +;
				" AND ACV.ACV_GRUPO >= '" + mv_par13 + "'" +;
				" AND ACV.ACV_GRUPO <= '" + mv_par14 + "'" +;
				" AND MFJ_PRODUT >= '" + mv_par15 + "'" +;
	            " AND MFJ_PRODUT <= '" + mv_par16 + "'" +;
	     		" AND MFJ_QUANT <> '0' " +;
	            " AND MFJ_CODOCO BETWEEN '" + mv_par23 + "' and '" + mv_par24+"'"	+;
	            " AND MFJ_DATA >= '" + DToS(mv_par09) + "'"  +;
	            " AND MFJ_DATA <= '" + DToS(mv_par10) + "'"  +;
	 	 	    " AND ACV.D_E_L_E_T_ = ' ' " +;
	     		" AND MFJ.D_E_L_E_T_ = ' ' " +;
				" GROUP BY MFJ_FILIAL,MFJ_CODIGO,MFJ_CODOCO,MFJ_QUANT,MFJ_VUNIT,ACV.ACV_CATEGO"
Else
 	cQuery :=	" SELECT MFJ.MFJ_FILIAL,MFJ.MFJ_CODOCO,MFJ.MFJ_QUANT,MFJ.MFJ_VUNIT " +;
			" FROM 	" + RetSqlName("MFJ")  +" MFJ " +;
			" WHERE " +LJ7017QryFil(.F.,"MFJ")[2]	 +;
			" AND MFJ_PRODUT >= '" + mv_par15 + "'" +;
            " AND MFJ_PRODUT <= '" + mv_par16 + "'" +;
     		" AND MFJ_QUANT <> '0' " +;
            " AND MFJ_CODOCO BETWEEN '" + mv_par23 + "' and '" + mv_par24+"'"	+;
            " AND MFJ_DATA >= '" + DToS(mv_par09) + "'"  +;
            " AND MFJ_DATA <= '" + DToS(mv_par10) + "'"  +;
     		" AND MFJ.D_E_L_E_T_ = ' ' " +;
			" GROUP BY MFJ_FILIAL, MFJ_CODIGO,MFJ_CODOCO,MFJ_QUANT,MFJ_VUNIT "
Endif

cQuery := ChangeQuery(cQuery)

DbSelectArea("MFJ")
DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), 'MFJTRB', .F., .T.)

While MFJTRB->(!Eof()) 			
	 
    If cCont == 0 
  		Aadd(aTotal,{MFJTRB->MFJ_CODOCO,(val(MFJTRB->MFJ_QUANT) * MFJTRB->MFJ_VUNIT ),"", val(MFJTRB->MFJ_QUANT)})
  		lAchou := .T.
    Else             
	    For nI:= 1 to len(aTotal)
	    	If MFJTRB->MFJ_CODOCO == aTotal[nI][1] 
	    		aTotal[nI][2] := aTotal[nI][2] + (val(MFJTRB->MFJ_QUANT) * MFJTRB->MFJ_VUNIT ) //incrementa o totalizador da mesma categoria
	    		aTotal[nI][4] := aTotal[nI][4] + val(MFJTRB->MFJ_QUANT)  //incrementa o totalizador da mesma categoria
	    		lAchou := .T.
            Endif
	    Next nI
	Endif

	If !lAchou
  		Aadd(aTotal,{MFJTRB->MFJ_CODOCO,(val(MFJTRB->MFJ_QUANT) * MFJTRB->MFJ_VUNIT ),"", val(MFJTRB->MFJ_QUANT)})//adiciona uma nova categoria
    Endif
    
	cCont ++
	
	lAchou := .F.
	
	MFJTRB->(dbSkip())

EndDo
 
//Ordernar do maior para o menor valor 
ASORT(aTotal,,,{ | x,y | x[2] > y[2] } )

If len(aTotal) < len(aSerie)
   nTotal := len(aTotal)
Else
   nTotal := len(aSerie)   
Endif

For nI:= 1 to nTotal
	aSerie[nI][1] := "Cod:" + AllTrim(aTotal[nI][1])
	aSerie[nI][2] := aTotal[nI][2]//Total 
	aSerie[nI][3] := AllTrim(aTotal[nI][1])+"-"+AllTrim(Posicione( "MFN", 1, xFilial("MFN")+alltrim(aTotal[nI][1]), "MFN_DESCR" ))
	aSerie[nI][4] := aTotal[nI][4]//Total
Next nI  

RestArea(aArea)
MFJTRB->(DbCloseArea())

Return aSerie

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ProcInd31        ³Autor  ³TOTVS               ³ Data ³ 22/07/13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Retorna os valores que serao impressos pelo painel             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Quebra Conf.Caixa >> Grupo de Filial                           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function ProcInd31()

Local aArea  	:= GetArea()
Local cCont		:= 0  // contador de serie
Local cQuery    := ""// Texto SQL que é enviado para o comando TCGenQry
Local aTotal    := {}
Local nI,nY     := 0
Local nTotal    := 0 //limitador do numero de registros por ranking
Local lAchou    := .F.  
Local cFiliais  := ""

cQuery :=	" SELECT  SAU.AU_CODGRUP, SAU.AU_DESCRI, SLW.LW_FILIAL, MBI_CODACA, LW_OPERADO, MBH_FORMPG, LW_PDV, LW_NUMMOV, MBH_ESTACA, LW_DTABERT,LW_SERIE,LW_HRABERT,LT_VLRAPU,LT_VLRDIG,LT_VLRAPU-LT_VLRDIG VLRDIF " +;
		" FROM 	" + RetSqlName("SLT")  +" SLT,"+ RetSqlName("MBH")  +" MBH,"+ RetSqlName("MBI")  +" MBI, "+  RetSqlName("SLW")  +" SLW "+;
		" INNER JOIN " + RetSqlName("SAU") + " SAU " +;
		" ON SAU.D_E_L_E_T_ = ' ' AND SAU.AU_CODFIL = SLW.LW_FILIAL " +;
		" WHERE  " + LJ7017QryFil(.F.,"SLW")[2] +;
		" AND LW_OPERADO >= '" + mv_par05 + "'"  +;
		" AND LW_OPERADO <= '" + mv_par06 + "'"  +;
		" AND LW_DTFECHA >= '" + DToS(mv_par09) + "'"  +;
		" AND LW_DTFECHA <= '" + DToS(mv_par10) + "'"  +;
		" AND LT_FILIAL = LW_FILIAL "+;
		" AND LT_DTFECHA = LW_DTFECHA "+;
		" AND LW_NUMMOV = LT_NUMMOV  "+; 
		" AND LW_OPERADO = LT_OPERADO  "+;
		" AND LW_ESTACAO  = LT_ESTACAO  "+;
		" AND LW_PDV = LT_PDV  "+;
		" AND LT_CONFERE = '1'  "+;
		" AND LT_VLRDIG <> 0 "+;
		" AND MBH_FILIAL = LW_FILIAL " +;
		" AND MBH_OPERAD = LW_OPERADO "+;
		" AND MBH_DATA  = LT_DTFECHA " +;
		" AND MBH_FORMPG = LT_FORMPG " +;
		" AND MBH_PDV= LW_PDV " +;
		" AND MBH_NUMMOV = LW_NUMMOV  "+;
		" AND MBI_FILIAL = MBH_FILIAL "+;
		" AND MBI_CODACA = MBH_ACAO   "+;
		" AND MBI.D_E_L_E_T_ = ' ' " +;
		" AND MBH.D_E_L_E_T_ = ' ' " +;
		" AND SLW.D_E_L_E_T_ = ' ' " +;
		" GROUP BY SAU.AU_CODGRUP, SAU.AU_DESCRI, SLW.LW_FILIAL, MBI_CODACA, LW_OPERADO, MBH_FORMPG, LW_PDV, LW_NUMMOV, MBH_ESTACA, LW_DTABERT,LW_SERIE,LW_HRABERT,LT_VLRAPU,LT_VLRDIG"				

cQuery := ChangeQuery(cQuery)

DbSelectArea("SLW")
DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), 'SLWTRB', .F., .T.)

While SLWTRB->(!Eof()) 			

    If cCont == 0 
  		Aadd(aTotal,{SLWTRB->AU_CODGRUP,(SLWTRB->VLRDIF),AllTrim(SLWTRB->AU_DESCRI),cCont+1})
  		lAchou := .T.
    Else             
	    For nI:= 1 to len(aTotal)
	    	If SLWTRB->AU_CODGRUP == aTotal[nI][1] 
	    		aTotal[nI][2] := aTotal[nI][2] + (SLWTRB->VLRDIF)
		    	aTotal[nI][4] := aTotal[nI][4] + 1
	    		lAchou := .T.
            Endif
	    Next nI
	Endif

	If !lAchou
  		cCont := 0
  		Aadd(aTotal,{SLWTRB->AU_CODGRUP,(SLWTRB->VLRDIF),AllTrim(SLWTRB->AU_DESCRI),cCont+1})//adiciona uma nova filial 
	Endif

	cCont ++
	
	lAchou := .F.
	
	SLWTRB->(dbSkip())
EndDo	              

SLWTRB->(DbCloseArea())
	 
//Ordernar do maior para o menor valor 
ASORT(aTotal,,,{ | x,y | x[2] > y[2] } )

//Limitar o numero de registros pelo numero de ranking informado
If len(aTotal) < len(aSerie)
   nTotal := len(aTotal)
Else
   nTotal := len(aSerie)   
Endif

For nI:= 1 to nTotal
	aSerie[nI][1] := "Cod:" + AllTrim(aTotal[nI][1])	
	aSerie[nI][2] := aTotal[nI][2]//quantidade
	aSerie[nI][3] := AllTrim(aTotal[nI][1])+"-"+AllTrim(aTotal[nI][3])
	aSerie[nI][4] := aTotal[nI][4]
Next nI  

RestArea(aArea)

Return aSerie


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ProcInd32        ³Autor  ³TOTVS               ³ Data ³ 22/07/13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Retorna os valores que serao impressos pelo painel             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Quebra Conf.Caixa >> Filial                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function ProcInd32()

Local aArea  	:= GetArea()
Local cCont		:= 0 // contador de serie
Local cQuery    := ""// Texto SQL que é enviado para o comando TCGenQry
Local aTotal    := {}
Local nI,nY     := 0
Local nTotal    := 0 //limitador do numero de registros por ranking
Local lAchou    := .F.  
Local cFiliais  := ""
Local nPos		:= 1
Local aFiliais 	:= Lj7017Fil()// Recebera o retorna dos nomes das Filiais	
Local nY        := 0

cQuery :=	" SELECT  SLW.LW_FILIAL, MBI_CODACA, LW_OPERADO, MBH_FORMPG, LW_PDV, LW_NUMMOV, MBH_ESTACA, LW_DTABERT,LW_SERIE,LW_HRABERT,LT_VLRAPU,LT_VLRDIG,LT_VLRAPU-LT_VLRDIG VLRDIF" +;
			" FROM 	" + RetSqlName("SLW")  +" SLW, "+ RetSqlName("SLT")  +" SLT,"+ RetSqlName("MBH")  +" MBH,"+ RetSqlName("MBI")  +" MBI" +;
		    " WHERE  " + LJ7017QryFil(.F.,"SLW")[2] +;
			" AND LW_OPERADO >= '" + mv_par05 + "'"  +;
			" AND LW_OPERADO <= '" + mv_par06 + "'"  +;
			" AND LW_DTFECHA >= '" + DToS(mv_par09) + "'"  +;
			" AND LW_DTFECHA <= '" + DToS(mv_par10) + "'"  +;
			" AND LT_FILIAL = LW_FILIAL "+;
			" AND LT_DTFECHA = LW_DTFECHA "+;
			" AND LW_NUMMOV = LT_NUMMOV  "+; 
			" AND LW_OPERADO = LT_OPERADO  "+;
			" AND LW_ESTACAO  = LT_ESTACAO  "+;
			" AND LW_PDV = LT_PDV  "+;
			" AND LT_CONFERE = '1'  "+;
			" AND LT_VLRDIG <> 0 "+;
			" AND MBH_FILIAL = LW_FILIAL  "+;
			" AND MBH_OPERAD = LW_OPERADO "+;
			" AND MBH_DATA  = LT_DTFECHA "+;
			" AND MBH_FORMPG = LT_FORMPG "+;
			" AND MBH_PDV= LW_PDV "+;
			" AND MBH_NUMMOV= LW_NUMMOV  "+;
			" AND MBI_FILIAL = MBH_FILIAL "+;
			" AND MBI_CODACA  = MBH_ACAO "+;
			" AND MBI.D_E_L_E_T_ = ' ' "+;
			" AND MBH.D_E_L_E_T_ = ' ' "+;
			" AND SLW.D_E_L_E_T_ = ' ' "+;
			" GROUP BY LW_FILIAL, MBI_CODACA, LW_OPERADO, MBH_FORMPG, LW_PDV, LW_NUMMOV, MBH_ESTACA, LW_DTABERT,LW_SERIE,LW_HRABERT,LT_VLRAPU,LT_VLRDIG" 

cQuery := ChangeQuery(cQuery)

DbSelectArea("SLW")
DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), 'SLWTRB', .F., .T.)

While SLWTRB->(!Eof()) 			

    If cCont == 0 
		Aadd(aTotal,{SLWTRB->LW_FILIAL, (SLWTRB->VLRDIF),"",cCont+1})
  		lAchou := .T.
    Else             
	    For nI:= 1 to len(aTotal)
	    	If SLWTRB->LW_FILIAL == aTotal[nI][1] 
	    		aTotal[nI][2] := aTotal[nI][2] + (SLWTRB->VLRDIF)  //incrementa o totalizador da mesma filial
	    		aTotal[nI][4] := aTotal[nI][4] + 1
	    		lAchou := .T.
            Endif
	    Next nI
	Endif

	If !lAchou
  		cCont := 0
  		Aadd(aTotal,{SLWTRB->LW_FILIAL, (SLWTRB->VLRDIF),"",cCont+1})//adiciona uma nova filial
	Endif

	cCont ++
	lAchou := .F.
	
	SLWTRB->(dbSkip())
EndDo	              

 
//Ordernar do maior para o menor valor 
ASORT(aTotal,,,{ | x,y | x[2] > y[2] } )

//Limitar o numero de registros pelo numero de ranking informado
If len(aTotal) < len(aSerie)
   nTotal := len(aTotal)
Else
   nTotal := len(aSerie)   
Endif

For nI:= 1 to nTotal	
	For nY:= 1 to len(aFiliais)
		If alltrim(aTotal[nI][1]) == alltrim(aFiliais[nY][1]) 
			nPos := nY
		Endif	
	Next nY	
	aSerie[nI][1] := "Cod:" + AllTrim(aTotal[nI][1])
	aSerie[nI][2] := aTotal[nI][2]//Total 
	If nPos <> 0
		aSerie[nI][3] := AllTrim(aTotal[nI][1]) +"-"+ AllTrim(aFiliais[nPos][2])  //Filial
	Else
		aSerie[nI][3] := AllTrim(aTotal[nI][1]) //Filial	
	Endif
	aSerie[nI][4] := aTotal[nI][4]
Next nI  

RestArea(aArea)
SLWTRB->(DbCloseArea())

Return aSerie


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ProcInd33        ³Autor  ³TOTVS               ³ Data ³ 22/07/13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Retorna os valores que serao impressos pelo painel             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Quebra Conf.Caixa >> Caixa                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function ProcInd33()

Local aArea  	:= GetArea()
Local cCont		:= 0 // contador de serie
Local cQuery    := ""// Texto SQL que é enviado para o comando TCGenQry
Local aTotal    := {}
Local nI,nY     := 0
Local nTotal    := 0 //limitador do numero de registros por ranking
Local lAchou    := .F.  
Local cFiliais  := ""

cQuery :=	" SELECT  LW_FILIAL, LW_OPERADO,LT_VLRAPU,LT_VLRDIG,LT_VLRAPU-LT_VLRDIG VLRDIF,A6_NREDUZ " +;
			" FROM 	" +RetSqlName("SLW")+" SLW, " +RetSqlName("SLT")+" SLT," +RetSqlName("MBH")+" MBH," +RetSqlName("MBI")+" MBI," +RetSqlName("SA6")+" SA6 " +;
		    " WHERE  " + LJ7017QryFil(.F.,"SLW")[2] +;
		    " AND LW_OPERADO >= '" + mv_par05 + "'"  +;
			" AND LW_OPERADO <= '" + mv_par06 + "'"  +;
			" AND LW_DTFECHA >= '" + DToS(mv_par09) + "'"  +;
			" AND LW_DTFECHA <= '" + DToS(mv_par10) + "'"  +;
			" AND LT_FILIAL = LW_FILIAL "+;
			" AND LT_DTFECHA = LW_DTFECHA "+;
			" AND LW_NUMMOV = LT_NUMMOV  "+; 
			" AND LW_OPERADO = LT_OPERADO  "+;
			" AND LW_ESTACAO  = LT_ESTACAO  "+;
   		    " AND LW_PDV >= '" + mv_par07 + "'" +;
            " AND LW_PDV <= '" + mv_par08 + "'" +;  			
			" AND LW_PDV = LT_PDV  "+;
			" AND LT_CONFERE = '1'  "+; 
			" AND LT_VLRDIG <> 0 "+;
			" AND MBH_FILIAL = LW_FILIAL  "+;
			" AND MBH_OPERAD = LW_OPERADO "+;
			" AND MBH_DATA  = LT_DTFECHA "+;
			" AND MBH_FORMPG = LT_FORMPG "+;
			" AND MBH_PDV= LW_PDV "+;
			" AND MBH_NUMMOV= LW_NUMMOV  "+;
			" AND MBI_FILIAL = MBH_FILIAL "+;
			" AND MBI_CODACA  = MBH_ACAO "+;
			" AND A6_COD = LT_OPERADO "+; 
			" AND MBI.D_E_L_E_T_ = ' ' "+;
			" AND MBH.D_E_L_E_T_ = ' ' "+;
			" AND SLW.D_E_L_E_T_ = ' ' "+;
			" AND SA6.D_E_L_E_T_ = ' ' "+;
			" GROUP BY LW_FILIAL, LW_OPERADO,LT_VLRAPU,LT_VLRDIG,A6_NREDUZ "				

cQuery := ChangeQuery(cQuery)

DbSelectArea("SLW")
DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), 'SLWTRB', .F., .T.)

While SLWTRB->(!Eof()) 			

    If cCont == 0 
  		Aadd(aTotal,{SLWTRB->LW_OPERADO,(SLWTRB->VLRDIF),SLWTRB->A6_NREDUZ,cCont+1})
  		lAchou := .T.
    Else             
	    For nI:= 1 to len(aTotal)
	    	If SLWTRB->LW_OPERADO == aTotal[nI][1] 
	    		aTotal[nI][2] := aTotal[nI][2] + SLWTRB->VLRDIF   //incrementa o totalizador da mesma filial
	    		aTotal[nI][4] := aTotal[nI][4] + 1
	    		lAchou := .T.
            Endif
	    Next nI
	Endif

	If !lAchou
  		cCont := 0
  		Aadd(aTotal,{SLWTRB->LW_OPERADO,(SLWTRB->VLRDIF),SLWTRB->A6_NREDUZ,cCont+1}) //adiciona uma nova filial
	Endif

	cCont ++
	lAchou := .F.
	
	SLWTRB->(dbSkip())
EndDo	              

//Ordernar do maior para o menor valor 
ASORT(aTotal,,,{ | x,y | x[2] > y[2] } )

//Limitar o numero de registros pelo numero de ranking informado
If len(aTotal) < len(aSerie)
   nTotal := len(aTotal)
Else
   nTotal := len(aSerie)   
Endif

For nI:= 1 to nTotal
	aSerie[nI][1] := "Cod:" + AllTrim(aTotal[nI][1])
	aSerie[nI][2] := aTotal[nI][2]//Total de quebras na conferencia de caixa
	aSerie[nI][3] := AllTrim(aTotal[nI][1])+"-"+AllTrim(aTotal[nI][3])//Caixa
	aSerie[nI][4] := aTotal[nI][4]
Next nI  

RestArea(aArea)
SLWTRB->(DbCloseArea())

Return aSerie


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ProcInd34        ³Autor  ³TOTVS               ³ Data ³ 22/07/13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Retorna os valores que serao impressos pelo painel             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Cheques devolvidos >> Grupo de Filial                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function ProcInd34()

Local aArea  	:= GetArea()
Local cCont		:= 0  // contador de serie
Local cQuery    := "" // Texto SQL que é enviado para o comando TCGenQry
Local aTotal    := {}
Local nI,nY     := 0
Local nTotal    := 0 //limitador do numero de registros por ranking
Local lAchou    := .F.  
Local cFiliais  := ""

cQuery:= " SELECT SAU.AU_CODGRUP,SAU.AU_DESCRI, SEF.EF_FILIAL,SEF.EF_PREFIXO,SEF.EF_TITULO,SEF.EF_NUMNOTA,SEF.EF_SERIE,SEF.EF_VALOR,SEF.EF_CLIENTE,SEF.EF_LOJACLI,SEF.EF_BANCO,SEF.EF_AGENCIA,SEF.EF_CONTA,SEF.EF_NUM " +;
         " FROM " + RetSqlName("SE1") +" SE1, "+ RetSqlName("SEF") +" SEF " +;
    	 " INNER JOIN " + RetSqlName("SAU") + " SAU " +;
	     " ON SAU.D_E_L_E_T_ = ' ' AND SAU.AU_CODFIL = SEF.EF_FILIAL " +;
		 " WHERE  " + LJ7017QryFil(.F.,"SEF")[2] +;
		 " AND SEF.EF_CHDEVOL <> ' ' " +;
	 	 " AND SEF.EF_FILIAL = E1_FILIAL "+;
	 	 " AND SEF.EF_PREFIXO = E1_PREFIXO "+;
	 	 " AND SEF.EF_TITULO = SE1.E1_NUM "+;
	 	 " AND SEF.EF_SERIE = SE1.E1_SERIE "+;
	 	 " AND SEF.EF_NUMNOTA = E1_NUMNOTA "+;
	 	 " AND SEF.EF_CLIENTE = E1_CLIENTE "+;
	 	 " AND SEF.EF_LOJACLI = E1_LOJA "+;
	 	 " AND SEF.EF_DATA  >= '" + DToS(mv_par09) + "'"  +;
		 " AND SEF.EF_DATA  <= '" + DToS(mv_par10) + "'"  +;
	 	 " AND SE1.E1_PORTADO >= '" + mv_par05 + "'"  +;
	 	 " AND SE1.E1_PORTADO <= '" + mv_par06 + "'"  +;
	 	 " AND SEF.D_E_L_E_T_ = ' ' " +;
	 	 " AND SE1.D_E_L_E_T_ = ' ' " +;
 		 " GROUP BY SAU.AU_CODGRUP,SAU.AU_DESCRI,SEF.EF_FILIAL,SEF.EF_PREFIXO,SEF.EF_TITULO,SEF.EF_NUMNOTA,SEF.EF_SERIE,SEF.EF_VALOR,SEF.EF_CLIENTE,SEF.EF_LOJACLI,SEF.EF_BANCO,SEF.EF_AGENCIA,SEF.EF_CONTA,SEF.EF_NUM"

cQuery := ChangeQuery(cQuery)

DbSelectArea("SEF")
DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), 'SEFTRB', .F., .T.)

While SEFTRB->(!Eof()) 			

    If cCont == 0
  		Aadd(aTotal,{SEFTRB->AU_CODGRUP,(SEFTRB->EF_VALOR),AllTrim(SEFTRB->AU_DESCRI),cCont+1})
  		lAchou := .T.
    Else             
	    For nI:= 1 to len(aTotal)
	    	If SEFTRB->AU_CODGRUP == aTotal[nI][1] 
	    		aTotal[nI][2] := aTotal[nI][2] + (SEFTRB->EF_VALOR) //incrementa o totalizador da mesma filial
		    	aTotal[nI][4] := aTotal[nI][4] + 1
	    		lAchou := .T.
            Endif
	    Next nI
	Endif

	If !lAchou
  		cCont := 0
  		Aadd(aTotal,{SEFTRB->AU_CODGRUP,(SEFTRB->EF_VALOR),AllTrim(SEFTRB->AU_DESCRI),cCont+1}) //adiciona uma nova filial
	Endif

	cCont ++
	lAchou := .F.
	
	SEFTRB->(dbSkip())
EndDo	              

SEFTRB->(DbCloseArea())

//Ordernar do maior para o menor valor 
ASORT(aTotal,,,{ | x,y | x[2] > y[2] } )

//Limitar o numero de registros pelo numero de ranking informado
If len(aTotal) < len(aSerie)
   nTotal := len(aTotal)
Else
   nTotal := len(aSerie)   
Endif

For nI:= 1 to nTotal
	aSerie[nI][1] := "Cod:" + AllTrim(aTotal[nI][1])
	aSerie[nI][2] := aTotal[nI][2]//Total de cheques devolvidos
	aSerie[nI][3] := AllTrim(aTotal[nI][1])+"-"+AllTrim(aTotal[nI][3])//Filial
	aSerie[nI][4] := aTotal[nI][4] 
Next nI  

RestArea(aArea)

Return aSerie


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ProcInd35        ³Autor  ³TOTVS               ³ Data ³ 22/07/13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Retorna os valores que serao impressos pelo painel             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Cheques devolvidos >> Filial                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function ProcInd35()

Local aArea  	:= GetArea()
Local cCont		:= 0  // contador de serie
Local cQuery    := "" // Texto SQL que é enviado para o comando TCGenQry
Local aTotal    := {}
Local nI,nY     := 0
Local nTotal    := 0 //limitador do numero de registros por ranking
Local lAchou    := .F.  
Local cFiliais  := ""
Local nPos		:= 1
Local aFiliais 	:= Lj7017Fil()// Recebera o retorna dos nomes das Filiais	
Local nY        := 0

cQuery:= " SELECT SEF.EF_FILIAL,SEF.EF_PREFIXO,SEF.EF_TITULO,SEF.EF_NUMNOTA,SEF.EF_SERIE,SEF.EF_VALOR,SEF.EF_CLIENTE,SEF.EF_LOJACLI,SEF.EF_BANCO,SEF.EF_AGENCIA,SEF.EF_CONTA,SEF.EF_NUM " +;
             " FROM " + RetSqlName("SEF") +" SEF, "+ RetSqlName("SE1") +" SE1" +;
		     " WHERE  " + LJ7017QryFil(.F.,"SEF")[2] +;
		 	 " AND SEF.EF_CHDEVOL <> ' ' " +;
             " AND SEF.EF_FILIAL = E1_FILIAL "+;
             " AND SEF.EF_PREFIXO = E1_PREFIXO "+;
             " AND SEF.EF_TITULO = SE1.E1_NUM "+;
             " AND SEF.EF_SERIE = SE1.E1_SERIE "+;
             " AND SEF.EF_NUMNOTA = E1_NUMNOTA "+;
             " AND SEF.EF_CLIENTE = E1_CLIENTE "+;
             " AND SEF.EF_LOJACLI = E1_LOJA "+;
             " AND SEF.EF_DATA  >= '" + DToS(mv_par09) + "'"  +;
			 " AND SEF.EF_DATA  <= '" + DToS(mv_par10) + "'"  +;
             " AND SE1.E1_PORTADO >= '" + mv_par05 + "'"  +;
		 	 " AND SE1.E1_PORTADO <= '" + mv_par06 + "'"  +;
		 	 " AND SEF.D_E_L_E_T_ = ' ' " +;
 		 	 " AND SE1.D_E_L_E_T_ = ' ' " +;
 			 " GROUP BY SEF.EF_FILIAL,SEF.EF_PREFIXO,SEF.EF_TITULO,SEF.EF_NUMNOTA,SEF.EF_SERIE,SEF.EF_VALOR,SEF.EF_CLIENTE,SEF.EF_LOJACLI,SEF.EF_BANCO,SEF.EF_AGENCIA,SEF.EF_CONTA,SEF.EF_NUM"

cQuery := ChangeQuery(cQuery)

DbSelectArea("SEF")
DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), 'SEFTRB', .F., .T.)

While SEFTRB->(!Eof()) 			

    If cCont == 0 
  		Aadd(aTotal,{SEFTRB->EF_FILIAL, (SEFTRB->EF_VALOR),"",cCont+1})
  		lAchou := .T.
    Else             
	    For nI:= 1 to len(aTotal)
	    	If SEFTRB->EF_FILIAL == aTotal[nI][1] 
	    		aTotal[nI][2] := aTotal[nI][2] + (SEFTRB->EF_VALOR) //incrementa o totalizador da mesma filial
	    		aTotal[nI][4] := aTotal[nI][4] + 1
	    		lAchou := .T.
            Endif
	    Next nI
	Endif

	If !lAchou
  		cCont := 0
  		Aadd(aTotal,{SEFTRB->EF_FILIAL, (SEFTRB->EF_VALOR),"",cCont+1})//adiciona uma nova filial 
	Endif

	cCont ++
	lAchou := .F.
	
	SEFTRB->(dbSkip())
EndDo	              
	
//Ordernar do maior para o menor valor 
ASORT(aTotal,,,{ | x,y | x[2] > y[2] } )

//Limitar o numero de registros pelo numero de ranking informado
If len(aTotal) < len(aSerie)
   nTotal := len(aTotal)
Else
   nTotal := len(aSerie)   
Endif

For nI:= 1 to nTotal	
	For nY:= 1 to len(aFiliais)
		If alltrim(aTotal[nI][1]) == alltrim(aFiliais[nY][1]) 
			nPos := nY
		Endif	
	Next nY	

	aSerie[nI][1] := "Cod:" + AllTrim(aTotal[nI][1])
	aSerie[nI][2] := aTotal[nI][2]//Total de cheques devolvidos
	If nPos <> 0
		aSerie[nI][3] := AllTrim(aTotal[nI][1]) +"-"+ AllTrim(aFiliais[nPos][2])  //Filial
	Else
		aSerie[nI][3] := AllTrim(aTotal[nI][1]) //Filial	
	Endif
	aSerie[nI][4] := aTotal[nI][4]
Next nI  

RestArea(aArea)

SEFTRB->(DbCloseArea())

Return aSerie



/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ProcInd36        ³Autor  ³TOTVS               ³ Data ³ 22/07/13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Retorna os valores que serao impressos pelo painel             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Titulos em atraso >> Grupo de Filial                           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function ProcInd36()

Local aArea  	:= GetArea()
Local cCont		:= 0  // contador de serie  
Local cQuery    := "" // Texto SQL que é enviado para o comando TCGenQry
Local aTotal    := {}
Local nI,nY     := 0
Local nTotal    := 0 //limitador do numero de registros por ranking
Local lAchou    := .F.  
Local cFiliais  := ""

cQuery:= " SELECT SAU.AU_CODGRUP, SAU.AU_DESCRI,E1_FILIAL, E1_LOJA, E1_PREFIXO, E1_NUM, E1_PARCELA, E1_VALOR , E1_PORTADO, E1_CLIENTE " +;
	         " FROM " + RetSqlName("SE1") + " SE1 " +;                                                                
    		 " INNER JOIN " + RetSqlName("SAU") + " SAU " +;
	     	 " ON SAU.D_E_L_E_T_ = ' ' AND SAU.AU_CODFIL = SE1.E1_FILIAL " +;
		 	 " WHERE  " + LJ7017QryFil(.F.,"SE1")[2] +;
 			 " AND E1_VENCREA >= '" + DToS(mv_par09) + "'"  +;
 			 " AND E1_VENCREA <= '" + DToS(mv_par10) + "'"  +;
 			 " AND E1_SALDO <> 0 "+;
             " AND E1_BAIXA = ''"+;
			 " AND E1_TIPO <> 'PIS' "+; 
 			 " AND E1_TIPO <> 'COF' "+;
 			 " AND E1_TIPO <> 'CSL'"+;
	   		 " AND E1_PORTADO >= '" + mv_par05 + "'"  +;
		 	 " AND E1_PORTADO <= '" + mv_par06 + "'"   +;
		 	 " AND SE1.D_E_L_E_T_ = ' ' " +;  
 			 " GROUP BY SAU.AU_CODGRUP, SAU.AU_DESCRI,E1_FILIAL, E1_LOJA, E1_PREFIXO, E1_NUM, E1_PARCELA, E1_VALOR, E1_PORTADO, E1_CLIENTE   "

cQuery := ChangeQuery(cQuery)

DbSelectArea("SE1")
DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), 'SE1TRB', .F., .T.)

While SE1TRB->(!Eof()) 			

    If cCont == 0 
  		Aadd(aTotal,{SE1TRB->AU_CODGRUP,(SE1TRB->E1_VALOR),AllTrim(SE1TRB->AU_DESCRI),cCont+1})
  		lAchou := .T.
    Else             
	    For nI:= 1 to len(aTotal)
	    	If SE1TRB->AU_CODGRUP == aTotal[nI][1] 
	    		aTotal[nI][2] := aTotal[nI][2] + (SE1TRB->E1_VALOR) //incrementa o totalizador da mesma filial
	    		aTotal[nI][4] := aTotal[nI][4] + 1
	    		lAchou := .T.
            Endif
	    Next nI
	Endif

	If !lAchou
  		cCont := 0
  		Aadd(aTotal,{SE1TRB->AU_CODGRUP,(SE1TRB->E1_VALOR),AllTrim(SE1TRB->AU_DESCRI),cCont+1}) //adiciona uma nova filial
	Endif

	cCont ++
	lAchou := .F.
	
	SE1TRB->(dbSkip())
EndDo	              

SE1TRB->(DbCloseArea())                                           

//Ordernar do maior para o menor valor 
ASORT(aTotal,,,{ | x,y | x[2] > y[2] } )

//Limitar o numero de registros pelo numero de ranking informado
If len(aTotal) < len(aSerie)
   nTotal := len(aTotal)
Else
   nTotal := len(aSerie)   
Endif

For nI:= 1 to nTotal
	aSerie[nI][1] := "Cod:" + AllTrim(aTotal[nI][1])	
	aSerie[nI][2] := aTotal[nI][2]//Total de titulos em atraso 
	aSerie[nI][3] := AllTrim(aTotal[nI][1])+"-"+AllTrim(aTotal[nI][3])//Filial
	aSerie[nI][4] := aTotal[nI][4]
Next nI  

RestArea(aArea)

Return aSerie

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ProcInd37        ³Autor  ³TOTVS               ³ Data ³ 22/07/13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Retorna os valores que serao impressos pelo painel             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Titulos em atraso>> Filial                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function ProcInd37()

Local aArea  	:= GetArea()
Local cCont		:= 0 // contador de serie
Local cQuery    := ""// Texto SQL que é enviado para o comando TCGenQry
Local aTotal    := {}
Local nI,nY     := 0
Local nTotal    := 0 //limitador do numero de registros por ranking
Local lAchou    := .F.  
Local cFiliais  := ""
Local nPos		:= 1
Local aFiliais 	:= Lj7017Fil()// Recebera o retorna dos nomes das Filiais	
Local nY        := 0


cQuery:= " SELECT E1_FILIAL, E1_LOJA, E1_PREFIXO, E1_NUM, E1_PARCELA, E1_NOMCLI, E1_VALOR" +;
         " FROM " + RetSqlName("SE1") + " SE1 " +;
	 	 " WHERE  " + LJ7017QryFil(.F.,"SE1")[2] +;                         
	 	 " AND E1_VENCREA >= '" + DToS(mv_par09) + "'"  +;
		 " AND E1_VENCREA <= '" + DToS(mv_par10) + "'"  +;
		 " AND E1_SALDO <> 0 "+;
         " AND E1_BAIXA = ''"+;
		 " AND E1_TIPO <> 'PIS' "+; 
 		 " AND E1_TIPO <> 'COF' "+;
		 " AND E1_TIPO <> 'CSL'"+;
   		 " AND E1_PORTADO >= '" + mv_par05 + "'"  +;
	 	 " AND E1_PORTADO <= '" + mv_par06 + "'"   +;  
 	     " AND D_E_L_E_T_ = ' ' " +;
 		 " GROUP BY E1_FILIAL, E1_LOJA, E1_PREFIXO, E1_NUM, E1_PARCELA, E1_NOMCLI, E1_VALOR "
             
cQuery := ChangeQuery(cQuery)

DbSelectArea("SE1")
DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), 'SE1TRB', .F., .T.)

While SE1TRB->(!Eof()) 			

    If cCont == 0 
  		Aadd(aTotal,{SE1TRB->E1_FILIAL, (SE1TRB->E1_VALOR),"",cCont+1})
  		lAchou := .T.
    Else             
	    For nI:= 1 to len(aTotal)
	    	If SE1TRB->E1_FILIAL == aTotal[nI][1] 
	    		aTotal[nI][2] := aTotal[nI][2] + (SE1TRB->E1_VALOR)//incrementa o totalizador da mesma filial
	    		aTotal[nI][4] := aTotal[nI][4] + 1
	    		lAchou := .T.
            Endif
	    Next nI
	Endif

	If !lAchou
  		cCont := 0
  		Aadd(aTotal,{SE1TRB->E1_FILIAL, (SE1TRB->E1_VALOR),"",cCont+1})
	Endif

	cCont ++
	lAchou := .F.
	
	SE1TRB->(dbSkip())
EndDo	              
	 
//Ordernar do maior para o menor valor 
ASORT(aTotal,,,{ | x,y | x[2] > y[2] } )

//Limitar o numero de registros pelo numero de ranking informado
If len(aTotal) < len(aSerie)
   nTotal := len(aTotal)
Else
   nTotal := len(aSerie)   
Endif

For nI:= 1 to nTotal	
	For nY:= 1 to len(aFiliais)
		If alltrim(aTotal[nI][1]) == alltrim(aFiliais[nY][1]) 
			nPos := nY
		Endif	
	Next nY	
    
	aSerie[nI][1] := "Cod:" + AllTrim(aTotal[nI][1])
	aSerie[nI][2] := aTotal[nI][2]//Total de titulos em atraso

	If nPos <> 0
		aSerie[nI][3] := AllTrim(aTotal[nI][1]) +"-"+ AllTrim(aFiliais[nPos][2])  //Filial
	Else
		aSerie[nI][3] := AllTrim(aTotal[nI][1]) //Filial	
	Endif
	aSerie[nI][4] := aTotal[nI][4]
Next nI  

RestArea(aArea)

SE1TRB->(DbCloseArea())
	
Return aSerie

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ProcInd38        ³Autor  ³TOTVS               ³ Data ³ 22/07/13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Retorna os valores que serao impressos pelo painel             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Titulos em atraso>> Cliente                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function ProcInd38()

Local aArea  	:= GetArea()
Local cCont		:= 0  // contador de serie
Local cQuery    := "" // Texto SQL que é enviado para o comando TCGenQry
Local aTotal    := {}
Local nI,nY     := 0
Local nTotal    := 0 //limitador do numero de registros por ranking
Local lAchou    := .F.  
Local cFiliais  := ""

cQuery:= " SELECT E1_FILIAL, E1_LOJA, E1_PORTADO,E1_PREFIXO, E1_NUM, E1_PARCELA, E1_CLIENTE, E1_NOMCLI, E1_VALOR  " +;
         " FROM " + RetSqlName("SE1") + " SE1 " +;
	 	 " WHERE  " + LJ7017QryFil(.F.,"SE1")[2] +;
		 " AND E1_VENCREA >= '" + DToS(mv_par09) + "'"  +;
 		 " AND E1_VENCREA <= '" + DToS(mv_par10) + "'"  +;
 		 " AND E1_SALDO <> 0 "+;
         " AND E1_BAIXA = ''"+;
		 " AND E1_TIPO <> 'PIS' "+; 
 		 " AND E1_TIPO <> 'COF' "+;
 		 " AND E1_TIPO <> 'CSL'"+;
   		 " AND E1_PORTADO >= '" + mv_par05 + "'"  +;
	 	 " AND E1_PORTADO <= '" + mv_par06 + "'"   +;
	 	 " AND D_E_L_E_T_ = ' ' " +;
 		 " GROUP BY E1_FILIAL, E1_LOJA,E1_PORTADO,E1_PREFIXO, E1_NUM, E1_PARCELA, E1_CLIENTE, E1_NOMCLI, E1_VALOR   "

cQuery := ChangeQuery(cQuery)

DbSelectArea("SE1")
DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), 'SE1TRB', .F., .T.)

While SE1TRB->(!Eof()) 			

    If cCont == 0
  		Aadd(aTotal,{SE1TRB->E1_CLIENTE, (SE1TRB->E1_VALOR),SE1TRB->E1_NOMCLI,cCont+1})
  		lAchou := .T.
    Else             
	    For nI:= 1 to len(aTotal)
	    	If SE1TRB->E1_CLIENTE == aTotal[nI][1] 
	    		aTotal[nI][2] := aTotal[nI][2] + (SE1TRB->E1_VALOR) //incrementa o totalizador da mesma filial
	    		aTotal[nI][4] := aTotal[nI][4] + 1
	    		lAchou := .T.
            Endif
	    Next nI
	Endif

	If !lAchou
  		cCont := 0 
  		Aadd(aTotal,{SE1TRB->E1_CLIENTE, (SE1TRB->E1_VALOR),SE1TRB->E1_NOMCLI,cCont+1}) //adiciona uma nova filial
	Endif

	cCont ++
	lAchou := .F.
	
	SE1TRB->(dbSkip())
EndDo	              
	 
//Ordernar do maior para o menor valor 
ASORT(aTotal,,,{ | x,y | x[2] > y[2] } )

//Limitar o numero de registros pelo numero de ranking informado
If len(aTotal) < len(aSerie)
   nTotal := len(aTotal)
Else
   nTotal := len(aSerie)   
Endif

For nI:= 1 to nTotal
	aSerie[nI][1] := "Cod:" + AllTrim(aTotal[nI][1])
	aSerie[nI][2] := aTotal[nI][2]
	aSerie[nI][3] := AllTrim(aTotal[nI][1])+"-"+AllTrim(aTotal[nI][3])
	aSerie[nI][4] := aTotal[nI][4]
Next nI  

RestArea(aArea)

SE1TRB->(DbCloseArea())
	
Return aSerie

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ProcInd301       ³Autor  ³TOTVS               ³ Data ³ 02/07/13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Retorna os valores que serao impressos pelo painel             ³±±
±±³          ³ Qtde. Consulta Precos - Grupo de Filial                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Prevencao de Perdas - Loja   	                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function ProcInd301()
Local aArea  	:= GetArea()
Local cQuery    := ""// Texto SQL que é enviado para o comando TCGenQry
Local aTotal    := {}
Local nI        := 0
Local nTotal    := 0 //limitador do numero de registros por ranking

cQuery := " SELECT SAU.AU_CODGRUP, SAU.AU_DESCRI, COUNT(MFL.MFL_FILIAL) TOTALIZ "
cQuery += " FROM " + RetSqlName("MFL") + " MFL "
cQuery += " INNER JOIN " + RetSqlName("SAU") + " SAU "
cQuery += " ON SAU.D_E_L_E_T_ = ' ' AND SAU.AU_CODFIL = MFL.MFL_FILIAL "
cQuery += " WHERE " + LJ7017QryFil(.F.,"MFL")[2] 								   		  			//Grupo de Filial ou Filial
cQuery += " AND MFL.MFL_CAIXA BETWEEN '"	+ mv_par05 			+"' AND '"+ mv_par06 		+"' "	//Caixa
cQuery += " AND MFL.MFL_PDV BETWEEN '"		+ mv_par07 			+"' AND '"+ mv_par08 		+"' "	//PDV
cQuery += " AND MFL.MFL_DATA BETWEEN '"		+ DToS(mv_par09) 	+"' AND '"+ DToS(mv_par10) 	+"' "	//Data
cQuery += " AND MFL.D_E_L_E_T_ = ' ' GROUP BY SAU.AU_CODGRUP, SAU.AU_DESCRI"

cQuery := ChangeQuery(cQuery)
DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), 'MFLTRB', .F., .T.)
MFLTRB->(DBGoTop())

While MFLTRB->(!Eof())
	Aadd(aTotal,{MFLTRB->AU_CODGRUP, MFLTRB->TOTALIZ,MFLTRB->AU_DESCRI,0})
	MFLTRB->(dbSkip())
EndDo
MFLTRB->(DbCloseArea())

//Ordernar do maior para o menor valor 
ASORT(aTotal,,,{ | x,y | x[2] > y[2] } )

//Limitar o numero de registros pelo numero de ranking informado
If Len(aTotal) < Len(aSerie)
   nTotal := Len(aTotal)
Else
   nTotal := Len(aSerie)
Endif

For nI:= 1 to nTotal
	aSerie[nI][1] := "Cod:" + AllTrim(aTotal[nI][1])
	aSerie[nI][2] := aTotal[nI][2]
	aSerie[nI][3] := AllTrim(aTotal[nI][1])+'-'+AllTrim(aTotal[nI][3])
	aSerie[nI][4] := aTotal[nI][4]
Next nI  
RestArea(aArea)

Return aSerie

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ProcInd302       ³Autor  ³TOTVS               ³ Data ³ 02/07/13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Retorna os valores que serao impressos pelo painel             ³±±
±±³          ³ Qtde. Consulta Precos - Filial                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Prevencao de Perdas - Loja   	                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function ProcInd302()
Local aArea  	:= GetArea()
Local cQuery    := ""// Texto SQL que é enviado para o comando TCGenQry
Local aTotal    := {}
Local nI        := 0
Local nTotal    := 0 //limitador do numero de registros por ranking
Local nPos		:= 1
Local aFiliais 	:= Lj7017Fil()// Recebera o retorna dos nomes das Filiais	

cQuery := " SELECT MFL.MFL_FILIAL, COUNT(MFL.MFL_FILIAL) TOTALIZ "
cQuery += " FROM " + RetSqlName("MFL") + " MFL "
cQuery += " WHERE " + LJ7017QryFil(.F.,"MFL")[2]													//Grupo de Filial ou Filial
cQuery += " AND MFL.MFL_CAIXA BETWEEN '"	+ mv_par05 			+"' AND '"+ mv_par06 		+"' "	//Caixa
cQuery += " AND MFL.MFL_PDV BETWEEN '"		+ mv_par07 			+"' AND '"+ mv_par08 		+"' "	//PDV
cQuery += " AND MFL.MFL_DATA BETWEEN '"		+ DToS(mv_par09) 	+"' AND '"+ DToS(mv_par10) 	+"' "	//Data
cQuery += " AND MFL.D_E_L_E_T_ = ' ' GROUP BY MFL.MFL_FILIAL"

cQuery := ChangeQuery(cQuery)
DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), 'MFLTRB', .F., .T.)
MFLTRB->(DBGoTop())

While MFLTRB->(!Eof())
	nPos := aScan( aFiliais, {|xVar| AllTrim(xVar[1]) == AllTrim(MFLTRB->MFL_FILIAL)})
	Aadd(aTotal,{MFLTRB->MFL_FILIAL, MFLTRB->TOTALIZ,IIF(nPos>0,aFiliais[nPos][2],""),0})
	MFLTRB->(dbSkip())
EndDo
MFLTRB->(DbCloseArea())

//Ordernar do maior para o menor valor 
ASORT(aTotal,,,{ | x,y | x[2] > y[2] } )

//Limitar o numero de registros pelo numero de ranking informado
If Len(aTotal) < Len(aSerie)
   nTotal := Len(aTotal)
Else
   nTotal := Len(aSerie)
Endif

For nI:= 1 to nTotal
	aSerie[nI][1] := "Cod:" + AllTrim(aTotal[nI][1])
	aSerie[nI][2] := aTotal[nI][2]
	aSerie[nI][3] := AllTrim(aTotal[nI][1])+'-'+AllTrim(aTotal[nI][3])
	aSerie[nI][4] := aTotal[nI][4]
Next nI  
RestArea(aArea)

Return aSerie

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ProcInd303       ³Autor  ³TOTVS               ³ Data ³ 02/07/13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Retorna os valores que serao impressos pelo painel             ³±±
±±³          ³ Qtde. Consulta Precos - Caixa                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Prevencao de Perdas - Loja   	                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function ProcInd303()
Local aArea  	:= GetArea()
Local cQuery    := ""  // Texto SQL que é enviado para o comando TCGenQry
Local aTotal    := {}
Local nI        := 0
Local nTotal    := 0 //limitador do numero de registros por ranking

cQuery := " SELECT SA6.A6_COD, SA6.A6_NREDUZ, COUNT(MFL.MFL_FILIAL) TOTALIZ "
cQuery += " FROM " + RetSqlName("MFL") + " MFL "
cQuery += " INNER JOIN " + RetSqlName("SA6") + " SA6 "
cQuery += " ON SA6.D_E_L_E_T_ = ' ' AND SA6.A6_COD = MFL.MFL_CAIXA "
cQuery += " WHERE " + LJ7017QryFil(.F.,"MFL")[2]											  		//Grupo de Filial ou Filial
cQuery += " AND MFL.MFL_CAIXA BETWEEN '"	+ mv_par05 			+"' AND '"+ mv_par06 		+"' "	//Caixa
cQuery += " AND MFL.MFL_PDV BETWEEN '"		+ mv_par07 			+"' AND '"+ mv_par08 		+"' "	//PDV
cQuery += " AND MFL.MFL_DATA BETWEEN '"		+ DToS(mv_par09) 	+"' AND '"+ DToS(mv_par10) 	+"' "	//Data
cQuery += " AND MFL.D_E_L_E_T_ = ' ' GROUP BY SA6.A6_COD, SA6.A6_NREDUZ"

cQuery := ChangeQuery(cQuery)
DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), 'MFLTRB', .F., .T.)
MFLTRB->(DBGoTop())

While MFLTRB->(!Eof())
	Aadd(aTotal,{MFLTRB->A6_COD,MFLTRB->TOTALIZ,MFLTRB->A6_NREDUZ,0})
	MFLTRB->(dbSkip())
EndDo
MFLTRB->(DbCloseArea())

//Ordernar do maior para o menor valor 
ASORT(aTotal,,,{ | x,y | x[2] > y[2] } )

//Limitar o numero de registros pelo numero de ranking informado
If Len(aTotal) < Len(aSerie)
   nTotal := Len(aTotal)
Else
   nTotal := Len(aSerie)
Endif

For nI:= 1 to nTotal
	aSerie[nI][1] := "Cod:" + AllTrim(aTotal[nI][1])
	aSerie[nI][2] := aTotal[nI][2]
	aSerie[nI][3] := AllTrim(aTotal[nI][1])+'-'+AllTrim(aTotal[nI][3])
	aSerie[nI][4] := aTotal[nI][4]
Next nI  
RestArea(aArea)

Return aSerie

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ProcInd304       ³Autor  ³TOTVS               ³ Data ³ 02/07/13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Retorna os valores que serao impressos pelo painel             ³±±
±±³          ³ Qtde. Consulta Precos - PDV                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Prevencao de Perdas - Loja   	                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function ProcInd304()
Local aArea  	:= GetArea()
Local cQuery    := ""  // Texto SQL que é enviado para o comando TCGenQry
Local aTotal    := {}
Local nI        := 0
Local nTotal    := 0 //limitador do numero de registros por ranking

cQuery := " SELECT SLG.LG_FILIAL, SLG.LG_PDV, SLG.LG_NOME, COUNT(MFL.MFL_FILIAL) TOTALIZ "
cQuery += " FROM " + RetSqlName("MFL") + " MFL "
cQuery += " INNER JOIN " + RetSqlName("SLG") + " SLG "
cQuery += " ON SLG.D_E_L_E_T_ = ' ' AND SLG.LG_FILIAL = MFL.MFL_FILIAL AND SLG.LG_PDV = MFL.MFL_PDV "
cQuery += " WHERE " + LJ7017QryFil(.F.,"MFL")[2]												 	//Grupo de Filial ou Filial
cQuery += " AND MFL.MFL_CAIXA BETWEEN '"	+ mv_par05 			+"' AND '"+ mv_par06 		+"' "	//Caixa
cQuery += " AND MFL.MFL_PDV BETWEEN '"		+ mv_par07 			+"' AND '"+ mv_par08 		+"' "	//PDV
cQuery += " AND MFL.MFL_DATA BETWEEN '"		+ DToS(mv_par09) 	+"' AND '"+ DToS(mv_par10) 	+"' "	//Data
cQuery += " AND MFL.D_E_L_E_T_ = ' ' GROUP BY SLG.LG_FILIAL, SLG.LG_PDV, SLG.LG_NOME"

cQuery := ChangeQuery(cQuery)
DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), 'MFLTRB', .F., .T.)
MFLTRB->(DBGoTop())

While MFLTRB->(!Eof())
	Aadd(aTotal,{AllTrim(MFLTRB->LG_FILIAL)+'-'+AllTrim(MFLTRB->LG_PDV), MFLTRB->TOTALIZ,AllTrim(MFLTRB->LG_NOME),0})
	MFLTRB->(dbSkip())
EndDo
MFLTRB->(DbCloseArea())

//Ordernar do maior para o menor valor 
ASORT(aTotal,,,{ | x,y | x[2] > y[2] } )

//Limitar o numero de registros pelo numero de ranking informado
If Len(aTotal) < Len(aSerie)
   nTotal := Len(aTotal)
Else
   nTotal := Len(aSerie)
Endif

For nI:= 1 to nTotal
	aSerie[nI][1] := "Cod:" + AllTrim(aTotal[nI][1])
	aSerie[nI][2] := aTotal[nI][2]
	aSerie[nI][3] := AllTrim(aTotal[nI][1])+'-'+AllTrim(aTotal[nI][3])
	aSerie[nI][4] := aTotal[nI][4]
Next nI  
RestArea(aArea)

Return aSerie

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ProcInd305       ³Autor  ³TOTVS               ³ Data ³ 02/07/13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Retorna os valores que serao impressos pelo painel             ³±±
±±³          ³ Cancelamento Cupom - Grupo de Filial                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Prevencao de Perdas - Loja   	                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function ProcInd305()
Local aArea  	:= GetArea()
Local cQuery    := ""  // Texto SQL que é enviado para o comando TCGenQry
Local aTotal    := {}
Local nI        := 0
Local nTotal    := 0 //limitador do numero de registros por ranking
Local nCont		:= 0 // contador de serie
Local cChvAgrup	:= ""
Local cCodigo	:= ""

cQuery := " SELECT SAU.AU_CODGRUP, SAU.AU_DESCRI, SLX.LX_FILIAL, SLX.LX_PDV, SLX.LX_CUPOM, SLX.LX_SERIE, SLX.LX_DTMOVTO, SLX.LX_HORA "
cQuery += " FROM " + RetSqlName("SLX") + " SLX "
cQuery += " INNER JOIN " + RetSqlName("SAU") + " SAU "
cQuery += " ON SAU.D_E_L_E_T_ = ' ' AND SAU.AU_CODFIL = SLX.LX_FILIAL "
cQuery += " WHERE " + LJ7017QryFil(.F.,"SLX")[2] 								   		  			//Grupo de Filial ou Filial
cQuery += " AND SLX.LX_OPERADO BETWEEN '"	+ mv_par05 			+"' AND '"	+ mv_par06 +"' "   		//Caixa
cQuery += " AND SLX.LX_PDV BETWEEN '"		+ mv_par07 			+"' AND '"	+ mv_par08 +"' "   		//PDV
cQuery += " AND SLX.LX_DTMOVTO BETWEEN '"	+ DToS(mv_par09) 	+"' AND '"	+ DToS(mv_par10) +"' " 	//Data
cQuery += " AND SLX.D_E_L_E_T_ = ' ' "
cQuery += " GROUP BY SAU.AU_CODGRUP, SAU.AU_DESCRI, SLX.LX_FILIAL, SLX.LX_PDV, SLX.LX_CUPOM, SLX.LX_SERIE, SLX.LX_DTMOVTO, SLX.LX_HORA "
cQuery += " ORDER BY SAU.AU_CODGRUP, SLX.LX_FILIAL"

cQuery := ChangeQuery(cQuery)
DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), 'SLXTRB', .F., .T.)
SLXTRB->(DBGoTop())

If SLXTRB->(!Eof())
	nCont := 0
	cChvAgrup := SLXTRB->AU_CODGRUP+'-'+AllTrim(SLXTRB->AU_DESCRI)
	While SLXTRB->(!Eof())
		If SLXTRB->AU_CODGRUP+'-'+AllTrim(SLXTRB->AU_DESCRI) == cChvAgrup
			nCont++
			cCodigo := SLXTRB->AU_CODGRUP
		Else
			Aadd(aTotal,{cCodigo, nCont, cChvAgrup, 0}) // Grava chave anterior e o total
			nCont := 1
			cCodigo := SLXTRB->AU_CODGRUP
			cChvAgrup := SLXTRB->AU_CODGRUP+'-'+AllTrim(SLXTRB->AU_DESCRI)
		EndIf
		SLXTRB->(dbSkip())
	EndDo
	Aadd(aTotal,{cCodigo, nCont, cChvAgrup, 0}) // Grava chave anterior e o total pela ultima vez
EndIf

SLXTRB->(DbCloseArea())

//Ordernar do maior para o menor valor 
ASORT(aTotal,,,{ | x,y | x[2] > y[2] } )

//Limitar o numero de registros pelo numero de ranking informado
If Len(aTotal) < Len(aSerie)
   nTotal := Len(aTotal)
Else
   nTotal := Len(aSerie)
Endif

For nI:= 1 to nTotal
	aSerie[nI][1] := "Cod:" + AllTrim(aTotal[nI][1])
	aSerie[nI][2] := aTotal[nI][2]
	aSerie[nI][3] := AllTrim(aTotal[nI][3])
	aSerie[nI][4] := aTotal[nI][4]
Next nI  
RestArea(aArea)

Return aSerie

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ProcInd306       ³Autor  ³TOTVS               ³ Data ³ 02/07/13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Retorna os valores que serao impressos pelo painel             ³±±
±±³          ³ Cancelamento Cupom - Filial                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Prevencao de Perdas - Loja   	                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function ProcInd306()
Local aArea  	:= GetArea()
Local cQuery    := ""  // Texto SQL que é enviado para o comando TCGenQry
Local aTotal    := {}
Local nI        := 0
Local nTotal    := 0 //limitador do numero de registros por ranking
Local nCont		:= 0 // contador de serie
Local cChvAgrup	:= ""
Local nPos		:= 1
Local aFiliais 	:= Lj7017Fil()// Recebera o retorna dos nomes das Filiais	

cQuery := " SELECT SLX.LX_FILIAL, SLX.LX_PDV, SLX.LX_CUPOM, SLX.LX_SERIE, SLX.LX_DTMOVTO, SLX.LX_HORA "
cQuery += " FROM " + RetSqlName("SLX") + " SLX "
cQuery += " WHERE " + LJ7017QryFil(.F.,"SLX")[2] 								   		  			//Grupo de Filial ou Filial
cQuery += " AND SLX.LX_OPERADO BETWEEN '"	+ mv_par05 			+"' AND '"	+ mv_par06 +"' "   		//Caixa
cQuery += " AND SLX.LX_PDV BETWEEN '"		+ mv_par07 			+"' AND '"	+ mv_par08 +"' "   		//PDV
cQuery += " AND SLX.LX_DTMOVTO BETWEEN '"	+ DToS(mv_par09) 	+"' AND '"	+ DToS(mv_par10) +"' " 	//Data
cQuery += " AND SLX.D_E_L_E_T_ = ' ' "
cQuery += " GROUP BY SLX.LX_FILIAL, SLX.LX_PDV, SLX.LX_CUPOM, SLX.LX_SERIE, SLX.LX_DTMOVTO, SLX.LX_HORA "
cQuery += " ORDER BY SLX.LX_FILIAL"

cQuery := ChangeQuery(cQuery)
DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), 'SLXTRB', .F., .T.)
SLXTRB->(DBGoTop())

If SLXTRB->(!Eof())
	nCont := 0
	cChvAgrup := SLXTRB->LX_FILIAL
	While SLXTRB->(!Eof())
		If SLXTRB->LX_FILIAL == cChvAgrup
			nCont++
		Else
			nPos := aScan( aFiliais, {|xVar| AllTrim(xVar[1]) == AllTrim(cChvAgrup)})
			Aadd(aTotal,{cChvAgrup, nCont, cChvAgrup+IIF(nPos>0,"-"+aFiliais[nPos][2],""), 0})
			nCont := 1
			cChvAgrup := SLXTRB->LX_FILIAL
		EndIf
		SLXTRB->(dbSkip())
	EndDo
	nPos := aScan( aFiliais, {|xVar| AllTrim(xVar[1]) == AllTrim(cChvAgrup)})
	Aadd(aTotal,{cChvAgrup, nCont, cChvAgrup+IIF(nPos>0,"-"+aFiliais[nPos][2],""), 0}) //Grava chave anterior e o total pela ultima vez
EndIf

SLXTRB->(DbCloseArea())

//Ordernar do maior para o menor valor 
ASORT(aTotal,,,{ | x,y | x[2] > y[2] } )

//Limitar o numero de registros pelo numero de ranking informado
If Len(aTotal) < Len(aSerie)
   nTotal := Len(aTotal)
Else
   nTotal := Len(aSerie)
Endif

For nI:= 1 to nTotal
	aSerie[nI][1] := "Cod:" + AllTrim(aTotal[nI][1])
	aSerie[nI][2] := aTotal[nI][2]
	aSerie[nI][3] := AllTrim(aTotal[nI][3])
	aSerie[nI][4] := aTotal[nI][4]
Next nI  
RestArea(aArea)

Return aSerie

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ProcInd307       ³Autor  ³TOTVS               ³ Data ³ 02/07/13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Retorna os valores que serao impressos pelo painel             ³±±
±±³          ³ Cancelamento Cupom - Caixa                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Prevencao de Perdas - Loja   	                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function ProcInd307()
Local aArea  	:= GetArea()
Local cQuery    := ""  // Texto SQL que é enviado para o comando TCGenQry
Local aTotal    := {}
Local nI        := 0
Local nTotal    := 0 //limitador do numero de registros por ranking
Local nCont		:= 0 // contador de serie
Local cChvAgrup	:= ""
Local cCodigo	:= ""

cQuery := " SELECT SA6.A6_COD, SA6.A6_NREDUZ, SLX.LX_FILIAL, SLX.LX_PDV, SLX.LX_CUPOM, SLX.LX_SERIE, SLX.LX_DTMOVTO, SLX.LX_HORA "
cQuery += " FROM " + RetSqlName("SLX") + " SLX "
cQuery += " INNER JOIN " + RetSqlName("SA6") + " SA6 "
cQuery += " ON SA6.D_E_L_E_T_ = ' ' AND SA6.A6_COD = SLX.LX_OPERADO "
cQuery += " WHERE " + LJ7017QryFil(.F.,"SLX")[2] 								   		  			//Grupo de Filial ou Filial
cQuery += " AND SLX.LX_OPERADO BETWEEN '"	+ mv_par05 			+"' AND '"	+ mv_par06 +"' "   		//Caixa
cQuery += " AND SLX.LX_PDV BETWEEN '"		+ mv_par07 			+"' AND '"	+ mv_par08 +"' "   		//PDV
cQuery += " AND SLX.LX_DTMOVTO BETWEEN '"	+ DToS(mv_par09) 	+"' AND '"	+ DToS(mv_par10) +"' " 	//Data
cQuery += " AND SLX.D_E_L_E_T_ = ' ' "
cQuery += " GROUP BY SA6.A6_COD, SA6.A6_NREDUZ, SLX.LX_FILIAL, SLX.LX_PDV, SLX.LX_CUPOM, SLX.LX_SERIE, SLX.LX_DTMOVTO, SLX.LX_HORA "
cQuery += " ORDER BY SA6.A6_COD, SA6.A6_NREDUZ, SLX.LX_FILIAL"

cQuery := ChangeQuery(cQuery)
DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), 'SLXTRB', .F., .T.)
SLXTRB->(DBGoTop())

If SLXTRB->(!Eof())
	nCont := 0
	cChvAgrup := SLXTRB->A6_COD+'-'+SLXTRB->A6_NREDUZ
	While SLXTRB->(!Eof())
		If SLXTRB->A6_COD+'-'+SLXTRB->A6_NREDUZ == cChvAgrup
			nCont++
			cCodigo := SLXTRB->A6_COD
		Else
			Aadd(aTotal,{cCodigo, nCont, cChvAgrup, 0}) // Grava chave anterior e o total
			nCont := 1
			cCodigo := SLXTRB->A6_COD
			cChvAgrup := SLXTRB->A6_COD+'-'+SLXTRB->A6_NREDUZ
		EndIf
		SLXTRB->(dbSkip())
	EndDo
	Aadd(aTotal,{cCodigo, nCont, cChvAgrup, 0}) // Grava chave anterior e o total pela ultima vez
EndIf

SLXTRB->(DbCloseArea())

//Ordernar do maior para o menor valor 
ASORT(aTotal,,,{ | x,y | x[2] > y[2] } )

//Limitar o numero de registros pelo numero de ranking informado
If Len(aTotal) < Len(aSerie)
   nTotal := Len(aTotal)
Else
   nTotal := Len(aSerie)
Endif

For nI:= 1 to nTotal
	aSerie[nI][1] := "Cod:" + AllTrim(aTotal[nI][1])
	aSerie[nI][2] := aTotal[nI][2]
	aSerie[nI][3] := AllTrim(aTotal[nI][3])
	aSerie[nI][4] := aTotal[nI][4]
Next nI  
RestArea(aArea)

Return aSerie

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ProcInd308       ³Autor  ³TOTVS               ³ Data ³ 02/07/13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Retorna os valores que serao impressos pelo painel             ³±±
±±³          ³ Cancelamento Cupom - PDV                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Prevencao de Perdas - Loja   	                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function ProcInd308()
Local aArea  	:= GetArea()
Local cQuery    := ""  // Texto SQL que é enviado para o comando TCGenQry
Local aTotal    := {}
Local nI        := 0
Local nTotal    := 0 //limitador do numero de registros por ranking
Local nCont		:= 0 // contador de serie
Local cChvAgrup	:= ""
Local cCodigo	:= ""

cQuery := " SELECT SLG.LG_CODIGO, SLG.LG_NOME, SLX.LX_FILIAL, SLX.LX_PDV, SLX.LX_CUPOM, SLX.LX_SERIE, SLX.LX_DTMOVTO, SLX.LX_HORA "
cQuery += " FROM " + RetSqlName("SLX") + " SLX "
cQuery += " INNER JOIN " + RetSqlName("SLG") + " SLG "
cQuery += " ON SLG.D_E_L_E_T_ = ' ' AND SLG.LG_FILIAL = SLX.LX_FILIAL AND SLG.LG_PDV = SLX.LX_PDV "
cQuery += " WHERE " + LJ7017QryFil(.F.,"SLX")[2] 								   		  			//Grupo de Filial ou Filial
cQuery += " AND SLX.LX_OPERADO BETWEEN '"	+ mv_par05 			+"' AND '"	+ mv_par06 +"' "   		//Caixa
cQuery += " AND SLX.LX_PDV BETWEEN '"		+ mv_par07 			+"' AND '"	+ mv_par08 +"' "   		//PDV
cQuery += " AND SLX.LX_DTMOVTO BETWEEN '"	+ DToS(mv_par09) 	+"' AND '"	+ DToS(mv_par10) +"' " 	//Data
cQuery += " AND SLX.D_E_L_E_T_ = ' ' "
cQuery += " GROUP BY SLG.LG_CODIGO, SLG.LG_NOME, SLX.LX_FILIAL, SLX.LX_PDV, SLX.LX_CUPOM, SLX.LX_SERIE, SLX.LX_DTMOVTO, SLX.LX_HORA "
cQuery += " ORDER BY SLG.LG_CODIGO, SLG.LG_NOME, SLX.LX_FILIAL"

cQuery := ChangeQuery(cQuery)
DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), 'SLXTRB', .F., .T.)
SLXTRB->(DBGoTop())

If SLXTRB->(!Eof())
	nCont := 0
	cChvAgrup := AllTrim(SLXTRB->LX_FILIAL)+'-'+AllTrim(SLXTRB->LX_PDV)+'-'+AllTrim(SLXTRB->LG_NOME)
	While SLXTRB->(!Eof())
		If AllTrim(SLXTRB->LX_FILIAL)+'-'+AllTrim(SLXTRB->LX_PDV)+'-'+AllTrim(SLXTRB->LG_NOME) == cChvAgrup
			nCont++
			cCodigo := AllTrim(SLXTRB->LX_FILIAL)+'-'+AllTrim(SLXTRB->LX_PDV)
		Else
			Aadd(aTotal,{cCodigo, nCont, cChvAgrup, 0}) // Grava chave anterior e o total
			nCont := 1
			cCodigo := AllTrim(SLXTRB->LX_FILIAL)+'-'+AllTrim(SLXTRB->LX_PDV)
			cChvAgrup := AllTrim(SLXTRB->LX_FILIAL)+'-'+AllTrim(SLXTRB->LX_PDV)+'-'+AllTrim(SLXTRB->LG_NOME)
		EndIf
		SLXTRB->(dbSkip())
	EndDo
	Aadd(aTotal,{cCodigo, nCont, cChvAgrup, 0}) // Grava chave anterior e o total pela ultima vez
EndIf

SLXTRB->(DbCloseArea())

//Ordernar do maior para o menor valor 
ASORT(aTotal,,,{ | x,y | x[2] > y[2] } )

//Limitar o numero de registros pelo numero de ranking informado
If Len(aTotal) < Len(aSerie)
   nTotal := Len(aTotal)
Else
   nTotal := Len(aSerie)
Endif

For nI:= 1 to nTotal
	aSerie[nI][1] := "Cod:" + AllTrim(aTotal[nI][1])
	aSerie[nI][2] := aTotal[nI][2]
	aSerie[nI][3] := AllTrim(aTotal[nI][3])
	aSerie[nI][4] := aTotal[nI][4]
Next nI  
RestArea(aArea)

Return aSerie

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ProcInd309       ³Autor  ³TOTVS               ³ Data ³ 02/07/13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Retorna os valores que serao impressos pelo painel             ³±±
±±³          ³ Entrada de Troco - Grupo de Filial                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Prevencao de Perdas - Loja   	                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function ProcInd309()
Local aArea  	:= GetArea()
Local cQuery    := ""  // Texto SQL que é enviado para o comando TCGenQry
Local aTotal    := {}
Local nI        := 0
Local nTotal    := 0 //limitador do numero de registros por ranking

cQuery := " SELECT SAU.AU_CODGRUP, SAU.AU_DESCRI, SUM(SE5.E5_VALOR) TOTALIZ "
cQuery += " FROM " + RetSqlName("SE5") + " SE5 "
cQuery += " INNER JOIN " + RetSqlName("SLW") + " SLW "
cQuery += " ON SLW.D_E_L_E_T_ = ' ' AND SE5.E5_FILIAL = SLW.LW_FILIAL AND (SE5.E5_NUMERO >= SLW.LW_NUMINI AND SE5.E5_NUMERO < SLW.LW_NUMFIM) " 
cQuery += " 	AND SE5.E5_BANCO = SLW.LW_OPERADO AND SE5.E5_DATA >= SLW.LW_DTABERT AND SE5.E5_DATA <= SLW.LW_DTFECHA "
cQuery += " INNER JOIN " + RetSqlName("SAU") + " SAU "
cQuery += " ON SAU.D_E_L_E_T_ = ' ' AND SAU.AU_CODFIL = SE5.E5_FILIAL "
cQuery += " WHERE " + LJ7017QryFil(.F.,"SE5")[2] 								   		  			//Grupo de Filial ou Filial
cQuery += " AND SE5.E5_BANCO BETWEEN '"		+ mv_par05 			+"' AND '"	+ mv_par06 +"' "   		//Caixa
cQuery += " AND SLW.LW_PDV BETWEEN '" 		+ mv_par07 			+"' AND '"	+ mv_par08 +"' "   		//PDV
cQuery += " AND SE5.E5_DATA BETWEEN '"		+ DToS(mv_par09) 	+"' AND '"	+ DToS(mv_par10) +"' " 	//Data
cQuery += " AND SE5.E5_MOEDA = 'TC' AND SE5.E5_NATUREZ = 'TROCO' AND SE5.E5_RECPAG = 'R' AND SE5.D_E_L_E_T_ = ' ' "
cQuery += " GROUP BY SAU.AU_CODGRUP, SAU.AU_DESCRI "
cQuery += " ORDER BY SAU.AU_CODGRUP, SAU.AU_DESCRI "

cQuery := ChangeQuery(cQuery)
DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), 'SE5TRB', .F., .T.)
SE5TRB->(DBGoTop())

While SE5TRB->(!Eof())
	Aadd(aTotal,{SE5TRB->AU_CODGRUP, SE5TRB->TOTALIZ, SE5TRB->AU_DESCRI, 0})
	SE5TRB->(dbSkip())
EndDo
SE5TRB->(DbCloseArea())

//Ordernar do maior para o menor valor 
ASORT(aTotal,,,{ | x,y | x[2] > y[2] } )

//Limitar o numero de registros pelo numero de ranking informado
If Len(aTotal) < Len(aSerie)
   nTotal := Len(aTotal)
Else
   nTotal := Len(aSerie)
Endif

For nI:= 1 to nTotal
	aSerie[nI][1] := "Cod:" + AllTrim(aTotal[nI][1])
	aSerie[nI][2] := aTotal[nI][2]
	aSerie[nI][3] := AllTrim(aTotal[nI][1])+'-'+AllTrim(aTotal[nI][3])
	aSerie[nI][4] := aTotal[nI][4]
Next nI  
RestArea(aArea)

Return aSerie

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ProcInd310       ³Autor  ³TOTVS               ³ Data ³ 02/07/13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Retorna os valores que serao impressos pelo painel             ³±±
±±³          ³ Entrada de Troco - Filial                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Prevencao de Perdas - Loja   	                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function ProcInd310()
Local aArea  	:= GetArea()
Local cQuery    := ""  // Texto SQL que é enviado para o comando TCGenQry
Local aTotal    := {}
Local nI        := 0
Local nTotal    := 0 //limitador do numero de registros por ranking
Local nPos		:= 1
Local aFiliais 	:= Lj7017Fil()// Recebera o retorna dos nomes das Filiais	

cQuery := " SELECT SE5.E5_FILIAL, SUM(SE5.E5_VALOR) TOTALIZ "
cQuery += " FROM " + RetSqlName("SE5") + " SE5 "
cQuery += " INNER JOIN " + RetSqlName("SLW") + " SLW "
cQuery += " ON SLW.D_E_L_E_T_ = ' ' AND SE5.E5_FILIAL = SLW.LW_FILIAL AND (SE5.E5_NUMERO >= SLW.LW_NUMINI AND SE5.E5_NUMERO < SLW.LW_NUMFIM) " 
cQuery += " 	AND SE5.E5_BANCO = SLW.LW_OPERADO AND SE5.E5_DATA >= SLW.LW_DTABERT AND SE5.E5_DATA <= SLW.LW_DTFECHA "
cQuery += " WHERE " + LJ7017QryFil(.F.,"SE5")[2] 								   		  			//Grupo de Filial ou Filial
cQuery += " AND SE5.E5_BANCO BETWEEN '"		+ mv_par05 			+"' AND '"	+ mv_par06 +"' "   		//Caixa
cQuery += " AND SLW.LW_PDV BETWEEN '" 		+ mv_par07 			+"' AND '"	+ mv_par08 +"' "   		//PDV
cQuery += " AND SE5.E5_DATA BETWEEN '"		+ DToS(mv_par09) 	+"' AND '"	+ DToS(mv_par10) +"' " 	//Data
cQuery += " AND SE5.E5_MOEDA = 'TC' AND SE5.E5_NATUREZ = 'TROCO' AND SE5.E5_RECPAG = 'R' AND SE5.D_E_L_E_T_ = ' ' "
cQuery += " GROUP BY SE5.E5_FILIAL "
cQuery += " ORDER BY SE5.E5_FILIAL "

cQuery := ChangeQuery(cQuery)
DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), 'SE5TRB', .F., .T.)
SE5TRB->(DBGoTop())

While SE5TRB->(!Eof())
	nPos := aScan( aFiliais, {|xVar| AllTrim(xVar[1]) == AllTrim(SE5TRB->E5_FILIAL)})
	Aadd(aTotal,{SE5TRB->E5_FILIAL, SE5TRB->TOTALIZ, IIF(nPos>0,aFiliais[nPos][2],""), 0})
	SE5TRB->(dbSkip())
EndDo
SE5TRB->(DbCloseArea())

//Ordernar do maior para o menor valor 
ASORT(aTotal,,,{ | x,y | x[2] > y[2] } )

//Limitar o numero de registros pelo numero de ranking informado
If Len(aTotal) < Len(aSerie)
   nTotal := Len(aTotal)
Else
   nTotal := Len(aSerie)
Endif

For nI:= 1 to nTotal
	aSerie[nI][1] := "Cod:" + AllTrim(aTotal[nI][1])
	aSerie[nI][2] := aTotal[nI][2]
	aSerie[nI][3] := AllTrim(aTotal[nI][1])+'-'+AllTrim(aTotal[nI][3])
	aSerie[nI][4] := aTotal[nI][4]
Next nI  
RestArea(aArea)

Return aSerie

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ProcInd311       ³Autor  ³TOTVS               ³ Data ³ 02/07/13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Retorna os valores que serao impressos pelo painel             ³±±
±±³          ³ Entrada de Troco - Caixa                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Prevencao de Perdas - Loja   	                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function ProcInd311()
Local aArea  	:= GetArea()
Local cQuery    := ""  // Texto SQL que é enviado para o comando TCGenQry
Local aTotal    := {}
Local nI        := 0
Local nTotal    := 0 //limitador do numero de registros por ranking

cQuery := " SELECT SA6.A6_COD, SA6.A6_NREDUZ, SUM(SE5.E5_VALOR) TOTALIZ "
cQuery += " FROM " + RetSqlName("SE5") + " SE5 "
cQuery += " INNER JOIN " + RetSqlName("SLW") + " SLW "
cQuery += " ON SLW.D_E_L_E_T_ = ' ' AND SE5.E5_FILIAL = SLW.LW_FILIAL AND (SE5.E5_NUMERO >= SLW.LW_NUMINI AND SE5.E5_NUMERO < SLW.LW_NUMFIM) " 
cQuery += " 	AND SE5.E5_BANCO = SLW.LW_OPERADO AND SE5.E5_DATA >= SLW.LW_DTABERT AND SE5.E5_DATA <= SLW.LW_DTFECHA "
cQuery += " INNER JOIN " + RetSqlName("SA6") + " SA6 "
cQuery += " ON SA6.D_E_L_E_T_ = ' ' AND SA6.A6_COD = SE5.E5_BANCO AND SA6.A6_AGENCIA = SE5.E5_AGENCIA AND SA6.A6_NUMCON = SE5.E5_CONTA "
cQuery += " WHERE " + LJ7017QryFil(.F.,"SE5")[2] 								   		  			//Grupo de Filial ou Filial
cQuery += " AND SE5.E5_BANCO BETWEEN '"		+ mv_par05 			+"' AND '"	+ mv_par06 +"' "   		//Caixa
cQuery += " AND SLW.LW_PDV BETWEEN '" 		+ mv_par07 			+"' AND '"	+ mv_par08 +"' "   		//PDV
cQuery += " AND SE5.E5_DATA BETWEEN '"		+ DToS(mv_par09) 	+"' AND '"	+ DToS(mv_par10) +"' " 	//Data
cQuery += " AND SE5.E5_MOEDA = 'TC' AND SE5.E5_NATUREZ = 'TROCO' AND SE5.E5_RECPAG = 'R' AND SE5.D_E_L_E_T_ = ' ' "
cQuery += " GROUP BY SA6.A6_COD, SA6.A6_NREDUZ "
cQuery += " ORDER BY SA6.A6_COD, SA6.A6_NREDUZ "

cQuery := ChangeQuery(cQuery)
DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), 'SE5TRB', .F., .T.)
SE5TRB->(DBGoTop())

While SE5TRB->(!Eof())
	Aadd(aTotal,{SE5TRB->A6_COD, SE5TRB->TOTALIZ, SE5TRB->A6_NREDUZ, 0})
	SE5TRB->(dbSkip())
EndDo
SE5TRB->(DbCloseArea())

//Ordernar do maior para o menor valor 
ASORT(aTotal,,,{ | x,y | x[2] > y[2] } )

//Limitar o numero de registros pelo numero de ranking informado
If Len(aTotal) < Len(aSerie)
   nTotal := Len(aTotal)
Else
   nTotal := Len(aSerie)
Endif

For nI:= 1 to nTotal
	aSerie[nI][1] := "Cod:" + AllTrim(aTotal[nI][1])
	aSerie[nI][2] := aTotal[nI][2]
	aSerie[nI][3] := AllTrim(aTotal[nI][1])+'-'+AllTrim(aTotal[nI][3])
	aSerie[nI][4] := aTotal[nI][4]
Next nI  
RestArea(aArea)

Return aSerie

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ProcInd312       ³Autor  ³TOTVS               ³ Data ³ 02/07/13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Retorna os valores que serao impressos pelo painel             ³±±
±±³          ³ Entrada de Troco - PDV                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Prevencao de Perdas - Loja   	                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function ProcInd312()
Local aArea  	:= GetArea()
Local cQuery    := ""  // Texto SQL que é enviado para o comando TCGenQry
Local aTotal    := {}
Local nI        := 0
Local nTotal    := 0 //limitador do numero de registros por ranking

cQuery := " SELECT SLG.LG_FILIAL, SLG.LG_CODIGO, SLG.LG_PDV, SLG.LG_NOME, SUM(SE5.E5_VALOR) TOTALIZ "
cQuery += " FROM " + RetSqlName("SE5") + " SE5 "
cQuery += " INNER JOIN " + RetSqlName("SLW") + " SLW "
cQuery += " ON SLW.D_E_L_E_T_ = ' ' AND SE5.E5_FILIAL = SLW.LW_FILIAL AND (SE5.E5_NUMERO >= SLW.LW_NUMINI AND SE5.E5_NUMERO < SLW.LW_NUMFIM) " 
cQuery += " 	AND SE5.E5_BANCO = SLW.LW_OPERADO AND SE5.E5_DATA >= SLW.LW_DTABERT AND SE5.E5_DATA <= SLW.LW_DTFECHA "
cQuery += " INNER JOIN " + RetSqlName("SLG") + " SLG "
cQuery += " ON SLG.D_E_L_E_T_ = ' ' AND SLG.LG_FILIAL = SE5.E5_FILIAL AND SLG.LG_CODIGO = SLW.LW_ESTACAO AND SLG.LG_PDV = SLW.LW_PDV"
cQuery += " WHERE " + LJ7017QryFil(.F.,"SE5")[2] 								   		  			//Grupo de Filial ou Filial
cQuery += " AND SE5.E5_BANCO BETWEEN '"		+ mv_par05 			+"' AND '"	+ mv_par06 +"' "   		//Caixa
cQuery += " AND SLW.LW_PDV BETWEEN '"		+ mv_par07 			+"' AND '"	+ mv_par08 +"' "   		//PDV
cQuery += " AND SE5.E5_DATA BETWEEN '"		+ DToS(mv_par09) 	+"' AND '"	+ DToS(mv_par10) +"' " 	//Data
cQuery += " AND SE5.E5_MOEDA = 'TC' AND SE5.E5_NATUREZ = 'TROCO' AND SE5.E5_RECPAG = 'R' AND SE5.D_E_L_E_T_ = ' ' "
cQuery += " GROUP BY SLG.LG_FILIAL, SLG.LG_CODIGO, SLG.LG_PDV, SLG.LG_NOME "
cQuery += " ORDER BY SLG.LG_FILIAL, SLG.LG_CODIGO, SLG.LG_PDV, SLG.LG_NOME "

cQuery := ChangeQuery(cQuery)
DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), 'SE5TRB', .F., .T.)
SE5TRB->(DBGoTop())

While SE5TRB->(!Eof())
	Aadd(aTotal,{AllTrim(SE5TRB->LG_FILIAL)+'-'+AllTrim(SE5TRB->LG_PDV), SE5TRB->TOTALIZ, AllTrim(SE5TRB->LG_NOME), 0})
	SE5TRB->(dbSkip())
EndDo
SE5TRB->(DbCloseArea())

//Ordernar do maior para o menor valor 
ASORT(aTotal,,,{ | x,y | x[2] > y[2] } )

//Limitar o numero de registros pelo numero de ranking informado
If Len(aTotal) < Len(aSerie)
   nTotal := Len(aTotal)
Else
   nTotal := Len(aSerie)
Endif

For nI:= 1 to nTotal
	aSerie[nI][1] := "Cod:" + AllTrim(aTotal[nI][1])
	aSerie[nI][2] := aTotal[nI][2]
	aSerie[nI][3] := AllTrim(aTotal[nI][1])+'-'+AllTrim(aTotal[nI][3])
	aSerie[nI][4] := aTotal[nI][4]
Next nI  
RestArea(aArea)

Return aSerie

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ProcInd313       ³Autor  ³TOTVS               ³ Data ³ 02/07/13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Retorna os valores que serao impressos pelo painel             ³±±
±±³          ³ Sangria - Grupo de Filial                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Prevencao de Perdas - Loja   	                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function ProcInd313()
Local aArea  	:= GetArea()
Local cQuery    := ""  // Texto SQL que é enviado para o comando TCGenQry
Local aTotal    := {}
Local nI        := 0
Local nTotal    := 0 //limitador do numero de registros por ranking

cQuery := " SELECT SAU.AU_CODGRUP, SAU.AU_DESCRI, SUM(SE5.E5_VALOR) TOTALIZ "
cQuery += " FROM " + RetSqlName("SE5") + " SE5 "
cQuery += " INNER JOIN " + RetSqlName("SLW") + " SLW "
cQuery += " ON SLW.D_E_L_E_T_ = ' ' AND SE5.E5_FILIAL = SLW.LW_FILIAL AND SE5.E5_NUMERO = SLW.LW_NUMFIM " 
cQuery += " 	AND SE5.E5_BANCO = SLW.LW_OPERADO AND SE5.E5_DATA >= SLW.LW_DTABERT AND SE5.E5_DATA <= SLW.LW_DTFECHA "
cQuery += " INNER JOIN " + RetSqlName("SAU") + " SAU "
cQuery += " ON SAU.D_E_L_E_T_ = ' ' AND SAU.AU_CODFIL = SE5.E5_FILIAL "
cQuery += " WHERE " + LJ7017QryFil(.F.,"SE5")[2] 								   		  			//Grupo de Filial ou Filial
cQuery += " AND SE5.E5_BANCO BETWEEN '"		+ mv_par05 			+"' AND '"	+ mv_par06 +"' "   		//Caixa
cQuery += " AND SLW.LW_PDV BETWEEN '"		+ mv_par07 			+"' AND '"	+ mv_par08 +"' "   		//PDV
cQuery += " AND SE5.E5_DATA BETWEEN '"		+ DToS(mv_par09) 	+"' AND '"	+ DToS(mv_par10) +"' " 	//Data
cQuery += " AND SE5.E5_NATUREZ = 'SANGRIA' AND SE5.E5_TIPODOC IN ('SG','TR','TE') AND SE5.E5_RECPAG = 'P' "
cQuery += " AND (SE5.E5_SITUACA <> 'C') AND (SE5.E5_MOEDA <> 'ES') AND SE5.E5_TIPODOC <> 'LJ' AND SE5.D_E_L_E_T_ = ' '  "
cQuery += " GROUP BY SAU.AU_CODGRUP, SAU.AU_DESCRI "
cQuery += " ORDER BY SAU.AU_CODGRUP, SAU.AU_DESCRI "

cQuery := ChangeQuery(cQuery)
DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), 'SE5TRB', .F., .T.)
SE5TRB->(DBGoTop())

While SE5TRB->(!Eof())
	Aadd(aTotal,{SE5TRB->AU_CODGRUP, SE5TRB->TOTALIZ, AllTrim(SE5TRB->AU_DESCRI), 0})
	SE5TRB->(dbSkip())
EndDo
SE5TRB->(DbCloseArea())

//Ordernar do maior para o menor valor 
ASORT(aTotal,,,{ | x,y | x[2] > y[2] } )

//Limitar o numero de registros pelo numero de ranking informado
If Len(aTotal) < Len(aSerie)
   nTotal := Len(aTotal)
Else
   nTotal := Len(aSerie)
Endif

For nI:= 1 to nTotal
	aSerie[nI][1] := "Cod:" + AllTrim(aTotal[nI][1])
	aSerie[nI][2] := aTotal[nI][2]
	aSerie[nI][3] := AllTrim(aTotal[nI][1])+'-'+AllTrim(aTotal[nI][3])
	aSerie[nI][4] := aTotal[nI][4]
Next nI  
RestArea(aArea)

Return aSerie

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ProcInd314       ³Autor  ³TOTVS               ³ Data ³ 02/07/13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Retorna os valores que serao impressos pelo painel             ³±±
±±³          ³ Sangria - Filial                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Prevencao de Perdas - Loja   	                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function ProcInd314()
Local aArea  	:= GetArea()
Local cQuery    := ""  // Texto SQL que é enviado para o comando TCGenQry
Local aTotal    := {}
Local nI        := 0
Local nTotal    := 0 //limitador do numero de registros por ranking
Local nPos		:= 1
Local aFiliais 	:= Lj7017Fil()// Recebera o retorna dos nomes das Filiais	

cQuery := " SELECT SE5.E5_FILIAL, SUM(SE5.E5_VALOR) TOTALIZ "
cQuery += " FROM " + RetSqlName("SE5") + " SE5 "
cQuery += " INNER JOIN " + RetSqlName("SLW") + " SLW "
cQuery += " ON SLW.D_E_L_E_T_ = ' ' AND SE5.E5_FILIAL = SLW.LW_FILIAL AND SE5.E5_NUMERO = SLW.LW_NUMFIM " 
cQuery += " 	AND SE5.E5_BANCO = SLW.LW_OPERADO AND SE5.E5_DATA >= SLW.LW_DTABERT AND SE5.E5_DATA <= SLW.LW_DTFECHA "
cQuery += " WHERE " + LJ7017QryFil(.F.,"SE5")[2] 								   		  			//Grupo de Filial ou Filial
cQuery += " AND SE5.E5_BANCO BETWEEN '"		+ mv_par05 			+"' AND '"	+ mv_par06 +"' "   		//Caixa
cQuery += " AND SLW.LW_PDV BETWEEN '"  		+ mv_par07 			+"' AND '"	+ mv_par08 +"' "   		//PDV
cQuery += " AND SE5.E5_DATA BETWEEN '"		+ DToS(mv_par09) 	+"' AND '"	+ DToS(mv_par10) +"' " 	//Data
cQuery += " AND SE5.E5_NATUREZ = 'SANGRIA' AND SE5.E5_TIPODOC IN ('SG','TR','TE') AND SE5.E5_RECPAG = 'P' "
cQuery += " AND (SE5.E5_SITUACA <> 'C') AND (SE5.E5_MOEDA <> 'ES') AND SE5.E5_TIPODOC <> 'LJ' AND SE5.D_E_L_E_T_ = ' '  "
cQuery += " GROUP BY SE5.E5_FILIAL "
cQuery += " ORDER BY SE5.E5_FILIAL "

cQuery := ChangeQuery(cQuery)
DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), 'SE5TRB', .F., .T.)
SE5TRB->(DBGoTop())

While SE5TRB->(!Eof())
	nPos := aScan( aFiliais, {|xVar| AllTrim(xVar[1]) == AllTrim(SE5TRB->E5_FILIAL)})
	Aadd(aTotal,{SE5TRB->E5_FILIAL, SE5TRB->TOTALIZ, IIF(nPos>0,aFiliais[nPos][2],""), 0})
	SE5TRB->(dbSkip())
EndDo
SE5TRB->(DbCloseArea())

//Ordernar do maior para o menor valor 
ASORT(aTotal,,,{ | x,y | x[2] > y[2] } )

//Limitar o numero de registros pelo numero de ranking informado
If Len(aTotal) < Len(aSerie)
   nTotal := Len(aTotal)
Else
   nTotal := Len(aSerie)
Endif

For nI:= 1 to nTotal
	aSerie[nI][1] := "Cod:" + AllTrim(aTotal[nI][1])
	aSerie[nI][2] := aTotal[nI][2]
	aSerie[nI][3] := AllTrim(aTotal[nI][1])+'-'+AllTrim(aTotal[nI][3])
	aSerie[nI][4] := aTotal[nI][4]
Next nI  
RestArea(aArea)

Return aSerie

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ProcInd315       ³Autor  ³TOTVS               ³ Data ³ 02/07/13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Retorna os valores que serao impressos pelo painel             ³±±
±±³          ³ Sangria - Caixa                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Prevencao de Perdas - Loja   	                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function ProcInd315()
Local aArea  	:= GetArea()
Local cQuery    := ""  // Texto SQL que é enviado para o comando TCGenQry
Local aTotal    := {}
Local nI        := 0
Local nTotal    := 0 //limitador do numero de registros por ranking

cQuery := " SELECT SA6.A6_COD, SA6.A6_NREDUZ, SUM(SE5.E5_VALOR) TOTALIZ "
cQuery += " FROM " + RetSqlName("SE5") + " SE5 "
cQuery += " INNER JOIN " + RetSqlName("SLW") + " SLW "
cQuery += " ON SLW.D_E_L_E_T_ = ' ' AND SE5.E5_FILIAL = SLW.LW_FILIAL AND SE5.E5_NUMERO = SLW.LW_NUMFIM " 
cQuery += " 	AND SE5.E5_BANCO = SLW.LW_OPERADO AND SE5.E5_DATA >= SLW.LW_DTABERT AND SE5.E5_DATA <= SLW.LW_DTFECHA "
cQuery += " INNER JOIN " + RetSqlName("SA6") + " SA6 "
cQuery += " ON SA6.D_E_L_E_T_ = ' ' AND SA6.A6_COD = SE5.E5_BANCO AND SA6.A6_AGENCIA = SE5.E5_AGENCIA AND SA6.A6_NUMCON = SE5.E5_CONTA "
cQuery += " WHERE " + LJ7017QryFil(.F.,"SE5")[2] 								   		  			//Grupo de Filial ou Filial
cQuery += " AND SE5.E5_BANCO BETWEEN '"		+ mv_par05 			+"' AND '"	+ mv_par06 +"' "   		//Caixa
cQuery += " AND SLW.LW_PDV BETWEEN '" 		+ mv_par07 			+"' AND '"	+ mv_par08 +"' "   		//PDV
cQuery += " AND SE5.E5_DATA BETWEEN '"		+ DToS(mv_par09) 	+"' AND '"	+ DToS(mv_par10) +"' " 	//Data
cQuery += " AND SE5.E5_NATUREZ = 'SANGRIA' AND SE5.E5_TIPODOC IN ('SG','TR','TE') AND SE5.E5_RECPAG = 'P' "
cQuery += " AND (SE5.E5_SITUACA <> 'C') AND (SE5.E5_MOEDA <> 'ES') AND SE5.E5_TIPODOC <> 'LJ' AND SE5.D_E_L_E_T_ = ' '  "
cQuery += " GROUP BY SA6.A6_COD, SA6.A6_NREDUZ "
cQuery += " ORDER BY SA6.A6_COD, SA6.A6_NREDUZ "

cQuery := ChangeQuery(cQuery)
DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), 'SE5TRB', .F., .T.)
SE5TRB->(DBGoTop())

While SE5TRB->(!Eof())
	Aadd(aTotal,{SE5TRB->A6_COD, SE5TRB->TOTALIZ, SE5TRB->A6_NREDUZ, 0})
	SE5TRB->(dbSkip())
EndDo
SE5TRB->(DbCloseArea())

//Ordernar do maior para o menor valor 
ASORT(aTotal,,,{ | x,y | x[2] > y[2] } )

//Limitar o numero de registros pelo numero de ranking informado
If Len(aTotal) < Len(aSerie)
   nTotal := Len(aTotal)
Else
   nTotal := Len(aSerie)
Endif

For nI:= 1 to nTotal
	aSerie[nI][1] := "Cod:" + AllTrim(aTotal[nI][1])
	aSerie[nI][2] := aTotal[nI][2]
	aSerie[nI][3] := AllTrim(aTotal[nI][1])+'-'+AllTrim(aTotal[nI][3])
	aSerie[nI][4] := aTotal[nI][4]
Next nI  
RestArea(aArea)

Return aSerie

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ProcInd316       ³Autor  ³TOTVS               ³ Data ³ 02/07/13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Retorna os valores que serao impressos pelo painel             ³±±
±±³          ³ Sangria - PDV                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Prevencao de Perdas - Loja   	                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function ProcInd316()
Local aArea  	:= GetArea()
Local cQuery    := ""  // Texto SQL que é enviado para o comando TCGenQry
Local aTotal    := {}
Local nI        := 0
Local nTotal    := 0 //limitador do numero de registros por ranking

cQuery := " SELECT SLG.LG_FILIAL, SLG.LG_PDV, SLG.LG_NOME, SUM(SE5.E5_VALOR) TOTALIZ "
cQuery += " FROM " + RetSqlName("SE5") + " SE5 "
cQuery += " INNER JOIN " + RetSqlName("SLW") + " SLW "
cQuery += " ON SLW.D_E_L_E_T_ = ' ' AND SE5.E5_FILIAL = SLW.LW_FILIAL AND SE5.E5_NUMERO = SLW.LW_NUMFIM " 
cQuery += " 	AND SE5.E5_BANCO = SLW.LW_OPERADO AND SE5.E5_DATA >= SLW.LW_DTABERT AND SE5.E5_DATA <= SLW.LW_DTFECHA "
cQuery += " INNER JOIN " + RetSqlName("SLG") + " SLG "
cQuery += " ON SLG.D_E_L_E_T_ = ' ' AND SLG.LG_FILIAL = SE5.E5_FILIAL AND SLG.LG_CODIGO = SLW.LW_ESTACAO AND SLG.LG_PDV = SLW.LW_PDV "
cQuery += " WHERE " + LJ7017QryFil(.F.,"SE5")[2] 								   		  			//Grupo de Filial ou Filial
cQuery += " AND SE5.E5_BANCO BETWEEN '"		+ mv_par05 			+"' AND '"	+ mv_par06 +"' "   		//Caixa
cQuery += " AND SLW.LW_PDV BETWEEN '" 		+ mv_par07 			+"' AND '"	+ mv_par08 +"' "   		//PDV
cQuery += " AND SE5.E5_DATA BETWEEN '"		+ DToS(mv_par09) 	+"' AND '"	+ DToS(mv_par10) +"' " 	//Data
cQuery += " AND SE5.E5_NATUREZ = 'SANGRIA' AND SE5.E5_TIPODOC IN ('SG','TR','TE') AND SE5.E5_RECPAG = 'P' "
cQuery += " AND (SE5.E5_SITUACA <> 'C') AND (SE5.E5_MOEDA <> 'ES') AND SE5.E5_TIPODOC <> 'LJ' AND SE5.D_E_L_E_T_ = ' '  "
cQuery += " GROUP BY SLG.LG_FILIAL, SLG.LG_PDV, SLG.LG_NOME "
cQuery += " ORDER BY SLG.LG_FILIAL, SLG.LG_PDV, SLG.LG_NOME "

cQuery := ChangeQuery(cQuery)
DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), 'SE5TRB', .F., .T.)
SE5TRB->(DBGoTop())

While SE5TRB->(!Eof())
	Aadd(aTotal,{AllTrim(SE5TRB->LG_FILIAL)+'-'+AllTrim(SE5TRB->LG_PDV), SE5TRB->TOTALIZ, AllTrim(SE5TRB->LG_NOME), 0})
	SE5TRB->(dbSkip())
EndDo
SE5TRB->(DbCloseArea())

//Ordernar do maior para o menor valor 
ASORT(aTotal,,,{ | x,y | x[2] > y[2] } )

//Limitar o numero de registros pelo numero de ranking informado
If Len(aTotal) < Len(aSerie)
   nTotal := Len(aTotal)
Else
   nTotal := Len(aSerie)
Endif

For nI:= 1 to nTotal
	aSerie[nI][1] := "Cod:" + AllTrim(aTotal[nI][1])
	aSerie[nI][2] := aTotal[nI][2]
	aSerie[nI][3] := AllTrim(aTotal[nI][1])+'-'+AllTrim(aTotal[nI][3])
	aSerie[nI][4] := aTotal[nI][4]
Next nI  
RestArea(aArea)

Return aSerie

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ProcInd401       ³Autor  ³TOTVS               ³ Data ³ 02/07/13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Retorna os valores que serao impressos pelo painel             ³±±
±±³          ³ Media Atendimento Vendas - Grupo de Filial                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Prevencao de Perdas - Loja   	                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function ProcInd401()
Local aArea  	:= GetArea()
Local cQuery    := ""  // Texto SQL que é enviado para o comando TCGenQry
Local aTotal    := {}
Local nI        := 0
Local nTotal    := 0 //limitador do numero de registros por ranking
Local nCont		:= 0 // contador de serie
Local cChvAgrup	:= ""
Local cCodigo	:= ""

cQuery := " SELECT SAU.AU_CODGRUP,SAU.AU_DESCRI,SLW.LW_OPERADO,SL1.L1_EMISSAO,SL1.L1_DOC,SL1.L1_SERIE,SL1.L1_FILIAL,SL1.L1_PDV,SL1.L1_TIMEATE "
cQuery += " FROM " + RetSqlName("SL1") + " SL1 "
cQuery += " INNER JOIN " + RetSqlName("SLW") + " SLW ON SLW.D_E_L_E_T_ = ' ' "
cQuery += " AND SL1.L1_FILIAL = SLW.LW_FILIAL AND SL1.L1_NUMMOV = SLW.LW_NUMMOV AND SL1.L1_PDV = SLW.LW_PDV AND SL1.L1_DOC >= SLW.LW_NUMINI"
cQuery += " AND SL1.L1_EMISSAO >= SLW.LW_DTABERT AND SL1.L1_EMISSAO <= SLW.LW_DTFECHA "
cQuery += " INNER JOIN " + RetSqlName("SAU") + " SAU "
cQuery += " ON SAU.D_E_L_E_T_ = ' ' AND SAU.AU_CODFIL = SL1.L1_FILIAL "
cQuery += " WHERE " + LJ7017QryFil(.F.,"SL1")[2] 								   		  			//Grupo de Filial ou Filial
cQuery += " AND SLW.LW_OPERADO BETWEEN '"	+ mv_par05 			+"' AND '"	+ mv_par06 +"' "   		//Caixa
cQuery += " AND SL1.L1_PDV BETWEEN '"		+ mv_par07 			+"' AND '"	+ mv_par08 +"' "   		//PDV
cQuery += " AND SL1.L1_EMISSAO BETWEEN '"	+ DToS(mv_par09) 	+"' AND '"	+ DToS(mv_par10) +"' " 	//Data
cQuery += " AND SL1.L1_IMPRIME <> ' ' AND SL1.L1_STATUS = ' '	AND SL1.D_E_L_E_T_ = ' ' "
cQuery += " GROUP BY SAU.AU_CODGRUP,SAU.AU_DESCRI,SLW.LW_OPERADO,SL1.L1_EMISSAO,SL1.L1_DOC,SL1.L1_SERIE,SL1.L1_FILIAL,SL1.L1_PDV,SL1.L1_TIMEATE "
cQuery += " ORDER BY SAU.AU_CODGRUP, SL1.L1_FILIAL, SL1.L1_DOC"

cQuery := ChangeQuery(cQuery)
DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), 'SL1TRB', .F., .T.)
SL1TRB->(DBGoTop())

If SL1TRB->(!Eof())
	nTotal := 0
	nCont := 0
	cChvAgrup := SL1TRB->AU_CODGRUP+'-'+AllTrim(SL1TRB->AU_DESCRI)
	While SL1TRB->(!Eof())
		If SL1TRB->AU_CODGRUP+'-'+AllTrim(SL1TRB->AU_DESCRI) == cChvAgrup
			nTotal += SL1TRB->L1_TIMEATE
			nCont++
			cCodigo := SL1TRB->AU_CODGRUP
		Else
			Aadd(aTotal,{cCodigo, Round(nTotal/nCont,0), cChvAgrup, 0}) // Grava chave anterior e o total
			nTotal := SL1TRB->L1_TIMEATE
			nCont := 1
			cCodigo := SL1TRB->AU_CODGRUP
			cChvAgrup := SL1TRB->AU_CODGRUP+'-'+AllTrim(SL1TRB->AU_DESCRI)
		EndIf
		SL1TRB->(dbSkip())
	EndDo
	Aadd(aTotal,{cCodigo, Round(nTotal/nCont,0), cChvAgrup, 0}) // Grava chave anterior e o total pela ultima vez
EndIf

SL1TRB->(DbCloseArea())

//Ordernar do maior para o menor valor 
ASORT(aTotal,,,{ | x,y | x[2] > y[2] } )

//Limitar o numero de registros pelo numero de ranking informado
nTotal := 0
If Len(aTotal) < Len(aSerie)
   nTotal := Len(aTotal)
Else
   nTotal := Len(aSerie)
Endif

For nI:= 1 to nTotal
	aSerie[nI][1] := "Cod:" + AllTrim(aTotal[nI][1])
	aSerie[nI][2] := aTotal[nI][2]
	aSerie[nI][3] := AllTrim(aTotal[nI][3])
	aSerie[nI][4] := aTotal[nI][4]
Next nI  
RestArea(aArea)

Return aSerie

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ProcInd402       ³Autor  ³TOTVS               ³ Data ³ 02/07/13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Retorna os valores que serao impressos pelo painel             ³±±
±±³          ³ Media Atendimento Vendas - Filial                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Prevencao de Perdas - Loja   	                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function ProcInd402()
Local aArea  	:= GetArea()
Local cQuery    := ""  // Texto SQL que é enviado para o comando TCGenQry
Local aTotal    := {}
Local nI        := 0
Local nTotal    := 0 //limitador do numero de registros por ranking
Local nCont		:= 0 // contador de serie
Local cChvAgrup	:= ""
Local nPos		:= 1
Local aFiliais 	:= Lj7017Fil()// Recebera o retorna dos nomes das Filiais	

cQuery := " SELECT SLW.LW_OPERADO,SL1.L1_EMISSAO,SL1.L1_DOC,SL1.L1_SERIE,SL1.L1_FILIAL,SL1.L1_PDV,SL1.L1_TIMEATE "
cQuery += " FROM " + RetSqlName("SL1") + " SL1 "
cQuery += " INNER JOIN " + RetSqlName("SLW") + " SLW ON SLW.D_E_L_E_T_ = ' ' "
cQuery += " AND SL1.L1_FILIAL = SLW.LW_FILIAL AND SL1.L1_NUMMOV = SLW.LW_NUMMOV AND SL1.L1_PDV = SLW.LW_PDV AND SL1.L1_DOC >= SLW.LW_NUMINI"
cQuery += " AND SL1.L1_EMISSAO >= SLW.LW_DTABERT AND SL1.L1_EMISSAO <= SLW.LW_DTFECHA "
cQuery += " WHERE " + LJ7017QryFil(.F.,"SL1")[2] 								   		  			//Grupo de Filial ou Filial
cQuery += " AND SLW.LW_OPERADO BETWEEN '"	+ mv_par05 			+"' AND '"	+ mv_par06 +"' "   		//Caixa
cQuery += " AND SL1.L1_PDV BETWEEN '"		+ mv_par07 			+"' AND '"	+ mv_par08 +"' "   		//PDV
cQuery += " AND SL1.L1_EMISSAO BETWEEN '"	+ DToS(mv_par09) 	+"' AND '"	+ DToS(mv_par10) +"' " 	//Data
cQuery += " AND SL1.L1_IMPRIME <> ' ' AND SL1.L1_STATUS = ' '	AND SL1.D_E_L_E_T_ = ' ' "
cQuery += " GROUP BY SLW.LW_OPERADO,SL1.L1_EMISSAO,SL1.L1_DOC,SL1.L1_SERIE,SL1.L1_FILIAL,SL1.L1_PDV,SL1.L1_TIMEATE "
cQuery += " ORDER BY SL1.L1_FILIAL, SL1.L1_DOC"

cQuery := ChangeQuery(cQuery)
DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), 'SL1TRB', .F., .T.)
SL1TRB->(DBGoTop())

If SL1TRB->(!Eof())
	nTotal := 0
	nCont := 0
	cChvAgrup := SL1TRB->L1_FILIAL
	While SL1TRB->(!Eof())
		If SL1TRB->L1_FILIAL == cChvAgrup
			nTotal += SL1TRB->L1_TIMEATE
			nCont++
		Else
			nPos := aScan( aFiliais, {|xVar| AllTrim(xVar[1]) == AllTrim(cChvAgrup)})
			Aadd(aTotal,{cChvAgrup, Round(nTotal/nCont,0), cChvAgrup+IIF(nPos>0,"-"+aFiliais[nPos][2],""), 0}) // Grava chave anterior e o total
			nTotal := SL1TRB->L1_TIMEATE
			nCont := 1
			cChvAgrup := SL1TRB->L1_FILIAL
		EndIf
		SL1TRB->(dbSkip())
	EndDo
	nPos := aScan( aFiliais, {|xVar| AllTrim(xVar[1]) == AllTrim(cChvAgrup)})
	Aadd(aTotal,{cChvAgrup, Round(nTotal/nCont,0), cChvAgrup+IIF(nPos>0,"-"+aFiliais[nPos][2],""), 0}) // Grava chave anterior e o total
EndIf

SL1TRB->(DbCloseArea())

//Ordernar do maior para o menor valor 
ASORT(aTotal,,,{ | x,y | x[2] > y[2] } )

//Limitar o numero de registros pelo numero de ranking informado
nTotal := 0
If Len(aTotal) < Len(aSerie)
   nTotal := Len(aTotal)
Else
   nTotal := Len(aSerie)
Endif

For nI:= 1 to nTotal
	aSerie[nI][1] := "Cod:" + AllTrim(aTotal[nI][1])
	aSerie[nI][2] := aTotal[nI][2]
	aSerie[nI][3] := AllTrim(aTotal[nI][3])
	aSerie[nI][4] := aTotal[nI][4]
Next nI  
RestArea(aArea)

Return aSerie

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ProcInd403       ³Autor  ³TOTVS               ³ Data ³ 02/07/13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Retorna os valores que serao impressos pelo painel             ³±±
±±³          ³ Media Atendimento Vendas - Caixa                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Prevencao de Perdas - Loja   	                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function ProcInd403()
Local aArea  	:= GetArea()
Local cQuery    := ""  // Texto SQL que é enviado para o comando TCGenQry
Local aTotal    := {}
Local nI        := 0
Local nTotal    := 0 //limitador do numero de registros por ranking
Local nCont		:= 0 // contador de serie
Local cChvAgrup	:= ""
Local cCodigo	:= ""

cQuery := " SELECT SA6.A6_COD,SA6.A6_NREDUZ,SL1.L1_EMISSAO,SL1.L1_DOC,SL1.L1_SERIE,SL1.L1_FILIAL,SL1.L1_PDV,SL1.L1_TIMEATE "
cQuery += " FROM " + RetSqlName("SL1") + " SL1 "
cQuery += " INNER JOIN " + RetSqlName("SLW") + " SLW ON SLW.D_E_L_E_T_ = ' ' "
cQuery += " AND SL1.L1_FILIAL = SLW.LW_FILIAL AND SL1.L1_NUMMOV = SLW.LW_NUMMOV AND SL1.L1_PDV = SLW.LW_PDV AND SL1.L1_DOC >= SLW.LW_NUMINI"
cQuery += " AND SL1.L1_EMISSAO >= SLW.LW_DTABERT AND SL1.L1_EMISSAO <= SLW.LW_DTFECHA "
cQuery += " INNER JOIN " + RetSqlName("SA6") + " SA6 "
cQuery += " ON SA6.D_E_L_E_T_ = ' ' AND SA6.A6_COD = SLW.LW_OPERADO "
cQuery += " WHERE " + LJ7017QryFil(.F.,"SL1")[2] 								   		  			//Grupo de Filial ou Filial
cQuery += " AND SLW.LW_OPERADO BETWEEN '"	+ mv_par05 			+"' AND '"	+ mv_par06 +"' "   		//Caixa
cQuery += " AND SL1.L1_PDV BETWEEN '"		+ mv_par07 			+"' AND '"	+ mv_par08 +"' "   		//PDV
cQuery += " AND SL1.L1_EMISSAO BETWEEN '"	+ DToS(mv_par09) 	+"' AND '"	+ DToS(mv_par10) +"' " 	//Data
cQuery += " AND SL1.L1_IMPRIME <> ' ' AND SL1.L1_STATUS = ' '	AND SL1.D_E_L_E_T_ = ' ' "
cQuery += " GROUP BY SA6.A6_COD,SA6.A6_NREDUZ,SL1.L1_EMISSAO,SL1.L1_DOC,SL1.L1_SERIE,SL1.L1_FILIAL,SL1.L1_PDV,SL1.L1_TIMEATE "
cQuery += " ORDER BY SA6.A6_COD,SA6.A6_NREDUZ,SL1.L1_FILIAL,SL1.L1_DOC"

cQuery := ChangeQuery(cQuery)
DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), 'SL1TRB', .F., .T.)
SL1TRB->(DBGoTop())

If SL1TRB->(!Eof())
	nTotal := 0
	nCont := 0
	cChvAgrup := SL1TRB->A6_COD+'-'+SL1TRB->A6_NREDUZ
	While SL1TRB->(!Eof())
		If SL1TRB->A6_COD+'-'+SL1TRB->A6_NREDUZ == cChvAgrup
			nTotal += SL1TRB->L1_TIMEATE
			nCont++
			cCodigo := SL1TRB->A6_COD
		Else
			Aadd(aTotal,{cCodigo, Round(nTotal/nCont,0), cChvAgrup, 0}) // Grava chave anterior e o total
			nTotal := SL1TRB->L1_TIMEATE
			nCont := 1
			cCodigo := SL1TRB->A6_COD
			cChvAgrup := SL1TRB->A6_COD+'-'+SL1TRB->A6_NREDUZ
		EndIf
		SL1TRB->(dbSkip())
	EndDo
	Aadd(aTotal,{cCodigo, Round(nTotal/nCont,0), cChvAgrup, 0}) // Grava chave anterior e o total pela ultima vez
EndIf

SL1TRB->(DbCloseArea())

//Ordernar do maior para o menor valor 
ASORT(aTotal,,,{ | x,y | x[2] > y[2] } )

//Limitar o numero de registros pelo numero de ranking informado
nTotal := 0
If Len(aTotal) < Len(aSerie)
   nTotal := Len(aTotal)
Else
   nTotal := Len(aSerie)
Endif

For nI:= 1 to nTotal
	aSerie[nI][1] := "Cod:" + AllTrim(aTotal[nI][1])
	aSerie[nI][2] := aTotal[nI][2]
	aSerie[nI][3] := AllTrim(aTotal[nI][3])
	aSerie[nI][4] := aTotal[nI][4]
Next nI  
RestArea(aArea)

Return aSerie

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ProcInd404       ³Autor  ³TOTVS               ³ Data ³ 02/07/13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Retorna os valores que serao impressos pelo painel             ³±±
±±³          ³ Media Atendimento Vendas - PDV                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Prevencao de Perdas - Loja   	                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function ProcInd404()
Local aArea  	:= GetArea()
Local cQuery    := ""  // Texto SQL que é enviado para o comando TCGenQry
Local aTotal    := {}
Local nI        := 0
Local nTotal    := 0 //limitador do numero de registros por ranking
Local nCont		:= 0 // contador de serie
Local cChvAgrup	:= ""
Local cCodigo	:= ""

cQuery := " SELECT SLG.LG_FILIAL,SLG.LG_PDV,SLG.LG_NOME,SL1.L1_EMISSAO,SL1.L1_DOC,SL1.L1_SERIE,SL1.L1_FILIAL,SL1.L1_PDV,SL1.L1_TIMEATE "
cQuery += " FROM " + RetSqlName("SL1") + " SL1 "
cQuery += " INNER JOIN " + RetSqlName("SLW") + " SLW ON SLW.D_E_L_E_T_ = ' ' "
cQuery += " AND SL1.L1_FILIAL = SLW.LW_FILIAL AND SL1.L1_NUMMOV = SLW.LW_NUMMOV AND SL1.L1_PDV = SLW.LW_PDV AND SL1.L1_DOC >= SLW.LW_NUMINI"
cQuery += " AND SL1.L1_EMISSAO >= SLW.LW_DTABERT AND SL1.L1_EMISSAO <= SLW.LW_DTFECHA "
cQuery += " INNER JOIN " + RetSqlName("SLG") + " SLG ON SLG.D_E_L_E_T_ = ' ' AND SLG.LG_FILIAL = SL1.L1_FILIAL "
cQuery += " AND SLG.LG_CODIGO = SLW.LW_ESTACAO AND SLG.LG_PDV = SLW.LW_PDV "
cQuery += " WHERE " + LJ7017QryFil(.F.,"SL1")[2] 								   		  			//Grupo de Filial ou Filial
cQuery += " AND SLW.LW_OPERADO BETWEEN '"	+ mv_par05 			+"' AND '"	+ mv_par06 +"' "   		//Caixa
cQuery += " AND SL1.L1_PDV BETWEEN '"		+ mv_par07 			+"' AND '"	+ mv_par08 +"' "   		//PDV
cQuery += " AND SL1.L1_EMISSAO BETWEEN '"	+ DToS(mv_par09) 	+"' AND '"	+ DToS(mv_par10) +"' " 	//Data
cQuery += " AND SL1.L1_IMPRIME <> ' ' AND SL1.L1_STATUS = ' '	AND SL1.D_E_L_E_T_ = ' ' "
cQuery += " GROUP BY SLG.LG_FILIAL,SLG.LG_PDV,SLG.LG_NOME,SL1.L1_EMISSAO,SL1.L1_DOC,SL1.L1_SERIE,SL1.L1_FILIAL,SL1.L1_PDV,SL1.L1_TIMEATE "
cQuery += " ORDER BY SLG.LG_FILIAL,SLG.LG_PDV,SLG.LG_NOME"

cQuery := ChangeQuery(cQuery)
DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), 'SL1TRB', .F., .T.)
SL1TRB->(DBGoTop())

If SL1TRB->(!Eof())
	nTotal := 0
	nCont := 0
	cChvAgrup := AllTrim(SL1TRB->LG_FILIAL)+'-'+AllTrim(SL1TRB->LG_PDV)+'-'+AllTrim(SL1TRB->LG_NOME)
	While SL1TRB->(!Eof())
		If AllTrim(SL1TRB->LG_FILIAL)+'-'+AllTrim(SL1TRB->LG_PDV)+'-'+AllTrim(SL1TRB->LG_NOME) == cChvAgrup
			nTotal += SL1TRB->L1_TIMEATE
			nCont++
			cCodigo := AllTrim(SL1TRB->LG_FILIAL)+'-'+AllTrim(SL1TRB->LG_PDV)
		Else
			Aadd(aTotal,{cCodigo, Round(nTotal/nCont,0), cChvAgrup, 0}) // Grava chave anterior e o total
			nTotal := SL1TRB->L1_TIMEATE
			nCont := 1
			cCodigo := AllTrim(SL1TRB->LG_FILIAL)+'-'+AllTrim(SL1TRB->LG_PDV)
			cChvAgrup := AllTrim(SL1TRB->LG_FILIAL)+'-'+AllTrim(SL1TRB->LG_PDV)+'-'+AllTrim(SL1TRB->LG_NOME)
		EndIf
		SL1TRB->(dbSkip())
	EndDo
	Aadd(aTotal,{cCodigo, Round(nTotal/nCont,0), cChvAgrup, 0}) // Grava chave anterior e o total pela ultima vez
EndIf

SL1TRB->(DbCloseArea())

//Ordernar do maior para o menor valor 
ASORT(aTotal,,,{ | x,y | x[2] > y[2] } )

//Limitar o numero de registros pelo numero de ranking informado
If Len(aTotal) < Len(aSerie)
   nTotal := Len(aTotal)
Else
   nTotal := Len(aSerie)
Endif

For nI:= 1 to nTotal
	aSerie[nI][1] := "Cod:" + AllTrim(aTotal[nI][1])
	aSerie[nI][2] := aTotal[nI][2]
	aSerie[nI][3] := AllTrim(aTotal[nI][3])
	aSerie[nI][4] := aTotal[nI][4]
Next nI  
RestArea(aArea)

Return aSerie


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ProcInd405       ³Autor  ³TOTVS               ³ Data ³ 02/07/13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Retorna os valores que serao impressos pelo painel             ³±±
±±³          ³ Média Registro Item - Grupo de Filial                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Prevencao de Perdas - Loja   	                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function ProcInd405()
Local aArea  	:= GetArea()
Local cQuery    := ""  // Texto SQL que é enviado para o comando TCGenQry
Local aTotal    := {}
Local nI        := 0
Local nTotal    := 0 //limitador do numero de registros por ranking
Local nCont		:= 0 // contador de serie
Local cChvAgrup	:= ""
Local cCodigo	:= ""

cQuery := " SELECT SAU.AU_CODGRUP,SAU.AU_DESCRI,SLW.LW_OPERADO,SL1.L1_EMISSAO,SL1.L1_DOC,SL1.L1_SERIE,SL1.L1_FILIAL,SL1.L1_PDV,SL1.L1_TIMEITE "
cQuery += " FROM " + RetSqlName("SL1") + " SL1 "
cQuery += " INNER JOIN " + RetSqlName("SLW") + " SLW ON SLW.D_E_L_E_T_ = ' ' "
cQuery += " AND SL1.L1_FILIAL = SLW.LW_FILIAL AND SL1.L1_NUMMOV = SLW.LW_NUMMOV AND SL1.L1_PDV = SLW.LW_PDV AND SL1.L1_DOC >= SLW.LW_NUMINI"
cQuery += " AND SL1.L1_EMISSAO >= SLW.LW_DTABERT AND SL1.L1_EMISSAO <= SLW.LW_DTFECHA "
cQuery += " INNER JOIN " + RetSqlName("SAU") + " SAU "
cQuery += " ON SAU.D_E_L_E_T_ = ' ' AND SAU.AU_CODFIL = SL1.L1_FILIAL "
cQuery += " WHERE " + LJ7017QryFil(.F.,"SL1")[2] 								   		  			//Grupo de Filial ou Filial
cQuery += " AND SLW.LW_OPERADO BETWEEN '"	+ mv_par05 			+"' AND '"	+ mv_par06 +"' "   		//Caixa
cQuery += " AND SL1.L1_PDV BETWEEN '"		+ mv_par07 			+"' AND '"	+ mv_par08 +"' "   		//PDV
cQuery += " AND SL1.L1_EMISSAO BETWEEN '"	+ DToS(mv_par09) 	+"' AND '"	+ DToS(mv_par10) +"' " 	//Data
cQuery += " AND SL1.L1_IMPRIME <> ' ' AND SL1.L1_STATUS = ' '	AND SL1.D_E_L_E_T_ = ' ' "
cQuery += " GROUP BY SAU.AU_CODGRUP,SAU.AU_DESCRI,SLW.LW_OPERADO,SL1.L1_EMISSAO,SL1.L1_DOC,SL1.L1_SERIE,SL1.L1_FILIAL,SL1.L1_PDV,SL1.L1_TIMEITE "
cQuery += " ORDER BY SAU.AU_CODGRUP, SL1.L1_FILIAL, SL1.L1_DOC"

cQuery := ChangeQuery(cQuery)
DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), 'SL1TRB', .F., .T.)
SL1TRB->(DBGoTop())

If SL1TRB->(!Eof())
	nTotal := 0
	nCont := 0
	cChvAgrup := SL1TRB->AU_CODGRUP+'-'+AllTrim(SL1TRB->AU_DESCRI)
	While SL1TRB->(!Eof())
		If SL1TRB->AU_CODGRUP+'-'+AllTrim(SL1TRB->AU_DESCRI) == cChvAgrup
			nTotal += SL1TRB->L1_TIMEITE
			nCont++
			cCodigo := SL1TRB->AU_CODGRUP
		Else
			Aadd(aTotal,{cCodigo, Round(nTotal/nCont,0), cChvAgrup, 0}) // Grava chave anterior e o total
			nTotal := SL1TRB->L1_TIMEITE
			nCont := 1
			cCodigo := SL1TRB->AU_CODGRUP
			cChvAgrup := SL1TRB->AU_CODGRUP+'-'+AllTrim(SL1TRB->AU_DESCRI)
		EndIf
		SL1TRB->(dbSkip())
	EndDo
	Aadd(aTotal,{cCodigo, Round(nTotal/nCont,0), cChvAgrup, 0}) // Grava chave anterior e o total pela ultima vez
EndIf

SL1TRB->(DbCloseArea())

//Ordernar do maior para o menor valor 
ASORT(aTotal,,,{ | x,y | x[2] > y[2] } )

//Limitar o numero de registros pelo numero de ranking informado
nTotal := 0
If Len(aTotal) < Len(aSerie)
   nTotal := Len(aTotal)
Else
   nTotal := Len(aSerie)
Endif

For nI:= 1 to nTotal
	aSerie[nI][1] := "Cod:" + AllTrim(aTotal[nI][1])
	aSerie[nI][2] := aTotal[nI][2]
	aSerie[nI][3] := AllTrim(aTotal[nI][3])
	aSerie[nI][4] := aTotal[nI][4]
Next nI  
RestArea(aArea)

Return aSerie

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ProcInd406       ³Autor  ³TOTVS               ³ Data ³ 02/07/13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Retorna os valores que serao impressos pelo painel             ³±±
±±³          ³ Média Registro Item - Filial                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Prevencao de Perdas - Loja   	                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function ProcInd406()
Local aArea  	:= GetArea()
Local cQuery    := ""  // Texto SQL que é enviado para o comando TCGenQry
Local aTotal    := {}
Local nI        := 0
Local nTotal    := 0 //limitador do numero de registros por ranking
Local nCont		:= 0 // contador de serie
Local cChvAgrup	:= ""
Local nPos		:= 1
Local aFiliais 	:= Lj7017Fil()// Recebera o retorna dos nomes das Filiais	

cQuery := " SELECT SLW.LW_OPERADO,SL1.L1_EMISSAO,SL1.L1_DOC,SL1.L1_SERIE,SL1.L1_FILIAL,SL1.L1_PDV,SL1.L1_TIMEITE "
cQuery += " FROM " + RetSqlName("SL1") + " SL1 "
cQuery += " INNER JOIN " + RetSqlName("SLW") + " SLW ON SLW.D_E_L_E_T_ = ' ' "
cQuery += " AND SL1.L1_FILIAL = SLW.LW_FILIAL AND SL1.L1_NUMMOV = SLW.LW_NUMMOV AND SL1.L1_PDV = SLW.LW_PDV AND SL1.L1_DOC >= SLW.LW_NUMINI"
cQuery += " AND SL1.L1_EMISSAO >= SLW.LW_DTABERT AND SL1.L1_EMISSAO <= SLW.LW_DTFECHA "
cQuery += " WHERE " + LJ7017QryFil(.F.,"SL1")[2] 								   		  			//Grupo de Filial ou Filial
cQuery += " AND SLW.LW_OPERADO BETWEEN '"	+ mv_par05 			+"' AND '"	+ mv_par06 +"' "   		//Caixa
cQuery += " AND SL1.L1_PDV BETWEEN '"		+ mv_par07 			+"' AND '"	+ mv_par08 +"' "   		//PDV
cQuery += " AND SL1.L1_EMISSAO BETWEEN '"	+ DToS(mv_par09) 	+"' AND '"	+ DToS(mv_par10) +"' " 	//Data
cQuery += " AND SL1.L1_IMPRIME <> ' ' AND SL1.L1_STATUS = ' '	AND SL1.D_E_L_E_T_ = ' ' "
cQuery += " GROUP BY SLW.LW_OPERADO,SL1.L1_EMISSAO,SL1.L1_DOC,SL1.L1_SERIE,SL1.L1_FILIAL,SL1.L1_PDV,SL1.L1_TIMEITE "
cQuery += " ORDER BY SL1.L1_FILIAL, SL1.L1_DOC"

cQuery := ChangeQuery(cQuery)
DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), 'SL1TRB', .F., .T.)
SL1TRB->(DBGoTop())

If SL1TRB->(!Eof())
	nTotal := 0
	nCont := 0
	cChvAgrup := SL1TRB->L1_FILIAL
	While SL1TRB->(!Eof())
		If SL1TRB->L1_FILIAL == cChvAgrup
			nTotal += SL1TRB->L1_TIMEITE
			nCont++
		Else
			nPos := aScan( aFiliais, {|xVar| AllTrim(xVar[1]) == AllTrim(cChvAgrup)})
			Aadd(aTotal,{cChvAgrup, Round(nTotal/nCont,0), cChvAgrup+IIF(nPos>0,"-"+aFiliais[nPos][2],""), 0}) // Grava chave anterior e o total
			nTotal := SL1TRB->L1_TIMEITE
			nCont := 1
			cChvAgrup := SL1TRB->L1_FILIAL
		EndIf
		SL1TRB->(dbSkip())
	EndDo
	nPos := aScan( aFiliais, {|xVar| AllTrim(xVar[1]) == AllTrim(cChvAgrup)})
	Aadd(aTotal,{cChvAgrup, Round(nTotal/nCont,0), cChvAgrup+IIF(nPos>0,"-"+aFiliais[nPos][2],""), 0}) // Grava chave anterior e o total
EndIf

SL1TRB->(DbCloseArea())

//Ordernar do maior para o menor valor 
ASORT(aTotal,,,{ | x,y | x[2] > y[2] } )

//Limitar o numero de registros pelo numero de ranking informado
nTotal := 0
If Len(aTotal) < Len(aSerie)
   nTotal := Len(aTotal)
Else
   nTotal := Len(aSerie)
Endif

For nI:= 1 to nTotal
	aSerie[nI][1] := "Cod:" + AllTrim(aTotal[nI][1])
	aSerie[nI][2] := aTotal[nI][2]
	aSerie[nI][3] := AllTrim(aTotal[nI][3])
	aSerie[nI][4] := aTotal[nI][4]
Next nI  
RestArea(aArea)

Return aSerie

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ProcInd407       ³Autor  ³TOTVS               ³ Data ³ 02/07/13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Retorna os valores que serao impressos pelo painel             ³±±
±±³          ³ Média Registro Item - Caixa                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Prevencao de Perdas - Loja   	                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function ProcInd407()
Local aArea  	:= GetArea()
Local cQuery    := ""  // Texto SQL que é enviado para o comando TCGenQry
Local aTotal    := {}
Local nI        := 0
Local nTotal    := 0 //limitador do numero de registros por ranking
Local nCont		:= 0 // contador de serie
Local cChvAgrup	:= ""
Local cCodigo	:= ""

cQuery := " SELECT SA6.A6_COD,SA6.A6_NREDUZ,SL1.L1_EMISSAO,SL1.L1_DOC,SL1.L1_SERIE,SL1.L1_FILIAL,SL1.L1_PDV,SL1.L1_TIMEITE "
cQuery += " FROM " + RetSqlName("SL1") + " SL1 "
cQuery += " INNER JOIN " + RetSqlName("SLW") + " SLW ON SLW.D_E_L_E_T_ = ' ' "
cQuery += " AND SL1.L1_FILIAL = SLW.LW_FILIAL AND SL1.L1_NUMMOV = SLW.LW_NUMMOV AND SL1.L1_PDV = SLW.LW_PDV AND SL1.L1_DOC >= SLW.LW_NUMINI"
cQuery += " AND SL1.L1_EMISSAO >= SLW.LW_DTABERT AND SL1.L1_EMISSAO <= SLW.LW_DTFECHA "
cQuery += " INNER JOIN " + RetSqlName("SA6") + " SA6 "
cQuery += " ON SA6.D_E_L_E_T_ = ' ' AND SA6.A6_COD = SLW.LW_OPERADO "
cQuery += " WHERE " + LJ7017QryFil(.F.,"SL1")[2] 								   		  			//Grupo de Filial ou Filial
cQuery += " AND SLW.LW_OPERADO BETWEEN '"	+ mv_par05 			+"' AND '"	+ mv_par06 +"' "   		//Caixa
cQuery += " AND SL1.L1_PDV BETWEEN '"		+ mv_par07 			+"' AND '"	+ mv_par08 +"' "   		//PDV
cQuery += " AND SL1.L1_EMISSAO BETWEEN '"	+ DToS(mv_par09) 	+"' AND '"	+ DToS(mv_par10) +"' " 	//Data
cQuery += " AND SL1.L1_IMPRIME <> ' ' AND SL1.L1_STATUS = ' '	AND SL1.D_E_L_E_T_ = ' ' "
cQuery += " GROUP BY SA6.A6_COD,SA6.A6_NREDUZ,SL1.L1_EMISSAO,SL1.L1_DOC,SL1.L1_SERIE,SL1.L1_FILIAL,SL1.L1_PDV,SL1.L1_TIMEITE "
cQuery += " ORDER BY SA6.A6_COD,SA6.A6_NREDUZ,SL1.L1_FILIAL,SL1.L1_DOC"

cQuery := ChangeQuery(cQuery)
DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), 'SL1TRB', .F., .T.)
SL1TRB->(DBGoTop())

If SL1TRB->(!Eof())
	nTotal := 0
	nCont := 0
	cChvAgrup := SL1TRB->A6_COD+'-'+SL1TRB->A6_NREDUZ
	While SL1TRB->(!Eof())
		If SL1TRB->A6_COD+'-'+SL1TRB->A6_NREDUZ == cChvAgrup
			nTotal += SL1TRB->L1_TIMEITE
			nCont++
			cCodigo := SL1TRB->A6_COD
		Else
			Aadd(aTotal,{cCodigo, Round(nTotal/nCont,0), cChvAgrup, 0}) // Grava chave anterior e o total
			nTotal := SL1TRB->L1_TIMEITE
			nCont := 1
			cCodigo := SL1TRB->A6_COD
			cChvAgrup := SL1TRB->A6_COD+'-'+SL1TRB->A6_NREDUZ
		EndIf
		SL1TRB->(dbSkip())
	EndDo
	Aadd(aTotal,{cCodigo, Round(nTotal/nCont,0), cChvAgrup, 0}) // Grava chave anterior e o total pela ultima vez
EndIf

SL1TRB->(DbCloseArea())

//Ordernar do maior para o menor valor 
ASORT(aTotal,,,{ | x,y | x[2] > y[2] } )

//Limitar o numero de registros pelo numero de ranking informado
nTotal := 0
If Len(aTotal) < Len(aSerie)
   nTotal := Len(aTotal)
Else
   nTotal := Len(aSerie)
Endif

For nI:= 1 to nTotal
	aSerie[nI][1] := "Cod:" + AllTrim(aTotal[nI][1])
	aSerie[nI][2] := aTotal[nI][2]
	aSerie[nI][3] := AllTrim(aTotal[nI][3])
	aSerie[nI][4] := aTotal[nI][4]
Next nI  
RestArea(aArea)

Return aSerie

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ProcInd408       ³Autor  ³TOTVS               ³ Data ³ 02/07/13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Retorna os valores que serao impressos pelo painel             ³±±
±±³          ³ Média Registro Item - PDV                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Prevencao de Perdas - Loja   	                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function ProcInd408()
Local aArea  	:= GetArea()
Local cQuery    := ""  // Texto SQL que é enviado para o comando TCGenQry
Local aTotal    := {}
Local nI        := 0
Local nTotal    := 0 //limitador do numero de registros por ranking
Local nCont		:= 0 // contador de serie
Local cChvAgrup	:= ""
Local cCodigo	:= ""

cQuery := " SELECT SLG.LG_FILIAL,SLG.LG_PDV,SLG.LG_NOME,SL1.L1_EMISSAO,SL1.L1_DOC,SL1.L1_SERIE,SL1.L1_FILIAL,SL1.L1_PDV,SL1.L1_TIMEITE "
cQuery += " FROM " + RetSqlName("SL1") + " SL1 "
cQuery += " INNER JOIN " + RetSqlName("SLW") + " SLW ON SLW.D_E_L_E_T_ = ' ' "
cQuery += " AND SL1.L1_FILIAL = SLW.LW_FILIAL AND SL1.L1_NUMMOV = SLW.LW_NUMMOV AND SL1.L1_PDV = SLW.LW_PDV AND SL1.L1_DOC >= SLW.LW_NUMINI"
cQuery += " AND SL1.L1_EMISSAO >= SLW.LW_DTABERT AND SL1.L1_EMISSAO <= SLW.LW_DTFECHA "
cQuery += " INNER JOIN " + RetSqlName("SLG") + " SLG ON SLG.D_E_L_E_T_ = ' ' AND SLG.LG_FILIAL = SL1.L1_FILIAL "
cQuery += " AND SLG.LG_CODIGO = SLW.LW_ESTACAO AND SLG.LG_PDV = SLW.LW_PDV "
cQuery += " WHERE " + LJ7017QryFil(.F.,"SL1")[2] 								   		  			//Grupo de Filial ou Filial
cQuery += " AND SLW.LW_OPERADO BETWEEN '"	+ mv_par05 			+"' AND '"	+ mv_par06 +"' "   		//Caixa
cQuery += " AND SL1.L1_PDV BETWEEN '"		+ mv_par07 			+"' AND '"	+ mv_par08 +"' "   		//PDV
cQuery += " AND SL1.L1_EMISSAO BETWEEN '"	+ DToS(mv_par09) 	+"' AND '"	+ DToS(mv_par10) +"' " 	//Data
cQuery += " AND SL1.L1_IMPRIME <> ' ' AND SL1.L1_STATUS = ' '	AND SL1.D_E_L_E_T_ = ' ' "
cQuery += " GROUP BY SLG.LG_FILIAL,SLG.LG_PDV,SLG.LG_NOME,SL1.L1_EMISSAO,SL1.L1_DOC,SL1.L1_SERIE,SL1.L1_FILIAL,SL1.L1_PDV,SL1.L1_TIMEITE "
cQuery += " ORDER BY SLG.LG_FILIAL,SLG.LG_PDV,SLG.LG_NOME"

cQuery := ChangeQuery(cQuery)
DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), 'SL1TRB', .F., .T.)
SL1TRB->(DBGoTop())

If SL1TRB->(!Eof())
	nTotal := 0
	nCont := 0
	cChvAgrup := AllTrim(SL1TRB->LG_FILIAL)+'-'+AllTrim(SL1TRB->LG_PDV)+'-'+AllTrim(SL1TRB->LG_NOME)
	While SL1TRB->(!Eof())
		If AllTrim(SL1TRB->LG_FILIAL)+'-'+AllTrim(SL1TRB->LG_PDV)+'-'+AllTrim(SL1TRB->LG_NOME) == cChvAgrup
			nTotal += SL1TRB->L1_TIMEITE
			nCont++
			cCodigo := AllTrim(SL1TRB->LG_FILIAL)+'-'+AllTrim(SL1TRB->LG_PDV)
		Else
			Aadd(aTotal,{cCodigo, Round(nTotal/nCont,0), cChvAgrup, 0}) // Grava chave anterior e o total
			nTotal := SL1TRB->L1_TIMEITE
			nCont := 1
			cCodigo := AllTrim(SL1TRB->LG_FILIAL)+'-'+AllTrim(SL1TRB->LG_PDV)
			cChvAgrup := AllTrim(SL1TRB->LG_FILIAL)+'-'+AllTrim(SL1TRB->LG_PDV)+'-'+AllTrim(SL1TRB->LG_NOME)
		EndIf
		SL1TRB->(dbSkip())
	EndDo
	Aadd(aTotal,{cCodigo, Round(nTotal/nCont,0), cChvAgrup, 0}) // Grava chave anterior e o total pela ultima vez
EndIf

SL1TRB->(DbCloseArea())

//Ordernar do maior para o menor valor 
ASORT(aTotal,,,{ | x,y | x[2] > y[2] } )

//Limitar o numero de registros pelo numero de ranking informado
If Len(aTotal) < Len(aSerie)
   nTotal := Len(aTotal)
Else
   nTotal := Len(aSerie)
Endif

For nI:= 1 to nTotal
	aSerie[nI][1] := "Cod:" + AllTrim(aTotal[nI][1])
	aSerie[nI][2] := aTotal[nI][2]
	aSerie[nI][3] := AllTrim(aTotal[nI][3])
	aSerie[nI][4] := aTotal[nI][4]
Next nI  
RestArea(aArea)

Return aSerie

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ LJ7017QryFil    ³Autor  ³TOTVS               ³ Data ³ 02/07/13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Retorna dados cadastrados no Grupo de Filiais (SAU)            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Prevencao de Perdas - Loja   	                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function LJ7017QryFil(lVerifGrp,cAlias)
Local cQuery    := ""  // Texto SQL que é enviado para o comando TCGenQry
Local nX 		:= 0 		// Contador auxiliar
Local cQueryFil := ""  		// Retorno do complemento de query para filiais
Local aGrpFil	:= {}		// Retorno dos grupos de filiais
Local lAchou	:= .F.
Local aFilUsu   := {}
Local cFilUsu   := ""
Local cCompFil	:= ""
Local nPos 		:= 1

Default lVerifGrp 	:= .F.
Default cAlias		:= ""

//Consulta se a empresa trabalha com Grupo de Filial
If lVerifGrp .AND. AliasInDic("SAU")
	
	//1 selecionar as filiais pertencentes ao filtro dos grupos
	cQuery :=	" SELECT AU_CODFIL, AU_CODGRUP " 				+;
				" FROM 	" + RetSqlName("SAU")					+;
				" WHERE  AU_CODGRUP >= '" 	+ mv_par01 + "' " 	+;
				" AND AU_CODGRUP <= '" 		+ mv_par02 + "' " 	+;
				" AND D_E_L_E_T_ = ' ' " 						+;
				" GROUP BY AU_CODGRUP,AU_CODFIL "
	
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
			cQueryFil += "BETWEEN '" + mv_par03 + "' AND '" + mv_par04 + "' "
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
±±³Fun‡…o    ³ Lj7017Fil       ³Autor  ³TOTVS               ³ Data ³ 02/07/13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Retorna o nome da Filial	                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Prevencao de Perdas - Loja   	                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function Lj7017Fil()
Local aFiliais  := {} //Array que recebera os nomes das filiais
Local aAreaSM0  := SM0->(GetArea()) //Area atual

aFiliais := LJXGetFil()

RestArea(aAreaSM0)

Return aFiliais


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³LOJA7017  ºAutor  ³Microsiga           º Data ³  07/19/13   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Cria a barra de progresso                                  º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Prevencao de Perdas                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function TMeter(oExplorer,aFuncPanels )
Local oMeter	// Objeto com a barra de progressao
DEFINE FONT oFont NAME "Arial" BOLD SIZE 9,14

DEFINE DIALOG oDlg TITLE STR0085 FROM 180,180 TO 250,700 PIXEL//"Prevenção de Perdas - Consulta indicadores"

oPnlCentro := TPanel():New(01,01,,oDlg,,,,,,5,15,.F.,.F.)

oPnlCentro:Align := CONTROL_ALIGN_ALLCLIENT

@ 05,20 SAY STR0086	OF oPnlCentro PIXEL SIZE 150,9 FONT oFont COLOR CLR_BLUE  //"Processando.... Aguarde!"
oMeter := TMeter():New(15,10,,30,oPnlCentro,240,16,,.T.,,,.F.,,,,,)

oDlg:bStart := {|| CursorWait(),LJ7017Proc(oMeter,oExplorer ,aFuncPanels),CursorArrow(),oDlg:End()}

ACTIVATE DIALOG oDlg CENTERED

Return Nil



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³LOJA7017  ºAutor  ³Microsiga           º Data ³  07/19/13   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³  Processa as visões dos indicadores                        º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Prevencao de perdas                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function LJ7017Proc(oMeter,oExplorer ,aFuncPanels)
LocaL nReg   := 0
Local nI     := 0
Local nTotal := 0 //limitador do numero de registros por ranking

oMeter:SET(0)  
aFuncPanels := {}
aRelatorio	:= {}
nPanel		:= 0

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Função que monta todos os paineis³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
MsgRun(STR0087,STR0088,{||LJ7017MontaPanel(oExplorer ,aFuncPanels)}) //"Selecionando dados...."##"Aguarde!"
nTotal := len(aFuncPanels)
oMeter:SetTotal(nTotal)

aSerieAux := {}

For nI:= 1 to len(aFuncPanels) 
	&(aFuncPanels[nI])
	nReg++
	oMeter:Set(nReg)  
	oMeter:Refresh()
    ProcessMessages()
Next 

oMeter:Free()

Return Nil       

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ fAjustaMsg      ³Autor  ³TOTVS               ³ Data ³ 02/07/13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Retorna mensagem com resumo dos segundos em formato de minutos ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Prevencao de Perdas - Loja   	                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function fAjustaMsg(cMensagem1,cMensagem2,cMensagem3,cOpcao,aSerie)
Local nFor	:= 0
Local cMsg	:= "1"
Local cMsgMaster := "cMensagem"+cMsg

If VAL(cOpcao) >= 401 .AND. VAL(cOpcao) <= 408
	&(cMsgMaster) := STR0089 //"RESUMO SEGUNDOS: "

	For nFor := 1 To Len(aSerie)
		If aSerie[nFor][2] <> 0
			&(cMsgMaster) += AllTrim(aSerie[nFor][3]) + "->" + AllTrim( STR(aSerie[nFor][2]) ) + " (" + LJ7017CvHrs("",aSerie[nFor][2]) + ")   -   " 
			If Len(&(cMsgMaster)) >= 160
				&(cMsgMaster) := SUBSTR(&(cMsgMaster),1, LEN(&(cMsgMaster))-7) // Tira o ultimo Traco
				cMsg := ALLTRIM(STR(VAL(cMsg)+1))
				cMsgMaster := "cMensagem"+cMsg
				&(cMsgMaster) := STR0089 //"RESUMO SEGUNDOS: "
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
±±³Fun‡…o    ³ LJ7017CvHrs     ³Autor  ³TOTVS               ³ Data ³ 02/07/13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Converte segundos (inteiro) em um horário (string) e retorna no³±±
±±³          ³ formato HH:MM:SS                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Prevencao de Perdas - Loja   	                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function LJ7017CvHrs(cHoras,nSegundos)
Local cRet := ""

Default cHoras		:= ""
Default nSegundos	:= 0

If nSegundos <> 0
	cRet := StrZero( Int(Mod(nSegundos/3600,24)),2,0 ) +":"+ StrZero( Int(Mod(nSegundos/60,60)),2,0 ) +":"+ StrZero( Int(Mod(nSegundos,60)),2,0 )
ElseIf !EMPTY(cHoras)
	cRet := IIF( LEN(AllTrim(cHoras))==8, AllTrim(cHoras), AllTrim(cHoras)+":00" )
EndIf

Return cRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ LJ7017ToSec     ³Autor  ³TOTVS               ³ Data ³ 02/07/13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Converte um horário (string) em segundos (inteiro).            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Prevencao de Perdas - Loja   	                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function LJ7017ToSec(cTime)
Local nHours   	:= 0  // horas
Local nMinutes 	:= 0  // minutos
Local nSegundos	:= 0  // minutos

// converte de horas e minutos para valores numéricos
If Len(cTime) > 5	
	// formato "HH:MM:SS"
	nHours		:= Val(Substr(cTime, 1, 2))
	nMinutes	:= Val(Substr(cTime, 4, 2))
	nSegundos	:= Val(Substr(cTime, 7, 2))
Else	
	// formato "HH:MM"
	nHours   	:= Val(Substr(cTime, 1, 2))
	nMinutes	:= Val(Substr(cTime, 4, 2))
	nSegundos	:= 0
EndIf
Return (nHours * 3600) + (nMinutes * 60) + (nSegundos)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ L7017VlRotina   ³Autor  ³TOTVS               ³ Data ³ 02/07/13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Valida rotina compatibilizada                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Prevencao de Perdas - Loja   	                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function L7017VlRotina()
Local lRet := .T.

If !AliasInDic("MFL")  // Se existir tabela MFL - Consulta de Preco pelo PDV
	lRet := .F.
EndIf	
If SL1->(FieldPos("L1_TIMEATE") ) <= 0  // Se existir o campo L1_TIMEATE
	lRet := .F.
EndIf

If SL1->(FieldPos("L1_TIMEITE") ) <= 0  // Se existir o campo L1_TIMEITE
	lRet := .F.
EndIf

If MBR->(FieldPos("MBR_PDV") ) <= 0  // Se existir o campo MBR_PDV
	lRet := .F.
EndIf

If !lRet
	MsgInfo(STR0090,STR0091) //"Tabelas e campos essenciais inexistente no dicionario, indica que o update do pacote nao foi aplicado !"#"Aviso"
EndIF

If lRet 
	#IFDEF TOP
		lRet := .T.	
	#ELSE
		lRet := .F.
		MsgStop(STR0107)//"Funcionalidade disponivel somente para TopConnect") 
	#ENDIF 
Endif

Return lRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ L7017ValPerg    ³Autor  ³TOTVS               ³ Data ³ 02/07/13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Valida as perguntas da rotina                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Prevencao de Perdas - Loja   	                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function L7017ValPerg()
Local lRet := .T.

// Valida as Filiais
If lRet .AND. EMPTY(mv_par01) .AND. EMPTY(mv_par02) .AND. EMPTY(mv_par03) .AND. EMPTY(mv_par04)
	MsgInfo(STR0092,STR0091) //"Preencha os parametros das Filiais para visualizar os indicadores !"#"Aviso"
	lRet := .F.
EndIf
// Valida os caixas
If lRet .AND. EMPTY(mv_par05) .AND. EMPTY(mv_par06) .AND. ("3" $ AllTrim(mv_par26) .OR. "4" $ AllTrim(mv_par26))
	MsgInfo(STR0093,STR0091) //"Preencha os parametros dos Caixas para visualizar os indicadores !"#"Aviso"
	lRet := .F.
EndIf
// Valida os PDVs
If lRet .AND. EMPTY(mv_par07) .AND. EMPTY(mv_par08) .AND. ("3" $ AllTrim(mv_par26) .OR. "4" $ AllTrim(mv_par26))
	MsgInfo(STR0094,STR0091) //"Preencha os parametros dos PDVs para visualizar os indicadores !"#"Aviso"
	lRet := .F.
EndIf
// Valida as Datas
If lRet .AND. EMPTY(mv_par09) .AND. EMPTY(mv_par10)
	MsgInfo(STR0038,STR0091) //"Preencha os parametros das Datas para visualizar os indicadores !"#"Aviso"
	lRet := .F.
Else
	If lRet .AND. DToS(mv_par09) > DToS(mv_par10)
		MsgInfo(STR0003,STR0091) //"A Data Inicial não deve ser maior que a Data Final !"#"Aviso"
		lRet := .F.
	EndIf
EndIf
// Valida as Categorias
If lRet .AND. EMPTY(mv_par11) .AND. EMPTY(mv_par12) .AND. EMPTY(mv_par13) .AND. EMPTY(mv_par14) .AND. ("1" $ AllTrim(mv_par26))
	MsgInfo(STR0095,STR0091) //"Preencha os parametros de Categoria e Grupo de produtos para visualizar os indicadores. !"#"Aviso"
	lRet := .F.
EndIf
// Valida o Produto 
If lRet .AND. EMPTY(mv_par15) .AND. EMPTY(mv_par16) .AND. ("1" $ AllTrim(mv_par26) )
	MsgInfo(STR0096,STR0091) //"Preencha os parametros de Produto para visualizar os indicadores !"#"Aviso"
	lRet := .F.
EndIf
// Valida o Armazem 
If lRet .AND. EMPTY(mv_par17) .AND. EMPTY(mv_par18) .AND. ("1" $ AllTrim(mv_par26) )
	MsgInfo(STR0097,STR0091) //"Preencha os parametros de Armazem para visualizar os indicadores !"#"Aviso"
	lRet := .F.
EndIf
// Valida o Motivo 
If lRet .AND. EMPTY(mv_par19) .AND. EMPTY(mv_par20) .AND. ("1" $ AllTrim(mv_par26) )
	MsgInfo(STR0098,STR0091) //"Preencha os parametros de Motivo para visualizar os indicadores !"#"Aviso"
	lRet := .F.
EndIf
// Valida a Origem 
If lRet .AND. EMPTY(mv_par21) .AND. EMPTY(mv_par22) .AND. ("1" $ AllTrim(mv_par26) )
	MsgInfo(STR0099,STR0091) //"Preencha os parametros da Origem para visualizar os indicadores !"#"Aviso"
	lRet := .F.
EndIf
// Valida a Ocorrencia 
If lRet .AND. EMPTY(mv_par23) .AND. EMPTY(mv_par24) .AND. ("1" $ AllTrim(mv_par26) )
	MsgInfo(STR0100,STR0091) //"Preencha os parametros da Ocorrencia para visualizar os indicadores !"#"Aviso"
	lRet := .F.
EndIf
// Valida o Ranking 
If lRet .AND. EMPTY(mv_par25) 
	MsgInfo(STR0101,STR0091) //"Preencha o parametro Ranking para estabelecer a quantidade de itens no gráfico."#"Aviso"
	lRet := .F.
Else
	// Valida a quantidade do Ranking 
	If lRet .AND. mv_par25 > 10 
		MsgInfo(STR0106,STR0091)//"Preencha o parametro Ranking com um valor menor ou igual a 10."#"Aviso"
		lRet := .F.
	Endif	
EndIf

// Valida o Tipo de indicador 
If lRet .AND. EMPTY(mv_par26) 
	MsgInfo(STR0102,STR0091) //"Preencha o parametro Tipo de indicador que será apresentado."#"Aviso"
	lRet := .F.
EndIf

Return lRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ LJValFilial     ³Autor  ³TOTVS               ³ Data ³ 13/08/13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Valida as filiais que o usuario possui acessos                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Prevencao de Perdas - Loja   	                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function LJValFilial()
Local aUsrFil	:= {}
Local aGrupo    := ""
Local nX        := 0
Local nxFil     := 0
Local nInc      := 0
Local aFilUsr   := {}

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
		If (!EMPTY(mv_par03) .Or. !EMPTY(mv_par04)) .AND. !lGPFilial // Se nao for grupo de filial
	   		If aUsrFil[1] == '@' .Or. (Empty(MV_PAR03) .And. (MV_PAR04 $ "Z" .Or. MV_PAR04 $ "z")) //usuario possui todos os acessos
				For nInc := 1 To Len( aUsrFil )
			   		AADD(aFilUsr, "'"+ Right( aUsrFil[nInc],LEN(aUsrFil[nInc])-2 ) +"'")
		    	Next	
			Else
	   			For nInc := 1 To Len( aUsrFil )    
	 	   		 	If (Right(aUsrFil[nInc],7) >= AllTrim(MV_PAR03)) .AND. (Right(aUsrFil[nInc],7) <= AllTrim(MV_PAR04))
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
±±ºPrograma  ³LJAR7017  ºAutor  ³TOTVS               º Data ³  24/07/13   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Relatorio de impressao dos indicadores Prevencao de Perdas  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Prevencao de Perdas                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function LJAR7017(oExplorer,aRelatorio)
Local nI 		:= 0 			//Contador

For nI := 1 To Len(aRelatorio)
	If alltrim(aRelatorio[nI][2]) == alltrim(oExplorer:cGetTree)
		&(aRelatorio[nI][3]) //executa o relatório passado como referencia 
		Exit
	Endif
Next nI

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³LJ7017PrecºAutor  ³TOTVS               º Data ³  24/07/13   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Retorna Preço do Produto                                   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Prevencao de Perdas                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function LJ7017Prec(cProduto)
Local nRetPreco := 0

If lCenVenda
	LjxeValPre(@nRetPreco, cProduto, /*cCliente*/, /*cLoja*/, /*nMoeda*/, /*nQtdade*/ , /*lProdON*/ ) 
Else
	DbSelectArea("SB1")
	SB1->( DbSetOrder(1) )	//B1_FILIAL + B1_COD
	
	If SB1->( DbSeek(xFilial("SB1") + cProduto) )		
		nRetPreco := SB1->B1_PRV1
	EndIf
	
	If nRetPreco == 0
	    nRetPreco := LjGetB0Prv(cProduto)
	EndIf
	
EndIf

Return nRetPreco
