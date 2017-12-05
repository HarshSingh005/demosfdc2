/***********************************************************************************************************
 * Appirio, Inc
 * Name         : ExchangeRateTriggerHandlerTest
 * Created By   : Karl Houseknecht (Appirio)
 * Purpose      : Test code for trigger to validate that exchange rate start and end dates do not overlap for a given currency
 * Created Date : 01/26/2016
 *
 * Date Modified                Modified By             Description of the update
  ----------------------------------------------------------------------------------------------------------
 * 01/26/2016					Karl Houseknecht		Created
 * 08/16/2016					Vaibhav Goel    		Modified for optimized test-data creation
 **********************************************************************************************************/
@isTest
public class ExchangeRateTriggerHandlerTest 
{
    public static Currency__c cur;
    public static Exchange_Rate__c rate1, rate2, rate3;
    
    @isTest
	public static void validateRateDatesTest()
    {
        //set up currency and rate test data
        
        test.StartTest();
        createTestData();
        try
        {
            insert rate2;
        }
        catch(exception ex)
        {
            Boolean expectedExceptionThrown = ex.getMessage().contains(rate1.Id) ? true : false;
            System.AssertEquals(expectedExceptionThrown, true);
        }
        
        try
        {
            rate2.Start_Date__c = rate1.Start_Date__c.addDays(-1);
            rate2.End_Date__c = rate1.End_Date__c.addDays(-1);
            insert rate2;
        }
        catch(exception ex)
        {
            Boolean expectedExceptionThrown =  ex.getMessage().contains(rate1.Id) ? true : false;
            System.AssertEquals(expectedExceptionThrown, true);
        }
        
        try
        {
            rate2.Start_Date__c = rate1.Start_Date__c.addDays(-1);
            rate2.End_Date__c = rate1.End_Date__c.addDays(1);
            insert rate2;
        }
        catch(exception ex)
        {
            Boolean expectedExceptionThrown =  ex.getMessage().contains(rate1.Id) ? true : false;
            System.AssertEquals(expectedExceptionThrown, true);
        }
        
        rate2.Start_Date__c = rate1.End_Date__c.addDays(1);
        rate2.End_Date__c = rate2.Start_Date__c.addDays(2);
        insert rate2;
        
        rate2.End_Date__c = rate2.End_Date__c.addDays(1);
        update rate2;
        
        try
        {
            insert rate3;
        }
        catch(exception ex)
        {
            Boolean expectedExceptionThrown =  ex.getMessage().contains(rate1.Id) ? true : false;
            System.AssertEquals(expectedExceptionThrown, true);
            
            expectedExceptionThrown =  ex.getMessage().contains(rate2.Id) ? true : false;
            System.AssertEquals(expectedExceptionThrown, true);
        }
        
        test.StopTest();
    } // END public static void validateRateDatesTest()
    
    public static void createTestData(){
        
        cur = TestUtils.createCurrency('CAD', 'Canada', false);
        cur.Name = 'Canadian Dollar (CAD)';
        insert cur;
        
        rate1 = TestUtils.createExchangeRate(cur.Id, 0.7, date.today(), date.today().addDays(2), false);
        rate1.Start_Date__c = date.today();
        rate1.End_Date__c = date.today().addDays(2);
        insert rate1;
        
        rate2 = TestUtils.createExchangeRate(cur.id, 0.8, date.today(), date.today().addDays(3), false);
        rate2.Start_Date__c = date.today();
        rate2.End_Date__c = date.today().addDays(3);
        
        rate3 = TestUtils.createExchangeRate(cur.id, 0.8, date.today().addDays(-1), date.today().addDays(1), false);
        rate3.Start_Date__c = rate1.Start_Date__c.addDays(-1);
        rate3.End_Date__c = rate2.End_Date__c.addDays(1);
        
    }//END private static createTestData()
    
} // END public class ExchangeRateTriggerHandlerTest