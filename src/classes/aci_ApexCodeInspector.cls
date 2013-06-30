public with sharing class aci_ApexCodeInspector {
	public Map<String, Boolean> apexClassIsSelected {get;set;}
	public ApexClass [] classes{get;set;}
	public Integer numberOfClassesToShow {get;set;}
	public String searchByName{get;set;}
	public Inspectresult[] results{get;set;}
	public Integer currentStep{get;set;}
	public List<ClassInspector> classInspectors{get;set;}
	public List<TriggerInspector> triggerInspectors{get;set;}
	
	public class InspectResult{
		public String status{get;set;}
		public String errors{get;set;}
		public String apexClassName{get;set;}
	}
	
	public interface ClassInspector{
		InspectResult inspectClass(ApexClass cl);
	}
	
	public interface TriggerInspector{
		InspectResult inspectTrigger(ApexTrigger cl);
	}
	
	public aci_ApexCodeInspector(){
		initialize();
	}
	
	public void initialize(){
		results = new List<InspectResult>();
		numberOfClassesToShow = 100;
		currentStep = 1;
		classes = loadClasses();
		apexClassIsSelected = initializeApexClassIsSelected(classes);
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
	
	public Map<String, Boolean> initializeApexClassIsSelected(ApexClass [] classes){
		Map <String, Boolean> resultMap = new Map<String, Boolean>();
		for(ApexClass cl : classes){
			resultMap.put(cl.Id, false);	
		}
		return resultMap;
	}
	
	public void applyFilter(){
		classes = loadClasses(searchByName);
		apexClassIsSelected = initializeApexClassIsSelected(classes);	
	}
	
	public void inspectSelectedClasses(){
		results.clear();
		for(ApexClass cl : classes){
			if(apexClassIsSelected.get(cl.Id) == true){
				for(ClassInspector ci : classInspectors){
					results.add(ci.inspectClass(cl));		
				}	
			}
		}
		currentStep = 2;	
	}
	
	public void back(){
		currentStep = 1;
	}
	
	public class SOQLInLoopsInspector implements ClassInspector{
		public InspectResult inspectClass(ApexClass cl){
			InspectResult result = new InspectResult();
			
			return result;	
		}	
	}
	
}