#INCLUDE "MSOBJECT.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "LOJA7011.CH"      

#Define __L4_DATA    01
#Define __L4_FORMA   02
#Define __L4_VALOR   03
#Define __PORTE      04 
#Define __L4_CHEQID  05
#Define __L4_NUMCART 06 
#Define __L4_ADMINIS 07 
#Define __L4_AGENCIA 08
#Define __L4_CONTA   09  
#Define __L4_COMP 	  10
#Define __L4_MOEDA   11
#Define __L4DATA     12 
#Define __L4_DOCTEF  13
#Define __L4_FORMAID 14 
#Define __L4lEstorn  15 
#Define __L4_DATATEF 16
#Define __L4_NSUTEF  17
#Define __L4_DOCCANC 18
#Define __L4_HORCANC 19
#Define __L4_DATCANC 20
#Define __E1_PARCELA 21 
#Define __L4_RECNO	 22 
#Define __L4_TAMANHO 22
#Define USADO CHR(0)+CHR(0)+CHR(1)

Static lTEFPag := .F. 	//pagamento em TEF?
Static oGet2 := nil 	//Get da Janela Pagamentos dos orcamento
Static aLinhasPg := {}  //Pagamentos do orcamento
Static oGetdTRC		:= Nil //Objeto da grid
Static lCenVenda 		:= SuperGetMv("MV_LJCNVDA",,.F.) //Se utiliza cenario de vendas
Static cCodCli		:= Padr(SuperGetMV("MV_CLIPAD",,""),Len(CriaVar("A1_COD",.F.)),'') //Codigo do cliente
Static cLojaCli			:= Padr(SuperGetMV("MV_LOJAPAD"),Len(CriaVar("A1_LOJA",.F.)),'') //Codigo da loja
Static cNomeCliente 	:= Padr('',Len(CriaVar("A1_NOME",.F.)),'') //Nome do cliente
Static cCodVen		:=	SuperGetMV( "MV_VENDPAD" ) 		//Codigo do Vendedor 	
Static cProduto		:= Padr('',Len(CriaVar("B1_COD",.F.)),'') //Codigo do produto
Static cQtde			:= ''	//Quantidade na get
Static nValor			:= 0	//Valor unitario do produto 
Static cDescProd		:= '' //Descricao do produto
Static oProduto		:= Nil	//Objeto do get do codigo do produto
Static oQtde			:= Nil //Objeto do get de quantidade
Static oValor			:= Nil	//Valor unitario do produto
Static oDescProd		:= Nil
Static oListProd		:= Nil
Static oVendedor		:= Nil

Static nPrcTot		:= 0
Static nTotalVenda	:= 0	//Guarda o Total da venda 
Static cUm 	:= ''
Static cTesPad	:= ''

Static aItens 		:= {} 	//Itens da list box
Static aItensTab	:= {}	//Itens que sera repassado para a nota fiscal

Static nItem		:= 0	//Numero do item

Function LOJA7011 ; Return  // "dummy" function - Internal Use

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºClasse    |LJEstFrmVenda    ºAutor  ³Fabiana Cristina    º Data ³  24/11/2010 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Janela para Confirmacao das informacoes da Venda 	                 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³SigaLoja / FrontLoja                                        		 º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Class LJEstFrmVenda  	
   	Data oDlgOrc														//Objeto Dialog do Orcamento												    //Numero da Serie 		   	   			
	Data nOpcX                                                         //Opcao da Operacao
	Data oEstVenda                                                     //Objeto LjClEstVen
	Data lProssegue                                                    //Prossegue execucao da função
	Data aHeaderIt                                                     //Header dos Itens
	Data aColsIt                                                       //Colunas dos Itens 
	Data aHeaderPg                                                     //Header dos Pagamentos
	Data aColsPg                                                       //Itens dos Pagamentos
	Data nPosEst                                                       //Posicao da coluna estornado
	Data lIsTroca													//E central de PDV 
	Method New()								                       //colunas dos pagamentos
	Method Show()													   //Posicao do Pagamento estornado
	Method Confirma()                                                  //Mostra a janela
	Method CarregaItens()								               //Carrega os Itens do Browse
	Method CarregaPagto()                                              //Carrega os Pagamentos do Browse 
	Method ValidaCliente()                                             //Valida o cliente informado para estorno. 
	Method ShowTroca()												//tela para rotina de troca 
EndClass

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºMetodo    ³New   	       ºAutor  ³Vendas Clientes     º Data ³  24/11/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Metodo construtor da classe LJEstFrmVenda.  			    	     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³SigaLoja / FrontLoja                                        		 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³EXPO1 (1 - oEstVenda) - Objeto do tipo LjClEstVen            		 º±±
±±ºParametros³EXPO2 (2 - nOpcX) - Opcao selecionada                     		 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºRetorno   ³Objeto														     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Method New(oEstVenda, nOpcX, lTroca) Class LJEstFrmVenda
 
Default lTroca := .F.
   
    Self:oEstVenda  := oEstVenda                                                      //Objeto Estorno
    Self:nOpcX      := nOpcX
    Self:lProssegue := .F.
    Self:oDlgOrc 	:= nil														//Objeto Dialog do Orcamento
    Self:nPosEst    := 0
    Self:aHeaderIt  := {}                                                      //Header dos Itens
	Self:aColsIt    := {}
    Self:aHeaderPg	:= {}
    Self:aColsPg	:= {}                                                             
    Self:lIsTroca := lTroca                                                           
    
