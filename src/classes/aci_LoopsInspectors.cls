public with sharing class aci_LoopsInspectors {
	public static String LOOP_REG_EX = '[ \t\n\f\r]{0,}for[ \t\n\f\r]{0,}\\([^{]{0,}';
	
	public class LoopsInspector implements aci_ApexCodeInspector.ClassInspector, aci_ApexCodeInspector.TriggerInspector {
		private String SOQL_MESSAGE = 'SOQL in loop found. ';
		private String SOQL_REG_EX = '(?i)\\[[ \t\n\f\r]{0,}select[ \t\n\f\r]{1,}.*\\]';
		
		private String DML_MESSAGE = 'DML in loop found. ';
		private String DML_REG_EX = '';
		
		private String DATABASE_QUERY_MESSAGE = '';
		private String DATABASE_QUERY_REG_EX = '';
		
		public AnalysisResult inspectClass(String classBody){
			AnalysisResult result = inspectItem(classBody);
			return result;
		}
		
		public AnalysisResult inspectTrigger(String triggerBody){
			AnalysisResult result = inspectItem(triggerBody);
			return result;
		}
		
		public String getName(){
			return 'Loops Inspector';
		}	
		
		public String getDescription(){
			return 'Use this inspector to find the most dangerous typical programming errors: DML, SOQL, database operations in loops.';
		}
		
		private AnalysisResult inspectItem(String body){
			AnalysisResult result = new AnalysisResult();
			result.setStatus('Ok');
			body = aci_Utils.castStringToACIFormat(body);
			Pattern loopPat = Pattern.compile(LOOP_REG_EX);
			Matcher loopMatch = loopPat.matcher(body);
			Integer startIndex = 0;
			Integer endIndex = body.length();
			Map<Integer, Integer> scopes = aci_Utils.getScopesRanges(body);
			while(loopMatch.region(startIndex, endIndex).find()){
				system.debug('########## matching=' + loopMatch.group());
				String loopBody = body.substring(loopMatch.end(), scopes.get(loopMatch.end()));
				//SOQL
				Pattern soqlPat = Pattern.compile(SOQL_REG_EX);
				Matcher soqlMatch = soqlPat.matcher(loopBody);
				if(soqlMatch.find()){
					result.setStatus('Error');
					//result.Message__c = SOQL_MESSAGE + ' Line: ' + aci_Utils.getLine(body, loopMatch.start());	
				}
				//DML
				/*Pattern dmlPat = Pattern.compile(DML_REG_EX);
				Matcher dmlMatch = dmlPat.matcher(loopBody);
				if(dmlMatch.find()){
					result.Status__c = 'Error';
					result.Message__c = result.Message__c + DML_MESSAGE + ' Line: ' + aci_Utils.getLine(body, dmlMatch.start());	
				}*/
				startIndex = loopMatch.end();
			}
			return result;		
		}
	}
}