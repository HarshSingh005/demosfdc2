global class OpportunityDFCReceivedbyNOBatch implements Database.Batchable<sObject>
{

    Id GLAccount = null;
    String releaseNO = null;
    Date releaseDate = null;
 
    public OpportunityDFCReceivedbyNOBatch(String releaseNO, Date releaseDate) {
        this.releaseNO = releaseNO;
        this.releaseDate = releaseDate;


        system.debug('>>>>>>>>>releaseNO  :'+releaseNO);
        system.debug('>>>>>>>>>releaseDate  :'+releaseDate);
    }

    global Database.QueryLocator start(Database.BatchableContext BC)
    {
        Database.QueryLocator locater;

        // Query all obligated DFs for this release
        locater = Database.getQueryLocator([select id, Transaction__r.id,
        	Transaction__r.rC_Giving__Parent__r.Participant__c, Transaction__r.Name
			FROM gl_allocation__c
			WHERE GL_Allocation__c.IsObligation__c = true
			AND Transaction__r.Parent_Product_Type__c = 'Designated Fund'
            AND National_Office__c = :releaseNO
            AND Obligation__r.Release_Date__c = :releaseDate
            AND Transaction__r.rC_Giving__Parent__r.Participant__c != null
		 ]);

            // AND Transaction__r.DFC_status__c = 'Sent to NO' - not needed. if ob has release date it IS sent to NO
            // AND Received by NO date == null ??

        return locater;
    }

    global void execute(Database.BatchableContext BC, List<sObject> scope)
    {
        //List<Opportunity> updateTransactions = new List<Opportunity>();
        List<Mail_Control_Slip__c> newTYLMCS = new List<Mail_Control_Slip__c>();

        Id tranRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Transaction').getRecordTypeId();


        for(sobject o : scope)
        {
            gl_allocation__c gla = (gl_allocation__c)o;

            system.debug('>>>> Creating TYL for:'+gla.transaction__r.Name);

            if (gla.transaction__r == null)
            	continue;

                // TBD: REMOVE
            //Opportunity upOpp = new Opportunity();
            //upOpp.id = gla.Transaction__r.id;
            //upOpp.DFC_status__c = 'Received by NO';
            //updateTransactions.add(upOpp);
                //

            Mail_Control_Slip__c mcs = new Mail_Control_Slip__c();
            mcs.MCS_Letter_Type__c = 'Thank You Letter for DF';
            mcs.Participant__c = gla.Transaction__r.rC_Giving__Parent__r.Participant__c;

            // points to DFC Transaction record
            mcs.DFC_Opportunity__c = gla.transaction__r.id;

            // NEW: points to GL Allocation record (tied to DFC Transaction record)
            mcs.DFC_Record__c = gla.id;

            newTYLMCS.add(mcs);
        }
        
            // TBD: REMOVE
        //if(updateTransactions.size() != 0 && !Test.isRunningTest())
        //    update updateTransactions;
            //

        if(newTYLMCS.size() != 0 && !Test.isRunningTest())
            insert newTYLMCS;
    }

    global void finish(Database.BatchableContext BC)
    {
    }
}