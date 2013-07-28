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
		return classBody;
	}
	
	public static String replaceAllSpaceSymbols(String str){
		return str.replaceAll('\t', '').replaceAll(' ', '').replaceAll('\n', '');
	}
	
	public static String [] findClassNamesWhichImplementInterface(String interfaceName){
		String interfaceNameRegex = interfaceName.replaceAll('\\.', '\\\\\\\\.');
		system.debug('!!!!!! interface reg ex=' + interfaceNameRegex);
		String classPat = 'class[ \t\n\f\r]{1,}.[^{]{1,}';
		ApexClass [] classes = [select id, Name, Body 
								from ApexClass
								where Status =: 'Active'];
		String classWithInterfaceRegex = '[ \t\n\f\r]{1,}implements[ \t\n\f\r]{1,}.*[ \t\n\f\r]|[,]{1,}' + interfaceName;
		String [] classNames = new List<String>();
		for(ApexClass cl : classes){
			String body = cl.Body;
			body = castStringToACIFormat(body);
			if(!body.contains(interfaceName)){
				continue;
			}
			Pattern classPattern = Pattern.compile(classPat);
			Matcher match = classPattern.matcher(body);
			Integer startPos = 0;
			Integer endPos = body.length();
			Map<Integer, Integer> scopes = getScopesRanges(body);
			List<String> classDefs = new List<String>();
			List<String> classBodies = new List<String>();
			while(match.region(startPos, endPos).find()){
				classDefs.add(match.group());
				classBodies.add(body.substring(match.end(), scopes.get(match.end())));
				startPos = match.end();
			}
			for(Integer i = classDefs.size() - 1; i >= 0; i --){
				String classDef = classDefs.get(i);
				String className = classDef.replaceAll('class[ \t\n\f\r]{1,}', '').replaceAll('[ \t\n\f\r]{1,}.*', '');
				String classBody = classBodies.get(i);
				system.debug('!!!!!!!!!!! className=' + className);
				system.debug('!!!!!!!!!!! classDef=' + classDef);
				system.debug('!!!!!!!!!!! classBody=' + classBody);
				for(Integer j = 0; j < i; j ++){
					String parentClassDef = classDefs.get(j); 
					String parentClassName = parentClassDef.replaceAll('class[ \t\n\f\r]{1,}', '').replaceAll('[ \t\n\f\r]{1,}.*', '');
					String parentClassBody = classBodies.get(j);
					system.debug('!!!!!!! parentClassBody=' + parentClassBody);
					if(parentClassBody.contains(classBody)){
						className = parentClassName + '.' + className;
					}
				}
				system.debug('!!!!!!!!!!! finalClassName=' + className);
				Pattern interfacePattern = Pattern.compile(classWithInterfaceRegex);
				Matcher interfaceMatcher = interfacePattern.matcher(classDef);
				if(interfaceMatcher.find()){
					classNames.add(className);
				}
			}
		}
		return classNames;
	}
}