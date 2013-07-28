public with sharing class aci_ApexCodeInspector {
	public static final String CLASS_INSPECTOR_INTERFACE = 'aci_ApexCodeInspector.ClassInspector';
	public static final String TRIGGER_INSPECTOR_INTERFACE = 'aci_ApexCodeInspector.TriggerInspector';
	
	public ApexClass [] classes{get;set;}
	public Map<String, Boolean> apexClassIsSelected {get;set;}
	public ApexTrigger [] triggers{get;set;}
	public Map<String, Boolean> triggerIsSelected {get;set;}
	public Integer numberOfItemsToShow {get;set;}
	public String searchByName{get;set;}
	public Map<String, aci_Inspect_Result__c[]> classIdResult{get;set;}
	public Map<String, aci_Inspect_Result__c[]> triggerIdResult{get;set;}
	public Integer currentStep{get;set;}
	public String mode{get;set;}
	public List<InspectorWrapper> classInspectors{get;set;}
	public List<InspectorWrapper> triggerInspectors{get;set;}
	
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
	
	public class InspectorWrapper{
		public ClassInspector classInspector{get;set;}
		public TriggerInspector triggerInspector{get;set;}
		public Boolean isSelected{get;set;}
		
		public InspectorWrapper(ClassInspector clIn){
			this.classInspector = clIn;
		}
		public InspectorWrapper(TriggerInspector trIn){
			this.triggerInspector = trIn;
		}
	}
	
	public aci_ApexCodeInspector(){
		initialize();
	}
	
	public void initialize(){
		classIdResult = new Map<String, aci_Inspect_Result__c[]>();
		numberOfItemsToShow = 100;
		currentStep = 1;
		loadClasses();
		initializeApexClassIsSelectedMap(classes);
		loadClassInspectors();
		mode = 'class_inspecting';
	}
	
	public void loadClasses(){
		classes = [select id, Body, Name 
				from ApexClass 
				where Status =: 'Active' ORDER BY Name LIMIT : numberOfItemsToShow];
	}
	
	public void loadClasses(String searchString){
		if(searchString != null){
		searchString = '%' + searchString + '%';
		classes = [select id, Body, Name from ApexClass  
				where Status =: 'Active'
				and Name like : searchString ORDER BY Name LIMIT : numberOfItemsToShow];
		}
		else{
			loadClasses();
		}	
	}
	
	public void initializeApexClassIsSelectedMap(ApexClass [] classes){
		apexClassIsSelected = new Map<String, Boolean>();
		for(ApexClass cl : classes){
			apexClassIsSelected.put(cl.Id, false);	
		}
	}
	
	public void loadClassInspectors(){
		classInspectors = new List<InspectorWrapper>();
		for(String clName : aci_Utils.findClassNamesWhichImplementInterface(CLASS_INSPECTOR_INTERFACE)){
			try{
				classInspectors.add(new InspectorWrapper((ClassInspector)Type.forName(clName).newInstance()));
			}
			catch(Exception e){
				ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Error occured due loading ' + clName + ' ' + e.getMessage()));
			}
		}
	}
	
	public void applyFilter(){
		loadClasses(searchByName);
		initializeApexClassIsSelectedMap(classes);	
	}
	
	public void inspectSelectedClasses(){
		classIdResult.clear();
		for(ApexClass cl : classes){
			if(apexClassIsSelected.get(cl.Id) == true){
				aci_Inspect_Result__c [] results = new List<aci_Inspect_Result__c>();
				for(InspectorWrapper ci : classInspectors){
					if(ci.isSelected)
						results.add(ci.classInspector.inspectClass(cl));		
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