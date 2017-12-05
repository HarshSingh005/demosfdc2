/*
 * Class        : CaseControllerExt
 * Developer/Org: Krishna Krupal/Bluewolf
 * Created      : Feb 3, 2014
 * Objective    : Controller Extension for the Case creation wizard
*/

public with sharing class CaseControllerExt {
        
        //Properties
        public CaseModel masterCase{get;set;} 
        public Boolean displayOverlay {get; set;}
        public Case relatedCase{get;set;}
        private Id contactId;
        private Id accountId;
        public String caseIdtoDel{get;set;}
	    public String caseIdtoEdit{get;set;}
        public String relatedCaseError{get; private set;}
        public Boolean isEditOp{get;set;}
    	public String pageMessage{get; private set;}
        public String pageMessageSeverity{get; private set;}
        public String routedCasePageMessage{get; private set;}
            
        //Fields on the Master Case that we need access to. Helps avoid using a SOQL
        private static List<String> caseFields = new List<String>{'ContactId', 'AccountId', 'Status', 'Priority', 'Priority_Reason__c', 'Origin', 'Subject', 'Description', 
                                                                                                                                 'Preferred_Method_of_Response__c', 'Organization_Name__c', 'RecordType.DeveloperName'};                                        
        
        //Reference to this Controller Extension.
        public CaseControllerExt thisCon{
            get{
                return this;
            } 
            private set;
        }     
        
        //Get Master Case Record Type
        public Id masterCaseRecType{
            get{
                if(masterCaseRecType == null){
					RecordType recType = SObjectServices.getRecordType(Constants.CASE_REC_TYPE_MASTER, 'Case');
                    if(recType != null)
                    	masterCaseRecType = recType.Id;
                }
                return masterCaseRecType;       
            }
            private set;
        }
        
        public Case routedCase{get;set;}
        
        //Constructor
		public CaseControllerExt(ApexPages.StandardController stdCon){
                if(!Test.isRunningTest()){
                        //Add all fields that we need for the Master Case
                        stdCon.addFields(caseFields);
                }
                //Initialize the Master Case Record
                masterCase = new CaseModel((Case)stdCon.getRecord());
    	}
        
        /**
     * Initialize the Controller Extension. Called from action on CaseWizard VF page
     * @parm 
     * @return PageReference
    */
        public PageReference init(){
            if(masterCase.caseRecord == null || String.isBlank(masterCase.caseRecord.Id)){
                //This is a New Case
	            masterCase = new CaseModel(new Case());
	            contactId = Apexpages.currentPage().getParameters().get(Constants.CONTACT_URL_PARM);
	            accountId = Apexpages.currentPage().getParameters().get(Constants.ACCOUNT_URL_PARM);
	            masterCase.initializeCase(contactId, accountId, masterCaseRecType);
	        }else if(masterCase.caseRecord.RecordType.DeveloperName != Constants.CASE_REC_TYPE_MASTER){
                //Edit Case. If the Case being edited is not a master case, redirect to the standard edit page 
                PageReference pRef = new ApexPages.StandardController(masterCase.caseRecord).edit();
                pRef.getParameters().put(Constants.RETURN_URL, masterCase.caseRecord.Id);
                pRef.getParameters().put(Constants.NO_OVERRIDE, '1');
                        return pRef;
            }else{//get the related cases for the master case       
                masterCase.getRelatedCases();
                routedCase = masterCase.addRelatedCase(Constants.CASE_REC_TYPE_STANDARD);
        	}
        	return null;
        }
        
        /**
     * Save the Master Case
     * @parm 
     * @return PageReference
    */    
    public PageReference saveMasterCase(){
        try{
            masterCase.save();
            pageMessage = 'Case is saved';
            pageMessageSeverity = 'info';
            routedCase = masterCase.addRelatedCase(Constants.CASE_REC_TYPE_STANDARD);
            //ApexPages.addMessage(new ApexPages.message(ApexPages.severity.INFO, 'Case is saved'));
        }catch(ChildFundException.CustomDMLException ce){
        	pageMessage = ce.getMessage();
            pageMessageSeverity = 'error';
            //ApexPages.addMessage(new ApexPages.message(ApexPages.severity.FATAL, ce.getMessage()));
        }
        return null;
    }
    
    /**
     * Add Related Case
     * @parm 
     * @return PageReference
    */
    public PageReference addCase(){
        relatedCase = masterCase.addRelatedCase(Constants.CASE_REC_TYPE_NO);
        displayOverlay = true;
        isEditOp = false;
        return null;
    }
    
    /**
     * Edit Related Case
     * @parm 
     * @return PageReference
    */
    public PageReference editRelatedCase(){
        relatedCase = masterCase.editRelatedCase(caseIdToEdit);
        displayOverlay = true;
        isEditOp = true;
        return null;
    }
    
    /**
     * Refresh the Field Set on Record Type Selection
     * @parm 
     * @return PageReference
    */
    public PageReference setRecordTypeAndRefresh(){
                relatedCase = masterCase.addRelatedCase(relatedCase.Related_Case_Record_Type__c);
                relatedCaseError = null;        
        return null;
    }
    
    /**
     * Close the Overlay section
     * @parm 
     * @return PageReference
    */
    public PageReference closeOverlay() {        
        displayOverlay = false;
        relatedCaseError = null;
        return null;    
    }
    
    /**
     * Save the Related Case
     * @parm 
     * @return PageReference
    */
    public PageReference saveRelatedCase(){ 
        try{
            masterCase.saveRelatedCase(relatedCase);
            displayOverlay = false;
            relatedCaseError = null;
        }catch(ChildFundException.CustomDMLException cfe){
            relatedCaseError = cfe.getMessage();
        }
        return null;
    }
        
    /**
     * Save the Routed Case
     * @parm 
     * @return PageReference
    */
    public PageReference saveRoutedCase(){ 
        try{
            masterCase.saveRelatedCase(routedCase);
			routedCase = masterCase.addRelatedCase(Constants.CASE_REC_TYPE_STANDARD);
			routedCasePageMessage = null;
        }catch(ChildFundException.CustomDMLException cfe){
            //ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, cfe.getMessage()));
            routedCasePageMessage = cfe.getMessage();
        }
        return null;
    }
    
    /**
     * Delete Related Case
     * @parm 
     * @return PageReference
    */
        public void deleteRelatedCase(){
        masterCase.deleteRelatedCase(caseIdToDel);
    }
        
        /**
     * Return control to Case/Contact page
     * @parm 
     * @return PageReference
    */    
    public PageReference cancel(){
                if(masterCase.caseRecord.Id != null){
                    return new PageReference('/'+masterCase.caseRecord.Id);
                }else if(contactId != null){
                    return new PageReference('/'+contactId);
                }else if(accountId != null){
                	return new PageReference('/'+accountId);
                }else{
                    return new PageReference(Constants.CASE_TAB);
                }       
    } 
}