public with sharing class aci_test {
	public String st {get;set;}
	public ApexClass cl{get;set;}
	
	
	/*TODO: test this comment*/
	public aci_test(){
		cl = [select id, Body from ApexClass where Name =:'aci_ApexCodeInspector'];
		system.debug('########################################################################################################### ' + cl.Body);
		st = cl.Body.replaceAll('\n', '<br/>').replaceAll('\t', '&nbsp;&nbsp;&nbsp;&nbsp;').replaceAll(' ', '&nbsp;');
	}
	//TODO: Test this comment
}