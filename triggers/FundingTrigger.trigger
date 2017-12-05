trigger FundingTrigger on Funding__c (after insert, after update, after delete) {
    
    if(TriggerState.isActive('FundingTrigger')) {
        if(Trigger.isDelete){
            FundingService.updateProjectWithFundingAmount(Trigger.Old);
        }else{
            FundingService.updateProjectWithFundingAmount(Trigger.New);
        }
    }
}