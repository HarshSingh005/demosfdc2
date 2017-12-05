/***********************************************************************************************************
 * Appirio, Inc
 * Name         : WebTransactionTriggerHandler
 * Created By   : Karl Houseknecht (Appirio)
 * Purpose      : Trigger Handler for WebTransaction
 * Created Date : 03/03/2016
 *
 * Date Modified                Modified By             Description of the update
  ----------------------------------------------------------------------------------------------------------
 * 12/01/2016                   Karl Houseknecht        Created
 **********************************************************************************************************/
public class WebTransactionTriggerHandler 
{
	public static void OnAfterInsert(List<Web_Transaction__c> transList)
	{
		UpdateBatchUploads(transList);
	}

	public static void OnAfterUpdate(List<Web_Transaction__c> transList)
	{
		UpdateBatchUploads(transList);
	}

	private static void UpdateBatchUploads(List<Web_Transaction__c> transList)
	{
		//If the web transaction record's status is set to Flagged,
		//set all of the related Batch Upload records to flagged also.

		Set<id> transIds = new Set<Id>(); 


		for(Web_Transaction__c trans : transList)
			if(trans.Status__c == 'Flagged')
				transIds.add(trans.id);

		if(transIds.size() > 0)
		{
			List<rC_Connect__Batch_Upload__c> batchUploads = [select id, rC_Connect__Batch_Upload_Status__c
															  from rC_Connect__Batch_Upload__c
															  where Web_Transaction__c in :transIds
															  and rC_Connect__Batch_Upload_Status__c not in ('Committed','Flagged')];

		    for(rC_Connect__Batch_Upload__c batch : batchUploads)
		    	batch.rC_Connect__Batch_Upload_Status__c = 'Flagged';

	    	update batchUploads;
		}
	}

}