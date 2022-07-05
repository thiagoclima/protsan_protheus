#INCLUDE 'PROTHEUS.CH' 
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'LOJA7013.CH' 

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �LOJA7014   �Autor  �TOTVS              � Data �  01/07/2013 ���
�������������������������������������������������������������������������͹��
���Desc.     �MVC - Cadastro de Origem                                    ���
�������������������������������������������������������������������������͹��
���Uso       � Prevencao de perdas                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function LOJA7013()
Local oBrowse	:= NIL			// Objeto Browse

//�������������������������������Ŀ
//�Instanciamento da Classe Browse�
//���������������������������������
oBrowse := FWMBrowse():New()

//�������������������Ŀ
//�Tabela a ser aberta�
//���������������������
oBrowse:SetAlias("MFK")


//����������������Ŀ
//�Titulo do Browse�
//������������������
oBrowse:SetDescription(STR0001)//"Cadastro de Origem"

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
Local oStruMFK 	:= NIL 		// Objeto Struct
Local oModelMFK	:= NIL		// Objeto Model

//���������������������������������������������Ŀ
//�Cria Estrutura a ser usada no Modelo de Dados�
//�����������������������������������������������
oStruMFK 	:= FWFormStruct(1,'MFK')

//��������������������������������Ŀ
//�Cria o Objeto do Modelo de Dados�
//����������������������������������
oModelMFK	:= MPFormModel():New( "SYMFK", /*Pre-Validacao*/,  /*Pos-Validacao*/,  {|oModelMFK| LJ7013Excl(oModelMFK   )}/*Commit*/, /*Cancel*/ )

//���������������������������������������������Ŀ
//�Adiciona ao modelo o componente de formul�rio�
//�����������������������������������������������
oModelMFK:AddFields('MFKMASTER',/*cOwner*/,oStruMFK)

//�������������������Ŀ
//�Cria Chave Primaria�
//���������������������
oModelMFK:SetPrimaryKey( {"MFK_FILIAL","MFK_CODIGO"} )

//���������������������������������������Ŀ
//�Adiciona a descri��o do Modelo de Dados�
//�����������������������������������������
oModelMFK:SetDescription(STR0002)//"Modelo de Dados Cadastro de Origem"

//�����������������������������������������������������Ŀ
//�Adiciona a descri��o do componente do Modelo de Dados�
//�������������������������������������������������������
oModelMFK:GetModel('MFKMASTER'):SetDescription(STR0003)//'Dados Cadastro de Origem'

Return oModelMFK

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
Local oModelDef	:= NIL	 	// Objeto Define
Local oStruMFK	:= NIL		// Objeto Struct
Local oViewDef  := NIL 		// Objeto View

//���������������������������������������������������������������������������Ŀ
//�Cria um objeto de Modelo de dados baseado no ModelDef() do fonte informado �
//�����������������������������������������������������������������������������
oModelDef := FWLoadModel('LOJA7013') 

//�������������������������������������Ŀ
//�Cria a estrutura a ser usada na View �
//���������������������������������������
oStruMFK := FWFormStruct( 2,'MFK') 

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
oViewDef:AddField( 'VIEW_MFK', oStruMFK, 'MFKMASTER' )

//��������������������������������������������������������������Ŀ
//�Criar um "box" horizontal para receber algum elemento da view �
//����������������������������������������������������������������
oViewDef:CreateHorizontalBox( 'TELA' , 100 ) 

//�����������������������������������������������������������������Ŀ
//�Relaciona o identificador (ID) da View com o "box" para exibi��o �
//�������������������������������������������������������������������
oViewDef:SetOwnerView( 'VIEW_MFK', 'TELA' ) 

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
Function LJ7013OK()
Local aArea 	:= GetArea()			//Area Atual

DbSelectArea( "MFK" )
DbSetOrder( 1 ) //MFK_FILIAL+MFK_CODIGO
If DbSeek( xFilial( "MFK" ) + M->MFK_CODIGO )
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
Return FWMVCMenu( "LOJA7013" )


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �LJ7013Excluir �Autor  � TOTVS          � Data �  20/09/2013 ���
�������������������������������������������������������������������������͹��
���Desc.     �Valida se permite excluir, caso nao esteja sendo usado no   ���
���          � cadastro de Prevencao de perdas                            ���
�������������������������������������������������������������������������͹��
���Uso       � Prevencao de Perdas                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function LJ7013Excl(oModelMFK)
Local lRet	 := .T.       // retorno da funcao que habilitara a exclusao do registro
Local aArea  := GetArea() // Salva a area atual
Local cQuery :=  ""       // Texto SQL que � enviado para o comando TCGenQry

IF oModelMFK:GetOperation() == 5
	cQuery :=	" SELECT MFJ.MFJ_QUANT "+;
				" FROM 	" + RetSqlName("MFK")+" MFK, "+ RetSqlName("MFJ") + " MFJ "+;
				" WHERE MFK.MFK_FILIAL = '"+ xFilial("MFK") + "'" +;
				" AND MFK.MFK_CODIGO = '"+ MFK->MFK_CODIGO + "'" +;
				" AND MFJ.MFJ_FILIAL = MFK.MFK_FILIAL  "  +;
				" AND MFJ.MFJ_CODORI = MFK.MFK_CODIGO   " +;
				" AND MFJ.D_E_L_E_T_ = '' "		

	cQuery := ChangeQuery(cQuery)
		
	DbSelectArea("MFK")
	DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), 'MFKTRB', .F., .T.)

	If !Empty(alltrim(MFKTRB->MFJ_QUANT))
	     lRet := .F.
   	     Help( ,, 'Help',, STR0004, 1, 0 )//"N�o � permitido excluir esse registro."
	EndIF
    
    MFKTRB->(DbCloseArea())	
Endif
	
If lRet
	FWFormCommit(oModelMFK)
EndIf

RestArea(aArea)

return .T.