#Include 'Protheus.ch'

//-------------------------------------------------------------------
/*/{Protheus.doc} ZDPCOM04
Ponto de entrada para filtrar orçamento do vendedor 


@author  Heverson Gomes
@since   07/01/2021
@version 1.0
/*/
//-------------------------------------------------------------------
User Function LJ10DE()

Local _aArea := GetArea() 
//Local _ni := 0 

// Descricao dos Itens do Array
//01 - Produto
//02 - Descrição
//03 - Valordesconto
//04 - Teste
//05 - Unidade de Medida
//06 - Quantidade
//07 - Valor Unitário
//08 - Valor do Icm
//09 - Cf
//10 - Desconto em %
//11 - Número da NF
//12 - Dados de Emissão
//13 - Série da nota
//14 - Base de Icm
//15 - Local
//16 - Item
//17 - Valor do Ipi
//18 - Valor do Iss
//19 - Valor total do item
//20 - recno do sl2
//21 - Zero
//22 - Desconto Proporcional
//23 - Pré-venda
//24 - Tabela de preco utilizada

//01AAdd(aVendas,{	L2_PRODUTO		,;
//02		    				L2_DESCPRO		,;
//03		    				L2_VALDESC		,;
//04		    				L2_TES			,;
//05		    				L2_UM			,;
//06				 			L2_QUANT		,;
//07				 			L2_VRUNIT		,;
//08				 			L2_VALICM		,;
//09				 			L2_CF			,;
//10				 			L2_DESC			,;
//11				 			L2_DOC			,;
//12				 			L2_EMISSAO		,;
//13				 			L2_SERIE		,;
//14				 			L2_BASEICM		,;
//15				 			L2_LOCAL		,;
//16				 			L2_ITEM			,;
//17				 			L2_VALIPI		,;
//18				 			L2_VALISS		,;
//19				 			L2_VLRITEM		,;
//20				 			SL2->(Recno())	,;
//21				 			0				,;
//22				 			SL2->L2_DESCPRO	,;
//23				 			SL2->L2_PR CTAB	,;
//24				 			L2_TABELA		,;
//25				 			L2_VALFRE		,;
//26				 			L2_SEGURO		,;
//27				 			L2_DESPESA})		


//MV_DESCSAI = 1



//MSGSTOP("LJ10DE - L2_DOC "   , SL2->L2_FILIAL+" " + SL2->L2_DOC+" "+ SL2->L2_SERIE+" "  + SD2->D2_COD+" " + SD2->D2_ITEM  )

