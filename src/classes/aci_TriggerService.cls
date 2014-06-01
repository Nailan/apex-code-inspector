/*
* Service class for Apex Triggers.
*/
public with sharing class aci_TriggerService implements aci_Singleton {
	private static aci_TriggerService service;
	
	private aci_TriggerService() {
	}
	
	public static aci_TriggerService getInstance() {
		if (service == null) {
			service = new aci_TriggerService();
		}
		return service;	
	}
	
	public List<ApexTrigger> loadTriggers(Integer numberOfItems) {
		return [select id, Body, Name 
				from ApexTrigger 
				where Status =: 'Active' ORDER BY Name LIMIT : numberOfItems];
	}
	
	public List<ApexTrigger> loadTriggers(String searchString, Integer numberOfItems){ 
		if(searchString != null) {
			searchString = '%' + searchString + '%';
			return [select id, Body, Name from ApexTrigger  
					where Status =: 'Active'
					and Name like : searchString ORDER BY Name LIMIT : numberOfItems];
		}
		else {
			return loadTriggers(numberOfItems);
		}	
	}
}