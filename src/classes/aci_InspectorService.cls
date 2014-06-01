/*
* Service class for ACI inspector classes.
*/
public with sharing class aci_InspectorService {
	public static final String CLASS_INSPECTOR_INTERFACE = 'aci_ClassInspector';
	public static final String TRIGGER_INSPECTOR_INTERFACE = 'aci_TriggerInspector';
	
	private static aci_InspectorService service;
	
	private aci_InspectorService() {
	}
	
	public static aci_InspectorService getInstance() {
		if (service == null) {
			service = new aci_InspectorService();
		}
		return service;	
	}
	
	public List<String> findClassInspectorNames() {
		return aci_ReflectionApiExt.findClassNamesWhichImplementInterface(CLASS_INSPECTOR_INTERFACE);
	}
	
	public List<String> findTriggerInspectorNames() {
		return aci_ReflectionApiExt.findClassNamesWhichImplementInterface(TRIGGER_INSPECTOR_INTERFACE);
	}

}