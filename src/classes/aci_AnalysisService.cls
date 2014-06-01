/*
* Service class for aci_AnalysisExecution, aci_AnalysisResult
*/
public with sharing class aci_AnalysisService implements aci_Singleton {
	private static aci_AnalysisService service;
	
	private aci_AnalysisService() {
	}
	
	public static aci_AnalysisService getInstance() {
		if (service == null) {
			service = new aci_AnalysisService();
		}
		return service;	
	}
	
	public void saveResults(List<aci_AnalysisResult> results) {
		aci_Analysis_Execution__c execution = new aci_Analysis_Execution__c();
		execution.Execution_Time__c = system.now();
		execution.Executed_By__c = UserInfo.getUserId();
		insert execution;
		List<SObject> toInsertResults = new List<SObject>();
		for(aci_AnalysisResult r: results) {
			toInsertResults.add(r.getSobject(execution.Id));
		}
		insert toInsertResults;
		List<SObject> toInsertDets = new List<SObject>();
		for(aci_AnalysisResult r: results) {
			Id rId = r.getSObjectId();
			for(aci_AnalysisDetail d: r.getDetails()) {
				toInsertDets.add(d.getSObject(rId));
			}	
		}
		insert toInsertDets;
	}
	
	public List<aci_AnalysisExecution> loadExecutions() {
		List<aci_AnalysisExecution> executions = new List<aci_AnalysisExecution>();
		List<aci_Analysis_Execution__c> executionObjs = [select id, Executed_By__c, Execution_Time__c 
														from aci_Analysis_Execution__c order by Execution_Time__c];
		List<aci_Inspect_Result__c> resultObjs = [select id, Item_Name__c, Inspector_Name__c, Status__c, CreatedDate, Analysis_Execution__c
												from aci_Inspect_Result__c order by Item_Name__c];
		List<aci_Inspect_Detail__c> detObjs = [select Code_Fragment__c, End_Line__c, Inspect_Result__c, Lines__c, Message__c, Start_Line__c
												from aci_Inspect_Detail__c];
		for(aci_Analysis_Execution__c ex: executionObjs) {
			aci_AnalysisExecution exec = new aci_AnalysisExecution(ex);
			List<aci_AnalysisResult> ress = new List<aci_AnalysisResult>();
			for(aci_Inspect_Result__c r: resultObjs) {
				if(r.Analysis_Execution__c == ex.Id) {
					aci_AnalysisResult res = new aci_AnalysisResult(r);
					List<aci_AnalysisDetail> dets = new List<aci_AnalysisDetail>();
					for(aci_Inspect_Detail__c d: detObjs) {
						if(d.Inspect_Result__c == r.Id) {
							dets.add(new aci_AnalysisDetail(d));
						}
					}
					res.setDetails(dets);
					ress.add(res);
				}		
			}
			exec.setResults(ress);
			executions.add(exec);
		}
		return executions;	
	}
	
	public void deleteAllExecutions() {
		delete [select id from aci_Inspect_Detail__c];
		delete [select id from aci_Inspect_Result__c];
		delete [select id from aci_Analysis_Execution__c];	
	}

}