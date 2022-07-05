#Include "Protheus.Ch"

/*/{Protheus.doc} VlrCalc 
(long_description) Programa para calcular o valor dos titulos com abatimentos.
@type  Static Function
@author user Eduardo Silva
@since date 11.11.2019
@version version
@param param, param_type, param_descr
@return return, return_type, return_description
@example
(examples)
@see (links_or_references)
/*/

User Function VLRCALC()

    Local nValor	:= 0
    Local nSaldo	:= SE1->E1_SALDO
    Local nDecres	:= SE1->E1_DECRESC

    nValrAbat	:= SomaAbat(SE1->E1_PREFIXO,SE1->E1_NUM,SE1->E1_PARCELA,"R",SE1->E1_MOEDA,dDataBase,SE1->E1_CLIENTE,SE1->E1_LOJA)
    nValor		:= (nSaldo - (nValrAbat + nDecres)) * 100
    nValor      := Strzero(nValor,13)

Return nValor