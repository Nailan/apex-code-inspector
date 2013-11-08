/**
 * @author Pavel Demeshchik
 *
 * Test class for aci_Utils.cls
 */
@isTest
public with sharing class aci_tt_cov_Utils {
	
	public static testmethod void testReplaceAllSpaceSymbols() {
		String strWithSpaces = '123   45    67 ';
		system.assertEquals('1234567', aci_Utils.replaceAllSpaceSymbols(strWithSpaces));
		
		String strWithTabs = '123\t456\t7';
		system.assertEquals('1234567', aci_Utils.replaceAllSpaceSymbols(strWithTabs));
		
		String strWithLineBreaks = '123\n456\n7\n';
		system.assertEquals('1234567', aci_Utils.replaceAllSpaceSymbols(strWithLineBreaks));
		
		String strComplex = '123      456\n\n\n 7 \t';
		system.assertEquals('1234567', aci_Utils.replaceAllSpaceSymbols(strComplex));
	}
	
	public static testmethod void testGetLineNumber() {
		String str = '123\n\n\n45\n\n67 ';
		system.assertEquals(6, aci_Utils.getLineNumberOfPosition(str, 10));
	}
	
	public static testmethod void testCastStringToACIFormat() {
		String strWithStCom = '1234/*asdf*/5678/*asdf*/';
		system.assertEquals('1234########5678########', aci_Utils.castStringToACIFormat(strWithStCom));
		
		String strLit = '1234\'asdf\'567\'asdf\'';
		system.assertEquals('1234######567######', aci_Utils.castStringToACIFormat(strLit));
		
		String newLineCom = '1234//adfasdf\n5678';
		system.assertEquals('1234#########\n5678', aci_Utils.castStringToACIFormat(newLineCom));
		
		String complex = '/**\n' +
					    '* This method prevent task creations for Users w/o Permissions over parent Milestone of task.\n' +
					    '* Checks if OWD for Milestone1_Milestone__c object are Private and then, checks if the current User have read/write permissons.\n' +
					    '* The way to do it its if Milestone1_Milestone__share exist, so we need do a QueryString to avoid compilations errors if that Object doesn\'t exist.\n*/';
		system.assertequals('1111', aci_Utils.castStringToACIFormat(complex).replaceAll('#', '').replaceAll('\n', '1'));
    
	}
	
	public static testmethod void testGetScopesRanges() {
		String str = '{{12345}    {12345}}';
		system.assertEquals(19, aci_Utils.getScopesRanges(str).get(0));
		system.assertEquals(7, aci_Utils.getScopesRanges(str).get(1));
		system.assertEquals(18, aci_Utils.getScopesRanges(str).get(12));
	}
	
	public static testmethod void testGetLineStartPosition() {
		String test1 = 'asdf\nasdf\n\n\n';
		system.assertEquals(5, aci_Utils.getLineStartPosition(test1, 2));
		system.assertEquals(0, aci_Utils.getLineStartPosition(test1, -1));
		
		String test2 = '1234\n567\n89';
		system.assertEquals(5, aci_Utils.getLineStartPosition(test2, 2));
		system.assertEquals(test2.length(), aci_Utils.getLineStartPosition(test2, 4));
		system.assertEquals(0, aci_Utils.getLineStartPosition(test2, 1));
	}
	
	public static testmethod void testGetLinesCoveredBySubstring() {
		String str1 = '1234\n5678\n9';
		system.assertEquals(3, aci_Utils.getLinesCoveredBySubstring(str1, 5, 10).get(1));	
	}
}