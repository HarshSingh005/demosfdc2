trigger StandardAllocationTrigger on Standard_Allocation__c (after update) {
    
    if(TriggerState.isActive('StandardAllocationTrigger')) {
        if(Trigger.isAfter && Trigger.isUpdate){
            StandardAllocationService.onAfterUpdate(Trigger.oldMap, Trigger.newMap);
        }
    }
}