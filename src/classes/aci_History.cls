public without sharing class aci_History {
	public String renderAs{get;set;} 
	public AnalysisExecution [] executions{get;set;}
	private aci_Analysis_Execution__c [] executionObjs;
	private aci_Inspect_Result__c [] resultObjs;
	private aci_Inspect_Detail__c [] detObjs;
	
	public aci_History(){
		String modeParam = ApexPages.currentPage().getParameters().get('aci_mode');
		if(modeParam == null){
			modeParam = 'html';
		}
		initialize(modeParam);
	}
	
	public void initialize(String modeParam){
		if(modeParam == 'pdf'){
			renderAs = 'pdf';
		}
		else{
			renderAs = 'html';
		}
		loadExecutionHistory();
	}
	
	public void loadExecutionHistory(){
		executions = new List<AnalysisExecution>();
		executionObjs = [select id, Executed_By__c, Execution_Time__c 
						from aci_Analysis_Execution__c order by Execution_Time__c];
		resultObjs = [select id, Item_Name__c, Inspector_Name__c, Status__c, CreatedDate, Analysis_Execution__c
					from aci_Inspect_Result__c order by Item_Name__c];
		detObjs = [select Code_Fragment__c, End_Line__c, Inspect_Result__c, Lines__c, Message__c, Start_Line__c
											from aci_Inspect_Detail__c];
		for(aci_Analysis_Execution__c ex: executionObjs){
			AnalysisExecution exec = new AnalysisExecution(ex);
			List<AnalysisResult> ress = new List<AnalysisResult>();
			for(aci_Inspect_Result__c r: resultObjs){
				if(r.Analysis_Execution__c == ex.Id){
					AnalysisResult res = new AnalysisResult(r);
					List<AnalysisDetail> dets = new List<AnalysisDetail>();
					for(aci_Inspect_Detail__c d: detObjs){
						if(d.Inspect_Result__c == r.Id){
							dets.add(new AnalysisDetail(d));
						}
					}
					res.setDetails(dets);
					ress.add(res);
				}		
			}
			exec.setResults(ress);
			executions.add(exec);
		}
	}
	
	public Pagereference cleanHistory(){
		delete detObjs;
		delete resultObjs;
		delete executionObjs;
		Pagereference pr = new Pagereference('/apex/aci_History');
		pr.setRedirect(true);
		return pr;
	}
	
	public Pagereference back(){
		return new Pagereference('/apex/aci_ApexCodeInspector');
	}
	
	public Pagereference exportToPDF(){
		Pagereference pr = new Pagereference('/apex/aci_History?aci_mode=pdf');
		pr.setRedirect(true);
		return pr;
	}
	
}