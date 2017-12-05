/***********************************************************************************************************
 * Appirio, Inc
 * Name         : PaymentMethodTrigger
 * Created By   : Ravi Chauhan
 * Purpose      : Trigger on Payment Method object
 * Created Date : 08/04/2016
 *
 * Date Modified                Modified By             Description of the update
  ----------------------------------------------------------------------------------------------------------
 * 
 **********************************************************************************************************/
trigger PaymentMethodTrigger on rC_Giving__Payment_Method__c (before insert, after insert, after update) {
    
    if(TriggerState.isActive('PaymentMethodTrigger')) {
        if(Trigger.isAfter && Trigger.isInsert){
            PaymentMethodTriggerHandler.OnAfterInsert(Trigger.New, Trigger.newMap);
        }
        else if(Trigger.isAfter && Trigger.isUpdate){
            PaymentMethodTriggerHandler.OnAfterUpdate(Trigger.New, Trigger.oldMap, Trigger.newMap);
        }
        else if(Trigger.isBefore && Trigger.isInsert){
        	PaymentMethodTriggerHandler.OnBeforeInsert(Trigger.New);
        }
        
    }

}