public with sharing class AnalysisExecution {
	private aci_Analysis_Execution__c execution;
	private List<AnalysisResult> results;
	
	public AnalysisExecution(){
		execution = new aci_Analysis_Execution__c();
		results = new List<AnalysisResult>();
	}
	
	public AnalysisExecution(aci_Analysis_Execution__c ex){
		execution = ex;
		results = new List<AnalysisResult>();
	}
	
	public void setExecutionTime(DateTime d){
		execution.Execution_Time__c = d;
	}
	
	public void setExecutedById(Id uId){
		execution.Executed_By__c = uId;
	}
	
	public DateTime getExecutionTime(){
		return execution.Execution_Time__c;
	}
	
	public String getExecutedById(){
		return execution.Executed_By__c;
	}
	
	public List<AnalysisResult> getResults(){
		return results;
	}
	
	public void addResult(AnalysisResult r){
		results.add(r);
	}
	
	public void setResults(List<AnalysisResult> ress){
		results = ress;
	}
	
	public void save(){
		insert execution;
		List<SObject> toInsertResults = new List<SObject>();
		for(AnalysisResult r: results){
			toInsertResults.add(r.getSobject(execution.Id));
		}
		insert toInsertResults;
		List<SObject> toInsertDets = new List<SObject>();
		for(AnalysisResult r: results){
			Id rId = r.getSObjectId();
			/*clean code fragment because of text area size is 64000,
			but code fragment can be much more bigger. Moreover, 
			History is a section with a cmmon information.
			*/
			for(AnalysisDetail d : r.getDetails()){
				d.setCodeFragment('');
			}
			for(AnalysisDetail d: r.getDetails()){
				toInsertDets.add(d.getSObject(rId));
			}	
		}
		insert toInsertDets;
	}
}