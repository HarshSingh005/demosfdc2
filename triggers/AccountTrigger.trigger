/***********************************************************************************************************
 * Appirio, Inc
 * Name         : AccountTrigger
 * Created By   : Rohit B. (Appirio)
 * Purpose      : Trigger on Account object
 * Created Date : 12/Dec/2015
 *
 * Date Modified                Modified By             Description of the update
  ----------------------------------------------------------------------------------------------------------
 * 16/Dec/2015                  Rohit B. (Appirio)      Added condition "TriggerState.isActive('AccountTrigger')"
 **********************************************************************************************************/
trigger AccountTrigger on Account (before insert,after insert, after update, before delete, before update) {

    if(TriggerState.isActive('AccountTrigger')) {
        AccountTriggerHandler handler = new AccountTriggerHandler(Trigger.isExecuting, Trigger.size);      
        
        if(Trigger.isInsert && Trigger.isBefore){
            handler.OnBeforeInsert(Trigger.new);
        }
        else if(Trigger.isInsert && Trigger.isAfter){
            handler.OnAfterInsert(Trigger.new);
        } // END if(Trigger.isInsert && Trigger.isAfter){
        else if(Trigger.isUpdate && Trigger.isBefore){
            handler.OnBeforeUpdate(Trigger.old, Trigger.new, Trigger.newMap, Trigger.oldMap);
        }// END else if(Trigger.isUpdate && Trigger.isBefore){
        else if(Trigger.isUpdate && Trigger.isAfter){
            handler.OnAfterUpdate(Trigger.old, Trigger.new, Trigger.newMap, Trigger.oldMap);
        } // END else if(Trigger.isUpdate && Trigger.isAfter){
        else if(Trigger.isDelete && Trigger.isBefore){
            handler.OnBeforeDelete(Trigger.old);
        } // END else if(Trigger.isUpdate && Trigger.isAfter){
        
    }

} // END trigger AccountTrigger on Account (after insert, after update) {