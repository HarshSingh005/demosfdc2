/***********************************************************************************************************
 * Appirio, Inc
 * Name         : ContactTrigger
 * Created By   : Greg Bistany
 * Purpose      : Trigger on Contact object
 * Created Date : 8/28/2014
 *
 * Date Modified                Modified By             Description of the update
  ----------------------------------------------------------------------------------------------------------
 * 12/11/2015                   Karl Houseknecht        Support single trigger pattern and update of National Office / Local Partner fields
 **********************************************************************************************************/
trigger ContactTrigger on Contact (before insert, after insert, before update, after update) 
{
    if(TriggerState.isActive('ContactTrigger')) {
        System.debug('[RB] - ContactTrigger :: Method Entry..');
        System.debug('Contact trigger  user name >>>> '+ userInfo.getUserName() );
        if(userInfo.getUserName() != 'RJ Sync User') {
                if (Trigger.isBefore && Trigger.isInsert) {
                    ContactTriggerHandler.OnBeforeInsert(Trigger.New);
                } else if(Trigger.isBefore && Trigger.IsUpdate) {
                    ContactTriggerHandler.OnBeforeUpdate(Trigger.New, Trigger.oldMap);
                } else if(Trigger.isAfter && Trigger.isUpdate) {
                    ContactTriggerHandler.OnAfterUpdate(Trigger.oldMap, Trigger.New, Trigger.newMap);
                } else if(Trigger.isAfter && Trigger.isInsert) {
                    ContactTriggerHandler.onAfterInsert(Trigger.New, Trigger.newMap);
                }
        }
        System.debug('[RB] - ContactTrigger :: Method End..');
    }
}