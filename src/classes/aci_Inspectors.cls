public without sharing class aci_Inspectors {
	public static String LOOP_REG_EX = '(?i)[;\\{\\}]{1}[ \t\n\f\r]{0,}(for)|(while)[ \t\n\f\r]{0,}\\([^{]{1,}';
	
	public class SOQLInLoopsInspector ImplementS aci_ApexCodeInspector.ClassInspector, aci_ApexCodeInspector.TriggerInspector {
		private String MESSAGE = 'SOQL in loop found';
		private String SOQL_REG_EX = '(?i)\\[[ \t\n\f\r]{0,}select[ \t\n\f\r]{1,}.*\\]';
		
		public aci_Inspect_Result__c inspectClass(String classBody){
			aci_Inspect_Result__c result = inspectItem(classBody);
			return result;
		}
		
		public aci_Inspect_Result__c inspectTrigger(String triggerBody){
			aci_Inspect_Result__c result = inspectItem(triggerBody);
			return result;
		}
		
		public String getName(){
			return 'SOQL Inspector';
		}	
		
		public String getDescription(){
			return 'Use this inspector to find SOQL in loops';
		}
		
		private aci_Inspect_Result__c inspectItem(String body){
			aci_Inspect_Result__c result = new aci_Inspect_Result__c();
			body = aci_Utils.castStringToACIFormat(body);
			Pattern loopPat = Pattern.compile(LOOP_REG_EX);
			Matcher loopMatch = loopPat.matcher(body);
			Integer startIndex = 0;
			Integer endIndex = body.length();
			Map<Integer, Integer> scopes = aci_Utils.getScopesRanges(body);
			result.Status__c = 'Good';
			while(loopMatch.region(startIndex, endIndex).find()){
				system.debug('########## matching=' + loopMatch.group());
				String loopBody = body.substring(loopMatch.end(), scopes.get(loopMatch.end()));
				Pattern soqlPat = Pattern.compile(SOQL_REG_EX);
				Matcher soqlMatch = soqlPat.matcher(loopBody);
				if(soqlMatch.find()){
					result.Status__c = 'Error';
					result.Message__c = MESSAGE;	
				}
				startIndex = loopMatch.end();
			}
			return result;		
		}
	}
}