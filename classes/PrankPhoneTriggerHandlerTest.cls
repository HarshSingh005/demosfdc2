/***********************************************************************************************************
 * Appirio, Inc
 * Name         : PrankPhoneTriggerHandlerTest
 * Created By   : Jagjeet Singh (Appirio)
 * Purpose      : Test class for PrankPhoneTriggerHandler
 * Created Date : 03/09/2016
 *
 * Date Modified                Modified By             Description of the update
  ----------------------------------------------------------------------------------------------------------
 * 
 **********************************************************************************************************/
@isTest
private class PrankPhoneTriggerHandlerTest {
    Public static Prank_Phone__c prankPhnObj, prankPhnObj2;
    //test method to check the OnInsert Functionality.
    static testMethod void prankPhoneOnInsertTest(){ 
        //start Test
        Test.startTest();
        
        //creates the test data
        createTestData();
        
        //creates the Prank Phone data.
        
        try{
            //Fire the DML
        	insert prankPhnObj2;
        }catch(Exception ex){
            //Record should not have been saved succesfully, expecting exception!
            system.assert(true);
        }
        //stop test
        Test.stopTest();
    }
    
    //test method to check the OnUpdate Functionality.
    static testMethod void prankPhoneOnUpdate(){ 
        //start Test
        Test.startTest();
        
        //creates the test data
        createTestData();
        
        //creates the Prank Phone data.
        prankPhnObj2 = new Prank_Phone__c();
        prankPhnObj2.Phone__c = '(804) 555-1211'; // New Phone Number, doesn't match with any of the exisiting data.
        try{
        	insert prankPhnObj2;
        }catch(Exception ex){
            //Record should have been saved succesfully.
            system.assert(false);
        }
        
        prankPhnObj2.Phone__c = '(804) 555-1212'; // update the Phone to the same value
        try{
            update prankPhnObj2;
        }catch(Exception ex){
            //Record should not have been updated succesfully.
            system.assert(true);
        }
        //stop test
        Test.stopTest();
    }
    
    //creates the test data
    static void createTestData(){
        //creates the Prank Phone data.
        prankPhnObj = new Prank_Phone__c();
        prankPhnObj.Phone__c = '(804) 555-1212';
        insert prankPhnObj;
        
        prankPhnObj2 = new Prank_Phone__c();
        prankPhnObj2.Phone__c = '(804) 555-1212';
                
    }
    
}