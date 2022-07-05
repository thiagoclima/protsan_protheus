
/*
Programa.: LJ7066
Autor....: Heverson Gomes - totvs tsm 
Data.....: 17/01/2022   
Descricao: Ponto de entrega utilizado para deixar o preco de tabela = preco de venda para 
nao demonstrar na nota valor com desconto  

Uso......: PROTSAN  

*/

User Function LJ7066() 
Local _nPComis := 0 
Local _aArea   :={}

_aArea := GetArea()

//If Inclui .Or. Altera

DbSelectArea("SC6")
DbSetOrder(1)

If DbSeek(xFilial("SC6")+SC5->C5_NUM)    // Filial + Numero do Pedido
		
        While ( !Eof() .AND. xFilial("SC5")+SC5->C5_NUM  == SC6->C6_FILIAL + SC6->C6_NUM )
						
            DbSelectArea("SL2") 
            DbOrderNickName("SC6PED")  //indice 9 = L2_PEDRES + L2_ITESC6 
            if dbseek(xFilial("SL2")+SC6->C6_NUM + SC6->C6_ITEM) 
                _nPComis := SL2->L2_COMIS1 
            Endif      
                    	
            DbSelectArea("SC6")
            DbSetOrder(1)
            RecLock("SC6",.F.)
            // Preco de tabela igual ao preço de venda após desconto 
			SC6->C6_PRUNIT := SC6->C6_PRCVEN  
            SC6->C6_DESCONT := 0 
            SC6->C6_VALDESC := 0 
            SC6->C6_COMIS1 := _nPComis 
            _nPcomis := 0 
    		MsUnlock()
            dbskip()
        Enddo 

Endif 

RestArea(_aArea)
Return Nil



//LjAutoNFe( SL1->L1_DOC, SL1->L1_SERIE, SL1->L1_CLIENTE, SL1->L1_LOJA )
//chama funcao para gerar nf 


