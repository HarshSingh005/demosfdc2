/***********************************************************************************************************
 * Appirio, Inc
 * Name         : EmailExclusionBatchTest
 * Created By   : Munib Ur Rehman (Appirio)
 * Purpose      : Test class for the EmailExclusionBatch
 * Created Date : 19/07/2016
 *
 * Date Modified                Modified By             Description of the update
  ----------------------------------------------------------------------------------------------------------
 * 19/07/2016                   Munib Ur Rehman       Created
 **********************************************************************************************************/
@isTest
public with sharing class EmailExclusionBatchTest
{
    static Contact participant,participant2;
    @isTest
	public static void testEmailExclusionBatch() {
		createTestData();
		
        //test starts
        Test.startTest();
        Database.executebatch(new EmailExclusionBatch());
		//test stops        
        Test.stopTest();
        
        // assertion done to check no. of records in Email_Exclusion__c
        List<Email_Exclusion__c> exclusionsDeleted = [select Id from Email_Exclusion__c];
        System.assertEquals(exclusionsDeleted.size() , 0);
        
        Contact part = [SELECT ID,No_Email_Birthday_Communications__c,No_Email_Newsletters__c,No_Email_Statement_Communications__c
                        FROM Contact 
                        WHERE id=:participant.id];
        //to check No_Email_Birthday_Communications__c                
        System.assertEquals(part.No_Email_Birthday_Communications__c,false);
        //to check No_Email_Newsletters__c
        System.assertEquals(part.No_Email_Newsletters__c,true);
        //to check No_Email_Statement_Communications__c
        System.assertEquals(part.No_Email_Statement_Communications__c,false);
        
        Contact donor = [SELECT ID,No_Email_Birthday_Communications__c,No_Email_Newsletters__c,No_Email_Statement_Communications__c
                        FROM Contact 
                        WHERE id=:participant2.id];
                        
        //to check No_Email_Birthday_Communications__c
        System.assertEquals(donor.No_Email_Birthday_Communications__c,true);
        //to check No_Email_Newsletters__c
        System.assertEquals(donor.No_Email_Newsletters__c,false);
        //to check No_Email_Statement_Communications__c
        System.assertEquals(donor.No_Email_Statement_Communications__c,true);
        
        
    } 
    
    
     @isTest
    public static void testExecuteSchedule(){
        
        
        Test.StartTest();
        EmailExclusionBatch objBatch = new EmailExclusionBatch();
        String sc = '0 0 23 * * ?';
        String jobId = system.schedule('Test sc Check', sc, objBatch); 
        Test.StopTest();
        
        System.debug('@@@jobId'+jobId);
        //to check jobId is not null
        System.assertNotEquals(jobId,null);
       
       
       
    }
    
    static void createTestData(){
        List<Account> accListToInsert = new List<Account>();
        Account acct = TestUtils.createAccount('Acc1', false);
        accListToInsert.add(acct);
    	//create account and contact data
    	Account nationalOffice = TestUtils.createAccount('National Office', false);
        nationalOffice.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('National Office').getRecordTypeId();
        nationalOffice.National_Office_Id__c = '899';
        accListToInsert.add(nationalOffice);
        
        insert accListToInsert;
        
        Account localPartner = TestUtils.createAccount('Local Partner', false);
        localPartner.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Local Partner').getRecordTypeId();
        localPartner.ParentId = nationalOffice.Id;
        localPartner.Local_Partner_ID__c = '1233122';
        insert localPartner;
        
        List<Account> accCommList = new List<Account>();
        
        Account community = TestUtils.createAccount('Community', false);
        community.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Community').getRecordTypeId();
        community.ParentId = localPartner.Id;
        community.Community_Id__c = '3456';
        accCommList.add(community);
        
        Account community2 = TestUtils.createAccount('Community2', false);
        community2.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Community').getRecordTypeId();
        community2.ParentId = localPartner.Id;
        community2.Community_Id__c = '9912';
        accCommList.add(community2);        
        
        insert accCommList;
        
        List<Contact> conList = new List<Contact>();
        
        participant = TestUtils.createContact(acct,  'Joe', 'Kid', false);
        participant.Community__c = community.id;
        participant.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Household').getRecordTypeId();
        participant.Participant_Case_Number__c = '87654';
        participant.Email = 'test@salesforce.com';
        participant.rC_Sponsorship__Sponsorship_Status__c = 'Sponsored';
        conList.add(participant);
        
        participant2 = TestUtils.createContact(acct,  'Joe1', 'Kid1', false);
        participant2.Community__c = community.id;
        participant2.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Household').getRecordTypeId();
        participant2.Participant_Case_Number__c = '49874';
        participant2.Email = 'test1@salesforce.com';
        participant2.rC_Sponsorship__Sponsorship_Status__c = 'Sponsored';
        conList.add(participant2);
        
        insert conList;
        //adding accounts into list
        List<Account> accList = new List<Account>();
        accList.add(community);
        accList.add(community2);
        
        
        
        Email_Exclusion__c exclusion1 = TestUtils.createEmailExclusion('exclusion1', 'test@salesforce.com', 'EC', true);
        
        Email_Exclusion__c exclusion2 = TestUtils.createEmailExclusion('exclusion2', 'test1@salesforce.com', 'BDAY', true);
        
        //Added by Ashu Gupta to increase code coverage
        Email_Exclusion__c exclusion3 = TestUtils.createEmailExclusion('exclusion2', 'test1@salesforce.com', 'SA', true);
        
        List<Email_Exclusion__c> exclusionList = new List<Email_Exclusion__c>();
        exclusionList.add(exclusion1);
        exclusionList.add(exclusion2);
        exclusionList.add(exclusion3);
        
        
        
    }
} // END public with sharing class EmailExclusionBatchTest