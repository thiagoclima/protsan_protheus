#INCLUDE 'PROTHEUS.CH' 
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'LOJA7016.CH' 
#include "fileio.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณLOJA7016   บAutor  ณTOTVS              บ Data ณ  01/07/2013 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณMVC - Quebra Operacional                                    บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Prevencao de perdas                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function LOJA7016()
Local oBrowse	:= NIL			// Objeto Browse

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณInstanciamento da Classe Browseณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
oBrowse := FWMBrowse():New()

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณTabela a ser abertaณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
oBrowse:SetAlias("MFJ")


//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณTitulo do Browseณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
oBrowse:SetDescription(STR0001)//Cadastro de Quebra Operacional

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณAtiva็ใo do Browseณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
oBrowse:Activate()

Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณModelDef  บAutor  ณTOTVS                      ณ  01/07/2013 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณConstru็ใo defini็ใo do modelo de dados					  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Prevencao de Perdas                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function ModelDef()
Local oStruMFJ 		:= NIL	// Objeto Struct
Local oModelMFJ		:= NIL	// Objeto Model

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณCria Estrutura a ser usada no Modelo de Dadosณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
oStruMFJ 	:= FWFormStruct(1,'MFJ')

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณCria o Objeto do Modelo de Dadosณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
oModelMFJ	:= MPFormModel():New('SYMFJ', /*Pre-Validacao*/, {|oX| VldBtOk(oX)}/*Pos-Validacao*/, /*Commit*/,/*Cancel*/)

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณAdiciona ao modelo o componente de formulแrioณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
oModelMFJ:AddFields('MFJMASTER',/*cOwner*/,oStruMFJ)

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณCria Chave Primariaณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
oModelMFJ:SetPrimaryKey( {"MFJ_FILIAL","MFJ_CODIGO"} )

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณAdiciona a descri็ใo do Modelo de Dadosณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
oModelMFJ:SetDescription(STR0002)//'Modelo de Dados Cadastro da Quebra Operacional

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณAdiciona a descri็ใo do componente do Modelo de Dadosณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
oModelMFJ:GetModel('MFJMASTER'):SetDescription(STR0003)//'Dados Cadastro de Quebra Operacional'

Return oModelMFJ

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณViewDef   บAutor  ณ Totvs              บ Data ณ  01/07/2013 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณConstru็ใo da interface do modelo de dados				  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Preven็ใo de Perdas                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function ViewDef() 
Local oModelDef		:= NIL	 	// Objeto Define
Local oStruMFJ		:= NIL 		// Objeto Struct
Local oViewDef  	:= NIL 		// Objeto View

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณCria um objeto de Modelo de dados baseado no ModelDef() do fonte informado ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
oModelDef := FWLoadModel('LOJA7016') 

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณCria a estrutura a ser usada na View ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
oStruMFJ := FWFormStruct( 2,'MFJ') 

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณCria o objeto de View ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
oViewDef := FWFormView():New() 

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณDefine qual o Modelo de dados serแ utilizado na View ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
oViewDef:SetModel(oModelDef) 

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณAdiciona no nosso View um controle do tipo formulแrio  ณ
//ณ(antiga Enchoice)                                      ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
oViewDef:AddField( 'VIEW_MFJ', oStruMFJ, 'MFJMASTER' )

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณCriar um "box" horizontal para receber algum elemento da view ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
oViewDef:CreateHorizontalBox( 'TELA' , 100 ) 

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณRelaciona o identificador (ID) da View com o "box" para exibi็ใo ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
oViewDef:SetOwnerView( 'VIEW_MFJ', 'TELA' ) 

Return oViewDef

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณVlCampo   บAutor  ณTOTVS               บ Data ณ  01/07/2013 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณValida se o codigo digitado jแ existe                       บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function VldBtOk(oModel)
Local aSD3     := {} 								//Array que contem os campos da tabela SD3 que serao usados para na executar a MSEXECAUTO do MATA240.
Local cTPMov   := SuperGetMv("MV_LJTPMOV",,.F.)	    //Tipo de Movimento da tabela SF5 que serแ usado para informar o tipo de movimento na SD3
Local lRet     := .T. 								//Variavel de retorno
Local aArea    := GetArea()                        	//Area Atual
Local nOpe     := ""                                //Tipo de operacao 3= inclusao e 5=estorno no caso de Alteracao 
Local cLocal   := ""                                //Armazem do produto
Local lEstorno := .F.                               //Indica se a operacao trata-se de um estorno
Local oModelMFJ:= oModel:GetModel("MFJMASTER")      //Altera o conteudo de variavel de tela
Local cProduto := oModelMFJ:ADATAMODEL[1][Ascan( oModelMFJ:ADATAMODEL[1],{|x| x[1] == 'MFJ_PRODUT'})][2]
Local cSD3NUM  := oModelMFJ:ADATAMODEL[1][Ascan( oModelMFJ:ADATAMODEL[1],{|x| x[1] == 'MFJ_SD3NUM'})][2]
Local nQuant   := Val( oModelMFJ:ADATAMODEL[1][Ascan( oModelMFJ:ADATAMODEL[1],{|x| x[1] == 'MFJ_QUANT'})][2] )

