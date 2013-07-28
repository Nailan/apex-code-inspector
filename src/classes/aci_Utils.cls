public without sharing class aci_Utils {
	
	public static String [] retrieveScopes(String classBody){
		Map<Integer, Integer> beginEndScopePos = getScopesRanges(classBody);
		List<Integer> sortedKeyset = new List<Integer>();
		sortedKeyset.addAll(beginEndScopePos.keyset());
		sortedKeyset.sort();
		String [] scopes = new List<String>();
		for(Integer i = 0; i < sortedKeyset.size(); i ++){
			Integer beg = sortedKeyset.get(i);
			Integer begScopeDef = getScopeDefinitionBeginning(classBody.substring(0, beg));
			Integer endPos = beginEndScopePos.get(beg) + 1;
			scopes.add(classBody.substring(begScopeDef, beginEndScopePos.get(beg) + 1));
		}
		return scopes;
	}
	
	public static Map<Integer, Integer> getScopesRanges(String classBody){
		Integer totalScopes = classBody.countMatches('{');
		Integer [] beginBracketsPos = new List<Integer>();
		Integer [] endBracketsPos = new List<Integer>();
		Integer lastBeginPos = -1;
		Integer lastEndPos = -1;
		for(Integer i = 0; i < totalScopes; i ++){
			beginBracketsPos.add(classBody.indexOf('{', lastBeginPos + 1));
			lastBeginPos = classBody.indexOf('{', lastBeginPos + 1);
			endBracketsPos.add(classBody.indexOf('}', lastEndPos + 1));
			lastEndPos = classBody.indexOf('}', lastEndPos + 1);
		}
		Map<Integer, Integer> beginEndScopePos = new Map<Integer, Integer>();
		for(Integer endPos : endBracketsPos){
			Integer begPos = classBody.length();
			for(Integer beginPos : beginBracketsPos){
				if(beginPos > endPos){
					break;
				}
				if(beginEndScopePos.get(beginPos) == null){
					begPos = beginPos;
				}
			}
			beginEndScopePos.put(begPos, endPos);
		}
		return beginEndScopePos;	
	}
	
	public static Integer getScopeDefinitionBeginning(String str){
		Integer pos = 0;
		Integer semicolonPos = str.lastIndexOf(';');
		Boolean splittingSemicolonDetected = false;
		while(!splittingSemicolonDetected && semicolonPos != -1){
			if(str.substring(semicolonPos).countMatches(')') == str.substring(semicolonPos).countMatches('(')){
				splittingSemicolonDetected = true;
			}
			else{
				semicolonPos = str.substring(0, semicolonPos).lastIndexOf(';');
			}
		}
		Integer begBracket = str.lastIndexOf('{');
		Integer endBracket = str.lastIndexOf('}');
		if(pos < begBracket){
			pos = begBracket + 1;
		}
		if(pos < endBracket){
			pos = endBracket + 1;
		}
		if(pos < semicolonPos){
			pos = semicolonPos + 1;
		}
		return pos;
	}
	
	public static String castStringToACIFormat(String classBody){
		String starsCommentRegEx = '/\\*.*\\*/';
		String slashesCommentRegEx = '//.*\n';
		String stringLiteralRegEx = '\'.*\'';
		classBody = classBody.replaceAll(starsCommentRegEx, '').replaceAll(slashesCommentRegEx, '\n').replaceAll(stringLiteralRegEx, '#aci_string_literal#');
		classBody = classBody.replaceAll('\n', '#aci_end_line#');
		return classBody;
	}
	
	public static String replaceAllSpaceSymbols(String str){
		return str.replaceAll('\t', '').replaceAll(' ', '').replaceAll('\n', '');
	}
	//to do: inner classes support
	public static String [] findClassNamesWhichImplementInterface(String interfaceName){
		String classPat = 'class[ \t\n\f\r]{1,}[a-zA-Z_0-9]{1,}[ \t\n\f\r]{1,}implements[ \t\n\f\r]{1,}aci_ApexCodeInspector\\.ClassInspector.*\\}';
		ApexClass [] classes = [select id, Name, Body 
								from ApexClass
								where Status =: 'Active'];
		system.debug('####### classes fount=' + classes.size() + '\n searching by a pattern ' + classPat);
		String [] classNames = new List<String>();
		for(ApexClass cl : classes){
			system.debug('############# class name=' + cl.Name);
			String body = cl.Body;
			body = castStringToACIFormat(body);
			system.debug('############ body =' + body);
			//body = replaceAllSpaceSymbols(body);
			Pattern implPattern = Pattern.compile(classPat);
			Matcher match = implPattern.matcher(body);
			Integer startPos = 0;
			Integer endPos = body.length();
			if(match.region(startPos, endPos).find()){
				system.debug('################ !!!!!!!!!!!!!!!');
				startPos = match.start();
				system.debug('############# ' + match.group());
			}
			/*if(body.containsIgnoreCase(searchString)){
				system.debug('!!!!!!!!!!!! got!!!!!!!!!!');
				String name = cl.Name;
				Integer defenitionPos = 0;
				for(Integer i = 0; i < body.countMatches(searchString); i ++){
					
				}
				classNames.add(cl.Name);
			}*/
		}
		return classNames;
	}
}