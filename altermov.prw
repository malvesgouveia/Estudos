#INCLUDE "RWMAKE.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"

#DEFINE ENTER CHR(10) + CHR(13)

/*/{Protheus.doc} User Function ALTERMOV
	(long_description)
	@type  Function
	@author user Jean Falcao
	@since 12/03/2021
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
	/*/

User Function ALTERMOV()


Local CBANCO        := Space(TamSx3("A6_COD")[1])
Local cFilial       := Space(TamSx3("A6_FILIAL")[1])
Local dAbertu        := CTOD("  /  /  ")

Local aPergs		:= {}
Local aRet			:= {}

Private cUser			:= RetCodUsr() 


Private cAPREABSA6 	:= U_SuperGetMv("AP_REABSA6", .T., "000000", "C", "Usuários que podem reabrir caixa em data retroativa.")

	IF cUser $ cAPREABSA6

		// Parambox
		Aadd(aPergs, {1, "Filial", cFilial	, "", "", "", ".T.", 20, .T.})
        Aadd(aPergs, {1, "Caixa" , cBanco	, "", "", "", ".T.", 20, .T.})
        Aadd(aPergs, {1, "Fechamento", dAbertu	, "", "", "", ".T.", 60, .T.})
	Else
		MsgInfo("Usuário sem permissão para reabrir caixa em data retroativa, Contate o administrador do sistema","Sem permissão")
		Return
	EndIf
	IF ParamBox(aPergs, "Informe os dados para reabertura do caixa.", aRet,,,,,,,, .T., .T.)
			
		cFilial	:= MV_PAR01
        CBANCO  := MV_PAR02
        dAbertu := MV_PAR03

		// Inicia o processamento
		oProcess := MsNewProcess():New({|lEnd| U_ALTERMVA(MV_PAR01,CBANCO,dAbertu,)}, "Selecionando registros", "Aguarde...", .F.)
		oProcess:Activate()
	EndIF
    Return
/*/{Protheus.doc} User Function ALTERMVA
	(long_description)
	@type  Function
	@author user Jean Falcao
	@since 12/03/2021
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
	/*/

Static Function ALTERMVA(MV_PAR01,CBANCO,dAbertu)

	Local nQtd          := 0
	Local MV_PAR01 
	Local CBANCO
	Local dAbertu
	Local cAliasQry     := GetNextAlias()
	Local cFech			:= CTOD("  /  /  ")

	cQuery := " SELECT A6_FILIAL AS FILIAL,A6_COD AS COD,A6_DATAABR AS DTABR,A6_HORAABR AS HRAABR,A6_DATAFCH AS DTFCH,A6_HORAFCH AS HRAABR,A6_NOME AS NOME" + ENTER
	cQuery += " FROM " + RETSQLNAME("SA6") + " WHERE "+ ENTER
	cQuery += " A6_FILIAL = '" + SUBSTRING(MV_PAR01,1,2) + "'"+ ENTER
	cQuery += "AND A6_COD = '" + CBANCO + "' "+ ENTER


    DbUseArea(.T., "TOPCONN", TCGenQry( ,, cQuery), cAliasQry, .F., .T. )
	Count To nQtd




	IF nQtd = 0
		MsgInfo("Não foi encontrado nenhum registro relacionado a este codigo.")
		Return
	Endif

	IF nQtd > 1
		MsgAlert("O codigo de banco esta duplicado, contate o Administrador do sistema.")
		Return
	Endif

	(cAliasQry)->(DbGoTop())

	dbSelectArea ("SA6")
	DbSetOrder(1)



	If SA6->(dbSeek((cAliasQry)->FILIAL+(cAliasQry)->COD))

		RecLock("SA6",.F.)
		SA6->A6_DATAFCH := cFech
		SA6->A6_HORAFCH := ''
		SA6->A6_DATAABR := dAbertu
		SA6->A6_HORAABR := Substring(Time(),1,5)
		SA6->(msUnLock())

	EndIf

	MsgInfo("O caixa foi reaberto na data:"+Dtos(dAbertu))

	IF MSGYESNO("Deseja cancelar a sangria desta mesma data ? ","Cancelar Sangria")
		U_CANCSANGR(dAbertu,MV_PAR01,CBANCO)
	EndIF
RETURN
/*/{Protheus.doc} User Function CANCSANGR
	(long_description)
	@type  Function
	@author user Jean Falcao
	@since 12/03/2021
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
	/*/

Static Function CANCSANGR(dAbertu,MV_PAR01,CBANCO)
	Local CBANCO
	Local dAbertu
	Local MV_PAR01
	Local cAliasQryE5     := GetNextAlias()
	Local MVCXLOJA		:= SuperGetMv("MV_CXLOJA", .T., "", MV_PAR01)
	Local cAPEXCSAN		:= U_SuperGetMv("AP_EXCSAN", .T., "000000","C", "Usuários que podem excluir a sangria.")

	IF cUser $ cAPEXCSAN
	
		cQuery := "SELECT R_E_C_N_O_  AS RECNO,E5_BANCO " + ENTER
		cQuery += "FROM " + RetSqlName("SE5") + " " + ENTER
		cQuery += "WHERE E5_BANCO IN ('"+SUBSTRING(+MVCXLOJA,1,3)+"','"+cBanco+"') AND" + ENTER
		cQuery += "E5_NATUREZ = 'SANGRIA' AND E5_TIPODOC = 'TR' AND" + ENTER
		cQuery += "E5_MSFIL = '" + MV_PAR01 + "' AND D_E_L_E_T_ = '' AND " + ENTER
		cQuery += "E5_DATA = '" + dtos(dAbertu) + "' AND "  + ENTER
		cQuery += "E5_HISTOR LIKE '%"+CBANCO+"%'" +ENTER

		DbUseArea(.T., "TOPCONN", TCGenQry( ,, cQuery), cAliasQryE5, .F., .T. )
		Count To nQtd
		(cAliasQryE5)->(DbGoTop())

		IF nQtd = 0
			Msginfo("Não foi encontrado nenhum registro que satisfaça a necessidade")
		Endif

		dbSelectArea ("SE5")		

		WHILE (cAliasQryE5)->(!EOF()) 
	
			SE5->(DbGoTo((cAliasQryE5)->RECNO))
			
				IF SE5->(!EOF())
					RecLock("SE5",.F.)
						SE5->(dbDelete())
					SE5->(MsUnLock())				
				EndIf
			(cAliasQryE5)->(DbSkip())
		ENDDO
		
	EndIf
	
RETURN
