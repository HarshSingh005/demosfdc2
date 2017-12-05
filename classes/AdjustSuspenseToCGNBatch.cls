global class AdjustSuspenseToCGNBatch implements Database.Batchable<sObject> {

    static final string RT_TRANSACTION = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Transaction').getRecordTypeId();
    static final string RT_DONATION = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Donation').getRecordTypeId();
	public Map<String, ID> mapGAU = new Map<String, ID>();

	public AdjustSuspenseToCGNBatch() {
		for (rC_Giving__GAU__c r : [SELECT Receipt_Category__c, Id FROM rC_Giving__GAU__c where Receipt_Category__c IN ('0600', '0302') ]) {
			mapGAU.put(r.Receipt_Category__c, r.id);
		}
	}

    global Database.QueryLocator start(Database.BatchableContext BC)
    {
        Database.QueryLocator locater;

        // Get all transactions of GAU 600 that were distributed > 90 days ago AND still have
        //   remaining non-adjusted amounts -> back these amounts out and put into
        //   new CGN opportunity
        
        locater = Database.getQueryLocator([select id,
        	rC_Giving__Parent__c,
			Remaining_Non_Adjusted__c,
			rC_Giving__Hard_Credit_Contact__c,
			rC_Giving__Primary_Contact__c,
			AccountId,
			rC_Giving__Parent__r.CampaignId,
			rC_Giving__Payment_Method_Selected__c,
			CloseDate,
			rC_Giving__GL_Batch_Number__c,
			Sequence_Number__c,
			Adjustment_Reason__c,
			Return_Code__c,
			Adjustment_Comments__c
            from Opportunity 
            WHERE
            Date_of_Distribution__c < LAST_N_DAYS:90
            AND rC_Giving__Parent__r.rC_Giving__GAU__c = :mapGAU.get('0600')
            AND Remaining_Non_Adjusted__c > 0
            AND RecordTypeId = :RT_TRANSACTION ]);

        return locater;
    }

    global void execute(Database.BatchableContext BC, List<sObject> scope)
    {
    	System.debug('>>>>> AdjustSuspenseToCGNBatch - scope.size():'+ scope.size());
        List<Opportunity> newOpps = new List<Opportunity>();
        List<Opportunity> updateOpps = new List<Opportunity>();

        for(sobject o : scope)
        {
            Opportunity opp = (Opportunity)o;

            Opportunity backOutOpp = new Opportunity();
            Opportunity CGNOpp = new Opportunity();

        // Create Back Out Transaction

			backOutOpp.rC_Giving__Parent__c = opp.rC_Giving__Parent__c;
			backOutOpp.RecordTypeId = RT_TRANSACTION;

			backOutOpp.CampaignId = opp.rC_Giving__Parent__r.CampaignId; // Campaign inherited 
			backOutOpp.rC_Giving__GAU__c = mapGAU.get('0600'); // 600 GAU from parent

			backOutOpp.StageName = 'Adj From';
			backOutOpp.Amount = - opp.Remaining_Non_Adjusted__c; 
			backOutOpp.rC_Giving__Primary_Contact__c = opp.rC_Giving__Primary_Contact__c;
			backOutOpp.rC_Giving__Hard_Credit_Contact__c = opp.rC_Giving__Hard_Credit_Contact__c;
			backOutOpp.AccountId = opp.AccountId;			
			backOutOpp.Payment_Hard_Credit_Contact__c = opp.rC_Giving__Hard_Credit_Contact__c;

			backOutOpp.rC_Giving__Payment_Method_Selected__c = opp.rC_Giving__Payment_Method_Selected__c;
			backOutOpp.rC_Giving__Transaction_Type__c = 'Refund';
			backOutOpp.CloseDate = opp.CloseDate;
			backOutOpp.Date_of_Distribution__c = system.today();
			backOutOpp.Adjusted_Transaction__c = opp.id;

			backOutOpp.rC_Giving__GL_Batch_Number__c = opp.rC_Giving__GL_Batch_Number__c;
			backOutOpp.Sequence_Number__c = opp.Sequence_Number__c;
			backOutOpp.Adjustment_Reason__c = opp.Adjustment_Reason__c;
			backOutOpp.Return_Code__c = opp.Return_Code__c;
			backOutOpp.Adjustment_Comments__c = opp.Adjustment_Comments__c;

        // Create New CGN Opportunity


			CGNOpp.rC_Giving__Parent__c = null;
			CGNOpp.RecordTypeId = RT_DONATION;

			CGNOpp.CampaignId = opp.rC_Giving__Parent__r.CampaignId; // Campaign inherited 
			CGNOpp.rC_Giving__GAU__c = mapGAU.get('0302'); // TBD: CGN GAU -------------


			CGNOpp.StageName = 'Completed';
			CGNOpp.Amount = opp.Remaining_Non_Adjusted__c; 
			CGNOpp.rC_Giving__Primary_Contact__c = opp.rC_Giving__Primary_Contact__c;
			CGNOpp.rC_Giving__Hard_Credit_Contact__c = opp.rC_Giving__Hard_Credit_Contact__c;
			CGNOpp.AccountId = opp.AccountId;
			//CGNOpp.Payment_Hard_Credit_Contact__c = opp.rC_Giving__Hard_Credit_Contact__c;


			CGNOpp.rC_Giving__Payment_Method_Selected__c = opp.rC_Giving__Payment_Method_Selected__c;
			CGNOpp.rC_Giving__Transaction_Type__c = 'Payment';
			CGNOpp.CloseDate = opp.CloseDate;
			CGNOpp.Date_of_Distribution__c = system.today();
			CGNOpp.Adjusted_Transaction__c = opp.id;

			CGNOpp.rC_Giving__GL_Batch_Number__c = opp.rC_Giving__GL_Batch_Number__c;
			CGNOpp.Sequence_Number__c = opp.Sequence_Number__c;
			CGNOpp.Adjustment_Reason__c = opp.Adjustment_Reason__c;
			CGNOpp.Return_Code__c = opp.Return_Code__c;
			CGNOpp.Adjustment_Comments__c = opp.Adjustment_Comments__c;


		// fields required for parent opportunity

			CGNOpp.rC_Giving__First_Payment_Date__c = System.today();
			CGNOpp.rC_Giving__Payment_End_Date__c = System.today();
			CGNOpp.rC_Giving__Payment_Day__c = '1st';
			CGNOpp.rC_Giving__Giving_Amount__c = opp.Remaining_Non_Adjusted__c; 
			CGNOpp.rC_Giving__Giving_Frequency__c = 'One Payment';
			CGNOpp.Product_Type__c = 'One Time Gift';
            CGNOpp.Product_Sub_Type__c = 'Standard';
            CGNOpp.StageName = 'Completed';


            newOpps.add(backOutOpp);
            newOpps.add(CGNOpp);

        // zero out remaining non-adjusted amounts

			opp.Remaining_Non_Adjusted__c = 0;
			updateOpps.add(opp);

        }
        
        if(newOpps.size() > 0 && !Test.isRunningTest()) {

   	    	System.debug('>>>>> AdjustSuspenseToCGNBatch - Inserting new Opps');
        	insert newOpps;

   	    	System.debug('>>>>> AdjustSuspenseToCGNBatch - updating old Opps');
            update updateOpps;  // update GAU 600 transactions to $0 non-adjusted amounts
        }


    }

    global void finish(Database.BatchableContext BC)
    {
    }
}