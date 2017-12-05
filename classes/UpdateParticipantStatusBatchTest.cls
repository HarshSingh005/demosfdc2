/***********************************************************************************************************
 * Appirio, Inc
 * Name         : UpdateParticipantStatusBatchTest
 * Created By   : Karl Houseknecht (Appirio)
 * Purpose      : Test class for Batch job to update Participant status based on materials date
 * Created Date : 01/22/2016
 *
 * Date Modified                Modified By             Description of the update
  ----------------------------------------------------------------------------------------------------------
 * 01/22/2016					Karl Houseknecht		Created
 **********************************************************************************************************/
@isTest
public class UpdateParticipantStatusBatchTest 
{
    @isTest
	public static void UpdateParticipantStatusTest() {
        Id childRecTypeId = 
            Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Participant').getRecordTypeId();
        
        //6 year old child - will be updated
        Contact child6 = new Contact();
        child6.FirstName = 'joe';
        child6.LastName = 'six';
        child6.RecordTypeId = childRecTypeId;
        child6.Participant_Case_Number__c = '14576';
        child6.rC_Sponsorship__Sponsorship_Status__c = 'Available';
        child6.Participant_Materials_Approved_Date__c = date.today().addYears(-3);
        date sixYearsAgo = date.today().addYears(-6);
        child6.rC_Bios__Birth_Day__c = string.valueOf(sixYearsAgo.day());
        child6.rC_Bios__Birth_Month__c = string.valueOf(sixYearsAgo.month());
        child6.rC_Bios__Birth_Year__c = string.valueOf(sixYearsAgo.year());
        insert child6;
        
        //4 year old child - will be updated
        Contact child4 = new Contact();
        child4.FirstName = 'joe';
        child4.LastName = 'four';
        child4.RecordTypeId = childRecTypeId;
        child4.rC_Sponsorship__Sponsorship_Status__c = 'Available';
        child4.Participant_Case_Number__c = '14076';
        child4.Participant_Materials_Approved_Date__c = date.today().addYears(-2);
        date fourYearsAgo = date.today().addYears(-4);
        child4.rC_Bios__Birth_Day__c = string.valueOf(fourYearsAgo.day());
        child4.rC_Bios__Birth_Month__c = string.valueOf(fourYearsAgo.month());
        child4.rC_Bios__Birth_Year__c = string.valueOf(fourYearsAgo.year());
        insert child4;
        
        //4 year old child - will not be updated because of materials date
        Contact childnot4 = new Contact();
        childnot4.FirstName = 'not';
        childnot4.LastName = 'four';
        childnot4.RecordTypeId = childRecTypeId;
        childnot4.Participant_Case_Number__c = '94576';
        childnot4.rC_Sponsorship__Sponsorship_Status__c = 'Available';
        childnot4.Participant_Materials_Approved_Date__c = date.today().addYears(-1);
        childnot4.rC_Bios__Birth_Day__c = string.valueOf(fourYearsAgo.day());
        childnot4.rC_Bios__Birth_Month__c = string.valueOf(fourYearsAgo.month());
        childnot4.rC_Bios__Birth_Year__c = string.valueOf(fourYearsAgo.year());
        insert childnot4;
        
        UpdateParticipantStatusBatch batch = new UpdateParticipantStatusBatch();
        Database.BatchableContext context;
        Database.QueryLocator locator = batch.start(context);
        
        List<Contact> participants = new List<Contact>();
        Database.QueryLocatorIterator iterator = locator.iterator();
        while(iterator.hasNext())
        {
            Contact child = (Contact)iterator.next();
            participants.add(child);
        }
        
		batch.execute(context, participants);
        batch.finish(context);   
        
        Map<Id,Contact> childMap = new Map<Id,Contact>([select id, rC_Sponsorship__Sponsorship_Status__c from Contact]);
        
        system.assertEquals('Unavailable', childMap.get(child6.Id).rC_Sponsorship__Sponsorship_Status__c, 'Status should be Unavailable');
    	system.assertEquals('Unavailable', childMap.get(child4.Id).rC_Sponsorship__Sponsorship_Status__c, 'Status should be Unavailable');
    	system.assertEquals('Available', childMap.get(childnot4.Id).rC_Sponsorship__Sponsorship_Status__c, 'Status should be Unavailable');
        batch.execute(null);
        
    } // END public static void UpdateParticipantStatusTest() {
} // END public class UpdateParticipantStatusBatchTest