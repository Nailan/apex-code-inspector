public with sharing class aci_ApexCodeInspector {
	public static final String CLASS_INSPECTOR_INTERFACE = 'aci_ApexCodeInspector.ClassInspector';
	public static final String TRIGGER_INSPECTOR_INTERFACE = 'aci_ApexCodeInspector.TriggerInspector';
	
	public Map<String, Boolean> apexClassIsSelected {get;set;}
	public ApexClass [] classes{get;set;}
	public ApexTrigger [] triggers{get;set;}
	public Integer numberOfClassesToShow {get;set;}
	public String searchByName{get;set;}
	public Map<String, aci_Inspect_Result__c[]> classIdResult{get;set;}
	public Integer currentStep{get;set;}
	public List<ClassInspector> classInspectors{get;set;}
	public Map<String, Boolean> classInspectorIsSelected{get;set;}
	public List<TriggerInspector> triggerInspectors{get;set;}
	
	public interface ClassInspector{
		aci_Inspect_Result__c inspectClass(ApexClass cl);
		String getName();
		String getDescription();
	}
	
	public interface TriggerInspector{
		aci_Inspect_Result__c inspectTrigger(ApexTrigger cl);
		String getName();
		String getDescription();
	}
	
	public aci_ApexCodeInspector(){
		initialize();
	}
	
	public void initialize(){
		classIdResult = new Map<String, aci_Inspect_Result__c[]>();
		numberOfClassesToShow = 100;
		currentStep = 1;
		classes = loadClasses();
		apexClassIsSelected = initializeApexClassIsSelectedMap(classes);
		classInspectors = loadClassInspectors();
		classInspectorIsSelected = initializeInspectorIsSelectedMap(classInspectors);
	}
	
	public ApexClass [] loadClasses(){
		return [select id, Body, Name 
				from ApexClass 
				where Status =: 'Active' ORDER BY Name LIMIT : numberOfClassesToShow];
	}
	
	public ApexClass [] loadClasses(String searchString){
		if(searchString != null){
		searchString = '%' + searchString + '%';
		return [select id, Body, Name from ApexClass  
				where Status =: 'Active'
				and Name like : searchString ORDER BY Name LIMIT : numberOfClassesToShow];
		}
		else{
			return loadClasses();
		}	
	}
	
	public Map<String, Boolean> initializeApexClassIsSelectedMap(ApexClass [] classes){
		Map <String, Boolean> resultMap = new Map<String, Boolean>();
		for(ApexClass cl : classes){
			resultMap.put(cl.Id, false);	
		}
		return resultMap;
	}
	
	public List<ClassInspector> loadClassInspectors(){
		List<ClassInspector> inspectors = new List<ClassInspector>();
		for(String clName : aci_Utils.findClassNamesWhichImplementInterface(CLASS_INSPECTOR_INTERFACE)){
			inspectors.add((ClassInspector)Type.forName(clName).newInstance());
		}
		return inspectors;	
	}
	
	public Map<String, Boolean> initializeInspectorIsSelectedMap(ClassInspector [] classes){
		Map <String, Boolean> resultMap = new Map<String, Boolean>();
		for(ClassInspector cl : classes){
			//resultMap.put(cl, false);	
		}
		return resultMap;
	}
	
	public void applyFilter(){
		classes = loadClasses(searchByName);
		apexClassIsSelected = initializeApexClassIsSelectedMap(classes);	
	}
	
	public void inspectSelectedClasses(){
		classIdResult.clear();
		for(ApexClass cl : classes){
			if(apexClassIsSelected.get(cl.Id) == true){
				aci_Inspect_Result__c [] results = new List<aci_Inspect_Result__c>();
				for(ClassInspector ci : classInspectors){
					results.add(ci.inspectClass(cl));		
				}
				classIdResult.put(cl.Id, results);
			}
		}
		currentStep = 2;	
	}
	
	public void toFirstStep(){
		currentStep = 1;
	}
	
	public void toSecondStep(){
		currentStep = 2;
	}
}