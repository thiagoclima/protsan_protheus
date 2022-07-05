#INCLUDE "MSOBJECT.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "LOJA7010.CH"
#INCLUDE "AUTODEF.CH"
#INCLUDE "STPOS.CH"
 
#Define __L2_VLRITEM  05
#Define __L2_VRUNIT   04 
#Define __L2_PRODUTO  01 
#Define __L2_DESCRI   02 
#Define __L2_QUANT    03
#DEFINE __TECBAN   "TECBAN HOST HOST" 

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
#Define __L4_INSTITU 23
#Define __L4_BANDEIR 24
#Define __L4_REDEAUT 25
#Define __TP_TRANS	 26
#Define __L4_TRNID	 27 //ID da Transa็ใo (Payment Hub)
#Define __L4_TRNPCID 28 //ID Transa็ใo Processador (Payment Hub)
#Define __L4_TRNEXID 29 //ID da Transa็ใo Externa (Payment Hub)
#Define __L4_TAMANHO 29                           

#DEFINE TEF_NAOUTILIZA          "1"
#DEFINE TEF_SEMCLIENT_DEDICADO  "2"
#DEFINE TEF_COMCLIENT_DEDICADO  "3"
#DEFINE TEF_DISCADO             "4"
#DEFINE TEF_LOTE                "5" 
#DEFINE TEF_CLISITEF   		    "6"

#Define CRLF CHR(13)+CHR(10)      

Static lMVLJPDVPA := FindFunction("LjxBGetPaf") .AND. LjxBGetPaf()[2] //SIGALOJA OFFLINE - PDV PAF


Function LOJA7010 ; Return  // "dummy" function - Internal Use

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบClasse    |LjClEstVen       บAutor  ณVendas Clientes     บ Data ณ  19/11/2010 บฑฑ
ฑฑฬออออออออออุอออออออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณClasse de Estorno de Vendas   							         บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSigaLoja / FrontLoja                                        		 บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Class LjClEstVen
   	
	Data cSerie                                                            //Serie da Orcamento
	Data cPDV	                                                           //N๚mero do PDV
	Data cFilOrc                                                           //Filial do Or็amento
	Data cNumCaixa                                                         //Codigo do Caixa
	Data dDtBase                                                           //DataBase do Caixa
	Data nSeqMov                                                           //Sequencia de Movimento do caixa
    Data oDlgOrc		                                               	   //Diaแlogo do Or็amento
	Data lOffLine		                                                   //Busca do Or็amento OffLine
	Data lRetag                                                            //Execu็ใo na Retaguarda
    Data lRetagOrc                                                         //Or็amento na Retaguarda
    Data nAcesso                                                           //Codigo do profile da rotina de estorno    
  	Data cOrcamento                                                        //Or็amento
    Data dOrc_Emissao	                                                   //Data de Emissใo do Orcamento
    Data cOrc_Situa                                                         //Situa็ใo do Orcamento no Job FRTA020
    Data cOrc_StOrc                                                         //Situa็ใo do Orcamento  
	Data cOrc_Tipo                                                         //Tipo do Or็amento
    Data cOrc_Cupom 													   //N๚mero do Cupom
    Data cOrc_Opera                                                        //Operador do Orcamento
    Data cOrc_Pdv                                                          //Pdv do Orcamento
    Data cOrc_Cli                                                          //Cliente do Orcamento
    Data cOrc_Loja	                                                       //Loja do Cliente
    Data cOrc_Ven                                                          //Vendedor do Orcamento
    Data nOrc_VlMer                                                        //Total de Mercadoria
    Data nOrc_Desc                                                         //Desconto
    Data nOrc_VlLiq                                                        //Valor Liquido
    Data nOrc_Abat                                                         //Total de Abatimentos
    Data dOrc_Valid                                                        //Validade do Orcamento
    Data cOrc_PedCli                                                       //Pedido do Cliente
	Data nOrc_Imp	                                                       //Impostos do Orcamneto
	Data nOrc_ImpIn                                                        //Total da Venda 
	Data nOrc_VlTot
	Data nOrc_Moeda                                                        //Moeda do orcamento
	Data cOrc_VendTEF                                                      //Venda com L1_VENDTEF
	Data cOrc_DocCanc                                                      //Documento de Cancelamento do TEf L1_DOCCANC
	Data cOrc_FormPg                                                       //Formas de pagamento L1_FORMPG
	Data cOrc_DatCanc                                                      //Data de Cancelamento TEF
	Data cOrc_HorCanc                                                      //Hora de Cancelamento TEF
	Data cOrc_DocTEF                                                       //Documento da Transa็ใo TEF
	Data cOrc_Institu                                                      //Gerenciador do TEF
	Data aOrc_Itens                                                        //Itens do Orcamento
	Data aOrc_Pagtos                                                       //Pagamentos do Orcamento   
    Data cOrc_StatuEs                                                      //Status do Estorno
    Data cOrc_CupFis                                                       //Numero do Cupom Fiscal quando haver entrega+retira nos itens
    Data cOrc_SerCF                                                        //Serie do Cupom Fiscal quando haver entrega+retira nos itens
	Data lOrc_PedAb															// Indica se Pedido em aberto possibilitando estorno
    Data cURLWebService                                                    //URL do WebService 
    Data cMensagem                                                         //Mensagem de Valida็ใo do orcamento na retaguarda 
    Data aSE1                                                            	//Titulos do Orcamento
    Data aQuery                                                            //Fitro do SL1
    Data lOrc_MovFe                                                        //Orcamento estแ no movimento de caixa fechado
	Data lCliPad														  // Orcamento realizado para cliente padrใo	
	Data aOrc_Res														   //Reservas do Orcamento
	Data lJob                                                              //Execucao em Job 
	Data lAutomato                                                         //Definir se a chamada estแ sendo realizada do Robo de Testes
	Data nCredito                                                          // Valor do campo L1_CREDITO 	 
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณLOJA7010  บAutor  ณMicrosiga           บ Data ณ  11/24/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/	
	Method New()  
	Method ExibeFrmCupom() 
	Method BuscaOrcamento()                                               //Busca o Orcamento 
	Method BuscaWsOrcamento()                                             ///Busca o Orcamento pelo WS
	Method ConfirmaOrcamento()                                           //Verifica se o orcamento ้ valido, ou seja, nใo estornada e a data da venda ้ no mesmo dia do movimento
	Method ValidaOrcamento()                                             //Verifica Acesso a rotina  de estorno
	Method Acesso()			                                              //Verifica de o usuario possui acesso para realizar o estorno
	Method GetOrcamento()                                                //Busca dados do orcamento.
	Method OrcDevolvido()                                                 //Verifica se o Orcamento foi devolvido ou nใo
	Method OrcWsDevolvido()                                               //Executa um WebService e verifica se o Orcamento foi devolvido ou nใo
	Method RealizaEstorno()                                               //Realiza o Estorno da Venda
	Method RealizaRpcEstorno()											  //Realiza o Estorno da Venda via Componente de comunicacao
	Method BuscaItensOrcamento()                                           //Busca os Itens do Orcamento
	Method BuscaWsItensOrcamento()										  //Executa o WS de Busca de Itens do Orcamento
	Method BuscaPagtosOrcamento()                                         //Busca os Pagamentos do Orcamento
	Method BuscaWsPagtosOrcamento()                                       //Executa o WS de busca de pagamentos
	Method OrcValReserva()                                                //Executa o m้todo de valida็ใo da reserva
    Method OrcWsValReserva()                                              //Executa o Ws de Valida็ใo da REserva   
    Method BuscaTitulosOrcamento()                                        //Busca os titulos do Orcamento
    Method BuscaWsTitulosOrcamento()                                       //Executa o Ws de titulos do Orcamento
    Method TEFCancela(lProssegue)                                          //Metodo que cancela a transacaoTEF
    Method TEFGenericoCancela()                                            //Metodo que cancela a transacao TEF Generico
    Method TEFSitefCancela(lProssegue)		//Metodo que cancela a transacaoTEF SiTEF
    Method BuscaChequesOrcamento()                                         //Metodo que busca os cheques do Orcamento
    Method BuscaWsChequesOrcamento()                                       //Metodo que busca os cheques do Orcamento via WS  
    Method CalculaParcelas()                                               //Metodo que calcula as parcelas dos pagamentos  
    Method PagtoPodeCompensar()                                            //Metodo que verifica se o pagamento pode ser estornado
    Method ImpCupEstorno()                                                	//Metodo que imprime o comprovante de Estorno
    Method GrvDadosPgto()                                                 	//Metodo que grava os dados do pagamento
	Method PagtoDigitalCancela()								   		 	//Metodo que cancela a transacao de Pagamento Digital
EndClass  


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออออออหอออออออัอออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบMetodo    |New              บAutor  ณFabiana Cristina     บ Data ณ  19/11/2010 บฑฑ
ฑฑฬออออออออออุอออออออออออออออออสอออออออฯอออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณMetodo que Instancia o objeto                                       บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ  
ฑฑบParametrosณ ExpC1 = Serie do PDV                                               บฑฑ
ฑฑบ          ณ ExpC2 = Caixa do PDV                                               บฑฑ
ฑฑบ          ณ ExpC3 = Numero do PDV                                              บฑฑ  
ฑฑบ          ณ ExpD4 = Database do Sistema                                        บฑฑ
ฑฑบ          ณ ExpN5 = Sequencia de Movimento do Caixa                            บฑฑ
ฑฑบ          ณ ExpA6 = Filtro do MBrowse                                          บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSigaLoja/SigaFRT                                             		  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Method New(cSerie	, cCaixa	, cPDV	, dDtBase	,;
           nSeqMov	, lRetag	, aQuery )  Class LjClEstVen
	Self:cSerie 		:= cSerie 
	Self:cNumCaixa	    := cCaixa
	Self:cOrcamento 	:= ""
	Self:cFilOrc		:= ""
	Self:cPDV		:= cPDV
	Self:dDtBase    := dDtBase
	Self:nSeqMov	:= nSeqMov 
	Self:lOffLine   := .F.
	Self:lRetag     := lRetag  
	Self:lRetagOrc  := .F.  
	Self:dOrc_Emissao := Ctod("")
	Self:cURLWebService := IIF(lRetag, "", "http://"+AllTrim(LJGetStation("WSSRV"))+"/LJESTORC.apw")                                              
   	Self:cOrc_Situa := ""
    Self:cOrc_StOrc := "" 
    Self:nAcesso	:= 29
    Self:cOrc_Tipo	:= "" 
    Self:cOrc_Cupom := ""													   //N๚mero do Cupom
    Self:cOrc_Opera := ""                                                       //Operador do Orcamento
    Self:cOrc_Pdv  := ""                                                    
    Self:cOrc_Cli := ""                                                         
    Self:cOrc_Loja	:= ""
    Self:cOrc_Ven := ""                                                         
    Self:nOrc_VlMer := 0                                                       
    Self:nOrc_Desc := 0                                                        
    Self:nOrc_VlLiq := 0                                                      
    Self:nOrc_Abat  := 0                                                       
    Self:dOrc_Valid := Ctod("")                                                                                                    
    Self:cOrc_PedCli := ""                                                   
	Self:nOrc_Imp	:= 0                                                      
	Self:nOrc_ImpIn := 0                                                       
	Self:nOrc_VlTot := 0
	Self:nOrc_Moeda := 0                                                    
	Self:cOrc_VendTEF := ""
	Self:cOrc_DocCanc := ""
	Self:cOrc_FormPg := ""
	Self:cOrc_DatCanc := ""                                                     
	Self:cOrc_HorCanc := ""
	Self:aOrc_Itens	:= {}
	Self:aOrc_Pagtos := {} 
	Self:cMensagem := ""
	Self:aSE1	    := {}
    Self:aQuery		:= aQuery
    Self:cOrc_StatuEs	:= ""
    Self:cOrc_DocTEF    := ""   
	Self:cOrc_Institu   := ""                                                   
    Self:lOrc_MovFe		:= .F.   
    Self:cOrc_CupFis	:= ""
    Self:cOrc_SerCF     := ""   
	Self:lOrc_PedAb		:= .T.
    Self:aOrc_Res		:= {}	
    Self:lJob			:= .F. 
    Self:lCliPad		:= .F.
    Self:lAutomato      := If(Type("lAutomatoX")<>"L",.F.,lAutomatoX)
    Self:nCredito       := 0 
Return Nil  

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออออออหอออออออัอออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบMetodo    | BuscaOrcamento  บAutor  ณFabiana Cristina     บ Data ณ  19/11/2010 บฑฑ
ฑฑฬออออออออออุอออออออออออออออออสอออออออฯอออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณMetodo que busca um orcamento                                       บฑฑ 
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ 
ฑฑบParametrosณ ExpC1 = Numero do Cupom                                            บฑฑ
ฑฑบ          ณ ExpC2 = Serie do Cupom                                             บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSigaLoja                                                     		  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Method BuscaOrcamento(cCupom, cSerie) Class LjClEstVen    
   
	Local aAreaSL1 := SL1->(GetArea()) //Area da tabela de Orcamentos	
	
	Self:cSerie  := cSerie //A็tera a propriedade da s้rie para a s้rie informada     
	
	cSerie := PadR(cSerie, TamSX3("L1_SERIE")[1])  
	
	cCupom := PadR(cCupom, TamSX3("L1_DOC")[1])
		
	If !Empty(cCupom) .and. !Empty(cSerie)   
	
	       If Self:lRetag .or. Self:lOffline
	        
			   DbSelectArea("SL1") 
			   
			   Sl1->(DbCloseArea())
			   
			   DbSelectArea("SL1")
			   
			   SL1->(DbSetOrder(2)) //L1_FILIAL+L1_SERIE+L1_DOC+L1_PDV   
			   
			   If ! SL1->(DbSeek(xFilial("SL1") + cSerie + cCupom  ))	
			      
			      SL1->(DbSetOrder(11))//L1_FILIAL+L1_SERPED+L1_DOCPED 
			      
			      
			      SL1->(DbSeek(xFilial("SL1") + cSerie + cCupom)) 
			          		   
	
			   EndIf 
	     		                                                                                                                                  			    			 
				       			
				If  SL1->(Found())
	   			    Self:GetOrcamento()
				EndIf
				
			Else 
			     
			    //Executa WS				       			
				Self:BuscaWsOrcamento(cCupom, cSerie)  
				
			EndIf
	   

	EndIf 
	
	RestArea(aAreaSl1)

Return Self //Retorna o Objeto


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออออออหอออออออัอออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบMetodo    |ExibeFrmCupom    บAutor  ณFabiana Cristina     บ Data ณ  19/11/2010 บฑฑ
ฑฑฬออออออออออุอออออออออออออออออสอออออออฯอออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณMetodo que exibe a janela para digita็ao do numero do cupom e serie บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSigaLoja                                                     		  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Method ExibeFrmCupom() Class LjClEstVen
Local oDlgCupom := nil //Janela para informar o Numero do Cupom e Serie

	oDlgCupom := LJCFrmCupom():New(Self)
	
	If !Self:lAutomato
		oDlgCupom:Show()
    EndIf
	oDlgCupom := nil
Return  



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออออออออหอออออออัอออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบMetodo    | ConfirmaOrcamento บAutor  ณFabiana Cristina     บ Data ณ  19/11/2010 บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออสอออออออฯอออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณMetodo que exibe a janela para confirma็ใo do orcamento               บฑฑ 
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ ExpN1 = Op็ใo da Operacao 4 Altera, 2 Visualiza                      บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSigaLoja                                                     	        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Method ConfirmaOrcamento(nOpcX) Class LjClEstVen 
Local lProssegue := .F. //Prossegue com a rotina?
Local oFrmOrc := Nil    //Janela com os dados do Orcamento
Local nC   := 0         //Contador de registros de Pagamentos

Self:BuscaItensOrcamento()         

If cPaisLoc == "BRA" //Considera o valor do ICMS solidario
	Self:nOrc_VlTot += Self:nOrc_Imp
EndIf 
	

  
If Len(::aOrc_Itens) > 0
	Self:BuscaPagtosOrcamento()
EndIf   

If Len(::aOrc_Pagtos) > 0 .Or. ::nCredito > 0
	If cPaisloc <> "BRA"
		Self:nOrc_VlLiq -= Self:nOrc_Imp
	EndIf
	
	oFrmOrc := LJEstFrmVenda():New(Self, nOpcX)
	If !Self:lAutomato
		oFrmOrc:Show() 
	Endif
	    
	If (lProssegue := oFrmOrc:lProssegue)  .and. !Self:lOrc_MovFe 
		
		//Pagamento em TEF Discado, verifica se os pagamentos forma estornados manualmente	
		Do While (nC := nC + 1) <= Len(::aOrc_Pagtos)		
			::aOrc_Pagtos[nC, __PORTE ] := oFrmOrc:aColsPg[nC, __PORTE]
			If AllTrim(::aOrc_Pagtos[nC, __L4_FORMA]) $ _FORMATEF .and. Empty(Self:cOrc_DocTEF) .and. oFrmOrc:nPosEst > 0
				::aOrc_Pagtos[nC, __L4lEstorn ] := (oFrmOrc:aColsPg[nC, oFrmOrc:nPosEst] = "1") //Pagamento em cartใo estornado  
			Else
				If !Empty(::aOrc_Pagtos[nC, __PORTE ]) 
					::aOrc_Pagtos[nC, __L4lEstorn ] := (::aOrc_Pagtos[nC, __PORTE ] <> "2")
				EndIf
			EndIf	
 
		EndDo
		oFrmOrc := nil
	EndIf
	
EndIf  
  
