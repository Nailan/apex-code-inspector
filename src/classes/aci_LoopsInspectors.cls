public with sharing class aci_LoopsInspectors {
	private static String LOOP_REG_EX = '(?i)([;\\{\\}]{1}[ \n\t\r]{0,}(for|while)[ \n\t\r]{0,}\\([^\\{]{1,})|([;\\{\\}]{1}[ \n\t\r]{0,}do[^\\{]{0,})';
	
	public class SOQLInspector implements aci_ApexCodeInspector.ClassInspector, aci_ApexCodeInspector.TriggerInspector {
		private String SOQL_MESSAGE = 'A SOQL query in a loop found. ';
		private String SOQL_REG_EX = '(?i)\\[[ \t\n\f\r]{0,}select[ \t\n\f\r]{1,}[^]]{0,}\\]';
		
		public AnalysisResult inspectClass(String classBody){
			AnalysisResult result = inspectItem(classBody, SOQL_REG_EX, SOQL_MESSAGE, AnalysisResult.STATUS_WARNING);
			return result;
		}
		
		public AnalysisResult inspectTrigger(String triggerBody){
			AnalysisResult result = inspectItem(triggerBody, SOQL_REG_EX, SOQL_MESSAGE, AnalysisResult.STATUS_WARNING);
			return result;
		}
		
		public String getName(){
			return 'SOQL Inspector';
		}	
		
		public String getDescription(){
			return 'Checks optimal usage of SOQL queries';
		}
		
	}
	
	public class SOSLInspector implements aci_ApexCodeInspector.ClassInspector, aci_ApexCodeInspector.TriggerInspector {
		private String SOSL_MESSAGE = 'A SOSL query in a loop found. ';
		private String SOSL_REG_EX = '(?i)\\[[ \t\n\f\r]{0,}find[ \t\n\f\r]{1,}[^]]{0,}\\]';

		public AnalysisResult inspectClass(String classBody){
			AnalysisResult result = inspectItem(classBody, SOSL_REG_EX, SOSL_MESSAGE, AnalysisResult.STATUS_WARNING);
			return result;
		}
		
		public AnalysisResult inspectTrigger(String triggerBody){
			AnalysisResult result = inspectItem(triggerBody, SOSL_REG_EX, SOSL_MESSAGE, AnalysisResult.STATUS_WARNING);
			return result;
		}
		
		public String getName(){
			return 'SOSL quesries usage Analysist';
		}	
		
		public String getDescription(){
			return 'Checks if SOSL queries are used optimally';
		}
	}
	
	public class DatabaseOperationsInspector implements aci_ApexCodeInspector.ClassInspector, aci_ApexCodeInspector.TriggerInspector {
		private String DATABASE_MESSAGE = 'An operation with Database in a loop found. ';
		private String DATABASE_REG_EX = '(?i)(Database\\.[A-Za-z]{1,}[^;]{0,};)|([;\\{\\}]{1}[ \t\n\f\r]{0,}((insert)|(update)|(delete)|(merge)|(undelete)|(upsert))[ \t\n\f\r]{1,}[^;]{1,};)';
		
		public AnalysisResult inspectClass(String classBody){
			AnalysisResult result = inspectItem(classBody, DATABASE_REG_EX, DATABASE_MESSAGE, AnalysisResult.STATUS_WARNING);
			return result;
		}
		
		public AnalysisResult inspectTrigger(String triggerBody){
			AnalysisResult result = inspectItem(triggerBody, DATABASE_REG_EX, DATABASE_MESSAGE, AnalysisResult.STATUS_WARNING);
			return result;
		}
		
		public String getName(){
			return 'Database Operations Analysist.';
		}	
		
		public String getDescription(){
			return 'Detects operations with Database in loops';
		}
	}
	
	public class SendEmailInspector implements aci_ApexCodeInspector.ClassInspector, aci_ApexCodeInspector.TriggerInspector {
		private String SEND_EMAIL_MESSAGE = 'A "Send Email" invocation in a loop found. ';
		private String SEND_EMAIL_REG_EX = '(?i)[;\\{\\}]{1}[ \t\n\f\r]{0,}Messaging.sendEmail[^;]{1,};';
		
		public AnalysisResult inspectClass(String classBody){
			AnalysisResult result = inspectItem(classBody, SEND_EMAIL_REG_EX, SEND_EMAIL_MESSAGE, AnalysisResult.STATUS_WARNING);
			return result;
		}
		
		public AnalysisResult inspectTrigger(String triggerBody){
			AnalysisResult result = inspectItem(triggerBody, SEND_EMAIL_REG_EX, SEND_EMAIL_MESSAGE, AnalysisResult.STATUS_WARNING);
			return result;
		}
		
		public String getName(){
			return '"Send Email" invocations Analysist.';
		}	
		
		public String getDescription(){
			return 'Detects "Send Email" invocations in loops. Salesforce limit is 10 invocations per transaction.';
		}
	}
	
	private static AnalysisResult inspectItem(String body, String InterRegExp, String message, String statusIfFounded){
		AnalysisResult result = new AnalysisResult();
		result.setStatus(AnalysisResult.STATUS_OK);
		String copyBody = body;
		body = aci_Utils.castStringToACIFormat(body);
		Pattern loopPat = Pattern.compile(LOOP_REG_EX);
		Matcher loopMatch = loopPat.matcher(body);
		Integer startIndex = 0;
		Integer endIndex = body.length();
		Map<Integer, Integer> scopes = aci_Utils.getScopesRanges(body);
		//system.debug('########### scopes=' + scopes);
		while(loopMatch.region(startIndex, endIndex).find()){
			system.debug('########### loop def=' + loopMatch.group());
			//system.debug('########### loop def end=' + loopMatch.end());
			String loopBody = body.substring(loopMatch.end(), scopes.get(loopMatch.end()));
			Pattern interPat = Pattern.compile(InterRegExp);
			Matcher interMatch = interPat.matcher(loopBody);
			if(interMatch.find()){
				system.debug('########### matching=' + interMatch.group());
				result.setStatus(statusIfFounded);
				AnalysisDetail det = new AnalysisDetail();
				det.setMessage(message + '. Line ' + aci_Utils.getLineNumberOfPosition(body, loopMatch.start() + interMatch.start()));
				det.setCodeFragment(copyBody);
				det.setStartLineNumber(1);
				det.setLinesToHighlight(aci_Utils.getLinesCoveredBySubstring(body, loopMatch.start() + interMatch.start(), loopMatch.start() + interMatch.end()));
				system.debug('########### lines to highlight=' + det.getLinesToHighlight());
				result.addDetail(det);	
			}
			startIndex = loopMatch.end();
		}
		return result;			
	}
}