Return Self

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºMetodo    ³Show  	       ºAutor  ³Vendas Clientes     º Data ³ 24/11/2010  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Responsavel em exibir a tela.							    	     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³SigaLoja / FrontLoja                                        		 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³																	 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºRetorno   ³String														     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Method Show() Class LJEstFrmVenda
	

Local oDlg          := nil                              //Janela 
Local oObj			:= Self                             //Objeto da janela
Local oGet			:= nil                              //Get da Janela Itens do orcamento
Local lCliPadr      := .T.                              //Indica que a venda foi realizada para o cliente padrao. 
Local cCliente      := Space(TamSX3("A1_COD")[1])       //Cliente para o estorno.
Local cLoja         := Space(TamSx3("A1_LOJA")[1])      //Loja para o estorno.

Local aObjects		:= {}
Local aInfo			:= {}
Local aPosObj		:= {}
Local aSize			:= MsAdvSize()
Local aRotinBK      := {}


	Self:CarregaItens()   
	Self:CarregaPagtos()       
	lTEFPag := !Empty(Self:oEstVenda:cOrc_DocTEF) 
	lCliPadr:= Self:oEstVenda:lCliPad
	cCliente:= Self:oEstVenda:cOrc_Cli
	cLoja   := Self:oEstVenda:cOrc_Loja

If lCliPadr
	aRotinBK	:= aClone(aRotina)  // Faço o back-up do aRotina para voltar o valor novamente 
	aRotina     := Nil	
