/***********************************************************************************************************
 * Appirio, Inc
 * Name         : TriggerStateTest 
 * Created By   : Rohit B (Appirio)
 * Purpose      : Test class for TriggerState class.
 * Created Date : 16/Dec/2015
 *
 * Date Modified                Modified By             Description of the update
  ----------------------------------------------------------------------------------------------------------
 * Aug 08, 2016                 Ashu Gupta              Increased code coverage
 * Aug 10, 2016                 Ravi Chauhan            Covered Exception Scenario
 **********************************************************************************************************/
@isTest
private class TriggerStateTest {
	static  TriggerSettings__c triggerSettingObj1,triggerSettingObj2;
	@isTest 
	static void test_method1() {
		
		createTestData();
        Boolean isActiveValue = TriggerState.isActive('AccountTrigger1');
        //System.assertEquals(false,isActiveValue );
        Boolean isTestModeValue= TriggerState.executeForTestMethods('AccountTrigger1');
        System.assertEquals(false,isTestModeValue);
    } // END static void test_method1() {
    
    @isTest 
	static void test_method2() {
		createTestData();
		
        Boolean isActiveValue = TriggerState.isActive('AccountTrigger2');
        Boolean isTestModeValue= TriggerState.executeForTestMethods('AccountTrigger2');
        System.assertEquals(true,isTestModeValue);
        
	}// END static void test_method2() {
	
	// Ravi Chauhan | 10 Aug 2016 | Test method to cover the exception scenario
	@isTest
	static void test_method3(){
	    createTestData();
        TriggerState.shouldThrowException = true;
		Boolean isActiveValue = TriggerState.isActive('AccountTrigger2');
	}
	
	static void createTestData(){
	    List<TriggerSettings__c> triggerSettList =  new List<TriggerSettings__c>();
	    triggerSettingObj1 = new TriggerSettings__c();
		triggerSettingObj1.Name = 'AccountTrigger1';
		triggerSettingObj1.isTestMode__c = false;
		triggerSettingObj1.isActive__c = false;
		triggerSettList.add(triggerSettingObj1);
		
	    triggerSettingObj2 = new TriggerSettings__c();
		triggerSettingObj2.Name = 'AccountTrigger2';
		triggerSettingObj2.isTestMode__c = true;
		triggerSettingObj2.isActive__c = false;
		triggerSettList.add(triggerSettingObj2);
		insert triggerSettList;
	}
	// END static void createTestData() {
    
}