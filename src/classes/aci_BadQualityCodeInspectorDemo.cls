public with sharing class aci_BadQualityCodeInspectorDemo
		implements aci_ApexCodeInspector.ClassInspector {
			
	public String getName() {
		return 'Bad-quality code inspector for demo';
	}
	
	public String getDescription() {
		return 'Finds bad-quality code';
	}
	
	public AnalysisResult inspectClass(String classBody) {
		AnalysisResult res = new AnalysisResult();
		if (classBody.contains('bad-quality code')) {
			res.setStatus(AnalysisResult.STATUS_ERROR);
			AnalysisDetail det = new AnalysisDetail();
			det.setMessage('Bad-quality code detected!');
			det.setCodeFragment(classBody);
			res.addDetail(det);
		}
		return res;
	}
}