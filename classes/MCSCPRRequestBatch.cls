global with sharing class MCSCPRRequestBatch implements Database.Batchable<sObject>
{

	global List<Account> communities;
    global boolean sendCPROnlyToSponsored;

	public MCSCPRRequestBatch(List<Account> comm, boolean cprtospon) {
		this.communities = comm;
        this.sendCPROnlyToSponsored = cprtospon;
	}

	global Database.QueryLocator start(Database.BatchableContext BC)
    {
        Database.QueryLocator locater;
        
        //if there are communities to process
        if(communities.size() != 0)
        {

            //IF Send_CPR_only_to_Sponsored__c == true
            // don't create an MCS unless the child is sponsored

            if (sendCPROnlyToSponsored == true)
                locater = Database.getQueryLocator([select id
                    from Contact 
                    where RecordType.Name = 'Participant'
                    AND rC_Sponsorship__Sponsorship_Status__c = 'Sponsored'
                    AND rC_Bios__Active__c = true
                    AND Community__c IN :communities  ]);
            else
                locater = Database.getQueryLocator([select id
                    from Contact 
                    where RecordType.Name = 'Participant'
                    AND rC_Sponsorship__Sponsorship_Status__c != 'Sponsored'
                    AND rC_Sponsorship__Sponsorship_Status__c != 'Departed'
                    AND rC_Bios__Active__c = true
                    AND Community__c IN :communities  ]);

        }
        return locater;
    }

    global void execute(Database.BatchableContext BC, List<sObject> scope)
    {
    	List<Mail_Control_Slip__c> MCSToInsert = new List<Mail_Control_Slip__c>();
        
        for(sobject c : scope)
        {
            Contact cont = (Contact)c;

            Mail_Control_Slip__c mcs = new Mail_Control_Slip__c();
            mcs.Participant__c = cont.id;
            mcs.MCS_Letter_Type__c = 'Child Progress Report';
            MCSToInsert.add(mcs);
        }
        
        if(MCSToInsert.size() != 0)
            insert MCSToInsert;
    }

    global void finish(Database.BatchableContext BC)
    {
    }

}