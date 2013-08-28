@isTest
public with sharing class aci_tt_cov_Utils {
	
	public static testmethod void testReplaceAllSpaceSymbols(){
		String strWithSpaces = '123   45    67 ';
		system.assertEquals('1234567', aci_Utils.replaceAllSpaceSymbols(strWithSpaces));
		
		String strWithTabs = '123\t456\t7';
		system.assertEquals('1234567', aci_Utils.replaceAllSpaceSymbols(strWithTabs));
		
		String strWithLineBreaks = '123\n456\n7\n';
		system.assertEquals('1234567', aci_Utils.replaceAllSpaceSymbols(strWithLineBreaks));
		
		String strComplex = '123      456\n\n\n 7 \t';
		system.assertEquals('1234567', aci_Utils.replaceAllSpaceSymbols(strComplex));
	}
	
	public static testmethod void testGetLineNumber(){
		String str = '123\n\n\n45\n\n67 ';
		system.assertEquals(5, aci_Utils.getLineNumber(str, 10));
	}
	
	public static testmethod void testCastStringToACIFormat(){
		String strWithStCom = '1234/*asdf*/5678/*asdf*/';
		system.assertEquals('1234########5678########', aci_Utils.castStringToACIFormat(strWithStCom));
		
		String strLit = '1234\'asdf\'567\'asdf\'';
		system.assertEquals('1234######567######', aci_Utils.castStringToACIFormat(strLit));
	}
	
	public static testmethod void testGetScopesRanges(){
		
	}
}