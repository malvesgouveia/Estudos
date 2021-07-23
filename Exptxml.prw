#INCLUDE "RWMAKE.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"

#DEFINE ENTER CHR(10) + CHR(13)

/*/{Protheus.doc} User Function Exptxml
	(long_description)
	@type  Function
	@author user Jean Falcao.
	@since 12/03/2021
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
	/*/

User Function Exptxml()

    Local aPergs		:= {}
    Local aRet			:= {}
    Local cDdata        := CTOD("  /  /  ")
    Local cTdata        := CTOD("  /  /  ")

	// Parambox
		Aadd(aPergs, {1, "De data", cDdata	, "", "", "", ".T.", 40, .T.})
        Aadd(aPergs, {1, "Caixa" , cTdata	, "", "", "", ".T.", 40, .T.})
	
	IF ParamBox(aPergs, "Informe os dados para reabertura do caixa.", aRet,,,,,,,, .T., .T.)
			
		cDdata	:= MV_PAR01
        cTdata  := MV_PAR02

		// Inicia o processamento
		oProcess := MsNewProcess():New({|lEnd| U_Exptxml1(cDdata,cTdata)}, "Selecionando registros", "Aguarde...", .F.)
		oProcess:Activate()
    Endif
    Return

/*/{Protheus.doc} User Function Exptxml1
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

Static Function U_Exptxml1(cDdata,cTdata)

    Local cDdata
    Local cTdata
	Local cAliasQry     := GetNextAlias()
    Local nID           := 000001
    Local nQuantidade   := 0

    cQuery := "SELECT TB1.ID_ENT AS ENTIDADE,NFE_ID,CNPJ,ISNULL(CAST(CAST(XML_ERP AS VARBINARY(8000)) AS VARCHAR(8000)),''),DATE_NFE,STATUS,STATUSCANC FROM SPED050 AS TB1" + ENTER
    cQuery += "INNER JOIN SPED001 AS TB2 ON TB1.ID_ENT = TB2.ID_ENT" + ENTER
    cQuery += "WHERE DATE_NFE BETWEEN '" +Dtos(cDdata)+ "' AND '" +Dtos(cTdata)+ "' " + ENTER
    cQuery += "AND MODELO = '65' AND TB1.D_E_L_E_T_ = '' AND TB2.D_E_L_E_T_ = '' " + ENTER
    cQuery += "ORDER BY TB1.ID_ENT,DATE_NFE" + ENTER

    DbUseArea(.T., "TOPCONN", TCGenQry( ,, cQuery), cAliasQry, .F., .T. )
	Count To nQtd

    (cAliasQry)->(DbGoTop())

    If nQtd < 0
        Msgalert("Não foram encontrado registos que satisfaça a solicitação !!")
    ELSE

        WHILE (cAliasQry)->(!EOF())
            cNomePasta := (cAliasQry)->ENTIDADE
            cXml       := CFIELD4

            IF ExistDir("D:\XML")

                IF ExistDir("D:\XML\"+cNomePasta)
                   nHandle := FCreate("D:\XML\"+cNomePasta+"\"+(cAliasQry)->NFE_ID+".xml")
                   FWrite(nHandle, cXml)
                   FClose(nHandle)
                Else
                    MakeDir("D:\XML\"+cNomePasta)
                    nHandle := FCreate("D:\XML\"+cNomePasta+"\"+(cAliasQry)->NFE_ID+".xml")
                   FWrite(nHandle, cXml)
                    FClose(nHandle)
                EndIf

            else

                MakeDir("D:\XML")

                IF ExistDir("D:\XML\"+cNomePasta)
                    nHandle := FCreate("D:\XML\"+cNomePasta+"\"+(cAliasQry)->NFE_ID+".xml")
                    FWrite(nHandle, cXml)
                    FClose(nHandle)
                Else
                    MakeDir("D:\XML\"+cNomePasta)
                    nHandle := FCreate("D:\XML\"+cNomePasta+"\"+(cAliasQry)->NFE_ID+".xml")
                    FWrite(nHandle, cXml)
                    FClose(nHandle)
                EndIf
                
            EndIf
        (cAliasQry)->(DbSkip())
        EndDo
    Endif
Return


/*

            aEmpresa := FWLoadSM0()  
            nQtdEmp  := LEN(aEmpresa)
            nnQuant  := 1

            IF cValToChar(aEmpresa[nQuant][18]) $ cTeste
                Msgalert("Achei a filial")
                Return
            Endif

            nQuant++
*/
