/***********************************************************************************************************
 * Appirio, Inc
 * Name         : ScheduledAGPEmailBatch
 * Created By   : Karl Houseknecht (Appirio)
 * Purpose      : Batch job to update Hard Credit Contacts to send AGP reminder email
 * Created Date : 06/21/2016
 *
 * Date Modified                Modified By             Description of the update
  ----------------------------------------------------------------------------------------------------------
 * 06/21/2016                   Karl Houseknecht        Created
 **********************************************************************************************************/
global class ScheduledAGPEmailBatch implements Database.Batchable<sObject>, Schedulable
{
    global void execute(SchedulableContext SC) 
    {
        ScheduledAGPEmailBatch batch = new ScheduledAGPEmailBatch();
        database.executeBatch(batch);
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC)
    {
        Database.QueryLocator locator;
        
        //get a list of Transactions that are scheduled to be deducted
        //5 days from today, and who have a giving frequency that is non-monthly
        //use this to find hard credit contacts to update
        
        date fiveDaysFromToday = date.today().addDays(5);
        
        locator = database.getQueryLocator([select id,
                                           rC_Giving__Hard_Credit_Contact__c
                                           from opportunity
                                           where opportunity.recordtype.name = 'Transaction'
                                           and rC_Giving__Parent__r.AGP_Method__c = true
                                           and rC_Giving__Parent__r.rC_Giving__Giving_Frequency__c in ('Annually','Semi-Annually','Quarterly')
                                           and CloseDate = :fiveDaysFromToday
                                           and StageName != 'Completed']);
        
        return locator;
    }
    
    global void execute(Database.BatchableContext BC, List<sObject> scope)
    {
        Set<Id> contactIds = new Set<Id>();
        
        for(sobject s : scope)
        {
        	Opportunity opp = (Opportunity)s;
            
            if(opp.rC_Giving__Hard_Credit_Contact__c != null)
            	contactIds.add(opp.rC_Giving__Hard_Credit_Contact__c);
        }
        
        //get a list of contacts to update
        List<Contact> contacts = [select id, AGP_Donation_Advisory_Send_Date__c, US_Donor__c
                                  from contact 
                                  where id in :contactIds];
        
        //setting this date will trigger a workflow to send the visualforce reminder email
        //It is okay if the same contact gets updated in subsequent batches because
        //the workflow rule will look to see if the date has changed. Batch will not run
        //for longer than a day, and should be scheduled to run after midnight so the date
        //should only change once on a contact per batch run.
        for(Contact donor : contacts)
            if(donor.US_Donor__c){
                donor.AGP_Donation_Advisory_Send_Date__c = date.today();
            }
        
        update contacts;
    }
    
    global void finish(Database.BatchableContext BC)
    {
    }
}