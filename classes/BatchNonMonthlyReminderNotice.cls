global class BatchNonMonthlyReminderNotice implements Database.Batchable<sObject>
{
	public BatchNonMonthlyReminderNotice()
	{
	}

	global Database.QueryLocator start(Database.BatchableContext BC)
    {
        Database.QueryLocator locater;

        // Query all obligated DFs for this release
        locater = Database.getQueryLocator([select id, rC_Giving__Hard_Credit_Account__r.name
			from Opportunity
			where
			rC_Giving__Giving_Frequency__c in ('Annually', 'Semi-Annually', 'Quarterly')
			and StageName IN ('Open', 'Partially Complete')
			and AGP_Method__c = false
			and RecordType.Name = 'Donation'
            and Product_Type__c = 'Sponsorship'
			and Paid_Through_Date__c = NEXT_MONTH
            and rC_Giving__Hard_Credit_Contact__r.Alliance_Donor__c  = false
		 ]);

        system.debug('### BatchNonMonthlyReminderNotice LOCATOR:');

        return locater;
    }

    global void execute(Database.BatchableContext BC, List<sObject> scope)
    {
        system.debug('### BatchNonMonthlyReminderNotice SCOPE:'+scope.size());

		list<Print_Queue__c> listPQ = new list<Print_Queue__c>();
        for(sobject o  : scope)
        {
        	Opportunity opp = (Opportunity) o;
            system.debug('### Opp:'+opp.id);

        	Print_Queue__c pq = new Print_Queue__c();

        	pq.Opportunity__c = opp.id;
        	pq.Letter_ID__c = 'Non-Monthly Reminder';

        	listPQ.add(pq);
        }

        insert listPQ;
    }

    global void finish(Database.BatchableContext BC)
    {
    }


}