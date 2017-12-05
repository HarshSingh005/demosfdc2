/***********************************************************************************************************
 * Appirio, Inc
 * Name         : PrankPhoneTrigger
 * Created By   : Karl Houseknecht (Appirio)
 * Purpose      : Trigger for Prank_Phone__c object to prevent duplicate records
 * Created Date : 03/03/2016
 *
 * Date Modified                Modified By             Description of the update
  ----------------------------------------------------------------------------------------------------------
 * 03/03/2016                   Karl Houseknecht        Created
 **********************************************************************************************************/
trigger PrankPhoneTrigger on Prank_Phone__c (before insert, before update) 
{
    
    if(TriggerState.isActive('PrankPhoneTrigger')) {
        PrankPhoneTriggerHandler handler = new PrankPhoneTriggerHandler();
        
        if(trigger.isBefore)
        {
            if(trigger.isInsert)
            {
                handler.OnBeforeInsert(trigger.new);
            }
            
            if(trigger.isUpdate)
            {
                handler.OnBeforeUpdate(trigger.new, trigger.oldmap);
            }
        }
    }
}