Return lProssegue      


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออออออหอออออออัอออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบMetodo    | BuscaWSOrcamentoบAutor  ณFabiana Cristina     บ Data ณ  22/11/2010 บฑฑ
ฑฑฬออออออออออุอออออออออออออออออสอออออออฯอออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณMetodo que executa um WebService de busca de orcamento na retaguradaบฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ ExpC1 = Numero do Cupom                                            บฑฑ
ฑฑบ          ณ ExpC2 = Serie do Cupom                                             บฑฑ  
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSigaLoja                                                     		  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method BuscaWsOrcamento(cCupom, cSerie) Class LjClEstVen 
Local oWsOrcamento := Nil  //Objeto WebService


 oWsOrcamento := WSLJESTORC():New()   
 oWsOrcamento:_URL := Self:cURLWebService     
 
 If !oWsOrcamento:LjEstOrcBus(cCupom, cSerie, cEmpAnt, cFilAnt) 
 	Self:lOffLine := .T. //Configura o objeto estorno para off-line, pois nใo conseguiu conexใo com a retaguarda
	If !Self:lJob
   		MsgAlert(STR0002+CRLF+STR0011)
    EndIf
	Self:BuscaOrcamento(cCupom, cSerie)
 Else                      
    
    If !Empty(Self:cOrcamento   := oWsOrcamento:oWSLJESTORCBUSRESULT:cOrcamento)
		Self:cOrc_Cupom   := oWsOrcamento:oWSLJESTORCBUSRESULT:cOrc_Cupom
	    Self:cSerie 	  := oWsOrcamento:oWSLJESTORCBUSRESULT:cSerie
	 	
	 	Self:cOrcamento   := oWsOrcamento:oWSLJESTORCBUSRESULT:cOrcamento
	    Self:dOrc_Emissao := StoD(oWsOrcamento:oWSLJESTORCBUSRESULT:cOrc_Emissao)	                                                   
	   	Self:cOrc_Situa   := oWsOrcamento:oWSLJESTORCBUSRESULT:cOrc_Situa 
	   	Self:cOrc_StOrc   := oWsOrcamento:oWSLJESTORCBUSRESULT:cOrc_StOrc 
	   	Self:cOrc_Tipo    := oWsOrcamento:oWSLJESTORCBUSRESULT:cOrc_Tipo 
	    Self:cOrc_Opera   := oWsOrcamento:oWSLJESTORCBUSRESULT:cOrc_Opera                                                    
	    Self:cOrc_Pdv  	  := oWsOrcamento:oWSLJESTORCBUSRESULT:cOrc_Pdv                                                 
	    Self:cOrc_Cli     := oWsOrcamento:oWSLJESTORCBUSRESULT:cOrc_Cli  
	    Self:cOrc_Loja    := oWsOrcamento:oWSLJESTORCBUSRESULT:cOrc_Loja                                                  
	    Self:cOrc_Ven     := oWsOrcamento:oWSLJESTORCBUSRESULT:cOrc_Ven                                                       
	    Self:nOrc_VlMer   := oWsOrcamento:oWSLJESTORCBUSRESULT:nOrc_VlMer                                                      
	    Self:nOrc_Desc    := oWsOrcamento:oWSLJESTORCBUSRESULT:nOrc_Desc                                                   
	    Self:nOrc_VlLiq   := oWsOrcamento:oWSLJESTORCBUSRESULT:nOrc_VlLiq                                                     
	    Self:dOrc_Valid   := StoD(oWsOrcamento:oWSLJESTORCBUSRESULT:cOrc_Valid)                                                      	 
	    Self:nOrc_Abat    := oWsOrcamento:oWSLJESTORCBUSRESULT:nOrc_Abat                                                                                                       
	    Self:cOrc_PedCli  := oWsOrcamento:oWSLJESTORCBUSRESULT:cOrc_PedCli   
	    Self:nOrc_VlTot   := oWsOrcamento:oWSLJESTORCBUSRESULT:nOrc_VlTot    
	    Self:nOrc_Moeda   := oWsOrcamento:oWSLJESTORCBUSRESULT:nOrc_Moeda
	    Self:cOrc_VendTEF := oWsOrcamento:oWSLJESTORCBUSRESULT:cOrc_VendTEF
		Self:cOrc_DocCanc := oWsOrcamento:oWSLJESTORCBUSRESULT:cOrc_DocCanc
		Self:cOrc_FormPg := oWsOrcamento:oWSLJESTORCBUSRESULT:cOrc_FormPg
	    Self:cOrc_DocTEF := oWsOrcamento:oWSLJESTORCBUSRESULT:cOrc_DocTEF   
	    Self:lOrc_MovFe := oWsOrcamento:oWSLJESTORCBUSRESULT:lOrc_MovFe
	    Self:cOrc_Institu := oWsOrcamento:oWSLJESTORCBUSRESULT:cOrc_Institu  
	    Self:cOrc_StatuEs := oWsOrcamento:oWSLJESTORCBUSRESULT:cOrc_StatuEs    
	    

	    
	 	Self:lRetagOrc  := .T.  //Configura o or็amento para estar na retaguarda  
	 	Self:lCliPad    := oWsOrcamento:oWSLJESTORCBUSRESULT:lCliPad //Cl็iente Padrao 
	 Else  
	 	Self:lOffLine := .T. //Configura o objeto estorno para off-line, pois nใo conseguiu conexใo com a retaguarda
   		If !Self:lJob
   			MsgAlert(STR0011)
		EndIf
		Self:BuscaOrcamento(cCupom, cSerie)
	 EndIf
 EndIf

Return 
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออออออออหอออออออัอออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบMetodo    | ValidaOrcamento   บAutor  ณFabiana Cristina     บ Data ณ  19/11/2010 บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออสอออออออฯอออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณMetodo que verifica se o orcamento ้ vแlido                           บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ 
ฑฑบParametrosณ ExpN1 = Op็ใo da Operacao 4 Altera, 2 Visualiza                      บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSigaLoja                                                     	        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/   

Method ValidaOrcamento(nOpc,lRemote) Class LjClEstVen 

Local 	lRet 		:= .F.  //Orcamento Valido?
Local	lCentPDV 	:= Iif( FindFunction("LjGetCPDV"), LjGetCPDV()[1] , .F. ) //Central de PDV?   

Default nOpc 		:= 4 
Default lRemote 	:= .F. //Execucao remota

If !Empty(Self:cOrcamento)

    If nOpc = 4 
    	//-- Se for Central de PDV Chamada Remota nao valida data
    	If !lRemote
			If !Self:lJob
				lRet := (Self:dOrc_Emissao == Self:dDtBase) 
			Else
				lRet := .T.
			EndIf      
		Else
			lRet := .T. 
		EndIf 
		
		lRet := lRet .and. Self:cOrc_StOrc <> "E" .and. Self:cOrc_StOrc <> "C" .and. Self:cOrc_Tipo <> "D" .And. (Self:cOrc_Tipo  $ "PV")  // data de emissใo deve ser igual a database e o or็amento nใo pode estar estornado
		
		If Self:lRetagOrc .or. Self:lRetag //Se orcamento estiver na retaguarda lRetagOrc or lRetag, valida a situa็ใo como OK  e nใo estornado
			If lCentPDV
				lRet :=  lRet .and. (Empty(Self:cOrc_Situa) .or. Self:cOrc_Situa == "TX") 
			Else 
				lRet :=  lRet .and. (padr(Self:cOrc_Situa,2)+"|"$"  |OK|FR|" ) 
			EndIf	
		Else 
			//Orcamento pode ou nใo estar na retaguarda, valida a situa็ใo como nใo estornada 
			If Self:lOffLine  
				//Quando estแ offline, podemos ter: Or็amento Nใo Enviado ("00") ou Enviado ("TX")
				lRet := lRet .and. (Self:cOrc_Situa == "00" .OR. Self:cOrc_Situa == "TX")
			EndIf
		EndIf
		
		lRet := lRet .and. Empty(Self:cOrc_StatuEs) //Orcamento nใo esta estornado  
		
		If lRet
			lRet := !Self:OrcDevolvido(Self:cOrcamento) //Verifica se o or็amento estแ devolvido
		EndIf
		
		If !lRet         
			Self:cMensagem := STR0003+CRLF+CRLF+; // "Venda nใo poderแ ser cancelada, em virtude de um dos motivos abaixo:"  
				         "- "+STR0006+CRLF+;   //"Or็amento cancelado.		          
				         "- "+STR0004+CRLF+;     //"Venda realizada fora da data vigente."
				         "- "+STR0005+CRLF+;//"Venda estornada."
				         "- "+STR0009+CRLF+;  //""Venda com devolu็ใo pendente."
				         "- "+STR0056+CRLF+; //"Venda de outro caixa nใo processada na retaguarda." 
				         "- "+STR0010
			If !Self:lJob
				MsgInfo(Self:cMensagem) //"Venda devolvida."
			EndIf
		Else
			//Verifica valida็๕es adicionais do or็amento, na retaguarda
			
			
			If 	Self:lRetagOrc .or. Self:lRetag //Or็amento esta na retagura	da entใo valida as reservas
			
				lRet := Self:OrcValReserva(Self:cOrcamento)
				
				If !lRet 
					If !Self:lJob
						MsgInfo(Self:cMensagem)
					EndIf
				EndIf   
				
			Else
				//Venda Offline - Verifica se o PDV do orcamento ้ o PDV da Venda
				If Self:lOffLine
					lRet := RTrim(Self:cPDV) == Rtrim(Self:cOrc_PDV)
					If !lRet 
						Self:cMensagem := STR0021//"PDV OffLine. So ้ possํvel estorno de vendas geradas nesta esta็ใo."
						If !Self:lJob
							MsgInfo(Self:cMensagem)
						EndIf
					EndIf
				EndIf
			EndIf
	
			
		EndIf
		
		// Valida se or็amento possui pedido e se ainda nใo foi faturado
		If Self:lOrc_PedAb <> NIL .AND. !Self:lOrc_PedAb
			lRet := .F.
		EndIf

	Else	
		lRet := .T.
	EndIf
		  
Else 
	Self:cMensagem := STR0001
	If !Self:lJob
   		MsgAlert(Self:cMensagem)
    EndIf
EndIf

Return lRet 

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออออออออหอออออออัอออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบMetodo    | Acesso            บAutor  ณFabiana Cristina     บ Data ณ  23/11/2010 บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออสอออออออฯอออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณMetodo que verifica o acesso a rotina de estono                       บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSigaLoja                                                     	        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/ 
Method Acesso() Class LjClEstVen 
Local aPermissao := {}   //Permissoes do Caixa
Local lRet := .T.        //Usuario possui acesso?
Local nPosacess := 0     //Posicao do Acesso de Estorno da Venda

aPermissao := LJ120Permi() 

nPosacess := aScan( aPermissao, { |x| x[1] == Self:nAcesso } )   

If nPosacess == 0
	cStrAcesso := Subst( cStrAcesso, 1, Self:nAcesso - 1 ) + "N" + Subst( cStrAcesso, Self:nAcesso + 1 )
                                     
EndIf             
 

If !(lRet := SubStr( cStrAcesso, Self:nAcesso, 1 ) <> "N")
	MsgAlert(STR0008) 
EndIf

Return lRet 


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออออออออหอออออออัอออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบMetodo    |GetOrcamento       บAutor  ณFabiana Cristina     บ Data ณ  23/11/2010 บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออสอออออออฯอออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณMetodo que carrega as propriedades do Orcamento                       บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSigaLoja                                                     	        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/ 
Method GetOrcamento() Class LjClEstVen 
Local aAreaSL1 := SL1->(GetArea()) //WorkArea SL1
Local aAreaMBZ := nil   			//WorkArea MBZ
Local cChave := ""                  //Chave de Busca
Local aAreaSLW := nil               //WorkArea SLW
Local cOrPai := "" 					//Orcamento-pai que originou a venda
Local lUpdConf := SuperGetMV("MV_LJCONFF",.T.,.F.) .AND. IIf(FindFunction("LjUpd70Ok"),LjUpd70Ok(),.F.)//Confer๊ncia de caixa ativada    FNC 00000019711/2010
Local cCliPad := SuperGetMV("MV_CLIPAD")
Local cLojaPad := SuperGetMV("MV_LOJAPAD")
Local lCliRecIss := .F.				// Cliente recolhe Iss
Local aOrcamento := {}				// Dados do or็amento

If Empty(cOrPai := SL1->L1_ORCRES) //E Orcamento-pai, entใo buscao os itens

	Self:cOrcamento   := SL1->L1_NUM
	Self:dOrc_Emissao := SL1->L1_EMISSAO	                                                   
	Self:cOrc_Situa   := SL1->L1_SITUA 
	Self:cOrc_Tipo    := SL1->L1_TIPO
	Self:cOrc_Opera := SL1->L1_OPERADO                                                
	Self:cOrc_Pdv  := SL1->L1_PDV                                                    
	Self:cOrc_Cli := SL1->L1_CLIENTE                                                     
	Self:cOrc_Ven := SL1->L1_VEND                                                       
	Self:nOrc_VlMer := SL1->L1_VALMERC                                                       
	Self:nOrc_Desc := SL1->L1_DESCONT                                                      
	Self:dOrc_Valid := SL1->L1_DTLIM                                                          
	Self:cOrc_PedCli := SL1->L1_NROPCLI 
	Self:nOrc_VlTot  := SL1->L1_VLRTOT
	Self:nOrc_Moeda  := SL1->L1_MOEDA    
	Self:nCredito    := SL1->L1_CREDITO
	
	If cPaisloc <> "BRA"
		Self:nOrc_VlLiq := SL1->L1_VLRTOT  + SL1->L1_DESCONT
	Else
	    	Self:nOrc_VlLiq := SL1->L1_VLRLIQ                                                     
	EndIf
	
	If SL1->L1_TIPO <> "P"
		Self:cOrc_Cupom := SL1->L1_DOC
		Self:cSerie := SL1->L1_SERIE
	Else
		Self:cOrc_Cupom := SL1->L1_DOCPED
		Self:cSerie := SL1->L1_SERPED

		aOrcamento := LJ140Fill()
		If Len(aOrcamento) > 0
			Self:lOrc_PedAb := LJ140VldPV(aOrcamento)
		EndIf	

	EndIf
	    
	If SL1->( FieldPos( "L1_ABTOPCC" ) ) > 0 
		Self:nOrc_VlLiq -= SL1->L1_ABTOPCC
		Self:nOrc_Abat += SL1->L1_ABTOPCC
	EndIf  	
		
	// Verifica se esta usando a nova configuracao para confirmar se o cliente recolhera o iss.
	If SuperGetMV("MV_LJRECIS",,.F.) .AND. SL1->(FieldPos("L1_RECISS")) > 0 
		lCliRecIss := SL1->L1_RECISS == "1" .AND. GetNewPar("MV_DESCISS", .F.)  					
	Else
		lCliRecIss := (Posicione("SA1",1,xFilial("SA1")+SL1->(L1_CLIENTE+ L1_LOJA),"SA1->A1_RECISS") == "1" .AND.;
		GetNewPar("MV_DESCISS", .F.) )   					
	EndIf	

	If lCliRecIss
		Self:nOrc_VlLiq -= SL1->L1_VALISS
		Self:nOrc_Abat += SL1->L1_VALISS
	EndIf   
	
	Self:cOrc_StatuEs := SL1->L1_STATUES
	Self:cOrc_Loja	  := SL1->L1_LOJA
	
	Self:cOrc_VendTEF := SL1->L1_VENDTEF
	Self:cOrc_DocCanc := SL1->L1_DOCCANC
	Self:cOrc_FormPg := SL1->L1_FORMPG 
	Self:cOrc_DocTEF := SL1->L1_DOCTEF   
	
	Self:cOrc_Institu   := SL1->L1_INSTITU   
	
	//Verifica se o or็amento de do cliente padrใo da loja
	Self:lCliPad := !((AllTrim(Self:cOrc_Cli) <> AllTrim(cCliPad)) .OR. (AllTrim(Self:cOrc_Loja) <> AllTrim(cLojaPad)))      

	
	If !Self:lJob   //Se for execu็ใo em batch, alimenta o statusES com a busca MBZ
		aAreaMBZ := MBZ->(GetArea())
		DbSelectArea("MBZ")
		MBZ->(DbSetOrder(1))
		If MBZ->( DbSeek(xFilial("MBZ") + PadR(Self:cOrc_Cupom,TamSX3("MBZ_CUPOM")[1]) + PadR(Self:cSerie,TamSX3("MBZ_SERIE")[1])))
	    	Self:cOrc_StatuEs := "2" //Grava o  Status como estornado parcialmente
	    EndIf  
	    RestArea(aAreaMBZ)
	EndIf    
		
		
	//Verifica se o Orcamento esta no movimento de fechamento do caixa
	If lUpdConf
		If AliasIndic("SLW")   
			Self:lOrc_MovFe := .T.
			aAreaSLW :=  SLW->(GetArea())
			//Pesquisar o proximo movimento em aberto que deve ser finalizado
			cChave := xFilial("SLW") + SL1->L1_PDV + SL1->L1_OPERADO + DtoS(SL1->L1_EMISSAO) 
			DbSelectArea("SLW")
			SLW->(DbSetOrder(1))
			If SLW->(dbSeek(cChave))
				While SLW->(!Eof()) .AND. SLW->(LW_FILIAL + LW_PDV + LW_OPERADO + Dtos(LW_DTABERT)) == cChave .AND. DtoC(SLW->LW_DTFECHA) # "  /  /  "
					SLW->(dbSkip())
				EndDo
				If SLW->(!Eof())  .and.  SLW->(LW_FILIAL + LW_PDV + LW_OPERADO + Dtos(LW_DTABERT) ) == cChave 
					Self:lOrc_MovFe := AllTrim(SLW->LW_NUMMOV) # AllTrim(IF(Empty(SL1->L1_NUMMOV), AllTrim(SLW->LW_NUMMOV), SL1->L1_NUMMOV))									
				EndIf 	

			EndIf
			RestArea(aAreaSLW)
		EndIf
		   
	EndIf  
Else 
	
	SL1->(DbSetOrder(1))  //Posiciona no Orcamento-pai 
	SL1->(DbSeek(xFilial("SL1")+ cOrPai))
	Self:GetOrcamento()
	
