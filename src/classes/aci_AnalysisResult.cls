/**
 * Model for aci_Inspect_Result__c
 */
public with sharing class aci_AnalysisResult {
	public static final String STATUS_OK = 'Ok';
	public static final String STATUS_WARNING = 'Warning';
	public static final String STATUS_ERROR = 'Error';
	public static final String STATUS_INFO = 'Info';
	
	private aci_Inspect_Result__c result;
	private List<aci_AnalysisDetail> details;
	
	public aci_AnalysisResult(){
		result = new aci_Inspect_Result__c();
		details = new List<aci_AnalysisDetail>();	
	}
	
	public aci_AnalysisResult(aci_Inspect_Result__c r) {
		result = r;
		details = new List<aci_AnalysisDetail>();	
	}
	
	public SObject getSObject(Id executionId) {
		result.Analysis_Execution__c = executionId;
		return result;
	}
	
	public aci_AnalysisDetail CreateDetail() {
		aci_Inspect_Detail__c d = new aci_Inspect_Detail__c();
		return new aci_AnalysisDetail(d);	
	}
	
	public void addDetail(aci_AnalysisDetail d) {
		details.add(d);
	}
	
	public void setDetails(List<aci_AnalysisDetail> ds) {
		details = ds;
	}
	
	public void setStatus(String st) {
		result.Status__c = st;
	}
	
	public String getStatus() {
		return result.Status__c;
	}
	
	public List<aci_AnalysisDetail> getDetails() {
		return details;
	}
	
	public Id getSObjectId() {
		return result.Id;
	}
	
	public void setInspectorName(String n) {
		result.Inspector_Name__c = n;
	}
	
	public String getInspectorName() {
		return result.Inspector_Name__c;
	}
	
	public void setItemName(String name) {
		result.Item_Name__c = name;
	}
	
	public String getItemName() {
		return result.Item_Name__c;
	}
}