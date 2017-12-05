trigger ShowingTrigger on Showing__c (After insert,After update) {
    if(Trigger.isAfter && Trigger.isUpdate){
        ShowingTriggerHandler.onAfterUpdate(Trigger.new, Trigger.oldMap);
    }
    if(Trigger.isAfter && Trigger.isInsert){
        ShowingTriggerHandler.onAfterInsert(Trigger.newMap);
    }
}