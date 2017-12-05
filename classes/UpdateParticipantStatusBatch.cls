/***********************************************************************************************************
 * Appirio, Inc
 * Name         : UpdateParticipantStatusBatch
 * Created By   : Karl Houseknecht (Appirio)
 * Purpose      : Batch job to update Participant status based on materials date
 * Created Date : 01/22/2016
 *
 * Date Modified                Modified By             Description of the update
  ----------------------------------------------------------------------------------------------------------
 * 01/22/2016                   Karl Houseknecht        Created
 * 01/25/2016                   Karl Houseknecht        Added Schedulable interface
 **********************************************************************************************************/
global class UpdateParticipantStatusBatch implements Database.Batchable<sObject>, Schedulable
{
    global void execute(SchedulableContext SC) 
    {
        UpdateParticipantStatusBatch batch = new UpdateParticipantStatusBatch();
        database.executeBatch(batch);
    }

    global Database.QueryLocator start(Database.BatchableContext BC)
    {
        Database.QueryLocator locator;
        Id childRecTypeId = 
            Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Participant').getRecordTypeId();
        
        locator = database.getQueryLocator([select id,
                                            rC_Sponsorship__Sponsorship_Status__c,
                                            Participant_Materials_Approved_Date__c,
                                            rC_Bios__Age__c
                                            from contact 
                                            where (RecordTypeId = :childRecTypeId) AND
                                            (rC_Sponsorship__Sponsorship_Status__c = 'Available')]);
        
        return locator;
    }
    
    global void execute(Database.BatchableContext BC, List<sObject> scope)
    {
        List<Contact> childrenToUpdate = new List<Contact>();
        
        for(sobject s : scope)
        {
            Contact child = (Contact)s;
            if(child.Participant_Materials_Approved_Date__c != null) {
                date twoYearsFromApprovalDate = child.Participant_Materials_Approved_Date__c.addYears(2);
                date eighteenMonthsFromApprovalDate = child.Participant_Materials_Approved_Date__c.addMonths(18);
                
                //if the child's age is 5 or older and the materials approval date is older than 2 years, or
                //if the child's age is less than 5 and the materials approval date is older than 18 months
                //then update the sponsorship status to unavailable
                if(((child.rC_Bios__Age__c >= 5) && (date.today() >= twoYearsFromApprovalDate)) ||
                   ((child.rC_Bios__Age__c < 5) && (date.today() >= eighteenMonthsFromApprovalDate)))
                {
                    child.rC_Sponsorship__Sponsorship_Status__c = 'Unavailable';
                    child.Sponsorship_Status_Reason__c = 'Child Materials Expired';
                    childrenToUpdate.add(child);
                }
            }
        }
        
        if(childrenToUpdate.size() > 0)
            update childrenToUpdate;
    }
    
    global void finish(Database.BatchableContext BC)
    {
    }
}