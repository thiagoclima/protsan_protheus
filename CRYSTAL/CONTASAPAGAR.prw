  #include 'PROTHEUS.CH'
  // #include 'TBICONN.CH'



		User Function CONTAPAGAR()
 
        Local cRpt                := "CONTAPAGAR"
        Local cParams             := ""
        Local cOptions            := "1;0;1;PRODUCAO"
        Local lWaitRun            := .T.
        //Local lShowGauge          := .T.
        //Local lRunOnServer        := .T.
        Local lExportFromServer  := .T.
        //Local lToFile         := .F.
        
 	CallCrys (cRpt,cParams,cOptions,lWaitRun,lExportFromServer/*lShowGauge,lRunOnServer*/)
         
 Return
