public with sharing class aci_UncompleteCodeInspector implements aci_ApexCodeInspector.ClassInspector, aci_ApexCodeInspector.TriggerInspector {
	private static final String MESSAGE = 'TO DO comment detected';
	private static final String COMMENT_REG_EXP = '(/\\*(?:.|[\\n\\r])*?\\*/)|(//[^\n]{0,}\n)';
	private static final String TO_DO_REG_EXP = '(?i)to[ \t\n\f\r]{0,}do[^A-Za-z0-9]{1,}';
	private static final Integer LINES_BEFORE_AFTER_COMMENT = 5;
	
	public AnalysisResult inspectClass(String body){
		return inspectItem(body);
	}
	
	public AnalysisResult inspectTrigger(String body){
		return inspectItem(body);
	}
	
	private AnalysisResult inspectItem(String body){
		String cBody = body;
		body = aci_Utils.replaceAllStringLiteralsWithGridSymbol(body);
		AnalysisResult r = new AnalysisResult();
		r.setStatus(AnalysisResult.STATUS_OK);
		Pattern commPat = Pattern.compile(COMMENT_REG_EXP);
		Matcher commMatch = commPat.matcher(body);
		Integer startIndex = 0;
		Integer endIndex = body.length();
		Pattern todoPat = Pattern.compile(TO_DO_REG_EXP);
		while(commMatch.region(startIndex, endIndex).find()){
			system.debug('############# comment=' + commMatch.group());
			startIndex = commMatch.end();
			String comment = commMatch.group();
			Matcher todoMat = todoPat.matcher(comment);
			if(todoMat.find()){
				r.setStatus(AnalysisResult.STATUS_WARNING);
				AnalysisDetail det = new AnalysisDetail();
				det.setMessage(MESSAGE + '. Line ' + aci_Utils.getLineNumberOfPosition(body, commMatch.start() + todoMat.start()));
				det.setCodeFragment(cBody);
				det.setStartLineNumber(1);
				det.setLinesToHighlight(aci_Utils.getLinesCoveredBySubstring(body, commMatch.start() + todoMat.start(), commMatch.start() + todoMat.end()));
				r.addDetail(det);
				system.debug('############# todo=' + todoMat.group());
				system.debug('############# lines to highlight=' + det.getLinesToHighlight());
			}
		}
		return r;
	}
	
	public String getName(){
		return 'Uncomplete code Analyst';
	}
	
	public String getDescription(){
		return 'Finds all of the "TO DO" comments in code ';
	}

}