EndIf	

	aLinhasPg := aClone(Self:aColsPg)   
	
   	Self:nPosEst := aScan(Self:aHeaderPg, {|c| AllTrim(c[2]) == "L4lEstorn"})
   	
   	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Calcula as posicoes da tela		  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ                                 	 
	aObjects := {}
	AADD(aObjects,{100,050,.T.,.T.})
	AADD(aObjects,{200,200,.T.,.T.})
	AADD(aObjects,{200,200,.T.,.T.})
	AADD(aObjects,{100,100,.T.,.T.})

	aInfo 	:= {aSize[1],aSize[2],aSize[3],aSize[4],3,3}
	aPosObj := MsObjSize(aInfo,aObjects,.T.)  

	DEFINE MSDIALOG oDlg TITLE STR0003 From aSize[1],aSize[1] To aSize[6],aSize[5] of oMainWnd PIXEL  //Estornar
	
		@ aPosObj[1,1],aPosObj[1,2] TO aPosObj[1,3],aPosObj[1,4] OF oDlg PIXEL
		
		@1.4,01 Say STR0004														// Orcamento
		@1.4, 05 MSGet Self:oEstVenda:cOrcamento When .F. SIZE 36, 07
	
		@1.4,10 Say STR0005														//Documento 
		@1.4,14 MSGet Self:oEstVenda:cOrc_Cupom When .F.  SIZE 65, 07
	
		@1.4,23 Say STR0006													//Serie: 
		@1.4,25 MSGet Self:oEstVenda:cSerie When .F. SIZE 15, 07
		
		@1.4,29 Say STR0007														// PDV:
		@1.4,31 MSGet Self:oEstVenda:cOrc_Pdv When .F. SIZE 18, 7

		@1.4,33.5 Say STR0008													//Operador: 
		@1.4,37 MSGet Self:oEstVenda:cOrc_Opera When .F. SIZE 36, 7
		
		oGet := MSNewGetDados():New(aPosObj[2,1],aPosObj[2,2],aPosObj[2,3],aPosObj[2,4],self:nOpcx ,,,,,,,,,,oDlg,Self:aHeaderIt,Self:aColsIt) 
		
		oGet2 := MSNewGetDados():New(aPosObj[3,1],aPosObj[3,2],aPosObj[3,3],aPosObj[3,4],self:nOpcx ,IIF(!Self:oEstVenda:lOrc_MovFe , {|| Lj600VlPr(lTEFPag, aLinhasPg)}, {|| .t.}),"AlwaysTrue",,{"L4lEstorn","PORTE"},,Len(Self:aColsPg),,,,oDlg,Self:aHeaderPg,Self:aColsPg)
		
		oGet2:lInsert := .F.
		oGet2:lDelete := .F.
		
		If Self:nOpcx = 4 .and. !Self:oEstVenda:lOrc_MovFe 
			oGet2:lUpdate := .T.
		Else
			oGet2:lUpdate := .F.
		EndIf
			
		@ aPosObj[4,1],aPosObj[4,2] TO aPosObj[4,3],aPosObj[4,4] OF oDlg PIXEL
	
		@ aPosObj[4,1]+5, 008 SAY xPadL( STR0009, 36 )		 SIZE 36, 7		OF oDlg PIXEL	//Seu Pedido: 
		@ aPosObj[4,1]+5, 038 MSGET Self:oEstVenda:cOrc_PedCli  When .F.	 SIZE 30, 08	OF oDlg PIXEL
		@ aPosObj[4,1]+17, 008 SAY xPadL( STR0010, 24 )		 SIZE 30, 7		OF oDlg PIXEL	// Cliente:
		@ aPosObj[4,1]+29, 008 SAY xPadL( STR0029, 31 )		 SIZE 31, 7		OF oDlg PIXEL	// Loja:
		
		If lCliPadr  //Trata cliente padrao.     			
			@ aPosObj[4,1]+17, 038 MSGET cCliente SIZE 85,08 Picture "@!" F3 "SA1" OF oDlg PIXEL 
		   	@ aPosObj[4,1]+29, 038 MSGET cLoja 	  SIZE 30, 08 OF oDlg PIXEL	
		Else
			@ aPosObj[4,1]+17, 038 MSGET cCliente When .F. SIZE 85, 08	OF oDlg PIXEL
		  	@ aPosObj[4,1]+29, 038 MSGET cLoja    When .F. SIZE 30, 08	OF oDlg PIXEL
		EndIf 
			 			 	
		@ aPosObj[4,1]+29, 068 SAY xPadL( STR0011, 31 )		 SIZE 31, 7		OF oDlg PIXEL	//Vendedor: 
		@ aPosObj[4,1]+29, 093 MSGET Self:oEstVenda:cOrc_Ven  When .F.	 SIZE 30, 08	OF oDlg PIXEL
	
		@ aPosObj[4,1]+5, 130 SAY xPadL( STR0012, 66 ) SIZE 66, 7 OF oDlg PIXEL	// Total de Mercadorias:
		@ aPosObj[4,1]+17, 130 SAY xPadL( STR0013, 36 ) SIZE 36, 7 OF oDlg PIXEL	//Desconto: 
	
		If cPaisLoc == "BRA"
			@ aPosObj[4,1]+17, 185 MSGET Self:oEstVenda:nOrc_Desc When .F. Picture "@E 999,999.99" SIZE 46, 08 OF oDlg PIXEL
		Else
			@ aPosObj[4,1]+17, 185 MSGET Self:oEstVenda:nOrc_Desc When .F. Picture PesqPict("SL1","L1_DESCONT") SIZE 50, 08 OF oDlg PIXEL
		EndIf
	
		If cPaisLoc == "BRA"
		
			@ aPosObj[4,1]+5, 240 SAY xPadL(  STR0014, 25 ) SIZE 25, 7 OF oDlg PIXEL	//L¡quido:
			@ aPosObj[4,1]+17, 240 SAY xPadL( STR0015, 28 ) SIZE 25, 7 OF oDlg PIXEL	//'Validade:' 
				
			@ aPosObj[4,1]+5, 185 MSGET Self:oEstVenda:nOrc_VlTot When .F. Picture "@E 999,999.99"	SIZE 46, 08 OF oDlg PIXEL
			@ aPosObj[4,1]+5, 270 MSGET Self:oEstVenda:nOrc_VlLiq When .F. Picture "@E 999,999.99"	SIZE 46, 08 OF oDlg PIXEL
			@ aPosObj[4,1]+17, 270 MSGET Self:oEstVenda:dOrc_Valid  When .F.							SIZE 46, 08 OF oDlg PIXEL
			@ aPosObj[4,1]+29, 130 SAY xPadL( STR0016, 66 ) 						SIZE 66, 07 OF oDlg PIXEL   ///Abatimentos 
			@ aPosObj[4,1]+29, 185 MSGET Self:oEstVenda:nOrc_Abat When .F. Picture "@E 999,999.99"	SIZE 50, 08 OF oDlg PIXEL
		
		Else
		
			@ aPosObj[4,1]+5, 240 SAY xPadL( STR0015, 28) SIZE 28, 7 OF oDlg PIXEL	//Validade 
			@ aPosObj[4,1]+29, 130 SAY xPadL( STR0014, 25) SIZE 25, 7 OF oDlg PIXEL	// Liquido
			
			@ aPosObj[4,1]+5, 185 MSGET Self:oEstVenda:nOrc_VlLiq	When .F. Picture PesqPict("SL1","L1_VLRLIQ") SIZE 50, 08 OF oDlg PIXEL
			@ aPosObj[4,1]+29, 185 MSGET Self:oEstVenda:nOrc_VlTot	When .F. Picture PesqPict("SL1","L1_VLRTOT") SIZE 50, 08 OF oDlg PIXEL
			@ aPosObj[4,1]+5, 267 MSGET Self:oEstVenda:dOrc_Valid	When .F. SIZE 49, 08 OF oDlg PIXEL
			
			@ aPosObj[4,1]+17, 240 SAY xPadL( STR0017, 28 ) SIZE 28, 7 OF oDlg PIXEL	//Imp. Inc.: 
			@ aPosObj[4,1]+17, 267 MSGET Self:oEstVenda:nOrc_ImpIn	 When .F. Picture PesqPict("SL1","L1_VALIMP1") SIZE 49, 08 OF oDlg PIXEL
			@ aPosObj[4,1]+29, 240 SAY xPadL( STR0018, 28 ) SIZE 28, 7 OF oDlg PIXEL 	//Imp. Disc. 
			@ aPosObj[4,1]+29, 267 MSGET Self:oEstVenda:nOrc_Imp When .F. Picture PesqPict("SL1","L1_VALIMP1") SIZE 49, 08 OF oDlg PIXEL
			
		EndIf
		
	
		ACTIVATE MSDIALOG oDlg VALID IIF(lCliPadr, oObj:ValidaCliente(Self,cCliente,cLoja), .T.) ON INIT EnchoiceBar( oDlg ,;
					{||oObj:Confirma(oGet2:aHeader, oGet2:aCols, aLinhasPg, lTEfPag),oDlg:End()},{|| oDlg:End()})

If lCliPadr
	aRotina := aRotinBK
