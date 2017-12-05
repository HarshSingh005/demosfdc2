/***********************************************************************************************************
 * Appirio, Inc
 * Name         : StandardAllocationServiceTest
 * Created By   : Munib Ur Rehman (Appirio)
 * Purpose      : Test class for the StandardAllocationService
 * Created Date : 11/02/2016
 *
 * Date Modified                Modified By             Description of the update
  ----------------------------------------------------------------------------------------------------------
 * 11/02/2016                   Munib Ur Rehman       Created
 * 03/21/2017					Suminder Singh		  Modified for data errors and code coverage
 **********************************************************************************************************/
@isTest
public with sharing class StandardAllocationServiceTest
{
	public static testMethod void testStandardAllocationService()
    {
        //create account and contact data
        Date currentDate = System.Date.today();
        rC_Giving__GAU__c gau = TestUtils.createGeneralAccountingUnit('3333', true);
        Standard_Allocation__c standardAllocate = TestUtils.createStandardAllocation('Allocation1',gau.Id,false);//Fixed for date errors
        //Added data for date fields
        standardAllocate.Start_Date__c = currentDate.addDays(-10);
        standardAllocate.End_Date__c = currentDate.addDays(10);
        insert standardAllocate;
        Standard_Allocation__c standardAllocate2 = TestUtils.createStandardAllocation('Allocation2',gau.Id,false);//Fixed for date errors
        //Added data for date fields
        standardAllocate2.Start_Date__c = currentDate.addDays(-10);
        standardAllocate2.End_Date__c = currentDate.addDays(10);
        insert standardAllocate2;
        //test starts
        Test.startTest();
        standardAllocate.Credit__c = 15.0;
        standardAllocate.Debit__c = 15.0;
        update standardAllocate;
        List<rC_Giving__GAU__c> gauList = new List<rC_Giving__GAU__c>();
        gauList = [select Id, Balanced__c from rC_Giving__GAU__c];
        System.assertEquals(gauList.get(0).Balanced__c, true);
        standardAllocate2.Credit__c = 15.0;
        standardAllocate2.Debit__c = 16.0;
        update standardAllocate2;
    	Test.stopTest();
    	gauList = new List<rC_Giving__GAU__c>();
    	gauList = [select Id, Balanced__c from rC_Giving__GAU__c];
        System.assertEquals(gauList.get(0).Balanced__c, false);
    }
     
}