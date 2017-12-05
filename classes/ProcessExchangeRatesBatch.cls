/***********************************************************************************************************
 * Appirio, Inc
 * Name         : ProcessExchangeRatesBatch
 * Created By   : Karl Houseknecht (Appirio)
 * Purpose      : Batch job to process Exchange Rates on Transactions (Opportunity)
 * Created Date : 01/07/2016
 *
 * Date Modified                Modified By             Description of the update
  ----------------------------------------------------------------------------------------------------------
 * 01/07/2016					Karl Houseknecht		Created
 **********************************************************************************************************/
global class ProcessExchangeRatesBatch implements Database.Batchable<sObject>
{
    global List<Exchange_Rate__c> rates;
    
    global ProcessExchangeRatesBatch()
    {
        this.rates = [select id, 
                 Currency__c,
                 Currency__r.Code__c,
                 Start_Date__c, 
                 End_Date__c, 
                 Exchange_Rate__c, 
                 Status__c 
                 from Exchange_Rate__c 
                 where Status__c = 'Process'];
    }
    
    //gets a list of opportunities but only if there are rates to process
	global Database.QueryLocator start(Database.BatchableContext BC)
    {
        Database.QueryLocator locater;
        
        //if there are rates to process, update their status and query for Transactions to process
        if(rates.size() != 0)
        {
            for(Exchange_Rate__c rate : this.rates)
                rate.Status__c = 'Processing';
            update this.rates;
            
            Id transRecTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Transaction').getRecordTypeId();
            locater = Database.getQueryLocator([select id, 
                                                Local_Currency__c, 
                                                Local_Currency__r.Code__c, 
                                                Exchange_Rate__c, 
                                                Exchange_Rate_Id__c,
                                                CloseDate
                                                from Opportunity 
                                                where (RecordTypeId = :transRecTypeId and 
                                                       CloseDate <> null and
                                                       StageName = 'Completed' and
                                                       Exchange_Rate_Applied__c = null and 
                                                       Local_Currency__c <> null and 
                                                       Local_Currency__r.Code__c <> 'USD')]);
        }
        
        return locater;
    }
    
    //for each transaction
    //Check to see if there is an exchange rate which is applicable to the close date of the opp which has "Processing" for Status
    //update transaction exchange rate and exchange rate applied
    //update exchange rate lookup field
    global void execute(Database.BatchableContext BC, List<sObject> scope)
    {
        List<Opportunity> oppsToUpdate = new List<Opportunity>();
        
        for(sobject s : scope)
        {
            Opportunity opp = (Opportunity)s;
            Exchange_Rate__c rate = this.findApplicableRate(opp.Local_Currency__r.Code__c, opp.CloseDate);
            if(rate != null)
            {
                opp.Exchange_Rate__c = rate.Exchange_Rate__c;
                opp.Exchange_Rate_Applied__c = datetime.now();
                opp.Exchange_Rate_Id__c = rate.id;
                oppsToUpdate.add(opp);
            }
        }
        
        if(oppsToUpdate.size() != 0)
            update oppsToUpdate;
    }
    
    //find a rate given currency and transaction CloseDate
    global Exchange_Rate__c findApplicableRate(string currencyCode, date closeDate)
    {
        Exchange_Rate__c foundRate;
        
        for(Exchange_Rate__c rate : this.rates)
        {
            if((rate.Currency__r.Code__c == currencyCode) && 
               (rate.Start_Date__c <= closeDate) &&
               (rate.End_Date__c >= closeDate))
            {
                foundRate = rate;
                break;
            }
        }

        return foundRate;
    }
    
    //update the rate status to Applied
    global void finish(Database.BatchableContext BC)
    {
        for(Exchange_Rate__c rate : this.rates)
            rate.Status__c = 'Applied';
        update this.rates;
    }
}