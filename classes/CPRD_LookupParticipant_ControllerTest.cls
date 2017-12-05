/***********************************************************************************************************
 * Appirio, Inc
 * Name         : CPRD_LookupParticipant_ControllerTest
 * Created By   : Ashu Gupta (Appirio)
 * Purpose      : Test class for CPRD_LookupParticipant_Controller
 * Created Date : 29/07/2016
 *
 * Date Modified                Modified By             Description of the update
  ----------------------------------------------------------------------------------------------------------
 * 27/09/2016                   Ashu Gupta              Created
 **********************************************************************************************************/
@isTest
private class CPRD_LookupParticipant_ControllerTest {
    
    Static Account acc;
    Static Contact participant;
    
    private static testMethod void test() {
        
        test.startTest();
        
        createTestData();
        
        CPRD_LookupParticipant_Controller controllerInstance = new CPRD_LookupParticipant_Controller();
        controllerInstance.runQuery();
        system.assertEquals(controllerInstance.contacts, null);
        
        controllerInstance.query = 'Test';
        
        controllerInstance.runQuery();
        system.assertEquals(controllerInstance.doneLookup,true);
        system.assertNotEquals(controllerInstance.contacts, null);
        
        
        test.StopTest();
    }
    
    private static void createTestData(){
        
        acc = TestUtils.createAccount('My Unit test', true);
        
        participant = TestUtils.createContact(acc, 'Unit test', 'Apex', false);
        participant.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Participant').getRecordTypeId();
        participant.rC_Sponsorship__Sponsorship_Status__c = 'Pre-Sponsored';
        participant.Participant_Case_Number__c = '12345';
        participant.Correspondence_Paused__c = true;
        insert participant;
        
    }

}