EndIf  

RestArea(aAreaSL1)
	      
Return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออออออออหอออออออัอออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบMetodo    | OrcDevolvido      บAutor  ณFabiana Cristina     บ Data ณ  23/11/2010 บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออสอออออออฯอออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณMetodo que verifica se a venda foi devolvida ou nใo                   บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ ExpC1 = C๓digo do Or็amento                                          บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSigaLoja                                                     	        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Method OrcDevolvido(cOrcmto) Class LjClEstVen
Local lRet := .F.				//Retorno de Execucao da funcao                 
Local aArea := GetArea()       	//WorkAreas Ativas
Local aAreaSL1 := nil          	//WorkArea SL1
Local aAreaSL2 := nil			//WorkArea SL2
Local aAreaSD2 := nil  			//WorkArea SD2
Local aPedRes  := {} 			//Pedidos de Reservas
Local aOrcRes  := {} 			//Orcamentos com Reservas
Local nC := 0  					//Variavel de controle de la็o        


If Self:lRetag .or. Self:lOffLine //Or็amento estแ na retaguarda , busca localmente   
	
	aAreaSL1 := SL1->(GetArea())  
	aAreaSL2  := SL2->(GetArea())

	
	DbSelectArea("SL1") 
	SL1->(DbSetOrder(1))
	SL1->(DbSeek(xFilial("SL1")+ cOrcmto))
	
	DbSelectArea("SL2")
	SL2->( DbSetOrder( 1 ) )
	If !SL2->( DbSeek( xFilial( "SL2" ) + SL1->L1_NUM) )
		lRet := .T. //Nใo ha itens, nao pode estornar a venda
	EndIf
	
	While  !SL2->(Eof()) .AND. xFilial("SL2") + RTrim(SL2->L2_NUM) == xFilial("SL1") + RTrim(SL1->L1_NUM)	
		If SL2->L2_STATUS == "D"
			lRet := .T.
			Exit
		EndIf 
		//Verifica se existem orcamentos de reservas amarrados ao item 
		If !Empty(SL2->L2_ORCRES) .and. aScan(aOrcRes, {|p| p[1] == SL2->L2_FILRES .and. p[2] == SL2->L2_ORCRES}) == 0 
			aAdd(aOrcRes, {SL2->L2_FILRES,SL2->L2_ORCRES})
		EndIf
		SL2->( dbSkip() )
	End
	
	
	If !Self:lOffLine  //Somente verifica os itens da NF se a venda estiver na retaguarda      
		aAreaSD2 := SD2->(GetArea())
		If !Empty( SL1->L1_DOC ) .AND. !lRet  	
			
			SD2->( dbSetOrder( 3 ) )
			SD2->( dbSeek( xFilial( "SD2" ) + SL1->L1_DOC + SL1->L1_SERIE ) )
			While SD2->(!EoF() .AND. RTrim(SD2->D2_DOC) == RTrim(SL1->L1_DOC) .AND. SD2->D2_SERIE == SL1->L1_SERIE )
				If SD2->D2_QTDEDEV > 0
					lRet  := .T.
					Exit
				Endif
		
				SD2->( dbSkip() )
			End 
			
		EndIf	
		
		If !lRet
			SD2->( dbSetOrder( 3 ) )
			nC := 0
			Do While (nC := nC + 1) <= Len(aOrcRes)
				SL2->(DbSeek( aOrcRes[nC, 01]+ aOrcRes[nC, 02] ) ) 
				Do While SL2->(!Eof() .and. L2_FILIAL + RTrim(L2_NUM) == aOrcRes[nC, 01]+ RTrim(aOrcRes[nC, 02]) )
					If !Empty(SL2->L2_DOC) .And.  aScan(aPedRes, {|p| p[1] == aOrcRes[nC, 01] .and. p[2] == SL2->L2_DOC .and. p[3] == SL2->L2_SERIE }) == 0
				    	aAdd(aPedRes, {aOrcRes[nC, 01], SL2->L2_DOC, SL2->L2_SERIE})
				    EndIf
				    SL2->(DbSkip(1))
			    EndDo
			EndDo 
			
			nC := 0
			Do While (nC := nC + 1) <= Len(aPedRes)
				SD2->( DbSeek(aPedRes[nC, 01] + aPedRes[nC, 02] + aPedRes[nC, 03] ) )
				While SD2->(!EoF() .AND. D2_FILIAL + Rtrim(D2_DOC) + rTrim(D2_SERIE) == aPedRes[nC, 01] + RTrim(aPedRes[nC, 02]) + Rtrim(aPedRes[nC, 03]) )
					If SD2->D2_QTDEDEV > 0
						lRet  := .T.
						Exit
					Endif
			
					SD2->( dbSkip() )
				End 					
			EndDo  

		EndIf
		
		RestArea(aAreaSD2)
	
	EndIf
	RestArea(aAreaSL1)
	RestArea(aAreaSL2)  

Else 
	 //Excuta o WS de valida็ใo do orcamento

	 	lRet := Self:OrcWsDevolvido(cOrcmto)    

EndIf

RestArea(aArea)


Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออออออออหอออออออัอออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบMetodo    |OrcWsDevolvido     บAutor  ณFabiana Cristina     บ Data ณ  23/11/2010 บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออสอออออออฯอออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณMetodo que verifica se a venda foi devolvida ou nใo                   บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ  
ฑฑบParametrosณ ExpC1 = C๓digo do Or็amento                                          บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSigaLoja                                                     	        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method OrcWsDevolvido(cOrcmto) Class LjClEstVen
Local lRet			:= .F.	//Retorno da Funcao
Local oWsOrcamento	:= Nil	//Objeto WebService


 oWsOrcamento := WSLJESTORC():New()   
 oWsOrcamento:_URL := Self:cURLWebService    
 
 If !oWsOrcamento:LjEstOrcDev(cOrcmto, cEmpAnt, cFilAnt) 
 	Self:lOffLine := .T. //Configura o objeto estorno para off-line, pois nใo conseguiu conexใo com a retaguarda
	MsgAlert(STR0002+CRLF+STR0011)   
    lRet := .T. //Erro na execucao do WebService, exibe orcamento como devolvido
 Else 
    lRet := oWsOrcamento:lLJESTORCDEVRESULT
 EndIf 
 
Return lRet 

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออออออออหอออออออัอออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบMetodo    |RealizaEstorno     บAutor  ณFabiana Cristina     บ Data ณ  25/11/2010 บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออสอออออออฯอออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณMetodo que realiza o estorno                                          บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSigaLoja                                                     	        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method RealizaEstorno( cNewCli , cNewLoja , aDocDev ,  lRemote ) Class LjClEstVen    

Local nC 			:= 0      		//Variavel contadora
Local cCodDia 		:= ""	   		//Cํdigo do diario - Portugal
Local cMotivo 		:= ""			//Motivo da devolu็ใo
Local cNumDoc 		:= ""			//Numero da NFE/NCC de Devolucao
Local cSerieDoc 	:= ""			//Serie da NFE/NCC de Devolucao
Local nVlrTotal 	:= 0 			//Valor Total da NFE
Local nImpostos 	:= 0 			//Total de Impostos da NFE
Local lProssegue	:= .T.  		//Controle de execucao da rotina 
Local cSimbMoeda	:= SuperGetMV( "MV_SIMB1")   //Moeda corrente    
Local aPagtos 		:= {} 			//Array dos pagamentos estornados
Local cParcela 		:= ""    		//Parcela do tํtulo gerado de NCC  
Local aCupom 		:= {}			//Dados da Venda
Local nValorNFE 	:= 0 			//total da NF entrada
Local nValorNCC		:= 0 			//total do Pedido
Local cNumDoc2 		:= ""			//Numero da NCC de Entrada de Orcamento com Retira + Entrega
Local cSerieDoc2	:= "" 			//Numero da NCC de Entrada de Orcamento com Retira + Entrega       
Local cMV_TPNRNFS	:= LJTpNrNFS()	//Retorno do parametro MV_TPNRNFS, utilizado pela Sx5NumNota() de onde serah controlado o numero da NF  1=SX5  2=SXE/SXF  3=SD9
Local xRet							//Retorno para o ponto de entrada LJ7068
Local nTransacoes	:= 0			//Numero de cartoes estornados
Local lRetaPaf		:= LjNfPafEcf(SM0->M0_CGC) .AND. !lMvljpdvpa	//Indica se ้ uma retaguarda PAF

DEFAULT cNewCli    	:= ""            //Novo cliente para o estorno.
DEFAULT cNewLoja	:= ""            //Nova loja para o estorno. 
DEFAULT aDocDev		:= {}
DEFAULT lRemote		:= .F.

If ExistBlock("LJ7068")
	xRet	:= ExecBlock("LJ7068") // Se retorno: .T. = Estorno permitido / .F. = Estorno nใo permitido
	If ValType(xRet) == "L" 
		If xRet == .F.    
			lProssegue	:=	.F.
		EndIf	
	EndIf
EndIf


aSort( Self:aOrc_Pagtos,,, {|x,y| x[__L4_FORMAID] < y[__L4_FORMAID] } ) //__L4_FORMAID  
	
Do While  (nC := nC  + 1)  <= Len(Self:aOrc_Pagtos)
	If !Empty(Self:aOrc_Pagtos[nC, __L4_DOCTEF]) .and. Self:PagtoPodeCompensar(Self:aOrc_Pagtos[nC], Self:aSE1)
		// Verifica se mudou ID do cartao
	    If nC == 1 .Or. (Self:aOrc_Pagtos[Iif(nC>1,nC-1,nC), __L4_FORMAID] <> Self:aOrc_Pagtos[nC, __L4_FORMAID] .Or. ;
	                     Self:aOrc_Pagtos[Iif(nC>1,nC-1,nC), __L4_FORMA] <> Self:aOrc_Pagtos[nC, __L4_FORMA])
			nTransacoes := nTransacoes + 1
		Endif	
	EndIf
EndDo
                                   
// Forca pelo menos uma passagem pelo For
For nC := 1 To Iif(nTransacoes==0, 1, nTransacoes)

	If !Self:lJob	.AND.	lProssegue 
	
		If Self:lRetag .or. Self:lRetagOrc //Busca os tํtulos somente se o orcamento estiver na retaguarda
			Self:BuscaTitulosOrcamento()
		EndIf
		
		If !Self:lOrc_MovFe					
			Self:TEFCancela(@lProssegue)
			cSimbMoeda := "NCC"		
		EndIf
		
	 	If 	!lProssegue
	 		Exit
	 	Endif
	 		
		If !Self:lOrc_MovFe
			Do While (nC := nC + 1) <= Len(::aOrc_Pagtos)
				If ::aOrc_Pagtos[nC, __L4lEstorn] .and. !Self:PagtoPodeCompensar(::aOrc_Pagtos[nC], ::aSE1)
			    		Aviso( STR0020,STR0022 + CRLF + ;//"O Pagamento em Cartใo  nใo poderia ter sido estornado, pois o tํtulo jแ possui baixas ou nใo estแ no porte do caixa."
			    						STR0023+ STR0024 +STR0026+;  //"A rotina de estorno irแ gerar ""uma NCC" , " para o seguinte tํtulo abaixo:"
			    				 STR0027 + Alltrim(Self:cOrc_Cupom) + STR0028+Alltrim(Self:cSerie) + ; //"Documento:""  Serie:"
			    				 STR0029 +  AllTrim(Self:aOrc_Pagtos[nC,__L4_FORMA]) + ;  //" Tipo:"
			    				 STR0030 + AllTrim(Self:aOrc_Pagtos[nC,__E1_PARCELA ])  +;  //" Parcela:"
			    				 STR0031 +  AllTrim(Self:aOrc_Pagtos[nC,__L4_ADMINIS]), {STR0031}) //" Administradora:""&Ok"
			    		aOrc_Pagtos[nC, __L4lEstorn] := .F. //Marca o estorno como .F.		 				
				EndIf
			EndDo 
		EndIf 
		
	
		
	EndIf
	//se estornado, cancela e compensa, senใo somente gera 1 movimento do tipo TR em dinheiro pois o tํtulo estแ em porte do caixa
	//
	//Este Tratamento deverแ ser o ultimo a ser realizado   
	
	//Abertura de transacao
	//BeginTransaction()    
	//fabiana 26/07/11 - Verificar a situacao aonde a devolu็ใira gerar uma ncc para consumidor final, neste caso
	//deverแ a NCC deverแ ser completamente baixada e a devolu็ใo ser em dinheiro
	
	If lProssegue
		If Self:lRetag //Tratamento para estorno realizado no sigaloja
	
			If Self:cOrc_Tipo <> "P"
		
				lProssegue := Lj601GeraNFE( Self:cNumCaixa	, Self:cOrc_Cupom	, Self:cSerie 	, Self:cOrc_Cli ,;
											Self:cOrc_Loja	, cCodDia			, cMotivo 		, @cNumDoc     	,;
											@cSerieDoc		, @nValorNFE		, @nImpostos	, Self:lJob 	,;
											cNewCli			, cNewLoja          , @aDocDev	)	
		    
			Else
		
				//Se for na retaguarda, ้ gerada uma NCC com o valor total do pedido de saํda
				//depois elimina os residuos das venda e gera uma ncc com o valor do pedido 
				lProssegue := Lj601RePed(Self:cNumCaixa,  	Self:cOrc_Cupom,  	Self:cSerie , 	Self:cOrc_Cli  , ;
										Self:cOrc_Loja,  	Self:cOrcamento, 	@cNumDoc, 		@cSerieDoc, ;
										@nValorNCC, 		Self:dOrc_Emissao, 	Self:lRetagOrc, @Self:cOrc_CupFis, ;
										@Self:cOrc_SerCF,	@Self:aQuery, 		@Self:aOrc_Res,	Self:lJob)
		
			
				If lProssegue .and. !Empty(Self:cOrc_CupFis) .and. !Empty(Self:cOrc_SerCF)  //Caso o or็amento tenha gerado pedido + cupom fiscal , gera Nota fiscal de entrada dos itens de Cf
					lProssegue := Lj601GeraNFE(  Self:cNumCaixa	, Self:cOrc_CupFis	, @Self:cOrc_SerCF 	, Self:cOrc_Cli ,;
											 	 Self:cOrc_Loja	, cCodDia			, cMotivo 			, @cNumDoc2    	,;
											 	 @cSerieDoc2	, @nValorNFE		, @nImpostos   		, Self:lJob 	,;
											 	 cNewCli		, cNewLoja          , @aDocDev	)	
				EndIf                
	
				If lProssegue .and. !Empty(Self:cOrc_Cupom) .and. !Empty(Self:cSerie)  //Caso o or็amento tenha gerado nota ou cupom fiscal , gera Nota fiscal de entrada dos itens de Cf
					lProssegue := Lj601GeraNFE(  Self:cNumCaixa	, Self:cOrc_Cupom	, @Self:cSerie 	, Self:cOrc_Cli ,;
											 	 Self:cOrc_Loja	, cCodDia			, cMotivo 			, @cNumDoc2    	,;
											 	 @cSerieDoc2	, @nValorNFE		, @nImpostos   		, Self:lJob 	,;
											 	 cNewCli		, cNewLoja          , @aDocDev	)	
				EndIf                
			EndIf 
		
			nVlrTotal := nValorNCC + nValorNFE
	       
	
	 
			lProssegue := lProssegue .and.  Lj601EstDinh(Self:cOrcamento, Self:lOrc_MovFe , Self:cOrc_Cupom, Self:cSerie, ;
														@Self:aOrc_pagtos, Self:lJob)
	    
		    If lProssegue
			//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
			//ณGerar Titulo Referente as taxas das administradoras              ณ
			//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู  
		
				cParcela := Lj601TxAdm(  Self:cOrc_Cupom	, Self:cSerie		, Self:cOrc_Cli	, Self:cOrc_Loja,; 
										Self:cNumCaixa      , Self:aOrc_pagtos , @aPagtos		) 
									  
				If !Self:lOrc_MovFe 
					
	 
			    	
				    	Lj601Comp( 	cNumDoc			,	cSerieDoc          	,	Self:cOrc_Cupom	,	Self:cSerie	,;
				   					Self:cOrc_Cli 	,	Self:cOrc_Loja		,	Self:aOrc_pagtos, 	cParcela	,;
			   						cNumDoc2		,	cSerieDoc2			, 	cNewCli			,	cNewLoja 	)   
						           
		  				cSimbMoeda := "NCC"
				          				          	
				Else
			
					If !Empty(cNumDoc2) .and. !Empty(cSerieDoc2)
				   		Lj720DevDinh( cNumDoc, cSerieDoc, Self:cOrc_Cli, Self:cOrc_Loja, nValorNCC,.F., ,0,Self:cNumCaixa, "TR",STR0054)      //"BAIXA REF. ESTORNO DE VENDA"
					Else 
						Lj720DevDinh( cNumDoc, cSerieDoc, Self:cOrc_Cli, Self:cOrc_Loja, nVlrTotal,.F., ,nImpostos,Self:cNumCaixa,"TR", STR0054)   //"BAIXA REF. ESTORNO DE VENDA"
					EndIf
			     
			    
				EndIf 								
									
									
			EndIf
	            
	
		Else
		 
	
			nC := 0
			Do While (nC := nC +1) <= Len(Self:aOrc_pagtos)     //parcela, Tipo, valor , agrupa as parcelas que foram estornadas
				If IsMoney(Self:aOrc_pagtos[nC,__L4_FORMA]) .And. !Self:lOrc_MovFe  //Incluํda a valida็ใo para 
					Self:aOrc_pagtos[nC, __L4lEstorn] := .T.
				EndIf
				If Self:aOrc_pagtos[nC, __L4lEstorn] 
					If (nPos := aScan(aPagtos, {|e| e[1] == Self:aOrc_pagtos[nC, __E1_PARCELA] .and. e[2] == Self:aOrc_pagtos[nC, __L4_FORMA] })) = 0
		    			aAdd( aPagtos, {Self:aOrc_pagtos[nC, __E1_PARCELA], Self:aOrc_pagtos[nC, __L4_FORMA],  0})
		    			nPos := Len(aPagtos)
			    	EndIf
			    	aPagtos[nPos, 03] := aPagtos[nPos, 03] + Self:aOrc_pagtos[nC, __L4_VALOR]
		    	
				EndIf
				nVlrTotal := nVlrTotal + Self:aOrc_pagtos[nC, __L4_VALOR]
			EndDo  
	
		EndIf   //Fim - Orcamento no sigaloja
	EndIf	// Fim - If lProssegue
	
	//Na retaguarda PAF, nใo serแ impresso o comprovante nใo fiscal, pois nใo se usa impressora na retaguarda
	If lProssegue .AND. !Self:lJob .AND. !lRemote .AND. !lRetaPAF
	
		aCupom := {Self:cOrc_Cupom,; //Cupom do Orcamento
					Self:cSerie	,;   //Serie do cupom
					Self:cOrc_Cli,;  //Cliente do Orcamento
					Self:cOrc_Loja,; //Loja do Cliente
					Self:cOrc_Opera,; //Caixa da Venda
					Self:lOffLine }   //Venda Off-Line
					
		Self:ImpCupEstorno(  aPagtos, aCupom , nVlrTotal, cSimbMoeda)
	   
	EndIf
		
	//Gravar  como estornado sl1 -> todos e sl4->orcamento-pai
	If !Self:lRetag .AND. lProssegue			
	
		//PDV //Realiza a grava็ใo dos Pagamentos para enviar na retaguarda 
	   lProssegue := lProssegue .and. Self:GrvDadosPgto()
	EndIf 
	
	If Self:lRetag  .AND. lProssegue////Retaguarda realiza a grava็ใo dos pagamentos e do or็amento como estornado
		 lProssegue := lProssegue .and. Lj601GrStE(Self:cOrcamento, 	Self:aOrc_Pagtos, 	Self:aOrc_Res, Self:lRetagOrc, ;
		 											@Self:aQuery, 		Self:lJob, 		  	Self:lOffLine, Self:cOrc_DocCanc , ;
		 											Self:cOrc_DatCanc , Self:cOrc_HorCanc, 	Self:cNumCaixa)
	EndIf
	
	If lProssegue .and. Self:lRetag .and. !Self:lJob .and. nValorNFE > 0  //Se gerou documento de entrada, exibe a mensagem
		MsgAlert(STR0053 + ": " + IIF(Self:cOrc_Tipo <> "P",;  //"Foi gerado o documento de entrada"
														RTrim(cNumDoc)+"/"+cSerieDoc,;
														Rtrim(cNumDoc2)+"/"+cSerieDoc2 ))
	
	EndIf

