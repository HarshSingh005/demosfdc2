/***********************************************************************************************************
 * Appirio, Inc
 * Name         : PrankPhoneTriggerHandler
 * Created By   : Karl Houseknecht (Appirio)
 * Purpose      : Trigger handler for Prank_Phone__c object to prevent duplicate records
 * Created Date : 03/03/2016
 *
 * Date Modified                Modified By             Description of the update
  ----------------------------------------------------------------------------------------------------------
 * 03/03/2016                   Karl Houseknecht        Created
 **********************************************************************************************************/
public class PrankPhoneTriggerHandler 
{
	public void OnBeforeInsert(List<Prank_Phone__c> newPhones)
    {
        this.FindDuplicatePhoneNumbers(newPhones);
    }
    
    public void OnBeforeUpdate(List<Prank_Phone__c> newPhones, Map<Id, Prank_Phone__c> phonesOldMap)
    {
        this.FindDuplicatePhoneNumbers(newPhones);
    }
    
    //finds duplicate phone numbers before insert or update
    //and prevents save
    //@param phones - list of phone numbers inserted or updated
    private void FindDuplicatePhoneNumbers(List<Prank_Phone__c> phones)
    {
        //create list of search phones for the query
       	Set<string> searchPhones = new Set<string>();
        for(Prank_Phone__c phone : phones)
            searchPhones.add(phone.Search_Phone__c);
        
        //query by Search_Phone__c 
        List<Prank_Phone__c> phoneMatches = [select id, name, Phone__c, Search_Phone__c 
                                         from Prank_Phone__c
                                         where Search_Phone__c in :searchPhones];
        
        //there are matches
        //before insert, any match is a duplicate
        //before update, must check to see if id values are not same
        if(!phoneMatches.isEmpty())
        {   
            for(Prank_Phone__c phoneMatch : phoneMatches)
            {
                for(Prank_Phone__c phone : phones)
                {
                    if(phone.Search_Phone__c == phoneMatch.Search_Phone__c)
                    {
                        string message = 'Phone number already exists:&nbsp;<a href="/' 
                            + phoneMatch.Id + '">' + phoneMatch.Name + ' </a>';
                        
                        if((phone.id == null) || (phone.id != phoneMatch.Id))
                        	phone.Phone__c.addError(message, false);    
                    }
                }
            }
        }
    }
}