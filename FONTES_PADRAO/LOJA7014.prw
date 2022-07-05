#INCLUDE 'PROTHEUS.CH' 
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'LOJA7014.CH' 

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �LOJA7014   �Autor  �TOTVS              � Data �  01/07/2013 ���
�������������������������������������������������������������������������͹��
���Desc.     �MVC - Cadastro de Ocorrencia                                ���
�������������������������������������������������������������������������͹��
���Uso       � Prevencao de perdas                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function LOJA7014()
Local oBrowse 	:= NIL			// Objeto Browse

//�������������������������������Ŀ
//�Instanciamento da Classe Browse�
//���������������������������������
oBrowse := FWMBrowse():New()

//�������������������Ŀ
//�Tabela a ser aberta�
//���������������������
oBrowse:SetAlias("MFN")


//����������������Ŀ
//�Titulo do Browse�
//������������������
oBrowse:SetDescription(STR0001)//"Cadastro de Ocorrencia"

//������������������Ŀ
//�Ativa��o do Browse�
//��������������������
oBrowse:Activate()

Return NIL

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
Local oStruMFN  	:= NIL		// Objeto Struct
Local oModelMFN 	:= NIL		// Objeto Model

//���������������������������������������������Ŀ
//�Cria Estrutura a ser usada no Modelo de Dados�
//�����������������������������������������������
oStruMFN 	:= FWFormStruct(1,'MFN')

//��������������������������������Ŀ
//�Cria o Objeto do Modelo de Dados�
//����������������������������������
oModelMFN      := MPFormModel():New( 'SYMFN', /*Pre-Validacao*/,  /*Pos-Validacao*/,  {|oModelMFN| LJ7014Excl(oModelMFN   )}/*Commit*/, /*Cancel*/ )

//���������������������������������������������Ŀ
//�Adiciona ao modelo o componente de formul�rio�
//�����������������������������������������������
oModelMFN:AddFields('MFNMASTER',/*cOwner*/,oStruMFN)

//�������������������Ŀ
//�Cria Chave Primaria�
//���������������������
oModelMFN:SetPrimaryKey( {"MFN_FILIAL","MFN_CODIGO"} )

//���������������������������������������Ŀ
//�Adiciona a descri��o do Modelo de Dados�
//�����������������������������������������
oModelMFN:SetDescription(STR0002)//"Modelo de Dados Cadastro de Ocorrencia"

//�����������������������������������������������������Ŀ
//�Adiciona a descri��o do componente do Modelo de Dados�
//�������������������������������������������������������
oModelMFN:GetModel('MFNMASTER'):SetDescription(STR0003)//'Dados Cadastro de Ocorrencia'

Return oModelMFN

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
Local oModelDef 	:= NIL	 	// Objeto Define
Local oStruMFN 		:= NIL		// Objeto Struct
Local oViewDef 		:= NIL 		// Objeto View

//���������������������������������������������������������������������������Ŀ
//�Cria um objeto de Modelo de dados baseado no ModelDef() do fonte informado �
//�����������������������������������������������������������������������������
oModelDef := FWLoadModel('LOJA7014') 

//�������������������������������������Ŀ
//�Cria a estrutura a ser usada na View �
//���������������������������������������
oStruMFN := FWFormStruct( 2,'MFN') 

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
oViewDef:AddField( 'VIEW_MFN', oStruMFN, 'MFNMASTER' )

//��������������������������������������������������������������Ŀ
//�Criar um "box" horizontal para receber algum elemento da view �
//����������������������������������������������������������������
oViewDef:CreateHorizontalBox( 'TELA' , 100 ) 

//�����������������������������������������������������������������Ŀ
//�Relaciona o identificador (ID) da View com o "box" para exibi��o �
//�������������������������������������������������������������������
oViewDef:SetOwnerView( 'VIEW_MFN', 'TELA' ) 

Return oViewDef

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �VlCampo   �Autor  �TOTVS               � Data �  01/07/2013 ���
�������������������������������������������������������������������������͹��
���Desc.     �Valida se o codigo j� existe                                ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function LJ7014OK()
Local aArea 	:= GetArea()			//Area Atual

DbSelectArea( "MFN" )
DbSetOrder( 1 ) //MFN_FILIAL+MFN_CODIGO
If DbSeek( xFilial( "MFN" ) + M->MFN_CODIGO )
	Return .F.
Endif

RestArea(aArea)

Return .T.

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
Return FWMVCMenu( "LOJA7014" )

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �LJ7014Excluir �Autor  � TOTVS          � Data �  20/09/2013 ���
�������������������������������������������������������������������������͹��
���Desc.     �Valida se permite excluir, caso nao esteja sendo usado no   ���
���          � cadastro de Prevencao de Perdas                            ���
�������������������������������������������������������������������������͹��
���Uso       � Cadastro de ocorrencia                                     ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

Static Function LJ7014Excl(oModelMFN)
Local lRet	 := .T.       // retorno da funcao que habilitara a exclusao do registro
Local aArea  := GetArea() // Salva a area atual
Local cQuery :=  ""       // Texto SQL que � enviado para o comando TCGenQry

IF oModelMFN:GetOperation() == 5
	cQuery :=	" SELECT MFJ.MFJ_QUANT "+;
				" FROM 	" + RetSqlName("MFN")+" MFN, "+ RetSqlName("MFJ") + " MFJ "+;
				" WHERE MFN.MFN_FILIAL = '"+ xFilial("MFN") + "'" +;
				" AND MFN.MFN_CODIGO = '"+ MFN->MFN_CODIGO + "'" +;
				" AND MFJ.MFJ_FILIAL = MFN.MFN_FILIAL  "  +;
				" AND MFJ.MFJ_CODOCO = MFN.MFN_CODIGO   " +;            
				" AND MFJ.D_E_L_E_T_ = '' "		

	cQuery := ChangeQuery(cQuery)
		
	DbSelectArea("MFN")
	DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), 'MFNTRB', .F., .T.)

	If !Empty(alltrim(MFNTRB->MFJ_QUANT))
	     lRet := .F.
   	     Help( ,, 'Help',, STR0004, 1, 0 )//"N�o � permitido excluir esse registro."
	EndIF
    
    MFNTRB->(DbCloseArea())	
Endif
	
If lRet
	FWFormCommit(oModelMFN)
EndIf

RestArea(aArea)

return .T.