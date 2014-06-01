/*
* Service class for Apex classes.
*/
public with sharing class aci_ClassService implements aci_Singleton {
	private static aci_ClassService service;
	
	private aci_ClassService() {
	}
	
	public static aci_ClassService getInstance() {
		if (service == null) {
			service = new aci_ClassService();
		}
		return service;	
	}
	
	public List<ApexClass> loadClasses(Integer numberOfItems) {
		return [select id, Body, Name 
				from ApexClass 
				where Status =: 'Active' ORDER BY Name LIMIT : numberOfItems];
	}
	
	public List<ApexClass> loadClasses(String searchString, Integer numberOfItems) {
		if(searchString != null){
			searchString = '%' + searchString + '%';
			return [select id, Body, Name from ApexClass  
					where Status =: 'Active'
					and Name like : searchString ORDER BY Name LIMIT : numberOfItems];
		}
		else {
			return loadClasses(numberOfItems);
		}	
	}
}