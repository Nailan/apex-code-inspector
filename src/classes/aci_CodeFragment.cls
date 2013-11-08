public without sharing class aci_CodeFragment {
	public String codeStr{set;get;}
	
	public aci_CodeFragment(){
		codeStr = '';
	}
	
	public String getCode(){
		return codeStr;
		//return codeStr.replaceAll('\n', '<br/>').replaceAll('\t', '&nbsp;&nbsp;&nbsp;&nbsp;').replaceAll(' ', '&nbsp;');
	}
	
	public Boolean getIsRendered(){
		return codeStr != null && codeStr.length() > 0;
	}
}