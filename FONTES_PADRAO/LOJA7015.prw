#INCLUDE 'PROTHEUS.CH' 
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'LOJA7015.CH' 

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �LOJA7014   �Autor  �TOTVS              � Data �  01/07/2013 ���
�������������������������������������������������������������������������͹��
���Desc.     �MVC - Cadastro de Motivo                                    ���
�������������������������������������������������������������������������͹��
���Uso       � Prevencao de perdas                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function LOJA7015()
Local oBrowse 	:= NIL			// Objeto Browse

//�������������������������������Ŀ
//�Instanciamento da Classe Browse�
//���������������������������������
oBrowse := FWMBrowse():New()

//�������������������Ŀ
//�Tabela a ser aberta�
//���������������������
oBrowse:SetAlias("MFM")


//����������������Ŀ
//�Titulo do Browse�
//������������������
oBrowse:SetDescription(STR0001)//"Cadastro de Motivo"

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
Local oStruMFM  	:= NIL		// Objeto Struct
Local oModelMFM 	:= NIL		// Objeto Model

//���������������������������������������������Ŀ
//�Cria Estrutura a ser usada no Modelo de Dados�
//�����������������������������������������������
oStruMFM 	:= FWFormStruct(1,'MFM')

//��������������������������������Ŀ
//�Cria o Objeto do Modelo de Dados�
//����������������������������������
oModelMFM      := MPFormModel():New( 'SYMFM', /*Pre-Validacao*/,  /*Pos-Validacao*/,  {|oModelMFM| LJ7015Excl(oModelMFM   )}/*Commit*/, /*Cancel*/ )

//���������������������������������������������Ŀ
//�Adiciona ao modelo o componente de formul�rio�
//�����������������������������������������������
oModelMFM:AddFields('MFMMASTER',/*cOwner*/,oStruMFM)

//�������������������Ŀ
//�Cria Chave Primaria�
//���������������������
oModelMFM:SetPrimaryKey( {"MFM_FILIAL","MFM_CODIGO"} )

//���������������������������������������Ŀ
//�Adiciona a descri��o do Modelo de Dados�
//�����������������������������������������
oModelMFM:SetDescription(STR0002)//'Modelo de Dados Cadastro de Motivo

//�����������������������������������������������������Ŀ
//�Adiciona a descri��o do componente do Modelo de Dados�
//�������������������������������������������������������
oModelMFM:GetModel('MFMMASTER'):SetDescription(STR0003)//'Dados Cadastro de Motivo'

Return oModelMFM

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
Local oStruMFM 		:= NIL		// Objeto Struct
Local oViewDef   	:= NIL 		// Objeto View

//���������������������������������������������������������������������������Ŀ
//�Cria um objeto de Modelo de dados baseado no ModelDef() do fonte informado �
//�����������������������������������������������������������������������������
oModelDef := FWLoadModel('LOJA7015') 

//�������������������������������������Ŀ
//�Cria a estrutura a ser usada na View �
//���������������������������������������
oStruMFM := FWFormStruct( 2,'MFM') 

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
oViewDef:AddField( 'VIEW_MFM', oStruMFM, 'MFMMASTER' )

//��������������������������������������������������������������Ŀ
//�Criar um "box" horizontal para receber algum elemento da view �
//����������������������������������������������������������������
oViewDef:CreateHorizontalBox( 'TELA' , 100 ) 

//�����������������������������������������������������������������Ŀ
//�Relaciona o identificador (ID) da View com o "box" para exibi��o �
//�������������������������������������������������������������������
oViewDef:SetOwnerView( 'VIEW_MFM', 'TELA' ) 

Return oViewDef

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �VlCampo   �Autor  �TOTVS               � Data �  01/07/2013 ���
�������������������������������������������������������������������������͹��
���Desc.     �Valida se o codigo ja existe                                ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function LJ7015OK()
Local aArea 	:= GetArea()			//Area Atual

DbSelectArea( "MFM" )
DbSetOrder( 1 ) //MFM_FILIAL+MFM_CODIGO
If DbSeek( xFilial( "MFM" ) + M->MFM_CODIGO )
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
Return FWMVCMenu( "LOJA7015" )

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

Static Function LJ7015Excl(oModelMFM)
Local lRet	 := .T.       // retorno da funcao que habilitara a exclusao do registro
Local aArea  := GetArea() // Salva a area atual
Local cQuery :=  ""       // Texto SQL que � enviado para o comando TCGenQry

IF oModelMFM:GetOperation() == 5
	cQuery :=	" SELECT MFJ.MFJ_QUANT "+;
				" FROM 	" + RetSqlName("MFM")+" MFM, "+ RetSqlName("MFJ") + " MFJ "+;
				" WHERE MFM.MFM_FILIAL = '"+ xFilial("MFM") + "'" +;
				" AND MFM.MFM_CODIGO = '"+ MFM->MFM_CODIGO + "'" +;
				" AND MFJ.MFJ_FILIAL = MFM.MFM_FILIAL  "  +;
				" AND MFJ.MFJ_CODORI = MFM.MFM_CODIGO   " +;
				" AND MFJ.D_E_L_E_T_ = '' "		

	cQuery := ChangeQuery(cQuery)
		
	DbSelectArea("MFM")
	DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), 'MFMTRB', .F., .T.)

	If !Empty(alltrim(MFMTRB->MFJ_QUANT))
	     lRet := .F.  
  	     Help( ,, 'Help',, STR0004, 1, 0 )//"N�o � permitido excluir esse registro."
	EndIF
    
    MFMTRB->(DbCloseArea())	
Endif
	
If lRet
	FWFormCommit(oModelMFM)
EndIf

RestArea(aArea)

return .T.