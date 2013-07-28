@isTest
private class aci_tt_cov_Utils {

    static testMethod void testGetScopeDefinitionBeginning() {
    	//semicolon splitter
     	String testFor = 'a = b; for(integer i = 0; i < z.length(); i ++)';
     	system.assertEquals(6, aci_Utils.getScopeDefinitionBeginning(testFor));
     	
     	String testIf = 'a = z * c; v = r - t; if(z == d.length())';
     	system.assertEquals(21, aci_Utils.getScopeDefinitionBeginning(testIf));
     	
     	String testWhile = 'asdf = df; df = gt; while(((true)))';
     	system.assertEquals(19, aci_Utils.getScopeDefinitionBeginning(testWhile)); 
     	
     	String testSimple = 'a = b; e = c + d; ';
     	system.assertEquals(17, aci_Utils.getScopeDefinitionBeginning(testSimple));
     	
     	//begin of class
     	String testInBegin = 'public static class myclass';
     	system.assertEquals(0, aci_Utils.getScopeDefinitionBeginning(testInBegin));
     	
     	//begin scope bracket
     	String testWithBeginBracket = 'class myclass { method1';
     	system.assertEquals(15, aci_Utils.getScopeDefinitionBeginning(testWithBeginBracket));
     	
     	//end scope bracket
     	String testWithEndBracket = 'method mymethod { asdfasdf; } method2';
     	system.assertEquals(29, aci_Utils.getScopeDefinitionBeginning(testWithEndBracket));
    }
    
    static testMethod void testGetScopesRanges(){
    	String test1 = 'class class { method mymethod {smth;}}';
    	Map<Integer, Integer> scopeMap1 = aci_Utils.getScopesRanges(test1);
    	system.assertEquals(37, scopeMap1.get(12));
    	system.assertEquals(36, scopeMap1.get(30));
    	
    	String test2 = 'method mymethod {smth;} method mymethod2 {smth;}';
    	Map<Integer, Integer> scopeMap2 = aci_Utils.getScopesRanges(test2);
    	system.assertEquals(22, scopeMap2.get(16));
    	system.assertEquals(47, scopeMap2.get(41));
    }
    
    static testMethod void testRetrieveScopes(){
    	String test1 = 'class class { method mymethod {smth;}}';
    	String [] scopes1 = aci_Utils.retrieveScopes(test1);
    	system.assertEquals(2, scopes1.size());
    	system.assertEquals('class class { method mymethod {smth;}}', scopes1[0]);
    	system.assertEquals(' method mymethod {smth;}', scopes1[1]);	
    }
    
    static testMethod void testCastStringToACIFormat(){
    	String test1 = 'aj = sdf; a = sadf + sdf == df; /*asd*/';
    	system.assertEquals('aj = sdf; a = sadf + sdf == df; ', aci_Utils.castStringToACIFormat(test1));
    	
    	String test2 = 'fd = afasdf;//asdf\n';
    	system.assertEquals('fd = afasdf;#aci_end_line#', aci_Utils.castStringToACIFormat(test2));
    	
    	String test3 = 'asdf=\'asdf\';';
    	system.assertEquals('asdf=#aci_string_literal#;', aci_Utils.castStringToACIFormat(test3));
    	
    	String testStarCommentWithNewLine = 'asdf/*asdfasdf/nasdf*/';
    	system.assertEquals('asdf', aci_Utils.castStringToACIFormat(testStarCommentWithNewLine));
    } 
    @isTest(SeeAllData=true)
    static void testFindClassNamesWhichImplementInterface(){
    	aci_Utils.findClassNamesWhichImplementInterface('aci_ApexCodeInspector.ClassInspector');
    }
}