Next nC

If ExistBlock("LJ7103")
	ExecBlock("LJ7103",.F.,.F.,{lProssegue,Self:cOrc_Cupom,Self:cOrcamento,Self:lJob,Self:cSerie,Self:aOrc_Pagtos}) // Se retorno: .T. = Estorno permitido / .F. = Estorno nใo permitido
EndIf

Return lProssegue

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออออออออหอออออออัอออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบMetodo    |BuscaItensOrcamentoบAutor  ณFabiana Cristina     บ Data ณ  25/11/2010 บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออสอออออออฯอออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณMetodo que realiza a busca dos itens do Orcamento                     บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ 
ฑฑบParametrosณ ExpC1 = 	Orcamento                                                   บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ 
ฑฑบUso       ณSigaLoja                                                     	        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Method BuscaItensOrcamento(cOrcmto) Class LjClEstVen  
Local aArea 	:= GetArea()  //WorkAreas Ativas
Local aAreaSL2  := nil        //WorkArea SL2
Local aPropImp  := {}         //TES
Local nY := 0                 //Varial contadora
Local nPosDescPro := 0        //Descricao Produto
Local nDecs := MsDecimais(Self:nOrc_Moeda)         //MsDecimais(SL1->L1_MOEDA) 
Local nPosOrc  := 0           //Posicao do orcamento

Default cOrcmto := Self:cOrcamento

If Self:lRetag  .or. Self:lOffLine //Or็amento estแ na retaguarda ou off-line, entใo busca localmente   
	
 
	aAreaSL2  := SL2->(GetArea())

	DbSelectArea("SL2")
	SL2->( DbSetOrder( 1 ) )
	SL2->( DbSeek( xFilial( "SL2" ) + cOrcmto ) ) 
	
	nPosDescPro := SL2->(FieldPos("L2_DESCPRO"))
	
	While  !SL2->(Eof()) .AND. xFilial("SL2") + RTrim(SL2->L2_NUM) == xFilial("SL1") + Rtrim(cOrcmto)
 
        aAdd(Self:aOrc_Itens, {SL2->L2_PRODUTO, SL2->L2_DESCRI, SL2->L2_QUANT, SL2->L2_VRUNIT, SL2->L2_VLRITEM })
		nPosOrc++
		
		If cPaisLoc <> "BRA"
		
			If nPosDescPro > 0
			   Self:aOrc_Itens[nPosOrc,__L2_VLRITEM] += SL2->L2_DESCPRO
			EndIf
		   
			Self:aOrc_Itens[nPosOrc,__L2_VRUNIT]  := Round(  Self:aOrc_Itens[nPosOrc,__L2_VLRITEM]  /	 SL2->L2_QUANT, nDecs ) //valor unitแrio "L2_VRUNIT" := "L2_VLRITEM"/	"L2_QUANT"
			
			aPropImp :=	TesImpInf(SL2->L2_TES) //"L2_TES"

			For nY := 1	To Len( aPropImp )
				If ( aPropImp[nY][3]=="1" )
					Self:nOrc_Imp += SL2->( FieldGet( FieldPos( "L2_" + Substr( aPropImp[nY][2],4,7 ) ) ) )
				ElseIf ( aPropImp[nY][3]=="3" )
					Self:nOrc_ImpIn  += SL2->( FieldGet( FieldPos( "L2_" + Substr( aPropImp[nY][2],4,7 ) ) ) )
				EndIf
			Next nY
			
		Else
			SF4->(DbSetOrder(1))
			SF4->(DbSeek(xFilial("SF4")+SL2->L2_TES))
				
					//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
					//ณ Faz o tratamento do valor do ICMS solidแrio                              ณ
					//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
					// VerIfica se agrega solidario. (Se o valor do imposto incide ou nao no total da venda)
			If SF4->F4_INCSOL <> "N"
				Self:nOrc_Imp	+= SL2->L2_ICMSRET
			EndIf	
		EndIf  
		
		SL2->(DbSkip(1))
	End
		
	RestArea(aAreaSL2)
	
  

Else 
	 //Excuta o WS de valida็ใo do orcamento
	 Self:BuscaWsItensOrcamento(cOrcmto, Self:nOrc_Moeda)
EndIf

RestArea(aArea)

Return 

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออออออออออหอออออออัอออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบMetodo    |BuscaWsItensOrcamentoบAutor  ณFabiana Cristina     บ Data ณ  25/11/2010 บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออสอออออออฯอออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณMetodo que verifica se a venda foi devolvida ou nใo                     บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ  
ฑฑบParametrosณ ExpC1 = 	Orcamento                                                     บฑฑ 
ฑฑบ			 ณ ExpN1 = 	Moeda                                                         บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ  
ฑฑบUso       ณSigaLoja                                                     	          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method BuscaWsItensOrcamento(cOrcmto, nMoeda) Class LjClEstVen
Local oWsOrcamento := Nil     //Objeto WebService
Local nC := 0                 //Variavel contadora

 oWsOrcamento := WSLJESTORC():New()   
 oWsOrcamento:_URL := Self:cURLWebService    
 
 If !oWsOrcamento:LjEstOrcIt(cOrcmto, nMoeda, cEmpAnt, cFilAnt) 
 	Self:lOffLine := .T. //Configura o objeto estorno para off-line, pois nใo conseguiu conexใo com a retaguarda
	If !Self:lJob
		MsgAlert(STR0002+CRLF+STR0012) 
	EndIf
 Else 
    //Executa a busca dos itens do Orcamento localmente
   	Self:nOrc_Imp := oWsOrcamento:oWSLJESTORCITRESULT:nOrc_Imp
   	Self:nOrc_ImpIn := oWsOrcamento:oWSLJESTORCITRESULT:nOrc_ImpIn  
   	 
   	
   	For nC := 1 To Len(oWsOrcamento:oWSLJESTORCITRESULT:oWSOrc_Itens:oWstRet_Itens)
   	   
   	   aAdd( Self:aOrc_Itens, Array(05))
   	   Self:aOrc_Itens[nC,__L2_PRODUTO] := oWsOrcamento:oWSLJESTORCITRESULT:oWSOrc_Itens:oWstRet_Itens[nC]:cL2_PRODUTO
   	   Self:aOrc_Itens[nC,__L2_DESCRI]  := oWsOrcamento:oWSLJESTORCITRESULT:oWSOrc_Itens:oWstRet_Itens[nC]:cL2_DESCRI
   	   Self:aOrc_Itens[nC,__L2_QUANT]   := oWsOrcamento:oWSLJESTORCITRESULT:oWSOrc_Itens:oWstRet_Itens[nC]:nL2_QUANT
   	   Self:aOrc_Itens[nC,__L2_VRUNIT]  := oWsOrcamento:oWSLJESTORCITRESULT:oWSOrc_Itens:oWstRet_Itens[nC]:nL2_VRUNIT
   	   Self:aOrc_Itens[nC,__L2_VLRITEM] := oWsOrcamento:oWSLJESTORCITRESULT:oWSOrc_Itens:oWstRet_Itens[nC]:nL2_VLRITEM     	   
   	Next nC
 EndIf 
 
Return  

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออออออออออหอออออออัอออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบMetodo    |BuscaPagtosOrcamentoบAutor  ณFabiana Cristina     บ Data ณ  26/11/2010 บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออสอออออออฯอออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณMetodo que realiza a busca dos itens do Orcamento                      บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ    
ฑฑบParametrosณ ExpC1 = C๓digo do Or็amento                                           บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSigaLoja                                                     	         บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method BuscaPagtosOrcamento(cOrcmto) Class LjClEstVen  
Local nPos	 		:= 0                //Posicao do Array
Local cSimbMoeda	:= ""				// Simbolo da moeda da venda (parcela em dinheiro)
Local lVisualSint   := .f.				// Controla se esta habilitada a visualizacao sintetica das parcelas
Local nMoeda		:= ""               //Moeda
Local dData			:= Ctod("")         //Data
Local cBanco		:= ""               //Banco
Local cAgencia		:= ""               //Agencia
Local cConta		:= ""               //Conta
Local cCompens		:= ""               //compensacao
Local cCheque		:= ""               //Cheque
Local aArea			:= GetArea()        //WorkAreas Ativas
Local aAreaSL4		:= SL4->(GetArea()) //WorkArea SL4
Local aPgtos		:= {}               //Pagamentos
Local cPorte		:= ""               //Porte do titulo
Local nC			:= 0                //contador

Local lCmpsIdTRN    := SL4->(ColumnPos("L4_TRNID")) > 0 .And. SL4->(ColumnPos("L4_TRNPCID")) > 0 .And. SL4->(ColumnPos("L4_TRNEXID")) > 0 //Verifica se existem os campos que guardam os IDs das transa็๕es do Payment Hub
Local cTRNID		:= "" 				//ID da Transa็ใo (Payment Hub)
Local cTRNPCID		:= ""				//ID Transa็ใo Processador (Payment Hub)
Local cTRNEXID		:= ""				//ID da Transa็ใo Externa (Payment Hub)

Default cOrcmto := Self:cOrcamento

If Self:lRetag  .or. Self:lOffLine //Or็amento estแ na retaguarda ou off-line, entใo busca localmente 
	
	If !Empty(Self:nOrc_Moeda)
	   cSimbMoeda	:= SuperGetMV("MV_SIMB"+ALLTRIM(STR(Self:nOrc_Moeda)))
	Else
		cSimbMoeda	:= SuperGetMV("MV_SIMB1")
	EndIf          
	
	lVisualSint   := SL4->(FieldPos("L4_FORMAID")) > 0
	
	DbSelectArea("SL4")
	DbSetOrder(1)
	DbSeek(xFilial("SL4")+cOrcmto)
	
		
	While !Eof() .AND. SL4->L4_FILIAL+RTrim(SL4->L4_NUM) == xFilial("SL4")+RTrim(cOrcmto)
	    
	    nMoeda := 0
	    dData := Ctod("")
        cBanco := ""
        cAgencia := ""
        cConta := ""
        cCompens := ""   
        cCheque := ""
        cPorte := " "	
        
        If cPaisLoc<>"BRA" 
        	nMoeda := SL4->L4_MOEDA
        	dData := SL4->L4_DATA
        EndIf
        
        If  Alltrim(SL4->L4_FORMA) == "CH" 
	        cBanco := SL4->L4_ADMINIS
	        cCheque := SL4->L4_NUMCART 
	        cAgencia := SL4->L4_AGENCIA
	        cConta := SL4->L4_CONTA
	        cCompens := SL4->L4_COMP      
	        //cPorte := "1"
        ElseIf AllTrim(SL4->L4_FORMA) $ "CC#CD" 
	        cBanco := SL4->L4_ADMINIS     	
        EndIf
        
		If Empty(SL4->L4_ORIGEM)       
		
		    aAdd(aPgtos , Array(__L4_TAMANHO))
		    nC := nC + 1

			If lCmpsIdTRN
                cTRNID		:= Alltrim(SL4->L4_TRNID) 	//ID da Transa็ใo (Payment Hub)
                cTRNPCID	:= Alltrim(SL4->L4_TRNPCID) //ID Transa็ใo Processador (Payment Hub)
                cTRNEXID	:= Alltrim(SL4->L4_TRNEXID) //ID da Transa็ใo Externa (Payment Hub)
            EndIf
		    
 	   	    aPgtos[nC, __L4_DATA] := 	SL4->L4_DATA
 			aPgtos[nC, __L4_FORMA] := SL4->L4_FORMA
 			aPgtos[nC, __L4_VALOR] := SL4->L4_VALOR
 			aPgtos[nC, __PORTE] := cPorte
 			aPgtos[nC, __L4_CHEQID] := IIf(SL4->(FieldPos("L4_CHEQID"))>0,L4_CHEQID,Space(1))
 			aPgtos[nC, __L4_NUMCART] := cCheque
 			aPgtos[nC, __L4_ADMINIS] := cBanco
 			aPgtos[nC, __L4_AGENCIA] := cAgencia
 			aPgtos[nC, __L4_CONTA] := cConta
 			aPgtos[nC, __L4_COMP] := cCompens
 			aPgtos[nC, __L4_MOEDA] := nMoeda
 			aPgtos[nC, __L4DATA] := dData  
 			aPgtos[nC, __L4_RECNO] := SL4->(Recno())
 			
 			aPgtos[nC,__L4_DATATEF] := SL4->L4_DATATEF 
			aPgtos[nC, __L4_DOCTEF] := SL4->L4_DOCTEF
			aPgtos[nC, __L4_NSUTEF] := SL4->L4_NSUTEF     
			If SL4->(FieldPos("L4_FORMAID")) > 0
				aPgtos[nC, __L4_FORMAID] := SL4->L4_FORMAID 
			Else
				aPgtos[nC, __L4_FORMAID] := ""
			EndIf

			aPgtos[nC, __L4_INSTITU] := SL4->L4_INSTITU
			aPgtos[nC, __L4_BANDEIR] := SL4->L4_BANDEIR
			aPgtos[nC, __L4_REDEAUT] := SL4->L4_REDEAUT

			// Verifica se transa็ใo foi via TEF ou POS ou Pagamento Digital
            If AllTrim(SL4->L4_FORMA) $ _FORMATPD
				If AllTrim(SL4->L4_FORMA) == "PD"
                	aPgtos[nC, __TP_TRANS] := "PD"
				Else
					aPgtos[nC, __TP_TRANS] := "PX"
				EndIf
			ElseIf Empty(aPgtos[nC, __L4_INSTITU]) .AND. Empty(aPgtos[nC, __L4_BANDEIR]) .AND. Empty(aPgtos[nC, __L4_REDEAUT])
				aPgtos[nC, __TP_TRANS] := "POS"
			Else
				aPgtos[nC, __TP_TRANS] := "TEF"
			EndIf

            aPgtos[nC, __L4_TRNID]	 := cTRNID      //ID da Transa็ใo (Payment Hub)
            aPgtos[nC, __L4_TRNPCID] := cTRNPCID    //ID Transa็ใo Processador (Payment Hub)
            aPgtos[nC, __L4_TRNEXID] := cTRNEXID    //ID da Transa็ใo Externa (Payment Hub)

			aPgtos[nC,__L4lEstorn] := .T.

		EndIf

		DbSkip()
	End

	//Chama o m้todo que calcula a parcela associada ao SE1
	
	aPgtos := Self:CalculaParcelas(aPgtos, cOrcmto)
	
	aSort( aPgtos,,, {|x,y| Dtos(x[__L4_DATA])+x[__L4_FORMA] < Dtos(y[__L4_DATA])+y[__L4_FORMA] } ) //Data + Cond 
	
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ A Forma $ sempre sera a primeira!!!  ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	If (nPos := Ascan(aPgtos, {|x| AllTrim(x[__L4_FORMA]) == AllTrim(cSimbMoeda)})) > 1
		aAdd(aPgtos,{})
		aIns(aPgtos,1)
		nPos++
		aPgtos[1] := aPgtos[nPos] 
		aDel(aPgtos, nPos)
		aSize(aPgtos,Len(aPgtos)-1)
	EndIf
	
	Self:aOrc_Pagtos := aPgtos   
	
    RestArea(aAreaSL4)	               

Else 
	 //Excuta o WS de valida็ใo do orcamento
	 Self:BuscaWsPagtosOrcamento(cOrcmto)
