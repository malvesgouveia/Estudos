#INCLUDE "RDMAKE.CH"

/*/{Protheus.doc} User Function atuspd050
	(long_description) FUNÇÃO CRIADA PARA ALTERAR STATUS DA SPED050
	@type  Function
	@author user Jean Falcao
	@since 26/07/2021
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
/*/

User Function atuspd050()

    Local cChave
    Local aTeste:= {"1 = Autorizado","2 = Não autorizado"}
    Local nCombo:= 0

    Aadd(aPergs, {2, "Status", nCombo	, aTeste, "", "", ".T.", 40, .T.})
