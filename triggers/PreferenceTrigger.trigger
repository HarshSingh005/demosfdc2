/***********************************************************************************************************
 * Appirio, Inc
 * Name         : PreferenceTrigger
 * Created By   : Rohit B. (Appirio)
 * Purpose      : Trigger on Preference (rC_Bios__Preference__c) object
 * Created Date : 07/June/2016
 *
 * Date Modified                Modified By             Description of the update
  ----------------------------------------------------------------------------------------------------------
 * [Date]                       [Person Name]           [Short Description]
 **********************************************************************************************************/
trigger PreferenceTrigger on rC_Bios__Preference__c (before update, before delete)  {

    if(TriggerState.isActive('PreferenceTrigger')) { 
        if(Trigger.isBefore && Trigger.isUpdate){
            PreferenceTriggerHandler.onBeforeUpdate(Trigger.oldMap, Trigger.new);
        } else if(Trigger.isBefore && Trigger.isDelete) {
            PreferenceTriggerHandler.onBeforeDelete(Trigger.old, Trigger.oldMap);
        } 
    }
} // END trigger PreferenceTrigger on rC_Bios__Preference__c (before update, before delete)  {