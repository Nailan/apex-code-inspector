public without sharing class aci_Inspectors {
	public class SOQLInLoopsInspector implements aci_ApexCodeInspector.ClassInspector{
		String MESSAGE = 'SOQL in loop found';
		
		public aci_Inspect_Result__c inspectClass(ApexClass cl){
			aci_Inspect_Result__c result = new aci_Inspect_Result__c();
			result.Apex_Class_Trigger_Name__c = cl.Name;
			String body = cl.Body;
			String soqlInloopRegex = 'for[/S]';
			//body = aci_Utils.castStringToACIFormat(body);
			String [] scopes = aci_Utils.retrieveScopes(body);
			String status = 'Good';
			/*for(String scope : scopes){
				if(scope.substring(0, scope.indexOf('{')).replaceAll(' ', '').toLowerCase().contains('for(')){
					if(scope.replaceAll(' ', '').replaceAll('\n', '').replaceAll('\t', '').toLowerCase().contains('[select')){
						result.Message__c = MESSAGE;
						if(status == 'Good'){
							status = 'Error';
						}
					}	
				}
			}*/
			result.Status__c = status;
			return result;	
			
			
		}
		
		public String getName(){
			return 'SOQL Inspector';
		}	
		
		public String getDescription(){
			return 'Use this inspector to find SOQL in loops';
		}
	}
}