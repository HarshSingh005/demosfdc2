trigger ProjectTrigger on Project__c (after insert, after update, after delete) {
    
    if(TriggerState.isActive('ProjectTrigger')) {
        if(Trigger.isDelete){
            ProjectService.updateParentProjectWithFundingAmount(Trigger.old);
            ProjectService.updateParentProjectWithChildExpenses(Trigger.old);
        }else{
            ProjectService.updateParentProjectWithFundingAmount(Trigger.New);
            ProjectService.updateParentProjectWithChildExpenses(Trigger.New);
        }
    }
    
}