/*
 * Class        : CustomLookupController
 * Developer/Org: Krishna Krupal/Bluewolf
 * Created      : Aug 26, 2013
 * Objective    : Controller for custom lookup on VF page
*/
public with sharing class CustomLookupController {
	
	private String sObjName;
	private String fieldId;
	private String hiddenFldId;
	
	//Constructor
	public CustomLookupController(){
		sObjName = ApexPages.currentPage().getParameters().get('lookupType');
		fieldId = ApexPages.currentPage().getParameters().get('fieldId');
		hiddenFldId = ApexPages.currentPage().getParameters().get('hiddenFldId');
	}
	
	/**
     * Get the URL parmeters from the VF page and redirect based on Object type  
     * @parm 
     * @return PageReference
    */
	public PageReference redirectToLookupPage(){
		PageReference pRef;
        System.debug('Ashu>>>SOBJECT @@@'+sObjName);
		if(sObjName == 'Account'){
			pRef = Page.AccountLookupPage;
		}
		if(pRef != null){
			pRef.getParameters().put('fieldId', fieldId);
            System.debug('Ashu>>>fieldId @@@'+fieldId);
			pRef.getParameters().put('hiddenFldId', hiddenFldId);
            System.debug('Ashu>>>hiddenFldId @@@'+hiddenFldId);
		}
		return pRef;
	}
}