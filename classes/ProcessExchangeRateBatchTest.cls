/***********************************************************************************************************
 * Appirio, Inc
 * Name         : ProcessExchangeRatesBatchTest
 * Created By   : Karl Houseknecht (Appirio)
 * Purpose      : Test class for Batch job to process Exchange Rates on Transactions (Opportunity)
 * Created Date : 01/08/2016
 *
 * Date Modified                Modified By             Description of the update
  ----------------------------------------------------------------------------------------------------------
 * 01/08/2016					Karl Houseknecht		Created
 * Aug 12,2016                  Ashu Gupta              Implemented coding conventions
 **********************************************************************************************************/
@isTest
public class ProcessExchangeRateBatchTest 
{   
    static Exchange_Rate__c canRate;
    static Opportunity trans;
	public static testMethod void testProcessExchangeRates()
    {
        createTestData();
        Test.startTest();
        ProcessExchangeRatesBatch batch = new ProcessExchangeRatesBatch();
        Database.BatchableContext context;
        Database.QueryLocator locator = batch.start(context);
        
        List<Opportunity> transactions = new List<Opportunity>();
        Database.QueryLocatorIterator iterator = locator.iterator();
        while(iterator.hasNext())
        {
            Opportunity opp = (Opportunity)iterator.next();
            transactions.add(opp);
        }
        
        batch.execute(context, transactions);
        batch.finish(context);
        
        trans = [select id, 
                 name,
                 Amount, 
                 Exchange_Rate__c, 
                 Exchange_Rate_Applied__c,
                 Exchange_Rate_Id__c
                 from Opportunity
                 where id = :trans.id];
        
        canRate = [select id, Status__c from Exchange_Rate__c where id = :canRate.Id];
        
        system.assertEquals('Applied', canRate.Status__c, 'Exchange Rate Status incorrect.');
        //system.assertEquals(39.76, trans.Amount, 'Amount incorrect.');
        system.assertEquals(0.71, trans.Exchange_Rate__c, 'Exchange Rate incorrect.');
        system.assert(trans.Exchange_Rate_Applied__c != null, 'Exchange Rate Applied should have a value.');
        system.assertEquals(canRate.Id, trans.Exchange_Rate_Id__c, 'Exchange Rate Id incorrect.');
        Test.stopTest();
    }
    static void createTestData(){
        Currency__c canCurrency = TestUtils.createCurrency('CAN','Canada',false);
        canCurrency.Name = 'Canadian Dollar (CAN)';
        insert canCurrency;
        
        canRate = TestUtils.createExchangeRate(canCurrency.id,0.71,date.today().addDays(-1),date.today().addDays(1),false);
        canRate.Status__c = 'Process';
        insert canRate;
        
        Account acc = TestUtils.createAccount('test',true);
        
        trans = TestUtils.createOpportunity(acc,'Test Trans',100,false);
        trans.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Transaction').getRecordTypeId();
        trans.Local_Currency__c = canCurrency.id;
        //trans.Local_Currency_Quantity__c = 56;
        trans.StageName = 'Completed';
        trans.CloseDate = date.today();
        insert trans;
        
    }
}