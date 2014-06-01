/*
* Determines interface inspectors for triggers should implement to be detected by app.
*/
public interface aci_TriggerInspector {
	/*
	* Contains inspection logic.
	* @param triggerBody trigger body as string
	* @return aci_AnalysisResult inspection result 
	*/
	aci_AnalysisResult inspectTrigger(String triggerBody);
	
	/*
	* Returns name of inspector.
	*/
	String getName();
	
	/*
	* Returns description.
	*/
	String getDescription();
}