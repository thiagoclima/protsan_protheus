#INCLUDE "MSOBJECT.CH"
#INCLUDE "PROTHEUS.CH"


Function LOJA7012 ; Return  // "dummy" function - Internal Use

/*
������������������������������������������������������������������������������������
������������������������������������������������������������������������������������
��������������������������������������������������������������������������������ͻ��
���Classe    |LjClSE1          �Autor  �Vendas Clientes     � Data �  03/12/2010 ���
��������������������������������������������������������������������������������͹��
���Desc.     �Classe de T�tulos      									         ���
��������������������������������������������������������������������������������͹��
���Uso       �SigaLoja / FrontLoja                                        		 ���
��������������������������������������������������������������������������������ͼ��
������������������������������������������������������������������������������������
������������������������������������������������������������������������������������
*/
Class LjClSE1
   	
	Data cChave //Chave do SE1E1_FILIAL+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO                                                                                                                  
	Data nIndice //Indice da chave do SE1 =:1
	Data cE1_SITUACA //Situacao do titulo
	Data dE1_EMISSAO //Emiss�o do t�tulo
	Data dE1_VENCTO //Vencimento do t�tulo
	Data dE1_BAIXA //Data da Baixa do t�tulo
	Data cE1_STATUS //Status do t�tulo
	Data cE1_PARCELA //Parcela do t�tulo
	Data cE1_TIPO   //Tipo do T�tulo
	Data nE1_SALDO  //Saldo do t�tulo
	Data cE1_ORIGEM //Origem do t�tulo    
	Data nE1_VALOR  //Valor do t�tulo
	Data cE1_NUMCRD //Numero do Contrato de financiamento
	Data cE1_PORTADO //Portador do T�tulo 
	Data nE1_VLRREAL //Valor Real do t�tulo
  	Data cE1_FLUXO  //Fluxo de Caixa      
  	Data aSE5       //Pagamentos do T�tulo
	
	
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �LOJA7008  �Autor  �Microsiga           � Data �  03/12/2010 ���
�������������������������������������������������������������������������͹��
���Desc.     �                                                            ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/	
Method New()  
	    
EndClass  


/*

/*
�������������������������������������������������������������������������������������
�������������������������������������������������������������������������������������
���������������������������������������������������������������������������������ͻ��
���Metodo    |New              �Autor  �Fabiana Cristina     � Data �  03/12/2010 ���
���������������������������������������������������������������������������������͹��
���Desc.     �Metodo que Instancia o objeto                                       ���
���������������������������������������������������������������������������������͹��
���Uso       �SigaLoja                                                     		  ���
���������������������������������������������������������������������������������ͼ��
�������������������������������������������������������������������������������������
�������������������������������������������������������������������������������������
*/

Method New(cChave, nIndice)  Class LjClSE1  

	Self:cChave := cChave //Chave do SE1E1_FILIAL+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO                                                                                                                  
	Self:nIndice := nIndice //Indice da chave do SE1 =:1
	Self:cE1_SITUACA := ""//Situacao do titulo
	Self:dE1_EMISSAO := nil//Emiss�o do t�tulo
	Self:dE1_VENCTO := nil//Vencimento do t�tulo
	Self:dE1_BAIXA  := nil//Data da Baixa do t�tulo
	Self:cE1_SITUACA := ""//Situa��o do t�tulo
	Self:cE1_STATUS := ""//Status do t�tulo
	Self:cE1_PARCELA := ""//Parcela do t�tulo
	Self:cE1_TIPO  := "" //Tipo do T�tulo
	Self:nE1_SALDO  := 0//Saldo do t�tulo
	Self:cE1_ORIGEM := ""//Origem do t�tulo    
	Self:nE1_VALOR  := 0//Valor do t�tulo
	Self:cE1_NUMCRD := ""//Numero do Contrato de financiamento
	Self:cE1_PORTADO := ""//Portador do T�tulo 
	Self:nE1_VLRREAL := 0 //Valor Real do t�tulo
  	Self:cE1_FLUXO := ""  //Fluxo de Caixa   
  	Self:aSE5 := {}

Return Nil   