EndIf

 
Return Nil    

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºMetodo    ³Confirma 	       ºAutor  ³Vendas Clientes     º Data ³ 24/11/2010  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Confirma a Janela.	             					    	     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³SigaLoja / FrontLoja                                        		 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³																	 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºRetorno   ³String														     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/ 
Method Confirma(aHeader, aCols, aLinhas, lTEfPag) Class LJEstFrmVenda      
Local nPosPorte := aScan(aHeader, {|c| AllTrim(c[2]) == "PORTE"})  //Posicao do porte do titulo
Local nPosForma := aScan(aHeader, {|c| AllTrim(c[2]) == "L4_FORMA"})   //Posicao da forma do titulo
Local nPosEst := aScan(aHeader, {|c| AllTrim(c[2]) == "L4lEstorn"})   //Posicao do pagamento estornado

If oGet2:oBrowse:nAT    > 0
	
	If !lTEfPag .and. ( AllTrim(aCols[oGet2:oBrowse:nAT, nPosForma]) $ "CD/CC")
		aLinhas[oGet2:oBrowse:nAT, nPosEst] := aCols[oGet2:oBrowse:nAT, nPosEst]
	Else
		
		If Len(alinhas)> 0 .And. !(AllTrim(aCols[oGet2:oBrowse:nAT, nPosForma]) $ "CD/CC") .And.  !IsMoney(aCols[oGet2:oBrowse:nAT, nPosForma])
		    aLinhas[oGet2:oBrowse:nAT, nPosPorte] := aCols[oGet2:oBrowse:nAT, nPosPorte] 	    
		EndIf 
	EndIf
EndIf
    
   If Self:nOpcX = 4 .and. LjProfile(Self:oEstVenda:nAcesso)
      Self:aColsPg := {}
      Self:aColsPg := aClone(aLinhas)
	  Self:lProssegue := .T.  
   EndIf 
      
Return  


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºMetodo    ³CarregaItens     ºAutor  ³Vendas Clientes     º Data ³ 25/11/2010  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     | Alimenta os Arrays aHeader e ACols do Browse de Itens    	     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³SigaLoja / FrontLoja                                        		 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³																	 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºRetorno   ³String														     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Method CarregaItens() Class LJEstFrmVenda  
Local aArea := GetArea() //workarea ativa
Local aAreaSX3 := SX3->(GetArea()) //Area SX3
Local aCampos := {"L2_PRODUTO","L2_DESCRI", "L2_QUANT", "L2_VRUNIT", "L2_VLRITEM"} //Campos dos itens do orcamento
Local nC  := 0  //Variavel contadora
Local nC2 := 0  //Variavel contadora
Local nCampos := Len(aCampos)   //Tamanho dos campos
	
DbSelectArea("SX3")
SX3->(DbSetOrder(2))

For nC := 1 To nCampos
	SX3->(DbSeek(aCampos[nC]))
	SX3->( aAdd( Self:aHeaderIt, {	X3TITULO()		,;	//01 Titulo
									X3_CAMPO		,;	//02 Campo	
									X3_PICTURE		,;	//03 Picture
									X3_TAMANHO		,;	//04 Tamanho
									X3_DECIMAL		,;	//05 Decimal
									.t.	,;	//06 Valid
									Nil				,;	//07 Usado
									X3_TIPO			,;	//08 Tipo
									X3_ARQUIVO		,;	//09 Arquivo
									"R"		}) )	//10 Contexto //vITUAL
		
Next nC	 

If !Self:lIsTroca
	For nC2 := 1 to Len(Self:oEstVenda:aOrc_Itens)
	    aAdd(Self:aColsIt, Array(nCampos +1))
	    For nC := 1 To nCampos  
	       If Self:Self:aHeaderIt[nC, 10]  = "V" 
	       	  Self:aColsIt[nC2, nC]  :=	CriaVar(aHeader[nC,2],.T.)	
	       Else
	       	  Self:aColsIt[nC2, nC]  := Self:oEstVenda:aOrc_Itens[nC2, nC]  	
	       EndIf	 
	    Next
	    Self:aColsIt[nC2, nCampos + 1] := .F.
	Next nC2  
Else
	aAdd(Self:aColsIt, Array(nCampos +1))
	For nC := 1 To nCampos  
		Self:aColsIt[1, nC]  :=	&("SL2"+"->"+Self:aHeaderIt[nC,2])	
	Next
	Self:aColsIt[1, nCampos + 1] := .F.
EndIf

RestArea(aAreaSX3)
RestArea(aArea)
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºMetodo    ³CarregaPagto     ºAutor  ³Vendas Clientes     º Data ³ 26/11/2010  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     | Alimenta os Arrays aHeader e ACols do Browse dos Pagamentos 	     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³SigaLoja / FrontLoja                                        		 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³																	 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºRetorno   ³String														     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Method CarregaPagto() Class LJEstFrmVenda 

Local aArea := GetArea() //workarea ativa
Local aAreaSX3 := SX3->(GetArea()) //workarea SX3
Local aCampos := {  ; 
					{"L4_DATA", STR0019,nil, "R",nil, __L4_DATA},; //Data
 					{"L4_FORMA", STR0020,nil, "R",nil, __L4_FORMA}, ;//"Forma"
 					{"L4_VALOR",STR0021, PesqPict("SL1","L1_VLRTOT"),"R",nil, __L4_VALOR},; //"Valor"
 					{"PORTE",STR0022, "@!", "R", STR0025, __PORTE},; //Porte
 					{"L4_NUMCART",STR0023, nil, "R",nil, __L4_NUMCART },;   //Cheque
 					{"L4_ADMINIS",STR0024, nil, "R", nil, __L4_ADMINIS},; //Banco/Admin.
 					{"L4_AGENCIA",nil, nil, "R", nil,__L4_AGENCIA},;
 					{"L4_CONTA",nil, nil, "R", nil,__L4_CONTA},;
 					{"L4_COMP", nil, nil, "R", nil, __L4_COMP},;
 					{"L4_DOCTEF",STR0026,nil, "R",nil,  __L4_DOCTEF};
 					}  //Campos do mbrowse

