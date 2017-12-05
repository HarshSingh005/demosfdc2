/***********************************************************************************************************
 * Appirio, Inc
 * Name         : AccountLookupControllerTest 
 * Created By   : Ashu Gupta (Appirio)
 * Purpose      : Test class of AccountLookupController class
 * Created Date : July 27, 2016
 *
 * Date Modified                Modified By             Description of the update
  ----------------------------------------------------------------------------------------------------------
 * [Date]                       [Person Name]           [Short Description]
 **********************************************************************************************************/

@isTest
private class AccountLookupControllerTest {
    
    static Account acc1,acc2;
    static list<Account> accList;
	private static testMethod void test_doSearch() {
	    
	    Test.startTest();
	    AccountLookupController accLookUpController = new AccountLookupController();
	    Test.setCurrentPage(Page.AccountLookupPage);
	    accLookUpController.searchtxt = 'testAcc1';
	    
	    accLookUpController.doSearch();
	    System.assertEquals(accLookUpController.doneSearch, true);
	    test.stopTest();
	    

	}
	static void createTestData(){
	    
	    acc1 = TestUtils.createAccount('testAcc1',false);
	    acc1.Type = 'Internal';
	    accList.add(acc1);
	    
	    acc2 = TestUtils.createAccount('TestAcc2',false);
	    accList.add(acc2);
	    insert accList;
	    
	}

}