EndIf

RestArea(aArea)

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออออออออออออหอออออออัอออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบMetodo    |BuscaWsPagtosOrcamentoบAutor  ณFabiana Cristina     บ Data ณ  26/11/2010 บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออสอออออออฯอออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณMetodo que realiza a busca dos itens do Orcamento                        บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ ExpC1 = C๓digo do Or็amento                                             บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSigaLoja                                                     	           บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/   
Method BuscaWsPagtosOrcamento(cOrcmto) Class LjClEstVen   
Local oWsOrcamento := Nil     //Objeto WebService
Local nC := 0                 //Variavel contadora

 oWsOrcamento := WSLJESTORC():New()   
 oWsOrcamento:_URL := Self:cURLWebService    
 
 If !oWsOrcamento:LjEstOrcPg(cOrcmto, cEmpAnt, cFilAnt) 
 	Self:lOffLine := .T. //Configura o objeto estorno para off-line, pois nใo conseguiu conexใo com a retaguarda
	If !Self:lJob
   		MsgAlert(STR0002+CRLF+STR0012) 
    EndIf
 	//Self:BuscaPagtosOrcamento()
 Else 
    //Executa a busca dos itens do Orcamento localmente  
   	For nC := 1 To Len(oWsOrcamento:oWsLjEstOrcPgResult:oWstRetPgOrc)  
   	
   	   aAdd(Self:aOrc_Pagtos, Array(__L4_TAMANHO))
   	   Self:aOrc_Pagtos[nC, __L4_DATA] := StoD(oWsOrcamento:oWsLjEstOrcPgResult:oWstRetPgOrc[nC]:cL4_DATA)
   	   Self:aOrc_Pagtos[nC, __L4_FORMA] := oWsOrcamento:oWsLjEstOrcPgResult:oWstRetPgOrc[nC]:cL4_FORMA
   	   Self:aOrc_Pagtos[nC, __L4_VALOR] := oWsOrcamento:oWsLjEstOrcPgResult:oWstRetPgOrc[nC]:nL4_VALOR
   	   Self:aOrc_Pagtos[nC, __PORTE] := oWsOrcamento:oWsLjEstOrcPgResult:oWstRetPgOrc[nC]:cPORTE
   	   Self:aOrc_Pagtos[nC, __L4_CHEQID] := oWsOrcamento:oWsLjEstOrcPgResult:oWstRetPgOrc[nC]:cL4_CHEQID
   	   Self:aOrc_Pagtos[nC, __L4_NUMCART] := oWsOrcamento:oWsLjEstOrcPgResult:oWstRetPgOrc[nC]:cL4_NUMCART
   	   Self:aOrc_Pagtos[nC, __L4_ADMINIS] := oWsOrcamento:oWsLjEstOrcPgResult:oWstRetPgOrc[nC]:cL4_ADMINIS
   	   Self:aOrc_Pagtos[nC, __L4_AGENCIA] := oWsOrcamento:oWsLjEstOrcPgResult:oWstRetPgOrc[nC]:cL4_AGENCIA
   	   Self:aOrc_Pagtos[nC, __L4_CONTA] := oWsOrcamento:oWsLjEstOrcPgResult:oWstRetPgOrc[nC]:cL4_CONTA
   	   Self:aOrc_Pagtos[nC, __L4_COMP] := oWsOrcamento:oWsLjEstOrcPgResult:oWstRetPgOrc[nC]:cL4_COMP
   	   Self:aOrc_Pagtos[nC, __L4_MOEDA] := oWsOrcamento:oWsLjEstOrcPgResult:oWstRetPgOrc[nC]:nL4_MOEDA
   	   Self:aOrc_Pagtos[nC, __L4DATA] := StoD(oWsOrcamento:oWsLjEstOrcPgResult:oWstRetPgOrc[nC]:cL4DATA)
   	   
   	   
   	   Self:aOrc_Pagtos[nC,__L4_DATATEF] := oWsOrcamento:oWsLjEstOrcPgResult:oWstRetPgOrc[nC]:cL4_DATATEF 
	   Self:aOrc_Pagtos[nC, __L4_DOCTEF] := oWsOrcamento:oWsLjEstOrcPgResult:oWstRetPgOrc[nC]:cL4_DOCTEF
	   Self:aOrc_Pagtos[nC, __L4_NSUTEF] := oWsOrcamento:oWsLjEstOrcPgResult:oWstRetPgOrc[nC]:cL4_NSUTEF  
	   Self:aOrc_Pagtos[nC, __L4_FORMAID] := oWsOrcamento:oWsLjEstOrcPgResult:oWstRetPgOrc[nC]:cL4_FORMAID  
	   Self:aOrc_Pagtos[nC, __E1_PARCELA] := oWsOrcamento:oWsLjEstOrcPgResult:oWstRetPgOrc[nC]:cE1_PARCELA  
	   Self:aOrc_Pagtos[nC, __L4_RECNO] := oWsOrcamento:oWsLjEstOrcPgResult:oWstRetPgOrc[nC]:nL4_RECNO  
	   
	   Self:aOrc_Pagtos[nC, __L4_NSUTEF]   := oWsOrcamento:oWsLjEstOrcPgResult:oWstRetPgOrc[nC]:cL4_NSUTEF 
	   
	   Self:aOrc_Pagtos[nC,__L4lEstorn] := .T.
   	   
   	   
   	Next nC
 EndIf 

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออออออออออออหอออออออัอออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบMetodo    |OrcValReserva         บAutor  ณFabiana Cristina     บ Data ณ  02/12/2010 บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออสอออออออฯอออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณRealiza as Valida็๕es do Orcamento na Reserva                            บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ 
ฑฑบParametrosณ ExpC1 = C๓digo do Or็amento                                             บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSigaLoja                                                     	           บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/  
Method OrcValReserva(cOrcmto) Class LjClEstVen 
Local lRet := .T. 			//Validacao da reserva ok    
Local aReservas := {}  		//Reservas
Local nCntRes := 0     		//Contador reservas
Local cOrcPai  := ""   		//Orcamento-Pai
Local lPedRes := SL1->(FieldPos("L1_PEDRES")) > 0 //Posicao da coluna L1_PEDRES
Local aAreaSL1 := nil		//WorkArea SL1
Local aAreaSL2 := nil		//WorkArea SL2
Local aAreaSF2 := nil		//WorkArea SF2
Local aAreaSC5 := nil		//WorkArea SC5   
Local aQuery := {}			//Querys
Local cCondicao := nil		//condicao   
Local aLeg := {}            //Legenda
Local lLstPre := .F.

If Self:lRetag //Estแ via WS  



	aAreaSL1 := SL1->(GetArea())      
	DbSelectArea("SL1")
	
    //Primeiramente limpa o filtro do orcamento
    //	
	If !Self:lRetagOrc .and. !Self:lJob
   		EndFilBrw("SL1",Self:aQuery)
    EndIf
 
	SL1->(DbSetOrder(1))
	SL1->(DbSeek(xFilial("SL1")+ cOrcmto))
	  

	If Empty( SL1->L1_DOCPED ) .AND. !Empty( SL1->L1_FILRES ) .AND. (Empty(L1_DOC) .AND. Empty(L1_SERIE))
	
		Self:cMensagem := STR0013 //"Este orcamento nใo poderแ ser excluido porque se trata de um or็amento com reserva."
		lRet := .F.
	EndIf  
     

	If lRet .and. !Empty(SL1->L1_DOC)   //LRETAGUARDA   
	
		aAreaSF2 := SF2->(GetArea())
	
		DbSelectArea("SF2")
		DbSetOrder(1)
		DbSeek(xFilial("SF2")+PadR(SL1->L1_DOC,TamSx3("F2_DOC")[1])+SL1->L1_SERIE)
	
		If SF2->(Found()) .and. !Empty( SF2->F2_NFCUPOM )
	
			Self:cMensagem := STR0014 + " " + Subs( SF2->F2_NFCUPOM,4 ) +STR0015//"Nใo ้ possํvel excluir este documento. A Nota Fiscal " XXXXXX " estแ relacionada a este cupom fiscal.
			lRet := .F.
		EndIf
		
		RestArea(aAreaSF2)
		
	EndIf

	
	If lRet .and. !Empty( SL1->L1_DOCPED )
		
		cOrcPai := SL1->L1_NUM
		SL1->( DbSetOrder( 1 ) )  
		
		
		aAreaSL2 := SL2->(GetArea())
		aAreaSC5 := SC5->(GetArea())
		
		DbSelectArea("SL2")
		SL2->( DbSetOrder( 1 ) )
		SL2->( DbSeek( xFilial( "SL2" ) + cOrcmto ) ) 
	
	
		While  lRet .and. !SL2->(Eof()) .AND. xFilial("SL2") + Rtrim(SL2->L2_NUM) == xFilial("SL1") + Rtrim(cOrcmto)
			
			lLstPre	:= Iif(SL1->L1_RESERVA == "S",.T.,.F.)
			 		
			If !Empty( SL2->L2_ORCRES ) .And. !lLstPre
				If (nCntRes := aScan(aReservas,{|l| l[1]+l[2] == SL2->L2_FILRES + SL2->L2_ORCRES})) = 0
					AAdd( aReservas, {SL2->L2_FILRES,SL2->L2_ORCRES} )
					nCntRes := Len( aReservas )
				EndIf
			EndIf
			
			If !lLstPre
			   	SL1->( DbSeek( aReservas[nCntRes][1]+aReservas[nCntRes][2] )) //Filial da reserva + orcamento da reserva
			  	
			  	If SL1->L1_TIPO == "V"  .AND. !Empty(SL2->L2_ENTREGA) .AND.  SL2->L2_ENTREGA <> '2' .and. !Empty(SL1->(L1_DOC+L1_SERIE) )
			   	    Self:cMensagem := STR0016//"Este pedido possui orcamentos finalizados, favor efetuar a devolucao do pedido pela rotina de trocas (LOJA720)"
			   		lRet := .F.
			   		Exit
			   	EndIf 
			   	
				If lPedRes .AND. !Empty(SL1->L1_PEDRES)  
				
					DbSelectArea("SC5")      //RETAGUARDA
					DbSetOrder(1)		//Filial + Pedido  
					
					If DbSeek(aReservas[nCntRes][1] + SL1->L1_PEDRES)
						If !Empty(SC5->C5_NOTA) .AND. !Empty(SC5->C5_SERIE)
							Self:cMensagem := STR0017//	//"Este Pedido possui Pedidos de Venda finalizados, nao sera possivel efetuar o cancelamento."###"Atencao"
							lRet := .F.
							Exit
						EndIf
					EndIf 
					
				EndIf 
			EndIf
			SL2->(DbSkip(1))
		EndDo
		
		RestArea(aAreaSL2)
		RestArea(aAreaSC5)
		
	EndIf
	
	RestArea(aAreaSL1)   
	
	//Restaura o filtro do Browse do SL1
	If !Self:lRetagOrc   .and. !Self:lJob
		DbSelectArea("SL1")
		cCondicao := "(!Empty(L1_DOC) .OR. !Empty(L1_DOCPED)) .AND. ( !Empty(L1_SERIE) .Or. !Empty(L1_SERPED) ) .AND. L1_TIPO <> 'D' .AND. ( L1_TIPO == 'V' .or. L1_TIPO == 'P') .AND. L1_STORC <> 'E'"                   
		Eval({|| FilBrowse("SL1",@aQuery,@cCondicao) })
		
		Self:aQuery := aQuery
	EndIf

Else 
	//Executa o Ws de Valida็ใo da Reserva
	lRet := Self:OrcWsValReserva(cOrcmto)
EndIf

Return lRet 

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออออออออออออหอออออออัอออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบMetodo    |OrcWsValReserva       บAutor  ณFabiana Cristina     บ Data ณ  02/12/2010 บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออสอออออออฯอออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณExecuta o WS de Valida็๕es do Orcamento na Reserva                       บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ 
ฑฑบParametrosณ ExpC1 = 	Orcamento                                                      บฑฑ 
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ 
ฑฑบUso       ณSigaLoja                                                     	           บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/  
Method OrcWsValReserva(cOrcmto) Class LjClEstVen
Local lRet := .t.           //Retorno da Funcao
Local oWsOrcamento := Nil   //Objeto WebService

 oWsOrcamento := WSLJESTORC():New()   
 oWsOrcamento:_URL := Self:cURLWebService  

 If !(lRet := oWsOrcamento:LjEstOrcVRe(cOrcmto, cEmpAnt, cFilAnt) )
 	Self:cMensagem := STR0002+CRLF+STR0012 // "Problemas na execu็ใo do WebService." "Rotina cancelada." 	
 Else 
   lRet := oWsOrcamento:lLJESTORCVRERESULT
 EndIf 

Return lRet 


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออออออออออหอออออออัอออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบMetodo    |BuscaTitulosOrcamentoบAutor  ณFabiana Cristina     บ Data ณ  26/11/2010 บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออสอออออออฯอออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณMetodo que realiza a busca dos Tํtulos do Orcamento                     บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SigaLoja                                                     	      บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method BuscaTitulosOrcamento() Class LjClEstVen  
Local aAreaSE1 := SE1->(GetArea()) 	 //WorkArea SE1
Local aAreaSE5 := SE5->(GetArea())  //WorkArea SE5
Local nPos := 0                      //Posicao do titulo
Local cChave := ""                   //Chave do tํtulo
Local cIndice := ""                  //Indice do titulo
Local nPos2	:= 0                     //Posicao
Local cIndice2 := ""                 //Indice do pagamento
Local cChaveSE1 := ""                //Chave do titulo

If Self:lRetag   
	
	DbSelectArea("SE1")
	DbSetOrder(1) //E1_FILIAL+E1_PREFIXO+E1_NUM
	cIndice :=	SE1->(IndexKey())        
	
	DbSelectArea("SE5") 
	DbSetOrder(7)
	cIndice2 := SE5->(IndexKey())   //E5_FILIAL+E5_PREFIXO+E5_NUMERO+E5_PARCELA+E5_TIPO+E5_CLIFOR+E5_LOJA+E5_SEQ+E5_RECPAG                                                                            

	
	cChave := xFilial("SE1")+PadR(Self:cSerie, TamSx3("E1_PREFIXO")[1]) +  PadR(Self:cOrc_Cupom, TamSx3("E1_NUM")[1])
	SE1->(DbSeek(cChave))
	
	Do While SE1->(!Eof() .and. E1_FILIAL +E1_PREFIXO + E1_NUM == cChave) 
	     
	     DbSelectArea("SE1")
	     aAdd(Self:aSE1, LjClSE1():New(SE1->(&(cIndice)), 1 ))
	     
	     nPos := nPos + 1    
	     //Alimenta os campos dos tํtulos
	     
	    Self:aSE1[nPos]:cE1_SITUACA := SE1->E1_SITUACA	
		Self:aSE1[nPos]:dE1_EMISSAO := SE1->E1_EMISSAO
		Self:aSE1[nPos]:dE1_VENCTO := SE1->E1_VENCTO
		Self:aSE1[nPos]:dE1_BAIXA  := SE1->E1_BAIXA
		Self:aSE1[nPos]:cE1_STATUS := SE1->E1_STATUS
		Self:aSE1[nPos]:cE1_PARCELA := SE1->E1_PARCELA
		Self:aSE1[nPos]:cE1_TIPO  := SE1->E1_TIPO
		Self:aSE1[nPos]:nE1_SALDO  := SE1->E1_SALDO
		Self:aSE1[nPos]:cE1_ORIGEM := SE1->E1_ORIGEM     
		Self:aSE1[nPos]:nE1_VALOR  := SE1->E1_VALOR
		Self:aSE1[nPos]:cE1_NUMCRD := SE1->E1_NUMCRD
		Self:aSE1[nPos]:cE1_PORTADO := SE1->E1_PORTADO 
		Self:aSE1[nPos]:nE1_VLRREAL := SE1->E1_VLRREAL
	  	Self:aSE1[nPos]:cE1_FLUXO := SE1->E1_FLUXO
	  	
	  	cChaveSE1 := SE1->(E1_FILIAL+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO+E1_CLIENTE+E1_LOJA)    
	    DbSelectArea("SE5") 
        nPos2 := 0
	    DbSeek(cChaveSE1)
	    Do While SE5->(!Eof() .and. E5_FILIAL+E5_PREFIXO+E5_NUMERO+E5_PARCELA+E5_TIPO+E5_CLIFOR+E5_LOJA == cChaveSE1) 
	    	aAdd( Self:aSE1[nPos]:aSE5,  LjClSE5():New(SE5->(&(cIndice2)), 7))
	    	nPos2 := nPos2 + 1    	
	    	Self:aSE1[nPos]:aSE5[nPos2]:cE5_TIPODOC := SE5->E5_TIPODOC //Tipo do Documento
			Self:aSE1[nPos]:aSE5[nPos2]:dE5_DATA := SE5->E5_DATA  //Data da movimenta็ใo
			Self:aSE1[nPos]:aSE5[nPos2]:cE5_AGENCIA := SE5->E5_AGENCIA   //Agencia da Conta
			Self:aSE1[nPos]:aSE5[nPos2]:cE5_TIPO := SE5->E5_TIPO  //Tipo do Tํtulo  
			Self:aSE1[nPos]:aSE5[nPos2]:nE5_VALOR := SE5->E5_VALOR  //Valor do Lan็amento        
			Self:aSE1[nPos]:aSE5[nPos2]:cE5_BANCO := SE5->E5_BANCO   //C๓digo do Banco   
			Self:aSE1[nPos]:aSE5[nPos2]:cE5_CONTA := SE5->E5_CONTA  //Conta Corrente do Banco
			Self:aSE1[nPos]:aSE5[nPos2]:cE5_RECPAG := SE5->E5_RECPAG  //Recebimento ou Pagamento 
			Self:aSE1[nPos]:aSE5[nPos2]:cE5_MOTBX := SE5->E5_MOTBX  //Motivo da Baixa do Tํtulo    
			SE5->(DbSkip(1))
	    EndDo
		SE1->(DbSkip(1))
	EndDo

	RestArea(aAreaSE1)
	RestArea(aAreaSE5)