Local nC  := 0  //Variavel contadora
Local nC2 := 0  //Variavel contadora
Local nCampos := 0  //Variavel de campos
Local lSx3 := .f.  //Procura SX3	 

If !Self:oEstVenda:lOrc_MovFe .and. !lTEFPag
	aAdd(aCampos,	{"L4lEstorn", STR0027, nil, "V",STR0028, __L4lEstorn} ) //TEF EStornado 
EndIf			
 					
If cPaisLoc <> "BRA"
 aAdd(aCampos, {"L4_MOEDA", nil, nil, "R", nil, __L4_MOEDA})
 aAdd(aCampos, {"L4_DATA", nil, nil, "R", nil,__L4DATA})
EndIf  
                                                                         

If cPaisLoc == "ARG" .AND. (SL4->(FieldPos("L4_CHEQID")) > 0) 
  aAdd(aCampos, {"L4_CHEQID", nil, nil, "R", nil, __L4_CHEQID})
EndIf 

nCampos := Len(aCampos)

aSort(aCampos,,, {|a, b|, a[6] < b[6]}	)				
	
DbSelectArea("SX3")
SX3->(DbSetOrder(2)) 

For nC := 1 To nCampos 
	lSx3 := SX3->(DbSeek(aCampos[nC, 01]))
	SX3->( aAdd( Self:aHeaderPg, {	IIF(aCampos[nC,02] <> nil, aCampos[nC,02], X3TITULO()	),;	//01 Titulo
									IIF(lSx3, X3_CAMPO, aCampos[nC, 01]),;	//02 Campo	
									IIF(aCampos[nC,03] <> nil, aCampos[nC,03], IIF(lSx3, X3_PICTURE,"")),;	//03 Picture
									IIF(lSx3,X3_TAMANHO, 1),;	//04 Tamanho
									IIF(lSx3,X3_DECIMAL,0)	,;	//05 Decimal
									"",;	//06 Valid
									""	,;	//07 Usado
									IIF(lSx3,X3_TIPO,IIF(Len(Self:oEstVenda:aOrc_Pagtos) > 0, ValType(Self:oEstVenda:aOrc_Pagtos[1, 06]),"C")),;	//08 Tipo
									""	,;	//09 Arquivo
									"",;        //10 Contexto
									IIF(aCampos[nC,05]<> nil, aCampos[nC,05],"")}))	//11 CBOX

Next nC	 

For nC2 := 1 to Len(Self:oEstVenda:aOrc_Pagtos)
    aAdd(Self:aColsPg, Array(nCampos +1))
    For nC := 1 To nCampos        
       If aCampos[nC, 04] = "R"
       	Self:aColsPg[nC2, nC]  := Self:oEstVenda:aOrc_Pagtos[nC2, aCampos[nC, 06]]  
       Else 
       	Self:aColsPg[nC2, nC] := space(Self:aHeaderPg[nC, 4])
       EndIf	
    Next
    Self:aColsPg[nC2, nCampos + 1] := .F.
Next nC2  

RestArea(aArea)
RestArea(aAreaSX3)
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Lj600ValCliºAutor  ³Vendas Clientes     º Data ³ 26/07/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Valida o cliente informado pelo usuario                     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³LOJA600                                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Method ValidaCliente(oEstVenda, cCliente , cLoja )  Class LJEstFrmVenda

Local aArea		:= GetArea()						// Salva posicionamento atual
Local aAreaSA1	:= SA1->(GetArea())					// Salva posicionamento do SA1
Local lRet		:= .T.								// Retorno da funcao
Local cCliPad	:= SuperGetMV("MV_CLIPAD")			// Cliente padrao

DbSelectArea("SA1")
DbSetOrder(1)   

lRet := DbSeek(xFilial("SA1") + cCliente + cLoja ) //Valida se o codigo informado pelo usuario existe.

If !lRet         
	MsgStop(STR0030) //"O cliente selecionado não está cadastrado!"
Else
	//Valida se e cliente padrao.
	lRet := (AllTrim(cCliente) <> AllTrim(cCliPad)) 
	If !lRet
		Self:lProssegue := .F.
		MsgStop( STR0031 , STR0032 )//"A venda foi realizada para o cliente padrão. Favor informar um cliente diferente do padrão para o estorno."### "Atencao"
	Else
		Self:oEstVenda:lCliPad	 := .F.
		Self:oEstVenda:cOrc_Cli	 := cCliente
		Self:oEstvenda:cOrc_Loja := cLoja
	EndIf 
EndIf

RestArea(aAreaSA1)
RestArea(aArea)

Return lRet
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Lj600ValCliºAutor  ³Vendas Clientes     º Data ³ 26/07/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Valida o cliente informado pelo usuario                     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³LOJA600                                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Method ShowTroca() Class LJEstFrmVenda

Local oDlg			:= Nil //Objeto da dialog
Local aInfo		:= {} //Guarda informacoes de dimensionamento da tela
Local aSize		:= MsAdvSize() //Dimensionamento da tela
Local aObjects		:= {} //Array com informacao a serem repassadas ao MsObjSize
Local oFont		:= TFont():New('Courier new',,-16,.T.) //Tipo e tamanho da fonte do ListBox
Local aButtons		:= {}

nTotalVenda := 0 
aInfo 	:= {aSize[1],aSize[2],aSize[3],aSize[4],3,3}

