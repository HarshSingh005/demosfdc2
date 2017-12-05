/**
 * CaseTrigger: Service class that provides utility methods on Case sObject
 *
 * Ver No.     Developer/Org                 Date         Changes
 * -----------------------------------------------------------------------------
 *   1.0       Charlie Xie/Bluewolf          02/06/2014    Refatored from setTargetSLATimes.trigger
 *   2.0       ---                           02/11/2014    add after-Update trigger to update master case status
 */  
trigger CaseTrigger on Case (before insert, before update, after update, after insert) {

    if(TriggerState.isActive('CaseTrigger')) {
        if(Trigger.isBefore){
            if(Trigger.isInsert){
                CaseService.setTargetSLATimes(false, Trigger.new);
            }
            if(Trigger.isUpdate){
                CaseService.setTargetSLATimes(true, Trigger.new);
            }
        }
        if(Trigger.isAfter){
            
            if(Trigger.isUpdate){
                CaseService.updateMasterCaseWithStatus(Trigger.oldMap, Trigger.new);
            }
            if(Trigger.isInsert)
            {
                CaseService.updateClosedMasterCaseToInProgress(Trigger.new);
            }
            CaseService.validateMasterCase(Trigger.New);
        }
    }
}