/***********************************************************************************************************
 * Appirio, Inc
 * Name         : MCSCPRRequestBatchTest
 * Created By   : Munib Ur Rehman (Appirio)
 * Purpose      : Test class for the MCSCPRRequestBatch
 * Created Date : 27/01/2016
 *
 * Date Modified                Modified By             Description of the update
  ----------------------------------------------------------------------------------------------------------
 * 27/01/2016                   Munib Ur Rehman         Created
 * 29/Nov/2016					Suminder Singh			Fixed failure of this class by creating valid data.	
 * 17/Jan/2017					Suminder Singh			Fixed for failures
 * 5/Apr/2017					Harsh Singh				Fixed for Failures					
 **********************************************************************************************************/
@isTest
public with sharing class MCSCPRRequestBatchTest
{
    static  List<Account> accList ;
    @isTest
	public static void testMCSCPRRequestBatch() {
        createTestData();
        //test starts
        Test.startTest();
			Database.executebatch(new MCSCPRRequestBatch(accList, true));
		//test stops        
        Test.stopTest();
        
        // assertion done to check no. of records in Mail_Control_Slip__c
        List<Mail_Control_Slip__c> MCSToInsert = [select Id from Mail_Control_Slip__c];
        System.assertEquals(MCSToInsert.size() , 1);
        System.assertEquals([select MCS_Letter_Type__c from Mail_Control_Slip__c Limit 1].MCS_Letter_Type__c , 'Child Progress Report');
    } // END public static void testMCSCPRRequestBatch() {
    @isTest
	public static void testMCSCPRRequestBatchFalse() {
        createTestData1();
        //test starts
        Test.startTest();
        MCSCPRRequestBatch obj = new MCSCPRRequestBatch(accList, false);
        Database.executebatch(obj);
		//test stops        
        Test.stopTest();
        
        // assertion done to check no. of records in Mail_Control_Slip__c
        List<Mail_Control_Slip__c> MCSToInsert = [select Id from Mail_Control_Slip__c];
        System.assertEquals(MCSToInsert.size() , 1);
        System.assertEquals([select MCS_Letter_Type__c from Mail_Control_Slip__c Limit 1].MCS_Letter_Type__c , 'Child Progress Report');
  
        
    } // END public static void testMCSCPRRequestBatchFalse() {
    static void createTestData(){
        	//create account and contact data
        Account acc = TestUtils.createAccount('testAcc',true);
        
        Account acc1 = TestUtils.createAccount('My Unit test Acc', false);
        acc1.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Household').getRecordTypeId();
        insert acc1;
        
    	Account nationalOffice = TestUtils.createAccount('National Office', false);
        nationalOffice.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('National Office').getRecordTypeId();
        nationalOffice.National_Office_Id__c = '899';
        insert nationalOffice;
        
        Account localPartner = TestUtils.createAccount('Local Partner', false);
        localPartner.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Local Partner').getRecordTypeId();
        localPartner.ParentId = nationalOffice.Id;
        localPartner.Local_Partner_ID__c = '1121145';
        insert localPartner;
      
        
        
        Account community = TestUtils.createAccount('Community', false);
        community.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Community').getRecordTypeId();
        community.ParentId = localPartner.Id;
        community.Community_Id__c = '3456';
        insert community; 
        
       
        
        //adding accounts into list
        accList = new List<Account>();
        accList.add(community);
         String RT_ACC_CFUND=Schema.SObjectType.Account.getRecordTypeInfosByName().get('ChildFund').getRecordTypeId();
         Account chAccount = TestUtils.createAccountWithRT('Test Household Account1', RT_ACC_CFUND, acc, '666', '3843', false);
        chAccount.Alliance__c  = true;
        insert chAccount;
        
        Contact participant = TestUtils.createContact(null, 'Joe', 'Kid', false);
        
        participant.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Participant').getRecordTypeId();
  	    participant.rC_Sponsorship__Sponsorship_Status__c ='Sponsored';
        participant.Correspondence_Paused__c = false;
        participant.Participant_Case_Number__c = '18395';
        participant.Accept_DF_Fee__c = true;
        participant.rC_Giving__Track_Hard_Credits__c = true;
        participant.BirthDate = System.today().addYears(20);
        participant.rC_Bios__Active__c=true;
        insert participant;   
        participant.Community__c = community.id;
        update participant;    
        System.assertEquals([select NAME from RECORDTYPE where ID IN (SELECT RecordTYPEID FROM CONTACT WHERE ID=:participant.ID)].NAME, 'Participant');
         
                 
    }
    
     static void createTestData1(){
        	//create account and contact data
        Account acc = TestUtils.createAccount('testAcc',true);
        
        Account acc1 = TestUtils.createAccount('My Unit test Acc1', false);
        acc1.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Household').getRecordTypeId();
        insert acc1;
        
    	Account nationalOffice = TestUtils.createAccount('National Office1', false);
        nationalOffice.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('National Office').getRecordTypeId();
        nationalOffice.National_Office_Id__c = '789';
        insert nationalOffice;
        
        Account localPartner = TestUtils.createAccount('Local Partner1', false);
        localPartner.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Local Partner').getRecordTypeId();
        localPartner.ParentId = nationalOffice.Id;
        localPartner.Local_Partner_ID__c = '1121185';
        insert localPartner;
         
         Account community2 =TestUtils.createAccount('Community', false);
        //community2.Name = 'Community';
        community2.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Community').getRecordTypeId();
        community2.ParentId = localPartner.Id;
        community2.Community_Id__c = '9912';
        insert community2;        
        
        //adding accounts into list
        accList = new List<Account>();
        accList.add(community2);
        String RT_ACC_CFUND=Schema.SObjectType.Account.getRecordTypeInfosByName().get('ChildFund').getRecordTypeId();
         Account chAccount = TestUtils.createAccountWithRT('Test Household Account1', RT_ACC_CFUND, acc, '666', '3843', false);
        chAccount.Alliance__c  = true;
        insert chAccount;
        
        Contact participant = TestUtils.createContact(null, 'Joe', 'Kid', false);
        
        participant.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Participant').getRecordTypeId();
  	    participant.rC_Sponsorship__Sponsorship_Status__c ='Reinstateable';//'Sponsored';
        participant.Correspondence_Paused__c = false;
        participant.Participant_Case_Number__c = '41114';
        participant.Accept_DF_Fee__c = true;
        participant.rC_Giving__Track_Hard_Credits__c = true;
        participant.BirthDate = System.today().addYears(20);
        participant.rC_Bios__Active__c=true;
        insert participant;   
        participant.Community__c = community2.id;
        update participant;    
        System.assertEquals([select NAME from RECORDTYPE where ID IN (SELECT RecordTYPEID FROM CONTACT WHERE ID=:participant.ID)].NAME, 'Participant');
               
    }
    
    
    
} // END public with sharing class MCSCPRRequestBatchTest