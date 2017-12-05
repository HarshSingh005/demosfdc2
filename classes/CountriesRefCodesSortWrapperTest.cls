/***********************************************************************************************************
 * Appirio, Inc
 * Name         : CountriesRefCodesSortWrapperTest
 * Created By   : Munib Ur Rehman (Appirio)
 * Purpose      : Test Class for CountriesRefCodesSortWrapper
 * Created Date : 07/04/2016
 *
 * Date Modified                Modified By             Description of the update
  ----------------------------------------------------------------------------------------------------------
 * 07/04/2016                   Munib Ur Rehman        Created
 **********************************************************************************************************/
 @isTest
public with sharing class CountriesRefCodesSortWrapperTest {
	@isTest
	public static void TestCountriesRefCodesSortWrapper(){
		Test.startTest();
		List<CountriesRefCodesSortWrapper> listOfCodes = new List<CountriesRefCodesSortWrapper>();
		
		CountriesRefCodes__c code1 = TestUtils.createCountriesRefCodes('CRC1',true, 'IND', false);
		code1.Description__c = '3DES';
		CountriesRefCodesSortWrapper wrap1 = new CountriesRefCodesSortWrapper(code1);
		listOfCodes.add(wrap1);
		
		// Assertion | there is only one element in the list so its at the first position
		System.assertEquals('3DES', listOfCodes.get(0).CountriesRefCodes.Description__c);
		
		CountriesRefCodes__c code2 = TestUtils.createCountriesRefCodes('CRC2',true, 'USA', false);
		code2.Description__c = '1D';
		CountriesRefCodesSortWrapper wrap2 = new CountriesRefCodesSortWrapper(code2);
		listOfCodes.add(wrap2);
		
		// Assertion | both the elements are in the order they were inserted in the list
		System.assertEquals('3DES', listOfCodes.get(0).CountriesRefCodes.Description__c);
		System.assertEquals('1D', listOfCodes.get(1).CountriesRefCodes.Description__c);
		
		CountriesRefCodes__c code3 = TestUtils.createCountriesRefCodes('CRC3',true, 'IND', false);
		code3.Description__c = '2DE';
		CountriesRefCodesSortWrapper wrap3 = new CountriesRefCodesSortWrapper(code3);
		listOfCodes.add(wrap3);
		
		// Assertion | all the elements are in the order they were inserted in the list
		System.assertEquals('3DES', listOfCodes.get(0).CountriesRefCodes.Description__c);
		System.assertEquals('1D', listOfCodes.get(1).CountriesRefCodes.Description__c);
		System.assertEquals('2DE', listOfCodes.get(2).CountriesRefCodes.Description__c);
		
		// Sorting the list | The list will be sorted on the basis of length of description as per the compareTo() method defined
		listOfCodes.sort();
		
		// Assertion | All the elements are now sorted on the basis of lenghth of the description i.e 1D < 2DE < 3DES
		System.assertEquals('1D', listOfCodes.get(0).CountriesRefCodes.Description__c);
		System.assertEquals('2DE', listOfCodes.get(1).CountriesRefCodes.Description__c);
		System.assertEquals('3DES', listOfCodes.get(2).CountriesRefCodes.Description__c);

		Test.StopTest();
	}
}