aObjects := {}
AADD(aObjects,{100,050,.T.,.T.})
AADD(aObjects,{200,200,.T.,.T.})
AADD(aObjects,{200,200,.T.,.T.})
AADD(aObjects,{100,100,.T.,.T.})

aPosObj := MsObjSize(aInfo,aObjects,.T.)

//Cliente padrao
L602ChgCli( "CODCLI", @cCodCli, @cLojaCli, @cNomeCliente)

DEFINE MSDIALOG oDlg TITLE STR0034 From aSize[1],aSize[1] To aSize[6],aSize[5] of oMainWnd PIXEL //'Troca' 

@ aPosObj[1,1],aPosObj[1,2] TO aPosObj[1,3] * 1.7,aPosObj[1,4] OF oDlg PIXEL

//Cliente
@aPosObj[1,1] * 0.3,01 Say STR0010 //'Cliente: '														
@aPosObj[1,1] * 0.3,05 MSGET cCodCli	 SIZE 75,08 Picture "@!" F3 "SA1" VALID L602ChgCli( "CODCLI", @cCodCli, @cLojaCli, @cNomeCliente) 

//Loja
@aPosObj[1,1] * 0.3,15 MSGET cLojaCli SIZE 30, 08 Picture "@!" VALID L602ChgCli( "CODLOJA", @cCodCli, @cLojaCli, @cNomeCliente) 

//Nome do cliente
@aPosObj[1,1] * 0.3,20 MSGET cNomeCliente SIZE 95,08 WHEN .F. Picture "@!"

If (SF1->(FieldPos("F1_VEND1")) > 0)
	@aPosObj[1,1] * 0.3,36 Say STR0050 //"Vendedor: "														
	@aPosObj[1,1] * 0.3,41 MSGET cCodVen	 SIZE 75,08 Picture "@!" F3 "SA3" VALID ExistCpo( "SA3",cCodVen,1 )
EndIf	 

@aPosObj[1,1] * 0.9,01 Say STR0035 //'Cod. Prod: '	
@aPosObj[1,1] * 0.9,05 MSGET oProduto VAR cProduto SIZE 75, 08 Picture "@!" F3 "SB1" VALID Lj7011VldProd(cProduto, 1)

@aPosObj[1,1] * 0.9,15 Say STR0036 //'Produto: '
@aPosObj[1,1] * 0.9,20 MSGET oDescProd VAR cDescProd SIZE 90, 08 WHEN .F. Picture "@!" 

@aPosObj[1,1] * 0.9,33 Say STR0037 //'Qtde: '
@aPosObj[1,1] * 0.9,35 MSGET oQtde VAR cQtde SIZE 30, 08 Picture "@!" VALID Lj7011Trigger('TRB_QUANT',,Val(cQtde)) 

@aPosObj[1,1] * 0.9,41 Say STR0038 //'Valor: '
@aPosObj[1,1] * 0.9,44 MSGET oValor VAR nValor SIZE 50, 08 Picture "@E 999,999.99" VALID Lj7011Trigger('TRB_PRCVEN',,Val(cQtde)) .AND. Lj7011InsProd()

oListProd := TListBox():Create(oDlg, aPosObj[2,1] * 1.9, aPosObj[2,2], Nil, aItens, aPosObj[2,4], aPosObj[2,3],,,,,.T.,,{||.T.},oFont,,,)

Aadd(aButtons,{STR0039,{|| Lj7011DelItem(.F.), oProduto:SetFocus() }, OemToAnsi(STR0039)}) //"Excluir Item"


//Total:
@aPosObj[3,1] * 0.11,01 Say STR0049 //'Total: '
//Total
@aPosObj[3,1] * 0.11,05 MSGET oVendedor VAR nTotalVenda SIZE 75,08 WHEN .F. Picture "@E 999,999.99"
//Valido
ACTIVATE MSDIALOG oDlg VALID .T. ON INIT EnchoiceBar( oDlg ,;
					{||Lj7011ExecDev(), oDlg:End()},{|| Lj7011FimClear(), oDlg:End()},,aButtons)

//Teste
//ACTIVATE MSDIALOG oDlg VALID .T. ON INIT EnchoiceBar( oDlg ,;
//					{||Lj602Dev(cCodCli, cLojaCli , cCodVen),oDlg:End()},{|| Lj7011FimClear(), oDlg:End()},,aButtons)

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³Lj720VldPro³ Autor ³ Vendas Cliente       ³ Data ³ 16/09/05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±ºDescri‡„o ³Validacao do produto quando nao tem NF de origem   		  º±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Lj720VldProd(ExpC1, ExpN2)                                 ³±±
±±³			 ³ ExpC1 - Codigo do produto 							      ³±±
±±³			 ³ ExpN2 - Quantidade devolvida							      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ Automacao Comercial										  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Lj7011VldProd(  cCodProd  ,nQuant   )
Local lRet := .T.   						//Variavel de retorno, controla se o produto foi validado

If !Empty(cCodProd)

	nQuant  := Max(nQuant,1)
	If lRet  := LJSB1SLK(  @cCodProd  ,@nQuant   ,.F.     ) 
		lRet  := Lj7011Trigger(  'TRB_CODPRO'  ,  cCodProd   ,nQuant   )  
		cProduto := cCodProd
	EndIf   

EndIf

