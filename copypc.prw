#INCLUDE "RDMAKE"

/*/{Protheus.doc} User Function COPYPC
	(long_description) FUNÇÃO CRIADA PARA COPIAR PEDIDO DE COMPRA PARA OUTRAS FILIAIS
	@type  Function
	@author user Jean Falcao
	@since 22/07/2021
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
/*/

User Function copypc()

    Local aPergs{}
    Local lRet

    // Parambox
    Aadd(aPergs, {1, "Filial", cFilial	, "", "", "", ".T.", 20, .T.})
    Aadd(aPergs, {1, "Caixa" , cBanco	, "", "", "", ".T.", 20, .T.})
    Aadd(aPergs, {1, "Fechamento", dAbertu	, "", "", "", ".T.", 60, .T.})

    IF ParamBox(aPergs, "Informe os dados para reabertura do caixa.", aRet,,,,,,,, .T., .T.)
			
		cFilial	:= MV_PAR01
        CBANCO  := MV_PAR02
        dAbertu := MV_PAR03

		// Inicia o processamento
		oProcess := MsNewProcess():New({|lEnd| U_ALTERMVA(MV_PAR01,CBANCO,dAbertu,)}, "Selecionando registros", "Aguarde...", .F.)
		oProcess:Activate()
	EndIF
