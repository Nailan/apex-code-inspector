public without sharing class AnalysisResult {
	private aci_Inspect_Result__c result;
	private List<AnalysisDetail> details;
	
	public AnalysisResult(){
		result = new aci_Inspect_Result__c();
		details = new List<AnalysisDetail>();	
	}
	
	public AnalysisResult(aci_Inspect_Result__c r){
		result = r;
		details = new List<AnalysisDetail>();	
	}
	
	public SObject getSObject(Id executionId){
		result.Analysis_Execution__c = executionId;
		return result;
	}
	
	public AnalysisDetail CreateDetail(){
		aci_Inspect_Detail__c d = new aci_Inspect_Detail__c();
		return new AnalysisDetail(d);	
	}
	
	public void addDetail(AnalysisDetail d){
		details.add(d);
	}
	
	public void setDetails(List<AnalysisDetail> ds){
		details = ds;
	}
	
	public void setStatus(String st){
		result.Status__c = st;
	}
	
	public String getStatus(){
		return result.Status__c;
	}
	
	public List<AnalysisDetail> getDetails(){
		return details;
	}
	
	public Id getSObjectId(){
		return result.Id;
	}
	
	public void setInspectorName(String n){
		result.Inspector_Name__c = n;
	}
	
	public String getInspectorName(){
		return result.Inspector_Name__c;
	}
	
	public void setItemName(String name){
		result.Item_Name__c = name;
	}
	
	public String getItemName(){
		return result.Item_Name__c;
	}
}