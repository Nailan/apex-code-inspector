public with sharing class aci_ApexCodeInspector {
	public static final String CLASS_INSPECTOR_INTERFACE = 'aci_ApexCodeInspector.ClassInspector';
	public static final String TRIGGER_INSPECTOR_INTERFACE = 'aci_ApexCodeInspector.TriggerInspector';
	
	public ApexClass [] classes{get;set;}
	public Map<String, Boolean> apexClassIsSelected {get;set;}
	public ApexTrigger [] triggers{get;set;}
	public Map<String, Boolean> apexTriggerIsSelected {get;set;}
	public Integer numberOfItemsToShow {get;set;}
	public String searchByName{get;set;}
	public Map<String, AnalysisResult[]> itemNameResultMap{get;set;}
	public Integer currentStep{get;set;}
	public String mode{get;set;}//class_inspecting, trigger_inspecting
	public String modeInFilter{get;set;}
	public List<InspectorWrapper> classInspectors{get;set;}
	public List<InspectorWrapper> triggerInspectors{get;set;}
	public Boolean saved {get;set;}
	public Integer currentItemNumber{get;set;}
	public boolean isSaved{get;set;}
	private List<String> errorsDuringInspecting;
	
	public interface ClassInspector{
		AnalysisResult inspectClass(String classBody);
		String getName();
		String getDescription();
	}
	
	public interface TriggerInspector{
		AnalysisResult inspectTrigger(String triggerBody);
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
		mode = 'class_inspecting';
		saved = false;
		initialize();
	}
	
	public void initialize(){
		currentItemNumber = 0;
		itemNameResultMap = new Map<String, AnalysisResult[]>();
		numberOfItemsToShow = 100;
		currentStep = 1;
		if(mode == 'class_inspecting'){
			loadClasses();
			initializeApexClassIsSelectedMap();
		}
		else{
			loadTriggers();
			initializeApexTriggerIsSelectedmap();
		}
	}
	
	public void loadClasses(){
		classes = [select id, Body, Name 
				from ApexClass 
				where Status =: 'Active' ORDER BY Name LIMIT : numberOfItemsToShow];
	}
	
	public void loadTriggers(){
		triggers = [select id, Body, Name 
				from ApexTrigger 
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
	
	public void loadTriggers(String searchString){
		if(searchString != null){
		searchString = '%' + searchString + '%';
		triggers = [select id, Body, Name from ApexTrigger  
				where Status =: 'Active'
				and Name like : searchString ORDER BY Name LIMIT : numberOfItemsToShow];
		}
		else{
			loadTriggers();
		}	
	}
	
	public void initializeApexClassIsSelectedMap(){
		apexClassIsSelected = initItemIsSelectedMap(classes);
	}
	
	public void initializeApexTriggerIsSelectedMap(){
		apexTriggerIsSelected = initItemIsSelectedMap(triggers);
	}
	
	public Map<String, boolean> initItemIsSelectedMap(sObject [] objs){
		Map<String, boolean> resMap = new Map<String, Boolean>();
		for(sObject o : objs){
			resmap.put(o.Id, false);
		}
		return resMap;
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
	
	public void loadTriggerInspectors(){
		triggerInspectors = new List<InspectorWrapper>();
		for(String clName : aci_Utils.findClassNamesWhichImplementInterface(TRIGGER_INSPECTOR_INTERFACE)){
			try{
				triggerInspectors.add(new InspectorWrapper((TriggerInspector)Type.forName(clName).newInstance()));
			}
			catch(Exception e){
				ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Error occured due loading ' + clName + ' ' + e.getMessage()));
			}
		}
	}
	
	public void applyFilter(){
		mode = modeInFilter;
		if(mode == 'class_inspecting'){
			loadClasses(searchByName);
			initializeApexClassIsSelectedMap();
		}
		else{
			loadTriggers(searchByName);
			initializeApexTriggerIsSelectedmap();
		}
	}
	
	public void startInspecting(){
		errorsDuringInspecting = new List<String>();
		currentItemNumber = 0;
		itemNameResultMap.clear();
		isSaved = false;
		if(mode == 'class_inspecting'){
			if(!checkIfInspectorSelected(classInspectors)){
				ApexPages.addMessage(new ApexPages.message(ApexPages.severity.INFO,'Please select Inspectors to analyze the classes'));
				return;	
			}
		}
		else{
			if(!checkIfInspectorSelected(triggerInspectors)){
				ApexPages.addMessage(new ApexPages.message(ApexPages.severity.INFO,'Please select Inspectors to analyze the triggers'));
				return;	
			}
		}
	}
	
	public void inspectNextItem(){
		if(mode == 'class_inspecting'){
			inspectNextClass();
		}
		else{
			inspectNextTrigger();
		}
	}
	
	public void inspectNextClass(){
		Integer nextIndex = getNextItemToInspect();
		if(nextIndex == null){
			return;
		}
		ApexClass cl = classes.get(nextIndex);
		AnalysisResult [] results = new List<AnalysisResult>();
		for(InspectorWrapper ci : classInspectors){
			if(ci.isSelected){
				try{
					system.debug('######## inspecting ' + cl.Name + ' with ' + ci.classInspector.getName());
					AnalysisResult res = ci.classInspector.inspectClass(cl.Body);
					res.setInspectorName(ci.classInspector.getName());
					res.setItemName(cl.Name);
					results.add(res);
					system.debug('######## status=' + res.getStatus());
				}
				catch(Exception e){
					errorsDuringInspecting.add('An error occured during inspecting ' + cl.Name + ' by ' + ci.classInspector.getName()
											 + ' ' + e.getMessage() + '. Stack Trace:' + e.getStackTraceString());
				}
			}	
		}
		itemNameResultMap.put(cl.Name, results);
		currentItemNumber ++;
	}
	
	public void inspectNextTrigger(){
		Integer nextIndex = getNextItemToInspect();
		if(nextIndex == null){
			return;
		}
		ApexTrigger tr = triggers.get(nextIndex);
		AnalysisResult [] results = new List<AnalysisResult>();
		for(InspectorWrapper ci : triggerInspectors){
			if(ci.isSelected){
				try{
					AnalysisResult res = ci.triggerInspector.inspectTrigger(tr.Body);
					res.setInspectorName(ci.triggerInspector.getName());
					res.setItemName(tr.Name);
					results.add(res);
				}
				catch(Exception e){
					errorsDuringInspecting.add('An error occured during inspecting ' + tr.Name + ' by ' + ci.triggerInspector.getName() 
											+ ' ' + e.getMessage() + '. Stack Trace:' + e.getStackTraceString());
				}
			}	
		}
		itemNameResultMap.put(tr.Name, results);
		currentItemNumber ++;
	}
	
	public void finishInspecting(){
		currentStep = 3;
		for(String m: errorsDuringInspecting)
			ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, m));
	}
	
	public List<String> getItemNames(){
		List<String> names = new List<String>();
		names.addAll(itemNameResultMap.keyset());
		return names;
	}
	
	private static boolean checkIfSmthInMapSelected(Map<String, boolean> m){
		for(boolean b : m.values()){
			if(b)
				return true;
		}
		return false;	
	}
	
	private static boolean checkIfInspectorSelected(InspectorWrapper [] iws){
		for(InspectorWrapper iw: iws){
			if(iw.IsSelected){
				return true;
			}
		}
		return false;
	}
	
	public boolean getIsAnalyzingWithoutErrors(){
		return errorsDuringInspecting.size() == 0;
	}
	
	public void saveResults(){
		AnalysisExecution ex = new AnalysisExecution();
		ex.setExecutionTime(system.now());
		ex.setExecutedById(UserInfo.getUserId());
		List<AnalysisResult> ress = new List<AnalysisResult>();
		for(List<AnalysisResult> rl: itemNameResultMap.values()){
			for(AnalysisResult r: rl){
				ress.add(r);
			}
		}
		ex.setResults(ress);
		isSaved = true;
		try{
			ex.save();
			ApexPages.addMessage(new ApexPages.message(ApexPages.severity.CONFIRM, 'Saved'));
		}
		catch(Exception e){
			ApexPages.addMessage(new ApexPages.message(ApexPages.severity.WARNING, 'Cannot be saved: ' + e.getMessage() + '. Stack Trace:' + e.getStackTraceString()));	
		}
	}
	
	public Pagereference toHistory(){
		return new Pagereference('/apex/aci_History');
	}
	
	public Integer getItemsToInspectSize(){
		Integer rem = 0;
		if(mode == 'class_inspecting'){
			for(String s: apexClassIsSelected.keyset()){
				if(apexClassIsSelected.get(s) == true){
					rem ++;
				}
			}
		}
		if(mode == 'trigger_inspecting'){
			for(String s: apexTriggerIsSelected.keyset()){
				if(apexTriggerIsSelected.get(s) == true){
					rem ++;
				}
			}	
		}
		return rem;
	}
	
	public Integer getNextItemToInspect(){
		Integer itemNumber = 0;
		Integer retIndex = null;
		if(mode == 'class_inspecting'){
			for(Integer i = 0; i < classes.size(); i ++){
				ApexClass cl = classes.get(i);
				if(apexClassIsSelected.get(cl.Id) == true){
					if(itemNumber == currentItemNumber){
						retIndex = i;
						break;	
					}
					itemNumber ++;
				}	
			}
		}
		else{
			for(Integer i = 0; i < triggers.size(); i ++){
				ApexTrigger tr = triggers.get(i);
				if(apexTriggerIsSelected.get(tr.Id) == true){
					if(itemNumber == currentItemNumber){
						retIndex = i;
						break;	
					}
					itemNumber ++;		
				}	
			}	
		}
		return retIndex;
	}
		
	public void toFirstStep(){
		currentStep = 1;
	}
	
	public void toSecondStep(){
		if(mode == 'class_inspecting'){
			if(!checkIfSmthInMapSelected(apexClassIsSelected)){
				ApexPages.addMessage(new ApexPages.message(ApexPages.severity.INFO,'Please select at least one class for analysis'));
				return;	
			}
			loadClassInspectors();
		}
		else{
			if(!checkIfSmthInMapSelected(apexTriggerIsSelected)){
				ApexPages.addMessage(new ApexPages.message(ApexPages.severity.INFO,'Please select at least one trigger for analysis'));
				return;	
			}
			loadtriggerinspectors();
		}
		currentStep = 2;
	}
}