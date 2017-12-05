/***********************************************************************************************************
 * Appirio, Inc
 * Name         : EmailExclusionBatch
 * Created By   : Karl Houseknecht (Appirio)
 * Purpose      : Batch job to update Contact email unsubscribe info based on entry in Email_Exclusion__c table
 * Created Date : 06/03/2016
 *
 * Date Modified                Modified By             Description of the update
  ----------------------------------------------------------------------------------------------------------
 * 06/03/2016                   Karl Houseknecht        Created
 **********************************************************************************************************/
global class EmailExclusionBatch implements Database.Batchable<sObject>, Schedulable
{
    global void execute(SchedulableContext SC) 
    {
        EmailExclusionBatch batch = new EmailExclusionBatch();
        database.executeBatch(batch);
    }

    global Database.QueryLocator start(Database.BatchableContext BC)
    {
        Database.QueryLocator locator;
        
        //go through all records that remain in the exclusion table
        locator = database.getQueryLocator([select id,
                                           Email__c,
                                           EPub_Code__c
                                           from Email_Exclusion__c
                                           order by Email__c asc]);
        
        return locator;
    }
    
    global void execute(Database.BatchableContext BC, List<sObject> scope)
    {
        Set<string> emails = new Set<string>();
        List<Email_Exclusion__c> exclusions = new List<Email_Exclusion__c>();
        set<Email_Exclusion__c> exclusionsToDeleteSet = new set<Email_Exclusion__c>();
        
        //create a list of email addressses and exclusion records
        for(sobject s : scope)
        {
            Email_Exclusion__c exclusion = (Email_Exclusion__c)s;
            emails.add(exclusion.Email__c);
            exclusions.add(exclusion);
        }
        
        //find a list of donors that match the emails in the exclusion table
        //Note: we can't do a SOQL LIKE statement here for case-insensitive comparison
        //so the best we can hope for is that the email matches in lower case
        //it is added to the table in lower case and Donor emails are captured in lower case
        //from the web site services
        List<Contact> donors = [select id,
                             No_Email_Birthday_Communications__c,
                             No_Email_Newsletters__c,
                             No_Email_Statement_Communications__c,
                             Email
                             from Contact
                             where RecordType.Name in ('Household','Organization')
                             and (Email in :emails)];
        
        //for all matching donors, find the exclusion records that match
        //an email on the record and update that donor appropriately
        for(Contact donor : donors)
        {  
            //There may be multiple excusions that match a donor
            //because there are multiple epub codes that they
            //can be unsubscribed from. So go through each exclusion
            for(Email_Exclusion__c exclusion : exclusions)
            {
            	if(donor.Email == exclusion.Email__c)
                {
                    //because there is a match, this exclusion
                    //will be deleted from the table
                    exclusionsToDeleteSet.add(exclusion);
                    
                    if(exclusion.EPub_Code__c == 'BDAY')
                        donor.No_Email_Birthday_Communications__c = true;
                    else if(exclusion.EPub_Code__c == 'EC')
                        donor.No_Email_Newsletters__c = true;
                    else if(exclusion.EPub_Code__c == 'SA')
                        donor.No_Email_Statement_Communications__c = true;
                }
            }
        }
  
        //update the donors and delete the exclusion records
        if(exclusionsToDeleteSet.size() > 0)
        {
            List<Email_Exclusion__c> exclusionsToDelete = new List<Email_Exclusion__c>();
        	exclusionsToDelete.addAll(exclusionsToDeleteSet);
            update donors;
        	delete exclusionsToDelete;
        }
        
    }
    
    global void finish(Database.BatchableContext BC)
    {
    }
}