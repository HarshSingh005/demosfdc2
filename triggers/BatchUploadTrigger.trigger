/***********************************************************************************************************
 * Appirio, Inc
 * Name         : BatchUploadTrigger
 * Created By   : Rohit B. (Appirio)
 * Purpose      : Trigger on Batch Upload(rC_Connect__Batch_Upload__c) object
 * Created Date : 04/Feb/2016
 *
 * Date Modified                Modified By             Description of the update
  ----------------------------------------------------------------------------------------------------------
 * [Date]                       [Person Name]           [Short Description]
 **********************************************************************************************************/

trigger BatchUploadTrigger on rC_Connect__Batch_Upload__c (before insert, before update, after update, after insert) {

    if(TriggerState.isActive('BatchUploadTrigger')) {
        if(Trigger.isBefore && Trigger.isInsert){
            BatchUploadTriggerHandler.onBeforeInsert(Trigger.New);
        }
        
        if(Trigger.isBefore && Trigger.isUpdate){
            BatchUploadTriggerHandler.onBeforeUpdate(Trigger.New, Trigger.oldMap);
        }
        
        if(Trigger.isAfter && Trigger.isUpdate){
            BatchUploadTriggerHandler.onAfterUpdate(Trigger.oldMap, Trigger.New, Trigger.newMap);
        }
        
        if(Trigger.isAfter && Trigger.isInsert){
            BatchUploadTriggerHandler.onAfterInsert(Trigger.New, Trigger.newMap);
        }
    }
} // END trigger BatchUploadTrigger on rC_Connect__Batch_Upload__c (after update) {