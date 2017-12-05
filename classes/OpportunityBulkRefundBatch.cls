global class OpportunityBulkRefundBatch implements Database.Batchable<sObject>
{
	//List<ID> listOppIds = new List<ID>();

	public OpportunityBulkRefundBatch() //(List<ID> inputlistOppIds)
	{
		//this.listOppIds = inputlistOppIds;
	}

    global Database.QueryLocator start(Database.BatchableContext BC)
    {
        Database.QueryLocator locater;

        // TBD: query against Opp.processreturn == TRUE

        // Query all obligated DFs for this release
        locater = Database.getQueryLocator([select Name, rC_Giving__GAU__c, Amount, Parent_Product_Type__c,
			rC_Giving__Primary_Contact__c, rC_Giving__Hard_Credit_Contact__c, AccountId,
			Participant__c, CampaignId, rC_Giving__Parent__c, rC_Giving__Payment_Method_Selected__c,
			CloseDate, RecordTypeId, rC_Giving__GL_Batch_Number__c, Batch_Number__c, Sequence_Number__c,
			Adjustment_Reason__c, Return_Code__c, Adjustment_Comments__c,
			(select Obligation__c from GL_Allocation__r where IsObligation__c = TRUE)
			from Opportunity
			where Process_Return__c = true
		 ]);
//			where id in :listOppIds

        return locater;
    }


    global void execute(Database.BatchableContext BC, List<sObject> scope)
    {
		Map<String, ID> mapGAU = new Map<String, ID>();
		for (rC_Giving__GAU__c r : [SELECT Receipt_Category__c, Id FROM rC_Giving__GAU__c where Receipt_Category__c IN ('0152', '0154')])
		{
			mapGAU.put(r.Receipt_Category__c, r.id);
		}

		Id backoutGAUID;
		list<opportunity> listReturnOpps = new list<opportunity>();
		list<print_queue__c> listPQ = new list<print_queue__c>();
		list<opportunity> listOrigOpps = new list<opportunity>();
        for(sobject o  : scope)
        {
        	Opportunity originalTransaction = (Opportunity) o;
        	Print_Queue__c pq = new Print_Queue__c();

				// Determine back out GAU - always use origin GAU unless its a DFC that has been Obligated (then use 152)
			backoutGAUID = originalTransaction.rC_Giving__GAU__c;
			if (originalTransaction.GL_Allocation__r.size() > 0 && originalTransaction.Parent_Product_Type__c == 'Designated Fund')
			{
				if (originalTransaction.GL_Allocation__r[0].Obligation__c != null)
					backoutGAUID = mapGAU.get('0152');
			}

				// Create back out
		    Opportunity backouttransaction = new Opportunity();
			backoutTransaction.RecordTypeId = originalTransaction.RecordTypeId;
			backoutTransaction.rC_Giving__GAU__c = backoutGAUID; // return GAU		
			backoutTransaction.StageName = 'Adj From';
			backoutTransaction.Amount = - originalTransaction.Amount;  // full amount
			backoutTransaction.rC_Giving__Primary_Contact__c = originalTransaction.rC_Giving__Primary_Contact__c;
			backoutTransaction.rC_Giving__Hard_Credit_Contact__c = originalTransaction.rC_Giving__Hard_Credit_Contact__c;
			backoutTransaction.Payment_Hard_Credit_Contact__c = originalTransaction.rC_Giving__Hard_Credit_Contact__c;
			backoutTransaction.AccountId = originalTransaction.AccountId;

			backoutTransaction.Participant__c = originalTransaction.Participant__c;
			backoutTransaction.CampaignId = originalTransaction.CampaignId; 

			backoutTransaction.rC_Giving__Parent__c = originalTransaction.rC_Giving__Parent__c;
			backoutTransaction.rC_Giving__Payment_Method_Selected__c = originalTransaction.rC_Giving__Payment_Method_Selected__c;
			backoutTransaction.rC_Giving__Transaction_Type__c = 'Refund';
			backoutTransaction.CloseDate = originalTransaction.CloseDate;
			backoutTransaction.Date_of_Distribution__c = system.today();
			backoutTransaction.Adjusted_Transaction__c = originalTransaction.id;

			backoutTransaction.rC_Giving__GL_Batch_Number__c = originalTransaction.rC_Giving__GL_Batch_Number__c;
	        backoutTransaction.Batch_Number__c = originalTransaction.Batch_Number__c;
			backoutTransaction.Sequence_Number__c = originalTransaction.Sequence_Number__c;

			backoutTransaction.Return_Code__c = originalTransaction.Return_Code__c;
			backoutTransaction.Adjustment_Reason__c = 'Automated ACH Bank Draft Return';
			backoutTransaction.Adjustment_Comments__c = '';

				// Create + Return
		    Opportunity newtransaction = new Opportunity();
			newtransaction.RecordTypeId = originalTransaction.RecordTypeId;
			newtransaction.StageName = 'Returned';
			newtransaction.rC_Giving__GAU__c = mapGAU.get('0154'); // return GAU
			newtransaction.rC_Giving__Parent__c = originalTransaction.rC_Giving__Parent__c;
			newtransaction.rC_Giving__Primary_Contact__c = originalTransaction.rC_Giving__Primary_Contact__c;
			newtransaction.CampaignId = originalTransaction.CampaignId; 
			newtransaction.Participant__c = originalTransaction.Participant__c;
			newtransaction.Amount = originalTransaction.Amount;  // full amount

			newtransaction.rC_Giving__Transaction_Type__c = 'Payment';
			newtransaction.CloseDate = originalTransaction.CloseDate;
			newtransaction.Date_of_Distribution__c = system.today();
			newtransaction.Adjusted_Transaction__c = originalTransaction.id;

			newtransaction.rC_Giving__GL_Batch_Number__c = originalTransaction.rC_Giving__GL_Batch_Number__c;
	        newtransaction.Batch_Number__c = originalTransaction.Batch_Number__c;
			newtransaction.Sequence_Number__c = originalTransaction.Sequence_Number__c;

			newtransaction.Return_Code__c = originalTransaction.Return_Code__c;
			newtransaction.Adjustment_Reason__c = 'Automated ACH Bank Draft Return';
			newtransaction.Adjustment_Comments__c = '';


				// add to list: adj from and return transactions
			listReturnOpps.add(backouttransaction);
			listReturnOpps.add(newtransaction);

				// add to list: print queue donor letters
			pq.Letter_ID__c = 'ACH Automated Return';
			pq.Opportunity__c = originalTransaction.id;
			listPQ.add(pq);

				// add to list: original opps w/ Remaining_Non_Adjusted__c set to $0 on original transaction
			originalTransaction.Remaining_Non_Adjusted__c = 0;
				// clear process return flag
			originalTransaction.Process_Return__c = false;

			listOrigOpps.add(originalTransaction);

        }
        
   		insert listReturnOpps;
   		insert listPQ;
		update listOrigOpps;

    }

    global void finish(Database.BatchableContext BC)
    {
    }

}