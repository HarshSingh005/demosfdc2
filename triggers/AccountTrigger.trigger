trigger AccountTrigger on Account (before insert) {
    if(Trigger.isInsert==True && Trigger.isBefore==True){
       AccountTriggerHandler.CreateAccounts(Trigger.NEW);
    }

}