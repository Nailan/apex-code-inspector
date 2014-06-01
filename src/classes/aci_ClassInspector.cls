/*
* Determines interface inspectors for classes should implement to be detected by app.
*/
public interface aci_ClassInspector {
	/*
	* Contains inspection logic.
	* @param classBody class body as string
	* @return aci_AnalysisResult inspection result 
	*/
	aci_AnalysisResult inspectClass(String classBody);
	
	/*
	* Returns name of inspector.
	*/
	String getName();
	
	/*
	* Returns description.
	*/
	String getDescription();
}