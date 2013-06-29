public with sharing class aci_ApexCodeInspector {
	public Map<String, Boolean> apexClassIsSelected {get;set;}
	public ApexClass [] classes{get;set;}
	public Integer numberOfClassesToShow{get;set;}
	
	public aci_ApexCodeInspector(){
		initialize();
	}
	
	public void initialize(){
		classes = loadClasses();
		apexClassIsSelected = initializeApexClassIsSelected(classes);
		numberOfClassesToShow = 100;
	}
	
	public void initialize(String searchString){
		classes = loadClasses(searchString);
		apexClassIsSelected = initializeApexClassIsSelected(classes);
	}
	
	public ApexClass [] loadClasses(){
		return [select id, Body, Name 
				from ApexClass 
				where Status =: 'Active' ORDER BY Name LIMIT : numberOfClassesToShow];
	}
	
	public ApexClass [] loadClasses(String searchString){
		return [select id, Body, Name from ApexClass  
				where Status =: 'Active' ORDER BY Name LIMIT : numberOfClassesToShow];	
	}
	
	public Map<String, Boolean> initializeApexClassIsSelected(ApexClass [] classes){
		Map <String, Boolean> resultMap = new Map<String, Boolean>();
		for(ApexClass cl : classes){
			resultMap.put(cl.Id, false);	
		}
		return resultMap;
	}
	
	public void inspectSelectedClasses(){
		
	}
}