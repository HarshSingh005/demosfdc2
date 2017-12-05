/***********************************************************************************************************
 * Appirio, Inc
 * Name         : WebTransactionTrigger
 * Created By   : Karl Houseknecht (Appirio)
 * Purpose      : Trigger for WebTransaction
 * Created Date : 03/03/2016
 *
 * Date Modified                Modified By             Description of the update
  ----------------------------------------------------------------------------------------------------------
 * 12/01/2016                   Karl Houseknecht        Created
 **********************************************************************************************************/
trigger WebTransactionTrigger on Web_Transaction__c (after insert, after update) 
{
	if(TriggerState.isActive('WebTransactionTrigger')) 
	{
		if(trigger.isAfter && trigger.isInsert)
			WebTransactionTriggerHandler.OnAfterInsert(trigger.new);
		else if(trigger.isAfter && trigger.isUpdate)
			WebTransactionTriggerHandler.OnAfterUpdate(trigger.new);
	}
}