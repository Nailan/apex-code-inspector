@isTest
public with sharing class aci_tt_cov_LoopsInspectors {
	
	public static testmethod void testSOQL(){
		aci_LoopsInspectors.SOQLInspector soqlIns = new aci_LoopsInspectors.SOQLInspector();
		
		String strFor = ';for(Integer i = 0; i < 10; i ++){[select id from Account];}';
		system.assertEquals(AnalysisResult.STATUS_WARNING, soqlIns.inspectClass(strFor).getStatus());
		
		String strWh = 'method(){while(true){[select id from Account];}}';
		system.assertEquals(AnalysisResult.STATUS_WARNING, soqlIns.inspectClass(strWh).getStatus());
		
		String strDo = 'method(){do{[select id from Account];}while(true)}';
		system.assertEquals(AnalysisResult.STATUS_WARNING, soqlIns.inspectClass(strDo).getStatus());
		
		String strValid = 'methoddo(){[select id from Account];}';
		system.assertEquals(AnalysisResult.STATUS_OK, soqlIns.inspectClass(strValid).getStatus());
	}
	
	public static testmethod void testSOSL(){
		aci_LoopsInspectors.SOSLInspector soslIns = new aci_LoopsInspectors.SOSLInspector();
		
		String str1 = ';for(Integer i = 0; i < 10; i ++){[find id in *];}';
		system.assertEquals(AnalysisResult.STATUS_WARNING, soslIns.inspectClass(str1).getStatus());
		
		String str2 = ';do{[find id in *];}while(true)';
		system.assertEquals(AnalysisResult.STATUS_WARNING, soslIns.inspectClass(str2).getStatus());
	}
	
	public static testmethod void testDatabaseStatements(){
		aci_LoopsInspectors.DatabaseOperationsInspector databaseIns = new aci_LoopsInspectors.DatabaseOperationsInspector();
		
		String str1 = ';for(Integer i = 0; i < 10; i ++){insert accounts;}';
		system.assertEquals(AnalysisResult.STATUS_WARNING, databaseIns.inspectClass(str1).getStatus());
	}
	
	public static testmethod void testSendEmail(){
		aci_LoopsInspectors.SendEmailInspector sendEmailIns = new aci_LoopsInspectors.SendEmailInspector();
		
		String str1 = ';for(Integer i = 0; i < 10; i ++){messaging.SendEmail(emails);}';
		system.assertEquals(AnalysisResult.STATUS_WARNING, sendEmailIns.inspectClass(str1).getStatus());
	}	

}