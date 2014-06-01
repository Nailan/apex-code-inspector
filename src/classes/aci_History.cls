/**
 * Controller for aci_History.page
 */
public without sharing class aci_History {
	public String renderAs{get;set;} 
	public aci_AnalysisExecution [] executions{get;set;}
	private aci_AnalysisService analysisService;
	
	public aci_History() {
		analysisService = aci_AnalysisService.getInstance();
		
		String modeParam = ApexPages.currentPage().getParameters().get('aci_mode');
		if(modeParam == null) {
			modeParam = 'html';
		}
		initialize(modeParam);
	}
	
	public void initialize(String modeParam) {
		if(modeParam == 'pdf') {
			renderAs = 'pdf';
		}
		else {
			renderAs = 'html';
		}
		loadExecutionHistory();
	}
	
	public void loadExecutionHistory() {
		executions = analysisService.loadExecutions();			
	}
	
	public Pagereference cleanHistory() {
		analysisService.deleteAllExecutions();
		Pagereference pr = new Pagereference('/apex/aci_History');
		pr.setRedirect(true);
		return pr;
	}
	
	public Pagereference back() {
		return new Pagereference('/apex/aci_ApexCodeInspector');
	}
	
	public Pagereference exportToPDF() {
		Pagereference pr = new Pagereference('/apex/aci_History?aci_mode=pdf');
		pr.setRedirect(true);
		return pr;
	}
	
}