Else 
	Self:BuscaWsTitulosOrcamento(Self:cSerie, Self:cOrc_Cupom)
EndIf

Return      

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออออออออออออหอออออออัอออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบMetodo    |BuscaWsTitulosOrcamentoบAutor  ณFabiana Cristina     บ Data ณ  26/11/2010 บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออสอออออออฯอออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณMetodo que realiza a busca dos Tํtulos do Orcamento via WS                บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ 
ฑฑบParametrosณ ExpC1 = Serie do Cupom                                                   บฑฑ
ฑฑบ          ณ ExpC2 = Numero do Cupom                                                  บฑฑ 
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ 
ฑฑบUso       ณ SigaLoja                                                        	        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method BuscaWsTitulosOrcamento(cSerie, cCupom) Class LjClEstVen      
Local lRet := .t.              //Retorno de execucao da funcao
Local oWsOrcamento := Nil      //Objeto WebService
Local nC := 0                  //Variavel contadora

 oWsOrcamento := WSLJESTORC():New()   
 oWsOrcamento:_URL := Self:cURLWebService  

 If !(lRet := oWsOrcamento:LjEstOrcTit(cSerie, cCupom, cEmpAnt, cFilAnt) )
 	MsgAlert(STR0002+CRLF+STR0012) // "Problemas na execu็ใo do WebService." "Rotina cancelada." 	
 Else 
   	For nC := 1 to Len(oWsOrcamento:oWSLJESTORCTITRESULT:oWSTRETSE1)  
   		aAdd( Self:aSE1, LjClSE1():New("", 1 )  )
   		Self:aSE1[nC]:cChave := oWsOrcamento:oWSLJESTORCTITRESULT:oWSTRETSE1[nC]:cChave 
   		Self:aSE1[nC]:cE1_SITUACA := oWsOrcamento:oWSLJESTORCTITRESULT:oWSTRETSE1[nC]:cE1_SITUACA	
		Self:aSE1[nC]:dE1_EMISSAO := oWsOrcamento:oWSLJESTORCTITRESULT:oWSTRETSE1[nC]:dE1_EMISSAO
		Self:aSE1[nC]:dE1_VENCTO := oWsOrcamento:oWSLJESTORCTITRESULT:oWSTRETSE1[nC]:dE1_VENCTO
		Self:aSE1[nC]:dE1_BAIXA  := oWsOrcamento:oWSLJESTORCTITRESULT:oWSTRETSE1[nC]:dE1_BAIXA
		Self:aSE1[nC]:cE1_STATUS := oWsOrcamento:oWSLJESTORCTITRESULT:oWSTRETSE1[nC]:cE1_STATUS
		Self:aSE1[nC]:cE1_PARCELA := oWsOrcamento:oWSLJESTORCTITRESULT:oWSTRETSE1[nC]:cE1_PARCELA
		Self:aSE1[nC]:cE1_TIPO  := oWsOrcamento:oWSLJESTORCTITRESULT:oWSTRETSE1[nC]:cE1_TIPO
		Self:aSE1[nC]:nE1_SALDO  := oWsOrcamento:oWSLJESTORCTITRESULT:oWSTRETSE1[nC]:nE1_SALDO
		Self:aSE1[nC]:cE1_ORIGEM := oWsOrcamento:oWSLJESTORCTITRESULT:oWSTRETSE1[nC]:cE1_ORIGEM     
		Self:aSE1[nC]:nE1_VALOR  := oWsOrcamento:oWSLJESTORCTITRESULT:oWSTRETSE1[nC]:nE1_VALOR
		Self:aSE1[nC]:cE1_NUMCRD := oWsOrcamento:oWSLJESTORCTITRESULT:oWSTRETSE1[nC]:cE1_NUMCRD
		Self:aSE1[nC]:cE1_PORTADO := oWsOrcamento:oWSLJESTORCTITRESULT:oWSTRETSE1[nC]:cE1_PORTADO 
		Self:aSE1[nC]:nE1_VLRREAL := oWsOrcamento:oWSLJESTORCTITRESULT:oWSTRETSE1[nC]:nE1_VLRREAL
	  	Self:aSE1[nC]:cE1_FLUXO := oWsOrcamento:oWSLJESTORCTITRESULT:oWSTRETSE1[nC]:cE1_FLUXO
  		
   		Self:aSE1[nC]:aSE5 := aClone(oWsOrcamento:oWSLJESTORCTITRESULT:oWSTRETSE1[nC]:oWSASE5:oWSTRETSE5)
   	Next
   	
 EndIf 

Return lRet                                            

Return .t. 

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออออออออออออหอออออออัอออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบMetodo    |TEFCancela             บAutor  ณFabiana Cristina     บ Data ณ  07/12/2010 บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออสอออออออฯอออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณMetodo que realiza o cancelamento da Transacao TEF                        บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SigaLoja                                                        	        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Method TEFCancela(lProssegue) Class LjClEstVen
Local cTipTEF		:= LJGetStation("TIPTEF")	//Indica o tipo de TEF
Local nPagtoTEF		:= 0 			// Numero de transa็๕es via TEF
Local nPagDigPix	:= 0			// Informar o numero de transa็๕es em Pagamentos Digitais / PIX
Local nX			:= 0 			// Contador do For

DEFAULT lProssegue := .T.

For nX := 1 To Len(Self:aOrc_Pagtos) //Digitais / PIX
	// Verifica se tem pagamentos via TOTVS Pagamentos Digitais (TPD)
	If AlLTrim( Self:aOrc_Pagtos[nX,__L4_FORMA] ) $ _FORMATPD
		nPagDigPix += 1
	Else 
		// Pagamentos via TEF - CC/CD
		nPagtoTEF += 1
	EndIf

Next nX

If Self:cOrc_VendTEF = "S" .or. (aScan(Self:aOrc_Pagtos, {|l| !Empty(l[__L4_DOCTEF])  .or. !Empty(l[__L4_NSUTEF])}) > 0) // SL1->L1_FORMPG$"CC|CD|CH" .OR. AllTrim(L4_FORMA) $ "CC|CD|CH"
	If !lUsaTef
   		Help(" ","1","NAOTEF")
   		
	Else
        If Val(Self:cOrc_DocCanc) > 0 
        
        	Aviso(STR0020,STR0032 , {STR0031},, STR0033+Alltrim(Self:cOrc_DocCanc) )  //Aten็ใo, "Transa็ใo TEF jแ cancelada""&Ok""Canc: "
		Else
			
           If  cTipTEF $ TEF_SEMCLIENT_DEDICADO+";"+TEF_COMCLIENT_DEDICADO+";"+TEF_DISCADO
           
  			  Self:TEFGenericoCancela() //Rotina de Cancelamento TEF Generico    - somente na esta็ใo aonde foi originada a venda

			ElseIf  cTipTEF == TEF_CLISITEF .AND. nPagtoTEF > 0

				 Self:TEFSiTEFCancela(@lProssegue)
				 oTEF:lEstVenda := .F. //Muda variavel para estorno  
			EndIf

			If nPagDigPix > 0
            	Self:PagtoDigitalCancela(@lProssegue)
			EndIf
			
		EndIf //Or็camento jแ cancelado
			 
	EndIf  //Esta็ใo Sem TEf

EndIf  //Venda Com TEF

Return    

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออออออออออออหอออออออัอออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบMetodo    |TEFGenericoCancela     บAutor  ณFabiana Cristina     บ Data ณ  07/12/2010 บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออสอออออออฯอออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณMetodo que realiza o cancelamento da TransacaoTEF                         บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SigaLoja                                                        	        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Method TEFGenericoCancela() Class LjClEstVen  
Local aAreaSL1 := SL1->(GetArea())  //WorkArea SL1
Local nPos			:= 0             //Posicao 
Local nParc			:= 0             //Parcela
Local cFormaPg		:= _FORMATEF     //Forma de pagamento
Private aParcTef	:= {}            //Parcelas TEF
Private aTefMult	:= {}            //Multiplas transacoes TEF
Private lTefMult	:= SuperGetMV("MV_TEFMULT", NIL, .F.)  //TEF Multiplas transacoes
Private nTotal     	:= 0             //total
Private aTefDados   := {}            //Dados TEF
Private aTefChq		:= {}            //TEF Cheque

If LjProfile(17)
	DbSelectArea("SL1")
	DbSetOrder(1)  
	//POSICINA NO SL1 - LOCALMENTE  - NรO LOCALIZOU, ENTรO ERRO
	If !SL1->(DbSeek(xFilial("SL1")+ Self:cOrcamento))
	   	MsgAlert(STR0018)	 //	"Para cancelamento de transa็๕es TEF, a venda deverแ ser cancelada no PDV aonde foi realizada a venda"
	Else
	
		If !lTefMult
			//VERIFICANDO SE EFETUOU OPERAวรO TEF				
			//Cancelamento de Garantia de Cheque TecBan, sendo que o tํtulo deverแ estar no porte do caixa
			If AllTRim(Self:cOrc_FormPg) == "CH" .AND. At(__TECBAN,Upper(AllTrim(Self:cOrc_Institu)))<>0
				//Buscando os dados do cheque para enviar a transa็ใo		
				aTefChq :=  Self:BuscaChequesOrcamento() 
				cFormaPg := cFormaPg + "/CH"
			EndIf
		EndIf	
			
		If Loja010T("E") 
		
			If lTefMult    
	    			nParc:=0
					While (nParc := nParc + 1 ) <= Len(Self:aOrc_Pagtos)
	
				        If (nPos := Ascan(aTefMult,{|t| AllTrim(t[7][1][4]) == AllTrim(Self:aOrc_Pagtos[nParc, __L4_DOCTEF]) }))<> 0  //Busca a transacaoTEf
		                		   	           					                			
							aTefDados:=aClone(aTefMult[nPos][7])
	
							Self:aOrc_Pagtos[nParc, __L4_DOCCANC] :=  aTefDados[1][6]
							Self:aOrc_Pagtos[nParc, __L4_DATCANC] :=  aTefDados[1][12]
							Self:aOrc_Pagtos[nParc, __L4_HORCANC] := aTefDados[1][7]
	                        Self:aOrc_Pagtos[nParc, __L4lEstorn ] := .T. 
	                        
	                        Self:cOrc_DocCanc  := aTefDados[1][6]                                                    
	   						Self:cOrc_DatCanc  := aTefDados[1][12]                                                     
							Self:cOrc_HorCanc  := aTefDados[1][7] 
		
						EndIf	
					End	
	
			Else
				

				
				Self:cOrc_DocCanc := aTefDados[1][6]
				Self:cOrc_DatCanc := aTefDados[1][12]
				Self:cOrc_HorCanc := aTefDados[1][7] 

			   If !Empty(aTEFDados[1][15]) .and. (nParc := aScan(Self:aOrc_Pagtos, {|p| AllTrim(p[ __L4_FORMA]) $ aTEFDados[1][15] }) ) > 0 //validar mais dados do aTEFDados
							Self:aOrc_Pagtos[nParc, __L4_DOCCANC] :=  aTefDados[1][6]
							Self:aOrc_Pagtos[nParc, __L4_DATCANC] :=  aTefDados[1][12]
							Self:aOrc_Pagtos[nParc, __L4_HORCANC] := aTefDados[1][7]
	                        Self:aOrc_Pagtos[nParc, __L4lEstorn ] := .T.  
			   ElseIf	(nParc := aScan(Self:aOrc_Pagtos, {|p| AllTrim(p[ __L4_FORMA]) $ cFormaPg }) ) > 0  
							Self:aOrc_Pagtos[nParc, __L4_DOCCANC] :=  aTefDados[1][6]
							Self:aOrc_Pagtos[nParc, __L4_DATCANC] :=  aTefDados[1][12]
							Self:aOrc_Pagtos[nParc, __L4_HORCANC] := aTefDados[1][7]
	                        Self:aOrc_Pagtos[nParc, __L4lEstorn ] := .T.  			   
			   EndIf   
	 
	
			Endif	
												
		Else
		   	Aviso( STR0020,STR0034 , {STR0031},, STR0027 + Alltrim(Self:cOrc_Cupom) + STR0028+Alltrim(Self:cSerie) ) //aTENCAO, "Nใo foi possํvel estornar as Transa็๕es TEF da Venda ""OK""Documento:""Serie"
		Endif
	
	EndIf	
	 
	RestArea(aAreaSL1)   
Else
	Help(" ","1","NAOTEF") 
EndIf
Return    

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออออออออออหอออออออัอออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบMetodo    |BuscaChequesOrcamentoบAutor  ณFabiana Cristina     บ Data ณ  08/12/2010 บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออสอออออออฯอออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณMetodo que realiza a busca dos Cheques do Orcamento                     บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ 
ฑฑบParametrosณ ExpC1 = 	Serie do Cupom                                                บฑฑ  
ฑฑบ          ณ ExpC2 = 	Cupom                                                         บฑฑ 
ฑฑบ          ณ ExpL3 =  titulo no porte do caixa                                      บฑฑ 
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ 
ฑฑบUso       ณ SigaLoja                                                     	      บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method BuscaChequesOrcamento(cSerie, cCupom, lPorteCx) Class LjClEstVen    
Local aCheques  := {}    //Cheques
Local aAreaSEF := nil    //WorkArea Cheques
Local nPos := 0          //Posicao

Default cSerie := Self:cSerie
Default cCupom := Self:cOrc_Cupom 

If lPorteCX = Nil
   lPorteCX :=	(nPos := aScan(Self:aOrc_Pagtos, {|p| p[__L4_FORMA] = "CH" .and. !Empty( p[__PORTE]) .and. p[__PORTE] <> "2"})) > 0
EndIf

If lPorteCX
	If Self:lRetag 
		aAreaSEF := SEF->(GetArea())
		DbSelectArea("SEF")
		DbSetOrder(3) //EF_FILIAL+EF_PREFIXO+EF_TITULO+EF_PARCELA+EF_TIPO+EF_NUM+EF_SEQUENC 
		If DbSeek(xFilial("SEF") + cSerie + cCupom )	   
			aCheques = {	SEF->EF_BANCO	,;
			   				SEF->EF_AGENCIA	,; 
			   				SEF->EF_CONTA	,; 
			   				SEF->EF_NUM     ,;
			   				SEF->EF_VALOR    }
		EndIf  
		
		RestArea(aAreaSEF)
	Else
		If Self:lOffLine 
			If nPos > 0
				aCheques := {	Self:aOrc_Pagtos[nPos, __L4_ADMINIS]	,;
					   				Self:aOrc_Pagtos[nPos, __L4_AGENCIA]	,; 
					   				Self:aOrc_Pagtos[nPos, __L4_CONTA ]	,; 
					   				Self:aOrc_Pagtos[nPos, __L4_NUMCART]    ,;
					   				Self:aOrc_Pagtos[nPos, __L4_VALOR]    }  
			EndIf
		Else
		   aCheques := Self:BuscaWsTitulosOrcamento(cSerie, cCupom, lPorteCX)
		EndIf
	EndIf
EndIf
Return  aCheques   


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออออออออออออหอออออออัอออออออออออออออออออหออออออัอออออออออออออออปฑฑ
ฑฑบMetodo    |BuscaWSChequesOrcamentoบAutor  ณFabiana Cristina   บ Data ณ  08/12/2010   บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออสอออออออฯอออออออออออออออออออสออออออฯอออออออออออออออนฑฑ
ฑฑบDesc.     ณMetodo que realiza a busca dos Cheques do Orcamento via WS                บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ ExpC1 = 	Serie do Cupom                                                  บฑฑ  
ฑฑบ          ณ ExpC2 = 	Cupom                                                           บฑฑ 
ฑฑบ          ณ ExpL3 =  titulo no porte do caixa                                        บฑฑ 
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SigaLoja                                                        	        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method BuscaWsChequesOrcamento(cSerie, cCupom, lPorteCx) Class LjClEstVen   
Local aCheques := {}     	//Cheques

Local lRet := .t.          //Retorno da Funcao
Local oWsOrcamento := Nil  //Objeto WebService


oWsOrcamento := WSLJESTORC():New()   
oWsOrcamento:_URL := Self:cURLWebService  

If !(lRet := oWsOrcamento:LjEstOrcChq(cSerie, cCupom, lPorteCx, cEmpAnt, cFilAnt) )
  MsgAlert(STR0002+CRLF+ STR0011) // "Problemas na execu็ใo do WebService."+"A rotina de estorno serแ realizada off-line."
  Self:lOffLine := .T.
  aCheques := Self:BuscaChequesOrcamento() //Realiza a busca local		
  
Else
  If !Empty(oWSLJESTORCCHQRESULT:cEF_AGENCIA).and. ;
    !Empty(oWSLJESTORCCHQRESULT:cEF_BANCO) .and. ;
  	!Empty(oWSLJESTORCCHQRESULT:cEF_CONTA) .and. ;
  	!Empty(oWSLJESTORCCHQRESULT:cEF_NUM)  
  	
  	aCheques = {oWSLJESTORCCHQRESULT:cEF_BANCO	,;
			  oWSLJESTORCCHQRESULT:cEF_AGENCIA	,; 
			  oWSLJESTORCCHQRESULT:cEF_CONTA,; 
			  oWSLJESTORCCHQRESULT:cEF_NUM,;
			  WSLJESTORCCHQRESULT:nEF_VALOR}
  EndIf			  
EndIf

Return aCheques

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออออออออออออหอออออออัอออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบMetodo    |TEFSiTEfCancela        บAutor  ณFabiana Cristina     บ Data ณ  08/12/2010 บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออสอออออออฯอออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณMetodo que realiza o cancelamento da TransacaoTEF                         บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SigaLoja                                                        	        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Method TEFSiTEfCancela(lProssegue) Class LjClEstVen
Local nTransacoes   := 0   //Contador de Transa็๕es
Local nC   			:= 0   //Contador
Local nPos 			:= 0   //Posicao do Array
Local nCountCart    := 0   //Contador de parcelas