/*
for _ni:= 1 to Len(aVendas)

// zera valores relacionados ao desconto 


aVendas[_ni,03]  := 0.00 // L2_VALDESC   VALOR DO DESCONTO

aVendas[_ni,10]  := 0.00 // L2_DESC   PERCENTUAL DO DESCONTO 

aVendas[_ni,22]  := 0.00  // L2_DESCPRO 

aVendas[_ni,23]  := aVendas[_ni,07] // L2_PRCTAB PRECO DE TABELA 
aVendas[_ni,24]  := SPACE(03)  // L2_TABELA CODIGO DA TABELA DE PRECO 

//MSGSTOP( "L2_VALDESC ", STRZERO(aVendas[_ni,03]))

/*


	_cProduto:=""
	_cDescPro:=""
	_cTes :=""
	_cUm :=""
	_cCf :=""
	_cDoc :=""
	_cSérie :=""
	_cLocal:=""
	_cItem :=""
	_nValDesc:=0
	_nQuant :=0
	_nVrUnit :=0
	_nValIcm :=0
	_nDesc :=0
	_nBaseIcm:=0
	_nValIpi :=0
	_nValIss :=0
	_nVlrItem:=0
	_dEmissão:=dDatabase
	_nDescPro:=0
	_nPrcTab :=0
	_nCm1 :=0
	_nCm2 :=0
	_nCm3 :=0
	_nCm4 :=0
	_nCm5 :=0				
	
	cTabD2 :=""
	dbSelectArea("SG1")
	dbSetOrder(1)
	dbSeek(xFilial()+aVendas[_ni,1])
	SE !Eof()
		dbSelectArea("SB1")
		dbSeek(xFilial()+aVendas[_ni,1])
		_cSeq := ProxNum()
    	dbSelectArea("SB2")
	   dbSetOrder(1)
	   If dbSeek(xFilial()+aVendas[_ni,1])
		   _nCm1:=B2_Cm1
		   _nCm2:=B2_Cm2
		   _nCm3:=B2_Cm3
		   _nCm4:=B2_Cm4
		   _nCm5:=B2_Cm5
		Endif													
		// Gerar RE7 do computador
		dbSelectArea("SD3")
		RecLock("SD3",.t.)
		SD3->D3_FILIAL := xFilial("SD3")
		SD3->D3_COD := aVendas[_ni,1]
		SD3->D3_QUANT := aVendas[_ni,6]
		SD3->D3_CF := "RE7"
		SD3->D3_CHAVE := "E0"
		SD3->D3_LOCAL := aVendas[_ni,15]
		SD3->D3_DOC := aVendas[_ni,11]
		SD3->D3_EMISSAO := dDatabase
		SD3->D3_UM := aVendas[_ni,5]
		SD3->D3_GRUPO := SB1->B1_GRUPO
		SD3->D3_NUMSEQ := _cSeq
		SD3->D3_TM := "999"
		SD3->D3_TIPO := SB1->B1_TIPO
		SD3->D3_CONTA := SB1->B1_CONTA
		SD3->D3_USUARIO := SubStr(cUsuario,7,15)
		SD3->D3_RATEIO:= 100
		SD3->D3_CUSTO1 := _nCm1
		SD3->D3_CUSTO2 := _nCm2
		SD3->D3_CUSTO3 := _nCm3
		SD3->D3_CUSTO4 := _nCm4
		SD3->D3_CUSTO5 := _nCm5								
		B2AtuComD3({_nCm1,_nCm2,_nCm3,_nCm4,_nCm5})	
      // Certa Quantidade de Pedido de Vendas	
    	dbSelectArea("SB2")
	   dbSetOrder(1)
	   If dbSeek(xFilial()+aVendas[_ni,1])
    	   Reclock("SB2")	   
		   Substitua B2_QPedVen por (B2_QPedVen) - (aVendas[_ni,6])
   	   MsDesbloquear ( )
   	Endif	
		dbSelectArea("SG1")
		_aStru := {}
		_nTotal:= 0
		Enquanto !Eof() .and. SG1->G1_COD == aVendas[_ni,1]
			dbSelectArea("SB1")
			dbSeek(xFilial()+SG1->G1_COMP)
			AADD(_aStru,{SG1->G1_COMP,SG1->G1_QUANT,SB1->B1_UPRC})
			_nTotal:= _nTotal + (SB1->B1_UPRC * SG1->G1_QUANT)
			dbSelectArea("SG1")
			dbSkip()
		Fim
		
		_nSobra := 100		
		Para _nJ := 1 para Len(_aStru)
			// Definicoes que nao precisam de Arquivo
			_cDoc :=aVendas[_ni,11]
			_dEmissão:=aVendas[_ni,12]
			_cSerie :=aVendas[_ni,13]
			_cItem :=StrZero(Len(_aRetorno)+1,2)
			_nDesc :=aVendas[_ni,10]
			_nValIcm :=0
			
			_cProduto:=_aStru[_nj,1]
			
			// Posicionando SB1
			dbSelectArea("SB1")
			dbSeek(xFilial()+_aStru[_nj,1])

			// Posicionando SB0
			dbSelectArea("SB0")
			dbSetOrder(1)
			dbSeek(xFilial()+_cProduto)			
									

			_cDescPro:=0
			_nQuant :=aVendas[_ni,6]*_aStru[_nj,2]
			_cTes :=SB1->B1_Ts
			_cUm :=SB1->B1_Um
			_cLocal :=SB1->B1_LocPad
			cTabD2 :=aVendas[_ni,24]
			Se cTabd2 == "1"
			   _nPrcTab :=SB0->B0_Prv1
			ElseIf cTabD2 == "2"	
			   _nPrcTab :=SB0->B0_Prv2
			ElseIf cTabD2 == "3"	
			   _nPrcTab :=SB0->B0_Prv3
			ElseIf cTabD2 == "4"	
			   _nPrcTab :=SB0->B0_Prv4
			ElseIf cTabD2 == "5"	
			   _nPrcTab :=SB0->B0_Prv5
			ElseIf cTabD2 == "6"	
			   _nPrcTab :=SB0->B0_Prv6
			ElseIf cTabD2 == "7"																
			   _nPrcTab :=SB0->B0_Prv7
			ElseIf cTabD2 == "8"	
			   _nPrcTab :=SB0->B0_Prv8
			ElseIf cTabD2 == "9"	
			   _nPrcTab :=SB0->B0_Prv9				
			Endif			
			_nVrUnit :=_nPrcTab
		   _nVlrItem:=_nVrUnit*_nQuant
			_nValDesc:=_nVlrItem*(_nDesc/100)
			_nDescPro:=aVendas[_ni,22]

									
   
			//Posicionando SF4
			dbSelectArea("SF4")
			dbSetOrder(1)
			dbSeek(xFilial()+_cTes)
			_cCf:=SF4->F4_CF

			Se SF4->F4_IPI == "S"
			   _nValIpi :=_nVlrItem * (SB1->B1_IPI /100)
		   else
			  _nValIpi :=0		
			Endif
			
			SE SF4->F4_ISS == "S"
				_nValIss :=_nVlrItem * (SB1->B1_ALIQISS / 100)			
			else
			   _nValIss :=0
			Endif	

         Se SF4->F4_BASEICM> 0
            _nBaseIcm:= _nVlrItem * (SF4->F4_BaseICM/100)
			else
			   _nBaseIcm:=_nVlrItem	
		   Endif
					
			SE SF4->F4_ICM == "S"
				SE Vazio(SA1->A1_INSCR)
					_nPerRet := iif(SB1->B1_PICM>0,SB1->B1_PICM,GetMV("mv_icmpad"))
				Elseif SB1->B1_PICM > 0 .And. SA1->A1_EST == _cEstado
					_nPerRet := SB1->B1_PICM
				Elseif SA1->A1_EST == _cEstado
					_nPerRet := GetMV("mv_icmpad")
				Elseif SA1->A1_EST $ _tNorte .And. At(_cEstado,_tNorte) == 0
					_nPerRet := 7
				else
					_nPerRet := 12
				Endif
			Endif

         Se _nPerRet > 0
	         _nValIcm := NoRound(_nBaseIcm * _nPerRet / 100 , 2)
		   else
				_nValIcm :=0
		   Endif
										
			AADD(_aRetorno,{_cProduto,0,_nValDesc,_cTes,_cUm,_nQuant,_nVrUnit,_nValIcm,;
			_cCf,_nDesc,_cDoc,_dEmissao,_cSerie,_nBaseicm,_cLocal,_cItem,_nValIpi,_nValIss,_nVlrItem,aVendas[_ni,20],0,_nDescPro,_nPrcTab})		
		
    	  dbSelectArea("SB2")
	     dbSetOrder(1)
	     If dbSeek(xFilial()+_aStru[_nj,1])
		     _nCm1:=B2_Cm1
		     _nCm2:=B2_Cm2
		     _nCm3:=B2_Cm3
		     _nCm4:=B2_Cm4
		     _nCm5:=B2_Cm5
		  else
		     _nCm1 :=0
	        _nCm2 :=0
	        _nCm3 :=0
	        _nCm4 :=0
	        _nCm5 :=0						  
		  Endif													

			// Gerar DE7 das pecas
			RecLock("SD3",.t.)
			SD3->D3_FILIAL := xFilial("SD3")
			SD3->D3_COD := _aStru[_nj,1]
			SD3->D3_QUANT := _aStru[_nj,2] * aVendas[_ni,6]
			SD3->D3_CF := "DE7"
			SD3->D3_CHAVE := "E9"
			SD3->D3_LOCAL := aVendas[_ni,15]
			SD3->D3_DOC := aVendas[_ni,11]
			SD3->D3_EMISSAO := dDatabase
			SD3->D3_UM := SB1->B1_UM
			SD3->D3_GRUPO := SB1->B1_GRUPO
			SD3->D3_NUMSEQ := _cSeq
			SD3->D3_TM := "499"
			SD3->D3_TIPO := SB1->B1_TIPO
			SD3->D3_CONTA := SB1->B1_CONTA
			SD3->D3_USUARIO := SubStr(cUsuario,7,15)
		   SD3->D3_CUSTO1 := _nCm1
		   SD3->D3_CUSTO2 := _nCm2
		   SD3->D3_CUSTO3 := _nCm3
		   SD3->D3_CUSTO4 := _nCm4
		   SD3->D3_CUSTO5 := _nCm5								
			IF _nj == Len(_aStru)
					SD3->D3_RATEIO := _nSobra
			else
					IF _nSobra > 0
						SD3->D3_RATEIO := Round( ( ( _aStru[_nj,2]*_aStru[_nj,3] ) / _nTotal ) * 100 , 2 ) 
						_nSobra := Round(_nSobra - SD3->D3_RATEIO,2)
						IF _nSobra < 0
							SD3->D3_RATEIO := SD3->D3_RATEIO - _nSobra
							_nSobra := 0
						Endif
					Endif
			Endif

    	   dbSelectArea("SB2")
	      dbSetOrder(1)
	      If dbSeek(xFilial()+_aStru[_nj,1])			
    	      Reclock("SB2")	   
		      Substitua B2_QATU por B2_QATU+SD3->D3_QUANT
				Substitua B2_vAtu1 por B2_vAtu1+B2_Cm1
				Substitua B2_vAtu2 por B2_vAtu2+B2_Cm2
				Substitua B2_vAtu3 por B2_vAtu3+B2_Cm3
				Substitua B2_vAtu4 por B2_vAtu4+B2_Cm4
				Substitua B2_vAtu5 por B2_vAtu5+B2_Cm5																
			Endif				
			
						
			//Atualizar Quantidade de Pedido de Venda das Pecas
       	dbSelectArea("SB2")
	      dbSetOrder(1)
	      Se dbSeek(xFilial()+SG1->G1_Comp)
    	      Reclock("SB2")	   
		      Substitua B2_QPedVen por (B2_QPedVen) + (_aRetorno[_ni,6])
   	      MsDesbloquear ( )
   	   Endif	
		Próximo
	else
		AADD(_aRetorno,aClone(aVendas[_ni]))
		_aRetorno[Len(_aRetorno),16] := StrZero(Len(_aRetorno),2,0)
		dbSelectArea("SB1")
		dbSeek(xFilial()+aVendas[_ni,1])		
		Se B1_Suporte > 0 
          // Desconto para o Software no Valor do Item
		   _nSuporte:= B1_Suporte
			_aRetorno[Len(_aRetorno),3] :=_nSuporte
			_aRetorno[Len(_aRetorno),10]:=(_nSuporte/_aRetorno[Len(_aRetorno),19])*100
			dbSeek(xFilial()+"SUPORTE")
			// Posicionando SB0
			dbSelectArea("SB0")
			dbSetOrder(1)
			dbSeek(xFilial()+"SUPORTE")			
					
			_cDescPro:=0
			_nQuant :=1
			_cTes :=SB1->B1_Ts
			_cUm :=SB1->B1_Um
			_cLocal :=SB1->B1_LocPad
			_nVrUnit :=_nSuporte
		   _nVlrItem:=_nSuporte*_nQuant
			_nValDesc:=0
		   _nDescPro:=aVendas[_ni,22]
			cTabD2 :=aVendas[_ni,24]
			Se cTabd2 == "1"
			   _nPrcTab :=SB0->B0_Prv1
			ElseIf cTabD2 == "2"	
			   _nPrcTab :=SB0->B0_Prv2
			ElseIf cTabD2 == "3"	
			   _nPrcTab :=SB0->B0_Prv3
			ElseIf cTabD2 == "4"	
			   _nPrcTab :=SB0->B0_Prv4
			ElseIf cTabD2 == "5"	
			   _nPrcTab :=SB0->B0_Prv5
			ElseIf cTabD2 == "6"	
			   _nPrcTab :=SB0->B0_Prv6
			ElseIf cTabD2 == "7"																
			   _nPrcTab :=SB0->B0_Prv7
			ElseIf cTabD2 == "8"	
			   _nPrcTab :=SB0->B0_Prv8
			ElseIf cTabD2 == "9"	
			   _nPrcTab :=SB0->B0_Prv9				
			Endif

			//Posicionando SF4
			dbSelectArea("SF4")
			dbSetOrder(1)
			dbSeek(xFilial()+_cTes)
			_cCf:=SF4->F4_CF

			if SF4->F4_IPI == "S"
			   _nValIpi :=_nVlrItem * (SB1->B1_IPI /100)
		   else
			  _nValIpi :=0		
			Endif
			
			if SF4->F4_ISS == "S"
				_nValIss :=_nVlrItem * (SB1->B1_ALIQISS / 100)			
			else
			   _nValIss :=0
			Endif	

         If SF4->F4_BASEICM> 0
            _nBaseIcm:= _nVlrItem * (SF4->F4_BaseICM/100)
			else
			   _nBaseIcm:=_nVlrItem	
		   Endif
					
			if SF4->F4_ICM == "S"
				SE Vazio(SA1->A1_INSCR)
					_nPerRet := iif(SB1->B1_PICM>0,SB1->B1_PICM,GetMV("mv_icmpad"))
				Elseif SB1->B1_PICM > 0 .And. SA1->A1_EST == _cEstado
					_nPerRet := SB1->B1_PICM
				Elseif SA1->A1_EST == _cEstado
					_nPerRet := GetMV("mv_icmpad")
				Elseif SA1->A1_EST $ _tNorte .And. At(_cEstado,_tNorte) == 0
					_nPerRet := 7
				else
					_nPerRet := 12
				Endif
			Endif

         If _nPerRet > 0
	         _nValIcm := NoRound(_nBaIfIcm * _nPerRet / 100 , 2)
		   elIf
				_nValIcm :=0
		   Endif
										
			_cDoc :=aVendas[_ni,11]
			_cSerie :=aVendas[_ni,13]
			_cItem :=StrZero(Len(_aRetorno)+1,2)
			AADD(_aRetorno,{"SUPORTE",0,_nValDesc,_cTes,_cUm,1,_nVrUnit,_nValIcm,;
			_cCf,_nDesc,_cDoc,_dEmissao,_cSerie,_nBaseicm,_cLocal,_cItem,_nValIpi,_nValIss,_nVlrItem,1,0,_nDescPro,_nPrcTab})		
		Endif
	Endif	

*/    

//next _ni 

RestArea(_aArea)

Return(.t.) 

