/***********************************************************************************************************
 * Appirio, Inc
 * Name         : StateTerrProvRefCodesSortWrapperTest
 * Created By   : Munib Ur Rehman (Appirio)
 * Purpose      : Test Class for StateTerrProvRefCodesSortWrapper
 * Created Date : 08/04/2016
 *
 * Date Modified                Modified By             Description of the update
  ----------------------------------------------------------------------------------------------------------
 * 08/04/2016                   Munib Ur Rehman        Created
 **********************************************************************************************************/
 @isTest
public with sharing class StateTerrProvRefCodesSortWrapperTest {
	@isTest
	public static void TestStateTerrProvRefCodesSortWrapper(){
		Test.startTest();
		List<StateTerrProvRefCodesSortWrapper> listOfCodes = new List<StateTerrProvRefCodesSortWrapper>();
		
		StateTerrProvRefCodes__c code1 = new StateTerrProvRefCodes__c();
		code1.Description__c = 'desc1';
		StateTerrProvRefCodesSortWrapper wrap1 = new StateTerrProvRefCodesSortWrapper(code1);
		listOfCodes.add(wrap1);
		
		StateTerrProvRefCodes__c code2 = new StateTerrProvRefCodes__c();
		code2.Description__c = 'desc2';
		StateTerrProvRefCodesSortWrapper wrap2 = new StateTerrProvRefCodesSortWrapper(code2);
		listOfCodes.add(wrap2);
		
		StateTerrProvRefCodes__c code3 = new StateTerrProvRefCodes__c();
		code3.Description__c = 'desc3';
		StateTerrProvRefCodesSortWrapper wrap3 = new StateTerrProvRefCodesSortWrapper(code3);
		listOfCodes.add(wrap3);
		
		listOfCodes.sort();
		System.assertEquals(listOfCodes.get(0).StateRefCodes.Description__c, 'desc1');
		Test.stopTest();
		
	}
}