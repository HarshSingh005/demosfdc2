/*
 * Class        : CaseModel
 * Developer/Org: Krishna Krupal/Bluewolf
 * Created      : Feb 3, 2014
 * Objective    : Model class for the Case object. Any DML on Case or SOQL queries to retrieve child objects should be done in this class. 
*/

public with sharing class CaseModel {
    
    //Properties
    public Case caseRecord{get;set;}
    public Contact contact{get; private set;} 
    public List<Case> relatedCases{get;set;}
    
    private Map<String, Id> caseRecordTypes;
        
    //Constructor
    public CaseModel(Case caseRecord){
        this.caseRecord = caseRecord;
    }
    
    /**
     * Initialize the Case
     * @parm 
     * @return void
    */  
    public void initializeCase(Id contactId, Id accountId, Id recordTypeId){
        caseRecord.ContactId = contactId;
        if(contactId != null){
            caseRecord.AccountId = accountId;
        }else{
            caseRecord.Organization_Name__c = accountId;    
        }
        //caseRecord.AccountId = accountId;
        caseRecord.RecordTypeId = recordTypeId;
        caseRecord.Origin = 'Phone';
    }
    
    /**
     * Refresh Master Case
     * @parm 
     * @return void
    */
    private void refreshMasterCase(){
        caseRecord = [SELECT ContactId, AccountId, Status, Priority, Priority_Reason__c, Origin, Subject, Description, Preferred_Method_of_Response__c, Organization_Name__c, RecordType.DeveloperName
                        FROM Case WHERE Id =: caseRecord.Id];
    }
    
    /**
     * Get Related Cases
     * @parm 
     * @return void
    */
    public void getRelatedCases(){ 
        //Get all the fields from the Related Cases' Field Sets
        String queryStr = 'SELECT Id, CaseNumber, Subject, Related_Case_Record_Type__c ';
        Set<String> relatedCaseFields = CaseService.getCaseFieldsFromFieldSets();
        for(String fieldName : relatedCaseFields){
            queryStr += ', ' + fieldName;   
        }
        queryStr += ' FROM Case WHERE Master_Case__c = \'' + caseRecord.Id + '\'';
        relatedCases = Database.query(queryStr);
    }
    
    /**
     * Save the Case
     * @parm 
     * @return void
    */
    public void save(){
        try{
            upsert caseRecord;
        }catch(DMLException dmlEx){
            throw new ChildFundException.CustomDMLException('There was an error saving the Case. ' + dmlEx.getMessage());
        }
    }
    
    /**
     * Save Related Case
     * @parm 
     * @return void
    */
    public void saveRelatedCase(Case relatedCase){
        try{
            //If the Use Assignment Rule checkbox is checked, set the option on the Case
            if(relatedCase.Use_Case_Assignment_Rules__c)
                relatedCase.setOptions(CaseService.defaultAssignmentDBOptions);
            upsert relatedCase;
        }catch(DMLException dmlEx){
            throw new ChildFundException.CustomDMLException('There was an error saving the Case. ' + dmlEx.getMessage());
        }
        //Refresh the Master Case
        refreshMasterCase();
        //Refresh the Related Cases
        getRelatedCases();
    }
    
    /**
     * Delete Related Case
     * @parm 
     * @return void
    */
    public void deleteRelatedCase(Id relatedCaseId){
        try{
            delete new Case(Id = relatedCaseId);
        }catch(DMLException dmlEx){
            throw new ChildFundException.CustomDMLException('There was an error deleting the Case. ' + dmlEx.getMessage());
        }
        //Refresh the Related Cases     
        getRelatedCases();
    }
    
    /**
     * Get Record Types for Case
     * @parm 
     * @return Map<String, Id>  Record Type Name <==> Record Type Id
    */
    public Map<String, Id> getRecTypesForCase(){
        if(caseRecordTypes == null){
            caseRecordTypes = SObjectServices.getRecordNameIdMap(Schema.SObjectType.Case);
        }
        return caseRecordTypes; 
    }
    
    /**
     * Add Related Case
     * @parm String recType 
     * @return Case
    */
    public Case addRelatedCase(String recType){
        Case relatedCase = new Case(Related_Case_Record_Type__c = recType);
        //populate Related Case from Master Case
        pullMasterInfoToRelatedCase(relatedCase);
        return relatedCase;
    }
    
    /**
     * Edit Related Case
     * @parm String relatedCaseId 
     * @return Case
    */
    public Case editRelatedCase(String relatedCaseId){
        getRelatedCases();
        Case relatedCase;
        //Iterate through the related cases to find the one that is being edited
        for(Case c : relatedCases){
            if(c.Id == relatedCaseId){
                relatedCase = c; 
            }
        }
        return relatedCase;
    }
    
    /**
     * Populate Related Case from Master Case
     * @parm Case relatedCase 
     * @return void
    */
    private void pullMasterInfoToRelatedCase(Case relatedCase){
        relatedCase.Master_Case__c = caseRecord.Id;
        relatedCase.RecordTypeId = getRecTypesForCase().get(relatedCase.Related_Case_Record_Type__c);
        relatedCase.ContactId = caseRecord.ContactId;
        relatedCase.AccountId = caseRecord.AccountId;
        relatedCase.Priority = caseRecord.Priority;
        relatedCase.Priority_Reason__c = caseRecord.Priority_Reason__c;
        relatedCase.Origin = caseRecord.Origin;
        relatedCase.Organization_Name__c = caseRecord.Organization_Name__c;
        
        //if(relatedCase.Related_Case_Record_Type__c == Constants.CASE_REC_TYPE_SIMPLE){
        //  relatedCase.Status = 'Closed';
        //}else 
        if(relatedCase.Related_Case_Record_Type__c == Constants.CASE_REC_TYPE_STANDARD){
            relatedCase.Preferred_Method_of_Response__c = caseRecord.Preferred_Method_of_Response__c;
            relatedCase.Use_Case_Assignment_Rules__c = false;
            relatedCase.Status = 'Closed';
            relatedCase.OwnerId = UserInfo.getUserId();
        }else if(relatedCase.Related_Case_Record_Type__c == Constants.CASE_REC_TYPE_NO){
            relatedCase.Preferred_Method_of_Response__c = caseRecord.Preferred_Method_of_Response__c;
            //relatedCase.Organization_Name__c = caseRecord.Organization_Name__c;
            relatedCase.Use_Case_Assignment_Rules__c = true;
            relatedCase.Status = 'Pending - National Office';
            relatedCase.OwnerId = UserInfo.getUserId();
        }else if(relatedCase.Related_Case_Record_Type__c == Constants.CASE_REC_TYPE_CHILD_INQ){
            relatedCase.Use_Case_Assignment_Rules__c = true;
            relatedCase.Status = 'Pending - National Office';
            relatedCase.OwnerId = UserInfo.getUserId();
        }
    }   
}