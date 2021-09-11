#include "protheus.ch"
#include "parmtype.ch"

/*/{Protheus.doc} findname
// Retorna a Descrição da Razão Social do Cliente ou Fornecedor conforme o Tipo de Nota
@author Jean Carlos
@since 20-07-20-21
@version 1.0
@return ${return}, ${return_description}
@param nInAlias, numeric, descricao
@type function
/*/
User function findname(nInAlias,cOpcOut)
  
	Local	cNomRet	 := ""
	Default	nInAlias := 2 // SF2
	Default	cOpcOut	 := "_NOME"
	
	// SF1
	If nInAlias == 1
		If SF1->F1_TIPO $ "D#B"
			DbSelectArea("SA1")
			DbSetOrder(1)
			DbSeek(xFilial("SA1")+SF1->F1_FORNECE+SF1->F1_LOJA)
			cNomRet := &("SA1->A1"+cOpcOut) //NOME
		Else
		   DbSelectArea("SA2")
		   DbSetOrder(1)
		   DbSeek(xFilial("SA2")+SF1->F1_FORNECE+SF1->F1_LOJA)
		   cNomRet := &("SA2->A2"+cOpcOut) //"_NOME
		Endif
	endif
Return cNomRet
