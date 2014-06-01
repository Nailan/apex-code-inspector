public with sharing class aci_ReflectionApiExt {
	private aci_ReflectionApiExt() {}
	
	/**
     * Returns names of all of the classes which implement specified interface name.
     *
     * @param interfaceName - name of interface
     * @return list of full names of classes. Inserted classes supported
     */
    public static String [] findClassNamesWhichImplementInterface(String interfaceName) {
        String classPat = '(?i)class[ \t\n\f\r]{1,}.[^{]{1,}';
        String classWithInterfaceRegex = '(?i)[ \t\n\f\r]{1,}implements[ \t\n\f\r]{1,}(.*[,]{1,}' + interfaceName + ')|(' + interfaceName + ')';
        String [] classNames = new List<String>();
        String searchString = '\'*' + interfaceName + '*\'';
        String query = 'FIND ' +  searchString + ' IN ALL FIELDS RETURNING ApexClass(Id, Body, Name)';
        List<Sobject[]> results = search.query(query);
        List<ApexClass> classes  = new List<ApexClass>();
        if (results != null && results[0].size() != 0) {
        	classes = results[0];
        }
        for(ApexClass cl : classes) {
            String body = cl.Body;
            body = aci_StringUtils.castStringToACIFormat(body);
            if(!body.contains(interfaceName)) {
                continue;
            }
            Pattern classPattern = Pattern.compile(classPat);
            Matcher match = classPattern.matcher(body);
            Integer startPos = 0;
            Integer endPos = body.length();
            Map<Integer, Integer> scopes = aci_StringUtils.getScopesRanges(body);
            List<String> classDefs = new List<String>();
            List<String> classBodies = new List<String>();
            while(match.region(startPos, endPos).find()) {
                classDefs.add(match.group());
                classBodies.add(body.substring(match.end(), scopes.get(match.end())));
                startPos = match.end();
            }
            for(Integer i = classDefs.size() - 1; i >= 0; i --) {
                String classDef = classDefs.get(i);
                String className = classDef.replaceAll('class[ \t\n\f\r]{1,}', '').replaceAll('[ \t\n\f\r]{1,}.*', '');
                String classBody = classBodies.get(i);
                for(Integer j = 0; j < i; j ++) {
                    String parentClassDef = classDefs.get(j); 
                    String parentClassName = parentClassDef.replaceAll('class[ \t\n\f\r]{1,}', '').replaceAll('[ \t\n\f\r]{1,}.*', '');
                    String parentClassBody = classBodies.get(j);
                    if(parentClassBody.contains(classBody) && parentClassBody.contains(classDef)){
                        className = parentClassName + '.' + className;
                    }
                }
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