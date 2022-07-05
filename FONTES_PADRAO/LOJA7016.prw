#INCLUDE 'PROTHEUS.CH' 
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'LOJA7016.CH' 
#include "fileio.ch"

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �LOJA7016   �Autor  �TOTVS              � Data �  01/07/2013 ���
�������������������������������������������������������������������������͹��
���Desc.     �MVC - Quebra Operacional                                    ���
�������������������������������������������������������������������������͹��
���Uso       � Prevencao de perdas                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function LOJA7016()
Local oBrowse	:= NIL			// Objeto Browse

//�������������������������������Ŀ
//�Instanciamento da Classe Browse�
//���������������������������������
oBrowse := FWMBrowse():New()

//�������������������Ŀ
//�Tabela a ser aberta�
//���������������������
oBrowse:SetAlias("MFJ")


//����������������Ŀ
//�Titulo do Browse�
//������������������
oBrowse:SetDescription(STR0001)//Cadastro de Quebra Operacional

//������������������Ŀ
//�Ativa��o do Browse�
//��������������������
oBrowse:Activate()

Return Nil

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �ModelDef  �Autor  �TOTVS                      �  01/07/2013 ���
�������������������������������������������������������������������������͹��
���Desc.     �Constru��o defini��o do modelo de dados					  ���
�������������������������������������������������������������������������͹��
���Uso       � Prevencao de Perdas                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function ModelDef()
Local oStruMFJ 		:= NIL	// Objeto Struct
Local oModelMFJ		:= NIL	// Objeto Model

//���������������������������������������������Ŀ
//�Cria Estrutura a ser usada no Modelo de Dados�
//�����������������������������������������������
oStruMFJ 	:= FWFormStruct(1,'MFJ')

//��������������������������������Ŀ
//�Cria o Objeto do Modelo de Dados�
//����������������������������������
oModelMFJ	:= MPFormModel():New('SYMFJ', /*Pre-Validacao*/, {|oX| VldBtOk(oX)}/*Pos-Validacao*/, /*Commit*/,/*Cancel*/)

//���������������������������������������������Ŀ
//�Adiciona ao modelo o componente de formul�rio�
//�����������������������������������������������
oModelMFJ:AddFields('MFJMASTER',/*cOwner*/,oStruMFJ)

//�������������������Ŀ
//�Cria Chave Primaria�
//���������������������
oModelMFJ:SetPrimaryKey( {"MFJ_FILIAL","MFJ_CODIGO"} )

//���������������������������������������Ŀ
//�Adiciona a descri��o do Modelo de Dados�
//�����������������������������������������
oModelMFJ:SetDescription(STR0002)//'Modelo de Dados Cadastro da Quebra Operacional

//�����������������������������������������������������Ŀ
//�Adiciona a descri��o do componente do Modelo de Dados�
//�������������������������������������������������������
oModelMFJ:GetModel('MFJMASTER'):SetDescription(STR0003)//'Dados Cadastro de Quebra Operacional'

Return oModelMFJ

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �ViewDef   �Autor  � Totvs              � Data �  01/07/2013 ���
�������������������������������������������������������������������������͹��
���Desc.     �Constru��o da interface do modelo de dados				  ���
�������������������������������������������������������������������������͹��
���Uso       � Preven��o de Perdas                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function ViewDef() 
Local oModelDef		:= NIL	 	// Objeto Define
Local oStruMFJ		:= NIL 		// Objeto Struct
Local oViewDef  	:= NIL 		// Objeto View

//���������������������������������������������������������������������������Ŀ
//�Cria um objeto de Modelo de dados baseado no ModelDef() do fonte informado �
//�����������������������������������������������������������������������������
oModelDef := FWLoadModel('LOJA7016') 

//�������������������������������������Ŀ
//�Cria a estrutura a ser usada na View �
//���������������������������������������
oStruMFJ := FWFormStruct( 2,'MFJ') 

//����������������������Ŀ
//�Cria o objeto de View �
//������������������������
oViewDef := FWFormView():New() 

//�����������������������������������������������������Ŀ
//�Define qual o Modelo de dados ser� utilizado na View �
//�������������������������������������������������������
oViewDef:SetModel(oModelDef) 

//�������������������������������������������������������Ŀ
//�Adiciona no nosso View um controle do tipo formul�rio  �
//�(antiga Enchoice)                                      �
//���������������������������������������������������������
oViewDef:AddField( 'VIEW_MFJ', oStruMFJ, 'MFJMASTER' )

//��������������������������������������������������������������Ŀ
//�Criar um "box" horizontal para receber algum elemento da view �
//����������������������������������������������������������������
oViewDef:CreateHorizontalBox( 'TELA' , 100 ) 

//�����������������������������������������������������������������Ŀ
//�Relaciona o identificador (ID) da View com o "box" para exibi��o �
//�������������������������������������������������������������������
oViewDef:SetOwnerView( 'VIEW_MFJ', 'TELA' ) 

Return oViewDef

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �VlCampo   �Autor  �TOTVS               � Data �  01/07/2013 ���
�������������������������������������������������������������������������͹��
���Desc.     �Valida se o codigo digitado j� existe                       ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function VldBtOk(oModel)
Local aSD3     := {} 								//Array que contem os campos da tabela SD3 que serao usados para na executar a MSEXECAUTO do MATA240.
Local cTPMov   := SuperGetMv("MV_LJTPMOV",,.F.)	    //Tipo de Movimento da tabela SF5 que ser� usado para informar o tipo de movimento na SD3
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

// Valida��es
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
	    // para que o indice 3 da SD3(filial+produto+local+sequencia da SD3) seja localizada na fun��o MsRotAuto 
	    // do fonte MATXFUNB que � executada via MATA240. 
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

	    MsgRun(STR0004,STR0005,{||MSExecAuto({|x,y|MATA240(x,y)},aSD3,If(!lEstorno,3,5))})//"Registrando movimenta��o internas."##"Aguarde..." 

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
   MsgAlert(STR0007)//'Parametro MV_LJTPMOV n�o est� preenchido.'
   Return .F.
Endif


RestArea( aArea )
 
Return lRet 

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �MenuDef   �Autor  � TOTVS              � Data �  01/07/2013 ���
�������������������������������������������������������������������������͹��
���Desc.     �Cria menu de op��es para o usu�rio                          ���
�������������������������������������������������������������������������͹��
���Uso       � Prevencao de Perdas                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function MenuDef()
Local aRotina := {}
aAdd( aRotina, { "Visualizar", "VIEWDEF.LOJA7016", 0, 2, 0, NIL } ) // "Visualizar"
aAdd( aRotina, { "Incluir", "VIEWDEF.LOJA7016", 0, 3, 0, NIL } ) // "Incluir"
aAdd( aRotina, { "Excluir", "VIEWDEF.LOJA7016", 0, 5, 0, NIL } ) // "Excluir"
Return aRotina
