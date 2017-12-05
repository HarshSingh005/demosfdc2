/***********************************************************************************************************
 * Appirio, Inc
 * Name         : OpportunityLegacyPaymentTransactionTest
 * Created By   : Munib Ur Rehman (Appirio)
 * Purpose      : Test class for the OpportunityLegacyPaymentTransaction
 * Created Date : 29/01/2016
 *
 * Date Modified                Modified By             Description of the update
  ----------------------------------------------------------------------------------------------------------
 * 29/01/2016                   Munib Ur Rehman       Created
 * Aug 12, 2016                 Ashu Gupta              Increased code coverage and added asserts
 **********************************************************************************************************/
@isTest
public with sharing class OpportunityLegacyPaymentTransactionTest
{   
    Final Static Id nationalAccRecId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('National Office').getRecordTypeId();
    Final Static Id localAccRecId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Local Partner').getRecordTypeId();
    Final Static Id commAccRecId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Community').getRecordTypeId();
    Final Static Id conParticipantRecId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Participant').getRecordTypeId();
    static Account acc, nationalOffice, localPartner, community;
    static Contact participant;
    @isTest
	public static void testOpportunityLegacyPaymentTransaction() {
        
        createTestData();
        //added account into account list
        List<Account> accList = new List<Account>();
        accList.add(community);
        
         Test.startTest();
         ApexPages.Message[] pageMessages;
        // creating page reference for the page and mark it as current page
        PageReference pageRef = Page.OpportunityLegacyPaymentTransaction;
        Test.setCurrentPage(pageRef);
        
        // calling standard set controller 
        ApexPages.StandardSetController sc = new ApexPages.StandardSetController(accList);
        sc.setSelected(accList);
        
        //pageRef.getParameters().put('id', String.valueOf(community.Id));
        OpportunityLegacyPaymentTransaction testOpp = new OpportunityLegacyPaymentTransaction(sc);
        System.assertEquals(testOpp.isTimerEnabled,true);
        System.assertEquals(testOpp.interestPayment,0.0);
        
        PageReference pr = testOpp.submitCPRRequest();
        pageMessages = ApexPages.getMessages();
        System.assertEquals(pageMessages[0].getSummary().contains('Batch job with id'), true);
        
        System.assertEquals(testOpp.isProcessButtonRendered,false);
        System.assertEquals(testOpp.isReturnButtonRendered,true);
        System.assertEquals(testOpp.isJobStatusRendered,true);
        System.assertEquals(testOpp.isTimerEnabled,true);
        System.assertEquals(pr,null);
        
        System.debug('batch id@@@'+testOpp.batchprocessid);
        System.debug('status@@@'+testOpp.jobs[0].status);
        testOpp.refreshJobInfo();
        System.assertEquals(testOpp.jobs.size(),1);
        //test ends
        System.debug('status2@@@'+testOpp.jobs[0].status);
        
    	Test.stopTest();
    	 testOpp.refreshJobInfo();
    	System.debug('status3@@@'+testOpp.jobs[0].status);
    	system.assertEquals(testOpp.jobs[0].status,'Completed');
    	 pageMessages = ApexPages.getMessages();
        System.assertEquals(pageMessages[1].getSummary().contains('CPR Request batch job has completed.'), true);
    	
    } // END public static void testOpportunityLegacyPaymentTransaction() {
    
    static void createTestData(){
        List<Account> listAccToInsert = new List<Account>();
        
        acc = TestUtils.createAccount('My Unit test', false);
        listAccToInsert.add(acc);
        
        nationalOffice = TestUtils.createAccountWithRT('National Office', nationalAccRecId, null,'899', null, false);
        listAccToInsert.add(nationalOffice);
        insert listAccToInsert;
        
        localPartner = TestUtils.createAccountWithRT('Local Partner', localAccRecId, nationalOffice, '908', '1331', true);
        
        community = TestUtils.createAccountWithRT('Community', commAccRecId, localPartner ,null,'3457' , true);
        
        // creating contact record
        participant = TestUtils.createContact(acc,'Joe','Kid',false);
        participant.Community__c = community.id;
        participant.RecordTypeId = conParticipantRecId;
        participant.Participant_Case_Number__c = '87654';
        participant.rC_Sponsorship__Sponsorship_Status__c = 'Sponsored';
        insert participant;
    }
    
} // END public with sharing class OpportunityLegacyPaymentTransactionTest