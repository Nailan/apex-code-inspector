/**
 * Model for aci_Analysis_Execution__c
 */
 public with sharing class aci_AnalysisExecution {
	private aci_Analysis_Execution__c execution;
	private List<aci_AnalysisResult> results;
	
	public aci_AnalysisExecution() {
		execution = new aci_Analysis_Execution__c();
		results = new List<aci_AnalysisResult>();
	}
	
	public aci_AnalysisExecution(aci_Analysis_Execution__c ex) {
		execution = ex;
		results = new List<aci_AnalysisResult>();
	}
	
	public void setExecutionTime(DateTime d) {
		execution.Execution_Time__c = d;
	}
	
	public void setExecutedById(Id uId) {
		execution.Executed_By__c = uId;
	}
	
	public DateTime getExecutionTime() {
		return execution.Execution_Time__c;
	}
	
	public String getExecutedById() {
		return execution.Executed_By__c;
	}
	
	public List<aci_AnalysisResult> getResults() {
		return results;
	}
	
	public void addResult(aci_AnalysisResult r) {
		results.add(r);
	}
	
	public void setResults(List<aci_AnalysisResult> ress) {
		results = ress;
	}
	
}