Return (lRet)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Lj720TriggerºAutor  ³ Vendas Cliente     º Data ³  08/24/05 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³- Gatilha o campo descricao do produto, UM e TES.           º±±
±±º          ³- Executa o calculo do valor total do item baseado na       º±±
±±º          ³ quantidade e no preco unitario digitado.                   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ExpC1 - Campo a ser tratado                                 º±±
±±º          ³ExpC2 - Valor referente ao campo                            º±±
±±º          ³ExpN3 - Quantidade referente ao campo                       º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SIGALOJA - VENDA ASSISTIDA.                                º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Lj7011Trigger( cCampo  ,cValor  ,nQuant )

Local lRet			:= 	.T.								// Retorno da funcao
Local cTesSai		:= SuperGetMV("MV_TESSAI")			// Pega do parametro o TES padrao para saida
Local cTesInt		:= ""								// Codigo do Tes de saida
Local cTabPrecos    := ""                               // Tabela de preco utilizada no caso de possuir cenario de venda
Local nPrcVenda     := ""                               // Preco de venda
Local cCliente      := ""                               // Cliente 
Local cLoja      	:= ""                               // Loja 
Local nMoeda        := 1                                // Moeda definada como 1 pois o cenario de venda somente existe para o Brasil

Default nQuant  		:= 1
     
If lRet
	
	Do Case
	
		Case cCampo $ "TRB_CODPRO"
	
			SB1->(DbSetOrder(1))
			SB1->(DbSeek(xFilial("SB1")+cValor))
			cCliente	:= SA1->A1_COD
			cLoja    	:= SA1->A1_LOJA
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Parametro da funcao MaTesInt               ³
			//³ExpN1 = Documento de 1-Entrada / 2-Saida   ³
			//³ExpC1 = Tipo de Operacao Tabela "DJ" do SX5³
			//³ExpC2 = Codigo do Cliente ou Fornecedor    ³
			//³ExpC3 = Codigo do gracao E-Entrada         ³
			//³ExpC4 = Tipo de Operacao E-Entrada         ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			cTesInt := MaTesInt( 2	,Padr("6",2)	,cCliente	,cLoja	,;
							     "C",SB1->B1_COD	,NIL)
	
			If !Empty(cTesInt)
				cTesPad := cTesInt
			Else
				If Empty( SB1->B1_TS )
					cTesPad := cTesSai
				Else
					cTesPad := SB1->B1_TS					
				EndIf
			Endif
			
			cDescProd 	:= SB1->B1_DESC
			cQtde		:= '1'
					   	
		   	// No caso de utilizar o cenario de venda busca o preco da tabela de preco utilizada 
		   	If lCenVenda
				cTabPrecos := LjXETabPre(cCliente, cLoja) 
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Retorna o valor da tabela de preco DA1 de acordo com a moeda utilizada.³
				//³caso nao encontre a tabela de preco retorna o valor do B0_PRV          ³
	   			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		   		nPrcVenda := MaTabPrVen( cTabPrecos		,cValor		,nQuant			,cCliente	,; 
										cLoja			,nMoeda		, /*dDataVld*/	,/*nTipo*/	,;
										/*lExec*/	)
	   		Else                                                      
				nPrcVenda := Posicione("SB0",1,xFilial("SB0")+cValor,"B0_PRV1")
	   		EndIf 

			nValor		:= nPrcVenda
			nPrcTot	:= A410Arred(1 * nValor ,"D2_TOTAL")
			cUm 		:= SB1->B1_UM
			
	   		
		Case cCampo $ "TRB_QUANT"
	        		    
		    nPrcTot	:= A410Arred(nQuant * nValor ,"D2_TOTAL")
		
		Case cCampo $ "TRB_PRCVEN"
		
			nPrcTot	:= A410Arred(nQuant * nValor ,"D2_TOTAL")
			nTotalVenda += nPrcTot  
	
	EndCase
	
EndIf

Return(lRet)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Lj7011InsProdºAutor  ³ Vendas Cliente     º Data ³  08/24/05 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³- Insere o produto na listbox						           º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ LOJA7011                                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Lj7011InsProd()

If !Empty(cQtde) .AND. nValor > 0
	nItem += 1
	Aadd(aItens,Padl(nItem,3,'0') +; //Numero do item
						' -> ' +; //Seta
						Padr(AllTrim(cProduto),Len(CriaVar("B1_COD",.F.)),'') +; //Codigo do produto
						' - ' +; //Traco
						SubStr(Padr(AllTrim(cDescProd),Len(CriaVar("B1_DESC",.F.)),''),1,30) +; //Descricao do produto
						' - ' +; //Traco
						Padl(AllTrim(Str(Val(cQtde),7,2)),7,'') +; //Quantidade
						' x ' +; //Sinal de vezes
						Padl(AllTrim(Str(nValor, 10,2)),10,'') +; //Valor unitario
						' = ' +; //Igual
						Padl(AllTrim(Str(nPrcTot,10,2)),10,'')) //Valor total Qtde x Preco Unitario
	
	
	oListProd:Reset()    
	oListProd:SetArray(aItens)
	
	Aadd(aItensTab,{Padl(nItem,3,'0') + ' -> ' + Padr(AllTrim(cProduto),Len(CriaVar("B1_COD",.F.)),'') +;
		              ' - ' + SubStr(Padr(AllTrim(cDescProd),Len(CriaVar("B1_DESC",.F.)),''),1,30) +;
		              ' - ' + Padl(AllTrim(Str(Val(cQtde),7,2)),7,'') +;
		              ' x ' + Padl(AllTrim(Str(nValor, 10,2)),10,'') +;
		              ' = ' + Padl(AllTrim(Str(nPrcTot,10,2)),10,''),; //Linha como esta no listbox
	                  Padl(nItem,3,'0'),; //Numero do item
	                  cProduto,; //Codigo do produto
	                  cDescProd,; //Descricao do produto
	                  cQtde,; //Quantidade
	                  nValor,; //Preco de venda
	                  nPrcTot,; //Preco total - quantidade x preco de venda
	                  cUm,; //Unidade
	                  cTesPad,; //Tes
	                  .F.}) //Produto excluido? .F. = Nao ou .T. = Sim
	                  
	Lj7011DelItem(.T.)
	Lj7011ClearSta()
