public without sharing class DepartChildController {
    public Contact conObj{get;set;}
    static final string RT_DEPARTED = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Departed Participant').getRecordTypeId();
    public Boolean isDedicated {get; set;}
    public String contactID {get; set;}
    
    public DepartChildController(ApexPages.StandardController stdController){
        this.conObj = [Select id, Name, Departer_ID_Name__c, Departure_Reason__c, Departure_Reason_Detail__c,
                        Departure_Date__c, Departed__c, rC_Sponsorship__Sponsorship_Status__c, RecordTypeId,  
                        Community__r.Dedicated_to_Alliance__c,
                        // Queried below fields for T-479210 (Dheeraj)
                        Child_Number__c, rC_Bios__Gender__c, Community__c, Local_Partner__c, National_Office__c
                        FROM Contact where Id = :stdController.getId() limit 1];
        system.debug('----conObj---' + conObj);
        system.debug('----conObj1---' + conObj.Name);
        this.conObj.Departer_ID_Name__c = UserInfo.getUserId();
        contactID = this.conObj.Id;
        isDedicated = this.conObj.Community__r.Dedicated_to_Alliance__c != null ? true : false;
    }
    
    public PageReference departChild(){
        try {
            conObj.Departure_Date__c = system.Today();
            conObj.Departed__c = true;
            conObj.RecordTypeId = RT_DEPARTED;
            system.debug('----RT_DEPARTED---' + RT_DEPARTED);
            conObj.rC_Sponsorship__Sponsorship_Status__c = 'Departed';
            conObj.Sponsorship_Status_Reason__c = 'Reason A';
            update conObj;
            //String retURL = conObj.Id;
            system.debug('----retURL---' + conObj.Id);
            return (new PageReference('/'+conObj.Id));
        } catch(DmlException e) {
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, e.getDmlMessage(0))); // I-249369 - Modifed to handle only DML Exceptions
            system.debug('----exception---' + e + '-----' + e.getStackTraceString() + '-----' + e.getCause());
            return null;
        }
    }
}