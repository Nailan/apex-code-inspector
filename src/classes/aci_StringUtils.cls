/**
 * Class contains string utility methods.
 */
public with sharing class aci_StringUtils {
	
	private aci_StringUtils() {}
    
    /**
     * Removes all space symbols
     * 
     * @param str - String for processing
     * @return specified string without space symbols
     */
    public static String replaceAllSpaceSymbols(String str) {
        return str.replaceAll('\t', '').replaceAll(' ', '').replaceAll('\n', '');
    }
    
    /**
     * Returns line number for specified position.
     *
     * @param str - string for processing 
     * @param pos - number of position in specified string
     *
     * @return line number of specified position in specified string
     */
    public static Integer getLineNumberOfPosition(String str, Integer pos) {
        return str.subString(0, pos).countMatches('\n') + 1;
    }
    
    /**
     * Returns number of lines in specified string
     *
     * @param str - string for processing
     */
    public static Integer getTotalLines(String str) {
    	return str.countMatches('\n') + 1;
    }
    
    /**
     * Returns list of line numbers, covered by substring from @substrStartindex to @substrEndIndex
     *
     * @param str - string for processing
     * @param substrStartindex - start position of substring in str
     * @param substrEndIndex - end position of substring in str
     */
    public static List<Integer> getLinesCoveredBySubstring(String str, Integer substrStartindex, Integer substrEndIndex) {
    	List<Integer> lines = new List<Integer>();
    	for(Integer i = getLineNumberOfPosition(str, substrStartindex); i<= getLineNumberOfPosition(str, substrEndIndex); i++) {
    		lines.add(i);
    	}
    	return lines;
    }
    
    /**
     * Returns position of line start.
     * 
     * @param body - string for processing
     * @param lineNumber - number of line
     */
    public static Integer getLineStartPosition(String body, Integer lineNumber) {
    	if(lineNumber <= 1){
    		return 0;
    	}
    	if(lineNumber > body.countMatches('\n') + 1) {
    		return body.length();
    	}
    	Integer pos = 0;
    	Integer lastIndex = 0;
    	for(Integer i = 0; i < lineNumber - 1; i ++) {
    		lastIndex = body.indexOf('\n', pos);
    		pos = lastIndex + 1;
    	}
    	return pos;
    }    
    
    /**
     * Replaces all of string literals and comments with '#' character.
     * 
     * @param classBody - string for processing
     * @return string with comments and string literals replaced with '#'
     */
    public static String castStringToACIFormat(String classBody) {
        classBody = replaceAllCommentsWithGridSymbol(classBody);
        classBody = replaceAllStringLiteralsWithGridSymbol(classBody);
        return classBody;
    }
    
    /**
     * Replaces all of the comments with '#'.
     *
     * @param classBody - string for processing
     */
    public static String replaceAllCommentsWithGridSymbol(String classBody) {
    	String starsCommentRegEx = '(?s)(/\\*.*?\\*/)|(//[^\n]{0,}\n)';
        Pattern starsComPat = Pattern.compile(starsCommentRegEx);
        Matcher starsComMat = starsComPat.matcher(classBody);
        Integer startPos = 0;
        Integer endPos = classBody.length();
        while(starsComMat.region(startPos, endPos).find()){
            classBody = classBody.replace(starsComMat.group(), getPlaceholder(starsComMat.group()));
            startPos = starsComMat.end();       
        }
        return classBody;	
    }
    
    /**
     * Replaces all of the string literals with '#'.
     *
     * @param classBody - string for processing
     */
    public static String replaceAllStringLiteralsWithGridSymbol(String classBody) {
    	String stringLiteralRegEx = '\'[^\']*\'';
        Pattern stringLitPat = Pattern.compile(stringLiteralRegEx);
        Matcher stringLitMat = stringLitPat.matcher(classBody);
        Integer startPos = 0;
        Integer endPos = classBody.length();
        while(stringLitMat.region(startPos, endPos).find()) {
            classBody = classBody.replace(stringLitMat.group(), getPlaceholder(stringLitMat.group()));
            startPos = stringLitMat.end();          
        }
        return classBody;	
    }
    
    private static String getPlaceholder(String str) {
        String placeHolder = '';
        placeHolder = str.replaceAll('[^\n]', '#');
        return placeHolder;
    }
    
    /**
     * Returns map of positions of pairs '{' and '}'.
     *
     * @param classBody - string for processing
     */
    public static Map<Integer, Integer> getScopesRanges(String classBody) {
    	classBody = castStringToACIFormat(classBody);
        Integer totalScopes = classBody.countMatches('{');
        Integer [] beginBracketsPos = new List<Integer>();
        Integer [] endBracketsPos = new List<Integer>();
        Integer lastBeginPos = -1;
        Integer lastEndPos = -1;
        for(Integer i = 0; i < totalScopes; i ++) {
            beginBracketsPos.add(classBody.indexOf('{', lastBeginPos + 1));
            lastBeginPos = classBody.indexOf('{', lastBeginPos + 1);
            endBracketsPos.add(classBody.indexOf('}', lastEndPos + 1));
            lastEndPos = classBody.indexOf('}', lastEndPos + 1);
        }
        Map<Integer, Integer> beginEndScopePos = new Map<Integer, Integer>();
        for(Integer endPos : endBracketsPos){
            Integer begPos = classBody.length();
            for(Integer beginPos : beginBracketsPos){
                if(beginPos > endPos) {
                    break;
                }
                if(beginEndScopePos.get(beginPos) == null) {
                    begPos = beginPos;
                }
            }
            beginEndScopePos.put(begPos, endPos);
        }
        return beginEndScopePos;    
    }
    
    /**
     * Returns string which contains specified numbers devided by ', '.
     *
     * @param lineNumber  list of numbers
     */
    public static String getLineNumbersAsString(List<Integer> lineNumbers) {
    	String linesStr = '';
		for(Integer i = 0; i < lineNumbers.size(); i ++) {
			linesStr += lineNumbers.get(i);
			if(i != lineNumbers.size() - 1) {
				linesStr += ', ';
			}
		}
		return linesStr;
    }
}