EndIf

Return .T.


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Lj7011ClearStaºAutor  ³ Vendas Cliente   º Data ³  08/24/05 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³- Responsavel por limpar as variaveis Static   	           º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ LOJA7011                                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Lj7011ClearSta()
cProduto 	:= Padr('',Len(CriaVar("B1_COD",.F.)),'') //Codigo do produto
cDescProd	:= ''
cQtde 		:= ''
nPrcTot 	:= 0
nValor		:= 0
cUm 		:= ''
cTesPad 	:= ''
oProduto:SetFocus()
Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Lj7011ClearStaºAutor  ³ Vendas Cliente   º Data ³  08/24/05 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³- Responsavel por limpar as variaveis Static   	           º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ LOJA7011                                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Lj7011GetVar()
Return aItensTab

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Lj7011ExecDevºAutor  ³ Varejo            º Data ³  08/24/05 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³- Chama rotina de devolucao via STBRemoteExecute	           º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ LOJA7011                                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Lj7011ExecDev()

Local aRetDev 		:= {} //Retorno do remote execute
Local lContinue 	:= .F. //Retorno da execucao remota
Local lRet			:= .F. //Retorno da funcao
Local cCoCliente	:= Padr(SuperGetMV("MV_CLIPAD",,""),Len(CriaVar("A1_COD",.F.)),'') //Codigo do cliente
Local cLoCliente	:= Padr(SuperGetMV("MV_LOJAPAD"),Len(CriaVar("A1_LOJA",.F.)),'') //Codigo da loja 


If Len(aItensTab) > 0
	If AllTrim(cCoCliente) + AllTrim(cLoCliente) ==  AllTrim(cCodCli) + AllTrim(cLojaCli)
		MsgStop(STR0040,STR0041) //"Não é permitida a troca/devolução de mercadorias para o cliente padrão" # "Atenção" 
	Else
	
		MsgRun(STR0042,STR0041,{|| lContinue := STBRemoteExecute( "Lj602Devol" , { cCodCli, cLojaCli, aItensTab , cCodVen } , Nil , .F. , @aRetDev ) }) //"Aguarde, gerando nota de devolução..." # "Atenção"
		
		If lContinue
		
			If aRetDev[1]
				lRet := .T.		
				Lj7011FimClear()
				MsgInfo(STR0043) //"Nota de devolução gerada com sucesso!"
			Else
				If !Empty(aRetDev[2])
					CoNout(aRetDev[2])
					Alert(aRetDev[2])
				Else
					Alert(STR0045) //"Erro na geração da nota de entrada!"
				EndIf
			EndIf
		
		EndIf 
	
	EndIf
Else
	Alert(STR0048) //"Por favor, informe o(s) iten(s) para efetuar a devolução!"
EndIf

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Lj7011FimClearºAutor  ³ Varejo   º Data ³  08/24/05 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³- Limpa dados da tela							   	           º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ LOJA7011                                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Lj7011FimClear()
cCodCli		:= Padr(SuperGetMV("MV_CLIPAD",,""),Len(CriaVar("A1_COD",.F.)),'') //Codigo do cliente
cLojaCli		:= Padr(SuperGetMV("MV_LOJAPAD"),Len(CriaVar("A1_LOJA",.F.)),'') //Codigo da loja
cNomeCliente 	:= Padr('',Len(CriaVar("A1_NOME",.F.)),'') //Nome do cliente
cProduto 	:= Padr('',Len(CriaVar("B1_COD",.F.)),'') //Codigo do produto
cCodVen		:=	SuperGetMV( "MV_VENDPAD" ) 
cDescProd	:= ''
cQtde 		:= ''
nPrcTot 	:= 0
nValor		:= 0
cUm 		:= ''
cTesPad 	:= ''
aItensTab	:= {}
aItens		:= {}
nItem		:= 0
nTotalVenda := 0  
Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Lj7011DelItemºAutor  ³ Varejo   º Data ³           08/24/05 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³- Exclui item do listbox							   	           º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ LOJA7011                                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Lj7011DelItem(lAtlz)

Local nI := 0 //Variavel de loop

Default lAtlz := .F.

If oListProd:Len() > 0
	If lAtlz
		For nI := 1 To Len(aItensTab)
			If aItensTab[nI][10]				
				oListProd:Modify(aItensTab[nI][1] + " - " + STR0047,nI)
			EndIf
		Next nI
	Else	
		If MsgNoYes(STR0046 + aItensTab[oListProd:GetPos()][2],STR0041) //"Confirma a exclusão do item: " # "Atenção"
			aItensTab[oListProd:GetPos()][10] := .T.
			oListProd:Modify(aItensTab[oListProd:GetPos()][1] + " - " + STR0047,oListProd:GetPos()) //"[Excluido]"
			nTotalVenda := ( nTotalVenda - aItensTab[oListProd:GetPos()][7] ) 
		EndIf
	EndIf
	oListProd:Refresh()				
EndIf

Return .T.

