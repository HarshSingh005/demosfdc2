/***********************************************************************************************************
 * Appirio, Inc
 * Name         : MailControlSlipTrigger
 * Created By   : Dirk K. (Appirio)
 * Purpose      : Trigger on Mail_Control_Slip__c object
 * Created Date : Dec/2015
 *
 * Date Modified                Modified By             Description of the update
  ----------------------------------------------------------------------------------------------------------
 * 05/09/2016                   Munib Ur Rehman         Created After Insert After Update Trigger
 **********************************************************************************************************/
trigger MailControlSlipTrigger on Mail_Control_Slip__c (before insert,before update, after insert, after update) {

    if(TriggerState.isActive('MailControlSlipTrigger')) {
        MCSTriggerHandler handler = new MCSTriggerHandler(Trigger.isExecuting, Trigger.size);
        
        if(Trigger.isInsert && Trigger.isBefore){
            handler.OnBeforeInsert(Trigger.new);
        }
        else if(Trigger.isUpdate && Trigger.isBefore){
            handler.onBeforeUpdate(Trigger.new,Trigger.oldMap);
        }
        
        //After Trigger
        if(Trigger.isAfter){
            //T-514023 Created By Munib Ur Rehman
            if(Trigger.isUpdate){
                handler.OnAfterUpdate(Trigger.new, Trigger.NewMap);
            }
            //T-514023 Created By Munib Ur Rehman
            else if(Trigger.isInsert){
                handler.onAfterInsert(Trigger.new, Trigger.NewMap);
            }
        }
    }

} // END trigger