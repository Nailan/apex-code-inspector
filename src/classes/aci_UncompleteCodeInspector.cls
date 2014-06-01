/**
 * TODO comments finder plugin. 
 */
public with sharing class aci_UncompleteCodeInspector implements aci_ClassInspector, aci_TriggerInspector {
	private static final String MESSAGE = 'TO DO comment detected';
	private static final String COMMENT_REG_EXP = '(?s)(/\\*.*?\\*/)|(//[^\n]{0,}\n)';
	private static final String TO_DO_REG_EXP = '(?i)to[ \t\n\f\r]{0,}do[^A-Za-z0-9]{1,}';
	private static final Integer LINES_BEFORE_AFTER_COMMENT = 5;
	
	public aci_AnalysisResult inspectClass(String body) {
		return inspectItem(body);
	}
	
	public aci_AnalysisResult inspectTrigger(String body) {
		return inspectItem(body);
	}
	
	private aci_AnalysisResult inspectItem(String body) {
		String cBody = body;
		body = aci_StringUtils.replaceAllStringLiteralsWithGridSymbol(body);
		aci_AnalysisResult r = new aci_AnalysisResult();
		r.setStatus(aci_AnalysisResult.STATUS_OK);
		Pattern commPat = Pattern.compile(COMMENT_REG_EXP);
		Matcher commMatch = commPat.matcher(body);
		Integer startIndex = 0;
		Integer endIndex = body.length();
		Pattern todoPat = Pattern.compile(TO_DO_REG_EXP);
		List<Integer> lineNumbers = new List<Integer>();
		while(commMatch.region(startIndex, endIndex).find()) {
			system.debug('############# comment=' + commMatch.group());
			startIndex = commMatch.end();
			String comment = commMatch.group();
			Matcher todoMat = todoPat.matcher(comment);
			if(todoMat.find()) {
				lineNumbers.add(aci_StringUtils.getLineNumberOfPosition(body, commMatch.start() + todoMat.end()));
				r.setStatus(aci_AnalysisResult.STATUS_WARNING);
			}
		}
		if(r.getStatus() == aci_AnalysisResult.STATUS_WARNING) {
			aci_AnalysisDetail det = new aci_AnalysisDetail();
			if(lineNumbers.size() < 2) {
				det.setMessage(MESSAGE + '. Line ' + String.valueOf(lineNumbers.get(0)));	
			}
			else {
				det.setMessage(MESSAGE + '. Lines ' + aci_StringUtils.getLineNumbersAsString(lineNumbers));	
			}
			det.setCodeFragment(cBody);
			r.addDetail(det);
		}
		return r;
	}
	
	public String getName() {
		return '"TO DO" comments finder';
	}
	
	public String getDescription() {
		return 'Finds "TO DO" comments in code ';
	}

}