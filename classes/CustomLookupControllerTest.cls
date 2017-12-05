/***********************************************************************************************************
 * Appirio, Inc
 * Name         : CustomLookupControllerTest
 * Created By   : Ashu Gupta (Appirio)
 * Purpose      : Test class for the CustomLookupController
 * Created Date : July 29, 2016
 *
 **********************************************************************************************************/

@isTest
private class CustomLookupControllerTest {

	private static testMethod void testAccountsObject(){
	    Test.startTest();
	    PageReference pageRef = Page.CustomLookupPage;
        Test.setCurrentPage(pageRef);

	    ApexPages.currentPage().getParameters().put('lookupType', 'Account');
        CustomLookupController controller = new CustomLookupController();
        PageReference pageRefReturned = controller.redirectToLookupPage();
        
        PageReference pageRefAcc = Page.AccountLookupPage;
        System.assertEquals(pageRefAcc.getURL(),pageRefReturned.getURL());
        Test.stopTest();
        
	}

}