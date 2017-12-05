/***********************************************************************************************************
 * Appirio, Inc
 * Name         : AccountMergeControllerTest 
 * Created By   : Rohit B (Appirio)
 * Purpose      : Test class of AccountMergeController class
 * Created Date : 12/Jan/2016
 *
 * Date Modified                Modified By             Description of the update
  ----------------------------------------------------------------------------------------------------------
 * 08/Sep/2016                  Ashu Gupta              Worked upon the failure of this class
 **********************************************************************************************************/
@isTest
private class AccountMergeControllerTest {
	static Account NO_Acc, LP_Acc1, LP_Acc2, Com_Acc;

	@isTest 
	static void test_mergeAccounts() {
		System.debug('[RB] - AccountMergeControllerTest.test_PreferencesControllerTest :: Method Start..');
    	
    	createTestSetupData();
    	Test.setCurrentPage(Page.AccountMerge);
    	ApexPages.currentPage().getParameters().put('fromAcc', NO_Acc.Id);
    	ApexPages.currentPage().getParameters().put('toAcc', LP_Acc2.Id);
    	AccountMergeController amcRTError = new AccountMergeController();

    	ApexPages.currentPage().getParameters().put('fromAcc', '001290994NQeh');
    	ApexPages.currentPage().getParameters().put('toAcc', LP_Acc2.Id);
    	AccountMergeController amcFAError = new AccountMergeController();

    	ApexPages.currentPage().getParameters().put('fromAcc', LP_Acc1.Id);
    	ApexPages.currentPage().getParameters().put('toAcc', '001290994NQeh');
    	AccountMergeController amcSAError = new AccountMergeController();

    	ApexPages.currentPage().getParameters().put('fromAcc', LP_Acc1.Id);
    	ApexPages.currentPage().getParameters().put('toAcc', LP_Acc2.Id);
    	AccountMergeController amc = new AccountMergeController();
    	Test.startTest();
	    	amc.mergeAccounts();
	    	amc.cancel();
	    Test.stopTest();

	    List<Account> lstAcc = new List<Account>([SELECT ID, ParentId FROM Account WHERE Id =: Com_Acc.Id]);
	    //lstAcc = ;
	    System.assertEquals(lstAcc[0].ParentId, LP_Acc2.Id);

    	System.debug('[RB] - AccountMergeControllerTest.test_PreferencesControllerTest :: Method End..');
	} // END static void test_mergeAccounts() {

	static void createTestSetupData() {
    	System.debug('[RB] - AccountMergeControllerTest.createTestSetupData :: Method Start..');

    	String accNORTId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('National Office').getRecordTypeId();
        String accLPRTId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Local Partner').getRecordTypeId();
        String accComRTId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Community').getRecordTypeId();
        
    	NO_Acc = TestUtils.createAccountWithRT('Test NO Account', accNORTId, null, '123', '1345', true);
    	List<Account> localAccList = new List<Account>();
        LP_Acc1 = TestUtils.createAccountWithRT('Test LP Account 1', accLPRTId, NO_Acc, '124', '1246', false);
        LP_Acc1.Local_Partner_ID__c = '1234567';
        localAccList.add(LP_Acc1);
        
        LP_Acc2 = TestUtils.createAccountWithRT('Test LP Account 2', accLPRTId, NO_Acc, '125', '1347', false);
        LP_Acc2.Local_Partner_ID__c = '1234997';
    	localAccList.add(LP_Acc2);
    	
    	insert localAccList;
    	
        Com_Acc = TestUtils.createAccountWithRT('Test Community Account', accComRTId, LP_Acc1, '126', '1248', true);

    	System.debug('[RB] - AccountMergeControllerTest.createTestSetupData :: Method End..');
    } // END static void createTestSetupData() {
}