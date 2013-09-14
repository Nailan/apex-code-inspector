@isTest
public with sharing class aci_tt_cov_UncompleteCodeInspector {
	public static testmethod void testInspecting(){
		aci_UncompleteCodeInspector ins = new aci_UncompleteCodeInspector();
		
		String test1 = '/*TO DO: asdfasdfasdf*/';
		system.assertEquals(AnalysisResult.STATUS_WARNING,  ins.inspectClass(test1).getStatus());
		
		String test2 = '/*TODO: asdfasdfasdf*/';
		system.assertEquals(AnalysisResult.STATUS_WARNING,  ins.inspectClass(test2).getStatus());
		
		String test3 = '/*asdfasdfasdf todo*/';
		system.assertEquals(AnalysisResult.STATUS_WARNING,  ins.inspectClass(test3).getStatus());
		
		String test4 = '/*asdfasdfasdf to doasdfasd*/';
		system.assertEquals(AnalysisResult.STATUS_OK,  ins.inspectClass(test4).getStatus());
		
		String test5 = '//todo: finish\n';
		system.assertEquals(AnalysisResult.STATUS_WARNING,  ins.inspectClass(test5).getStatus());
	}
}