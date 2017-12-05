/***********************************************************************************************************
 * Appirio, Inc
 * Name         : ProcessExchangeRatesControllerTest
 * Created By   : Karl Houseknecht (Appirio)
 * Purpose      : Test class for Controller class of Process Exchange Rates listview selection/confirmation page
 * Created Date : 01/08/2016
 *
 * Date Modified                Modified By             Description of the update
  ----------------------------------------------------------------------------------------------------------
 * 01/08/2016					Karl Houseknecht		Created
 * 08/12/2016					Karl Houseknecht		Created
 * 08/29/2016                   Ashu Gupta              Added asserts
 **********************************************************************************************************/
@isTest
public class ProcessExchangeRatesControllerTest
{
	public static List<Exchange_Rate__c> rates;
	public static Exchange_Rate__c canRate;
	public static Currency__c canCurrency;
	public static testMethod void textProcessExchangeRatesController()
    {   
        ApexPages.Message[] pageMessages;
    	createTestData();
    	Test.startTest();
        PageReference ref = Page.ProcessExchangeRates;
        Test.setCurrentPage(ref);
        ApexPages.StandardSetController standardController = new ApexPages.StandardSetController(rates);
        standardController.setSelected(rates);
        ProcessExchangeRatesController controller = new ProcessExchangeRatesController(standardController);
        
        controller.retURL = '/' + canRate.Id;
        PageReference pr = controller.updateExchangeRateStatus();
        System.assertEquals(pr,null);
        
        pr = controller.processExchangeRates();
        pageMessages = ApexPages.getMessages();
        System.assertEquals(pr,null);
        //verify whether batch is submitted or not
        System.assertEquals(pageMessages[0].getSummary().contains('Exchange Rate batch job with id'), true);
        
        pr = controller.returnToListView();
        system.assertEquals(pr.getURL(),new PageReference(controller.retURL).getURL());
        System.assertEquals(controller.isJobStatusRendered, true);
        
        Test.stopTest();
        
        controller.refreshJobInfo();
        pageMessages = ApexPages.getMessages();
        //to verify the status of batch job
        System.assertEquals(pageMessages[1].getSummary().contains('Exchange Rate batch job has completed.'), true);
        System.assertEquals(controller.jobs[0].Status,'Completed');
    }
    public static void createTestData(){
    	 //test data setup
        canCurrency = TestUtils.createCurrency('CAN','Canada', false);
        canCurrency.Name = 'Canadian Dollar (CAN)';
        insert canCurrency;
        
        canRate = TestUtils.createExchangeRate(canCurrency.Id, 0.71, date.today().addDays(-1), date.today().addDays(1), false);
        canRate.Status__c = 'Process';
        insert canRate;
        
        rates = new List<Exchange_Rate__c>();
		rates.add(canRate);
    }
}