/**
 * @author Pavel Demeshchik
 *
 * Controller for aci_CodeFragment.component
 */
public without sharing class aci_CodeFragment {
	public String codeStr{set;get;}
	
	public aci_CodeFragment() {
		codeStr = '';
	}
	
	public String getCode() {
		return codeStr;
	}
	
	public Boolean getIsRendered() {
		return codeStr != null && codeStr.length() > 0;
	}
}