Private lMSErroAuto := .F.

IF oModel:GetOperation() == 3
	nOpe :=  3//inclusao
	cLocal  := Alltrim(Posicione("SB1",1,xFilial("SB1")+cProduto,"B1_LOCPAD"))
Else
	nOpe   :=  5//estorno  
	cLocal :=  Alltrim(Posicione("SB1",1,xFilial("SB1")+MFJ->MFJ_PRODUT,"B1_LOCPAD"))
	dbSelectArea("SD3")
	dbSetOrder(3)
	If DbSeek(xFilial("SD3")+ MFJ->MFJ_PRODUT+cLocal+MFJ->MFJ_SD3NUM)	
		lRet := .T.
	Endif	
	lEstorno := .T.
Endif		  

// Valida็๕es
If nQuant < 0
	lRet     := .F.
   	Help( ,, 'Help',, "Quantidade negativa.", 1, 0 )//"Quantidade negativa."
Endif

If lRet
	DbSelectArea("SB2")
	DbSetOrder(1)//B2_FILIAL+B2_COD+B2_LOCAL  
	If !DbSeek(xFilial("SB2") + cProduto + cLocal)
		lRet	:= .F.	
	Endif
	
	DbSelectArea("SB9")
	DbSetOrder(1)//B9_FILIAL+B9_COD+B9_LOCAL
	If !DbSeek(xFilial("SB9") + cProduto + cLocal)
		lRet	:= .F.	
	Endif
	If !lRet
		Help(" ",1,"B2PROD" )
	   	Return lRet
	EndIf
EndIf

If !Empty(cTPMov) .And. lRet 
	If Val(cTPMov) >= 500 //Requisicao
	    //Atencao! A estrutura de montar o array aSD3 deve ser mantida conforme abaixo,
	    // para que o indice 3 da SD3(filial+produto+local+sequencia da SD3) seja localizada na fun็ใo MsRotAuto 
	    // do fonte MATXFUNB que ้ executada via MATA240. 
		AAdd(aSD3,{'D3_FILIAL'  ,xFilial("SD3") ,Nil})
		AAdd(aSD3,{'D3_COD'		,cProduto,Nil})		
        AAdd(aSD3,{'D3_LOCAL'   ,cLocal,Nil})
		If nOpe ==  5			
			AAdd(aSD3,{'D3_NUMSEQ'	,cSD3NUM	  ,Nil})		
		Endif	
		AAdd(aSD3,{'D3_TM'      ,Alltrim(cTPMov) ,Nil})
		AAdd(aSD3,{'D3_QUANT'	,nQuant,Nil})
		AAdd(aSD3,{'D3_EMISSAO'	,dDataBase	   ,Nil})
		
		If Localiza(PadR(cProduto,Len(SD3->D3_COD))) // Se o Produto possuir localizacao
			AAdd(aSD3,{'D3_LOTECTL'	,PadR(M->MFJ_LOTCTL,Len(SD3->D3_LOTECTL))	,Nil})
			AAdd(aSD3,{'D3_NUMLOTE'	,PadR(M->MFJ_NUMLOT,Len(SD3->D3_NUMLOTE))	,Nil})
			AAdd(aSD3,{'D3_NUMSERI'	,PadR(M->MFJ_NUMSER,Len(SD3->D3_NUMSERI))	,Nil})
		Endif
		
		AAdd(aSD3,{"INDEX",3,Nil})
		
		lMSHelpAuto := .T.

	    MsgRun(STR0004,STR0005,{||MSExecAuto({|x,y|MATA240(x,y)},aSD3,If(!lEstorno,3,5))})//"Registrando movimenta็ใo internas."##"Aguarde..." 

	    lMSHelpAuto := .F.
	   
		IF lMSErroAuto//esse tratamento exibe qual o campo esta com erro.
		    lRet := .F.
			MostraErro()
		Else
			If lRet				
				If nOpe ==  3 //Inclusao, necessaria para localizar chave na SD3 
					oModelMFJ:LoadValue( "MFJ_SD3NUM" , SD3->D3_NUMSEQ)
                Endif
                
				FWFormCommit(oModel)  
 				
			Endif	
		Endif		
	Else
	   MsgAlert(STR0006)//'Tipo de Movimento cadastrado no parametro MV_LJTPMOV esta inferior a 500.'
	   Return .F.
	Endif	
Else
   MsgAlert(STR0007)//'Parametro MV_LJTPMOV nใo estแ preenchido.'
   Return .F.
Endif


RestArea( aArea )
 
Return lRet 

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณMenuDef   บAutor  ณ TOTVS              บ Data ณ  01/07/2013 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณCria menu de op็๕es para o usuแrio                          บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Prevencao de Perdas                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function MenuDef()
Local aRotina := {}
aAdd( aRotina, { "Visualizar", "VIEWDEF.LOJA7016", 0, 2, 0, NIL } ) // "Visualizar"
aAdd( aRotina, { "Incluir", "VIEWDEF.LOJA7016", 0, 3, 0, NIL } ) // "Incluir"
aAdd( aRotina, { "Excluir", "VIEWDEF.LOJA7016", 0, 5, 0, NIL } ) // "Excluir"
Return aRotina
