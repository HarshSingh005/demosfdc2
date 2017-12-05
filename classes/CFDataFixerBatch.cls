global class CFDataFixerBatch implements Database.Batchable<sObject>
{
	public CFDataFixerBatch()
	{
	}

	global Database.QueryLocator start(Database.BatchableContext BC)
    {
        Database.QueryLocator locater;

        // Query all obligated DFs for this release
        locater = Database.getQueryLocator([select id, Participant__r.National_Office__c,
        	Participant__r.Local_Partner__c, Participant__r.Community__c
        	from Mail_Control_Slip__c where
        	NO_Lookup__c = null
		 ]);

        system.debug('### CFDataFixerBatch LOCATOR:');

        return locater;
    }

    global void execute(Database.BatchableContext BC, List<sObject> scope)
    {
        //system.debug('### CFDataFixerBatch SCOPE:'+scope.size());

		list<Mail_Control_Slip__c> listMCS = new list<Mail_Control_Slip__c>();
        for(sobject o  : scope)
        {
        	Mail_Control_Slip__c mcs = (Mail_Control_Slip__c) o;

        	mcs.NO_Lookup__c = mcs.Participant__r.National_Office__c;
        	mcs.LP_Lookup__c = mcs.Participant__r.Local_Partner__c;
        	mcs.Community_Lookup__c = mcs.Participant__r.Community__c;

        	listMCS.add(mcs);
        }


		// DML statement
		Database.SaveResult[] srList = Database.update(listMCS, false);

		// Iterate through each returned result
		for (Database.SaveResult sr : srList) {
		    if (sr.isSuccess()) {
		        // Operation was successful, so get the ID of the record that was processed
		        //System.debug('Successfully inserted account. Account ID: ' + sr.getId());
		    }
		    else {
		        // Operation failed, so get all errors                
		        for(Database.Error err : sr.getErrors()) {
		            System.debug('DML ERROR - ' + err.getStatusCode() + ' : ' + err.getMessage());
		        }
		    }
		}

    }

    global void finish(Database.BatchableContext BC)
    {
    }


}