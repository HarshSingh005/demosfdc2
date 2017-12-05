trigger TrailerTrigger on Trailer__c (After insert,After update) {
    if(Trigger.isAfter && Trigger.isUpdate){
        TrailerTriggerHandler.onAfterUpdate(Trigger.new, Trigger.oldMap);
    }
    if(Trigger.isAfter && Trigger.isInsert){
        TrailerTriggerHandler.onAfterInsert(Trigger.newMap);
    }
}