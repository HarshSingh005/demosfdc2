global with sharing class UpdateOpportunityNameBatch implements Database.Batchable<sObject>{
    global Database.QueryLocator start(Database.BatchableContext BC){
        Database.QueryLocator locater;
        System.debug('beginning');
            locater = Database.getQueryLocator([select id, Product_Sub_Type__c, Product_Type__c, Sponsored_Account__c, Sponsored_Account__r.Name
                from Opportunity 
                Where Product_Type__c = 'Designated Fund'
                AND Product_Sub_Type__c in ('Gift for National Office',  'Gift for Local Partner',  'Gift for Community',  'Gift for Former Sponsored Child')
                AND Sponsored_Account__c !=null 
                AND Id = '00629000002RkD8AAK']);
                System.debug('locator ....'+locater);
        return locater;
    }

    global void execute(Database.BatchableContext BC, List<sObject> scope){
        System.debug('scope ....'+scope);
        List<Opportunity> opportunitiesToUpdate = new List<Opportunity>();
        for(sobject c : scope){
            Opportunity opp = (Opportunity)c;
            System.debug(opp.Product_Sub_Type__c+' - '+opp.Sponsored_Account__r.Name);
            opp.Name = opp.Product_Sub_Type__c+' - '+opp.Sponsored_Account__r.Name;
            opportunitiesToUpdate.add(opp);
        }
        if(opportunitiesToUpdate.size() > 0)
        System.debug('inside ....');
            update opportunitiesToUpdate;
    }
    global void finish(Database.BatchableContext BC){
    }
}