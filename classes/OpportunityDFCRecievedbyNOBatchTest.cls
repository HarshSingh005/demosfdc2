/***********************************************************************************************************
 * Appirio, Inc
 * Name         : OpportunityDFCRecievedbyNOBatchTest
 * Created By   : Munib Ur Rehman (Appirio)
 * Purpose      : Test Class for OpportunityDFCReceivedbyNOBatch
 * Created Date : 07/04/2016
 *
 * Date Modified                Modified By             Description of the update
  ----------------------------------------------------------------------------------------------------------
 * 07/04/2016                   Munib Ur Rehman        Created
 **********************************************************************************************************/
 @isTest
 public with sharing class OpportunityDFCRecievedbyNOBatchTest {
 	public static Opportunity testOpp2;
 	public static Account NO_Acc;
 	@isTest  
 	public static void OpportunityDFCReceivedbyNOBatch(){
 		createTestData();
 		
 		testOpp2.DFC_status__c = 'Sent to NO';
 		update testOpp2;
 		
 		Test.startTest();
        id batchId = Database.executeBatch(new OpportunityDFCReceivedbyNOBatch(NO_Acc.Id, System.today()), 200);
        List<Mail_Control_Slip__c> slipList = [select Id from Mail_Control_Slip__c];
        System.assertEquals(slipList.size(),0); 
 		Test.StopTest();
 		
 	}
 	
 	public static void createTestData(){
 		Account acc = TestUtils.createAccount('testAcc', true);
 		Id ACC_NO_RT = Schema.SObjectType.Account.getRecordTypeInfosByName().get('National Office').getRecordTypeId();
 		NO_Acc = TestUtils.createAccountWithRT('1st National Account test', ACC_NO_RT, null, '209', '21245', false);
        insert NO_Acc;
        
         Id participantRecordTypeId = 
                Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Participant').getRecordTypeId();
        Contact kid = TestUtils.createContact(acc, 'Good', 'Kid', false);
        kid.RecordTypeId = participantRecordTypeId;
        kid.Participant_Case_Number__c = '12345';
        kid.rC_Sponsorship__Sponsorship_Status__c = 'Available';
        insert kid;
        
        Double amt = 100;
        Opportunity testOpp1 = TestUtils.createOpportunity(acc, 'testOpportunity', amt , false);
    	testOpp1.StageName = 'Completed';
    	testOpp1.CloseDate = system.today() + 30;
    	testOpp1.recordTypeId  = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Transaction').getRecordTypeId();
    	testOpp1.Participant__c = kid.Id;
        testOpp1.rC_Giving__Giving_Amount__c = 100;
        testOpp1.Legacy_Type__c = 'Term';
        testOpp1.DFC_status__c = 'Sent to NO';
        testOpp1.Product_Type__c = 'Designated Fund';
        insert  testOpp1;
        
        testOpp2 = TestUtils.createOpportunity(acc, 'testOpportunity', amt , false);
    	testOpp2.StageName = 'Completed';
    	testOpp2.CloseDate = system.today() + 30;
    	testOpp2.recordTypeId  = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Transaction').getRecordTypeId();
    	testOpp2.Participant__c = kid.Id;
        testOpp2.rC_Giving__Giving_Amount__c = 100;
        testOpp2.Legacy_Type__c = 'Term';
        testOpp2.DFC_status__c = 'Sent to NO';
        testOpp2.rC_Giving__Parent__c = testOpp1.Id;
        insert  testOpp2;
        
        Obligation__c obligation = TestUtils.createObligation(NO_Acc, false);
 		obligation.Release_Date__c = System.today();
 		insert obligation;
        
 		rC_Giving__GAU__c gau = TestUtils.createGeneralAccountingUnit('testGAU',true);
        List<GL_Allocation__c> allocationList = new List<GL_Allocation__c>();
 		GL_Allocation__c allocation = new GL_Allocation__c();
 		allocation.GL_Account__c = gau.Id;
 		allocation.isObligation__c = true;
 		allocation.Transaction__c = testOpp2.Id;
 		allocation.Obligation__c = obligation.Id;
 		allocationList.add(allocation);
 		insert allocationList;
 		
 	}
}