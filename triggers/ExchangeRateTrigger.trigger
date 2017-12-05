/***********************************************************************************************************
 * Appirio, Inc
 * Name         : ExchangeRateTrigger
 * Created By   : Karl Houseknecht (Appirio)
 * Purpose      : Trigger to validate that exchange rate start and end dates do not overlap for a given currency
 * Created Date : 01/26/2016
 *
 * Date Modified                Modified By             Description of the update
  ----------------------------------------------------------------------------------------------------------
 * 01/26/2016                   Karl Houseknecht        Created
 **********************************************************************************************************/
trigger ExchangeRateTrigger on Exchange_Rate__c (before insert, before update) 
{
    
    if(TriggerState.isActive('ExchangeRateTrigger')) {
        ExchangeRateTriggerHandler handler = new ExchangeRateTriggerHandler();
        
        if(trigger.isBefore && trigger.isInsert)
        {
            handler.OnBeforeInsert(trigger.new);
        }
        
        if(trigger.isBefore && trigger.isUpdate)
        {
            handler.OnBeforeUpdate(trigger.new, trigger.oldMap);
        }
    }
}