DEFAULT lProssegue := .T.

                        
//E1_FILIAL+E1_CLIENTE+E1_LOJA+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO    
//FUNCAO PARA VERIFICAR SE O TITULO CORRESPONDENTE ESTA EM ABERTO PARA PODER REALIZAR O ESTORNO

aSort( Self:aOrc_Pagtos,,, {|x,y| x[__L4_FORMAID] < y[__L4_FORMAID] } ) //__L4_FORMAID 
	
Do While  (nC := nC  + 1)  <= Len(Self:aOrc_Pagtos)
	If !Empty(Self:aOrc_Pagtos[nC, __L4_DOCTEF]) .AND. Self:PagtoPodeCompensar(Self:aOrc_Pagtos[nC], Self:aSE1) .AND. AllTrim(Self:aOrc_Pagtos[nC, __L4_FORMA] ) $ _FORMATEF // "CC;CD"
		// Verifica se mudou ID do cartao para incrementar nTransacoes 
	    If nC == 1 .Or. (Self:aOrc_Pagtos[Iif(nC>1,nC-1,nC), __L4_FORMAID] <> Self:aOrc_Pagtos[nC, __L4_FORMAID] .Or. ;
	                     Self:aOrc_Pagtos[Iif(nC>1,nC-1,nC), __L4_FORMA] <> Self:aOrc_Pagtos[nC, __L4_FORMA]) 
			nTransacoes:=nTransacoes+1
		Endif	
	EndIf
EndDo

If nTransacoes > 0

	oTEF:lEstVenda := .T. //Muda variavel para estorno 

	For nC := 1 To nTransacoes

		If Self:aOrc_Pagtos[nC, __TP_TRANS] == "TEF"
			oTEF:Operacoes("GERENCIAIS",{}) 
							//Valida o retorno						   						 
			If !Empty(oTef:aRetCartao[1]:cNsuAutor)	    
				nPos := AScan(Self:aOrc_Pagtos, {|p| (p[__L4_DATATEF] == DtoS(oTef:aRetCartao[oTef:nTrans]:dDataCanRei) .Or. ;  
													p[__L4_DATATEF] == DtoS(oTef:aRetCartao[oTef:nTrans]:dDataTrans)) .And. ;
												(  AllTrim(p[__L4_DOCTEF]) ==	Alltrim(oTef:aRetCartao[oTef:nTrans]:cDocCanRei) .Or. ;
													AllTrim(p[__L4_NSUTEF]) == Alltrim(oTef:aRetCartao[oTef:nTrans]:cDocCanRei) ) .And.;							   			     	 
													Alltrim(p[__L4_FORMA ]) == Alltrim(oTef:aRetCartao[oTef:nTrans]:cForma) } ) 					   			 
																																											
				If nPos > 0
		
					Self:cOrc_DocCanc := oTef:aRetCartao[1]:cNsuAutor
					Self:cOrc_DatCanc := StrTran(DToC(oTef:aRetCartao[1]:dDataCanRei),"/","")
					Self:cOrc_HorCanc := oTef:aRetCartao[1]:cHoraTrans 
														
					For nCountCart := nPos to Len(Self:aOrc_Pagtos)
						// Se for o mesmo ID do cartao atualiza os dados do Estorno
						If Self:aOrc_Pagtos[nCountCart, __L4_FORMAID] ==  Self:aOrc_Pagtos[nPos, __L4_FORMAID]
							Self:aOrc_Pagtos[nCountCart, __L4_DOCCANC] := oTef:aRetCartao[1]:cNsuAutor
							Self:aOrc_Pagtos[nCountCart, __L4_DATCANC] := StrTran(DToC(oTef:aRetCartao[1]:dDataCanRei),"/","")
							Self:aOrc_Pagtos[nCountCart, __L4_HORCANC] := oTef:aRetCartao[1]:cHoraTrans
							Self:aOrc_Pagtos[nCountCart, __L4lEstorn ] := .T.
						Endif	  
					Next nCountCart
			
					If  !Self:PagtoPodeCompensar(Self:aOrc_Pagtos[nPos], Self:aSE1) //Verifica se o tํtulo esta em aberto
						Aviso( STR0020, STR0035+ CRLF +;       //Aten็ใo "A Transa็ใo TEF cancelada nใo poderia ter sido estornada, pois o tํtulo jแ possui baixas ou nใo estแ no porte do caixa."
									STR0027 + Alltrim(Self:cOrc_Cupom) + STR0028+Alltrim(Self:cSerie) + ; //Documento: XXXXXX  S้rie
									STR0029+  AllTrim(Self:aOrc_Pagtos[nPos,__L4_FORMA]) + ; //Tipo:
									STR0036+ AllTrim(Self:aOrc_Pagtos[nPos,__E1_PARCELA ])  +;   //" Parcela:"
									STR0030+  AllTrim(Self:aOrc_Pagtos[nPos,__L4_ADMINIS]), {STR0031},,  STR0037 + Alltrim(oTef:aRetCartao[oTef:nTrans]:cDocCanRei) )   //" Administradora:""&Ok""NSU Origem:"
						Self:aOrc_Pagtos[nPos, __L4lEstorn ] := .F.  				 
					EndIf
					If !Empty(oTef:aRetCartao[1]:cDocCanRei) .And. nModulo == 23 
						oTEF:aRetCartao := {}
					EndIf	
				Else
					Aviso( STR0020, STR0038+ CRLF + STR0027 + Alltrim(Self:cOrc_Cupom) +;//"A Transa็ใo TEF cancelada nใo se refere เs transa็๕es da Venda.""Documento:"
						STR0028+Alltrim(Self:cSerie), {STR0031},,  STR0037+ Alltrim(oTef:aRetCartao[oTef:nTrans]:cDocCanRei) )  //	 "  Serie:""OK""NSU Origem:" 
					lProssegue := .F.
					Exit
				EndIf
			
			Else
				Aviso( STR0020, STR0038, {STR0031},, STR0027 + Alltrim(Self:cOrc_Cupom) + STR0028+Alltrim(Self:cSerie) ) //Nใo foi possํvel estornar as transa็๕es TEF da venda""&Ok" "Documento:""  Serie:" 
				lProssegue := .F.
				Exit
			EndIf
		ElseIf Self:aOrc_Pagtos[nC, __TP_TRANS] == "POS"
			If IsBlind()
				Help( " ", 1, "Help",, STR0071, 1, 0 ) // "Transa็ใo realizada via POS, necessแrio realizar o estorno manualmente."
			Else
				MsgInfo(STR0071)
			Endif
			LjGrvLog("LOJA600",STR0071,)
		EndIf
	Next 
	
	oTEF:lEstVenda := .F. // Restaura Muda variavel para nใo estorno

	// Este array e reinicializado no metodo ImpCupTef quando oTef:nCodFuncao for diferente 110 (Cancelamento) 
	// Quando oTef:nCodFuncao for 110 (Cancelamento), sera reinicializado neste ponto	
	oTef:aRetCartao := {} 
 
EndIf 
Return 

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออออออออออออหอออออออัอออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบMetodo    |CalculaParcelas       บAutor  ณFabiana Cristina     บ Data ณ  10/12/2010 บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออสอออออออฯอออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณMetodo que calcula as Parcelas de um pagamento                           บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ 
ฑฑบParametrosณ ExpA1 = Pagamentos da Venda ExpA1[n,22], conforme define acima          บฑฑ  
ฑฑบ          ณ ExpC2 = 	Orcamento                                                      บฑฑ 
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ 
ฑฑบUso       ณSigaLoja                                                     	           บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/   
Method CalculaParcelas(aPagtos, cOrcmto) Class LjClEstVen       
Local aArea			:= GetArea()      //WorkAreas Ativas
Local lUsaVP		:= SuperGetMV("MV_LJVALEP",,.F.)  						// Utiliza Vale Presente    
Local cParcela      := PadR(SuperGetMV("MV_1DUP"), TamSx3("E1_PARCELA")[1]) //1 Duplicata	
Local c1DUP         := SuperGetMV("MV_1DUP")   //1 Duplicata
Local lAdmin        := .F.    		//Administradora
Local lAglutina     := .F.    		//Aglutina
Local nI			:= 0  			//contador
Local cL1Doc        := ""           //Documento
Local cSerie        := ""           //Serie
Local cForma		:= ""           //Forma
Local nPos	        := 0            //Posicao
Local aFormas := {  }               //Formas
   

aSort(aPagtos,,,{|x,y| 	x[__L4_FORMA] + x[__L4_ADMINIS] + x[__L4_FORMAID] + DtoS(x[__L4_DATA]) <;
						y[__L4_FORMA] + y[__L4_ADMINIS] + y[__L4_FORMAID] + DtoS(y[__L4_DATA])})     
						
DbSelectArea("SX5")
SX5->(DbSeek(xFilial("SX5")+"24"))
Do While SX5->(!Eof() .and. X5_FILIAL + X5_TABELA == xFilial("SX5")+"24")   
	aAdd(aFormas, {AllTrim(X5_CHAVE) , 0})
	SX5->(DbSkip(1))
EndDo
						
						
DbSelectArea("SAE")
DbSetOrder(1)
				

For nI := 1 To Len(aPagtos)
	
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณPara paises diferentes de Brasil a gravacao dos titulos em $ tem que ser ณ
	//ณrealizada pelo array aPagtos devido o fato de poder existir recebimento emณ
	//ณdiversas moedas...                                                       ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู		
	If 	aPagtos[nI][__L4_VALOR] <= 0 .OR.;
		(AllTrim(aPagtos[nI][__L4_FORMA]) == SuperGetMV("MV_SIMB1") .AND.;
		cPaisLoc == "BRA")
		aPagtos[nI, __E1_PARCELA] := " "
		Loop
	EndIf
	
	lAltParcela := .T.
	
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณPosiciona o SA1 -- DbSeek, para nใo causar lentidใoณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู		

	SAE->(DbSeek(xFilial("SAE")+Left(aPagtos[nI][__L4_ADMINIS],TamSx3("AE_COD")[1])))
	
	aRetTp := LjGrvTpFin( SAE->AE_FINPRO, If( SAE->(FieldPos("AE_AGLPARC")) > 0, SAE->AE_AGLPARC, 2 ) )
	lAglutina	:= aRetTp[1]
	lAdmProp	:= aRetTp[2]  
	
		
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณSe a Administradora ou o ID do Cartao forem diferentes ณ
	//ณda parcela anterior, gera um novo titulo.              ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู			
	lAdmin := .F.
	If nI > 1
		If 	aPagtos[nI][__L4_ADMINIS] <> aPagtos[nI - 1][__L4_ADMINIS] .OR.;
			aPagtos[nI][__L4_FORMAID] <> aPagtos[nI - 1][__L4_FORMAID]
            lAdmin 		:= .T.
  		EndIf
  	Else
  		lAdmin 		:= .T.
  	EndIf   
  	
  	cForma := AllTrim(aPagtos[nI][__L4_FORMA])
		
  	If  (cPaisLoc <> "BRA") .AND. IsMoney(aPagtos[nI,__L4_FORMA])
  		cForma := "DI"
  	EndIf
  	
	If (nPos := aScan(aFormas, {|f| AllTrim(f[1]) = cForma})) = 0  .or.;
	   (AllTrim(aPagtos[nI][__L4_FORMA]) $ "VP" .AND. !lUsaVP)
		nPos := Len(aFormas)
	EndIf
	
	If  !(allTrim(aPagtos[nI][__L4_FORMA]) $ "CC|VA|CO|CD|FI"  .AND. aFormas[nPos, 2] > 0 .and. !lAdmin .AND. lAglutina)		
        aFormas[nPos, 2] := aFormas[nPos, 2] + 1 //Incrementa a Forma   			
	
	EndIf
	

	aPagtos[nI, __E1_PARCELA] :=  LJParcela(aFormas[nPos, 2], c1DUP)

Next nI

RestArea(aArea)

Return aPagtos

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออออออออหอออออออัอออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบMetodo    |PagtoPodeCompensarบAutor  ณFabiana Cristina     บ Data ณ  13/12/2010 บฑฑ
ฑฑฬออออออออออุออออออออออออออออออสอออออออฯอออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณMetodo que verifica se o pagamento pode ser estornado                บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ ExpA1 = Pagamentos da Venda ExpA1[n,22], conforme define acima      บฑฑ  
ฑฑบ          ณ ExpA2 = Tํtulos, conforme classe LjClSE1                            บฑฑ  
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSigaLoja                                                       	   บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/   
Method PagtoPodeCompensar(aPagtos, aSE1)  Class LjClEstVen    
Local lPode			:= .T.        		//Retorno da Funcao
Local lTefMult		:= SuperGetMV("MV_TEFMULT", NIL, .F.)  //TEF Multiplo   
Local cFormaPg		:= _FORMATEF		//Forma de Pagamento
Local lPagtoTEF     := .F.     			//Pagamento TEF
Local lTituloCX     := .T.     			//Titulo no porte do caixa
Local nPos       	:= 0       			//Posicao do titulo


If !IsMoney(aPagtos[__L4_FORMA])   

    If (nPos := aScan(aSE1, {|oT| AllTrim(oT:cE1_TIPO) == AllTrim(aPagtos[__L4_FORMA]) .and.  AllTrim(oT:cE1_PARCELA) == aPagtos[__E1_PARCELA]})) > 0

		If AllTRim(Self:cOrc_FormPg) == "CH" .AND. At(__TECBAN,Upper(AllTrim(Self:cOrc_Institu)))<>0
	
			cFormaPg := cFormaPg + "/CH"
		EndIf
	
	    lPagtoTEF :=  AT(AllTrim(aPagtos[__L4_FORMA]), cFormaPg) > 0
	    
	    lTituloCX :=  Alltrim(aSE1[nPos]:cE1_PORTADO)  ==  AllTrim(Self:cOrc_Opera) 
	    
	    If !lPagtoTEF .Or. IIF( !lTefMult, Empty(Self:cOrc_DocTEF), Empty(aPagtos[__L4_NSUTEF]) )
	    	lTituloCX := lTituloCX .and. aPagtos[__PORTE] <> "2" //Nos tํtulos sem forma de pagamento TEF, Verifica se o usuario informou o porte do caixa  
	    EndIf
	    	    
	    //Verifica se o tํtulo nใo esta baixado
	    lPode := lTituloCX .and.  Round(aSE1[nPos]:nE1_Saldo, 2) > 0	    	
	     
    EndIf

EndIf

Return lPode   
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  |ImpCupEstorno บAutor  ณ Vendas Cliente     บ Data ณ  15/12/10   บฑฑ
ฑฑฬออออออออออุออออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณImprime cupom nao fiscal nao vinculado quando utilizar          บฑฑ
ฑฑบ          ณESTORNO     .                                                   บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametro ณ ExpA1 - Informacoes do valor e forma de pagamento.(aFormaPag)  บฑฑ 
ฑฑบ          ณ    [1] - Parcela                                               บฑฑ
ฑฑบ          ณ    [2] - Forma de pagamento                                    บฑฑ
ฑฑบ          ณ    [3] - valor                                                 บฑฑ
ฑฑบ          ณ ExpA2 - Informacoes do Cupom Estornado  .(aDocDev)             บฑฑ
ฑฑบ          ณ    [1] - Numero do cupom                                       บฑฑ
ฑฑบ          ณ    [2] - Serie                                                 บฑฑ
ฑฑบ          ณ    [3] - Cliente                                               บฑฑ
ฑฑบ          ณ    [4] - Loja                                                  บฑฑ
ฑฑบ          ณ    [5] - Caixa                                                 บฑฑ
ฑฑบ          ณ    [6] - Se (.t.) = OFF-Line  e (.f.) = ON-Line                บฑฑ
ฑฑบ          ณ ExpN3 - Valor total da Compra                                  บฑฑ
ฑฑบ          ณ ExpC3 - Tipo Devolucao                                         บฑฑ
ฑฑบ          ณ                                                                บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ XXXXXXX                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/      
Method ImpCupEstorno( aPagtos, aDocDev, nVlrTotalCompra, cTipoDevol) Class LjClEstVen

Local cTickForm 		:= ""   											// String que guarda o que sera impresso.
Local cTickFormPag 		:= ""    											// Forma de Pagamento
Local nI 				:= 0       											// Contator para o For     
Local nVlrTotalEstorno	:= 0 												// Valor do Estorno
Local lImprime  		:= .T.												// Indica se imprime novamente o relatorio gerencial na impressora
Local cCodClie 			:= ""    										    // Cod Cliente
Local cNomClie 			:= ""    										    // Nome Cliente
Local cFormaDescr 		:= ""    											// Descricao Forma pagamento                          
Local cSimbMoeda		:= SuperGetMV( "MV_SIMB1")          				// Simbolo da moeda corrente do sistema.
Local aArea 			:= GetArea()   										// WorkAreas Ativas
Local nTamChave 		:= TamSX3("X5_CHAVE")[1]  							// Tamanho chave SX5  
Local aFormaPag 		:= {}  												// Array de Impressao das formas de pagamentos
Local nPos     			:= 0        										// Posicao
Local lGuil				:= SuperGetMV("MV_FTTEFGU",, .F.)					// Ativa guilhotina
Local lEmitNFCe 		:= FindFunction("LjEmitNFCe") .AND. LjEmitNFCe()	// Indica a utilizacao da NFC-e
Local lLJ7101   		:= ExistBlock("LJ7101") 							// Indica utiliza็ใo PE LJ7101

//Agrupa os pagamentos pela descricao da forma
For nI := 1 To Len(aPagtos)
	If (nPos := aScan(aFormaPag, {|f| f[1] == aPagtos[nI, 02]} ) ) = 0 
		aAdd(aFormaPag, {aPagtos[nI, 02], 0})
		nPos := Len(aFormaPag)
	EndIf
	aFormaPag[nPos, 02] := aFormaPag[nPos, 02] + aPagtos[nI, 03]
