/***********************************************************************************************************
 * Appirio, Inc
 * Name         : createReciprocalAllianceControllerTest
 * Created By   : Rohit B. (Appirio)
 * Purpose      : Test class of createReciprocalAllianceController class
 * Created Date : 16/Aug/2016
 *
 * Date Modified                Modified By             Description of the update
  ----------------------------------------------------------------------------------------------------------
 * 29 Aug 2016                  Ashu Gupta              Added asserts
 **********************************************************************************************************/

@isTest
public class createReciprocalAllianceControllerTest { 
	static Obligation__c obl;
	@isTest
    private static void testMethod1() {
		createTestData();
        ApexPages.Message[] pageMessages;
        Test.startTest();
            // creating page reference for the page and mark it as current page
            Test.setCurrentPage(Page.createReciprocalAlliancePage);
            createReciprocalAllianceController rpc = new createReciprocalAllianceController();
			PageReference pr = rpc.save();
			pageMessages = ApexPages.getMessages();
			System.assertEquals(pr.getURL(),new PageReference('/' + rpc.rpfq.Id).getURL());
            System.assertEquals(pageMessages[0].getSummary().contains('Record Saved Successfully'), true);
            
			rpc.rpfq.File_Type__c = 'New';
			rpc.rpfq.Alliance__c = 'Australia';
			rpc.rpfq.Start_Date__c = System.today();
			rpc.rpfq.End_Date__c = System.today().addMonths(3);
			pr = rpc.save();
			System.assertEquals(pr,null);
			
			
			pr = rpc.cancel();
            System.assertEquals(new PageReference('/home/home.jsp').getURL(),pr.getURL());
			
			Test.setCurrentPage(Page.createReciprocalAlliancePage);
			ApexPages.currentPage().getParameters().put('id', obl.Id);
			rpc.retURL = obl.Id;
			rpc.rpfq.File_Type__c = 'Regenerated';
			rpc.rpfq.Alliance__c = 'Denmark';
			rpc.rpfq.Start_Date__c = System.today();
			rpc.rpfq.End_Date__c = System.today().addMonths(5);
			pr = rpc.save();
		    System.assertEquals(pr,null);
			pr = rpc.cancel();
            System.assertEquals(new PageReference('/' + rpc.retURL).getURL(),pr.getURL());
			
        Test.stopTest(); 

		Reciprocal_Alliance_File_Queue__c rafq = [SELECT Id, Name from Reciprocal_Alliance_File_Queue__c WHERE Id = :rpc.rpfq.Id];
		System.assertNotEquals(null, rafq);
    }
    
    private static void createTestData(){
        Account accNO = TestUtils.createAccount('Test Account', false);
		accNO.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('National Office').getRecordTypeId();
        accNO.National_Office_Id__c = '899';
        insert accNO;

         obl = TestUtils.createObligation(accNO, true);
    }
}