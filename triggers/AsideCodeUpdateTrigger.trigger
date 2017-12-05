/**
 * @author      Phil Rymek
 * @date        3/15/2012
 * @description Code update trigger
 **/
trigger AsideCodeUpdateTrigger on Aside_Code_Update__c (after insert) {

    if(TriggerState.isActive('AsideCodeUpdateTrigger')) {
        if(Trigger.isInsert) {
            AsideTriggerUtil.generateCodeFiles(Trigger.new);
        }
    }
}