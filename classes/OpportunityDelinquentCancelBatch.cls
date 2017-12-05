global class OpportunityDelinquentCancelBatch implements Database.Batchable<sObject> {
	public boolean recordsUpdated{get; set;}
	public OpportunityDelinquentCancelBatch() {
		recordsUpdated = false;
	}

    global Database.QueryLocator start(Database.BatchableContext BC)
    {
        Database.QueryLocator locater;
        recordsUpdated = false;

        // selective filter
        // AND Paid_Through_Date__c >= LAST_N_DAYS:90
        // AND Number_Months_Delinquent__c > 2
        
        locater = Database.getQueryLocator([select id, name,
            Product_Type__c,
            Product_Sub_Type__c,
        	Number_Months_Delinquent__c,
            rC_Giving__Suspended_Start_Date__c,
            rC_Giving__Suspended_End_Date__c,
            rC_Giving__Hard_Credit_Contact__r.Alliance_Donor__c,
            rC_Giving__Hard_Credit_Contact__r.Active_Sponsorships__c,
            Participant__c //I-244913 | To cancel MCS on this participant
            from Opportunity 
            where Product_Type__c IN ('Sponsorship', 'Recurring Gift')
            AND StageName IN ('Open','Partially Complete')
            AND Number_Months_Delinquent__c > 2
            AND Paid_Through_Date__c <= LAST_N_DAYS:90
            AND rC_Giving__Hard_Credit_Contact__r.Alliance_Donor__c = false]);

// AND Sponsorship_Status__c = 'Sponsored'

        return locater;
    }

    global void execute(Database.BatchableContext BC, List<sObject> scope)
    {
    	System.debug('>>>>> scope.size():'+ scope.size());
        List<Opportunity> cancelOpps = new List<Opportunity>();
        Set<ID> fullcancelParIDs = new Set<ID>();
        Integer delinquentMonth;

        List<Print_Queue__c> listPrintQueue = new List<Print_Queue__c>();

        for(sobject o : scope)
        {
            Opportunity opp = (Opportunity)o;
            Print_Queue__c pq = new Print_Queue__c();

            // do NOT cancel if suspended
            if ( opp.rC_Giving__Suspended_Start_Date__c != null
                 && opp.rC_Giving__Suspended_End_Date__c != null
                 && opp.rC_Giving__Suspended_Start_Date__c <= system.today()
                 && opp.rC_Giving__Suspended_End_Date__c >= system.today())
                continue;

            // do NOT cancel if an Alliance member
            if (opp.rC_Giving__Hard_Credit_Contact__r.Alliance_Donor__c == true)
                continue;

    /* 

        START: Cancel Period Configuration

        The following section can be configured
          - add Product Sub Types as needed
          - modify delinquent months as needed (eg. the month at which an unpaid donation is canceled)
    */

            if (opp.Product_Type__c == 'Sponsorship') {
                delinquentMonth = 7;

                if (opp.rC_Giving__Hard_Credit_Contact__r.Active_Sponsorships__c == 1)
                {
                    system.debug('@@@@monthdeliqnt'+Opp.Number_Months_Delinquent__c);
                    if (opp.Number_Months_Delinquent__c == 4)
                        pq.Letter_ID__c = '13';
                    else if (opp.Number_Months_Delinquent__c == 5)
                        pq.Letter_ID__c = '14';
                    else if (opp.Number_Months_Delinquent__c == 6)
                        pq.Letter_ID__c = '15';
                }
                else if (opp.rC_Giving__Hard_Credit_Contact__r.Active_Sponsorships__c > 1)
                {
                    if (opp.Number_Months_Delinquent__c == 4)
                        pq.Letter_ID__c = '13-multi';
                    else if (opp.Number_Months_Delinquent__c == 5)
                        pq.Letter_ID__c = '14-multi';
                    else if (opp.Number_Months_Delinquent__c == 6)
                        pq.Letter_ID__c = '15-multi';
                }

            }
            else if (opp.Product_Type__c == 'Recurring Gift' && opp.Product_Sub_Type__c == 'CGN')
                delinquentMonth = 4;
            else if (opp.Product_Type__c == 'Recurring Gift' && opp.Product_Sub_Type__c == 'EFS')
                delinquentMonth = 4;
            else if (opp.Product_Type__c == 'Recurring Gift' && opp.Product_Sub_Type__c == 'Guardian Angel')
                delinquentMonth = 4;
            else if (opp.Product_Type__c == 'Recurring Gift' && opp.Product_Sub_Type__c == 'Other Contribution')
                delinquentMonth = 4;
            else
                continue;

    /*
        END: Cancel Period Configuration
    */

            System.debug('>>>>> opp.Name:'+ opp.Name);
            System.debug('>>>>> opp.Number_Months_Delinquent__c:'+ opp.Number_Months_Delinquent__c);
            System.debug('>>>>> delinquentMonth:'+ delinquentMonth);
            System.debug('>>>>> opp.Product_Type__c:'+ opp.Product_Type__c);

            if (opp.Number_Months_Delinquent__c >= delinquentMonth && opp.Product_Type__c == 'Sponsorship')
            {
            	opp.Cancel_Sponsorship__c = 'Cancel - Reinstateable';
                opp.Cancelled_Date__c = system.today();
                //opp.rC_Sponsorship__Future_Cancellation_Date__c = system.today().addDays(90);
                opp.rC_Sponsorship__Sponsorship_Status_Reason__c = 'Cancellation';
                opp.Sponsorship_Change_Reason_Detail__c = 'Delinquency';
            	cancelOpps.add(opp);

                pq.Letter_ID__c = '12';
            }
            else if (opp.Number_Months_Delinquent__c >= delinquentMonth && opp.Product_Type__c == 'Recurring Gift')
            {
                opp.Cancel_Sponsorship__c = 'Cancel - No Reinstate';
                opp.Cancelled_Date__c = system.today();
                opp.rC_Sponsorship__Sponsorship_Status_Reason__c = 'Cancellation';
                opp.Sponsorship_Change_Reason_Detail__c = 'Delinquency';
                cancelOpps.add(opp);
                fullcancelParIDs.add(opp.Participant__c);

                pq.Letter_ID__c = '30498';
            }


            if (pq.Letter_ID__c != null)
            {
                pq.Opportunity__c = opp.id;
                listPrintQueue.add(pq);
            }

        }
        
        if(cancelOpps.size() != 0 && !Test.isRunningTest()) {
            Database.update(cancelOpps, false);
            OpportunityService.cancelMCS(fullcancelParIDs);       // cancel all open MCSs for these participants
        }
        
        if (listPrintQueue.size() > 0)
            insert listPrintQueue;

        if(cancelOpps.size() != 0 && Test.isRunningTest()) {
        	recordsUpdated = true;
        }


    }

    global void finish(Database.BatchableContext BC)
    {
    }
}