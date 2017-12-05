trigger OpportunityTrigger on Opportunity (before insert, before update, after insert, after update) {
    
    if(TriggerState.isActive('OpportunityTrigger')) {
        if(Trigger.isBefore && Trigger.isInsert){
            OpportunityService.onBeforeInsert(Trigger.new);
        } 
        
        if(Trigger.isBefore && Trigger.isUpdate) {
            OpportunityService.onBeforeUpdate(Trigger.New, Trigger.oldMap, Trigger.newMap);
    
        } 
        if(Trigger.isAfter && Trigger.isInsert){
            system.debug('************ Opportunity after insert trigger');
            OpportunityService.onAfterInsert(Trigger.new, Trigger.newMap);
            
        } 
        
        if(Trigger.isAfter && Trigger.isUpdate){
            OpportunityService.onAfterUpdate(Trigger.New, Trigger.oldMap, Trigger.newMap);
        }
    }
}