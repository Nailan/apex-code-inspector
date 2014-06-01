/**
 * Model for aci_Inspect_Detail__c.
 */
public with sharing class aci_AnalysisDetail {
	private aci_Inspect_Detail__c detail;
	private String codeFragment; //shouldn't be saved into the DB because maximum text field length is only 32 000
	
	public aci_AnalysisDetail(aci_Inspect_Detail__c d) {
		detail = d;	
	}
	
	public aci_AnalysisDetail() {
		detail = new aci_Inspect_Detail__c();	
	}
	
	public void setMessage(String m) {
		detail.Message__c = m;
	}
	
	public void setStartLineNumber(Integer stLine) {
		detail.Start_Line__c = stLine;	
	}
	
	public void setEndLine(Integer endL) {
		detail.End_Line__c = endL;
	}
	
	public void addLineToHighlight(Integer pos) {
		detail.Lines__c = detail.Lines__c + String.valueOf(pos) + ';';
	}
	
	public void setLinesToHighlight(List<Integer> lines) {
		detail.Lines__c = '';
		for(Integer l : lines){
			detail.Lines__c = detail.Lines__c + String.valueOf(l) + ';';	
		}
	}
	
	public SObject getSObject(Id resultObjId) {
		detail.Inspect_Result__c = resultObjId;
		return detail;
	}
	
	public String getMessage() {
		return detail.Message__c;
	}
	
	public Integer getStartLine() {
		if(detail.Start_Line__c != null)
			return Integer.valueOf(detail.Start_Line__c);
		return 0;	
	}
	
	public Integer getEndLine() {
		if(detail.End_Line__c != null)
			return Integer.valueOf(detail.End_Line__c);
		return 0;
	}
	
	public List<Integer> getLinesToHighlight() {
		List<Integer> result = new List<Integer>();
		if(detail.Lines__c == null || detail.Lines__c.length() == 0) {
			return result;
		}
		for(String linStr : detail.Lines__c.split(';')) {
			result.add(Integer.valueOf(linStr));
		}
		return result;
	}
	
	public String getCodeFragment() {
		return codeFragment;
	}
	
	public void setCodeFragment(String fr) {
		codeFragment = fr;
	}

}