global class OpportunityLegacyPaymentTransactionBatch implements Database.Batchable<sObject>
{

    Decimal legacyIntPayment;

    public OpportunityLegacyPaymentTransactionBatch(Decimal intPay) {
        this.legacyIntPayment = intPay;
    }

    global Database.QueryLocator start(Database.BatchableContext BC)
    {
        Database.QueryLocator locater;

        // Query all active legacy sponsorships:        
        // StageName 'Open' - no payment yet received, 'Partially Complete' - 1+ payments received
        // AND Product_Sub_Type__c = 'Legacy Child?'
        
        locater = Database.getQueryLocator([select id, Name, Account.id
            from Opportunity 
            where RecordType.Name = 'Donation'
            AND StageName IN ('Open','Partially Complete')
            AND Product_Type__c = 'Sponsorship'
            AND Product_Sub_Type__c IN ('Legacy Local Partner', 'Legacy Child')
            AND Legacy_type__c IN ('Term','Perpetual') ]);
        //System.debug('aaaaaaaaaaaaaaaaaaaa'+ locater);
        return locater;
    }

    global void execute(Database.BatchableContext BC, List<sObject> scope)
    {
    	//System.debug('aaaaaaaaaaaaaaaaaaaa'+ scope);
        List<Opportunity> newTransactions = new List<Opportunity>();
        Id tranRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Transaction').getRecordTypeId();

        // Truncate the decimal past the penny.
        //  Therefore: total legacy payments might be as much as 1 penny * # of sponsorships LESS than original total
        Decimal legacyIntPaymentSingle = (legacyIntPayment / scope.size()).setScale(2, RoundingMode.DOWN);
        

        // NOT TO BE IMPLEMENTED: add 1 penny to % of records to achieve 1 penny accuracy

    /*
        Decimal mydec = 49.9978;
        Decimal numRECs = 79;

        Decimal mydec3 = mydec.setScale(2, RoundingMode.DOWN);
        System.debug('mydec.setScale(2, RoundingMode.HALF_DOWN) '+mydec3);

        Decimal percentExtraPenny = (mydec - mydec3) * 100;
        System.debug('% extra penny recs: '+percentExtraPenny);

        Decimal extraPennyRecs = (numRECs * percentExtraPenny).setScale(0);
        System.debug('extraPennyRecs: '+extraPennyRecs);

        Decimal newTotal = (extraPennyRecs * (mydec3 + .01)) + 
            ((numRECs - extraPennyRecs) * mydec3);

        System.debug('newTotal: '+newTotal);
        System.debug('original Total: '+(mydec * numRECs));
    */



        for(sobject o : scope)
        {
            Opportunity opp = (Opportunity)o;

            Opportunity newTransOpp = new Opportunity();
            newTransOpp.rC_Giving__Parent__c = opp.id;
            newTransOpp.account = opp.account;
            newTransOpp.CloseDate = date.today();
            newTransOpp.RecordTypeId = tranRecordTypeId;
            newTransOpp.rC_Giving__Transaction_Type__c = 'Payment';
            newTransOpp.StageName = 'Completed';
            newTransOpp.Amount = legacyIntPaymentSingle;
            newTransOpp.Name = opp.Name + ' - Legacy Sponsorship Payment';

            newTransactions.add(newTransOpp);
        }
        
        if(newTransactions.size() != 0 && !Test.isRunningTest())
            insert newTransactions;
    }

    global void finish(Database.BatchableContext BC)
    {
    }
}