Next

SX5->(DbSetOrder(1))
For nI := 1 To Len( aFormaPag )
	SX5->(DbSeek(xFilial("SX5")+'24'+PadR(aFormaPag[nI, 01], nTamChave)))
	cTickFormPag += PadR( Substr(SX5->X5_DESCRI,1,26) + Transform(aFormaPag[nI, 02], "@E 999,999,999.99"), 40 ) + CHR(13) + CHR(10) // Formas de pagamento.
	nVlrTotalEstorno := nVlrTotalEstorno + aFormaPag[nI, 02]     // valor total estornado.    
Next nI			

cTickForm += CRLF + PadC(STR0040,40) + CRLF //ESTORNO DE VENDA
nI := 0
For nI := 1 To Len( aDocDev )
	Do Case
		Case nI == 1
			cTickForm += CHR(13) + CHR(10)
			cTickForm += PadR( PadR(STR0041,9,".") +": " + aDocDev[nI], 40 ) + CHR(13) + CHR(10) // "Documento.:"
			cTickForm += CHR(13) // + CHR(10)
		Case nI == 2
			cTickForm += PadR( PadR(STR0042,9,".")+": " + aDocDev[nI], 40 ) + CHR(13) + CHR(10) // "Serie.....:"
			cTickForm += CHR(13) // + CHR(10)
		Case nI == 3
			cNomClie := PadR(STR0043,9,".")+": " + RTrim(aDocDev[nI]) // "Cliente...:"
			cCodClie  := aDocDev[nI]
		Case nI == 4         
			SA1->(DbSetOrder(1))
			SA1->(DbSeek(xFilial("SA1")+cCodClie+aDocDev[nI]))
			cNomClie += STR0044 + RTrim(aDocDev[nI])    // "Loja.:"
			cNomClie += " "+ SA1->A1_NOME 
			cTickForm += Left(cNomClie,40) + CHR(13) + CHR(10) 
		Case nI == 5
			cTickForm += PadR( PadR(STR0045,9,".")+": " + aDocDev[nI], 40 ) + CHR(13) + CHR(10) // "Num.Caixa.:"
			cTickForm += CHR(13) 
		Case nI == 6                         
			cTickForm += PadR( PadR(STR0046,9,".")+": " + IIF(aDocDev[nI],STR0047, STR0055), 40 ) + CHR(13) + CHR(10)   // "Processo..:""OFF-Line""ON-Line"
			cTickForm += CHR(13) 
	EndCase
Next nI

cTickForm += CRLF + PadR( PadR(PadR(STR0048,22,".")+": " + cSimbMoeda,26) + Transform(nVlrTotalCompra, "@E 999,999,999.99" ), 40 ) + CHR(13) + CHR(10) //  "VALOR TOTAL DA COMPRA"
cTickForm += CHR(13)                                                                  
If nVlrTotalEstorno > 0
	cTickFormPag += PadR( STR0069 + Space(20) + Transform(nVlrTotalCompra, "@E 999,999,999.99" ),40)+ CHR(13) + CHR(10)  //Total:
	cTickForm += PadR( PadR(PadR(STR0049,22,".")+": " + cSimbMoeda,26) + Transform(nVlrTotalEstorno, "@E 999,999,999.99" ), 40 ) + CHR(13) + CHR(10) // "VALOR TOTAL DO ESTORNO..:"
	cTickForm += CHR(13) + CHR(10)			
	
	cTickForm += PadC(STR0050 , 40, "-" ) + CHR(13) + CHR(10)    //  "---------------VALORES ESTORNADOS---------------"
	cTickForm += CHR(13)      					
					
	cTickForm +=  cTickFormPag                

EndIf

IF nVlrTotalCompra <> nVlrTotalEstorno 
	cTickForm += CHR(13) + CHR(10)
	cTickForm += PadC( STR0051 , 40, "-" ) + CHR(13) + CHR(10)    // "---------------VALORES DEVOLVIDOS---------------"
	cTickForm += CHR(13)      

	If cTipoDevol == cSimbMoeda
		SX5->(DbSeek(xFilial("SX5")+'24'+PadR(cTipoDevol, nTamChave)))	
		cFormaDescr := PadR(Left(SX5->X5_DESCRI,26),26) 
	Else 
		cFormaDescr := PadR(STR0052,26)    //Nota de Credito
	EndIf
	cTickForm += PadR(cFormaDescr + Transform(nVlrTotalCompra-nVlrTotalEstorno, "@E 999,999,999.99" ), 40 ) + CHR(13) + CHR(10)
Endif

If lGuil .And. lEmitNFCe .and. !lLJ7101
	cTickForm += TAG_PULANL_INI+"5"+TAG_PULANL_FIM+TAG_GUIL_INI+TAG_GUIL_FIM
EndIf

While lImprime
	lImprime	:= .F.
	nRet 		:= -1
	nRet 		:= IFRelGer( nHdlECF, cTickForm, 1 )
	lImprime 	:= LjTEFAskImp(1, nRet)
End

RestArea(aArea)

Return Nil
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  |GrvDadosPgto  บAutor  ณ Vendas Cliente     บ Data ณ  28/12/10   บฑฑ
ฑฑฬออออออออออุออออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณGrava os Dados do Pagamentos da Venda Estornada para ser        บฑฑ
ฑฑบ          ณutilizada no Job de integracao da retaguarda                    บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametro ณ                                                                บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGAFRT                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method GrvDadosPgto() Class LjClEstVen
Local aDados := {}     //Dados do Pagamento
Local nC := 0          //contador
Local lRet := .F.      //Retorno
Local aHeadMBZ	:= MBZ->(dbStruct())
Local cMBZTipo  := aHeadMBZ [aScan( aHeadMBZ, { |x|  x[1] == "MBZ_REG"})][2]

For nC := 1 To Len(Self:aOrc_Pagtos)
	aDados := { 	  {"MBZ_FILIAL"	, xFilial("MBZ")								},;  
					  {"MBZ_NUM"	, Self:cOrcamento								},;	 
					  {"MBZ_CUPOM"	, Self:cOrc_Cupom								},;
					  {"MBZ_SERIE"	, Self:cSerie									},;	 	 					  					  
					  {"MBZ_OPERA"	, Self:cNumCaixa								},;
					  {"MBZ_SITUA"	, "00"											},;
					  {"MBZ_PARCEL"	, Self:aOrc_Pagtos[nC, __E1_PARCELA]			},;
					  {"MBZ_ESTORN"	, IIF(Self:aOrc_Pagtos[nC, __L4lEstorn], "S","")},; 					  
					  {"MBZ_FORMA"	, Self:aOrc_Pagtos[nC, __L4_FORMA]				},;
					  {"MBZ_VALOR"	, Self:aOrc_Pagtos[nC, __L4_VALOR]				},;
					  {"MBZ_PORTE"	, Self:aOrc_Pagtos[nC, __PORTE]					},;
					  {"MBZ_CHEQID"	, Self:aOrc_Pagtos[nC, __L4_CHEQID]				},;					  
					  {"MBZ_NUMCAR"	, Self:aOrc_Pagtos[nC, __L4_NUMCART]			},;
					  {"MBZ_ADMIN"	, Self:aOrc_Pagtos[nC, __L4_ADMINIS]			},;
					  {"MBZ_AGENCI"	, Self:aOrc_Pagtos[nC, __L4_AGENCIA]			},;
					  {"MBZ_CONTA"	, Self:aOrc_Pagtos[nC, __L4_CONTA]				},;
					  {"MBZ_COMP"	, Self:aOrc_Pagtos[nC, __L4_COMP]				},;
					  {"MBZ_MOEDA"	, Self:aOrc_Pagtos[nC, __L4_MOEDA]				},;
					  {"MBZ_DOCTEF"	, Self:aOrc_Pagtos[nC, __L4_DOCTEF]				},;
					  {"MBZ_FORMID"	, Self:aOrc_Pagtos[nC, __L4_FORMAID]			},;
					  {"MBZ_NSUTEF" , Self:aOrc_Pagtos[nC, __L4_NSUTEF]				},;
					  {"MBZ_DOCCAN"	, Self:aOrc_Pagtos[nC, __L4_DOCCANC]			},;
					  {"MBZ_HORCAN"	, Self:aOrc_Pagtos[nC, __L4_HORCANC]			},;
					  {"MBZ_DTCAN"	, Self:aOrc_Pagtos[nC, __L4_DATCANC]			};				  
	                } 
	                
	If !Self:lOffLine          
		//Se foi pela retaguarda entใo alimenta o registro
		If  cMBZTipo == "C" // se a Base PDV for Caracter
			aAdd(aDados,  {"MBZ_REG"	, AllTrim(Str(Self:aOrc_Pagtos[nC, __L4_RECNO]))} ) 
		Else                // 
			aAdd(aDados,  {"MBZ_REG"	, Self:aOrc_Pagtos[nC, __L4_RECNO]} ) 
	  	EndIf  
	EndIf  
	
	If ( MBZ->( FieldPos( "MBZ_CLIENT" ) ) > 0 ) .AND. ( MBZ->( FieldPos( "MBZ_LOJA" ) ) > 0 )  
		aAdd(aDados,  {"MBZ_CLIENT"	, Self:cOrc_Cli	 } )
		aAdd(aDados,  {"MBZ_LOJA"	, Self:cOrc_Loja } )
	EndIf 

    Lj7GeraSL( "MBZ", aDados, .t.)

Next

lRet := .T.

Return  lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออออออออหอออออออัอออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบMetodo    |RealizaRpcEstorno  บAutor  ณCaio Murakami        บ Data ณ  25/11/2010 บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออสอออออออฯอออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณMetodo que realiza o estorno                                          บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametro ณ ExpC1 = Numero do orcamento                                    		บฑฑ
ฑฑบ          ณ ExpL2 = Retorno logico da funcao Lj600Estor (Referencia)      		บฑฑ
ฑฑบ          ณ ExpL3 = Indica se contingencia serแ ativada                    		บฑฑ
ฑฑบ          ณ ExpC4 = Mensagem de erro apos chamada da Lj600Estor (Referencia) 	บฑฑ
ฑฑบ          ณ                                                                		บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑบUso       ณLOJA600                                                     	        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method RealizaRpcEstorno(  cDoc , cSerie, lContinua, lContingency , cMsgEstorno , cNewCli , cNewLoja ) Class LjClEstVen    
Local lRet 			:= .T. //-- lRet valida se a comunicacao foi bem sucessida 
 
Default cDoc 		:= "" 
Default cSerie 		:= "" 
Default lContinua   := .T. //-- lContinua ้ passado por referencia para assimilar o conteudo do retorno da funcao
Default lContingency:= .T. //-- Ativa contigencia na STRBRemoteExecute
Default cMsgEstorno := ""  //-- Mensagem de estorno
Default cNewCli  	:= Space(TamSX3("A1_COD")[1])  //Cliente para o estorno.
Default cNewLoja 	:= Space(TamSx3("A1_LOJA")[1]) //Loja para o estorno. 

If FindFunction("STBRemoteExecute")
	//-- Executa o estorno da retaguarda remotamente
	lRet := STBRemoteExecute( "Lj600Estor" , {"SL1",Nil, 4 , .T. , cDoc , cSerie , cNewCli , cNewLoja } , NIL, lContingency , @lContinua )	

    //-- Comunica็ใo nao efetuada
	If !lRet 	
		cMsgEstorno := 	STR0057 +CRLF+CRLF; //"Comunica็ใo com retaguarda nใo efetuada".
			
		If lContingency .And. lContinua
	   		cMsgEstorno += "- "+STR0058 +CRLF+; // "Conting๊ncia ativa."
		   	 			   "- "+STR0059 +SL1->L1_NUM+ STR0060 +CRLF+; //-- "Venda de numero ";" terแ seu estorno realizado por contingencia. "
	 		               "- "+STR0061 +CRLF+CRLF //-- "Estorno local prosseguirแ normalmente"
	 		
	 		//-- Com a contigencia ativa or็amento local pode ser realizado. 
	 		lRet := .T. 
	 	
	 	EndIf 
	EndIf 
 	
 	//-- Rotina nใo validada
 	If !lContinua
 		
 		cMsgEstorno += STR0062+CRLF+CRLF //-- "Venda nใo estornada na retaguarda."
 		
 		cMsgEstorno += "- "+STR0059 +SL1->L1_NUM+STR0063+CRLF+;//--"Venda de numero ";" nao sera estornado."
 					   "- "+STR0064 +CRLF+CRLF //--"Verifique retaguarda"
 		
 	EndIf
 	 
 	If lRet .And. lContinua 
 		//-- Marca registro como estornado
 		Lj602GrStE(SL1->L1_NUM , "1" )  
 	EndIf

Else
	lRet := .F. 
	cMsgEstorno := STR0065 //-- "Funcao STBRemoteExecute nใo encontrada." 
EndIf

Return lRet

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} PagtoDigitalCancela
Realiza o cancelamento da transacao de Pagamento Digital

@type       Method
@author     Alberto Deviciente
@since      12/11/2020
@version    12.1.27

@param lProssegue, L๓gico, Controla se prossegue o processo de estorno.

@return Nil, Nulo, Retorno nulo.
/*/
//-------------------------------------------------------------------------------------
Method PagtoDigitalCancela(lProssegue) Class LjClEstVen
Local nC   			:= 0    //Contador
Local nPos 			:= 0    //Posicao do Array
Local aPagDig       := {}   //Informa็๕es dos Pagamentos Digitais
Local aCancPgDig    := {}   //Transa็๕es de Pagamento Digital da venda a serem canceladas
Local cChaveAnt     := ""

Default lProssegue  := .T.

If ExistFunc("LjPDGtPGrv") .And. ExistFunc("LjPDCanTrn")
    //Busca informa็๕es de Pagamentos Digitais gravados na venda.
    aPagDig	:= LjPDGtPGrv(Self:cOrcamento, .T.)

    aSort( Self:aOrc_Pagtos,,, {|x,y| x[__L4_FORMA]+x[__L4_FORMAID] < y[__L4_FORMA]+y[__L4_FORMAID] } )

    For nC := 1 To Len(Self:aOrc_Pagtos)
        If !Empty(Self:aOrc_Pagtos[nC, __L4_DOCTEF]) .And. Self:aOrc_Pagtos[nC, __TP_TRANS] $ _FORMATPD // JMM Alterado "PD/PX" 
        
            If Self:PagtoPodeCompensar(Self:aOrc_Pagtos[nC], Self:aSE1) //Verifica se o tํtulo esta em aberto
                If cChaveAnt <> Self:aOrc_Pagtos[nC, __L4_FORMA]+Self:aOrc_Pagtos[nC, __L4_FORMAID]
                    cChaveAnt := Self:aOrc_Pagtos[nC, __L4_FORMA]+Self:aOrc_Pagtos[nC, __L4_FORMAID]
                    nPos := aScan( aPagDig, { |x| AllTrim(x[1])+AllTrim(x[8]) == Alltrim(Self:aOrc_Pagtos[nC, __L4_DOCTEF])+Alltrim(Self:aOrc_Pagtos[nC, __L4_FORMAID]) } )
                    If nPos > 0
                        aAdd( aCancPgDig, aPagDig[nPos] )
                    EndIf
                EndIf
            Else
                Aviso( STR0020, STR0072 + CRLF +; //Aten็ใo ## "A Transa็ใo de Pagamento Digital nใo pode ser estornada, pois o tํtulo jแ possui baixas ou nใo estแ no porte do caixa."
                            STR0027 + Alltrim(Self:cOrc_Cupom) + STR0028+Alltrim(Self:cSerie) + ; //Documento: XXXXXX  S้rie
                            STR0029 + AllTrim(Self:aOrc_Pagtos[nPos,__L4_FORMA])    +;  //Tipo:
                            STR0036 + AllTrim(Self:aOrc_Pagtos[nPos,__E1_PARCELA ]) +;  //"Parcela:"
                            STR0030 + AllTrim(Self:aOrc_Pagtos[nPos,__L4_ADMINIS])  +;  //"Administradora:"
                            STR0037 + Alltrim(oTef:aRetCartao[oTef:nTrans]:cDocCanRei),;//"NSU Origem:"
                            {STR0031})   //"&Ok"
                
                lProssegue := .F.
                Exit
            EndIf
        EndIf
    Next nC

    If lProssegue
        If Len(aCancPgDig) > 0
            lProssegue := LjPDCanTrn(@aCancPgDig)

            If lProssegue

                For nC := 1 To Len(aCancPgDig)

                    If !Empty(aCancPgDig[nC][09])
                        //Atualiza todas as parcelas da mesma transa็ใo
                        While ( nPos := aScan( Self:aOrc_Pagtos, { |x| Alltrim(x[__L4_DOCTEF])+Alltrim(x[__L4_FORMAID]) == AllTrim(aCancPgDig[nC][1])+AllTrim(aCancPgDig[nC][8]) .And. Empty(x[__L4_DOCCANC]) } ) ) > 0
                            Self:aOrc_Pagtos[nPos, __L4_DOCCANC] := aCancPgDig[nC][09]
                            Self:aOrc_Pagtos[nPos, __L4_DATCANC] := aCancPgDig[nC][10]
                            Self:aOrc_Pagtos[nPos, __L4_HORCANC] := aCancPgDig[nC][11]
                            Self:aOrc_Pagtos[nPos, __L4lEstorn ] := .T.
                        End
                    EndIf

                Next nC
            Else
				Aviso( STR0020, STR0073 , {STR0031},, STR0027 + Alltrim(Self:cOrc_Cupom) + STR0028+Alltrim(Self:cSerie) ) //"Aten็ใo"###"&Ok" "Documento:""  Serie:"  ## "Nใo foi possํvel estornar as transa็๕es de Pagamento Digital desta venda"
				lProssegue := .F.
            EndIf
        EndIf
    EndIf
EndIf

Return